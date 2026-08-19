import 'package:flutter/material.dart';
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
class GlassFloatingTabBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GlassSurface(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _GlassTab(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                      height: height,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _GlassTab extends StatelessWidget {
  const _GlassTab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.height,
  });

  final GlassTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color fg = selected ? cs.primary : cs.onSurfaceVariant;
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
            color: selected
                ? GlassTokens.selectedHighlight(cs)
                : pressed
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
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
