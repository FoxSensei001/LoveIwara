import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/theme_mode.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 主题步：与「设置 → 主题设置」同构——同样的分组顺序、同样的单选行，
/// 用户第二次在设置页看到它们时不会觉得是两个页面。
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
    final themeService = Get.find<ThemeService>();

    return StepPageLayout(
      subtitle: subtitle,
      description: description,
      content: StepSectionList(
        children: [
          _buildThemeModeSection(themeService),
          _buildGlassEffectSection(themeService),
          _buildDynamicColorSection(themeService),
          _buildPresetColorsSection(context, themeService),
          _buildCustomColorsSection(context, themeService),
        ],
      ),
      tip: StepTipBanner.info(
        slang.t.firstTimeSetup.common.settingsChangeableTip,
      ),
    );
  }

  Widget _buildThemeModeSection(ThemeService themeService) {
    return Obx(
      () => GlassSettingSection(
        title: slang.t.settings.themeMode,
        children: [
          GlassChoiceItem<AppThemeMode>(
            icon: Icons.brightness_auto,
            value: AppThemeMode.system,
            groupValue: themeService.themeMode,
            onChanged: themeService.setThemeMode,
            title: Text(slang.t.settings.followSystem),
          ),
          GlassChoiceItem<AppThemeMode>(
            icon: Icons.light_mode,
            value: AppThemeMode.light,
            groupValue: themeService.themeMode,
            onChanged: themeService.setThemeMode,
            title: Text(slang.t.settings.lightMode),
          ),
          GlassChoiceItem<AppThemeMode>(
            icon: Icons.dark_mode,
            value: AppThemeMode.dark,
            groupValue: themeService.themeMode,
            onChanged: themeService.setThemeMode,
            title: Text(slang.t.settings.darkMode),
          ),
        ],
      ),
    );
  }

  /// 玻璃质感：与「设置 → 主题设置」里那一项、以及老用户看到的一次性
  /// 提醒（`GlassMaterialIntro`）是同一个开关，三处必须给同一份选择。
  Widget _buildGlassEffectSection(ThemeService themeService) {
    return Obx(
      () => GlassSettingSection(
        title: slang.t.settings.glassEffect,
        children: [
          GlassChoiceItem<bool>(
            icon: Icons.blur_on,
            value: true,
            groupValue: themeService.enableLiquidGlass,
            onChanged: themeService.setLiquidGlassEnabled,
            title: Text(slang.t.settings.liquidGlassEffect),
            subtitle: Text(slang.t.settings.liquidGlassEffectDesc),
          ),
          GlassChoiceItem<bool>(
            icon: Icons.filter_b_and_w,
            value: false,
            groupValue: themeService.enableLiquidGlass,
            onChanged: themeService.setLiquidGlassEnabled,
            title: Text(slang.t.settings.plainGlassEffect),
            subtitle: Text(slang.t.settings.plainGlassEffectDesc),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicColorSection(ThemeService themeService) {
    return GlassSettingSection(
      title: slang.t.settings.dynamicColor,
      children: [
        Obx(
          () => GlassSwitchItem(
            icon: Icons.auto_awesome,
            title: Text(slang.t.settings.useDynamicColor),
            subtitle: Text(slang.t.settings.dynamicColorDesc),
            value: themeService.useDynamicColor,
            onChanged: themeService.setUseDynamicColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetColorsSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    final crossAxisCount = stepIsNarrow(context) ? 5 : 6;
    return GlassSettingSection(
      title: slang.t.settings.presetColors,
      children: [
        Obx(
          () => _DisabledByDynamicColor(
            disabled: themeService.useDynamicColor,
            child: Padding(
              padding: const EdgeInsets.all(StepMetrics.cardPadding),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // ⛔ padding 不能省：BoxScrollView 在 padding == null 时会把
                // MediaQuery 的竖直 padding 自动补进来，而这页开了
                // extendBodyBehindAppBar，那个值是「状态栏 + AppBar」≈80。
                // 于是色块上方凭空多出一大片空白（卡里看着像漏排了一行）。
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: ThemeService.presetColors.length,
                itemBuilder: (context, i) => _ColorSwatch(
                  color: ThemeService.presetColors[i],
                  selected: themeService.isColorSelected(
                    ThemeService.presetColors[i],
                  ),
                  onTap: () => themeService.setPresetColor(i),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomColorsSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    return GlassSettingSection(
      title: slang.t.settings.customColors,
      children: [
        // 「添加」不再是分组标题右边那枚裸 IconButton：做成一条普通设置行，
        // 与卡片里其它行同一条基线，也不用再单独处理禁用态的视觉。
        Obx(() {
          final disabled = themeService.useDynamicColor;
          return GlassSettingTile(
            icon: Icons.add,
            title: Text(slang.t.settings.pickColor),
            onTap: () {
              if (disabled) {
                // 点得动、但会告诉你为什么没用，而不是一枚静默的死按钮。
                showAppToast(
                  slang.t.settings.customColorsDisabledByDynamicColor,
                  type: AppToastType.info,
                );
                return;
              }
              _showColorPicker(context, themeService);
            },
          );
        }),
        Obx(
          () => _DisabledByDynamicColor(
            disabled: themeService.useDynamicColor,
            child: Padding(
              padding: const EdgeInsets.all(StepMetrics.cardPadding),
              child: themeService.customThemeColors.isEmpty
                  ? Center(
                      child: Text(
                        slang.t.settings.noCustomColors,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      spacing: 8,
                      children: [
                        for (final hex in themeService.customThemeColors)
                          _CustomColorRow(
                            hex: hex,
                            selected: themeService.isCustomColorSelected(hex),
                            onTap: () => themeService.setCustomColor(hex),
                            onDelete: () =>
                                themeService.removeCustomThemeColor(hex),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, ThemeService themeService) {
    Color pickerColor =
        CommonConstants.dynamicLightColorScheme?.primary ?? Colors.orange;
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.settings.pickColor,
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.confirm,
            onPressed: () {
              final hex = pickerColor
                  .toARGB32()
                  .toRadixString(16)
                  .substring(2)
                  .toUpperCase();
              themeService.addCustomThemeColor(hex);
              AppService.tryPop();
            },
          ),
        ],
      ),
    );
  }
}

/// 动态取色接管时，色板整体不可用。
///
/// 与「设置 → 主题设置」同一个表达（半透明 + 不接手势）。这里包住的只有
/// 色块网格与色号列表，里面没有玻璃件——玻璃件的显隐一律走 `GlassReveal`，
/// 见 `glass_style_guard_test` 里那条零容忍规则。
class _DisabledByDynamicColor extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const _DisabledByDynamicColor({required this.disabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: disabled ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AbsorbPointer(absorbing: disabled, child: child),
    );
  }
}

/// 预设色块。
class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}

/// 自定义色号行。
class _CustomColorRow extends StatelessWidget {
  final String hex;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomColorRow({
    required this.hex,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = Color(int.parse('0xFF$hex'));
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Expanded(child: Text('#$hex', style: theme.textTheme.bodyMedium)),
              if (selected)
                Icon(Icons.check_circle, size: 20, color: cs.primary),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                color: cs.error,
                tooltip: slang.t.common.delete,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
