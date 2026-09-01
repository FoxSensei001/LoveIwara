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
import 'package:path/path.dart' as path;
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

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
          value: 'moveTo',
          icon: Icons.drive_file_move_outline,
          label: t.download.category.moveTo,
        ),
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
          GlassMenuOption<String>(
            value: 'reveal',
            icon: Icons.folder_open,
            label: t.download.showInFolder,
          ),
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
      case 'moveTo':
        showMoveToCategorySheet(context, [task.id]);
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
    final extData = galleryData;

    if (extData == null) return const SizedBox.shrink();

    final scale = DownloadUiScale.of(context);

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
              if (extData.previewUrls.isNotEmpty)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RepaintBoundary(
                      child: CachedNetworkImage(
                        imageUrl: extData.previewUrls[0],
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
              if (extData.previewUrls.isNotEmpty)
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
                            // 预览图区域
                            Container(
                              width: 120 * scale,
                              height: 80 * scale,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildPreviewImages(context, extData),
                            ),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 标题
                                  Text(
                                    extData.title ?? t.download.errors.unknown,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // 作者信息
                                  MouseRegion(
                                    cursor: extData.authorUsername != null
                                        ? SystemMouseCursors.click
                                        : SystemMouseCursors.basic,
                                    child: GestureDetector(
                                      onTap: extData.authorUsername != null
                                          ? () =>
                                                NaviService.navigateToAuthorProfilePage(
                                                  extData.authorUsername!,
                                                )
                                          : null,
                                      child: Row(
                                        children: [
                                          AvatarWidget(
                                            avatarUrl: extData.authorAvatar,
                                            size: 25 * scale,
                                          ),
                                          SizedBox(width: 12 * scale),
                                          Text(
                                            extData.authorName ??
                                                t.download.errors.unknown,
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
                      _buildProgressStatusBar(context),
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

  Widget _buildPreviewImages(
    BuildContext context,
    GalleryDownloadExtData extData,
  ) {
    final t = slang.Translations.of(context);
    final scale = DownloadUiScale.of(context);
    if (extData.previewUrls.isEmpty) {
      return Center(child: Icon(Icons.image_not_supported, size: 32 * scale));
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
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline),
              ),
            ),
          ),
          // 下载进度指示器
          if (task.status == DownloadStatus.downloading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: Center(
                  child: Obx(() {
                    final progress = DownloadService.to
                        .getGalleryDownloadProgress(task.id);
                    if (progress == null) return const SizedBox.shrink();

                    final totalImages = progress.length;
                    final downloadedImages = progress.values
                        .where((downloaded) => downloaded)
                        .length;
                    final currentProgress = totalImages > 0
                        ? downloadedImages / totalImages
                        : 0;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: currentProgress.toDouble(),
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$downloadedImages/$totalImages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }),
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
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
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
          // 仅在桌面平台显示"打开文件夹"按钮
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            return IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: t.download.showInFolder,
              onPressed: () => _showInFolder(context),
            );
          }
          // 移动平台不显示按钮（点击卡片即可查看图库）
          return SizedBox(width: 24 * scale, height: 24 * scale);
      }
    });
  }

  Widget _buildProgressStatusBar(BuildContext context) {
    final t = slang.Translations.of(context);
    final extData = galleryData;
    if (extData == null) return const SizedBox.shrink();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
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
            // 图库详情按钮
            if (extData.id != null)
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () =>
                    NaviService.navigateToGalleryDetailPage(extData.id!),
                tooltip: t.download.viewGalleryDetail,
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
    String progressText;
    if (task.totalBytes > 0) {
      final downloaded = _formatImageCount(task.downloadedBytes);
      final total = _formatImageCount(task.totalBytes);
      final progress = (task.downloadedBytes / task.totalBytes * 100)
          .toStringAsFixed(1);
      progressText = '$downloaded/$total ($progress%)';
    } else {
      final downloaded = _formatImageCount(task.downloadedBytes);
      progressText = downloaded;
    }

    return Obx(() {
      final downloadProgress = DownloadService.to.getGalleryDownloadProgress(
        task.id,
      );

      String imageProgressText = '';
      if (downloadProgress != null) {
        final totalImages = downloadProgress.length;
        final downloadedImages = downloadProgress.values
            .where((downloaded) => downloaded)
            .length;
        imageProgressText = '$downloadedImages/$totalImages';
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
          // 第二行：下载中 tag + 图片进度
          if (imageProgressText.isNotEmpty)
            Row(
              children: [
                StatusLabel(status: task.status, text: t.download.downloading),
                const SizedBox(width: 8),
                Text(
                  imageProgressText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }

  String _getStatusText(BuildContext context) {
    final t = slang.Translations.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    switch (task.status) {
      case DownloadStatus.pending:
        return t.download.waitingForDownload;
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          final downloaded = _formatImageCount(task.downloadedBytes);
          final total = _formatImageCount(task.totalBytes);

          return t.download.downloadingProgressForImageProgress(
            downloaded: downloaded,
            total: total,
            progress: progress,
          );
        } else {
          final downloaded = _formatImageCount(task.downloadedBytes);
          return t.download.downloadingOnlyDownloaded(downloaded: downloaded);
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          final downloaded = _formatImageCount(task.downloadedBytes);
          final total = _formatImageCount(task.totalBytes);

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
          final downloaded = _formatImageCount(task.downloadedBytes);
          return t.download.pausedAndDownloaded(downloaded: downloaded);
        }
      case DownloadStatus.completed:
        // 图库单位是“张”，不能用字节语义的 downloadedWithSize 展示。
        // 直接展示已下载 / 总张数的纯计数。
        return '${_formatImageCount(task.downloadedBytes)}'
            '/${_formatImageCount(task.totalBytes)}';
      case DownloadStatus.failed:
        return t.download.errors.downloadFailed;
    }
  }

  /// 图库任务的 downloadedBytes / totalBytes 实际是“图片张数”而非字节，
  /// 这里只做计数格式化（不带 KB/MB 等字节单位）。
  String _formatImageCount(int count) {
    return count.toString();
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
        showAppToast(
          t.download.errors.openFolderFailed,
          type: AppToastType.error,
        );
      }
    }
  }

  String _normalizePath(String path) {
    // 仅做路径分隔符规范化，避免因"生成唯一路径"而在已有文件名后追加 (1)
    if (Platform.isWindows) {
      return path.replaceAll('/', '\\');
    } else {
      return path.replaceAll('\\', '/');
    }
  }

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      NaviService.navigateToGalleryDownloadTaskDetailPage(task.id);
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
