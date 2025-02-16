import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_edit_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:oktoast/oktoast.dart';

class AppSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const AppSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Scaffold(
      appBar: isWideScreen
          ? null
          : AppBar(
              title: Text(slang.t.settings.appSettings,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              elevation: 2,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              iconTheme: IconThemeData(color: Get.isDarkMode ? Colors.white : null),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.autoRecordHistory),
                    subtitle: Text(slang.t.settings.autoRecordHistoryDesc),
                    value: configService[ConfigKey.AUTO_RECORD_HISTORY_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.AUTO_RECORD_HISTORY_KEY] = value;
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.activeBackgroundPrivacyMode),
                    subtitle: Text(slang.t.settings.activeBackgroundPrivacyModeDesc),
                    value: configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE],
                    onChanged: (value) {
                      configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE] = value;
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(slang.t.settings.enableVibration),
                          subtitle: Text(slang.t.settings.enableVibrationDesc),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.showUnprocessedMarkdownText),
                    subtitle: Text(slang.t.settings.showUnprocessedMarkdownTextDesc),
                    value: configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY] = value;
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
                    slang.t.settings.forum,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.disableForumReplyQuote),
                    subtitle: Text(slang.t.settings.disableForumReplyQuoteDesc),
                    value: configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY] = value;
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
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    slang.t.settings.signature, // 需要在翻译文件中添加相应的翻译
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.enableSignature),
                    subtitle: Text(slang.t.settings.enableSignatureDesc),
                    value: configService[ConfigKey.ENABLE_SIGNATURE_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.ENABLE_SIGNATURE_KEY] = value;
                    },
                  ),
                ),
                Obx(
                  () => configService[ConfigKey.ENABLE_SIGNATURE_KEY]
                      ? ListTile(
                          title: Text(slang.t.settings.signatureContent),
                          subtitle: Text(
                            configService[ConfigKey.SIGNATURE_CONTENT_KEY],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => SignatureEditDialog(
                                initialContent: configService[ConfigKey.SIGNATURE_CONTENT_KEY],
                              ),
                            );
                            if (result != null) {
                              configService[ConfigKey.SIGNATURE_CONTENT_KEY] = result;
                            }
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
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
              children: [
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: Text(slang.t.settings.exportConfig),
                  subtitle: Text(slang.t.settings.exportConfigDesc),
                  onTap: () async {
                    try {
                      await Get.find<ConfigBackupService>().exportConfig();
                      showToastWidget(MDToastWidget(message: slang.t.settings.exportConfigSuccess, type: MDToastType.success));
                    } catch (e) {
                      showToastWidget(MDToastWidget(message: '${slang.t.settings.exportConfigFailed}: ${e.toString()}', type: MDToastType.error));
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: Text(slang.t.settings.importConfig),
                  subtitle: Text(slang.t.settings.importConfigDesc),
                  onTap: () async {
                    try {
                      await Get.find<ConfigBackupService>().importConfig();
                      showToastWidget(MDToastWidget(message: slang.t.settings.importConfigSuccess, type: MDToastType.success));
                    } catch (e) {
                      showToastWidget(MDToastWidget(message: '${slang.t.settings.importConfigFailed}: ${e.toString()}', type: MDToastType.error));
                    }
                  },
                ),
              ],
            ),
          ),
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

