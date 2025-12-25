import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/default_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/video_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/gallery_download_task_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';

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

  // 用于监听任务状态变更
  int _lastStatusVersion = -1;

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

  @override
  void initState() {
    super.initState();
    _historySource = _HistoryDownloadTasksSource(_downloadTaskRepository);
    _reloadPendingTasks();
    _reloadFailedTasks();
  }

  @override
  void dispose() {
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
        title: _isSelectionMode
            ? Text(t.common.selectedRecords(num: _selectedTaskIds.length))
            : Text(t.download.downloadList),
        leading: _isSelectionMode
            ? null // 多选模式下隐藏返回按钮，退出按钮在左下角
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: t.common.batchDelete,
              onPressed: _enterSelectionMode,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content (列表在底层)
          Obx(() {
            // 监听任务状态变更
            final currentVersion =
                DownloadService.to.taskStatusChangedNotifier.value;
            if (currentVersion != _lastStatusVersion) {
              _lastStatusVersion = currentVersion;
              // 刷新顶部区域
              _refreshPendingTasksIfNeeded();
              _refreshFailedTasksIfNeeded();
              // 刷新历史区域
              Future.microtask(() {
                if (mounted) {
                  _historySource.refresh(true);
                }
              });
            }

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

  Widget _buildSingleList() {
    // 获取正在下载的任务 (apply filters)
    final downloadingTasks = DownloadService.to.tasks.values
        .where((task) => task.status == DownloadStatus.downloading)
        .where(_filterTask)
        .toList();

    // Apply filters to pending and failed tasks
    final filteredPendingTasks = _pendingTasks.where(_filterTask).toList();
    final filteredFailedTasks = _failedTasks.where(_filterTask).toList();

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

    return LoadingMoreCustomScrollView(
      controller: _scrollController,
      slivers: [
        // 顶部留白，为悬浮的 AppBar 和搜索栏留出空间
        SliverPadding(
          padding: EdgeInsets.only(top: appBarTotalHeight + filterBarHeight),
        ),
        // 顶部活跃区域
        if (activeWidgets.isNotEmpty)
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
            indicatorBuilder: (context, status) => myLoadingMoreIndicator(
              context,
              status,
              isSliver: true,
              loadingMoreBase: _historySource,
            ),
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
                        size: 40,
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

  /// 根据 DownloadService 的任务状态版本，按需刷新等待中任务
  void _refreshPendingTasksIfNeeded() {
    final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
    if (_isLoadingPendingTasks || currentVersion == _lastPendingVersion) {
      return;
    }
    _reloadPendingTasks();
  }

  /// 根据 DownloadService 的任务状态版本，按需刷新失败任务
  void _refreshFailedTasksIfNeeded() {
    final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
    if (_isLoadingFailedTasks || currentVersion == _lastFailedVersion) {
      return;
    }
    _reloadFailedTasks();
  }

  /// 重新加载等待中任务
  Future<void> _reloadPendingTasks() async {
    if (_isLoadingPendingTasks) return;

    _isLoadingPendingTasks = true;
    _lastPendingVersion = DownloadService.to.taskStatusChangedNotifier.value;

    try {
      final tasks = await _downloadTaskRepository
          .getPendingTasksOrderByCreatedAtAsc();
      if (!mounted) return;
      setState(() {
        _pendingTasks = tasks;
      });
    } catch (e) {
      // 读取等待中任务失败时，静默处理，避免影响主流程
    } finally {
      _isLoadingPendingTasks = false;
    }
  }

  /// 重新加载失败任务
  Future<void> _reloadFailedTasks() async {
    if (_isLoadingFailedTasks) return;

    _isLoadingFailedTasks = true;
    _lastFailedVersion = DownloadService.to.taskStatusChangedNotifier.value;

    try {
      final tasks = await _downloadTaskRepository
          .getFailedTasksOrderByUpdatedAtDesc();
      if (!mounted) return;
      setState(() {
        _failedTasks = tasks;
      });
    } catch (e) {
      // 读取失败任务失败时，静默处理，避免影响主流程
    } finally {
      _isLoadingFailedTasks = false;
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
    refresh(true);
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
      if (hasFilters) {
        tasks = await _repository.searchTasks(
          offset: length,
          limit: pageSize,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          statusFilter: _statusFilter,
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

  Get.dialog(
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
