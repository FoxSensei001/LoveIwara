import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video.model.dart';

import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/services/saved_search_config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/saved_search_config_drawer.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:flutter/rendering.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/identity_avatar_button.dart';

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
  final int contentResetVersion;

  const PopularMediaListPageBase({
    super.key,
    required this.controllerTag,
    required this.searchSegment,
    required this.emptyIcon,
    this.contentResetVersion = 0,
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
      state.refreshOnReselect();
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

  late PopularMediaListController _mediaListController;
  late BatchSelectController<T> _batchSelectController;
  final UserService userService = Get.find<UserService>();

  /// 用于打开右侧「已保存筛选」抽屉。
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 已保存筛选的存储池：热门视频/图库与订阅页共用同一份配置。
  String get _segmentKey => SavedSearchConfigService.sharedSegment;

  final Map<SortId, R> _repositories = {};
  final Map<SortId, C> _controllers = {};

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  // Current tab index for segmented control / dropdown sync
  final RxInt _currentTabIndex = 0.obs;

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

  /// 再次点击当前栏目时触发：当前子 tab 回到顶部并重新加载，
  /// 已访问过的其他子 tab 也一并刷新。
  void refreshOnReselect() {
    if (!mounted) return;
    final activeSortId = sorts[_tabController.index].id;
    // 重置头部折叠状态并把当前列表滚动到顶部
    _mediaListController.scrollToTop();

    if (_mediaListController.isPaginated.value) {
      // 分页模式：当前子 tab 立即重建并重新加载第 0 页（MediaListView.initState 会触发），
      // 其他已访问子 tab 标记为待刷新（下次切换到它时重建并重载）。
      _mediaListController.invalidateLoadedSorts(activeSortId: activeSortId);
    } else {
      // 瀑布流模式：仓库实例是持久复用的，仅重建 Widget 不会重新请求，
      // 因此直接对所有已加载子 tab 的仓库执行刷新（当前 tab 就地更新）。
      for (final sortId in _mediaListController.loadedSorts) {
        _repositories[sortId]?.refresh(true);
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

  Future<void> _openVideoFromPopularList({
    required String videoId,
    required List<Video> loadedVideos,
    Map<String, dynamic>? extData,
  }) async {
    Video? initialVideoInfo;
    for (final video in loadedVideos) {
      if (video.id == videoId) {
        initialVideoInfo = video;
        break;
      }
    }

    final playlistContext = InnerPlaylistContext.fromVideos(
      source: InnerPlaylistSource.popularVideoList,
      videos: loadedVideos,
      currentVideoId: videoId,
    );

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      innerPlaylistContext: playlistContext,
      initialVideoInfo: initialVideoInfo,
    );
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SavedSearchConfigService>()) {
      Get.put(SavedSearchConfigService(), permanent: true);
    }
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
      // 使用 widget 的抽象方法创建 Controller
      final controller = widget.createSpecificController(sort.id.name);
      _controllers[sort.id] = controller;
      // 使用 widget 的抽象方法获取 Repository
      _repositories[sort.id] = widget.getSpecificRepository(controller);
    }
    _tabController = TabController(length: sorts.length, vsync: this);
    _tabController.addListener(_onTabChange);
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
    // 不再有可折叠的 header 行
    _mediaListController.configureHeaderExtent(0);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
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

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentResetVersion != widget.contentResetVersion) {
      _resetForContentChange();
    }
  }

  void _resetForContentChange() {
    tags = [];
    year = '';
    rating = '';

    for (final controller in _controllers.values) {
      if (controller is BaseMediaController) {
        controller.resetState();
      }
    }

    _batchSelectController.exitMultiSelect();

    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
    _currentTabIndex.value = 0;
    _mediaListController.invalidateLoadedSorts(
      activeSortId: sorts[_tabController.index].id,
    );
    _mediaListController.resetHeaderState();
    _mediaListController.currentScrollOffset.value = 0.0;
    _mediaListController.lastScrollDirection.value = ScrollDirection.idle;

    if (mounted) {
      setState(() {});
    }
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
    // 顶栏的筛选小红点读的是本 State 的字段，refreshPageUI 只动 controller 的
    // Rx，这里必须自己触发一次重建，否则红点要等下一次无关重建才亮/灭。
    if (mounted) {
      setState(() {});
    }
  }

  /// 当前是否有生效中的筛选（决定筛选入口是否显示小红点）。
  bool get _hasActiveFilter =>
      tags.isNotEmpty || year.isNotEmpty || rating.isNotEmpty;

  void _onTabChange() {
    _currentTabIndex.value = _tabController.index;
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
  }

  void _openParamsModal() {
    showAppDialog(
      PopularMediaSearchConfig(
        searchTags: tags,
        searchYear: year,
        searchRating: rating,
        // 本页的排序是 TabBar，这里不需要弹窗里的排序区，回调的 sortId 恒为 null
        onConfirm: (tags, year, rating, _) {
          setParams(tags: tags, year: year, rating: rating);
        },
      ),
    );
  }

  /// 打开右侧「已保存筛选」抽屉。
  void _openSavedConfigDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  /// 应用一条已保存的筛选配置，并关闭抽屉。
  void _applySavedConfig(SavedSearchConfig config) {
    setParams(
      tags: List<Tag>.from(config.tags),
      year: config.date,
      rating: config.rating,
    );
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  /// 过窄时的排序入口：下拉菜单（代替分段胶囊）。
  /// 只渲染「图标 + 文字 + 箭头」的无壳内容，玻璃壳由外层 GlassCapsuleMorph 提供。
  ///
  /// 文案接 `_tabController.animation`：横滑 TabBarView 时跟着手指一格一格
  /// 翻页（见 [GlassFlipLabel]），不是等滑完才换字。
  Widget _buildTabDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 触发位只是胶囊里的无壳内容；菜单走 [showGlassMenu]，材质跟着外层胶囊
    // 的档位走（玻璃胶囊 → 玻璃菜单）。Builder 是为了拿到**触发位自身**的
    // context 去量落点。
    return Builder(
      builder: (anchorContext) => GlassPressable(
        onTap: () => _openSortMenu(anchorContext),
        // 触发位是胶囊的全部内容，按下缩放会把整只胶囊带得一起抖；
        // 反馈改成整只胶囊压深一档（换掉 PopupMenuButton 原本的水波）。
        scale: 1.0,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: GlassTokens.pillHeight,
          decoration: BoxDecoration(
            color: pressed
                ? colorScheme.onSurface.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(GlassTokens.pillHeight / 2),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme.merge(
                  data: IconThemeData(color: colorScheme.onSurface),
                  child: GlassFlipLabel(
                    progress: _tabController.animation!,
                    labels: [for (final sort in sorts) sort.label],
                    icons: [for (final sort in sorts) sort.icon],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 22,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSortMenu(BuildContext anchorContext) async {
    final index = _currentTabIndex.value;
    final selected = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        for (var i = 0; i < sorts.length; i++)
          GlassMenuOption<int>(
            value: i,
            // Sort.icon 是个现成的 Widget，不是 IconData
            leading: sorts[i].icon,
            label: sorts[i].label,
            selected: i == index,
          ),
      ],
    );
    if (selected != null && mounted) {
      _tabController.animateTo(selected);
    }
  }

  static const String _menuActionOpenSearch = 'open_search';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionToggleBatchSelect = 'toggle_batch_select';

  void _handleTopBarMenuAction(String action) {
    switch (action) {
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
      case _menuActionToggleBatchSelect:
        _batchSelectController.toggleMultiSelect();
        break;
    }
  }

  List<GlassMenuEntry> _buildTopBarMenuItems({required bool isWide}) {
    final List<GlassMenuEntry> items = [];

    void addMenuItem({
      required String value,
      required IconData icon,
      required String label,
    }) {
      items.add(
        GlassMenuOption<String>(value: value, icon: icon, label: label),
      );
    }

    // 窄屏的搜索在底部独立圆钮上，宽屏在右侧胶囊里；菜单里再留一个兜底入口。
    if (!isWide) {
      addMenuItem(
        value: _menuActionOpenSearch,
        icon: Icons.search,
        label: t.common.search,
      );
    }
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
    // 批量选择：默认只收在菜单里；开启后按钮才会冒到右侧胶囊中，
    // 菜单里的入口同步换成「退出编辑模式」。
    addMenuItem(
      value: _menuActionToggleBatchSelect,
      icon: _batchSelectController.isMultiSelect.value
          ? Icons.close
          : Icons.checklist,
      label: _batchSelectController.isMultiSelect.value
          ? t.common.exitEditMode
          : t.common.editMode,
    );
    items.add(const GlassMenuSeparator());
    addMenuItem(
      value: _menuActionTogglePagination,
      icon: _mediaListController.isPaginated.value
          ? Icons.grid_view
          : Icons.view_stream,
      label: _mediaListController.isPaginated.value
          ? t.common.pagination.waterfall
          : t.common.pagination.pagination,
    );
    return items;
  }

  /// 右侧动作胶囊：[搜索(仅宽屏)] 筛选 · 已保存筛选 · [退出批量(多选中才冒出)] 更多。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    return Obx(() {
      final isMultiSelect = _batchSelectController.isMultiSelect.value;
      return GlassButtonGroup(
        // 液态档下整只胶囊接跟手拉伸；宽度会随 isWide/isMultiSelect 动画
        // 过渡，签名变化时 LiquidGlassSettledTouch 会先退回自然布局、
        // 等过渡跑完再重新量出精确宽度并开 touch（见该类说明）。
        touchFlex: true,
        touchFlexSignature: '$isWide|$isMultiSelect',
        children: [
          GlassGroupSlot(
            visible: isWide,
            child: GlassIconButton(
              icon: const Icon(Icons.search),
              tooltip: t.common.search,
              onPressed: _openSearchDialog,
            ),
          ),
          GlassIconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: t.searchFilter.filterSettings,
            showBadge: _hasActiveFilter,
            onPressed: _openParamsModal,
          ),
          GlassIconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: t.savedSearchConfig.title,
            onPressed: _openSavedConfigDrawer,
          ),
          // 批量模式的入口在「更多」菜单里；开启后这里只承担退出职责
          GlassGroupSlot(
            visible: isMultiSelect,
            child: GlassIconButton(
              icon: const Icon(Icons.close),
              tooltip: t.common.exitEditMode,
              onPressed: _batchSelectController.toggleMultiSelect,
            ),
          ),
          Builder(
            builder: (anchorContext) => GlassIconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                final action = await showGlassMenu<String>(
                  anchorContext: anchorContext,
                  entries: _buildTopBarMenuItems(isWide: isWide),
                  touchFlex: true,
                );
                if (action != null) _handleTopBarMenuAction(action);
              },
            ),
          ),
        ],
      );
    });
  }

  /// 滚过约一屏后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Obx(() {
      final visible =
          _mediaListController.currentScrollOffset.value > 800 &&
          !_batchSelectController.isMultiSelect.value;
      return Positioned(
        // 移动端底栏可见时与搜索圆钮中心共轴；宽屏（rail 布局）用普通右边距
        right: isFloatingBarInsetActive(context)
            ? GlassTokens.floatingActionCoAxisRight(GlassTokens.pillHeight)
            : 16,
        // 分页模式下底部固定着分页栏，浮钮要在安全区之上再避开栏体
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (_mediaListController.isPaginated.value
                ? PaginationBar.barHeight
                : 0),
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            offset: visible ? Offset.zero : const Offset(0, 0.4),
            child: AnimatedOpacity(
              duration: GlassTokens.motionDuration,
              opacity: visible ? 1 : 0,
              child: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.vertical_align_top),
                tooltip: t.common.scrollToTop,
                onPressed: _mediaListController.scrollToTop,
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerRowHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerRowHeight;

    return Scaffold(
      key: _scaffoldKey,
      // 抽屉盖在浮动底栏之上，不需要为底栏让位：还原系统原始底部安全区
      endDrawer: RemoveFloatingBarInset(
        child: SavedSearchConfigDrawer(
          segment: _segmentKey,
          onApply: _applySavedConfig,
          onAddCurrent: () {
            _scaffoldKey.currentState?.closeEndDrawer();
            SavedSearchConfigDrawer.promptSaveCurrent(
              segment: _segmentKey,
              tags: tags,
              date: year,
              rating: rating,
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = MediaQuery.sizeOf(context).width > 600;

          return BatchDownloadSelectionScope(
            controllers: [_batchSelectController],
            child: GlassHeaderOverlay(
            // 热门视频 / 图库：header 与浮层 chrome 走真折射透镜，列表本体
            // 留在传统档（见 GlassHeaderOverlay.liquid）。
            liquid: true,
            headerExtent: headerExtent,
            headerTop: statusBarHeight,
            solidExtent: statusBarHeight,
            body: Obx(() {
              // 内容区域：列表铺满整页，通过 paddingTop 让出 header
              final isPaginated = _mediaListController.isPaginated.value;
              final rebuildKey = _mediaListController.rebuildKey.value
                  .toString();
              final isMultiSelectMode =
                  _batchSelectController.isMultiSelect.value;
              final selectedMediaIds = _batchSelectController.selectedMediaIds
                  .toSet();

              _batchSelectController.setPaginatedMode(isPaginated);

              // 视口必须铺满整页（不能在外面套 Padding，否则内容会在 header
              // 下边缘被视口裁掉、永远滚不到 header 背后）；留白交给列表自身的
              // paddingTop，这样首屏从 header 下方开始、滚动时从 header 背后经过。
              return TabBarView(
                controller: _tabController,
                children: sorts.map((sort) {
                  final sortReloadVersion = _mediaListController
                      .reloadVersionFor(sort.id);
                  return MediaTabView<T>(
                    key: ValueKey(
                      '${sort.id}_${sortReloadVersion}_$isPaginated$rebuildKey',
                    ),
                    sortId: sort.id,
                    repository: _repositories[sort.id]!,
                    emptyIcon: widget.emptyIcon,
                    isPaginated: isPaginated,
                    // 底部安全区由 MediaQuery.padding.bottom 统一提供
                    //（窄屏时 Shell 已把浮动底栏的高度加进去）
                    showBottomPadding: true,
                    rebuildKey: rebuildKey,
                    paddingTop: headerExtent,
                    mediaListController: _mediaListController,
                    isMultiSelectMode: isMultiSelectMode,
                    selectedItemIds: selectedMediaIds,
                    onItemSelect: (media) =>
                        _batchSelectController.toggleSelection(media),
                    onPageChanged: () => _batchSelectController.onPageChanged(),
                    onOpenVideo:
                        T == Video &&
                            widget.searchSegment == SearchSegment.video
                        ? ({
                            required videoId,
                            required loadedVideos,
                            Map<String, dynamic>? extData,
                          }) => _openVideoFromPopularList(
                            videoId: videoId,
                            loadedVideos: loadedVideos,
                            extData: extData,
                          )
                        : null,
                  );
                }).toList(),
              );
            }),
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const IdentityAvatarButton(),
                  const SizedBox(width: 8),
                  // 「够不够摆下分段胶囊」读 Expanded 实际分到的宽度，不靠公式
                  // 预测右侧胶囊有几个键——批量模式的退出键会临时挤进来，公式
                  // 恒为错，且按钮收放途中更是差着一整个动画的时长。
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, centerConstraints) {
                        final segmentItems = [
                          for (final sort in sorts)
                            GlassSegmentItem(
                              label: sort.label,
                              icon: sort.icon,
                            ),
                        ];
                        // 平铺至少要能完整露出两个排序项，否则让位给下拉钮
                        final bool useSegmented =
                            centerConstraints.maxWidth >=
                            GlassSegmentedControl.minWidthFor(
                              context,
                              segmentItems,
                            );
                        return Align(
                          alignment: Alignment.centerLeft,
                          // 玻璃壳由 GlassCapsuleMorph 常驻提供，两侧只换
                          // 无壳内容——胶囊平滑伸缩，阴影/圆角全程完整。
                          child: Obx(() {
                            // 选择态下这只胶囊改报「已选 N 项」：进选择态是一次
                            // 页面级的模式切换，header 不该毫无反应
                            if (_batchSelectController.isMultiSelect.value) {
                              return GlassCapsuleMorph(
                                child: SizedBox(
                                  key: const ValueKey('selection'),
                                  width: 168,
                                  child: GlassSelectionSummary(
                                    selectedCount:
                                        _batchSelectController.selectedCount,
                                    allSelected: false,
                                    // 全选留空：这是一条懒加载的无限列表，
                                    // 「全选」够不到还没加载的部分，给了反而
                                    // 是个误导（见 glass_selection.dart）
                                    onToggleAll: null,
                                  ),
                                ),
                              );
                            }
                            return GlassCapsuleMorph(
                              child: useSegmented
                                  ? Obx(
                                      key: const ValueKey('segmented'),
                                      () => GlassSegmentedControl(
                                        flat: true,
                                        selectedIndex: _currentTabIndex.value,
                                        progress: _tabController.animation,
                                        onChanged: (i) =>
                                            _tabController.animateTo(i),
                                        items: segmentItems,
                                      ),
                                    )
                                  // 不再是 Obx：当前项现在只在打开菜单那一刻读
                                  // （_openSortMenu），触发位的文案由
                                  // _tabController.animation 驱动。空 Obx 会
                                  // 直接抛 ObxError。
                                  : KeyedSubtree(
                                      key: const ValueKey('dropdown'),
                                      child: _buildTabDropdown(context),
                                    ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionGroup(context, isWide: isWide),
                ],
              ),
            ),
            extra: [
              _buildScrollToTopFab(context),

              // 批量动作：瀑布流模式下的底部玻璃坞。分页模式下动作行由分页栏
              // 自己承载（见 BatchSelectionScope），这里自动隐身，底部不会
              // 出现第二条玻璃。
              Obx(
                () => GlassSelectionDock(
                  paginated: _mediaListController.isPaginated.value,
                ),
              ),
              ],
            ),
          );
        },
      ),
    );
  }
}
