import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
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

  /// 已选中的项目ID集合
  final Set<String>? selectedItemIds;

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
    this.onItemSelect,
    this.onPageChanged,
    this.onOpenVideo,
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
      itemBuilder: (context, item, index) =>
          _buildItemForLayout(item, context, index),
    );
  }

  Widget _buildItemForLayout(T item, BuildContext context, int index) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;

    // 使用工具类计算卡片宽度
    final double cardWidth = MediaLayoutUtils.calculateCardWidth(screenWidth);

    return _buildItem(item, context, cardWidth);
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
        onSelect: widget.onItemSelect != null
            ? () => widget.onItemSelect!(imageModel)
            : null,
      );
    }
    throw Exception('Unsupported type: $T');
  }
}
