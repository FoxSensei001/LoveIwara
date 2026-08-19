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
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/saved_search_config_drawer.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:flutter/rendering.dart';
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
  late final SavedSearchConfigService _savedConfigService;

  /// 当前栏目的 segment 标识（video / image），用于区分保存的筛选配置。
  String get _segmentKey => widget.searchSegment.name;

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
    _savedConfigService = Get.find<SavedSearchConfigService>();
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

  /// 根据筛选条件生成一个默认名称（评级/日期/标签数）。
  String _buildDefaultConfigName({
    required List<Tag> tags,
    required String date,
    required String rating,
  }) {
    final parts = <String>[];
    if (rating.isNotEmpty) {
      final r = MediaRating.values.firstWhere(
        (e) => e.value == rating,
        orElse: () => MediaRating.ALL,
      );
      if (r != MediaRating.ALL) parts.add(r.label);
    }
    if (date.isNotEmpty) parts.add(date);
    if (tags.isNotEmpty) {
      parts.add(t.savedSearchConfig.tagsCount(count: tags.length));
    }
    return parts.isEmpty ? t.savedSearchConfig.noConditions : parts.join(' · ');
  }

  /// 弹出命名对话框，将给定筛选条件保存为一条新的快速筛选配置。
  Future<void> _promptSaveConfig({
    required List<Tag> tags,
    required String date,
    required String rating,
  }) async {
    final controller = TextEditingController(
      text: _buildDefaultConfigName(tags: tags, date: date, rating: rating),
    );
    final name = await showAppDialog<String>(
      Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(t.savedSearchConfig.namePromptTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.savedSearchConfig.nameLabel,
              hintText: t.savedSearchConfig.nameHint,
            ),
            onSubmitted: (v) => Navigator.of(dialogContext).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.common.cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(t.common.save),
            ),
          ],
        ),
      ),
    );
    if (name == null) return;

    final config = SavedSearchConfig(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.isEmpty
          ? _buildDefaultConfigName(tags: tags, date: date, rating: rating)
          : name,
      tags: List<Tag>.from(tags),
      date: date,
      rating: rating,
    );
    await _savedConfigService.add(_segmentKey, config);
    showToastWidget(
      MDToastWidget(
        message: t.savedSearchConfig.saveSuccess,
        type: MDToastType.success,
      ),
      position: ToastPosition.bottom,
    );
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

  /// 过窄时的排序入口：玻璃胶囊 + 下拉菜单（代替分段胶囊）。
  Widget _buildTabDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final index = _currentTabIndex.value;
    final currentSort = sorts[index];

    return PopupMenuButton<int>(
      initialValue: index,
      onSelected: (newIndex) => _tabController.animateTo(newIndex),
      position: PopupMenuPosition.under,
      // 往下挪一点，别压住玻璃胶囊本身
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GlassSurface(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: GlassTokens.motionDuration,
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
                        color: colorScheme.onSurface,
                      ),
                      child: currentSort.icon!,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    currentSort.label,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 22, color: colorScheme.onSurface),
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
    );
  }

  /// 左上角「我」圆钮：已登录显示头像（带未读红点），未登录显示占位图标。
  Widget _buildAvatarButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final user = userService.hasLoadedProfile
          ? userService.currentUser.value
          : null;
      final count =
          userService.notificationCount.value + userService.messagesCount.value;

      return GlassSurface(
        circle: true,
        tooltip: t.common.me,
        onTap: AppService.switchGlobalDrawer,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (user != null)
              // 头像铺满圆钮（只留 1px 玻璃描边），不要一圈内边距
              IgnorePointer(
                child: AvatarWidget(
                  user: user,
                  size: GlassTokens.pillHeight - 2,
                ),
              )
            else
              Icon(
                Icons.account_circle,
                size: 26,
                color: colorScheme.onSurface,
              ),
            if (count > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  static const String _menuActionOpenSearch = 'open_search';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionSavedConfigs = 'saved_configs';

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
      case _menuActionSavedConfigs:
        _openSavedConfigDrawer();
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildTopBarMenuItems({required bool isWide}) {
    final List<PopupMenuEntry<String>> items = [];

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
    items.add(const PopupMenuDivider());
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
      value: _menuActionSavedConfigs,
      icon: Icons.bookmarks_outlined,
      label: t.savedSearchConfig.title,
    );
    return items;
  }

  /// 右侧动作胶囊：[搜索(仅宽屏)] 筛选 · 批量 · 更多。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    return Obx(() {
      final isMultiSelect = _batchSelectController.isMultiSelect.value;
      return GlassButtonGroup(
        children: [
          if (isWide)
            GlassIconButton(
              icon: const Icon(Icons.search),
              tooltip: t.common.search,
              onPressed: _openSearchDialog,
            ),
          GlassIconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: t.searchFilter.filterSettings,
            showBadge: _hasActiveFilter,
            onPressed: _openParamsModal,
          ),
          GlassIconButton(
            icon: Icon(isMultiSelect ? Icons.close : Icons.checklist),
            tooltip: isMultiSelect ? t.common.exitEditMode : t.common.editMode,
            onPressed: _batchSelectController.toggleMultiSelect,
          ),
          SizedBox(
            width: GlassTokens.groupIconButtonSize,
            height: GlassTokens.groupIconButtonSize,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, size: GlassTokens.iconSize),
              position: PopupMenuPosition.under,
              // 往下挪一点，别压住玻璃胶囊本身
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: _handleTopBarMenuAction,
              itemBuilder: (context) => _buildTopBarMenuItems(isWide: isWide),
            ),
          ),
        ],
      );
    });
  }

  /// 滚过约一屏后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: Obx(() {
        final visible =
            _mediaListController.currentScrollOffset.value > 800 &&
            !_batchSelectController.isMultiSelect.value;
        return IgnorePointer(
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
        );
      }),
    );
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
            _promptSaveConfig(tags: tags, date: year, rating: rating);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = MediaQuery.sizeOf(context).width > 600;
          // 中间排序区可用宽度不足时退化为下拉
          const double sideWidth = GlassTokens.pillHeight; // 左侧头像圆钮
          final double actionGroupWidth =
              GlassTokens.groupIconButtonSize * (isWide ? 4 : 3) + 8;
          final double centerWidth =
              constraints.maxWidth -
              16 * 2 -
              8 * 2 -
              sideWidth -
              actionGroupWidth;
          final bool useSegmented = centerWidth >= 200;

          return Stack(
            children: [
              // 内容区域：列表铺满整页，通过 paddingTop 让出 header
              Obx(() {
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
                      onPageChanged: () =>
                          _batchSelectController.onPageChanged(),
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

              // 顶部渐变蒙层（列表滚到下面时淡出）
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: EdgeFadeScrim.top(
                  height: headerExtent + GlassTokens.headerFadeExtent,
                  // 平台段只盖状态栏；header 行本身已经在 S 曲线的衰减段里
                  solidExtent: statusBarHeight,
                ),
              ),

              // header 行：左 头像圆钮 / 中 排序分段胶囊 / 右 动作胶囊
              Positioned(
                top: statusBarHeight,
                left: 0,
                right: 0,
                height: headerRowHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildAvatarButton(context),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: useSegmented
                              ? Obx(
                                  () => GlassSegmentedControl(
                                    selectedIndex: _currentTabIndex.value,
                                    progress: _tabController.animation,
                                    onChanged: (i) =>
                                        _tabController.animateTo(i),
                                    items: sorts
                                        .map(
                                          (sort) => GlassSegmentItem(
                                            label: sort.label,
                                            icon: sort.icon,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                              : Obx(() => _buildTabDropdown(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionGroup(context, isWide: isWide),
                    ],
                  ),
                ),
              ),

              _buildScrollToTopFab(context),

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
