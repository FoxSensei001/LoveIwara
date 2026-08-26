import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// 「整页跟手侧滑返回」与页内横向手势抢竞技场时，让侧滑返回自动让位的机制。
///
/// ## 为什么必须是机制，而不是逐页开关
///
/// `SwipeablePageRoute` 的手势检测器是一张 `Positioned.fill` 的透明层，盖在整页
/// 内容**之上**（见包内 `_FancyBackGestureDetector`）。按下时它比页内任何控件都先
/// 进手势竞技场，于是同一次右滑里它总是先宣布胜利——页面被弹掉，TabBarView / 横向
/// 列表 / 滑块一个都吃不到手势。包作者给的答案是逐页传 `canOnlySwipeFromEdge`，
/// 那等于每加一个带 Tab 的页面就欠一笔债，且漏一页就复发一次。
///
/// 这里改成：**按下那一刻**就地判断这根手指落在了什么上面，若落点确实存在会吃掉
/// 这个方向拖拽的横向手势，就把本页路由的 `canSwipe` 临时置 false，抬手再还原。
/// `_FancyBackGestureDetector` 每收到一个 move 事件都会重读 `canSwipe`，读到 false
/// 就 `stopTrackingPointer` 退出竞技场，横向控件自然接管。
///
/// 时序上成立的原因：按下事件按命中路径派发，透明手势层在前（只是 `addPointer`
/// 登记，尚未判定），本组件的 [Listener] 在后（这时置 false），真正的判定发生在
/// 之后的 move 事件里。
///
/// ## 判定口径：边界让渡
///
/// 只有「该横向控件还能继续朝这个方向滚」时才让位。TabBarView 停在第一个 tab、
/// 横向 tab 条已经滑到最左时，右滑对它们没有任何意义，此时仍旧返回上一页——这正是
/// 微信 / Telegram 的观感，也保证「整页跟手」不会因为页面里有 Tab 就整片失效。
///
/// ## 覆盖不到的情形
///
/// 手势识别器直接建在 RenderObject 里、又不走 `GestureDetector` 的控件（典型是
/// Material `Slider`）没有可供识别的公共特征，需要在控件收口处显式包一层
/// [SwipeBackAbsorber]。
class SwipeBackScrollGuard extends StatefulWidget {
  const SwipeBackScrollGuard({super.key, required this.child});

  final Widget child;

  @override
  State<SwipeBackScrollGuard> createState() => _SwipeBackScrollGuardState();
}

/// 显式声明「这块区域自己要吃横向拖拽」，按下期间关掉整页跟手侧滑返回。
///
/// 给 [SwipeBackScrollGuard] 自动识别不到的控件用：手势识别器藏在 RenderObject
/// 里的 Material `Slider`（见 `GlassSlider`）就是这一类。用在**控件收口处**，
/// 别在页面里一处处包。
class SwipeBackAbsorber extends StatefulWidget {
  const SwipeBackAbsorber({super.key, required this.child});

  final Widget child;

  @override
  State<SwipeBackAbsorber> createState() => _SwipeBackAbsorberState();
}

/// 判定「已经滑到头」的像素容差。`precisionErrorTolerance`（1e-10）对滚动像素太紧，
/// 半个逻辑像素的残留偏移不该让整页侧滑失效。
const double _boundaryTolerance = 0.5;

/// 按下期间临时关掉本页 `canSwipe`、抬手还原的公共部分。
mixin _SwipeBackSuppression<T extends StatefulWidget> on State<T> {
  final Set<int> _activePointers = <int>{};
  SwipeablePageRoute<dynamic>? _suppressedRoute;

  /// 本页不是跟手侧滑页（非 iOS / 页面自己已经关掉）时是空操作。
  void _suppressFor(int pointer) {
    if (_activePointers.contains(pointer)) return;
    if (_suppressedRoute == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route is! SwipeablePageRoute) return;
      // 页面自己关掉的别去动，免得抬手时替它打开。
      if (!route.canSwipe) return;
      route.canSwipe = false;
      _suppressedRoute = route;
    }
    _activePointers.add(pointer);
  }

  void _releasePointer(PointerEvent event) {
    if (!_activePointers.remove(event.pointer)) return;
    if (_activePointers.isEmpty) _releaseAll();
  }

  void _releaseAll() {
    _activePointers.clear();
    _suppressedRoute?.canSwipe = true;
    _suppressedRoute = null;
  }

  @override
  void dispose() {
    _releaseAll();
    super.dispose();
  }
}

class _SwipeBackScrollGuardState extends State<SwipeBackScrollGuard>
    with _SwipeBackSuppression<SwipeBackScrollGuard> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _releasePointer,
      onPointerCancel: _releasePointer,
      child: widget.child,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_hitsCompetingHorizontalGesture(event.position)) return;
    _suppressFor(event.pointer);
  }

  /// 就地对本页子树做一次命中测试，看落点上有没有会吃掉「返回方向」拖拽的东西。
  bool _hitsCompetingHorizontalGesture(Offset globalPosition) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;

    final Offset local = renderObject.globalToLocal(globalPosition);
    if (!(Offset.zero & renderObject.size).contains(local)) return false;

    final BoxHitTestResult result = BoxHitTestResult();
    renderObject.hitTest(result, position: local);

    // 侧滑返回只吃「从起始边往回拖」：LTR 是右滑，RTL 是左滑。
    final bool backDragIsRightward =
        Directionality.of(context) == TextDirection.ltr;
    final Set<RenderObject> judged = <RenderObject>{};
    for (final HitTestEntry<HitTestTarget> entry in result.path) {
      final HitTestTarget target = entry.target;
      if (target is! RenderObject) continue;

      // `GestureDetector`（含 onPan* / onHorizontalDrag*）和每一只 `Scrollable`
      // 都会在这里留下语义手势节点。Scrollable 那只必须回到它自己的 viewport 上
      // 判边界，否则「滑到头就让给返回」永远不成立。
      if (target is RenderSemanticsGestureHandler) {
        if (target.onHorizontalDragUpdate == null) continue;
        final RenderObject? viewport = _viewportBelow(target);
        // 认不出对应的 viewport，就是页面自己写的横向拖拽区域（滑块、拖拽把手…），
        // 没有边界可言，直接让位。
        if (viewport == null) return true;
        // 同一只 viewport 已经在命中路径里判过了，别判第二遍。
        if (!judged.add(viewport)) continue;
        final bool? consumes = _viewportConsumesBackDrag(
          viewport,
          backDragIsRightward: backDragIsRightward,
        );
        if (consumes ?? true) return true;
        continue;
      }

      final bool? consumes = _viewportConsumesBackDrag(
        target,
        backDragIsRightward: backDragIsRightward,
      );
      if (consumes == null) continue;
      judged.add(target);
      if (consumes) return true;
    }
    return false;
  }

  /// 从 [Scrollable] 的语义手势节点往下找它自己的 viewport。
  ///
  /// `Scrollable` 的内部结构是固定的一串单孩子（Listener → Semantics →
  /// IgnorePointer → viewport），所以只沿单孩子链下探；一分叉就说明这不是
  /// Scrollable，交还给调用方按「页面自绘的横向手势」处理。
  ///
  /// 命中路径本身不能替代这一步：viewport 只有在落点确实命中了它的内容时才会进
  /// 路径，而横向 tab 条的空隙、卡片之间的间距都命不中，只有 Scrollable 那层
  /// opaque 的手势层恒在。
  static RenderObject? _viewportBelow(RenderObject start, {int maxDepth = 8}) {
    RenderObject? current = start;
    for (int depth = 0; depth < maxDepth; depth++) {
      RenderObject? onlyChild;
      int count = 0;
      current!.visitChildren((child) {
        onlyChild = child;
        count++;
      });
      if (count != 1) return null;
      if (onlyChild is RenderAbstractViewport) return onlyChild;
      current = onlyChild;
    }
    return null;
  }

  /// 该 viewport 还能不能朝「返回方向」继续滚。
  ///
  /// 返回 `null` 表示这个命中目标压根不是横向 viewport。
  static bool? _viewportConsumesBackDrag(
    RenderObject target, {
    required bool backDragIsRightward,
  }) {
    if (target is! RenderAbstractViewport) return null;

    // `RenderViewportBase`（ListView / PageView / TabBarView…）和
    // `SingleChildScrollView` 的私有 viewport 都有 axisDirection / offset，
    // 但没有公共基类声明它们，只能鸭子类型取。
    final dynamic viewport = target;
    final AxisDirection direction;
    final ViewportOffset offset;
    try {
      final dynamic rawDirection = viewport.axisDirection;
      final dynamic rawOffset = viewport.offset;
      if (rawDirection is! AxisDirection || rawOffset is! ViewportOffset) {
        return null;
      }
      direction = rawDirection;
      offset = rawOffset;
    } on NoSuchMethodError {
      return null;
    }

    if (axisDirectionToAxis(direction) != Axis.horizontal) return null;
    if (offset is! ScrollPosition) return null;

    final ScrollPosition position = offset;
    if (!position.hasPixels || !position.hasContentDimensions) return null;
    // NeverScrollableScrollPhysics、以及压根没有可滚内容的横向容器都在这里出局：
    // 它们吃不下拖拽，也就轮不到它们决定要不要让位。
    if (!position.physics.shouldAcceptUserOffset(position)) return null;

    // AxisDirection.right 下内容右移 = 偏移变小，AxisDirection.left 反之。
    final bool needsDecreasingPixels =
        (direction == AxisDirection.right) == backDragIsRightward;
    return needsDecreasingPixels
        ? position.pixels > position.minScrollExtent + _boundaryTolerance
        : position.pixels < position.maxScrollExtent - _boundaryTolerance;
  }
}

class _SwipeBackAbsorberState extends State<SwipeBackAbsorber>
    with _SwipeBackSuppression<SwipeBackAbsorber> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _suppressFor(event.pointer),
      onPointerUp: _releasePointer,
      onPointerCancel: _releasePointer,
      child: widget.child,
    );
  }
}
