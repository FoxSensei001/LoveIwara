import 'package:flutter/widgets.dart';

/// 播放器画面区域的实际尺寸，供播放器内部的浮层按「播放器有多大」做响应式。
///
/// # 为什么需要它
///
/// 播放器里的浮层（进度条上方的 Seek Preview 是第一个）要跟着**播放器**的大小走，
/// 而不是跟着窗口走：内嵌播放器在竖屏手机上只有窗口的一小条，全屏时才铺满。
/// `MediaQuery.sizeOf` 给的是窗口，两者在内嵌态差得很远。
///
/// 尺寸只在 [MyVideoScreen] 的那一只 `LayoutBuilder` 里算得到；浮层却挂在
/// 好几层之下（工具栏 → 进度条 → tooltip）。逐层往下传参数意味着每加一个
/// 需要几何的浮层就要再穿一次线，于是这里改成**一个作用域**：播放器栈顶供上，
/// 谁需要谁自己取。
///
/// # 供的是 Stack 的尺寸，不是窗口
///
/// 播放器栈外面套着 `Container(padding: EdgeInsets.only(top: paddingTop))`，
/// 所以供上来的高度必须已经把状态栏那一段减掉，与 `_buildPlayerNotice` 的口径一致。
class PlayerBoxScope extends InheritedWidget {
  const PlayerBoxScope({super.key, required this.size, required super.child});

  /// 播放器画面区域（Stack）的尺寸。
  final Size size;

  /// 取播放器尺寸。播放器子树内必然有这只作用域；取不到说明调用方挂错了地方，
  /// debug 下直接断言，release 下退回一个 16:9 的保守值而不是崩掉播放。
  static Size sizeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlayerBoxScope>();
    assert(
      scope != null,
      'PlayerBoxScope 不在祖先里：播放器内的浮层必须挂在 PlayerBoxScope 之下，'
      '否则它拿不到播放器几何，只能按窗口大小画（内嵌态会大得离谱）。',
    );
    return scope?.size ?? const Size(640, 360);
  }

  /// 允许缺席的版本，给「可能在播放器外复用」的组件用。
  static Size? maybeSizeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlayerBoxScope>()?.size;

  @override
  bool updateShouldNotify(PlayerBoxScope oldWidget) => size != oldWidget.size;
}
