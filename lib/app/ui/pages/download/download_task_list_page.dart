import 'dart:convert';

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
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:super_clipboard/super_clipboard.dart';

class DownloadTaskListPage extends StatefulWidget {
  const DownloadTaskListPage({super.key});

  @override
  State<DownloadTaskListPage> createState() => _DownloadTaskListPageState();
}

class _DownloadTaskListPageState extends State<DownloadTaskListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CompletedDownloadTaskRepository _completedTaskRepository;
  late FailedDownloadTaskRepository _failedTaskRepository;
  final DownloadTaskRepository _downloadTaskRepository = DownloadTaskRepository();
  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _failedScrollController = ScrollController();
  final ScrollController _completedScrollController = ScrollController();

  // 等待中任务仅从数据库加载，不驻留在 DownloadService 内存中
  List<DownloadTask> _pendingTasks = [];
  bool _isLoadingPendingTasks = false;
  int _lastPendingVersion = -1;

  // 暂停任务仅从数据库加载，不驻留在 DownloadService 内存中
  List<DownloadTask> _pausedTasks = [];
  bool _isLoadingPausedTasks = false;
  int _lastPausedVersion = -1;

  // 失败 / 完成任务列表的版本号缓存，避免在切换 Tab 时重复刷新
  int _lastFailedVersion = -1;
  int _lastCompletedVersion = -1;

  // Tab 数量
  int? _activeCount;
  int? _failedCount;
  int? _completedCount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _completedTaskRepository = CompletedDownloadTaskRepository();
    _failedTaskRepository = FailedDownloadTaskRepository();
    _loadTabCounts();
    
    // 监听tab切换，确保切换到已完成tab时刷新列表
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 2) {
        // 切换到已完成tab时，检查是否需要刷新
        final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
        if (currentVersion != _lastCompletedVersion) {
          _lastCompletedVersion = currentVersion;
          _completedTaskRepository.refresh(true);
        }
      }
      if (!_tabController.indexIsChanging && _tabController.index == 1) {
        // 切换到失败tab时，检查是否需要刷新
        final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
        if (currentVersion != _lastFailedVersion) {
          _lastFailedVersion = currentVersion;
          _failedTaskRepository.refresh(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _activeScrollController.dispose();
    _failedScrollController.dispose();
    _completedScrollController.dispose();
    _tabController.dispose();
    _completedTaskRepository.dispose();
    _failedTaskRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.download.downloadList),
        bottom: TabBar(
          controller: _tabController,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          padding: EdgeInsets.zero,
          tabs: [
            Tab(
              text: _buildTabTitle(
                t.download.downloading,
                _activeCount,
              ),
            ),
            Tab(
              text: _buildTabTitle(
                t.download.failed,
                _failedCount,
              ),
            ),
            Tab(
              text: _buildTabTitle(
                t.download.completed,
                _completedCount,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 下载中的任务列表（包括等待中的任务）
          _buildActiveTaskList(),
          // 失败的任务列表
          _buildFailedTaskList(),
          // 已完成的任务列表
          _buildCompletedTaskList(),
        ],
      ),
    );
  }

  String _buildTabTitle(String title, int? count) {
    if (count == null) {
      return title;
    }
    return '$title ($count)';
  }

  Widget _buildActiveTaskList() {
    return Obx(() {
      // 状态变更时刷新 Tab 数量
      if (DownloadService.to.taskStatusChangedNotifier.value > 0) {
        _loadTabCounts();
      }

      _refreshPendingTasksIfNeeded();
      _refreshPausedTasksIfNeeded();

      final downloadingTasks = DownloadService.to.tasks.values
          .where((task) => task.status == DownloadStatus.downloading)
          .toList();
      final pendingTasks = _pendingTasks;
      final pausedTasks = _pausedTasks;

      if (downloadingTasks.isEmpty && pendingTasks.isEmpty && pausedTasks.isEmpty) {
        return Center(
          child: Text(slang.t.download.errors.noActiveDownloadTask),
        );
      }

      return ListView(
        key: const PageStorageKey('download_active_list'),
        controller: _activeScrollController,
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          MediaQuery.of(context).padding.bottom,
        ),
        children: [
          if (downloadingTasks.isNotEmpty) ...[
            _buildSectionHeader(
              title: slang.t.download.downloading,
              count: downloadingTasks.length,
            ),
            ...downloadingTasks.map((task) => _buildTaskItem(task)),
          ],
          if (pendingTasks.isNotEmpty) ...[
            _buildSectionHeader(
              title: slang.t.download.waiting,
              count: pendingTasks.length,
            ),
            ...pendingTasks.map((task) => _buildTaskItem(task)),
          ],
          if (pausedTasks.isNotEmpty) ...[
            _buildSectionHeader(
              title: slang.t.download.paused,
              count: pausedTasks.length,
            ),
            ...pausedTasks.map((task) => _buildTaskItem(task)),
          ],
        ],
      );
    });
  }

  Widget _buildFailedTaskList() {
    return Obx(() {
      // 监听任务状态变更通知器，在状态变化时刷新仓库数据
      final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
      // 仅在版本号变更时刷新，如果当前 Tab 为「失败」则立即刷新，否则在切换到该tab时刷新
      if (currentVersion != _lastFailedVersion) {
        _lastFailedVersion = currentVersion;
        // 如果当前在失败tab，立即刷新；否则在切换到该tab时刷新
        if (_tabController.index == 1) {
          // 使用 Future.microtask 确保在下一帧刷新，避免在 build 过程中直接刷新
          Future.microtask(() {
            if (mounted && _tabController.index == 1) {
              _failedTaskRepository.refresh(true);
            }
          });
        }
      }

      return LoadingMoreCustomScrollView(
        key: const PageStorageKey('download_failed_list'),
        controller: _failedScrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showClearFailedTasksDialog(context),
                icon: const Icon(Icons.delete_sweep),
                label: Text(slang.t.download.clearAllFailedTasks),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          LoadingMoreSliverList<DownloadTask>(
            SliverListConfig<DownloadTask>(
              itemBuilder: (context, task, index) {
                return _buildTaskItem(task);
              },
              sourceList: _failedTaskRepository,
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                MediaQuery.of(context).padding.bottom,
              ),
              indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                context,
                status,
                isSliver: true,
                loadingMoreBase: _failedTaskRepository,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCompletedTaskList() {
    return Obx(() {
      // 监听任务状态变更通知器，在状态变化时刷新仓库数据
      final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
      // 仅在版本号变更时刷新，如果当前 Tab 为「已完成」则立即刷新，否则标记需要刷新
      if (currentVersion != _lastCompletedVersion) {
        _lastCompletedVersion = currentVersion;
        // 如果当前在已完成tab，立即刷新；否则在切换到该tab时刷新
        if (_tabController.index == 2) {
          // 使用 Future.microtask 确保在下一帧刷新，避免在 build 过程中直接刷新
          Future.microtask(() {
            if (mounted && _tabController.index == 2) {
              _completedTaskRepository.refresh(true);
            }
          });
        }
      }

      return LoadingMoreCustomScrollView(
        key: const PageStorageKey('download_completed_list'),
        controller: _completedScrollController,
        slivers: [
          LoadingMoreSliverList<DownloadTask>(
            SliverListConfig<DownloadTask>(
              itemBuilder: (context, task, index) {
                return _buildTaskItem(task);
              },
              sourceList: _completedTaskRepository,
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                MediaQuery.of(context).padding.bottom,
              ),
              indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                context,
                status,
                isSliver: true,
                loadingMoreBase: _completedTaskRepository,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(DownloadTask task) {
    if (task.extData?.type == DownloadTaskExtDataType.video) {
      return VideoDownloadTaskItem(task: task);
    } else if (task.extData?.type == DownloadTaskExtDataType.gallery) {
      return GalleryDownloadTaskItem(task: task);
    }
    return DefaultDownloadTaskItem(task: task);
  }

  void _showClearFailedTasksDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.download.clearAllFailedTasks),
        content: Text(t.download.clearAllFailedTasksConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await DownloadService.to.clearFailedTasks();
                if (context.mounted) {
                  showToastWidget(
                    MDToastWidget(
                      message: t.download.clearAllFailedTasksSuccess,
                      type: MDToastType.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showToastWidget(
                    MDToastWidget(
                      message: t.download.clearAllFailedTasksError,
                      type: MDToastType.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              t.common.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据 DownloadService 的任务状态版本，按需刷新等待中任务
  void _refreshPendingTasksIfNeeded() {
    final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
    if (_isLoadingPendingTasks || currentVersion == _lastPendingVersion) {
      return;
    }
    _isLoadingPendingTasks = true;
    _lastPendingVersion = currentVersion;

    _downloadTaskRepository
        .getPendingTasksOrderByCreatedAtAsc()
        .then((tasks) {
      if (!mounted) return;
      setState(() {
        _pendingTasks = tasks;
      });
    }).catchError((_) {
      // 读取等待中任务失败时，静默处理，避免影响主流程
    }).whenComplete(() {
      _isLoadingPendingTasks = false;
    });
  }

  /// 根据 DownloadService 的任务状态版本，按需刷新暂停任务
  void _refreshPausedTasksIfNeeded() {
    final currentVersion = DownloadService.to.taskStatusChangedNotifier.value;
    if (_isLoadingPausedTasks || currentVersion == _lastPausedVersion) {
      return;
    }
    _isLoadingPausedTasks = true;
    _lastPausedVersion = currentVersion;

    _downloadTaskRepository
        .getAllTasksByStatus(DownloadStatus.paused)
        .then((tasks) {
      if (!mounted) return;
      setState(() {
        _pausedTasks = tasks;
      });
    }).catchError((_) {
      // 读取暂停任务失败时，静默处理，避免影响主流程
    }).whenComplete(() {
      _isLoadingPausedTasks = false;
    });
  }

  /// 加载 Tab 数量（下载中/失败/完成）
  Future<void> _loadTabCounts() async {
    try {
      final service = DownloadService.to;
      final results = await Future.wait<int>([
        service.getActiveTasksCountForTab(),
        service.getFailedTasksCount(),
        service.getCompletedTasksCount(),
      ]);

      if (!mounted) return;
      setState(() {
        _activeCount = results[0];
        _failedCount = results[1];
        _completedCount = results[2];
      });
    } catch (_) {
      // 忽略统计失败，避免影响主流程
    }
  }
}


 void showDownloadDetailDialog(BuildContext context, DownloadTask task) async {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // 获取相关任务信息
    final DownloadService downloadService = DownloadService.to;
    DownloadTask? currentActiveTask = downloadService.getMemoryActiveTaskById(task.id);
    DownloadTask? currentCompletedTask = await DownloadService.to.repository.getTaskById(task.id);
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
      }
    };

    final String prettyJson = const JsonEncoder.withIndent('  ').convert(fullTaskInfo);

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
