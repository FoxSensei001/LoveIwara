import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_reply_dialog.dart';
import 'package:i_iwara/app/ui/widgets/comment_actions_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 论坛楼层项：与评论区同一套「扁平线程流」语言——无卡片、头像列 + 内容列、
/// 身份小徽标（楼主 / 我）代替旧版整卡强调色，动作行是幽灵胶囊钮。
/// 角色身份（admin / officer）由 [buildUserName] 的名字着色承载。
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

  // 楼主强调色（琥珀），与主楼卡片保持一致
  static const Color _authorAccent = Color(0xFFFFB300);

  /// 动作行所有控件的统一高度：胶囊钮 / 翻译胶囊 / 更多圆钮必须一样高，
  /// 否则视觉上大小不一（语言选择器内部是默认 48 触摸目标的 IconButton，
  /// 不约束会把翻译胶囊撑高一圈）。
  static const double _actionPillHeight = 30.0;

  // 使用翻译控制器
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
            SizedBox(
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

  /// 「更多」圆钮：目前只有本人可编辑，无可选项时整钮隐藏。
  Widget _buildActionMenu(BuildContext context) {
    final t = slang.Translations.of(context);
    final isOwner =
        _userService.currentUser.value?.id == widget.comment.user.id;
    if (!isOwner) {
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
          // 菜单走全站统一的玻璃面板（原来是 PopupMenuButton）。
          child: Builder(
            builder: (anchorContext) => GlassPressable(
              // 长按也能打开，且长按不抬手可以直接划到某一条上松手选中
              // （见 GlassTapArea.opensOverlay）。
              opensOverlay: true,
              onTap: () async {
                final action = await showGlassMenu<String>(
                  anchorContext: anchorContext,
                  entries: [
                    GlassMenuOption<String>(
                      value: 'edit',
                      icon: Icons.edit,
                      label: t.common.edit,
                    ),
                  ],
                );
                if (action == 'edit') _handleEdit();
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

  /// 身份小徽标（「楼主」用琥珀强调色 /「我」用主色）。
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

  void _navigateToProfile() {
    NaviService.navigateToAuthorProfilePage(
      widget.comment.user.username,
      initialUser: widget.comment.user,
    );
  }

  void _copyUsername() {
    Clipboard.setData(ClipboardData(text: widget.comment.user.username));
    showGlassToast(
      slang.t.forum.copySuccessForMessage(str: widget.comment.user.username),
      type: GlassToastType.success,
    );
  }

  bool _ensureLoggedIn() {
    final userService = Get.find<UserService>();
    if (!userService.isAuthenticated) {
      AppService.switchGlobalDrawer();
      showGlassToast(
        slang.t.errors.pleaseLoginFirst,
        type: GlassToastType.warning,
      );
      return false;
    }
    return true;
  }

  void _handleReply() {
    if (!_ensureLoggedIn()) return;
    final replyTemplate =
        'Reply #${widget.comment.replyNum + 1}: @${widget.comment.user.username}\n---\n';
    showGlassBottomSheet(
      context: context,
      builder: (context) => ForumReplyBottomSheet(
        threadId: widget.comment.threadId,
        initialContent: replyTemplate,
        onSubmit: () {
          widget.listSourceRepository.refresh();
        },
      ),
    );
  }

  bool get _canReply => !widget.lockedThread;

  /// 长按（整行或正文文本上）弹出操作菜单：复制 / 选择复制 / 回复。
  /// [globalPosition] 是长按落点，菜单贴着它弹。
  void _showActionsMenu(Offset globalPosition) {
    showCommentActionsMenu(
      context: context,
      globalPosition: globalPosition,
      text: widget.comment.body,
      onReply: _canReply ? _handleReply : null,
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

  /// 元信息单行：@用户名 · 时间 (· xx编辑)(· 待审核)。
  /// 待审核用警示色区分，其余灰字。
  Widget _buildMetaLine(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final comment = widget.comment;
    final bool isEdited = comment.createdAt != comment.updatedAt;

    final parts = <String>[
      '@${comment.user.username}',
      CommonUtils.formatFriendlyTimestamp(comment.createdAt),
      if (isEdited)
        t.common.editedAt(
          num: CommonUtils.formatFriendlyTimestamp(comment.updatedAt),
        ),
    ];

    final baseStyle = TextStyle(
      fontSize: 12,
      height: 1.2,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
    );

    // 点按复制用户名（沿用旧版行为）
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _copyUsername,
        child: Text.rich(
          TextSpan(
            text: parts.join(' · '),
            children: [
              if (!comment.approved)
                TextSpan(
                  text: ' · ${t.forum.pendingReview}',
                  style: baseStyle.copyWith(color: colorScheme.error),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final comment = widget.comment;

    final bool isMe = _userService.currentUser.value?.id == comment.user.id;
    final bool isThreadAuthor = widget.threadAuthorId == comment.user.id;
    final bool canReply = _canReply;

    return RepaintBoundary(
      // 整条楼层区域可点：点按任意空白处直接回复（锁定帖不响应），
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
            onTap: canReply ? _handleReply : null,
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
                      onTap: _navigateToProfile,
                      child: AvatarWidget(user: comment.user, size: 36),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 内容列
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名字行：左侧「名字 + 身份徽标」为一组占满剩余宽度，
                        // 楼号固定钉在行尾
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: _navigateToProfile,
                                        child: buildUserName(
                                          context,
                                          comment.user,
                                          fontSize: 14,
                                          bold: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isThreadAuthor)
                                    _buildIdentityChip(
                                      t.common.author,
                                      _authorAccent,
                                    ),
                                  if (isMe)
                                    _buildIdentityChip(
                                      t.common.me,
                                      colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                            // 楼号弱化为灰字，钉在行尾
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                '#${comment.replyNum + 1}',
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
                        const SizedBox(height: 2),
                        _buildMetaLine(context),
                        const SizedBox(height: 8),
                        // 正文；SelectionArea 会吞掉 tap 传不到整行的 InkWell，
                        // 点按回复需经 onTap 显式透传进去
                        CustomMarkdownBody(
                          data: comment.body,
                          originalData: comment.body,
                          showTranslationButton: false,
                          translationController: _translationController,
                          padding: EdgeInsets.zero,
                          onTap: canReply ? _handleReply : null,
                          onLongPress: _showActionsMenu,
                          initialShowUnprocessedText: _showOriginal,
                          onProcessedContentChanged: (hasProcessed) {
                            if (_hasProcessedContent == hasProcessed) return;
                            setState(() => _hasProcessedContent = hasProcessed);
                          },
                        ),
                        const SizedBox(height: 4),
                        // 动作行：回复 …… 翻译 / 更多
                        Row(
                          children: [
                            if (canReply)
                              _buildGhostAction(
                                context,
                                icon: Icons.reply,
                                label: t.common.reply,
                                onTap: _handleReply,
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
