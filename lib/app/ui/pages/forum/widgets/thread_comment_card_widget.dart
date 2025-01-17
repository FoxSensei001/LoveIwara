import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_reply_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:flutter/services.dart';
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

  Widget _buildUserName(User user) {
    // 根据用户角色设置颜色
    Color? nameColor;
    if (user.role == 'officer' || user.role == 'moderator' || user.role == 'admin') {
      nameColor = Colors.green.shade400;
    } else if (user.role == 'limited') {
      nameColor = Colors.grey.shade400;
    } else {
      nameColor = user.isAdmin ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant;
    }

    // 如果是高级用户,使用渐变效果
    if (user.premium) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.purple.shade300,
            Colors.blue.shade300,
            Colors.pink.shade300,
          ],
        ).createShader(bounds),
        child: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // 普通用户名显示
    return Text(
      user.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: nameColor,
      ),
    );
  }

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
              Text(
                'Powered by Google',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
              ),
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
                child: Text(
                  slang.t.common.selectTranslationLanguage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = _userService.currentUser.value?.id == widget.comment.user.id;
    final bool isThreadAuthor = widget.threadAuthorId == widget.comment.user.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            // 评论者信息和楼层
            Row(
              spacing: 12,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
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
                                child: _buildUserName(widget.comment.user),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#${widget.comment.replyNum + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      // 第二行：用户名和发布时间
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: widget.comment.user.username));
                                  showToastWidget(MDToastWidget(
                                    message: slang.t.forum.copySuccessForMessage(str: widget.comment.user.username),
                                    type: MDToastType.success
                                  ));
                                },
                                child: Text(
                                  '@${widget.comment.user.username}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.schedule, size: 14),
                          Text(
                            CommonUtils.formatFriendlyTimestamp(widget.comment.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      // 第三行：标签
                      if (!widget.comment.approved || isCurrentUser || isThreadAuthor)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (!widget.comment.approved)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pending_outlined,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        slang.t.forum.pendingReview,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (isCurrentUser)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        slang.t.common.me,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (isThreadAuthor)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stars_outlined,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        slang.t.common.author,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // 评论内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 翻译按钮行
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
                  ],
                ),
                // Markdown内容
                CustomMarkdownBody(
                  data: widget.comment.body,
                ),
                if (_translatedText != null) _buildTranslatedContent(context),
                // 操作按钮行
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 编辑按钮
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
                              // 刷新评论列表
                              widget.listSourceRepository.refresh();
                            },
                          ));
                        },
                      ),
                    // 如果thread没有lock
                    if (!widget.lockedThread)
                      // 回复按钮
                      IconButton(
                        icon: const Icon(Icons.reply),
                      tooltip: slang.t.forum.reply,
                      onPressed: () {
                        UserService userService = Get.find<UserService>();
                        if (!userService.isLogin) {
                          AppService.switchGlobalDrawer();
                          showToastWidget(MDToastWidget(message: slang.t.errors.pleaseLoginFirst, type: MDToastType.warning));
                          return;
                        }
                        // 生成回复模板文本
                        final replyTemplate = 'Reply #${widget.comment.replyNum + 1}: @${widget.comment.user.username}\n---\n';
                        
                        // 打开回复对话框
                        Get.dialog(ForumReplyDialog(
                          threadId: widget.comment.threadId,
                          initialContent: replyTemplate,
                          onSubmit: () {
                            // 刷新评论列表
                            widget.listSourceRepository.refresh();
                          },
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 