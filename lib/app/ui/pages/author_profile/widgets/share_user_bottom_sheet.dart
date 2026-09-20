import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/widgets/share/share_cards.dart';
import 'package:i_iwara/app/ui/widgets/share/share_image_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class ShareUserBottomSheet extends StatelessWidget {
  final String username;
  final String authorName;
  final String? avatarUrl;
  final int followerCount;
  final int followingCount;
  final int commentCount;

  const ShareUserBottomSheet({
    super.key,
    required this.username,
    required this.authorName,
    this.avatarUrl,
    required this.followerCount,
    required this.followingCount,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final url = ShareService.buildUrl('/profile/$username');

    return ShareImageBottomSheet(
      sheetTitle: t.share.shareUser,
      shareUrl: url,
      imageFileNamePrefix: 'share_user',
      card: ProfileShareCard(
        avatarUrl: avatarUrl,
        displayName: authorName,
        handle: username,
        stats: [
          ShareCardStat(
            t.common.follower,
            CommonUtils.formatFriendlyNumber(followerCount),
          ),
          ShareCardStat(
            t.common.following,
            CommonUtils.formatFriendlyNumber(followingCount),
          ),
          ShareCardStat(
            t.share.comments,
            CommonUtils.formatFriendlyNumber(commentCount),
          ),
        ],
        url: url,
      ),
      onShareAsText: () {
        ShareService.shareUserDetail(username, authorName);
        Navigator.pop(context);
      },
    );
  }
}
