import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';

void main() {
  group('LogPolicy', () {
    test('normalizes out-of-range values', () {
      final policy = LogPolicy(
        enabled: true,
        persistenceEnabled: true,
        minLevel: LogLevel.debug,
        maxFileBytes: 1,
        maxRotatedFiles: 99,
        maxLogsPerSecond: 1,
        hangEventsMaxFileBytes: 1,
        hangEventsMaxRotatedFiles: 99,
      ).normalized();

      expect(policy.maxFileBytes, greaterThanOrEqualTo(256 * 1024));
      expect(policy.maxRotatedFiles, lessThanOrEqualTo(10));
      expect(policy.maxLogsPerSecond, greaterThanOrEqualTo(10));
      expect(policy.hangEventsMaxFileBytes, greaterThanOrEqualTo(128 * 1024));
      expect(policy.hangEventsMaxRotatedFiles, lessThanOrEqualTo(10));
    });

    test('parses level label with fallback', () {
      expect(
        LogLevel.fromLabelOrDefault('warn', LogLevel.debug),
        LogLevel.warning,
      );
      expect(
        LogLevel.fromLabelOrDefault('unknown', LogLevel.error),
        LogLevel.error,
      );
    });
  });
}
