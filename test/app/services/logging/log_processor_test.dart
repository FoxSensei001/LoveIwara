import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/services/logging/log_processor.dart';

LogEvent _event(
  LogLevel level,
  String message, {
  String tag = 'ApiService',
  String? error,
}) => LogEvent(
  timestamp: DateTime.now(),
  level: level,
  tag: tag,
  message: message,
  error: error,
  sessionId: 's',
);

void main() {
  group('LogProcessor dedup fingerprint', () {
    test('collapses errors that differ only by a volatile request id', () {
      final processor = LogProcessor();

      // ApiService._ensureRequestId() 用的就是 microsecondsSinceEpoch。
      expect(
        processor.process(
          _event(LogLevel.error, '[1756789012345678] 等待 token 刷新时出错'),
        ),
        isNotNull,
      );
      expect(
        processor.process(
          _event(LogLevel.error, '[1756789099999999] 等待 token 刷新时出错'),
        ),
        isNull,
      );
      expect(
        processor.process(
          _event(LogLevel.error, '[1756790000000000] 等待 token 刷新时出错'),
        ),
        isNull,
      );
      expect(processor.suppressedCount, 2);
    });

    test('collapses errors that differ only by a hex-ish token id', () {
      final processor = LogProcessor();

      expect(
        processor.process(_event(LogLevel.error, '[a1b2c3d4e5] 上传分片失败')),
        isNotNull,
      );
      expect(
        processor.process(_event(LogLevel.error, '[f0e9d8c7b6] 上传分片失败')),
        isNull,
      );
      expect(processor.suppressedCount, 1);
    });

    test('still keeps genuinely different errors', () {
      final processor = LogProcessor();

      expect(
        processor.process(_event(LogLevel.error, '[req-1] 等待 token 刷新时出错')),
        isNotNull,
      );
      expect(
        processor.process(_event(LogLevel.error, '[req-1] 写入下载文件失败')),
        isNotNull,
      );
      expect(processor.suppressedCount, 0);
    });

    test('tag participates in the fingerprint', () {
      final processor = LogProcessor();

      expect(
        processor.process(
          _event(LogLevel.error, '请求失败', tag: 'ApiService'),
        ),
        isNotNull,
      );
      expect(
        processor.process(
          _event(LogLevel.error, '请求失败', tag: 'DownloadService'),
        ),
        isNotNull,
      );
    });

    test('短数字是错误身份，绝不能被归一化合并', () {
      final processor = LogProcessor();

      // 状态码：404 / 500 / 403 是三种完全不同的故障，必须各留一条。
      expect(
        processor.process(_event(LogLevel.error, '代理检测失败，响应状态码: 404')),
        isNotNull,
      );
      expect(
        processor.process(_event(LogLevel.error, '代理检测失败，响应状态码: 500')),
        isNotNull,
      );
      expect(
        processor.process(_event(LogLevel.error, '代理检测失败，响应状态码: 403')),
        isNotNull,
      );

      // errno：111=SYN 被拒、110=超时，定性完全不同（见网络诊断那条工作线）。
      expect(
        processor.process(_event(LogLevel.error, '连接失败 errno = 111')),
        isNotNull,
      );
      expect(
        processor.process(_event(LogLevel.error, '连接失败 errno = 110')),
        isNotNull,
      );

      expect(processor.suppressedCount, 0);
    });

    test('消息文案相同但异常类型不同时不合并', () {
      final processor = LogProcessor();

      expect(
        processor.process(
          _event(LogLevel.error, '加载更多失败', error: 'SocketException: 断开'),
        ),
        isNotNull,
      );
      expect(
        processor.process(
          _event(LogLevel.error, '加载更多失败', error: 'FormatException: 非法 JSON'),
        ),
        isNotNull,
      );
      // 同类型同文案才该被合并
      expect(
        processor.process(
          _event(LogLevel.error, '加载更多失败', error: 'SocketException: 超时'),
        ),
        isNull,
      );
      expect(processor.suppressedCount, 1);
    });

    test('only the first line of a multi-line message is fingerprinted', () {
      final processor = LogProcessor();

      expect(
        processor.process(_event(LogLevel.error, '解析失败\n细节 A')),
        isNotNull,
      );
      expect(
        processor.process(_event(LogLevel.error, '解析失败\n细节 B')),
        isNull,
      );
    });
  });

  group('LogProcessor rate limiting', () {
    test('deduplicated errors do not consume the rate-limit budget', () {
      final processor = LogProcessor(maxLogsPerSecond: 10);

      // 同一个 error 刷 200 次：应当全部走去重，而不是吃掉限流配额。
      // id 用 4 位以上，才会被指纹归一化抹掉（见 _fingerprintVolatile）。
      for (var i = 0; i < 200; i++) {
        processor.process(
          _event(LogLevel.error, '[${1756789000000 + i}] 网络超时'),
        );
      }
      expect(processor.suppressedCount, 199);
      expect(processor.rateLimitedCount, 0);

      // 配额没被吃光，别的 info 仍然能过。
      expect(processor.process(_event(LogLevel.info, '正常信息')), isNotNull);
    });

    test('被限流丢弃的 error 不能污染去重表', () async {
      final processor = LogProcessor(maxLogsPerSecond: 10);

      // 1) 用低优先级日志打满总配额（真实场景：播放器位置回调 / 下载进度
      //    轻易就能刷满 100 条/秒）。
      for (var i = 0; i < 30; i++) {
        processor.process(_event(LogLevel.info, '噪音 $i'));
      }
      // 2) 再把 warn/error 的独立配额也打满（warning 不参与去重）。
      for (var i = 0; i < 11; i++) {
        processor.process(_event(LogLevel.warning, '高优先级噪音'));
      }

      // 3) 此刻来一条全新的真 error —— 两条配额都满了，它会被限流丢弃。
      const realError = '支付回调校验失败';
      expect(
        processor.process(_event(LogLevel.error, realError)),
        isNull,
        reason: '前置条件：这条 error 必须确实被限流丢掉',
      );

      // 4) 等限流窗口（1 秒，固定窗口）滚过去，但仍在去重窗口（5 秒）之内。
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      // 关键断言：第 3 步那条 error 从未落盘，就绝不该在去重表里留下指纹。
      // 留下的话，接下来 5 秒内同类 error 会被全部去重抑制 —— 这类错误
      // 一条都不见，只剩聚合计数在涨。
      expect(
        processor.process(_event(LogLevel.error, realError)),
        isNotNull,
        reason: '从未落盘的 error 不该在去重表里留指纹',
      );
    });

    test('still rate limits a flood of distinct low-priority logs', () {
      final processor = LogProcessor(maxLogsPerSecond: 10);

      for (var i = 0; i < 50; i++) {
        processor.process(_event(LogLevel.info, '消息 $i'));
      }
      expect(processor.rateLimitedCount, greaterThan(0));
    });

    test('fatal is never dropped by the rate limiter', () {
      final processor = LogProcessor(maxLogsPerSecond: 10);

      for (var i = 0; i < 50; i++) {
        processor.process(_event(LogLevel.info, '噪音 $i'));
      }
      expect(
        processor.process(_event(LogLevel.fatal, '进程即将崩溃')),
        isNotNull,
      );
    });
  });
}
