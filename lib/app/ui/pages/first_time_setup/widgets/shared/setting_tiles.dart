import 'package:flutter/material.dart';

class SettingIconBadge extends StatelessWidget {
  final IconData icon;
  final bool isNarrow;
  final bool selected;

  const SettingIconBadge({
    super.key,
    required this.icon,
    required this.isNarrow,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isNarrow ? 6 : 8),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(isNarrow ? 6 : 8),
      ),
      child: Icon(
        icon,
        color: selected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.onPrimaryContainer,
        size: isNarrow ? 16 : 20,
      ),
    );
  }
}

class SwitchSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isNarrow;

  const SwitchSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 16 : 20,
        vertical: isNarrow ? 8 : 12,
      ),
      child: Row(
        children: [
          SettingIconBadge(icon: icon, isNarrow: isNarrow),
          SizedBox(width: isNarrow ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (isNarrow ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: isNarrow ? 1 : 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary,
            materialTapTargetSize: isNarrow ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
          ),
        ],
      ),
    );
  }
}

class NumberSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String valueText;
  final VoidCallback onTap;
  final bool isNarrow;

  const NumberSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.valueText,
    required this.onTap,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isNarrow ? 8 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 16 : 20,
          vertical: isNarrow ? 8 : 12,
        ),
        child: Row(
          children: [
            SettingIconBadge(icon: icon, isNarrow: isNarrow),
            SizedBox(width: isNarrow ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isNarrow ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: isNarrow ? 1 : 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(valueText, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}


