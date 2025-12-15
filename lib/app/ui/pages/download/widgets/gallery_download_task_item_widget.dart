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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 模糊背景
          if (extData.previewUrls.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: extData.previewUrls[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          if (extData.previewUrls.isNotEmpty)
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
                        // 预览图区域
                        Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
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
                                        size: 25,
                                      ),
                                      const SizedBox(width: 12),
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
                  _buildProgressStatusBar(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImages(
    BuildContext context,
    GalleryDownloadExtData extData,
  ) {
    final t = slang.Translations.of(context);
    if (extData.previewUrls.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, size: 32));
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
          // 仅在桌面平台显示"打开文件夹"按钮
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            return IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: t.download.showInFolder,
              onPressed: () => _showInFolder(context),
            );
          }
          // 移动平台不显示按钮（点击卡片即可查看图库）
          return const SizedBox(width: 48, height: 48);
      }
    });
  }

  Widget _buildProgressStatusBar(BuildContext context) {
    final t = slang.Translations.of(context);
    final extData = galleryData;
    if (extData == null) return const SizedBox.shrink();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
            // 图库详情按钮
            if (extData.id != null)
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () =>
                    NaviService.navigateToGalleryDetailPage(extData.id!),
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

  // 窄屏下载中状态的专用显示组件
  Widget _buildSmallScreenDownloadingStatus(
    BuildContext context,
    slang.Translations t,
  ) {
    String progressText;
    if (task.totalBytes > 0) {
      final downloaded = _formatFileSize(task.downloadedBytes);
      final total = _formatFileSize(task.totalBytes);
      final progress = (task.downloadedBytes / task.totalBytes * 100)
          .toStringAsFixed(1);
      progressText = '$downloaded/$total ($progress%)';
    } else {
      final downloaded = _formatFileSize(task.downloadedBytes);
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
          final downloaded = _formatFileSize(task.downloadedBytes);
          final total = _formatFileSize(task.totalBytes);

          return t.download.downloadingProgressForImageProgress(
            downloaded: downloaded,
            total: total,
            progress: progress,
          );
        } else {
          final downloaded = _formatFileSize(task.downloadedBytes);
          return t.download.downloadingOnlyDownloaded(downloaded: downloaded);
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
    double size = bytes.toDouble();

    String sizeStr = size >= 10
        ? size.round().toString()
        : size.toStringAsFixed(1);
    return sizeStr;
  }

  void _showMoreOptionsDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
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
