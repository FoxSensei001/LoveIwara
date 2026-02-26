// ignore_for_file: unnecessary_underscores

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
  // 缓存Tag组件以避免重建
  late List<Widget> _cachedTags;
  bool _tagsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tagsInitialized) {
      // 在didChangeDependencies中安全地访问InheritedWidget
      final thumbnail = _Thumbnail(video: widget.video, width: widget.width);
      _cachedTags = thumbnail.buildTags(
        context,
        slang.Translations.of(context),
      );
      _tagsInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保tags已初始化
    if (!_tagsInitialized) {
      final thumbnail = _Thumbnail(video: widget.video, width: widget.width);
      _cachedTags = thumbnail.buildTags(
        context,
        slang.Translations.of(context),
      );
      _tagsInitialized = true;
    }

    // 多选模式下的遮罩
    final Widget? overlay = widget.isMultiSelectMode
        ? Container(
            color: widget.isSelected ? Colors.black38 : Colors.black12,
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
      child: BaseCardListItem(
        width: widget.width,
        thumbnail: _buildCachedThumbnail(),
        title: widget.video.title ?? '',
        createdAt: widget.video.createdAt,
        user: widget.video.user,
        onTap: widget.isMultiSelectMode && widget.onSelect != null
            ? widget.onSelect!
            : () => NaviService.navigateToVideoDetailPage(widget.video.id),
        onSecondaryTap: widget.isMultiSelectMode ? null : _showDetailsModal,
        onLongPress: widget.isMultiSelectMode ? null : _showDetailsModal,
        contentOverlay: overlay,
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

  Future<void> _showDetailsModal() async {
    if (!mounted) return;
    final result = await showDialog<VideoPreviewModalResult>(
      context: context,
      builder: (_) => VideoPreviewDetailModal(video: widget.video),
    );

    if (!mounted || result == null) return;

    switch (result.type) {
      case VideoPreviewModalActionType.openVideo:
        if (result.videoId?.isNotEmpty ?? false) {
          NaviService.navigateToVideoDetailPage(result.videoId!);
        }
        break;
      case VideoPreviewModalActionType.openAuthor:
        NaviService.navigateToAuthorProfilePage(result.username ?? '');
        break;
    }
  }
}

class _Thumbnail extends StatelessWidget {
  final Video video;
  final double width;
  final List<Widget>? cachedTags;

  const _Thumbnail({required this.video, required this.width, this.cachedTags});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [_buildImage(), ...(cachedTags ?? buildTags(context, t))],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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

  /// 格式化数字显示（如1.2K、1.5M等）
  String _formatNumber(int? number) {
    if (number == null || number == 0) return '0';

    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double k = number / 1000.0;
      return k >= 10 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      double m = number / 1000000.0;
      return m >= 10 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else {
      double b = number / 1000000000.0;
      return b >= 10 ? '${b.toInt()}B' : '${b.toStringAsFixed(1)}B';
    }
  }

  List<Widget> buildTags(BuildContext context, slang.Translations t) {
    const durationTagBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(6),
      bottomRight: Radius.circular(4),
    );

    List<Widget> tags = [];

    // 点赞数和播放量标签组（左上角）
    bool hasLikes = video.numLikes != null && video.numLikes! > 0;
    bool hasViews = video.numViews != null && video.numViews! > 0;

    if (hasLikes || hasViews) {
      tags.add(
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasLikes) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(video.numLikes),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (hasViews) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(video.numViews),
                          style: const TextStyle(
                            color: Colors.white,
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

    // Private标签和R18标签组（左下角）
    bool isPrivate = video.private == true;
    bool isR18 = video.rating == 'ecchi';

    if (isPrivate || isR18) {
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
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomLeft: Radius.circular(4),
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
