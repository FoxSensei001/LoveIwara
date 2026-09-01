import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_remove_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'dart:async';

import '../../../../models/comment.model.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';

import '../../../widgets/comment_actions_menu.dart';
import '../../../widgets/custom_markdown_body_widget.dart';
import '../widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_replies_bottom_sheet.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final String? authorUserId;
  final CommentController? controller;
  final bool isReply;
  final void Function(Duration position)? onTimestampSeek;

  /// 回复（子评论）编辑成功后回调：CommentItem 自己只发请求，
  /// 列表刷新由宿主（回复弹层）负责。顶级评论走 [controller] 不经此回调。
  final void Function(Comment updated)? onCommentEdited;

  /// 回复（子评论）删除成功后回调，参数为被删评论 id。
  final void Function(String commentId)? onCommentDeleted;

  const CommentItem({
    super.key,
    required this.comment,
    this.authorUserId,
    this.controller,
    this.isReply = false,
    this.onTimestampSeek,
    this.onCommentEdited,
    this.onCommentDeleted,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final UserService _userService = Get.find();
  final ConfigService _configService = Get.find();
  final CommentService _commentService = Get.find();

  // 翻译控制器
  late final MarkdownTranslationController _translationController;

  /// 「显示原始文本」由动作行那枚 only-icon 钮受控（正文内置开关已关闭），
  /// 初值仍沿用全局设置项。
  late bool _showOriginal;

  /// 正文加工前后确实有差异时才让那枚钮长出来。
  bool _hasProcessedContent = false;

  @override
  void initState() {
    super.initState();
    _translationController = MarkdownTranslationController();
    _showOriginal =
        _configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  bool get _canReply => !widget.isReply && widget.comment.parent == null;

  /// 长按（整条评论或正文文本上）弹出操作菜单：复制 / 选择复制 / 回复。
  /// [globalPosition] 是长按落点，菜单贴着它弹。
  void _showActionsMenu(Offset globalPosition) {
    showCommentActionsMenu(
      context: context,
      globalPosition: globalPosition,
      text: widget.comment.body,
      onReply: _canReply ? _showReplyDialog : null,
    );
  }

  void _handleViewReplies() {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => CommentRepliesBottomSheet(
        parentComment: widget.comment,
        authorUserId: widget.authorUserId,
        controller: widget.controller,
        onTimestampSeek: widget.onTimestampSeek,
      ),
    );
  }

  /// 动作行所有控件的统一高度：胶囊钮 / 翻译胶囊 / 更多圆钮必须一样高，
  /// 否则视觉上大小不一（语言选择器内部是默认 48 触摸目标的 IconButton，
  /// 不约束会把翻译胶囊撑高一圈）。
  static const double _actionPillHeight = 30.0;

  /// 胶囊动作钮：小图标 + 小字 + 浅色胶囊底。
  /// 传 [color]（如主色）时底色用它的淡化版本，否则用中性浅灰底。
  Widget _buildGhostAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = color ?? colorScheme.onSurfaceVariant;
    final bg = color != null
        ? color.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHigh;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: _actionPillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 翻译入口：翻译图标（翻译中转菊花）+ 紧凑语言选择器，合装进一个胶囊。
  Widget _buildTranslationControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: _actionPillHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final busy = _translationController.isTranslating.value;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: busy ? null : _handleTranslation,
                child: Container(
                  height: _actionPillHeight,
                  padding: const EdgeInsets.only(left: 10, right: 4),
                  alignment: Alignment.center,
                  child: busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.translate,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                ),
              );
            }),
            // 语言选择器自己不带尺寸，尺寸由这只槽位说了算
            Obx(
              () => SizedBox(
                width: 34,
                height: _actionPillHeight,
                child: TranslationLanguageSelector(
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
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTranslation() async {
    await _translationController.translate(
      widget.comment.body,
      originalText: widget.comment.body,
    );
  }

  /// 回复（子评论）不由 CommentController 管（它只维护顶级评论列表），
  /// 编辑/删除走 CommentService 直连 + [onCommentEdited]/[onCommentDeleted]
  /// 通知宿主刷新；只有顶级评论才真正需要 controller。
  bool get _isTopLevel => widget.comment.parent == null;

  void _showDeleteConfirmDialog() {
    if (_isTopLevel && widget.controller == null) {
      showAppToast(
        slang.t.errors.canNotFindCommentController,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
      return;
    }

    showAppDialog(
      CommentRemoveDialog(
        onDelete: () async {
          if (_isTopLevel) {
            await widget.controller!.deleteComment(widget.comment.id);
          } else {
            final result = await _commentService.deleteComment(
              widget.comment.id,
            );
            if (!mounted) return;
            if (result.isSuccess) {
              widget.onCommentDeleted?.call(widget.comment.id);
              showAppToast(
                slang.t.common.commentDeletedSuccessfully,
                type: AppToastType.success,
              );
            } else {
              showAppToast(
                result.message,
                type: AppToastType.error,
                position: AppToastPosition.bottom,
              );
            }
          }
          AppService.tryPop();
        },
      ),
    );
  }

  void _showEditDialog() {
    if (_isTopLevel && widget.controller == null) {
      showAppToast(
        slang.t.errors.canNotFindCommentController,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
      return;
    }

    showGlassBottomSheet(
      context: context,
      builder: (context) => CommentInputBottomSheet(
        initialText: widget.comment.body,
        title: slang.t.common.editComment,
        submitText: slang.t.common.save,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showAppToast(
              slang.t.errors.commentCanNotBeEmpty,
              type: AppToastType.error,
              position: AppToastPosition.bottom,
            );
            return;
          }

          if (_isTopLevel) {
            await widget.controller!.editComment(widget.comment.id, text);
          } else {
            final result = await _commentService.editComment(
              widget.comment.id,
              text,
            );
            if (!mounted) return;
            if (result.isSuccess) {
              widget.onCommentEdited?.call(
                widget.comment.copyWith(body: text, updatedAt: DateTime.now()),
              );
              showAppToast(
                slang.t.common.commentUpdated,
                type: AppToastType.success,
              );
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            } else {
              showAppToast(
                result.message,
                type: AppToastType.error,
                position: AppToastPosition.bottom,
              );
            }
          }
        },
      ),
    );
  }

  void _showReplyDialog() {
    if (widget.controller == null) {
      showAppToast(
        slang.t.errors.canNotFindCommentController,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
      return;
    }

    showGlassBottomSheet(
      context: context,
      builder: (context) => CommentInputBottomSheet(
        title: slang.t.common.replyComment,
        submitText: slang.t.common.reply,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showAppToast(
              slang.t.errors.commentCanNotBeEmpty,
              type: AppToastType.error,
              position: AppToastPosition.bottom,
            );
            return;
          }
          await widget.controller!.postComment(
            text,
            parentId: widget.comment.id,
          );
        },
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    final t = slang.Translations.of(context);

    // 检查是否有菜单项
    final hasReplyOption = widget.comment.parent == null && !widget.isReply;
    final isOwner =
        _userService.currentUser.value?.id == widget.comment.user?.id;

    // 如果只有回复选项，而旁边已经有回复按钮了，就不显示三个点菜单
    if (hasReplyOption && !isOwner) {
      return const SizedBox.shrink();
    }

    final hasMenuItems = hasReplyOption || isOwner;

    // 如果没有菜单项，返回空的 SizedBox
    if (!hasMenuItems) {
      return const SizedBox.shrink();
    }

    // 间距自带：菜单不可见（返回 shrink）时不能留下悬空的固定间距，
    // 否则右侧的翻译胶囊会贴不到行尾
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: SizedBox(
          width: _actionPillHeight,
          height: _actionPillHeight,
          // 菜单走全站统一的玻璃面板（原来是 PopupMenuButton，吐出来是块不透明
          // 的 Material 卡片）。Builder 是为了拿到触发钮自身的 context 量落点。
          child: Builder(
            builder: (anchorContext) => GlassPressable(
              // 长按也能打开，且长按不抬手可以直接划到某一条上松手选中
              // （见 GlassTapArea.opensOverlay）。
              opensOverlay: true,
              onTap: () async {
                final action = await showGlassMenu<String>(
                  anchorContext: anchorContext,
                  entries: [
                    if (hasReplyOption)
                      GlassMenuOption<String>(
                        value: 'reply',
                        icon: Icons.reply,
                        label: t.common.reply,
                      ),
                    if (isOwner) ...[
                      GlassMenuOption<String>(
                        value: 'edit',
                        icon: Icons.edit,
                        label: t.common.edit,
                      ),
                      GlassMenuOption<String>(
                        value: 'delete',
                        icon: Icons.delete,
                        label: t.common.delete,
                        destructive: true,
                      ),
                    ],
                  ],
                );
                switch (action) {
                  case 'reply':
                    _showReplyDialog();
                  case 'edit':
                    _showEditDialog();
                  case 'delete':
                    _showDeleteConfirmDialog();
                }
              },
              builder: (context, pressed) => Center(
                child: Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 身份小徽标（「作者」/「我」），代替旧版的整条左侧强调竖条。
  Widget _buildIdentityChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }

  /// 元信息单行：@用户名 · 时间 (· xx编辑)。
  String _buildMetaLine(Comment comment, slang.Translations t) {
    final parts = <String>[];
    final username = comment.user?.username ?? '';
    if (username.isNotEmpty) parts.add('@$username');
    if (comment.createdAt != null) {
      parts.add(CommonUtils.formatFriendlyTimestamp(comment.createdAt));
    }
    final hasEdit =
        comment.updatedAt != null &&
        comment.createdAt != null &&
        comment.updatedAt!.isAfter(comment.createdAt!);
    if (hasEdit) {
      parts.add(
        t.common.editedAt(
          num: CommonUtils.formatFriendlyTimestamp(comment.updatedAt),
        ),
      );
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 身份标识：内容作者（secondary）与当前登录用户（primary），可同时显示。
    final currentUserId = _userService.currentUser.value?.id;
    final commentUserId = comment.user?.id;
    final isMe = commentUserId != null && commentUserId == currentUserId;
    final isContentAuthor =
        commentUserId != null &&
        widget.authorUserId != null &&
        commentUserId == widget.authorUserId;

    final bool canReply = _canReply;
    final metaLine = _buildMetaLine(comment, t);

    void openProfile() =>
        NaviService.navigateToAuthorProfilePage(comment.user?.username ?? '');

    return RepaintBoundary(
      // 整条评论区域可点：顶级评论点按任意空白处直接回复，
      // 长按弹出 复制/选择复制/回复 操作菜单
      //（头像 / 名字 / 幽灵钮 / 菜单等内层手势优先，不受影响）
      child: Material(
        color: Colors.transparent,
        // 长按由外面这层接：一来 InkWell.onLongPress 给不出落点（菜单要贴着
        // 手指弹），二来这层会把还按着的手指交给菜单，「按住 → 划到某一条 →
        // 松手选中」才成立。InkWell 只留点按，不再注册长按识别器，两层不抢。
        child: GlassLongPressMenuArea(
          onMenu: _showActionsMenu,
          child: InkWell(
            onTap: canReply ? _showReplyDialog : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像列
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: openProfile,
                      child: AvatarWidget(
                        user: comment.user,
                        size: widget.isReply ? 30 : 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 内容列
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名字行：左侧「名字 + 身份徽标」为一组占满剩余宽度，
                        // 楼号固定钉在行尾（不能用 Flexible+Spacer 平分空间的写法：
                        // 名字短时用不完的份额会留在行尾，楼号就贴不到最右）
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: openProfile,
                                        child: buildUserName(
                                          context,
                                          comment.user,
                                          fontSize: 14,
                                          bold: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isContentAuthor)
                                    _buildIdentityChip(
                                      t.common.author,
                                      colorScheme.secondary,
                                    ),
                                  if (isMe)
                                    _buildIdentityChip(
                                      t.common.me,
                                      colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                            // 楼号（只有顶级评论显示），弱化为灰字
                            if (comment.parent == null &&
                                comment.floorNumber != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  '#${comment.floorNumber}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (metaLine.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            metaLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // 正文；SelectionArea 会吞掉 tap 传不到整条评论的
                        // InkWell，点按回复需经 onTap 显式透传进去
                        CustomMarkdownBody(
                          data: comment.body,
                          originalData: comment.body,
                          showTranslationButton: false,
                          translationController: _translationController,
                          onTimestampSeek: widget.onTimestampSeek,
                          onTap: canReply ? _showReplyDialog : null,
                          onLongPress: _showActionsMenu,
                          initialShowUnprocessedText: _showOriginal,
                          onProcessedContentChanged: (hasProcessed) {
                            if (_hasProcessedContent == hasProcessed) return;
                            setState(() => _hasProcessedContent = hasProcessed);
                          },
                        ),
                        const SizedBox(height: 4),
                        // 动作行：回复 / 查看回复 …… 翻译 / 更多
                        Row(
                          children: [
                            if (canReply) ...[
                              _buildGhostAction(
                                context,
                                icon: Icons.reply,
                                label: t.common.reply,
                                onTap: _showReplyDialog,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (!widget.isReply && comment.numReplies > 0)
                              Tooltip(
                                message: t.common.viewReplies(
                                  num: comment.numReplies,
                                ),
                                child: _buildGhostAction(
                                  context,
                                  icon: Icons.chat_bubble_outline,
                                  label: '${comment.numReplies}',
                                  color: colorScheme.primary,
                                  onTap: _handleViewReplies,
                                ),
                              ),
                            const Spacer(),
                            MarkdownOriginalTextToggle(
                              visible: _hasProcessedContent,
                              showOriginal: _showOriginal,
                              pillSize: _actionPillHeight,
                              padding: const EdgeInsets.only(right: 8),
                              onChanged: (v) =>
                                  setState(() => _showOriginal = v),
                            ),
                            _buildTranslationControls(context),
                            _buildActionMenu(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
