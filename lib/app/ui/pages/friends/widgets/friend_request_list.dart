import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_request_dto.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/friends/controllers/friends_controller.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FriendRequestList extends StatelessWidget {
  final ScrollController scrollController;

  /// 列表顶部让出的高度（玻璃 header 悬浮在列表之上）。
  final double paddingTop;

  const FriendRequestList({
    super.key,
    required this.scrollController,
    this.paddingTop = 0,
  });

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find();
    final UserService userService = Get.find();

    return RefreshIndicator(
      // 指示器从玻璃 header 下方弹出
      displacement: paddingTop,
      onRefresh: () => controller.requestRepository.refresh(true),
      child: LoadingMoreCustomScrollView(
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
                      _buildAcceptRejectButtons(
                        context,
                        controller,
                        request,
                        fake: true,
                      )
                    else
                      _buildCancelRequestButton(
                        context,
                        controller,
                        request,
                        fake: true,
                      ),
                  ],
                );
              },
              sourceList: controller.requestRepository,
              padding: EdgeInsets.fromLTRB(
                5.0,
                paddingTop,
                5.0,
                MediaQuery.of(context).padding.bottom + 5.0,
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
      ),
    );
  }

  Widget _buildAcceptRejectButtons(
    BuildContext context,
    FriendsController controller,
    UserRequestDTO request, {
    bool fake = false,
  }) {
    final t = slang.Translations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIconButton(
          standalone: true,
          size: 36,
          icon: const Icon(Icons.check_circle, size: 20),
          tooltip: t.common.accept,
          onPressed: fake
              ? null
              : () => controller.acceptFriendRequest(request.id),
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          standalone: true,
          size: 36,
          icon: const Icon(Icons.cancel, size: 20),
          tooltip: t.common.reject,
          onPressed: fake
              ? null
              : () => controller.rejectFriendRequest(request.id),
        ),
      ],
    );
  }

  Widget _buildCancelRequestButton(
    BuildContext context,
    FriendsController controller,
    UserRequestDTO request, {
    bool fake = false,
  }) {
    final t = slang.Translations.of(context);
    return GlassIconButton(
      standalone: true,
      size: 36,
      icon: const Icon(Icons.person_remove, size: 20),
      tooltip: t.common.cancelFriendRequest,
      onPressed: fake
          ? null
          : () {
              controller.cancelFriendRequest(request.target.id);
            },
    );
  }
}
