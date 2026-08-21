import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';

/// LogPolicy.normalized() 把 maxLogsPerSecond 钳在 [10, 1000]，
/// 所以单个限流窗口内最多只能过 1000 条——测试要按这个上限来编排。
const int kMaxLogsPerWindow = 1000;

Future<(LogService, LogPaths)> _bootService({
  int maxLogsPerSecond = kMaxLogsPerWindow,
}) async {
  final tempDir = await Directory.systemTemp.createTemp('loveiwara_log_svc_');
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final paths = LogPaths.forTesting(
    logDir: '${tempDir.path}/logs',
    exportDir: '${tempDir.path}/export',
  );

  final service = await LogService().init(
    paths: paths,
    policy: LogPolicy.defaults(isProduction: false)
        .copyWith(maxLogsPerSecond: maxLogsPerSecond)
        .normalized(),
  );
  return (service, paths);
}

int _countLines(File file) =>
    file.readAsLinesSync().where((l) => l.trim().isNotEmpty).length;

void main() {
  group('LogService flush', () {
    test('close() drains the whole queue, not just the batch cap', () async {
      final (service, paths) = await _bootService();

      // 分两个限流窗口灌 2000 条，越过 maxImmediateFlushBatches(8) × 200 = 1600
      // 的单次落盘封顶（期间周期 flush 只会带走 50 条/300ms，远追不上）。
      for (var round = 0; round < 2; round++) {
        for (var i = 0; i < kMaxLogsPerWindow; i++) {
          service.log(
            level: LogLevel.info,
            message: '批量日志 $round-$i',
            tag: 'FlushTest',
          );
        }
        if (round == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 1100));
        }
      }

      final beforeClose = await service.getHealthSnapshot();
      expect(
        beforeClose.queueDepth,
        greaterThan(LogConstants.maxImmediateFlushBatches * 200),
        reason: '队列必须真的超过封顶，否则这条用例什么都没验证到',
      );

      await service.close();

      final written = _countLines(File(paths.currentLogFile));
      // 里面还混着 init 阶段的内部日志，所以是 >=。
      expect(written, greaterThanOrEqualTo(2 * kMaxLogsPerWindow));
    });

    test('errors arriving over time are coalesced into few forced flushes',
        () async {
      final (service, _) = await _bootService();

      // 关键是**分散到达**：真实的 error 来自各自独立的异步回调，
      // 每条之间事件循环都转得开，早先"每条 error 一次 immediate flush"
      // 的写法就会变成每条一次 fsync。同步 for 循环反而看不出差别。
      //
      // 消息必须在**指纹**上真正不同：只换数字 id 会被归一化后的去重合并掉
      // （那正是另一处修复的效果），这里用纯字母后缀来绕开归一化。
      const errorCount = 40;
      const spacing = Duration(milliseconds: 5);
      for (var i = 0; i < errorCount; i++) {
        final suffix = String.fromCharCodes([97 + i ~/ 26, 97 + i % 26]);
        service.log(
          level: LogLevel.error,
          message: '网络请求失败 $suffix',
          tag: 'BurstTest',
        );
        await Future<void>.delayed(spacing);
      }
      final mid = await service.getHealthSnapshot();
      expect(
        mid.processorSuppressedCount,
        0,
        reason: '这些 error 必须都活下来，否则测的就不是落盘合并了',
      );

      await Future<void>.delayed(
        LogConstants.errorFlushDebounce + const Duration(milliseconds: 120),
      );

      final health = await service.getHealthSnapshot();
      // 全程约 200ms，按 50ms 的合并窗口应当只落盘几次，
      // 而不是 errorCount 次。
      expect(health.flushCount, greaterThan(0));
      expect(health.flushCount, lessThan(errorCount ~/ 2));
      expect(health.flushFailureCount, 0);
      expect(health.queueDepth, 0);

      await service.close();
    });

    test('flush() waits for an in-flight flush instead of bailing', () async {
      final (service, paths) = await _bootService();

      for (var i = 0; i < 1000; i++) {
        service.log(
          level: LogLevel.info,
          message: '并发落盘 $i',
          tag: 'ConcurrentTest',
        );
      }

      // 三个并发的 flush 都必须等到队列真的排空才返回。
      await Future.wait([service.flush(), service.flush(), service.flush()]);

      final health = await service.getHealthSnapshot();
      expect(health.queueDepth, 0);
      expect(_countLines(File(paths.currentLogFile)), greaterThanOrEqualTo(1000));

      await service.close();
    });
  });
}
