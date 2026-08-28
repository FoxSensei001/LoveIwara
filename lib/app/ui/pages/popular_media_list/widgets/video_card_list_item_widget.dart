import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_slot.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_state.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/content_block_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/blocked_media_card_placeholder.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart'
    show BaseTag;
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

import '../../../../models/video.model.dart';

class VideoCardListItemWidget extends StatefulWidget {
  final Video video;
  final double width;

  /// 是否处于多选模式
  final bool isMultiSelectMode;

  /// 是否被选中（多选模式下使用）
  final bool isSelected;

  /// 选中状态变化回调
  final VoidCallback? onSelect;
  final Future<void> Function({
    required String videoId,
    Map<String, dynamic>? extData,
  })?
  onOpenVideo;

  /// 是否禁用内容屏蔽（如作者本人主页内不屏蔽其内容）。
  final bool disableBlock;

  const VideoCardListItemWidget({
    super.key,
    required this.video,
    required this.width,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onSelect,
    this.onOpenVideo,
    this.disableBlock = false,
  });

  @override
  State<VideoCardListItemWidget> createState() =>
      _VideoCardListItemWidgetState();
}

class _VideoCardListItemWidgetState extends State<VideoCardListItemWidget>
    with MediaCardActionState<VideoCardListItemWidget> {
  static const double _titleFontSize = 14;
  static const double _titleLineHeight = 1.22;
  static const double _titleHeight = _titleFontSize * _titleLineHeight * 2;

  bool _isHovering = false;
  bool _revealed = false;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);

  @override
  Video get actionVideo => widget.video;
  @override
  String get actionMediaId => widget.video.id;
  @override
  bool get baseLiked => widget.video.liked == true;
  @override
  int get baseLikeCount => widget.video.numLikes ?? 0;

  String get _displayTitle {
    final title = widget.video.title?.trim();
    if (title == null || title.isEmpty) {
      return slang.t.common.noTitle;
    }
    return title;
  }

  Map<String, dynamic> _buildVideoDetailExtData() {
    final user = widget.video.user;
    return {
      'thumbnailUrl': widget.video.thumbnailUrl,
      'title': widget.video.title,
      'authorId': user?.id,
      'authorName': user?.name,
      'authorUsername': user?.username,
      'authorAvatarUrl': user?.avatar?.avatarUrl,
      'authorRole': user?.role,
      'authorPremium': user?.premium,
    };
  }

  Future<void> _openVideoDetail(
    String videoId, {
    Map<String, dynamic>? extData,
  }) async {
    if (widget.onOpenVideo != null) {
      await widget.onOpenVideo!(videoId: videoId, extData: extData);
    } else {
      await NaviService.navigateToVideoDetailPage(videoId, extData: extData);
    }
    if (!mounted) return;
    applyLikePatchFromExtData(extData);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disableBlock ||
        widget.isMultiSelectMode ||
        !Get.isRegistered<ContentBlockService>()) {
      return _buildCard(context);
    }
    return Obx(() {
      final match = Get.find<ContentBlockService>().check(
        title: widget.video.title,
        authorId: widget.video.user?.id,
      );
      final blocked = match != null && !_revealed;
      // 真实卡片与磨砂遮罩同时常驻，遮罩以淡入淡出 + 缩放过渡显隐，
      // 保证与普通卡片完全等高，同时避免揭示/重新屏蔽时的瞬间硬切。
      return Stack(
        children: [
          IgnorePointer(
            ignoring: blocked,
            child: _buildCard(context, showReblock: match != null && !blocked),
          ),
          Positioned.fill(
            child: BlockedMediaOverlayFade(
              match: match,
              visible: blocked,
              onReveal: () => setState(() => _revealed = true),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCard(BuildContext context, {bool showReblock = false}) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: _titleFontSize,
      fontWeight: FontWeight.w700,
      height: _titleLineHeight,
    );
    final bool enableHover = !widget.isMultiSelectMode && _isDesktopPlatform();
    final bool showHoverState = enableHover && _isHovering;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        child: MouseRegion(
          onEnter: enableHover
              ? (_) => setState(() => _isHovering = true)
              : null,
          onExit: enableHover
              ? (_) => setState(() => _isHovering = false)
              : null,
          child: AnimatedContainer(
            duration: _hoverAnimationDuration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(
                    alpha: showHoverState ? 0.2 : 0.08,
                  ),
                  blurRadius: showHoverState ? 18 : 8,
                  offset: Offset(0, showHoverState ? 8 : 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: radius,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: radius,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: showHoverState ? 0.6 : 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: radius,
                    onTap: widget.isMultiSelectMode && widget.onSelect != null
                        ? widget.onSelect!
                        : () => _openVideoDetail(
                            widget.video.id,
                            extData: _buildVideoDetailExtData(),
                          ),
                    // 长按 / 右键 / 三点钮 → 同一只媒体操作菜单。
                    // 原来这两条指向的是只能看不能动手的预览弹窗，已整只移除。
                    onSecondaryTap: widget.isMultiSelectMode
                        ? null
                        : openActionMenu,
                    onLongPress: widget.isMultiSelectMode
                        ? null
                        : openActionMenu,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Thumbnail(
                          video: widget.video,
                          width: widget.width,
                          isHovering: showHoverState,
                          reblockVisible: showReblock,
                          onReblock: () => setState(() => _revealed = false),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: _titleHeight,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _displayTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    strutStyle: const StrutStyle(
                                      fontSize: _titleFontSize,
                                      height: _titleLineHeight,
                                      forceStrutHeight: true,
                                    ),
                                    style: titleStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              VideoCardMetaLine(
                                video: widget.video,
                                isLiked: effectiveLiked,
                                likeCount: effectiveLikeCount,
                              ),
                              const SizedBox(height: 8),
                              _AuthorLine(
                                video: widget.video,
                                isMultiSelectMode: widget.isMultiSelectMode,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 三点钮：压在整张卡片的右下角（B站同款位置）。
                  MediaCardActionSlot(
                    video: widget.video,
                    isMultiSelectMode: widget.isMultiSelectMode,
                    likedOverride: effectiveLiked,
                    onLikeChanged: applyLikeToggle,
                    busy: menuBusy,
                    duration: _hoverAnimationDuration,
                  ),
                  // 多选态：勾选片 + 描边包住**整张卡片**（含标题与作者行），
                  // 而不是只框住缩略图——框到一半读起来像被裁断了。常驻挂载，
                  // 进出选择态两个方向都有淡入淡出。
                  Positioned.fill(
                    child: GlassSelectableOverlay(
                      selectionMode: widget.isMultiSelectMode,
                      selected: widget.isSelected,
                      borderRadius: radius,
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

  bool _isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }
}

class _Thumbnail extends StatelessWidget {
  final Video video;
  final double width;

  final bool isHovering;
  final bool reblockVisible;
  final VoidCallback onReblock;

  const _Thumbnail({
    required this.video,
    required this.width,
    required this.isHovering,
    required this.reblockVisible,
    required this.onReblock,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    const radius = BorderRadius.vertical(top: Radius.circular(14));

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            ...buildTags(context, t),
            ReblockChip(visible: reblockVisible, onTap: onReblock),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return _buildThumbnailImage();
  }

  Widget _buildThumbnailImage() {
    return CachedNetworkImage(
      imageUrl: video.thumbnailUrl,
      fit: BoxFit.cover,
      memCacheWidth: (width * 1.5).toInt(),
      fadeInDuration: const Duration(milliseconds: 50),
      placeholderFadeInDuration: const Duration(milliseconds: 0),
      placeholder: _buildPlaceholder,
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      maxWidthDiskCache: 400,
      maxHeightDiskCache: 400,
      fadeOutDuration: const Duration(milliseconds: 0),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    return const SizedBox.expand(
      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE0E0E0))),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 32,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  List<Widget> buildTags(BuildContext context, slang.Translations t) {
    const durationTagBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(6),
      bottomRight: Radius.circular(4),
    );

    List<Widget> tags = [];

    // Private标签和R18标签组（左下角）
    bool isPrivate = video.private == true;
    bool isR18 = video.rating == 'ecchi';

    if (isPrivate || isR18) {
      final bottomLeftRadius = isR18 ? Radius.zero : const Radius.circular(4);
      // 如果有R18或private，整个标签组使用红色背景
      Color backgroundColor = (isR18 || isPrivate)
          ? Colors.red
          : Colors.black54;
      Color textColor = (isR18 || isPrivate)
          ? Theme.of(context).colorScheme.onSecondary
          : Colors.white;

      tags.add(
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(6),
                bottomLeft: bottomLeftRadius,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isR18) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    child: Text(
                      'R18',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
                if (isPrivate) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 10, color: textColor),
                        const SizedBox(width: 2),
                        Text(
                          t.common.private,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // 时长或外链标签（右下角）
    if (video.isExternalVideo) {
      tags.add(
        Positioned(
          right: 0,
          bottom: 0,
          child: BaseTag(
            text: t.common.externalVideo,
            icon: Icons.link,
            backgroundColor: Colors.black54,
            borderRadius: durationTagBorderRadius,
          ),
        ),
      );
    } else if (video.minutesDuration != null) {
      tags.add(
        Positioned(
          right: 0,
          bottom: 0,
          child: BaseTag(
            text: video.minutesDuration!,
            icon: Icons.access_time,
            backgroundColor: Colors.black54,
            borderRadius: durationTagBorderRadius,
          ),
        ),
      );
    }

    return tags;
  }
}

class VideoCardMetaLine extends StatelessWidget {
  final Video video;
  final bool? isLiked;
  final int? likeCount;

  const VideoCardMetaLine({
    super.key,
    required this.video,
    this.isLiked,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIsLiked = isLiked ?? (video.liked == true);
    final resolvedLikeCount = likeCount ?? (video.numLikes ?? 0);
    return _buildMetaLine(
      context,
      isLiked: resolvedIsLiked,
      likeCount: resolvedLikeCount < 0 ? 0 : resolvedLikeCount,
    );
  }

  Widget _buildMetaLine(
    BuildContext context, {
    required bool isLiked,
    required int likeCount,
  }) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 210;
        final chipTextMaxWidth = ((constraints.maxWidth - 55) / 2).clamp(
          24.0,
          56.0,
        );
        final IconData likeIcon = isLiked
            ? Icons.favorite
            : Icons.favorite_border;
        final Color likeColor = isLiked
            ? Colors.pink
            : theme.colorScheme.onSurfaceVariant;

        return Wrap(
          spacing: compact ? 5 : 6,
          runSpacing: 5,
          children: [
            _StatChip(
              icon: Icons.visibility,
              value: CommonUtils.formatFriendlyNumber(video.numViews ?? 0),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: chipTextMaxWidth,
            ),
            _StatChip(
              icon: likeIcon,
              value: CommonUtils.formatFriendlyNumber(likeCount),
              color: likeColor,
              maxTextWidth: chipTextMaxWidth,
            ),
            if (!compact && (video.numComments ?? 0) > 0)
              _StatChip(
                icon: Icons.forum,
                value: CommonUtils.formatFriendlyNumber(video.numComments ?? 0),
                color: theme.colorScheme.onSurfaceVariant,
                maxTextWidth: chipTextMaxWidth,
              ),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final double maxTextWidth;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.maxTextWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxTextWidth + 24),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 2),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxTextWidth),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorLine extends StatelessWidget {
  final Video video;
  final bool isMultiSelectMode;

  const _AuthorLine({required this.video, required this.isMultiSelectMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAtText = CommonUtils.formatFriendlyTimestamp(video.createdAt);
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 11,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 210;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAuthorName(context),
              const SizedBox(height: 4),
              Text(
                createdAtText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: timeStyle,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildAuthorName(context)),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  createdAtText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: timeStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthorName(BuildContext context) {
    final user = video.user;
    final avatar = AvatarWidget(user: user, size: 22);
    final name = buildUserName(context, user, bold: true, fontSize: 12.5);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isMultiSelectMode
          ? null
          : () {
              final username = user?.username;
              if (username != null && username.isNotEmpty) {
                NaviService.navigateToAuthorProfilePage(
                  username,
                  initialUser: user,
                );
              }
            },
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 6),
          Expanded(child: name),
        ],
      ),
    );
  }
}
