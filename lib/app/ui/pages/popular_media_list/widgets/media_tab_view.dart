import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  });

  @override
  MediaTabViewState<T> createState() => MediaTabViewState<T>();
}

class MediaTabViewState<T> extends State<MediaTabView<T>>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // 缓存列表项
  final Map<String, Widget> _itemCache = {};

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    if (widget.mediaListController != null) {
      // 注册滚动控制器
      widget.mediaListController!.registerScrollController(
        widget.sortId,
        _scrollController,
      );

      _scrollController.addListener(() {
        final controller = widget.mediaListController!;
        final currentOffset = _scrollController.offset;

        // 确定滚动方向
        ScrollDirection direction = ScrollDirection.idle;
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          direction = ScrollDirection.reverse; // 向上滚动
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          direction = ScrollDirection.forward; // 向下滚动
        }

        // 更新控制器的滚动信息
        controller.updateScrollInfo(
          sortId: widget.sortId,
          offset: currentOffset,
          direction: direction,
        );
      });
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
      itemBuilder: (context, item, index) {
        // 多选模式下不使用缓存，因为选中状态会变化
        if (widget.isMultiSelectMode) {
          return _buildCachedItem(item, context, index);
        }
        final cacheKey = '${item.hashCode}_$index';
        return _itemCache.putIfAbsent(cacheKey, () {
          return _buildCachedItem(item, context, index);
        });
      },
    );
  }

  Widget _buildCachedItem(T item, BuildContext context, int index) {
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
