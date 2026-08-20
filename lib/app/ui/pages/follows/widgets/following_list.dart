import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FollowingList extends StatefulWidget {
  final ScrollController scrollController;
  final FollowsController controller;

  /// 列表顶部让出的高度（玻璃 header 悬浮在列表之上）。
  final double paddingTop;

  /// 分页模式（false = 瀑布/无限滚动）。
  final bool isPaginated;

  /// 外部刷新信号：分页模式必须由 MediaListView 自己刷新，
  /// 直接 `repository.refresh()` 只会动数据源、不会换掉当前显示的那一页。
  final ValueListenable<int>? refreshSignal;

  const FollowingList({
    super.key,
    required this.scrollController,
    required this.controller,
    this.paddingTop = 0,
    this.isPaginated = false,
    this.refreshSignal,
  });

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MediaListView<User>(
      sourceList: widget.controller.followingRepository,
      isPaginated: widget.isPaginated,
      refreshSignal: widget.refreshSignal,
      scrollController: widget.scrollController,
      paddingTop: widget.paddingTop,
      emptyIcon: Icons.person_add_alt_1_outlined,
      // 用户卡是通栏条目：窄屏一列，宽屏才分列
      extendedListDelegate:
          const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 600,
            crossAxisSpacing: 5,
            mainAxisSpacing: 0,
          ),
      // 接口返回的关注/被关注状态不可靠，这里只做纯列表展示，不露出关注按钮
      itemBuilder: (context, user, index) => UserCard(user: user),
    );
  }
}
