import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/pages/friends/controllers/friends_controller.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class FriendList extends StatelessWidget {
  final ScrollController scrollController;

  const FriendList({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find();
    final t = slang.Translations.of(context);
    
    return RefreshIndicator(
      onRefresh: () => controller.friendRepository.refresh(true),
      child: LoadingMoreCustomScrollView(
        controller: scrollController,
        slivers: [
          LoadingMoreSliverList<User>(
            SliverListConfig<User>(
              itemBuilder: (context, user, index) {
                return UserCard(
                  user: user,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person_remove),
                      color: Colors.red,
                      // onPressed: () => controller.removeFriend(user.id),
                      onPressed: null, // [TODO_PLACEHOLDER]由于移除朋友后刷新页面存在奇怪bug，临时禁用
                      tooltip: t.common.removeFriend,
                    ),
                  ],
                );
              },
              sourceList: controller.friendRepository,
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
                loadingMoreBase: controller.friendRepository,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
