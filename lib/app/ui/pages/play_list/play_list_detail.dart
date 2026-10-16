import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'dart:async';

import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_row.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_view.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';

enum _PlaylistDetailMenuAction {
  togglePagination,
  refresh,
  editTitle,
  deletePlaylist,
  share,
  copyLink,
}

/// 播放列表详情（玻璃化 + 瀑布/分页双模式）。
class PlayListDetailPage extends StatefulWidget {
  final String playlistId;
  final bool isMine;

  const PlayListDetailPage({
    super.key,
    required this.playlistId,
    required this.isMine,
  });

  @override
  State<PlayListDetailPage> createState() => _PlayListDetailPageState();
}

class _PlayListDetailPageState extends State<PlayListDetailPage> {
  late PlayListDetailController controller;
  final ScrollController _scrollController = ScrollController();

  /// 外部刷新信号：分页模式必须由 MediaListView 自己刷新，
  /// 直接 `repository.refresh()` 只会动数据源、不会换掉当前显示的那一页。
  /// 带回执的刷新信号：header 上的刷新钮据此在刷完前显示沙漏。
  final ListRefreshSignal _refreshSignal = ListRefreshSignal();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  late bool _isPaginated = CommonConstants.isPaginated;

  /// header 搜索钮里的搜索词。
  final TextEditingController _searchInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      PlayListDetailController(playlistId: widget.playlistId),
    );
  }

  @override
  void dispose() {
    _searchInput.dispose();
    _scrollController.dispose();
    _refreshSignal.dispose();
    _showBackToTop.dispose();
    controller.repository.dispose();
    Get.delete<PlayListDetailController>();
    super.dispose();
  }

  Future<void> _refreshList() => _refreshSignal.request();

  void _togglePaginationMode() {
    setState(() => _isPaginated = !_isPaginated);
    persistPaginationMode(_isPaginated);
    // 分页与瀑布的下标口径不同，模式一换就把选择清掉，免得删到别的视频
    controller.selectedVideos.clear();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: Obx(() {
        final bool active = controller.isMultiSelect.value;
        final int count = controller.selectedVideos.length;
        return BatchSelectionScope(
          active: active,
          selectedCount: count,
          actions: [
            GlassSelectionAction(
              icon: Icons.delete,
              label: slang.t.common.delete,
              destructive: true,
              onPressed: count == 0 ? null : _showDeleteConfirmDialog,
            ),
          ],
          onClear: controller.selectedVideos.clear,
          // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整页弹掉
          child: SelectionPopScope(
            active: active,
            // 交给通用键鼠多选
            model: SelectionModel(
              enter: () {
                if (!controller.isMultiSelect.value) {
                  controller.toggleMultiSelect();
                }
              },
              isSelected: (k) => controller.selectedVideos.contains(k),
              toggle: (k) => controller.toggleSelection(k as String),
              // 搜索结果盖在列表上时，「已加载」指的是眼前这批结果
              loadedKeys: () => [
                for (final v
                    in controller.search.showingResults
                        ? controller.search.results
                        : controller.repository)
                  v.id,
              ],
              replaceSelection: (keys) {
                controller.selectedVideos
                  ..clear()
                  ..addAll(keys.cast<String>());
              },
            ),
            onExit: controller.toggleMultiSelect,
            child: _buildBody(context, headerExtent, statusBarHeight),
          ),
        );
      }),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double headerExtent,
    double statusBarHeight,
  ) {
    final t = slang.Translations.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    // 与 MediaListView 不传 delegate 时的默认列宽同一条公式；显式传给浏览列表
    // 和搜索结果两边，结果网格的列数才和浏览时一致。
    final gridDelegate = SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent:
          screenWidth / MediaLayoutUtils.calculateCrossAxisCount(screenWidth),
      crossAxisSpacing: MediaLayoutUtils.crossAxisSpacing,
      mainAxisSpacing: MediaLayoutUtils.mainAxisSpacing,
    );
    return GlassHeaderOverlay(
      liquid: true,
      headerExtent: headerExtent,
      headerTop: statusBarHeight,
      solidExtent: statusBarHeight,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical) {
            _showBackToTop.value = notification.metrics.pixels >= 300;
          }
          return false;
        },
        // 有搜索词时结果网格盖在浏览列表上，卡片（含多选）同一套。
        child: PagedSearchView<Video>(
          search: controller.search,
          scrollController: _scrollController,
          paddingTop: headerExtent,
          gridDelegate: gridDelegate,
          itemBuilder: _buildVideoItem,
          browseBuilder: (scrollController) => MediaListView<Video>(
            sourceList: controller.repository,
            isPaginated: _isPaginated,
            refreshSignal: _refreshSignal,
            onPaginatedRefresh: controller.repository.resetPagingState,
            scrollController: scrollController,
            paddingTop: headerExtent,
            emptyIcon: Icons.video_library_outlined,
            extendedListDelegate: gridDelegate,
            // 换页后原来的选择已经不在屏幕上了，留着只会误删
            onPageChanged: () => controller.selectedVideos.clear(),
            itemBuilderWithWidth: (context, video, index, width) =>
                _buildVideoItem(context, video, width),
            itemBuilder: (context, video, index) =>
                _buildVideoItem(context, video, 220),
          ),
        ),
      ),
      // header 行：左 返回圆钮 / 中 播放列表标题胶囊 / 搜索钮 / 右 动作胶囊
      header: Obx(
        () => PagedSearchHeaderRow(
          keyPrefix: 'playlist',
          search: controller.search,
          input: _searchInput,
          hintText: t.pagedSearch.mediaHint,
          onChanged: controller.search.setQuery,
          // 多选态展开搜索也留着动作胶囊：退出多选的键在里面
          keepActions: controller.isMultiSelect.value,
          leading: GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.arrow_back),
            tooltip: t.common.back,
            onPressed: () => AppService.tryPop(),
          ),
          // 选择态下标题胶囊改报「已选 N 项」：单壳常驻、只换内容
          title: GlassCapsuleMorph(
            child: controller.isMultiSelect.value
                ? SizedBox(
                    key: const ValueKey('selection'),
                    width: 168,
                    child: GlassSelectionSummary(
                      selectedCount: controller.selectedVideos.length,
                      allSelected: false,
                      onToggleAll: null,
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('title'),
                    child: GlassTitlePill(
                      flat: true,
                      title: controller.playlistTitle.value.isEmpty
                          ? null
                          : controller.playlistTitle.value,
                    ),
                  ),
          ),
          actions: _buildActionGroup(
            context,
            compact: screenWidth < PagedSearchHeaderRow.wideRowWidth,
          ),
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

  /// 右侧动作胶囊：[多选（仅自己的列表）] 瀑布/分页 · 刷新 · 更多。
  ///
  /// 窄屏（[compact]）只留多选与更多，瀑布/分页和刷新收进更多菜单：一行里
  /// 还要摆标题和搜索钮，四枚键会把标题挤没。
  Widget _buildActionGroup(BuildContext context, {required bool compact}) {
    final t = slang.Translations.of(context);
    return Obx(
      () => GlassButtonGroup(
        touchFlexSignature: 'playlist-detail|$compact',
        children: [
          GlassGroupSlot(
            visible: widget.isMine,
            child: GlassIconButton(
              icon: Icon(
                controller.isMultiSelect.value ? Icons.close : Icons.checklist,
              ),
              tooltip: controller.isMultiSelect.value
                  ? t.common.exitEditMode
                  : t.common.editMode,
              onPressed: () => controller.toggleMultiSelect(),
            ),
          ),
          GlassGroupSlot(
            visible: !compact,
            child: GlassIconButton(
              icon: Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
              tooltip: _isPaginated
                  ? t.common.pagination.waterfall
                  : t.common.pagination.pagination,
              onPressed: _togglePaginationMode,
            ),
          ),
          GlassGroupSlot(
            visible: !compact,
            child: GlassAsyncIconButton(
              icon: const Icon(Icons.refresh),
              tooltip: t.common.refresh,
              onPressed: _refreshList,
            ),
          ),
          Builder(
            builder: (anchorContext) => GlassIconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: t.common.more,
              // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
              // 松手选中（见 GlassTapArea.opensOverlay）。
              opensOverlay: true,
              onPressed: () => _openMoreMenu(anchorContext, compact: compact),
            ),
          ),
        ],
      ),
    );
  }

  /// 「更多」菜单：[瀑布/分页 · 刷新（仅窄屏）] 编辑标题 / 删除播放列表
  /// （均仅自己的列表）· 分享 · 复制链接。
  Future<void> _openMoreMenu(
    BuildContext anchorContext, {
    required bool compact,
  }) async {
    final t = slang.Translations.of(anchorContext);
    final action = await showGlassMenu<_PlaylistDetailMenuAction>(
      anchorContext: anchorContext,
      entries: [
        if (compact) ...[
          GlassMenuOption(
            value: _PlaylistDetailMenuAction.togglePagination,
            icon: _isPaginated ? Icons.grid_view : Icons.view_stream,
            label: _isPaginated
                ? t.common.pagination.waterfall
                : t.common.pagination.pagination,
          ),
          GlassMenuOption(
            value: _PlaylistDetailMenuAction.refresh,
            icon: Icons.refresh,
            label: t.common.refresh,
          ),
          const GlassMenuSeparator(),
        ],
        if (widget.isMine)
          GlassMenuOption(
            value: _PlaylistDetailMenuAction.editTitle,
            icon: Icons.edit,
            label: t.common.editTitle,
          ),
        if (widget.isMine)
          GlassMenuOption(
            value: _PlaylistDetailMenuAction.deletePlaylist,
            icon: Icons.delete,
            label: t.common.delete,
            destructive: true,
          ),
        GlassMenuOption(
          value: _PlaylistDetailMenuAction.share,
          icon: Icons.share,
          label: t.common.share,
        ),
        GlassMenuOption(
          value: _PlaylistDetailMenuAction.copyLink,
          icon: Icons.copy,
          label: t.galleryDetail.copyLink,
        ),
      ],
    );
    if (action == null) return;
    switch (action) {
      case _PlaylistDetailMenuAction.togglePagination:
        _togglePaginationMode();
        break;
      case _PlaylistDetailMenuAction.refresh:
        _refreshList();
        break;
      case _PlaylistDetailMenuAction.editTitle:
        _showEditTitleDialog();
        break;
      case _PlaylistDetailMenuAction.deletePlaylist:
        _showDeleteCurPlaylistConfirmDialog();
        break;
      case _PlaylistDetailMenuAction.share:
        _showShareDialog();
        break;
      case _PlaylistDetailMenuAction.copyLink:
        _copyPlaylistLink();
        break;
    }
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Positioned(
      right: 16,
      bottom:
          computeBottomSafeInset(MediaQuery.of(context)) +
          16 +
          (_isPaginated ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) =>
            ScrollToTopFab(visible: visible, onPressed: _scrollToTop),
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, Video video, double width) {
    return Obx(
      () => VideoCardListItemWidget(
        video: video,
        width: width,
        isMultiSelectMode: controller.isMultiSelect.value,
        selectionSource: controller.selectedVideos,
        onSelect: () => controller.toggleSelection(video.id),
        onOpenVideo: ({required videoId, Map<String, dynamic>? extData}) {
          return _openVideoFromPlaylist(
            videoId: videoId,
            initialVideo: video,
            extData: extData,
          );
        },
      ),
    );
  }

  Future<void> _openVideoFromPlaylist({
    required String videoId,
    Video? initialVideo,
    required Map<String, dynamic>? extData,
  }) async {
    final Video? initialVideoInfo =
        initialVideo ??
        controller.repository.cast<Video?>().firstWhere(
          (v) => v?.id == videoId,
          orElse: () => null,
        );

    // 从播放列表进来时，池就是这张播放列表本身——**不再传来源快照**。
    // 两个原因：
    // 1. 快照会被 `_limitItems` 打乱（那是给"随机推荐"用的），播放列表是作者
    //    排好的顺序，打乱就把它的意义毁了；
    // 2. 快照只有已加载的那些，而播放列表池能接着翻页（游标活在
    //    PlaybackQueueService 里，不随页面生灭）。
    //
    // 顺带满足"从播放列表进来就只有播放列表 tab、没有『来源』"这条约定：
    // 详情页组装池清单时，来源池只在真的传了 innerPlaylistContext 时才出现。
    final queue = PlaybackQueueService.to.openPlaylist(
      widget.playlistId,
      title: controller.playlistTitle.value,
      // 主人一起带上：从**他人的**播放列表进来时，抽屉靠它开出「他人的播放
      // 列表」那一条，否则那个人的其它列表在播放器里根本够不着。
      owner: controller.playlistOwner.value,
    );
    if (queue.loaded.isEmpty) {
      unawaited(queue.loadMore());
    }

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      initialVideoInfo: initialVideoInfo,
      playbackQueueRef: PlaybackQueueRef(
        queueId: queue.queueId,
        currentItemId: videoId,
      ),
    );
  }

  void _showShareDialog() {
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.common.share,
        content: Text(slang.t.common.areYouSureYouWantToShareThisPlaylist),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.share,
            emphasized: false,
            onPressed: () {
              AppService.tryPop();
              ShareService.sharePlayListDetail(
                widget.playlistId,
                controller.playlistTitle.value,
              );
            },
          ),
        ],
      ),
    );
  }

  void _copyPlaylistLink() async {
    final String url = ShareService.buildUrl('/playlist/${widget.playlistId}');
    try {
      await ShareService.copyToClipboard(url);
      showAppToast(slang.t.galleryDetail.copyLink, type: AppToastType.success);
    } catch (e) {
      showAppToast(slang.t.errors.failedToOperate, type: AppToastType.error);
    }
  }

  void _showEditTitleDialog() {
    final TextEditingController textController = TextEditingController(
      text: controller.playlistTitle.value,
    );

    showAppDialog(
      GlassAlertDialog(
        title: slang.t.common.editTitle,
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: slang.t.common.pleaseEnterNewTitle,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.save,
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.editTitle(textController.text.trim());
                AppService.tryPop();
              }
            },
          ),
        ],
      ),
    );
  }

  /// 批量移出确认：走全站统一的玻璃确认弹窗（含所选预览）。
  Future<void> _showDeleteConfirmDialog() async {
    final count = controller.selectedVideos.length;
    if (count == 0) return;
    final confirmed = await showBatchConfirmDialog(
      title: slang.t.common.confirmDelete,
      message: slang.t.common.areYouSureYouWantToDeleteSelectedItems(
        num: count,
      ),
      confirmLabel: slang.t.common.delete,
      previewTitles: _selectedVideoTitles(),
      totalCount: count,
    );
    if (!confirmed || !mounted) return;
    await controller.deleteSelected();
    // 删除接口回来后由本页驱动刷新：分页模式下数据源自己 refresh
    // 是刷不到当前显示的那一页的
    _refreshList();
    // 删除完成后关闭多选模式
    if (controller.selectedVideos.isEmpty && controller.isMultiSelect.value) {
      controller.toggleMultiSelect();
    }
  }

  /// 取所选视频的标题，供确认弹窗列出「到底要移出哪几个」。
  List<String> _selectedVideoTitles() {
    final selected = controller.selectedVideos;
    final titles = <String>[];
    final seen = <String>{};
    // 勾选可能来自「整个列表」的搜索结果，那些不一定在浏览列表里
    for (final video in [
      ...controller.repository,
      ...controller.search.results,
    ]) {
      if (!selected.contains(video.id) || !seen.add(video.id)) continue;
      final title = video.title?.trim() ?? '';
      titles.add(title.isEmpty ? slang.t.common.noTitle : title);
      if (titles.length >= 3) break;
    }
    return titles;
  }

  void _showDeleteCurPlaylistConfirmDialog() {
    final RxBool isLoading = false.obs;

    showAppDialog(
      Obx(
        () => PopScope(
          canPop: !isLoading.value,
          child: GlassAlertDialog(
            title: slang.t.common.confirmDelete,
            showCloseButton: !isLoading.value,
            content: Text(
              slang.t.favorite.removeItemConfirmWithTitle(
                title: controller.playlistTitle.value,
              ),
            ),
            actions: [
              GlassDialogAction(
                label: slang.t.common.cancel,
                emphasized: false,
                onPressed: isLoading.value ? null : () => AppService.tryPop(),
              ),
              GlassDialogAction(
                label: slang.t.common.delete,
                destructive: true,
                loading: isLoading.value,
                onPressed: isLoading.value
                    ? null
                    : () async {
                        isLoading.value = true;
                        final deleted = await controller.deletePlaylist();
                        if (!mounted) {
                          return;
                        }
                        if (deleted) {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pop(true);
                          return;
                        }
                        isLoading.value = false;
                      },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
