import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// 进程已经活了多久——注意是**进程**，不是 Dart `main()`。
///
/// # 为什么需要它
///
/// `StartupTrace` 的原点是 Dart `main()` 的第一行，在那之前还有一整段：加载
/// 几十个 DLL、起 Dart VM、跑 AOT 快照的初始化、注册插件。这一段 Dart 侧看不见，
/// 而它恰恰是 Windows 上「白屏很久」最容易藏身的地方——刚下载的 exe 第一次运行，
/// Defender 会把整包扫一遍，冷盘上十几秒并不稀奇。
///
/// 没有这个读数，时间线会给出一个会骗人的结论：总计 1.2 秒，一切正常，可用户
/// 明明白了十几秒。有了它就能一眼分开「Dart 侧某个 await 慢」和「进程还没跑到
/// Dart 就已经耗掉了」——两者的修法毫无共同之处。
///
/// # 只有 Windows 有
///
/// 用的是 `GetProcessTimes`。其他平台返回 null：白屏这件事目前只在 Windows 上
/// 有报障，为它单独写三套平台实现不值当；调用方按 null 处理（那一行就不打印）。
Duration? currentProcessUptime() {
  if (!Platform.isWindows) return null;

  final creation = calloc<FILETIME>();
  final exit = calloc<FILETIME>();
  final kernel = calloc<FILETIME>();
  final user = calloc<FILETIME>();
  try {
    final ok = GetProcessTimes(
      GetCurrentProcess(),
      creation,
      exit,
      kernel,
      user,
    );
    if (ok == 0) return null;

    // FILETIME 是「自 1601-01-01 UTC 起的 100 纳秒数」，拆成高低两个 32 位。
    final ticks =
        (creation.ref.dwHighDateTime << 32) | creation.ref.dwLowDateTime;
    final startedUs = ticks ~/ 10;
    final nowUs =
        DateTime.now().toUtc().microsecondsSinceEpoch + _unixEpochOffsetUs;

    final uptimeUs = nowUs - startedUs;
    // 时钟被改过、或者两个时间基准对不上时会算出负数。宁可不报也不报错的。
    if (uptimeUs < 0) return null;
    return Duration(microseconds: uptimeUs);
  } catch (_) {
    return null;
  } finally {
    calloc
      ..free(creation)
      ..free(exit)
      ..free(kernel)
      ..free(user);
  }
}

/// Unix 纪元（1970-01-01）在 FILETIME 纪元（1601-01-01）里的偏移，微秒。
const int _unixEpochOffsetUs = 11644473600 * 1000000;
