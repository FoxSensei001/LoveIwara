import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/services/gallery_video_poster.dart';

/// 本机文件模块里所有「一张本地图铺满一块区域」的封面。
///
/// ⛔ 解码尺寸只在这里算。原先目录卡 / 来源卡 / 图库卡各抄一份
/// `LayoutBuilder + Image.file + cacheWidth`，媒体卡又另写了一个
/// `(width * 2)`——写死 2 倍在 3 倍屏上糊、在 1 倍桌面上白解一倍像素。
///
/// 封面多是用户自己的原图（相机直出 6000px 很常见），不给 cacheWidth 就按原尺寸
/// 解进内存：一屏几十格，光解码缓存就能吃掉几百 MB。上限钉在 [maxCacheWidth]。
///
/// ⭐ [path] 指向**视频**时画的是它旁边那张封面（[galleryVideoPosterPath]）：
/// 视频文件本身喂给 `Image.file` 只会当场判成「坏图」。封面还没落盘、而调用方知道
/// 它的网络地址（[posterUrl]）时，这里顺手取一次存下来，之后离线也有。
/// ⛔ 不在这里解帧：无头 libmpv 在 Quest 上一帧都抓不出来，理由写在
/// [ensureGalleryVideoPoster] 上。
class LocalCoverImage extends StatefulWidget {
  const LocalCoverImage({
    super.key,
    required this.path,
    required this.placeholder,
    this.posterUrl,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  /// 解码宽度上限（物理像素）。
  static const int maxCacheWidth = 1280;

  final String path;
  final BoxFit fit;

  /// [path] 是视频、而它旁边还没有封面时，去哪儿取一张。只有下载域知道这个地址
  /// （任务的 `imageList` 里存着原始地址，改写一道就是海报，见 [iwaraPosterUrlFrom]）。
  final String? posterUrl;

  /// 读图失败、或视频没有封面时画它。
  final Widget placeholder;

  /// 读图失败时画什么。媒体卡要在失败时换下一张候选图，所以留这个口子。
  final WidgetBuilder? errorBuilder;

  /// 给定逻辑宽度下的解码宽度：逻辑宽 × 设备像素比，夹在 [1, maxCacheWidth]。
  /// 宽度不可用（无界约束）时按 320 逻辑像素估。
  static int cacheWidthFor(BuildContext context, double logicalWidth) {
    final width = logicalWidth.isFinite && logicalWidth > 0
        ? logicalWidth
        : 320.0;
    return (width * MediaQuery.devicePixelRatioOf(context)).round().clamp(
      1,
      maxCacheWidth,
    );
  }

  @override
  State<LocalCoverImage> createState() => _LocalCoverImageState();
}

class _LocalCoverImageState extends State<LocalCoverImage> {
  /// 视频旁边那张封面的路径。不是视频时恒为 null（直接画 [LocalCoverImage.path]）。
  String? _posterPath;

  /// 找过了（不管找没找到）。没找到不重试：结论不会因为多问一次而改变。
  bool _resolved = false;

  bool get _isVideo => isGalleryVideoFileName(widget.path);

  @override
  void initState() {
    super.initState();
    if (_isVideo) unawaited(_resolvePoster());
  }

  @override
  void didUpdateWidget(covariant LocalCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path == widget.path &&
        oldWidget.posterUrl == widget.posterUrl) {
      return;
    }
    _posterPath = null;
    _resolved = false;
    if (_isVideo) unawaited(_resolvePoster());
  }

  Future<void> _resolvePoster() async {
    final path = widget.path;
    final url = widget.posterUrl;
    final poster = url == null || url.isEmpty
        ? await existingGalleryVideoPoster(path)
        : await ensureGalleryVideoPoster(videoPath: path, posterUrl: url);
    if (!mounted || path != widget.path) return;
    setState(() {
      _posterPath = poster;
      _resolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      final poster = _posterPath;
      // 还在找 / 没找到：画占位图。⛔ 别把视频文件本身交给 `Image.file`——
      // 它解不出位图，errorBuilder 会当场把这一格判成「坏图」。
      if (poster == null) {
        if (!_resolved) return widget.placeholder;
        return widget.errorBuilder?.call(context) ?? widget.placeholder;
      }
      return _buildFile(poster);
    }
    return _buildFile(widget.path);
  }

  Widget _buildFile(String path) {
    return LayoutBuilder(
      builder: (context, constraints) => Image.file(
        File(path),
        fit: widget.fit,
        cacheWidth: LocalCoverImage.cacheWidthFor(
          context,
          constraints.maxWidth,
        ),
        errorBuilder: (context, error, stackTrace) =>
            widget.errorBuilder?.call(context) ?? widget.placeholder,
      ),
    );
  }
}
