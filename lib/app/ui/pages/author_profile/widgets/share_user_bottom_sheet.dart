import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';

class ShareUserBottomSheet extends StatefulWidget {
  final String username;
  final String authorName;
  final String previewUrl;
  final String? avatarUrl;
  final int followerCount;
  final int followingCount;
  final int commentCount;

  const ShareUserBottomSheet({
    super.key,
    required this.username,
    required this.authorName,
    required this.previewUrl,
    this.avatarUrl,
    required this.followerCount,
    required this.followingCount,
    required this.commentCount,
  });

  @override
  State<ShareUserBottomSheet> createState() => _ShareUserBottomSheetState();
}

class _ShareUserBottomSheetState extends State<ShareUserBottomSheet> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isGeneratingImage = false;

  String get _shareUrl => ShareService.buildUrl('/profile/${widget.username}');

  Future<void> _copyLink() async {
    try {
      await ShareService.copyToClipboard(_shareUrl);
      showGlassToast(
        slang.t.galleryDetail.copyLink,
        type: GlassToastType.success,
        position: GlassToastPosition.bottom,
      );
    } catch (e) {
      LogUtils.e('复制链接失败', error: e, tag: 'ShareUserBottomSheet');
      showGlassToast(
        slang.t.errors.failedToOperate,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = _shareUrl;

    return GlassBottomSheet(
      title: t.share.shareUser,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分享预览
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部信息
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 头像
                      AvatarWidget(avatarUrl: widget.avatarUrl, size: 70),
                      const SizedBox(width: 16),
                      // 用户信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.authorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${widget.username}',
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
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrImageView(
                              data: url,
                              version: QrVersions.auto,
                              size: 88,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 统计信息
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          CommonUtils.formatFriendlyNumber(
                            widget.followerCount,
                          ),
                          t.common.follower,
                        ),
                        _buildStatItem(
                          CommonUtils.formatFriendlyNumber(
                            widget.followingCount,
                          ),
                          t.common.following,
                        ),
                        _buildStatItem(
                          CommonUtils.formatFriendlyNumber(widget.commentCount),
                          t.share.comments,
                        ),
                      ],
                    ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 分享为图片按钮
                IconButton(
                  onPressed: _isGeneratingImage
                      ? null
                      : () async {
                          setState(() {
                            _isGeneratingImage = true;
                          });
                          try {
                            // 获取RenderRepaintBoundary
                            final boundary =
                                _globalKey.currentContext!.findRenderObject()
                                    as RenderRepaintBoundary;
                            // 转换为图片
                            final image = await boundary.toImage(
                              pixelRatio: View.of(context).devicePixelRatio,
                            );
                            final byteData = await image.toByteData(
                              format: ui.ImageByteFormat.png,
                            );
                            final bytes = byteData!.buffer.asUint8List();

                            // 保存到临时文件
                            final tempDir = await getTemporaryDirectory();
                            final file = File(
                              '${tempDir.path}/share_user_${DateTime.now().millisecondsSinceEpoch}.png',
                            );
                            await file.writeAsBytes(bytes);

                            // 分享
                            await SharePlus.instance.share(
                              ShareParams(files: [XFile(file.path)], text: url),
                            );
                          } finally {
                            setState(() {
                              _isGeneratingImage = false;
                            });
                          }
                        },
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
                // 分享为文本按钮
                IconButton(
                  onPressed: () {
                    ShareService.shareUserDetail(
                      widget.username,
                      widget.authorName,
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.share),
                  tooltip: t.share.shareAsText,
                  padding: const EdgeInsets.all(16),
                ),
                // 复制链接按钮
                IconButton(
                  onPressed: _copyLink,
                  icon: const Icon(Icons.copy),
                  tooltip: slang.t.galleryDetail.copyLink,
                  padding: const EdgeInsets.all(16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}
