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
  bool _initialized = false;
  bool _flushInProgress = false;
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

  Future<LogService> init({LogPolicy? policy}) async {
    _sessionId = const Uuid().v4();
    _paths = await LogPaths.resolve();
    _policy = (policy ?? LogPolicy.defaults(isProduction: kReleaseMode))
        .normalized();
    _processor = LogProcessor(maxLogsPerSecond: _policy.maxLogsPerSecond);
    _buffer = LogBuffer();
    _sink = LogFileSink(_paths);
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

    if (!_initialized) return;

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

  void log({
    required LogLevel level,
    required String message,
    String tag = 'i_iwara',
    Object? error,
    StackTrace? stackTrace,
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
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
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
      unawaited(_flushBuffer(immediate: true));
    }
  }

  Future<void> flush() async {
    await _flushBuffer(immediate: true);
  }

  Future<void> close() async {
    if (!_initialized) return;
    _flushTimer?.cancel();
    await _stopPersistenceSubsystems();
    if (_policy.persistenceEnabled) {
      await _flushBuffer(immediate: true);
    } else {
      _buffer.clearWriteQueue();
    }
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

    final processed = _processor.process(event) ?? event;
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

  Future<void> _flushBuffer({bool immediate = false}) async {
    if (!_initialized || !_buffer.hasItemsToFlush) return;
    if (!_policy.persistenceEnabled) {
      _buffer.clearWriteQueue();
      return;
    }
    if (_flushInProgress) return;

    _flushInProgress = true;
    final stopwatch = Stopwatch()..start();
    var wroteAny = false;
    var hadFailure = false;
    try {
      while (_buffer.hasItemsToFlush) {
        final batchSize = immediate ? 200 : LogConstants.flushBatchSize;
        final batch = _buffer.drain(maxItems: batchSize);
        if (batch.isEmpty) break;

        final ok = await _sink.appendBatch(batch, forceFlush: immediate);
        if (!ok) {
          hadFailure = true;
          _buffer.requeueFront(batch);
          break;
        }
        wroteAny = true;

        if (!immediate) break;
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
      _flushInProgress = false;
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
    if (_initialized) {
      unawaited(_stopPersistenceSubsystems());
    }
    super.onClose();
  }
}
