import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/compact_subscription_dropdown.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_select_list_widget.dart';
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

  // 滚动进度值，0.0表示未折叠，1.0表示完全折叠
  double _scrollProgress = 0.0;
  // 最大折叠高度
  static const double _maxCollapsibleHeight = 60.0;
  
  // 定义常量
  static const double _tabBarHeight = 48.0;
  static const double _headerExpandedHeight = 56.0;
  static const double _userListHeight = 80.0;

  // 动态内边距RX变量，用于实时更新paddingTop
  final RxDouble _dynamicPaddingTop = 0.0.obs;

  final ScrollController _extendedScrollController = ScrollController();
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

    // 添加滚动监听器
    _extendedScrollController.addListener(_onExtendedScroll);

    mediaListController = Get.put(MediaListController());

    // 注册滚动回调以接收来自列表的滚动事件
    mediaListController.registerListScrollCallback(_handleListScroll);
    
    // 初始化动态内边距
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDynamicPaddingTop();
    });
  }

  // 处理扩展滚动视图滚动
  void _onExtendedScroll() {
    if (_extendedScrollController.hasClients) {
      final double offset = _extendedScrollController.offset;
      _updateScrollProgress(offset);
    }
  }

  // 处理来自列表的滚动
  void _handleListScroll(double offset) {
    _updateScrollProgress(offset);
  }

  // 更新滚动进度值
  void _updateScrollProgress(double offset) {
    final double progress = (offset / _maxCollapsibleHeight).clamp(0.0, 1.0);
    if (progress != _scrollProgress) {
      setState(() {
        _scrollProgress = progress;
      });
      // 更新动态内边距
      _updateDynamicPaddingTop();
    }
  }
  
  // 更新动态内边距
  void _updateDynamicPaddingTop() {
    // 计算状态栏高度
    double statusBarHeight = MediaQuery.of(context).padding.top;
    // 计算展开/折叠状态下的头部高度
    double expandedHeaderHeight = _headerExpandedHeight;
    double collapsedHeaderHeight = _headerExpandedHeight;
    // 用户列表随滚动进度动态变化的高度
    double userListHeight = _userListHeight * (1 - _scrollProgress);
    
    // 总内边距 = 状态栏 + 头部高度 + 用户列表高度 + TabBar高度
    double totalPaddingTop = statusBarHeight + expandedHeaderHeight + userListHeight + _tabBarHeight;
    
    // 更新动态内边距
    _dynamicPaddingTop.value = totalPaddingTop;
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
    _extendedScrollController.removeListener(_onExtendedScroll);
    _extendedScrollController.dispose();
    _tabBarScrollController.dispose();
    // 注销滚动回调
    mediaListController.unregisterListScrollCallback(_handleListScroll);
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
    // 计算头部区域高度（包含用户选择器部分）
    double expandedHeaderHeight = _headerExpandedHeight + _userListHeight;
    double collapsedHeaderHeight = _headerExpandedHeight;
    double headerHeight = collapsedHeaderHeight + (expandedHeaderHeight - collapsedHeaderHeight) * (1 - _scrollProgress);
    
    final t = slang.Translations.of(context);
    
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
                // 使用动态内边距
                final paddingTop = _dynamicPaddingTop.value;

                return GlowNotificationWidget(
                  key: ValueKey('video_$rebuildKey'),
                  child: SubscriptionVideoList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    // 使用动态计算的paddingTop
                    paddingTop: paddingTop,
                  ),
                );
              }),
              // 图片列表 - 使用全局状态控制器
              Obx(() {
                final isPaginated = mediaListController.isPaginated.value;
                final rebuildKey = mediaListController.rebuildKey.value;
                // 使用动态内边距
                final paddingTop = _dynamicPaddingTop.value;

                return GlowNotificationWidget(
                  key: ValueKey('image_$rebuildKey'),
                  child: SubscriptionImageList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    // 使用动态计算的paddingTop
                    paddingTop: paddingTop,
                  ),
                );
              }),
              // 帖子列表 - 使用全局状态控制器
              Obx(() {
                final isPaginated = mediaListController.isPaginated.value;
                final rebuildKey = mediaListController.rebuildKey.value;
                // 使用动态内边距
                final paddingTop = _dynamicPaddingTop.value;

                return GlowNotificationWidget(
                  key: ValueKey('post_$rebuildKey'),
                  child: SubscriptionPostList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    // 使用动态计算的paddingTop
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 捕获滚动事件，更新折叠状态
              if (notification is ScrollUpdateNotification) {
                _handleListScroll(notification.metrics.pixels);
              }
              return false;
            },
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 系统状态栏高度填充
                      TopPaddingHeightWidget(),
                      
                      // 头像和标题行 - 实现动画过渡
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _scrollProgress > 0.7
                            ? _buildCollapsedHeader()
                            : _buildExpandedHeader(),
                      ),
                      
                      // 订阅用户选择列表 - 会随滚动进度折叠
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        height: _userListHeight * (1 - _scrollProgress),
                        clipBehavior: Clip.none,
                        child: Opacity(
                          opacity: 1 - _scrollProgress,
                          child: Obx(() => _buildSubscriptionList()),
                        ),
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
                                // 先尝试使用控制器滚动所有列表
                                mediaListController.scrollToTop();
                                // 检查_extendedScrollController是否已附加到滚动视图
                                if (_extendedScrollController.hasClients) {
                                  _extendedScrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
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
        ),
      ],
    );
  }

  // 展开状态下的头部布局
  Widget _buildExpandedHeader() {
    return Row(
      children: [
        Obx(() => _buildAvatarButton()),
        Expanded(
          child: Text(
            slang.Translations.of(context).common.subscriptions,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          tooltip: slang.Translations.of(context).common.search,
        ),
      ],
    );
  }

  // 收缩状态下的头部布局 - 包含下拉选择控件
  Widget _buildCollapsedHeader() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
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
          tooltip: slang.Translations.of(context).common.search,
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
                baseColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                highlightColor: Theme.of(context).colorScheme.surface,
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

  // 抽取订阅列表构建方法
  Widget _buildSubscriptionList() {
    final likedUsers = userPreferenceService.likedUsers;

    List<SubscriptionSelectItem> selectionList = likedUsers
        .map((userDto) => SubscriptionSelectItem(
              id: userDto.id,
              label: userDto.name,
              avatarUrl: userDto.avatarUrl,
              onLongPress: () =>
                  NaviService.navigateToAuthorProfilePage(userDto.username),
            ))
        .toList();
    return SubscriptionSelectList(
      userList: selectionList,
      selectedUserId: selectedId,
      onUserSelected: _onUserSelected,
    );
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
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
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

// 添加一个SliverPersistentHeaderDelegate来处理TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({
    required this.child,
  });

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
