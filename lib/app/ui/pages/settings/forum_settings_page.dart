import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_edit_sheet_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_library_page.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class ForumSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const ForumSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final configService = Get.find<ConfigService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.forum,
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(t.settings.disableForumReplyQuote),
                          subtitle: Text(t.settings.disableForumReplyQuoteDesc),
                          value:
                              configService[ConfigKey
                                  .DISABLE_FORUM_REPLY_QUOTE_KEY],
                          onChanged: (value) {
                            configService[ConfigKey
                                    .DISABLE_FORUM_REPLY_QUOTE_KEY] =
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(t.settings.enableSignature),
                          subtitle: Text(t.settings.enableSignatureDesc),
                          value: configService[ConfigKey.ENABLE_SIGNATURE_KEY],
                          onChanged: (value) {
                            configService[ConfigKey.ENABLE_SIGNATURE_KEY] =
                                value;
                          },
                        ),
                      ),
                      Obx(
                        () => configService[ConfigKey.ENABLE_SIGNATURE_KEY]
                            ? ListTile(
                                title: Text(t.settings.signatureContent),
                                subtitle: Text(
                                  configService[ConfigKey
                                      .SIGNATURE_CONTENT_KEY],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.edit),
                                onTap: () async {
                                  final result =
                                      await showModalBottomSheet<String>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) =>
                                            SignatureEditSheet(
                                              initialContent:
                                                  configService[ConfigKey
                                                      .SIGNATURE_CONTENT_KEY],
                                            ),
                                      );
                                  if (result != null) {
                                    configService[ConfigKey
                                            .SIGNATURE_CONTENT_KEY] =
                                        result;
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.emoji_emotions),
                        title: Text(t.emoji.library),
                        subtitle: Text(t.emoji.manageEmojiGroupsAndImages),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (isWideScreen) {
                            // 宽屏模式：使用设置页面的内部导航
                            SettingsPage.navigateToNestedPage(
                              EmojiLibraryPage(isWideScreen: true),
                            );
                          } else {
                            // 窄屏模式：使用全局导航
                            NaviService.navigateToEmojiLibraryPage();
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
