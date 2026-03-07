import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_preview_modal.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart'
    show BaseTag;
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

import '../../../../models/video.model.dart';
import 'media_like_override_utils.dart';

class VideoCardListItemWidget extends StatefulWidget {
  final Video video;
  final double width;

  /// 是否处于多选模式
  final bool isMultiSelectMode;

  /// 是否被选中（多选模式下使用）
  final bool isSelected;

  /// 选中状态变化回调
  final VoidCallback? onSelect;

  const VideoCardListItemWidget({
    super.key,
    required this.video,
    required this.width,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<VideoCardListItemWidget> createState() =>
      _VideoCardListItemWidgetState();
}

class _VideoCardListItemWidgetState extends State<VideoCardListItemWidget> {
  static const double _titleFontSize = 14;
  static const double _titleLineHeight = 1.22;
  static const double _titleHeight = _titleFontSize * _titleLineHeight * 2;

  bool _isHovering = false;
  bool? _likedOverride;
  int? _likeCountOverride;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);

  bool get _effectiveLiked => _likedOverride ?? (widget.video.liked == true);
  int get _effectiveLikeCount =>
      _likeCountOverride ?? (widget.video.numLikes ?? 0);

  String get _displayTitle {
    final title = widget.video.title?.trim();
    if (title == null || title.isEmpty) {
      return slang.t.common.noTitle;
    }
    return title;
  }

  @override
  void didUpdateWidget(covariant VideoCardListItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (shouldResetLikeOverride(
      oldId: oldWidget.video.id,
      newId: widget.video.id,
      oldLiked: oldWidget.video.liked,
      newLiked: widget.video.liked,
      oldLikeCount: oldWidget.video.numLikes,
      newLikeCount: widget.video.numLikes,
    )) {
      _likedOverride = null;
      _likeCountOverride = null;
    }
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
    await NaviService.navigateToVideoDetailPage(videoId, extData);
    if (!mounted) return;
    _applyLikePatch(extData);
  }

  void _applyLikePatch(Map<String, dynamic>? extData) {
    if (extData == null) return;
    final liked = extData[NaviService.mediaLikePatchLikedKey];
    final likeCount = extData[NaviService.mediaLikePatchCountKey];
    if (liked is! bool || likeCount is! num) return;

    final normalizedLikeCount = likeCount.toInt() < 0 ? 0 : likeCount.toInt();
    if (_effectiveLiked == liked &&
        _effectiveLikeCount == normalizedLikeCount) {
      return;
    }
    setState(() {
      _likedOverride = liked;
      _likeCountOverride = normalizedLikeCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: _titleFontSize,
      fontWeight: FontWeight.w700,
      height: _titleLineHeight,
    );
    final bool enableHover = !widget.isMultiSelectMode && _isDesktopPlatform();
    final bool showHoverState = enableHover && _isHovering;

    // 多选模式下的遮罩
    final Widget? overlay = widget.isMultiSelectMode
        ? Container(
            color: widget.isSelected
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.2),
            child: Center(
              child: Icon(
                widget.isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: widget.isSelected ? Colors.white : Colors.white70,
                size: 40,
              ),
            ),
          )
        : null;

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
                    onSecondaryTap: widget.isMultiSelectMode
                        ? null
                        : _showDetailsModal,
                    onLongPress: widget.isMultiSelectMode
                        ? null
                        : _showDetailsModal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Thumbnail(
                          video: widget.video,
                          width: widget.width,
                          isHovering: showHoverState,
                          overlay: overlay,
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
                                isLiked: _effectiveLiked,
                                likeCount: _effectiveLikeCount,
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

  Future<void> _showDetailsModal() async {
    if (!mounted) return;
    final result = await showDialog<VideoPreviewModalResult>(
      context: context,
      builder: (_) => VideoPreviewDetailModal(
        video: widget.video,
        isLiked: _effectiveLiked,
        likeCount: _effectiveLikeCount,
      ),
    );

    if (!mounted || result == null) return;

    switch (result.type) {
      case VideoPreviewModalActionType.openVideo:
        if (result.videoId?.isNotEmpty ?? false) {
          final videoId = result.videoId!;
          await _openVideoDetail(
            videoId,
            extData: videoId == widget.video.id
                ? _buildVideoDetailExtData()
                : null,
          );
        }
        break;
      case VideoPreviewModalActionType.openAuthor:
        final username = (result.username ?? '').trim();
        if (username.isNotEmpty) {
          NaviService.navigateToAuthorProfilePage(
            username,
            initialUser: widget.video.user,
          );
        }
        break;
    }
  }
}

class _Thumbnail extends StatelessWidget {
  final Video video;
  final double width;
  final bool isHovering;
  final Widget? overlay;

  const _Thumbnail({
    required this.video,
    required this.width,
    required this.isHovering,
    this.overlay,
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
            if (overlay != null) Positioned.fill(child: overlay!),
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
            if (video.isExternalVideo)
              Container(
                constraints: BoxConstraints(maxWidth: compact ? 92 : 140),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  video.externalVideoDomain.isEmpty
                      ? slang.t.common.externalVideo
                      : video.externalVideoDomain,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
