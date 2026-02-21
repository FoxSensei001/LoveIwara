import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

class AppHangWatchdogService {
  AppHangWatchdogService({
    Duration threshold = const Duration(seconds: 8),
    Duration heartbeatInterval = const Duration(seconds: 1),
    Duration checkInterval = const Duration(seconds: 1),
  }) : _threshold = threshold,
       _heartbeatInterval = heartbeatInterval,
       _checkInterval = checkInterval;

  final Duration _threshold;
  final Duration _heartbeatInterval;
  final Duration _checkInterval;

  Isolate? _isolate;
  SendPort? _sendPort;
  Timer? _heartbeatTimer;
  String? _sessionId;
  bool _running = false;

  bool get isRunning => _running;

  Future<void> start({
    required String sessionId,
    required String hangEventsFilePath,
    required int maxFileBytes,
    required int maxRotatedFiles,
  }) async {
    if (_running) return;

    final readyPort = ReceivePort();
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
      );

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
      _sendHeartbeat();
      _running = true;
    } catch (e) {
      debugPrint('[HangWatchdog] Failed to start: $e');
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _sendPort = null;
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
      _running = false;
    } finally {
      readyPort.close();
    }
  }

  Future<void> stop() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    try {
      _sendPort?.send(<String, Object?>{'type': 'stop'});
    } catch (_) {}

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _sessionId = null;
    _running = false;
  }

  void _sendHeartbeat() {
    final port = _sendPort;
    final sessionId = _sessionId;
    if (port == null || sessionId == null) return;
    port.send(<String, Object?>{
      'type': 'heartbeat',
      'sessionId': sessionId,
      'ts': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
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
    });
    detectedAtMs = null;
    detectedLastHeartbeatMs = null;
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
        writeHangRecovered(ts);
      }
      lastHeartbeatMs = ts;
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
