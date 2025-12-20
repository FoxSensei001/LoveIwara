import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/followers_list.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/following_list.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/special_follows_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FollowsPage extends StatefulWidget {
  final String userId;
  final String name;
  final String username;
  final bool initIsFollowing;
  final int? initialIndex;

  const FollowsPage({
    super.key,
    required this.userId,
    required this.name,
    required this.username,
    required this.initIsFollowing,
    this.initialIndex,
  });

  @override
  State<FollowsPage> createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FollowsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      FollowsController(
        userId: widget.userId,
        initIsFollowing: widget.initIsFollowing,
      ),
      tag: widget.userId,
    );
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex ?? (widget.initIsFollowing ? 0 : 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<FollowsController>(tag: widget.userId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text([widget.name, '@${widget.username}'].join(' - ')),
        bottom: TabBar(
          // 使用Material 3风格的指示器
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Theme.of(context).colorScheme.primary,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          // 标签样式
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          // 取消标签的内边距，让整个区域都可点击
          padding: EdgeInsets.zero,
          controller: _tabController,
          tabs: [
            Tab(text: t.common.following),
            Tab(text: t.common.fans),
            Tab(text: t.common.specialFollowed),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FollowingList(
            scrollController: controller.followingListScrollController,
            controller: controller,
          ),
          FollowersList(
            scrollController: controller.followersListScrollController,
            controller: controller,
          ),
          SpecialFollowsList(controller: controller),
        ],
      ),
    );
  }
}
