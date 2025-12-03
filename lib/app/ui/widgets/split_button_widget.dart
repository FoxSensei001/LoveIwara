import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';

/// Split Button 组件，左侧主按钮，右侧下拉菜单
/// 复现 Ant Design Space.Compact 效果
class SplitFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final List<PopupMenuEntry<String>> menuItems;
  final Function(String)? onMenuItemSelected;
  final bool isDisabled;
  final IconData? icon; // 左侧按钮的图标

  const SplitFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.menuItems,
    this.onMenuItemSelected,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isDisabled;

    // 1. 颜色定义：确保边框颜色清晰
    // 使用 outline 并提高不透明度确保可见
    final borderColor = colorScheme.outline.withValues(alpha: 0.4);
    final backgroundColor = colorScheme.surfaceContainerHighest;
    final contentColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    // 2. 圆角定义
    const radiusValue = 20.0; // 与 ActionButtonWidget 保持一致
    const radius = Radius.circular(radiusValue);

    // 3. 边框定义 (分离左侧和右侧的边框逻辑)
    // 左侧按钮：左、上、下 有边框
    final leftBorder = Border(
      top: BorderSide(color: borderColor, width: 1),
      bottom: BorderSide(color: borderColor, width: 1),
      left: BorderSide(color: borderColor, width: 1),
      right: BorderSide.none, // 关键：右侧无边框
    );

    // 右侧按钮：右、上、下 有边框
    final rightBorder = Border(
      top: BorderSide(color: borderColor, width: 1),
      bottom: BorderSide(color: borderColor, width: 1),
      right: BorderSide(color: borderColor, width: 1),
      left: BorderSide.none, // 关键：左侧无边框
    );

    // 内部 Padding
    const internalPadding = EdgeInsets.symmetric(
      horizontal: UIConstants.buttonInternalPadding,
      vertical: UIConstants.smallSpacing,
    );

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =======================
          // 1. 左侧：主操作按钮
          // =======================
          // 使用 Material 确保 InkWell 正确渲染
          Material(
            color: Colors.transparent, // 背景由内部 Container 负责
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: radius,
                  bottomLeft: radius,
                ),
                border: leftBorder, // 显式绘制边框
              ),
              child: InkWell(
                onTap: isEnabled ? onPressed : null,
                // 修复 Hover 溢出：告诉 InkWell 它的形状
                borderRadius: const BorderRadius.only(
                  topLeft: radius,
                  bottomLeft: radius,
                ),
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: contentColor,
                        ),
                        const SizedBox(width: UIConstants.iconTextSpacing),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: contentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =======================
          // 2. 中间：分割线
          // =======================
          Container(
            width: 1,
            color: borderColor,
          ),

          // =======================
          // 3. 右侧：下拉菜单按钮
          // =======================
          // 修复 Hover 溢出：将 ClipRRect 放在最外层，包裹整个右侧区域
          // 这样 PopupMenuButton 内部的方形水波纹就会被切成圆角
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: radius,
              bottomRight: radius,
            ),
            clipBehavior: Clip.antiAlias, // 确保裁剪生效
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias, // Material 也启用裁剪
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topRight: radius,
                    bottomRight: radius,
                  ),
                  border: rightBorder, // 显式绘制边框
                ),
                child: PopupMenuButton<String>(
                  tooltip: '',
                  enabled: isEnabled,
                  offset: const Offset(0, 48),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) => menuItems,
                  onSelected: onMenuItemSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // 使用 child 自定义触发区域
                  child: Container(
                    // 水平 Padding 稍微调小一点，视觉更紧凑
                    padding: internalPadding.copyWith(left: 10, right: 14),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: contentColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

