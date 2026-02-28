import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart'
    show BaseTag;
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

String _galleryCoverHeroTag(String imageModelId) =>
    'gallery_cover:$imageModelId';

String _galleryCardHeroTag(String imageModelId) => 'gallery_card:$imageModelId';

String _galleryTitleHeroTag(String imageModelId) =>
    'gallery_title:$imageModelId';

String _galleryAuthorAvatarHeroTag(String imageModelId) =>
    'gallery_author_avatar:$imageModelId';

String _galleryAuthorNameHeroTag(String imageModelId) =>
    'gallery_author_name:$imageModelId';

RectTween _createGalleryCoverRectTween(Rect? begin, Rect? end) {
  return MaterialRectArcTween(begin: begin, end: end);
}

Widget _galleryCoverFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final fromHero = fromHeroContext.widget as Hero;
  final toHero = toHeroContext.widget as Hero;
  return flightDirection == HeroFlightDirection.push
      ? fromHero.child
      : toHero.child;
}

class ImageModelCardListItemWidget extends StatefulWidget {
  final ImageModel imageModel;
  final double width;

  /// 是否处于多选模式
  final bool isMultiSelectMode;

  /// 是否被选中（多选模式下使用）
  final bool isSelected;

  /// 选中状态变化回调
  final VoidCallback? onSelect;

  const ImageModelCardListItemWidget({
    super.key,
    required this.imageModel,
    required this.width,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<ImageModelCardListItemWidget> createState() =>
      _ImageModelCardListItemWidgetState();
}

class _ImageModelCardListItemWidgetState
    extends State<ImageModelCardListItemWidget> {
  bool _isHovering = false;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final bool enableHover = !widget.isMultiSelectMode && _isDesktopPlatform();
    final bool showHoverState = enableHover && _isHovering;

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
                    child: Hero(
                      tag: _galleryCardHeroTag(widget.imageModel.id),
                      transitionOnUserGestures: true,
                      placeholderBuilder: (context, size, child) {
                        return Material(
                          color: Colors.transparent,
                          borderRadius: radius,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: radius,
                            ),
                          ),
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: radius,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: radius,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(
                                    alpha: showHoverState ? 0.6 : 0.3,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: radius,
                    onTap: widget.isMultiSelectMode && widget.onSelect != null
                        ? widget.onSelect!
                        : () => NaviService.navigateToGalleryDetailPage(
                            widget.imageModel.id,
                            coverUrl: widget.imageModel.thumbnailUrl,
                            title: widget.imageModel.title,
                            imageCount: widget.imageModel.numImages,
                            authorName: widget.imageModel.user?.name,
                            authorUsername: widget.imageModel.user?.username,
                            authorAvatarUrl:
                                widget.imageModel.user?.avatar?.avatarUrl,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Thumbnail(
                          imageModel: widget.imageModel,
                          width: widget.width,
                          isHovering: showHoverState,
                          overlay: overlay,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: _galleryTitleHeroTag(widget.imageModel.id),
                                transitionOnUserGestures: true,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    widget.imageModel.title.isEmpty
                                        ? slang.t.common.noTitle
                                        : widget.imageModel.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          height: 1.22,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _MetaLine(imageModel: widget.imageModel),
                              const SizedBox(height: 8),
                              _AuthorLine(
                                imageModel: widget.imageModel,
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
}

class _Thumbnail extends StatelessWidget {
  final ImageModel imageModel;
  final double width;
  final bool isHovering;
  final Widget? overlay;

  const _Thumbnail({
    required this.imageModel,
    required this.width,
    required this.isHovering,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(top: Radius.circular(14));
    return Hero(
      tag: _galleryCoverHeroTag(imageModel.id),
      createRectTween: _createGalleryCoverRectTween,
      flightShuttleBuilder: _galleryCoverFlightShuttleBuilder,
      transitionOnUserGestures: true,
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageModel.thumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: (width * 1.5).toInt(),
                fadeInDuration: const Duration(milliseconds: 50),
                placeholderFadeInDuration: const Duration(milliseconds: 0),
                fadeOutDuration: const Duration(milliseconds: 0),
                maxWidthDiskCache: 400,
                maxHeightDiskCache: 400,
                placeholder: _buildPlaceholder,
                errorWidget: (context, url, error) => _buildErrorPlaceholder(),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.52, 1],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              ..._buildTags(context),
              if (overlay != null) Positioned.fill(child: overlay!),
            ],
          ),
        ),
      ),
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

  List<Widget> _buildTags(BuildContext context) {
    final List<Widget> tags = [];
    tags.add(
      Positioned(
        right: 0,
        bottom: 0,
        child: BaseTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numImages),
          icon: Icons.image,
          backgroundColor: Colors.black54,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomRight: Radius.circular(4),
          ),
        ),
      ),
    );

    if (imageModel.rating == 'ecchi') {
      tags.add(
        Positioned(
          left: 0,
          bottom: 0,
          child: BaseTag(
            text: 'R18',
            backgroundColor: Colors.red,
            textColor: Theme.of(context).colorScheme.onSecondary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomLeft: Radius.zero,
            ),
          ),
        ),
      );
    }

    return tags;
  }
}

class _MetaLine extends StatelessWidget {
  final ImageModel imageModel;

  const _MetaLine({required this.imageModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 210;
        final chipTextMaxWidth = ((constraints.maxWidth - 55) / 2).clamp(
          24.0,
          56.0,
        );

        return Wrap(
          spacing: compact ? 5 : 6,
          runSpacing: 5,
          children: [
            _StatChip(
              icon: Icons.visibility,
              value: CommonUtils.formatFriendlyNumber(imageModel.numViews),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: chipTextMaxWidth,
            ),
            _StatChip(
              icon: Icons.favorite,
              value: CommonUtils.formatFriendlyNumber(imageModel.numLikes),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: chipTextMaxWidth,
            ),
            if (!compact && imageModel.numComments > 0)
              _StatChip(
                icon: Icons.forum,
                value: CommonUtils.formatFriendlyNumber(imageModel.numComments),
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
  final ImageModel imageModel;
  final bool isMultiSelectMode;

  const _AuthorLine({
    required this.imageModel,
    required this.isMultiSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAtText = CommonUtils.formatFriendlyTimestamp(
      imageModel.createdAt,
    );
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
    final user = imageModel.user;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isMultiSelectMode
          ? null
          : () {
              final username = user?.username;
              if (username != null && username.isNotEmpty) {
                NaviService.navigateToAuthorProfilePage(username);
              }
            },
      child: Row(
        children: [
          Hero(
            tag: _galleryAuthorAvatarHeroTag(imageModel.id),
            transitionOnUserGestures: true,
            child: AvatarWidget(user: user, size: 22),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Hero(
              tag: _galleryAuthorNameHeroTag(imageModel.id),
              transitionOnUserGestures: true,
              child: Material(
                type: MaterialType.transparency,
                child: buildUserName(context, user, bold: true, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
