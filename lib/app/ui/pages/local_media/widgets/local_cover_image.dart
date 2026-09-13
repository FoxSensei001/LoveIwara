import 'dart:io';

import 'package:flutter/material.dart';

/// 本机文件模块里所有「一张本地图铺满一块区域」的封面。
///
/// ⛔ 解码尺寸只在这里算。原先目录卡 / 来源卡 / 图库卡各抄一份
/// `LayoutBuilder + Image.file + cacheWidth`，媒体卡又另写了一个
/// `(width * 2)`——写死 2 倍在 3 倍屏上糊、在 1 倍桌面上白解一倍像素。
///
/// 封面多是用户自己的原图（相机直出 6000px 很常见），不给 cacheWidth 就按原尺寸
/// 解进内存：一屏几十格，光解码缓存就能吃掉几百 MB。上限钉在 [maxCacheWidth]。
class LocalCoverImage extends StatelessWidget {
  const LocalCoverImage({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  /// 解码宽度上限（物理像素）。
  static const int maxCacheWidth = 1280;

  final String path;
  final BoxFit fit;

  /// 读图失败且没给 [errorBuilder] 时画它。
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Image.file(
        File(path),
        fit: fit,
        cacheWidth: cacheWidthFor(context, constraints.maxWidth),
        errorBuilder: (context, error, stackTrace) =>
            errorBuilder?.call(context) ?? placeholder,
      ),
    );
  }
}
