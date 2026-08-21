import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

enum _PlaylistDetailMenuAction { editTitle, deletePlaylist, share, copyLink }

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

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      PlayListDetailController(playlistId: widget.playlistId),
    );
  }

  @override
  void dispose() {
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
    return GlassHeaderOverlay(
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
        child: MediaListView<Video>(
          sourceList: controller.repository,
          isPaginated: _isPaginated,
          refreshSignal: _refreshSignal,
          scrollController: _scrollController,
          paddingTop: headerExtent,
          emptyIcon: Icons.video_library_outlined,
          // 换页后原来的选择已经不在屏幕上了，留着只会误删
          onPageChanged: () => controller.selectedVideos.clear(),
          itemBuilder: buildVideoItem,
        ),
      ),
      // header 行：左 返回圆钮 / 中 播放列表标题胶囊 / 右 动作胶囊
      header: Padding(
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
            // 选择态下标题胶囊改报「已选 N 项」：单壳常驻、只换内容
            Expanded(
              child: Obx(
                () => GlassCapsuleMorph(
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
              ),
            ),
            const SizedBox(width: 8),
            _buildActionGroup(context),
          ],
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
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(
      () => GlassButtonGroup(
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
            onPressed: _refreshList,
          ),
          SizedBox(
            width: GlassTokens.groupIconButtonSize,
            height: GlassTokens.groupIconButtonSize,
            child: PopupMenuButton<_PlaylistDetailMenuAction>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, size: GlassTokens.iconSize),
              position: PopupMenuPosition.under,
              // 往下挪一点，别压住玻璃胶囊本身
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (action) {
                switch (action) {
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
              },
              itemBuilder: (context) => [
                if (widget.isMine)
                  PopupMenuItem(
                    value: _PlaylistDetailMenuAction.editTitle,
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 12),
                        Text(t.common.editTitle),
                      ],
                    ),
                  ),
                if (widget.isMine)
                  PopupMenuItem(
                    value: _PlaylistDetailMenuAction.deletePlaylist,
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          t.common.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: _PlaylistDetailMenuAction.share,
                  child: Row(
                    children: [
                      const Icon(Icons.share),
                      const SizedBox(width: 12),
                      Text(t.common.share),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _PlaylistDetailMenuAction.copyLink,
                  child: Row(
                    children: [
                      const Icon(Icons.copy),
                      const SizedBox(width: 12),
                      Text(t.galleryDetail.copyLink),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom:
          computeBottomSafeInset(MediaQuery.of(context)) +
          16 +
          (_isPaginated ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => IgnorePointer(
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
                onPressed: _scrollToTop,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildVideoItem(BuildContext context, Video video, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaLayoutUtils.calculateCardWidth(
                MediaQuery.sizeOf(context).width,
              );

        return Obx(() {
          final bool isSelected = controller.selectedVideos.contains(video.id);
          final bool isMultiSelect = controller.isMultiSelect.value;

          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                VideoCardListItemWidget(
                  video: video,
                  width: itemWidth,
                  onOpenVideo:
                      ({required videoId, Map<String, dynamic>? extData}) {
                        return _openVideoFromPlaylist(
                          videoId: videoId,
                          extData: extData,
                        );
                      },
                ),
                // 选择态：角标勾选片 + 选中描边（全站统一，
                // 见 GlassSelectableOverlay）。常驻挂载以获得进出过渡。
                Positioned.fill(
                  child: GlassSelectableOverlay(
                    selectionMode: isMultiSelect,
                    selected: isSelected,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (isMultiSelect)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.toggleSelection(video.id),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _openVideoFromPlaylist({
    required String videoId,
    required Map<String, dynamic>? extData,
  }) async {
    final loadedVideos = List<Video>.of(controller.repository);

    Video? initialVideoInfo;
    for (final video in loadedVideos) {
      if (video.id == videoId) {
        initialVideoInfo = video;
        break;
      }
    }

    final playlistContext = InnerPlaylistContext.fromVideos(
      source: InnerPlaylistSource.playlistDetail,
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

  /// 弹窗标题行：标题 + 玻璃关闭圆钮（全局统一约定）。
  Widget _dialogTitleRow(
    BuildContext context,
    String title, {
    bool enabled = true,
  }) {
    final t = slang.Translations.of(context);
    return Row(
      children: [
        Expanded(child: Text(title)),
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.close),
          tooltip: t.common.close,
          onPressed: enabled ? () => AppService.tryPop() : null,
        ),
      ],
    );
  }

  void _showShareDialog() {
    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(context, slang.t.common.share),
        content: Text(slang.t.common.areYouSureYouWantToShareThisPlaylist),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              AppService.tryPop();
              ShareService.sharePlayListDetail(
                widget.playlistId,
                controller.playlistTitle.value,
              );
            },
            child: Text(slang.t.common.share),
          ),
        ],
      ),
    );
  }

  void _copyPlaylistLink() async {
    final String url = ShareService.buildUrl('/playlist/${widget.playlistId}');
    try {
      await ShareService.copyToClipboard(url);
      Get.snackbar(
        slang.t.common.success,
        slang.t.galleryDetail.copyLink,
        snackPosition: SnackPosition.bottom,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        slang.t.common.error,
        slang.t.errors.failedToOperate,
        snackPosition: SnackPosition.bottom,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showEditTitleDialog() {
    final TextEditingController textController = TextEditingController(
      text: controller.playlistTitle.value,
    );

    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(context, slang.t.common.editTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: slang.t.common.pleaseEnterNewTitle,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.editTitle(textController.text.trim());
                AppService.tryPop();
              }
            },
            child: Text(slang.t.common.save),
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
    for (final video in controller.repository) {
      if (!selected.contains(video.id)) continue;
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
          child: AlertDialog(
            title: _dialogTitleRow(
              context,
              slang.t.common.confirmDelete,
              enabled: !isLoading.value,
            ),
            content: Text(
              slang.t.favorite.removeItemConfirmWithTitle(
                title: controller.playlistTitle.value,
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading.value ? null : () => AppService.tryPop(),
                child: Text(slang.t.common.cancel),
              ),
              TextButton(
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
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Text(slang.t.common.delete),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
