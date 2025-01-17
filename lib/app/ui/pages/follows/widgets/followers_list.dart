import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:loading_more_list/loading_more_list.dart';

class FollowersList extends StatefulWidget {
  final ScrollController scrollController;
  final FollowsController controller;

  const FollowersList({
    super.key,
    required this.scrollController,
    required this.controller,
  });

  @override
  State<FollowersList> createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return LoadingMoreCustomScrollView(
      controller: widget.scrollController,
      slivers: [
        LoadingMoreSliverList<User>(
          SliverListConfig<User>(
            itemBuilder: (context, user, index) {
              return UserCard(
                user: user,
                onTap: () => widget.controller.navigateToUserProfile(user.username),
                showFollowButton: false,
              );
            },
            sourceList: widget.controller.followersRepository,
            padding: EdgeInsets.fromLTRB(
              5.0,
              5.0,
              5.0,
              Get.context != null ? MediaQuery.of(Get.context!).padding.bottom + 5.0 : 0,
            ),
            indicatorBuilder: (context, status) => myLoadingMoreIndicator(
              context,
              status,
              isSliver: true,
              loadingMoreBase: widget.controller.followersRepository,
            ),
          ),
        ),
      ],
    );
  }
} 