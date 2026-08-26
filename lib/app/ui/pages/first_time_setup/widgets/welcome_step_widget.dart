import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
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

  // 跟随系统文案
  static const Map<String, String> _followSystemTexts = {
    'en': 'Follow System',
    'ja': 'システムに従う',
    'zh-CN': '跟随系统',
    'zh-TW': '跟隨系統',
  };

  static const String _systemLocaleKey = 'system';

  Map<String, String> get _languageOptions => {
    _systemLocaleKey: _getFollowSystemText(),
    'en': 'English',
    'ja': '日本語',
    'zh-CN': '简体中文',
    'zh-TW': '繁体中文',
  };

  String _getFollowSystemText() {
    final deviceLocale = CommonUtils.getDeviceLocale();
    return _followSystemTexts[deviceLocale] ?? _followSystemTexts['en']!;
  }

  String _currentLocaleKey(ConfigService configService) {
    return configService[ConfigKey.APPLICATION_LOCALE] ?? _systemLocaleKey;
  }

  void _showLanguageDialog(BuildContext context, ConfigService configService) {
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.settings.language,
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

    showGlassToast(
      _resolveLanguageChangedMessage(value),
      type: GlassToastType.success,
    );

    AppService.tryPop();
  }

  // 与设置页一致：根据选择值/系统语言确定提示文案
  static const Map<String, String> _languageChangedMessages = {
    'en':
        'Language changed successfully, some features require restarting the app to take effect.',
    'ja': '言語が正常に変更されました。一部の機能はアプリを再起動して有効にする必要があります。',
    'zh-CN': '语言切换成功，部分功能需重启应用生效',
    'zh-TW': '語言切換成功，部分功能需重啟應用生效',
  };

  String _resolveLanguageChangedMessage(String selectedValue) {
    String localeKey = selectedValue;
    if (localeKey == _systemLocaleKey) {
      final deviceLocale = CommonUtils.getDeviceLocale();
      if (_languageChangedMessages.containsKey(deviceLocale)) {
        localeKey = deviceLocale;
      } else {
        localeKey = 'en';
      }
    }
    return _languageChangedMessages[localeKey] ??
        _languageChangedMessages['en']!;
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
