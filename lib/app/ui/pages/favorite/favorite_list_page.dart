import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本地收藏夹列表（玻璃化）。
///
/// 数据全在本地 sqlite，一次取完，所以这里没有分页 / 瀑布切换；
/// 「分页模式」只对收藏夹详情里的作品列表有意义（见 favorite_folder_detail_page）。
class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final FavoriteService _favoriteService = Get.find<FavoriteService>();
  final ScrollController _scrollController = ScrollController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  List<FavoriteFolder> _folders = [];
  bool _isLoading = true;
  String? _error;
  bool _isDragMode = false;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  Future<void> _fetchFolders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final folders = await _favoriteService.getAllFolders();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _folders = folders;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _createNewFolder() async {
    final t = slang.Translations.of(context);
    final title = await _promptFolderName(
      dialogTitle: t.favorite.createFolder,
      confirmLabel: t.favorite.create,
    );
    if (title == null || !mounted) return;

    try {
      final folder = await _favoriteService.createFolder(title: title);
      if (folder == null) throw Exception('Create failed');
      await _fetchFolders();
      if (!mounted) return;
      showGlassToast(
        t.favorite.createFolderSuccess,
        type: GlassToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showGlassToast(t.favorite.createFolderFailed, type: GlassToastType.error);
    }
  }

  Future<void> _deleteFolder(FavoriteFolder folder) async {
    final t = slang.Translations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => GlassAlertDialog(
        title: t.favorite.deleteFolderTitle,
        content: Text(
          t.favorite.deleteFolderConfirmWithTitle(title: folder.title),
        ),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          GlassDialogAction(
            label: t.common.confirm,
            emphasized: false,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final success = await _favoriteService.deleteFolder(folder.id);
      if (!success) throw Exception('Delete failed');
      await _fetchFolders();
      if (!mounted) return;
      showGlassToast(
        t.favorite.errors.deleteFolderSuccess,
        type: GlassToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showGlassToast(
        t.favorite.errors.deleteFolderFailed,
        type: GlassToastType.error,
      );
    }
  }

  Future<void> _editFolder(FavoriteFolder folder) async {
    final t = slang.Translations.of(context);
    final title = await _promptFolderName(
      dialogTitle: t.favorite.editFolderTitle,
      confirmLabel: t.common.confirm,
      initialValue: folder.title,
    );
    if (title == null || !mounted) return;

    try {
      final success = await _favoriteService.updateFolder(
        folder.id,
        title: title,
      );
      if (!success) throw Exception('Update failed');
      await _fetchFolders();
      if (!mounted) return;
      showGlassToast(
        t.favorite.editFolderSuccess,
        type: GlassToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showGlassToast(t.favorite.editFolderFailed, type: GlassToastType.error);
    }
  }

  /// 新建 / 重命名共用的输入弹窗；返回 null 表示取消或名称为空。
  Future<String?> _promptFolderName({
    required String dialogTitle,
    required String confirmLabel,
    String? initialValue,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _FolderNameDialog(
        dialogTitle: dialogTitle,
        confirmLabel: confirmLabel,
        initialValue: initialValue,
      ),
    );
  }

  void _navigateToFolderDetail(String folderId, String? folderTitle) {
    NaviService.navigateToLocalFavoriteDetailPage(folderId, folderTitle);
  }

  Future<void> _updateFoldersOrder() async {
    final folderIds = _folders.map((f) => f.id).toList();
    await _favoriteService.updateFoldersOrder(folderIds);
  }

  /// 右侧动作胶囊：[排序（仅有收藏夹时）] 新建。
  ///
  /// 没有刷新键：本地收藏是本地库，只会被 App 自己的操作改动（新建、改名、
  /// 删除、排序都会就地刷新列表），留一个手动刷新纯属占位；真要重拉还有
  /// 下拉刷新，加载失败时空态里也有重试。
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassButtonGroup(
      children: [
        GlassGroupSlot(
          visible: _folders.isNotEmpty,
          child: GlassIconButton(
            icon: Icon(_isDragMode ? Icons.check : Icons.sort),
            tooltip: _isDragMode ? t.common.confirm : t.common.sort,
            onPressed: () => setState(() => _isDragMode = !_isDragMode),
          ),
        ),
        GlassIconButton(
          icon: const Icon(Icons.create_new_folder),
          tooltip: t.favorite.createFolder,
          onPressed: _createNewFolder,
        ),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
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
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth == 0 &&
                notification.metrics.axis == Axis.vertical) {
              _showBackToTop.value = notification.metrics.pixels >= 300;
            }
            return false;
          },
          child: RefreshIndicator(
            // 指示器从玻璃 header 下方弹出
            displacement: headerExtent,
            onRefresh: _fetchFolders,
            child: _buildBody(context, t, headerExtent),
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
              Expanded(child: GlassTitlePill(title: t.favorite.myFavorites)),
              const SizedBox(width: 8),
              _buildActionGroup(context),
            ],
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    slang.Translations t,
    double headerExtent,
  ) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom + 16;

    if (_error != null) {
      return _buildFullScreenState(
        headerExtent: headerExtent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _fetchFolders,
                icon: const Icon(Icons.refresh),
                label: Text(t.common.refresh),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading && _folders.isEmpty) {
      return _buildFullScreenState(
        headerExtent: headerExtent,
        child: const CircularProgressIndicator(),
      );
    }

    if (_folders.isEmpty) {
      return _buildFullScreenState(
        headerExtent: headerExtent,
        child: const MyEmptyWidget(),
      );
    }

    if (_isDragMode) {
      return ReorderableListView.builder(
        scrollController: _scrollController,
        padding: EdgeInsets.fromLTRB(16, headerExtent + 8, 16, bottomInset),
        itemCount: _folders.length,
        buildDefaultDragHandles: false,
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            final folder = _folders.removeAt(oldIndex);
            _folders.insert(newIndex, folder);
          });
          _updateFoldersOrder();
        },
        itemBuilder: (context, index) =>
            _buildDraggableFolderCard(_folders[index], index, t),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16, headerExtent + 8, 16, bottomInset),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _folders.length,
      itemBuilder: (context, index) => _buildFolderCard(_folders[index], t),
    );
  }

  /// 全屏状态（加载 / 错误 / 空）也要可下拉刷新，所以套一层可滚动视图。
  Widget _buildFullScreenState({
    required double headerExtent,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: EdgeInsets.only(top: headerExtent),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderCard(FavoriteFolder folder, slang.Translations t) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToFolderDetail(folder.id, folder.title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 第一行：名称
              Text(
                folder.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // 第二行：数量和按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 14,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${folder.itemCount ?? 0}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (folder.id != 'default')
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      position: PopupMenuPosition.under,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editFolder(folder);
                        } else if (value == 'delete') {
                          _deleteFolder(folder);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 18),
                              const SizedBox(width: 8),
                              Text(t.common.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.common.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableFolderCard(
    FavoriteFolder folder,
    int index,
    slang.Translations t,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      key: ValueKey(folder.id),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 拖拽手柄
            ReorderableDragStartListener(
              index: index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.drag_handle, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 文件夹图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.folder, color: colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            // 文件夹信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${folder.itemCount ?? 0} ${t.favorite.items}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 排序序号
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 新建 / 重命名收藏夹的输入弹窗。
///
/// 独立成 StatefulWidget 是为了让 controller 的生命周期跟着弹窗本体走：
/// `showDialog` 的 future 在 `Navigator.pop` 当下就完成了，而弹窗还要播完退场
/// 动画才卸载——在 `whenComplete` 里 dispose controller，退场期间 TextField
/// 重建就会撞上「A TextEditingController was used after being disposed」。
class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({
    required this.dialogTitle,
    required this.confirmLabel,
    this.initialValue,
  });

  final String dialogTitle;
  final String confirmLabel;
  final String? initialValue;

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    final t = slang.Translations.of(context);
    final value = raw.trim();
    if (value.isEmpty) {
      showGlassToast(
        t.favorite.errors.folderNameCannotBeEmpty,
        type: GlassToastType.error,
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassAlertDialog(
      title: widget.dialogTitle,
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: t.favorite.enterFolderNameHere,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: _submit,
      ),
      actions: [
        GlassDialogAction(
          label: t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        GlassDialogAction(
          label: widget.confirmLabel,
          onPressed: () => _submit(_controller.text),
        ),
      ],
    );
  }
}
