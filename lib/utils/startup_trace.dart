import 'dart:io';

/// 冷启动分段计时。
///
/// # 为什么要有它
///
/// Windows release 产物「开了窗口、白屏很久才出内容」这类报障，光看代码是认不
/// 出来的：`main()` 在 `runApp` 之前串着十来个 `await`（存储、sqlite 迁移、安全
/// 存储、locale…），任何一段慢下来都长一个样——窗口是第一帧光栅完成才 Show 的
/// （见 `windows/runner/flutter_window.cpp` 的 `SetNextFrameCallback`），在那之前
/// 屏幕上就是一块白。要分清是哪一段，只能让产物自己报时间。
///
/// # ⛔ 为什么不挂在 `GLASS_PERF` 那类基准开关上
///
/// `FramePerfProbe` / `GlassPerfKnobs` 走的是「另出一版基准包」的路子，适合自己
/// 在手边的机器上归因。但白屏是**用户在 CI 正式产物上**遇到的，让对方装一版特制
/// 包再复现一次，往返一天起步，而且基准包和正式包的编译参数本来就不同，测出来
/// 的数不一定是同一回事。所以这只秒表**常规包里也跑**：一次冷启动几十次
/// `Stopwatch.elapsedMicroseconds` 加一条几百字节的文件写，代价可以忽略。
///
/// # ⛔ 为什么自己写文件，而不是只打一条日志
///
/// 日志总开关出厂默认关闭（`ConfigKey.LOG_PERSISTENCE_ENABLED`），
/// 而默认设置的用户恰恰是最可能来报「启动好慢」的那批——走 `LogUtils` 的话，
/// 他们那边一个字都不会留下。这和崩溃标记当初遇到的是同一个坑（见
/// `LogService.init` 里「崩溃检测不受日志开关控制」那段），处理方式也照搬：
/// 时间线是本地小文件，照常维护；[summary] 另外再打一条日志，开了开关的人
/// 在日志里也能直接看到。
///
/// # 时间原点是 Dart `main()`，不是进程启动
///
/// 引擎起 Dart VM、注册插件那一段在 `main()` 之前，Dart 侧拿不到。所以这里所有
/// 读数都是「自 `main()` 第一行起」的毫秒数，比用户感知的白屏时长**短**一个引擎
/// 启动的量（Windows release 上通常几百毫秒）。够用了：我们要找的是某一段几秒
/// 的坑，不是几百毫秒的常数。
abstract final class StartupTrace {
  /// 原点。类首次被触达时起表——调用方的第一个 [mark] 之前只隔着一次类加载。
  static final Stopwatch _sw = Stopwatch()..start();

  static final List<_Mark> _marks = <_Mark>[];
  static int _lastUs = 0;

  /// 本次启动的身份抬头（时间、版本、构建标识、平台、玻璃档位），写进文件的
  /// 每一块。由 `main()` 在 `runApp` 前塞进来，而不是在这里现算：那几样东西分别
  /// 住在 `CommonConstants` 和 `liquid_glass_material.dart` 里，让 `utils/` 反过来
  /// import 应用常量和主题开关，层次就倒过来了。
  static String? header;

  /// 进程启动到 Dart `main()` 第一行之间的那一段（见 `currentProcessUptime`）。
  /// 只有 Windows 拿得到；为 null 时时间线就从 `main()` 起算。
  static Duration? preMain;

  /// [preMain] 里属于**加载器**的那一截：进程创建到 `wWinMain` 第一行，也就是
  /// 把 exe 和每一个静态导入的 DLL 映射进地址空间的时间。由原生侧经 Dart
  /// 入口参数 `--startup-entry-ms` 传进来（见 `windows/runner/main.cpp`）。
  ///
  /// 为什么要拆：`pre-main` 实测两秒，但「加载 30MB 的 libmpv」和「起 Dart VM、
  /// 读 36MB 的 AOT 快照、注册插件」是两件完全不同的事，修法也完全不同。
  /// 不拆开就只能对着一个两秒的黑盒子猜。
  static Duration? loaderPhase;

  /// 进程创建到「引擎即将构造」之间（见 `windows/runner/main.cpp`）：控制台
  /// 附加、COM 初始化、命令行解析都在里头。它和 [loaderPhase] 的差就是这些
  /// 杂活的成本，和 [preMain] 的差才是引擎真正起步的那一段。
  static Duration? preEnginePhase;

  /// 从入口参数里把原生侧的读数捡出来。认不出来就当没有——多一个参数不该
  /// 让启动出任何岔子。
  static void adoptNativeTimings(List<String> args) {
    for (final arg in args) {
      loaderPhase = _parseUs(arg, '--startup-entry-ms=') ?? loaderPhase;
      preEnginePhase =
          _parseUs(arg, '--startup-preengine-ms=') ?? preEnginePhase;
    }
  }

  static Duration? _parseUs(String arg, String prefix) {
    if (!arg.startsWith(prefix)) return null;
    final us = int.tryParse(arg.substring(prefix.length));
    if (us == null || us < 0) return null;
    return Duration(microseconds: us);
  }

  /// 打点条数上限。正常一次启动二十几条；留这个闸是防着有人把 [mark] 写进循环，
  /// 让一只诊断工具反过来吃内存。
  static const int _maxMarks = 64;

  /// 文件里保留最近几次启动。再多没意义——要对照的是「这次」和「上次」。
  static const int _keepRuns = 5;

  static const String _separator = '===== startup =====';

  /// 记一个分段终点。[label] 是**刚刚跑完**的那一段的名字。
  static void mark(String label) {
    if (_marks.length >= _maxMarks) return;
    final us = _sw.elapsedMicroseconds;
    _marks.add(_Mark(label, us - _lastUs, us));
    _lastUs = us;
  }

  /// 本次启动已经走掉的毫秒数。
  static int get elapsedMs => _sw.elapsedMilliseconds;

  static bool get isEmpty => _marks.isEmpty;

  /// 人读的时间线。每行是「本段耗时 / 累计」，末行是总计。
  ///
  /// 对齐用空格补到固定宽度：这东西最终是被用户复制粘贴进 issue 的，等宽排版
  /// 下哪一段鼓出来一眼就看得见。
  static String summary() {
    final buffer = StringBuffer();
    final head = header;
    if (head != null) buffer.writeln(head);
    // 拿得到 pre-main 时，整条时间线的累计列就以**进程启动**为零点——那才是
    // 用户盯着白屏数的那个零点。
    final offsetUs = preMain?.inMicroseconds ?? 0;

    // 拿到原生侧的读数就把 pre-main 拆开。两个读数各自可缺，所以挑出所有
    // 「合法且递增」的切点，按顺序切成若干段——缺哪个就少一条线，不会算错。
    const preMainLabel = 'pre-main';
    final cuts = <(String, int)>[];
    for (final (label, phase) in [
      ('pre-main.loader', loaderPhase),
      ('pre-main.preEngine', preEnginePhase),
    ]) {
      final us = phase?.inMicroseconds;
      if (us == null || us <= 0 || us > offsetUs) continue;
      if (cuts.isNotEmpty && us <= cuts.last.$2) continue;
      cuts.add((label, us));
    }

    var widest = 0;
    if (offsetUs > 0) {
      widest = cuts.isEmpty ? preMainLabel.length : 0;
      for (final (label, _) in cuts) {
        if (label.length > widest) widest = label.length;
      }
      if ('pre-main.engine'.length > widest && cuts.isNotEmpty) {
        widest = 'pre-main.engine'.length;
      }
    }
    for (final mark in _marks) {
      if (mark.label.length > widest) widest = mark.label.length;
    }

    void row(String label, int deltaUs, int totalUs) {
      buffer.writeln(
        '  ${label.padRight(widest)}  '
        '${_ms(deltaUs).padLeft(9)}  '
        '(累计 ${_ms(totalUs)})',
      );
    }

    if (offsetUs > 0) {
      if (cuts.isEmpty) {
        row(preMainLabel, offsetUs, offsetUs);
      } else {
        var prev = 0;
        for (final (label, us) in cuts) {
          row(label, us - prev, us);
          prev = us;
        }
        // 最后一段：切点之后到 Dart main，也就是引擎真正起步的那一截。
        row('pre-main.engine', offsetUs - prev, offsetUs);
      }
    }
    for (final mark in _marks) {
      row(mark.label, mark.deltaUs, offsetUs + mark.totalUs);
    }
    buffer.write('  总计 ${_ms(offsetUs + _lastUs)}');
    return buffer.toString();
  }

  /// 把本次启动的时间线追加进 [filePath]，并把文件裁到最近 [_keepRuns] 次。
  ///
  /// 允许一次启动调用多次（首帧一次、就绪一次）：每次写的都是**当下为止**的
  /// 完整时间线，后一块是前一块的超集。故意不做「改写上一块」——启动卡死在
  /// 某一段时，先落盘的那块就是现场，不能被后面的覆盖逻辑吃掉。
  ///
  /// # ⛔ 必须排队，不能并发
  ///
  /// 两处调用点都是 `unawaited` 的，而首帧回调和「就绪」几乎前后脚到（实测只差
  /// 几十毫秒）。一次 flush 是「读全文 → 拼新块 → 写回」，两次叠在一起就各读到
  /// 同一份旧内容、各写回自己那份，**后写的把先写的整块吃掉**——第一次实跑就是
  /// 这样：文件里只剩「就绪」那块，首帧的读数一个字都没留下。
  /// 所以这里把调用串成一条链，前一次写完下一次才开始。
  static Future<void> _writeChain = Future<void>.value();

  static Future<void> flush(String filePath) {
    if (_marks.isEmpty) return Future<void>.value();
    final queued = _writeChain.then((_) => _flush(filePath));
    // 链上任何一环失败都不该把后面的写卡住（_flush 自己已经吞了异常，这里是
    // 兜底：别让一条 broken future 传染整条链）。
    _writeChain = queued.catchError((_) {});
    return queued;
  }

  static Future<void> _flush(String filePath) async {
    try {
      final file = File(filePath);
      final block = '$_separator\n${summary()}\n';

      var existing = '';
      if (await file.exists()) {
        existing = await file.readAsString();
      }
      final blocks = <String>[
        ...existing
            .split(_separator)
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .map((part) => '$_separator\n$part\n'),
        block,
      ];
      final kept = blocks.length > _keepRuns
          ? blocks.sublist(blocks.length - _keepRuns)
          : blocks;

      await file.parent.create(recursive: true);
      await file.writeAsString(kept.join());
    } catch (_) {
      // 诊断工具不该让启动更糟：盘满、目录不可写、文件被占用，统统咽掉。
    }
  }

  static String _ms(int us) => '${(us / 1000).toStringAsFixed(1)}ms';

  /// 仅供测试：清空已记录的分段并把秒表归零。
  static void resetForTesting() {
    _marks.clear();
    _lastUs = 0;
    header = null;
    preMain = null;
    loaderPhase = null;
    preEnginePhase = null;
    _writeChain = Future<void>.value();
    _sw
      ..reset()
      ..start();
  }
}

class _Mark {
  const _Mark(this.label, this.deltaUs, this.totalUs);

  final String label;
  final int deltaUs;
  final int totalUs;
}
