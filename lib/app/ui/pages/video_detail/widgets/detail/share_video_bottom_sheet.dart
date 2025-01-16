import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ShareVideoBottomSheet extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final String authorName;
  final String previewUrl;

  const ShareVideoBottomSheet({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.authorName,
    required this.previewUrl,
  });

  @override
  State<ShareVideoBottomSheet> createState() => _ShareVideoBottomSheetState();
}

class _ShareVideoBottomSheetState extends State<ShareVideoBottomSheet> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isGeneratingImage = false;

  Future<void> _shareAsImage() async {
    if (_isGeneratingImage) return;

    setState(() {
      _isGeneratingImage = true;
    });

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/share_image.png').create();
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '${widget.videoTitle}\n@${widget.authorName}\n${CommonConstants.iwaraBaseUrl}/video/${widget.videoId}',
        );
      }
    } catch (e) {
      LogUtils.e('生成分享图片失败', error: e, tag: 'ShareVideoBottomSheet');
      showToastWidget(MDToastWidget(message: slang.t.errors.failedToOperate, type: MDToastType.error));
    } finally {
      setState(() {
        _isGeneratingImage = false;
      });
    }
  }

  Future<void> _shareAsText() async {
    await ShareService.shareVideoDetail(
      widget.videoId,
      widget.videoTitle,
      widget.authorName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  t.common.share,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 分享预览图
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 预览图
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.previewUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 标题、作者和二维码区域
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题和作者信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.videoTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '@${widget.authorName}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 二维码
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: QrImageView(
                          data: '${CommonConstants.iwaraBaseUrl}/video/${widget.videoId}',
                          version: QrVersions.auto,
                          size: 80,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 分享按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingImage ? null : _shareAsImage,
                    icon: _isGeneratingImage 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image),
                    label: Text(t.share.shareAsImage),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareAsText,
                    icon: const Icon(Icons.link),
                    label: Text(t.share.shareAsText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
} 