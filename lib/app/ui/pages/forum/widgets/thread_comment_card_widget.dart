import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_reply_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';

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
  final ConfigService _configService = Get.find();
  
  // 使用翻译控制器
  late final MarkdownTranslationController _translationController;

  @override
  void initState() {
    super.initState();
    _translationController = MarkdownTranslationController();
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  // 构建翻译按钮
  Widget _buildTranslationButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => IconButton(
          onPressed: _translationController.isTranslating.value ? null : () => _handleTranslation(),
          icon: _translationController.isTranslating.value
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.translate,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
        )),
        // 不设置间隙，紧靠着放置
        TranslationLanguageSelector(
          compact: true,
          extrimCompact: true,
          selectedLanguage: _configService.currentTranslationSort,
          onLanguageSelected: (sort) {
            _configService.updateTranslationLanguage(sort);
            if (_translationController.hasTranslation) {
              _handleTranslation();
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleTranslation() async {
    await _translationController.translate(widget.comment.body, originalText: widget.comment.body);
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
                        size: 40
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
                  const SizedBox(width: 4),
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
                  IconButton(
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ForumReplyBottomSheet(
                          threadId: widget.comment.threadId,
                          initialContent: replyTemplate,
                          onSubmit: () {
                            widget.listSourceRepository.refresh();
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.reply,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            // Markdown内容
            CustomMarkdownBody(
              data: widget.comment.body,
              originalData: widget.comment.body,
              showTranslationButton: false,
              translationController: _translationController,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
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