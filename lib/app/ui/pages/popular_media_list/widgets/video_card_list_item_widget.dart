import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_preview_modal.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../../../models/video.model.dart';

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
  @override
  Widget build(BuildContext context) {
    return BaseCardListItem(
      width: widget.width,
      thumbnail: _Thumbnail(video: widget.video),
      title: widget.video.title ?? '',
      createdAt: widget.video.createdAt,
      user: widget.video.user,
      onTap: () => NaviService.navigateToVideoDetailPage(widget.video.id),
      onSecondaryTap: _showDetailsModal,
      onLongPress: _showDetailsModal,
    );
  }

  void _showDetailsModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => VideoPreviewDetailModal(video: widget.video),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Video video;

  const _Thumbnail({required this.video});

  @override
  Widget build(BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < BaseCardListItem.narrowScreenWidth;
    final t = slang.Translations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(isNarrowScreen),
        ...buildTags(context, t),
      ],
    );
  }

  Widget _buildImage(bool isNarrowScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isNarrowScreen ? 6 : 8),
      child: _buildThumbnailImage(),
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

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600]),
    );
  }

  List<Widget> buildTags(BuildContext context, slang.Translations t) {
    const tagBorderRadius = BorderRadius.only(
      topRight: Radius.circular(6),
      bottomLeft: Radius.circular(4),
    );
    const privateTagBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(4),
      bottomRight: Radius.circular(6),
    );
    const durationTagBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(6),
      bottomRight: Radius.circular(4),
    );

    return [
      if (video.rating == 'ecchi')
        Positioned(
          left: 0,
          bottom: 0,
          child: BaseTag(
            text: 'R18',
            backgroundColor: Colors.red,
            borderRadius: tagBorderRadius,
            textColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      if (video.private == true)
        Positioned(
          left: 0,
          top: 0,
          child: BaseTag(
            text: t.common.private,
            icon: Icons.lock,
            backgroundColor: Colors.black54,
            borderRadius: privateTagBorderRadius,
            textColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      if (video.minutesDuration != null)
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
      if (video.isExternalVideo)
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
    ];
  }
}
