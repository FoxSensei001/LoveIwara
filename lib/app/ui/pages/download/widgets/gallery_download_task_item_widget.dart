import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path;

class GalleryDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const GalleryDownloadTaskItem({super.key, required this.task});

  GalleryDownloadExtData? get galleryData {
    try {
      if (task.extData?.type == 'gallery') {
        return GalleryDownloadExtData.fromJson(task.extData!.data);
      }
    } catch (e) {
      LogUtils.e('解析图库下载任务数据失败', tag: 'GalleryDownloadTaskItem', error: e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final extData = galleryData;
    if (extData == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 预览图区域
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildPreviewImages(extData),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          extData.title ?? '未知标题',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // 作者信息
                        Row(
                          children: [
                            AvatarWidget(
                              avatarUrl: extData.authorAvatar,
                              defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                              radius: 12,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              extData.authorName ?? '未知作者',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 主要操作按钮
                  _buildMainActionButton(context),
                ],
              ),
              const SizedBox(height: 8),
              // 进度条和状态
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getStatusText()),
                            if (task.error != null)
                              Text(
                                task.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                      // 图库详情按钮
                      if (extData.id != null)
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () => NaviService.navigateToGalleryDetailPage(extData.id!),
                          tooltip: '查看图库详情',
                        ),
                      // 更多操作按钮
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () => _showMoreOptionsDialog(context),
                        tooltip: '更多操作',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImages(GalleryDownloadExtData extData) {
    if (extData.previewUrls.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 32),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // 主预览图
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: extData.previewUrls[0],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline),
              ),
            ),
          ),
          // 图片数量指示器
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${extData.totalImages}张',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context) {
    switch (task.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.pause),
          tooltip: '暂停',
          onPressed: () => DownloadService.to.pauseTask(task.id),
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: '继续',
          onPressed: () => DownloadService.to.resumeTask(task.id),
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: '重试',
          onPressed: () => DownloadService.to.retryTask(task.id),
        );
      case DownloadStatus.completed:
        return IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: '打开文件夹',
          onPressed: () => _showInFolder(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgressIndicator() {
    // 如果有总大小，显示具体进度
    if (task.totalBytes > 0) {
      return LinearProgressIndicator(
        value: task.downloadedBytes / task.totalBytes,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(task.status)),
      );
    }
    // 如果没有总大小但正在下载，显示不确定进度
    else if (task.status == DownloadStatus.downloading) {
      return const LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
    }
    // 其他状态（完成/失败）
    else {
      return LinearProgressIndicator(
        value: task.status == DownloadStatus.completed ? 1.0 : 0.0,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(task.status)),
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
    switch (task.status) {
      case DownloadStatus.pending:
        return '等待下载...';
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
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
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
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

    String sizeStr =
        size >= 10 ? size.round().toString() : size.toStringAsFixed(1);
    return '$sizeStr ${units[unitIndex]}';
  }

  void _showMoreOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.status == DownloadStatus.completed) ...[
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('在文件夹中显示'),
                onTap: () {
                  Navigator.pop(context);
                  _showInFolder(context);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除任务', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInFolder(BuildContext context) async {
    try {
      final filePath = _normalizePath(task.savePath);
      LogUtils.d('显示文件夹: $filePath', 'GalleryDownloadTaskItem');

      final directory = path.dirname(filePath);
      if (!await Directory(directory).exists()) {
        throw Exception('目录不存在');
      }

      if (Platform.isWindows) {
        final windowsPath = filePath.replaceAll('/', '\\');
        await Process.run('explorer.exe', ['/select,', windowsPath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      LogUtils.e('打开文件夹失败', tag: 'GalleryDownloadTaskItem', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打开文件夹失败')),
        );
      }
    }
  }

  String _normalizePath(String path) {
    if (Platform.isWindows) {
      return path.replaceAll('/', '\\');
    } else {
      return path.replaceAll('\\', '/');
    }
  }

  void _onTap(BuildContext context) {
    NaviService.navigateToGalleryDownloadTaskDetailPage(task.id);
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除下载任务'),
        content: const Text('确定要删除该下载任务吗?已下载的文件也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              AppService.tryPop();
              DownloadService.to.deleteTask(task.id);
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