import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

import 'hang_breadcrumb.dart';

class AppHangWatchdogService {
  AppHangWatchdogService({
    Duration threshold = const Duration(seconds: 8),
    Duration heartbeatInterval = const Duration(seconds: 1),
    Duration checkInterval = const Duration(seconds: 1),
    Duration breadcrumbBeatFloor = const Duration(milliseconds: 50),
  }) : _threshold = threshold,
       _heartbeatInterval = heartbeatInterval,
       _checkInterval = checkInterval,
       _breadcrumbBeatFloor = breadcrumbBeatFloor;

  final Duration _threshold;
  final Duration _heartbeatInterval;
  final Duration _checkInterval;

  /// 两次「面包屑补发心跳」之间的最小间隔。
  ///
  /// 补发是为了把段落名的误差从一跳（1 秒）压到进段那一刻，见
  /// [HangBreadcrumb.onChanged]。但埋点万一下到了偏热的路径上，不节流就会
  /// 变成一条每秒上百次的 `port.send`。节流只保证不被打爆。
  final Duration _breadcrumbBeatFloor;

  Isolate? _isolate;
  SendPort? _sendPort;
  Timer? _heartbeatTimer;
  ReceivePort? _exitPort;
  Future<void>? _exitFuture;
  String? _sessionId;
  bool _running = false;
  int _lastBeatMs = 0;

  bool get isRunning => _running;

  Future<void> start({
    required String sessionId,
    required String hangEventsFilePath,
    required int maxFileBytes,
    required int maxRotatedFiles,
  }) async {
    if (_running) return;

    final readyPort = ReceivePort();
    final exitPort = ReceivePort();
    _sessionId = sessionId;

    try {
      _isolate = await Isolate.spawn<Map<String, Object?>>(
        _watchdogEntryPoint,
        <String, Object?>{
          'readyPort': readyPort.sendPort,
          'eventsFilePath': hangEventsFilePath,
          'sessionId': sessionId,
          'thresholdMs': _threshold.inMilliseconds,
          'checkIntervalMs': _checkInterval.inMilliseconds,
          'maxFileBytes': maxFileBytes,
          'maxRotatedFiles': maxRotatedFiles,
        },
        debugName: 'loveiwara-hang-watchdog',
        onExit: exitPort.sendPort,
      );

      _exitPort = exitPort;
      _exitFuture = exitPort.first.then((_) {});

      final first = await readyPort.first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (first is! SendPort) {
        throw StateError('Watchdog isolate did not return SendPort');
      }

      _sendPort = first;
      _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
        _sendHeartbeat();
      });
      // 关键段一开始就补一跳，卡死事件里的 section 才指得准。
      HangBreadcrumb.onChanged = _onBreadcrumbChanged;
      _sendHeartbeat();
      _running = true;
    } catch (e) {
      debugPrint('[HangWatchdog] Failed to start: $e');
      _detachBreadcrumb();
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _sendPort = null;
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
      _exitPort?.close();
      _exitPort = null;
      _exitFuture = null;
      _running = false;
    } finally {
      readyPort.close();
      if (!_running) {
        exitPort.close();
      }
    }
  }

  Future<void> stop() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _detachBreadcrumb();

    try {
      _sendPort?.send(<String, Object?>{'type': 'stop'});
    } catch (_) {}

    // Give the isolate a brief chance to flush and exit gracefully.
    // If it doesn't, force kill as a fallback.
    final exitFuture = _exitFuture;
    if (exitFuture != null) {
      try {
        await exitFuture.timeout(const Duration(milliseconds: 300));
      } catch (_) {
        // ignore and force kill below
      }
    }

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _exitPort?.close();
    _exitPort = null;
    _exitFuture = null;
    _sessionId = null;
    _running = false;
  }

  /// 关键段的栈顶换人了，补一跳。
  ///
  /// ⛔ 不能无条件补：埋点一旦落到偏热的路径上，这里就是每秒上百次 `port.send`。
  /// [_breadcrumbBeatFloor] 以内的变动攒着，等下一次周期心跳带走——段落名的误差
  /// 退回最多一跳，但看门狗不会被自己的埋点打爆。
  void _onBreadcrumbChanged() {
    if (!_running) return;
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    if (nowMs - _lastBeatMs < _breadcrumbBeatFloor.inMilliseconds) return;
    _sendHeartbeat();
  }

  void _detachBreadcrumb() {
    // 只摘自己挂的那个：单测里可能有另一个实例接了手。
    if (HangBreadcrumb.onChanged == _onBreadcrumbChanged) {
      HangBreadcrumb.onChanged = null;
    }
  }

  void _sendHeartbeat() {
    final port = _sendPort;
    final sessionId = _sessionId;
    if (port == null || sessionId == null) return;
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    _lastBeatMs = nowMs;
    final message = <String, Object?>{
      'type': 'heartbeat',
      'sessionId': sessionId,
      'ts': nowMs,
    };
    // 当时在干什么。没有关键段开着就不带这几项，看门狗那边按 null 处理。
    final breadcrumb = HangBreadcrumb.snapshot();
    if (breadcrumb != null) {
      message.addAll(breadcrumb);
    }
    port.send(message);
  }
}

@pragma('vm:entry-point')
void _watchdogEntryPoint(Map<String, Object?> args) {
  final readyPort = args['readyPort'] as SendPort;
  final eventsFilePath = args['eventsFilePath'] as String;
  final defaultSessionId = args['sessionId'] as String;
  final thresholdMs = args['thresholdMs'] as int? ?? 8000;
  final checkIntervalMs = args['checkIntervalMs'] as int? ?? 1000;
  final maxFileBytes = args['maxFileBytes'] as int? ?? (2 * 1024 * 1024);
  final maxRotatedFiles = args['maxRotatedFiles'] as int? ?? 2;

  final inbox = ReceivePort();
  readyPort.send(inbox.sendPort);

  final eventsFile = File(eventsFilePath);
  eventsFile.parent.createSync(recursive: true);

  int lastHeartbeatMs = DateTime.now().toUtc().millisecondsSinceEpoch;
  int? detectedAtMs;
  int? detectedLastHeartbeatMs;
  String activeSessionId = defaultSessionId;

  // 最后一条心跳捎来的「当时在干什么」。卡死事件里原样写出去——这是现场。
  String? lastSection;
  int? lastSectionSinceMs;
  int? lastSectionDepth;
  String? detectedSection;
  int? detectedSectionSinceMs;
  int? detectedSectionDepth;

  void appendEvent(Map<String, Object?> payload) {
    try {
      _rotateIfNeededSync(
        filePath: eventsFilePath,
        maxFileBytes: maxFileBytes,
        maxRotatedFiles: maxRotatedFiles,
      );
      final line = jsonEncode(payload);
      eventsFile.writeAsStringSync(
        '$line\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {}
  }

  void writeHangDetected() {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final stalledMs = nowMs - lastHeartbeatMs;
    detectedAtMs = nowMs;
    detectedLastHeartbeatMs = lastHeartbeatMs;
    detectedSection = lastSection;
    detectedSectionSinceMs = lastSectionSinceMs;
    detectedSectionDepth = lastSectionDepth;

    appendEvent(<String, Object?>{
      'type': 'hang_detected',
      'sessionId': activeSessionId,
      'detectedAt': DateTime.fromMillisecondsSinceEpoch(
        nowMs,
        isUtc: true,
      ).toIso8601String(),
      'lastHeartbeatAt': DateTime.fromMillisecondsSinceEpoch(
        lastHeartbeatMs,
        isUtc: true,
      ).toIso8601String(),
      'stalledMs': stalledMs,
      // ⛔ `section` 是**最后一条心跳当时**在跑的那一段，不是「卡死在这里」的
      // 断言：段落可能在那一跳之后正常结束，然后卡在别处。`sectionSinceMs` 也
      // 是那一跳时的读数，真正跑了多久还要加上 `stalledMs`。
      'section': ?lastSection,
      'sectionSinceMs': ?lastSectionSinceMs,
      'sectionDepth': ?lastSectionDepth,
    });
  }

  void writeHangRecovered(int recoverHeartbeatMs) {
    final startedAtMs = detectedAtMs;
    if (startedAtMs == null) return;
    final lastBeatBeforeHangMs = detectedLastHeartbeatMs ?? startedAtMs;
    final stalledMs = recoverHeartbeatMs - lastBeatBeforeHangMs;
    appendEvent(<String, Object?>{
      'type': 'hang_recovered',
      'sessionId': activeSessionId,
      'detectedAt': DateTime.fromMillisecondsSinceEpoch(
        startedAtMs,
        isUtc: true,
      ).toIso8601String(),
      'lastHeartbeatAt': detectedLastHeartbeatMs != null
          ? DateTime.fromMillisecondsSinceEpoch(
              detectedLastHeartbeatMs!,
              isUtc: true,
            ).toIso8601String()
          : null,
      'recoveredAt': DateTime.fromMillisecondsSinceEpoch(
        recoverHeartbeatMs,
        isUtc: true,
      ).toIso8601String(),
      'stalledMs': stalledMs < 0 ? 0 : stalledMs,
      // 恢复事件里带的是**卡住时**那一段，不是恢复后的那一段——那才是要查的。
      'section': ?detectedSection,
      'sectionSinceMs': ?detectedSectionSinceMs,
      'sectionDepth': ?detectedSectionDepth,
    });
    detectedAtMs = null;
    detectedLastHeartbeatMs = null;
    detectedSection = null;
    detectedSectionSinceMs = null;
    detectedSectionDepth = null;
  }

  final timer = Timer.periodic(Duration(milliseconds: checkIntervalMs), (_) {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final stalledMs = nowMs - lastHeartbeatMs;
    if (detectedAtMs == null && stalledMs >= thresholdMs) {
      writeHangDetected();
    }
  });

  inbox.listen((message) {
    if (message is! Map) return;
    final type = message['type'] as String?;
    if (type == 'stop') {
      timer.cancel();
      inbox.close();
      Isolate.exit();
    }
    if (type == 'heartbeat') {
      final nextSessionId = message['sessionId'] as String?;
      if (nextSessionId != null && nextSessionId.isNotEmpty) {
        activeSessionId = nextSessionId;
      }
      final ts =
          message['ts'] as int? ??
          DateTime.now().toUtc().millisecondsSinceEpoch;
      if (detectedAtMs != null) {
        // ⛔ 先写恢复事件再更新 lastSection：恢复事件要带的是**卡住时**那一段。
        writeHangRecovered(ts);
      }
      lastHeartbeatMs = ts;
      lastSection = message['section'] as String?;
      lastSectionSinceMs = message['sectionSinceMs'] as int?;
      lastSectionDepth = message['sectionDepth'] as int?;
    }
  });
}

void _rotateIfNeededSync({
  required String filePath,
  required int maxFileBytes,
  required int maxRotatedFiles,
}) {
  try {
    final current = File(filePath);
    if (!current.existsSync()) return;
    if (current.lengthSync() < maxFileBytes) return;

    if (maxRotatedFiles <= 1) {
      current.writeAsStringSync('');
      return;
    }

    final oldest = File('$filePath.${maxRotatedFiles - 1}');
    if (oldest.existsSync()) {
      oldest.deleteSync();
    }

    for (int i = maxRotatedFiles - 2; i >= 1; i--) {
      final rotated = File('$filePath.$i');
      if (rotated.existsSync()) {
        rotated.renameSync('$filePath.${i + 1}');
      }
    }

    current.renameSync('$filePath.1');
    File(filePath).createSync(recursive: true);
  } catch (_) {}
}
