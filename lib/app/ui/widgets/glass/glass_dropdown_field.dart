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
    this.shrinkWrap = false,
  });

  final List<GlassDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hint;

  /// false 时这一行会**撑满拿到的宽度**，箭头贴右——这是选择器该有的样子
  /// （文字长短不该让箭头跟着晃）。
  ///
  /// 只有「按内容收缩才对」的位置才传 true，例如 `ListTile.trailing`：那里
  /// 的约束是整条 tile 的宽度，撑满会把标题挤没。
  final bool shrinkWrap;

  /// 不可用时**要看得出来**：底色/描边压淡、文字与箭头走 disabled 前景色。
  /// 光是点不动而样式不变会误导——用户会以为是自己没点准（2026-08-26 反馈：
  /// 「没选年的时候月份点不了，可是它们两个的颜色都一样」）。
  final bool enabled;

  /// Material 的 disabled 前景不透明度。
  static const double _disabledAlpha = 0.38;

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
      builder: (context, pressed) {
        final Color labelColor = !enabled
            ? cs.onSurface.withValues(alpha: _disabledAlpha)
            : (selected == null ? cs.onSurfaceVariant : cs.onSurface);
        final Color accessoryColor = enabled
            ? cs.onSurfaceVariant
            : cs.onSurfaceVariant.withValues(alpha: _disabledAlpha);
        final Color fill = !enabled
            ? GlassTokens.fill(cs).withValues(alpha: 0.4)
            : (pressed ? GlassTokens.pressedFill(cs) : GlassTokens.fill(cs));
        final Color stroke = enabled
            ? GlassTokens.stroke(cs)
            : GlassTokens.stroke(cs).withValues(alpha: 0.4);

        final label = Text(
          selected?.label ?? hint ?? '',
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(color: labelColor),
        );

        return AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stroke, width: GlassTokens.strokeWidth),
          ),
          // 宽度有界就撑满、箭头贴右；无界（横向滚动行里）只能按内容收缩。
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool fillWidth =
                  !shrinkWrap && constraints.maxWidth.isFinite;
              return Row(
                mainAxisSize: fillWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  if (selected?.icon != null) ...[
                    Icon(selected!.icon, size: 18, color: accessoryColor),
                    const SizedBox(width: 8),
                  ],
                  if (fillWidth)
                    Expanded(child: label)
                  else
                    Flexible(child: label),
                  const SizedBox(width: 6),
                  Icon(Icons.expand_more, size: 18, color: accessoryColor),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
