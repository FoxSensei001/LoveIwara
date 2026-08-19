import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

class GlassSegmentItem {
  const GlassSegmentItem({required this.label, this.icon});

  final String label;
  final Widget? icon;
}

/// 玻璃分段胶囊：一个长胶囊里放多个文字段，选中段用滑动高亮块标记，
/// 段数多时可横向滚动（支持桌面滚轮），选中项变化时自动滚到可见。
class GlassSegmentedControl extends StatefulWidget {
  const GlassSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.progress,
    this.height = GlassTokens.pillHeight,
  });

  final List<GlassSegmentItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// 可选：连续的「当前位置」（典型地传 `TabController.animation`，或由
  /// `PageController.page` 喂出来的 `ValueNotifier<double>`，值为小数下标）。
  /// 传入后高亮块与文字颜色会随横向滑动进度实时插值，而不是等切换完成后才跳到新段。
  final ValueListenable<double>? progress;
  final double height;

  @override
  State<GlassSegmentedControl> createState() => _GlassSegmentedControlState();
}

class _GlassSegmentedControlState extends State<GlassSegmentedControl> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rowKey = GlobalKey();
  List<GlobalKey> _itemKeys = [];

  double? _highlightLeft;
  double? _highlightWidth;
  bool _hasMeasured = false;
  int _measureRetries = 0;

  /// 每个段相对于 Row 的 (left, width)，供 progress 驱动模式做插值。
  List<Rect>? _itemRects;

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _measure(animateScroll: false),
    );
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
    final textTheme = Theme.of(context).textTheme;
    const double inset = 4;
    final double innerHeight = widget.height - inset * 2;

    final Widget row = Row(
      key: _rowKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          _buildItem(context, i, cs, textTheme, innerHeight),
      ],
    );

    return GlassSurface(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: inset, vertical: inset),
      clipContent: true,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
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
  }

  Widget _buildHighlight(ColorScheme cs, double innerHeight) {
    final decoration = BoxDecoration(
      color: GlassTokens.selectedHighlight(cs),
      borderRadius: BorderRadius.circular(innerHeight / 2),
    );
    final progress = widget.progress;
    if (progress != null && _itemRects != null) {
      // 跟手：按 TabController 的小数下标逐帧插值
      return AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final h = _interpolatedHighlight(progress.value);
          final left = h?.$1 ?? _highlightLeft!;
          final width = h?.$2 ?? _highlightWidth!;
          return Positioned(
            left: left,
            top: 0,
            width: width,
            height: innerHeight,
            child: DecoratedBox(decoration: decoration),
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
      child: DecoratedBox(decoration: decoration),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    ColorScheme cs,
    TextTheme textTheme,
    double innerHeight,
  ) {
    final item = widget.items[index];
    final bool selected = index == widget.selectedIndex;
    final Color selectedColor = cs.onSecondaryContainer;
    final Color unselectedColor = cs.onSurfaceVariant;
    // 字重保持不变：字重变化会改变段宽，导致高亮块测量失准
    final TextStyle baseStyle =
        (textTheme.labelLarge ?? const TextStyle(fontSize: 14)).copyWith(
          fontWeight: FontWeight.w600,
        );

    Widget buildContent(Color fg) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(size: 16, color: fg),
            child: item.icon!,
          ),
          const SizedBox(width: 5),
        ],
        DefaultTextStyle(
          style: baseStyle.copyWith(color: fg),
          child: Text(item.label, maxLines: 1, softWrap: false),
        ),
      ],
    );

    final progress = widget.progress;
    final Widget content;
    if (progress != null) {
      // 跟手：文字颜色按「离当前位置的距离」插值
      content = AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final double strength = (1.0 - (progress.value - index).abs()).clamp(
            0.0,
            1.0,
          );
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
