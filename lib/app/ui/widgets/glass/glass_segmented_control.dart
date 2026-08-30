import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;

class GlassSegmentItem {
  const GlassSegmentItem({required this.label, this.icon});

  final String label;
  final Widget? icon;
}

/// 玻璃分段胶囊：一个长胶囊里放多个文字段，选中段用滑动高亮块标记，
/// 段数多时可横向滚动（支持桌面滚轮），选中项变化时自动滚到可见。
///
/// 支持「长按拾起」：长按后高亮块微放大并跟随手指滑动（跨段有触感反馈），
/// 松手落在手指所在段——液态玻璃的跟手质感。
///
/// ## 高亮块在 [GlassBackend.liquidWidgets] 档下换成果冻玻璃指示器
///
/// 那一档里高亮块不再是一块 `DecoratedBox`，而是
/// `liquid_glass_widgets` 的 `AnimatedGlassIndicator`——**静止时是实心药丸，
/// 一开始移动就化成液态玻璃并被速度挤压（果冻物理），落位后再凝回实心**。
/// 照他们自己的用法分成上下两趟画（见 `_buildJellyStack`）：
///   - 第一趟在文字**底下**，只画实心药丸；
///   - 第二趟在文字**上面**，只画玻璃——这样 shader 采样得到文字，
///     滑过去的时候字会跟着折射。iOS 26 的分段控件就是这个读法。
///
/// 本组件其余能力**一概不变**：跟着 `TabBarView` 滑动实时联动
/// （[progress]）、长按拾起跟手、选中项自动滚到可见、[minWidthFor] 断点。
/// 这也是没有整只换成他们的 `GlassSegmentedControl` 的原因——那边没有外部
/// progress 入口，滑页时指示器只能等页面落位后才动，不跟手。
class GlassSegmentedControl extends StatefulWidget {
  const GlassSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.progress,
    this.height = GlassTokens.pillHeight,
    this.flat = false,
  });

  final List<GlassSegmentItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// `true`：去掉自带的玻璃壳（底色/描边/阴影），只渲染分段内容。
  /// 放进 `GlassCapsuleMorph` 这类自带玻璃壳的外层容器时用，避免双层壳。
  final bool flat;

  /// 可选：连续的「当前位置」（典型地传 `TabController.animation`，或由
  /// `PageController.page` 喂出来的 `ValueNotifier<double>`，值为小数下标）。
  /// 传入后高亮块与文字颜色会随横向滑动进度实时插值，而不是等切换完成后才跳到新段。
  final ValueListenable<double>? progress;
  final double height;

  /// 段内左右内边距。测量（[minWidthFor]）与真实布局共用同一组常量，
  /// 别让两边各写各的漂移开。
  static const double itemHorizontalPadding = 14;

  /// 段内图标尺寸与图标到文字的间距。
  static const double itemIconSize = 16;
  static const double itemIconGap = 5;

  /// 胶囊内缩（分段与玻璃壳之间的留白）。
  static const double capsuleInset = 4;

  static TextStyle _labelStyle(BuildContext context) =>
      (Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 14))
          .copyWith(fontWeight: FontWeight.w600);

  /// 平铺版本要**完整显示** [minVisibleItems] 个段，胶囊至少得有多宽。
  ///
  /// header 中间摆不下时会退化成下拉钮，但「摆不下」不该是拍脑袋的魔法数字：
  /// 同一个阈值在中文两字标签下富余、在英文长标签下不够，换个语言就判错。
  /// 这里按真实文案量出每段的宽度，取**最宽的那几段**求和——这样不管横向
  /// 滚到哪一段，都保证至少有 [minVisibleItems] 个段是完整的；连这个都摆不
  /// 下，平铺就没有意义了（只能看见一个段还得横着拨），该让位给下拉钮。
  ///
  /// [minVisibleItems] 支持小数（约定值 2.5）：整数部分的段完整计入，
  /// 小数部分按比例算下一段（次宽的那段）的宽度——只够刚好露出 2 个完整段
  /// 时不算「够」，得再多出半段的宽度做视觉余量/可横滑的提示，否则退化成
  /// 下拉钮反而更清爽。
  static double minWidthFor(
    BuildContext context,
    List<GlassSegmentItem> items, {
    double minVisibleItems = 2.5,
  }) {
    if (items.isEmpty) return 0;
    final TextStyle style = _labelStyle(context);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextDirection direction = Directionality.of(context);

    final widths = <double>[];
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(text: item.label, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      double width = painter.width + itemHorizontalPadding * 2;
      if (item.icon != null) width += itemIconSize + itemIconGap;
      painter.dispose();
      widths.add(width);
    }
    widths.sort((a, b) => b.compareTo(a));

    final double effectiveMin = minVisibleItems.clamp(
      1,
      widths.length.toDouble(),
    );
    final int fullCount = effectiveMin.floor();
    final double frac = effectiveMin - fullCount;
    double total = 0;
    for (var i = 0; i < fullCount; i++) {
      total += widths[i];
    }
    if (frac > 0 && fullCount < widths.length) {
      total += widths[fullCount] * frac;
    }
    // 胶囊内缩 + 左右两条玻璃描边
    return total + capsuleInset * 2 + GlassTokens.strokeWidth * 2;
  }

  @override
  State<GlassSegmentedControl> createState() => _GlassSegmentedControlState();
}

// ---- 果冻指示器（[GlassBackend.liquidWidgets] 档）----

/// 化成玻璃 / 凝回实心的两段时长。凝回慢一点，落位后还能挂一小会儿余韵。
const Duration _jellyRiseDuration = Duration(milliseconds: 180);
const Duration _jellyFallDuration = Duration(milliseconds: 300);

/// 认定「在动」的阈值：小数下标离最近的整数有这么远就算还在路上。
/// 与他们内部那条 0.05 是同一个意思，只是我们的单位是「段」不是 alignment。
const double _jellyMovingEpsilon = 0.02;

/// 折射挤压强度，取他们 `GlassSegmentedControl` 的标定值。
const double _jellyPinch = 0.4;

/// 拖拽时药丸的胀出量。
///
/// 他们的默认值是 12/8，但那是给自带 2px 内边距、且外面没有壳的控件用的。
/// 我们这只分段胶囊四周只有 [GlassSegmentedControl.capsuleInset]（4）的内缩，
/// 外面还罩着一层会按形状裁切的玻璃壳（`GlassCapsuleMorph` → `GlassSurface`）
/// ——胀出量一旦超过内缩，果冻在两端就会被切出一道直边，比不胀还难看。
/// 所以按内缩本身取值、再留一像素给抗锯齿。
const EdgeInsets _jellyExpansion = EdgeInsets.all(
  GlassSegmentedControl.capsuleInset - 1,
);

class _GlassSegmentedControlState extends State<GlassSegmentedControl>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rowKey = GlobalKey();
  List<GlobalKey> _itemKeys = [];

  double? _highlightLeft;
  double? _highlightWidth;
  bool _hasMeasured = false;
  int _measureRetries = 0;

  /// 每个段相对于 Row 的 (left, width)，供 progress 驱动模式做插值。
  List<Rect>? _itemRects;

  // ---- 长按跟手拖拽 ----
  /// 拾起 / 落位共用的过渡动画（两个阶段在时间上不重叠）。
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _dragging = false;

  /// 拖拽中的小数下标（以各段中心做分段线性反插值）。
  double? _dragT;

  /// 拾起瞬间高亮所在的小数下标：长按后先从这里「追」到手指，避免瞬移。
  double? _grabFrom;

  /// 松手瞬间的小数下标；非 null 表示落位/等待 progress 汇合中。
  double? _releaseFrom;
  int _releaseTarget = 0;
  int? _lastHapticIndex;
  bool _cleanupScheduled = false;

  // ---- 果冻指示器（只在 GlassBackend.liquidWidgets 档下用到）----

  /// 指示器的「玻璃化」程度：0 = 静止的实心药丸，1 = 跟手的液态玻璃。
  late final AnimationController _jelly = AnimationController(
    vsync: this,
    duration: _jellyRiseDuration,
    reverseDuration: _jellyFallDuration,
  );

  /// `_jelly` 当前的目标端，用来避免每帧都重下一次 forward/reverse。
  bool _jellyUp = false;

  /// 没有 [GlassSegmentedControl.progress] 时的换段过渡。
  ///
  /// 传统档那条路用 `AnimatedPositioned` 隐式插值就够了，但果冻指示器是自己
  /// 定位的（`exactOffset`/`exactWidth`），套不进 `AnimatedPositioned`，
  /// 只能自己插。progress 驱动时这条闲置。
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
  );
  double? _hopFromLeft;
  double? _hopFromWidth;

  /// 指示器速度，单位与他们内部一致：**整条控件归一到 [-1, 1] 后每秒走多少**。
  /// 喂给 `AnimatedGlassIndicator.velocity` 去算果冻挤压。
  double _velocity = 0;
  double? _lastT;
  Duration? _lastStamp;

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
    // 拾起追赶 / 落位动画期间逐帧重建（高亮位置与文字颜色都依赖 _overrideT）
    _slideController.addListener(() {
      if (mounted && (_dragging || _releaseFrom != null)) setState(() {});
    });
    // 果冻档的「在不在动」必须在**帧回调里**判，不能只在 build 里判：
    // 动画停下来的那一帧之后 build 就不再跑了，玻璃会僵在半路凝不回去。
    _slideController.addListener(_onMotionTick);
    _hop.addListener(_onMotionTick);
    widget.progress?.addListener(_onMotionTick);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _measure(animateScroll: false),
    );
  }

  /// 每一帧位置变化后：量一次速度，再决定玻璃该化开还是凝回。
  void _onMotionTick() {
    if (!mounted) return;
    final double? t = _liveT;
    if (t != null) _trackVelocity(t);
    final bool moving = _dragging || _isBetweenSegments(t);
    if (moving == _jellyUp) return;
    _jellyUp = moving;
    if (moving) {
      _jelly.forward();
    } else {
      _jelly.reverse();
    }
  }

  /// 当前的小数下标（拖拽/落位覆盖优先，其次 progress）。都没有时为 null。
  double? get _liveT => _overrideT ?? widget.progress?.value;

  bool _isBetweenSegments(double? t) {
    if (t != null) return (t - t.roundToDouble()).abs() > _jellyMovingEpsilon;
    return _hop.isAnimating;
  }

  void _trackVelocity(double t) {
    final SchedulerBinding binding = SchedulerBinding.instance;
    final double? lastT = _lastT;
    final Duration? lastStamp = _lastStamp;
    if (binding.schedulerPhase == SchedulerPhase.idle) {
      // 不在帧里（例如外部直接改了 progress）：留下位置但不猜时间。
      _lastT = t;
      _lastStamp = null;
      return;
    }
    final Duration now = binding.currentFrameTimeStamp;
    _lastT = t;
    _lastStamp = now;
    if (lastT == null || lastStamp == null) return;
    final double dt = (now - lastStamp).inMicroseconds / 1e6;
    // 掉帧 / 页面挂起后回来：这一大段位移不代表速度，丢掉。
    if (dt <= 0 || dt > 0.1) {
      _velocity = 0;
      return;
    }
    final int span = widget.items.length - 1;
    if (span <= 0) {
      _velocity = 0;
      return;
    }
    // 「段/秒」换算成他们的单位：整条控件归一到 [-1, 1]，一个段 = 2/span。
    _velocity = (t - lastT) / dt * (2 / span);
  }

  /// 覆盖位置：
  /// - 拖拽中：从拾起位置「追」向手指（追上后 1:1 跟手）；
  /// - 落位中：从松手位置**单调**滑到目标段（绝不向仍在路上的 progress 混合，
  ///   否则会被旧位置往回拽出左右晃动），到位后停在目标段等 progress 追到，
  ///   两者重合的那一刻才交还，肉眼无跳变；
  /// - 空闲：null（回落到 progress / 静态测量驱动）。
  double? get _overrideT {
    if (_dragging && _dragT != null) {
      final from = _grabFrom;
      if (from == null) return _dragT;
      final double f = Curves.easeOutCubic.transform(_slideController.value);
      return from + (_dragT! - from) * f;
    }
    final from = _releaseFrom;
    if (from != null) {
      final double target = _releaseTarget.toDouble();
      if (_slideController.isCompleted) {
        final p = widget.progress;
        if (p == null || (p.value - target).abs() < 0.02) {
          // progress 已汇合：下一帧清掉覆盖，交还驱动权
          _scheduleReleaseCleanup();
          return null;
        }
        return target;
      }
      final double f = Curves.easeOutCubic.transform(_slideController.value);
      return from + (target - from) * f;
    }
    return null;
  }

  void _scheduleReleaseCleanup() {
    if (_cleanupScheduled) return;
    _cleanupScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cleanupScheduled = false;
      if (mounted && _releaseFrom != null && _slideController.isCompleted) {
        setState(() => _releaseFrom = null);
      }
    });
  }

  /// 手指 x（Row 坐标系）→ 小数下标：以各段中心为锚做分段线性反插值。
  double _positionForDx(double dx) {
    final rects = _itemRects!;
    if (dx <= rects.first.center.dx) return 0;
    if (dx >= rects.last.center.dx) return (rects.length - 1).toDouble();
    for (var i = 0; i < rects.length - 1; i++) {
      final c0 = rects[i].center.dx;
      final c1 = rects[i + 1].center.dx;
      if (dx >= c0 && dx <= c1) {
        return i + (dx - c0) / (c1 - c0);
      }
    }
    return (rects.length - 1).toDouble();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (_itemRects == null || _itemRects!.isEmpty) return;
    _slideController.stop();
    HapticFeedback.mediumImpact();
    setState(() {
      _dragging = true;
      // 从当前视觉位置（可能正处于落位途中）出发追手指，而不是瞬移
      _grabFrom =
          _overrideT ??
          widget.progress?.value ??
          widget.selectedIndex.toDouble();
      _releaseFrom = null;
      _dragT = _positionForDx(details.localPosition.dx);
      _lastHapticIndex = _dragT!.round();
    });
    _slideController.duration = const Duration(milliseconds: 220);
    _slideController.forward(from: 0);
  }

  void _handleLongPressMove(LongPressMoveUpdateDetails details) {
    if (!_dragging || _itemRects == null) return;
    final t = _positionForDx(details.localPosition.dx);
    final idx = t.round();
    if (idx != _lastHapticIndex) {
      _lastHapticIndex = idx;
      HapticFeedback.selectionClick();
    }
    setState(() => _dragT = t);
    // 段可滚动时，拖到边缘保证目标段可见
    final rect = _itemRects![idx.clamp(0, _itemRects!.length - 1)];
    _ensureVisible(rect.left, rect.width, animate: false);
  }

  void _finishDrag({required bool commit}) {
    if (!_dragging) return;
    // 从当前视觉位置（可能还在拾起追赶途中）出发落位
    final double from = _overrideT ?? _dragT ?? widget.selectedIndex.toDouble();
    final int target = commit
        ? (_dragT ?? from).round().clamp(0, widget.items.length - 1)
        : widget.selectedIndex;
    setState(() {
      _dragging = false;
      _dragT = null;
      _grabFrom = null;
      _releaseFrom = from;
      _releaseTarget = target;
    });
    _slideController.duration = const Duration(milliseconds: 260);
    _slideController.forward(from: 0);
    if (commit && target != widget.selectedIndex) {
      HapticFeedback.lightImpact();
      widget.onChanged(target);
    }
  }

  @override
  void didUpdateWidget(covariant GlassSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.progress, widget.progress)) {
      oldWidget.progress?.removeListener(_onMotionTick);
      widget.progress?.addListener(_onMotionTick);
    }
    if (oldWidget.items.length != widget.items.length) {
      _rebuildKeys();
      _hasMeasured = false;
    }
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.items.length != widget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  @override
  void dispose() {
    widget.progress?.removeListener(_onMotionTick);
    _slideController.dispose();
    _jelly.dispose();
    _hop.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _rebuildKeys() {
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
  }

  void _measure({bool animateScroll = true}) {
    if (!mounted) return;
    final index = widget.selectedIndex;
    if (index < 0 || index >= _itemKeys.length) return;
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    final itemBox =
        _itemKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null ||
        itemBox == null ||
        !rowBox.hasSize ||
        !itemBox.hasSize) {
      // 首帧可能还没完成布局：有限次重试，避免高亮块一直不出现
      if (!_hasMeasured && _measureRetries < 3) {
        _measureRetries++;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _measure(animateScroll: animateScroll),
        );
      }
      return;
    }
    _measureRetries = 0;
    final offset = itemBox.localToGlobal(Offset.zero, ancestor: rowBox);
    final left = offset.dx;
    final width = itemBox.size.width;

    // 顺手量出所有段的位置（progress 驱动模式需要）
    final rects = <Rect>[];
    for (final key in _itemKeys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        rects.clear();
        break;
      }
      final o = box.localToGlobal(Offset.zero, ancestor: rowBox);
      rects.add(Rect.fromLTWH(o.dx, 0, box.size.width, box.size.height));
    }
    final bool rectsChanged =
        rects.isNotEmpty && !_sameRects(rects, _itemRects);

    if (_highlightLeft != left ||
        _highlightWidth != width ||
        !_hasMeasured ||
        rectsChanged) {
      // 果冻档没有 AnimatedPositioned 可用（指示器自己定位），换段时得自己
      // 从旧位置插到新位置——记下起点并起跑。progress 驱动时这条不参与。
      if (_hasMeasured &&
          widget.progress == null &&
          _highlightLeft != null &&
          (_highlightLeft != left || _highlightWidth != width)) {
        _hopFromLeft = _highlightLeft;
        _hopFromWidth = _highlightWidth;
        _hop.forward(from: 0);
      }
      setState(() {
        _highlightLeft = left;
        _highlightWidth = width;
        _hasMeasured = true;
        if (rects.isNotEmpty) _itemRects = rects;
      });
    }
    _ensureVisible(left, width, animate: animateScroll);
  }

  static bool _sameRects(List<Rect> a, List<Rect>? b) {
    if (b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i].left - b[i].left).abs() > 0.5 ||
          (a[i].width - b[i].width).abs() > 0.5) {
        return false;
      }
    }
    return true;
  }

  /// progress 驱动模式下，按小数下标插值出高亮块的 (left, width)。
  (double, double)? _interpolatedHighlight(double value) {
    final rects = _itemRects;
    if (rects == null || rects.isEmpty) return null;
    final double t = value.clamp(0.0, (rects.length - 1).toDouble());
    final int i0 = t.floor();
    final int i1 = (i0 + 1).clamp(0, rects.length - 1);
    final double f = t - i0;
    final left = rects[i0].left + (rects[i1].left - rects[i0].left) * f;
    final width = rects[i0].width + (rects[i1].width - rects[i0].width) * f;
    return (left, width);
  }

  void _ensureVisible(double left, double width, {required bool animate}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final viewport = position.viewportDimension;
    final current = position.pixels;
    double target = current;
    const margin = 12.0;
    if (left - margin < current) {
      target = left - margin;
    } else if (left + width + margin > current + viewport) {
      target = left + width + margin - viewport;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - current).abs() < 0.5) return;
    if (animate) {
      _scrollController.animateTo(
        target,
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final next = (position.pixels + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double inset = GlassSegmentedControl.capsuleInset;
    final double innerHeight = widget.height - inset * 2;
    // 只有 widgets 那一档换果冻指示器；另外两档的高亮块一如既往。
    final bool jelly =
        LiquidGlassScope.of(context) == GlassBackend.liquidWidgets;
    // 果冻那一趟**玻璃透镜**只在没被融合层罩着时才画，见 [_buildJellyStack]。
    final bool jellyLens = jelly && !GlassBlendGroup.isInside(context);

    final Widget row = Row(
      key: _rowKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          _buildItem(context, i, cs, innerHeight),
      ],
    );

    final Widget core = Listener(
      onPointerSignal: _onPointerSignal,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          // 长按拾起高亮块跟手滑动；轻点和横向滚动仍由原手势处理。
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPressStart: _handleLongPressStart,
            onLongPressMoveUpdate: _handleLongPressMove,
            onLongPressEnd: (_) => _finishDrag(commit: true),
            onLongPressCancel: () => _finishDrag(commit: false),
            child: jelly
                ? _buildJellyStack(cs, innerHeight, row, lens: jellyLens)
                : Stack(
                    children: [
                      if (_highlightLeft != null && _highlightWidth != null)
                        _buildHighlight(cs, innerHeight),
                      row,
                    ],
                  ),
          ),
        ),
      ),
    );

    if (widget.flat) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: inset, vertical: inset),
        child: core,
      );
    }
    return GlassSurface(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: inset, vertical: inset),
      clipContent: true,
      child: core,
    );
  }

  /// 果冻档的三层：实心药丸 → 文字 → 玻璃。
  ///
  /// 玻璃那一趟压在文字**上面**是有意的：`AnimatedGlassIndicator` 的 premium
  /// 通路靠采样身下的像素做折射，压在文字上滑过去时字才会跟着被镜头拉一下
  /// ——这正是他们（和 iOS 26）分段控件的读法，也是这次要换过来的那个观感。
  ///
  /// ## ⚠️ 药丸那一趟的 thickness 恒为 0，不跟着果冻走
  ///
  /// `AnimatedGlassIndicator` 内部把实心药丸的不透明度定死成
  /// `1 - thickness / 0.15`——thickness 一过 0.15 药丸就整只淡没，全靠玻璃透镜
  /// 顶上。他们能这么做是因为原设计里指示器身后是有内容、有对比度的。
  ///
  /// 我们这儿不成立：header 底下压着 `EdgeFadeScrim`，是一片接近纯白的低对比
  /// 背景，透镜（`baseAlphaMultiplier` 0.2，中心近乎全清）在上面**什么都显不出来**。
  /// OnePlus Pad 真机实测：滑到两段之间时选中指示器整个消失，比不换还糟。
  ///
  /// 所以药丸这一趟固定喂 `thickness: 0`——它本来在 premium 通路下就长在果冻
  /// Transform 外面（刚性、不参与挤压），喂 0 只是额外保证它**全程不透明**，
  /// 顺带也不吃 [_jellyExpansion] 的胀出。果冻与折射由上面那趟玻璃单独承担。
  ///
  /// ## ⛔ [lens] = false：被融合层罩住时，玻璃那一趟必须整只不画
  ///
  /// 上面那段说的「透镜在这片近乎纯白的背景上什么都显不出来」，是把它当成
  /// **良性无效**接受下来的。2026-08-23 给 header 行加上 [GlassBlendGroup] 之后
  /// 这条前提当场翻掉：融合层把整行 chrome 收进一个 `LiquidGlassLayer` +
  /// `BackdropGroup`，指示器身下不再是那片平坦的白，而是**折射过的玻璃输出**
  /// ——透镜忽然有东西可折射了。用户当场报的就是这一条：
  ///
  /// > 主体色的 focus 背景下面出现了一层液态玻璃、透明的，只有切 tab 的时候
  /// > 跟着 focus 区域出现和消失，之前是没有的。
  ///
  /// 每一处细节都对得上：只在换段途中出现（`thickness: _jelly.value` 只有
  /// 途中非零）、跟着 focus 区域走（同一份几何）、比药丸大一圈所以从底下透出来
  /// （[_jellyExpansion] 的胀出）。
  ///
  /// 既然这趟透镜在这个背景下本来就贡献不了观感（真机实测），被融合层照亮之后
  /// 又只剩副作用，就在融合层底下**整只不画**——留下的正是换之前的样子：一枚
  /// 不透明的实心药丸。融合层之外（传统档 / easy 档 / `blendHeader: false` /
  /// 将来独立摆放的分段控件）一切照旧。
  Widget _buildJellyStack(
    ColorScheme cs,
    double innerHeight,
    Widget row, {
    required bool lens,
  }) {
    return AnimatedBuilder(
      // row 走 child 透传，逐帧重建的只有两趟指示器。
      animation: Listenable.merge([
        ?widget.progress,
        _slideController,
        _hop,
        _jelly,
      ]),
      child: row,
      builder: (context, child) {
        final (double, double)? pos = _indicatorPos();
        return Stack(
          // 果冻胀出要能溢出，裁切交给外层玻璃壳。
          clipBehavior: Clip.none,
          children: <Widget>[
            if (pos != null)
              _jellyIndicator(cs, pos, innerHeight, glass: false),
            child!,
            if (pos != null && lens)
              _jellyIndicator(cs, pos, innerHeight, glass: true),
          ],
        );
      },
    );
  }

  /// 指示器此刻的 (left, width)。与传统档 `_buildHighlight` 取的是同一份几何，
  /// 只是那边交给 `AnimatedPositioned`、这边得算出确切值喂给 `exactOffset`。
  (double, double)? _indicatorPos() {
    final double? t = _liveT;
    if (t != null) {
      final h = _interpolatedHighlight(t);
      if (h != null) return h;
    }
    final double? left = _highlightLeft;
    final double? width = _highlightWidth;
    if (left == null || width == null) return null;
    final double? fromLeft = _hopFromLeft;
    final double? fromWidth = _hopFromWidth;
    if (fromLeft != null && fromWidth != null && _hop.isAnimating) {
      final double f = GlassTokens.motionCurve.transform(_hop.value);
      return (
        fromLeft + (left - fromLeft) * f,
        fromWidth + (width - fromWidth) * f,
      );
    }
    return (left, width);
  }

  Widget _jellyIndicator(
    ColorScheme cs,
    (double, double) pos,
    double innerHeight, {
    required bool glass,
  }) {
    return lgw.AnimatedGlassIndicator(
      velocity: glass ? _velocity : 0,
      itemCount: widget.items.length,
      // exact 定位模式下 alignment 不参与计算，但参数是必填的。
      alignment: Alignment.centerLeft,
      // 药丸那趟恒 0：见 [_buildJellyStack] 上那段真机实测的说明。
      thickness: glass ? _jelly.value : 0,
      // premium 才有完整的 SDF 折射；非 Impeller 环境由包自己降级。
      quality: chromeGlassQuality,
      indicatorColor: GlassTokens.selectedHighlight(cs),
      isBackgroundIndicator: false,
      borderRadius: innerHeight / 2,
      paintBackground: !glass,
      paintGlass: glass,
      exactOffset: pos.$1,
      exactWidth: pos.$2,
      settings: GlassTokens.widgetsIndicator,
      pinchStrength: _jellyPinch,
      expansion: _jellyExpansion,
    );
  }

  Widget _buildHighlight(ColorScheme cs, double innerHeight) {
    final decoration = BoxDecoration(
      color: GlassTokens.selectedHighlight(cs),
      borderRadius: BorderRadius.circular(innerHeight / 2),
    );
    // 拖拽中微放大，松手还原
    final Widget thumb = AnimatedScale(
      scale: _dragging ? 1.07 : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: DecoratedBox(decoration: decoration),
    );

    final progress = widget.progress;
    if (_itemRects != null && (progress != null || _overrideT != null)) {
      // 跟手：拖拽/落位覆盖优先，否则按 TabController 的小数下标逐帧插值
      final Listenable listenable = Listenable.merge([
        ?progress,
        _slideController,
      ]);
      return AnimatedBuilder(
        animation: listenable,
        builder: (context, _) {
          final double? t = _overrideT ?? progress?.value;
          final h = t == null ? null : _interpolatedHighlight(t);
          final left = h?.$1 ?? _highlightLeft!;
          final width = h?.$2 ?? _highlightWidth!;
          return Positioned(
            left: left,
            top: 0,
            width: width,
            height: innerHeight,
            child: thumb,
          );
        },
      );
    }
    return AnimatedPositioned(
      duration: _hasMeasured ? GlassTokens.motionDuration : Duration.zero,
      curve: GlassTokens.motionCurve,
      left: _highlightLeft!,
      top: 0,
      width: _highlightWidth!,
      height: innerHeight,
      child: thumb,
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    ColorScheme cs,
    double innerHeight,
  ) {
    final item = widget.items[index];
    final bool selected = index == widget.selectedIndex;
    final Color selectedColor = cs.onSecondaryContainer;
    final Color unselectedColor = cs.onSurfaceVariant;
    // 字重保持不变：字重变化会改变段宽，导致高亮块测量失准
    final TextStyle baseStyle = GlassSegmentedControl._labelStyle(context);

    Widget buildContent(Color fg) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(
              size: GlassSegmentedControl.itemIconSize,
              color: fg,
            ),
            child: item.icon!,
          ),
          const SizedBox(width: GlassSegmentedControl.itemIconGap),
        ],
        DefaultTextStyle(
          style: baseStyle.copyWith(color: fg),
          child: Text(item.label, maxLines: 1, softWrap: false),
        ),
      ],
    );

    final progress = widget.progress;
    final Widget content;
    if (progress != null || _overrideT != null) {
      // 跟手：文字颜色按「离当前位置的距离」插值；拖拽/落位覆盖优先
      final Listenable listenable = Listenable.merge([
        ?progress,
        _slideController,
      ]);
      content = AnimatedBuilder(
        animation: listenable,
        builder: (context, _) {
          final double t =
              _overrideT ?? progress?.value ?? widget.selectedIndex.toDouble();
          final double strength = (1.0 - (t - index).abs()).clamp(0.0, 1.0);
          final fg = Color.lerp(unselectedColor, selectedColor, strength)!;
          return buildContent(fg);
        },
      );
    } else {
      // 文字走 AnimatedDefaultTextStyle，图标也得跟着一起过渡——只动文字的话
      // 段内图标会瞬间跳色，两者不同步（见 GlassAnimatedColors 的说明）。
      content = GlassAnimatedColors(
        colors: [selected ? selectedColor : unselectedColor],
        builder: (context, c) => AnimatedDefaultTextStyle(
          duration: GlassTokens.motionDuration,
          style: baseStyle.copyWith(color: c.first),
          child: buildContent(c.first),
        ),
      );
    }

    return GlassPressable(
      key: _itemKeys[index],
      scale: 0.95,
      onTap: () {
        if (!selected) widget.onChanged(index);
      },
      builder: (context, pressed) => Container(
        height: innerHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: GlassSegmentedControl.itemHorizontalPadding,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
