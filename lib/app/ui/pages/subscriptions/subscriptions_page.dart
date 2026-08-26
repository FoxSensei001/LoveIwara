import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // 用于 ScrollDirection
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_site.dart';

import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/compact_subscription_dropdown.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_video_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_filter_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/saved_search_config_drawer.dart';
import 'package:i_iwara/app/services/saved_search_config_service.dart';

import 'package:i_iwara/app/services/tutorial_service.dart';

import 'controllers/media_list_controller.dart';
import '../popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/identity_avatar_button.dart';

class SubscriptionsPage extends StatefulWidget implements HomeWidgetInterface {
  static final globalKey = GlobalKey<SubscriptionsPageState>();
  final int contentResetVersion;
  final IwaraSite site;

  const SubscriptionsPage({
    super.key,
    required this.site,
    this.contentResetVersion = 0,
  });

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

  /// 视频 / 图库列表的筛选条件（帖子 tab 的接口不吃这些参数，不参与）。
  /// 排序默认 date —— 实测服务端默认排序就是 date，保持与接入前一致。
  List<Tag> _filterTags = [];
  String _filterDate = '';
  String _filterRating = '';
  SortId _filterSortId = SortId.date;

  /// 评级只在订阅流（未指定具体用户）下有效：带 `user=` 时服务端会忽略 rating。
  bool get _isRatingFilterAvailable => selectedId.isEmpty;

  /// 用于打开右侧「已保存筛选」抽屉。

  /// header 形变专用的「视觉 tab」：横滑过半就算已经到了目标栏目。
  ///
  /// `TabController.index` 要等松手才跳，拿它驱动 header 会变成「手指都离开
  /// 屏幕了，右侧两个筛选键才忽然消失、中间胶囊才忽然展开」。改读
  /// `animation.value` 的四舍五入值，形变就跟 [GlassFlipLabel] 的翻牌交接点
  /// 对齐在同一个位置——滑过半程的那一瞬，字翻完、键开始收、胶囊开始长。
  int get _visualTabIndex {
    final animation = _tabController.animation;
    if (animation == null) return _tabController.index;
    return animation.value.round().clamp(0, _tabController.length - 1);
  }

  /// 当前 tab 是否支持筛选（0=视频，1=图库）。按**视觉 tab** 算，好让筛选
  /// 键在手指还没松开时就开始收——入口只在这里出现，业务上没有别的判断依赖它。
  bool get _isFilterSupportedTab => _visualTabIndex <= 1;

  bool get _hasActiveFilter =>
      _filterTags.isNotEmpty ||
      _filterDate.isNotEmpty ||
      _filterSortId != SortId.date ||
      (_isRatingFilterAvailable && _filterRating.isNotEmpty);

  List<String> get _filterTagIds => _filterTags.map((tag) => tag.id).toList();

  /// 弹窗里的排序顺序：默认项「最新」排第一，其余保持 [CommonConstants.mediaSorts]
  /// 的原顺序。不能直接改那个常量——热门页的排序 TabBar 用的是同一份，改了会
  /// 连带把它的默认 tab 也换掉。
  List<Sort> get _filterSortOptions {
    final sorts = CommonConstants.mediaSorts;
    return [
      ...sorts.where((sort) => sort.id == SortId.date),
      ...sorts.where((sort) => sort.id != SortId.date),
    ];
  }

  // 教程指导需要的GlobalKey
  final GlobalKey _userSelectorKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();

  static const String _menuActionOpenSearch = 'open_search';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionToggleBatchSelect = 'toggle_batch_select';

  bool get _isBatchSupportedTab => _tabController.index <= 1;

  BatchSelectController? get _activeBatchController {
    if (!_isBatchSupportedTab) return null;
    return _tabController.index == 0
        ? _videoBatchController
        : _imageBatchController;
  }

  void _handleTopBarMenuAction(String action) {
    switch (action) {
      case _menuActionOpenSearch:
        _openSearchDialog();
        break;
      case _menuActionRefresh:
        refreshCurrentList();
        break;
      case _menuActionScrollTop:
        mediaListController.scrollToTop();
        break;
      case _menuActionTogglePagination:
        mediaListController.setPaginatedMode(
          !mediaListController.isPaginated.value,
        );
        break;
      case _menuActionToggleBatchSelect:
        _activeBatchController?.toggleMultiSelect();
        break;
    }
  }

  List<GlassMenuEntry> _buildTopBarMenuItems({
    required BuildContext context,
    required bool isWide,
  }) {
    final t = slang.Translations.of(context);
    final List<GlassMenuEntry> items = [];

    void addItem({
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
      addItem(
        value: _menuActionOpenSearch,
        icon: Icons.search,
        label: t.common.search,
      );
    }
    addItem(
      value: _menuActionRefresh,
      icon: Icons.refresh,
      label: t.common.refresh,
    );
    addItem(
      value: _menuActionScrollTop,
      icon: Icons.vertical_align_top,
      label: t.common.scrollToTop,
    );
    // 批量选择：默认只收在菜单里（帖子 tab 不支持）；开启后按钮才会冒到
    // 右侧胶囊中，菜单里的入口同步换成「退出编辑模式」。
    if (_isBatchSupportedTab) {
      final isMultiSelect =
          _activeBatchController?.isMultiSelect.value ?? false;
      addItem(
        value: _menuActionToggleBatchSelect,
        icon: isMultiSelect ? Icons.close : Icons.checklist,
        label: isMultiSelect ? t.common.exitEditMode : t.common.editMode,
      );
    }
    items.add(const GlassMenuSeparator());
    addItem(
      value: _menuActionTogglePagination,
      icon: mediaListController.isPaginated.value
          ? Icons.grid_view
          : Icons.view_stream,
      label: mediaListController.isPaginated.value
          ? t.common.pagination.waterfall
          : t.common.pagination.pagination,
    );
    // 「我」入口在 header 左侧的头像圆钮上（打开全局抽屉），菜单里不再重复
    return items;
  }

  /// 右侧动作胶囊：[搜索(仅宽屏)] 特别关注筛选 · [筛选] [已保存筛选] [退出批量(多选中才冒出)] 更多。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final batchController = _activeBatchController;
    return Obx(() {
      final isMultiSelect = batchController?.isMultiSelect.value ?? false;
      // 只让这一小块跟着横滑逐帧重建（整个 header 逐帧 setState 会连
      // TabBarView 一起重建，太贵）。
      return AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, _) => _buildActionGroupBody(
          context,
          isWide: isWide,
          isMultiSelect: isMultiSelect,
          batchController: batchController,
        ),
      );
    });
  }

  Widget _buildActionGroupBody(
    BuildContext context, {
    required bool isWide,
    required bool isMultiSelect,
    required BatchSelectController<dynamic>? batchController,
  }) {
    final t = slang.Translations.of(context);
    final bool filterVisible = _isFilterSupportedTab;
    return GlassButtonGroup(
      // 与热门视频/图库同一口径：整只胶囊接跟手形变（按住拖动时玻璃跟着手指
      // 走、松手弹回）。签名要囊括**所有会改变胶囊宽度**的外部状态——
      // 宽窄屏（搜索键）、批量态（退出键）、当前 tab 支不支持筛选（两枚筛选
      // 键），以及特别关注选中项（触发位的文案宽度会变）。
      touchFlex: true,
      touchFlexSignature: '$isWide|$isMultiSelect|$filterVisible|$selectedId',
      children: [
        GlassGroupSlot(
          visible: isWide,
          child: GlassIconButton(
            key: _searchButtonKey,
            icon: const Icon(Icons.search),
            tooltip: t.common.search,
            onPressed: _openSearchDialog,
          ),
        ),
        // 特别关注筛选：也是「按用户筛列表」，所以跟筛选/已保存筛选放一起
        _buildUserSelector(),
        GlassGroupSlot(
          visible: filterVisible,
          child: GlassIconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: t.searchFilter.filterSettings,
            showBadge: _hasActiveFilter,
            onPressed: _openFilterDialog,
          ),
        ),
        // 已保存筛选：与热门视频/图库共用同一份配置池
        GlassGroupSlot(
          visible: filterVisible,
          child: GlassIconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: t.savedSearchConfig.title,
            onPressed: _openSavedConfigDrawer,
          ),
        ),
        // 批量模式的入口在「更多」菜单里；开启后这里只承担退出职责
        GlassGroupSlot(
          visible: batchController != null && isMultiSelect,
          child: GlassIconButton(
            icon: const Icon(Icons.close),
            tooltip: t.common.exitEditMode,
            onPressed: () => batchController?.toggleMultiSelect(),
          ),
        ),
        Builder(
          builder: (anchorContext) => GlassIconButton(
            icon: const Icon(Icons.more_vert),
            // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
            // 松手选中（见 GlassTapArea.opensOverlay）。
            opensOverlay: true,
            onPressed: () async {
              final action = await showGlassMenu<String>(
                anchorContext: anchorContext,
                entries: _buildTopBarMenuItems(
                  context: anchorContext,
                  isWide: isWide,
                ),
              );
              if (action != null) _handleTopBarMenuAction(action);
            },
          ),
        ),
      ],
    );
  }

  /// 特别关注用户选择器：header 右侧动作胶囊里的无壳按钮位。
  Widget _buildUserSelector() {
    return Obx(() {
      final likedUsers = userPreferenceService.likedUsers;
      final userDropdownItems = likedUsers
          .map(
            (userDto) => SubscriptionDropdownItem(
              id: userDto.id,
              label: userDto.name,
              avatarUrl: userDto.avatarUrl,
              onLongPress: () =>
                  NaviService.navigateToAuthorProfilePage(userDto.username),
            ),
          )
          .toList();
      return CompactSubscriptionDropdown(
        key: _userSelectorKey,
        userList: userDropdownItems,
        selectedUserId: selectedId,
        onUserSelected: _onUserSelected,
      );
    });
  }

  /// 滚过约一屏后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final batchActive =
          _videoBatchController.isMultiSelect.value ||
          _imageBatchController.isMultiSelect.value;
      final visible =
          mediaListController.currentScrollOffset.value > 800 && !batchActive;
      return Positioned(
        // 移动端底栏可见时与搜索圆钮中心共轴；宽屏（rail 布局）用普通右边距
        right: isFloatingBarInsetActive(context)
            ? GlassTokens.floatingActionCoAxisRight(GlassTokens.pillHeight)
            : 16,
        // 分页模式下底部固定着分页栏，浮钮要在安全区之上再避开栏体
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (mediaListController.isPaginated.value
                ? PaginationBar.barHeight
                : 0),
        child: GlassReveal(
          visible: visible,
          builder: (context, m) => GlassIconButton(
            materialize: m,
            standalone: true,
            icon: const Icon(Icons.vertical_align_top),
            tooltip: t.common.scrollToTop,
            onPressed: mediaListController.scrollToTop,
          ),
        ),
      );
    });
  }

  // 打开搜索页面
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

    NaviService.navigateToSearchPage(
      initialSegment: segment,
    );
  }

  /// 打开筛选弹窗（标签 / 年月 / 排序，订阅流下额外含评级）。
  ///
  /// 确认后只改 State，列表会在 didUpdateWidget 里按新参数重建数据源。
  /// 打开右侧「筛选」抽屉。改动即时生效（列表在 didUpdateWidget 里按新参数重建
  /// 数据源），抽屉常驻不关。
  void _openFilterDialog() {
    showMediaFilterDrawer(
      context: context,
      tags: _filterTags,
      date: _filterDate,
      rating: _filterRating,
      showRating: _isRatingFilterAvailable,
      sortOptions: _filterSortOptions,
      selectedSortId: _filterSortId,
      onChanged: (tags, date, rating, sortId) {
        if (!mounted) return;
        setState(() {
          _filterTags = tags;
          _filterDate = date;
          _filterRating = rating;
          _filterSortId = sortId ?? _filterSortId;
        });
      },
    );
  }

  /// 打开右侧「已保存筛选」抽屉（与热门视频/图库共用同一份配置池，走同一条路由）。
  void _openSavedConfigDrawer() {
    showGlassSideDrawer<void>(
      context: context,
      builder: (drawerContext) => SavedSearchConfigDrawer(
        segment: SavedSearchConfigService.sharedSegment,
        onApply: (config) {
          Navigator.of(drawerContext).pop();
          _applySavedConfig(config);
        },
        onAddCurrent: () {
          Navigator.of(drawerContext).pop();
          SavedSearchConfigDrawer.promptSaveCurrent(
            segment: SavedSearchConfigService.sharedSegment,
            tags: _filterTags,
            date: _filterDate,
            rating: _filterRating,
          );
        },
      ),
    );
  }

  /// 应用一条已保存的筛选配置。
  void _applySavedConfig(SavedSearchConfig config) {
    setState(() {
      _filterTags = List<Tag>.from(config.tags);
      _filterDate = config.date;
      _filterRating = config.rating;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChange);
    if (!Get.isRegistered<SavedSearchConfigService>()) {
      Get.put(SavedSearchConfigService(), permanent: true);
    }
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
    mediaListController.setActiveTab(_tabController.index);
    // 不再有可折叠的 header 行
    mediaListController.configureHeaderExtent(0);

    // 显示教程指导（延迟执行，确保页面完全加载）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && userService.isAuthenticated) {
        TutorialService().showSubscriptionTutorial(context);
      }
    });
  }

  void _onTabChange() {
    mediaListController.setActiveTab(_tabController.index);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant SubscriptionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentResetVersion != widget.contentResetVersion) {
      _resetForContentChange();
    }
  }

  void _resetForContentChange() {
    selectedId = '';
    _filterTags = [];
    _filterDate = '';
    _filterRating = '';
    _filterSortId = SortId.date;
    _videoBatchController.exitMultiSelect();
    _imageBatchController.exitMultiSelect();
    mediaListController.resetHeaderState();
    mediaListController.currentScrollOffset.value = 0.0;
    mediaListController.lastScrollDirection.value = ScrollDirection.idle;

    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
    mediaListController.setActiveTab(_tabController.index);
    mediaListController.invalidateLoadedTabs(
      activeTabIndex: _tabController.index,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _onUserSelected(String id) {
    // 如果点击的是已选中的用户（且不是"全部"），则取消选择回到"全部"
    if (selectedId == id && id.isNotEmpty) {
      setState(() {
        selectedId = '';
      });
      // Reset scroll state when switching users
      mediaListController.resetHeaderState();
      mediaListController.currentScrollOffset.value = 0.0;
      mediaListController.lastScrollDirection.value = ScrollDirection.idle;
    } else if (selectedId != id) {
      setState(() {
        selectedId = id;
      });
      // Reset scroll state when switching users
      mediaListController.resetHeaderState();
      mediaListController.currentScrollOffset.value = 0.0;
      mediaListController.lastScrollDirection.value = ScrollDirection.idle;
    }
  }

  Future<void> refreshCurrentList() async {
    if (!mounted) return;
    // 当前子 tab 回到顶部并重载，已访问过的其他子 tab 标记为待刷新
    mediaListController.scrollToTop();
    mediaListController.invalidateLoadedTabs(
      activeTabIndex: _tabController.index,
    );
  }

  // 获取教程指导需要的GlobalKey
  GlobalKey get userSelectorKey => _userSelectorKey;
  GlobalKey get searchButtonKey => _searchButtonKey;

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
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
      if (userService.isAuthenticated) {
        return _buildLoggedInView(context);
      } else {
        return _buildNotLoggedIn(context);
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerRowHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerRowHeight;

    final tabItems = [
      GlassSegmentItem(label: t.common.video),
      GlassSegmentItem(label: t.common.gallery),
      GlassSegmentItem(label: t.common.post),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = MediaQuery.sizeOf(context).width > 600;

          return BatchDownloadSelectionScope(
            // 视频 / 图库两个控制器只广播当前 tab 那一个：InheritedWidget
            // 取最近的一层，套两层的话分页栏会永远读到内层那个
            controllers: [_videoBatchController, _imageBatchController],
            activeIndex: () => _tabController.index,
            child: GlassHeaderOverlay(
              // 订阅：header 与浮层 chrome 走真折射透镜，列表本体留在传统档
              // （见 GlassHeaderOverlay.liquid）。
              liquid: true,
              headerExtent: headerExtent,
              headerTop: statusBarHeight,
              solidExtent: statusBarHeight,
              body: Obx(() {
                // 内容区域：列表铺满整页，通过 paddingTop 让出 header。
                // 视口不能在外面套 Padding（否则内容到 header 下边缘就被裁掉、
                // 永远滚不到 header 背后），留白交给列表自身的 paddingTop。
                final isPaginated = mediaListController.isPaginated.value;
                final rebuildKey = mediaListController.rebuildKey.value
                    .toString();
                final videoReloadVersion = mediaListController
                    .reloadVersionForTab(0);
                final imageReloadVersion = mediaListController
                    .reloadVersionForTab(1);
                final postReloadVersion = mediaListController
                    .reloadVersionForTab(2);
                // 底部安全区由 MediaQuery.padding.bottom 统一提供
                //（窄屏时 Shell 已把浮动底栏的高度加进去）
                const bool shouldApplyBottomSafeAreaPadding = true;

                // 同步分页模式状态到批量选择控制器
                _videoBatchController.setPaginatedMode(isPaginated);
                _imageBatchController.setPaginatedMode(isPaginated);

                return TabBarView(
                  controller: _tabController,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    GlowNotificationWidget(
                      key: ValueKey(
                        'video_${selectedId}_${isPaginated}_${videoReloadVersion}_$rebuildKey',
                      ),
                      child: Obx(
                        () => SubscriptionVideoList(
                          userId: selectedId,
                          tabIndex: 0,
                          isPaginated: isPaginated,
                          paddingTop: headerExtent,
                          sortId: _filterSortId.name,
                          searchTagIds: _filterTagIds,
                          searchDate: _filterDate,
                          searchRating: _filterRating,
                          showBottomPadding: shouldApplyBottomSafeAreaPadding,
                          isMultiSelectMode:
                              _videoBatchController.isMultiSelect.value,
                          selectedItemIds: _videoBatchController
                              .selectedMediaIds
                              .toSet(),
                          onItemSelect: (video) =>
                              _videoBatchController.toggleSelection(video),
                        ),
                      ),
                    ),
                    GlowNotificationWidget(
                      key: ValueKey(
                        'image_${selectedId}_${isPaginated}_${imageReloadVersion}_$rebuildKey',
                      ),
                      child: Obx(
                        () => SubscriptionImageList(
                          userId: selectedId,
                          tabIndex: 1,
                          isPaginated: isPaginated,
                          paddingTop: headerExtent,
                          sortId: _filterSortId.name,
                          searchTagIds: _filterTagIds,
                          searchDate: _filterDate,
                          searchRating: _filterRating,
                          showBottomPadding: shouldApplyBottomSafeAreaPadding,
                          isMultiSelectMode:
                              _imageBatchController.isMultiSelect.value,
                          selectedItemIds: _imageBatchController
                              .selectedMediaIds
                              .toSet(),
                          onItemSelect: (image) =>
                              _imageBatchController.toggleSelection(image),
                        ),
                      ),
                    ),
                    GlowNotificationWidget(
                      key: ValueKey(
                        'post_${selectedId}_${isPaginated}_${postReloadVersion}_$rebuildKey',
                      ),
                      child: SubscriptionPostList(
                        userId: selectedId,
                        tabIndex: 2,
                        isPaginated: isPaginated,
                        paddingTop: headerExtent,
                        showBottomPadding: shouldApplyBottomSafeAreaPadding,
                      ),
                    ),
                  ],
                );
              }),
              header: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const IdentityAvatarButton(),
                    const SizedBox(width: 8),
                    _buildCenterCapsule(context, tabItems),
                    const SizedBox(width: 8),
                    _buildActionGroup(context, isWide: isWide),
                  ],
                ),
              ),
              extra: [
                _buildScrollToTopFab(context),

                // 批量动作：瀑布流模式下的底部玻璃坞；分页模式下动作行由分页栏
                // 自己承载（见 BatchSelectionScope），底部不会出现第二条玻璃。
                Obx(
                  () => GlassSelectionDock(
                    paginated: mediaListController.isPaginated.value,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// header 中间的子栏目控件：空间够就平铺分段胶囊，不够退化成下拉钮。
  ///
  /// 「够不够」不再靠公式预测右侧胶囊有几个键——那份算术在按钮**正在**
  /// 收放的那几百毫秒里恒为错，会让分段胶囊在右侧还没让出空间时就被塞进
  /// 来、当场被裁掉半截（2026-08-20 订阅页横滑到「投稿」的反馈）。这里直接
  /// 读 `Expanded` 实际分到的宽度：右侧胶囊一帧一帧收窄，中间的可用宽度就
  /// 一帧一帧变宽，`useSegmented` 自然在**真的放得下那一刻**才翻——两段动
  /// 效因此天然串成先后，而不是抢在一起。
  Widget _buildCenterCapsule(
    BuildContext context,
    List<GlassSegmentItem> tabItems,
  ) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, centerConstraints) {
          // 平铺至少要能完整露出两个子栏目，否则不如让位给下拉钮
          final bool useSegmented =
              centerConstraints.maxWidth >=
              GlassSegmentedControl.minWidthFor(context, tabItems);
          return Align(
            alignment: Alignment.centerLeft,
            // 玻璃壳由 GlassCapsuleMorph 常驻提供，两侧只换
            // 无壳内容——胶囊平滑伸缩，阴影/圆角全程完整。
            child: Obx(() {
              // 选择态下这只胶囊改报「已选 N 项」：进选择态是一次页面级的
              // 模式切换，header 不该毫无反应。
              // 两个控制器的 Rx 都要在分支之外读一次：帖子 tab 上 batch 为
              // null，那一支不碰任何可观察量的话 Obx 会直接抛 ObxError。
              final bool videoSelecting =
                  _videoBatchController.isMultiSelect.value;
              final bool imageSelecting =
                  _imageBatchController.isMultiSelect.value;
              final batch = _activeBatchController;
              final bool selecting = batch == null
                  ? false
                  : (batch == _videoBatchController
                        ? videoSelecting
                        : imageSelecting);
              if (batch != null && selecting) {
                return GlassCapsuleMorph(
                  child: SizedBox(
                    key: const ValueKey('selection'),
                    width: 168,
                    child: GlassSelectionSummary(
                      selectedCount: batch.selectedCount,
                      allSelected: false,
                      // 懒加载列表够不到未加载的部分，不给全选
                      onToggleAll: null,
                    ),
                  ),
                );
              }
              return GlassCapsuleMorph(
                child: useSegmented
                    ? GlassSegmentedControl(
                        key: const ValueKey('segmented'),
                        flat: true,
                        selectedIndex: _tabController.index,
                        progress: _tabController.animation,
                        onChanged: (i) => _tabController.animateTo(i),
                        items: tabItems,
                      )
                    : KeyedSubtree(
                        key: const ValueKey('dropdown'),
                        child: _buildTabDropdown(context, tabItems),
                      ),
              );
            }),
          );
        },
      ),
    );
  }

  /// 过窄时的子栏目入口：下拉菜单（代替分段胶囊）。
  /// 只渲染「文字 + 箭头」的无壳内容，玻璃壳由外层 GlassCapsuleMorph 提供。
  ///
  /// 文案接 `_tabController.animation`：横滑 TabBarView 时跟着手指一格一格
  /// 翻页（见 [GlassFlipLabel]），不是等滑完才换字。
  Widget _buildTabDropdown(BuildContext context, List<GlassSegmentItem> items) {
    final colorScheme = Theme.of(context).colorScheme;
    // 菜单走 [showGlassMenu]，材质跟着外层胶囊的档位走；Builder 是为了拿到
    // 触发位自身的 context 去量落点。
    return Builder(
      builder: (anchorContext) => GlassPressable(
        // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
        // 松手选中（见 GlassTapArea.opensOverlay）。
        opensOverlay: true,
        onTap: () => _openTabMenu(anchorContext, items),
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
                GlassFlipLabel(
                  progress: _tabController.animation!,
                  labels: [for (final item in items) item.label],
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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

  Future<void> _openTabMenu(
    BuildContext anchorContext,
    List<GlassSegmentItem> items,
  ) async {
    final index = _tabController.index;
    final selected = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        for (var i = 0; i < items.length; i++)
          GlassMenuOption<int>(
            value: i,
            label: items[i].label,
            selected: i == index,
          ),
      ],
    );
    if (selected != null && mounted) {
      _tabController.animateTo(selected);
    }
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
