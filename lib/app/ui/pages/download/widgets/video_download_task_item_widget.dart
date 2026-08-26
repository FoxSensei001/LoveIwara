import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_error_label.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/move_to_category_sheet.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_status_colors.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/status_label_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path/path.dart' as path;
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/utils/common_utils.dart';

class VideoDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const VideoDownloadTaskItem({super.key, required this.task});

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
          GlassMenuOption<String>(
            value: 'playLocally',
            icon: Icons.play_circle_outline,
            label: t.download.playLocally,
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
      case 'playLocally':
        _playLocalVideo(context);
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
    final videoData = VideoDownloadExtData.fromJson(task.extData!.data);
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;
    final scale = DownloadUiScale.of(context);

    // 从任务ID中提取清晰度信息
    final quality = videoData.quality;

    return DownloadActionButtonTheme(
      child: RepaintBoundary(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // 背景封面图 - 对应 Android 的 ivCoverBg
              if (videoData.thumbnail != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RepaintBoundary(
                      child: CachedNetworkImage(
                        imageUrl: videoData.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ),
                ),
              // 半透明遮罩层（替代模糊效果，避免边缘问题）
              if (videoData.thumbnail != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              // 内容层
              GestureDetector(
                onSecondaryTapUp: (details) => _showTaskMenu(
                  context,
                  globalPosition: details.globalPosition,
                ),
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
                        padding: EdgeInsets.all(12 * scale),
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
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 视频标题
                                  Text(
                                    videoData.title ?? task.fileName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
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
                                              size: 25 * scale,
                                            ),
                                            SizedBox(width: 12 * scale),
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
                                        ? SizedBox(
                                            width: 24 * scale,
                                            height: 24 * scale,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                          )
                                        : const Icon(Icons.delete_outline),
                                    tooltip: t.download.deleteTask,
                                    onPressed: isProcessing
                                        ? null
                                        : () =>
                                              _showDeleteConfirmDialog(context),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 进度和状态（紧贴边缘，无 padding）
                      _buildProgressStatusBar(
                        context,
                        videoData,
                        isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    VideoDownloadExtData videoData,
    bool isSmallScreen,
    String? quality,
  ) {
    final t = slang.Translations.of(context);
    final scale = DownloadUiScale.of(context);
    if (videoData.thumbnail == null) {
      return Container(
        width: 120 * scale,
        height: 80 * scale,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Icon(Icons.video_library, size: 32 * scale)),
      );
    }

    return Container(
      width: 120 * scale,
      height: 80 * scale,
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
                    CommonUtils.getQualityDisplayLabel(t, quality),
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
                  DownloadErrorLabel(task: task),
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
            DownloadMoreButton(
              tooltip: t.download.moreOptions,
              onPressed: _showTaskMenu,
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
          // 完成时显示"本地播放"按钮
          return IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: t.download.playLocally,
            onPressed: () => _playLocalVideo(context),
          );
      }
    });
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
        showGlassToast(
          t.download.copyDownloadUrlSuccess,
          type: GlassToastType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showGlassToast(
          t.download.errors.copyDownloadUrlFailed,
          type: GlassToastType.error,
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
          showGlassToast(
            t.download.errors.fileNotFound,
            type: GlassToastType.error,
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
      final filePath = path.normalize(task.savePath);
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
      LogUtils.d('打开文件结果: ${result.type}', 'DownloadTaskItem');
      if (result.type != ResultType.done) {
        LogUtils.e('打开文件失败: ${result.message}', tag: 'DownloadTaskItem');
        if (context.mounted) {
          showGlassToast(
            t.download.errors.openFolderFailedWithMessage(
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
          t.download.errors.openFolderFailed,
          type: GlassToastType.error,
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
          showGlassToast(
            t.download.errors.fileNotFound,
            type: GlassToastType.error,
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
        showGlassToast(
          t.download.errors.playLocallyFailedWithMessage(message: e.toString()),
          type: GlassToastType.error,
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
