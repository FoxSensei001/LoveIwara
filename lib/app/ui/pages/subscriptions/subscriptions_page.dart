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
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';

import 'package:i_iwara/app/services/tutorial_service.dart';

import 'controllers/media_list_controller.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import '../popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

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

  /// 当前 tab 是否支持筛选（0=视频，1=图库）
  bool get _isFilterSupportedTab => _tabController.index <= 1;

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
  static const String _menuActionOpenDrawer = 'open_drawer';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';

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
      case _menuActionOpenDrawer:
        AppService.switchGlobalDrawer();
        break;
      case _menuActionScrollTop:
        mediaListController.scrollToTop();
        break;
      case _menuActionTogglePagination:
        mediaListController.setPaginatedMode(
          !mediaListController.isPaginated.value,
        );
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildTopBarMenuItems({
    required BuildContext context,
    required bool isWide,
  }) {
    final t = slang.Translations.of(context);
    final List<PopupMenuEntry<String>> items = [];

    void addItem({
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
    items.add(const PopupMenuDivider());
    addItem(
      value: _menuActionTogglePagination,
      icon: mediaListController.isPaginated.value
          ? Icons.grid_view
          : Icons.view_stream,
      label: mediaListController.isPaginated.value
          ? t.common.pagination.waterfall
          : t.common.pagination.pagination,
    );
    // 本页左侧没有「我」头像钮（位置给了特别关注选择器），设置入口放菜单里
    addItem(
      value: _menuActionOpenDrawer,
      icon: Icons.settings,
      label: t.common.settings,
    );
    return items;
  }

  /// 右侧动作胶囊：[搜索(仅宽屏)] [筛选] [批量] 更多。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    final batchController = _activeBatchController;
    return Obx(() {
      final isMultiSelect = batchController?.isMultiSelect.value ?? false;
      return GlassButtonGroup(
        children: [
          if (isWide)
            GlassIconButton(
              key: _searchButtonKey,
              icon: const Icon(Icons.search),
              tooltip: t.common.search,
              onPressed: _openSearchDialog,
            ),
          if (_isFilterSupportedTab)
            GlassIconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: t.searchFilter.filterSettings,
              showBadge: _hasActiveFilter,
              onPressed: _openFilterDialog,
            ),
          if (batchController != null)
            GlassIconButton(
              icon: Icon(isMultiSelect ? Icons.close : Icons.checklist),
              tooltip: isMultiSelect
                  ? t.common.exitEditMode
                  : t.common.editMode,
              onPressed: batchController.toggleMultiSelect,
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
              itemBuilder: (context) =>
                  _buildTopBarMenuItems(context: context, isWide: isWide),
            ),
          ),
        ],
      );
    });
  }

  /// 特别关注用户选择器（玻璃胶囊）。
  Widget _buildUserSelector({required bool compact}) {
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
        compact: compact,
      );
    });
  }

  /// 滚过约一屏后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: Obx(() {
        final batchActive =
            _videoBatchController.isMultiSelect.value ||
            _imageBatchController.isMultiSelect.value;
        final visible =
            mediaListController.currentScrollOffset.value > 800 && !batchActive;
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
                onPressed: mediaListController.scrollToTop,
              ),
            ),
          ),
        );
      }),
    );
  }

  // 打开搜索对话框
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

    showAppDialog(
      SearchDialog(
        userInputKeywords: '',
        initialSegment: segment,
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

  /// 打开筛选弹窗（标签 / 年月 / 排序，订阅流下额外含评级）。
  ///
  /// 确认后只改 State，列表会在 didUpdateWidget 里按新参数重建数据源。
  void _openFilterDialog() {
    showAppDialog(
      PopularMediaSearchConfig(
        searchTags: _filterTags,
        searchYear: _filterDate,
        searchRating: _filterRating,
        showRating: _isRatingFilterAvailable,
        sortOptions: _filterSortOptions,
        selectedSortId: _filterSortId,
        onConfirm: (tags, year, rating, sortId) {
          if (!mounted) return;
          setState(() {
            _filterTags = tags;
            _filterDate = year;
            _filterRating = rating;
            _filterSortId = sortId ?? _filterSortId;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChange);
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
          // 左侧特别关注选择器：窄屏只放头像（compact），宽屏带名字
          final bool compactSelector = constraints.maxWidth < 720;
          final double selectorWidth = compactSelector ? 64 : 220;
          final int groupButtons =
              (isWide ? 1 : 0) +
              (_isFilterSupportedTab ? 1 : 0) +
              (_isBatchSupportedTab ? 1 : 0) +
              1;
          final double actionGroupWidth =
              GlassTokens.groupIconButtonSize * groupButtons + 8;
          final double centerWidth =
              constraints.maxWidth -
              16 * 2 -
              8 * 2 -
              selectorWidth -
              actionGroupWidth;
          final bool useSegmented = centerWidth >= 176;

          return Stack(
            children: [
              // 内容区域：列表铺满整页，通过 paddingTop 让出 header。
              // 视口不能在外面套 Padding（否则内容到 header 下边缘就被裁掉、
              // 永远滚不到 header 背后），留白交给列表自身的 paddingTop。
              Obx(() {
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

              // 顶部渐变蒙层（列表滚到下面时淡出）
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: EdgeFadeScrim.top(
                  height: headerExtent + GlassTokens.headerFadeExtent,
                  solidExtent: statusBarHeight,
                ),
              ),

              // header 行：左 特别关注选择器 / 中 视频·图库·帖子 分段 / 右 动作胶囊
              Positioned(
                top: statusBarHeight,
                left: 0,
                right: 0,
                height: headerRowHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildUserSelector(compact: compactSelector),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: useSegmented
                              ? GlassSegmentedControl(
                                  selectedIndex: _tabController.index,
                                  progress: _tabController.animation,
                                  onChanged: (i) => _tabController.animateTo(i),
                                  items: tabItems,
                                )
                              : _buildTabDropdown(context, tabItems),
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
              BatchActionFabColumn<Video>(
                controller: _videoBatchController,
                heroTagPrefix: 'subscriptions_video',
                isPaginated: mediaListController.isPaginated.value,
                visible: () => _tabController.index == 0,
              ),
              BatchActionFabColumn<ImageModel>(
                controller: _imageBatchController,
                heroTagPrefix: 'subscriptions_image',
                isPaginated: mediaListController.isPaginated.value,
                visible: () => _tabController.index == 1,
              ),
            ],
          );
        },
      ),
    );
  }

  /// 过窄时的子栏目入口：玻璃胶囊 + 下拉菜单（代替分段胶囊）。
  Widget _buildTabDropdown(BuildContext context, List<GlassSegmentItem> items) {
    final colorScheme = Theme.of(context).colorScheme;
    final index = _tabController.index;
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
            Text(
              items[index].label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 22, color: colorScheme.onSurface),
          ],
        ),
      ),
      itemBuilder: (context) => [
        for (var i = 0; i < items.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Text(items[i].label),
                if (i == index) ...[
                  const Spacer(),
                  Icon(Icons.check, size: 18, color: colorScheme.primary),
                ],
              ],
            ),
          ),
      ],
    );
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
