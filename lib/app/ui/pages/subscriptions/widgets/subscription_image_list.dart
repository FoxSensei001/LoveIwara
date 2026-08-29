import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import '../controllers/subscription_image_repository.dart';
import '../controllers/subscription_query_params.dart';
import 'base_subscription_list.dart';

class SubscriptionImageList
    extends BaseSubscriptionList<ImageModel, SubscriptionImageRepository> {
  const SubscriptionImageList({
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
  State<SubscriptionImageList> createState() => _SubscriptionImageListState();
}

class _SubscriptionImageListState
    extends
        BaseSubscriptionListState<
          ImageModel,
          SubscriptionImageRepository,
          SubscriptionImageList
        > {
  @override
  SubscriptionImageRepository createRepository() {
    return SubscriptionImageRepository(
      userId: widget.userId,
      sortId: widget.sortId,
      searchTagIds: widget.searchTagIds,
      searchDate: widget.searchDate,
      searchRating: widget.searchRating,
    );
  }

  @override
  IconData get emptyIcon => Icons.image_outlined;

  /// 「接着看」的池引用：拿**这一页真正发出去的那份查询**登记一个分页池，
  /// 图库详情页只收两个字符串。参数拼装与仓库共用同一条
  /// [buildSubscriptionQueryParams]。
  PlaybackQueueRef _queueRef(String galleryId) {
    final query = MediaListQuery.pruned(
      mediaType: PlaybackMediaType.gallery,
      params: buildSubscriptionQueryParams(
        userId: widget.userId,
        sortId: widget.sortId,
        searchTagIds: widget.searchTagIds,
        searchDate: widget.searchDate,
        searchRating: widget.searchRating,
      ),
    );
    final seed = <InnerPlaylistItemSnapshot>[
      for (final item in repository) InnerPlaylistItemSnapshot.fromGallery(item),
    ];
    return PlaybackQueueRef(
      queueId: PlaybackQueueService.to
          .openRemoteList(query, seed: seed)
          .queueId,
      currentItemId: galleryId,
    );
  }

  @override
  Widget buildListItem(BuildContext context, ImageModel image, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaLayoutUtils.calculateCardWidth(
                MediaQuery.sizeOf(context).width,
              );

        return ImageModelCardListItemWidget(
          imageModel: image,
          width: itemWidth,
          isMultiSelectMode: widget.isMultiSelectMode,
          isSelected: widget.selectedItemIds.contains(image.id),
          onSelect: () => widget.onItemSelect?.call(image),
          playbackQueueRefBuilder: _queueRef,
        );
      },
    );
  }
}
