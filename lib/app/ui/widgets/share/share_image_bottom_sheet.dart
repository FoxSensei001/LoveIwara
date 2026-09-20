import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 通用「分享」底部弹窗：负责截图分享的骨架，卡片内容由调用方给。
///
/// 三件事：
/// - 把 [card] 圈进 [RepaintBoundary]，「分享为图片」时截图存临时 PNG，
///   经 [ShareService.shareImageFile] 走系统分享（附 [imageShareText]，
///   不传则附 [shareUrl]）
/// - 「分享为文本」交给 [onShareAsText]（通常调 ShareService.shareXxxDetail
///   后关掉弹窗）
/// - 「复制链接」走 [ShareService.copyLinkWithFeedback]（toast 提示）
///
/// 卡片本体在 `share_cards.dart`（媒体卡 / 文本内容卡 / 用户卡）。
class ShareImageBottomSheet extends StatefulWidget {
  /// 弹窗标题行文字。
  final String sheetTitle;

  /// 被截图的卡片内容（自带完整背景，如白底媒体卡）。
  final Widget card;

  /// 分享链接：二维码内容、复制按钮、图片分享附文（见 [imageShareText]）。
  final String shareUrl;

  /// 「分享为文本」回调，在点击时触发。
  final VoidCallback onShareAsText;

  /// 分享图片时附带的文案；不传则用 [shareUrl]。
  final String? imageShareText;

  /// 截图临时文件名前缀，如 `share_video` → `share_video_<ts>.png`。
  final String imageFileNamePrefix;

  const ShareImageBottomSheet({
    super.key,
    required this.sheetTitle,
    required this.card,
    required this.shareUrl,
    required this.onShareAsText,
    this.imageShareText,
    this.imageFileNamePrefix = 'share',
  });

  @override
  State<ShareImageBottomSheet> createState() => _ShareImageBottomSheetState();
}

class _ShareImageBottomSheetState extends State<ShareImageBottomSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isGeneratingImage = false;

  Future<void> _shareAsImage() async {
    if (_isGeneratingImage) return;
    setState(() => _isGeneratingImage = true);

    try {
      final file = await ShareService.captureWidgetAsPngFile(
        _boundaryKey,
        fileNamePrefix: widget.imageFileNamePrefix,
      );
      if (file == null) {
        throw StateError('分享卡片截图失败');
      }
      await ShareService.shareImageFile(
        file.path,
        text: widget.imageShareText ?? widget.shareUrl,
      );
    } catch (e) {
      LogUtils.e('生成分享图片失败', error: e, tag: 'ShareImageBottomSheet');
      showAppToast(
        slang.t.errors.failedToOperate,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImage = false);
      }
    }
  }

  Future<void> _copyLink() async {
    await ShareService.copyLinkWithFeedback(widget.shareUrl);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassBottomSheet(
      title: widget.sheetTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分享卡片（截图区域）
          RepaintBoundary(key: _boundaryKey, child: widget.card),
          const SizedBox(height: 16),
          // 操作行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 分享为图片
                IconButton(
                  onPressed: _isGeneratingImage ? null : _shareAsImage,
                  icon: _isGeneratingImage
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image),
                  tooltip: t.share.shareAsImage,
                  padding: const EdgeInsets.all(16),
                ),
                // 分享为文本
                IconButton(
                  onPressed: widget.onShareAsText,
                  icon: const Icon(Icons.share),
                  tooltip: t.share.shareAsText,
                  padding: const EdgeInsets.all(16),
                ),
                // 复制链接
                IconButton(
                  onPressed: _copyLink,
                  icon: const Icon(Icons.copy),
                  tooltip: t.galleryDetail.copyLink,
                  padding: const EdgeInsets.all(16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
