import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/pages/friends/controllers/friends_controller.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FriendList extends StatelessWidget {
  final ScrollController scrollController;

  /// 列表顶部让出的高度（玻璃 header 悬浮在列表之上）。
  final double paddingTop;

  const FriendList({
    super.key,
    required this.scrollController,
    this.paddingTop = 0,
  });

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find();
    final t = slang.Translations.of(context);

    return RefreshIndicator(
      // 指示器从玻璃 header 下方弹出
      displacement: paddingTop,
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
                    GlassIconButton(
                      standalone: true,
                      size: 36,
                      icon: const Icon(Icons.person_remove, size: 20),
                      tooltip: t.common.removeFriend,
                      // [TODO_PLACEHOLDER]由于移除朋友后刷新页面存在奇怪bug，临时禁用
                      onPressed: null,
                    ),
                  ],
                );
              },
              sourceList: controller.friendRepository,
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
                loadingMoreBase: controller.friendRepository,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
