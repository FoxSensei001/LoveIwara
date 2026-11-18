import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// Cached thumbnail or avatar for a lazily built list item. A loaded image
/// paints directly: the crossfade used by CachedNetworkImage can keep an
/// OpacityLayer (and promote ancestor clips to layers) after the fade settles.
class CachedListImage extends StatelessWidget {
  const CachedListImage({
    super.key,
    required this.imageUrl,
    this.httpHeaders,
    this.fit = BoxFit.cover,
    this.width,
    this.memCacheWidth,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    required this.placeholder,
    required this.errorWidget,
  });

  final String imageUrl;
  final Map<String, String>? httpHeaders;
  final BoxFit fit;
  final double? width;
  final int? memCacheWidth;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final Widget Function(BuildContext context, String url) placeholder;
  final Widget Function(BuildContext context, String url, Object error)
  errorWidget;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: ResizeImage.resizeIfNeeded(
        memCacheWidth,
        null,
        CachedNetworkImageProvider(
          imageUrl,
          headers: httpHeaders,
          maxWidth: maxWidthDiskCache,
          maxHeight: maxHeightDiskCache,
        ),
      ),
      width: width,
      fit: fit,
      filterQuality: FilterQuality.low,
      frameBuilder: (context, child, frame, loadedSynchronously) =>
          frame == null ? placeholder(context, imageUrl) : child,
      errorBuilder: (context, error, _) =>
          errorWidget(context, imageUrl, error),
    );
  }
}
