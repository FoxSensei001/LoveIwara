import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';

/// 全 App 玻璃件**唯一**的点击 / 长按入口，也是「手指移出按钮多远才算放弃这
/// 一下」这条规矩的唯一定义处。
///
/// # 为什么不能直接用 `GestureDetector`
///
/// 框架自带的 tap 识别器有两道距离闸门（`preAcceptSlopTolerance` /
/// `postAcceptSlopTolerance`），默认都是 [kTouchSlop]（18 逻辑像素），量的是
/// **离按下点的直线距离**。液态玻璃这套手感偏偏鼓励人按住不放拖着玩：按住一枚
/// 键蠕动两下、手指走个二三十像素再抬起来是常态，而 18px 一过这一下就已经被
/// 判负——玻璃还黏着手指在变形，点击却早没了，读起来就是「明明按着呢，抬手却
/// 没反应」。
///
/// 这里换成**按边界判**：按下那一刻量下这枚键的矩形，外扩
/// [GlassTokens.touchStaySlop]，手指在这个圈里怎么动都还算「按在这枚键上」，
/// 走出去才作废（按下态一起撤掉，抬手不再触发）。两个好处：
///   - 一条 200px 宽的胶囊，顺着长边挪 30px 手指压根没离开按钮，按距离判会
///     误伤，按边界判不会；
///   - 40px 的小圆钮，容忍圈也有 40+2×slop，「挪出去一点还能点到」自然成立。
///
/// # 滚动照样抢得走
///
/// 关掉的只是**这层自己**的距离判负，竞技场没有动：列表的纵向拖拽、
/// TabBarView / PageView 的横向拖拽仍然在走出 [kTouchSlop] 时自行宣布胜利，把
/// 这层的 tap 判负（`onTapCancel` 会到、按下态跟着撤）。而 [GlassTokens.touchStaySlop]
/// 比 [kTouchSlop] 大，所以**永远是滚动先出手**——「按住列表里的玻璃钮往下滑」
/// 照旧是滚动，不会变成点击。
///
/// # 语义自己发
///
/// 内部走 [RawGestureDetector]（要换掉框架的 tap 识别器只能走这条），而它按
/// **精确类型**去查 `TapGestureRecognizer` 来接无障碍的「激活」动作，换成子类
/// 之后查不着。所以这里一律 `excludeFromSemantics: true`，另外自己挂一个
/// [Semantics]；[excludeFromSemantics] 为真时连这个也不挂——留给外层统一发
/// （[GlassPressable] 的深处触发那一路就是这么用的）。
class GlassTapArea extends StatefulWidget {
  const GlassTapArea({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onPressedChanged,
    this.behavior = HitTestBehavior.opaque,
    this.excludeFromSemantics = false,
    this.sticky = true,
    this.opensOverlay = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 按下态的变化：手指落在这枚键上为真，抬起 / 被取消 / 走出容忍圈为假。
  ///
  /// 走的是不进竞技场的 `Listener`，所以**按下那一帧就到**，不像
  /// `onTapDown` 要等 [kPressTimeout] 的 deadline（有竞争者时）。
  final ValueChanged<bool>? onPressedChanged;

  final HitTestBehavior behavior;

  /// 不挂自己的 [Semantics] 节点，由外层统一发。
  final bool excludeFromSemantics;

  /// 这枚键的 [onTap] 干的事情是**吐出一张浮层**（玻璃菜单 / 下拉板）。
  ///
  /// 置真后多两件事：
  ///   1. **长按也能打开**——没有单独的 [onLongPress] 时，长按 500ms 直接把
  ///      [onTap] 跑掉，不用等抬手；
  ///   2. **手指接力**——长按打开的那一下手指还按着，这根手指会顺势交给刚弹出
  ///      来的面板（[GlassPointerHandoff]），于是「按住 → 划到某一条 → 松手
  ///      选中」一气呵成，不用抬手再点第二下。
  ///
  /// ⛔ **不能默认开**。长按提前触发对「打开菜单」是白赚的，对普通动作键
  /// （刷新 / 关闭 / 提交）却是实打实的破坏：按住看玻璃蠕动是这套材质的基本
  /// 玩法，动作在 500ms 处自己跑掉就再也滑不开、取消不掉了。而组件**没法预知**
  /// [onTap] 会干什么——等它跑完才知道的话副作用早发生了，所以只能由调用点
  /// 声明一次。
  final bool opensOverlay;

  /// 是否启用上面那套「按边界判」的容忍圈。
  ///
  /// 置假就退回框架默认（离按下点 [kTouchSlop] 即判负）。**只给本来就要拿位移
  /// 去做别的事的调用点用**——玻璃菜单的「按住上下划换焦点」就是靠 tap 在
  /// [kTouchSlop] 处自行判负来和点按分家的（见 `glass_menu.dart`），黏上之后
  /// 一次滑动取焦会连带触发行自己的点击，等于选中两遍。
  final bool sticky;

  @override
  State<GlassTapArea> createState() => _GlassTapAreaState();
}

class _GlassTapAreaState extends State<GlassTapArea> {
  /// 按下那一刻量出来的容忍圈（全局坐标）。整段按压期间不再重量：液态档下这枚
  /// 键自己会跟着手指形变，每帧重量的话容忍圈也跟着漂，判定就永远追不上。
  Rect? _stayBounds;

  /// 只跟第一根手指。多指同时落在同一枚键上时，后来的那根不该把容忍圈重量一遍
  /// （量出来的是同一个矩形，但按下态会被它的抬手提前撤掉）。
  int? _pointer;

  bool _pressed = false;

  /// 长按打开浮层之后，这根手指已经交给面板了——后续的移动 / 抬手要转发过去。
  GlassPointerHandoffSession? _handoff;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;
    widget.onPressedChanged?.call(value);
  }

  Rect? _measure() {
    if (!widget.sticky) return null;
    final RenderObject? box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return (box.localToGlobal(Offset.zero) & box.size)
        .inflate(GlassTokens.touchStaySlop);
  }

  bool _outOfRange(Offset position) {
    final Rect? bounds = _stayBounds;
    return bounds != null && !bounds.contains(position);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _stayBounds = _measure();
    _setPressed(true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    if (_pressed && _outOfRange(event.position)) _setPressed(false);
    // 手指已经交出去了：面板那边靠这条流做滑动取焦（它自己收不到这根手指——
    // 命中路径在按下那一刻就定死了，面板当时还不存在）。
    _handoff?.move(event.position);
  }

  void _handlePointerRelease(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    _stayBounds = null;
    _setPressed(false);
    _handoff?.release(event is PointerUpEvent ? event.position : null);
    _handoff = null;
  }

  /// 长按当作「打开浮层」那一下：跑 [GlassTapArea.onTap]，并在它执行的这段
  /// **同步**窗口里挂出手指接力票——`showGlassMenu` 会在自己的同步前缀里认领。
  void _openOverlayByLongPress() {
    final VoidCallback? open = widget.onTap;
    if (open == null || _pointer == null) return;
    // 长按到点了：Android/iOS 上这一下都该有触感，否则「按住不动」到底有没有
    // 生效全靠盯着屏幕看。
    VibrateUtils.vibrate();
    final session = GlassPointerHandoffSession();
    GlassPointerHandoff.offerDuring(session, open);
    if (session.claimed && !session.finished) _handoff = session;
  }

  @override
  void dispose() {
    _handoff?.release(null);
    _handoff = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 没有单独的长按行为、但这枚键就是浮层的触发钮 → 长按顶上，见
    // [GlassTapArea.opensOverlay]。
    final VoidCallback? longPress =
        widget.onLongPress ??
        (widget.opensOverlay && widget.onTap != null
            ? _openOverlayByLongPress
            : null);
    final bool hasGesture = widget.onTap != null || longPress != null;
    if (!hasGesture && widget.onPressedChanged == null) return widget.child;

    Widget result = widget.child;
    if (hasGesture) {
      result = RawGestureDetector(
        behavior: widget.behavior,
        // 语义由下面那层 [Semantics] 统一发，见类注释。
        excludeFromSemantics: true,
        gestures: <Type, GestureRecognizerFactory>{
          if (widget.onTap != null)
            _GlassTapRecognizer:
                GestureRecognizerFactoryWithHandlers<_GlassTapRecognizer>(
                  () => _GlassTapRecognizer(
                    stayBounds: () => _stayBounds,
                    sticky: widget.sticky,
                    debugOwner: this,
                  ),
                  (recognizer) => recognizer
                    ..onTap = widget.onTap
                    // 被别的手势（滚动 / 翻页 / 长按）抢走时按下态要跟着撤。
                    ..onTapCancel = () => _setPressed(false),
                ),
          if (longPress != null)
            LongPressGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                  () => LongPressGestureRecognizer(debugOwner: this),
                  (recognizer) => recognizer..onLongPress = longPress,
                ),
        },
        child: result,
      );
    }

    // 按下态走旁听：不进竞技场、不改命中测试，按下那一帧就点亮。
    result = Listener(
      behavior: widget.behavior,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerRelease,
      onPointerCancel: _handlePointerRelease,
      child: result,
    );

    if (widget.excludeFromSemantics || !hasGesture) return result;
    return Semantics(
      button: true,
      onTap: widget.onTap,
      // 只报**显式**的长按。[GlassTapArea.opensOverlay] 合成出来的那只和点按
      // 干的是同一件事，读屏上多一个「长按」动作只会让人以为还有别的功能。
      onLongPress: widget.onLongPress,
      child: result,
    );
  }
}

/// 把「离按下点多远」的判负换成「有没有走出容忍圈」的 tap 识别器。
///
/// 只改判负这一条，其余（deadline、竞技场、回调时机）全走
/// [TapGestureRecognizer] 原样——滚动、翻页、长按照旧抢得走它。
class _GlassTapRecognizer extends TapGestureRecognizer {
  _GlassTapRecognizer({
    required this.stayBounds,
    required bool sticky,
    super.debugOwner,
  }) : super(
         // 两道 slop 一起关掉：它们量的是离按下点的直线距离，和「有没有离开这
         // 枚键」不是一回事（见 [GlassTapArea] 类注释）。判负改由下面的
         // [handleEvent] 按 [stayBounds] 做。
         preAcceptSlopTolerance: sticky ? null : kTouchSlop,
         postAcceptSlopTolerance: sticky ? null : kTouchSlop,
       );

  /// 当前的容忍圈（全局坐标）；null 表示不做边界判负。
  final Rect? Function() stayBounds;

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent &&
        state == GestureRecognizerState.possible &&
        event.pointer == primaryPointer) {
      final Rect? bounds = stayBounds();
      if (bounds != null && !bounds.contains(event.position)) {
        resolve(GestureDisposition.rejected);
        stopTrackingPointer(event.pointer);
        return;
      }
    }
    super.handleEvent(event);
  }
}

/// 「按住触发钮 → 弹出面板 → 手指不抬直接滑进面板选」的接力站。
///
/// # 为什么需要接力
///
/// 指针的派发路径在**按下那一刻**就由一次命中测试定死了，之后这根手指的
/// move / up 只会发给当初命中的那几层。长按弹出来的面板是**后**建的、还挂在
/// 根 Overlay 上另一棵子树里——它永远收不到这根手指，哪怕手指此刻正悬在它
/// 头顶上。所以只能由还在收事件的触发钮把落点**转发**过去。
///
/// # 认领是一扇同步窗
///
/// 触发钮在跑 `onTap` 的这段**同步**时间里把票挂出来（[offerDuring]），
/// `showGlassMenu` 一类的浮层入口在自己的同步前缀里 [claim] 一下就接上了——
/// 调用点写的还是 `onTap: () => _openSortMenu(ctx)`，不用多传任何东西。
///
/// 抬手才触发的**普通点按**天然认领不到：`onTap` 是在 pointer up 之后才发的，
/// 那时手指已经离开，[GlassPointerHandoffSession.finished] 为真。也就是说
/// 接力只会发生在「长按打开」这条路上，正是它该在的地方。
abstract final class GlassPointerHandoff {
  static GlassPointerHandoffSession? _offered;

  /// 在 [body] 执行期间挂出接力票。
  static void offerDuring(GlassPointerHandoffSession session, VoidCallback body) {
    final GlassPointerHandoffSession? previous = _offered;
    _offered = session;
    try {
      body();
    } finally {
      _offered = previous;
    }
  }

  /// 认领「此刻还按着的那根手指」。没人按着（或已经被别的浮层领走）时返回 null。
  static GlassPointerHandoffSession? claim() {
    final GlassPointerHandoffSession? session = _offered;
    if (session == null || session.finished) return null;
    // 一根手指只交一次：同一次 onTap 里连开两张面板时，后面那张不再接。
    _offered = null;
    session._claimed = true;
    return session;
  }
}

/// 一次接力：触发钮往里喂落点，浮层从里面取。
class GlassPointerHandoffSession {
  Offset? _position;
  bool _finished = false;
  bool _claimed = false;
  ValueChanged<Offset>? _onMove;
  ValueChanged<Offset?>? _onRelease;

  /// 已经有浮层认领过这根手指。
  bool get claimed => _claimed;

  /// 手指已经抬起 / 取消，这次接力结束了。
  bool get finished => _finished;

  /// 最后一次已知的全局落点。浮层挂上来时拿它做**起手焦点**——面板往往是在
  /// 手指底下弹出来的，接上的第一帧就该有焦点，而不是等手指再动一下。
  Offset? get position => _position;

  /// 浮层挂上来收落点。面板要等第一帧布局完（拿得到内容的 RenderBox）再挂。
  void attach({
    required ValueChanged<Offset> onMove,
    required ValueChanged<Offset?> onRelease,
  }) {
    _onMove = onMove;
    _onRelease = onRelease;
  }

  void detach() {
    _onMove = null;
    _onRelease = null;
  }

  // ---- 触发钮侧 ----

  void move(Offset position) {
    if (_finished) return;
    _position = position;
    _onMove?.call(position);
  }

  /// [position] 为 null 表示这一下是取消（而不是正常抬手），浮层不该当成选中。
  void release(Offset? position) {
    if (_finished) return;
    _finished = true;
    if (position != null) _position = position;
    final ValueChanged<Offset?>? onRelease = _onRelease;
    detach();
    onRelease?.call(position);
  }
}
