import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:i_iwara/utils/logger_utils.dart';

/// 模糊缩略图背景：用于视频播放页剧院模式背景、站外视频提示背景等场景的通用组件。
class BlurredThumbnailBackground extends StatelessWidget {
  const BlurredThumbnailBackground({
    super.key,
    required this.thumbnailUrl,
    this.blurSigma = 20.0,
    this.scale = 1.08,
    this.opacity = 0.2,
    this.switchDuration = const Duration(milliseconds: 160),
  });

  final String? thumbnailUrl;
  final double blurSigma;
  final double scale;
  final double opacity;
  final Duration switchDuration;

  @override
  Widget build(BuildContext context) {
    final hasThumbnail = thumbnailUrl != null && thumbnailUrl!.isNotEmpty;
    final backgroundKey = ValueKey(hasThumbnail ? thumbnailUrl : 'empty');

    final Widget background = hasThumbnail
        ? Stack(
            key: backgroundKey,
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              Opacity(
                opacity: opacity,
                child: ClipRect(
                  child: Transform.scale(
                    scale: scale,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: blurSigma,
                        sigmaY: blurSigma,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: thumbnailUrl!,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 200),
                        fadeOutDuration: const Duration(milliseconds: 200),
                        placeholder: (context, url) =>
                            const ColoredBox(color: Colors.black),
                        errorWidget: (context, url, error) {
                          LogUtils.e(
                            '模糊缩略图背景加载失败: $error',
                            tag: 'BlurredThumbnailBackground',
                          );
                          return const ColoredBox(color: Colors.black);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.expand(
            key: ValueKey('empty'),
            child: ColoredBox(color: Colors.black),
          );

    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: switchDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: background,
      ),
    );
  }
}
