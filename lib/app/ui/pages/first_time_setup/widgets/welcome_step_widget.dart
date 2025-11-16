import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';

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

    return StepResponsiveScaffold(
      desktopBuilder: (context, theme) => _buildDesktopLayout(context, theme, configService),
      mobileBuilder: (context, theme, isNarrow) => _buildMobileLayout(context, theme, isNarrow, configService),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, ConfigService configService) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 副标题
              Text(
                subtitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              // 描述
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildLanguageSelector(context, theme, false, configService),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                CommonConstants.launcherIconPath,
                width: 120,
                height: 120,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, bool isNarrow, ConfigService configService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isNarrow ? 16 : 24),
        // 应用图标
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              CommonConstants.launcherIconPath,
              width: isNarrow ? 72 : 96,
              height: isNarrow ? 72 : 96,
            ),
          ),
        ),
        SizedBox(height: isNarrow ? 20 : 32),
            // 副标题
        Text(
          subtitle,
          style: (isNarrow ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isNarrow ? 20 : 32),
        // 描述
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        SizedBox(height: isNarrow ? 16 : 24),
        _buildLanguageSelector(context, theme, isNarrow, configService),
      ],
    );
  }

  // 语言选择控件（符合 Step Widget 的风格）
  Widget _buildLanguageSelector(
    BuildContext context,
    ThemeData theme,
    bool isNarrow,
    ConfigService configService,
  ) {
    return Obx(() {
      final currentLabel = _languageOptions[_currentLocaleKey(configService)] ?? '';
      return Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isNarrow ? 6 : 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(isNarrow ? 8 : 10),
              ),
              child: Icon(
                Icons.language,
                size: isNarrow ? 18 : 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slang.t.settings.language,
                    style: (isNarrow ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: isNarrow ? 2 : 4),
                  Text(
                    currentLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            TextButton.icon(
              onPressed: () => _showLanguageDialog(context, configService),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text('修改'),
            ),
          ],
        ),
      );
    });
  }

  // 跟随系统文案
  static const Map<String, String> _followSystemTexts = {
    'en': 'Follow System',
    'ja': 'システムに従う',
    'zh-CN': '跟随系统',
    'zh-TW': '跟隨系統',
  };

  Map<String, String> get _languageOptions => {
    'system': _getFollowSystemText(),
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
    return configService[ConfigKey.APPLICATION_LOCALE] ?? 'system';
  }

  void _showLanguageDialog(BuildContext context, ConfigService configService) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 8),
            Text(slang.t.settings.language),
          ],
        ),
        content: SizedBox(
          width: double.minPositive,
          child: Obx(
            () => ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: RadioGroup<String>(
                    groupValue: configService[ConfigKey.APPLICATION_LOCALE],
                    onChanged: (String? value) async {
                      if (value != null) {
                        configService.updateApplicationLocale(value);
                        if (value == 'system') {
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

                        final String message = _resolveLanguageChangedMessage(value);
                        showToastWidget(MDToastWidget(message: message, type: MDToastType.success));

                        AppService.tryPop();
                      }
                    },
                child: ListView(
                  shrinkWrap: true,
                  children: _languageOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
                ),
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: Text(slang.t.common.cancel),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // 与设置页一致：根据选择值/系统语言确定提示文案
  static const Map<String, String> _languageChangedMessages = {
    'en': 'Language changed successfully, some features require restarting the app to take effect.',
    'ja': '言語が正常に変更されました。一部の機能はアプリを再起動して有効にする必要があります。',
    'zh-CN': '语言切换成功，部分功能需重启应用生效',
    'zh-TW': '語言切換成功，部分功能需重啟應用生效',
  };

  String _resolveLanguageChangedMessage(String selectedValue) {
    String localeKey = selectedValue;
    if (localeKey == 'system') {
      final deviceLocale = CommonUtils.getDeviceLocale();
      if (_languageChangedMessages.containsKey(deviceLocale)) {
        localeKey = deviceLocale;
      } else {
        localeKey = 'en';
      }
    }
    return _languageChangedMessages[localeKey] ?? _languageChangedMessages['en']!;
  }
}
