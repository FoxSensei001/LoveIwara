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
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
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
  late PausedDownloadTaskRepository _pausedTaskRepository;
  late FailedDownloadTaskRepository _failedTaskRepository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _completedTaskRepository = CompletedDownloadTaskRepository();
    _pausedTaskRepository = PausedDownloadTaskRepository();
    _failedTaskRepository = FailedDownloadTaskRepository();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _completedTaskRepository.dispose();
    _pausedTaskRepository.dispose();
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
            Tab(text: t.download.downloading),
            Tab(text: t.download.paused),
            Tab(text: t.download.failed),
            Tab(text: t.download.completed),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 下载中的任务列表（包括等待中的任务）
          _buildActiveTaskList(),
          // 暂停的任务列表
          _buildPausedTaskList(),
          // 失败的任务列表
          _buildFailedTaskList(),
          // 已完成的任务列表
          _buildCompletedTaskList(),
        ],
      ),
    );
  }

  Widget _buildActiveTaskList() {
    return Obx(() {
      final activeTasks = DownloadService.to.tasks.values.toList()
        ..sort((a, b) {
          final statusOrder = {
            DownloadStatus.downloading: 0,
            DownloadStatus.pending: 1,
            DownloadStatus.completed: 2,
            DownloadStatus.failed: 3,
            DownloadStatus.paused: 4,
          };
          return (statusOrder[a.status] ?? 999).compareTo(statusOrder[b.status] ?? 999);
        });

      if (activeTasks.isEmpty) {
        return Center(
          child: Text(slang.t.download.errors.noActiveDownloadTask),
        );
      }

      final downloadingTasks = activeTasks
          .where((task) => task.status == DownloadStatus.downloading)
          .toList();
      final pendingTasks =
          activeTasks.where((task) => task.status == DownloadStatus.pending).toList();

      return ListView(
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
        ],
      );
    });
  }

  Widget _buildPausedTaskList() {
    return Obx(() {
      // 监听任务状态变更通知器
      if (DownloadService.to.taskStatusChangedNotifier.value > 0) {
        _pausedTaskRepository.refresh(true);
      }

      return LoadingMoreCustomScrollView(
        slivers: [
          LoadingMoreSliverList<DownloadTask>(
            SliverListConfig<DownloadTask>(
              itemBuilder: (context, task, index) {
                return _buildTaskItem(task);
              },
              sourceList: _pausedTaskRepository,
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
                loadingMoreBase: _pausedTaskRepository,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFailedTaskList() {
    return Obx(() {
      // 监听任务状态变更通知器
      if (DownloadService.to.taskStatusChangedNotifier.value > 0) {
        _failedTaskRepository.refresh(true);
      }

      return LoadingMoreCustomScrollView(
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
      // 监听任务状态变更通知器
      if (DownloadService.to.taskStatusChangedNotifier.value > 0) {
        _completedTaskRepository.refresh(true);
      }

      return LoadingMoreCustomScrollView(
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
}


 void showDownloadDetailDialog(BuildContext context, DownloadTask task) async {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

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
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AlertDialog(
            title: Text(t.download.downloadDetail),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                  ],
                ),
              ),
            ),
            actions: [
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
              TextButton(
                onPressed: () => AppService.tryPop(),
                child: Text(t.common.close),
              ),
            ],
          ),
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
