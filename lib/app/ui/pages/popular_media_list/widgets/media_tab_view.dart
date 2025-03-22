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
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.isPaginated) {
          if (widget.repository is ExtendedLoadingMoreBase) {
            await (widget.repository as ExtendedLoadingMoreBase).loadPageData(0, 20);
          }
        } else {
          await widget.repository.refresh(true);
        }
      },
      child: MediaListView<T>(
        sourceList: widget.repository,
        emptyIcon: widget.emptyIcon,
        isPaginated: widget.isPaginated,
        scrollController: _scrollController,
        paddingTop: widget.paddingTop,
        itemBuilder: (context, item, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
              vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
            ),
            child: _buildItem(item, context),
          );
        },
      ),
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