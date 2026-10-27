import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/favorites/controllers/favorites_controller.dart';
import 'package:i_iwara/app/ui/pages/favorites/widgets/favorite_video_list.dart';
import 'package:i_iwara/app/ui/pages/favorites/widgets/favorite_image_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_row.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import 'package:i_iwara/app/ui/widgets/iwara_site_badge.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';

class MyFavorites extends StatefulWidget {
  const MyFavorites({super.key});

  @override
  State<MyFavorites> createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites>
    with SingleTickerProviderStateMixin {
  /// header 与列表首屏之间的呼吸。
  static const double _headerBottomGap = 8;

  late TabController _tabController;
  late FavoritesController controller;
  final ScrollController _videoScrollController = ScrollController();
  final ScrollController _imageScrollController = ScrollController();

  /// 带回执的刷新信号：header 的刷新钮据此在刷完前显示沙漏；分页模式也只能
  /// 靠它刷新（直接刷数据源不会换掉当前显示的那一页）。
  final ListRefreshSignal _videoRefreshSignal = ListRefreshSignal();
  final ListRefreshSignal _imageRefreshSignal = ListRefreshSignal();

  /// 两个 tab 各自的多选状态：视频与图库的批量操作互不牵连。
  late final BatchSelectController<Video> _videoBatchController;
  late final BatchSelectController<ImageModel> _imageBatchController;

  /// 批量取消进行中：期间禁掉 FAB，免得重复发一整批请求。
  final RxBool _isBatchProcessing = false.obs;

  late bool _isPaginated = CommonConstants.isPaginated;

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  /// 两个 tab 各自的搜索词；切 tab 时输入框跟着换成该 tab 的那份。
  final List<TextEditingController> _searchInputs = List.generate(
    2,
    (_) => TextEditingController(),
  );
  bool _scrollSyncPending = false;

  /// 当前 tab 是否正显示搜索结果。结果网格没有分页栏，回顶浮钮的高度跟着变。
  bool _showingResults = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FavoritesController());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    _videoBatchController = Get.put(
      BatchSelectController<Video>(),
      tag: 'my_favorites_video_batch',
    );
    _imageBatchController = Get.put(
      BatchSelectController<ImageModel>(),
      tag: 'my_favorites_image_batch',
    );
    _videoBatchController.isPaginatedMode.value = _isPaginated;
    _imageBatchController.isPaginatedMode.value = _isPaginated;

    // 两个 tab 各持一个滚动控制器，共用同一个监听驱动回顶浮钮
    _videoScrollController.addListener(_onScroll);
    _imageScrollController.addListener(_onScroll);
    controller.videoSearch.addListener(_queueBackToTopSync);
    controller.imageSearch.addListener(_queueBackToTopSync);
  }

  @override
  void dispose() {
    _videoScrollController.removeListener(_onScroll);
    _imageScrollController.removeListener(_onScroll);
    _tabController.removeListener(_handleTabChange);
    controller.videoSearch.removeListener(_queueBackToTopSync);
    controller.imageSearch.removeListener(_queueBackToTopSync);
    for (final input in _searchInputs) {
      input.dispose();
    }
    _tabController.dispose();
    _showBackToTop.dispose();
    _videoRefreshSignal.dispose();
    _imageRefreshSignal.dispose();
    _videoScrollController.dispose();
    _imageScrollController.dispose();
    Get.delete<BatchSelectController<Video>>(tag: 'my_favorites_video_batch');
    Get.delete<BatchSelectController<ImageModel>>(
      tag: 'my_favorites_image_batch',
    );
    Get.delete<FavoritesController>();
    super.dispose();
  }

  bool get _isVideoTab => _tabController.index == 0;

  void _handleTabChange() {
    // 动画途中 indexIsChanging 为 true，只关心落定后的那次
    if (_tabController.indexIsChanging) return;
    if (mounted) setState(() {});
    _syncBackToTop();
    _queueBackToTopSync();
  }

  PagedSearchController<dynamic> get _activeSearch =>
      _isVideoTab ? controller.videoSearch : controller.imageSearch;

  /// 结果网格与浏览列表互换时滚动位置会跳，回顶浮钮要在下一帧重新对一次
  /// （顺带对齐浮钮高度）。搜索通知可能来自刷新途中，挪到帧后再 setState。
  void _queueBackToTopSync() {
    if (_scrollSyncPending) return;
    _scrollSyncPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollSyncPending = false;
      if (!mounted) return;
      final showing = _activeSearch.showingResults;
      if (showing != _showingResults) {
        setState(() => _showingResults = showing);
      }
      _syncBackToTop();
    });
  }

  void _updateSearch(String query) => _activeSearch.setQuery(query);

  ScrollController get _activeScrollController =>
      _isVideoTab ? _videoScrollController : _imageScrollController;

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

  /// 刷新当前 tab：先滚回顶部，再等列表真正刷完（刷新钮据此退出沙漏态）。
  Future<void> _refreshCurrentTab() async {
    _scrollToTop();
    await (_isVideoTab ? _videoRefreshSignal : _imageRefreshSignal).request();
  }

  void _togglePaginationMode() {
    setState(() => _isPaginated = !_isPaginated);
    persistPaginationMode(_isPaginated);
    // 分页模式下的选择只对「当前这一页」有意义，切换模式一律清空。
    _videoBatchController.setPaginatedMode(_isPaginated);
    _imageBatchController.setPaginatedMode(_isPaginated);
  }

  void _toggleMultiSelect() {
    if (_isVideoTab) {
      _videoBatchController.toggleMultiSelect();
    } else {
      _imageBatchController.toggleMultiSelect();
    }
  }

  /// 从「最爱」进视频详情。
  ///
  /// ⛔ 这里交出去的是**最爱池本身**，不是一份来源快照（原来那样）。理由和
  /// 播放列表那条一模一样（见 `play_list_detail.dart`）：快照会被
  /// `_limitItems` 打乱并截到 100 条，而最爱池能接着翻页、游标活在
  /// `PlaybackQueueService` 里不随页面生灭。顺带满足用户要的那条——从「最爱」
  /// 进来，「接着看」一开就落在「最爱」上，而不是一个笼统的「来源」。
  Future<void> _openFavoriteVideo({
    required String videoId,
    required List<Video> loadedVideos,
    required Video initialVideo,
    Map<String, dynamic>? extData,
  }) async {
    final queue = PlaybackQueueService.to.openFavorites();
    if (queue.loaded.isEmpty) {
      unawaited(queue.loadMore());
    }

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      initialVideoInfo: initialVideo,
      playbackQueueRef: PlaybackQueueRef(
        queueId: queue.queueId,
        currentItemId: videoId,
      ),
    );
  }

  /// 批量取消最爱：二次确认 → 分批发请求 → 汇报结果 → 退出多选。
  ///
  /// 取消后的项不会从列表里消失，而是盖上「点击恢复最爱」蒙层，跟单个取消
  /// 一致——批量操作因此是可撤销的。
  Future<void> _batchCancelFavorites({required bool isVideo}) async {
    if (_isBatchProcessing.value) return;

    final t = slang.Translations.of(context);
    final ids = isVideo
        ? _videoBatchController.selectedMediaIds.toList()
        : _imageBatchController.selectedMediaIds.toList();
    if (ids.isEmpty) return;

    final batch = isVideo ? _videoBatchController : _imageBatchController;
    final confirmed = await showBatchConfirmDialog(
      title: t.favorites.batchCancelFavorite,
      message: t.favorites.batchCancelFavoriteConfirm(count: ids.length),
      confirmLabel: t.favorites.batchCancelFavorite,
      previewTitles: _selectedTitles(batch),
      totalCount: ids.length,
    );
    if (!confirmed || !mounted) return;

    _isBatchProcessing.value = true;
    try {
      final result = isVideo
          ? await controller.batchCancelVideoFavorites(ids)
          : await controller.batchCancelImageFavorites(ids);

      showAppToast(
        result.failed == 0
            ? t.favorites.batchCancelFavoriteSuccess(count: result.success)
            : t.favorites.batchCancelFavoriteResult(
                success: result.success,
                failed: result.failed,
              ),
        type: result.failed == 0 ? AppToastType.success : AppToastType.warning,
        position: AppToastPosition.bottom,
      );

      if (isVideo) {
        _videoBatchController.exitMultiSelect();
      } else {
        _imageBatchController.exitMultiSelect();
      }
    } finally {
      _isBatchProcessing.value = false;
    }
  }

  /// 右侧动作胶囊：多选 · 瀑布/分页 · 刷新（刷新中原位换沙漏并置灰）。
  ///
  /// [compact]（窄屏）只留多选键，瀑布/分页与刷新收进「更多」菜单——header
  /// 这一行还要放搜索圆钮，三枚键平铺会把分段胶囊挤成下拉钮。
  Widget _buildActionGroup(BuildContext context, {bool compact = false}) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final bool isMultiSelect = _isVideoTab
          ? _videoBatchController.isMultiSelect.value
          : _imageBatchController.isMultiSelect.value;
      final multiSelectButton = GlassIconButton(
        icon: Icon(isMultiSelect ? Icons.close : Icons.checklist),
        tooltip: isMultiSelect ? t.common.exitEditMode : t.common.editMode,
        onPressed: _toggleMultiSelect,
      );
      if (compact) {
        return GlassButtonGroup(
          children: [
            multiSelectButton,
            Builder(
              builder: (anchorContext) => GlassAsyncIconButton(
                icon: const Icon(Icons.more_horiz),
                tooltip: t.common.more,
                onPressed: () => _showMoreMenu(anchorContext),
              ),
            ),
          ],
        );
      }
      return GlassButtonGroup(
        children: [
          multiSelectButton,
          GlassIconButton(
            icon: Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
            tooltip: _isPaginated
                ? t.common.pagination.waterfall
                : t.common.pagination.pagination,
            onPressed: _togglePaginationMode,
          ),
          GlassAsyncIconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t.common.refresh,
            onPressed: _refreshCurrentTab,
          ),
        ],
      );
    });
  }

  /// 窄屏「更多」菜单：瀑布/分页 · 刷新。刷新时按钮跟着这个 future 转沙漏。
  Future<void> _showMoreMenu(BuildContext anchorContext) async {
    final t = slang.Translations.of(context);
    final action = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuOption(
          value: 0,
          label: _isPaginated
              ? t.common.pagination.waterfall
              : t.common.pagination.pagination,
          leading: Icon(_isPaginated ? Icons.view_stream : Icons.grid_view),
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
  }

  /// 当前 tab 对应的批量选择控制器。
  BatchSelectController<dynamic> get _activeBatch =>
      _isVideoTab ? _videoBatchController : _imageBatchController;

  /// 取所选项的标题，供统一确认弹窗列出「到底要取消哪几个」。
  List<String> _selectedTitles(BatchSelectController<dynamic> batch) {
    return [
      for (final item in batch.selectedMediaList)
        if (item is Video)
          (item.title?.trim().isNotEmpty ?? false)
              ? item.title!
              : slang.t.common.noTitle
        else if (item is ImageModel)
          item.title.trim().isNotEmpty ? item.title : slang.t.common.noTitle,
    ];
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上
  /// （搜索结果网格没有分页栏，不用抬）。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Positioned(
      right: 16,
      bottom:
          computeBottomSafeInset(MediaQuery.of(context)) +
          16 +
          (_isPaginated && !_showingResults ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) =>
            ScrollToTopFab(visible: visible, onPressed: _scrollToTop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final currentSite = Get.find<AppService>().currentSiteMode;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerHeight;

    final tabItems = [
      GlassSegmentItem(
        label: t.common.video,
        icon: const Icon(Icons.video_library),
      ),
      GlassSegmentItem(
        label: t.common.gallery,
        icon: const Icon(Icons.photo_library),
      ),
    ];

    return Scaffold(
      body: Obx(() {
        final batch = _activeBatch;
        final bool active = batch.isMultiSelect.value;
        final int count = batch.selectedCount;
        return BatchSelectionScope(
          active: active,
          selectedCount: count,
          actions: [
            GlassSelectionAction(
              icon: Icons.heart_broken,
              label: t.favorites.batchCancelFavorite,
              destructive: true,
              loading: _isBatchProcessing.value,
              onPressed: count == 0
                  ? null
                  : () => _batchCancelFavorites(isVideo: _isVideoTab),
            ),
          ],
          onClear: batch.clearSelection,
          // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整页弹掉
          child: SelectionPopScope(
            active: active,
            // 交给通用键鼠多选
            model: _isVideoTab
                // 显示搜索结果时，「已加载的项」就是结果网格里那些
                ? _videoBatchController.selectionModel(
                    loadedItems: () => controller.videoSearch.showingResults
                        ? controller.videoSearch.results
                        : controller.videoRepository,
                  )
                : _imageBatchController.selectionModel(
                    loadedItems: () => controller.imageSearch.showingResults
                        ? controller.imageSearch.results
                        : controller.imageRepository,
                  ),
            onExit: batch.exitMultiSelect,
            child: _buildBody(
              context,
              headerExtent,
              headerHeight,
              statusBarHeight,
              tabItems,
              currentSite,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double headerExtent,
    double headerHeight,
    double statusBarHeight,
    List<GlassSegmentItem> tabItems,
    IwaraSite currentSite,
  ) {
    final t = slang.Translations.of(context);
    return GlassHeaderOverlay(
      headerExtent: headerExtent,
      headerTop: statusBarHeight,
      headerHeight: headerHeight,
      solidExtent: statusBarHeight,
      liquid: true,
      body: TabBarView(
        controller: _tabController,
        physics: const ClampingScrollPhysics(),
        children: [
          Obx(
            () => FavoriteVideoList(
              scrollController: _videoScrollController,
              paddingTop: headerExtent + _headerBottomGap,
              isPaginated: _isPaginated,
              refreshSignal: _videoRefreshSignal,
              isMultiSelectMode: _videoBatchController.isMultiSelect.value,
              selectedItemIds: _videoBatchController.selectedMediaIds,
              selectionSource: _videoBatchController.selectedMediaIds,
              onItemSelect: _videoBatchController.toggleSelection,
              onPageChanged: () {
                _videoBatchController.onPageChanged();
                _scrollToTop();
              },
              onOpenVideo: _openFavoriteVideo,
            ),
          ),
          Obx(
            () => FavoriteImageList(
              scrollController: _imageScrollController,
              paddingTop: headerExtent + _headerBottomGap,
              isPaginated: _isPaginated,
              refreshSignal: _imageRefreshSignal,
              isMultiSelectMode: _imageBatchController.isMultiSelect.value,
              selectedItemIds: _imageBatchController.selectedMediaIds,
              selectionSource: _imageBatchController.selectedMediaIds,
              onItemSelect: _imageBatchController.toggleSelection,
              onPageChanged: () {
                _imageBatchController.onPageChanged();
                _scrollToTop();
              },
            ),
          ),
        ],
      ),
      // header 一行：左 返回圆钮 / 中 分段胶囊（视频/图库 + AI 站点徽标）/
      // 搜索圆钮（点开向左长成输入框，盖住分段胶囊）/ 右 动作胶囊
      header: PagedSearchHeaderRow(
        keyPrefix: 'favorite',
        search: _activeSearch,
        input: _searchInputs[_tabController.index],
        hintText: t.pagedSearch.mediaHint,
        onChanged: _updateSearch,
        // 多选态展开搜索也留着动作胶囊：退出多选的键在里面
        keepActions: _activeBatch.isMultiSelect.value,
        leading: GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.arrow_back),
          tooltip: t.common.back,
          onPressed: () => AppService.tryPop(),
        ),
        title: Row(
          children: [
            // 空间够就平铺分段胶囊，露不出 2.5 个完整段就退化成下拉钮
            // （全站同一条约定，见 GlassAdaptiveSegmentedControl）。
            // Flexible：站点徽标先量，胶囊拿剩下的那点宽度去判定。
            Flexible(
              // 选择态下这只胶囊改报「已选 N 项」：进选择态是一次页面级
              // 的模式切换，header 不该毫无反应
              child: Obx(
                () => GlassAdaptiveSegmentedControl(
                  selectedIndex: _tabController.index,
                  progress: _tabController.animation,
                  onChanged: _tabController.animateTo,
                  items: tabItems,
                  replacement: _activeBatch.isMultiSelect.value
                      ? SizedBox(
                          key: const ValueKey('selection'),
                          width: 168,
                          child: GlassSelectionSummary(
                            selectedCount: _activeBatch.selectedCount,
                            allSelected: false,
                            // 懒加载列表够不到未加载的部分，不给全选
                            onToggleAll: null,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            // AI 站点模式下标明当前看的是哪个站的最爱
            if (currentSite.isAi) ...[
              const SizedBox(width: 8),
              IwaraSiteBadge(site: currentSite),
            ],
          ],
        ),
        actions: _buildActionGroup(
          context,
          compact:
              MediaQuery.sizeOf(context).width <
              PagedSearchHeaderRow.wideRowWidth,
        ),
      ),
      extra: [
        _buildScrollToTopFab(context),
        // 批量动作：瀑布流模式下的底部玻璃坞；分页模式下动作行由分页栏
        // 自己承载（见 BatchSelectionScope），底部不会出现第二条玻璃。
        GlassSelectionDock(paginated: _isPaginated),
      ],
    );
  }
}
