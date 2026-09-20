import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/share/share_cards.dart';
import 'package:i_iwara/app/ui/widgets/share/share_image_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class ShareThreadBottomSheet extends StatelessWidget {
  final ForumThreadModel thread;

  const ShareThreadBottomSheet({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = ShareService.buildUrl(
      '/forum/${thread.section}/${thread.id}',
    );

    return ShareImageBottomSheet(
      sheetTitle: t.share.shareThread,
      shareUrl: url,
      imageFileNamePrefix: 'share_thread',
      // 分享图片时附一段带标题/作者/链接的推荐文案（沿用旧文案格式）
      imageShareText:
          '${t.share.wowDidYouSeeThis}\n'
          '${t.share.nameIs}: ${thread.title}\n'
          '${t.share.authorIs}: ${thread.user.name}\n'
          '${t.share.clickLinkToView}: $url\n\n'
          '${t.share.iReallyLikeThis}',
      card: TextContentShareCard(
        avatarUrl: thread.user.avatar?.avatarUrl,
        title: thread.title,
        authorLine: Text(
          thread.user.name,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        stats: [
          ShareCardStat(
            t.share.views,
            CommonUtils.formatFriendlyNumber(thread.numViews),
          ),
          ShareCardStat(
            t.share.comments,
            CommonUtils.formatFriendlyNumber(thread.numPosts),
          ),
        ],
        url: url,
      ),
      onShareAsText: () {
        ShareService.shareThreadDetail(
          thread.section,
          thread.id,
          thread.title,
          thread.user.name,
        );
        Navigator.pop(context);
      },
    );
  }
}
