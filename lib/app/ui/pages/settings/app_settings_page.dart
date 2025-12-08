import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';

class AppSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const AppSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  // 根据系统语言显示"跟随系统"的常量 map
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
    'zh-TW': '繁體中文',
  };

  // 根据当前设备语言获取"跟随系统"的文本
  String _getFollowSystemText() {
    final deviceLocale = CommonUtils.getDeviceLocale();
    return _followSystemTexts[deviceLocale] ?? _followSystemTexts['en']!;
  }

  final Map<String, String> _languageChangedMessages = {
    'en': 'Language changed successfully, some features require restarting the app to take effect.',
    'ja': '言語が正常に変更されました。一部の機能はアプリを再起動して有効にする必要があります。',
    'zh-CN': '语言切换成功，部分功能需重启应用生效',
    'zh-TW': '語言切換成功，部分功能需重啟應用生效',
  };

  void _showLanguageDialog(BuildContext context, ConfigService configService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(slang.t.settings.language),
          content: SizedBox(
            width: double.minPositive,
            child: Obx(
              () => RadioGroup<String>(
                groupValue: configService[ConfigKey.APPLICATION_LOCALE],
                onChanged: (String? value) async {
                  if (value != null) {
                    // 更新配置
                    configService.updateApplicationLocale(value);
                    
                    // 立即切换语言
                    if (value == 'system') {
                      slang.LocaleSettings.useDeviceLocale();
                    } else {
                      // 根据语言代码找到对应的 AppLocale
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
                    
                    // 强制刷新整个应用界面
                    Get.forceAppUpdate();
                    
                    Navigator.of(context).pop();

                    String message;
                    String localeKey = value;
                    if (localeKey == 'system') {
                      // 获取设备语言，但确保是我们支持的语言
                      String deviceLocale = CommonUtils.getDeviceLocale();
                      // 检查设备语言是否在我们的支持列表中
                      if (_languageChangedMessages.containsKey(deviceLocale)) {
                        localeKey = deviceLocale;
                      } else {
                        // 如果不支持，使用英语作为默认
                        localeKey = 'en';
                      }
                    }

                    message =
                        _languageChangedMessages[localeKey] ??
                        _languageChangedMessages['en']!;

                    showToastWidget(
                      MDToastWidget(
                        message: message,
                        type: MDToastType.success,
                      ),
                    );
                  }
                },
                child: ListView(
                  shrinkWrap: true,
                  children: _languageOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(slang.t.common.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 添加一个方法来刷新整个页面
  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.settings.appSettings,
            isWideScreen: widget.isWideScreen,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.history,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(slang.t.settings.autoRecordHistory),
                          subtitle: Text(
                            slang.t.settings.autoRecordHistoryDesc,
                          ),
                          value:
                              configService[ConfigKey.AUTO_RECORD_HISTORY_KEY],
                          onChanged: (value) {
                            configService[ConfigKey.AUTO_RECORD_HISTORY_KEY] =
                                value;
                            CommonConstants.enableHistory = value;
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.privacy,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(
                            slang.t.settings.activeBackgroundPrivacyMode,
                          ),
                          subtitle: Text(
                            slang.t.settings.activeBackgroundPrivacyModeDesc,
                          ),
                          value:
                              configService[ConfigKey
                                  .ACTIVE_BACKGROUND_PRIVACY_MODE],
                          onChanged: (value) {
                            configService[ConfigKey
                                    .ACTIVE_BACKGROUND_PRIVACY_MODE] =
                                value;
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (VibrateUtils.hasVibrator())
                  Card(
                    elevation: 2,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            slang.t.settings.interaction,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        Obx(
                          () => SwitchListTile(
                            title: Text(slang.t.settings.enableVibration),
                            subtitle: Text(
                              slang.t.settings.enableVibrationDesc,
                            ),
                            value: configService[ConfigKey.ENABLE_VIBRATION],
                            onChanged: (value) {
                              configService[ConfigKey.ENABLE_VIBRATION] = value;
                              CommonConstants.enableVibration = value;
                            },
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.language,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => ListTile(
                          title: Text(slang.t.settings.language),
                          subtitle: Text(
                            _languageOptions[configService[ConfigKey
                                    .APPLICATION_LOCALE]] ??
                                '',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () =>
                              _showLanguageDialog(context, configService),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (GetPlatform.isAndroid)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            slang.t.settings.appLinks,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(slang.t.settings.defaultBrowser),
                          subtitle: Text(slang.t.settings.defaultBrowserDesc),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () async {
                            final packageName = CommonConstants.packageName;
                            try {
                              // 首先尝试使用APP_LINKS_SETTINGS
                              final AndroidIntent intent = AndroidIntent(
                                action: 'android.settings.APP_LINKS_SETTINGS',
                                data: 'package:$packageName',
                              );
                              await intent.launch();
                            } catch (e) {
                              // 如果失败，尝试使用APPLICATION_DETAILS_SETTINGS
                              final AndroidIntent intent = AndroidIntent(
                                action:
                                    'android.settings.APPLICATION_DETAILS_SETTINGS',
                                data: 'package:$packageName',
                              );
                              await intent.launch();
                            }
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.markdown,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(
                            slang.t.settings.showUnprocessedMarkdownText,
                          ),
                          subtitle: Text(
                            slang.t.settings.showUnprocessedMarkdownTextDesc,
                          ),
                          value:
                              configService[ConfigKey
                                  .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY],
                          onChanged: (value) {
                            configService[ConfigKey
                                    .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY] =
                                value;
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  clipBehavior: Clip.hardEdge,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.exportConfig,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.file_upload),
                        title: Text(slang.t.settings.exportConfig),
                        subtitle: Text(slang.t.settings.exportConfigDesc),
                        onTap: () async {
                          try {
                            await Get.find<ConfigBackupService>()
                                .exportConfig();
                          } catch (e) {
                            showToastWidget(
                              MDToastWidget(
                                message:
                                    '${slang.t.settings.exportConfigFailed}: ${e.toString()}',
                                type: MDToastType.error,
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.file_download),
                        title: Text(slang.t.settings.importConfig),
                        subtitle: Text(slang.t.settings.importConfigDesc),
                        onTap: () async {
                          try {
                            await Get.find<ConfigBackupService>()
                                .importConfig();
                          } catch (e) {
                            showToastWidget(
                              MDToastWidget(
                                message:
                                    '${slang.t.settings.importConfigFailed}: ${e.toString()}',
                                type: MDToastType.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),


                const SafeArea(child: SizedBox.shrink()),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
