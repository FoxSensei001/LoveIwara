import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/share/share_cards.dart';
import 'package:i_iwara/app/ui/widgets/share/share_image_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ShareVideoBottomSheet extends StatelessWidget {
  final String videoId;
  final String videoTitle;
  final String authorName;

  /// 静态封面图地址（⛔ 不要传 `previewUrl`，那是动图预览）。
  final String coverUrl;

  const ShareVideoBottomSheet({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.authorName,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = ShareService.buildUrl('/video/$videoId');

    return ShareImageBottomSheet(
      sheetTitle: t.common.share,
      shareUrl: url,
      imageFileNamePrefix: 'share_video',
      card: MediaShareCard(
        coverUrl: coverUrl,
        title: videoTitle,
        authorName: authorName,
        url: url,
      ),
      onShareAsText: () {
        ShareService.shareVideoDetail(videoId, videoTitle, authorName);
        Navigator.pop(context);
      },
    );
  }
}
