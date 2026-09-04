import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

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
/// # 为什么这里**可以**有 `FadeTransition`（全站唯一的例外）
///
/// 全站规矩是「玻璃件外面不许包 Opacity」：α∈(0,1) 期间 `RenderOpacity` 会
/// `saveLayer` 把子树隔离，液态 lens 的 backdrop 采样吃不到**身后页面**的
/// 像素，整段淡入里折射是断的（闸门见 `test/glass_style_guard_test.dart`，
/// 实锤见 `glass_menu.dart` 文件头）。
///
/// 弹窗是那条规矩唯一不适用的地方，理由是结构性的：**弹窗面板本身就是一张
/// 不透明的 `Material`（`cs.surface`）**，里头那两块玻璃（标题行关闭钮、动作
/// 行按钮组）身后压根没有页面可折射——它们采样到的一直只是自己脚下那张纯色
/// 面。规矩要保护的东西在这里不存在。
///
/// 2026-08-24 到 2026-09-04 之间这里一度连淡入淡出一起删掉，只留缩放/位移，
/// 并指望内容自己读 [GlassDialogMotionScope] 去驱动 `GlassSurface.materialize`
/// 把材质淡进来。结果是：**全 App 没有任何一处消费过那个 scope**，于是所有
/// 弹窗都退化成「不透明卡片从 0.92 撑到 1.0」——8% 的缩放在 `easeOutCubic`
/// 下前 1/3 就走完了，剩下 2/3 一动不动；出场同理。用户读到的就是
/// 「动画走着走着瞬间停下，然后卡片瞬间出现/消失」。淡入淡出不是加分项，
/// 它是这段过渡里唯一挑得起大梁的通道。
///
/// 时值上两条通道**故意不同长**（见 [GlassTokens.dialogFadeInCurve] /
/// [GlassTokens.dialogFadeOutCurve]）：淡入早收工、淡出早退场，形变的尾巴
/// 才不会被读成「卡住了」。
class GlassDialogTransition extends StatefulWidget {
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
  State<GlassDialogTransition> createState() => _GlassDialogTransitionState();
}

/// ⛔ 有状态不是为了存东西，是为了 **`dispose` 那两条 [CurvedAnimation]**。
///
/// `CurvedAnimation` 在构造时往 parent 上挂一条 status listener，只有
/// `dispose()` 会摘掉。过渡期间 `transitionBuilder` 每帧都跑一次，若在 `build`
/// 里新建（2026-09-04 之前就是），一次 260ms 的入场能往路由的
/// `AnimationController` 上堆几十条永不摘除的监听。
class _GlassDialogTransitionState extends State<GlassDialogTransition> {
  /// 形变（缩放/位移）通道。同时也是递给 [GlassDialogMotionScope] 的那条。
  late CurvedAnimation _shape;

  /// 材质淡入淡出通道，比形变收得早（见类注释）。
  late CurvedAnimation _fade;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant GlassDialogTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      _unbind();
      _bind();
    }
  }

  @override
  void dispose() {
    _unbind();
    super.dispose();
  }

  void _bind() {
    _shape = CurvedAnimation(
      parent: widget.animation,
      curve: GlassTokens.dialogEnterCurve,
      reverseCurve: GlassTokens.dialogExitCurve,
    );
    _fade = CurvedAnimation(
      parent: widget.animation,
      curve: GlassTokens.dialogFadeInCurve,
      reverseCurve: GlassTokens.dialogFadeOutCurve,
    );
  }

  void _unbind() {
    _shape.dispose();
    _fade.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ 弹窗面板是不透明的 Material（`cs.surface`），身后那一页在过渡期间不
    // 参与任何采样；正文这一层显式压回便宜档（flatGlassBackend），只有
    // GlassAlertDialog 自己用 GlassChromeLayer 供档的关闭钮 / 动作行是真玻璃。
    //
    // 配套 RepaintBoundary：让 Fade / Scale / Slide 三层都由合成器硬件加速，
    // 动画期间不必逐帧重绘弹窗内部内容。
    final Widget scoped = RepaintBoundary(
      child: GlassDialogMotionScope(
        animation: _shape,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: LiquidGlassScope(
            backend: flatGlassBackend(context),
            child: widget.child,
          ),
        ),
      ),
    );

    final Widget shaped = switch (_resolve(context)) {
      GlassDialogMotion.scale => ScaleTransition(
        scale: _shape.drive(
          Tween<double>(begin: GlassDialogTransition._scaleBegin, end: 1),
        ),
        child: scoped,
      ),
      GlassDialogMotion.page => SlideTransition(
        position: _shape.drive(
          Tween<Offset>(
            begin: const Offset(0, GlassDialogTransition._slideBegin),
            end: Offset.zero,
          ),
        ),
        child: scoped,
      ),
      // 兜底：_resolve 不会返回 auto。
      GlassDialogMotion.auto => scoped,
    };

    return FadeTransition(opacity: _fade, child: shaped);
  }

  GlassDialogMotion _resolve(BuildContext context) {
    if (widget.motion != GlassDialogMotion.auto) return widget.motion;
    return MediaQuery.sizeOf(context).width > GlassTokens.dialogWideBreakpoint
        ? GlassDialogMotion.scale
        : GlassDialogMotion.page;
  }
}

/// 把弹窗出入场的**形变**驱动动画（0→1 入场，1→0 出场，已过曲线）沿子树下发。
///
/// 用途是给个别弹窗内容一个「跟着出入场再多做一点动作」的挂钩：自己驱动
/// `GlassSurface.materialize`、让某段内容错峰长出来之类。
///
/// ⚠️ **它不是弹窗淡入淡出的实现方式**，别再指望它兜这件事：整张弹窗的淡入
/// 淡出由 [GlassDialogTransition] 在路由层统一做（为什么弹窗可以用
/// `FadeTransition`，见那边的类注释）。2026-08-24 那版把淡入的责任整个押在这
/// 个 scope 上，而全 App 一个消费者都没有，结果是所有弹窗一起硬切。当前它是
/// **纯可选的加分挂钩**，没人接也不影响观感。
///
/// 没有祖先 scope 时 [maybeOf] 返回 null——弹窗内容要能在非 `GlassDialogRoute`
/// 语境下（单测、未来别的路由实现）照常工作，退化成静止态。
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
