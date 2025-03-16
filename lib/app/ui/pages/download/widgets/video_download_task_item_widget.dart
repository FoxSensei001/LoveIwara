import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/status_label_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path/path.dart' as path;

class VideoDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const VideoDownloadTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final videoData = VideoDownloadExtData.fromJson(task.extData!.data);
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    // 从任务ID中提取清晰度信息
    final quality = videoData.quality;

    return GestureDetector(
      onSecondaryTapUp: (details) {
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            details.globalPosition,
            details.globalPosition,
          ),
          Offset.zero & overlay.size,
        );
        showMenu(
          context: context,
          position: position,
          items: [
            // 查看下载详情
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.info),
                  const SizedBox(width: 8),
                  Text(t.download.downloadDetail),
                ],
              ),
              onTap: () => showDownloadDetailDialog(context, task),
            ),
            // 复制下载链接
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.link),
                  const SizedBox(width: 8),
                  Text(t.download.copyDownloadUrl),
                ],
              ),
              onTap: () => _copyDownloadUrl(context),
            ),
            if (task.status == DownloadStatus.completed) ...[
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new),
                    const SizedBox(width: 8),
                    Text(t.download.openFile),
                  ],
                ),
                onTap: () => _openFile(context),
              ),
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open),
                      const SizedBox(width: 8),
                      Text(t.download.showInFolder),
                    ],
                  ),
                  onTap: () => _showInFolder(context),
                ),
            ],
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(t.download.deleteTask, style: const TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _showDeleteConfirmDialog(context),
            ),
            // 强制删除
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(t.download.forceDeleteTask, style: const TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _showDeleteConfirmDialog(context, force: true),
            ),
          ],
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: () => _onTap(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频缩略图
                    if (videoData.thumbnail != null)
                      SizedBox(
                        width: isSmallScreen ? 120 : 160,
                        height: isSmallScreen ? 68 : 90,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: videoData.thumbnail!,
                                width: isSmallScreen ? 120 : 160,
                                height: isSmallScreen ? 68 : 90,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                            // 清晰度标签
                            if (quality != null)
                              Positioned(
                                left: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    quality,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            // 时长标签
                            if (videoData.duration != null)
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatDuration(videoData.duration!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 视频标题
                          Text(
                            videoData.title ?? task.fileName,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 作者信息
                          if (videoData.authorName != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (videoData.authorAvatar != null)
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _navigateToAuthorProfile(videoData),
                                      child:  AvatarWidget(
                                            avatarUrl: videoData.authorAvatar,
                                            size: 25
                                          ),
                                        ),
                                  ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: IntrinsicWidth(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _navigateToAuthorProfile(videoData),
                                          child: Text(
                                            videoData.authorName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (!isSmallScreen) const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    // 主要操作按钮
                    _buildMainActionButton(context),
                  ],
                ),
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
                              // 修改状态标签显示方式，为窄屏优化
                              if (isSmallScreen && task.status == DownloadStatus.downloading)
                                Row(
                                  children: [
                                    StatusLabel(status: task.status, text: t.download.downloading),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getStatusText(context),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                )
                              else
                                StatusLabel(status: task.status, text: _getStatusText(context)),
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
                        // 视频详情跳转按钮
                        if (videoData.id != null)
                          IconButton(
                            icon: const Icon(Icons.video_library),
                            tooltip: t.download.viewVideoDetail,
                            onPressed: () =>
                                NaviService.navigateToVideoDetailPage(
                                    videoData.id!),
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
          tooltip: t.download.retryDownload,
          onPressed: () => DownloadService.to.retryTask(task.id),
        );
      case DownloadStatus.completed:
        return IconButton(
          icon: const Icon(Icons.play_circle_outline),
          tooltip: t.download.openFile,
          onPressed: () => _openFile(context),
        );
      default:
        return const SizedBox.shrink();
    }
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
            // 复制下载链接
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(t.download.copyDownloadUrl),
              onTap: () {
                Navigator.pop(context);
                _copyDownloadUrl(context);
              },
            ),
            if (task.status == DownloadStatus.completed) ...[
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: Text(t.download.openFile),
                onTap: () {
                  Navigator.pop(context);
                  _openFile(context);
                },
              ),
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
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
              title: Text(t.download.deleteTask,
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context);
              },
            ),
            // 强制删除
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(t.download.forceDeleteTask, style: const TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _showDeleteConfirmDialog(context, force: true),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAuthorProfile(VideoDownloadExtData videoData) {
    if (videoData.authorUsername != null) {
      NaviService.navigateToAuthorProfilePage(videoData.authorUsername!);
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressIndicator() {
    if (task.status == DownloadStatus.completed) {
      return const SizedBox.shrink();
    }
    // 如果有总大小，显示具体进度
    if (task.totalBytes > 0) {
      return LinearProgressIndicator(
        value: task.downloadedBytes / task.totalBytes,
        backgroundColor: Colors.grey[200],
        valueColor:
            AlwaysStoppedAnimation<Color>(_getProgressColor(task.status)),
      );
    }
    // 如果没有总大小但正在下载，显示不确定进度
    else if (task.status == DownloadStatus.downloading) {
      return const LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
    }
    // 其他状态（失败...）
    else {
      return LinearProgressIndicator(
        value: task.status == DownloadStatus.completed ? 1.0 : 0.0,
        backgroundColor: Colors.grey[200],
        valueColor:
            AlwaysStoppedAnimation<Color>(_getProgressColor(task.status)),
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

  String _getStatusText(BuildContext context) {
    final t = slang.Translations.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
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
          
          // 窄屏设备使用更紧凑的格式
          if (isSmallScreen) {
            return '$downloaded/$total\n${speed}MB/s';
          }
          
          return t.download.downloadingProgressForVideoTask(
              downloaded: downloaded,
              total: total,
              progress: progress,
              speed: speed);
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          
          // 窄屏设备使用更紧凑的格式
          if (isSmallScreen) {
            return '$downloaded\n${speed}MB/s';
          }
          
          return t.download.downloadingOnlyDownloadedAndSpeed(
              downloaded: downloaded, speed: speed);
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          
          // 窄屏设备使用更紧凑的格式
          if (isSmallScreen) {
            return '$downloaded/$total';
          }
          
          return t.download.pausedForDownloadedAndTotal(
              downloaded: downloaded, total: total, progress: progress);
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          return t.download.pausedAndDownloaded(downloaded: downloaded);
        }
      case DownloadStatus.completed:
        final size = _formatFileSize(task.downloadedBytes);
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

  Future<void> _copyDownloadUrl(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final item = DataWriterItem();
      item.add(Formats.plainText(task.url));
      await SystemClipboard.instance?.write([item]);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.download.copyDownloadUrlSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.download.errors.copyDownloadUrlFailed)),
        );
      }
    }
  }

  Future<void> _showInFolder(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final filePath = path.normalize(task.savePath);
      LogUtils.d('显示文件夹: $filePath', 'DownloadTaskItem');

      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.download.errors.fileNotFound)),
          );
        }
        return;
      }

      if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        final directory = path.dirname(filePath);
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      LogUtils.e('打开文件夹失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.download.errors.openFolderFailed)),
        );
      }
    }
  }

  Future<void> _openFile(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final filePath = path.normalize(task.savePath);
      LogUtils.d('打开文件: $filePath', 'DownloadTaskItem');

      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.download.errors.fileNotFound)),
          );
        }
        return;
      }

      final result = await OpenFile.open(filePath);
      LogUtils.d('打开文件结果: ${result.type}', 'DownloadTaskItem');
      if (result.type != ResultType.done) {
        LogUtils.e('打开文件失败: ${result.message}', tag: 'DownloadTaskItem');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(t.download.errors
                    .openFolderFailedWithMessage(message: result.message))),
          );
        }
      }
    } catch (e) {
      LogUtils.e('打开文件失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.download.errors.openFolderFailed)),
        );
      }
    }
  }

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      _openFile(context);
    } else {
      // 如果是视频类型且有视频ID，可以跳转到视频详情页
      final videoData = VideoDownloadExtData.fromJson(task.extData!.data);
      if (videoData.id != null) {
        NaviService.navigateToVideoDetailPage(videoData.id!);
      }
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, {bool force = false}) {
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
              DownloadService.to.deleteTask(task.id, ignoreFileDeleteError: force);
            },
            child: Text(t.common.confirm),
          ),
        ],
      ),
    );
  }
}
