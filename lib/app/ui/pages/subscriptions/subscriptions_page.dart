import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart'; // 用于 ScrollDirection
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/compact_subscription_dropdown.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_video_list.dart';
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../services/app_service.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';

import 'dart:ui';
import 'controllers/media_list_controller.dart';

class SubscriptionsPage extends StatefulWidget implements HomeWidgetInterface {
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
  static const double _userSelectorRowHeight = 56.0; // 用户选择器/图标行的实际高度
  static const double _tabBarActualHeight = 48.0; // TabBar 本身的高度

  final ScrollController _tabBarScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  // 添加节流器避免频繁处理滚动事件
  DateTime _lastScrollTime = DateTime.now();
  static const Duration _scrollThrottleDuration = Duration(milliseconds: 16);

  // 头部折叠状态
  bool _isHeaderCollapsed = false;
  final double _headerCollapseThreshold = 50.0; // 触发折叠/展开的滚动阈值（像素）

  // 头部滚动监听器
  VoidCallback? _scrollListenerDisposer;

  // 打开搜索对话框
  void _openSearchDialog() {
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

    Get.dialog(
      SearchDialog(
        initialSearch: '',
        initialSegment: segment,
        onSearch: (searchInfo, segment) {
          NaviService.toSearchPage(searchInfo: searchInfo, segment: segment);
        },
      ),
    );
  }

  // 显示用户选择对话框
  void _showUserSelectionDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    final likedUsers = userPreferenceService.likedUsers;

    if (likedUsers.isEmpty) {
      Get.snackbar(
        t.common.notice,
        t.subscriptions.noSubscribedUsers,
        snackPosition: SnackPosition.top,
      );
      return;
    }

    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 对话框标题
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.subscriptions.selectUser,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 用户列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: likedUsers.length,
                  itemBuilder: (context, index) {
                    final user = likedUsers[index];
                    final isSelected = selectedId == user.id;

                    return ListTile(
                      leading: AvatarWidget(
                        avatarUrl: user.avatarUrl,
                        size: 40,
                      ),
                      title: Text(user.name),
                      subtitle: Text('@${user.username}'),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        _onUserSelected(user.id);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      onLongPress: () {
                        NaviService.navigateToAuthorProfilePage(user.username);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    for (int i = 0; i < 3; i++) {
      _tabKeys.add(GlobalKey());
    }

    _tabController.addListener(_onTabChange);
    mediaListController = Get.put(MediaListController());

    // 监听 MediaListController 的滚动变化
    _scrollListenerDisposer = ever(mediaListController.currentScrollOffset, (
      double offset,
    ) {
      final direction = mediaListController.lastScrollDirection.value;
      bool shouldCollapse = _isHeaderCollapsed;

      if (direction == ScrollDirection.reverse && // 向上滚动
          offset > _headerCollapseThreshold &&
          !_isHeaderCollapsed) {
        shouldCollapse = true;
      } else if (direction == ScrollDirection.forward && _isHeaderCollapsed) {
        // 向下滚动
        // 如果向下滚动足够或接近顶部，则展开
        if (offset < (_headerCollapseThreshold * 0.8) || offset < 10.0) {
          shouldCollapse = false;
        }
      } else if (offset <= 5.0 && _isHeaderCollapsed) {
        // 如果在顶部或接近顶部，则始终展开
        shouldCollapse = false;
      }

      // 仅在用户滚动时更新状态，忽略因 tab 切换等编程方式触发的滚动重置
      if (direction != ScrollDirection.idle &&
          mounted &&
          _isHeaderCollapsed != shouldCollapse) {
        setState(() {
          _isHeaderCollapsed = shouldCollapse;
        });
      }
    }).call;
  }

  void _onTabChange() {
    _scrollToSelectedTab();

    // 切换 tab 时不再强制展开顶部区域
    // if (_isHeaderCollapsed) {
    //   setState(() {
    //     _isHeaderCollapsed = false;
    //   });
    // }

    // 重置滚动状态，让新的 tab 从正确的状态开始
    mediaListController.currentScrollOffset.value = 0.0;
    mediaListController.lastScrollDirection.value = ScrollDirection.idle;
  }

  void _scrollToSelectedTab() {
    // 添加节流以减少不必要的滚动计算
    final now = DateTime.now();
    if (now.difference(_lastScrollTime) < _scrollThrottleDuration) {
      return;
    }
    _lastScrollTime = now;

    final GlobalKey currentTabKey = _tabKeys[_tabController.index];

    final RenderBox? renderBox =
        currentTabKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null && _tabBarScrollController.hasClients) {
      final position = renderBox.localToGlobal(Offset.zero);

      final screenWidth = MediaQuery.of(context).size.width;
      final tabWidth = renderBox.size.width;

      final targetScroll =
          _tabBarScrollController.offset +
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
    // 添加节流以减少滚动事件处理频率
    final now = DateTime.now();
    if (now.difference(_lastScrollTime) < _scrollThrottleDuration) {
      return;
    }
    _lastScrollTime = now;

    if (_tabBarScrollController.hasClients) {
      final double newOffset = _tabBarScrollController.offset + delta;
      if (newOffset < 0) {
        _tabBarScrollController.jumpTo(0);
      } else if (newOffset > _tabBarScrollController.position.maxScrollExtent) {
        _tabBarScrollController.jumpTo(
          _tabBarScrollController.position.maxScrollExtent,
        );
      } else {
        _tabBarScrollController.jumpTo(newOffset);
      }
    }
  }

  void _onUserSelected(String id) {
    if (selectedId != id) {
      setState(() {
        selectedId = id;
        // 切换用户时也展开顶部区域，确保新内容正确显示
        _isHeaderCollapsed = false;
      });
      // Reset header state when user changes, as new data will load
      mediaListController.currentScrollOffset.value = 0.0;
      mediaListController.lastScrollDirection.value = ScrollDirection.idle;
    }
  }

  Future<void> refreshCurrentList() async {
    mediaListController.refreshList();
  }

  @override
  void dispose() {
    _scrollListenerDisposer?.call(); // 销毁监听器
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
    final systemStatusBarHeight = MediaQuery.of(context).padding.top;

    // 根据折叠状态计算动态高度
    final double currentTopBarVisibleHeight = _isHeaderCollapsed
        ? _tabBarActualHeight
        : (_userSelectorRowHeight + _tabBarActualHeight);

    final double listPaddingTop =
        systemStatusBarHeight + currentTopBarVisibleHeight;

    final isPaginated = mediaListController.isPaginated.value;
    final rebuildKey = mediaListController.rebuildKey.value;

    return Stack(
      children: [
        // 1. 底部 TabBarView - 需要动态内边距
        Positioned.fill(
          child: RepaintBoundary(
            child: TabBarView(
              controller: _tabController,
              physics: const ClampingScrollPhysics(), // 允许手势滑动切换标签
              children: [
                // 视频列表
                GlowNotificationWidget(
                  key: ValueKey(
                    'video_${selectedId}_${isPaginated}_$rebuildKey',
                  ),
                  child: SubscriptionVideoList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    paddingTop: listPaddingTop,
                  ),
                ),
                // 图片列表
                GlowNotificationWidget(
                  key: ValueKey(
                    'image_${selectedId}_${isPaginated}_$rebuildKey',
                  ),
                  child: SubscriptionImageList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    paddingTop: listPaddingTop,
                  ),
                ),
                // 帖子列表
                GlowNotificationWidget(
                  key: ValueKey(
                    'post_${selectedId}_${isPaginated}_$rebuildKey',
                  ),
                  child: SubscriptionPostList(
                    userId: selectedId,
                    isPaginated: isPaginated,
                    paddingTop: listPaddingTop,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. 顶部浮动头部区域 - 动画其高度和内容
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            // 对 BackdropFilter 很重要
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: AnimatedContainer(
                // 动画头部整体高度
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: systemStatusBarHeight + currentTopBarVisibleHeight,
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 系统状态栏高度内边距
                    SizedBox(height: systemStatusBarHeight),

                    // 用户选择器和图标行 - 动画其不透明度和 Offstage 状态
                    AnimatedOpacity(
                      opacity: _isHeaderCollapsed ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Offstage(
                        offstage: _isHeaderCollapsed,
                        child: SizedBox(
                          // 使用 SizedBox 在不可见时保持布局空间
                          height: _userSelectorRowHeight,
                          child: Row(
                            // 用户选择器、设置、搜索的原始 Row
                            children: [
                              Obx(() {
                                // 保留 Obx 以响应用户列表变化
                                final likedUsers =
                                    userPreferenceService.likedUsers;
                                List<SubscriptionDropdownItem>
                                userDropdownItems = likedUsers
                                    .map(
                                      (userDto) => SubscriptionDropdownItem(
                                        id: userDto.id,
                                        label: userDto.name,
                                        avatarUrl: userDto.avatarUrl,
                                        onLongPress: () =>
                                            NaviService.navigateToAuthorProfilePage(
                                              userDto.username,
                                            ),
                                      ),
                                    )
                                    .toList();
                                return CompactSubscriptionDropdown(
                                  userList: userDropdownItems,
                                  selectedUserId: selectedId,
                                  onUserSelected: _onUserSelected,
                                );
                              }),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.settings,
                                  color: Get.isDarkMode ? Colors.white : null,
                                ),
                                onPressed: () =>
                                    AppService.switchGlobalDrawer(),
                              ),
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

                                  Get.dialog(
                                    SearchDialog(
                                      initialSearch: '',
                                      initialSegment: segment,
                                      onSearch: (searchInfo, segment) {
                                        NaviService.toSearchPage(
                                          searchInfo: searchInfo,
                                          segment: segment,
                                        );
                                      },
                                    ),
                                  );
                                },
                                tooltip: t.common.search,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // TabBar 区域 - 头部始终可见的部分
                    Container(
                      height: _tabBarActualHeight,
                      color: Colors.transparent, // 模糊背景的一部分
                      child: Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              child: Listener(
                                onPointerSignal: (pointerSignal) {
                                  if (pointerSignal is PointerScrollEvent) {
                                    _handleScroll(
                                      pointerSignal.scrollDelta.dy * 2,
                                    ); // 调整的灵敏度乘数
                                  }
                                },
                                child: SingleChildScrollView(
                                  controller: _tabBarScrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  child: TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
                                    overlayColor: WidgetStateProperty.all(
                                      Colors.transparent,
                                    ),
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
                          IconButton(
                            icon: const Icon(Icons.vertical_align_top),
                            onPressed: () => mediaListController.scrollToTop(),
                          ),
                          Obx(
                            () => IconButton(
                              icon: Icon(
                                mediaListController.isPaginated.value
                                    ? Icons.grid_view
                                    : Icons.view_stream,
                              ), // 更改为 view_stream 表示瀑布流
                              onPressed: () {
                                mediaListController.setPaginatedMode(
                                  !mediaListController.isPaginated.value,
                                );
                              },
                              tooltip: mediaListController.isPaginated.value
                                  ? t.common.pagination.waterfall
                                  : t.common.pagination.pagination,
                            ),
                          ),
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

  Widget _buildLoggedInView(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
      // 使用 GridSpeedDial 作为浮动按钮菜单，参考 popular_media_list_base_page.dart
      floatingActionButton: _isHeaderCollapsed
          ? Obx(
              () {
                final t = slang.Translations.of(context); // 在这里获取 t
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: mediaListController.isPaginated.value ? 40 : 20,
                    right: 0,
                  ),
                  child: GridSpeedDial(
                    icon: Icons.menu,
                    activeIcon: Icons.close,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    spacing: 6,
                    spaceBetweenChildren: 4,
                    direction: SpeedDialDirection.up,
                    childPadding: const EdgeInsets.all(6),
                  childrens: [
                    [
                      // 第一列
                      SpeedDialChild(
                        child: Obx(
                          () => Icon(
                            mediaListController.isPaginated.value
                                ? Icons.grid_view
                                : Icons.view_stream,
                          ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        onTap: () {
                          mediaListController.setPaginatedMode(
                            !mediaListController.isPaginated.value,
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.search),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        onTap: _openSearchDialog,
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.refresh),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        onTap: refreshCurrentList,
                      ),
                    ],
                    [
                      // 第二列
                      SpeedDialChild(
                        child: const Icon(Icons.vertical_align_top),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        onTap: () => mediaListController.scrollToTop(),
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.people),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        onTap: () => _showUserSelectionDialog(context),
                      ),
                      SpeedDialChild(
                        child: Obx(() {
                          if (userService.isLogin &&
                              userService.currentUser.value != null) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                AvatarWidget(
                                  user: userService.currentUser.value,
                                  size: 28,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Obx(() {
                                    final count =
                                        userService.notificationCount.value +
                                        userService.messagesCount.value;
                                    if (count > 0) {
                                      return Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
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
                            return const Icon(Icons.account_circle);
                          }
                        }),
                        backgroundColor:
                            Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        onTap: () {
                          AppService.switchGlobalDrawer();
                        },
                      ),
                    ],
                  ],
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  //  使用const构造器预构建非登录页面
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
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
