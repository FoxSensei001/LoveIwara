import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path;

class GalleryDownloadTaskDetailPage extends StatelessWidget {
  final String taskId;

  const GalleryDownloadTaskDetailPage({super.key, required this.taskId});

  DownloadTask? get task => DownloadService.to.tasks[taskId];

  GalleryDownloadExtData? get galleryData {
    try {
      if (task?.extData?.type == 'gallery') {
        return GalleryDownloadExtData.fromJson(task!.extData!.data);
      }
    } catch (e) {
      LogUtils.e('解析图库下载任务数据失败', tag: 'GalleryDownloadTaskDetailPage', error: e);
    }
    return null;
  }

  // 检查图片是否已下载
  bool isImageDownloaded(String imagePath) {
    try {
      return File(imagePath).existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final extData = galleryData;
    if (task == null || extData == null) {
      return const Scaffold(
        body: Center(
          child: Text('任务不存在或数据错误'),
        ),
      );
    }

    // 格式化保存路径
    final savePath = path.normalize(task!.savePath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('图库详情'),
        actions: [
          if (extData.id != null)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () => NaviService.navigateToGalleryDetailPage(extData.id!),
              tooltip: '查看图库详情',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                extData.title ?? '未知标题',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // 作者信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MouseRegion(
                cursor: extData.authorUsername != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: extData.authorUsername != null
                      ? () => NaviService.navigateToAuthorProfilePage(extData.authorUsername!)
                      : null,
                  child: Row(
                    children: [
                      AvatarWidget(
                        avatarUrl: extData.authorAvatar,
                        defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            extData.authorName ?? '未知作者',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (extData.authorUsername != null)
                            Text(
                              '@${extData.authorUsername}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 下载状态
            Obx(() {
              final currentTask = DownloadService.to.tasks[taskId];
              if (currentTask == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '下载状态',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: currentTask.status == DownloadStatus.completed
                          ? 1.0
                          : currentTask.totalBytes > 0
                              ? currentTask.downloadedBytes / currentTask.totalBytes
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(_getStatusText(currentTask)),
                    if (currentTask.error != null)
                      Text(
                        currentTask.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            // 图片网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '图片列表',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final currentTask = DownloadService.to.tasks[taskId];
              if (currentTask == null) return const SizedBox.shrink();
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: extData.imageList.length,
                itemBuilder: (context, index) {
                  final imageInfo = extData.imageList[index];
                  final imageId = imageInfo['id']!;
                  final imageUrl = imageInfo['url']!;
                  final imagePath = path.join(
                    savePath,
                    '$imageId${path.extension(imageUrl)}',
                  );
                  final isDownloaded = isImageDownloaded(imagePath);

                  return _buildImageItem(
                    context,
                    imageUrl: imageUrl,
                    imagePath: imagePath,
                    isDownloaded: isDownloaded,
                    onRetry: () {
                      if (currentTask.status == DownloadStatus.failed) {
                        DownloadService.to.retryGalleryImageDownload(taskId, imageId);
                      }
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(
    BuildContext context, {
    required String imageUrl,
    required String imagePath,
    required bool isDownloaded,
    required VoidCallback onRetry,
  }) {
    return Stack(
      children: [
        // 图片容器
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isDownloaded
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error_outline),
                    ),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error_outline),
                    ),
                  ),
          ),
        ),
        // 状态指示器
        if (!isDownloaded && task?.status == DownloadStatus.failed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: onRetry,
                  tooltip: '重试下载',
                ),
              ),
            ),
          ),
        // 下载状态指示器
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDownloaded ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isDownloaded ? '已下载' : '未下载',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(DownloadTask task) {
    switch (task.status) {
      case DownloadStatus.pending:
        return '等待下载...';
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          return '下载中 (${task.downloadedBytes}/${task.totalBytes}张 $progress%)';
        } else {
          return '下载中 (${task.downloadedBytes}张)';
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          return '已暂停 (${task.downloadedBytes}/${task.totalBytes}张 $progress%)';
        } else {
          return '已暂停 (已下载${task.downloadedBytes}张)';
        }
      case DownloadStatus.completed:
        return '下载完成 (共${task.totalBytes}张)';
      case DownloadStatus.failed:
        return '下载失败';
    }
  }
} 