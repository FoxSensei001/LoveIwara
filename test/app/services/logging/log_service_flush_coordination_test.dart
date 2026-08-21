import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_file_sink.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';

/// 写盘耗时可控的 sink，用来确定性地构造 flush 的并发时序。
/// 真实文件写在临时目录里快到撞不出竞态。
class _ControllableSink extends LogFileSink {
  _ControllableSink(super.paths);

  Duration delay = Duration.zero;

  /// 每次 appendBatch 的行数与 forceFlush 标记，按调用顺序记录。
  final List<({int lines, bool forceFlush})> calls = [];
  final List<String> written = [];

  /// 设为非 null 可以把写盘卡住不返回（模拟存储卸载 / syscall 阻塞）。
  Completer<void>? stall;

  @override
  Future<bool> appendBatch(
    Iterable<String> lines, {
    bool forceFlush = false,
  }) async {
    final materialized = lines.toList();
    calls.add((lines: materialized.length, forceFlush: forceFlush));
    final blocker = stall;
    if (blocker != null) {
      await blocker.future;
    }
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    written.addAll(materialized);
    return true;
  }
}

Future<(LogService, _ControllableSink)> _boot() async {
  final tempDir = await Directory.systemTemp.createTemp('loveiwara_flushco_');
  addTearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });
  final paths = LogPaths.forTesting(
    logDir: '${tempDir.path}/logs',
    exportDir: '${tempDir.path}/export',
  );
  final sink = _ControllableSink(paths);
  final service = await LogService().init(
    paths: paths,
    sink: sink,
    policy: LogPolicy.defaults(
      isProduction: false,
    ).copyWith(maxLogsPerSecond: 1000).normalized(),
  );
  return (service, sink);
}

void main() {
  group('flush 并发协调', () {
    test('close() 撞上一个「封顶的 immediate flush」时仍必须排干', () async {
      final (service, sink) = await _boot();
      // 让每批写盘都慢下来，制造出稳定的在途窗口。
      sink.delay = const Duration(milliseconds: 30);

      // LogPolicy.normalized() 把 maxLogsPerSecond 钳在 1000，所以要分两个
      // 限流窗口才能灌满，越过 maxImmediateFlushBatches(8) × 200 = 1600 的封顶。
      const perWindow = 1000;
      const total = perWindow * 2;
      for (var round = 0; round < 2; round++) {
        for (var i = 0; i < perWindow; i++) {
          service.log(
            level: LogLevel.info,
            message: '排干校验 $round-$i',
            tag: 'DrainTest',
          );
        }
        if (round == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 1100));
        }
      }
      // 掺一条 error，让 _errorFlushTimer 起来，形成
      // 「周期 flush 在途 + error 的 immediate(封顶) 续体排在后面」的时序。
      service.log(
        level: LogLevel.error,
        message: '触发合并落盘',
        tag: 'DrainTest',
      );

      // 等周期 flush 真正起跑，并让 error 的续体挂上去。
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await service.close();

      final health = await service.getHealthSnapshot();
      expect(health.queueDepth, 0, reason: 'close() 返回时队列必须已空');
      expect(
        sink.written.length,
        greaterThanOrEqualTo(total),
        reason: 'close() 合流进了封顶的 flush，队列尾巴被丢掉了',
      );
    });

    test('error 触发的落盘一定带 forceFlush，不会被降级成普通周期写', () async {
      final (service, sink) = await _boot();
      sink.delay = const Duration(milliseconds: 25);

      // 先制造一批普通日志让周期 flush 跑起来（forceFlush=false）。
      for (var i = 0; i < 400; i++) {
        service.log(level: LogLevel.info, message: '普通 $i', tag: 'T');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // 在周期 flush 在途期间来一条 error。
      service.log(level: LogLevel.error, message: '关键错误', tag: 'T');

      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(
        sink.calls.any((c) => c.forceFlush),
        isTrue,
        reason: 'error 的强制落盘被合流进普通周期 flush，fsync 整个跳过了',
      );
      await service.close();
    });

    test('写盘卡死时 close() 不会无限等待', () async {
      final (service, sink) = await _boot();
      sink.stall = Completer<void>();
      addTearDown(() => sink.stall?.complete());

      for (var i = 0; i < 100; i++) {
        service.log(level: LogLevel.info, message: '卡死校验 $i', tag: 'T');
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final sw = Stopwatch()..start();
      await service.close();
      sw.stop();

      // exitFlushTimeout = 2s，留足余量但必须远小于「永远」。
      expect(
        sw.elapsed,
        lessThan(LogConstants.exitFlushTimeout + const Duration(seconds: 3)),
        reason: 'close() 被挂死的写盘拖住了，桌面端表现为窗口关不掉',
      );
    });
  });
}
