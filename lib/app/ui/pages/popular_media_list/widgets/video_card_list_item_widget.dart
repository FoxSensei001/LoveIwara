import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_preview_modal.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';

import '../../../../../common/constants.dart';
import '../../../../models/video.model.dart';
import 'animated_preview_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class VideoCardListItemWidget extends StatefulWidget {
  final Video video;
  final double width;

  const VideoCardListItemWidget({
    super.key,
    required this.video,
    required this.width,
  });

  @override
  State<VideoCardListItemWidget> createState() =>
      _VideoCardListItemWidgetState();
}

class _VideoCardListItemWidgetState extends State<VideoCardListItemWidget> {
  bool _showAnimatedPreview = false;
  Timer? _hoverTimer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: widget.width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () => _navigateToDetailPage(context),
          onSecondaryTap: () => _showDetailsModal(context),
          onLongPress: () => _showDetailsModal(context),
          hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
          splashColor: Theme.of(context).splashColor.withOpacity(0.2),
          highlightColor: Theme.of(context).highlightColor.withOpacity(0.1),
          child: _buildCardContent(textTheme, context),
        ),
      ),
    );
  }

  Widget _buildCardContent(TextTheme textTheme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 220 / 160,
          child: _buildThumbnail(context),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(textTheme),
              _buildTimeInfo(textTheme),
              const SizedBox(height: 8),
              _buildAuthorInfo(textTheme, context),
            ],
          ),
        ),
      ],
    );
  }

  // 视频缩略图
  Widget _buildThumbnail(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _hoverTimer?.cancel();
        _hoverTimer = Timer(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showAnimatedPreview = true;
            });
          }
        });
      },
      onExit: (_) {
        _hoverTimer?.cancel();
        if (mounted) {
          setState(() {
            _showAnimatedPreview = false;
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _showAnimatedPreview
                ? CachedNetworkImage(
                    imageUrl: widget.video.previewUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) {
                      if (widget.video.file?.numThumbnails != null &&
                          widget.video.file!.numThumbnails! > 0) {
                        return AnimatedPreview(
                          videoId: widget.video.file!.id,
                          numThumbnails: widget.video.file!.numThumbnails!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey[600]));
                      }
                    },
                  )
                : CachedNetworkImage(
                    imageUrl: widget.video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            size: 40, color: Colors.grey[600])),
                  ),
          ),
          if (widget.video.rating == 'ecchi')
            Positioned(
              left: 0,
              bottom: 0,
              child: _buildRatingTag(context),
            ),
          if (widget.video.private == true)
            Positioned(
              left: 0,
              top: 0,
              child: _buildPrivateTag(context),
            ),
          if (widget.video.minutesDuration != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildDurationTag(context),
            ),
          if (widget.video.isExternalVideo)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildExternalVideoTag(context),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() => Container(color: Colors.grey[300]);

  Widget _buildRatingTag(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(14),
        bottomLeft: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: Text(
          'R18',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivateTag(BuildContext context) {
    final t = slang.Translations.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.black54,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              t.common.private,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationTag(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.black54,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              widget.video.minutesDuration!,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalVideoTag(BuildContext context) {
    final t = slang.Translations.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.black54,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.link,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              t.common.externalVideo,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(TextTheme textTheme) {
    return SizedBox(
      height: textTheme.bodyLarge!.fontSize! * 3.5,
      child: Text(
        widget.video.title ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(TextTheme textTheme) {
    return Text(
      CommonUtils.formatFriendlyTimestamp(widget.video.createdAt),
      style: textTheme.bodySmall,
    );
  }

  Widget _buildAuthorInfo(TextTheme textTheme, BuildContext context) {
    final t = slang.Translations.of(context);
    return GestureDetector(
      onTap: () => NaviService.navigateToAuthorProfilePage(
          widget.video.user?.username ?? ''),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Expanded(
            child: widget.video.user?.premium == true
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.purple.shade300,
                        Colors.blue.shade300,
                        Colors.pink.shade300,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      widget.video.user?.name ?? t.common.unknownUser,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    widget.video.user?.name ?? t.common.unknownUser,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return AvatarWidget(
      avatarUrl: widget.video.user?.avatar?.avatarUrl,
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      headers: const {'referer': CommonConstants.iwaraBaseUrl},
      radius: 14,
      isPremium: widget.video.user?.premium ?? false,
      isAdmin: widget.video.user?.isAdmin ?? false,
    );
  }

  void _navigateToDetailPage(BuildContext context) {
    NaviService.navigateToVideoDetailPage(widget.video.id);
  }

  void _showDetailsModal(BuildContext context) async {

    if (context.mounted) {
      // 显示预览模态框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return VideoPreviewDetailModal(video: widget.video);
        },
      );
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }
}
