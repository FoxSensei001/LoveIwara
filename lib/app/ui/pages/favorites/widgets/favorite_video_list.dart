import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/favorites/controllers/favorites_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class FavoriteVideoList extends StatefulWidget {
  final ScrollController scrollController;

  const FavoriteVideoList({
    super.key,
    required this.scrollController,
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
    final t = slang.Translations.of(context);
    return LoadingMoreCustomScrollView(
      controller: widget.scrollController,
      slivers: [
        LoadingMoreSliverList<Video>(
          SliverListConfig<Video>(
            extendedListDelegate:
                const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, video, index) {
              return Obx(() {
                final bool isCanceled =
                    controller.canceledFavoriteVideoIds.contains(video.id);
                return Stack(
                  children: [
                    VideoCardListItemWidget(
                      video: video,
                      width: 220,
                    ),
                    if (isCanceled)
                      Positioned.fill(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
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
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              });
            },
            sourceList: controller.videoRepository,
            padding: EdgeInsets.fromLTRB(
              5.0,
              5.0,
              5.0,
              Get.context != null ? MediaQuery.of(Get.context!).padding.bottom + 5.0 : 0,
            ),
            lastChildLayoutType: LastChildLayoutType.foot,
            indicatorBuilder: (context, status) => myLoadingMoreIndicator(
              context,
              status,
              isSliver: true,
              loadingMoreBase: controller.videoRepository,
            ),
          ),
        ),
      ],
    );
  }
} 