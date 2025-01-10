import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class GalleryDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const GalleryDownloadTaskItem({super.key, required this.task});

  GalleryDownloadExtData? get galleryData {
    try {
      if (task.extData?.type == DownloadTaskExtDataType.gallery) {
        return GalleryDownloadExtData.fromJson(task.extData!.data);
      }
    } catch (e) {
      LogUtils.e('解析图库下载任务数据失败', tag: 'GalleryDownloadTaskItem', error: e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildPreviewImages(context, extData),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          extData.title ?? t.download.errors.unknown,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // 作者信息
                        Row(
                          children: [
                            MouseRegion(
                              cursor: extData.authorUsername != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                              child: GestureDetector(
                                onTap: extData.authorUsername != null
                                    ? () => NaviService.navigateToAuthorProfilePage(extData.authorUsername!)
                                    : null,
                                child: AvatarWidget(
                                  avatarUrl: extData.authorAvatar,
                                  defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                                  radius: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                extData.authorName ?? t.download.errors.unknown,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.error != null)
                              Text(
                                task.error!,
                                style: const TextStyle(color: Colors.red),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      // 图库详情按钮
                      if (extData.id != null)
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () => NaviService.navigateToGalleryDetailPage(extData.id!),
                          tooltip: t.download.viewGalleryDetail,
                        ),
                      // 更多操作按钮
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () => _showMoreOptionsDialog(context),
                        tooltip: t.download.moreOptions,
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

  Widget _buildPreviewImages(BuildContext context, GalleryDownloadExtData extData) {
    final t = slang.Translations.of(context);
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
                t.download.totalImageNums(num: extData.totalImages),
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
    final t = slang.Translations.of(context);
    switch (task.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.pause),
          tooltip: t.download.pause,
          onPressed: () => DownloadService.to.pauseTask(task.id),
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: t.download.resume,
          onPressed: () => DownloadService.to.resumeTask(task.id),
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: t.common.retry,
          onPressed: () => DownloadService.to.retryTask(task.id),
        );
      case DownloadStatus.completed:
        return IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: t.download.openFile,
          onPressed: () => _showInFolder(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStatusText(BuildContext context) {
    final t = slang.Translations.of(context);
    switch (task.status) {
      case DownloadStatus.pending:
        return t.download.waitingForDownload;
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          // return '下载中 $downloaded/$total ($progress%) • ${speed}MB/s';
          return t.download.downloadingProgressForVideoTask(downloaded: downloaded, total: total, progress: progress, speed: speed);
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          // return '下载中 $downloaded • ${speed}MB/s';
          return t.download.downloadingOnlyDownloadedAndSpeed(downloaded: downloaded, speed: speed);
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          // return '已暂停 • $downloaded/$total ($progress%)';
          return t.download.pausedForDownloadedAndTotal(downloaded: downloaded, total: total, progress: progress);
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          // return '已暂停 • 已下载 $downloaded';
          return t.download.pausedAndDownloaded(downloaded: downloaded);
        }
      case DownloadStatus.completed:
        final size = _formatFileSize(task.downloadedBytes);
        // return '下载完成 • $size';
        return t.download.downloadedWithSize(size: size);
      case DownloadStatus.failed:
        return t.download.errors.downloadFailed;
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
    final t = slang.Translations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 查看下载详情
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(t.download.downloadDetail),
              onTap: () => showDownloadDetailDialog(context, task),
            ),
            if (task.status == DownloadStatus.completed) ...[
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(t.download.showInFolder),
                onTap: () {
                  Navigator.pop(context);
                  _showInFolder(context);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(t.download.deleteTask, style: const TextStyle(color: Colors.red)),
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
    final t = slang.Translations.of(context);
    try {
      final filePath = _normalizePath(task.savePath);
      LogUtils.d('显示文件夹: $filePath', 'GalleryDownloadTaskItem');

      final directory = path.dirname(filePath);
      if (!await Directory(directory).exists()) {
        throw Exception(t.download.errors.directoryNotFound);
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
          SnackBar(content: Text(t.download.errors.openFolderFailed)),
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
    final t = slang.Translations.of(context);
    Get.dialog(
      AlertDialog(
        title: Text(t.download.deleteTask),
        content: Text(t.download.clearAllFailedTasksConfirmation),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              AppService.tryPop();
              DownloadService.to.deleteTask(task.id);
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