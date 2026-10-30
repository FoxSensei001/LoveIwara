import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/startup_trace.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late String tracePath;

  setUp(() {
    StartupTrace.resetForTesting();
    tempDir = Directory.systemTemp.createTempSync('startup_trace_test');
    tracePath = p.join(tempDir.path, 'logs', 'startup_trace.txt');
  });

  tearDown(() {
    StartupTrace.resetForTesting();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('没有任何分段时不落盘——别给用户留一堆空文件', () async {
    await StartupTrace.flush(tracePath);
    expect(File(tracePath).existsSync(), isFalse);
  });

  test('抬头和每个分段都写进文件，目录不存在就建出来', () async {
    StartupTrace.header = '2026-10-30 · 0.6.1+4 · windows · glass=material';
    StartupTrace.mark('core.db');
    StartupTrace.mark('first.raster');

    await StartupTrace.flush(tracePath);

    final content = File(tracePath).readAsStringSync();
    expect(content, contains('glass=material'));
    expect(content, contains('core.db'));
    expect(content, contains('first.raster'));
    expect(content, contains('总计'));
  });

  test('同一次启动可以 flush 多次，后一块是前一块的超集且都留着', () async {
    StartupTrace.mark('first.raster');
    await StartupTrace.flush(tracePath);

    StartupTrace.mark('deferred.Feature Services');
    await StartupTrace.flush(tracePath);

    final content = File(tracePath).readAsStringSync();
    // 首帧那块是启动卡死时唯一的现场，不许被「就绪」那块覆盖掉。
    expect('===== startup ====='.allMatches(content).length, 2);
    expect(
      'deferred.Feature Services'.allMatches(content).length,
      1,
      reason: '只有第二块记到了延迟初始化',
    );
  });

  test('两次 flush 并发也不会互相覆盖', () async {
    // 实跑里首帧回调和「就绪」只差几十毫秒，两处都是 unawaited。没有排队的话
    // 后写的会把先写的整块吃掉——第一次实测就丢了首帧那块读数。
    StartupTrace.mark('first.raster');
    final first = StartupTrace.flush(tracePath);
    StartupTrace.mark('deferred.Feature Services');
    final second = StartupTrace.flush(tracePath);
    await Future.wait([first, second]);

    final content = File(tracePath).readAsStringSync();
    expect('===== startup ====='.allMatches(content).length, 2);
    expect(content, contains('first.raster'));
    expect(content, contains('deferred.Feature Services'));
  });

  test('只保留最近 5 次启动，文件不会无限涨', () async {
    for (var run = 0; run < 8; run++) {
      StartupTrace.resetForTesting();
      StartupTrace.mark('run$run');
      await StartupTrace.flush(tracePath);
    }

    final content = File(tracePath).readAsStringSync();
    expect('===== startup ====='.allMatches(content).length, 5);
    expect(content, isNot(contains('run2')));
    expect(content, contains('run3'));
    expect(content, contains('run7'));
  });

  test('拿到 pre-main 时，累计列以进程启动为零点', () {
    StartupTrace.preMain = const Duration(seconds: 3);
    StartupTrace.mark('binding');

    final summary = StartupTrace.summary();
    expect(summary, contains('pre-main'));
    // 3000ms 的 pre-main 要顶进累计和总计里，否则时间线会给出
    // 「总计 1 秒、一切正常」这种会骗人的结论。
    expect(summary, contains('累计 3000.'));
    expect(summary, contains('总计 300'));
  });

  test('原生侧给了加载器读数时，pre-main 拆成两行', () {
    StartupTrace.preMain = const Duration(milliseconds: 2000);
    StartupTrace.adoptNativeTimings([
      'whatever.mp4',
      '--startup-entry-ms=1200000',
    ]);
    StartupTrace.mark('binding');

    final summary = StartupTrace.summary();
    expect(summary, contains('pre-main.loader'));
    expect(summary, contains('pre-main.engine'));
    // 引擎那段是差值：2000 - 1200。
    expect(summary, contains('800.0ms'));
    // 拆开之后两段累计仍要落回 pre-main 原值，不能凭空多出或少掉时间。
    expect(summary, contains('pre-main.engine'));
    expect(summary, contains('(累计 2000.0ms)'));
  });

  test('加载器读数认不出或不合理时，退回不拆的单行', () {
    StartupTrace.preMain = const Duration(milliseconds: 2000);
    // 比 pre-main 还大，只能是哪里对不上——宁可不拆也不输出负数。
    StartupTrace.adoptNativeTimings(['--startup-entry-ms=9999000']);
    StartupTrace.mark('binding');

    final summary = StartupTrace.summary();
    expect(summary, contains('pre-main '));
    expect(summary, isNot(contains('pre-main.loader')));
  });

  test('没有这条参数时什么都不发生', () {
    StartupTrace.adoptNativeTimings(['--enable-dart-profiling', 'a.mp4']);
    expect(StartupTrace.loaderPhase, isNull);
    expect(StartupTrace.preEnginePhase, isNull);
  });

  test('两个原生读数都在时，pre-main 切成三段', () {
    StartupTrace.preMain = const Duration(milliseconds: 2000);
    StartupTrace.adoptNativeTimings([
      '--startup-entry-ms=40000',
      '--startup-preengine-ms=60000',
    ]);
    StartupTrace.mark('binding');

    final summary = StartupTrace.summary();
    expect(summary, contains('pre-main.loader'));
    expect(summary, contains('pre-main.preEngine'));
    expect(summary, contains('pre-main.engine'));
    // 40 / 20 / 1940，三段相加仍是 2000。
    expect(summary, contains('(累计 40.0ms)'));
    expect(summary, contains('(累计 60.0ms)'));
    expect(summary, contains('1940.0ms'));
  });

  test('第二个读数不递增时被丢掉，不切出负数段', () {
    StartupTrace.preMain = const Duration(milliseconds: 2000);
    StartupTrace.adoptNativeTimings([
      '--startup-entry-ms=60000',
      '--startup-preengine-ms=40000',
    ]);
    StartupTrace.mark('binding');

    final summary = StartupTrace.summary();
    expect(summary, contains('pre-main.loader'));
    expect(summary, isNot(contains('pre-main.preEngine')));
    // 不许出现负的毫秒数（`pre-main` 自己带连字符，所以只能盯「减号紧跟数字」）。
    expect(summary, isNot(matches(RegExp(r'-\d'))));
  });

  test('拿不到 pre-main（非 Windows）时不多打那一行', () {
    StartupTrace.mark('binding');
    expect(StartupTrace.summary(), isNot(contains('pre-main')));
  });

  test('打点条数有上限，写进循环也不会吃内存', () {
    for (var i = 0; i < 500; i++) {
      StartupTrace.mark('mark$i');
    }
    expect(StartupTrace.summary(), isNot(contains('mark100')));
    expect(StartupTrace.summary(), contains('mark0'));
  });

  test('落盘失败不抛——诊断工具不该让启动更糟', () async {
    StartupTrace.mark('core.db');
    // 把文件位置占成目录：写入必然失败。
    Directory(tracePath).createSync(recursive: true);
    await expectLater(StartupTrace.flush(tracePath), completes);
  });
}
