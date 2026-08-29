import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import '../controllers/subscription_query_params.dart';
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
    super.sortId,
    super.searchTagIds,
    super.searchDate,
    super.searchRating,
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
    return SubscriptionVideoRepository(
      userId: widget.userId,
      sortId: widget.sortId,
      searchTagIds: widget.searchTagIds,
      searchDate: widget.searchDate,
      searchRating: widget.searchRating,
    );
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
      // 交出**这一页真正发出去的那份查询**（订阅集合 / 某个作者 + 排序 + 标签
      // + 年月 + 评级），详情页的「接着看」就能顺着它一直翻下去，而不是只在
      // 进来那一刻加载出来的那几十条里打转。参数拼装与仓库共用同一条
      // [buildSubscriptionQueryParams]——那儿记着哪些参数在哪种查询下才生效。
      query: MediaListQuery.pruned(
        mediaType: PlaybackMediaType.video,
        params: buildSubscriptionQueryParams(
          userId: widget.userId,
          sortId: widget.sortId,
          searchTagIds: widget.searchTagIds,
          searchDate: widget.searchDate,
          searchRating: widget.searchRating,
        ),
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaLayoutUtils.calculateCardWidth(
                MediaQuery.sizeOf(context).width,
              );

        return VideoCardListItemWidget(
          video: item,
          width: itemWidth,
          isMultiSelectMode: widget.isMultiSelectMode,
          isSelected: widget.selectedItemIds.contains(item.id),
          onSelect: () => widget.onItemSelect?.call(item),
          onOpenVideo: ({required videoId, Map<String, dynamic>? extData}) {
            return _openVideoFromSubscriptions(
              videoId: videoId,
              extData: extData,
            );
          },
        );
      },
    );
  }
}
