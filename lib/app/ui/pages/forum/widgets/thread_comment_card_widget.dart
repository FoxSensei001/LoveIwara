import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_reply_dialog.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

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
  State<ThreadCommentCardWidget> createState() =>
      _ThreadCommentCardWidgetState();
}

class _ThreadCommentCardWidgetState extends State<ThreadCommentCardWidget> {
  final UserService _userService = Get.find<UserService>();
  final ConfigService _configService = Get.find();

  // 楼主强调色（琥珀），优先级高于工作人员角色色
  static const Color _authorAccent = Color(0xFFFFB300);

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

  /// 计算卡片的强调色：发帖人(楼主) > admin > officer/moderator。
  /// 高级用户(premium)、受限用户(limited)、普通用户返回 null（使用普通卡片）。
  Color? _resolveAccentColor() {
    if (widget.threadAuthorId == widget.comment.user.id) {
      return _authorAccent;
    }
    final role = widget.comment.user.role;
    if (role == 'admin' || widget.comment.user.isAdmin) {
      return Colors.red;
    }
    if (role == 'officer' || role == 'moderator') {
      return Colors.green.shade400;
    }
    return null;
  }

  // 构建翻译按钮
  Widget _buildTranslationButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => IconButton(
            onPressed: _translationController.isTranslating.value
                ? null
                : () => _handleTranslation(),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: _translationController.isTranslating.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.translate,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
        ),
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
    await _translationController.translate(
      widget.comment.body,
      originalText: widget.comment.body,
    );
  }

  // 紧凑的页脚操作按钮（统一尺寸与点击区域）
  Widget _buildFooterIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _navigateToProfile() {
    NaviService.navigateToAuthorProfilePage(
      widget.comment.user.username,
      initialUser: widget.comment.user,
    );
  }

  bool _ensureLoggedIn() {
    final userService = Get.find<UserService>();
    if (!userService.isAuthenticated) {
      AppService.switchGlobalDrawer();
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.pleaseLoginFirst,
          type: MDToastType.warning,
        ),
      );
      return false;
    }
    return true;
  }

  void _handleReply() {
    if (!_ensureLoggedIn()) return;
    final replyTemplate =
        'Reply #${widget.comment.replyNum + 1}: @${widget.comment.user.username}\n---\n';
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
  }

  void _handleEdit() {
    if (!_ensureLoggedIn()) return;
    showAppDialog(
      ForumEditReplyDialog(
        postId: widget.comment.id,
        initialContent: widget.comment.body,
        repository: widget.listSourceRepository,
        onSubmit: () {
          widget.listSourceRepository.refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mutedColor = colorScheme.onSurfaceVariant;
    final bool isCurrentUser =
        _userService.currentUser.value?.id == widget.comment.user.id;
    final bool isEdited = widget.comment.createdAt != widget.comment.updatedAt;
    final Color? accentColor = _resolveAccentColor();
    final bool isSpecial = accentColor != null;

    // 特殊用户：淡色背景 tint + 角色色描边；普通用户：常规卡片
    final Color cardColor = isSpecial
        ? Color.alphaBlend(
            accentColor.withValues(alpha: 0.06),
            colorScheme.surfaceContainerLowest,
          )
        : colorScheme.surfaceContainerLowest;
    final Color borderColor = isSpecial
        ? accentColor.withValues(alpha: 0.35)
        : colorScheme.outlineVariant.withValues(alpha: 0.3);

    return Card(
      elevation: 0,
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            // 竖条占去约 3.5px，左内边距相应缩小以保持头像对齐
            padding: EdgeInsets.fromLTRB(isSpecial ? 10.5 : 14, 12, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // 头部：头像 + 用户名 + 楼层号 / @用户名 · 时间
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _navigateToProfile,
                          child: AvatarWidget(
                            user: widget.comment.user,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 第一行：用户名 + 楼层号
                            Row(
                              children: [
                                Expanded(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: _navigateToProfile,
                                      child: buildUserName(
                                        context,
                                        widget.comment.user,
                                        fontSize: 15,
                                        bold: true,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '#${widget.comment.replyNum + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: mutedColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // 第二行：@用户名 · 发布时间（· 待审核）
                            Row(
                              children: [
                                Flexible(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: widget.comment.user.username,
                                          ),
                                        );
                                        showToastWidget(
                                          MDToastWidget(
                                            message: slang.t.forum
                                                .copySuccessForMessage(
                                                  str: widget
                                                      .comment.user.username,
                                                ),
                                            type: MDToastType.success,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '@${widget.comment.user.username}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: mutedColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '  ·  ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mutedColor,
                                  ),
                                ),
                                Text(
                                  CommonUtils.formatFriendlyTimestamp(
                                    widget.comment.createdAt,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mutedColor,
                                  ),
                                ),
                                if (!widget.comment.approved) ...[
                                  Text(
                                    '  ·  ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: mutedColor,
                                    ),
                                  ),
                                  Text(
                                    slang.t.forum.pendingReview,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 用户信息行与内容行之间的细分割线
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 10),
                  // 正文
                  CustomMarkdownBody(
                    data: widget.comment.body,
                    originalData: widget.comment.body,
                    showTranslationButton: false,
                    translationController: _translationController,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 2),
                  // 页脚：编辑时间（左）+ 翻译 / 编辑 / 回复（右）
                  Row(
                    children: [
                      // 左侧编辑时间用 Expanded 占满剩余空间，
                      // 保证右侧按钮始终完全贴右
                      Expanded(
                        child: isEdited
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 13,
                                    color: mutedColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      slang.t.common.editedAt(
                                        num: CommonUtils.formatFriendlyTimestamp(
                                          widget.comment.updatedAt,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      _buildTranslationButton(context),
                      if (isCurrentUser)
                        _buildFooterIconButton(
                          icon: Icons.edit_outlined,
                          tooltip: slang.t.common.edit,
                          onPressed: _handleEdit,
                        ),
                      if (!widget.lockedThread)
                        _buildFooterIconButton(
                          icon: Icons.reply,
                          tooltip: slang.t.common.reply,
                          color: colorScheme.primary,
                          onPressed: _handleReply,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // 左侧角色色竖条（仅特殊用户），覆盖全卡高度
            if (isSpecial)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(width: 3.5, color: accentColor),
              ),
          ],
        ),
      );
  }
}
