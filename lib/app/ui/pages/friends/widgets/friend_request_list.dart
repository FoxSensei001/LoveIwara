import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_request_dto.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/friends/controllers/friends_controller.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:loading_more_list/loading_more_list.dart';

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

              return UserCard(
                user: isTargetSelf ? request.user : request.target,
                showFriendAcceptAndRejectOptions: isTargetSelf,
                showCancelFriendRequestOption: !isTargetSelf,
                onAcceptFriendRequest: controller.acceptFriendRequest,
                onRejectFriendRequest: controller.rejectFriendRequest,
                onCancelFriendRequest: controller.cancelFriendRequest,
                isAcceptingRequest: controller.acceptingRequestIds[request.id] ?? false,
                isRejectingRequest: controller.rejectingRequestIds[request.id] ?? false,
                isCancelingRequest: controller.cancelingRequestIds[request.id] ?? false,
                onTap: () => NaviService.navigateToAuthorProfilePage(request.target.username),
              );
            },
            sourceList: controller.requestRepository,
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
              loadingMoreBase: controller.requestRepository,
            ),
          ),
        ),
      ],
    );
  }
}
