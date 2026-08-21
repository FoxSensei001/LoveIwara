import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/favorites/controllers/favorites_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FavoriteVideoList extends StatefulWidget {
  final ScrollController scrollController;

  /// 列表顶部让出的高度（玻璃 header 悬浮在列表之上）。
  final double paddingTop;

  /// 瀑布流 ↔ 分页。
  final bool isPaginated;

  /// 外部刷新信号：分页模式必须由 MediaListView 自己刷新，直接刷数据源只会换掉
  /// 底层数据、不会换掉当前显示的那一页。
  final ValueListenable<int>? refreshSignal;

  final bool isMultiSelectMode;
  final Set<String> selectedItemIds;
  final void Function(Video video)? onItemSelect;

  /// 分页翻页后回调（用于重置多选）。
  final VoidCallback? onPageChanged;

  final Future<void> Function({
    required String videoId,
    required List<Video> loadedVideos,
    required Video initialVideo,
    Map<String, dynamic>? extData,
  })?
  onOpenVideo;

  const FavoriteVideoList({
    super.key,
    required this.scrollController,
    this.paddingTop = 0,
    this.isPaginated = false,
    this.refreshSignal,
    this.isMultiSelectMode = false,
    this.selectedItemIds = const {},
    this.onItemSelect,
    this.onPageChanged,
    this.onOpenVideo,
  });

  @override
  State<FavoriteVideoList> createState() => _FavoriteVideoListState();
}

class _FavoriteVideoListState extends State<FavoriteVideoList>
    with AutomaticKeepAliveClientMixin {
  final FavoritesController controller = Get.find();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MediaListView<Video>(
      sourceList: controller.videoRepository,
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
      itemBuilder: (context, video, index) => _buildItem(context, video),
    );
  }

  Widget _buildItem(BuildContext context, Video video) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final bool isCanceled = controller.canceledFavoriteVideoIds.contains(
        video.id,
      );
      return Stack(
        children: [
          VideoCardListItemWidget(
            video: video,
            width: 220,
            isMultiSelectMode: widget.isMultiSelectMode,
            isSelected: widget.selectedItemIds.contains(video.id),
            onSelect: () => widget.onItemSelect?.call(video),
            onOpenVideo: widget.onOpenVideo == null
                ? null
                : ({required videoId, Map<String, dynamic>? extData}) {
                    return widget.onOpenVideo!(
                      videoId: videoId,
                      loadedVideos: List<Video>.of(controller.videoRepository),
                      initialVideo: video,
                      extData: extData,
                    );
                  },
          ),
          if (isCanceled)
            // 多选模式下蒙层只作视觉提示：点按要落到卡片上去切换选中，
            // 否则「已取消」的项在多选里就永远选不上、也取消不掉选中。
            Positioned.fill(
              child: IgnorePointer(
                ignoring: widget.isMultiSelectMode,
                child: Material(
                  color: Colors.black54,
                  child: InkWell(
                    onTap: () => controller.toggleVideoFavorite(video),
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
                  onTap: () => controller.toggleVideoFavorite(video),
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
