import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_settings_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class ForumSettingsPage extends StatelessWidget {
  const ForumSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final configService = Get.find<ConfigService>();
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return GlassSettingsScaffold(
      title: t.settings.chatSettings.name,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
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
                      () => GlassSwitchItem(
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
                    // 开关 + 所见即所得预览 + 编辑入口，与首次引导页共用同一份。
                    // 旧版这里只把小尾巴内容当一行纯文本塞进 subtitle，用户
                    // 看不到那条 `---` 会渲染成什么——而它正是整件事出问题的
                    // 地方（详见 CommentMarkup 的类文档）。
                    Obx(
                      () => SignatureSettingsBody(
                        enabled: configService[ConfigKey.ENABLE_SIGNATURE_KEY],
                        content:
                            configService[ConfigKey.SIGNATURE_CONTENT_KEY],
                        onContentChanged: (value) {
                          configService[ConfigKey.SIGNATURE_CONTENT_KEY] =
                              value;
                        },
                        switchBuilder: (context) => GlassSwitchItem(
                          title: Text(t.settings.enableSignature),
                          subtitle: Text(t.settings.enableSignatureDesc),
                          value: configService[ConfigKey.ENABLE_SIGNATURE_KEY],
                          onChanged: (value) {
                            configService[ConfigKey.ENABLE_SIGNATURE_KEY] =
                                value;
                          },
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
                        // 表情库是共享资源页（聊天输入框也能进），不属于设置树，
                        // 宽屏下也整页盖住设置，而不是塞进右栏。
                        NaviService.navigateToEmojiLibraryPage();
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
    );
  }
}
