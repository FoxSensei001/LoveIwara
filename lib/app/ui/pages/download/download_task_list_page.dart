import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/default_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/video_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/gallery_download_task_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// Status filter options for download tasks
enum DownloadStatusFilter { all, failed, downloaded }

/// Type filter options for download tasks
enum DownloadTypeFilter { all, video, gallery, other }

class DownloadTaskListPage extends StatefulWidget {
  const DownloadTaskListPage({super.key});

  @override
  State<DownloadTaskListPage> createState() => _DownloadTaskListPageState();
}

class _DownloadTaskListPageState extends State<DownloadTaskListPage> {
  final DownloadTaskRepository _downloadTaskRepository =
      DownloadTaskRepository();
  final ScrollController _scrollController = ScrollController();
  late _HistoryDownloadTasksSource _historySource;

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
        title: Text(t.common.confirmDelete),
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
      showToastWidget(
        MDToastWidget(
          message: t.download.errors.failedToLoadTasks,
          type: MDToastType.error,
        ),
      );
      return;
    }
    if (!mounted) return;

    if (tasks.isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.download.deleteByDate.noMatch,
          type: MDToastType.warning,
        ),
      );
      return;
    }

    // 2. 二次确认（明确告知数量与不可撤销）。
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.download.deleteByDate.confirmTitle),
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
      showToastWidget(
        MDToastWidget(
          message: t.download.deleteByDate.resultSuccess(count: result.deleted),
          type: MDToastType.success,
        ),
      );
    } else {
      showToastWidget(
        MDToastWidget(
          message: t.download.deleteByDate.resultPartial(
            deleted: result.deleted,
            skipped: result.skipped,
          ),
          type: MDToastType.warning,
        ),
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

    // 监听任务状态变更，将刷新（含 setState / DB 读）等副作用移出 build。
    _statusChangedWorker = ever(DownloadService.to.taskStatusChangedNotifier, (
      int currentVersion,
    ) {
      if (currentVersion == _lastStatusVersion) return;
      _lastStatusVersion = currentVersion;
      // 延后到帧回调后执行，避免在 build/通知阶段触发 setState。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // 刷新顶部区域
        _refreshPendingTasksIfNeeded();
        _refreshFailedTasksIfNeeded();
        // 刷新历史区域（串行 + 版本重跑，避免并发 refresh 漏掉刚完成的任务）
        _refreshHistory();
      });
    });
  }

  @override
  void dispose() {
    _statusChangedWorker?.dispose();
    _scrollController.dispose();
    _historySource.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // 普通模式下不再显示页面标题（按需求移除），仅在多选模式下显示已选数量。
        title: _isSelectionMode
            ? Text(t.common.selectedRecords(num: _selectedTaskIds.length))
            : null,
        leading: _isSelectionMode
            ? null // 多选模式下隐藏返回按钮，退出按钮在左下角
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        // AppBar 透明，需按主题显式设置状态栏图标明暗，否则会沿用上一页
        // （如视频详情页的白色图标），在浅色背景下看不见。
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.play_arrow_outlined),
              tooltip: t.download.resumeAll,
              onPressed: () => DownloadService.to.resumeAll(),
            ),
            IconButton(
              icon: const Icon(Icons.pause_outlined),
              tooltip: t.download.pauseAll,
              onPressed: () => DownloadService.to.pauseAll(),
            ),
            // “其他”菜单：批量删除 / 按日期删除，后续可扩展更多批量操作。
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: t.download.moreOptions,
              onSelected: (value) {
                switch (value) {
                  case 'batchDelete':
                    _enterSelectionMode();
                    break;
                  case 'deleteByDate':
                    _showDeleteByDateDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'batchDelete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_sweep_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(t.common.batchDelete),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'deleteByDate',
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_delete_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(t.download.deleteByDate.menuTitle),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: DownloadScaleScope(
        child: Stack(
          children: [
            // Main content (列表在底层)
            Obx(() {
              // 仅订阅任务状态变更以触发重建；实际的刷新副作用在
              // initState 注册的 worker 中处理（见 _statusChangedWorker）。
              DownloadService.to.taskStatusChangedNotifier.value;
              return _buildSingleList();
            }),
            // 顶部悬浮的搜索栏（透明背景，紧贴 AppBar 下方）
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterBar(),
                  // Loading indicator for filter
                  if (_isFilterLoading) const LinearProgressIndicator(),
                ],
              ),
            ),
            // 左下角操作按钮组
            BatchActionFab(
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
                return FloatingActionButton.small(
                  heroTag: 'batchDeleteFAB_downloadList',
                  onPressed: _deleteSelectedTasks,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  tooltip: t.common.delete,
                  child: const Icon(Icons.delete),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build the filter bar with search and dropdown filter icons
  Widget _buildFilterBar() {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasActiveFilter =
        _statusFilter != DownloadStatusFilter.all ||
        _typeFilter != DownloadTypeFilter.all;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      color: Colors.transparent,
      child: Row(
        children: [
          // Search bar (用 Flexible 配合 AnimatedContainer 实现宽度动画)
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.download.searchTasks,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 4),
          // Clear filters button with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: hasActiveFilter
                  ? IconButton(
                      key: const ValueKey('clear_filter'),
                      icon: Icon(
                        Icons.filter_alt_off,
                        color: colorScheme.error,
                      ),
                      tooltip: t.download.clearFilters,
                      onPressed: _clearFilters,
                    )
                  : const SizedBox.shrink(key: ValueKey('no_filter')),
            ),
          ),
          // Status filter dropdown - 根据状态显示不同图标
          PopupMenuButton<DownloadStatusFilter>(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _getStatusIcon(_statusFilter),
                key: ValueKey(_statusFilter),
                color: _statusFilter != DownloadStatusFilter.all
                    ? colorScheme.primary
                    : null,
              ),
            ),
            tooltip: t.download.statusLabel(
              label: _getStatusLabel(_statusFilter, t),
            ),
            onSelected: (value) {
              setState(() {
                _statusFilter = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              _buildFilterMenuItem(
                value: DownloadStatusFilter.all,
                label: t.download.allStatus,
                icon: Icons.filter_list,
                isSelected: _statusFilter == DownloadStatusFilter.all,
              ),
              _buildFilterMenuItem(
                value: DownloadStatusFilter.failed,
                label: t.download.failed,
                icon: Icons.error_outline,
                isSelected: _statusFilter == DownloadStatusFilter.failed,
              ),
              _buildFilterMenuItem(
                value: DownloadStatusFilter.downloaded,
                label: t.download.downloaded,
                icon: Icons.check_circle_outline,
                isSelected: _statusFilter == DownloadStatusFilter.downloaded,
              ),
            ],
          ),
          // Type filter dropdown - 根据类型显示不同图标
          PopupMenuButton<DownloadTypeFilter>(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _getTypeIcon(_typeFilter),
                key: ValueKey(_typeFilter),
                color: _typeFilter != DownloadTypeFilter.all
                    ? colorScheme.primary
                    : null,
              ),
            ),
            tooltip: t.download.typeLabel(label: _getTypeLabel(_typeFilter, t)),
            onSelected: (value) {
              setState(() {
                _typeFilter = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              _buildTypeFilterMenuItem(
                value: DownloadTypeFilter.all,
                label: t.download.allTypes,
                icon: Icons.category_outlined,
                isSelected: _typeFilter == DownloadTypeFilter.all,
              ),
              _buildTypeFilterMenuItem(
                value: DownloadTypeFilter.video,
                label: t.download.video,
                icon: Icons.videocam_outlined,
                isSelected: _typeFilter == DownloadTypeFilter.video,
              ),
              _buildTypeFilterMenuItem(
                value: DownloadTypeFilter.gallery,
                label: t.download.gallery,
                icon: Icons.photo_library_outlined,
                isSelected: _typeFilter == DownloadTypeFilter.gallery,
              ),
              _buildTypeFilterMenuItem(
                value: DownloadTypeFilter.other,
                label: t.download.other,
                icon: Icons.more_horiz,
                isSelected: _typeFilter == DownloadTypeFilter.other,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取状态筛选的图标
  IconData _getStatusIcon(DownloadStatusFilter filter) {
    return switch (filter) {
      DownloadStatusFilter.all => Icons.filter_list,
      DownloadStatusFilter.failed => Icons.error_outline,
      DownloadStatusFilter.downloaded => Icons.check_circle_outline,
    };
  }

  /// 获取类型筛选的图标
  IconData _getTypeIcon(DownloadTypeFilter filter) {
    return switch (filter) {
      DownloadTypeFilter.all => Icons.category_outlined,
      DownloadTypeFilter.video => Icons.videocam_outlined,
      DownloadTypeFilter.gallery => Icons.photo_library_outlined,
      DownloadTypeFilter.other => Icons.more_horiz,
    };
  }

  PopupMenuItem<DownloadStatusFilter> _buildFilterMenuItem({
    required DownloadStatusFilter value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (isSelected)
            Icon(
              Icons.check,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  PopupMenuItem<DownloadTypeFilter> _buildTypeFilterMenuItem({
    required DownloadTypeFilter value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (isSelected)
            Icon(
              Icons.check,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  String _getStatusLabel(DownloadStatusFilter filter, slang.Translations t) {
    return switch (filter) {
      DownloadStatusFilter.all => t.common.all,
      DownloadStatusFilter.failed => t.download.failed,
      DownloadStatusFilter.downloaded => t.download.downloaded,
    };
  }

  String _getTypeLabel(DownloadTypeFilter filter, slang.Translations t) {
    return switch (filter) {
      DownloadTypeFilter.all => t.common.all,
      DownloadTypeFilter.video => t.download.video,
      DownloadTypeFilter.gallery => t.download.gallery,
      DownloadTypeFilter.other => t.download.other,
    };
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = DownloadStatusFilter.all;
      _typeFilter = DownloadTypeFilter.all;
    });
    _applyFilters();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _applyFilters();
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
        _typeFilter != DownloadTypeFilter.all;

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

  Widget _buildSingleList() {
    // 跨分区去重：在状态切换的过渡窗口，同一任务可能同时存在于
    // _activeTasks（下载中）与 _pendingTasks/_failedTasks 的旧快照里。
    // 这里按“下载中 > 失败 > 等待中”的优先级保证每个任务最多只出现一次，
    // 修复“重试后失败任务与处理中任务同时显示”这类重复项问题。
    final seenIds = <String>{};

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

    // 搜索栏高度 (padding + content + border)
    const filterBarHeight = 56.0;
    // AppBar 高度 + 状态栏高度
    final appBarTotalHeight =
        kToolbarHeight + MediaQuery.of(context).padding.top;

    // 是否存在搜索 / 筛选条件（用于区分“暂无任务”与“无匹配结果”）
    final bool hasActiveFilter =
        _searchQuery.isNotEmpty ||
        _statusFilter != DownloadStatusFilter.all ||
        _typeFilter != DownloadTypeFilter.all;
    // 顶部活跃区域是否有内容（决定 history 为空时是否接管为整页空状态）
    final bool hasActiveWidgets = activeWidgets.isNotEmpty;

    return LoadingMoreCustomScrollView(
      controller: _scrollController,
      slivers: [
        // 顶部留白，为悬浮的 AppBar 和搜索栏留出空间
        SliverPadding(
          padding: EdgeInsets.only(top: appBarTotalHeight + filterBarHeight),
        ),
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
              MediaQuery.of(context).padding.bottom +
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
    final currentDate = task.createdAt;

    // 如果没有创建时间，直接渲染任务
    if (currentDate == null) {
      return _buildTaskItem(task);
    }

    // 判断是否需要插入日期标题：列表第一个元素，或与前一个元素不是同一天
    bool needHeader = false;
    if (index == 0) {
      needHeader = true;
    } else {
      final prevTask = _historySource[index - 1];
      final prevDate = prevTask.createdAt;
      if (prevDate == null || !_isSameDay(prevDate, currentDate)) {
        needHeader = true;
      }
    }

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
      padding: const EdgeInsets.all(16),
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
    } catch (e) {
      // 刷新历史失败时静默处理，避免影响主流程
    } finally {
      _isRefreshingHistory = false;
    }
  }
}

/// 历史任务数据源（paused/completed，不含failed），用于无限滚动加载
class _HistoryDownloadTasksSource extends LoadingMoreBase<DownloadTask> {
  final DownloadTaskRepository _repository;

  bool _hasMore = true;
  bool _forceRefresh = false;

  // Filter state
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _typeFilter = 'all';

  static const int pageSize = 20;

  _HistoryDownloadTasksSource(this._repository);

  @override
  bool get hasMore => _hasMore || _forceRefresh;

  /// Update filters and refresh the list
  void updateFilters({
    required String searchQuery,
    required String statusFilter,
    required String typeFilter,
  }) {
    _searchQuery = searchQuery;
    _statusFilter = statusFilter;
    _typeFilter = typeFilter;
    // 不在此处 refresh：由页面侧 _refreshHistory() 串行触发，
    // 避免与 worker 的历史刷新并发，导致列表被 clear/addAll 互相干扰。
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _forceRefresh = !notifyStateChanged;
    clear();
    final bool result = await super.refresh(notifyStateChanged);
    _forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      // Use searchTasks when filters are active, otherwise use getHistoryTasks
      final bool hasFilters =
          _searchQuery.isNotEmpty ||
          _statusFilter != 'all' ||
          _typeFilter != 'all';

      List<DownloadTask> tasks;
      if (_statusFilter == 'failed') {
        // 失败任务由顶部 failed section 负责展示，历史列表保持为空避免重复。
        tasks = const <DownloadTask>[];
      } else if (hasFilters) {
        final historyStatusFilter = _statusFilter == 'all'
            ? 'history'
            : _statusFilter;
        tasks = await _repository.searchTasks(
          offset: length,
          limit: pageSize,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          statusFilter: historyStatusFilter,
          typeFilter: _typeFilter,
        );
      } else {
        tasks = await _repository.getHistoryTasks(
          offset: length,
          limit: pageSize,
        );
      }

      addAll(tasks);

      _hasMore = tasks.length >= pageSize;
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                t.download.downloadDetail,
                style: theme.textTheme.titleLarge,
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
                        showToastWidget(
                          MDToastWidget(
                            message: t.download.copySuccess,
                            type: MDToastType.success,
                          ),
                        );
                      }
                    },
                    child: Text(t.download.copy),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => AppService.tryPop(),
                    child: Text(t.common.close),
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
        showToastWidget(
          MDToastWidget(
            message: t.download.deleteByDate.invalidRange,
            type: MDToastType.warning,
          ),
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
                  child: Text(
                    t.download.deleteByDate.dialogTitle,
                    style: Theme.of(context).textTheme.titleLarge,
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
