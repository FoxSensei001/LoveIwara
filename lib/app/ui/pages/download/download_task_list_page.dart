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
class DownloadTaskListPage extends StatelessWidget {
  const DownloadTaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.download.downloadList),
      ),
      body: Obx(() {
        final tasks = DownloadService.to.tasks.values.toList()
          ..sort((a, b) {
            // 首先按状态排序：下载中 > 等待中 > 暂停 > 失败 > 已完成
            final statusOrder = {
              DownloadStatus.downloading: 0,
              DownloadStatus.pending: 1,
              DownloadStatus.paused: 2,
              DownloadStatus.failed: 3,
              DownloadStatus.completed: 4,
            };

            final statusCompare =
                statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
            if (statusCompare != 0) return statusCompare;

            // 状态相同时
            return -a.id.compareTo(b.id);
          });

        // 计算失败的任务数量
        final failedTasksCount = tasks.where((task) => task.status == DownloadStatus.failed).length;

        if (tasks.isEmpty) {
          return Center(
            child: Text(t.download.errors.noDownloadTask),
          );
        }

        return Column(
          children: [
            // 清除失败任务按钮
            if (failedTasksCount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showClearFailedTasksDialog(context),
                        icon: const Icon(Icons.delete_sweep),
                        label: Text('${t.download.clearAllFailedTasks} ($failedTasksCount)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // 任务列表
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent * 0.9) {
                    // 当滚动到接近底部时，加载更多已完成的任务
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
      }),
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