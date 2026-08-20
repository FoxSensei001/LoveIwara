import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart'
    show openDownloadCategoryManagePage;
import 'package:i_iwara/app/ui/pages/download/widgets/move_to_category_sheet.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/default_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/video_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/gallery_download_task_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// Status filter options for download tasks
enum DownloadStatusFilter { all, failed, downloaded }

/// Type filter options for download tasks
enum DownloadTypeFilter { all, video, gallery, other }

/// 下载任务列表页（玻璃化）。
///
/// header 两行：第一行「返回 / 中间胶囊（搜索框 ↔ 已选计数）/ 动作胶囊」，
/// 第二行分类标签条。状态 / 类型筛选收进筛选弹窗，生效时动作胶囊上挂红点。
class DownloadTaskListPage extends StatefulWidget {
  const DownloadTaskListPage({super.key});

  @override
  State<DownloadTaskListPage> createState() => _DownloadTaskListPageState();
}

class _DownloadTaskListPageState extends State<DownloadTaskListPage> {
  /// 标题行与分类条之间的间距。
  static const double _headerRowGap = 6;

  /// 分类条与列表首屏之间的呼吸。
  ///
  /// 单行 header 的 56 里天然留了余量（胶囊只有 44 高），两行 header 的第二行
  /// 高度就是胶囊高度、一点余量都没有——不补这一段，第一张卡片会紧贴分类条下沿。
  static const double _headerBottomGap = 8;

  /// 分类条所占行高（与玻璃胶囊同高，标签本体略矮居中）。
  static const double _categoryStripHeight = GlassTokens.pillHeight;

  /// 分类标签本体高度。
  static const double _categoryChipHeight = 36;

  static const String _menuActionManageCategory = 'manageCategory';
  static const String _menuActionDeleteByDate = 'deleteByDate';
  static const String _menuActionResumeAll = 'resumeAll';
  static const String _menuActionPauseAll = 'pauseAll';

  final DownloadTaskRepository _downloadTaskRepository =
      DownloadTaskRepository();
  final ScrollController _scrollController = ScrollController();
  // 分类标签条的横向滚动控制器（用于鼠标滚轮转横向滑动）
  final ScrollController _categoryStripController = ScrollController();
  late _HistoryDownloadTasksSource _historySource;

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  /// 搜索输入防抖：每敲一个字都要走三条本地 DB 查询 + 历史区串行刷新，
  /// 不防抖既浪费查询，也让筛选钮的沙漏态一路抽搐。
  Timer? _searchDebounce;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 300);

  // 等待中任务列表
  List<DownloadTask> _pendingTasks = [];
  bool _isLoadingPendingTasks = false;
  int _lastPendingVersion = -1;

  // 失败任务列表
  List<DownloadTask> _failedTasks = [];
  bool _isLoadingFailedTasks = false;
  int _lastFailedVersion = -1;

  // 加载期间若有更新的状态版本到来，则置脏并在本轮加载结束后重跑，
  // 避免“加载中丢弃后续更新”导致快照永远停留在旧状态的竞态。
  bool _pendingReloadDirty = false;
  bool _failedReloadDirty = false;

  // 历史区域刷新串行化：LoadingMoreBase 不支持并发 refresh，
  // 并发会相互 clear/addAll 造成列表被清空或漏掉“刚完成”的任务。
  bool _isRefreshingHistory = false;
  bool _historyRefreshDirty = false;
  int _lastHistoryVersion = -1;

  // 用于监听任务状态变更
  int _lastStatusVersion = -1;
  Worker? _statusChangedWorker;

  // 批量删除模式
  bool _isSelectionMode = false;
  final Set<String> _selectedTaskIds = {};

  // Filter state
  String _searchQuery = '';
  DownloadStatusFilter _statusFilter = DownloadStatusFilter.all;
  DownloadTypeFilter _typeFilter = DownloadTypeFilter.all;
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterLoading = false;

  // 分类筛选状态：'all' | 'uncategorized' | <categoryId>
  String _categoryFilter = 'all';
  List<DownloadCategory> _categories = [];
  int _uncategorizedCount = 0;
  Worker? _categoriesChangedWorker;
  Worker? _removedTaskIdsWorker;

  // 历史区去重 / 删除残留防护：
  // - _deletedTombstones：本次会话中已成功删除、但异步历史刷新可能尚未从
  //   _historySource 中剔除的任务 id。删除“下载中”任务时，取消清理会把它瞬时
  //   写回 paused 并触发历史刷新，可能与删除的就地移除发生竞态而被重新读入；
  //   构建时据墓碑隐藏，保证删除后立刻消失、无需重进页面。刷新确认 DB 已无该
  //   行后清除（见 _refreshHistory）。
  // - _historyHiddenIds：每次构建时重算 = 活跃区(下载中/等待/失败)的全部 id ∪
  //   _deletedTombstones。历史区是独立的 LoadingMoreSliverList，原本不参与
  //   顶部区域的 seenIds 去重；命中该集合的历史行直接跳过渲染，杜绝同一任务在
  //   “下载中/暂停”等区域与历史区同时出现（如续传一个旧的暂停任务时的重复显示）。
  final Set<String> _deletedTombstones = <String>{};
  Set<String> _historyHiddenIds = <String>{};

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedTaskIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTaskIds.clear();
    });
  }

  void _toggleItemSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  Future<void> _deleteSelectedTasks() async {
    if (_selectedTaskIds.isEmpty) return;

    final t = slang.Translations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: _dialogTitleRow(context, t.common.confirmDelete),
        content: Text(
          t.common.areYouSureYouWantToDeleteSelectedItems(
            num: _selectedTaskIds.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.common.confirm),
          ),
        ],
      ),
    );

    if (result == true) {
      await DownloadService.to.deleteTasks(_selectedTaskIds.toList());
      _exitSelectionMode();
    }
  }

  /// 入口：打开“按日期删除”弹窗，拿到用户选择的日期条件后进入确认与删除流程。
  Future<void> _showDeleteByDateDialog() async {
    final selection = await showModalBottomSheet<_DateDeletionSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _DeleteByDateDialog(),
    );
    if (selection == null || !mounted) return;
    await _confirmAndDeleteByDate(selection);
  }

  /// 查询匹配任务 -> 二次确认 -> 带进度删除 -> 结果提示 -> 刷新列表。
  Future<void> _confirmAndDeleteByDate(_DateDeletionSelection selection) async {
    final t = slang.Translations.of(context);

    // 1. 查询区间内的任务（任意状态）。
    List<DownloadTask> tasks;
    try {
      tasks = await _downloadTaskRepository.getTasksByCreatedDateRange(
        start: selection.start,
        end: selection.end,
      );
    } catch (_) {
      if (!mounted) return;
      showGlassToast(
        t.download.errors.failedToLoadTasks,
        type: GlassToastType.error,
      );
      return;
    }
    if (!mounted) return;

    if (tasks.isEmpty) {
      showGlassToast(
        t.download.deleteByDate.noMatch,
        type: GlassToastType.warning,
      );
      return;
    }

    // 2. 二次确认（明确告知数量与不可撤销）。
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: _dialogTitleRow(context, t.download.deleteByDate.confirmTitle),
        content: Text(
          t.download.deleteByDate.confirmContent(count: tasks.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.common.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // 3. 执行删除（耗时操作，弹出不可关闭的进度弹窗）。
    final result = await showDialog<DeleteTasksResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteProgressDialog(tasks: tasks),
    );
    if (!mounted || result == null) return;

    // 4. 结果提示：全部成功 / 部分被占用跳过。
    if (result.skipped == 0) {
      showGlassToast(
        t.download.deleteByDate.resultSuccess(count: result.deleted),
        type: GlassToastType.success,
      );
    } else {
      showGlassToast(
        t.download.deleteByDate.resultPartial(
          deleted: result.deleted,
          skipped: result.skipped,
        ),
        type: GlassToastType.warning,
      );
    }

    // 5. 刷新各分区列表。
    await _reloadPendingTasks();
    await _reloadFailedTasks();
    await _refreshHistory();
  }

  @override
  void initState() {
    super.initState();
    _historySource = _HistoryDownloadTasksSource(_downloadTaskRepository);
    _reloadPendingTasks();
    _reloadFailedTasks();
    _reloadCategories();

    // 监听任务状态变更，将刷新（含 setState / DB 读）等副作用移出 build。
    _statusChangedWorker = ever(DownloadService.to.taskStatusChangedNotifier, (
      int currentVersion,
    ) {
      if (currentVersion == _lastStatusVersion) return;
      _lastStatusVersion = currentVersion;
      // 延后到帧回调后执行，避免在 build/通知阶段触发 setState。
      _runAfterFrame(() {
        // 刷新顶部区域
        _refreshPendingTasksIfNeeded();
        _refreshFailedTasksIfNeeded();
        // 刷新历史区域（串行 + 版本重跑，避免并发 refresh 漏掉刚完成的任务）
        _refreshHistory();
        // 任务增删 / 完成会影响各分类计数，顺带刷新分类条。
        _reloadCategories();
      });
    });

    // 分类增删改 / 排序变更时刷新分类条与筛选。
    _categoriesChangedWorker = ever(
      DownloadService.to.categoriesChangedNotifier,
      (_) {
        _runAfterFrame(() {
          _reloadCategories();
        });
      },
    );

    // 删除任务：就地移除对应行，保留滚动位置（不整列重载）。
    _removedTaskIdsWorker = ever(DownloadService.to.removedTaskIdsNotifier, (
      List<String> ids,
    ) {
      if (ids.isEmpty) return;
      _runAfterFrame(() {
        _removeTasksInPlace(ids);
        // 删除影响各分类计数，刷新分类条。
        _reloadCategories();
      });
    });
  }

  /// 在下一帧结束后执行 [action]（仍挂载时），用于把 setState / DB 读等副作用移出
  /// build / 通知阶段。
  ///
  /// 关键：addPostFrameCallback 只是登记回调，本身不会请求新的一帧。应用空闲时
  /// （未在下载、无动画、无 setState 待处理）注册的回调会一直挂起不执行——这正是
  /// “没有下载任务时删除列表项不刷新、必须重进页面才看到被删除”的根因：删除是异步
  /// 的（文件 IO + DB），完成并广播时确认弹窗的关闭动画往往已结束、界面进入空闲，
  /// 于是回调永远等不到下一帧。这里追加 ensureVisualUpdate() 主动安排一帧，确保
  /// 回调及时执行；若当前正处于某一帧之中则它无操作（本帧的 postFrame 回调照常触发）。
  void _runAfterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _statusChangedWorker?.dispose();
    _categoriesChangedWorker?.dispose();
    _removedTaskIdsWorker?.dispose();
    _scrollController.dispose();
    _categoryStripController.dispose();
    _showBackToTop.dispose();
    _historySource.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerHeight =
        GlassTokens.headerRowHeight + _headerRowGap + _categoryStripHeight;
    final double headerExtent = statusBarHeight + headerHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 没有 AppBar 就没人管状态栏图标明暗，不显式声明会沿用上一页
      //（如视频详情页的白色图标），在浅色背景下看不见。
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: DownloadScaleScope(
          child: GlassHeaderOverlay(
            headerExtent: headerExtent,
            headerTop: statusBarHeight,
            headerHeight: headerHeight,
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
                // 指示器从玻璃 header 下方弹出，而不是被 header 压住
                displacement: headerExtent,
                onRefresh: _refreshAll,
                child: Obx(() {
                  // 仅订阅任务状态变更以触发重建；实际的刷新副作用在
                  // initState 注册的 worker 中处理（见 _statusChangedWorker）。
                  DownloadService.to.taskStatusChangedNotifier.value;
                  return _buildSingleList(headerExtent + _headerBottomGap);
                }),
              ),
            ),
            // header：第一行「返回 / 搜索或已选计数 / 动作胶囊」，第二行分类条
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
                          tooltip: slang.Translations.of(context).common.back,
                          onPressed: () => AppService.tryPop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildCenterCapsule(context)),
                        const SizedBox(width: 8),
                        _buildActionGroup(context, isWide: isWide),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: _headerRowGap),
                // 分类标签条：始终显示，便于发现并进入分类系统
                // （无分类时显示「全部 + 管理分类」入口）。
                _buildCategoryStrip(),
              ],
            ),
            extra: [_buildScrollToTopFab(context), _buildBatchActionFab(context)],
          ),
        ),
      ),
    );
  }

  /// 下拉刷新：顶部三个分区 + 历史区 + 分类计数一起重拉。
  Future<void> _refreshAll() async {
    await Future.wait([
      _reloadPendingTasks(),
      _reloadFailedTasks(),
      _refreshHistory(),
      _reloadCategories(),
    ]);
  }

  /// header 中间的胶囊：普通模式是搜索框，多选模式换成「已选 N 条」。
  ///
  /// 两侧都是玻璃胶囊，走 [GlassCapsuleMorph] 单壳常驻、内容交接，
  /// 而不是两只胶囊硬切。
  Widget _buildCenterCapsule(BuildContext context) {
    return GlassCapsuleMorph(
      child: _isSelectionMode
          ? KeyedSubtree(
              key: const ValueKey('selection'),
              child: _buildSelectionSummary(context),
            )
          : KeyedSubtree(
              key: const ValueKey('search'),
              child: _buildSearchContent(context),
            ),
    );
  }

  /// 搜索胶囊的内容（无壳，玻璃壳由 [GlassCapsuleMorph] 提供）。
  Widget _buildSearchContent(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 14),
        Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: t.download.searchTasks,
              hintStyle: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // 有输入时右侧长出清空钮（跟输入框实时走，不等防抖）
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, _) => GlassGroupSlot(
            visible: value.text.isNotEmpty,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: t.common.clear,
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// 多选模式下中间胶囊的内容：已选数量。
  Widget _buildSelectionSummary(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 14),
        Icon(Icons.checklist, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t.common.selectedRecords(num: _selectedTaskIds.length),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  /// 右侧动作胶囊：[全部开始 · 全部暂停(宽屏)] 筛选(生效挂红点) · 多选
  /// [更多(管理分类 / 按日期删除，窄屏再收下全部开始 · 全部暂停)]。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    // 多选时「全部开始 / 全部暂停 / 更多」与当前语境无关，一并挤出胶囊
    final bool showBulkPlayback = isWide && !_isSelectionMode;

    return GlassButtonGroup(
      children: [
        GlassGroupSlot(
          visible: showBulkPlayback,
          child: GlassIconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: t.download.resumeAll,
            onPressed: () => DownloadService.to.resumeAll(),
          ),
        ),
        GlassGroupSlot(
          visible: showBulkPlayback,
          child: GlassIconButton(
            icon: const Icon(Icons.pause_outlined),
            tooltip: t.download.pauseAll,
            onPressed: () => DownloadService.to.pauseAll(),
          ),
        ),
        GlassIconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: t.searchFilter.filterSettings,
          // 状态 / 类型是收在弹窗里的条件，生效时用红点告诉用户「有东西在筛」。
          // 不挂 loading：这枚键自己的动作是「弹出筛选面板」，一瞬间的事；
          // 真正耗时的重查发生在列表里，由列表自己的加载指示器交代。
          showBadge: _hasSheetFilter,
          onPressed: _openFilterSheet,
        ),
        GlassIconButton(
          // 多选↔退出在同一按钮位上交叉过渡
          icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
          tooltip: _isSelectionMode
              ? t.common.exitEditMode
              : t.common.editMode,
          onPressed: _isSelectionMode ? _exitSelectionMode : _enterSelectionMode,
        ),
        GlassGroupSlot(
          visible: !_isSelectionMode,
          child: SizedBox(
            width: GlassTokens.groupIconButtonSize,
            height: GlassTokens.groupIconButtonSize,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, size: GlassTokens.iconSize),
              tooltip: t.download.moreOptions,
              position: PopupMenuPosition.under,
              // 往下挪一点，别压住玻璃胶囊本身
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case _menuActionManageCategory:
                    _openCategoryManagePage();
                  case _menuActionDeleteByDate:
                    _showDeleteByDateDialog();
                  case _menuActionResumeAll:
                    DownloadService.to.resumeAll();
                  case _menuActionPauseAll:
                    DownloadService.to.pauseAll();
                }
              },
              itemBuilder: (context) => [
                // 窄屏胶囊塞不下批量播放控制，收进这里
                if (!isWide) ...[
                  _buildMenuItem(
                    value: _menuActionResumeAll,
                    icon: Icons.play_arrow_outlined,
                    label: t.download.resumeAll,
                  ),
                  _buildMenuItem(
                    value: _menuActionPauseAll,
                    icon: Icons.pause_outlined,
                    label: t.download.pauseAll,
                  ),
                  const PopupMenuDivider(),
                ],
                _buildMenuItem(
                  value: _menuActionManageCategory,
                  icon: Icons.folder_outlined,
                  label: t.download.category.manageTitle,
                ),
                _buildMenuItem(
                  value: _menuActionDeleteByDate,
                  icon: Icons.auto_delete_outlined,
                  label: t.download.deleteByDate.menuTitle,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  void _openCategoryManagePage() => openDownloadCategoryManagePage(context);

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

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// 左下角多选操作按钮组：退出 / 清空所选 / 移至分类 / 删除。
  Widget _buildBatchActionFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return BatchActionFab(
      isMultiSelect: _isSelectionMode,
      selectedCount: _selectedTaskIds.length,
      heroTagPrefix: 'downloadList',
      onExit: _exitSelectionMode,
      onClear: () {
        setState(() {
          _selectedTaskIds.clear();
        });
      },
      customActionBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 移至分类
            FloatingActionButton.small(
              heroTag: 'batchMoveCategoryFAB_downloadList',
              onPressed: _moveSelectedToCategory,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              tooltip: t.download.category.moveTo,
              child: const Icon(Icons.drive_file_move_outline),
            ),
            const SizedBox(height: 8),
            // 删除
            FloatingActionButton.small(
              heroTag: 'batchDeleteFAB_downloadList',
              onPressed: _deleteSelectedTasks,
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              tooltip: t.common.delete,
              child: const Icon(Icons.delete),
            ),
          ],
        );
      },
    );
  }

  /// 状态 / 类型筛选是否生效（分类筛选有分类条直观呈现，不算在内）。
  bool get _hasSheetFilter =>
      _statusFilter != DownloadStatusFilter.all ||
      _typeFilter != DownloadTypeFilter.all;

  /// 是否存在任意筛选条件（用于区分「暂无任务」与「无匹配结果」）。
  bool get _hasAnyFilter =>
      _hasSheetFilter || _categoryFilter != 'all' || _searchQuery.isNotEmpty;

  /// 打开筛选弹窗：一次改完状态 + 类型再应用，不像原来两个下拉各触发一次重查。
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_DownloadFilterSelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DownloadFilterSheet(
        initial: _DownloadFilterSelection(
          status: _statusFilter,
          type: _typeFilter,
        ),
      ),
    );
    if (result == null || !mounted) return;
    if (result.status == _statusFilter && result.type == _typeFilter) return;
    setState(() {
      _statusFilter = result.status;
      _typeFilter = result.type;
    });
    _applyFilters();
  }

  void _clearFilters() {
    // 防抖里可能还压着一次「旧关键字」的重查，先作废，否则清完又被写回来
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = DownloadStatusFilter.all;
      _typeFilter = DownloadTypeFilter.all;
      _categoryFilter = 'all';
    });
    _applyFilters();
  }

  /// 切换当前分类筛选。
  void _onCategorySelected(String value) {
    if (_categoryFilter == value) return;
    setState(() => _categoryFilter = value);
    _applyFilters();
  }

  /// 重新加载分类列表与未分类计数；若当前选中分类已被删除则回退到「全部」。
  Future<void> _reloadCategories() async {
    try {
      final cats = await DownloadService.to.getAllCategories();
      final uncat = await DownloadService.to.getUncategorizedCount();
      if (!mounted) return;
      var nextFilter = _categoryFilter;
      final selectedCategoryGone =
          nextFilter != 'all' &&
          nextFilter != 'uncategorized' &&
          !cats.any((c) => c.id == nextFilter);
      // 选中「未分类」后又把所有分类删光时，「未分类」标签本身会从标签条上消失
      //（它只在有分类时才有意义），若不重置会留下一个点不掉的筛选，一并回到「全部」。
      final uncategorizedStrandedWhenStripHidden =
          nextFilter == 'uncategorized' && cats.isEmpty;
      if (selectedCategoryGone || uncategorizedStrandedWhenStripHidden) {
        nextFilter = 'all';
      }
      final filterChanged = nextFilter != _categoryFilter;
      setState(() {
        _categories = cats;
        _uncategorizedCount = uncat;
        _categoryFilter = nextFilter;
      });
      if (filterChanged) _applyFilters();
    } catch (_) {
      // 分类加载失败时静默处理，不影响主列表
    }
  }

  /// 批量「移至分类」：用已选任务打开移动弹窗，移动后退出多选。
  Future<void> _moveSelectedToCategory() async {
    if (_selectedTaskIds.isEmpty) return;
    final moved = await showMoveToCategorySheet(
      context,
      _selectedTaskIds.toList(),
    );
    if (moved == true) _exitSelectionMode();
  }

  /// 删除后就地移除对应行，尽量保留滚动位置（避免整列重载导致跳回顶部）。
  /// - 纯历史区删除：仅通知历史数据源就地刷新，不重建页面，滚动位置不变。
  /// - 涉及顶部「下载中/失败/等待」区或活跃任务：重建一次页面（这些区域本就在
  ///   视口上方，删除其元素时位置变化属预期）。
  void _removeTasksInPlace(List<String> ids) {
    final idSet = ids.toSet();
    // 记入墓碑：即使下方就地从 _historySource 移除，异步的历史刷新（尤其删除
    // “下载中”任务时，取消清理瞬时写回 paused 触发的刷新）仍可能把刚删的行重新
    // 读回。构建时据墓碑隐藏，保证删除后立刻消失、无需重进页面；刷新确认 DB 已
    // 无该行后会清除墓碑（见 _refreshHistory）。
    _deletedTombstones.addAll(idSet);

    final historyBefore = _historySource.length;
    _historySource.removeWhere((t) => idSet.contains(t.id));
    final historyChanged = _historySource.length != historyBefore;

    final topBefore = _pendingTasks.length + _failedTasks.length;
    _pendingTasks.removeWhere((t) => idSet.contains(t.id));
    _failedTasks.removeWhere((t) => idSet.contains(t.id));
    final topChanged =
        (_pendingTasks.length + _failedTasks.length) != topBefore;

    final pureHistoryChange = historyChanged && !topChanged;
    if (pureHistoryChange) {
      if (_historySource.isEmpty) {
        // 历史已空：走一次完整刷新让「空状态」正确显示（此时无内容，跳动无感）。
        _refreshHistory();
      } else {
        _historySource.setState();
      }
      return;
    }

    // 顶部「下载中/失败/等待」区或活跃任务受影响：需 setState 重建页面才能反映。
    // 重建会改变历史上方的内容高度，使历史滚动位置漂移；这里记录重建前的偏移与
    // 内容总高度，重建后按高度缩减量补偿，尽量让用户停留在原处。
    // （纯顶部删除时补偿精确；同时删顶部+历史时为近似，但不会跳回顶部。）
    if (historyChanged) _historySource.setState();
    if (!mounted) return;
    final hasClients = _scrollController.hasClients;
    final beforeOffset = hasClients ? _scrollController.offset : 0.0;
    final beforeMax = hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    setState(() {});
    if (hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final afterMax = _scrollController.position.maxScrollExtent;
        final shrink = beforeMax - afterMax; // 内容总高度缩减量 ≈ 被删元素总高
        if (shrink <= 0) return;
        final target = (beforeOffset - shrink).clamp(0.0, afterMax);
        if ((target - _scrollController.offset).abs() > 0.5) {
          _scrollController.jumpTo(target);
        }
      });
    }
  }

  /// 顶部分类标签条：管理入口 / 全部 / 未分类 / 各分类（带计数）。
  ///
  /// 标签本体是玻璃胶囊（选中态换成高亮底色），与 header 上的胶囊同族，
  /// 不再用 Material 的 ChoiceChip / ActionChip。
  Widget _buildCategoryStrip() {
    final t = slang.Translations.of(context);

    return SizedBox(
      height: _categoryStripHeight,
      child: Listener(
        // 鼠标悬浮在分类条上滚动滚轮时，把纵向滚轮增量转成横向滑动。
        // 仅当分类条确有横向可滚动空间时才接管事件，否则交还底层纵向列表。
        onPointerSignal: (event) {
          if (event is PointerScrollEvent &&
              _categoryStripController.hasClients) {
            final maxExtent = _categoryStripController.position.maxScrollExtent;
            if (maxExtent <= 0) return;
            final delta = event.scrollDelta.dy != 0
                ? event.scrollDelta.dy
                : event.scrollDelta.dx;
            GestureBinding.instance.pointerSignalResolver.register(event, (e) {
              if (!_categoryStripController.hasClients) return;
              final target = (_categoryStripController.offset + delta).clamp(
                0.0,
                _categoryStripController.position.maxScrollExtent,
              );
              _categoryStripController.jumpTo(target);
            });
          }
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            controller: _categoryStripController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 管理 / 新建入口放在最前：无分类时用更醒目的「管理分类」标签。
              _buildCategoryChip(
                label: _categories.isEmpty
                    ? t.download.category.manageTitle
                    : t.download.category.manage,
                icon: _categories.isEmpty
                    ? Icons.create_new_folder_outlined
                    : Icons.settings_outlined,
                selected: false,
                onTap: _openCategoryManagePage,
              ),
              _buildCategoryChip(
                label: t.common.all,
                selected: _categoryFilter == 'all',
                onTap: () => _onCategorySelected('all'),
              ),
              // 「未分类」仅在已有分类时才有意义（无分类时等同「全部」）。
              if (_categories.isNotEmpty)
                _buildCategoryChip(
                  label: t.download.category.uncategorized,
                  count: _uncategorizedCount,
                  selected: _categoryFilter == 'uncategorized',
                  onTap: () => _onCategorySelected('uncategorized'),
                ),
              for (final c in _categories)
                _buildCategoryChip(
                  label: c.title,
                  count: c.itemCount ?? 0,
                  selected: _categoryFilter == c.id,
                  onTap: () => _onCategorySelected(c.id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 单枚分类标签：玻璃胶囊，选中态换高亮底色（底色 / 文字色都带过渡，
  /// 切分类时是「同一枚标签亮起来」，不是瞬间换一块颜色）。
  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    int? count,
    IconData? icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final Color foreground = selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: GlassPressable(
          onTap: onTap,
          scale: 0.95,
          builder: (context, pressed) => AnimatedContainer(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            height: _categoryChipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected
                  ? GlassTokens.selectedHighlight(cs)
                  : (pressed ? GlassTokens.pressedFill(cs) : GlassTokens.fill(cs)),
              borderRadius: BorderRadius.circular(_categoryChipHeight / 2),
              border: Border.all(
                color: GlassTokens.stroke(cs),
                width: GlassTokens.strokeWidth,
              ),
              boxShadow: GlassTokens.shadow(cs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: foreground),
                  const SizedBox(width: 6),
                ],
                AnimatedDefaultTextStyle(
                  duration: GlassTokens.motionDuration,
                  curve: GlassTokens.motionCurve,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                  child: Text(count != null ? '$label · $count' : label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 搜索输入：防抖后再落到筛选上。
  ///
  /// 每次 [_applyFilters] 都是三条本地 DB 查询 + 一轮串行历史刷新，逐字符触发
  /// 既浪费查询，也让筛选钮的沙漏态一路抽搐。
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value == _searchQuery) return;
    _searchDebounce = Timer(_searchDebounceDelay, () {
      if (!mounted || value == _searchQuery) return;
      setState(() {
        _searchQuery = value;
      });
      _applyFilters();
    });
  }

  void _applyFilters() async {
    final statusFilterStr = switch (_statusFilter) {
      DownloadStatusFilter.all => 'all',
      DownloadStatusFilter.failed => 'failed',
      DownloadStatusFilter.downloaded => 'downloaded',
    };
    final typeFilterStr = switch (_typeFilter) {
      DownloadTypeFilter.all => 'all',
      DownloadTypeFilter.video => 'video',
      DownloadTypeFilter.gallery => 'gallery',
      DownloadTypeFilter.other => 'other',
    };

    // Show loading indicator
    setState(() {
      _isFilterLoading = true;
    });

    _historySource.updateFilters(
      searchQuery: _searchQuery,
      statusFilter: statusFilterStr,
      typeFilter: typeFilterStr,
      categoryFilter: _categoryFilter,
    );
    // 历史区域通过串行刷新触发（updateFilters 不再自行 refresh，避免并发）
    _refreshHistory();

    // Also filter the pending and failed tasks
    await _reloadPendingTasks();
    await _reloadFailedTasks();

    // Hide loading indicator
    if (mounted) {
      setState(() {
        _isFilterLoading = false;
      });
    }
  }

  /// Check if a task matches the current filter criteria
  bool _filterTask(DownloadTask task) {
    // Check if any filter is active
    final hasActiveFilter =
        _searchQuery.isNotEmpty ||
        _statusFilter != DownloadStatusFilter.all ||
        _typeFilter != DownloadTypeFilter.all ||
        _categoryFilter != 'all';

    // If no filter is active, show all
    if (!hasActiveFilter) return true;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      if (!task.fileName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
    }

    // Status filter - for active sections, we need different logic
    // 'all' shows everything, 'failed' shows only failed, 'downloaded' shows only completed
    switch (_statusFilter) {
      case DownloadStatusFilter.failed:
        if (task.status != DownloadStatus.failed) return false;
        break;
      case DownloadStatusFilter.downloaded:
        if (task.status != DownloadStatus.completed) return false;
        break;
      case DownloadStatusFilter.all:
        // Show all statuses
        break;
    }

    // Type filter
    switch (_typeFilter) {
      case DownloadTypeFilter.video:
        if (task.extData?.type != DownloadTaskExtDataType.video) return false;
        break;
      case DownloadTypeFilter.gallery:
        if (task.extData?.type != DownloadTaskExtDataType.gallery) return false;
        break;
      case DownloadTypeFilter.other:
        if (task.extData != null &&
            (task.extData!.type == DownloadTaskExtDataType.video ||
                task.extData!.type == DownloadTaskExtDataType.gallery)) {
          return false;
        }
        break;
      case DownloadTypeFilter.all:
        // Show all types
        break;
    }

    // Category filter
    switch (_categoryFilter) {
      case 'all':
        break;
      case 'uncategorized':
        if (task.categoryId != null) return false;
        break;
      default:
        if (task.categoryId != _categoryFilter) return false;
        break;
    }

    return true;
  }

  /// 构建空状态视图。
  /// - 存在搜索 / 筛选条件时：提示无匹配结果，并提供“清除筛选”入口。
  /// - 无任何任务时：提示暂无下载任务。
  Widget _buildEmptyState({required bool hasActiveFilter}) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilter ? Icons.search_off : Icons.download_done_outlined,
              size: 64 * DownloadUiScale.of(context),
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter
                  ? t.download.noMatchingTasks
                  : t.download.emptyTaskList,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilter) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: Text(t.download.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 单列列表：顶部「下载中 / 失败 / 等待」活跃区 + 底部无限滚动的历史区。
  ///
  /// [topPadding] 是玻璃 header 需要让出的高度——留白必须由列表自身的
  /// SliverPadding 提供，不能在外面套 Padding，否则内容滚不到 header 背后。
  Widget _buildSingleList(double topPadding) {
    // 跨分区去重：在状态切换的过渡窗口，同一任务可能同时存在于
    // _activeTasks（下载中）与 _pendingTasks/_failedTasks 的旧快照里。
    // 这里按“下载中 > 失败 > 等待中”的优先级保证每个任务最多只出现一次，
    // 修复“重试后失败任务与处理中任务同时显示”这类重复项问题。
    final seenIds = <String>{};

    // 历史区隐藏集合（每次构建重算）：活跃区(下载中/等待/失败)的全部 id ∪ 已删除
    // 墓碑。历史区是独立的 LoadingMoreSliverList，不参与上面的 seenIds 去重，故在
    // 此集中计算一份隐藏集合，构建历史行时据此跳过，修复两类“同一任务重复/残留”：
    //  1) 续传一个旧的暂停任务：它会进入 _activeTasks(下载中)，但 _historySource
    //     里可能仍残留它的暂停副本 → “下载中”与“暂停”两份同时显示；
    //  2) 删除“下载中”任务：取消清理会瞬时把它写成 paused 并被历史刷新读入，与删除
    //     的就地移除发生竞态而残留，需重进页面才消失。
    _historyHiddenIds = <String>{
      ...DownloadService.to.tasks.keys,
      for (final t in _pendingTasks) t.id,
      for (final t in _failedTasks) t.id,
      ..._deletedTombstones,
    };

    // 获取正在下载的任务 (apply filters)
    final downloadingTasks = DownloadService.to.tasks.values
        .where((task) => task.status == DownloadStatus.downloading)
        .where(_filterTask)
        .where((task) => seenIds.add(task.id))
        .toList();

    // Apply filters to failed and pending tasks (with cross-section dedup)
    final filteredFailedTasks = _failedTasks
        .where(_filterTask)
        .where((task) => seenIds.add(task.id))
        .toList();
    final filteredPendingTasks = _pendingTasks
        .where(_filterTask)
        .where((task) => seenIds.add(task.id))
        .toList();

    // 构建顶部活跃区域的 widgets
    final List<Widget> activeWidgets = [];

    // 添加正在下载的任务
    if (downloadingTasks.isNotEmpty) {
      activeWidgets.add(
        _buildSectionHeader(
          title: slang.t.download.downloading,
          count: downloadingTasks.length,
        ),
      );
      activeWidgets.addAll(
        downloadingTasks.map((task) => _buildTaskItem(task)),
      );
    }

    // 添加失败的任务（放在下载中之后、等待中之前，方便用户快速重试）
    if (filteredFailedTasks.isNotEmpty) {
      activeWidgets.add(
        _buildSectionHeader(
          title: slang.t.download.failed,
          count: filteredFailedTasks.length,
        ),
      );
      activeWidgets.addAll(
        filteredFailedTasks.map((task) => _buildTaskItem(task)),
      );
    }

    // 添加等待中的任务
    if (filteredPendingTasks.isNotEmpty) {
      activeWidgets.add(
        _buildSectionHeader(
          title: slang.t.download.waiting,
          count: filteredPendingTasks.length,
        ),
      );
      activeWidgets.addAll(
        filteredPendingTasks.map((task) => _buildTaskItem(task)),
      );
    }

    // 是否存在搜索 / 筛选条件（用于区分“暂无任务”与“无匹配结果”）
    final bool hasActiveFilter = _hasAnyFilter;
    // 顶部活跃区域是否有内容（决定 history 为空时是否接管为整页空状态）
    final bool hasActiveWidgets = activeWidgets.isNotEmpty;

    return LoadingMoreCustomScrollView(
      controller: _scrollController,
      // 空列表也要能下拉（否则筛不到结果时刷不了）
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // 顶部留白，为悬浮的玻璃 header（标题行 + 分类条）让出位置
        SliverPadding(padding: EdgeInsets.only(top: topPadding)),
        // 顶部活跃区域
        if (hasActiveWidgets)
          SliverList(delegate: SliverChildListDelegate(activeWidgets)),
        // 底部历史区域（无限滚动）
        LoadingMoreSliverList<DownloadTask>(
          SliverListConfig<DownloadTask>(
            itemBuilder: (context, task, index) {
              return _buildHistoryItemWithDateHeader(task, index);
            },
            sourceList: _historySource,
            padding: EdgeInsets.fromLTRB(
              0,
              0,
              0,
              computeBottomSafeInset(MediaQuery.of(context)) +
                  (_isSelectionMode ? 80 : 0), // 多选模式下增加底部padding防止遮挡
            ),
            indicatorBuilder: (context, status) {
              // history 为空时：若顶部活跃区域也无内容，则用自定义整页空状态
              // 接管（区分“暂无任务”/“无匹配结果”）；否则保持默认指示器。
              if (status == IndicatorStatus.empty &&
                  !hasActiveWidgets &&
                  !_isFilterLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(hasActiveFilter: hasActiveFilter),
                );
              }
              return myLoadingMoreIndicator(
                context,
                status,
                isSliver: true,
                loadingMoreBase: _historySource,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建历史任务条目，按天插入日期标题
  Widget _buildHistoryItemWithDateHeader(DownloadTask task, int index) {
    // 去重 / 删除残留防护：该 id 已在活跃区(下载中/等待/失败)展示或已被删除（墓碑），
    // 历史区不再渲染，避免重复或残留。返回收缩占位以保持其余行的索引稳定（日期标题
    // 改用“最近的可见行”比较，见下）。
    if (_historyHiddenIds.contains(task.id)) {
      return const SizedBox.shrink();
    }

    final currentDate = task.createdAt;

    // 如果没有创建时间，直接渲染任务
    if (currentDate == null) {
      return _buildTaskItem(task);
    }

    // 判断是否需要插入日期标题：与“前一个可见行”不是同一天则需要。必须跳过被隐藏的
    // 行——否则当某天的首行被隐藏时，同日的下一可见行会与隐藏行比较而漏掉日期标题。
    DateTime? prevVisibleDate;
    bool hasPrevVisible = false;
    for (int i = index - 1; i >= 0; i--) {
      final prev = _historySource[i];
      if (_historyHiddenIds.contains(prev.id)) continue;
      hasPrevVisible = true;
      prevVisibleDate = prev.createdAt;
      break;
    }

    final needHeader =
        !hasPrevVisible ||
        prevVisibleDate == null ||
        !_isSameDay(prevVisibleDate, currentDate);

    if (!needHeader) {
      return _buildTaskItem(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildDateHeader(currentDate), _buildTaskItem(task)],
    );
  }

  /// 构建日期标题
  Widget _buildDateHeader(DateTime date) {
    final textTheme = Theme.of(context).textTheme;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        dateString,
        style: textTheme.titleSmall?.copyWith(
          color: textTheme.bodySmall?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 判断是否为同一天
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildSectionHeader({required String title, required int count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('($count)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTaskItem(DownloadTask task) {
    Widget item;
    if (task.extData?.type == DownloadTaskExtDataType.video) {
      item = VideoDownloadTaskItem(task: task);
    } else if (task.extData?.type == DownloadTaskExtDataType.gallery) {
      item = GalleryDownloadTaskItem(task: task);
    } else {
      item = DefaultDownloadTaskItem(task: task);
    }

    if (_isSelectionMode) {
      final isSelected = _selectedTaskIds.contains(task.id);
      final scale = DownloadUiScale.of(context);
      return Stack(
        children: [
          // 列表项本身
          item,
          // 覆盖层 - 使用 Padding 和 ClipRRect 匹配 Card 的样式（margin 8/4, radius 12）
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: isSelected ? Colors.black38 : Colors.black12,
                  child: InkWell(
                    onTap: () => _toggleItemSelection(task.id),
                    child: Center(
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: 40 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // 使用 GestureDetector 代替 InkWell，避免水波纹超出卡片（因为卡片有 margin，外层 InkWell 会是矩形且包括 margin）
      // 内部 Item 已经有自己的点击反馈（WaterRipple）
      return GestureDetector(
        onLongPress: () {
          _enterSelectionMode();
          _toggleItemSelection(task.id);
        },
        child: item,
      );
    }
  }

  /// 根据 DownloadService 的任务状态版本，按需刷新等待中任务。
  /// 注意：加载进行中也要触发（通过置脏让本轮加载结束后重跑），
  /// 否则加载窗口内到来的状态变更会被永久丢弃。
  void _refreshPendingTasksIfNeeded() {
    final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
    if (!_isLoadingPendingTasks && currentVersion == _lastPendingVersion) {
      return;
    }
    _reloadPendingTasks();
  }

  /// 根据 DownloadService 的任务状态版本，按需刷新失败任务。
  void _refreshFailedTasksIfNeeded() {
    final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
    if (!_isLoadingFailedTasks && currentVersion == _lastFailedVersion) {
      return;
    }
    _reloadFailedTasks();
  }

  /// 重新加载等待中任务。
  /// 若加载期间状态版本又发生变化（或加载中被再次请求），结束后会自动重跑，
  /// 保证最终读到的是最新的数据库状态，杜绝“丢失更新”竞态。
  Future<void> _reloadPendingTasks() async {
    if (_isLoadingPendingTasks) {
      _pendingReloadDirty = true;
      return;
    }

    _isLoadingPendingTasks = true;
    try {
      do {
        _pendingReloadDirty = false;
        final versionAtLoad =
            DownloadService.to.taskStatusChangedNotifier.value;
        final tasks = await _downloadTaskRepository
            .getPendingTasksOrderByCreatedAtAsc();
        _lastPendingVersion = versionAtLoad;
        if (!mounted) return;
        setState(() {
          _pendingTasks = tasks;
        });
      } while (_pendingReloadDirty ||
          DownloadService.to.taskStatusChangedNotifier.value !=
              _lastPendingVersion);
    } catch (e) {
      // 读取等待中任务失败时，静默处理，避免影响主流程
    } finally {
      _isLoadingPendingTasks = false;
    }
  }

  /// 重新加载失败任务（语义同 [_reloadPendingTasks]，带版本重跑）。
  Future<void> _reloadFailedTasks() async {
    if (_isLoadingFailedTasks) {
      _failedReloadDirty = true;
      return;
    }

    _isLoadingFailedTasks = true;
    try {
      do {
        _failedReloadDirty = false;
        final versionAtLoad =
            DownloadService.to.taskStatusChangedNotifier.value;
        final tasks = await _downloadTaskRepository
            .getFailedTasksOrderByUpdatedAtDesc();
        _lastFailedVersion = versionAtLoad;
        if (!mounted) return;
        setState(() {
          _failedTasks = tasks;
        });
      } while (_failedReloadDirty ||
          DownloadService.to.taskStatusChangedNotifier.value !=
              _lastFailedVersion);
    } catch (e) {
      // 读取失败任务失败时，静默处理，避免影响主流程
    } finally {
      _isLoadingFailedTasks = false;
    }
  }

  /// 串行刷新历史区域（paused/completed）。
  /// 历史列表基于 LoadingMoreBase，并发 refresh 会相互 clear/addAll，
  /// 造成列表被清空或漏掉“刚完成”的任务（正是“下载完成后不刷新”的根因）。
  /// 这里串行化并在版本变化时重跑，确保最终读到最新状态。
  Future<void> _refreshHistory() async {
    if (!mounted) return;
    if (_isRefreshingHistory) {
      _historyRefreshDirty = true;
      return;
    }

    _isRefreshingHistory = true;
    try {
      do {
        _historyRefreshDirty = false;
        final versionAtRefresh =
            DownloadService.to.taskStatusChangedNotifier.value;
        await _historySource.refresh(true);
        _lastHistoryVersion = versionAtRefresh;
        if (!mounted) return;
      } while (_historyRefreshDirty ||
          DownloadService.to.taskStatusChangedNotifier.value !=
              _lastHistoryVersion);

      // 清理墓碑：刷新后历史源即来自 DB 的最新数据。若某个被删 id 已不在其中，说明
      // DB 行确已删除，墓碑使命完成，移除以防无界增长，并允许该 id 日后合法重现。
      // 反之若某次刷新恰好把“删除瞬时写回的 paused 行”读了进来（present 仍含该 id），
      // 墓碑会被保留，继续隐藏该残留行，直至下一次刷新读到干净的 DB。
      // 关键时序：取消清理写回 paused 发生在 deleteTask 删除 DB 行之前且被其 await，
      // 因此墓碑加入时 paused 写已成往事、不存在“清墓碑后又有写回”的竞态。
      if (_deletedTombstones.isNotEmpty) {
        if (_historySource.isEmpty) {
          _deletedTombstones.clear();
        } else {
          final present = <String>{for (final t in _historySource) t.id};
          _deletedTombstones.removeWhere((id) => !present.contains(id));
        }
      }
    } catch (e) {
      // 刷新历史失败时静默处理，避免影响主流程
    } finally {
      _isRefreshingHistory = false;
    }
  }
}

/// 历史任务数据源（paused/completed，不含failed），用于无限滚动加载
class _HistoryDownloadTasksSource extends LoadingMoreBase<DownloadTask>
    with LoadingMoreRefreshGuard<DownloadTask> {
  final DownloadTaskRepository _repository;

  bool _hasMore = true;
  bool _forceRefresh = false;

  // Filter state
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _typeFilter = 'all';
  String _categoryFilter = 'all';

  static const int pageSize = 20;

  _HistoryDownloadTasksSource(this._repository);

  @override
  bool get hasMore => _hasMore || _forceRefresh;

  /// Update filters and refresh the list
  void updateFilters({
    required String searchQuery,
    required String statusFilter,
    required String typeFilter,
    required String categoryFilter,
  }) {
    _searchQuery = searchQuery;
    _statusFilter = statusFilter;
    _typeFilter = typeFilter;
    _categoryFilter = categoryFilter;
    // 不在此处 refresh：由页面侧 _refreshHistory() 串行触发，
    // 避免与 worker 的历史刷新并发，导致列表被 clear/addAll 互相干扰。
  }

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _hasMore = true;
    // 本源用 length 当 offset，清空列表即把分页游标打回 0。
    clear();
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      _forceRefresh = !notifyStateChanged;
      try {
        return await super.refresh(notifyStateChanged);
      } finally {
        _forceRefresh = false;
      }
    });
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 游标快照必须在 await 之前取：await 期间可能发生 refresh()（它会
    // clear() 把 length 打回 0），否则回来的这一页会被追加到已清空的列表里。
    final int generation = currentGeneration;
    final int offset = length;
    try {
      // Use searchTasks when filters are active, otherwise use getHistoryTasks
      final bool hasFilters =
          _searchQuery.isNotEmpty ||
          _statusFilter != 'all' ||
          _typeFilter != 'all' ||
          _categoryFilter != 'all';

      List<DownloadTask> tasks;
      if (_statusFilter == 'failed') {
        // 失败任务由顶部 failed section 负责展示，历史列表保持为空避免重复。
        tasks = const <DownloadTask>[];
      } else if (hasFilters) {
        final historyStatusFilter = _statusFilter == 'all'
            ? 'history'
            : _statusFilter;
        tasks = await _repository.searchTasks(
          offset: offset,
          limit: pageSize,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          statusFilter: historyStatusFilter,
          typeFilter: _typeFilter,
          categoryFilter: _categoryFilter,
        );
      } else {
        tasks = await _repository.getHistoryTasks(
          offset: offset,
          limit: pageSize,
        );
      }

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      addAll(tasks);

      _hasMore = tasks.length >= pageSize;
      isSuccess = true;
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e(
        '加载下载历史任务失败',
        tag: '_HistoryDownloadTasksSource',
        error: e,
        stack: stack,
      );
    }
    return isSuccess;
  }
}

/// 状态 + 类型的筛选结果。
class _DownloadFilterSelection {
  const _DownloadFilterSelection({required this.status, required this.type});

  final DownloadStatusFilter status;
  final DownloadTypeFilter type;
}

/// 筛选弹窗：状态与类型一次改完再应用。
///
/// 原来这两项是 header 上并排的两个下拉菜单，各自触发一次全量重查；收进弹窗后
/// header 只留一枚带红点的筛选钮，条件是否生效一眼可见。
class _DownloadFilterSheet extends StatefulWidget {
  const _DownloadFilterSheet({required this.initial});

  final _DownloadFilterSelection initial;

  @override
  State<_DownloadFilterSheet> createState() => _DownloadFilterSheetState();
}

class _DownloadFilterSheetState extends State<_DownloadFilterSheet> {
  late DownloadStatusFilter _status = widget.initial.status;
  late DownloadTypeFilter _type = widget.initial.type;

  static const List<DownloadStatusFilter> _statuses = DownloadStatusFilter.values;
  static const List<DownloadTypeFilter> _types = DownloadTypeFilter.values;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: computeSheetBottomInset(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题行：标题 + 玻璃关闭圆钮
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.searchFilter.filterSettings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // 状态：所有状态 / 失败 / 已下载
          _buildSegmentRow(
            selectedIndex: _statuses.indexOf(_status),
            onChanged: (index) => setState(() => _status = _statuses[index]),
            items: [
              for (final s in _statuses)
                GlassSegmentItem(
                  label: _statusFilterLabel(s, t),
                  icon: Icon(_statusFilterIcon(s)),
                ),
            ],
          ),
          // 类型：所有类型 / 视频 / 图库 / 其他
          _buildSegmentRow(
            selectedIndex: _types.indexOf(_type),
            onChanged: (index) => setState(() => _type = _types[index]),
            items: [
              for (final type in _types)
                GlassSegmentItem(
                  label: _typeFilterLabel(type, t),
                  icon: Icon(_typeFilterIcon(type)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() {
                    _status = DownloadStatusFilter.all;
                    _type = DownloadTypeFilter.all;
                  }),
                  icon: const Icon(Icons.filter_alt_off),
                  label: Text(t.searchFilter.clearAll),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    _DownloadFilterSelection(status: _status, type: _type),
                  ),
                  child: Text(t.common.confirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 分段胶囊横向铺一行：段数固定但文案可长可短，胶囊自己能横向滚。
  Widget _buildSegmentRow({
    required List<GlassSegmentItem> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassSegmentedControl(
          items: items,
          selectedIndex: selectedIndex,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// 弹窗标题行：标题 + 玻璃关闭圆钮（全局统一约定，见 dialog-close-button-glass）。
///
/// [context] 传弹窗自己的 context，默认关闭动作就是把它 pop 掉（确认类弹窗因此
/// 拿到 null，等同「取消」）；需要别的关闭语义时传 [onClose]。
Widget _dialogTitleRow(
  BuildContext context,
  String title, {
  VoidCallback? onClose,
}) {
  return Row(
    children: [
      Expanded(child: Text(title)),
      GlassIconButton(
        standalone: true,
        icon: const Icon(Icons.close),
        tooltip: slang.Translations.of(context).common.close,
        onPressed: onClose ?? () => Navigator.of(context).pop(),
      ),
    ],
  );
}

IconData _statusFilterIcon(DownloadStatusFilter filter) {
  return switch (filter) {
    DownloadStatusFilter.all => Icons.filter_list,
    DownloadStatusFilter.failed => Icons.error_outline,
    DownloadStatusFilter.downloaded => Icons.check_circle_outline,
  };
}

IconData _typeFilterIcon(DownloadTypeFilter filter) {
  return switch (filter) {
    DownloadTypeFilter.all => Icons.category_outlined,
    DownloadTypeFilter.video => Icons.videocam_outlined,
    DownloadTypeFilter.gallery => Icons.photo_library_outlined,
    DownloadTypeFilter.other => Icons.more_horiz,
  };
}

String _statusFilterLabel(DownloadStatusFilter filter, slang.Translations t) {
  return switch (filter) {
    DownloadStatusFilter.all => t.download.allStatus,
    DownloadStatusFilter.failed => t.download.failed,
    DownloadStatusFilter.downloaded => t.download.downloaded,
  };
}

String _typeFilterLabel(DownloadTypeFilter filter, slang.Translations t) {
  return switch (filter) {
    DownloadTypeFilter.all => t.download.allTypes,
    DownloadTypeFilter.video => t.download.video,
    DownloadTypeFilter.gallery => t.download.gallery,
    DownloadTypeFilter.other => t.download.other,
  };
}

void showDownloadDetailDialog(BuildContext context, DownloadTask task) async {
  final t = slang.Translations.of(context);
  final theme = Theme.of(context);
  final size = MediaQuery.of(context).size;

  // 获取相关任务信息
  final DownloadService downloadService = DownloadService.to;
  DownloadTask? currentActiveTask = downloadService.getMemoryActiveTaskById(
    task.id,
  );
  DownloadTask? currentCompletedTask = await DownloadService.to.repository
      .getTaskById(task.id);
  List<String> currentQueueIds = downloadService.getQueueIds();

  // 构建完整的任务信息
  final Map<String, dynamic> fullTaskInfo = {
    'mainTask': task.toJson(),
    'currentActiveTask': currentActiveTask?.toJson(),
    'currentCompletedTask': currentCompletedTask?.toJson(),
    'queueStatus': {
      'isInQueue': currentQueueIds.contains(task.id),
      'queuePosition': currentQueueIds.indexOf(task.id),
      'totalQueueSize': currentQueueIds.length,
      'queueIds': currentQueueIds,
    },
  };

  final String prettyJson = const JsonEncoder.withIndent(
    '  ',
  ).convert(fullTaskInfo);

  showAppDialog(
    Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.8,
          maxWidth: size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Builder(
                builder: (dialogContext) => DefaultTextStyle.merge(
                  style: theme.textTheme.titleLarge,
                  child: _dialogTitleRow(
                    dialogContext,
                    t.download.downloadDetail,
                    onClose: () => AppService.tryPop(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      prettyJson,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final item = DataWriterItem();
                      item.add(Formats.plainText(prettyJson));
                      await SystemClipboard.instance?.write([item]);

                      if (context.mounted) {
                        showGlassToast(
                          t.download.copySuccess,
                          type: GlassToastType.success,
                        );
                      }
                    },
                    child: Text(t.download.copy),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// “按日期删除”弹窗的两种模式：日期区间 / 多少天以前。
enum _DeleteByDateMode { range, days }

/// 用户在“按日期删除”弹窗中确认后的选择结果。
///
/// [start]/[end] 为创建时间的闭区间边界（含端点），任一为 null 表示该侧不限。
/// - 日期区间模式：start=所选起始日 00:00:00，end=所选结束日 23:59:59。
/// - 多少天以前模式：start=null，end=（now - N 天）。
class _DateDeletionSelection {
  final DateTime? start;
  final DateTime? end;
  const _DateDeletionSelection({this.start, this.end});
}

/// “按日期删除”的条件选择弹窗。返回 [_DateDeletionSelection] 或 null（取消）。
class _DeleteByDateDialog extends StatefulWidget {
  const _DeleteByDateDialog();

  @override
  State<_DeleteByDateDialog> createState() => _DeleteByDateDialogState();
}

class _DeleteByDateDialogState extends State<_DeleteByDateDialog> {
  _DeleteByDateMode _mode = _DeleteByDateMode.range;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _daysController = TextEditingController(
    text: '30',
  );
  static const List<int> _dayPresets = [7, 30, 90, 180];

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 最大可输入的“多少天以前”。约 100 年，远小于 DateTime / Duration 的溢出边界，
  /// 防止超大值导致 Duration(days:) 溢出回绕成“未来”时间点而误删全部历史。
  static const int _maxDays = 36500;

  int? get _days {
    final v = int.tryParse(_daysController.text.trim());
    if (v == null || v < 1) return null;
    return v > _maxDays ? _maxDays : v;
  }

  bool get _canConfirm {
    if (_mode == _DeleteByDateMode.range) {
      return _startDate != null || _endDate != null;
    }
    return _days != null;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(2015),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _onConfirm() {
    final t = slang.Translations.of(context);
    if (_mode == _DeleteByDateMode.range) {
      final start = _startDate;
      final end = _endDate;
      if (start != null && end != null && start.isAfter(end)) {
        showGlassToast(
          t.download.deleteByDate.invalidRange,
          type: GlassToastType.warning,
        );
        return;
      }
      final normalizedStart = start == null
          ? null
          : DateTime(start.year, start.month, start.day);
      final normalizedEnd = end == null
          ? null
          : DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
      Navigator.pop(
        context,
        _DateDeletionSelection(start: normalizedStart, end: normalizedEnd),
      );
    } else {
      final days = _days;
      if (days == null) return;
      final cutoff = DateTime.now().subtract(Duration(days: days));
      Navigator.pop(context, _DateDeletionSelection(start: null, end: cutoff));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 底部 sheet 布局：顶部由 showModalBottomSheet 的 dragHandle 处理；
    // 底部用 SafeArea(top:false) + viewInsets.bottom 让内边距兼顾系统导航条与键盘。
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleLarge,
                    child: _dialogTitleRow(
                      context,
                      t.download.deleteByDate.dialogTitle,
                    ),
                  ),
                ),
                DropdownButtonFormField<_DeleteByDateMode>(
                  initialValue: _mode,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: _DeleteByDateMode.range,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.date_range, size: 20),
                          const SizedBox(width: 8),
                          Text(t.download.deleteByDate.modeRange),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: _DeleteByDateMode.days,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 20),
                          const SizedBox(width: 8),
                          Text(t.download.deleteByDate.modeDays),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _mode = value);
                  },
                ),
                const SizedBox(height: 16),
                if (_mode == _DeleteByDateMode.range) ...[
                  _buildDateTile(
                    label: t.download.deleteByDate.startDate,
                    value: _startDate,
                    notSet: t.download.deleteByDate.notSet,
                    onTap: () => _pickDate(isStart: true),
                    onClear: _startDate == null
                        ? null
                        : () => setState(() => _startDate = null),
                  ),
                  const SizedBox(height: 8),
                  _buildDateTile(
                    label: t.download.deleteByDate.endDate,
                    value: _endDate,
                    notSet: t.download.deleteByDate.notSet,
                    onTap: () => _pickDate(isStart: false),
                    onClear: _endDate == null
                        ? null
                        : () => setState(() => _endDate = null),
                  ),
                ] else ...[
                  Text(
                    t.download.deleteByDate.olderThanDaysHint(days: _days ?? 0),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // 限长 5 位，配合 _days 上的钳制，杜绝 Duration/DateTime 溢出。
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixText: t.download.deleteByDate.daysUnit,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _dayPresets.map((d) {
                      return ChoiceChip(
                        label: Text('$d'),
                        selected: _days == d,
                        onSelected: (_) {
                          setState(() {
                            _daysController.text = '$d';
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  t.download.deleteByDate.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t.common.cancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _canConfirm ? _onConfirm : null,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(t.common.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? value,
    required String notSet,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? _formatDate(value) : notSet,
          style: TextStyle(
            color: value != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 删除进度弹窗：进入即开始执行 [DownloadService.deleteTasksWithProgress]，
/// 完成后自动关闭并通过 [Navigator.pop] 返回 [DeleteTasksResult]。
/// 删除期间禁止返回键 / 点击外部关闭，避免中断耗时操作。
class _DeleteProgressDialog extends StatefulWidget {
  final List<DownloadTask> tasks;
  const _DeleteProgressDialog({required this.tasks});

  @override
  State<_DeleteProgressDialog> createState() => _DeleteProgressDialogState();
}

class _DeleteProgressDialogState extends State<_DeleteProgressDialog> {
  late final int _total = widget.tasks.length;
  int _done = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final result = await DownloadService.to.deleteTasksWithProgress(
      widget.tasks,
      onProgress: (done, total) {
        if (mounted) setState(() => _done = done);
      },
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: _total > 0 ? _done / _total : null),
            const SizedBox(height: 16),
            Text(t.download.deleteByDate.deleting(done: _done, total: _total)),
          ],
        ),
      ),
    );
  }
}
