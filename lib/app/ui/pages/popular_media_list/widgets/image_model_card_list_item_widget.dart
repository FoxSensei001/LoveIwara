// ignore_for_file: unnecessary_underscores

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart';

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
  // 缓存标签组件
  late List<Widget> _cachedTags;
  bool _tagsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tagsInitialized) {
      final thumbnail = _Thumbnail(
        imageModel: widget.imageModel,
        width: widget.width,
      );
      _cachedTags = thumbnail.buildTags(context);
      _tagsInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保标签已初始化
    if (!_tagsInitialized) {
      final thumbnail = _Thumbnail(
        imageModel: widget.imageModel,
        width: widget.width,
      );
      _cachedTags = thumbnail.buildTags(context);
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
        title: widget.imageModel.title,
        createdAt: widget.imageModel.createdAt,
        user: widget.imageModel.user,
        onTap: widget.isMultiSelectMode && widget.onSelect != null
            ? widget.onSelect!
            : () =>
                  NaviService.navigateToGalleryDetailPage(widget.imageModel.id),
        contentOverlay: overlay,
      ),
    );
  }

  Widget _buildCachedThumbnail() {
    return _Thumbnail(
      imageModel: widget.imageModel,
      width: widget.width,
      cachedTags: _cachedTags,
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final ImageModel imageModel;
  final double width;
  final List<Widget>? cachedTags;

  const _Thumbnail({
    required this.imageModel,
    required this.width,
    this.cachedTags,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [_buildImage(), ...(cachedTags ?? buildTags(context))],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _buildOptimizedImage(),
    );
  }

  Widget _buildOptimizedImage() {
    return CachedNetworkImage(
      imageUrl: imageModel.thumbnailUrl,
      fit: BoxFit.cover,
      memCacheWidth: (width * 1.5).toInt(),
      fadeInDuration: const Duration(milliseconds: 50),
      placeholderFadeInDuration: const Duration(milliseconds: 0),
      fadeOutDuration: const Duration(milliseconds: 0),
      maxWidthDiskCache: 400,
      maxHeightDiskCache: 400,
      placeholder: _buildPlaceholder,
      errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
    );
  }

  // 使用更高效的占位符
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

  List<Widget> buildTags(BuildContext context) {
    return [
      if (imageModel.rating == 'ecchi')
        Positioned(left: 0, bottom: 0, child: _buildRatingTag(context)),
      Positioned(
        right: 0,
        top: 0,
        child: _ImageTag(
          text: '${imageModel.numImages}',
          icon: Icons.image,
          borderRadius: BaseTagBorderRadius.imageNumTagBorderRadius,
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: _ImageTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numViews),
          icon: Icons.remove_red_eye,
          borderRadius: BaseTagBorderRadius.viewTagBorderRadius,
        ),
      ),
      Positioned(
        left: 0,
        top: 0,
        child: _ImageTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numLikes),
          icon: Icons.favorite,
          borderRadius: BaseTagBorderRadius.likeTagBorderRadius,
        ),
      ),
    ];
  }

  Widget _buildRatingTag(BuildContext context) {
    return ClipRRect(
      borderRadius: BaseTagBorderRadius.tagBorderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        color: Colors.red,
        child: Text(
          'R18',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _ImageTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final BorderRadius borderRadius;

  const _ImageTag({
    required this.text,
    required this.icon,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: const BoxDecoration(color: Colors.black54),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: Colors.white),
            const SizedBox(width: 2),
            Text(
              text,
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
    );
  }
}
