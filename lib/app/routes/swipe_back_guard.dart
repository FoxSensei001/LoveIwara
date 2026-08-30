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

/// 跟手侧滑进行中时，把「第二根手指」挡在这一页的命中路径之外。
///
/// ## 为什么需要
///
/// 包里的手势识别器（`_DirectionDependentDragGestureRecognizer`）继承
/// `HorizontalDragGestureRecognizer`，却没有设置 `multitouchDragStrategy`，于是
/// 用的是 Flutter 的默认值 [MultitouchDragStrategy.latestPointer]——框架文档里
/// 写明这是 **Android** 的手感，iOS 该用 `averageBoundaryPointers`。它的语义是
/// 「永远只跟最新落下的那根手指」：拖拽已经开始后再落下一根手指，
/// `_activePointer` 立刻切给新指针，原来那根手指后续的 move 全被丢弃。
///
/// 而这根新指针通常是掌根 / 虎口 / 另一只手扶屏幕蹭上来的，从落下到抬起一动
/// 不动，于是连锁反应是：
///   1. 页面**定格在半路**（路由的 AnimationController 停在 0.8 之类的中间值），
///      原来那根手指怎么滑都没有反馈；
///   2. 原手指抬起也不是「最后一根被跟踪的指针」，`didStopTrackingLastPointer`
///      不触发 → `onEnd` 不发 → `dragEnd` 不跑 → 动画永远停在那儿，
///      `navigator.didStopUserGesture()` 也永远不会调用；
///   3. 此后**每一次**新的侧滑都被 `_isPopGestureEnabled` 挡掉：路由动画状态不是
///      `completed`，而且 `popGestureInProgress` 读的是 `NavigatorState`
///      **整只 navigator** 的 `userGestureInProgress`——一页卡住，全应用的跟手
///      返回一起哑掉，直到那根滞留指针真的抬起（或某处 push/pop 触发
///      `Navigator._cancelActivePointers`）。应用其它部分毫发无损，所以看起来
///      「只有返回手势坏了」。
///
/// 系统原生的边缘返回没这个毛病，是因为它的手势层只有屏幕最左边一条 20px，
/// 蹭在页面中间的手指根本进不了它的命中路径。我们把手势层铺满整页之后，这个
/// 默认策略就从「几乎撞不上」变成了「概率必现」。
///
/// ## 做法
///
/// 挂在**手势层之上**（经由 `SwipeablePage.transitionBuilder`，包里的
/// `_FancyBackGestureDetector` 是在那之后才被 transitionBuilder 收进来的），
/// 在 `hitTest` 里现读 `navigator.userGestureInProgress`：跟手拖拽进行中、且本页
/// 已经有手指按着时，新落下的指针直接被这一层吃掉，不再往下派发——识别器压根
/// 见不到它，`_activePointer` 也就不会被抢走。
///
/// 读的是 navigator 的实时状态而不是 `setState` 出来的快照，所以拖拽开始的那一
/// 帧就已经生效，没有一帧的空窗。弹出动画期间 `userGestureInProgress` 同样为
/// true，但那时本页没有手指按着（`_pointersDown` 是空的），点按照常放行。
class SwipeBackSinglePointerGate extends StatelessWidget {
  const SwipeBackSinglePointerGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null) return child;
    return _SwipeBackPointerGate(navigator: navigator, child: child);
  }
}

class _SwipeBackPointerGate extends SingleChildRenderObjectWidget {
  const _SwipeBackPointerGate({required this.navigator, required super.child});

  final NavigatorState navigator;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSwipeBackPointerGate(navigator);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSwipeBackPointerGate renderObject,
  ) {
    renderObject.navigator = navigator;
  }
}

class _RenderSwipeBackPointerGate extends RenderProxyBoxWithHitTestBehavior {
  _RenderSwipeBackPointerGate(this.navigator)
    : super(behavior: HitTestBehavior.translucent);

  NavigatorState navigator;

  /// 本页当前按着的手指。命中路径是按下那一刻定下来的，所以 up / cancel 一定会
  /// 回到这一层，不会漏账。
  final Set<int> _pointersDown = <int>{};

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_pointersDown.isNotEmpty && navigator.userGestureInProgress) {
      // 吃掉它：既不给上面的手势层，也不漏到下面那一页去。
      if (size.contains(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return false;
    }
    return super.hitTest(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pointersDown.add(event.pointer);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointersDown.remove(event.pointer);
    }
    super.handleEvent(event, entry);
  }
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
