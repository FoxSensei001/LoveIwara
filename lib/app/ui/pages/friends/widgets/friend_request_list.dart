import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_request_dto.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/friends/controllers/friends_controller.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FriendRequestList extends StatelessWidget {
  final ScrollController scrollController;

  const FriendRequestList({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find();
    final UserService userService = Get.find();

    return LoadingMoreCustomScrollView(
      controller: scrollController,
      slivers: [
        LoadingMoreSliverList<UserRequestDTO>(
          SliverListConfig<UserRequestDTO>(
            itemBuilder: (context, request, index) {
              final bool isTargetSelf =
                  request.target.id == userService.currentUser.value?.id;
              final user = isTargetSelf ? request.user : request.target;

              return UserCard(
                user: user,
                actions: [
                  // [TODO_PLACEHOLDER]由于移除朋友后刷新页面存在奇怪bug，临时禁用
                  if (isTargetSelf)
                    _buildAcceptRejectButtons(context, controller, request, fake: true)
                  else
                    _buildCancelRequestButton(context, controller, request, fake: true),
                ],
              );
            },
            sourceList: controller.requestRepository,
            padding: EdgeInsets.fromLTRB(
              5.0,
              5.0,
              5.0,
              Get.context != null
                  ? MediaQuery.of(Get.context!).padding.bottom + 5.0
                  : 0,
            ),
            indicatorBuilder: (context, status) => myLoadingMoreIndicator(
              context,
              status,
              isSliver: true,
              loadingMoreBase: controller.requestRepository,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptRejectButtons(
    BuildContext context,
    FriendsController controller,
    UserRequestDTO request,
    {
      bool fake = false,
    }
  ) {
    final t = slang.Translations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle),
          color: Colors.green,
          onPressed: fake ? null : () => controller.acceptFriendRequest(request.id),
          tooltip: t.common.accept,
        ),
        IconButton(
          icon: const Icon(Icons.cancel),
          color: Colors.red,
          onPressed: fake ? null : () => controller.rejectFriendRequest(request.id),
          tooltip: t.common.reject,
        ),
      ],
    );
  }

  Widget _buildCancelRequestButton(
    BuildContext context,
    FriendsController controller,
    UserRequestDTO request,
    {
      bool fake = false,
    }
  ) {
    final t = slang.Translations.of(context);
    return IconButton(
      icon: const Icon(Icons.person_remove),
      color: Colors.orange,
      onPressed: fake ? null : () {
        print('取消好友请求: name: ${request.user.name} userId: ${request.user.id}, target: ${request.target.name} targetId: ${request.target.id}, id: ${request.id}');
        controller.cancelFriendRequest(request.target.id);
      },
      tooltip: t.common.cancelFriendRequest,
    );
  }
}
