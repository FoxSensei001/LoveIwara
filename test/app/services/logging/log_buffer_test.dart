import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_buffer.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';

void main() {
  group('LogBuffer', () {
    test('caps write queue under warning-only bursts', () {
      final buffer = LogBuffer();
      final total = LogConstants.highWaterMark + 200;

      for (var i = 0; i < total; i++) {
        buffer.push(
          LogEvent(
            timestamp: DateTime.now(),
            level: LogLevel.warning,
            tag: 'test',
            message: 'warn-$i',
            sessionId: 's',
          ),
        );
      }

      expect(buffer.writeQueueLength, LogConstants.highWaterMark);
    });
  });
}
