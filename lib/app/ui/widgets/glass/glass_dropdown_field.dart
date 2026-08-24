import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// [GlassDropdownField] 的一个候选项。
class GlassDropdownItem<T> {
  const GlassDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// `DropdownButton` / `DropdownButtonFormField` 的收口替代品。
///
/// `DropdownButton` 弹出的面板是 Material 的不透明卡片，是设置页里除
/// `AlertDialog` 外唯一还在用系统组件弹面板的地方——与 header 上「玻璃胶囊弹
/// 玻璃菜单」是同一个问题（见 `glass_menu.dart` 文件头）。这里直接复用
/// [showGlassMenu]：触发件是一行**恒为传统档**的选择器（同样躺在滚动容器里，
/// 不接液态 lens），弹出的面板则是已经成熟的玻璃菜单——面板本来就挂在根
/// Overlay 上，不受"lens 不能进滚动容器"这条约束。
class GlassDropdownField<T> extends StatelessWidget {
  const GlassDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.enabled = true,
  });

  final List<GlassDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    GlassDropdownItem<T>? selected;
    if (value != null) {
      for (final item in items) {
        if (item.value == value) {
          selected = item;
          break;
        }
      }
    }

    // ⛔ 不用 `InkWell`：水波是 Material 的反馈语言，而这一行已经是玻璃底色 +
    // 玻璃描边了；更要紧的是走 [GlassPressable] 才拿得到「长按也能打开、长按不
    // 抬手直接划到某一条上松手选中」那条（见 [GlassTapArea.opensOverlay]）——
    // 设置页的下拉与 header 上的下拉是同一件事，不该只有一半有这手感。
    // 反馈换成整行压深一档（与 community_page 那只下拉触发位同一套）。
    return GlassPressable(
      enabled: enabled,
      // 整行缩放会把表单里的一行带得抖起来；反馈只用底色。
      scale: 1.0,
      opensOverlay: true,
      onTap: enabled
          ? () async {
              final picked = await showGlassMenu<T>(
                anchorContext: context,
                entries: [
                  for (final item in items)
                    GlassMenuOption<T>(
                      value: item.value,
                      label: item.label,
                      icon: item.icon,
                      selected: item.value == value,
                    ),
                ],
              );
              if (picked != null) onChanged(picked);
            }
          : null,
      builder: (context, pressed) => AnimatedContainer(
        duration: GlassTokens.pressDuration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: pressed ? GlassTokens.pressedFill(cs) : GlassTokens.fill(cs),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GlassTokens.stroke(cs), width: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected?.icon != null) ...[
              Icon(selected!.icon, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                selected?.label ?? hint ?? '',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected == null ? cs.onSurfaceVariant : cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.expand_more, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
