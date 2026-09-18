import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_actions.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_tile.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/status_label_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
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
    final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

    return DownloadTaskTile(
      task: task,
      title: extData.title ?? t.download.errors.unknown,
      author: DownloadTileAuthor(
        name: extData.authorName ?? t.download.errors.unknown,
        avatarUrl: extData.authorAvatar,
        onTap: extData.authorUsername == null
            ? null
            : () => NaviService.navigateToAuthorProfilePage(
                extData.authorUsername!,
              ),
      ),
      cover: extData.previewUrls.isEmpty
          ? const Center(child: Icon(Icons.image_not_supported, size: 32))
          : CachedNetworkImage(
              // ⛔ 过一道 [iwaraPosterUrlFrom]：这张地址是**下载任务建起来那天**
              // 存进 ext_data 的，视频那几条指向原文件（webm），拿去当封面画不出来。
              // 那些数据库行不会因为代码改了就自己重写，只能在渲染这一侧改写。
              imageUrl: iwaraPosterUrlFrom(extData.previewUrls[0]),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
      coverBadges: [
        Positioned(
          right: 4,
          bottom: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              child: Text(
                t.download.totalImageNums(num: extData.totalImages),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ),
      ],
      coverOverlay: task.status == DownloadStatus.downloading
          ? _buildDownloadingOverlay()
          : null,
      statusBuilder: (context) =>
          isSmallScreen && task.status == DownloadStatus.downloading
          ? _buildSmallScreenDownloadingStatus(context, t)
          : StatusLabel(status: task.status, text: _getStatusText(context)),
      primaryAction: _buildMainActionButton(context),
      gridMeta: t.download.totalImageNums(num: extData.totalImages),
      onTap: task.status == DownloadStatus.completed
          ? () => _onTap(context)
          : null,
    );
  }

  /// 下载中盖在封面上的环形进度（已下张数 / 总张数）。
  Widget _buildDownloadingOverlay() {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Obx(() {
          final progress = DownloadService.to.getGalleryDownloadProgress(
            task.id,
          );
          if (progress == null) return const SizedBox.shrink();
          final total = progress.length;
          final done = progress.values.where((d) => d).length;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(
                  value: total > 0 ? done / total : 0,
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$done/$total',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          );
        }),
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
              onPressed: () => revealDownloadInFolder(task),
            );
          }
          // 移动平台不显示按钮（点击卡片即可查看图库）
          return SizedBox(width: 24 * scale, height: 24 * scale);
      }
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

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      NaviService.navigateToGalleryDownloadTaskDetailPage(task.id);
    }
  }
}
