import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/status_label_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_file/open_file.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

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
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _onTap(context),
          child: Column(
            children: [
              // 上部内容区域（带 padding）
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
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
                    // 主要操作 + 快捷删除按钮
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMainActionButton(context),
                        Obx(() {
                          final isProcessing = DownloadService.to.isTaskProcessing(task.id);
                          return IconButton(
                            icon: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.delete_outline),
                            tooltip: t.download.deleteTask,
                            onPressed: isProcessing ? null : () => _showDeleteConfirmDialog(context),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              // 进度和状态（紧贴边缘，无 padding）
              _buildProgressStatusBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context) {
    final t = slang.Translations.of(context);

    // 使用 Obx 监听处理状态
    return Obx(() {
      final isProcessing = DownloadService.to.isTaskProcessing(task.id);

      // 如果正在处理中，显示 loading
      if (isProcessing) {
        return const SizedBox(
          width: 48,
          height: 48,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      switch (task.status) {
        case DownloadStatus.pending:
          return IconButton(
            icon: const Icon(Icons.pause),
            tooltip: t.download.pause,
            onPressed: () => DownloadService.to.pauseTask(task.id),
          );
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
      }
    });
  }

  void _showMoreOptionsDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        t.common.more,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 可滚动的选项列表
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
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
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(t.download.deleteTask, style: const TextStyle(color: Colors.red)),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmDialog(context);
                          },
                        ),
                        // 强制删除
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(t.download.forceDeleteTask, style: const TextStyle(color: Colors.red)),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmDialog(context, force: true);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStatusBar(BuildContext context) {
    final t = slang.Translations.of(context);

    return Obx(() {
      // 监听进度变更
      DownloadService.to.getProgressTrigger(task.id).value;

      // 计算进度
      double progress = 0.0;
      if (task.totalBytes > 0) {
        progress = task.downloadedBytes / task.totalBytes;
      } else if (task.status == DownloadStatus.completed) {
        progress = 1.0;
      }

      // 完成状态使用更淡的颜色
      final isCompleted = task.status == DownloadStatus.completed;
      final alphaStart = isCompleted ? 0.15 : 0.3;
      final alphaEnd = isCompleted ? 0.05 : 0.1;

      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          gradient: LinearGradient(
            colors: [
              _getProgressColor(task.status).withValues(alpha: alphaStart),
              _getProgressColor(task.status).withValues(alpha: alphaEnd),
            ],
            stops: [progress.clamp(0.0, 1.0), progress.clamp(0.0, 1.0)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            // 更多操作按钮
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showMoreOptionsDialog(context),
              tooltip: t.common.more,
            ),
          ],
        ),
      );
    });
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
      LogUtils.d('打开文件结果: ${result.type}, ${result.message}', 'DownloadTaskItem');
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
    // 仅做路径分隔符规范化，避免因“生成唯一路径”而在已有文件名后追加 (1)
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

  void _showDeleteConfirmDialog(BuildContext context, {bool force = false}) {
    final t = slang.Translations.of(context);
    showAppDialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AlertDialog(
            title: Text(force ? t.download.forceDeleteTask : t.download.deleteTask),
            content: Text(force ? t.download.forceDeleteTaskConfirmation : t.download.deleteTaskConfirmation),
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
                child: Text(
                  t.common.confirm,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
