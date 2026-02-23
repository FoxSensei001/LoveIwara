import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/theme_mode.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ThemeSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const ThemeSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.themeSettings,
            isWideScreen: isWideScreen,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildThemeModeSection(context, themeService),
                const SizedBox(height: 16),
                _buildDynamicColorSection(context, themeService),
                const SizedBox(height: 16),
                _buildPresetColorsSection(context, themeService),
                const SizedBox(height: 16),
                _buildCustomColorsSection(context, themeService),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t.settings.themeMode,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => RadioGroup<int>(
              groupValue: themeService.themeMode.index,
              onChanged: (value) {
                switch (value) {
                  case 0:
                    themeService.setThemeMode(AppThemeMode.system);
                    break;
                  case 1:
                    themeService.setThemeMode(AppThemeMode.light);
                    break;
                  case 2:
                    themeService.setThemeMode(AppThemeMode.dark);
                    break;
                }
              },
              child: Column(
                children: [
                  RadioListTile<int>(
                    title: Text(t.settings.followSystem),
                    value: 0,
                  ),
                  RadioListTile<int>(
                    title: Text(t.settings.lightMode),
                    value: 1,
                  ),
                  RadioListTile<int>(
                    title: Text(t.settings.darkMode),
                    value: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicColorSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t.settings.dynamicColor,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => SwitchListTile(
              title: Text(t.settings.useDynamicColor),
              subtitle: Text(t.settings.useDynamicColorDesc),
              value: themeService.useDynamicColor,
              onChanged: (value) => themeService.setUseDynamicColor(value),
            ),
          ),
        ],
      ),
    );
  }

  // 预设颜色
  Widget _buildPresetColorsSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t.settings.presetColors,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => Opacity(
              opacity: themeService.useDynamicColor ? 0.5 : 1.0,
              child: AbsorbPointer(
                absorbing: themeService.useDynamicColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
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
          ),
        ],
      ),
    );
  }

  // 自定义颜色
  Widget _buildCustomColorsSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.settings.customColors,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (themeService.useDynamicColor) {
                      return;
                    }
                    _showColorPicker(context, themeService);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => Opacity(
              opacity: themeService.useDynamicColor ? 0.5 : 1.0,
              child: AbsorbPointer(
                absorbing: themeService.useDynamicColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => themeService.customThemeColors.isEmpty
                        ? Center(
                            child: Text(
                              t.settings.noCustomColors,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
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
                              return InkWell(
                                onTap: () => themeService.setCustomColor(hex),
                                borderRadius: BorderRadius.circular(12),
                                child: Obx(() {
                                  final isSelected = themeService
                                      .isCustomColorSelected(hex);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
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
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        const Spacer(),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () => themeService
                                              .removeCustomThemeColor(hex),
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            },
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

  // 颜色按钮
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

  // 颜色选择器
  void _showColorPicker(BuildContext context, ThemeService themeService) {
    Color pickerColor =
        CommonConstants.dynamicLightColorScheme?.primary ?? Colors.orange;
    showAppDialog(
      AlertDialog(
        title: Text(t.settings.pickColor),
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
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              final hex = pickerColor.toARGB32()
                  .toRadixString(16)
                  .substring(2)
                  .toUpperCase();
              themeService.addCustomThemeColor(hex);
              AppService.tryPop();
            },
            child: Text(t.common.confirm),
          ),
        ],
      ),
    );
  }
}
