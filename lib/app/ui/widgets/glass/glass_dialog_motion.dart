import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 弹窗出入场的动画风格。
///
/// 「液态」的神在于没有硬切——弹窗同样适用：Material 默认的 150ms 纯淡入
/// 在整页弹窗（搜索、筛选配置）上基本等于瞬间替换。这里把弹窗的出入场
/// 收进和 header 形变同一套时值/曲线里（见 [GlassTokens]）。
enum GlassDialogMotion {
  /// 按屏幕宽度自动选择：
  /// 宽屏（居中卡片）走 [scale]，窄屏（整页承载）走 [page]。
  /// 分界与 `ResponsiveDialogWidget` 一致（[GlassTokens.dialogWideBreakpoint]）。
  auto,

  /// 居中卡片：淡入 + 轻微放大。
  scale,

  /// 整页 / 近整页弹窗：淡入 + 自下而上一小段位移。
  ///
  /// 整页内容不能用放大——从 0.9x 撑到满屏会把四边从屏幕外拽进来，
  /// 露出下层页面，读起来像窗口而不是一层弹出的面板。
  page,
}

/// 弹窗出入场过渡。入场/出场共用一条 [animation]，靠 `reverseCurve` 分别取曲线。
///
/// ⛔ **这里不再有 `FadeTransition`**。2026-08-24 之前用它包住整个 [child]
/// （面板+正文），而 `RenderOpacity` 在 α∈(0,1) 期间会 `saveLayer` 把子树
/// 隔离出去——面板若接了液态 lens（`GlassSurface` 的 `easyLens`/`liquidWidgets`
/// 档），backdrop 采样吃不到身后像素，玻璃要等这层撤掉才「啪」地补上。
/// `glass_menu.dart`/`liquid_glass_material.dart` 文件头记录的那次实锤就是
/// 同一个坑，玻璃菜单已经改成不含透明度层的「卷开」；本文件现在照同一原则
/// 处理弹窗：**形状**（缩放/位移）继续用 `Scale`/`SlideTransition`——纯
/// `Transform`，不建 saveLayer，不影响折射；**材质**（玻璃自身的色调/描边/
/// 投影透明度）改由 [GlassDialogMotionScope] 把驱动动画原样递给内容，内容
/// 自己驱动 `GlassSurface.materialize`（同 [GlassIconButton]/`showGlassMenu`
/// 那套），图层结构全程不变。
///
/// 非玻璃内容（不读 [GlassDialogMotionScope] 的旧式弹窗 body）不会再有淡入——
/// 只剩缩放/位移，不是回归：这本身就是「不建透明度层」这条硬约束下唯一稳妥的
/// 全局默认值，玻璃内容额外接的 `materialize` 是在这个基础上的加分项，不是
/// 前提。
class GlassDialogTransition extends StatelessWidget {
  const GlassDialogTransition({
    super.key,
    required this.animation,
    required this.child,
    this.motion = GlassDialogMotion.auto,
  });

  /// 路由推进/退出的驱动动画（0→1 入场，1→0 出场）。
  final Animation<double> animation;

  final GlassDialogMotion motion;

  final Widget child;

  /// 入场起始缩放（[GlassDialogMotion.scale]）。
  static const double _scaleBegin = 0.92;

  /// 入场起始下移量，屏幕高度的比例（[GlassDialogMotion.page]）。
  static const double _slideBegin = 0.04;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: GlassTokens.dialogEnterCurve,
      reverseCurve: GlassTokens.dialogExitCurve,
    );

    final scoped = GlassDialogMotionScope(animation: curved, child: child);

    return switch (_resolve(context)) {
      GlassDialogMotion.scale => ScaleTransition(
        scale: curved.drive(Tween<double>(begin: _scaleBegin, end: 1)),
        child: scoped,
      ),
      GlassDialogMotion.page => SlideTransition(
        position: curved.drive(
          Tween<Offset>(begin: const Offset(0, _slideBegin), end: Offset.zero),
        ),
        child: scoped,
      ),
      // 兜底：_resolve 不会返回 auto。
      GlassDialogMotion.auto => scoped,
    };
  }

  GlassDialogMotion _resolve(BuildContext context) {
    if (motion != GlassDialogMotion.auto) return motion;
    return MediaQuery.sizeOf(context).width > GlassTokens.dialogWideBreakpoint
        ? GlassDialogMotion.scale
        : GlassDialogMotion.page;
  }
}

/// 把弹窗出入场的驱动动画（0→1 入场，1→0 出场，已过曲线）沿子树下发。
///
/// 弹窗内容（典型是 [GlassAlertDialog]）拿它驱动自己的
/// `GlassSurface.materialize`，让玻璃材质随入场动画同步淡入——不是靠
/// `Opacity` 包一层，是压材质自身的色调/描边/投影透明度，图层结构不变。
///
/// 没有祖先 scope 时 [maybeOf] 返回 null——弹窗内容要能在非 `GlassDialogRoute`
/// 语境下（单测、未来别的路由实现）照常工作，退化成静止态（materialize
/// 恒为 1）。
class GlassDialogMotionScope extends InheritedWidget {
  const GlassDialogMotionScope({
    super.key,
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  static Animation<double>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GlassDialogMotionScope>()
        ?.animation;
  }

  @override
  bool updateShouldNotify(GlassDialogMotionScope oldWidget) =>
      animation != oldWidget.animation;
}

/// 带 [GlassDialogTransition] 的弹窗路由。
///
/// `RawDialogRoute` 只有一个 `transitionDuration`（进出同长），这里额外
/// 覆写 [reverseTransitionDuration] 让出场比入场干脆。
class GlassDialogRoute<T> extends RawDialogRoute<T> {
  GlassDialogRoute({
    required super.pageBuilder,
    GlassDialogMotion motion = GlassDialogMotion.auto,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.settings,
    // 与 showDialog 一致：Tab 焦点在弹窗内闭环，不会跑到底层页面上。
    super.traversalEdgeBehavior = TraversalEdgeBehavior.closedLoop,
  }) : super(
         transitionDuration: GlassTokens.dialogEnterDuration,
         transitionBuilder: (context, animation, secondaryAnimation, child) =>
             GlassDialogTransition(
               animation: animation,
               motion: motion,
               child: child,
             ),
       );

  @override
  Duration get reverseTransitionDuration => GlassTokens.dialogExitDuration;
}
