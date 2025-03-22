import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/widgets/common_header.dart';
import 'dart:ui';

import '../../../models/sort.model.dart';
import '../../../models/tag.model.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'controllers/popular_gallery_controller.dart';
import 'controllers/popular_gallery_repository.dart';
import 'widgets/media_tab_view.dart';
import '../home_page.dart';

class PopularGalleryListPage extends StatefulWidget with RefreshableMixin {
  static final globalKey = GlobalKey<_PopularGalleryListPageState>();

  const PopularGalleryListPage({super.key});

  @override
  State<PopularGalleryListPage> createState() => _PopularGalleryListPageState();

  @override
  void refreshCurrent() {
    final state = globalKey.currentState;
    if (state != null) {
      state.tryRefreshCurrentSort();
    }
  }
}

class _PopularGalleryListPageState extends State<PopularGalleryListPage>
    with SingleTickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;

  late TabController _tabController;
  late ScrollController _tabBarScrollController;
  final List<GlobalKey> _tabKeys = [];

  // 添加媒体列表控制器
  late PopularMediaListController _mediaListController;

  final UserService userService = Get.find<UserService>();

  final Map<SortId, PopularGalleryRepository> _repositories = {};
  final Map<SortId, PopularGalleryController> _controllers = {};

  // 查询参数
  List<Tag> tags = [];
  String year = '';
  String rating = '';

  void tryRefreshCurrentSort() {
    if (mounted) {
      var sortId = sorts[_tabController.index].id;
      var repository = _repositories[sortId];
      // 如果当前仓库不是瀑布流模式，则刷新
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

    // 初始化媒体列表控制器
    _mediaListController =
        Get.put(PopularMediaListController(), tag: 'gallery');

    for (var sort in sorts) {
      _tabKeys.add(GlobalKey());
      final controller = Get.put(PopularGalleryController(sortId: sort.id.name),
          tag: sort.id.name);
      _controllers[sort.id] = controller;
      _repositories[sort.id] =
          controller.repository as PopularGalleryRepository;
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

    // 移除媒体列表控制器
    Get.delete<PopularMediaListController>(tag: 'gallery');

    for (var controller in _controllers.values) {
      Get.delete<PopularGalleryController>(tag: controller.sortId);
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
  }

  // 设置查询参数
  void setParams(
      {List<Tag> tags = const [], String year = '', String rating = ''}) {
    this.tags = tags;
    this.year = year;
    this.rating = rating;

    LogUtils.d('设置查询参数: tags: $tags, year: $year, rating: $rating',
        'PopularGalleryListPage');

    // 设置每个controller的查询参数并重置数据
    for (var sort in sorts) {
      var controller = _controllers[sort.id]!;
      controller.updateSearchParams(
        searchTagIds: tags.map((e) => e.id).toList(),
        searchDate: year,
        searchRating: rating,
      );
    }

    // 增加重建键值强制刷新UI
    _mediaListController.refreshPageUI();
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

  // 打开搜索配置弹窗
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
    // 计算TabBar的高度，用于设置paddingTop
    const double tabBarHeight = 48.0;
    const double headerHeight = 56.0;
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. 底层 TabBarView - 覆盖整个屏幕
          Positioned.fill(
            child: Obx(() {
              final isPaginated = _mediaListController.isPaginated.value;
              final rebuildKey = _mediaListController.rebuildKey.value.toString();

              return TabBarView(
                controller: _tabController,
                children: sorts.map((sort) {
                  return MediaTabView<ImageModel>(
                    key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                    repository: _repositories[sort.id]!,
                    emptyIcon: Icons.image_outlined,
                    isPaginated: isPaginated,
                    rebuildKey: rebuildKey,
                    // 设置paddingTop加上状态栏高度和header高度和tabbar高度
                    paddingTop: MediaQuery.of(context).padding.top + headerHeight + tabBarHeight - 12,
                  );
                }).toList(),
              );
            }),
          ),
          
          // 2. 顶层悬浮头部区域 - 带毛玻璃效果
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                      
                      // 通用头部组件
                      const CommonHeader(
                        searchSegment: SearchSegment.image,
                        avatarRadius: 20,
                      ),
                      
                      // Tab区域
                      SizedBox(
                        height: tabBarHeight,
                        child: Row(
                          children: [
                            // TabBar
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
                                      isScrollable: true,
                                      overlayColor: WidgetStateProperty.all(Colors.transparent),
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
                            
                            // 按钮区域
                            Obx(() => IconButton(
                              icon: Icon(_mediaListController.isPaginated.value
                                  ? Icons.grid_view
                                  : Icons.menu),
                              onPressed: () {
                                if (!_mediaListController.isPaginated.value) {
                                  var sortId = sorts[_tabController.index].id;
                                  var repository = _repositories[sortId]!;
                                  repository.refresh(true);
                                }
                                _mediaListController.setPaginatedMode(
                                    !_mediaListController.isPaginated.value);
                              },
                              tooltip: _mediaListController.isPaginated.value
                                  ? t.common.pagination.waterfall
                                  : t.common.pagination.pagination,
                            )),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                var sortId = sorts[_tabController.index].id;
                                var repository = _repositories[sortId]!;
                                if (_mediaListController.isPaginated.value) {
                                  _mediaListController.refreshPageUI();
                                } else {
                                  repository.refresh(true);
                                }
                              },
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
