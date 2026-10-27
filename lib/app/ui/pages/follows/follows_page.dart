import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/followers_list.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/following_list.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/special_follows_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follow_search_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/follow_search_list.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_row.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';

/// 关注 / 粉丝 / 特别关注（玻璃化，一行 header）。
///
/// header：返回 / 是谁的列表 + 关注类型（见 [_FollowsPageState._buildTitle]）/
/// 可展开的搜索钮 / 动作胶囊。
/// 列表与历史记录页一样铺满视口，从悬浮玻璃控件下方滚过。
class FollowsPage extends StatefulWidget {
  final String userId;
  final String name;
  final String username;
  final bool initIsFollowing;
  final int? initialIndex;

  const FollowsPage({
    super.key,
    required this.userId,
    required this.name,
    required this.username,
    required this.initIsFollowing,
    this.initialIndex,
  });

  @override
  State<FollowsPage> createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage>
    with SingleTickerProviderStateMixin {
  /// header 与列表首屏之间的呼吸。
  static const double _headerBottomGap = 8;

  /// 名字胶囊与分段胶囊之间的间距。
  static const double _titleGap = 8;

  /// 名字胶囊至少要这么宽才和分段胶囊并排，再窄就并进下拉钮。
  static const double _ownerMinWidth = 96;

  late TabController _tabController;
  late FollowsController controller;
  final _searchInputs = List.generate(3, (_) => TextEditingController());
  bool _scrollSyncPending = false;

  FollowSearchController? get _activeSearch => switch (_tabController.index) {
    0 => controller.followingSearch,
    1 => controller.followersSearch,
    _ => null,
  };

  void _queueBackToTopSync() {
    if (_scrollSyncPending) return;
    _scrollSyncPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollSyncPending = false;
      if (mounted) _syncBackToTop();
    });
  }

  void _updateSearch(String query) {
    final index = _tabController.index;
    if (index == 0) controller.followingSearch.setQuery(query);
    if (index == 1) controller.followersSearch.setQuery(query);
    if (index == 2) controller.specialSearchQuery.value = query;
    _queueBackToTopSync();
  }

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  /// 瀑布 ↔ 分页；初值取全局默认，切换后写回（跨页面、跨启动生效）。
  late bool _isPaginated = CommonConstants.isPaginated;

  /// 每个远端 tab 一个刷新信号：分页模式必须由 MediaListView 自己刷新，
  /// 直接 `repository.refresh()` 只会动数据源、不会换掉当前显示的那一页。
  /// 分开放是为了刷新当前 tab 时不连带重拉另一个 tab。
  /// 带回执，好让 header 的刷新钮在分页模式下也能显示沙漏
  /// （分页模式不经过 controller 的 isLoading）。
  final List<ListRefreshSignal> _refreshSignals = [
    ListRefreshSignal(),
    ListRefreshSignal(),
  ];

  /// 特别关注是本地列表（UserPreferenceService）：既没有远端刷新，也没有分页。
  bool get _isLocalTab => _tabController.index == 2;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      FollowsController(
        userId: widget.userId,
        initIsFollowing: widget.initIsFollowing,
      ),
      tag: widget.userId,
    );
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex ?? (widget.initIsFollowing ? 0 : 1),
    );
    _tabController.addListener(_onTabChanged);
    controller.followingSearch.addListener(_queueBackToTopSync);
    controller.followersSearch.addListener(_queueBackToTopSync);

    // 三个 tab 各持一个滚动控制器（在 controller 里），共用同一个监听
    for (final scrollController in _scrollControllers) {
      scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    // 先摘监听再 Get.delete（delete 会连带 dispose 掉三个滚动控制器）
    for (final scrollController in _scrollControllers) {
      scrollController.removeListener(_onScroll);
    }
    _tabController.removeListener(_onTabChanged);
    controller.followingSearch.removeListener(_queueBackToTopSync);
    controller.followersSearch.removeListener(_queueBackToTopSync);

    for (final input in _searchInputs) {
      input.dispose();
    }
    _tabController.dispose();
    _showBackToTop.dispose();
    for (final signal in _refreshSignals) {
      signal.dispose();
    }
    Get.delete<FollowsController>(tag: widget.userId);
    super.dispose();
  }

  List<ScrollController> get _scrollControllers => [
    controller.followingListScrollController,
    controller.followersListScrollController,
    controller.specialFollowsScrollController,
  ];

  ScrollController get _activeScrollController =>
      _scrollControllers[_tabController.index];

  void _onTabChanged() {
    // 动画途中 indexIsChanging 为 true，只关心落定后的那次
    if (_tabController.indexIsChanging) return;
    if (mounted) setState(() {});
    _syncBackToTop();
  }

  void _onScroll() {
    final active = _activeScrollController;
    if (active.hasClients) {
      _showBackToTop.value = active.position.pixels >= 300;
    }
  }

  void _syncBackToTop() {
    final active = _activeScrollController;
    _showBackToTop.value = active.hasClients && active.position.pixels >= 300;
  }

  void _scrollToTop() {
    final active = _activeScrollController;
    if (active.hasClients) {
      active.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _refreshCurrentTab() async {
    final int index = _tabController.index;
    if (index > 1) return;
    if (_isPaginated) {
      // 分页模式下刷新数据源不会换掉当前显示的那一页，得让 MediaListView 重载；
      // 等它回执才算刷完，否则刷新钮的沙漏会立刻弹回去
      await _refreshSignals[index].request();
      return;
    }
    await controller.refreshCurrentTab(index);
  }

  void _togglePaginationMode() {
    setState(() => _isPaginated = !_isPaginated);
    persistPaginationMode(_isPaginated);
  }

  /// 右侧动作胶囊：瀑布/分页切换 · 刷新。
  ///
  /// 特别关注是本地列表，两个键都没有意义——整只胶囊经 [GlassCapsuleReveal]
  /// 先缩小淡出、再收掉占位。（只把内部按钮收成 0 宽是不够的：胶囊壳自身还有
  /// 左右内边距和描边，会在 header 上留下一条竖着的细色块。）
  Widget _buildActionGroup(BuildContext context, {bool compact = false}) {
    final t = slang.Translations.of(context);
    return Obx(() {
      // 两个观察量必须无条件读取——分支跳过某一个会导致本 tab 下 Obx
      // 一个 observable 都没订阅到，GetX 直接抛 ObxError。
      final bool loadingFollowing = controller.isLoadingFollowing.value;
      final bool loadingFollowers = controller.isLoadingFollowers.value;
      final int index = _tabController.index;
      final bool isLocalTab = index == 2;
      final bool isLoading = index == 0
          ? loadingFollowing
          : index == 1
          ? loadingFollowers
          : false;
      return GlassCapsuleReveal(
        visible: !isLocalTab,
        child: GlassButtonGroup(
          children: compact
              ? [
                  Builder(
                    builder: (anchorContext) => GlassAsyncIconButton(
                      icon: const Icon(Icons.more_horiz),
                      loading: isLoading,
                      tooltip: t.common.more,
                      onPressed: () async {
                        final action = await showGlassMenu<int>(
                          anchorContext: anchorContext,
                          entries: [
                            GlassMenuOption(
                              value: 0,
                              label: _isPaginated
                                  ? t.common.pagination.waterfall
                                  : t.common.pagination.pagination,
                              leading: Icon(
                                _isPaginated
                                    ? Icons.view_stream
                                    : Icons.grid_view,
                              ),
                            ),
                            GlassMenuOption(
                              value: 1,
                              label: t.common.refresh,
                              leading: const Icon(Icons.refresh),
                            ),
                          ],
                        );
                        if (!mounted) return;
                        if (action == 0) _togglePaginationMode();
                        if (action == 1) await _refreshCurrentTab();
                      },
                    ),
                  ),
                ]
              : [
                  GlassIconButton(
                    icon: Icon(
                      _isPaginated ? Icons.grid_view : Icons.view_stream,
                    ),
                    tooltip: _isPaginated
                        ? t.common.pagination.waterfall
                        : t.common.pagination.pagination,
                    onPressed: _togglePaginationMode,
                  ),
                  // 瀑布模式的刷新由 controller 的 isLoading 驱动（下拉刷新也会点亮
                  // 它），分页模式没有那面旗子，靠按钮自己跟着刷新信号的回执走。
                  GlassAsyncIconButton(
                    icon: const Icon(Icons.refresh),
                    loading: isLoading,
                    tooltip: t.common.refresh,
                    onPressed: _refreshCurrentTab,
                  ),
                ],
        ),
      );
    });
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Positioned(
      right: 16,
      bottom:
          MediaQuery.paddingOf(context).bottom +
          16 +
          (_isPaginated && !_isLocalTab ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) =>
            ScrollToTopFab(visible: visible, onPressed: _scrollToTop),
      ),
    );
  }

  /// 标题区：**是谁的列表** + 关注类型。
  ///
  /// 这页不只看自己——从作者页进来时是别人的关注列表，所以名字必须常驻。
  /// - 放得下全部三段时：名字胶囊（截断后点开看全文）+ 平铺的分段胶囊；
  /// - 放不下时并成一只下拉钮「名字 · 关注 ▾」，只写昵称（没有才写 @用户名），
  ///   先省略名字，类型保持完整。
  Widget _buildTitle(BuildContext context, List<GlassSegmentItem> tabItems) {
    final handle = '@${widget.username}';
    final owner = widget.name.isEmpty ? handle : '${widget.name} $handle';
    final ownerShort = widget.name.isEmpty ? handle : widget.name;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final tabsWidth = GlassSegmentedControl.minWidthFor(
          context,
          tabItems,
          minVisibleItems: tabItems.length.toDouble(),
        );
        final ownerSpace = width - tabsWidth - _titleGap;
        if (ownerSpace >= _ownerMinWidth) {
          return Row(
            children: [
              // GlassTitlePill 自己是一只不带 widthFactor 的 Align，给多宽占多宽
              // （玻璃只包住文字，剩下的是空白）。按文字量出胶囊宽度再封顶，
              // 分段胶囊才紧跟在名字后面。
              SizedBox(
                width: math.min(_ownerPillWidth(context, owner), ownerSpace),
                child: GlassTitlePill(title: owner),
              ),
              const SizedBox(width: _titleGap),
              SizedBox(
                width: tabsWidth,
                child: GlassAdaptiveSegmentedControl(
                  selectedIndex: _tabController.index,
                  progress: _tabController.animation,
                  onChanged: _tabController.animateTo,
                  items: tabItems,
                ),
              ),
            ],
          );
        }
        return GlassBoundedDropdown(
          width: width,
          prefix: ownerShort,
          items: tabItems,
          selectedIndex: _tabController.index,
          onChanged: _tabController.animateTo,
        );
      },
    );
  }

  /// 名字胶囊放下全名要的宽度：标题字样（与 [GlassTitlePill] 同一口径）
  /// + 左右各 16 的内边距 + 描边。
  static double _ownerPillWidth(BuildContext context, String owner) {
    final painter = TextPainter(
      text: TextSpan(
        text: owner,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width.ceilToDouble() + 32 + GlassTokens.strokeWidth * 2;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerHeight;

    final tabItems = [
      GlassSegmentItem(label: t.common.following),
      GlassSegmentItem(label: t.common.fans),
      GlassSegmentItem(label: t.common.specialFollowed),
    ];

    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        headerHeight: headerHeight,
        solidExtent: statusBarHeight,
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            FollowingList(
              scrollController: controller.followingListScrollController,
              controller: controller,
              paddingTop: headerExtent + _headerBottomGap,
              isPaginated: _isPaginated,
              refreshSignal: _refreshSignals[0],
            ),
            FollowersList(
              scrollController: controller.followersListScrollController,
              controller: controller,
              paddingTop: headerExtent + _headerBottomGap,
              isPaginated: _isPaginated,
              refreshSignal: _refreshSignals[1],
            ),
            SpecialFollowsList(
              controller: controller,
              paddingTop: headerExtent + _headerBottomGap,
            ),
          ],
        ),
        // header 一行：返回 / 关注类型 / 搜索圆钮（点开向左长成输入框，
        // 盖住关注类型）/ 动作胶囊
        header: PagedSearchHeaderRow(
          key: const ValueKey('follows-header'),
          keyPrefix: 'follow',
          search: _activeSearch,
          input: _searchInputs[_tabController.index],
          hintText: t.common.search,
          onChanged: _updateSearch,
          labels: followSearchLabels,
          leading: GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.arrow_back),
            tooltip: t.common.back,
            onPressed: () => AppService.tryPop(),
          ),
          title: _buildTitle(context, tabItems),
          actions: _buildActionGroup(
            context,
            compact:
                MediaQuery.sizeOf(context).width <
                PagedSearchHeaderRow.wideRowWidth,
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }
}
