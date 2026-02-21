import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_file_sink.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';

void main() {
  group('LogFileSink', () {
    test('emergency writes still honor rotation policy', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_log_file_sink_',
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
        ..applyPolicy(maxFileBytes: 120, maxRotatedFiles: 2);

      final line = 'x' * 80;
      expect(sink.appendEmergencySync(line), isTrue);
      expect(sink.appendEmergencySync(line), isTrue);
      expect(sink.appendEmergencySync(line), isTrue);

      final rotated = File(paths.rotatedFile(1));
      final current = File(paths.currentLogFile);
      expect(await rotated.exists(), isTrue);
      expect(await current.exists(), isTrue);
      expect(await current.length(), lessThanOrEqualTo(120));
    });
  });
}
