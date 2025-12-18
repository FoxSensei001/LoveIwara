import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/utils/common_utils.dart' show CommonUtils;
import '../controllers/subscription_video_repository.dart';
import 'base_subscription_list.dart';

class SubscriptionVideoList
    extends BaseSubscriptionList<Video, SubscriptionVideoRepository> {
  const SubscriptionVideoList({
    super.key,
    required super.userId,
    super.isPaginated = false,
    super.paddingTop = 0,
    super.showBottomPadding = false,
  });

  @override
  State<SubscriptionVideoList> createState() => SubscriptionVideoListState();
}

class SubscriptionVideoListState
    extends
        BaseSubscriptionListState<
          Video,
          SubscriptionVideoRepository,
          SubscriptionVideoList
        > {
  @override
  SubscriptionVideoRepository createRepository() {
    return SubscriptionVideoRepository(userId: widget.userId);
  }

  @override
  IconData get emptyIcon => Icons.video_library_outlined;

  @override
  Widget buildListItem(BuildContext context, Video video, int index) {
    return VideoCardListItemWidget(
      video: video,
      width: CommonUtils.calculateCardWidth(MediaQuery.of(context).size.width),
    );
  }
}
