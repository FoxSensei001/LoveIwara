import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/friends/controllers/friends_controller.dart';
import 'package:i_iwara/app/ui/pages/friends/widgets/friend_list.dart';
import 'package:i_iwara/app/ui/pages/friends/widgets/friend_request_list.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late FriendsController _controller;
  late TabController _tabController;
  late UserService _userService;

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = Get.put(FriendsController());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _userService = Get.find<UserService>();

    // 两个 tab 各持一个滚动控制器（在 controller 里），共用同一个监听
    _controller.friendListScrollController.addListener(_onScroll);
    _controller.requestListScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 先摘监听再 Get.delete（delete 会连带 dispose 掉两个滚动控制器）
    _controller.friendListScrollController.removeListener(_onScroll);
    _controller.requestListScrollController.removeListener(_onScroll);
    _tabController.removeListener(_onTabChanged);

    _userService.refreshNotificationCount();

    _tabController.dispose();
    _showBackToTop.dispose();
    Get.delete<FriendsController>();
    super.dispose();
  }

  ScrollController get _activeScrollController => _tabController.index == 0
      ? _controller.friendListScrollController
      : _controller.requestListScrollController;

  void _onTabChanged() {
    // 动画途中 indexIsChanging 为 true，只关心落定后的那次
    if (_tabController.indexIsChanging) return;
    if (mounted) setState(() {});
    _syncBackToTop();
  }

  void _onScroll() {
    final active = _activeScrollController;
    if (active.hasClients) {
      _showBackToTop.value = active.position.pixels >= 300;
    }
  }

  void _syncBackToTop() {
    final active = _activeScrollController;
    _showBackToTop.value = active.hasClients && active.position.pixels >= 300;
  }

  void _scrollToTop() {
    final active = _activeScrollController;
    if (active.hasClients) {
      active.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _refreshCurrentTab() =>
      _controller.refreshCurrentTab(_tabController.index);

  /// 右侧动作胶囊：刷新；刷新中图标原位换成沙漏并置灰（GlassIconButton.loading）。
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final bool isLoading = _tabController.index == 0
          ? _controller.isLoadingFriends.value
          : _controller.isLoadingRequests.value;
      return GlassButtonGroup(
        children: [
          GlassIconButton(
            icon: const Icon(Icons.refresh),
            loading: isLoading,
            tooltip: t.common.refresh,
            onPressed: _refreshCurrentTab,
          ),
        ],
      );
    });
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            offset: visible ? Offset.zero : const Offset(0, 0.4),
            child: AnimatedOpacity(
              duration: GlassTokens.motionDuration,
              opacity: visible ? 1 : 0,
              child: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.vertical_align_top),
                tooltip: t.common.scrollToTop,
                onPressed: _scrollToTop,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    final tabItems = [
      GlassSegmentItem(
        label: t.friends.friendsList,
        icon: const Icon(Icons.people),
      ),
      GlassSegmentItem(
        label: t.friends.friendRequests,
        icon: const Icon(Icons.person_add),
      ),
    ];

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            FriendList(
              scrollController: _controller.friendListScrollController,
              paddingTop: headerExtent,
            ),
            FriendRequestList(
              scrollController: _controller.requestListScrollController,
              paddingTop: headerExtent,
            ),
          ],
        ),
        // header 行：左 返回圆钮 / 中 分段胶囊（好友/请求）/ 右 刷新胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GlassSegmentedControl(
                    selectedIndex: _tabController.index,
                    progress: _tabController.animation,
                    onChanged: _tabController.animateTo,
                    items: tabItems,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context),
            ],
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }
}
