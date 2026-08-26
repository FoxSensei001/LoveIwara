import 'package:flutter/material.dart';
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
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 关注 / 粉丝 / 特别关注（玻璃化，两行 header）。
///
/// 这页不只看自己——从作者页进来时是**别人**的关注列表，所以标题行必须常驻
/// 显示是谁的列表；三个 tab 的分段胶囊单开一行，窄屏也不用挤进标题行。
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
  /// 标题行与分段行之间的间距。
  static const double _headerRowGap = 6;

  /// 分段行与列表首屏之间的呼吸。
  ///
  /// 单行 header 的 56 里天然留了 6 的余量（胶囊只有 44 高），两行 header 的
  /// 第二行高度就是胶囊高度、一点余量都没有——不补这一段，第一排卡片会紧贴
  /// 分段胶囊下沿。
  static const double _headerBottomGap = 8;

  late TabController _tabController;
  late FollowsController controller;

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
  Widget _buildActionGroup(BuildContext context) {
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
          children: [
            GlassIconButton(
              icon: Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
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
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom:
          MediaQuery.paddingOf(context).bottom +
          16 +
          (_isPaginated && !_isLocalTab ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => GlassReveal(
          visible: visible,
          builder: (context, m) => GlassIconButton(
            materialize: m,
            standalone: true,
            icon: const Icon(Icons.vertical_align_top),
            tooltip: t.common.scrollToTop,
            onPressed: _scrollToTop,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight =
        GlassTokens.headerRowHeight + _headerRowGap + GlassTokens.pillHeight;
    final double headerExtent = statusBarHeight + headerHeight;

    final tabItems = [
      GlassSegmentItem(
        label: t.common.following,
        icon: const Icon(Icons.person_add_alt_1),
      ),
      GlassSegmentItem(label: t.common.fans, icon: const Icon(Icons.group)),
      GlassSegmentItem(
        label: t.common.specialFollowed,
        icon: const Icon(Icons.stars),
      ),
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
        // header：第一行「返回 / 标题胶囊 / 刷新胶囊」，第二行三段胶囊
        header: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: GlassTokens.headerRowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: t.common.back,
                      onPressed: () => AppService.tryPop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // 胶囊里就要看见是谁的列表；GlassTitlePill 的 subtitle
                      // 只出现在点开的全文弹窗里，所以名字与 @username 合并成
                      // 一行标题（截断后点胶囊仍能看全）
                      child: GlassTitlePill(
                        title: widget.name.isEmpty
                            ? '@${widget.username}'
                            : '${widget.name} @${widget.username}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionGroup(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _headerRowGap),
            SizedBox(
              height: GlassTokens.pillHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: // 空间够就平铺分段胶囊，露不出 2.5 个完整段就退化成下拉钮
                    // （全站同一条约定，见 GlassAdaptiveSegmentedControl）。
                    GlassAdaptiveSegmentedControl(
                      selectedIndex: _tabController.index,
                      progress: _tabController.animation,
                      onChanged: _tabController.animateTo,
                      items: tabItems,
                    ),
              ),
            ),
          ],
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }
}
