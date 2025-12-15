import 'dart:io';
import 'dart:ui';

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 模糊背景
          if (videoData.thumbnail != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: videoData.thumbnail!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          if (videoData.thumbnail != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.7),
                ),
              ),
            ),
          // 内容层
          GestureDetector(
            onSecondaryTapUp: (details) {
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(details.globalPosition, details.globalPosition),
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
                    // 本地播放按钮
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_outline),
                          const SizedBox(width: 8),
                          Text(t.download.playLocally),
                        ],
                      ),
                      onTap: () => _playLocalVideo(context),
                    ),
                    if (Platform.isWindows ||
                        Platform.isMacOS ||
                        Platform.isLinux)
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
                        Text(
                          t.download.deleteTask,
                          style: const TextStyle(color: Colors.red),
                        ),
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
                        Text(
                          t.download.forceDeleteTask,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    onTap: () => _showDeleteConfirmDialog(context, force: true),
                  ),
                ],
              );
            },
            child: InkWell(
              onTap: () => _onTap(context),
              mouseCursor: task.status == DownloadStatus.completed
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              splashFactory: task.status == DownloadStatus.completed
                  ? InkSplash.splashFactory
                  : NoSplash.splashFactory,
              child: Column(
                children: [
                  // 上部内容区域（带 padding）
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 视频缩略图
                        _buildThumbnail(
                          context,
                          videoData,
                          isSmallScreen,
                          quality,
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
                              const SizedBox(height: 8),
                              // 作者信息
                              if (videoData.authorName != null)
                                MouseRegion(
                                  cursor: videoData.authorUsername != null
                                      ? SystemMouseCursors.click
                                      : SystemMouseCursors.basic,
                                  child: GestureDetector(
                                    onTap: videoData.authorUsername != null
                                        ? () => _navigateToAuthorProfile(
                                            videoData,
                                          )
                                        : null,
                                    child: Row(
                                      children: [
                                        AvatarWidget(
                                          avatarUrl: videoData.authorAvatar,
                                          size: 25,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          videoData.authorName!,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
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
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
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
                  _buildProgressStatusBar(context, videoData, isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    VideoDownloadExtData videoData,
    bool isSmallScreen,
    String? quality,
  ) {
    if (videoData.thumbnail == null) {
      return Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Icon(Icons.video_library, size: 32)),
      );
    }

    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // 主缩略图
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: videoData.thumbnail!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error_outline),
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
                    horizontal: 6,
                    vertical: 2,
                  ),
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
                    horizontal: 6,
                    vertical: 2,
                  ),
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
    );
  }

  Widget _buildProgressStatusBar(
    BuildContext context,
    VideoDownloadExtData videoData,
    bool isSmallScreen,
  ) {
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

      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          gradient: LinearGradient(
            colors: [
              _getProgressColor(task.status).withValues(alpha: 0.3),
              _getProgressColor(task.status).withValues(alpha: 0.1),
            ],
            stops: [progress.clamp(0.0, 1.0), progress.clamp(0.0, 1.0)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 窄屏下载中状态：分两行显示
                  if (isSmallScreen &&
                      task.status == DownloadStatus.downloading)
                    _buildSmallScreenDownloadingStatus(context, t)
                  // 窄屏其他状态或宽屏所有状态：单行显示
                  else
                    StatusLabel(
                      status: task.status,
                      text: _getStatusText(context),
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
            // 视频详情按钮
            if (videoData.id != null)
              IconButton(
                icon: const Icon(Icons.video_library),
                onPressed: () =>
                    NaviService.navigateToVideoDetailPage(videoData.id!),
                tooltip: t.download.viewVideoDetail,
              ),
            // 更多操作按钮
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showMoreOptionsDialog(context),
              tooltip: t.download.moreOptions,
            ),
          ],
        ),
      );
    });
  }

  // 窄屏下载中状态的专用显示组件
  Widget _buildSmallScreenDownloadingStatus(
    BuildContext context,
    slang.Translations t,
  ) {
    final downloaded = _formatFileSize(task.downloadedBytes);
    final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);

    String progressText;
    if (task.totalBytes > 0) {
      final total = _formatFileSize(task.totalBytes);
      final progress = (task.downloadedBytes / task.totalBytes * 100)
          .toStringAsFixed(1);
      progressText = '$downloaded/$total ($progress%)';
    } else {
      progressText = downloaded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        // 第一行：进度
        Text(
          progressText,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 第二行：下载中 tag + 网速
        Row(
          children: [
            StatusLabel(status: task.status, text: t.download.downloading),
            const SizedBox(width: 8),
            Text(
              '${speed}MB/s',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
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
          // 完成时显示"本地播放"按钮
          return IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: t.download.playLocally,
            onPressed: () => _playLocalVideo(context),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
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
                          // 本地播放按钮
                          ListTile(
                            leading: const Icon(Icons.play_circle_outline),
                            title: Text(t.download.playLocally),
                            onTap: () {
                              Navigator.pop(context);
                              _playLocalVideo(context);
                            },
                          ),
                          if (Platform.isWindows ||
                              Platform.isMacOS ||
                              Platform.isLinux)
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
                          title: Text(
                            t.download.deleteTask,
                            style: const TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmDialog(context);
                          },
                        ),
                        // 强制删除
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            t.download.forceDeleteTask,
                            style: const TextStyle(color: Colors.red),
                          ),
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
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);

          return t.download.downloadingProgressForVideoTask(
            downloaded: downloaded,
            total: total,
            progress: progress,
            speed: speed,
          );
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          final speed = (task.speed / 1024 / 1024).toStringAsFixed(2);

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

          // 窄屏设备使用更紧凑的格式
          if (isSmallScreen) {
            return '$downloaded/$total ($progress%)';
          }

          return t.download.pausedForDownloadedAndTotal(
            downloaded: downloaded,
            total: total,
            progress: progress,
          );
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
              content: Text(
                t.download.errors.openFolderFailedWithMessage(
                  message: result.message,
                ),
              ),
            ),
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

  /// 本地播放视频
  Future<void> _playLocalVideo(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final filePath = path.normalize(task.savePath);
      LogUtils.d('本地播放: $filePath', 'DownloadTaskItem');

      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.download.errors.fileNotFound)),
          );
        }
        return;
      }

      // 获取同一视频的所有已下载清晰度任务
      final videoData = VideoDownloadExtData.fromJson(task.extData!.data);
      List<DownloadTask> allQualityTasks = [];

      if (videoData.id != null) {
        final downloadService = Get.find<DownloadService>();
        allQualityTasks = await downloadService.repository.getVideoTasksByMedia(
          videoData.id!,
        );
        // 只保留已完成的任务
        allQualityTasks = allQualityTasks
            .where((t) => t.status == DownloadStatus.completed)
            .toList();
      }

      // 导航到本地视频播放页面
      NaviService.navigateToLocalVideoPlayerPage(
        localPath: filePath,
        task: task,
        allQualityTasks: allQualityTasks,
      );
    } catch (e) {
      LogUtils.e('本地播放失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.download.errors.playLocallyFailedWithMessage(
                message: e.toString(),
              ),
            ),
          ),
        );
      }
    }
  }

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      _playLocalVideo(context);
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
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AlertDialog(
            title: Text(
              force ? t.download.forceDeleteTask : t.download.deleteTask,
            ),
            content: Text(
              force
                  ? t.download.forceDeleteTaskConfirmation
                  : t.download.deleteTaskConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => AppService.tryPop(),
                child: Text(t.common.cancel),
              ),
              TextButton(
                onPressed: () {
                  AppService.tryPop();
                  DownloadService.to.deleteTask(
                    task.id,
                    ignoreFileDeleteError: force,
                  );
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
