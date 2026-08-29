import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/favorites/controllers/favorites_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FavoriteImageList extends StatefulWidget {
  final ScrollController scrollController;

  /// 列表顶部让出的高度（玻璃 header 悬浮在列表之上）。
  final double paddingTop;

  /// 瀑布流 ↔ 分页。
  final bool isPaginated;

  /// 外部刷新信号，理由同 [FavoriteVideoList.refreshSignal]。
  final ValueListenable<int>? refreshSignal;

  final bool isMultiSelectMode;
  final Set<String> selectedItemIds;
  final void Function(ImageModel image)? onItemSelect;

  /// 分页翻页后回调（用于重置多选）。
  final VoidCallback? onPageChanged;

  const FavoriteImageList({
    super.key,
    required this.scrollController,
    this.paddingTop = 0,
    this.isPaginated = false,
    this.refreshSignal,
    this.isMultiSelectMode = false,
    this.selectedItemIds = const {},
    this.onItemSelect,
    this.onPageChanged,
  });

  @override
  State<FavoriteImageList> createState() => _FavoriteImageListState();
}

class _FavoriteImageListState extends State<FavoriteImageList>
    with AutomaticKeepAliveClientMixin {
  final FavoritesController controller = Get.find();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MediaListView<ImageModel>(
      sourceList: controller.imageRepository,
      scrollController: widget.scrollController,
      paddingTop: widget.paddingTop,
      isPaginated: widget.isPaginated,
      refreshSignal: widget.refreshSignal,
      onPageChanged: widget.onPageChanged,
      emptyIcon: Icons.favorite_border,
      extendedListDelegate:
          const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
      itemBuilder: (context, image, index) => _buildItem(context, image),
    );
  }

  Widget _buildItem(BuildContext context, ImageModel image) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final bool isCanceled = controller.canceledFavoriteGalleryIds.contains(
        image.id,
      );
      return Stack(
        children: [
          ImageModelCardListItemWidget(
            imageModel: image,
            width: 220,
            // 「最爱」的图库池：详情页的「接着看」直接接着这份列表往下走。
            playbackQueueRefBuilder: (galleryId) => PlaybackQueueRef(
              queueId: PlaybackQueueService.to.openFavoriteGalleries().queueId,
              currentItemId: galleryId,
            ),
            isMultiSelectMode: widget.isMultiSelectMode,
            isSelected: widget.selectedItemIds.contains(image.id),
            onSelect: () => widget.onItemSelect?.call(image),
          ),
          if (isCanceled)
            // 多选模式下蒙层只作视觉提示，点按落到卡片上去切换选中。
            Positioned.fill(
              child: IgnorePointer(
                ignoring: widget.isMultiSelectMode,
                child: Material(
                  color: Colors.black54,
                  child: InkWell(
                    onTap: () => controller.toggleImageFavorite(image),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.favorites.clickToRestoreFavorite,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          // 多选模式下右上角是选中标记的地盘，爱心键让位
          else if (!widget.isMultiSelectMode)
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.toggleImageFavorite(image),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.favorite, color: Colors.red, size: 24),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
