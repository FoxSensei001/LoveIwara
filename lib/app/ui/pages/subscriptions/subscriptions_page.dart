import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart'; // 用于 ScrollDirection
import 'package:get/get.dart';

import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/compact_subscription_dropdown.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_video_list.dart';
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';

import 'package:i_iwara/app/services/tutorial_service.dart';

import 'controllers/media_list_controller.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import '../popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';

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
  late final BatchSelectController<Video> _videoBatchController;
  late final BatchSelectController<ImageModel> _imageBatchController;

  late TabController _tabController;
  String selectedId = '';

  // 定义常量（现在使用本地常量，这里保留注释作为参考）
  // static const double _userSelectorRowHeight = 56.0; // 用户选择器/图标行的实际高度
  // static const double _tabBarActualHeight = 48.0; // TabBar 本身的高度

  final ScrollController _tabBarScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  // 教程指导需要的GlobalKey
  final GlobalKey _userSelectorKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _floatingActionsKey = GlobalKey();

  // 添加节流器避免频繁处理滚动事件
  DateTime _lastScrollTime = DateTime.now();
  static const Duration _scrollThrottleDuration = Duration(milliseconds: 16);

  // 头部折叠状态
  final double _headerCollapseThreshold = 50.0; // 触发折叠/展开的滚动阈值（像素）

  // 头部滚动监听器
  VoidCallback? _scrollListenerDisposer;

  // 浮动按钮状态
  static const double _edgePadding = 16.0;

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

    showAppDialog(
      SearchDialog(
        userInputKeywords: '',
        initialSegment: segment,
        onSearch: (searchInfo, segment, filters, sort) {
          NaviService.toSearchPage(
            searchInfo: searchInfo,
            segment: segment,
            filters: filters,
            sort: sort,
          );
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

    showAppDialog(
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
                      onPressed: () => AppService.tryPop(context: context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 用户列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: likedUsers.length + 1, // +1 for "全部" option
                  itemBuilder: (context, index) {
                    // 第一项为"全部"选项
                    if (index == 0) {
                      final isSelected = selectedId.isEmpty;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.people,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(t.common.all),
                        subtitle: Text(
                          t.subscriptions.showAllSubscribedUsersContent,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () {
                          _onUserSelected(''); // 传递空字符串表示选择全部
                          AppService.tryPop(context: context);
                        },
                      );
                    }

                    // 其他用户选项
                    final user = likedUsers[index - 1]; // -1 因为第一项是"全部"
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
                        // 如果点击已选中的用户，则取消选择（回到全部）
                        if (selectedId == user.id) {
                          _onUserSelected('');
                        } else {
                          _onUserSelected(user.id);
                        }
                        AppService.tryPop(context: context);
                      },
                      onLongPress: () {
                        NaviService.navigateToAuthorProfilePage(user.username);
                        AppService.tryPop(context: context);
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
    _videoBatchController = Get.put(
      BatchSelectController<Video>(),
      tag: 'subscriptions_video_batch',
    );
    _imageBatchController = Get.put(
      BatchSelectController<ImageModel>(),
      tag: 'subscriptions_image_batch',
    );

    // 监听列表页面变化
    mediaListController.registerOnPageChangedCallback(() {
      _videoBatchController.onPageChanged();
      _imageBatchController.onPageChanged();
    });

    // 显示教程指导（延迟执行，确保页面完全加载）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && userService.isLogin) {
        TutorialService().showSubscriptionTutorial(context);
      }
    });

    // 监听 MediaListController 的滚动变化
    _scrollListenerDisposer = ever(mediaListController.currentScrollOffset, (
      double offset,
    ) {
      final direction = mediaListController.lastScrollDirection.value;
      bool shouldShowHeader = mediaListController.showHeader.value;

      // 改进的折叠逻辑：
      // 1. 向上滚动且超过阈值时隐藏
      // 2. 向下滚动时显示
      // 3. 接近顶部时始终显示

      if (direction == ScrollDirection.reverse) {
        // 向上滚动：需要滚动超过阈值才隐藏
        if (offset > _headerCollapseThreshold && shouldShowHeader) {
          shouldShowHeader = false;
        }
      } else if (direction == ScrollDirection.forward) {
        // 向下滚动：更灵敏地显示
        if (!shouldShowHeader) {
          shouldShowHeader = true;
        }
      }

      // 特殊情况：接近顶部时始终显示
      if (offset <= 5.0 && !shouldShowHeader) {
        shouldShowHeader = true;
      }

      // 特殊情况：切换标签或数据时显示
      if (offset == 0.0 &&
          direction == ScrollDirection.idle &&
          !shouldShowHeader) {
        shouldShowHeader = true;
      }

      if (mounted && mediaListController.showHeader.value != shouldShowHeader) {
        mediaListController.showHeader.value = shouldShowHeader;
      }
    }).call;
  }

  void _onTabChange() {
    _scrollToSelectedTab();
    if (mounted) {
      setState(() {});
    }
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
    // 如果点击的是已选中的用户（且不是"全部"），则取消选择回到"全部"
    if (selectedId == id && id.isNotEmpty) {
      setState(() {
        selectedId = '';
      });
      // Reset scroll state when switching users
      mediaListController.showHeader.value = true;
      mediaListController.currentScrollOffset.value = 0.0;
      mediaListController.lastScrollDirection.value = ScrollDirection.idle;
    } else if (selectedId != id) {
      setState(() {
        selectedId = id;
      });
      // Reset scroll state when switching users
      mediaListController.showHeader.value = true;
      mediaListController.currentScrollOffset.value = 0.0;
      mediaListController.lastScrollDirection.value = ScrollDirection.idle;
    }
  }

  Future<void> refreshCurrentList() async {
    // Reset scroll state when refreshing
    mediaListController.showHeader.value = true;
    // 使用 Future.microtask 确保状态更新后再触发刷新
    await Future.microtask(() {
      mediaListController.currentScrollOffset.value = 0.0;
      mediaListController.lastScrollDirection.value = ScrollDirection.idle;
      mediaListController.refreshList();
    });
  }

  // 获取教程指导需要的GlobalKey
  GlobalKey get userSelectorKey => _userSelectorKey;
  GlobalKey get searchButtonKey => _searchButtonKey;
  GlobalKey get floatingActionsKey => _floatingActionsKey;

  @override
  void dispose() {
    _scrollListenerDisposer?.call(); // 销毁监听器
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabBarScrollController.dispose();
    Get.delete<MediaListController>();
    Get.delete<BatchSelectController<Video>>(tag: 'subscriptions_video_batch');
    Get.delete<BatchSelectController<ImageModel>>(
      tag: 'subscriptions_image_batch',
    );
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
    const double tabBarHeight = 48.0;
    const double headerHeight = 48.0;
    final systemStatusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 使用 Column 替代 Stack + dynamic padding
              Column(
                children: [
                  // 顶部空间（状态栏 + 动态折叠的头部）
                  Obx(() {
                    final bool showHeader =
                        mediaListController.showHeader.value;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      clipBehavior: Clip.hardEdge,
                      height: showHeader
                          ? systemStatusBarHeight + headerHeight
                          : systemStatusBarHeight,
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          SizedBox(height: systemStatusBarHeight),
                          Expanded(
                            child: IgnorePointer(
                              ignoring: !showHeader,
                              child: AnimatedOpacity(
                                opacity: showHeader ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  height: headerHeight,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          final likedUsers =
                                              userPreferenceService.likedUsers;
                                          List<SubscriptionDropdownItem>
                                          userDropdownItems = likedUsers
                                              .map(
                                                (
                                                  userDto,
                                                ) => SubscriptionDropdownItem(
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
                                            key: _userSelectorKey,
                                            userList: userDropdownItems,
                                            selectedUserId: selectedId,
                                            onUserSelected: _onUserSelected,
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.refresh),
                                        onPressed: refreshCurrentList,
                                        tooltip: t.common.refresh,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.settings),
                                        onPressed:
                                            AppService.switchGlobalDrawer,
                                        tooltip: t.common.settings,
                                      ),
                                      IconButton(
                                        key: _searchButtonKey,
                                        icon: const Icon(Icons.search),
                                        onPressed: _openSearchDialog,
                                        tooltip: t.common.search,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // TabBar 区域 - 始终显示
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: SizedBox(
                      height: tabBarHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              child: Listener(
                                onPointerSignal: (pointerSignal) {
                                  if (pointerSignal is PointerScrollEvent) {
                                    _handleScroll(
                                      pointerSignal.scrollDelta.dy * 2,
                                    );
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
                            tooltip: t.common.scrollToTop,
                          ),
                          Obx(
                            () => IconButton(
                              icon: Icon(
                                mediaListController.isPaginated.value
                                    ? Icons.grid_view
                                    : Icons.view_stream,
                              ),
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
                          // 多选按钮
                          Obx(() {
                            // 仅在视频和图库标签页显示多选按钮
                            if (_tabController.index > 1) {
                              return const SizedBox.shrink();
                            }
                            final controller = _tabController.index == 0
                                ? _videoBatchController
                                : _imageBatchController;
                            return IconButton(
                              icon: Icon(
                                controller.isMultiSelect.value
                                    ? Icons.close
                                    : Icons.checklist,
                              ),
                              onPressed: () => controller.toggleMultiSelect(),
                              tooltip: controller.isMultiSelect.value
                                  ? t.common.exitEditMode
                                  : t.common.editMode,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  // 内容区域
                  Expanded(
                    child: Obx(() {
                      final isPaginated = mediaListController.isPaginated.value;
                      final rebuildKey = mediaListController.rebuildKey.value
                          .toString();

                      // 同步分页模式状态到批量选择控制器
                      _videoBatchController.setPaginatedMode(isPaginated);
                      _imageBatchController.setPaginatedMode(isPaginated);

                      return TabBarView(
                        controller: _tabController,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          GlowNotificationWidget(
                            key: ValueKey(
                              'video_${selectedId}_${isPaginated}_$rebuildKey',
                            ),
                            child: Obx(
                              () => SubscriptionVideoList(
                                userId: selectedId,
                                isPaginated: isPaginated,
                                paddingTop: 0, // 使用 Column 布局，不需要 paddingTop
                                isMultiSelectMode:
                                    _videoBatchController.isMultiSelect.value,
                                selectedItemIds: _videoBatchController
                                    .selectedMediaIds
                                    .toSet(),
                                onItemSelect: (video) => _videoBatchController
                                    .toggleSelection(video),
                              ),
                            ),
                          ),
                          GlowNotificationWidget(
                            key: ValueKey(
                              'image_${selectedId}_${isPaginated}_$rebuildKey',
                            ),
                            child: Obx(
                              () => SubscriptionImageList(
                                userId: selectedId,
                                isPaginated: isPaginated,
                                paddingTop: 0, // 使用 Column 布局，不需要 paddingTop
                                isMultiSelectMode:
                                    _imageBatchController.isMultiSelect.value,
                                selectedItemIds: _imageBatchController
                                    .selectedMediaIds
                                    .toSet(),
                                onItemSelect: (image) => _imageBatchController
                                    .toggleSelection(image),
                              ),
                            ),
                          ),
                          GlowNotificationWidget(
                            key: ValueKey(
                              'post_${selectedId}_${isPaginated}_$rebuildKey',
                            ),
                            child: SubscriptionPostList(
                              userId: selectedId,
                              isPaginated: isPaginated,
                              paddingTop: 0, // 使用 Column 布局，不需要 paddingTop
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),

              // 多选操作按钮
              BatchActionFabColumn<Video>(
                controller: _videoBatchController,
                heroTagPrefix: 'subscriptions_video',
                isPaginated: mediaListController.isPaginated.value,
                visible: () => _tabController.index == 0,
              ),
              BatchActionFabColumn<ImageModel>(
                controller: _imageBatchController,
                heroTagPrefix: 'subscriptions_image',
                isPaginated: mediaListController.isPaginated.value,
                visible: () => _tabController.index == 1,
              ),

              // 浮动按钮（仅在头部隐藏时显示）
              Obx(() {
                final bool isHeaderCollapsed =
                    !mediaListController.showHeader.value;
                // 不再直接使用 SizedBox.shrink()，而是通过动画控制显示

                final isPaginatedNow = mediaListController.isPaginated.value;
                final bottomSafeNow = MediaQuery.of(context).padding.bottom;
                final double extraBottomNow = isPaginatedNow
                    ? (46 + bottomSafeNow + 20)
                    : 20;

                return Positioned(
                  right: _edgePadding,
                  bottom: _edgePadding + extraBottomNow,
                  child: IgnorePointer(
                    ignoring: !isHeaderCollapsed,
                    child: AnimatedScale(
                      scale: isHeaderCollapsed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: isHeaderCollapsed ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: GridSpeedDial(
                          key: _floatingActionsKey,
                          icon: Icons.menu,
                          activeIcon: Icons.close,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          spacing: 6,
                          spaceBetweenChildren: 4,
                          direction: SpeedDialDirection.up,
                          childPadding: const EdgeInsets.all(6),
                          childrens: [
                            [
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
                              SpeedDialChild(
                                child: Obx(() {
                                  final controller = _tabController.index == 0
                                      ? _videoBatchController
                                      : _imageBatchController;
                                  return Icon(
                                    controller.isMultiSelect.value
                                        ? Icons.close
                                        : Icons.checklist,
                                  );
                                }),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                onTap: () {
                                  if (_tabController.index <= 1) {
                                    final controller = _tabController.index == 0
                                        ? _videoBatchController
                                        : _imageBatchController;
                                    controller.toggleMultiSelect();
                                  }
                                },
                              ),
                            ],
                            [
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
                                                userService
                                                    .notificationCount
                                                    .value +
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
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
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
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return _buildContent(context);
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
                        onPressed: () => LoginService.showLogin(),
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
