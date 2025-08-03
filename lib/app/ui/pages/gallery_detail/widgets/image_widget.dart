import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 图片组件，带有加载进度条
class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final Map<String, String>? headers;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.headers,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: headers,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) {
        LogUtils.e('图片加载失败: $url', tag: 'ImageWidget', error: error);

        final fileExtension = CommonUtils.getFileExtension(url);
        final isUnsupportedFormat = error is Exception &&
            error.toString().contains('Invalid image data');

        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  slang.t.mediaPlayer.imageLoadFailed,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${slang.t.mediaPlayer.format}: ${fileExtension.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                if (isUnsupportedFormat) ...[
                  const SizedBox(height: 8),
                  Text(
                    slang.t.mediaPlayer.tryOtherViewer,
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: downloadProgress.progress,
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
                const SizedBox(height: 16),
                Text(
                  '${slang.t.common.loading} ${downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
