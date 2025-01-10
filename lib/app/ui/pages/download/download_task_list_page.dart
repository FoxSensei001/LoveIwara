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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _completedTaskRepository = CompletedDownloadTaskRepository();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _completedTaskRepository.dispose();
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
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          padding: EdgeInsets.zero,
          tabs: [
            Tab(text: t.download.downloading),
            Tab(text: t.download.completed),
          ],
        ),
      ),
      body: Obx(() {
        final allTasks = DownloadService.to.tasks.values.toList();

        // 按状态分类任务
        final activeTasks = allTasks
            .where((task) =>
                task.status == DownloadStatus.downloading ||
                task.status == DownloadStatus.pending ||
                task.status == DownloadStatus.paused ||
                task.status == DownloadStatus.failed)
            .toList()
          ..sort((a, b) {
            final statusOrder = {
              DownloadStatus.downloading: 0,
              DownloadStatus.pending: 1,
              DownloadStatus.paused: 2,
              DownloadStatus.failed: 3,
            };
            return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
          });

        return TabBarView(
          controller: _tabController,
          children: [
            // 进行中和失败的任务列表
            _buildActiveTaskList(
              tasks: activeTasks,
              emptyText: t.download.errors.noActiveDownloadTask,
              showClearButton: true,
              clearButtonText: t.download.clearAllFailedTasks,
              onClearPressed: () => _showClearFailedTasksDialog(context),
            ),

            // 已完成的任务列表（使用分页加载）
            _buildCompletedTaskList(),
          ],
        );
      }),
    );
  }

  Widget _buildActiveTaskList({
    required List<DownloadTask> tasks,
    required String emptyText,
    bool showClearButton = false,
    String? clearButtonText,
    VoidCallback? onClearPressed,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(emptyText),
      );
    }

    return Column(
      children: [
        if (showClearButton && tasks.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onClearPressed,
                    icon: const Icon(Icons.delete_sweep),
                    label: Text(
                        '$clearButtonText (${tasks.where((task) => task.status == DownloadStatus.failed).length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskItem(task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedTaskList() {
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


 void showDownloadDetailDialog(BuildContext context, DownloadTask task) {
    final t = slang.Translations.of(context);

    // 获取相关任务信息
    final DownloadService downloadService = DownloadService.to;
    DownloadTask? currentActiveTask = downloadService.getActiveTaskById(task.id);
    DownloadTask? currentCompletedTask = downloadService.getCompletedTaskById(task.id);
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    );
  }
