import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class WelcomeStepWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const WelcomeStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return StepPageLayout(
      subtitle: subtitle,
      description: description,
      hero: const _AppIconHero(),
      content: GlassSettingSection(
        children: [
          Obx(
            () => StepActionTile(
              icon: Icons.language,
              title: slang.t.settings.language,
              value: _languageOptions[_currentLocaleKey(configService)] ?? '',
              valueHighlighted:
                  _currentLocaleKey(configService) != _systemLocaleKey,
              onTap: () => _showLanguageDialog(context, configService),
            ),
          ),
        ],
      ),
      tip: StepTipBanner.info(
        slang.t.firstTimeSetup.common.settingsChangeableTip,
      ),
    );
  }

  static const String _systemLocaleKey = 'system';

  // 语言列表就地由 slang 生成：新增语言只要往 lib/i18n 丢一份 yaml，这里零改动。
  // 与设置页同一套口径：每项显示**那门语言自己的母语名**，「跟随系统」用
  // **设备语言**说，都不能走 `slang.t`（那只给当前语言）。读之前先
  // `CommonUtils.ensureAllAppLocalesLoaded()`，否则没加载过的语言会静默退回英文。
  Map<String, String> get _languageOptions => {
    _systemLocaleKey: _getFollowSystemText(),
    // 顺序走 CommonUtils.appLocaleDisplayOrder（英/日/简/繁优先，其余按二次元受众规模），
    // 不用 AppLocale.values 的字母序；新增语言会由 orderedAppLocales 兜底补在末尾。
    for (final locale in CommonUtils.orderedAppLocales)
      locale.languageTag: locale.translations.settings.languageNativeName,
  };

  // 跟随系统文案；设备语言没适配时 parse 会退回 en
  String _getFollowSystemText() {
    final deviceLocale = slang.AppLocaleUtils.parse(
      CommonUtils.getDeviceLocale(),
    );
    return deviceLocale.translations.settings.followSystemLanguage;
  }

  String _currentLocaleKey(ConfigService configService) {
    return configService[ConfigKey.APPLICATION_LOCALE] ?? _systemLocaleKey;
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    ConfigService configService,
  ) async {
    // 列表要显示每门语言自己的母语名，先确保所有语言的译文都加载好（幂等）。
    await CommonUtils.ensureAllAppLocalesLoaded();
    if (!context.mounted) return;

    showAppDialog(
      GlassAlertDialog(
        title: slang.t.settings.language,
        // ⛔ 列表现在是「跟随系统 + 12 门语言」13 行，比面板高：小屏 / 横屏下
        // 这个 Column 会直接 RenderFlex overflow（375x667 溢出 117px、
        // 844x390 溢出 374px）。装得下时与不加 `scrollable` 完全一致
        // （面板尺寸实测不变），装不下才滚。
        scrollable: true,
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _languageOptions.entries.map((entry) {
                return GlassChoiceItem<String>(
                  value: entry.key,
                  groupValue: _currentLocaleKey(configService),
                  title: Text(entry.value),
                  onChanged: (value) =>
                      _applyLanguage(context, configService, value),
                );
              }).toList(),
            ),
          ),
        ),
        actions: <GlassDialogAction>[
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(context: context),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _applyLanguage(
    BuildContext context,
    ConfigService configService,
    String value,
  ) {
    configService.updateApplicationLocale(value);
    if (value == _systemLocaleKey) {
      slang.LocaleSettings.useDeviceLocale();
    } else {
      slang.AppLocale? targetLocale;
      for (final locale in slang.AppLocale.values) {
        if (locale.languageTag.toLowerCase() == value.toLowerCase()) {
          targetLocale = locale;
          break;
        }
      }
      if (targetLocale != null) {
        slang.LocaleSettings.setLocale(targetLocale);
      }
    }
    Get.forceAppUpdate();

    showAppToast(
      _resolveLanguageChangedMessage(value),
      type: AppToastType.success,
    );

    AppService.tryPop();
  }

  // 与设置页一致：提示语用**刚切到的那门语言**显示——用户下一眼看到的就是它。
  // 选「跟随系统」时，那门语言就是设备语言（没适配时 parse 会退回 en）。
  String _resolveLanguageChangedMessage(String selectedValue) {
    final targetLocale = slang.AppLocaleUtils.parse(
      selectedValue == _systemLocaleKey
          ? CommonUtils.getDeviceLocale()
          : selectedValue,
    );
    return targetLocale.translations.settings.languageChangedMessage;
  }
}

/// 欢迎步的应用图标。
///
/// 尺寸跟着断点走，圆角按尺寸的比例算（固定 16 的话，120 的图标看着是「切了
/// 个角」，72 的又快成圆的了）。
class _AppIconHero extends StatelessWidget {
  const _AppIconHero();

  @override
  Widget build(BuildContext context) {
    final double size = stepIsDesktop(context)
        ? 120
        : (stepIsNarrow(context) ? 72 : 96);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        CommonConstants.launcherIconPath,
        width: size,
        height: size,
      ),
    );
  }
}
