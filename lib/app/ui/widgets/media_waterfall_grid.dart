import 'package:flutter/material.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

/// Builder that receives the calculated item width for each child.
typedef WaterfallItemBuilder = Widget Function(
  BuildContext context,
  int index,
  double itemWidth,
);

/// A non-scrollable waterfall flow grid for embedding inside scrollable parents
/// (e.g. [SingleChildScrollView] > [Column]).
///
/// Uses [CustomScrollView] + [SliverWaterfallFlow] internally to avoid the
/// top-padding issue present in [WaterfallFlow.builder] (which extends
/// [BoxScrollView] and applies [MediaQuery.removePadding]).
class MediaWaterfallGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final WaterfallItemBuilder itemBuilder;

  const MediaWaterfallGrid({
    super.key,
    required this.crossAxisCount,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisSpacing = MediaLayoutUtils.crossAxisSpacing;
    final mainAxisSpacing = MediaLayoutUtils.mainAxisSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) /
            crossAxisCount;

        return CustomScrollView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverWaterfallFlow(
              delegate: SliverChildBuilderDelegate(
                (context, index) => itemBuilder(context, index, itemWidth),
                childCount: itemCount,
              ),
              gridDelegate:
                  SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A sliver-based waterfall flow for use inside [CustomScrollView].
class MediaWaterfallSliver extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final WaterfallItemBuilder itemBuilder;

  const MediaWaterfallSliver({
    super.key,
    required this.crossAxisCount,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisSpacing = MediaLayoutUtils.crossAxisSpacing;
    final mainAxisSpacing = MediaLayoutUtils.mainAxisSpacing;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.crossAxisExtent -
                (crossAxisCount - 1) * crossAxisSpacing) /
            crossAxisCount;

        return SliverWaterfallFlow(
          delegate: SliverChildBuilderDelegate(
            (context, index) => itemBuilder(context, index, itemWidth),
            childCount: itemCount,
          ),
          gridDelegate:
              SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
        );
      },
    );
  }
}
