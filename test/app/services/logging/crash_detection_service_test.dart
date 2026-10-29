import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/crash_detection_service.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';
import 'package:i_iwara/app/services/logging/native_exit_info.dart';

void main() {
  group('CrashDetectionService', () {
    test('restores fatal snapshot for previous unclean session', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_crash_detection_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final paths = LogPaths.forTesting(
        logDir: '${tempDir.path}/logs',
        exportDir: '${tempDir.path}/export',
      );
      final service = CrashDetectionService(paths);

      await service.markAppStart(
        sessionId: 'session-1',
        version: '0.4.2',
        platform: 'Android',
      );
      service.recordFatalErrorSync(
        sessionId: 'session-1',
        source: 'test',
        message: 'fatal boom',
        error: 'state error',
        stackTrace: 'stack-trace',
      );

      final recovery = await service.checkAndRecover();
      expect(recovery.hadUncleanExit, isTrue);
      expect(recovery.previousSessionId, 'session-1');
      expect(recovery.fatalError, isNotNull);
      expect(recovery.fatalError!.message, 'fatal boom');
      expect(recovery.fatalError!.source, 'test');
    });

    test('ignores stale fatal snapshot from another session', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_crash_detection_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final paths = LogPaths.forTesting(
        logDir: '${tempDir.path}/logs',
        exportDir: '${tempDir.path}/export',
      );
      final service = CrashDetectionService(paths);

      await service.markAppStart(
        sessionId: 'session-2',
        version: '0.4.2',
        platform: 'Android',
      );
      service.recordFatalErrorSync(
        sessionId: 'session-other',
        source: 'test',
        message: 'stale fatal',
      );

      final recovery = await service.checkAndRecover();
      expect(recovery.hadUncleanExit, isTrue);
      expect(recovery.previousSessionId, 'session-2');
      expect(recovery.fatalError, isNull);
    });
  });

  group('enrichWithNativeExitInfo', () {
    NativeExitRecord record(int ms, int pid, int reasonCode, {String? trace}) =>
        NativeExitRecord(
          timestampMs: ms,
          pid: pid,
          processName: 'app',
          reasonCode: reasonCode,
          reason: '$reasonCode',
          status: reasonCode == NativeExitRecord.reasonSignaled ? 11 : 0,
          importanceCode: 100,
          importance: 'FOREGROUND',
          pssKb: 0,
          rssKb: 0,
          description: null,
          trace: trace,
        );

    Future<CrashDetectionService> crashedService(
      List<NativeExitRecord> records, {
      bool writePid = true,
    }) async {
      final tempDir = await Directory.systemTemp.createTemp('loveiwara_exit_');
      addTearDown(() => tempDir.delete(recursive: true));
      final paths = LogPaths.forTesting(
        logDir: '${tempDir.path}/logs',
        exportDir: '${tempDir.path}/export',
      );
      final service = CrashDetectionService(
        paths,
        exitRecordFetcher: (_, _) async => NativeExitFetchResult.ok(records),
      );
      await service.markAppStart(
        sessionId: 's',
        version: '1',
        platform: 'Android',
      );
      if (!writePid) {
        final marker = File(paths.crashMarkerFile);
        await marker.writeAsString(
          (await marker.readAsString()).replaceFirst(RegExp(r',"pid":\d+'), ''),
        );
      }
      await service.checkAndRecover();
      return service;
    }

    test(
      'prefers the CRASH_NATIVE record over the later SIGNALED one',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        // 真机上一次原生崩溃的记账形状：倒序，SIGNALED(11) 比带 tombstone 的
        // CRASH_NATIVE 晚几百毫秒。
        final service = await crashedService([
          record(now + 5240, pid, NativeExitRecord.reasonSignaled),
          record(
            now + 5000,
            pid,
            NativeExitRecord.reasonCrashNative,
            trace: 'proto',
          ),
        ]);
        final matched = await service.enrichWithNativeExitInfo();
        expect(matched?.reasonCode, NativeExitRecord.reasonCrashNative);
      },
    );

    test('ignores a newer death of another process', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final service = await crashedService([
        record(now + 9000, pid + 1, NativeExitRecord.reasonLowMemory),
        record(now + 5000, pid, NativeExitRecord.reasonSignaled),
      ]);
      final matched = await service.enrichWithNativeExitInfo();
      expect(matched?.pid, pid);
    });

    test(
      'without a pid in the marker, takes the first death after start',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final service = await crashedService([
          record(now + 9000, 222, NativeExitRecord.reasonLowMemory),
          record(now + 5000, 111, NativeExitRecord.reasonCrashNative),
          record(now - 60000, 111, NativeExitRecord.reasonCrashNative),
        ], writePid: false);
        final matched = await service.enrichWithNativeExitInfo();
        expect(matched?.pid, 111);
        expect(matched?.timestampMs, greaterThan(now));
      },
    );
  });
}
