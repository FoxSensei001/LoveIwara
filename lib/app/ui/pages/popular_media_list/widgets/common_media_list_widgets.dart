import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/shimmer_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 构建加载指示器
Widget? buildIndicator(
  BuildContext context,
  IndicatorStatus status,
  VoidCallback onErrorRefresh, {
  IconData? emptyIcon,
}) {
  Widget? finalWidget;

  // 提取通用的 shimmer grid 构建逻辑
  Widget buildShimmerGrid({required int itemCount}) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? 180 : 200,
        crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
        mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
        childAspectRatio: 1 / 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => buildShimmerItem(
        MediaQuery.of(context).size.width <= 600 ? 180 : 200,
      ),
    );
  }

  switch (status) {
    case IndicatorStatus.none:
      return null;
      
    case IndicatorStatus.loadingMoreBusying:
    case IndicatorStatus.fullScreenBusying:
      final isFullScreen = status == IndicatorStatus.fullScreenBusying;
      final shimmerContent = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: buildShimmerGrid(
          itemCount: isFullScreen ? 8 : (MediaQuery.of(context).size.width <= 600 ? 2 : 6),
        ),
      );
      
      if (isFullScreen) {
        return SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
            ),
            child: shimmerContent,
          ),
        );
      }
      
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
        ),
        child: shimmerContent,
      );

    case IndicatorStatus.error:
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: onErrorRefresh,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    slang.Translations.of(context).conversation.errors.loadFailedClickToRetry,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    case IndicatorStatus.fullScreenError:
      finalWidget = Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
        child: InkWell(
          onTap: onErrorRefresh,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  slang.Translations.of(context).conversation.errors.loadFailed,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slang.Translations.of(context).conversation.errors.clickToRetry,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: finalWidget,
          ),
        ),
      );
    case IndicatorStatus.noMoreLoad:
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            slang.Translations.of(context).common.noMoreDatas,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    case IndicatorStatus.empty:
      finalWidget = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon ?? Icons.image_not_supported,
              size: 48,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              slang.Translations.of(context).common.noData,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: finalWidget),
      );
  }
}

/// 构建骨架屏项目
Widget buildShimmerItem(double width) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ShimmerCard(width: width),
  );
}

/// 构建标签样式
class TagStyle {
  static BorderRadius getBorderRadius({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 1,
  );

  static const TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 10,
    decoration: TextDecoration.none,
  );

  static const double iconSize = 10;
  static const double iconSpacing = 2;
} 