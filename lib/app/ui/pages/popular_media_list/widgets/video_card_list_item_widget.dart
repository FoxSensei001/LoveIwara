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
  State<VideoCardListItemWidget> createState() =>
      _VideoCardListItemWidgetState();
}

class _VideoCardListItemWidgetState extends State<VideoCardListItemWidget> {
  // 缓存Tag组件以避免重建
  late List<Widget> _cachedTags;
  bool _tagsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tagsInitialized) {
      // 在didChangeDependencies中安全地访问InheritedWidget
      final thumbnail = _Thumbnail(video: widget.video, width: widget.width);
      _cachedTags =
          thumbnail.buildTags(context, slang.Translations.of(context));
      _tagsInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保tags已初始化
    if (!_tagsInitialized) {
      final thumbnail = _Thumbnail(video: widget.video, width: widget.width);
      _cachedTags =
          thumbnail.buildTags(context, slang.Translations.of(context));
      _tagsInitialized = true;
    }

    return RepaintBoundary(
      child: BaseCardListItem(
        width: widget.width,
        thumbnail: _buildCachedThumbnail(),
        title: widget.video.title ?? '',
        createdAt: widget.video.createdAt,
        user: widget.video.user,
        onTap: () => NaviService.navigateToVideoDetailPage(widget.video.id),
        onSecondaryTap: _showDetailsModal,
        onLongPress: _showDetailsModal,
      ),
    );
  }

  Widget _buildCachedThumbnail() {
    return _Thumbnail(
      video: widget.video,
      width: widget.width,
      cachedTags: _cachedTags,
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
  final double width;
  final List<Widget>? cachedTags;

  const _Thumbnail({
    required this.video,
    required this.width,
    this.cachedTags,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNarrowScreen =
        MediaQuery.of(context).size.width < BaseCardListItem.narrowScreenWidth;
    final t = slang.Translations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(isNarrowScreen),
        ...(cachedTags ?? buildTags(context, t)),
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
      memCacheWidth: (width * 1.5).toInt(),
      fadeInDuration: const Duration(milliseconds: 50),
      placeholderFadeInDuration: const Duration(milliseconds: 0),
      placeholder: _buildPlaceholder,
      errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
      maxWidthDiskCache: 400,
      maxHeightDiskCache: 400,
      fadeOutDuration: const Duration(milliseconds: 0),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFE0E0E0),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFE0E0E0),
        ),
        child: Center(
          child: Icon(Icons.image_not_supported,
              size: 32, color: Color(0xFF9E9E9E)),
        ),
      ),
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
