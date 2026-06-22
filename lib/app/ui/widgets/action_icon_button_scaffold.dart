import 'package:flutter/material.dart';

/// 统一风格的紧凑「仅图标」操作按钮，用于用户详情页操作栏等空间有限处。
/// 提供三种视觉层级：[filled]（主操作，实心强调）、[selected]（已激活的次操作，
/// 浅色容器）以及默认（描边/中性）。
class ActionIconButtonScaffold extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// 可选的简短文字标签。提供时渲染为「图标 + 文字」的胶囊按钮，
  /// 让用户一眼看懂按钮含义；为空时退化为纯图标圆形按钮。
  final String? label;

  /// 主操作：实心强调样式。
  final bool filled;

  /// 已激活的次操作：浅色容器样式。
  final bool selected;

  /// 覆盖高亮色（如特别关注用琥珀色）。
  final Color? highlightColor;

  /// 是否为加载占位。
  final bool _loading;

  const ActionIconButtonScaffold({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.label,
    this.filled = false,
    this.selected = false,
    this.highlightColor,
  }) : _loading = false;

  const ActionIconButtonScaffold.loading({super.key})
    : icon = Icons.hourglass_empty,
      tooltip = '',
      onPressed = null,
      label = null,
      filled = false,
      selected = false,
      highlightColor = null,
      _loading = true;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(11),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final Color bg;
    final Color fg;
    if (filled) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
    } else if (selected) {
      bg = (highlightColor ?? scheme.primary).withValues(alpha: 0.16);
      fg = highlightColor ?? scheme.primary;
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    }

    final hasLabel = label != null && label!.isNotEmpty;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: hasLabel ? const StadiumBorder() : const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: hasLabel
              ? ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _size),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 6),
                        Text(
                          label!,
                          style: TextStyle(
                            color: fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: _size,
                  height: _size,
                  child: Icon(icon, size: 20, color: fg),
                ),
        ),
      ),
    );
  }
}
