import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// ⭐ 状态栏 / 导航栏图标明暗：全应用只有这一套写法。
///
/// # 系统怎么决定图标颜色
///
/// 每合成一帧，`RenderView._updateSystemChrome` 在**状态栏正中那一点**
/// （横向居中、纵向是状态栏高度的一半）往图层树里找最上面那个
/// `SystemUiOverlayStyle` 标注；安卓再在导航栏正中找一次，导航栏的字段取那里的。
/// 一个都没找到就**什么也不做**——状态栏停在上一次设置的样子。
///
/// # 以前为什么不对
///
/// - 应用里几乎没有 AppBar（顶栏都是玻璃 header），绝大多数页面一个标注都没有，
///   图标颜色全靠「上一页留下的」。所以从视频页回来经常是白字压在白底上，
///   下载页、设置页才一处一处补了 `AnnotatedRegion`（见 2026-11-18 FEEDBACK_LOG）。
/// - 补丁大多只写了安卓认的 `statusBarIconBrightness`。**iOS 只认
///   `statusBarBrightness`**，缺了它引擎整条消息直接丢弃
///   （`FlutterPlatformPlugin.mm` 的 `setSystemChromeSystemUIOverlayStyle:`），
///   于是 iOS 上状态栏一直是系统默认样式＝跟着**系统**深浅色走，不管应用主题，
///   也不管视频页的黑色播放器：浅色模式下黑字压在黑色播放器上。
///
/// # 现在的分工
///
/// | 件 | 管什么 |
/// |---|---|
/// | [SystemBarStyles] | 「身后是深色 / 浅色」→ 一份完整样式（安卓、iOS 字段都写） |
/// | [SystemBarsThemeFallback] | 挂在应用根上，没人声明的地方一律按主题走 |
/// | [SystemBarsRegion] | 某块区域身后不是主题底色（黑色播放器、盖在上面的面板）时声明它 |
/// | [SystemBarsRouteScope] | 页面转场时，等这一页露出过半才让它的声明生效 |
/// | [SystemBarsPageTransitionsBuilder] | 在主题转场里给**每一页**自动套上 [SystemBarsRouteScope] |
///
/// 普通页面什么都不用写。⛔ 别再在页面里手写 `AnnotatedRegion<SystemUiOverlayStyle>`
/// 或调 `SystemChrome.setSystemUIOverlayStyle`：前者容易漏 iOS 字段，后者下一帧
/// 就会被图层树里的声明盖掉。
abstract final class SystemBarStyles {
  /// 只有手机有可调的系统栏。桌面引擎不认这条平台消息，发过去会报
  /// `MissingPluginException`（经 `FlutterError.reportError` 进错误日志）。
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// 白字与黑字对比度**相等**的那一点（WCAG 相对亮度）：
  /// `(L + 0.05)² = 1.05 × 0.05`，L ≈ 0.179，此时两种字都有 4.58:1。
  ///
  /// 不用 `ThemeData.estimateBrightnessForColor`：它的门槛在 L ≈ 0.34，
  /// 偏向白字，中灰背景上的白字对比度只剩 2.7:1。
  static const double _equalContrastLuminance = 0.17913;

  /// 已经是一种字时，背景要越过门槛这么多才换。滚动停在门槛附近时，手指的细微
  /// 抖动不会让图标来回闪。带宽两侧的最低对比度仍在 4.1:1 以上。
  static const double _hysteresis = 0.02;

  static const SystemUiOverlayStyle _onDark = SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    // 安卓：图标本身的颜色
    statusBarIconBrightness: Brightness.light,
    // iOS：描述的是**背景**，语义与上一行相反。缺了它 iOS 整条忽略。
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Color(0x00000000),
    // Android 9 上分隔线全透明会被画成不透明，与 styles.xml 的 #01000000 同值。
    systemNavigationBarDividerColor: Color(0x01000000),
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  static const SystemUiOverlayStyle _onLight = SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Color(0x00000000),
    systemNavigationBarDividerColor: Color(0x01000000),
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  /// 系统栏**身后**是 [background] 这种明暗时该用的样式。
  static SystemUiOverlayStyle forBackground(Brightness background) =>
      background == Brightness.dark ? _onDark : _onLight;

  /// 身后就是主题底色。
  static SystemUiOverlayStyle forTheme(ThemeData theme) =>
      forBackground(theme.brightness);

  /// 把一个**不透明**的颜色归成深 / 浅。半透明的要先自己合成到身后的颜色上
  /// （`Color.alphaBlend`），这里只看 RGB。
  ///
  /// 给了 [previous] 就带回差：背景要越过门槛 [_hysteresis] 才换边。
  static Brightness brightnessOf(Color color, {Brightness? previous}) {
    final double luminance = color.computeLuminance();
    final double threshold = switch (previous) {
      Brightness.dark => _equalContrastLuminance + _hysteresis,
      Brightness.light => _equalContrastLuminance - _hysteresis,
      null => _equalContrastLuminance,
    };
    return luminance > threshold ? Brightness.light : Brightness.dark;
  }
}

/// 挂在应用根上的兜底：页面没声明的地方，系统栏一律跟着**应用主题**
/// （不是系统深浅色，也不是上一页留下的）。
///
/// 它在图层树的最外层，任何更深的声明（[SystemBarsRegion]、AppBar 自带的）
/// 都比它先被找到；所以它只在「这一点上谁都没说」时起作用。主题一换就跟着换。
class SystemBarsThemeFallback extends StatelessWidget {
  const SystemBarsThemeFallback({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 平台是常量，树的形状不会在运行中变。
    if (!SystemBarStyles.isSupported) return child;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemBarStyles.forTheme(Theme.of(context)),
      child: child,
    );
  }
}

/// 声明「这块区域里，系统栏身后的颜色是 [background]」。
///
/// 只有落在系统栏正中那一点上的区域才算数（见 [SystemBarStyles] 的说明），
/// 所以放在哪儿、多大，要和它真正盖住状态栏的那部分一致。
///
/// [background] 可以每帧都变（比如随滚动淡入的顶栏）：只有跨过门槛时才重绘，
/// 而且带回差，停在门槛附近不会闪。
///
/// [enabled] 为 false 时不声明，等于这块不存在：比如页面退场、背景已经在淡出时。
///
/// 走主题转场的页面（`MaterialPage`，含 go_router `builder:` 的默认页）已经由
/// [SystemBarsPageTransitionsBuilder] 套好了 [SystemBarsRouteScope]，转场里不会
/// 提前生效。⛔ 不走主题转场的路由（`CustomTransitionPage` 之类）要自己在页面根上套。
class SystemBarsRegion extends SingleChildRenderObjectWidget {
  const SystemBarsRegion({
    super.key,
    required this.background,
    this.enabled = true,
    super.child,
  });

  /// 系统栏身后、这块区域此刻真正的颜色（不透明；半透明的先合成好）。
  final Color background;

  final bool enabled;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSystemBarsRegion(background: background, enabled: enabled);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderSystemBarsRegion)
      ..background = background
      ..enabled = enabled;
  }
}

class _RenderSystemBarsRegion extends RenderProxyBox {
  _RenderSystemBarsRegion({required Color background, required bool enabled})
    : _background = background,
      _resolved = SystemBarStyles.brightnessOf(background),
      _enabled = enabled;

  Color _background;
  Brightness _resolved;

  set background(Color value) {
    if (value == _background) return;
    _background = value;
    final Brightness next = SystemBarStyles.brightnessOf(
      value,
      previous: _resolved,
    );
    if (next == _resolved) return;
    _resolved = next;
    markNeedsPaint();
  }

  bool _enabled;

  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  bool get _declares => _enabled && SystemBarStyles.isSupported;

  @override
  bool get alwaysNeedsCompositing => _declares;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_declares) {
      super.paint(context, offset);
      return;
    }
    // 与 RenderAnnotatedRegion 一样不复用图层：它不产生引擎层，每次新建不花钱。
    context.pushLayer(
      AnnotatedRegionLayer<SystemUiOverlayStyle>(
        SystemBarStyles.forBackground(_resolved),
        size: size,
        offset: offset,
      ),
      super.paint,
      offset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('background', _background))
      ..add(EnumProperty<Brightness>('resolved', _resolved))
      ..add(FlagProperty('enabled', value: _enabled, ifFalse: 'disabled'));
  }
}

/// 套在页面根上：这一页**露出过半**之前，它里面的系统栏声明一律不算数。
///
/// 不套的话，声明在页面开始画的第一帧就生效：
/// - 安卓的推入转场是淡入，新页面透明度刚过 0 就接管了状态栏，屏幕上明明还是
///   上一页，图标已经换了色；退出时又要等它完全淡没才换回来。
/// - 新页面盖上来时，如果新页面自己没有声明（大多数页面都没有，交给根上兜底），
///   正中那一点往下找会穿过它、找到下面这一页的声明，要等转场结束、这一页不再
///   绘制才换。
///
/// 规则：`animation ≥ 0.5`（自己进场过半 / 退场未过半）且 `secondaryAnimation < 0.5`
/// （上面盖来的页面未过半）。iOS 侧滑返回时进度跟着手指走，过半那一刻正好是这一页
/// 让出屏幕正中、也就是让出状态栏正中那一点的时候，与几何上的结果一致。
///
/// 弹窗、底部弹层、侧边抽屉是 PopupRoute，不驱动 `secondaryAnimation`，它们开着时
/// 这一页的声明照常有效——它们的遮罩本身不声明，状态栏仍按这一页身后的颜色走；
/// 自己会盖住状态栏正中的（窄屏侧边抽屉），自己套 [SystemBarsRegion]。
///
/// 只拦 `SystemUiOverlayStyle` 这一种标注，别的（鼠标光标等）不受影响。
///
/// 走主题转场的页面不用手动套，见 [SystemBarsPageTransitionsBuilder]。
class SystemBarsRouteScope extends StatefulWidget {
  const SystemBarsRouteScope({super.key, required this.child});

  final Widget child;

  @override
  State<SystemBarsRouteScope> createState() => _SystemBarsRouteScopeState();
}

class _SystemBarsRouteScopeState extends State<SystemBarsRouteScope> {
  Animation<double>? _animation;
  Animation<double>? _secondaryAnimation;
  bool _open = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    _bind(route?.animation, route?.secondaryAnimation);
  }

  void _bind(Animation<double>? animation, Animation<double>? secondary) {
    if (!identical(animation, _animation)) {
      _animation?.removeListener(_sync);
      _animation = animation?..addListener(_sync);
    }
    if (!identical(secondary, _secondaryAnimation)) {
      _secondaryAnimation?.removeListener(_sync);
      _secondaryAnimation = secondary?..addListener(_sync);
    }
    _open = _computeOpen();
  }

  bool _computeOpen() =>
      (_animation?.value ?? 1) >= 0.5 &&
      (_secondaryAnimation?.value ?? 0) < 0.5;

  void _sync() {
    final bool next = _computeOpen();
    if (next != _open) setState(() => _open = next);
  }

  @override
  void dispose() {
    _animation?.removeListener(_sync);
    _secondaryAnimation?.removeListener(_sync);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _SystemBarsGate(open: _open, child: widget.child);
}

/// 把主题里的一档页面转场包一层：转场原样交给 [inner]，外面再套
/// [SystemBarsRouteScope]。
///
/// 为什么挂在这里：只有在每一页上都有这道门，交接才对得上。缺了门的页面，自己的
/// AppBar / [SystemBarsRegion] 一被查到就生效，不管它此刻有多透明。安卓
/// （FadeForwards）推入时新页面从右侧 1/4 处滑入、同时从全透明淡入，上一页要淡到
/// 0.25 才没。widget test 实测：不套门时黑色页 → 浅色 AppBar 页在 0.18 就切成黑字，
/// 正压在还看得见的黑色页上；套门后在 0.28（黑色页刚淡没）才切，iOS 在 0.51
/// （2026-11-18 审查发现）。
/// 一页一页去套必然有漏的；所有 `MaterialPage` / `MaterialPageRoute` 都要过主题
/// 转场，挂在这里一处就全覆盖。
///
/// 顺带覆盖跨 Navigator 的情况：根 Navigator 上压来的页面不会驱动 shell 里那一页的
/// `secondaryAnimation`，下面那页的门一直开着；但上面这页自己有门、而且画在上面，
/// 过半一开门就先被找到，交接点仍是 0.5。
///
/// 时长、委托转场都转给 [inner]，转场本身一个像素不变。桌面端不包。
class SystemBarsPageTransitionsBuilder extends PageTransitionsBuilder {
  const SystemBarsPageTransitionsBuilder(this.inner);

  /// 真正负责转场的那一档（predictive back / Cupertino）。
  final PageTransitionsBuilder inner;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      inner.delegatedTransition;

  @override
  Duration get transitionDuration => inner.transitionDuration;

  @override
  Duration get reverseTransitionDuration => inner.reverseTransitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Widget transition = inner.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
    // 平台是常量，树的形状不会在运行中变。
    if (!SystemBarStyles.isSupported) return transition;
    return SystemBarsRouteScope(child: transition);
  }
}

class _SystemBarsGate extends SingleChildRenderObjectWidget {
  const _SystemBarsGate({required this.open, super.child});

  final bool open;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSystemBarsGate(open: open);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSystemBarsGate renderObject,
  ) {
    renderObject.open = open;
  }
}

class _RenderSystemBarsGate extends RenderProxyBox {
  _RenderSystemBarsGate({required bool open}) : _open = open;

  bool _open;

  set open(bool value) {
    if (value == _open) return;
    _open = value;
    // 图层每次绘制新建（不产生引擎层），换一下开关只重推这一层，
    // 子树里的重绘边界原样复用。
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => SystemBarStyles.isSupported;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!SystemBarStyles.isSupported) {
      super.paint(context, offset);
      return;
    }
    context.pushLayer(_SystemBarsGateLayer(open: _open), super.paint, offset);
  }
}

/// 关着时，往下找系统栏样式的查询在这里直接返回「没找到」，
/// 查询就会接着去问画在它底下的东西（下面那一页 / 根上兜底）。
class _SystemBarsGateLayer extends ContainerLayer {
  _SystemBarsGateLayer({required this.open});

  final bool open;

  @override
  bool findAnnotations<S extends Object>(
    AnnotationResult<S> result,
    Offset localPosition, {
    required bool onlyFirst,
  }) {
    if (!open && S == SystemUiOverlayStyle) return false;
    return super.findAnnotations<S>(
      result,
      localPosition,
      onlyFirst: onlyFirst,
    );
  }
}
