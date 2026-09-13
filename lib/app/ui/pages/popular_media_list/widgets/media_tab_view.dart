import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'media_list_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

class MediaTabView<T> extends StatefulWidget {
  final SortId sortId;
  final LoadingMoreBase<T> repository;
  final IconData emptyIcon;
  final bool isPaginated;
  final String rebuildKey;
  final double paddingTop;
  final PopularMediaListController? mediaListController; // 添加控制器参数
  final bool showBottomPadding;

  /// 是否处于多选模式
  final bool isMultiSelectMode;

  /// 已选中的项目ID集合。
  ///
  /// 静态快照。热门页已经改用 [selectionSource]，这里保留给其它调用方。
  final Set<String>? selectedItemIds;

  /// 选中集合本身（响应式）。给了它，选中态由卡片自己订阅，调用方就不必把
  /// 选中集合读进 `Obx`——那会让整页变成它的依赖。见
  /// `VideoCardListItemWidget.selectionSource`。
  final RxSet<String>? selectionSource;

  /// 项目选中状态变化回调
  final void Function(dynamic item)? onItemSelect;

  /// 分页切换时的回调（用于重置选择）
  final VoidCallback? onPageChanged;
  final Future<void> Function({
    required String videoId,
    required List<Video> loadedVideos,
    Map<String, dynamic>? extData,
  })?
  onOpenVideo;

  /// 图库卡片的「接着看」池引用。列表页把自己那份查询登记成一个分页池，
  /// 详情页只拿两个字符串（见 `MediaListQuery` / `PlaybackQueueRef`）。
  final PlaybackQueueRef? Function(String galleryId)? playbackQueueRefBuilder;

  const MediaTabView({
    super.key,
    required this.sortId,
    required this.repository,
    required this.emptyIcon,
    this.isPaginated = false,
    this.rebuildKey = '',
    this.paddingTop = 0,
    this.mediaListController,
    this.showBottomPadding = false,
    this.isMultiSelectMode = false,
    this.selectedItemIds,
    this.selectionSource,
    this.onItemSelect,
    this.onPageChanged,
    this.onOpenVideo,
    this.playbackQueueRefBuilder,
  });

  @override
  MediaTabViewState<T> createState() => MediaTabViewState<T>();
}

class MediaTabViewState<T> extends State<MediaTabView<T>>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.mediaListController?.markSortLoaded(widget.sortId);
    _registerScrollController();
  }

  void _registerScrollController() {
    if (widget.mediaListController != null) {
      // 注册滚动控制器
      widget.mediaListController!.registerScrollController(
        widget.sortId,
        _scrollController,
      );
    }
  }

  @override
  void dispose() {
    if (widget.mediaListController != null) {
      // 注销滚动控制器
      widget.mediaListController!.unregisterScrollController(
        widget.sortId,
        _scrollController,
      );
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MediaListView<T>(
      sourceList: widget.repository,
      emptyIcon: widget.emptyIcon,
      isPaginated: widget.isPaginated,
      forceTotalCountUnknown: widget.isPaginated,
      scrollController: _scrollController,
      paddingTop: widget.paddingTop,
      showBottomPadding: widget.showBottomPadding,
      onPageChanged: widget.onPageChanged,
      onScrollMetricsChanged: (offset, delta, direction) {
        widget.mediaListController?.updateScrollInfo(
          sortId: widget.sortId,
          offset: offset,
          direction: direction,
          delta: delta,
        );
      },
      // 列宽由 MediaListView 算好递进来（与瀑布流 delegate 同一份公式）。
      // 不再为**每一项**套一个 LayoutBuilder：瀑布流本来就用紧约束把列宽给到了
      // 子项，这个值在列表层就是已知的；每项再套一层只会白搭一个 element +
      // render object，还逼着卡片子树在布局阶段才构建。
      itemBuilderWithWidth: (context, item, index, cardWidth) =>
          _buildItem(item, context, cardWidth),
    );
  }

  Widget _buildItem(T item, BuildContext context, double width) {
    if (T == Video) {
      final video = item as Video;
      final isSelected = widget.selectedItemIds?.contains(video.id) ?? false;
      return VideoCardListItemWidget(
        video: video,
        width: width,
        isMultiSelectMode: widget.isMultiSelectMode,
        isSelected: isSelected,
        selectionSource: widget.selectionSource,
        onSelect: widget.onItemSelect != null
            ? () => widget.onItemSelect!(video)
            : null,
        onOpenVideo: widget.onOpenVideo == null
            ? null
            : ({required videoId, Map<String, dynamic>? extData}) {
                return widget.onOpenVideo!(
                  videoId: videoId,
                  loadedVideos: List<Video>.of(widget.repository.cast<Video>()),
                  extData: extData,
                );
              },
      );
    } else if (T == ImageModel) {
      final imageModel = item as ImageModel;
      final isSelected =
          widget.selectedItemIds?.contains(imageModel.id) ?? false;
      return ImageModelCardListItemWidget(
        imageModel: imageModel,
        width: width,
        isMultiSelectMode: widget.isMultiSelectMode,
        isSelected: isSelected,
        selectionSource: widget.selectionSource,
        onSelect: widget.onItemSelect != null
            ? () => widget.onItemSelect!(imageModel)
            : null,
        playbackQueueRefBuilder: widget.playbackQueueRefBuilder,
      );
    }
    throw Exception('Unsupported type: $T');
  }
}
