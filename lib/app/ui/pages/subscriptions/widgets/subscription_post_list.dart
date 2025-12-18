import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../controllers/subscription_post_repository.dart';
import 'base_subscription_list.dart';

class SubscriptionPostList
    extends BaseSubscriptionList<PostModel, SubscriptionPostRepository> {
  const SubscriptionPostList({
    super.key,
    required super.userId,
    super.isPaginated = false,
    super.paddingTop = 0,
    super.showBottomPadding = false,
  });

  @override
  State<SubscriptionPostList> createState() => SubscriptionPostListState();
}

class SubscriptionPostListState
    extends
        BaseSubscriptionListState<
          PostModel,
          SubscriptionPostRepository,
          SubscriptionPostList
        > {
  @override
  SubscriptionPostRepository createRepository() {
    return SubscriptionPostRepository(userId: widget.userId);
  }

  @override
  IconData get emptyIcon => Icons.article_outlined;

  @override
  SliverWaterfallFlowDelegate get extendedListDelegate =>
      SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      );

  @override
  Widget buildListItem(BuildContext context, PostModel post, int index) {
    return PostCardListItemWidget(post: post);
  }
}
