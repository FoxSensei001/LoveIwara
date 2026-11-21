import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// Cached thumbnail or avatar for a lazily built list item. A loaded image
/// paints directly: the crossfade used by CachedNetworkImage can keep an
/// OpacityLayer (and promote ancestor clips to layers) after the fade settles.
///
/// ⛔ 没有「磁盘缓存缩图」（`maxWidth` / `maxHeight`）这个口子，别加回来。
/// 那条路在 flutter_cache_manager 里是：下载原图存一份 → 解码 → 再按目标尺寸
/// 解码一次 → **重新编码成 PNG** 另存一份（键是 `resized_w…_h…_<url>`）。
/// 2026-11-21 Mac 实测：头像原图 JPEG 约 15 KB，另存的 200×200 PNG 约 60 KB；
/// 每张图在缓存库里占两条，默认 200 条的上限只装得下约 100 张图。缩略图本身
/// 只有 220×160，从来不会被缩，却每次加载都白解码一遍原图来判断要不要缩。
/// 解码尺寸只靠 [memCacheWidth]（解码时缩，省内存，画面一样）。
class CachedListImage extends StatelessWidget {
  const CachedListImage({
    super.key,
    required this.imageUrl,
    this.httpHeaders,
    this.fit = BoxFit.cover,
    this.width,
    this.memCacheWidth,
    required this.placeholder,
    required this.errorWidget,
  });

  final String imageUrl;
  final Map<String, String>? httpHeaders;
  final BoxFit fit;
  final double? width;
  final int? memCacheWidth;
  final Widget Function(BuildContext context, String url) placeholder;
  final Widget Function(BuildContext context, String url, Object error)
  errorWidget;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: ResizeImage.resizeIfNeeded(
        memCacheWidth,
        null,
        CachedNetworkImageProvider(imageUrl, headers: httpHeaders),
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
