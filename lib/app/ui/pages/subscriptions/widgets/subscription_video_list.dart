import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/utils/common_utils.dart' show CommonUtils;
import '../controllers/subscription_video_repository.dart';
import 'base_subscription_list.dart';

class SubscriptionVideoList
    extends BaseSubscriptionList<Video, SubscriptionVideoRepository> {
  const SubscriptionVideoList({
    super.key,
    required super.userId,
    required super.tabIndex,
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

  Future<void> _openVideoFromSubscriptions({
    required String videoId,
    Map<String, dynamic>? extData,
  }) async {
    final loadedVideos = List<Video>.of(repository);

    Video? initialVideoInfo;
    for (final video in loadedVideos) {
      if (video.id == videoId) {
        initialVideoInfo = video;
        break;
      }
    }

    final playlistContext = InnerPlaylistContext.fromVideos(
      source: InnerPlaylistSource.subscriptionVideoList,
      videos: loadedVideos,
      currentVideoId: videoId,
    );

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      innerPlaylistContext: playlistContext,
      initialVideoInfo: initialVideoInfo,
    );
  }

  @override
  Widget buildListItem(BuildContext context, Video item, int index) {
    return VideoCardListItemWidget(
      video: item,
      width: CommonUtils.calculateCardWidth(MediaQuery.of(context).size.width),
      isMultiSelectMode: widget.isMultiSelectMode,
      isSelected: widget.selectedItemIds.contains(item.id),
      onSelect: () => widget.onItemSelect?.call(item),
      onOpenVideo: ({required videoId, Map<String, dynamic>? extData}) {
        return _openVideoFromSubscriptions(videoId: videoId, extData: extData);
      },
    );
  }
}
