import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/default_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/video_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';

class DownloadTaskListPage extends StatelessWidget {
  const DownloadTaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
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
          return const Center(
            child: Text('暂无下载任务'),
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
                        label: Text('清除全部失败任务 ($failedTasksCount)'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除失败任务'),
        content: const Text('确定要清除所有失败的下载任务吗？\n这些任务的文件也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await DownloadService.to.clearFailedTasks();
                if (context.mounted) {
                  showToastWidget(
                    const MDToastWidget(
                      message: '已清除所有失败任务',
                      type: MDToastType.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showToastWidget(
                    const MDToastWidget(
                      message: '清除失败任务时出错',
                      type: MDToastType.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}