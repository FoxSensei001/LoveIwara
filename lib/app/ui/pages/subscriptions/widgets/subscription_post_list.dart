import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../controllers/subscription_post_repository.dart';
import 'base_subscription_list.dart';

class SubscriptionPostList extends BaseSubscriptionList<PostModel, SubscriptionPostRepository> {
  const SubscriptionPostList({
    super.key,
    required super.userId,
    super.isPaginated = false,
    super.paddingTop = 0,
  });
  
  @override
  State<SubscriptionPostList> createState() => SubscriptionPostListState();
}

class SubscriptionPostListState extends BaseSubscriptionListState<PostModel, SubscriptionPostRepository, SubscriptionPostList> {
  @override
  SubscriptionPostRepository createRepository() {
    return SubscriptionPostRepository(userId: widget.userId);
  }
  
  @override
  IconData get emptyIcon => Icons.article_outlined;
  
  @override
  SliverWaterfallFlowDelegate get extendedListDelegate => SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? 400 : 600,
    crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
    mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
  );
  
  @override
  Widget buildListItem(BuildContext context, PostModel post, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 4,
      ),
      child: PostCardListItemWidget(post: post),
    );
  }
}
