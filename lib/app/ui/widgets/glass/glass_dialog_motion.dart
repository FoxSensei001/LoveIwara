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

    final faded = FadeTransition(opacity: curved, child: child);

    return switch (_resolve(context)) {
      GlassDialogMotion.scale => ScaleTransition(
        scale: curved.drive(Tween<double>(begin: _scaleBegin, end: 1)),
        child: faded,
      ),
      GlassDialogMotion.page => SlideTransition(
        position: curved.drive(
          Tween<Offset>(begin: const Offset(0, _slideBegin), end: Offset.zero),
        ),
        child: faded,
      ),
      // 兜底：_resolve 不会返回 auto。
      GlassDialogMotion.auto => faded,
    };
  }

  GlassDialogMotion _resolve(BuildContext context) {
    if (motion != GlassDialogMotion.auto) return motion;
    return MediaQuery.sizeOf(context).width > GlassTokens.dialogWideBreakpoint
        ? GlassDialogMotion.scale
        : GlassDialogMotion.page;
  }
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
