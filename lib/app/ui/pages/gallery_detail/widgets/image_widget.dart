import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:url_launcher/url_launcher.dart';

/// 图片组件，带有加载进度条与网络错误展示
class ImageWidget extends StatefulWidget {
  final String imageUrl;
  final Map<String, String>? headers;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.headers,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  int _reloadNonce = 0;

  String get _effectiveUrl => _reloadNonce > 0
      ? '${widget.imageUrl}${widget.imageUrl.contains('?') ? '&' : '?'}r=$_reloadNonce'
      : widget.imageUrl;

  int? _extractStatusCode(dynamic error) {
    final text = error.toString();
    final match = RegExp(r'statusCode:\s*(\d{3})').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  Future<void> _retry() async {
    try {
      await CachedNetworkImage.evictFromCache(widget.imageUrl);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _reloadNonce++;
      });
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(widget.imageUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _effectiveUrl,
      httpHeaders: widget.headers,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) {
        LogUtils.e('图片加载失败: $url', tag: 'ImageWidget', error: error);

        final fileExtension = CommonUtils.getFileExtension(url);
        final isUnsupportedFormat = error is Exception &&
            error.toString().contains('Invalid image data');
        final statusCode = _extractStatusCode(error);

        final maxCardHeight = MediaQuery.of(context).size.height * 0.8;
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 420, maxHeight: maxCardHeight),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        slang.t.mediaPlayer.imageLoadFailed,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (statusCode != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'HTTP $statusCode',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${slang.t.mediaPlayer.format}: ${fileExtension.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.imageUrl,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isUnsupportedFormat) ...[
                  const SizedBox(height: 8),
                  Text(
                    slang.t.mediaPlayer.tryOtherViewer,
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(slang.t.mediaPlayer.retry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openInBrowser,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text(slang.t.linkInputDialog.openInBrowser),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _copyLink,
                      icon: const Icon(Icons.link, size: 18),
                      label: Text(slang.t.galleryDetail.copyLink),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    slang.t.mediaPlayer.detailedErrorInfo,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        error.toString(),
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            ),
          ),
        );
      },
      progressIndicatorBuilder: (context, url, downloadProgress) {
        final double? progress = downloadProgress.progress;
        final int downloaded = downloadProgress.downloaded ?? 0;
        final int? total = downloadProgress.totalSize;

        // 格式化字节大小为易读格式
        String formatBytes(int bytes) {
          if (bytes < 1024) return '${bytes}B';
          if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
        }

        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        color: Colors.white,
                        strokeWidth: 3.0,
                      ),
                      if (progress != null)
                        Text(
                          '${(progress * 100).clamp(0, 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                // 只在有实际下载数据时显示字节数信息
                if (downloaded > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    total != null
                        ? '${formatBytes(downloaded)} / ${formatBytes(total)}'
                        : formatBytes(downloaded),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
