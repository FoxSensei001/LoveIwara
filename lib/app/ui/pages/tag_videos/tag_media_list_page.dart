import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_gallery_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_video_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/widgets/tag_video_search_config_widget.dart';
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 标签媒体列表页面 - 精简版本
class TagMediaListPage extends StatefulWidget {
  final Tag tag;
  final MediaType mediaType;

  const TagMediaListPage({
    super.key,
    required this.tag,
    required this.mediaType,
  });

  @override
  State<TagMediaListPage> createState() => _TagMediaListPageState();
}

class _TagMediaListPageState extends State<TagMediaListPage>
    with SingleTickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;
  late TabController _tabController;
  late ScrollController _tabBarScrollController;
  final List<GlobalKey> _tabKeys = [];

  late PopularMediaListController _mediaListController;
  final Map<SortId, BaseMediaRepository> _repositories = {};
  final Map<SortId, BaseMediaController> _controllers = {};

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  // 可拖拽浮动按钮状态
  Offset? _fabOffset;
  static const double _fabSize = 56.0;
  static const double _edgePadding = 16.0;

  @override
  void initState() {
    super.initState();

    // 设置初始标签
    tags = [widget.tag];

    final String baseTag =
        'tag_${widget.mediaType.name.toLowerCase()}_list_${widget.tag.id}';

    // 初始化控制器
    _mediaListController = Get.put(PopularMediaListController(), tag: baseTag);

    // 初始化tab相关
    for (var sort in sorts) {
      _tabKeys.add(GlobalKey());
      final String controllerTag = '${baseTag}_${sort.id.name}';
      late BaseMediaController controller;
      if (widget.mediaType == MediaType.VIDEO) {
        controller = Get.put(
          PopularVideoController(sortId: sort.id.name),
          tag: controllerTag,
        );
      } else {
        controller = Get.put(
          PopularGalleryController(sortId: sort.id.name),
          tag: controllerTag,
        );
      }
      _controllers[sort.id] = controller;
      _repositories[sort.id] = controller.repository;

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
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabBarScrollController.dispose();
    final String baseTag =
        'tag_${widget.mediaType.name.toLowerCase()}_list_${widget.tag.id}';
    Get.delete<PopularMediaListController>(tag: baseTag);

    for (var sort in sorts) {
      final String controllerTag = '${baseTag}_${sort.id.name}';
      if (widget.mediaType == MediaType.VIDEO) {
        Get.delete<PopularVideoController>(tag: controllerTag);
      } else {
        Get.delete<PopularGalleryController>(tag: controllerTag);
      }
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
  }

  void _onTabChange() {
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
    const double tabBarHeight = 40.0;
    const double headerHeight = 48.0; // 新增header高度
    final systemStatusBarHeight = MediaQuery.of(context).padding.top;
    final double topBarVisibleHeight =
        headerHeight + tabBarHeight; // 现在包含header和tab两行
    final double listPaddingTop = systemStatusBarHeight + topBarVisibleHeight;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 主要内容区域
              Positioned.fill(
                child: Obx(() {
                  final isPaginated = _mediaListController.isPaginated.value;
                  final rebuildKey = _mediaListController.rebuildKey.value
                      .toString();

                  // 初始化 FAB 位置
                  final bottomSafe = MediaQuery.of(context).padding.bottom;
                  final double extraBottom = isPaginated
                      ? (46 + bottomSafe + 20)
                      : 20;
                  _fabOffset ??= Offset(
                    constraints.maxWidth - _fabSize - _edgePadding,
                    constraints.maxHeight -
                        _fabSize -
                        _edgePadding -
                        extraBottom,
                  );

                  return TabBarView(
                    controller: _tabController,
                    children: sorts.map((sort) {
                      if (widget.mediaType == MediaType.VIDEO) {
                        return MediaTabView<Video>(
                          key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                          sortId: sort.id,
                          repository:
                              _repositories[sort.id]!
                                  as BaseMediaRepository<Video>,
                          emptyIcon: Icons.video_library_outlined,
                          isPaginated: isPaginated,
                          rebuildKey: rebuildKey,
                          paddingTop: listPaddingTop,
                          mediaListController: _mediaListController,
                          showBottomPadding: true,
                        );
                      } else {
                        return MediaTabView<ImageModel>(
                          key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                          sortId: sort.id,
                          repository:
                              _repositories[sort.id]!
                                  as BaseMediaRepository<ImageModel>,
                          emptyIcon: Icons.photo_library_outlined,
                          isPaginated: isPaginated,
                          rebuildKey: rebuildKey,
                          paddingTop: listPaddingTop,
                          mediaListController: _mediaListController,
                          showBottomPadding: true,
                        );
                      }
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
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.85),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 可拖拽浮动按钮
              Obx(() {
                final isPaginatedNow = _mediaListController.isPaginated.value;
                final bottomSafeNow = MediaQuery.of(context).padding.bottom;
                final double extraBottomNow = isPaginatedNow
                    ? (46 + bottomSafeNow + 20)
                    : 20;

                final double minX = _edgePadding;
                final double minY = _edgePadding;
                final double maxX =
                    constraints.maxWidth - _fabSize - _edgePadding;
                final double maxY =
                    constraints.maxHeight -
                    _fabSize -
                    _edgePadding -
                    extraBottomNow;
                final double showLeft = (_fabOffset?.dx ?? maxX)
                    .clamp(minX, maxX)
                    .toDouble();
                final double showTop = (_fabOffset?.dy ?? maxY)
                    .clamp(minY, maxY)
                    .toDouble();

                return Positioned(
                  left: showLeft,
                  top: showTop,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        final nextX =
                            (_fabOffset?.dx ?? showLeft) + details.delta.dx;
                        final nextY =
                            (_fabOffset?.dy ?? showTop) + details.delta.dy;
                        _fabOffset = Offset(
                          nextX.clamp(minX, maxX).toDouble(),
                          nextY.clamp(minY, maxY).toDouble(),
                        );
                      });
                    },
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
                          SpeedDialChild(
                            child: Icon(
                              _mediaListController.isPaginated.value
                                  ? Icons.grid_view
                                  : Icons.view_stream,
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
                            child: const Icon(Icons.filter_list),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            onTap: _openParamsModal,
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
                            onTap: () => _mediaListController.scrollToTop(),
                          ),
                          SpeedDialChild(
                            child: const Icon(Icons.refresh),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            onTap: _tryRefreshCurrentSort,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
