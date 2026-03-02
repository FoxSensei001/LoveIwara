import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:get/get.dart';

import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:flutter/gestures.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

// 定义抽象基类，包含泛型 T (媒体模型), C (特定媒体控制器), R (特定媒体仓库)
abstract class PopularMediaListPageBase<
  T,
  C extends GetxController,
  R extends LoadingMoreBase<T>
>
    extends StatefulWidget
    implements HomeWidgetInterface {
  final String controllerTag;
  final SearchSegment searchSegment;
  final IconData emptyIcon;

  const PopularMediaListPageBase({
    super.key,
    required this.controllerTag,
    required this.searchSegment,
    required this.emptyIcon,
  });

  // 抽象方法，由子类实现以创建特定的 Controller
  C createSpecificController(String sortIdName);

  // 抽象方法，由子类实现以获取特定的 Repository
  R getSpecificRepository(C controller);

  // 类静态变量，用于保存所有已创建的state实例的引用
  static final Map<String, PopularMediaListPageBaseState> stateInstances = {};

  // 通用的refreshCurrent实现，子类可以直接调用此方法
  void refreshCurrentImpl() {
    // 通过controllerTag查找对应的state
    final state = stateInstances[controllerTag];
    if (state != null && state.mounted) {
      state.tryRefreshCurrentSort();

      // 同时刷新UI
      try {
        final controller = Get.find<PopularMediaListController>(
          tag: controllerTag,
        );
        controller.refreshPageUI();
      } catch (e) {
        debugPrint('刷新UI时出错: $e');
      }
    }
  }
}

// 基类的 State - 移除下划线，设为公开
class PopularMediaListPageBaseState<
  T,
  C extends GetxController,
  R extends LoadingMoreBase<T>,
  W extends PopularMediaListPageBase<T, C, R>
>
    extends State<W>
    with SingleTickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;
  late TabController _tabController;
  late ScrollController _tabBarScrollController;
  final List<GlobalKey> _tabKeys = [];

  late PopularMediaListController _mediaListController;
  late BatchSelectController<T> _batchSelectController;
  final UserService userService = Get.find<UserService>();

  final Map<SortId, R> _repositories = {};
  final Map<SortId, C> _controllers = {};

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  // Tab bar scroll indicators for gradient fade
  final RxBool _tabBarAtStart = true.obs;
  final RxBool _tabBarAtEnd = true.obs;

  // Current tab index for dropdown sync
  final RxInt _currentTabIndex = 0.obs;

  void _updateTabBarScrollIndicators() {
    if (!_tabBarScrollController.hasClients) return;
    final pos = _tabBarScrollController.position;
    _tabBarAtStart.value = pos.pixels <= pos.minScrollExtent;
    _tabBarAtEnd.value = pos.pixels >= pos.maxScrollExtent - 1;
  }

  void tryRefreshCurrentSort() {
    if (mounted) {
      var sortId = sorts[_tabController.index].id;
      var repository = _repositories[sortId];
      if (!_mediaListController.isPaginated.value) {
        repository?.refresh(true);
      } else {
        _mediaListController.refreshPageUI();
      }
    }
  }

  // 打开搜索对话框
  void _openSearchDialog() {
    showAppDialog(
      SearchDialog(
        userInputKeywords: '',
        initialSegment: widget.searchSegment,
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

  @override
  void initState() {
    super.initState();
    _mediaListController = Get.put(
      PopularMediaListController(),
      tag: widget.controllerTag,
    );
    _batchSelectController = Get.put(
      BatchSelectController<T>(),
      tag: '${widget.controllerTag}_batch',
    );

    // 注册到静态映射中，便于外部访问
    PopularMediaListPageBase.stateInstances[widget.controllerTag] = this;

    for (var sort in sorts) {
      _tabKeys.add(GlobalKey());
      // 使用 widget 的抽象方法创建 Controller
      final controller = widget.createSpecificController(sort.id.name);
      _controllers[sort.id] = controller;
      // 使用 widget 的抽象方法获取 Repository
      _repositories[sort.id] = widget.getSpecificRepository(controller);
    }
    _tabController = TabController(length: sorts.length, vsync: this);
    _tabBarScrollController = ScrollController();
    _tabBarScrollController.addListener(_updateTabBarScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateTabBarScrollIndicators(),
    );
    _tabController.addListener(_onTabChange);
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabBarScrollController.removeListener(_updateTabBarScrollIndicators);
    _tabBarScrollController.dispose();
    Get.delete<PopularMediaListController>(tag: widget.controllerTag);
    Get.delete<BatchSelectController<T>>(tag: '${widget.controllerTag}_batch');

    // 从静态映射中移除
    PopularMediaListPageBase.stateInstances.remove(widget.controllerTag);

    for (var controller in _controllers.values) {
      // 假设 Controller 有 sortId 属性
      Get.delete<C>(tag: (controller as dynamic).sortId);
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
  }

  void setParams({
    List<Tag> tags = const [],
    String year = '',
    String rating = '',
  }) {
    this.tags = tags;
    this.year = year;
    this.rating = rating;

    LogUtils.d(
      '设置查询参数: tags: $tags, year: $year, rating: $rating',
      'PopularMediaListPageBase',
    );

    for (var sort in sorts) {
      var controller = _controllers[sort.id]!;
      // 直接调用 controller 的 updateSearchParams 方法，需要确保 C 类型有这个方法
      // 因为 BaseMediaController 现在是 GetxController 的子类，并且有 updateSearchParams
      // 所以这里的 C 类型（PopularVideoController/PopularGalleryController）也会有这个方法
      if (controller is BaseMediaController) {
        // 类型检查确保安全调用
        (controller as BaseMediaController).updateSearchParams(
          searchTagIds: tags.map((e) => e.id).toList(),
          searchDate: year,
          searchRating: rating,
        );
      } else {
        // 如果你的 Controller 结构更复杂，可能需要不同的处理方式
        LogUtils.w(
          'Controller type mismatch: Expected BaseMediaController but got ${controller.runtimeType}',
          'PopularMediaListPageBase',
        );
      }
    }
    _mediaListController.refreshPageUI();
  }

  void _onTabChange() {
    _currentTabIndex.value = _tabController.index;
    _scrollToSelectedTab();
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
  }

  void _scrollToSelectedTab() {
    if (!mounted ||
        _tabKeys.isEmpty ||
        _tabController.index >= _tabKeys.length) {
      return;
    }
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

  void _openParamsModal() {
    showAppDialog(
      PopularMediaSearchConfig(
        searchTags: tags,
        searchYear: year,
        searchRating: rating,
        onConfirm: (tags, year, rating) {
          setParams(tags: tags, year: year, rating: rating);
        },
      ),
    );
  }

  Widget _buildTabDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final index = _currentTabIndex.value;
    final currentSort = sorts[index];

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<int>(
        initialValue: index,
        onSelected: (newIndex) {
          _tabController.animateTo(newIndex);
        },
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.secondaryContainer,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: Row(
                  key: ValueKey(index),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentSort.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          size: 16,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        child: currentSort.icon!,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      currentSort.label,
                      style: TextStyle(color: colorScheme.onSecondaryContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => sorts.asMap().entries.map((entry) {
          return PopupMenuItem<int>(
            value: entry.key,
            child: Row(
              children: [
                if (entry.value.icon != null) ...[
                  entry.value.icon!,
                  const SizedBox(width: 8),
                ],
                Text(entry.value.label),
                if (entry.key == index) ...[
                  const Spacer(),
                  Icon(Icons.check, size: 18, color: colorScheme.primary),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static const double _topBarButtonSize = 40.0;

  Widget _buildCollapsedDrawerButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (userService.isLogin && userService.currentUser.value != null) {
        return SizedBox(
          width: _topBarButtonSize,
          height: _topBarButtonSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AvatarWidget(
                user: userService.currentUser.value,
                size: 28,
                onTap: () {
                  AppService.switchGlobalDrawer();
                },
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Obx(() {
                  final count =
                      userService.notificationCount.value +
                      userService.messagesCount.value;
                  if (count > 0) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        width: _topBarButtonSize,
        height: _topBarButtonSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: _topBarButtonSize,
            height: _topBarButtonSize,
          ),
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            AppService.switchGlobalDrawer();
          },
          tooltip: t.common.me,
        ),
      );
    });
  }

  Widget _buildCollapsedSearchButton() {
    return SizedBox(
      width: _topBarButtonSize,
      height: _topBarButtonSize,
      child: IconButton(
        constraints: const BoxConstraints.tightFor(
          width: _topBarButtonSize,
          height: _topBarButtonSize,
        ),
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.search, size: 22),
        onPressed: _openSearchDialog,
        tooltip: t.common.search,
      ),
    );
  }

  // 创建可动画的 IconButton
  Widget _buildAnimatedIconButton({
    required Widget child,
    required bool isVisible,
  }) {
    // 检查当前平台是否为 Windows 或 macOS
    final bool isDesktop = Platform.isWindows || Platform.isMacOS;

    // 如果是桌面平台，则始终可见，禁用动画收缩效果
    if (isDesktop) {
      return SizedBox(width: _topBarButtonSize, child: child);
    }

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isVisible ? _topBarButtonSize : 0.0,
        child: child,
      ),
    );
  }

  static const double _topBarBlurSigma = 10.0;
  static const double _topBarSurfaceAlpha = 0.8;

  Widget _buildUnifiedTopBarFrostedLayer({
    required BuildContext context,
    required Widget child,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _topBarBlurSigma,
          sigmaY: _topBarBlurSigma,
        ),
        child: ColoredBox(
          color: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: _topBarSurfaceAlpha),
          child: child,
        ),
      ),
    );
  }

  static const String _menuActionOpenDrawer = 'open_drawer';
  static const String _menuActionOpenSearch = 'open_search';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionFilter = 'filter';
  static const String _menuActionToggleBatch = 'toggle_batch';

  void _handleTopBarMenuAction(String action) {
    switch (action) {
      case _menuActionOpenDrawer:
        AppService.switchGlobalDrawer();
        break;
      case _menuActionOpenSearch:
        _openSearchDialog();
        break;
      case _menuActionRefresh:
        tryRefreshCurrentSort();
        break;
      case _menuActionScrollTop:
        _mediaListController.scrollToTop();
        break;
      case _menuActionTogglePagination:
        _mediaListController.setPaginatedMode(
          !_mediaListController.isPaginated.value,
        );
        break;
      case _menuActionFilter:
        _openParamsModal();
        break;
      case _menuActionToggleBatch:
        _batchSelectController.toggleMultiSelect();
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildTopBarMenuItems({
    required double maxWidth,
    required bool showHeader,
  }) {
    final List<PopupMenuEntry<String>> items = [];
    final bool showCollapsedQuickActions = !showHeader && maxWidth >= 420;

    void addMenuItem({
      required String value,
      required IconData icon,
      required String label,
    }) {
      items.add(
        PopupMenuItem<String>(
          value: value,
          child: Row(
            children: [Icon(icon), const SizedBox(width: 12), Text(label)],
          ),
        ),
      );
    }

    if (!showCollapsedQuickActions) {
      addMenuItem(
        value: _menuActionOpenDrawer,
        icon: Icons.account_circle,
        label: t.common.me,
      );
      addMenuItem(
        value: _menuActionOpenSearch,
        icon: Icons.search,
        label: t.common.search,
      );
    }

    if (!showHeader) {
      addMenuItem(
        value: _menuActionRefresh,
        icon: Icons.refresh,
        label: t.common.refresh,
      );
      addMenuItem(
        value: _menuActionScrollTop,
        icon: Icons.vertical_align_top,
        label: t.common.scrollToTop,
      );
    }

    if (items.isNotEmpty) {
      items.add(const PopupMenuDivider());
    }

    addMenuItem(
      value: _menuActionTogglePagination,
      icon: _mediaListController.isPaginated.value
          ? Icons.grid_view
          : Icons.view_stream,
      label: _mediaListController.isPaginated.value
          ? t.common.pagination.waterfall
          : t.common.pagination.pagination,
    );
    addMenuItem(
      value: _menuActionFilter,
      icon: Icons.filter_list,
      label: t.common.search,
    );
    addMenuItem(
      value: _menuActionToggleBatch,
      icon: _batchSelectController.isMultiSelect.value
          ? Icons.close
          : Icons.checklist,
      label: _batchSelectController.isMultiSelect.value
          ? t.common.exitEditMode
          : t.common.editMode,
    );

    return items;
  }

  Widget _buildTopBarOverflowMenu({
    required double maxWidth,
    required bool showHeader,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: _handleTopBarMenuAction,
        itemBuilder: (context) =>
            _buildTopBarMenuItems(maxWidth: maxWidth, showHeader: showHeader),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double tabBarHeight = 40.0;
    const double headerHeight = 44.0;
    final systemStatusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 内容区域 - 填充整个Stack，列表通过paddingTop留出头部空间
              Obx(() {
                final isPaginated = _mediaListController.isPaginated.value;
                final shouldApplyBottomSafeAreaPadding =
                    !Get.find<AppService>().showBottomNavi ||
                    MediaQuery.sizeOf(context).width > 600;
                final rebuildKey = _mediaListController.rebuildKey.value
                    .toString();
                final showHeader = _mediaListController.showHeader.value;
                final isMultiSelectMode =
                    _batchSelectController.isMultiSelect.value;
                final selectedMediaIds = _batchSelectController.selectedMediaIds
                    .toSet();

                _batchSelectController.setPaginatedMode(isPaginated);

                return TabBarView(
                  controller: _tabController,
                  children: sorts.map((sort) {
                    return MediaTabView<T>(
                      key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                      sortId: sort.id,
                      repository: _repositories[sort.id]!,
                      emptyIcon: widget.emptyIcon,
                      isPaginated: isPaginated,
                      showBottomPadding: shouldApplyBottomSafeAreaPadding,
                      rebuildKey: rebuildKey,
                      paddingTop:
                          systemStatusBarHeight +
                          tabBarHeight +
                          (showHeader ? headerHeight : 0),
                      mediaListController: _mediaListController,
                      isMultiSelectMode: isMultiSelectMode,
                      selectedItemIds: selectedMediaIds,
                      onItemSelect: (media) =>
                          _batchSelectController.toggleSelection(media),
                      onPageChanged: () =>
                          _batchSelectController.onPageChanged(),
                    );
                  }).toList(),
                );
              }),
              // 毛玻璃头部叠加层
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildUnifiedTopBarFrostedLayer(
                  context: context,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 顶部空间（状态栏 + 动态折叠的头部）
                      Obx(() {
                        final bool showHeader =
                            _mediaListController.showHeader.value;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          clipBehavior: Clip.hardEdge,
                          height: showHeader
                              ? systemStatusBarHeight + headerHeight
                              : systemStatusBarHeight,
                          decoration: const BoxDecoration(),
                          child: Column(
                            children: [
                              SizedBox(height: systemStatusBarHeight),
                              Expanded(
                                child: IgnorePointer(
                                  ignoring: !showHeader,
                                  child: AnimatedOpacity(
                                    opacity: showHeader ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          // Compact avatar
                                          Obx(() {
                                            if (userService.isLogin &&
                                                userService.currentUser.value !=
                                                    null) {
                                              return SizedBox(
                                                width: _topBarButtonSize,
                                                height: _topBarButtonSize,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    AvatarWidget(
                                                      user: userService
                                                          .currentUser
                                                          .value,
                                                      size: 32,
                                                      onTap: () =>
                                                          AppService.switchGlobalDrawer(),
                                                    ),
                                                    Positioned(
                                                      right: 4,
                                                      top: 4,
                                                      child: Obx(() {
                                                        final count =
                                                            userService
                                                                .notificationCount
                                                                .value +
                                                            userService
                                                                .messagesCount
                                                                .value;
                                                        if (count > 0) {
                                                          return Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                context,
                                                              ).colorScheme.error,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox.shrink();
                                                      }),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return SizedBox(
                                              width: _topBarButtonSize,
                                              height: _topBarButtonSize,
                                              child: IconButton(
                                                constraints:
                                                    const BoxConstraints.tightFor(
                                                      width: _topBarButtonSize,
                                                      height: _topBarButtonSize,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                  Icons.account_circle,
                                                  size: 24,
                                                ),
                                                onPressed: () =>
                                                    AppService.switchGlobalDrawer(),
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: 8),
                                          // Compact search pill
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _openSearchDialog,
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest
                                                      .withValues(alpha: 0.5),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.search,
                                                      size: 18,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      t.common.search,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          // Compact refresh button
                                          SizedBox(
                                            width: _topBarButtonSize,
                                            height: _topBarButtonSize,
                                            child: IconButton(
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                    width: _topBarButtonSize,
                                                    height: _topBarButtonSize,
                                                  ),
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.refresh),
                                              onPressed: tryRefreshCurrentSort,
                                              tooltip: t.common.refresh,
                                            ),
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
                      SizedBox(
                        height: tabBarHeight,
                        child: Obx(() {
                          final showHeader =
                              _mediaListController.showHeader.value;
                          final showCollapsedQuickActions =
                              !showHeader && constraints.maxWidth >= 420;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                if (showCollapsedQuickActions) ...[
                                  _buildCollapsedDrawerButton(context),
                                  const SizedBox(width: 4),
                                  _buildCollapsedSearchButton(),
                                  const SizedBox(width: 8),
                                ],
                                if (constraints.maxWidth < 600)
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Obx(
                                        () => _buildTabDropdown(context),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Obx(() {
                                      final atStart = _tabBarAtStart.value;
                                      final atEnd = _tabBarAtEnd.value;

                                      Widget tabContent = MouseRegion(
                                        child: Listener(
                                          onPointerSignal: (pointerSignal) {
                                            if (pointerSignal
                                                is PointerScrollEvent) {
                                              _handleScroll(
                                                pointerSignal.scrollDelta.dy,
                                              );
                                            }
                                          },
                                          child: SingleChildScrollView(
                                            controller: _tabBarScrollController,
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            child: TabBar(
                                              isScrollable: true,
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                    Colors.transparent,
                                                  ),
                                              tabAlignment: TabAlignment.start,
                                              dividerColor: Colors.transparent,
                                              padding: EdgeInsets.zero,
                                              controller: _tabController,
                                              tabs: sorts.asMap().entries.map((
                                                entry,
                                              ) {
                                                int index = entry.key;
                                                Sort sort = entry.value;
                                                return Container(
                                                  key: _tabKeys[index],
                                                  child: Tab(
                                                    child: Row(
                                                      children: [
                                                        sort.icon ??
                                                            const SizedBox(),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(sort.label),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );

                                      if (atStart && atEnd) return tabContent;

                                      return ShaderMask(
                                        shaderCallback: (Rect rect) {
                                          return LinearGradient(
                                            colors: [
                                              atStart
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              Colors.white,
                                              Colors.white,
                                              atEnd
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.05, 0.85, 1.0],
                                          ).createShader(rect);
                                        },
                                        blendMode: BlendMode.dstIn,
                                        child: tabContent,
                                      );
                                    }),
                                  ),
                                _buildAnimatedIconButton(
                                  isVisible: showHeader,
                                  child: IconButton(
                                    icon: const Icon(Icons.vertical_align_top),
                                    onPressed: () =>
                                        _mediaListController.scrollToTop(),
                                    tooltip: t.common.scrollToTop,
                                  ),
                                ),
                                if (constraints.maxWidth >= 600) ...[
                                  Obx(() {
                                    return _buildAnimatedIconButton(
                                      isVisible: showHeader,
                                      child: IconButton(
                                        icon: Icon(
                                          _mediaListController.isPaginated.value
                                              ? Icons.grid_view
                                              : Icons.view_stream,
                                        ),
                                        onPressed: () {
                                          _mediaListController.setPaginatedMode(
                                            !_mediaListController
                                                .isPaginated
                                                .value,
                                          );
                                        },
                                        tooltip:
                                            _mediaListController
                                                .isPaginated
                                                .value
                                            ? t.common.pagination.waterfall
                                            : t.common.pagination.pagination,
                                      ),
                                    );
                                  }),
                                  _buildAnimatedIconButton(
                                    isVisible: showHeader,
                                    child: IconButton(
                                      icon: const Icon(Icons.filter_list),
                                      onPressed: _openParamsModal,
                                      tooltip: t.common.search,
                                    ),
                                  ),
                                  Obx(() {
                                    return _buildAnimatedIconButton(
                                      isVisible: showHeader,
                                      child: IconButton(
                                        icon: Icon(
                                          _batchSelectController
                                                  .isMultiSelect
                                                  .value
                                              ? Icons.close
                                              : Icons.checklist,
                                        ),
                                        onPressed: () => _batchSelectController
                                            .toggleMultiSelect(),
                                        tooltip:
                                            _batchSelectController
                                                .isMultiSelect
                                                .value
                                            ? t.common.exitEditMode
                                            : t.common.editMode,
                                      ),
                                    );
                                  }),
                                ],
                                _buildTopBarOverflowMenu(
                                  maxWidth: constraints.maxWidth,
                                  showHeader: showHeader,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // 多选操作按钮
              Obx(
                () => BatchActionFabColumn<T>(
                  controller: _batchSelectController,
                  heroTagPrefix: 'popular_media_list',
                  isPaginated: _mediaListController.isPaginated.value,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
