import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ShareThreadBottomSheet extends StatefulWidget {
  final ForumThreadModel thread;

  const ShareThreadBottomSheet({
    super.key,
    required this.thread,
  });

  @override
  State<ShareThreadBottomSheet> createState() => _ShareThreadBottomSheetState();
}

class _ShareThreadBottomSheetState extends State<ShareThreadBottomSheet> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isGeneratingImage = false;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = '${CommonConstants.iwaraBaseUrl}/forum/${widget.thread.section}/${widget.thread.id}';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  t.share.shareThread,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
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
          // 分享预览
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 头部信息
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 头像
                      AvatarWidget(
                        avatarUrl: widget.thread.user.avatar?.avatarUrl,
                        size: 70
                      ),
                      const SizedBox(width: 16),
                      // 统计信息
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.share.views,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CommonUtils.formatFriendlyNumber(widget.thread.numViews),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.share.comments,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CommonUtils.formatFriendlyNumber(widget.thread.numPosts),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
                  // 标题和用户名
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.thread.title,
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
                        widget.thread.user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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
                    onPressed: _isGeneratingImage
                        ? null
                        : () async {
                            setState(() {
                              _isGeneratingImage = true;
                            });
                            try {
                              // 获取RenderRepaintBoundary
                              final boundary = _globalKey.currentContext!
                                  .findRenderObject() as RenderRepaintBoundary;
                              // 转换为图片
                              final image = await boundary.toImage(
                                  pixelRatio: View.of(context).devicePixelRatio);
                              final byteData = await image.toByteData(
                                  format: ui.ImageByteFormat.png);
                              final bytes = byteData!.buffer.asUint8List();

                              // 保存到临时文件
                              final tempDir = await getTemporaryDirectory();
                              final file = File(
                                  '${tempDir.path}/share_thread_${DateTime.now().millisecondsSinceEpoch}.png');
                              await file.writeAsBytes(bytes);

                              // 分享
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: '${t.share.wowDidYouSeeThis}\n'
                                      '${t.share.nameIs}: ${widget.thread.title}\n'
                                      '${t.share.authorIs}: ${widget.thread.user.name}\n'
                                      '${t.share.clickLinkToView}: $url\n\n'
                                      '${t.share.iReallyLikeThis}',
                                  subject: widget.thread.title,
                                ),
                              );
                            } finally {
                              setState(() {
                                _isGeneratingImage = false;
                              });
                            }
                          },
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
                    onPressed: () {
                      ShareService.shareThreadDetail(
                        widget.thread.section,
                        widget.thread.id,
                        widget.thread.title,
                        widget.thread.user.name,
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.text_fields),
                    label: Text(t.share.shareAsText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


} 