import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/theme_mode.model.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ThemeStepWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const ThemeStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StepResponsiveScaffold(
      desktopBuilder: (context, theme) => _buildDesktopLayout(context, theme),
      mobileBuilder: (context, theme, isNarrow) => _buildMobileLayout(context, theme, isNarrow),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 80,
      children: [
        Expanded(flex: 1, child: _buildContentSection(context, theme, false)),
        Expanded(
          flex: 1,
          child: _buildThemeOptionsContainer(context, theme, false),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    bool isNarrow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: isNarrow ? 16 : 24,
      children: [
        _buildTitle(context, theme, isNarrow),
        _buildThemeOptionsContainer(context, theme, isNarrow),
        _buildInfoCard(context, theme, isNarrow),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme, bool isNarrow) {
    return Text(
      subtitle,
      style:
          (isNarrow
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.headlineSmall)
              ?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    ThemeData theme,
    bool isNarrow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoCard(context, theme, isNarrow),
      ],
    );
  }

  Widget _buildThemeOptionsContainer(
    BuildContext context,
    ThemeData theme,
    bool isNarrow,
  ) {
    final themeService = Get.find<ThemeService>();

    return StepSectionCard(
      isNarrow: isNarrow,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeOption(
              context: context,
              title: slang.t.settings.followSystem,
              subtitle: slang.t.settings.dynamicColorDesc,
              icon: Icons.brightness_auto,
              isSelected: themeService.themeMode == AppThemeMode.system,
              isNarrow: isNarrow,
              onTap: () => themeService.setThemeMode(AppThemeMode.system),
            ),
            _buildThemeOption(
              context: context,
              title: slang.t.settings.lightMode,
              subtitle: slang.t.settings.basicTheme,
              icon: Icons.light_mode,
              isSelected: themeService.themeMode == AppThemeMode.light,
              isNarrow: isNarrow,
              onTap: () => themeService.setThemeMode(AppThemeMode.light),
            ),
            _buildThemeOption(
              context: context,
              title: slang.t.settings.darkMode,
              subtitle: slang.t.settings.basicTheme,
              icon: Icons.dark_mode,
              isSelected: themeService.themeMode == AppThemeMode.dark,
              isNarrow: isNarrow,
              onTap: () => themeService.setThemeMode(AppThemeMode.dark),
            ),
            Padding(
              padding: EdgeInsets.all(isNarrow ? 12 : 16),
              child: Text(
                slang.t.settings.dynamicColor,
                style:
                    (isNarrow
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SwitchListTile(
              title: Text(slang.t.settings.useDynamicColor),
              subtitle: Text(slang.t.settings.dynamicColorDesc),
              value: themeService.useDynamicColor,
              onChanged: (value) => themeService.setUseDynamicColor(value),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 12 : 16,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isNarrow ? 12 : 16),
              child: Text(
                slang.t.settings.presetColors,
                style:
                    (isNarrow
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Opacity(
              opacity: themeService.useDynamicColor ? 0.5 : 1.0,
              child: AbsorbPointer(
                absorbing: themeService.useDynamicColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isNarrow ? 5 : 6,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: ThemeService.presetColors.length,
                    itemBuilder: (context, i) => _buildColorButton(
                      context,
                      ThemeService.presetColors[i],
                      onTap: () => themeService.setPresetColor(i),
                      isSelected: themeService.isColorSelected(
                        ThemeService.presetColors[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isNarrow ? 12 : 16,
                isNarrow ? 12 : 16,
                isNarrow ? 12 : 16,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slang.t.settings.customColors,
                    style:
                        (isNarrow
                                ? theme.textTheme.titleSmall
                                : theme.textTheme.titleMedium)
                            ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (themeService.useDynamicColor) return;
                      _showColorPicker(context, themeService);
                    },
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: themeService.useDynamicColor ? 0.5 : 1.0,
              child: AbsorbPointer(
                absorbing: themeService.useDynamicColor,
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Obx(
                    () => themeService.customThemeColors.isEmpty
                        ? Center(
                            child: Text(
                              slang.t.settings.noCustomColors,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: themeService.customThemeColors.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final hex = themeService.customThemeColors[index];
                              final color = Color(int.parse('0xFF$hex'));
                              final isSelected = themeService
                                  .isCustomColorSelected(hex);
                              return InkWell(
                                onTap: () => themeService.setCustomColor(hex),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors.grey.withValues(alpha: 0.2),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '#$hex',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const Spacer(),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                        ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => themeService
                                            .removeCustomThemeColor(hex),
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.palette,
            color: theme.colorScheme.onPrimaryContainer,
            size: isNarrow ? 16 : 20,
          ),
          SizedBox(width: isNarrow ? 8 : 12),
          Expanded(
            child: Text(
              slang.t.firstTimeSetup.common.settingsChangeableTip,
              style:
                  (isNarrow
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isNarrow,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isNarrow ? 8 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 16 : 20,
          vertical: isNarrow ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isNarrow ? 8 : 12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isNarrow ? 6 : 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(isNarrow ? 6 : 8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                size: isNarrow ? 16 : 20,
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (isNarrow
                                ? theme.textTheme.bodyMedium
                                : theme.textTheme.titleSmall)
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                  ),
                  SizedBox(height: isNarrow ? 1 : 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            )
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.onPrimaryContainer,
                size: isNarrow ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context,
    Color color, {
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeService themeService) {
    Color pickerColor =
        CommonConstants.dynamicLightColorScheme?.primary ?? Colors.orange;
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.settings.pickColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              final hex = pickerColor
                  .toARGB32()
                  .toRadixString(16)
                  .substring(2)
                  .toUpperCase();
              themeService.addCustomThemeColor(hex);
              AppService.tryPop();
            },
            child: Text(slang.t.common.confirm),
          ),
        ],
      ),
    );
  }
}
