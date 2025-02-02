import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_reply_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_powered_by_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:flutter/services.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:oktoast/oktoast.dart';

class ThreadCommentCardWidget extends StatefulWidget {
  final ThreadCommentModel comment;
  final String threadAuthorId;
  final String threadId;
  final bool lockedThread;
  // repo
  final ThreadDetailRepository listSourceRepository;

  const ThreadCommentCardWidget({
    super.key,
    required this.comment,
    required this.threadAuthorId,
    required this.threadId,
    required this.lockedThread,
    required this.listSourceRepository,
  });

  @override
  State<ThreadCommentCardWidget> createState() => _ThreadCommentCardWidgetState();
}

class _ThreadCommentCardWidgetState extends State<ThreadCommentCardWidget> {
  final UserService _userService = Get.find<UserService>();
  final TranslationService _translationService = Get.find();
  final ConfigService _configService = Get.find();
  final RxBool isContentExpanded = false.obs;
  
  bool _isTranslating = false;
  String? _translatedText;

  // 构建翻译按钮
  Widget _buildTranslationButton(BuildContext context) {
    final t = slang.Translations.of(context);
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 左侧翻译按钮
          InkWell(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            onTap: _isTranslating ? null : () => _handleTranslation(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isTranslating)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.translate,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    t.common.translate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 分割线
          Container(
            height: 24,
            width: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
          ),
          // 右侧下拉按钮
          InkWell(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            onTap: _showTranslationMenuDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_drop_down,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建翻译后的内容区域
  Widget _buildTranslatedContent(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, size: 14),
              const SizedBox(width: 4),
              Text(
                t.common.translationResult,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              translationPoweredByWidget(context, fontSize: 10)
            ],
          ),
          const SizedBox(height: 8),
          if (_translatedText == t.common.translateFailedPleaseTryAgainLater)
            Text(
              _translatedText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            )
          else
            CustomMarkdownBody(
              data: _translatedText!,
            ),
        ],
      ),
    );
  }

  void _showTranslationMenuDialog() {
    final t = slang.Translations.of(context);
    final configService = Get.find<ConfigService>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.common.selectTranslationLanguage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Obx(() {
                      final isAIEnabled = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
                      if (!isAIEnabled) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(Routes.AI_TRANSLATION_SETTINGS_PAGE);
                          },
                          icon: Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            t.translation.enableAITranslation,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return Tooltip(
                        message: t.translation.disableAITranslation,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: true,
                              onChanged: (value) {
                                configService[ConfigKey.USE_AI_TRANSLATION] = false;
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(Get.context!).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: CommonConstants.translationSorts.map((sort) {
                      final isSelected = sort.id == _configService.currentTranslationSort.id;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        title: Text(sort.label),
                        trailing: isSelected ? const Icon(Icons.check, size: 18) : null,
                        onTap: () {
                          _configService.updateTranslationLanguage(sort);
                          AppService.tryPop();
                          if (_translatedText != null) {
                            _handleTranslation();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _handleTranslation() async {
    if (_isTranslating) return;

    setState(() => _isTranslating = true);

    final result = await _translationService.translate(widget.comment.body);
    if (result.isSuccess) {
      setState(() {
        _translatedText = result.data;
        _isTranslating = false;
      });
    } else {
      setState(() {
        _translatedText = slang.t.common.translateFailedPleaseTryAgainLater;
        _isTranslating = false;
      });
    }
  }

  Widget _buildCommentTag(String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    Color tagColor;
    if (text == slang.t.common.me) {
      tagColor = colorScheme.primary;
    } else if (text == slang.t.common.author) {
      tagColor = colorScheme.secondary;
    } else if (text == slang.t.forum.pendingReview) {
      tagColor = colorScheme.error;
    } else {
      tagColor = colorScheme.primary;
    }
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tagColor.withOpacity(0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: tagColor.withOpacity(0.8)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: tagColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = _userService.currentUser.value?.id == widget.comment.user.id;
    final bool isThreadAuthor = widget.threadAuthorId == widget.comment.user.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        NaviService.navigateToAuthorProfilePage(
                            widget.comment.user.username);
                      },
                      child: AvatarWidget(
                        user: widget.comment.user,
                        radius: 24,
                        defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 第一行：用户名和楼层号
                        Row(
                          children: [
                            Expanded(
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    NaviService.navigateToAuthorProfilePage(
                                        widget.comment.user.username);
                                  },
                                  child: buildUserName(context, widget.comment.user,
                                      fontSize: 16, bold: true),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '#${widget.comment.replyNum + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 第二行：用户名和发布时间
                        Row(
                          children: [
                            Expanded(
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.comment.user.username));
                                    showToastWidget(MDToastWidget(
                                        message: slang.t.forum
                                            .copySuccessForMessage(
                                                str: widget.comment.user.username),
                                        type: MDToastType.success));
                                  },
                                  child: Text(
                                    '@${widget.comment.user.username}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.schedule, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              CommonUtils.formatFriendlyTimestamp(
                                  widget.comment.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 第三行：标签
                        if (!widget.comment.approved || isCurrentUser || isThreadAuthor)
                          Wrap(
                            spacing: 8,
                            children: [
                              if (!widget.comment.approved)
                                _buildCommentTag(slang.t.forum.pendingReview, Icons.pending_outlined),
                              if (isCurrentUser)
                                _buildCommentTag(slang.t.common.me, Icons.person_outline),
                              if (isThreadAuthor)
                                _buildCommentTag(slang.t.common.author, Icons.stars_outlined),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 翻译与回复按钮行
            Row(
              spacing: 4,
              children: [
                if (widget.comment.createdAt != widget.comment.updatedAt) ...[
                  const Icon(Icons.edit, size: 14),
                  Text(
                    CommonUtils.formatFriendlyTimestamp(widget.comment.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
                const Spacer(),
                _buildTranslationButton(context),
                if (!widget.lockedThread) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      UserService userService = Get.find<UserService>();
                      if (!userService.isLogin) {
                        AppService.switchGlobalDrawer();
                        showToastWidget(MDToastWidget(
                          message: slang.t.errors.pleaseLoginFirst,
                          type: MDToastType.warning,
                        ));
                        return;
                      }
                      final replyTemplate = 'Reply #${widget.comment.replyNum + 1}: @${widget.comment.user.username}\n---\n';
                      Get.dialog(ForumReplyDialog(
                        threadId: widget.comment.threadId,
                        initialContent: replyTemplate,
                        onSubmit: () {
                          widget.listSourceRepository.refresh();
                        },
                      ));
                    },
                    icon: const Icon(Icons.reply),
                    label: Text(slang.t.forum.reply),
                  ).paddingRight(12),
                ],
              ],
            ),
            // Markdown内容
            CustomMarkdownBody(
              data: widget.comment.body,
            ),
            if (_translatedText != null) _buildTranslatedContent(context),
            // 操作按钮行（仅保留编辑按钮）
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: slang.t.common.edit,
                    onPressed: () {
                      UserService userService = Get.find<UserService>();
                      if (!userService.isLogin) {
                        AppService.switchGlobalDrawer();
                        showToastWidget(MDToastWidget(message: slang.t.errors.pleaseLoginFirst, type: MDToastType.warning));
                        return;
                      }
                      Get.dialog(ForumEditReplyDialog(
                        postId: widget.comment.id,
                        initialContent: widget.comment.body,
                        repository: widget.listSourceRepository,
                        onSubmit: () {
                          widget.listSourceRepository.refresh();
                        },
                      ));
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 