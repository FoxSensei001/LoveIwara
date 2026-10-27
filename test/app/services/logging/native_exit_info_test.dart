import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/native_exit_info.dart';

void main() {
  group('NativeExitRecord', () {
    final rawLowMemory = <Object?, Object?>{
      'timestampMs': 1751900000000,
      'pid': 12345,
      'processName': 'm.c.g.a.i_iwara',
      'reasonCode': 3,
      'reason': 'LOW_MEMORY',
      'status': 0,
      'importanceCode': 100,
      'importance': 'FOREGROUND',
      'pssKb': 480000,
      'rssKb': 520192,
      'description': null,
      'trace': null,
    };

    test('fromMap parses a platform channel map', () {
      final record = NativeExitRecord.fromMap(rawLowMemory);
      expect(record, isNotNull);
      expect(record!.reasonCode, NativeExitRecord.reasonLowMemory);
      expect(record.reason, 'LOW_MEMORY');
      expect(record.importance, 'FOREGROUND');
      expect(record.rssKb, 520192);
      expect(record.timestampMs, 1751900000000);
    });

    test('fromMap rejects garbage', () {
      expect(NativeExitRecord.fromMap(null), isNull);
      expect(NativeExitRecord.fromMap('not a map'), isNull);
      expect(NativeExitRecord.fromMap(<Object?, Object?>{}), isNull);
    });

    test('toSummaryLine carries reason, importance and memory numbers', () {
      final line = NativeExitRecord.fromMap(rawLowMemory)!.toSummaryLine();
      expect(line, contains('reason=LOW_MEMORY(3)'));
      expect(line, contains('importance=FOREGROUND(100)'));
      expect(line, contains('rss=508.0MB'));
      expect(line, isNot(contains('trace=')));
    });

    test('toJson includes trace only when asked', () {
      final withTrace = NativeExitRecord.fromMap(<Object?, Object?>{
        ...rawLowMemory,
        'reasonCode': 5,
        'reason': 'CRASH_NATIVE',
        'trace': 'tombstone body',
      })!;
      expect(withTrace.toJson()['trace'], 'tombstone body');
      expect(withTrace.toJson(includeTrace: false).containsKey('trace'), false);
      // 旧原生侧不带 traceFormat 时按文本处理。
      expect(withTrace.toJson(includeTrace: false)['traceFormat'], 'text');
    });

    test('SIGNALED with a crash signal counts as a native crash', () {
      final segv = NativeExitRecord.fromMap(<Object?, Object?>{
        ...rawLowMemory,
        'reasonCode': 2,
        'reason': 'SIGNALED',
        'status': 11,
      })!;
      expect(segv.isNativeCrash, true);
      expect(segv.crashSignalName, 'SIGSEGV');
      expect(segv.toSummaryLine(), contains('status=11(SIGSEGV)'));

      final killed = NativeExitRecord.fromMap(<Object?, Object?>{
        ...rawLowMemory,
        'reasonCode': 2,
        'reason': 'SIGNALED',
        'status': 9,
      })!;
      expect(killed.isNativeCrash, false);
      expect(killed.crashSignalName, isNull);
    });

    test('proto tombstone keeps its format and truncation flag', () {
      final record = NativeExitRecord.fromMap(<Object?, Object?>{
        ...rawLowMemory,
        'reasonCode': 5,
        'reason': 'CRASH_NATIVE',
        'trace': 'AAEC',
        'traceFormat': 'tombstone_proto_base64',
        'traceTruncated': true,
      })!;
      final json = record.toJson(includeTrace: false);
      expect(json['traceFormat'], 'tombstone_proto_base64');
      expect(json['traceTruncated'], true);
      expect(
        record.toSummaryLine(),
        contains('trace=已捕获(tombstone_proto_base64)'),
      );
    });
  });
}
