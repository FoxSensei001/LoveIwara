import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 下载分类管理页（玻璃化）：新建 / 重命名 / 删除 / 拖拽排序。
///
/// 与收藏夹管理页（favorite_list_page）同构，差异：
/// - 没有受保护的「默认」分类（未分类是虚拟桶，不在此页）。
/// - 删除分类不删文件，仅把任务退回「未分类」。
/// - 分类天然是「一列可拖拽的行」，没有网格 / 排序双模式，拖拽手柄常驻。
class DownloadCategoryManagePage extends StatefulWidget {
  const DownloadCategoryManagePage({super.key});

  @override
  State<DownloadCategoryManagePage> createState() =>
      _DownloadCategoryManagePageState();
}

class _DownloadCategoryManagePageState
    extends State<DownloadCategoryManagePage> {
  final DownloadService _service = Get.find<DownloadService>();
  final ScrollController _scrollController = ScrollController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  List<DownloadCategory> _categories = [];
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  /// 重新装载分类。
  ///
  /// 本页保留一份本地列表是因为拖拽排序需要「先改顺序、松手后再落库」的中间态；
  /// 但数据来源统一是 [DownloadService.categories] 这个可观察状态，不再各自查库。
  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      await _service.refreshCategories();
      if (mounted) {
        setState(() {
          _categories = List<DownloadCategory>.from(_service.categories);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  /// 新建分类：弹窗要名字 → 建 → 重拉列表。
  ///
  /// 建的过程走 [_isCreating]，让 header 上那枚新建键进沙漏态——不然点完弹窗一关
  /// 界面毫无动静，用户只能盯着列表猜有没有建上。
  Future<void> _create() async {
    if (_isCreating) return;
    final t = slang.Translations.of(context);
    final name = await _promptCategoryName(
      dialogTitle: t.download.category.createShortcut,
      hintText: t.download.category.newCategoryHint,
      confirmLabel: t.common.confirm,
    );
    if (name == null || !mounted) return;

    setState(() => _isCreating = true);
    try {
      final cat = await _service.createCategory(title: name);
      if (cat == null) throw Exception('create failed');
      await _fetch();
      if (!mounted) return;
      showGlassToast(
        t.download.category.createSuccess,
        type: GlassToastType.success,
      );
    } catch (e) {
      if (mounted) {
        showGlassToast(
          t.download.category.createFailed,
          type: GlassToastType.error,
        );
      }
    }
    if (mounted) setState(() => _isCreating = false);
  }

  Future<void> _rename(DownloadCategory category) async {
    final t = slang.Translations.of(context);
    final name = await _promptCategoryName(
      dialogTitle: t.download.category.renameTitle,
      hintText: t.download.category.renameHint,
      confirmLabel: t.common.confirm,
      initialValue: category.title,
    );
    if (name == null || !mounted) return;

    final ok = await _service.updateCategory(category.id, title: name);
    if (ok) {
      await _fetch();
      if (mounted) {
        showGlassToast(
          t.download.category.renameSuccess,
          type: GlassToastType.success,
        );
      }
    } else if (mounted) {
      showGlassToast(
        t.download.category.renameFailed,
        type: GlassToastType.error,
      );
    }
  }

  /// 新建 / 重命名共用的输入弹窗；返回 null 表示取消或名称为空。
  Future<String?> _promptCategoryName({
    required String dialogTitle,
    required String hintText,
    required String confirmLabel,
    String? initialValue,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _CategoryNameDialog(
        dialogTitle: dialogTitle,
        hintText: hintText,
        confirmLabel: confirmLabel,
        initialValue: initialValue,
      ),
    );
  }

  Future<void> _delete(DownloadCategory category) async {
    final t = slang.Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => GlassAlertDialog(
        title: t.download.category.deleteTitle,
        content: Text(
          t.download.category.deleteConfirm(
            title: category.title,
            count: category.itemCount ?? 0,
          ),
        ),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          GlassDialogAction(
            label: t.common.delete,
            emphasized: false,
            destructive: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await _service.deleteCategory(category.id);
    if (ok) {
      await _fetch();
      if (mounted) {
        showGlassToast(
          t.download.category.deleteSuccess,
          type: GlassToastType.success,
        );
      }
    } else if (mounted) {
      showGlassToast(
        t.download.category.deleteFailed,
        type: GlassToastType.error,
      );
    }
  }

  Future<void> _persistOrder() async {
    final ids = _categories.map((c) => c.id).toList();
    await _service.updateCategoriesOrder(ids);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 没有 AppBar 就没人管状态栏图标明暗，不显式声明会沿用上一页
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: GlassHeaderOverlay(
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
            child: RefreshIndicator(
              // 指示器从玻璃 header 下方弹出
              displacement: headerExtent,
              onRefresh: _fetch,
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
                Expanded(
                  child: GlassTitlePill(title: t.download.category.manageTitle),
                ),
                const SizedBox(width: 8),
                _buildActionGroup(context),
              ],
            ),
          ),
          extra: [_buildScrollToTopFab(context)],
        ),
      ),
    );
  }

  /// 右侧动作胶囊：新建分类。
  ///
  /// 没有刷新键：分类全在本地库，只会被这一页自己的操作改动（新建 / 改名 /
  /// 删除 / 排序都会就地重拉），留一个手动刷新纯属占位；真要重拉还有下拉刷新。
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: const Icon(Icons.create_new_folder_outlined),
          tooltip: t.download.category.createShortcut,
          loading: _isCreating,
          onPressed: _create,
        ),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: computeBottomSafeInset(MediaQuery.of(context)) + 16,
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

  Widget _buildBody(
    BuildContext context,
    slang.Translations t,
    double headerExtent,
  ) {
    final double bottomInset =
        computeBottomSafeInset(MediaQuery.of(context)) + 16;

    if (_isLoading && _categories.isEmpty) {
      return _buildFullScreenState(
        headerExtent: headerExtent,
        child: const CircularProgressIndicator(),
      );
    }

    if (_categories.isEmpty) {
      return _buildFullScreenState(
        headerExtent: headerExtent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MyEmptyWidget(),
              const SizedBox(height: 16),
              Text(
                t.download.category.emptyHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              // 空态里也给一个新建入口：这时 header 上那枚键还没被用户注意到
              FilledButton.tonalIcon(
                onPressed: _create,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(t.download.category.createShortcut),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      scrollController: _scrollController,
      padding: EdgeInsets.fromLTRB(16, headerExtent + 8, 16, bottomInset),
      itemCount: _categories.length,
      buildDefaultDragHandles: false,
      onReorderItem: (oldIndex, newIndex) {
        setState(() {
          final c = _categories.removeAt(oldIndex);
          _categories.insert(newIndex, c);
        });
        _persistOrder();
      },
      itemBuilder: (context, index) =>
          _buildDraggableCard(_categories[index], index, t),
    );
  }

  /// 全屏状态（加载 / 空）也要可下拉刷新，所以套一层可滚动视图。
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

  Widget _buildDraggableCard(
    DownloadCategory category,
    int index,
    slang.Translations t,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      key: ValueKey(category.id),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.title,
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
                        Icons.download_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${category.itemCount ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  _rename(category);
                } else if (value == 'delete') {
                  _delete(category);
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
                      const Icon(Icons.delete, size: 18, color: Colors.red),
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
      ),
    );
  }
}

/// 新建 / 重命名分类的输入弹窗。
///
/// 独立成 StatefulWidget 是为了让 controller 的生命周期跟着弹窗本体走：
/// `showDialog` 的 future 在 `Navigator.pop` 当下就完成了，而弹窗还要播完退场
/// 动画才卸载——在外面 dispose controller，退场期间 TextField 重建就会撞上
/// 「A TextEditingController was used after being disposed」。
class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.dialogTitle,
    required this.hintText,
    required this.confirmLabel,
    this.initialValue,
  });

  final String dialogTitle;
  final String hintText;
  final String confirmLabel;
  final String? initialValue;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
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
      showGlassToast(t.download.category.nameEmpty, type: GlassToastType.error);
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
          hintText: widget.hintText,
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
          emphasized: false,
          onPressed: () => _submit(_controller.text),
        ),
      ],
    );
  }
}
