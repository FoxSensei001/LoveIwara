import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import '../controllers/subscription_post_repository.dart';

class SubscriptionPostList extends StatefulWidget {
  final String userId;
  final bool isPaginated;

  const SubscriptionPostList({
    super.key,
    required this.userId,
    this.isPaginated = false,
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

  Widget? _buildIndicator(BuildContext context, IndicatorStatus status) {
    Widget? widget;
    
    switch (status) {
      case IndicatorStatus.none:
        return null;
      case IndicatorStatus.loadingMoreBusying:
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 4,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: _buildShimmerItem(),
          ),
        );
      case IndicatorStatus.fullScreenBusying:
        widget = Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              top: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
            ),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 4,
              ),
              child: _buildShimmerItem(),
            ),
          ),
        );
        return SliverFillRemaining(child: widget);
      case IndicatorStatus.error:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.errorContainer,
            child: InkWell(
              onTap: () => listSourceRepository.errorRefresh(),
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
                      t.conversation.errors.loadFailedClickToRetry,
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
        widget = Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: () => listSourceRepository.errorRefresh(),
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
                    t.conversation.errors.loadFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.conversation.errors.clickToRetry,
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
              child: widget,
            ),
          ),
        );
      case IndicatorStatus.noMoreLoad:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              t.common.noMoreDatas,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        );
      case IndicatorStatus.empty:
        widget = Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                t.common.noData,
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
          child: Center(child: widget),
        );
    }
  }

  Widget _buildShimmerItem() {
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    return SizedBox(
      height: isSmallScreen ? 180 : 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息骨架
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 4 : 8,
            ),
            child: Row(
              children: [
                // 头像骨架
                Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: isSmallScreen ? 14 : 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: isSmallScreen ? 11 : 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 帖子内容骨架
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 8 : 12,
                0,
                isSmallScreen ? 8 : 12,
                isSmallScreen ? 8 : 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题骨架
                  Container(
                    width: double.infinity,
                    height: isSmallScreen ? 14 : 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  // 内容骨架
                  Container(
                    width: double.infinity,
                    height: isSmallScreen ? 12 : 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: isSmallScreen ? 12 : 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  // 底部信息骨架
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: isSmallScreen ? 11 : 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 80,
                        height: isSmallScreen ? 11 : 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}