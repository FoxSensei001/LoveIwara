import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class IwaraSiteBadge extends StatelessWidget {
  final IwaraSite site;
  final bool showForMain;

  const IwaraSiteBadge({
    super.key,
    required this.site,
    this.showForMain = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showForMain && !site.isAi) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = site.isAi
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = site.isAi
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final t = slang.Translations.of(context);
    final label = site.isAi ? t.siteMode.aiSite : t.siteMode.mainSite;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}
