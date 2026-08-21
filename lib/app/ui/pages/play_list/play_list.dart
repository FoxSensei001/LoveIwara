import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_controller.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';
import 'package:i_iwara/app/ui/pages/play_list/widgets/playlist_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 播放列表列表页（玻璃化 + 瀑布/分页双模式）。
class PlayListPage extends StatefulWidget {
  final String userId;
  final bool isMine;

  const PlayListPage({super.key, required this.userId, required this.isMine});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  late PlayListsController controller;
  late PlayListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();

  /// 外部刷新信号：分页模式必须由 MediaListView 自己刷新，
  /// 直接 `repository.refresh()` 只会动数据源、不会换掉当前显示的那一页。
  /// 带回执，header 上的刷新钮据此在刷完前显示沙漏。
  final ListRefreshSignal _refreshSignal = ListRefreshSignal();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  late bool _isPaginated = CommonConstants.isPaginated;

  /// 编辑态：卡片右上角才出现删除钮（仅自己的播放列表可进）。
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PlayListsController());
    listSourceRepository = PlayListRepository(userId: widget.userId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshSignal.dispose();
    _showBackToTop.dispose();
    Get.delete<PlayListsController>();
    listSourceRepository.dispose();
    super.dispose();
  }

  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionHelp = 'help';

  Future<void> _refreshList() => _refreshSignal.request();

  void _toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
    // 进出编辑态都从空选开始，免得上次留下的勾选在下次删错东西
    controller.clearSelection();
  }

  void _togglePaginationMode() {
    setState(() => _isPaginated = !_isPaginated);
    persistPaginationMode(_isPaginated);
    // 分页与瀑布的下标口径不同，模式一换就把选择清掉
    controller.clearSelection();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openPlaylistDetail(
    BuildContext context,
    PlaylistModel playlist,
  ) async {
    final result = await GoRouter.of(context).push(
      '/playlist_detail/${playlist.id}',
      extra: PlayListDetailExtra(isMine: widget.isMine),
    );
    if (!mounted) return;
    // 详情页里删掉了这个播放列表 / 改了标题，回来得重拉
    if (result == true && widget.isMine) {
      _refreshList();
    }
  }

  /// 右侧动作胶囊：[编辑 · 新建（均仅自己的列表）] [瀑布/分页(宽屏)] 刷新
  /// [帮助(宽屏)] [更多(窄屏，收分页切换 + 帮助)]。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    return GlassButtonGroup(
      children: [
        // 编辑态开关：只有进了编辑态，卡片右上角的删除钮才长出来，
        // 平时列表保持干净（删播放列表是低频且不可逆的操作）
        GlassGroupSlot(
          visible: widget.isMine,
          child: GlassIconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.checklist),
            tooltip: _isEditMode ? t.common.exitEditMode : t.common.editMode,
            onPressed: _toggleEditMode,
          ),
        ),
        GlassGroupSlot(
          visible: widget.isMine,
          child: GlassIconButton(
            icon: const Icon(Icons.add),
            tooltip: t.playList.createNewPlaylist,
            onPressed: () => _showCreateDialog(context),
          ),
        ),
        GlassGroupSlot(
          visible: isWide,
          child: GlassIconButton(
            icon: Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
            tooltip: _isPaginated
                ? t.common.pagination.waterfall
                : t.common.pagination.pagination,
            onPressed: _togglePaginationMode,
          ),
        ),
        GlassAsyncIconButton(
          icon: const Icon(Icons.refresh),
          tooltip: t.common.refresh,
          onPressed: _refreshList,
        ),
        GlassGroupSlot(
          visible: isWide,
          child: GlassIconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: t.playList.friendlyTips,
            onPressed: _showHelpDialog,
          ),
        ),
        // 窄屏胶囊塞不下五个键，分页切换与帮助收进这里
        GlassGroupSlot(
          visible: !isWide,
          child: SizedBox(
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
              onSelected: (value) {
                switch (value) {
                  case _menuActionTogglePagination:
                    _togglePaginationMode();
                    break;
                  case _menuActionHelp:
                    _showHelpDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: _menuActionTogglePagination,
                  child: Row(
                    children: [
                      Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
                      const SizedBox(width: 12),
                      // 文案与图标一致：显示将要切换到的模式
                      Text(
                        _isPaginated
                            ? t.common.pagination.waterfall
                            : t.common.pagination.pagination,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: _menuActionHelp,
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline),
                      const SizedBox(width: 12),
                      Text(t.playList.friendlyTips),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      body: Obx(() {
        final int count = controller.selectedPlaylistIds.length;
        return BatchSelectionScope(
          active: _isEditMode,
          selectedCount: count,
          actions: [
            GlassSelectionAction(
              icon: Icons.delete,
              label: slang.t.common.delete,
              destructive: true,
              loading: controller.isBatchDeleting.value,
              onPressed: count == 0 ? null : _showDeleteSelectedDialog,
            ),
          ],
          onClear: controller.clearSelection,
          // 系统返回 / iOS 侧滑 / Esc 先退编辑态，而不是把整页弹掉
          child: SelectionPopScope(
            active: _isEditMode,
            onExit: _toggleEditMode,
            child: _buildBody(context, headerExtent, statusBarHeight, isWide),
          ),
        );
      }),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double headerExtent,
    double statusBarHeight,
    bool isWide,
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
        child: MediaListView<PlaylistModel>(
          sourceList: listSourceRepository,
          isPaginated: _isPaginated,
          refreshSignal: _refreshSignal,
          scrollController: _scrollController,
          paddingTop: headerExtent,
          emptyIcon: Icons.playlist_play,
          extendedListDelegate:
              const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
          // 换页后原来勾的已经不在屏幕上了，留着只会误删
          onPageChanged: controller.clearSelection,
          itemBuilder: (context, playlist, index) => Obx(
            () => PlaylistItemWidget(
              playlist: playlist,
              onTap: () => _openPlaylistDetail(context, playlist),
              isMultiSelect: _isEditMode,
              isSelected: controller.selectedPlaylistIds.contains(playlist.id),
              onToggleSelect: () => controller.toggleSelection(playlist.id),
              isDeleting: controller.isDeletingPlaylist(playlist.id),
            ),
          ),
        ),
      ),
      // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
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
              child: Obx(() {
                // Rx 必须在分支之外读一次：非选择态那一支不碰任何可观察量，
                // Obx 会因为「没有订阅到任何东西」直接抛 ObxError
                final int selectedCount = controller.selectedPlaylistIds.length;
                return GlassCapsuleMorph(
                  child: _isEditMode
                      ? SizedBox(
                          key: const ValueKey('selection'),
                          width: 168,
                          child: GlassSelectionSummary(
                            selectedCount: selectedCount,
                            allSelected: false,
                            onToggleAll: null,
                          ),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('title'),
                          child: GlassTitlePill(
                            flat: true,
                            title: t.playList.myPlayList,
                          ),
                        ),
                );
              }),
            ),
            const SizedBox(width: 8),
            _buildActionGroup(context, isWide: isWide),
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

  /// 批量删除确认：删除期间不许关弹窗、不许重复提交（逐条串行调接口，
  /// 中途关掉会让用户不知道删到哪儿了）。
  void _showDeleteSelectedDialog() {
    if (controller.selectedPlaylistIds.isEmpty) return;

    showAppDialog(
      Obx(
        () => PopScope(
          canPop: !controller.isBatchDeleting.value,
          child: AlertDialog(
            title: _dialogTitleRow(
              context,
              slang.t.common.confirmDelete,
              enabled: !controller.isBatchDeleting.value,
            ),
            content: Text(
              slang.t.common.areYouSureYouWantToDeleteSelectedItems(
                num: controller.selectedPlaylistIds.length,
              ),
            ),
            actions: [
              TextButton(
                onPressed: controller.isBatchDeleting.value
                    ? null
                    : () => AppService.tryPop(),
                child: Text(slang.t.common.cancel),
              ),
              TextButton(
                onPressed: controller.isBatchDeleting.value
                    ? null
                    : () async {
                        final deleted = await controller
                            .deleteSelectedPlaylists();
                        if (deleted > 0) {
                          AppService.tryPop();
                          _refreshList();
                          // 全删干净了就顺手退出编辑态
                          if (controller.selectedPlaylistIds.isEmpty &&
                              _isEditMode &&
                              mounted) {
                            setState(() => _isEditMode = false);
                          }
                        }
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: controller.isBatchDeleting.value
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

  void _showCreateDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final RxBool isLoading = false.obs;

    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(context, slang.t.common.createPlayList),
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
          Obx(
            () => TextButton(
              onPressed: isLoading.value
                  ? null
                  : () async {
                      isLoading.value = true;
                      if (textController.text.trim().isNotEmpty) {
                        final res = await controller.createPlaylist(
                          textController.text.trim(),
                        );
                        if (res) {
                          _refreshList();
                          AppService.tryPop();
                        }
                      }
                      isLoading.value = false;
                    },
              child: isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(slang.t.common.create),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(context, '💡 ${slang.t.playList.friendlyTips}'),
        content: Text(
          '${slang.t.playList.dearUser}:\n\n'
          '⚠️ ${slang.t.playList.iwaraPlayListSystemIsNotPerfectYet}\n'
          '• ${slang.t.playList.notSupportSetCover}\n'
          '• ${slang.t.playList.notSupportSetPrivate}\n\n'
          '${slang.t.playList.yesCreateListWillAlwaysExistAndVisibleToEveryone}😅\n\n'
          '💡 ${slang.t.playList.smallSuggestion}: ${slang.t.playList.useLikeToCollectContent}\n\n'
          '🤝 ${slang.t.playList.welcomeToDiscussOnGitHub}',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(
              slang.t.playList.iUnderstand,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
