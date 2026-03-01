import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/media_waterfall_grid.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// A reusable tab body widget that renders items in an infinite-scroll
/// waterfall grid. Generic on [T] — the model type.
class InfiniteScrollWaterfallTab<T> extends StatelessWidget {
  /// Current items to display.
  final List<T> items;

  /// Whether the initial fetch is in progress.
  final bool isLoading;

  /// Whether a "load more" request is in flight.
  final bool isLoadingMore;

  /// Whether there are more pages to fetch.
  final bool hasMore;

  /// Called when the user scrolls near the bottom.
  final VoidCallback onLoadMore;

  /// Builds the card widget for each item.
  final Widget Function(BuildContext context, T item, double itemWidth)
      itemBuilder;

  /// Number of columns in the waterfall grid.
  final int crossAxisCount;

  /// Message shown when the list is empty after loading.
  final String emptyMessage;

  /// Set to false while the data source (e.g. author controller) is null /
  /// not yet available. Shows skeleton in that case.
  final bool available;

  /// Optional skeleton card builder for the loading state.
  final Widget Function(BuildContext context, double itemWidth)?
      skeletonBuilder;

  /// Number of skeleton items to show during loading.
  final int skeletonCount;

  static const double _horizontalPadding = 5.0;

  const InfiniteScrollWaterfallTab({
    super.key,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    required this.emptyMessage,
    this.available = true,
    this.skeletonBuilder,
    this.skeletonCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    // Loading / not available → show skeleton
    if (!available || isLoading) {
      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _horizontalPadding,
            ),
            sliver: _buildSkeletonSliver(),
          ),
        ],
      );
    }

    // Empty state
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.collections_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Data state with infinite scroll
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification) {
          if (notification.metrics.pixels + 200 >=
                  notification.metrics.maxScrollExtent &&
              notification.metrics.maxScrollExtent > 0) {
            onLoadMore();
          }
        }
        return false;
      },
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _horizontalPadding,
            ),
            sliver: MediaWaterfallSliver(
              crossAxisCount: crossAxisCount,
              itemCount: items.length,
              itemBuilder: (context, index, itemWidth) {
                return itemBuilder(context, items[index], itemWidth);
              },
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (!hasMore && items.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    t.common.noMoreDatas,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SafeArea(child: SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _buildSkeletonSliver() {
    if (skeletonBuilder != null) {
      return MediaWaterfallSliver(
        crossAxisCount: crossAxisCount,
        itemCount: skeletonCount,
        itemBuilder: (context, index, itemWidth) {
          return skeletonBuilder!(context, itemWidth);
        },
      );
    }

    // Default skeleton
    return MediaWaterfallSliver(
      crossAxisCount: crossAxisCount,
      itemCount: skeletonCount,
      itemBuilder: (context, index, itemWidth) {
        return _DefaultSkeleton(width: itemWidth);
      },
    );
  }
}

class _DefaultSkeleton extends StatelessWidget {
  final double width;
  const _DefaultSkeleton({required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.35,
    );
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: radius),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: width * 0.9,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width * 0.65,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
