import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/common_header.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';

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
  final UserService userService = Get.find<UserService>();

  final Map<SortId, R> _repositories = {};
  final Map<SortId, C> _controllers = {};

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  // 头部折叠相关变量
  bool _isHeaderCollapsed = false;
  final double _headerCollapseThreshold = 50.0; // 触发折叠/展开的滚动阈值（像素）

  // 头部滚动监听器
  VoidCallback? _scrollListenerDisposer;

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
    Get.dialog(
      SearchDialog(
        initialSearch: '',
        initialSegment: widget.searchSegment,
        onSearch: (searchInfo, segment) {
          NaviService.toSearchPage(searchInfo: searchInfo, segment: segment);
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
    _tabController.addListener(_onTabChange);

    // 监听 PopularMediaListController 的滚动变化
    _scrollListenerDisposer = ever(_mediaListController.currentScrollOffset, (
      double offset,
    ) {
      final direction = _mediaListController.lastScrollDirection.value;
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

      // 特殊情况：如果用户刚刚切换了标签或数据，offset 可能为 0。
      if (offset == 0.0 &&
          direction == ScrollDirection.idle &&
          _isHeaderCollapsed) {
        shouldCollapse = false; // 如果新列表从顶部开始，则展开
      }

      if (mounted && _isHeaderCollapsed != shouldCollapse) {
        setState(() {
          _isHeaderCollapsed = shouldCollapse;
        });
      }
    }).call;
  }

  @override
  void dispose() {
    _scrollListenerDisposer?.call(); // 销毁滚动监听器
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabBarScrollController.dispose();
    Get.delete<PopularMediaListController>(tag: widget.controllerTag);

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
    _scrollToSelectedTab();
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
    Get.dialog(
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

  // 创建可动画的 IconButton
  Widget _buildAnimatedIconButton({
    required Widget child,
    required bool isVisible,
  }) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isVisible ? 48.0 : 0.0,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double tabBarHeight = 48.0;
    const double headerHeight = 56.0;
    final systemStatusBarHeight = MediaQuery.of(context).padding.top;

    // 根据折叠状态计算动态高度
    final double currentTopBarVisibleHeight = _isHeaderCollapsed
        ? tabBarHeight
        : (headerHeight + tabBarHeight);

    final double listPaddingTop =
        systemStatusBarHeight + currentTopBarVisibleHeight;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final isPaginated = _mediaListController.isPaginated.value;
              final rebuildKey = _mediaListController.rebuildKey.value
                  .toString();

              return TabBarView(
                controller: _tabController,
                children: sorts.map((sort) {
                  return MediaTabView<T>(
                    key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                    repository: _repositories[sort.id]!,
                    emptyIcon: widget.emptyIcon,
                    // 使用 widget 的 emptyIcon
                    isPaginated: isPaginated,
                    rebuildKey: rebuildKey,
                    paddingTop: listPaddingTop,
                    mediaListController: _mediaListController, // 传递控制器用于滚动监听
                  );
                }).toList(),
              );
            }),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                      SizedBox(height: systemStatusBarHeight),

                      // CommonHeader 区域 - 动画其不透明度和 Offstage 状态
                      AnimatedOpacity(
                        opacity: _isHeaderCollapsed ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Offstage(
                          offstage: _isHeaderCollapsed,
                          child: SizedBox(
                            height: headerHeight,
                            child: CommonHeader(
                              searchSegment: widget
                                  .searchSegment, // 使用 widget 的 searchSegment
                              avatarRadius: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: tabBarHeight,
                        child: Row(
                          children: [
                            Expanded(
                              child: MouseRegion(
                                child: Listener(
                                  onPointerSignal: (pointerSignal) {
                                    if (pointerSignal is PointerScrollEvent) {
                                      _handleScroll(
                                        pointerSignal.scrollDelta.dy,
                                      );
                                    }
                                  },
                                  child: SingleChildScrollView(
                                    controller: _tabBarScrollController,
                                    scrollDirection: Axis.horizontal,
                                    physics: const ClampingScrollPhysics(),
                                    child: TabBar(
                                      isScrollable: true,
                                      overlayColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      tabAlignment: TabAlignment.start,
                                      dividerColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      controller: _tabController,
                                      tabs: sorts.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        Sort sort = entry.value;
                                        return Container(
                                          key: _tabKeys[index],
                                          child: Tab(
                                            child: Row(
                                              children: [
                                                sort.icon ?? const SizedBox(),
                                                const SizedBox(width: 4),
                                                Text(sort.label),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _buildAnimatedIconButton(
                              isVisible: !_isHeaderCollapsed,
                              child: Obx(
                                () => IconButton(
                                  icon: Icon(
                                    _mediaListController.isPaginated.value
                                        ? Icons.grid_view
                                        : Icons.menu,
                                  ),
                                  onPressed: () {
                                    if (!_mediaListController
                                        .isPaginated.value) {
                                      var sortId =
                                          sorts[_tabController.index].id;
                                      var repository = _repositories[sortId]!;
                                      repository.refresh(true);
                                    }
                                    _mediaListController.setPaginatedMode(
                                      !_mediaListController.isPaginated.value,
                                    );
                                  },
                                  tooltip:
                                      _mediaListController.isPaginated.value
                                          ? t.common.pagination.waterfall
                                          : t.common.pagination.pagination,
                                ),
                              ),
                            ),
                            _buildAnimatedIconButton(
                              isVisible: !_isHeaderCollapsed,
                              child: IconButton(
                                icon: const Icon(Icons.vertical_align_top),
                                onPressed: () =>
                                    _mediaListController.scrollToTop(),
                                tooltip: t.common.scrollToTop,
                              ),
                            ),
                            _buildAnimatedIconButton(
                              isVisible: !_isHeaderCollapsed,
                              child: IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed:
                                    tryRefreshCurrentSort, // 直接调用 state 的方法
                                tooltip: t.common.refresh,
                              ),
                            ),
                            _buildAnimatedIconButton(
                              isVisible: !_isHeaderCollapsed,
                              child: IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: _openParamsModal,
                                tooltip: t.common.search,
                              ),
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
      ),
      floatingActionButton: _isHeaderCollapsed
          ? Obx(
              () => Padding(
                padding: EdgeInsets.only(
                  bottom: _mediaListController.isPaginated.value ? 40 : 20,
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
                            _mediaListController.isPaginated.value
                                ? Icons.grid_view
                                : Icons.menu,
                          ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        onTap: () {
                          if (!_mediaListController.isPaginated.value) {
                            var sortId = sorts[_tabController.index].id;
                            var repository = _repositories[sortId]!;
                            repository.refresh(true);
                          }
                          _mediaListController.setPaginatedMode(
                            !_mediaListController.isPaginated.value,
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
                        onTap: tryRefreshCurrentSort,
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
                        onTap: () => _mediaListController.scrollToTop(),
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.filter_list),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        onTap: _openParamsModal,
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
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
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
