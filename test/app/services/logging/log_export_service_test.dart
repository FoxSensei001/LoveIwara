import 'dart:io';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/crash_detection_service.dart';
import 'package:i_iwara/app/services/logging/log_export_service.dart';
import 'package:i_iwara/app/services/logging/log_file_sink.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogExportService', () {
    test('exports logs with stream encoder and updates export stats', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_log_export_',
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
      final sink = LogFileSink(paths)
        ..applyPolicy(maxFileBytes: 1024 * 1024, maxRotatedFiles: 3);
      final crash = CrashDetectionService(paths);
      final export = LogExportService(
        paths: paths,
        sink: sink,
        crash: crash,
        sessionId: 'session-test',
        healthMetaProvider: () async => {
          'health': {'queueDepth': 7, 'sinkDegraded': false},
          'policy': {'maxFileBytes': 1024 * 1024},
        },
      );

      await sink.appendBatch(const [
        '{"ts":"2026-01-01T00:00:00Z","level":"INFO","msg":"hello"}',
      ], forceFlush: true);
      await crash.markAppStart(
        sessionId: 'session-test',
        version: '0.4.2',
        platform: 'test',
      );
      await crash.checkAndRecover();

      final zip = await export.exportLogs();

      expect(await zip.exists(), isTrue);
      expect(await zip.length(), greaterThan(0));
      expect(export.exportFailCount, 0);
      expect(export.lastExportAt, isNotNull);
      expect(export.lastExportBytes, greaterThan(0));

      final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
      final names = archive.files.map((f) => f.name).toSet();
      expect(names, contains('meta/health.json'));

      final healthFile = archive.files.firstWhere(
        (f) => f.name == 'meta/health.json',
      );
      final healthJson =
          jsonDecode(utf8.decode(healthFile.content as List<int>))
              as Map<String, dynamic>;
      expect(healthJson['available'], isTrue);

      final snapshot = healthJson['snapshot'] as Map<String, dynamic>;
      final health = snapshot['health'] as Map<String, dynamic>;
      expect(health['queueDepth'], 7);

      final crashFile = archive.files.firstWhere(
        (f) => f.name == 'crash/last_crash.json',
      );
      final crashJson =
          jsonDecode(utf8.decode(crashFile.content as List<int>))
              as Map<String, dynamic>;
      expect(crashJson, contains('fatalError'));
      expect(crashJson, contains('lastHangEvent'));
      expect(crashJson['analysis'], isA<Map<String, dynamic>>());
    });
  });
}
