import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/related_media_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/infinite_scroll_waterfall_tab.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/models/video.model.dart';
import 'package:shimmer/shimmer.dart';

class RelatedVideosTabWidget extends StatefulWidget {
  final MyVideoStateController videoController;
  final RelatedMediasController relatedVideoController;

  /// The outer TabController (detail / comments / related) so that overscroll
  /// at inner tab boundaries can propagate to the outer level.
  final TabController? outerTabController;

  const RelatedVideosTabWidget({
    super.key,
    required this.videoController,
    required this.relatedVideoController,
    this.outerTabController,
  });

  @override
  State<RelatedVideosTabWidget> createState() => _RelatedVideosTabWidgetState();
}

class _RelatedVideosTabWidgetState extends State<RelatedVideosTabWidget>
    with SingleTickerProviderStateMixin {
  static const int _crossAxisCount = 2;
  static const int _skeletonItemCount = 6;

  late TabController _tabController;

  /// Accumulated overscroll at inner tab boundaries (pixels).
  double _accumulatedOverscroll = 0;

  /// Minimum overscroll needed to trigger an outer tab switch.
  static const double _outerSwitchThreshold = 40;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Detects overscroll at inner TabBarView boundaries and propagates
  /// the gesture to the outer TabController.
  bool _handleScrollNotification(ScrollNotification notification) {
    final outer = widget.outerTabController;
    if (outer == null) return false;

    if (notification is OverscrollNotification) {
      _accumulatedOverscroll += notification.overscroll;

      if (!outer.indexIsChanging) {
        // At first inner tab, swiping right → go to previous outer tab
        if (_accumulatedOverscroll < -_outerSwitchThreshold &&
            _tabController.index == 0 &&
            outer.index > 0) {
          _accumulatedOverscroll = 0;
          outer.animateTo(outer.index - 1);
        }
        // At last inner tab, swiping left → go to next outer tab
        else if (_accumulatedOverscroll > _outerSwitchThreshold &&
            _tabController.index == _tabController.length - 1 &&
            outer.index < outer.length - 1) {
          _accumulatedOverscroll = 0;
          outer.animateTo(outer.index + 1);
        }
      }
      return true;
    }

    if (notification is ScrollEndNotification) {
      _accumulatedOverscroll = 0;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Material(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: t.videoDetail.authorOtherVideos),
              Tab(text: t.videoDetail.relatedVideos),
            ],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerHeight: 0,
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Author's Other Videos
                Obx(() {
                  // Always access videoInfo so GetX registers a listener
                  // even when otherController is still null.
                  final _ = widget.videoController.videoInfo.value;
                  final ctrl =
                      widget.videoController.otherAuthorzVideosController;
                  return InfiniteScrollWaterfallTab<Video>(
                    items: ctrl?.videos.toList() ?? const [],
                    isLoading: ctrl?.isLoading.value ?? false,
                    isLoadingMore: ctrl?.isLoadingMore.value ?? false,
                    hasMore: ctrl?.hasMore.value ?? false,
                    onLoadMore: () => ctrl?.loadMore(),
                    available: ctrl != null,
                    crossAxisCount: _crossAxisCount,
                    emptyMessage: t.videoDetail.authorNoOtherVideos,
                    skeletonBuilder: _buildVideoCardSkeleton,
                    skeletonCount: _skeletonItemCount,
                    itemBuilder: (context, video, itemWidth) {
                      return VideoCardListItemWidget(
                        video: video,
                        width: itemWidth,
                      );
                    },
                  );
                }),
                // Tab 2: Related Videos
                Obx(() => InfiniteScrollWaterfallTab<Video>(
                        items: widget.relatedVideoController.videos.toList(),
                        isLoading:
                            widget.relatedVideoController.isLoading.value,
                        isLoadingMore:
                            widget.relatedVideoController.isLoadingMore.value,
                        hasMore: widget.relatedVideoController.hasMore.value,
                        onLoadMore: widget.relatedVideoController.loadMore,
                        crossAxisCount: _crossAxisCount,
                        emptyMessage: t.videoDetail.noRelatedVideos,
                        skeletonBuilder: _buildVideoCardSkeleton,
                        skeletonCount: _skeletonItemCount,
                        itemBuilder: (context, video, itemWidth) {
                          return VideoCardListItemWidget(
                            video: video,
                            width: itemWidth,
                          );
                        },
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCardSkeleton(BuildContext context, double width) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final radius = BorderRadius.circular(14);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: radius,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: width * 0.38,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: width * 0.9,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: width * 0.65,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
