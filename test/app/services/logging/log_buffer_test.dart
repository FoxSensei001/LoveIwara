import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_buffer.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';

LogEvent _event(
  LogLevel level,
  String message, {
  String tag = 'test',
}) => LogEvent(
  timestamp: DateTime.now(),
  level: level,
  tag: tag,
  message: message,
  sessionId: 's',
);

void main() {
  group('LogBuffer', () {
    test('caps write queue under warning-only bursts', () {
      final buffer = LogBuffer();
      final total = LogConstants.highWaterMark + 200;

      for (var i = 0; i < total; i++) {
        buffer.push(_event(LogLevel.warning, 'warn-$i'));
      }

      // 裁剪带迟滞：越过 highWaterMark 时一次性压回 writeQueueTrimTarget，
      // 之后才继续增长——所以只保证不超过上限，不再是恰好等于上限。
      expect(
        buffer.writeQueueLength,
        lessThanOrEqualTo(LogConstants.highWaterMark),
      );
      expect(
        buffer.writeQueueLength,
        greaterThanOrEqualTo(LogConstants.writeQueueTrimTarget),
      );
    });

    test('drops DEBUG/INFO before WARN/ERROR when over the cap', () {
      final buffer = LogBuffer();

      // 一半低优先级、一半高优先级，交替写入并越过上限。
      for (var i = 0; i < LogConstants.highWaterMark + 500; i++) {
        buffer.push(
          i.isEven
              ? _event(LogLevel.debug, 'debug-$i')
              : _event(LogLevel.error, 'error-$i'),
        );
      }

      final remaining = buffer.drain();
      final highPriority = remaining.where((e) => !e.isLowPriority).length;
      final lowPriority = remaining.where((e) => e.isLowPriority).length;

      // 低优先级先被牺牲，高优先级应当一条不少地留下来。
      expect(highPriority, (LogConstants.highWaterMark + 500) ~/ 2);
      expect(lowPriority, lessThan(highPriority));
    });

    test('keeps a WARNING whose body embeds a level-looking literal', () {
      final buffer = LogBuffer();

      // 正文里混入 `"level":"DEBUG"` 字面量。这**不是**旧实现的已知 bug
      // （jsonEncode 会把引号转义掉，line.contains() 匹配不上），
      // 这条用例是给现在的结构化等级判定加一道回归护栏。
      const trap = 'payload={"level":"DEBUG"} 上游返回异常';
      buffer.push(_event(LogLevel.warning, trap));
      for (var i = 0; i < LogConstants.highWaterMark + 500; i++) {
        buffer.push(_event(LogLevel.debug, 'debug-$i'));
      }

      final remaining = buffer.drain();
      expect(remaining.first.level, LogLevel.warning);
      expect(remaining.first.line, contains('上游返回异常'));
    });

    test('caps the write queue by bytes, not just entry count', () {
      final buffer = LogBuffer();
      final fat = 'x' * 20000;

      // 条数远低于 highWaterMark，但字节数早就爆了。
      for (var i = 0; i < 1000; i++) {
        buffer.push(_event(LogLevel.warning, '$fat-$i'));
      }

      expect(buffer.writeQueueLength, lessThan(LogConstants.highWaterMark));
      expect(
        buffer.writeQueueChars,
        lessThanOrEqualTo(LogConstants.maxWriteQueueChars),
      );
    });

    test('drain + requeueFront round-trips order and byte accounting', () {
      final buffer = LogBuffer();
      for (var i = 0; i < 10; i++) {
        buffer.push(_event(LogLevel.info, 'msg-$i'));
      }
      final beforeChars = buffer.writeQueueChars;

      final batch = buffer.drain(maxItems: 4);
      expect(batch.length, 4);
      expect(buffer.writeQueueLength, 6);
      expect(buffer.writeQueueChars, lessThan(beforeChars));

      buffer.requeueFront(batch);
      expect(buffer.writeQueueLength, 10);
      expect(buffer.writeQueueChars, beforeChars);

      final all = buffer.drain();
      expect(all.first.line, contains('msg-0'));
      expect(all.last.line, contains('msg-9'));
    });

    test('clearWriteQueue resets the byte counter', () {
      final buffer = LogBuffer();
      for (var i = 0; i < 10; i++) {
        buffer.push(_event(LogLevel.info, 'msg-$i'));
      }
      buffer.clearWriteQueue();
      expect(buffer.writeQueueLength, 0);
      expect(buffer.writeQueueChars, 0);
      // ring buffer 不受影响
      expect(buffer.ringBufferLength, 10);
    });
  });
}
