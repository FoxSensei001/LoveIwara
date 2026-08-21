import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

class GlassTabItem {
  const GlassTabItem({required this.icon, required this.label, this.badge});

  final IconData icon;
  final String label;

  /// 右上角角标（为 null 时不显示）。
  final Widget? badge;
}

/// 浮动在内容之上的玻璃 Tab 胶囊，可选在右侧并排一个独立圆钮（[trailing]）。
///
/// 本组件只负责「一行」的布局（不含底部安全区），调用方把它放进 Stack 的
/// 底部 Positioned 并自行加上安全区边距。
///
/// 选中项由统一的滑动高亮块标记；支持「长按拾起」：长按后高亮块微放大并
/// 跟随手指滑动（跨项有触感反馈），松手落在手指所在项——液态玻璃的跟手质感。
class GlassFloatingTabBar extends StatefulWidget {
  const GlassFloatingTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.trailing,
    this.height = GlassTokens.floatingTabBarHeight,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? trailing;
  final double height;

  @override
  State<GlassFloatingTabBar> createState() => _GlassFloatingTabBarState();
}

class _GlassFloatingTabBarState extends State<GlassFloatingTabBar>
    with SingleTickerProviderStateMixin {
  /// 各项之间的水平间距（高亮块两侧各让出这么多）。
  static const double _itemMargin = 2;

  /// 拾起 / 落位共用的过渡动画（两个阶段在时间上不重叠）。
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _dragging = false;

  /// 拖拽中的小数下标（等宽槽位，直接按 x 线性换算）。
  double? _dragT;

  /// 拾起瞬间高亮所在的小数下标：长按后先从这里「追」到手指，避免瞬移。
  double? _grabFrom;

  /// 松手瞬间的小数下标；非 null 表示落位动画进行中。
  double? _releaseFrom;
  int _releaseTarget = 0;
  int? _lastHapticIndex;

  @override
  void initState() {
    super.initState();
    // 拾起追赶 / 落位动画期间逐帧重建（高亮位置与图标颜色都依赖 _overrideT）
    _slideController.addListener(() {
      if (mounted && (_dragging || _releaseFrom != null)) setState(() {});
    });
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          mounted &&
          _releaseFrom != null) {
        setState(() => _releaseFrom = null);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  /// 覆盖位置：
  /// - 拖拽中：从拾起位置「追」向手指（追上后 1:1 跟手）；
  /// - 落位中：从松手位置单调滑到目标项；
  /// - 空闲：null（回落到 currentIndex 驱动的 AnimatedPositioned）。
  double? get _overrideT {
    if (_dragging && _dragT != null) {
      final from = _grabFrom;
      if (from == null) return _dragT;
      final double f = Curves.easeOutCubic.transform(_slideController.value);
      return from + (_dragT! - from) * f;
    }
    final from = _releaseFrom;
    if (from != null) {
      final double f = Curves.easeOutCubic.transform(_slideController.value);
      return from + (_releaseTarget - from) * f;
    }
    return null;
  }

  double _positionForDx(double dx, double slotWidth) {
    final double t = dx / slotWidth - 0.5;
    return t.clamp(0.0, (widget.items.length - 1).toDouble());
  }

  void _handleLongPressStart(double dx, double slotWidth) {
    HapticFeedback.mediumImpact();
    _slideController.stop();
    setState(() {
      _dragging = true;
      // 从当前视觉位置（可能正处于落位途中）出发追手指，而不是瞬移
      _grabFrom = _overrideT ?? widget.currentIndex.toDouble();
      _releaseFrom = null;
      _dragT = _positionForDx(dx, slotWidth);
      _lastHapticIndex = _dragT!.round();
    });
    _slideController.duration = const Duration(milliseconds: 220);
    _slideController.forward(from: 0);
  }

  void _handleLongPressMove(double dx, double slotWidth) {
    if (!_dragging) return;
    final t = _positionForDx(dx, slotWidth);
    final idx = t.round();
    if (idx != _lastHapticIndex) {
      _lastHapticIndex = idx;
      HapticFeedback.selectionClick();
    }
    setState(() => _dragT = t);
  }

  void _finishDrag({required bool commit}) {
    if (!_dragging) return;
    // 从当前视觉位置（可能还在拾起追赶途中）出发落位
    final double from = _overrideT ?? _dragT ?? widget.currentIndex.toDouble();
    final int target = commit
        ? (_dragT ?? from).round().clamp(0, widget.items.length - 1)
        : widget.currentIndex;
    setState(() {
      _dragging = false;
      _dragT = null;
      _grabFrom = null;
      _releaseFrom = from;
      _releaseTarget = target;
    });
    _slideController.duration = const Duration(milliseconds: 260);
    _slideController.forward(from: 0);
    if (commit && target != widget.currentIndex) {
      HapticFeedback.lightImpact();
      widget.onTap(target);
    }
  }

  /// 项 i 的「视觉选中强度」：空闲时选中项为 1，拖拽/落位中按距离插值。
  double _strengthFor(int index) {
    final double? t = _overrideT;
    if (t == null) return index == widget.currentIndex ? 1.0 : 0.0;
    return (1.0 - (t - index).abs()).clamp(0.0, 1.0);
  }

  Widget _buildThumb(ColorScheme cs, double slotWidth, double innerHeight) {
    final double top = (widget.height - innerHeight) / 2;
    final double width = slotWidth - _itemMargin * 2;
    final decoration = BoxDecoration(
      color: GlassTokens.selectedHighlight(cs),
      borderRadius: BorderRadius.circular(innerHeight / 2),
    );
    // 拖拽中微放大，松手还原
    final Widget thumb = AnimatedScale(
      scale: _dragging ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: DecoratedBox(decoration: decoration),
    );

    final double? t = _overrideT;
    if (t != null) {
      return Positioned(
        left: slotWidth * t + _itemMargin,
        top: top,
        width: width,
        height: innerHeight,
        child: thumb,
      );
    }
    return AnimatedPositioned(
      duration: GlassTokens.motionDuration,
      curve: GlassTokens.motionCurve,
      left: slotWidth * widget.currentIndex + _itemMargin,
      top: top,
      width: width,
      height: innerHeight,
      child: thumb,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double innerHeight = widget.height - 8;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GlassSurface(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double slotWidth =
                    constraints.maxWidth / widget.items.length;
                // 长按拾起高亮块跟手滑动；轻点仍由子项的 GlassPressable 处理
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPressStart: (d) =>
                      _handleLongPressStart(d.localPosition.dx, slotWidth),
                  onLongPressMoveUpdate: (d) =>
                      _handleLongPressMove(d.localPosition.dx, slotWidth),
                  onLongPressEnd: (_) => _finishDrag(commit: true),
                  onLongPressCancel: () => _finishDrag(commit: false),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildThumb(cs, slotWidth, innerHeight),
                      Row(
                        children: [
                          for (var i = 0; i < widget.items.length; i++)
                            Expanded(
                              child: _GlassTab(
                                item: widget.items[i],
                                selected: i == widget.currentIndex,
                                strength: _strengthFor(i),
                                onTap: () => widget.onTap(i),
                                height: widget.height,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 12),
          widget.trailing!,
        ],
      ],
    );
  }
}

class _GlassTab extends StatelessWidget {
  const _GlassTab({
    required this.item,
    required this.selected,
    required this.strength,
    required this.onTap,
    required this.height,
  });

  final GlassTabItem item;
  final bool selected;

  /// 视觉选中强度 0..1（拖拽跟手时按「离高亮块的距离」插值）。
  final double strength;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color fg = Color.lerp(cs.onSurfaceVariant, cs.primary, strength)!;
    final double innerHeight = height - 8;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GlassPressable(
        scale: 0.94,
        onTap: onTap,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.motionDuration,
          curve: GlassTokens.motionCurve,
          height: innerHeight,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            // 选中底色由统一的滑动高亮块负责，这里只画按下反馈
            color: pressed
                ? cs.onSurface.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(innerHeight / 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.icon, size: 26, color: fg),
                  if (item.badge != null)
                    Positioned(top: -4, right: -6, child: item.badge!),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.1,
                      fontWeight: strength > 0.5
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
