import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/crash_detection_service.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';

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
}
