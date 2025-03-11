import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_select_list_widget.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_video_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/constants.dart';
import '../../../services/app_service.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:shimmer/shimmer.dart';

class SubscriptionsPage extends StatefulWidget with RefreshableMixin {
  static final globalKey = GlobalKey<_SubscriptionsPageState>();

  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();

  @override
  void refreshCurrent() {
    final state = globalKey.currentState;
    if (state != null) {
      state.tryRefreshCurrentList();
    }
  }
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with TickerProviderStateMixin {
  final UserService userService = Get.find<UserService>();
  final UserPreferenceService userPreferenceService =
      Get.find<UserPreferenceService>();

  late TabController _tabController;
  String selectedId = '';

  late AnimationController _refreshIconController;
  
  // 添加列表显示模式状态，并使用保存的值初始化
  RxBool isPaginatedMode = CommonConstants.subscriptionPaginationMode.obs;

  // 使用更稳定的键管理策略
  // 为每个Tab和模式组合创建唯一的键
  final Map<String, GlobalKey<State>> _keyCache = {};

  // 为每个Tab添加独立的ScrollController缓存
  final Map<String, ScrollController> _scrollControllerCache = {};

  // 改进的键生成逻辑，使用更稳定的标识符
  GlobalKey<State> _getKey(int tabIndex, bool isPaginated) {
    // 创建稳定的键标识符
    String keyId = '${tabIndex}_${isPaginated ? 'paginated' : 'list'}_$selectedId';
    
    // 检查缓存中是否存在该键
    if (!_keyCache.containsKey(keyId)) {
      // 根据tabIndex创建不同类型的键
      switch (tabIndex) {
        case 0:
          _keyCache[keyId] = GlobalKey<SubscriptionVideoListState>(debugLabel: keyId);
        case 1:
          _keyCache[keyId] = GlobalKey<SubscriptionImageListState>(debugLabel: keyId);
        case 2:
          _keyCache[keyId] = GlobalKey<SubscriptionPostListState>(debugLabel: keyId);
        default:
          _keyCache[keyId] = GlobalKey<State>(debugLabel: keyId);
      }
    }
    
    return _keyCache[keyId]!;
  }

  // 优化的缓存清理逻辑，只清除特定ID相关的键
  void _clearKeysForId(String id) {
    if (id.isEmpty) return;
    
    final keysToRemove = _keyCache.keys.where((k) => k.contains(id)).toList();
    for (var key in keysToRemove) {
      _keyCache.remove(key);
    }
  }

  // 获取或创建Tab的ScrollController，确保每个Tab和模式组合有独立的控制器
  ScrollController _getScrollController(int tabIndex, bool isPaginated) {
    String key = '${tabIndex}_${isPaginated ? 'paginated' : 'list'}_$selectedId';
    if (!_scrollControllerCache.containsKey(key)) {
      _scrollControllerCache[key] = ScrollController();
    }
    return _scrollControllerCache[key]!;
  }
  
  // 优化的ScrollController清理逻辑
  void _clearScrollControllersForId(String id) {
    if (id.isEmpty) return;
    
    final keysToRemove = _scrollControllerCache.keys.where((k) => k.contains(id)).toList();
    for (var key in keysToRemove) {
      // 确保在移除前正确处理控制器的生命周期
      if (_scrollControllerCache[key]?.hasClients == true) {
        _scrollControllerCache[key]?.dispose();
      }
      _scrollControllerCache.remove(key);
    }
  }

  // 改进的刷新逻辑，确保正确触发视图更新
  void tryRefreshCurrentList() {
    if (mounted) {
      setState(() {});
    }
  }

  final ScrollController _extendedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _refreshIconController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // 添加对isPaginatedMode变化的监听，确保状态正确更新
    isPaginatedMode.listen((value) {
      // 保存用户的选择到常量中
      CommonConstants.subscriptionPaginationMode = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  // 改进的ID选择处理逻辑
  void _onIdSelected(String id) {
    if (selectedId != id) {
      // 清除旧ID对应的缓存键
      _clearKeysForId(selectedId);
      // 清除旧ID对应的ScrollController
      _clearScrollControllersForId(selectedId);
      
      setState(() {
        selectedId = id;
      });
    }
  }

  // 改进的刷新逻辑
  Future<void> _refreshCurrentList() async {
    _refreshIconController.repeat();
    try {
      // 触发重建以刷新数据
      setState(() {});
    } finally {
      _refreshIconController.stop();
      _refreshIconController.reset();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshIconController.dispose();
    _extendedScrollController.dispose();
    
    // 确保清理所有ScrollController
    for (var controller in _scrollControllerCache.values) {
      if (controller.hasClients) {
        controller.dispose();
      }
    }
    _scrollControllerCache.clear();
    
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
    return ExtendedNestedScrollView(
      controller: _extendedScrollController,
      onlyOneScrollInBody: true,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopPaddingHeightWidget(),
                // 头像和标题行
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Obx(() => _buildAvatarButton()),
                      Expanded(
                        child: Text(
                          t.common.subscriptions,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 订阅用户选择列表
                Obx(() => _buildSubscriptionList()),
              ],
            ),
          ),
          // TabBar 部分保持固定
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        physics: const NeverScrollableScrollPhysics(),
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
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
                          Tab(text: t.common.video),
                          Tab(text: t.common.gallery),
                          Tab(text: t.common.post),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.vertical_align_top),
                      onPressed: () {
                        _extendedScrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
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
                    // 添加列表模式切换按钮
                    Obx(() => IconButton(
                      icon: Icon(isPaginatedMode.value 
                          ? Icons.grid_view 
                          : Icons.menu),
                      onPressed: () {
                        // 切换模式前保存当前状态
                        final currentTabIndex = _tabController.index;
                        final currentId = selectedId;
                        
                        // 切换分页模式
                        isPaginatedMode.value = !isPaginatedMode.value;
                        
                        // 延迟执行，确保状态更新后再清理缓存
                        Future.microtask(() {
                          // 只清除当前Tab和ID的缓存，而不是所有缓存
                          final keyPattern = '${currentTabIndex}_';
                          final keysToRemove = _keyCache.keys
                              .where((k) => k.contains(keyPattern) && k.contains(currentId))
                              .toList();
                          
                          for (var key in keysToRemove) {
                            _keyCache.remove(key);
                          }
                          
                          // 同样只清除当前Tab和ID的ScrollController
                          final controllerKeysToRemove = _scrollControllerCache.keys
                              .where((k) => k.contains(keyPattern) && k.contains(currentId))
                              .toList();
                          
                          for (var key in controllerKeysToRemove) {
                            if (_scrollControllerCache[key]?.hasClients == true) {
                              _scrollControllerCache[key]?.dispose();
                            }
                            _scrollControllerCache.remove(key);
                          }
                          
                          // 强制更新UI
                          if (mounted) setState(() {});
                        });
                      },
                      tooltip: isPaginatedMode.value 
                           ? '瀑布流'
                           : '分页',
                    )),
                    RotationTransition(
                      turns: _refreshIconController,
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshCurrentList,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      pinnedHeaderSliverHeightBuilder: () {
        return MediaQuery.of(context).padding.top + kToolbarHeight;
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // 视频列表 - 改进的构建逻辑
          Builder(
            builder: (context) {
              final isPaginated = isPaginatedMode.value;
              final key = _getKey(0, isPaginated);
              final scrollController = _getScrollController(0, isPaginated);
              
              return GlowNotificationWidget(
                child: SubscriptionVideoList(
                  key: key,
                  userId: selectedId,
                  isPaginated: isPaginated,
                  scrollController: scrollController,
                ),
              );
            },
          ),
          // 图片列表 - 改进的构建逻辑
          Builder(
            builder: (context) {
              final isPaginated = isPaginatedMode.value;
              final key = _getKey(1, isPaginated);
              final scrollController = _getScrollController(1, isPaginated);
              
              return GlowNotificationWidget(
                child: SubscriptionImageList(
                  key: key,
                  userId: selectedId,
                  isPaginated: isPaginated,
                  scrollController: scrollController,
                ),
              );
            },
          ),
          // 帖子列表 - 改进的构建逻辑
          Builder(
            builder: (context) {
              final isPaginated = isPaginatedMode.value;
              final key = _getKey(2, isPaginated);
              final scrollController = _getScrollController(2, isPaginated);
              
              return GlowNotificationWidget(
                child: SubscriptionPostList(
                  key: key,
                  userId: selectedId,
                  isPaginated: isPaginated,
                  scrollController: scrollController,
                ),
              );
            },
          ),
        ],
      ),
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
                baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            icon: AvatarWidget(
              user: userService.currentUser.value,
              size: 40
            ),
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
      selectionList: selectionList,
      selectedId: selectedId,
      onIdSelected: _onIdSelected,
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
