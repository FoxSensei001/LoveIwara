import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'common_media_list_widgets.dart';

class MediaListView<T> extends StatelessWidget {
  final LoadingMoreBase<T> sourceList;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final IconData? emptyIcon;

  const MediaListView({
    super.key,
    required this.sourceList,
    required this.itemBuilder,
    this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingMoreCustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        LoadingMoreSliverList(
          SliverListConfig<T>(
            extendedListDelegate:
                SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? MediaQuery.of(context).size.width / 2 : 200,
              crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
              mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
            ),
            itemBuilder: itemBuilder,
            sourceList: sourceList,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0,
            ),
            lastChildLayoutType: LastChildLayoutType.foot,
            indicatorBuilder: (context, status) => buildIndicator(
              context,
              status,
              () => sourceList.errorRefresh(),
              emptyIcon: emptyIcon,
            ),
          ),
        ),
      ],
    );
  }
} 