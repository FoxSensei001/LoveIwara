import 'package:flutter/material.dart';

/// Centralized constants for consistent UI styling across tabs.
class UIConstants {
  // 基础间距
  static const double pagePadding = 12.0;          // 页面内边距
  static const double sectionSpacing = 12.0;       // 区域间间距
  static const double interElementSpacing = 10.0;  // 元素间间距
  static const double listSpacing = 8.0;           // 列表项间距

  // 派生间距
  static const double cardPadding = pagePadding;                   // 卡片内边距
  static const double smallSpacing = 4.0;                          // 小间距
  static const double tinySpacing = 2.0;                           // 微小间距
  static const double iconTextSpacing = 6.0;                       // 图标与文字间距
  static const double buttonInternalPadding = 8.0;                 // 按钮内部间距
  static const double tagPaddingHorizontal = 8.0;                  // 标签水平内边距
  static const double tagPaddingVertical = 4.0;                    // 标签垂直内边距

  static const TextStyle sectionHeaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
}

/// A reusable header widget for sections in different tabs.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: UIConstants.sectionHeaderStyle),
        ),
        if (action != null) action!,
      ],
    );
  }
}
