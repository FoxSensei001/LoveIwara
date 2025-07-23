import 'package:flutter/material.dart';

/// Centralized constants for consistent UI styling across tabs.
class UIConstants {
  static const double pagePadding = 12.0;
  static const double sectionSpacing = 20.0;
  static const double interElementSpacing = 10.0;
  static const double listSpacing = 8.0;

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
