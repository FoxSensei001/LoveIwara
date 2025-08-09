import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_video_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_video_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/widgets/tag_video_search_config_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 标签视频列表页面 - 精简版本
class TagVideoListPage extends StatefulWidget {
  final Tag tag;

  const TagVideoListPage({
    super.key,
    required this.tag,
  });

  @override
  State<TagVideoListPage> createState() => _TagVideoListPageState();
}

class _TagVideoListPageState extends State<TagVideoListPage>
    with SingleTickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;
  late TabController _tabController;
  late ScrollController _tabBarScrollController;
  final List<GlobalKey> _tabKeys = [];

  late PopularMediaListController _mediaListController;
  final Map<SortId, PopularVideoRepository> _repositories = {};
  final Map<SortId, PopularVideoController> _controllers = {};

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  @override
  void initState() {
    super.initState();
    
    // 设置初始标签
    tags = [widget.tag];
    
    // 初始化控制器
    _mediaListController = Get.put(
      PopularMediaListController(),
      tag: 'tag_video_list_${widget.tag.id}',
    );

    // 初始化tab相关
    for (var sort in sorts) {
      _tabKeys.add(GlobalKey());
      final controller = Get.put(
        PopularVideoController(sortId: sort.id.name),
        tag: 'tag_video_${widget.tag.id}_${sort.id.name}',
      );
      _controllers[sort.id] = controller;
      _repositories[sort.id] = controller.repository as PopularVideoRepository;
      
      // 为每个控制器设置标签参数
      controller.updateSearchParams(
        searchTagIds: [widget.tag.id],
        searchDate: year,
        searchRating: rating,
      );
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
    Get.delete<PopularMediaListController>(tag: 'tag_video_list_${widget.tag.id}');

    for (var sort in sorts) {
      Get.delete<PopularVideoController>(tag: 'tag_video_${widget.tag.id}_${sort.id.name}');
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
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
      TagVideoSearchConfigWidget(
        fixedTags: tags,
        searchYear: year,
        searchRating: rating,
        onConfirm: (newTags, newYear, newRating) {
          setState(() {
            // 保持固定标签不变，只更新年份和评级
            year = newYear;
            rating = newRating;
          });
          _updateSearchParams();
        },
      ),
    );
  }

  void _updateSearchParams() {
    for (var sort in sorts) {
      final controller = _controllers[sort.id]!;
      controller.updateSearchParams(
        searchTagIds: tags.map((e) => e.id).toList(),
        searchDate: year,
        searchRating: rating,
      );
    }
    _mediaListController.refreshPageUI();
  }

  void _tryRefreshCurrentSort() {
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
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    const double tabBarHeight = 40.0;
    const double headerHeight = 48.0; // 新增header高度
    final systemStatusBarHeight = MediaQuery.of(context).padding.top;
    final double topBarVisibleHeight = headerHeight + tabBarHeight; // 现在包含header和tab两行
    final double listPaddingTop = systemStatusBarHeight + topBarVisibleHeight;

    return Scaffold(
      body: Stack(
        children: [
          // 主要内容区域
          Positioned.fill(
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
                    paddingTop: listPaddingTop,
                    mediaListController: _mediaListController,
                  );
                }).toList(),
              );
            }),
          ),
          // 顶部Header + Tab栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  height: systemStatusBarHeight + topBarVisibleHeight,
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: systemStatusBarHeight),
                      // Header区域（第一行）- 包含返回按钮和标题
                      SizedBox(
                        height: headerHeight,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                '# ${widget.tag.id}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tab栏区域（第二行）
                      SizedBox(
                        height: tabBarHeight,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 浮动操作按钮
      floatingActionButton: Obx(
        () => Padding(
          padding: EdgeInsets.only(
            bottom: _mediaListController.isPaginated.value 
                ? (46 + (Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0) + 20)
                : 20,
            right: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 搜索选项按钮
              FloatingActionButton(
                heroTag: "filter",
                mini: true,
                onPressed: _openParamsModal,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                child: const Icon(Icons.filter_list),
              ),
              const SizedBox(height: 8),
              // 分页模式切换按钮
              FloatingActionButton(
                heroTag: "pagination",
                mini: true,
                onPressed: () {
                  if (!_mediaListController.isPaginated.value) {
                    var sortId = sorts[_tabController.index].id;
                    var repository = _repositories[sortId]!;
                    repository.refresh(true);
                  }
                  _mediaListController.setPaginatedMode(
                    !_mediaListController.isPaginated.value,
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                child: Icon(
                  _mediaListController.isPaginated.value
                      ? Icons.grid_view
                      : Icons.menu,
                ),
              ),
              const SizedBox(height: 8),
              // 回到顶部按钮
              FloatingActionButton(
                heroTag: "scrollToTop",
                mini: true,
                onPressed: () => _mediaListController.scrollToTop(),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                child: const Icon(Icons.vertical_align_top),
              ),
              const SizedBox(height: 8),
              // 刷新按钮
              FloatingActionButton(
                heroTag: "refresh",
                mini: true,
                onPressed: _tryRefreshCurrentSort,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}