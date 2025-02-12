import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_preview_modal.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
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
  State<VideoCardListItemWidget> createState() => _VideoCardListItemWidgetState();
}

class _VideoCardListItemWidgetState extends State<VideoCardListItemWidget> {
  static const double _narrowScreenWidth = 600;
  static const Duration _hoverDelay = Duration(seconds: 1);
  bool _showAnimatedPreview = false;
  Timer? _hoverTimer;

  late final bool _isNarrowScreen = MediaQuery.of(context).size.width < _narrowScreenWidth;
  late final double _cardBorderRadius = _isNarrowScreen ? 6 : 8;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius)
        ),
        child: InkWell(
          onTap: _navigateToDetailPage,
          onSecondaryTap: _showDetailsModal,
          onLongPress: _showDetailsModal,
          hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
          splashColor: Theme.of(context).splashColor.withOpacity(0.2),
          highlightColor: Theme.of(context).highlightColor.withOpacity(0.1),
          child: _CardContent(
            video: widget.video,
            isNarrowScreen: _isNarrowScreen,
            textTheme: _textTheme,
            showAnimatedPreview: _showAnimatedPreview,
            onHoverStart: _handleHoverStart,
            onHoverEnd: _handleHoverEnd,
          ),
        ),
      ),
    );
  }

  void _handleHoverStart(_) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(_hoverDelay, () {
      if (mounted) setState(() => _showAnimatedPreview = true);
    });
  }

  void _handleHoverEnd(_) {
    _hoverTimer?.cancel();
    if (mounted) setState(() => _showAnimatedPreview = false);
  }

  void _navigateToDetailPage() {
    NaviService.navigateToVideoDetailPage(widget.video.id);
  }

  void _showDetailsModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => VideoPreviewDetailModal(video: widget.video),
    );
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }
}

class _CardContent extends StatelessWidget {
  final Video video;
  final bool isNarrowScreen;
  final TextTheme textTheme;
  final bool showAnimatedPreview;
  final Function(PointerEvent) onHoverStart;
  final Function(PointerEvent) onHoverEnd;

  const _CardContent({
    required this.video,
    required this.isNarrowScreen,
    required this.textTheme,
    required this.showAnimatedPreview,
    required this.onHoverStart,
    required this.onHoverEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isNarrowScreen ? 16 / 12 : 220 / 160,
          child: _Thumbnail(
            video: video,
            showAnimatedPreview: showAnimatedPreview,
            onHoverStart: onHoverStart,
            onHoverEnd: onHoverEnd,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isNarrowScreen ? 6.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                title: video.title ?? '',
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
              _TimeInfo(
                createdAt: video.createdAt,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
              SizedBox(height: isNarrowScreen ? 4 : 8),
              _AuthorInfo(
                user: video.user,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VideoTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Color? textColor;

  const _VideoTag({
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.borderRadius,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(color: backgroundColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10, color: textColor),
              const SizedBox(width: 2),
            ],
            Text(
              text,
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
    );
  }
}

class _Thumbnail extends StatelessWidget {
  static const _tagBorderRadius = BorderRadius.only(
    topRight: Radius.circular(8),
    bottomLeft: Radius.circular(6),
  );

  static const _privateTagBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(6),
    bottomRight: Radius.circular(8),
  );

  static const _durationTagBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(8),
    bottomRight: Radius.circular(6),
  );

  final Video video;
  final bool showAnimatedPreview;
  final Function(PointerEvent) onHoverStart;
  final Function(PointerEvent) onHoverEnd;

  const _Thumbnail({
    required this.video,
    required this.showAnimatedPreview,
    required this.onHoverStart,
    required this.onHoverEnd,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: onHoverStart,
      onExit: onHoverEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(),
          ...buildTags(context),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: showAnimatedPreview
          ? _buildPreviewImage()
          : _buildThumbnailImage(),
    );
  }

  Widget _buildPreviewImage() {
    return CachedNetworkImage(
      imageUrl: video.previewUrl,
      fit: BoxFit.cover,
      placeholder: _buildPlaceholder,
      errorWidget: _buildErrorWidget,
    );
  }

  Widget _buildThumbnailImage() {
    return CachedNetworkImage(
      imageUrl: video.thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: _buildPlaceholder,
      errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    return Container(color: Colors.grey[300]);
  }

  Widget _buildErrorWidget(BuildContext context, String url, dynamic error) {
    if (video.file?.numThumbnails != null && video.file!.numThumbnails! > 0) {
      return AnimatedPreview(
        videoId: video.file!.id,
        numThumbnails: video.file!.numThumbnails!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600]),
    );
  }

  List<Widget> buildTags(BuildContext context) {
    final t = slang.Translations.of(context);
    return [
      if (video.rating == 'ecchi')
        Positioned(
          left: 0,
          bottom: 0,
          child: _VideoTag(
            text: 'R18',
            backgroundColor: Colors.red,
            borderRadius: _tagBorderRadius,
            textColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      if (video.private == true)
        Positioned(
          left: 0,
          top: 0,
          child: _VideoTag(
            text: t.common.private,
            icon: Icons.lock,
            backgroundColor: Colors.black54,
            borderRadius: _privateTagBorderRadius,
            textColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      if (video.minutesDuration != null)
        Positioned(
          right: 0,
          bottom: 0,
          child: _VideoTag(
            text: video.minutesDuration!,
            icon: Icons.access_time,
            backgroundColor: Colors.black54,
            borderRadius: _durationTagBorderRadius,
          ),
        ),
      if (video.isExternalVideo)
        Positioned(
          right: 0,
          bottom: 0,
          child: _VideoTag(
            text: t.common.externalVideo,
            icon: Icons.link,
            backgroundColor: Colors.black54,
            borderRadius: _durationTagBorderRadius,
          ),
        ),
    ];
  }
}

class _Title extends StatelessWidget {
  final String title;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _Title({
    required this.title,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: textTheme.bodyLarge!.fontSize! * 3.0,
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isNarrowScreen 
              ? textTheme.bodyLarge!.fontSize! * 0.9
              : textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final DateTime? createdAt;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _TimeInfo({
    required this.createdAt,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CommonUtils.formatFriendlyTimestamp(createdAt),
      style: textTheme.bodySmall?.copyWith(
        fontSize: isNarrowScreen ? 11 : textTheme.bodySmall?.fontSize,
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final User? user;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _AuthorInfo({
    required this.user,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NaviService.navigateToAuthorProfilePage(
          user?.username ?? ''),
      child: Row(
        children: [
          _buildAvatar(isNarrowScreen),
          const SizedBox(width: 4),
          Expanded(
            child: buildUserName(context, user, bold: true, fontSize: isNarrowScreen ? 12 : 14)
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isNarrowScreen) {
    return AvatarWidget(
      user: user,
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      radius: isNarrowScreen ? 12 : 14,
    );
  }
}
