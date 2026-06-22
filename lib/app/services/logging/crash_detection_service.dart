import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'log_models.dart';
import 'log_paths.dart';

class CrashDetectionService {
  final LogPaths _paths;
  CrashRecoveryResult? _lastResult;

  CrashDetectionService(this._paths);

  CrashRecoveryResult? get lastResult => _lastResult;

  Future<void> markAppStart({
    required String sessionId,
    required String version,
    required String platform,
  }) async {
    try {
      final marker = File(_paths.crashMarkerFile);
      final data = jsonEncode({
        'sessionId': sessionId,
        'startTime': DateTime.now().toUtc().toIso8601String(),
        'version': version,
        'platform': platform,
      });
      await marker.writeAsString(data, flush: true);
    } catch (e) {
      debugPrint('[CrashDetection] Failed to write marker: $e');
    }
  }

  void recordFatalErrorSync({
    required String sessionId,
    required String source,
    required String message,
    String? error,
    String? stackTrace,
  }) {
    try {
      final snapshot = FatalErrorSnapshot(
        timestamp: DateTime.now().toUtc(),
        sessionId: sessionId,
        source: source,
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
      final file = File(_paths.fatalSnapshotFile);
      file.writeAsStringSync(jsonEncode(snapshot.toJson()), flush: true);
    } catch (e) {
      debugPrint('[CrashDetection] Failed to persist fatal snapshot: $e');
    }
  }

  Future<void> markCleanExit() async {
    try {
      final marker = File(_paths.crashMarkerFile);
      if (await marker.exists()) {
        await marker.delete();
      }
    } catch (e) {
      debugPrint('[CrashDetection] Failed to delete marker: $e');
    }
  }

  /// 同步删除崩溃标记。退出路径应在任何「慢且可被打断」的清理（flush、停
  /// watchdog、关库）之前调用：删除标记只是一次小文件操作，能在进程被杀或
  /// 超时退出前完成；而 [checkAndRecover] 仅在标记仍存在时才读取 fatal /
  /// hang 快照——删掉标记即让整个崩溃检测对本次关闭窗口失效，从而避免「正常
  /// 关闭但清理太慢/被杀」被误报为崩溃。与 [recordFatalErrorSync] 同样采用
  /// 同步 IO，理由一致：必须在临近退出时可靠落地。
  void markCleanExitSync() {
    try {
      final marker = File(_paths.crashMarkerFile);
      if (marker.existsSync()) {
        marker.deleteSync();
      }
    } catch (e) {
      debugPrint('[CrashDetection] Failed to delete marker (sync): $e');
    }
  }

  Future<CrashRecoveryResult> checkAndRecover() async {
    try {
      final marker = File(_paths.crashMarkerFile);
      if (!await marker.exists()) {
        _lastResult = CrashRecoveryResult.clean();
        return _lastResult!;
      }

      final content = await marker.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final previousSessionId = data['sessionId'] as String?;

      _lastResult = CrashRecoveryResult(
        hadUncleanExit: true,
        previousSessionId: previousSessionId,
        previousStartTime: data['startTime'] != null
            ? DateTime.tryParse(data['startTime'] as String)
            : null,
        previousVersion: data['version'] as String?,
        fatalError: await _readFatalSnapshot(previousSessionId),
        lastHangEvent: await _readLastHangEvent(previousSessionId),
      );

      return _lastResult!;
    } catch (e) {
      debugPrint('[CrashDetection] Recovery check failed: $e');
      _lastResult = CrashRecoveryResult.clean();
      return _lastResult!;
    }
  }

  Future<FatalErrorSnapshot?> _readFatalSnapshot(
    String? previousSessionId,
  ) async {
    try {
      final file = File(_paths.fatalSnapshotFile);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      final snapshot = FatalErrorSnapshot.fromJson(decoded);
      if (snapshot == null) return null;
      if (previousSessionId != null &&
          snapshot.sessionId != previousSessionId) {
        return null;
      }
      return snapshot;
    } catch (e) {
      debugPrint('[CrashDetection] Failed to read fatal snapshot: $e');
      return null;
    }
  }

  Future<HangEventSnapshot?> _readLastHangEvent(
    String? previousSessionId,
  ) async {
    try {
      final files = <File>[File(_paths.hangEventsFile)];
      for (int i = 1; i <= 20; i++) {
        final rotated = File('${_paths.hangEventsFile}.$i');
        if (!await rotated.exists()) break;
        files.add(rotated);
      }

      for (final file in files) {
        if (!await file.exists()) continue;
        final lines = await file.readAsLines();
        for (var i = lines.length - 1; i >= 0; i--) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final decoded = jsonDecode(line);
          final snapshot = HangEventSnapshot.fromJson(decoded);
          if (snapshot == null) continue;
          if (previousSessionId != null &&
              snapshot.sessionId != previousSessionId) {
            continue;
          }
          return snapshot;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[CrashDetection] Failed to read hang snapshot: $e');
      return null;
    }
  }
}
