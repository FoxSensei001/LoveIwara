import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/share/share_cards.dart';
import 'package:i_iwara/app/ui/widgets/share/share_image_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ShareGalleryBottomSheet extends StatelessWidget {
  final String galleryId;
  final String galleryTitle;
  final String authorName;

  /// 静态封面图地址（图库缩略图为 jpg）。
  final String coverUrl;

  const ShareGalleryBottomSheet({
    super.key,
    required this.galleryId,
    required this.galleryTitle,
    required this.authorName,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = ShareService.buildUrl('/image/$galleryId');

    return ShareImageBottomSheet(
      sheetTitle: t.common.share,
      shareUrl: url,
      imageFileNamePrefix: 'share_gallery',
      card: MediaShareCard(
        coverUrl: coverUrl,
        title: galleryTitle,
        authorName: authorName,
        url: url,
      ),
      onShareAsText: () {
        ShareService.shareGalleryDetail(galleryId, galleryTitle, authorName);
        Navigator.pop(context);
      },
    );
  }
}
