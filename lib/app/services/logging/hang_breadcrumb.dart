/// 卡死现场的「当时在干什么」。
///
/// # ⛔ 为什么需要它
///
/// `AppHangWatchdogService` 只回答得出「主 isolate 停了多久」，答不出**停在哪**。
/// 2026-11-09 一份 Windows 报告就卡死在这个盲区上：日志最后一行是桌面全屏的
/// 孤儿会话收尾，95 毫秒后心跳断掉、再没回来——可到底是「退原生全屏」那一次
/// Win32 调用、是紧跟着的窗口几何还原、还是别的什么，日志里再找不出第二条
/// 证据，只能靠读代码推。推出来的东西修不了 bug。
///
/// 所以给那些「一旦堵住就再也回不来」的段落留个名字：进段压栈、出段弹栈，
/// 心跳把栈顶捎给看门狗。卡死事件里于是写得出 `section`，那就是现场。
///
/// # 怎么埋
///
/// 一律用 [guard] / [guardSync]，别手写 [enter] / [leave]——`try/finally` 漏一次，
/// 栈顶就永远停在那个段上，之后每一次卡死都会被归错账。
///
/// ```dart
/// await HangBreadcrumb.guard('fullscreen-exit-native', () async {
///   await _mediaKitChannel.invokeMethod('Utils.ExitNativeFullscreen');
/// });
/// ```
///
/// # ⛔ 埋在哪、不埋在哪
///
/// 它是给**秒级可能卡住的粗粒度段落**准备的：原生窗口操作、同步 FFI、驱动侧
/// 的着色器编译、退出流程里的排干。埋到帧级 / 每条日志那种热路径上，只会把
/// 看门狗的心跳变成噪音源（见 [onChanged] 那里的说明）。
///
/// 一次 [enter] / [leave] 的成本是一次 List 增删加一个 int 自增：没有锁、没有
/// IO、不碰文件。即使看门狗没在跑（日志持久化关着），这里也照常记——只是没人
/// 来取而已。
library;

class HangBreadcrumb {
  HangBreadcrumb._();

  /// 同时开着的段落上限。
  ///
  /// 正常深度是 1～3 层。真顶到上限只有一种可能：某处漏了 [leave]。此时丢**最旧**
  /// 的那一条（它才是漏掉的那个），保住栈顶——栈顶是卡死现场，是这套东西的全部
  /// 价值所在。
  static const int _maxDepth = 16;

  static final List<_OpenSection> _open = <_OpenSection>[];

  static int _nextToken = 1;

  /// 栈顶变了就叫一声。
  ///
  /// `AppHangWatchdogService` 挂在这里，顺手补发一次心跳：心跳本身是 1 秒一跳，
  /// 而一个段落可能在两跳之间开始、然后当场卡死——那样最后一条心跳里带的还是
  /// 上一个段落的名字，照着它查就查错了地方。补发这一下把误差从「1 秒」压到
  /// 「进段的那一刻」。
  ///
  /// ⛔ 看门狗那边对补发做了节流（见 `AppHangWatchdogService._onBreadcrumbChanged`）。
  /// 即便如此，埋点也不该下到热路径：节流只保证不被打爆，保证不了信噪比。
  static void Function()? onChanged;

  /// 此刻最里层那个还没结束的段落。没有就是 null。
  static String? get current => _open.isEmpty ? null : _open.last.name;

  /// 同时开着几层。
  static int get depth => _open.length;

  /// 栈顶那个段落已经跑了多久（毫秒）。没有段落就是 null。
  static int? get currentSinceMs {
    if (_open.isEmpty) return null;
    return DateTime.now().millisecondsSinceEpoch - _open.last.startedAtMs;
  }

  /// 进段。返回的 token 只能交给 [leave]。
  static int enter(String name) {
    final token = _nextToken++;
    if (_open.length >= _maxDepth) {
      // 漏掉 leave 的那一条在最旧的一端。丢它，不丢栈顶。
      _open.removeAt(0);
    }
    _open.add(
      _OpenSection(
        token: token,
        name: name,
        startedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _notify();
    return token;
  }

  /// 出段。token 不在栈里（已被挤掉 / 重复 leave）就什么都不做。
  ///
  /// ⛔ 按 token 删，不是弹栈：两个段落可以并发交错（同一时刻两次退全屏就是），
  /// 无条件弹栈会把别人的段落弹掉。
  static void leave(int token) {
    for (int i = _open.length - 1; i >= 0; i--) {
      if (_open[i].token == token) {
        _open.removeAt(i);
        _notify();
        return;
      }
    }
  }

  /// 把 [body] 包在一个段落里。异常照常往外抛，段落照常出栈。
  static Future<T> guard<T>(String name, Future<T> Function() body) async {
    final token = enter(name);
    try {
      return await body();
    } finally {
      leave(token);
    }
  }

  /// [guard] 的同步版。给同步 FFI 这类「调用期间整个 isolate 都在里面」的段落用。
  static T guardSync<T>(String name, T Function() body) {
    final token = enter(name);
    try {
      return body();
    } finally {
      leave(token);
    }
  }

  /// 捎给看门狗的那一份。没有段落开着就返回 null，心跳里也就不带这几项。
  static Map<String, Object?>? snapshot() {
    if (_open.isEmpty) return null;
    final top = _open.last;
    return <String, Object?>{
      'section': top.name,
      'sectionSinceMs':
          DateTime.now().millisecondsSinceEpoch - top.startedAtMs,
      'sectionDepth': _open.length,
    };
  }

  static void _notify() {
    final callback = onChanged;
    if (callback == null) return;
    try {
      callback();
    } catch (_) {
      // 面包屑不该因为取信人出错而拖垮调用方。
    }
  }

  /// 单测用：清空进程级状态。
  static void resetForTest() {
    _open.clear();
    _nextToken = 1;
    onChanged = null;
  }
}

class _OpenSection {
  _OpenSection({
    required this.token,
    required this.name,
    required this.startedAtMs,
  });

  final int token;
  final String name;
  final int startedAtMs;
}
