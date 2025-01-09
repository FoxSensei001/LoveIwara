import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_file/open_file.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class DefaultDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const DefaultDownloadTaskItem({super.key, required this.task});

  IconData _getFileIcon() {
    final extension = path.extension(task.fileName).toLowerCase();
    
    // 图片文件
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(extension)) {
      return Icons.image;
    }
    // 音频文件
    else if (['.mp3', '.wav', '.aac', '.ogg', '.m4a'].contains(extension)) {
      return Icons.audio_file;
    }
    // 视频文件
    else if (['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv'].contains(extension)) {
      return Icons.video_file;
    }
    // 压缩文件
    else if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension)) {
      return Icons.folder_zip;
    }
    // 文档文件
    else if (['.pdf', '.doc', '.docx', '.txt', '.md'].contains(extension)) {
      return Icons.description;
    }
    // 默认文件图标
    return Icons.file_present;
  }

  bool _isImageFile() {
    if (task.status != DownloadStatus.completed) return false;
    final extension = path.extension(task.fileName).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GestureDetector(
      onSecondaryTapUp: (details) => _showContextMenu(context, details.globalPosition),
      child: Card(
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
                    // 文件图标
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isImageFile() ? 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(task.savePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getFileIcon(),
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                        : Icon(
                          _getFileIcon(),
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 文件名
                          Text(
                            task.fileName,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                              Text(_getStatusText(context)),
                              if (task.error != null)
                                Text(
                                  task.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                        // 更多操作按钮
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () => _showMoreOptionsDialog(context),
                          tooltip: t.common.more,
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
          tooltip: t.common.retry,
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

  void _showContextMenu(BuildContext context, Offset position) {
    final t = slang.Translations.of(context);
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.link, size: 20),
              const SizedBox(width: 12),
              Text(t.download.copyDownloadUrl),
            ],
          ),
          onTap: () => _copyDownloadUrl(context),
        ),
        if (task.status == DownloadStatus.completed) ...[
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.folder_open, size: 20),
                  const SizedBox(width: 12),
                  Text(t.download.showInFolder),
                ],
              ),
              onTap: () => _showInFolder(context),
            ),
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.open_in_new, size: 20),
                const SizedBox(width: 12),
                Text(t.download.openFile),
              ],
            ),
            onTap: () => _openFile(context),
          ),
        ],
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              Text(t.download.deleteTask, style: const TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _showDeleteConfirmDialog(context),
        ),
      ],
    );
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
          return t.download.downloadingDownloadedTotalProgressSpeed(downloaded: downloaded, total: total, progress: progress, speed: speed);
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

  Future<void> _copyDownloadUrl(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final item = DataWriterItem();
      item.add(Formats.plainText(task.url));
      await SystemClipboard.instance?.write([item]);

      if (context.mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.copyDownloadUrlSuccess,
            type: MDToastType.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.errors.copyFailed,
            type: MDToastType.error,
          ),
        );
      }
    }
  }

  Future<void> _showInFolder(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final filePath = _normalizePath(task.savePath);
      LogUtils.d('显示文件夹: $filePath', 'DownloadTaskItem');

      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.download.errors.fileNotFound,
              type: MDToastType.error,
            ),
          );
        }
        return;
      }

      if (Platform.isWindows) {
        final windowsPath = filePath.replaceAll('/', '\\');
        await Process.run('explorer.exe', ['/select,', windowsPath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        final directory = File(filePath).parent.path;
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      LogUtils.e('打开文件夹失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.errors.openFolderFailed,
            type: MDToastType.error,
          ),
        );
      }
    }
  }

  Future<void> _openFile(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final filePath = _normalizePath(task.savePath);
      LogUtils.d('打开文件: $filePath', 'DownloadTaskItem');

      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.download.errors.fileNotFound,
              type: MDToastType.error,
            ),
          );
        }
        return;
      }

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        LogUtils.e('打开文件失败: ${result.message}', tag: 'DownloadTaskItem');
        if (context.mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.download.errors.openFileFailedWithMessage(message: result.message),
              type: MDToastType.error,
            ),
          );
        }
      }
    } catch (e) {
      LogUtils.e('打开文件失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.errors.openFileFailed,
            type: MDToastType.error,
          ),
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
    if (task.status == DownloadStatus.completed) {
      _openFile(context);
    }
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
