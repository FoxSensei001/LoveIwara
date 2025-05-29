import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/common_header.dart';
import 'package:i_iwara/app/ui/widgets/top_padding_height_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';

// 定义抽象基类，包含泛型 T (媒体模型), C (特定媒体控制器), R (特定媒体仓库)
abstract class PopularMediaListPageBase<T, C extends GetxController,
    R extends LoadingMoreBase<T>> extends StatefulWidget implements HomeWidgetInterface {
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
        final controller = Get.find<PopularMediaListController>(tag: controllerTag);
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
        W extends PopularMediaListPageBase<T, C, R>> extends State<W>
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

  @override
  void initState() {
    super.initState();
    _mediaListController =
        Get.put(PopularMediaListController(), tag: widget.controllerTag);

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
  }

  @override
  void dispose() {
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

  void setParams(
      {List<Tag> tags = const [], String year = '', String rating = ''}) {
    this.tags = tags;
    this.year = year;
    this.rating = rating;

    LogUtils.d('设置查询参数: tags: $tags, year: $year, rating: $rating',
        'PopularMediaListPageBase');

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
            'PopularMediaListPageBase');
        // 或者保留之前的 dynamic 调用，但不推荐
        // (controller as dynamic).updateSearchParams(
        //   searchTagIds: tags.map((e) => e.id).toList(),
        //   searchDate: year,
        //   searchRating: rating,
        // );
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
      final targetScroll = _tabBarScrollController.offset +
          position.dx -
          (screenWidth / 2) +
          (tabWidth / 2);
      final double finalScroll = targetScroll.clamp(
          0.0, _tabBarScrollController.position.maxScrollExtent);

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

  void _openParamsModal() {
    Get.dialog(PopularMediaSearchConfig(
      searchTags: tags,
      searchYear: year,
      searchRating: rating,
      onConfirm: (tags, year, rating) {
        setParams(tags: tags, year: year, rating: rating);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    const double tabBarHeight = 48.0;
    const double headerHeight = 56.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final isPaginated = _mediaListController.isPaginated.value;
              final rebuildKey =
                  _mediaListController.rebuildKey.value.toString();

              return TabBarView(
                controller: _tabController,
                children: sorts.map((sort) {
                  return MediaTabView<T>(
                    key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                    repository: _repositories[sort.id]!,
                    emptyIcon: widget.emptyIcon, // 使用 widget 的 emptyIcon
                    isPaginated: isPaginated,
                    rebuildKey: rebuildKey,
                    paddingTop: MediaQuery.of(context).padding.top +
                        headerHeight +
                        tabBarHeight -
                        6,
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
                child: Container(
                  color:
                      Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TopPaddingHeightWidget(),
                      CommonHeader(
                        searchSegment:
                            widget.searchSegment, // 使用 widget 的 searchSegment
                        avatarRadius: 20,
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
                                          pointerSignal.scrollDelta.dy);
                                    }
                                  },
                                  child: SingleChildScrollView(
                                    controller: _tabBarScrollController,
                                    scrollDirection: Axis.horizontal,
                                    physics: const ClampingScrollPhysics(),
                                    child: TabBar(
                                      isScrollable: true,
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.transparent),
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
                            Obx(() => IconButton(
                                  icon: Icon(
                                      _mediaListController.isPaginated.value
                                          ? Icons.grid_view
                                          : Icons.menu),
                                  onPressed: () {
                                    if (!_mediaListController
                                        .isPaginated.value) {
                                      var sortId =
                                          sorts[_tabController.index].id;
                                      var repository = _repositories[sortId]!;
                                      repository.refresh(true);
                                    }
                                    _mediaListController.setPaginatedMode(
                                        !_mediaListController
                                            .isPaginated.value);
                                  },
                                  tooltip:
                                      _mediaListController.isPaginated.value
                                          ? t.common.pagination.waterfall
                                          : t.common.pagination.pagination,
                                )),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed:
                                  tryRefreshCurrentSort, // 直接调用 state 的方法
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _openParamsModal,
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
    );
  }
}
