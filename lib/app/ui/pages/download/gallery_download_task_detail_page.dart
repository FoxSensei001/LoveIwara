import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path/path.dart' as path_lib;
class GalleryDownloadTaskDetailPage extends StatefulWidget {
  final String taskId;
  const GalleryDownloadTaskDetailPage({super.key, required this.taskId});

  @override
  State<GalleryDownloadTaskDetailPage> createState() => _GalleryDownloadTaskDetailPageState();
}

class _GalleryDownloadTaskDetailPageState extends State<GalleryDownloadTaskDetailPage> {
  GalleryDownloadExtData? galleryData;
  
  @override
  void initState() {
    super.initState();
    _loadGalleryData();
  }

  Future<void> _loadGalleryData() async {
    final data = await getGalleryData();
    if (mounted) {
      setState(() {
        galleryData = data;
      });
    }
  }

  DownloadTask? get task => DownloadService.to.tasks[widget.taskId];

  Future<GalleryDownloadExtData?> getGalleryData() async {
    if (task == null) {
      // 从数据库中获取
      final task = await DownloadService.to.repository.getTaskById(widget.taskId);
      if (task != null) {
        return GalleryDownloadExtData.fromJson(task.extData!.data);
      }
    }
    try {
      if (task?.extData?.type == DownloadTaskExtDataType.gallery) {
        return GalleryDownloadExtData.fromJson(task!.extData!.data);
      }
    } catch (e) {
      LogUtils.e('解析图库下载任务数据失败',
          tag: 'GalleryDownloadTaskDetailPage', error: e);
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

  // 构建图片菜单项
  List<MenuItem> _buildImageMenuItems(BuildContext context, ImageItem item) {
    final t = slang.Translations.of(context);
    
    return [
      if (GetPlatform.isDesktop)
        MenuItem(
          title: t.galleryDetail.saveAs,
          icon: Icons.download,
          onTap: () => ImageUtils.downloadImageToAppDirectory(item),
        ),
    ];
  }

  // 处理图片点击事件
  void _onImageTap(
      BuildContext context, ImageItem item, List<ImageItem> imageItems) {
    int index = imageItems.indexWhere((element) => element.url == item.url);
    if (index == -1) {
      index =
          imageItems.indexWhere((element) => element.data.id == item.data.id);
    }
    NaviService.navigateToPhotoViewWrapper(
      imageItems: imageItems,
      initialIndex: index,
      menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final extData = galleryData;
    final currentTask = task;

    // 如果数据还没加载完成，显示加载中
    if (extData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.galleryDetail.galleryDetail),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 构建图片列表
    List<ImageItem> buildImageItems(GalleryDownloadExtData extData, DownloadTask? currentTask) {
      return extData.imageList.entries.map((entry) {
        final imageId = entry.key;
        final localPath = extData.localPaths[imageId];
        
        if (localPath == null || !File(localPath).existsSync()) {
          LogUtils.e('图片本地文件不存在: $imageId', tag: 'GalleryDownloadTaskDetailPage');
          return null;
        }

        return ImageItem(
          url: 'file://$localPath',
          data: ImageItemData(
            id: imageId,
            url: 'file://$localPath',
            originalUrl: 'file://$localPath',
          ),
        );
      }).whereType<ImageItem>().toList();
    }

    final imageItems = buildImageItems(extData, currentTask);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.galleryDetail.galleryDetail),
        actions: [
          if (extData.id != null)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () =>
                  NaviService.navigateToGalleryDetailPage(extData.id!),
              tooltip: t.galleryDetail.viewGalleryDetail,
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
                extData.title ?? t.download.errors.unknown,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // 作者信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MouseRegion(
                cursor: extData.authorUsername != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: extData.authorUsername != null
                      ? () => NaviService.navigateToAuthorProfilePage(
                          extData.authorUsername!)
                      : null,
                  child: Row(
                    children: [
                      AvatarWidget(
                        avatarUrl: extData.authorAvatar,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            extData.authorName ?? t.download.errors.unknown,
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
              // 优先从活跃任务获取，如果不存在则从数据库获取
              final currentTask = DownloadService.to.tasks[widget.taskId];
              if (currentTask == null) {
                // 如果不是活跃任务，则不显示进度条等动态UI
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.download.downloadStatus,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_getStatusText(context, currentTask)),
                    if (currentTask.error != null)
                      Text(
                        currentTask.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    // 添加图片下载进度指示器
                    if (currentTask.status == DownloadStatus.downloading)
                      _buildGalleryProgressIndicator(context, currentTask),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            // 图片网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                t.download.imageList,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              // 优先从活跃任务获取，如果不存在则使用已加载的数据
              DownloadTask? currentTask = DownloadService.to.tasks[widget.taskId];

              return LayoutBuilder(
                builder: (context, constraints) {
                  // 计算列数，最少两列
                  final columnCount = (constraints.maxWidth / 200)
                      .floor()
                      .clamp(2, 4); // 200 是每列的最小宽度

                  return WaterfallFlow.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: imageItems.length,
                    itemBuilder: (context, index) {
                      final item = imageItems[index];
                      final isDownloaded = item.url.startsWith('file://');
                      final imageId = item.data.id;
                      final extension = path_lib.extension(item.url).toLowerCase();
                      final isUnsupportedFormat = ['.webm'].contains(extension);

                      return Stack(
                        children: [
                          // 图片容器
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onImageTap(context, item, imageItems),
                                  child: isDownloaded
                                      ? isUnsupportedFormat
                                          ? SizedBox(
                                              height: 200,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.image_not_supported),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      t.download.errors.unsupportedImageFormat(format: extension),
                                                      textAlign: TextAlign.center,
                                                      style: Theme.of(context).textTheme.bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Image.file(
                                              File(item.url.replaceFirst('file://', '')),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const SizedBox(
                                                    height: 200,
                                                    child: Center(
                                                      child: Icon(Icons.error_outline),
                                                    ),
                                                  ),
                                            )
                                      : Image.network(
                                          item.url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const SizedBox(
                                                height: 200,
                                                child: Center(
                                                  child: Icon(Icons.error_outline),
                                                ),
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          // 下载进度指示器
                          if (!isDownloaded && currentTask?.status == DownloadStatus.downloading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(() {
                                        if (currentTask == null) return const SizedBox.shrink();
                                        final progress = DownloadService.to.getGalleryImageProgress(currentTask.id)?[imageId] ?? 0;
                                        return Text(
                                          '${(progress * 100).toStringAsFixed(1)}%',
                                          style: const TextStyle(color: Colors.white),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // 下载状态指示器
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDownloaded ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isDownloaded
                                    ? t.download.downloaded
                                    : t.download.notDownloaded,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
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

  // 构建图库下载进度指示器
  Widget _buildGalleryProgressIndicator(BuildContext context, DownloadTask task) {
    final progress = DownloadService.to.getGalleryDownloadProgress(task.id);
    if (progress == null) return const SizedBox.shrink();

    final totalImages = progress.length;
    final downloadedImages = progress.values.where((downloaded) => downloaded).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalImages > 0 ? downloadedImages / totalImages : 0,
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$downloadedImages/$totalImages',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  String _getStatusText(BuildContext context, DownloadTask task) {
    final t = slang.Translations.of(context);
    switch (task.status) {
      case DownloadStatus.pending:
        return t.download.waitingForDownload;
      case DownloadStatus.downloading:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          // return '下载中 (${task.downloadedBytes}/${task.totalBytes}张 $progress%)';
          return t.download.downloadingProgressForImageProgress(
              downloaded: task.downloadedBytes,
              total: task.totalBytes,
              progress: progress);
        } else {
          // return '下载中 (${task.downloadedBytes}张)';
          return t.download
              .downloadingSingleImageProgress(downloaded: task.downloadedBytes);
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress =
              (task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(1);
          // return '已暂停 (${task.downloadedBytes}/${task.totalBytes}张 $progress%)';
          return t.download.pausedProgressForImageProgress(
              downloaded: task.downloadedBytes,
              total: task.totalBytes,
              progress: progress);
        } else {
          // return '已暂停 (已下载${task.downloadedBytes}张)';
          return t.download
              .pausedSingleImageProgress(downloaded: task.downloadedBytes);
        }
      case DownloadStatus.completed:
        // return '下载完成 (共${task.totalBytes}张)';
        return t.download
            .downloadedProgressForImageProgress(total: task.totalBytes);
      case DownloadStatus.failed:
        // return '下载失败';
        return t.download.errors.downloadFailed;
    }
  }
}
