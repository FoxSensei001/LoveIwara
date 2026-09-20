import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/share/share_cards.dart';
import 'package:i_iwara/app/ui/widgets/share/share_image_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class SharePostBottomSheet extends StatelessWidget {
  final PostModel post;

  const SharePostBottomSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = ShareService.buildUrl('/post/${post.id}');

    return ShareImageBottomSheet(
      sheetTitle: t.share.sharePost,
      shareUrl: url,
      imageFileNamePrefix: 'share_post',
      card: TextContentShareCard(
        avatarUrl: post.user.avatar?.avatarUrl,
        title: post.title,
        authorLine: buildUserName(
          context,
          post.user,
          bold: true,
          fontSize: 14,
        ),
        stats: [
          ShareCardStat(
            t.share.views,
            CommonUtils.formatFriendlyNumber(post.numViews ?? 0),
          ),
        ],
        url: url,
      ),
      onShareAsText: () {
        ShareService.sharePostDetail(post.id, post.title, post.user.name);
        Navigator.pop(context);
      },
    );
  }
}
