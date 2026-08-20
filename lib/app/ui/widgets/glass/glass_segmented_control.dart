import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

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
  static double minWidthFor(
    BuildContext context,
    List<GlassSegmentItem> items, {
    int minVisibleItems = 2,
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

    final int take = minVisibleItems.clamp(1, widths.length);
    double total = 0;
    for (var i = 0; i < take; i++) {
      total += widths[i];
    }
    // 胶囊内缩 + 左右两条玻璃描边
    return total + capsuleInset * 2 + GlassTokens.strokeWidth * 2;
  }

  @override
  State<GlassSegmentedControl> createState() => _GlassSegmentedControlState();
}

class _GlassSegmentedControlState extends State<GlassSegmentedControl>
    with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
    // 拾起追赶 / 落位动画期间逐帧重建（高亮位置与文字颜色都依赖 _overrideT）
    _slideController.addListener(() {
      if (mounted && (_dragging || _releaseFrom != null)) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _measure(animateScroll: false),
    );
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
    _slideController.dispose();
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
            child: Stack(
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
      content = AnimatedDefaultTextStyle(
        duration: GlassTokens.motionDuration,
        style: baseStyle.copyWith(
          color: selected ? selectedColor : unselectedColor,
        ),
        child: buildContent(selected ? selectedColor : unselectedColor),
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
