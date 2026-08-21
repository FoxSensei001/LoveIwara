import 'dart:convert';

enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warning(2, 'WARN'),
  error(3, 'ERROR'),
  fatal(4, 'FATAL');

  const LogLevel(this.value, this.label);
  final int value;
  final String label;

  static LogLevel fromLabelOrDefault(String? raw, LogLevel fallback) {
    if (raw == null || raw.isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    for (final level in LogLevel.values) {
      if (level.label == normalized) return level;
    }
    return fallback;
  }
}

class LogPolicy {
  final bool enabled;
  final bool persistenceEnabled;
  final LogLevel minLevel;
  final int maxFileBytes;
  final int maxRotatedFiles;
  final int maxLogsPerSecond;
  final int hangEventsMaxFileBytes;
  final int hangEventsMaxRotatedFiles;

  const LogPolicy({
    required this.enabled,
    required this.persistenceEnabled,
    required this.minLevel,
    required this.maxFileBytes,
    required this.maxRotatedFiles,
    required this.maxLogsPerSecond,
    required this.hangEventsMaxFileBytes,
    required this.hangEventsMaxRotatedFiles,
  });

  factory LogPolicy.defaults({required bool isProduction}) {
    return LogPolicy(
      enabled: true,
      persistenceEnabled: true,
      minLevel: isProduction ? LogLevel.info : LogLevel.debug,
      maxFileBytes: LogConstants.defaultMaxFileBytes,
      maxRotatedFiles: LogConstants.defaultMaxRotatedFiles,
      maxLogsPerSecond: LogConstants.defaultMaxLogsPerSecond,
      hangEventsMaxFileBytes: LogConstants.defaultHangEventsMaxFileBytes,
      hangEventsMaxRotatedFiles: LogConstants.defaultHangEventsMaxRotatedFiles,
    );
  }

  LogPolicy normalized() {
    return copyWith(
      persistenceEnabled: enabled ? persistenceEnabled : false,
      maxFileBytes: _clampInt(
        maxFileBytes,
        min: 256 * 1024,
        max: 50 * 1024 * 1024,
      ),
      maxRotatedFiles: _clampInt(maxRotatedFiles, min: 1, max: 10),
      maxLogsPerSecond: _clampInt(maxLogsPerSecond, min: 10, max: 1000),
      hangEventsMaxFileBytes: _clampInt(
        hangEventsMaxFileBytes,
        min: 128 * 1024,
        max: 20 * 1024 * 1024,
      ),
      hangEventsMaxRotatedFiles: _clampInt(
        hangEventsMaxRotatedFiles,
        min: 1,
        max: 10,
      ),
    );
  }

  LogPolicy copyWith({
    bool? enabled,
    bool? persistenceEnabled,
    LogLevel? minLevel,
    int? maxFileBytes,
    int? maxRotatedFiles,
    int? maxLogsPerSecond,
    int? hangEventsMaxFileBytes,
    int? hangEventsMaxRotatedFiles,
  }) {
    return LogPolicy(
      enabled: enabled ?? this.enabled,
      persistenceEnabled: persistenceEnabled ?? this.persistenceEnabled,
      minLevel: minLevel ?? this.minLevel,
      maxFileBytes: maxFileBytes ?? this.maxFileBytes,
      maxRotatedFiles: maxRotatedFiles ?? this.maxRotatedFiles,
      maxLogsPerSecond: maxLogsPerSecond ?? this.maxLogsPerSecond,
      hangEventsMaxFileBytes:
          hangEventsMaxFileBytes ?? this.hangEventsMaxFileBytes,
      hangEventsMaxRotatedFiles:
          hangEventsMaxRotatedFiles ?? this.hangEventsMaxRotatedFiles,
    );
  }

  static int _clampInt(int value, {required int min, required int max}) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'persistenceEnabled': persistenceEnabled,
      'minLevel': minLevel.label,
      'maxFileBytes': maxFileBytes,
      'maxRotatedFiles': maxRotatedFiles,
      'maxLogsPerSecond': maxLogsPerSecond,
      'hangEventsMaxFileBytes': hangEventsMaxFileBytes,
      'hangEventsMaxRotatedFiles': hangEventsMaxRotatedFiles,
    };
  }
}

class LogEvent {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final String? error;
  final String? stackTrace;
  final String sessionId;

  LogEvent({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
    required this.sessionId,
  });

  String toJsonLine() {
    final map = <String, dynamic>{
      'ts': timestamp.toUtc().toIso8601String(),
      'level': level.label,
      'tag': tag,
      'msg': message,
      'sid': sessionId,
    };
    if (error != null) map['err'] = error;
    if (stackTrace != null) map['stack'] = stackTrace;
    return jsonEncode(map);
  }

  static LogEvent? fromJsonLine(String line) {
    try {
      final map = jsonDecode(line) as Map<String, dynamic>;
      return LogEvent(
        timestamp: DateTime.parse(map['ts'] as String),
        level: LogLevel.values.firstWhere(
          (l) => l.label == map['level'],
          orElse: () => LogLevel.info,
        ),
        tag: map['tag'] as String? ?? '',
        message: map['msg'] as String? ?? '',
        error: map['err'] as String?,
        stackTrace: map['stack'] as String?,
        sessionId: map['sid'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

class FatalErrorSnapshot {
  final DateTime timestamp;
  final String sessionId;
  final String source;
  final String message;
  final String? error;
  final String? stackTrace;

  FatalErrorSnapshot({
    required this.timestamp,
    required this.sessionId,
    required this.source,
    required this.message,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'timestamp': timestamp.toUtc().toIso8601String(),
      'sessionId': sessionId,
      'source': source,
      'message': message,
    };
    if (error != null) map['error'] = error;
    if (stackTrace != null) map['stackTrace'] = stackTrace;
    return map;
  }

  static FatalErrorSnapshot? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final tsRaw = raw['timestamp'] as String?;
    final sessionId = raw['sessionId'] as String?;
    final source = raw['source'] as String?;
    final message = raw['message'] as String?;
    if (tsRaw == null ||
        sessionId == null ||
        source == null ||
        message == null) {
      return null;
    }
    final ts = DateTime.tryParse(tsRaw);
    if (ts == null) return null;
    return FatalErrorSnapshot(
      timestamp: ts,
      sessionId: sessionId,
      source: source,
      message: message,
      error: raw['error'] as String?,
      stackTrace: raw['stackTrace'] as String?,
    );
  }
}

class HangEventSnapshot {
  final String type;
  final String sessionId;
  final DateTime detectedAt;
  final DateTime? lastHeartbeatAt;
  final DateTime? recoveredAt;
  final int stalledMs;

  HangEventSnapshot({
    required this.type,
    required this.sessionId,
    required this.detectedAt,
    required this.stalledMs,
    this.lastHeartbeatAt,
    this.recoveredAt,
  });

  bool get recovered => recoveredAt != null || type == 'hang_recovered';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'sessionId': sessionId,
      'detectedAt': detectedAt.toUtc().toIso8601String(),
      'stalledMs': stalledMs,
    };
    if (lastHeartbeatAt != null) {
      map['lastHeartbeatAt'] = lastHeartbeatAt!.toUtc().toIso8601String();
    }
    if (recoveredAt != null) {
      map['recoveredAt'] = recoveredAt!.toUtc().toIso8601String();
    }
    return map;
  }

  static HangEventSnapshot? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final type = raw['type'] as String?;
    final sessionId = raw['sessionId'] as String?;
    final detectedAtRaw = raw['detectedAt'] as String?;
    if (type == null || sessionId == null || detectedAtRaw == null) return null;

    final detectedAt = DateTime.tryParse(detectedAtRaw);
    if (detectedAt == null) return null;

    final stalledRaw = raw['stalledMs'];
    final stalledMs = switch (stalledRaw) {
      int v => v,
      num v => v.toInt(),
      _ => 0,
    };

    final lastHeartbeatRaw = raw['lastHeartbeatAt'] as String?;
    final recoveredAtRaw = raw['recoveredAt'] as String?;

    return HangEventSnapshot(
      type: type,
      sessionId: sessionId,
      detectedAt: detectedAt,
      stalledMs: stalledMs,
      lastHeartbeatAt: lastHeartbeatRaw != null
          ? DateTime.tryParse(lastHeartbeatRaw)
          : null,
      recoveredAt: recoveredAtRaw != null
          ? DateTime.tryParse(recoveredAtRaw)
          : null,
    );
  }
}

class CrashRecoveryResult {
  final bool hadUncleanExit;
  final String? previousSessionId;
  final DateTime? previousStartTime;
  final String? previousVersion;
  final FatalErrorSnapshot? fatalError;
  final HangEventSnapshot? lastHangEvent;

  CrashRecoveryResult({
    required this.hadUncleanExit,
    this.previousSessionId,
    this.previousStartTime,
    this.previousVersion,
    this.fatalError,
    this.lastHangEvent,
  });

  factory CrashRecoveryResult.clean() =>
      CrashRecoveryResult(hadUncleanExit: false);
}

class LogHealthSnapshot {
  final bool enabled;
  final bool persistenceEnabled;
  final int droppedCount;
  final int droppedByDisabled;
  final int droppedByMinLevel;
  final int droppedByProcessor;
  final int queueDepth;
  final int ringDepth;
  final int processorSuppressedCount;
  final int processorRateLimitedCount;
  final int flushCount;
  final int flushFailureCount;
  final int? lastFlushLatencyMs;
  final DateTime? lastFlushAt;
  final int currentLogFileBytes;
  final bool sinkDegraded;
  final int exportFailCount;
  final DateTime? lastExportAt;
  final int lastExportBytes;

  const LogHealthSnapshot({
    required this.enabled,
    required this.persistenceEnabled,
    required this.droppedCount,
    required this.droppedByDisabled,
    required this.droppedByMinLevel,
    required this.droppedByProcessor,
    required this.queueDepth,
    required this.ringDepth,
    required this.processorSuppressedCount,
    required this.processorRateLimitedCount,
    required this.flushCount,
    required this.flushFailureCount,
    required this.lastFlushLatencyMs,
    required this.lastFlushAt,
    required this.currentLogFileBytes,
    required this.sinkDegraded,
    required this.exportFailCount,
    required this.lastExportAt,
    required this.lastExportBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'persistenceEnabled': persistenceEnabled,
      'droppedCount': droppedCount,
      'droppedByDisabled': droppedByDisabled,
      'droppedByMinLevel': droppedByMinLevel,
      'droppedByProcessor': droppedByProcessor,
      'queueDepth': queueDepth,
      'ringDepth': ringDepth,
      'processorSuppressedCount': processorSuppressedCount,
      'processorRateLimitedCount': processorRateLimitedCount,
      'flushCount': flushCount,
      'flushFailureCount': flushFailureCount,
      'lastFlushLatencyMs': lastFlushLatencyMs,
      'lastFlushAt': lastFlushAt?.toUtc().toIso8601String(),
      'currentLogFileBytes': currentLogFileBytes,
      'sinkDegraded': sinkDegraded,
      'exportFailCount': exportFailCount,
      'lastExportAt': lastExportAt?.toUtc().toIso8601String(),
      'lastExportBytes': lastExportBytes,
    };
  }
}

abstract class LogConstants {
  static const int defaultMaxFileBytes = 5 * 1024 * 1024;
  static const int defaultMaxRotatedFiles = 3;
  static const int ringBufferCapacity = 500;
  static const int defaultMaxLogsPerSecond = 100;
  static const Duration dedupWindowDuration = Duration(seconds: 5);
  static const String logFileName = 'app.log';
  static const String crashMarkerFileName = 'crash_marker.json';
  static const int flushBatchSize = 50;
  static const Duration flushInterval = Duration(milliseconds: 300);
  static const int highWaterMark = 5000;

  /// 触发裁剪后回落到的条数目标。留出迟滞区间，使 O(n) 的裁剪从「每次 push 都跑」
  /// 摊薄成「每 (highWaterMark - writeQueueTrimTarget) 次 push 跑一次」。
  static const int writeQueueTrimTarget = 3500;

  /// 写队列的**字符数**上限（UTF-16 码元，即 `String.length`），不是字节数。
  ///
  /// 只限条数是不够的：单条最大 message 2000 + err 1000 + stack 2000 字符，
  /// 5000 条最坏堆到 2500 万码元；Dart 的字符串按码元计费（非 ASCII 走
  /// TwoByteString，2 字节/码元），也就是约 50MB 常驻堆。
  ///
  /// 刻意不换算成 UTF-8 字节：这个上限管的是**内存**，而堆占用本来就按码元算；
  /// 换成字节还得为每条日志多编码一遍（push 一次、落盘再一次），正是本模块一路
  /// 在消灭的那类开销。
  static const int maxWriteQueueChars = 4 * 1024 * 1024;
  static const int writeQueueCharsTrimTarget = 3 * 1024 * 1024;

  /// 退出时等待落盘的上限。超时就放弃队列尾巴，绝不把退出流程挂死。
  static const Duration exitFlushTimeout = Duration(seconds: 2);

  /// error 触发落盘的合并窗口。一次网络错误风暴会产生大量互不相同的 error，
  /// 逐条 fsync 会把事件循环钉死；窗口内的 error 合并成一次 fsync。
  /// fatal 不走这条路径，仍由 appendEmergencySync 同步落盘。
  static const Duration errorFlushDebounce = Duration(milliseconds: 50);

  /// 单次 immediate flush 最多连续写几批，避免一口气做几十次 fsync。
  /// 剩余部分由周期 flush 接手。
  static const int maxImmediateFlushBatches = 8;
  static const String fatalSnapshotFileName = 'last_fatal.json';
  static const String hangEventsFileName = 'hang_events.jsonl';
  static const int defaultHangEventsMaxFileBytes = 2 * 1024 * 1024;
  static const int defaultHangEventsMaxRotatedFiles = 2;
}
