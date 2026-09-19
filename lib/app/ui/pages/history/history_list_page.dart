import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/routes/app_router.dart' show routeObserver;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/timeline_group.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

import 'controllers/history_feed.dart';
import 'controllers/history_list_controller.dart';
import 'widgets/history_tile.dart';

/// 浏览历史页。
///
/// header 两行：「返回 / 搜索框 / [筛选 · 多选]」，第二行五段类型胶囊。
/// 列表按**最后浏览时间**分组（今天 / 昨天 / 本周 / 本月 / 按月），窄屏长条、
/// 宽屏网格——与下载列表 R3 同一套版式。
///
/// # 与旧版相比删了什么
///
/// - 瀑布 ↔ 分页切换：历史按时间分组，分页会把一组切成两半；要找某天的记录用
///   时间区间筛选比翻页快。
/// - 「更多」菜单与 header 上的清空钮：清空挪进筛选抽屉底部（低频 + 破坏性，
///   不该和多选钮并排）。header 右侧于是在所有宽度下都只有两枚钮，窄屏不用再
///   往菜单里藏东西。
/// - 排序开关：「首次浏览」排序没有人要——重看一条老视频，它就该回到最上面。
class HistoryListPage extends StatefulWidget {
  const HistoryListPage({super.key});

  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage>
    with SingleTickerProviderStateMixin, RouteAware {
  /// 标题行与分段行之间的间距。
  static const double _headerRowGap = 6;

  /// 分段行与列表首屏之间的呼吸（两行 header 的第二行没有余量）。
  static const double _headerBottomGap = 8;

  /// 宽屏网格的断点，与全站 `kCornerDockBreakpoint` / 下载列表一致。
  static const double _wideBreakpoint = 600;

  final HistoryListController _controller = HistoryListController();
  late final TabController _tabController;
  final List<ScrollController> _scrollControllers = List.generate(
    HistoryListController.tags.length,
    (_) => ScrollController(),
  );
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  int get _index => _tabController.index;
  HistoryFeed get _feed => _controller.feeds[_index];
  String get _itemType => HistoryListController.tags[_index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: HistoryListController.tags.length,
      vsync: this,
    )..addListener(_handleTabChange);
    _ensureAround(0);
  }

  void _ensureAround(int index) {
    for (var i = index - 1; i <= index + 1; i++) {
      if (i >= 0 && i < HistoryListController.tags.length) {
        _controller.ensureLoaded(i);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  /// 从详情页回来：刚看的那条「最后浏览」变了，浮到最上面；进度也可能变了。
  ///
  /// 只认「从这页点出去的详情页」回来：预览弹窗、筛选抽屉、日期选择器关掉也会
  /// 触发 didPopNext，那些不改历史，不必重查。
  @override
  void didPopNext() {
    if (!_openedDetail) return;
    _openedDetail = false;
    _controller.refreshAfterReturn(_index);
  }

  bool _openedDetail = false;

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    for (final c in _scrollControllers) {
      c.dispose();
    }
    _searchController.dispose();
    _searchFocus.dispose();
    _showBackToTop.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // 点 tab 时 index 在滑动动画**开始**就已是目标页：这时就查库，别等动画
    // 播完——否则目标页整段滑入都是转圈。相邻页顺手预取，手指横拖切 tab
    // （只在拖完才改 index）也不会先看到转圈。本地库一页亚毫秒级，代价可忽略。
    _ensureAround(_index);
    if (_tabController.indexIsChanging) return;
    // 全选 = 本 tab 已加载的；换了 tab，原来勾的已经不在眼前了，留着只会误删。
    _controller.clearSelection();
    final active = _scrollControllers[_index];
    _showBackToTop.value = active.hasClients && active.position.pixels >= 300;
    if (mounted) setState(() {});
  }

  void _scrollToTop() {
    final active = _scrollControllers[_index];
    if (active.hasClients) {
      active.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ------------------------------------------------------------------ 打开

  /// 视频 / 图库带上「历史」这一池进详情页：播完接着放历史里的下一条，Quest
  /// 沉浸面板的「接着看」里也能顺着历史往下翻。池用眼前这份顺序当种子。
  Future<void> _open(HistoryRecord record) async {
    final data = record.originalData;
    _openedDetail = data != null;
    switch (data) {
      case final Video video:
        final queue = PlaybackQueueService.to.openHistory(
          fresh: true,
          seed: _seedFor<Video>(InnerPlaylistItemSnapshot.fromVideo),
        );
        if (queue.loaded.isEmpty) unawaited(queue.loadMore());
        final user = video.user;
        await NaviService.navigateToVideoDetailPage(
          video.id,
          extData: {
            'thumbnailUrl': video.thumbnailUrl,
            'title': video.title,
            'authorId': user?.id,
            'authorName': user?.name,
            'authorUsername': user?.username,
            'authorAvatarUrl': user?.avatar?.avatarUrl,
            'authorRole': user?.role,
            'authorPremium': user?.premium,
          },
          playbackQueueRef: PlaybackQueueRef(
            queueId: queue.queueId,
            currentItemId: video.id,
          ),
        );
      case final ImageModel gallery:
        final queue = PlaybackQueueService.to.openHistory(
          mediaType: PlaybackMediaType.gallery,
          fresh: true,
          seed: _seedFor<ImageModel>(InnerPlaylistItemSnapshot.fromGallery),
        );
        if (queue.loaded.isEmpty) unawaited(queue.loadMore());
        final user = gallery.user;
        await NaviService.navigateToGalleryDetailPage(
          gallery.id,
          coverUrl: gallery.thumbnailUrl,
          title: gallery.title,
          imageCount: gallery.numImages,
          authorId: user?.id,
          authorName: user?.name,
          authorUsername: user?.username,
          authorAvatarUrl: user?.avatar?.avatarUrl,
          authorRole: user?.role,
          authorPremium: user?.premium,
          playbackQueueRef: PlaybackQueueRef(
            queueId: queue.queueId,
            currentItemId: gallery.id,
          ),
        );
      case final PostModel post:
        NaviService.navigateToPostDetailPage(post.id, post);
      case final ForumThreadModel thread:
        NaviService.navigateToForumThreadDetailPage(
          thread.section,
          thread.id,
          initialThread: thread,
        );
      default:
        showAppToast(slang.t.common.noData, type: AppToastType.error);
    }
  }

  /// 当前 tab 已加载的同类条目，按列表顺序——池的种子必须是自然顺序。
  ///
  /// 有搜索 / 时间区间时不种：池翻的是不带筛选的整份历史，拿筛过的当种子，
  /// 游标就和池自己的顺序对不上了。
  List<InnerPlaylistItemSnapshot> _seedFor<T>(
    InnerPlaylistItemSnapshot Function(T) toSnapshot,
  ) {
    final feed = _feed;
    if (feed.keyword.isNotEmpty || feed.dateRange != null) return const [];
    return [
      for (final r in feed.items)
        if (r.originalData case final T data) toSnapshot(data),
    ];
  }

  // ------------------------------------------------------------------ 删除

  /// 单条删除不再弹确认：删掉、toast 里给「撤销」，原样放回（含观看进度）。
  Future<void> _removeOne(HistoryRecord record) async {
    final t = slang.t;
    try {
      await _controller.deleteRecords([record.id], animate: true);
    } catch (_) {
      showAppToast(t.errors.failedToOperate, type: AppToastType.error);
      return;
    }
    if (!mounted) return;
    showAppToast(
      t.historyPage.removed,
      type: AppToastType.success,
      // 撤销要有够的时间去点；放底部，不压住 header 下的分段 tab。
      position: AppToastPosition.bottom,
      duration: const Duration(seconds: 6),
      actionLabel: t.watchLater.undo,
      actionIcon: Icons.undo,
      onAction: () async {
        try {
          await _controller.restoreRecords([record], currentIndex: _index);
        } catch (_) {
          showAppToast(t.errors.failedToOperate, type: AppToastType.error);
        }
      },
    );
  }

  /// 批量删除：走全站统一的玻璃确认弹窗（含所选预览）。
  Future<void> _confirmDeleteSelected() async {
    final ids = _controller.selected.toSet();
    if (ids.isEmpty) return;
    final t = slang.t;
    final titles = <String>[
      for (final r in _feed.items)
        if (ids.contains(r.id))
          r.title.trim().isEmpty ? t.common.noTitle : r.title.trim(),
    ].take(3).toList();
    final confirmed = await showBatchConfirmDialog(
      title: t.common.confirmDelete,
      message: t.common.areYouSureYouWantToDeleteSelectedItems(num: ids.length),
      confirmLabel: t.common.delete,
      previewTitles: titles,
      totalCount: ids.length,
    );
    if (!confirmed || !mounted) return;
    try {
      await _controller.deleteRecords(ids);
    } catch (_) {
      showAppToast(t.errors.failedToOperate, type: AppToastType.error);
      return;
    }
    _controller.exitMultiSelect();
    showAppToast(t.common.success, type: AppToastType.success);
  }

  String _tabLabel(slang.Translations t, int index) => switch (index) {
    1 => t.common.video,
    2 => t.common.gallery,
    3 => t.common.post,
    4 => t.forum.forum,
    _ => t.common.all,
  };

  /// 清空当前 tab。文案说清楚清的是哪一类（「全部」才是真的全清）。
  void _confirmClearTab() {
    final t = slang.t;
    final index = _index;
    final itemType = _itemType;
    final all = itemType == 'all';
    final label = _tabLabel(t, index);
    showAppDialog(
      GlassAlertDialog(
        title: all
            ? t.common.clearAllHistory
            : t.historyPage.clearTabTitle(tab: label),
        content: Text(
          all
              ? t.common.clearAllHistoryConfirm
              : t.historyPage.clearTabConfirm(tab: label),
        ),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: t.common.confirm,
            emphasized: false,
            destructive: true,
            onPressed: () async {
              AppService.tryPop(); // 确认框
              AppService.tryPop(); // 筛选抽屉
              try {
                await _controller.clearTab(itemType, currentIndex: index);
              } catch (_) {
                showAppToast(t.errors.failedToOperate, type: AppToastType.error);
                return;
              }
              showAppToast(t.common.success, type: AppToastType.success);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRange() async {
    final t = slang.t;
    final index = _index;
    final itemType = _itemType;
    final count = await _controller.countInRange(itemType);
    if (!mounted) return;
    if (count == 0) {
      showAppToast(t.common.noHistoryRecordsInRange, type: AppToastType.info);
      return;
    }
    showAppDialog(
      GlassAlertDialog(
        title: t.common.confirmDelete,
        content: Text(t.common.deleteRecordsInDateRangeConfirm(num: count)),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: t.common.delete,
            emphasized: false,
            destructive: true,
            onPressed: () async {
              AppService.tryPop(); // 确认框
              AppService.tryPop(); // 筛选抽屉
              try {
                await _controller.deleteInRange(itemType, currentIndex: index);
              } catch (_) {
                showAppToast(t.errors.failedToOperate, type: AppToastType.error);
                return;
              }
              showAppToast(t.common.success, type: AppToastType.success);
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ 筛选

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _controller.dateRange.value,
    );
    if (picked != null && picked != _controller.dateRange.value) {
      _controller.setDateRange(picked, currentIndex: _index);
    }
  }

  void _openFilterDrawer() {
    showGlassSideDrawer<void>(
      context: context,
      builder: (_) => _HistoryFilterDrawer(
        controller: _controller,
        tabLabel: _tabLabel(slang.t, _index),
        onPickDateRange: _pickDateRange,
        onClearDateRange: () =>
            _controller.setDateRange(null, currentIndex: _index),
        onDeleteRange: _confirmDeleteRange,
        onClearTab: _confirmClearTab,
      ),
    );
  }

  // ------------------------------------------------------------------ 构建

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerHeight =
        GlassTokens.headerRowHeight + _headerRowGap + GlassTokens.pillHeight;
    final double headerExtent = statusBarHeight + headerHeight;

    final tabItems = [
      for (var i = 0; i < HistoryListController.tags.length; i++)
        GlassSegmentItem(label: _tabLabel(t, i)),
    ];

    return Scaffold(
      body: _ObxSelection(
        controller: _controller,
        builder: (active, count) => BatchSelectionScope(
          active: active,
          selectedCount: count,
          actions: [
            GlassSelectionAction(
              icon: Icons.delete,
              label: t.common.delete,
              destructive: true,
              onPressed: count == 0 ? null : _confirmDeleteSelected,
            ),
          ],
          onClear: _controller.clearSelection,
          // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整页弹掉
          child: SelectionPopScope(
            active: active,
            // 通用键鼠多选：Shift 区间选、Ctrl/Cmd 点选、Ctrl/Cmd+A、Delete
            model: SelectionModel(
              enter: _controller.enterMultiSelect,
              isSelected: (k) => _controller.selected.contains(k),
              toggle: (k) => _controller.toggleSelection(k as int),
              loadedKeys: () => [for (final r in _feed.items) r.id],
              replaceSelection: (keys) =>
                  _controller.selected.assignAll(keys.cast<int>()),
            ),
            onExit: _controller.exitMultiSelect,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                    _searchFocus.requestFocus,
                const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
                    _searchFocus.requestFocus,
              },
              child: GlassHeaderOverlay(
                headerExtent: headerExtent,
                headerTop: statusBarHeight,
                headerHeight: headerHeight,
                solidExtent: statusBarHeight,
                liquid: true,
                body: TabBarView(
                  controller: _tabController,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    for (var i = 0; i < _controller.feeds.length; i++)
                      _HistoryTabView(
                        feed: _controller.feeds[i],
                        controller: _controller,
                        scrollController: _scrollControllers[i],
                        topPadding: headerExtent + _headerBottomGap,
                        wideBreakpoint: _wideBreakpoint,
                        onOpen: _open,
                        onRemove: _removeOne,
                        // 只有前台 tab 的滚动决定回顶钮（后台 tab 不会发滚动）。
                        onScrolled: (px) {
                          if (i == _index) _showBackToTop.value = px >= 300;
                        },
                      ),
                  ],
                ),
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
                            // 选择态下搜索框换成「已选 N 项 + 全选」：单壳常驻、只换内容
                            Expanded(
                              child: GlassCapsuleMorph(
                                child: active
                                    ? KeyedSubtree(
                                        key: const ValueKey('selection'),
                                        // 全选键由 SelectionModel 自动接上（本 tab 已加载的）
                                        child: GlassSelectionSummary(
                                          selectedCount: count,
                                          allSelected: false,
                                          onToggleAll: null,
                                        ),
                                      )
                                    : KeyedSubtree(
                                        key: const ValueKey('search'),
                                        child: _buildSearchField(context),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildActionGroup(context, active: active),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: _headerRowGap),
                    SizedBox(
                      height: GlassTokens.pillHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // 空间够就平铺分段胶囊，露不出 2.5 段就退化成下拉钮
                        child: GlassAdaptiveSegmentedControl(
                          selectedIndex: _index,
                          progress: _tabController.animation,
                          onChanged: _tabController.animateTo,
                          items: tabItems,
                        ),
                      ),
                    ),
                  ],
                ),
                extra: [
                  Positioned(
                    right: 16,
                    bottom:
                        computeBottomSafeInset(MediaQuery.of(context)) +
                        16 +
                        (active ? _dockReserve : 0),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showBackToTop,
                      builder: (context, visible, _) => ScrollToTopFab(
                        visible: visible && !active,
                        onPressed: _scrollToTop,
                      ),
                    ),
                  ),
                  const GlassSelectionDock(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 选择态下底部玻璃坞（[GlassSelectionDock]）的占位：列表末尾让出这么多，
  /// 最后一排才不会被坞盖住（动作钮 48 + 上下留白）。
  static const double _dockReserve = 72;

  /// 玻璃搜索框（壳由外层 [GlassCapsuleMorph] 常驻提供）。
  /// 桌面 Ctrl/Cmd+F 聚焦；300ms 防抖后才查库。
  Widget _buildSearchField(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: GlassTokens.pillHeight,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (v) => _controller.search(v, currentIndex: _index),
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: t.common.searchHistoryRecords,
          hintStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) => GlassGroupSlot(
              visible: value.text.isNotEmpty,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: t.common.clear,
                onPressed: () {
                  _searchController.clear();
                  _controller.search('', currentIndex: _index);
                },
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// 右侧动作胶囊：筛选（生效时挂红点）· 多选↔退出。所有宽度都只有这两枚。
  Widget _buildActionGroup(BuildContext context, {required bool active}) {
    final t = slang.Translations.of(context);
    return Obx(
      () => GlassButtonGroup(
        children: [
          GlassIconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: t.searchFilter.filterSettings,
            showBadge: _controller.dateRange.value != null,
            onPressed: _openFilterDrawer,
          ),
          GlassIconButton(
            icon: Icon(active ? Icons.close : Icons.checklist),
            tooltip: active ? t.common.exitEditMode : t.common.editMode,
            onPressed: _controller.toggleMultiSelect,
          ),
        ],
      ),
    );
  }
}

/// 选择态（开没开 + 选了几条）的订阅点。只有它依赖选中集合。
class _ObxSelection extends StatelessWidget {
  const _ObxSelection({required this.controller, required this.builder});

  final HistoryListController controller;
  final Widget Function(bool active, int count) builder;

  @override
  Widget build(BuildContext context) => Obx(
    () => builder(controller.isMultiSelect.value, controller.selected.length),
  );
}

// ============================================================================
// 一个 tab
// ============================================================================

class _HistoryTabView extends StatefulWidget {
  const _HistoryTabView({
    required this.feed,
    required this.controller,
    required this.scrollController,
    required this.topPadding,
    required this.wideBreakpoint,
    required this.onOpen,
    required this.onRemove,
    required this.onScrolled,
  });

  final HistoryFeed feed;
  final HistoryListController controller;
  final ScrollController scrollController;
  final double topPadding;
  final double wideBreakpoint;
  final Future<void> Function(HistoryRecord record) onOpen;
  final void Function(HistoryRecord record) onRemove;
  final ValueChanged<double> onScrolled;

  @override
  State<_HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<_HistoryTabView>
    with AutomaticKeepAliveClientMixin {
  static const double _gutter = 12;
  static const double _itemGap = 10;

  // 切 tab 回来滚动位置还在（五个 tab 的数据本来就常驻在 feed 里）。
  @override
  bool get wantKeepAlive => true;

  bool _loadMoreScheduled = false;

  HistoryFeed get feed => widget.feed;

  /// 画到离末尾不到几条时翻下一页（一帧只约一次）。
  void _maybeLoadMore(int index) {
    if (_loadMoreScheduled || index < feed.items.length - 8) return;
    if (!feed.hasMore || feed.isLoading || feed.error != null) return;
    _loadMoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreScheduled = false;
      if (mounted) feed.loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 选中集合的订阅落在这一层（Obx），feed 的变动走 ListenableBuilder。
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) => Obx(() => _build(context)),
    );
  }

  Widget _build(BuildContext context) {
    final t = slang.Translations.of(context);
    final mq = MediaQuery.of(context);
    final selectionMode = widget.controller.isMultiSelect.value;
    // 整份读一遍：只读 length 的话，「换成另一批同样多条」的替换不会触发重建。
    final selected = widget.controller.selected.toSet();
    final bottom =
        computeBottomSafeInset(mq) +
        16 +
        (selectionMode ? _HistoryListPageState._dockReserve : 0);

    // 首屏：还没加载过就只留个转圈，出错给重试，空了给空态。
    if (!feed.loadedOnce || (feed.items.isEmpty && feed.error != null)) {
      return _CenteredState(
        top: widget.topPadding,
        child: feed.error != null
            ? _ErrorState(onRetry: feed.retry)
            : const CircularProgressIndicator(),
      );
    }
    if (feed.items.isEmpty) {
      final filtered = feed.keyword.isNotEmpty || feed.dateRange != null;
      return _CenteredState(
        top: widget.topPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.search_off : Icons.history,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              t.common.noData,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final wide = mq.size.width > widget.wideBreakpoint;
    final grid = wide
        ? LocalGridMetrics.media(mq.size.width - _gutter * 2)
        : null;

    // 监听放在 tab 里面：放到 TabBarView 外面时，竖向滚动要穿过 PageView 的
    // viewport，depth 已经是 1，按 depth == 0 过滤就永远收不到（回顶钮从不出现）。
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
          widget.onScrolled(n.metrics.pixels);
        }
        return false;
      },
      child: Scrollbar(
        controller: widget.scrollController,
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: widget.topPadding)),
            _buildGroups(
              context,
              grid: grid,
              selectionMode: selectionMode,
              selected: selected,
            ),
            SliverToBoxAdapter(child: _buildFooter(context)),
            SliverToBoxAdapter(child: SizedBox(height: bottom)),
          ],
        ),
      ),
    );
  }

  /// 按最后浏览时间切成若干组，每组一行小标题 + 一段行 / 格。
  ///
  /// 自己按数据画而不是交给通用列表组件：网格中间要插通栏标题（与下载列表
  /// 历史区同一个做法）。
  Widget _buildGroups(
    BuildContext context, {
    required LocalGridMetrics? grid,
    required bool selectionMode,
    required Set<int> selected,
  }) {
    final items = feed.items;
    final now = DateTime.now();
    final groups = <({String? label, int start, int end})>[];
    String? current;
    var start = 0;
    for (var i = 0; i < items.length; i++) {
      final label = timelineGroupLabel(context, items[i].updatedAt, now);
      if (i > 0 && label != current) {
        groups.add((label: current, start: start, end: i));
        start = i;
      }
      current = label;
    }
    groups.add((label: current, start: start, end: items.length));

    final extent = grid == null
        ? 0.0
        : HistoryTile.gridExtentFor(context, grid.cellWidth);
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget tile(int index, HistoryTileLayout layout) {
      _maybeLoadMore(index);
      final record = items[index];
      return SelectableItem(
        itemKey: record.id,
        onToggle: () => widget.controller.toggleSelection(record.id),
        child: HistoryTile(
          key: ValueKey(record.id),
          record: record,
          layout: layout,
          selectionMode: selectionMode,
          selected: selected.contains(record.id),
          onOpen: widget.onOpen,
          onRemove: widget.onRemove,
          onToggleSelect: () => widget.controller.toggleSelection(record.id),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        for (final group in groups) ...[
          if (group.label != null)
            SliverToBoxAdapter(
              // 组里最后一条被删时组头一起收起，而不是等卡片收完再硬切掉。
              child: _RemovalTransition(
                removing: [
                  for (var i = group.start; i < group.end; i++) items[i].id,
                ].every(feed.removing.contains),
                collapse: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(group.label!, style: labelStyle),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 6),
            sliver: grid == null
                ? SliverList.builder(
                    itemCount: group.end - group.start,
                    itemBuilder: (context, i) => _RemovalTransition(
                      removing: feed.removing.contains(
                        items[group.start + i].id,
                      ),
                      collapse: true,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: _itemGap),
                        child: tile(group.start + i, HistoryTileLayout.row),
                      ),
                    ),
                  )
                : SliverGrid.builder(
                    gridDelegate: grid.delegate(extent),
                    itemCount: group.end - group.start,
                    itemBuilder: (context, i) => _RemovalTransition(
                      removing: feed.removing.contains(
                        items[group.start + i].id,
                      ),
                      collapse: false,
                      child: tile(group.start + i, HistoryTileLayout.grid),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  /// 末尾：加载中 / 出错可重试 / 到底了什么都不画。
  Widget _buildFooter(BuildContext context) {
    final Widget child;
    if (feed.isLoading && feed.items.isNotEmpty) {
      child = const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (feed.error != null) {
      child = Padding(
        key: const ValueKey('error'),
        padding: const EdgeInsets.all(8),
        child: Center(child: _ErrorState(onRetry: feed.retry, compact: true)),
      );
    } else {
      child = const SizedBox(key: ValueKey('idle'), height: 8);
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.top, required this.child});

  final double top;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top),
    child: Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, this.compact = false});

  final Future<void> Function() onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final retry = TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(t.common.retry),
    );
    if (compact) return retry;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 8),
        retry,
      ],
    );
  }
}

// ============================================================================
// 筛选抽屉
// ============================================================================

/// 筛选抽屉：时间区间（按最后浏览时间）· 按区间删除 · 清空当前分类。
///
/// 改动即时生效，没有确认钮（与全站筛选抽屉同一约定）。
class _HistoryFilterDrawer extends StatelessWidget {
  const _HistoryFilterDrawer({
    required this.controller,
    required this.tabLabel,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.onDeleteRange,
    required this.onClearTab,
  });

  final HistoryListController controller;
  final String tabLabel;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;
  final VoidCallback onDeleteRange;
  final VoidCallback onClearTab;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final dateRange = controller.dateRange.value;
      return GlassFilterDrawerShell(
        title: t.searchFilter.filterSettings,
        subtitle: t.historyPage.rangeByLastViewed,
        onReset: dateRange == null ? null : onClearDateRange,
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: OutlinedButton.icon(
            onPressed: onClearTab,
            icon: const Icon(Icons.delete_sweep),
            label: Text(
              tabLabel == t.common.all
                  ? t.common.clearAllHistory
                  : t.historyPage.clearTabTitle(tab: tabLabel),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
            ),
          ),
        ),
        children: [
          GlassFilterSection(
            title: t.common.selectDateRange,
            actions: [
              if (dateRange != null)
                IconButton(
                  tooltip: t.common.clearDateRange,
                  icon: const Icon(Icons.clear, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: onClearDateRange,
                ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassSurface(
                  height: null,
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  onTap: onPickDateRange,
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateRange == null
                              ? t.common.selectDateRange
                              : '${CommonUtils.formatDate(dateRange.start)} - '
                                    '${CommonUtils.formatDate(dateRange.end)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: dateRange == null
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 没选区间时「按区间删除」整条收起（有出有入：高度 + 透明度一起过渡）。
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: dateRange == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: OutlinedButton.icon(
                            onPressed: onDeleteRange,
                            icon: const Icon(Icons.delete_outline),
                            label: Text(t.common.deleteRecordsInDateRange),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(
                                color: colorScheme.error.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// 逐条删除时卡片的退场：长条连同下方间距一起收起高度，网格格子缩小（格子尺寸
/// 由网格定死，收不了高度）；两者都淡出。播完由控制器真正拿掉这一条。
class _RemovalTransition extends StatelessWidget {
  const _RemovalTransition({
    required this.removing,
    required this.collapse,
    required this.child,
  });

  final bool removing;
  final bool collapse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const duration = HistoryListController.removeAnimation;
    const curve = Curves.easeInCubic;
    final faded = AnimatedOpacity(
      opacity: removing ? 0 : 1,
      duration: duration,
      curve: curve,
      child: child,
    );
    if (collapse) {
      return ClipRect(
        child: AnimatedAlign(
          // 只收高度：widthFactor 留空时 Align 会撑满宽度，topStart 让组头文字
          // 仍然贴左（topCenter 会把它挤到正中）。
          alignment: AlignmentDirectional.topStart,
          heightFactor: removing ? 0 : 1,
          duration: duration,
          curve: curve,
          child: faded,
        ),
      );
    }
    return AnimatedScale(
      scale: removing ? 0.9 : 1,
      duration: duration,
      curve: curve,
      child: faded,
    );
  }
}
