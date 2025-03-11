import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../controllers/subscription_post_repository.dart';

class SubscriptionPostList extends StatefulWidget {
  final String userId;
  final bool isPaginated;
  final ScrollController? scrollController;

  const SubscriptionPostList({
    super.key,
    required this.userId,
    this.isPaginated = false,
    this.scrollController,
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
  void didUpdateWidget(SubscriptionPostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      listSourceRepository = SubscriptionPostRepository(userId: widget.userId);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    if (widget.isPaginated) {
      setState(() {});
    } else {
      await listSourceRepository.refresh(true);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final mediaListView = MediaListView<PostModel>(
      sourceList: listSourceRepository,
      emptyIcon: Icons.article_outlined,
      isPaginated: widget.isPaginated,
      scrollController: widget.scrollController,
      extendedListDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? 400 : 600,
        crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
        mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
      ),
      itemBuilder: (context, post, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 4,
          ),
          child: PostCardListItemWidget(post: post),
        );
      },
    );
    
    return RefreshIndicator(
      onRefresh: refresh,
      child: mediaListView,
    );
  }
}
