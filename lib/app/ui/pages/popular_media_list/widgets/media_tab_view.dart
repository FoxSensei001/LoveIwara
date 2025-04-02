import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'media_list_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

class MediaTabView<T> extends StatefulWidget {
  final LoadingMoreBase<T> repository;
  final IconData emptyIcon;
  final bool isPaginated;
  final String rebuildKey;
  final double paddingTop;

  const MediaTabView({
    super.key,
    required this.repository,
    required this.emptyIcon,
    this.isPaginated = false,
    this.rebuildKey = '',
    this.paddingTop = 0,
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
  void dispose() {
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
      scrollController: _scrollController,
      paddingTop: widget.paddingTop,
      itemBuilder: (context, item, index) {
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
      return VideoCardListItemWidget(
        video: item as Video,
        width: width,
      );
    } else if (T == ImageModel) {
      return ImageModelCardListItemWidget(
        imageModel: item as ImageModel,
        width: width,
      );
    }
    throw Exception('Unsupported type: $T');
  }
}
