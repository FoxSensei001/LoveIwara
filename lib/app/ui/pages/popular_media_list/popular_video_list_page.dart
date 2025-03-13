import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/widgets/common_header.dart';

import '../../../models/sort.model.dart';
import '../../../models/tag.model.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'controllers/popular_video_controller.dart';
import 'controllers/popular_video_repository.dart';
import 'widgets/media_tab_view.dart';
import '../home_page.dart';

class PopularVideoListPage extends StatefulWidget with RefreshableMixin {
  static final globalKey = GlobalKey<_PopularVideoListPageState>();

  const PopularVideoListPage({super.key});

  @override
  State<PopularVideoListPage> createState() => _PopularVideoListPageState();

  @override
  void refreshCurrent() {
    final state = globalKey.currentState;
    if (state != null) {
      state.tryRefreshCurrentSort();
    }
  }
}

class _PopularVideoListPageState extends State<PopularVideoListPage>
    with SingleTickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;
  late TabController _tabController;
  late ScrollController _tabBarScrollController;
  final List<GlobalKey> _tabKeys = [];
  
  // 添加媒体列表控制器
  late PopularMediaListController _mediaListController;

  final UserService userService = Get.find<UserService>();

  final Map<SortId, PopularVideoRepository> _repositories = {};
  final Map<SortId, PopularVideoController> _controllers = {};

  void tryRefreshCurrentSort() {
    if (mounted) {
      var sortId = sorts[_tabController.index].id;
      var repository = _repositories[sortId];
      if (repository != null && !repository.isLoading) {
        repository.refresh(true);
      }
    }
  }

  // 查询参数
  List<Tag> tags = [];
  String year = '';
  String rating = '';

  @override
  void initState() {
    super.initState();
    
    // 初始化媒体列表控制器
    _mediaListController = Get.put(PopularMediaListController(), tag: 'video');
    
    for (var sort in sorts) {
      _tabKeys.add(GlobalKey());
      final controller = Get.put(PopularVideoController(sortId: sort.id.name), tag: sort.id.name);
      _controllers[sort.id] = controller;
      _repositories[sort.id] = controller.repository as PopularVideoRepository;
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
    Get.delete<PopularMediaListController>(tag: 'video');
    
    for (var controller in _controllers.values) {
      Get.delete<PopularVideoController>(tag: controller.sortId);
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

    LogUtils.d('设置查询参数: tags: $tags, year: $year, rating: $rating', 'PopularVideoListPage');

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
    _mediaListController.refreshList();
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
    return Scaffold(
      body: Column(
        children: [
          TopPaddingHeightWidget(),
          // 用抽离后的 CommonHeader 替换原有的头像和搜索框行
          const CommonHeader(
            searchSegment: SearchSegment.video,
            avatarRadius: 20,
          ),
          // 一行，显示TabBar和筛选按钮
          Row(
            children: [
              // TabBar
              Expanded(
                // 支持鼠标滚动 以及 tabbar 变动后位置调整
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
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        controller: _tabController,
                        tabs: sorts.asMap().entries.map((entry) {
                          int index = entry.key;
                          Sort sort = entry.value;
                          return Container(
                            key: _tabKeys[index], // 使用GlobalKey
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
              // 添加分页/瀑布流切换按钮
              Obx(() => IconButton(
                icon: Icon(_mediaListController.isPaginated.value 
                    ? Icons.grid_view 
                    : Icons.menu),
                onPressed: () {
                  _mediaListController.setPaginatedMode(!_mediaListController.isPaginated.value);
                },
                tooltip: _mediaListController.isPaginated.value 
                    ? '瀑布流'
                    : '分页',
              )),
              // 添加刷新按钮
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  var sortId = sorts[_tabController.index].id;
                  var repository = _repositories[sortId]!;
                  if (_mediaListController.isPaginated.value) {
                    (repository as ExtendedLoadingMoreBase).loadPageData(0, 20);
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
          // 使用 Expanded 包裹 TabBarView
          Expanded(
            child: Obx(() {
              final isPaginated = _mediaListController.isPaginated.value;
              final rebuildKey = _mediaListController.rebuildKey.value.toString();
              
              return TabBarView(
                controller: _tabController,
                children: sorts.map((sort) {
                  return MediaTabView<Video>(
                    key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                    repository: _repositories[sort.id]!,
                    emptyIcon: Icons.video_library_outlined,
                    isPaginated: isPaginated,
                    rebuildKey: rebuildKey,
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}
