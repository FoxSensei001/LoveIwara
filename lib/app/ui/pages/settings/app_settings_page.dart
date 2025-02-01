import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class AppSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const AppSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}