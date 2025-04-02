import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: _buildItem(item, context),
    );
  }

  Widget _buildItem(T item, BuildContext context) {
    if (T == Video) {
      return VideoCardListItemWidget(
        video: item as Video,
        width: MediaQuery.of(context).size.width <= 600 
            ? MediaQuery.of(context).size.width / 2 - 8 
            : 200,
      );
    } else if (T == ImageModel) {
      return ImageModelCardListItemWidget(
        imageModel: item as ImageModel,
        width: MediaQuery.of(context).size.width <= 600 
            ? MediaQuery.of(context).size.width / 2 - 8 
            : 200,
      );
    }
    throw Exception('Unsupported type: $T');
  }
} 