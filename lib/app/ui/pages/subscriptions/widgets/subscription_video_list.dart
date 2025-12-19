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
    super.isPaginated,
    super.paddingTop,
    super.showBottomPadding,
    super.isMultiSelectMode,
    super.selectedItemIds,
    super.onItemSelect,
  });

  @override
  State<SubscriptionVideoList> createState() => _SubscriptionVideoListState();
}

class _SubscriptionVideoListState
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
  Widget buildListItem(BuildContext context, Video item, int index) {
    return VideoCardListItemWidget(
      video: item,
      width: CommonUtils.calculateCardWidth(MediaQuery.of(context).size.width),
      isMultiSelectMode: widget.isMultiSelectMode,
      isSelected: widget.selectedItemIds.contains(item.id),
      onSelect: () => widget.onItemSelect?.call(item),
    );
  }
}
