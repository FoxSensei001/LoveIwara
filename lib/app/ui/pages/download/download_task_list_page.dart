import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/default_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/video_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/gallery_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class DownloadTaskListPage extends StatefulWidget {
  const DownloadTaskListPage({super.key});

  @override
  State<DownloadTaskListPage> createState() => _DownloadTaskListPageState();
}

class _DownloadTaskListPageState extends State<DownloadTaskListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

        final completedTasks = allTasks
            .where((task) => task.status == DownloadStatus.completed)
            .toList()
          ..sort((a, b) => -a.id.compareTo(b.id));

        return TabBarView(
          controller: _tabController,
          children: [
            // 进行中和失败的任务列表
            _buildTaskList(
              tasks: activeTasks,
              emptyText: t.download.errors.noActiveDownloadTask,
              showClearButton: true,
              clearButtonText: t.download.clearAllFailedTasks,
              onClearPressed: () => _showClearFailedTasksDialog(context),
            ),

            // 已完成的任务列表
            _buildTaskList(
              tasks: completedTasks,
              emptyText: t.download.errors.noCompletedDownloadTask,
              showClearButton: false,
              enableLoadMore: true,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTaskList({
    required List<DownloadTask> tasks,
    required String emptyText,
    bool showClearButton = false,
    String? clearButtonText,
    VoidCallback? onClearPressed,
    bool enableLoadMore = false,
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
                    label: Text('$clearButtonText (${tasks.length})'),
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (enableLoadMore &&
                  scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent * 0.9) {
                if (DownloadService.to.hasMoreCompletedTasks) {
                  DownloadService.to.loadMoreCompletedTasks();
                }
              }
              return true;
            },
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                if (task.extData?.type == 'video') {
                  return VideoDownloadTaskItem(task: task);
                } else if (task.extData?.type == 'gallery') {
                  return GalleryDownloadTaskItem(task: task);
                }
                return DefaultDownloadTaskItem(task: task);
              },
            ),
          ),
        ),
      ],
    );
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
