import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_service.dart';

class DownloadTaskListPage extends StatelessWidget {
  const DownloadTaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
      ),
      body: Obx(() {
        final tasks = DownloadService.to.tasks.values.toList();
        
        if(tasks.isEmpty) {
          return const Center(
            child: Text('暂无下载任务'),
          );
        }
        
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return DownloadTaskItem(task: task);
          },
        );
      }),
    );
  }
}

class DownloadTaskItem extends StatelessWidget {
  final DownloadTask task;
  
  const DownloadTaskItem({super.key, required this.task});
  
  @override 
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(task.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 4),
            Text(_getStatusText()),
            if(task.error != null)
              Text(
                task.error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (task.status == DownloadStatus.downloading) {
      if (task.totalBytes > 0) {
        return LinearProgressIndicator(
          value: task.downloadedBytes / task.totalBytes,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        );
      } else {
        return const LinearProgressIndicator(
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        );
      }
    } else {
      return LinearProgressIndicator(
        value: task.status == DownloadStatus.completed ? 1.0 : 0.0,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          _getProgressColor(task.status),
        ),
      );
    }
  }

  Color _getProgressColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.paused:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch(task.status) {
      case DownloadStatus.pending:
        return '等待下载...';
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          return '下载中 $downloaded/$total ($progress%) • ${speed}MB/s';
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          return '下载中 $downloaded • ${speed}MB/s';
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          return '已暂停 • $downloaded/$total ($progress%)';
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          return '已暂停 • 已下载 $downloaded';
        }
      case DownloadStatus.completed:
        final size = _formatFileSize(task.downloadedBytes);
        return '下载完成 • $size';
      case DownloadStatus.failed:
        return '下载失败';
    }
  }

  String _formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    String sizeStr = size >= 10 ? size.round().toString() : size.toStringAsFixed(1);
    return '$sizeStr ${units[unitIndex]}';
  }

  String _formatRemainingTime(DownloadTask task) {
    if (task.speed == 0) return '--:--';
    final remainingBytes = task.totalBytes - task.downloadedBytes;
    final remainingSeconds = remainingBytes ~/ task.speed;
    if (remainingSeconds < 60) return '${remainingSeconds}秒';
    if (remainingSeconds < 3600) {
      final minutes = remainingSeconds ~/ 60;
      final seconds = remainingSeconds % 60;
      return '${minutes}分${seconds}秒';
    }
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    return '${hours}时${minutes}分';
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(task.status == DownloadStatus.downloading)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => DownloadService.to.pauseTask(task.id),
          )
        else if(task.status == DownloadStatus.paused)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => DownloadService.to.resumeTask(task.id),
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmDialog(context),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除下载任务'),
        content: const Text('确定要删除该下载任务吗?已下载的文件也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              DownloadService.to.deleteTask(task.id);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 