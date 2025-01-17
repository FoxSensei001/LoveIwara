import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
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

    return LoadingMoreCustomScrollView(
      controller: scrollController,
      slivers: [
        LoadingMoreSliverList<User>(
          SliverListConfig<User>(
            itemBuilder: (context, user, index) {
              return Obx(() {
                final bool isRemoved =
                    controller.removedFriendIds.contains(user.id);
                return Stack(
                  children: [
                    UserCard(
                      user: user,
                      showFriendOptions: true,
                      onRemoveFriend: controller.removeFriend,
                      isRemovingFriend: controller.removingFriendIds[user.id] ?? false,
                      isRestoringFriend: controller.restoringFriendIds[user.id] ?? false,
                      onTap: () => NaviService.navigateToAuthorProfilePage(user.username),
                    ),
                    if (isRemoved)
                      Positioned.fill(
                        child: Material(
                          color: Colors.black54,
                          child: InkWell(
                            onTap: () => controller.restoreFriend(user.id),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t.friends.clickToRestoreFriend,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              });
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
    );
  }
}
