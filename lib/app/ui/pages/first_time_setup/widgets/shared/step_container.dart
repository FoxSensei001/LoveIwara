import 'package:flutter/material.dart';

/// 统一的 Step 容器样式：卡片外观、圆角与边框
class StepSectionCard extends StatelessWidget {
  final Widget child;
  final bool isNarrow;

  const StepSectionCard({super.key, required this.child, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}

/// 统一的分割线
class StepDivider extends StatelessWidget {
  const StepDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}

/// 顶部/底部的提示条
class StepTipBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isNarrow;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const StepTipBanner({
    super.key,
    required this.icon,
    required this.text,
    required this.isNarrow,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: isNarrow ? 16 : 20),
          SizedBox(width: isNarrow ? 8 : 12),
          Expanded(
            child: Text(
              text,
              style: (isNarrow ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
                  ?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}


