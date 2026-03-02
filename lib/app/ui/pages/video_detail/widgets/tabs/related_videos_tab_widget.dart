import 'dart:ui' show ImageFilter;

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
    final topInset = _FloatingTwoTabSwitch.listTopInset;

    return Stack(
      children: [
        Positioned.fill(
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
                    topInset: topInset,
                    itemBuilder: (context, video, itemWidth) {
                      return VideoCardListItemWidget(
                        video: video,
                        width: itemWidth,
                      );
                    },
                  );
                }),
                // Tab 2: Related Videos
                Obx(
                  () => InfiniteScrollWaterfallTab<Video>(
                    items: widget.relatedVideoController.videos.toList(),
                    isLoading: widget.relatedVideoController.isLoading.value,
                    isLoadingMore:
                        widget.relatedVideoController.isLoadingMore.value,
                    hasMore: widget.relatedVideoController.hasMore.value,
                    onLoadMore: widget.relatedVideoController.loadMore,
                    crossAxisCount: _crossAxisCount,
                    emptyMessage: t.videoDetail.noRelatedVideos,
                    skeletonBuilder: _buildVideoCardSkeleton,
                    skeletonCount: _skeletonItemCount,
                    topInset: topInset,
                    itemBuilder: (context, video, itemWidth) {
                      return VideoCardListItemWidget(
                        video: video,
                        width: itemWidth,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _FloatingTwoTabSwitch(
            controller: _tabController,
            leftLabel: t.videoDetail.authorOtherVideos,
            rightLabel: t.videoDetail.relatedVideos,
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

class _FloatingTwoTabSwitch extends StatelessWidget {
  final TabController controller;
  final String leftLabel;
  final String rightLabel;

  const _FloatingTwoTabSwitch({
    required this.controller,
    required this.leftLabel,
    required this.rightLabel,
  });

  static const double _height = 40;
  static const double _radius = 999;
  static const double _paddingHorizontal = 12;
  static const double _paddingTop = 10;
  static const double _paddingBottom = 10;

  /// Top inset for the list content so it starts below the track, but can
  /// still scroll under the (frosted) header area.
  static const double listTopInset = _paddingTop + _height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Material-ish segmented control:
    // - Track background is a frosted glass plate (blur + translucent tint)
    // - Selected segment is a filled pill that slides with TabController
    final trackBorder = colorScheme.outlineVariant.withValues(alpha: 0.55);
    final inactiveText = colorScheme.onSurfaceVariant;

    final leftActiveFill = colorScheme.primaryContainer.withValues(alpha: 0.92);
    final rightActiveFill = colorScheme.secondaryContainer.withValues(
      alpha: 0.92,
    );
    final leftActiveText = colorScheme.onPrimaryContainer;
    final rightActiveText = colorScheme.onSecondaryContainer;

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      letterSpacing: 0.2,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _paddingHorizontal,
        _paddingTop,
        _paddingHorizontal,
        _paddingBottom,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: controller.animation!,
          builder: (context, child) {
            final rawValue =
                controller.animation?.value ?? controller.index.toDouble();
            final value = rawValue.clamp(0.0, 1.0);

            final indicatorColor = Color.lerp(
              leftActiveFill,
              rightActiveFill,
              value,
            )!;

            final leftTextColor = Color.lerp(
              leftActiveText,
              inactiveText,
              value,
            )!;
            final rightTextColor = Color.lerp(
              inactiveText,
              rightActiveText,
              value,
            )!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final segmentWidth = constraints.maxWidth / 2;
                final indicatorLeft = value * segmentWidth;
                final radius = BorderRadius.circular(_radius);

                Widget buildSegmentButton({
                  required String label,
                  required Color textColor,
                  required VoidCallback onTap,
                }) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: radius,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  labelStyle?.copyWith(color: textColor) ??
                                  TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: _height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(
                            alpha: isDark ? 0.32 : 0.16,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      (isDark
                                              ? colorScheme
                                                    .surfaceContainerHighest
                                              : colorScheme.surfaceContainerLow)
                                          .withValues(
                                            alpha: isDark ? 0.28 : 0.78,
                                          ),
                                  borderRadius: radius,
                                  border: Border.all(color: trackBorder),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: radius,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(
                                          alpha: isDark ? 0.06 : 0.18,
                                        ),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: indicatorLeft,
                              top: 0,
                              bottom: 0,
                              width: segmentWidth,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: indicatorColor,
                                    borderRadius: radius,
                                    border: Border.all(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: buildSegmentButton(
                                    label: leftLabel,
                                    textColor: leftTextColor,
                                    onTap: () => controller.animateTo(0),
                                  ),
                                ),
                                Expanded(
                                  child: buildSegmentButton(
                                    label: rightLabel,
                                    textColor: rightTextColor,
                                    onTap: () => controller.animateTo(1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
