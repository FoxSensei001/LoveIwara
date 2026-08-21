import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'log_models.dart';
import 'log_paths.dart';
import 'log_processor.dart';
import 'log_buffer.dart';
import 'log_file_sink.dart';
import 'log_export_service.dart';
import 'crash_detection_service.dart';
import 'app_hang_watchdog_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';

class LogService extends GetxService {
  late LogProcessor _processor;
  late LogBuffer _buffer;
  late LogFileSink _sink;
  late LogExportService _export;
  late CrashDetectionService _crash;
  late AppHangWatchdogService _hangWatchdog;
  late LogPaths _paths;
  late String _sessionId;
  late LogPolicy _policy;

  Timer? _flushTimer;
  Timer? _errorFlushTimer;
  bool _initialized = false;

  /// 在途的那次落盘。用 future 而不是 bool：并发调用要能**等**到它结束，
  /// 而不是被静默丢弃——退出路径 close() 正是靠这个保证日志真的写出去了。
  Future<void>? _flushInFlight;

  /// 在途那次是不是「强制落盘」（forceFlush + 多批排干）。合流时要用它判断
  /// 能不能安全搭车，见 [_flushBuffer]。
  bool _inFlightIsImmediate = false;

  /// 在途那次是不是「不封顶」（maxBatches == null，一次排干）。
  /// 必须和 [_inFlightIsImmediate] 分开记：一个封顶 8 批的 immediate flush
  /// **无法**满足 close()/export 的「必须排干」要求，合流进去就会丢队列尾巴。
  bool _inFlightUncapped = false;
  int _droppedCount = 0;
  int _droppedByDisabled = 0;
  int _droppedByMinLevel = 0;
  int _droppedByProcessor = 0;
  int _flushCount = 0;
  int _flushFailureCount = 0;
  int? _lastFlushLatencyMs;
  DateTime? _lastFlushAt;

  CrashDetectionService get crash => _crash;
  bool get isInitialized => _initialized;
  String get sessionId => _sessionId;
  LogPolicy get policy => _policy;

  /// [paths] / [sink] 仅供测试注入；生产一律走 [LogPaths.resolve]（依赖
  /// path_provider 插件）和自建的 [LogFileSink]。
  ///
  /// [sink] 存在的理由：flush 的并发协调（在途合流、批次封顶、error 合并窗口、
  /// 退出排干）只有在写盘耗时可控时才能确定性地构造出时序，而真实文件写在
  /// 临时目录里快到撞不出竞态。
  Future<LogService> init({
    LogPolicy? policy,
    LogPaths? paths,
    LogFileSink? sink,
  }) async {
    _sessionId = const Uuid().v4();
    _paths = paths ?? await LogPaths.resolve();
    _policy = (policy ?? LogPolicy.defaults(isProduction: kReleaseMode))
        .normalized();
    _processor = LogProcessor(maxLogsPerSecond: _policy.maxLogsPerSecond);
    _buffer = LogBuffer();
    _sink = sink ?? LogFileSink(_paths);
    _sink.applyPolicy(
      maxFileBytes: _policy.maxFileBytes,
      maxRotatedFiles: _policy.maxRotatedFiles,
    );
    _crash = CrashDetectionService(_paths);
    _hangWatchdog = AppHangWatchdogService();

    var recovery = CrashRecoveryResult.clean();
    if (_policy.persistenceEnabled) {
      recovery = await _crash.checkAndRecover();
    }

    if (recovery.hadUncleanExit) {
      _logInternal(
        LogLevel.warning,
        '检测到上次异常退出 (session: ${recovery.previousSessionId}, version: ${recovery.previousVersion})',
        'CrashRecovery',
      );
    }

    _export = LogExportService(
      paths: _paths,
      sink: _sink,
      crash: _crash,
      sessionId: _sessionId,
      healthMetaProvider: _buildExportHealthMeta,
    );

    await _syncPersistenceSubsystems();

    _flushTimer = Timer.periodic(LogConstants.flushInterval, (_) {
      unawaited(_flushBuffer());
    });

    _initialized = true;
    return this;
  }

  static LogPolicy policyFromConfig(
    ConfigService? config, {
    required bool isProduction,
  }) {
    final defaults = LogPolicy.defaults(isProduction: isProduction);
    if (config == null) return defaults;

    final minLevelRaw = config[ConfigKey.LOG_MIN_LEVEL] as String?;
    final minLevel = LogLevel.fromLabelOrDefault(
      minLevelRaw,
      defaults.minLevel,
    );

    final maxFileMb = _asInt(
      config[ConfigKey.LOG_MAX_FILE_MB],
      defaults.maxFileBytes ~/ (1024 * 1024),
    );
    final maxHangMb = _asInt(
      config[ConfigKey.LOG_HANG_MAX_FILE_MB],
      defaults.hangEventsMaxFileBytes ~/ (1024 * 1024),
    );

    return defaults
        .copyWith(
          enabled: _asBool(config[ConfigKey.LOGGING_ENABLED], defaults.enabled),
          persistenceEnabled: _asBool(
            config[ConfigKey.LOG_PERSISTENCE_ENABLED],
            defaults.persistenceEnabled,
          ),
          minLevel: minLevel,
          maxFileBytes: maxFileMb * 1024 * 1024,
          maxRotatedFiles: _asInt(
            config[ConfigKey.LOG_MAX_ROTATED_FILES],
            defaults.maxRotatedFiles,
          ),
          maxLogsPerSecond: _asInt(
            config[ConfigKey.LOG_MAX_LOGS_PER_SECOND],
            defaults.maxLogsPerSecond,
          ),
          hangEventsMaxFileBytes: maxHangMb * 1024 * 1024,
          hangEventsMaxRotatedFiles: _asInt(
            config[ConfigKey.LOG_HANG_MAX_ROTATED_FILES],
            defaults.hangEventsMaxRotatedFiles,
          ),
        )
        .normalized();
  }

  Future<void> applyPolicy(LogPolicy policy) async {
    final next = policy.normalized();
    if (!_initialized) {
      _policy = next;
      return;
    }
    final previous = _policy;
    _policy = next;

    _processor.updateRateLimit(next.maxLogsPerSecond);
    _sink.applyPolicy(
      maxFileBytes: next.maxFileBytes,
      maxRotatedFiles: next.maxRotatedFiles,
    );

    if (previous.persistenceEnabled != next.persistenceEnabled) {
      await _syncPersistenceSubsystems();
      if (!next.persistenceEnabled) {
        _buffer.clearWriteQueue();
      }
    }
  }

  static int _asInt(dynamic raw, int fallback) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? fallback;
    return fallback;
  }

  static bool _asBool(dynamic raw, bool fallback) {
    if (raw is bool) return raw;
    if (raw is String) {
      final normalized = raw.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  /// [errorText] / [stackTraceText] 供调用方复用**已经**字符串化过的结果。
  /// AOT 下 `StackTrace.toString()` 需要符号化，是重操作；调用方（LogUtils.e）
  /// 为了拼控制台输出已经转过一次，这里不能再转第二次。
  void log({
    required LogLevel level,
    required String message,
    String tag = 'i_iwara',
    Object? error,
    StackTrace? stackTrace,
    String? errorText,
    String? stackTraceText,
  }) {
    if (!_initialized) {
      _consoleFallback(level, message, tag, error, stackTrace);
      return;
    }
    if (!_policy.enabled) {
      _droppedCount++;
      _droppedByDisabled++;
      return;
    }
    if (level.value < _policy.minLevel.value) {
      _droppedCount++;
      _droppedByMinLevel++;
      return;
    }

    final event = LogEvent(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: errorText ?? error?.toString(),
      stackTrace: stackTraceText ?? stackTrace?.toString(),
      sessionId: _sessionId,
    );

    final processed = _processor.process(event);
    if (processed == null) {
      _droppedCount++;
      _droppedByProcessor++;
      return;
    }

    if (_policy.persistenceEnabled) {
      _buffer.push(processed);
    } else {
      _buffer.pushToRingOnly(processed);
    }

    if (_policy.persistenceEnabled && level.value >= LogLevel.error.value) {
      _scheduleErrorFlush();
    }
  }

  /// 把窗口内的多条 error 合并成一次强制落盘。逐条 `flush: true` 就是逐条
  /// fsync，一波网络错误能连做几十次同步 I/O。fatal 不依赖这里——它走
  /// [captureUnhandledError] 的 `appendEmergencySync` 当场同步落盘。
  void _scheduleErrorFlush() {
    if (_errorFlushTimer?.isActive ?? false) return;
    _errorFlushTimer = Timer(LogConstants.errorFlushDebounce, () {
      unawaited(_flushBuffer(immediate: true));
    });
  }

  /// 把队列**全部**落盘后才返回（不受 immediate 的批次封顶约束）。
  /// 退出路径和导出路径都依赖这个保证。
  ///
  /// 「在途的那次不够强就挂到它后面重跑」的逻辑收在 [_flushBuffer] 里，
  /// 这里不要再自己 `await _flushInFlight` —— 那样等于把同一套判定写两遍，
  /// 而且中间那段空隙会被别的 flush 抢先占住 `_flushInFlight`。
  Future<void> flush() => _flushBuffer(immediate: true, maxBatches: null);

  /// 同步标记本次为正常退出。退出编排方（桌面 onWindowClose / 移动端 detached）
  /// 应在 flush / 停 watchdog / 关库等慢操作**之前**第一时间调用，使后续清理
  /// 无论超时还是被杀都不会误报崩溃。详见 [CrashDetectionService.markCleanExitSync]。
  void markCleanExitSync() {
    if (!_initialized) return;
    _crash.markCleanExitSync();
  }

  Future<void> close() async {
    if (!_initialized) return;
    _flushTimer?.cancel();
    _errorFlushTimer?.cancel();
    // 注意：正常退出路径已在 close() 之前通过 markCleanExitSync() 同步删除了
    // 崩溃标记，因此这里 _stopPersistenceSubsystems 里的 markCleanExit 多为
    // 幂等的二次删除。close() 自身仍保持「先 flush 再停子系统」的顺序，作为
    // 未提前标记的直接调用方的兜底（先把日志落盘）。
    if (_policy.persistenceEnabled) {
      // 加超时：写盘 syscall 若卡住（存储被卸载 / 网络挂载盘），flush 的 future
      // 永不完成，退出路径就会无限 await——桌面端表现为窗口关不掉。
      // 宁可丢掉队列尾巴，也不能把退出流程挂死。
      await flush().timeout(
        LogConstants.exitFlushTimeout,
        onTimeout: () {
          debugPrint('[LogService] Exit flush timed out, abandoning queue');
        },
      );
    } else {
      _buffer.clearWriteQueue();
    }
    await _stopPersistenceSubsystems();
    _initialized = false;
  }

  List<LogEvent> getRecentLogs({int? count}) {
    if (!_initialized) return [];
    return _buffer.getRecent(count: count);
  }

  Future<File> exportLogs() async {
    await flush();
    return _export.exportLogs();
  }

  CrashRecoveryResult? get lastCrashInfo => _crash.lastResult;

  Future<LogHealthSnapshot> getHealthSnapshot() async {
    if (!_initialized) {
      return const LogHealthSnapshot(
        enabled: false,
        persistenceEnabled: false,
        droppedCount: 0,
        droppedByDisabled: 0,
        droppedByMinLevel: 0,
        droppedByProcessor: 0,
        queueDepth: 0,
        ringDepth: 0,
        processorSuppressedCount: 0,
        processorRateLimitedCount: 0,
        flushCount: 0,
        flushFailureCount: 0,
        lastFlushLatencyMs: null,
        lastFlushAt: null,
        currentLogFileBytes: 0,
        sinkDegraded: false,
        exportFailCount: 0,
        lastExportAt: null,
        lastExportBytes: 0,
      );
    }

    final currentBytes = _policy.persistenceEnabled
        ? await _sink.currentFileSize()
        : 0;

    return LogHealthSnapshot(
      enabled: _policy.enabled,
      persistenceEnabled: _policy.persistenceEnabled,
      droppedCount: _droppedCount,
      droppedByDisabled: _droppedByDisabled,
      droppedByMinLevel: _droppedByMinLevel,
      droppedByProcessor: _droppedByProcessor,
      queueDepth: _buffer.writeQueueLength,
      ringDepth: _buffer.ringBufferLength,
      processorSuppressedCount: _processor.suppressedCount,
      processorRateLimitedCount: _processor.rateLimitedCount,
      flushCount: _flushCount,
      flushFailureCount: _flushFailureCount,
      lastFlushLatencyMs: _lastFlushLatencyMs,
      lastFlushAt: _lastFlushAt,
      currentLogFileBytes: currentBytes,
      sinkDegraded: _sink.isDegraded,
      exportFailCount: _export.exportFailCount,
      lastExportAt: _export.lastExportAt,
      lastExportBytes: _export.lastExportBytes,
    );
  }

  Future<Map<String, dynamic>> _buildExportHealthMeta() async {
    final snapshot = await getHealthSnapshot();
    return {
      'sessionId': _sessionId,
      'policy': _policy.toJson(),
      'health': snapshot.toJson(),
    };
  }

  void captureUnhandledError({
    required String source,
    required String message,
    required Object error,
    required StackTrace stackTrace,
    String tag = 'GlobalError',
  }) {
    if (!_initialized) {
      _consoleFallback(LogLevel.fatal, message, tag, error, stackTrace);
      return;
    }
    if (!_policy.enabled) {
      _droppedCount++;
      _droppedByDisabled++;
      return;
    }
    if (LogLevel.fatal.value < _policy.minLevel.value) {
      _droppedCount++;
      _droppedByMinLevel++;
      return;
    }

    final event = LogEvent(
      timestamp: DateTime.now(),
      level: LogLevel.fatal,
      tag: tag,
      message: message,
      error: error.toString(),
      stackTrace: stackTrace.toString(),
      sessionId: _sessionId,
    );

    // fatal 即使被去重返回 null，也必须脱敏后再落盘，不能回退到原始事件。
    final processed =
        _processor.process(event) ?? _processor.sanitizeEvent(event);
    _buffer.pushToRingOnly(processed);
    if (_policy.persistenceEnabled) {
      _sink.appendEmergencySync(processed.toJsonLine());
      _crash.recordFatalErrorSync(
        sessionId: _sessionId,
        source: source,
        message: processed.message,
        error: processed.error,
        stackTrace: processed.stackTrace,
      );
    }
  }

  /// [maxBatches] 为 null 表示不封顶（退出/导出路径用），
  /// 否则最多连续写这么多批就交还事件循环。
  Future<void> _flushBuffer({
    bool immediate = false,
    int? maxBatches = LogConstants.maxImmediateFlushBatches,
  }) {
    final inFlight = _flushInFlight;
    // 同一时刻只允许一次写盘；后来者直接合流到在途那次，而不是被静默丢弃。
    if (inFlight != null) {
      // 只有当在途那次**至少和本次一样强**时才能安全搭车，两个维度都要看：
      //
      // - immediate：普通周期 flush 是 forceFlush=false 且只写一批就 break，
      //   合流进去这条 error 的 fsync 会被整个跳过，而 _errorFlushTimer 已经
      //   fire、没有任何重排机制。
      // - uncapped：一个封顶 8 批的 immediate flush 满足不了 close()/export
      //   的「必须排干」要求，合流进去队列 >1600 条时会丢尾巴。
      //
      // 不满足就挂到它后面重跑一次。whenComplete 的注册早于这里的 then，
      // 所以续体跑到时 _flushInFlight 已被清空，会开一次全新的 flush。
      final needsStronger =
          (immediate && !_inFlightIsImmediate) ||
          (maxBatches == null && !_inFlightUncapped);
      if (needsStronger) {
        return inFlight.then(
          (_) => _flushBuffer(immediate: immediate, maxBatches: maxBatches),
        );
      }
      return inFlight;
    }
    if (!_initialized || !_buffer.hasItemsToFlush) return Future<void>.value();
    if (!_policy.persistenceEnabled) {
      _buffer.clearWriteQueue();
      return Future<void>.value();
    }

    final future = _runFlush(immediate: immediate, maxBatches: maxBatches);
    _flushInFlight = future;
    _inFlightIsImmediate = immediate;
    _inFlightUncapped = maxBatches == null;
    future.whenComplete(() {
      if (identical(_flushInFlight, future)) {
        _flushInFlight = null;
        _inFlightIsImmediate = false;
        _inFlightUncapped = false;
      }
    });
    return future;
  }

  Future<void> _runFlush({
    required bool immediate,
    required int? maxBatches,
  }) async {
    final stopwatch = Stopwatch()..start();
    var wroteAny = false;
    var hadFailure = false;
    var batches = 0;
    try {
      while (_buffer.hasItemsToFlush) {
        final batchSize = immediate ? 200 : LogConstants.flushBatchSize;
        final batch = _buffer.drain(maxItems: batchSize);
        if (batch.isEmpty) break;

        final ok = await _sink.appendBatch(
          batch.map((e) => e.line),
          forceFlush: immediate,
        );
        if (!ok) {
          hadFailure = true;
          _buffer.requeueFront(batch);
          break;
        }
        wroteAny = true;

        if (!immediate) break;

        // 封顶：immediate 时每批都带 fsync，队列积压时不封顶能一口气做
        // 几十次同步 I/O 把事件循环钉死。剩余部分交给 300ms 周期 flush。
        // 退出/导出路径传 null，必须一次排干。
        if (maxBatches != null && ++batches >= maxBatches) break;
      }
    } catch (e) {
      hadFailure = true;
      debugPrint('[LogService] Flush failed: $e');
    } finally {
      stopwatch.stop();
      _lastFlushLatencyMs = stopwatch.elapsedMilliseconds;
      _lastFlushAt = DateTime.now();
      if (wroteAny) {
        _flushCount++;
      }
      if (hadFailure) {
        _flushFailureCount++;
      }
    }
  }

  void _logInternal(LogLevel level, String message, String tag) {
    final event = LogEvent(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      sessionId: _sessionId,
    );
    _buffer.push(event);
  }

  void _consoleFallback(
    LogLevel level,
    String message,
    String tag,
    Object? error,
    StackTrace? stackTrace,
  ) {
    debugPrint('[${level.label}][$tag] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  Stack: $stackTrace');
  }

  Future<void> _markAppStart() async {
    await _crash.markAppStart(
      sessionId: _sessionId,
      version: _getAppVersion(),
      platform: _getPlatformName(),
    );
  }

  Future<void> _syncPersistenceSubsystems() async {
    if (_policy.persistenceEnabled) {
      await _startPersistenceSubsystems();
    } else {
      await _stopPersistenceSubsystems();
    }
  }

  Future<void> _startPersistenceSubsystems() async {
    try {
      await _markAppStart();
      if (!_hangWatchdog.isRunning) {
        await _hangWatchdog.start(
          sessionId: _sessionId,
          hangEventsFilePath: _paths.hangEventsFile,
          maxFileBytes: _policy.hangEventsMaxFileBytes,
          maxRotatedFiles: _policy.hangEventsMaxRotatedFiles,
        );
      }
    } catch (e) {
      debugPrint('[LogService] Failed to start persistence subsystems: $e');
    }
  }

  Future<void> _stopPersistenceSubsystems() async {
    try {
      if (_hangWatchdog.isRunning) {
        await _hangWatchdog.stop();
      }
      await _crash.markCleanExit();
    } catch (e) {
      debugPrint('[LogService] Failed to stop persistence subsystems: $e');
    }
  }

  String _getPlatformName() {
    if (GetPlatform.isAndroid) return 'Android';
    if (GetPlatform.isIOS) return 'iOS';
    if (GetPlatform.isWindows) return 'Windows';
    if (GetPlatform.isMacOS) return 'macOS';
    if (GetPlatform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String _getAppVersion() {
    return CommonConstants.VERSION;
  }

  @override
  void onClose() {
    _flushTimer?.cancel();
    _errorFlushTimer?.cancel();
    if (_initialized) {
      unawaited(_stopPersistenceSubsystems());
    }
    super.onClose();
  }
}
