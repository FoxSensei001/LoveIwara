import 'dart:io';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_error_label.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/move_to_category_sheet.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_status_colors.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/status_label_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/utils/logger_utils.dart';
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
    if ([
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
    ].contains(extension)) {
      return Icons.image;
    }
    // 音频文件
    else if (['.mp3', '.wav', '.aac', '.ogg', '.m4a'].contains(extension)) {
      return Icons.audio_file;
    }
    // 视频文件
    else if ([
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
    ].contains(extension)) {
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
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
    ].contains(extension);
  }

  /// 单个任务的操作菜单：右键和右侧的「更多」按钮共用这一份条目。
  ///
  /// 「更多」原来吐的是底部 sheet，和右键那条路长得不一样——同一堆操作两套
  /// 观感。现在两条路都走全站统一的玻璃面板：右键时没有「触发件」，落点用
  /// 指针处一个零尺寸的 `Rect` 给（[globalPosition]，见 [showGlassMenu] 的
  /// globalAnchor）；「更多」按钮则贴着按钮自己弹，落点由 [context] 量出来。
  Future<void> _showTaskMenu(
    BuildContext context, {
    Offset? globalPosition,
  }) async {
    final t = slang.Translations.of(context);
    final action = await showGlassMenu<String>(
      anchorContext: context,
      globalAnchor: globalPosition == null ? null : globalPosition & Size.zero,
      entries: [
        GlassMenuOption<String>(
          value: 'detail',
          icon: Icons.info,
          label: t.download.downloadDetail,
        ),
        GlassMenuOption<String>(
          value: 'copyUrl',
          icon: Icons.link,
          label: t.download.copyDownloadUrl,
        ),
        GlassMenuOption<String>(
          value: 'moveTo',
          icon: Icons.drive_file_move_outline,
          label: t.download.category.moveTo,
        ),
        if (task.status == DownloadStatus.completed) ...[
          GlassMenuOption<String>(
            value: 'open',
            icon: Icons.open_in_new,
            label: t.download.openFile,
          ),
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
            GlassMenuOption<String>(
              value: 'reveal',
              icon: Icons.folder_open,
              label: t.download.showInFolder,
            ),
        ],
        const GlassMenuSeparator(),
        GlassMenuOption<String>(
          value: 'delete',
          icon: Icons.delete,
          label: t.download.deleteTask,
          destructive: true,
        ),
        GlassMenuOption<String>(
          value: 'forceDelete',
          icon: Icons.delete_forever,
          label: t.download.forceDeleteTask,
          destructive: true,
        ),
      ],
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case 'detail':
        showDownloadDetailDialog(context, task);
      case 'copyUrl':
        _copyDownloadUrl(context);
      case 'moveTo':
        showMoveToCategorySheet(context, [task.id]);
      case 'open':
        _openFile(context);
      case 'reveal':
        _showInFolder(context);
      case 'delete':
        _showDeleteConfirmDialog(context);
      case 'forceDelete':
        _showDeleteConfirmDialog(context, force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final scale = DownloadUiScale.of(context);
    return DownloadActionButtonTheme(
      child: GestureDetector(
        onSecondaryTapUp: (details) =>
            _showTaskMenu(context, globalPosition: details.globalPosition),
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
                  padding: EdgeInsets.all(12 * scale),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 文件图标
                      Container(
                        width: 48 * scale,
                        height: 48 * scale,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isImageFile()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(task.savePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        _getFileIcon(),
                                        size: 24 * scale,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              )
                            : Icon(
                                _getFileIcon(),
                                size: 24 * scale,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      SizedBox(width: 12 * scale),
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
                            final isProcessing = DownloadService.to
                                .isTaskProcessing(task.id);
                            return IconButton(
                              icon: isProcessing
                                  ? SizedBox(
                                      width: 24 * scale,
                                      height: 24 * scale,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline),
                              tooltip: t.download.deleteTask,
                              onPressed: isProcessing
                                  ? null
                                  : () => _showDeleteConfirmDialog(context),
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
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context) {
    final t = slang.Translations.of(context);
    final scale = DownloadUiScale.of(context);

    // 使用 Obx 监听处理状态
    return Obx(() {
      final isProcessing = DownloadService.to.isTaskProcessing(task.id);

      // 处理中：用禁用态的图标按钮承载 loading，保持与其它按钮相同的
      // 填充矩形外观与占位，避免切换时尺寸跳动。
      if (isProcessing) {
        return IconButton(
          onPressed: null,
          icon: SizedBox(
            width: 22 * scale,
            height: 22 * scale,
            child: const CircularProgressIndicator(strokeWidth: 2),
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

  Widget _buildProgressStatusBar(BuildContext context) {
    final t = slang.Translations.of(context);
    final scale = DownloadUiScale.of(context);

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
              downloadStatusColor(
                context,
                task.status,
              ).withValues(alpha: alphaStart),
              downloadStatusColor(
                context,
                task.status,
              ).withValues(alpha: alphaEnd),
            ],
            stops: [progress.clamp(0.0, 1.0), progress.clamp(0.0, 1.0)],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 8 * scale,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusLabel(
                    status: task.status,
                    text: _getStatusText(context),
                  ),
                  DownloadErrorLabel(task: task),
                ],
              ),
            ),
            // 更多操作按钮
            DownloadMoreButton(
              tooltip: t.common.more,
              onPressed: _showTaskMenu,
            ),
          ],
        ),
      );
    });
  }

  String _getStatusText(BuildContext context) {
    final t = slang.Translations.of(context);
    switch (task.status) {
      case DownloadStatus.pending:
        return t.download.waitingForDownload;
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          // return '下载中 $downloaded/$total ($progress%) • ${speed}MB/s';
          return t.download.downloadingDownloadedTotalProgressSpeed(
            downloaded: downloaded,
            total: total,
            progress: progress,
            speed: speed,
          );
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);
          // return '下载中 $downloaded • ${speed}MB/s';
          return t.download.downloadingOnlyDownloadedAndSpeed(
            downloaded: downloaded,
            speed: speed,
          );
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          // return '已暂停 • $downloaded/$total ($progress%)';
          return t.download.pausedForDownloadedAndTotal(
            downloaded: downloaded,
            total: total,
            progress: progress,
          );
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

    String sizeStr = size >= 10
        ? size.round().toString()
        : size.toStringAsFixed(1);
    return '$sizeStr ${units[unitIndex]}';
  }

  Future<void> _copyDownloadUrl(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final item = DataWriterItem();
      item.add(Formats.plainText(task.url));
      await SystemClipboard.instance?.write([item]);

      if (context.mounted) {
        showGlassToast(
          t.download.copyDownloadUrlSuccess,
          type: GlassToastType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showGlassToast(
          t.download.errors.copyFailed,
          type: GlassToastType.error,
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
          showGlassToast(
            t.download.errors.fileNotFound,
            type: GlassToastType.error,
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
        showGlassToast(
          t.download.errors.openFolderFailed,
          type: GlassToastType.error,
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
          showGlassToast(
            t.download.errors.fileNotFound,
            type: GlassToastType.error,
          );
        }
        return;
      }

      final result = await OpenFile.open(filePath);
      LogUtils.d(
        '打开文件结果: ${result.type}, ${result.message}',
        'DownloadTaskItem',
      );
      if (result.type != ResultType.done) {
        LogUtils.e('打开文件失败: ${result.message}', tag: 'DownloadTaskItem');
        if (context.mounted) {
          showGlassToast(
            t.download.errors.openFileFailedWithMessage(
              message: result.message,
            ),
            type: GlassToastType.error,
          );
        }
      }
    } catch (e) {
      LogUtils.e('打开文件失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        showGlassToast(
          t.download.errors.openFileFailed,
          type: GlassToastType.error,
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
          GlassAlertDialog(
            title: force ? t.download.forceDeleteTask : t.download.deleteTask,
            content: Text(
              force
                  ? t.download.forceDeleteTaskConfirmation
                  : t.download.deleteTaskConfirmation,
            ),
            actions: [
              GlassDialogAction(
                label: t.common.cancel,
                emphasized: false,
                onPressed: () => AppService.tryPop(),
              ),
              GlassDialogAction(
                label: t.common.confirm,
                emphasized: false,
                destructive: true,
                onPressed: () {
                  AppService.tryPop();
                  DownloadService.to.deleteTask(
                    task.id,
                    ignoreFileDeleteError: force,
                  );
                },
              ),
            ],
          ),
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
