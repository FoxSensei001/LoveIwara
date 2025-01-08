import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../controllers/subscription_post_repository.dart';

class SubscriptionPostList extends StatefulWidget {
  final String userId;

  const SubscriptionPostList({
    super.key,
    required this.userId,
  });

  @override
  SubscriptionPostListState createState() => SubscriptionPostListState();
}

class SubscriptionPostListState extends State<SubscriptionPostList> with AutomaticKeepAliveClientMixin {
  late SubscriptionPostRepository listSourceRepository;

  @override
  void initState() {
    super.initState();
    listSourceRepository = SubscriptionPostRepository(userId: widget.userId);
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  // 提供一个刷新方法给外部调用
  Future<void> refresh() async {
    await listSourceRepository.refresh(true);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadingMoreCustomScrollView(
      slivers: <Widget>[
        LoadingMoreSliverList(
          SliverListConfig<PostModel>(
            extendedListDelegate:
                const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 600,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (BuildContext context, PostModel post, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: PostCardListItemWidget(post: post),
              );
            },
            sourceList: listSourceRepository,
            padding: EdgeInsets.only(
              left: 5.0,
              right: 5.0,
              top: 5.0,
              bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0,
            ),
            lastChildLayoutType: LastChildLayoutType.foot,
            indicatorBuilder: (context, status) => myLoadingMoreIndicator(
              context,
              status,
              isSliver: true,
              loadingMoreBase: listSourceRepository,
            ),
          ),
        ),
      ],
    );
  }
} 