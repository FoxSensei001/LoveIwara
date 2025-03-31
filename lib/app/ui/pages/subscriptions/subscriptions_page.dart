import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/compact_subscription_dropdown.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_video_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../services/app_service.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'controllers/media_list_controller.dart';

class SubscriptionsPage extends StatefulWidget with RefreshableMixin {
  static final globalKey = GlobalKey<SubscriptionsPageState>();

  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => SubscriptionsPageState();

  @override
  void refreshCurrent() {
    final state = globalKey.currentState;
    if (state != null) {
      state.refreshCurrentList();
    }
  }
}

class SubscriptionsPageState extends State<SubscriptionsPage>
    with TickerProviderStateMixin {
  final UserService userService = Get.find<UserService>();
  final UserPreferenceService userPreferenceService =
      Get.find<UserPreferenceService>();
  late final MediaListController mediaListController;

  late TabController _tabController;
  String selectedId = '';
  
  // 定义常量
  static const double _tabBarHeight = 48.0;
  static const double _headerHeight = 56.0;

  final ScrollController _tabBarScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    for (int i = 0; i < 3; i++) {
      _tabKeys.add(GlobalKey());
    }

    _tabController.addListener(_onTabChange);
    mediaListController = Get.put(MediaListController());
  }

  void _onTabChange() {
    _scrollToSelectedTab();
  }

  void _scrollToSelectedTab() {
    final GlobalKey currentTabKey = _tabKeys[_tabController.index];

    final RenderBox? renderBox =
        currentTabKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);

      final screenWidth = MediaQuery.of(context).size.width;
      final tabWidth = renderBox.size.width;

      final targetScroll = _tabBarScrollController.offset +
          position.dx -
          (screenWidth / 2) +
          (tabWidth / 2);

      final double finalScroll = targetScroll.clamp(
        0.0,
        _tabBarScrollController.position.maxScrollExtent,
      );

      _tabBarScrollController.animateTo(
        finalScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleScroll(double delta) {
    if (_tabBarScrollController.hasClients) {
      final double newOffset = _tabBarScrollController.offset + delta;
      if (newOffset < 0) {
        _tabBarScrollController.jumpTo(0);
      } else if (newOffset > _tabBarScrollController.position.maxScrollExtent) {
        _tabBarScrollController
            .jumpTo(_tabBarScrollController.position.maxScrollExtent);
      } else {
        _tabBarScrollController.jumpTo(newOffset);
      }
    }
  }

  void _onUserSelected(String id) {
    if (selectedId != id) {
      setState(() {
        selectedId = id;
      });
    }
  }

  Future<void> refreshCurrentList() async {
    mediaListController.refreshList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabBarScrollController.dispose();
    Get.delete<MediaListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (userService.isLogin) {
        return _buildLoggedInView(context);
      } else {
        return _buildNotLoggedIn(context);
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    final t = slang.Translations.of(context);
    final paddingTop = MediaQuery.of(context).padding.top + _headerHeight + _tabBarHeight;
    
    return Stack(
      children: [
        // 1. 底层TabBarView - 覆盖整个屏幕
        Positioned.fill(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 视频列表 - 使用全局状态控制器
              Obx(() {
                final isPaginated = mediaListController.isPaginated.value;
                final rebuildKey = mediaListController.rebuildKey.value;

                return GlowNotificationWidget(
                  key: ValueKey('video_$rebuildKey'),
                  child: SubscriptionVideoList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    paddingTop: paddingTop,
                  ),
                );
              }),
              // 图片列表 - 使用全局状态控制器
              Obx(() {
                final isPaginated = mediaListController.isPaginated.value;
                final rebuildKey = mediaListController.rebuildKey.value;

                return GlowNotificationWidget(
                  key: ValueKey('image_$rebuildKey'),
                  child: SubscriptionImageList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    paddingTop: paddingTop,
                  ),
                );
              }),
              // 帖子列表 - 使用全局状态控制器
              Obx(() {
                final isPaginated = mediaListController.isPaginated.value;
                final rebuildKey = mediaListController.rebuildKey.value;

                return GlowNotificationWidget(
                  key: ValueKey('post_$rebuildKey'),
                  child: SubscriptionPostList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    paddingTop: paddingTop,
                  ),
                );
              }),
            ],
          ),
        ),
        
        // 2. 顶部悬浮区域 - 带毛玻璃效果
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 系统状态栏高度填充
                    const SafeArea(child: SizedBox()),
                    
                    // 头像和用户选择器
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removed spaceBetween
                      children: [
                        // 喜欢的用户选择器
                        Obx(() {
                          final likedUsers = userPreferenceService.likedUsers;
                          List<SubscriptionDropdownItem> userDropdownItems = likedUsers
                              .map((userDto) => SubscriptionDropdownItem(
                                    id: userDto.id,
                                    label: userDto.name,
                                    avatarUrl: userDto.avatarUrl,
                                    onLongPress: () =>
                                        NaviService.navigateToAuthorProfilePage(
                                            userDto.username),
                                  ))
                              .toList();

                          return CompactSubscriptionDropdown(
                            userList: userDropdownItems,
                            selectedUserId: selectedId,
                            onUserSelected: _onUserSelected,
                          );
                        }),
                        const Spacer(), // Added Spacer to push icons to the right
                        // 设置按钮
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Get.isDarkMode ? Colors.white : null,
                          ),
                          onPressed: () {
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        // 搜索按钮
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            SearchSegment segment;
                            switch (_tabController.index) {
                              case 0:
                                segment = SearchSegment.video;
                                break;
                              case 1:
                                segment = SearchSegment.image;
                                break;
                              case 2:
                                segment = SearchSegment.post;
                                break;
                              default:
                                segment = SearchSegment.video;
                            }

                            Get.dialog(SearchDialog(
                              initialSearch: '',
                              initialSegment: segment,
                              onSearch: (searchInfo, segment) {
                                NaviService.toSearchPage(
                                  searchInfo: searchInfo,
                                  segment: segment,
                                );
                              },
                            ));
                          },
                          tooltip: t.common.search,
                        ),
                      ],
                    ),
                    
                    // TabBar 区域
                    Container(
                      height: _tabBarHeight,
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              child: Listener(
                                onPointerSignal: (pointerSignal) {
                                  if (pointerSignal is PointerScrollEvent) {
                                    _handleScroll(pointerSignal.scrollDelta.dy);
                                  }
                                },
                                child: SingleChildScrollView(
                                  controller: _tabBarScrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  child: TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
                                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                                    tabAlignment: TabAlignment.start,
                                    dividerColor: Colors.transparent,
                                    labelStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    tabs: [
                                      Tab(
                                        key: _tabKeys[0],
                                        text: t.common.video,
                                      ),
                                      Tab(
                                        key: _tabKeys[1],
                                        text: t.common.gallery,
                                      ),
                                      Tab(
                                        key: _tabKeys[2],
                                        text: t.common.post,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 置顶按钮
                          IconButton(
                            icon: const Icon(Icons.vertical_align_top),
                            onPressed: () {
                              // 滚动所有列表到顶部
                              mediaListController.scrollToTop();
                            },
                          ),
                          // 添加分页模式切换按钮
                          Obx(() => IconButton(
                            icon: Icon(mediaListController.isPaginated.value
                                ? Icons.grid_view
                                : Icons.menu),
                            onPressed: () {
                              // 切换分页模式
                              mediaListController.setPaginatedMode(
                                  !mediaListController.isPaginated.value);
                            },
                            tooltip: mediaListController.isPaginated.value
                                ? t.common.pagination.waterfall
                                : t.common.pagination.pagination,
                          )),
                          // 刷新按钮
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: refreshCurrentList,
                            tooltip: t.common.refresh,
                          ),
                        ],
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
  }

  // 抽取头像按钮构建方法
  Widget _buildAvatarButton() {
    if (userService.isLogining.value) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => AppService.switchGlobalDrawer(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface,
                highlightColor: Theme.of(context).colorScheme.surfaceContainer,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (userService.isLogin) {
      return Stack(
        children: [
          IconButton(
            icon: AvatarWidget(user: userService.currentUser.value, size: 40),
            onPressed: () => AppService.switchGlobalDrawer(),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Obx(() {
              final count = userService.notificationCount.value +
                  userService.messagesCount.value;
              if (count > 0) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: () => AppService.switchGlobalDrawer(),
      );
    }
  }

  Widget _buildLoggedInView(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopPaddingHeightWidget(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.signIn.pleaseLoginFirst,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.subscriptions.pleaseLoginFirstToViewYourSubscriptions,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.LOGIN),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          minimumSize: const Size(200, 0),
                        ),
                        child: Text(
                          t.auth.login,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
