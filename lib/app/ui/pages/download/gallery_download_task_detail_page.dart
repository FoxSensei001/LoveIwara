import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
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
  State<GalleryDownloadTaskDetailPage> createState() =>
      _GalleryDownloadTaskDetailPageState();
}

class _GalleryDownloadTaskDetailPageState
    extends State<GalleryDownloadTaskDetailPage> {
  GalleryDownloadExtData? galleryData;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadGalleryData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  Future<void> _loadGalleryData() async {
    final data = await getGalleryData();
    if (mounted) {
      setState(() {
        galleryData = data;
      });
    }
  }

  /// 当前任务。
  ///
  /// 先读内存真源（覆盖下载中 / 等待 / 暂停 / 失败四种活跃状态），再回落到
  /// 服务的下载中映射。此前只读后者——它只装「下载中」的任务，于是这个页面在任务
  /// 一被暂停就当它不存在：状态区整块消失、图片网格退回静态数据。
  DownloadTask? get task =>
      DownloadService.to.store.taskOf(widget.taskId) ??
      DownloadService.to.tasks[widget.taskId];

  /// 在 Obx 中订阅这条任务的变化，并返回它的最新快照。
  ///
  /// 已完成的任务不在内存真源里（没有句柄），此时靠 completedRevision 兜底订阅，
  /// 保证 Obx 至少有一个可观察依赖，且任务完成的那一刻这里会重建。
  DownloadTask? _observeTask() {
    final store = DownloadService.to.store;
    store.completedRevision.value;
    final handle = store.handleOf(widget.taskId);
    handle?.revision.value;
    return handle?.task ?? DownloadService.to.tasks[widget.taskId];
  }

  Future<GalleryDownloadExtData?> getGalleryData() async {
    if (task == null) {
      // 从数据库中获取
      final task = await DownloadService.to.repository.getTaskById(
        widget.taskId,
      );
      if (task != null) {
        return GalleryDownloadExtData.fromJson(task.extData!.data);
      }
    }
    try {
      if (task?.extData?.type == DownloadTaskExtDataType.gallery) {
        return GalleryDownloadExtData.fromJson(task!.extData!.data);
      }
    } catch (e) {
      LogUtils.e(
        '解析图库下载任务数据失败',
        tag: 'GalleryDownloadTaskDetailPage',
        error: e,
      );
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
    BuildContext context,
    ImageItem item,
    List<ImageItem> imageItems,
  ) {
    int index = imageItems.indexWhere((element) => element.url == item.url);
    if (index == -1) {
      index = imageItems.indexWhere(
        (element) => element.data.id == item.data.id,
      );
    }
    pushPhotoViewWrapperOverlay(
      context: context,
      imageItems: imageItems,
      initialIndex: index,
      menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item),
      enableMenu: false, // 下载详情进入的查看页不需要菜单/弹窗
    );
  }

  /// 顶栏：返回圆钮 / 标题胶囊 / 「看原图库」。
  ///
  /// 走全站详情页那份配方（见 [GlassHeaderOverlay] 的类文档）：这一页此前还停在
  /// 裸 `AppBar` 上，是最后几块没跟上的地方之一。标题不再在正文里另占一行——
  /// [GlassTitlePill] 自己管截断与「点一下弹全文」，还顺带把「数据还没读出来」
  /// 表达成 shimmer 占位（此前是整页一个转圈）。
  Widget _buildHeader(BuildContext context, GalleryDownloadExtData? extData) {
    final t = slang.Translations.of(context);
    return SizedBox(
      height: GlassTokens.headerRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.arrow_back),
              tooltip: t.common.back,
              onPressed: () => AppService.tryPop(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GlassTitlePill(
                // 还没读出来时传 null：那是占位条该出现的信号。
                title: extData == null
                    ? null
                    : (extData.title ?? t.galleryDetail.galleryDetail),
              ),
            ),
            const SizedBox(width: 8),
            // 原图库还在线上才给这枚键，长出来的那一下走 [GlassGroupSlot]
            // （数据是异步读的，不然就是凭空多一枚钮）。
            GlassGroupSlot(
              visible: extData?.id != null,
              child: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.photo_library),
                tooltip: t.galleryDetail.viewGalleryDetail,
                onPressed: () {
                  final id = galleryData?.id;
                  if (id == null) return;
                  NaviService.navigateToGalleryDetailPage(id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: computeBottomSafeInset(MediaQuery.of(context)) + 16,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => GlassReveal(
          visible: visible,
          builder: (context, m) => GlassIconButton(
            materialize: m,
            standalone: true,
            icon: const Icon(Icons.vertical_align_top),
            tooltip: t.common.scrollToTop,
            onPressed: () {
              if (!_scrollController.hasClients) return;
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final extData = galleryData;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 没有 AppBar 就没人管状态栏图标明暗，不显式声明会沿用上一页的。
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: GlassHeaderOverlay(
          liquid: true,
          headerExtent: headerExtent,
          headerTop: statusBarHeight,
          solidExtent: statusBarHeight,
          header: _buildHeader(context, extData),
          extra: [_buildScrollToTopFab(context)],
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.depth == 0 &&
                  notification.metrics.axis == Axis.vertical) {
                _showBackToTop.value = notification.metrics.pixels >= 300;
              }
              return false;
            },
            child: extData == null
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, extData, headerExtent),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    GalleryDownloadExtData extData,
    double headerExtent,
  ) {
    final t = slang.Translations.of(context);
    final currentTask = task;

    // 构建图片列表
    List<ImageItem> buildImageItems(
      GalleryDownloadExtData extData,
      DownloadTask? currentTask,
    ) {
      return extData.imageList.entries
          .map((entry) {
            final imageId = entry.key;
            final localPath = extData.localPaths[imageId];

            if (localPath == null || !File(localPath).existsSync()) {
              LogUtils.e(
                '图片本地文件不存在: $imageId',
                tag: 'GalleryDownloadTaskDetailPage',
              );
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
          })
          .whereType<ImageItem>()
          .toList();
    }

    final imageItems = buildImageItems(extData, currentTask);

    return SingleChildScrollView(
      controller: _scrollController,
      // ⛔ 让位只能靠**视口自己的** padding：在外面套一层 Padding 的话内容就
      // 滚不到 header 背后去了（见 [GlassHeaderOverlay] 的类文档）。
      padding: EdgeInsets.only(
        // +12：正文第一行（作者）不要贴着 header 的下沿开始。
        top: headerExtent + 12,
        bottom: computeBottomSafeInset(MediaQuery.of(context)) + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题不在这儿了：它现在是 header 那只 GlassTitlePill。
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
                        extData.authorUsername!,
                      )
                    : null,
                child: Row(
                  children: [
                    AvatarWidget(avatarUrl: extData.authorAvatar, size: 40),
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
            // 活跃任务（含暂停 / 失败）取内存真源，已完成任务没有动态状态可显示
            final currentTask = _observeTask();
            if (currentTask == null) {
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
            // 优先从内存真源获取，如果不存在则使用已加载的数据
            DownloadTask? currentTask = _observeTask();

            return LayoutBuilder(
              builder: (context, constraints) {
                // 计算列数，最少两列
                final columnCount = (constraints.maxWidth / 200).floor().clamp(
                  2,
                  4,
                ); // 200 是每列的最小宽度

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
                    final extension = path_lib
                        .extension(item.url)
                        .toLowerCase();
                    // ⛔ 这里曾经把 `.webm` 一律判成「不支持的图片格式」——图库里
                    // 混着的视频**现在能在大图页里放**（见 `GalleryVideoPlayer`），
                    // 那句话早就不是实情了。判定也不再自己数后缀，交给
                    // [ImageItem.isVideo] 一处（本地文件那条路它按
                    // `kGalleryVideoFileExtensions` 兜底）。
                    final bool isVideo = item.isVideo;

                    return Stack(
                      children: [
                        // 图片容器
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _onImageTap(context, item, imageItems),
                                child: isDownloaded
                                    ? isVideo
                                          // 视频格没有现成的缩略图地址，也不值得
                                          // 为一格几百像素再起一份 libmpv 去解首帧
                                          // ——摆一格认得出来的片头就够了，和大图页
                                          // 底下那条胶片同一套（[GalleryFilmstrip]）。
                                          ? const _VideoTile()
                                          : Image.file(
                                              File(
                                                item.url.replaceFirst(
                                                  'file://',
                                                  '',
                                                ),
                                              ),
                                              fit: BoxFit.cover,
                                              // 「不支持的格式」这句话留在这儿才诚实：
                                              // 走到这里说明这确实是一张**解不开的图**。
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => _UnsupportedTile(
                                                    extension: extension,
                                                  ),
                                            )
                                    : Image.network(
                                        item.url,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox(
                                                  height: 200,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.error_outline,
                                                    ),
                                                  ),
                                                ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        // 下载进度指示器
                        if (!isDownloaded &&
                            currentTask?.status == DownloadStatus.downloading)
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
                                      if (currentTask == null) {
                                        return const SizedBox.shrink();
                                      }
                                      final progress =
                                          DownloadService.to
                                              .getGalleryImageProgress(
                                                currentTask.id,
                                              )?[imageId] ??
                                          0;
                                      return Text(
                                        '${(progress * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
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
                              horizontal: 8,
                              vertical: 4,
                            ),
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
    );
  }

  // 构建图库下载进度指示器
  Widget _buildGalleryProgressIndicator(
    BuildContext context,
    DownloadTask task,
  ) {
    final progress = DownloadService.to.getGalleryDownloadProgress(task.id);
    if (progress == null) return const SizedBox.shrink();

    final totalImages = progress.length;
    final downloadedImages = progress.values
        .where((downloaded) => downloaded)
        .length;

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
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          // return '下载中 (${task.downloadedBytes}/${task.totalBytes}张 $progress%)';
          return t.download.downloadingProgressForImageProgress(
            downloaded: task.downloadedBytes,
            total: task.totalBytes,
            progress: progress,
          );
        } else {
          // return '下载中 (${task.downloadedBytes}张)';
          return t.download.downloadingSingleImageProgress(
            downloaded: task.downloadedBytes,
          );
        }
      case DownloadStatus.paused:
        if (task.totalBytes > 0) {
          final progress = (task.downloadedBytes / task.totalBytes * 100)
              .toStringAsFixed(1);
          // return '已暂停 (${task.downloadedBytes}/${task.totalBytes}张 $progress%)';
          return t.download.pausedProgressForImageProgress(
            downloaded: task.downloadedBytes,
            total: task.totalBytes,
            progress: progress,
          );
        } else {
          // return '已暂停 (已下载${task.downloadedBytes}张)';
          return t.download.pausedSingleImageProgress(
            downloaded: task.downloadedBytes,
          );
        }
      case DownloadStatus.completed:
        // return '下载完成 (共${task.totalBytes}张)';
        return t.download.downloadedProgressForImageProgress(
          total: task.totalBytes,
        );
      case DownloadStatus.failed:
        // return '下载失败';
        return t.download.errors.downloadFailed;
    }
  }
}

/// 网格里那一格视频。
///
/// 点它照样进大图页，在那儿真的会播（[GalleryVideoPlayer]）——所以这一格要读起来
/// 像「一段可以放的视频」，而不是像以前那样像一条报错。
class _VideoTile extends StatelessWidget {
  const _VideoTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ColoredBox(
        color: const Color(0xFF2A2A2A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                slang.Translations.of(context).common.video,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 真的解不开的那一格。
class _UnsupportedTile extends StatelessWidget {
  const _UnsupportedTile({required this.extension});

  /// 带点的后缀（`.psd`）。文案里原样报给用户。
  final String extension;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return SizedBox(
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
    );
  }
}
