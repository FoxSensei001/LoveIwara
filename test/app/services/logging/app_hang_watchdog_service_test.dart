import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/app_hang_watchdog_service.dart';

void main() {
  group('AppHangWatchdogService', () {
    test('writes hang_detected when heartbeat stalls', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_hang_watchdog_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final eventsFile = File('${tempDir.path}/hang_events.jsonl');
      final watchdog = AppHangWatchdogService(
        threshold: const Duration(milliseconds: 120),
        heartbeatInterval: const Duration(seconds: 1),
        checkInterval: const Duration(milliseconds: 50),
      );

      await watchdog.start(
        sessionId: 'session-a',
        hangEventsFilePath: eventsFile.path,
        maxFileBytes: 1024 * 1024,
        maxRotatedFiles: 2,
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await watchdog.stop();

      expect(await eventsFile.exists(), isTrue);
      final lines = await eventsFile.readAsLines();
      expect(lines, isNotEmpty);

      final hasDetected = lines.any((line) {
        final decoded = jsonDecode(line) as Map<String, dynamic>;
        return decoded['type'] == 'hang_detected';
      });
      expect(hasDetected, isTrue);
    });

    test('records recovered stall duration from last heartbeat gap', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_hang_watchdog_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final eventsFile = File('${tempDir.path}/hang_events.jsonl');
      final watchdog = AppHangWatchdogService(
        threshold: const Duration(milliseconds: 300),
        heartbeatInterval: const Duration(milliseconds: 350),
        checkInterval: const Duration(milliseconds: 20),
      );

      await watchdog.start(
        sessionId: 'session-b',
        hangEventsFilePath: eventsFile.path,
        maxFileBytes: 1024 * 1024,
        maxRotatedFiles: 2,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      await watchdog.stop();

      expect(await eventsFile.exists(), isTrue);
      final lines = await eventsFile.readAsLines();
      expect(lines, isNotEmpty);

      final recovered = lines
          .map((line) => jsonDecode(line) as Map<String, dynamic>)
          .where((event) => event['type'] == 'hang_recovered')
          .toList();
      expect(recovered, isNotEmpty);

      final stalledMs = recovered.first['stalledMs'] as int? ?? 0;
      expect(stalledMs, greaterThanOrEqualTo(300));
    });
  });
}
