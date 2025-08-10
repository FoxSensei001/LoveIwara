import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_edit_dialog_widget.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_library_page.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class ForumSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const ForumSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final configService = Get.find<ConfigService>();

    return Scaffold(
      appBar: isWideScreen
          ? null
          : AppBar(
              title: Text(t.settings.forum,
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
                    t.settings.forum,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(t.settings.disableForumReplyQuote),
                    subtitle: Text(t.settings.disableForumReplyQuoteDesc),
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
                    t.settings.signature, // 需要在翻译文件中添加相应的翻译
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(t.settings.enableSignature),
                    subtitle: Text(t.settings.enableSignatureDesc),
                    value: configService[ConfigKey.ENABLE_SIGNATURE_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.ENABLE_SIGNATURE_KEY] = value;
                    },
                  ),
                ),
                Obx(
                  () => configService[ConfigKey.ENABLE_SIGNATURE_KEY]
                      ? ListTile(
                          title: Text(t.settings.signatureContent),
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
                    t.emoji.emojiManagement,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emoji_emotions),
                  title: Text(t.emoji.library),
                  subtitle: Text(t.emoji.manageEmojiGroupsAndImages),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const EmojiLibraryPage());
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
        ],
      ),
    );
  }
}