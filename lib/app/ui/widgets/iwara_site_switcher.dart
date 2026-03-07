import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

String _siteLabel(IwaraSite site) {
  final t = slang.t.siteMode;
  return site == IwaraSite.ai ? t.aiSite : t.mainSite;
}

class IwaraSiteSwitcher extends StatelessWidget {
  final IwaraSite currentSite;
  final ValueChanged<IwaraSite> onChanged;
  final bool forceCompact;
  final double compactBreakpoint;

  const IwaraSiteSwitcher({
    super.key,
    required this.currentSite,
    required this.onChanged,
    this.forceCompact = false,
    this.compactBreakpoint = 560,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final mainLabel = _siteLabel(IwaraSite.main);
    final aiLabel = _siteLabel(IwaraSite.ai);
    final useCompact =
        forceCompact ||
        (compactBreakpoint > 0 && screenWidth < compactBreakpoint);

    if (useCompact) {
      return _CompactSiteSwitcher(
        currentSite: currentSite,
        onChanged: onChanged,
      );
    }

    return SegmentedButton<IwaraSite>(
      segments: [
        ButtonSegment<IwaraSite>(
          value: IwaraSite.main,
          label: Text(mainLabel),
          icon: const Icon(Icons.public, size: 16),
        ),
        ButtonSegment<IwaraSite>(
          value: IwaraSite.ai,
          label: Text(aiLabel),
          icon: const Icon(Icons.auto_awesome, size: 16),
        ),
      ],
      selected: <IwaraSite>{currentSite},
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onSelectionChanged: (selection) {
        if (selection.isEmpty) {
          return;
        }
        final site = selection.first;
        if (site != currentSite) {
          onChanged(site);
        }
      },
    );
  }
}

class _CompactSiteSwitcher extends StatelessWidget {
  final IwaraSite currentSite;
  final ValueChanged<IwaraSite> onChanged;

  const _CompactSiteSwitcher({
    required this.currentSite,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.t.siteMode;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = currentSite.isAi
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final fgColor = currentSite.isAi
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final buttonLabel = t.drawerSubtitle(
      currentSite: _siteLabel(currentSite),
      nextSite: _siteLabel(
        currentSite == IwaraSite.ai ? IwaraSite.main : IwaraSite.ai,
      ),
    );

    return Semantics(
      button: true,
      label: buttonLabel,
      child: MenuAnchor(
        consumeOutsideTap: true,
        crossAxisUnconstrained: false,
        menuChildren: IwaraSite.values
            .map(
              (site) => MenuItemButton(
                onPressed: site == currentSite ? null : () => onChanged(site),
                leadingIcon: Icon(
                  site.isAi ? Icons.auto_awesome : Icons.public,
                  size: 18,
                ),
                trailingIcon: site == currentSite
                    ? const Icon(Icons.check, size: 16)
                    : null,
                child: Text(_siteLabel(site)),
              ),
            )
            .toList(),
        builder: (context, controller, child) {
          return TextButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
                return;
              }
              controller.open();
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              foregroundColor: fgColor,
              backgroundColor: bgColor,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentSite.isAi ? Icons.auto_awesome : Icons.public,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  _siteLabel(currentSite),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  controller.isOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
