import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_remove_dialog.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:async';

import '../../../../../common/constants.dart';
import '../../../../models/comment.model.dart';
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

  const CommentItem({
    super.key,
    required this.comment,
    this.authorUserId,
    this.controller,
    this.isReply = false,
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

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _translationController = MarkdownTranslationController();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _translationController.dispose();
    super.dispose();
  }

  void _handleViewReplies() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentRepliesBottomSheet(
        parentComment: widget.comment,
        authorUserId: widget.authorUserId,
        controller: widget.controller,
      ),
    );
  }

  void _showTranslationMenuOverlay() {
    _overlayEntry?.remove();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 40),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: CommonConstants.translationSorts.map((sort) {
                final isSelected =
                    sort.id == _configService.currentTranslationSort.id;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  title: Text(sort.label),
                  onTap: () {
                    _configService.updateTranslationLanguage(sort);
                    _toggleTranslationMenu();
                    if (_translationController.hasTranslation) {
                      _handleTranslation();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _toggleTranslationMenu() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _showTranslationMenuOverlay();
    }
  }

  Widget _buildTranslationButton(BuildContext context) {
    final configService = Get.find<ConfigService>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => IconButton(
            onPressed: _translationController.isTranslating.value
                ? null
                : () => _handleTranslation(),
            icon: _translationController.isTranslating.value
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.translate,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
        ),
        Obx(
          () => TranslationLanguageSelector(
            compact: true,
            extrimCompact: true,
            selectedLanguage: configService.currentTranslationSort,
            onLanguageSelected: (sort) {
              configService.updateTranslationLanguage(sort);
              if (_translationController.hasTranslation) {
                _handleTranslation();
              }
            },
          ),
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

  Widget _buildCommentTag(String text, Color color, IconData icon) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        Color tagColor;
        switch (text) {
          case String t when t == slang.t.common.me:
            tagColor = colorScheme.primary;
            break;
          case String t when t == slang.t.common.premium:
            tagColor = colorScheme.tertiary;
            break;
          case String t when t == slang.t.common.author:
            tagColor = colorScheme.secondary;
            break;
          case String t when t == slang.t.common.admin:
            tagColor = colorScheme.error;
            break;
          default:
            tagColor = colorScheme.primary;
        }

        return Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tagColor.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: tagColor.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: tagColor.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeInfo(Comment comment, BuildContext context) {
    final t = slang.Translations.of(context);
    if (comment.createdAt == null) return const SizedBox.shrink();

    final hasEdit =
        comment.updatedAt != null &&
        comment.createdAt != null &&
        comment.updatedAt!.isAfter(comment.createdAt!);

    final timeTextStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CommonUtils.formatFriendlyTimestamp(comment.createdAt),
                    style: timeTextStyle,
                  ),
                  const Spacer(),
                ],
              ),
              if (hasEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_calendar,
                        size: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.common.editedAt(
                          num: CommonUtils.formatFriendlyTimestamp(
                            comment.updatedAt,
                          ),
                        ),
                        style: timeTextStyle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // 回复数量指示器
        if (!widget.isReply && widget.comment.numReplies > 0)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _handleViewReplies,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge.count(
                      count: widget.comment.numReplies,
                      child: Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmDialog() {
    if (widget.controller == null) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.canNotFindCommentController,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    showAppDialog(
      CommentRemoveDialog(
        onDelete: () async {
          await widget.controller!.deleteComment(widget.comment.id);
          AppService.tryPop();
        },
      ),
    );
  }

  void _showEditDialog() {
    if (widget.controller == null) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.canNotFindCommentController,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentInputBottomSheet(
        initialText: widget.comment.body,
        title: slang.t.common.editComment,
        submitText: slang.t.common.save,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showToastWidget(
              MDToastWidget(
                message: slang.t.errors.commentCanNotBeEmpty,
                type: MDToastType.error,
              ),
              position: ToastPosition.bottom,
            );
            return;
          }

          if (widget.comment.parent == null) {
            await widget.controller!.editComment(widget.comment.id, text);
          } else {
            final result = await _commentService.editComment(
              widget.comment.id,
              text,
            );
            if (!mounted) return;
            if (result.isSuccess) {
              showToastWidget(
                MDToastWidget(
                  message: slang.t.common.commentUpdated,
                  type: MDToastType.success,
                ),
              );
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            } else {
              showToastWidget(
                MDToastWidget(message: result.message, type: MDToastType.error),
                position: ToastPosition.bottom,
              );
            }
          }
        },
      ),
    );
  }

  void _showReplyDialog() {
    if (widget.controller == null) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.canNotFindCommentController,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentInputBottomSheet(
        title: slang.t.common.replyComment,
        submitText: slang.t.common.reply,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showToastWidget(
              MDToastWidget(
                message: slang.t.errors.commentCanNotBeEmpty,
                type: MDToastType.error,
              ),
              position: ToastPosition.bottom,
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

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16),
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        if (hasReplyOption)
          PopupMenuItem(
            value: 'reply',
            child: Row(
              children: [
                const Icon(Icons.reply, size: 16),
                const SizedBox(width: 8),
                Text(t.common.reply, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        if (isOwner) ...[
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16),
                const SizedBox(width: 8),
                Text(t.common.edit, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 16),
                const SizedBox(width: 8),
                Text(t.common.delete, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ],
      onSelected: (value) {
        switch (value) {
          case 'reply':
            _showReplyDialog();
            break;
          case 'edit':
            _showEditDialog();
            break;
          case 'delete':
            _showDeleteConfirmDialog();
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final t = slang.Translations.of(context);

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.isReply ? 0.0 : 8.0,
          right: 8.0,
          top: 6.0,
          bottom: 6.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => NaviService.navigateToAuthorProfilePage(
                  comment.user?.username ?? '',
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildUserAvatar(comment),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: buildUserName(
                                  context,
                                  comment.user!,
                                  fontSize: 14,
                                  bold: true,
                                ),
                              ),
                              // 显示楼号（只有顶级评论显示）
                              if (widget.comment.parent == null &&
                                  comment.floorNumber != null)
                                Text(
                                  '#${comment.floorNumber}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (comment.user?.id ==
                                    _userService.currentUser.value?.id)
                                  _buildCommentTag(
                                    t.common.me,
                                    Colors.blue,
                                    Icons.person,
                                  ),
                                if (comment.user?.premium == true)
                                  _buildCommentTag(
                                    t.common.premium,
                                    Colors.purple,
                                    Icons.star,
                                  ),
                                if (comment.user?.id == widget.authorUserId)
                                  _buildCommentTag(
                                    t.common.author,
                                    Colors.green,
                                    Icons.verified_user,
                                  ),
                                if (comment.user?.role.contains('admin') ==
                                    true)
                                  _buildCommentTag(
                                    t.common.admin,
                                    Colors.red,
                                    Icons.admin_panel_settings,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '@${comment.user?.username ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: !widget.isReply && widget.comment.parent == null
                          ? _showReplyDialog
                          : null,
                      child: CustomMarkdownBody(
                        data: comment.body,
                        originalData: comment.body,
                        showTranslationButton: false,
                        translationController: _translationController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTranslationButton(context),
                      const Spacer(),
                      if (!widget.isReply && comment.parent == null)
                        IconButton(
                          onPressed: _showReplyDialog,
                          icon: const Icon(Icons.reply, size: 20),
                          visualDensity: VisualDensity.compact,
                          tooltip: t.common.reply,
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                        ),
                      _buildActionMenu(context),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _buildTimeInfo(comment, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(Comment comment) {
    return AvatarWidget(user: comment.user, size: 32);
  }
}
