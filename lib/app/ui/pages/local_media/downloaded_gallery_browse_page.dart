import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_image_viewer.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_relocation_flow.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/media_waterfall_grid.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

const String _tag = 'DownloadedGalleryBrowsePage';

/// 已下载图库浏览页：沿用打开文件夹的视觉形式浏览本地下载完成的图库。
///
/// # 为什么以打开文件夹的形式浏览
///
/// 2026-09-11 用户要求：「本地文件里已下载模块的打开图库，我希望是以沿用打开
/// 文件夹的那种形式去浏览，并且这里也要有判断资源是否存在，如果不存在就删除的逻辑，
/// 以及让用户手动删除的更多按钮菜单」。
///
/// 此前的入口跳到了下载管理的任务详情页（[GalleryDownloadTaskDetailPage]），
/// 顶部大块下载状态和作者头像更偏向任务管理；而用户在「本地文件」视角下的心智
/// 是「打开这个文件夹看图」。因此本页沿用 [LocalFolderBrowsePage] 的视觉架构：
///
/// 1. 顶栏：[GlassHeaderOverlay] + 返回圆钮 + 标题胶囊 [GlassTitlePill] + 更多操作 [GlassIconButton]。
/// 2. 主体：[MediaWaterfallSliver] 统一瀑布流网格，列数与间距严格遵循 [MediaLayoutUtils]。
/// 3. 图片点击：调用 [pushPhotoViewWrapperOverlay] 进行大图相册滑动浏览与手势缩放。
/// 4. 资源存在性校验：进入时若本地资源已不存在（目录与图片均被外部删除），自动调用
///    `deleteTask` 清理失效记录并提示后退出。
/// 5. 更多按钮菜单：支持在顶栏和卡片上随时手动删除图库。
class DownloadedGalleryBrowsePage extends StatefulWidget {
  const DownloadedGalleryBrowsePage({super.key, required this.taskId});

  final String taskId;

  @override
  State<DownloadedGalleryBrowsePage> createState() =>
      _DownloadedGalleryBrowsePageState();
}

class _DownloadedGalleryBrowsePageState
    extends State<DownloadedGalleryBrowsePage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  DownloadTask? _task;
  GalleryDownloadExtData? _galleryData;

  /// 有效的本地图片列表（按图库原始顺序排列）。
  ///
  /// 每项记录：原始 imageId、已落盘的绝对路径、1-based 序号。
  List<({String id, String path, int index})> _validImages = const [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  String get _title {
    final title = _galleryData?.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    final taskName = _task?.fileName.trim();
    if (taskName != null && taskName.isNotEmpty) return taskName;
    return slang.t.localMedia.browse.galleriesSection;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      DownloadTask? task;
      if (Get.isRegistered<DownloadService>()) {
        task =
            DownloadService.to.store.taskOf(widget.taskId) ??
            DownloadService.to.tasks[widget.taskId] ??
            await DownloadService.to.repository.getTaskById(widget.taskId);
      }

      if (task == null) {
        LogUtils.w('图库下载任务不存在: taskId=${widget.taskId}', _tag);
        if (!mounted) return;
        showAppToast(
          slang.t.localMedia.browse.galleryResourceMissing,
          type: AppToastType.warning,
        );
        AppService.tryPop();
        return;
      }

      final ext = task.extData;
      if (ext == null || ext.type != DownloadTaskExtDataType.gallery) {
        LogUtils.w('任务不是图库类型: taskId=${widget.taskId}', _tag);
        if (!mounted) return;
        showAppToast(
          slang.t.localMedia.browse.galleryResourceMissing,
          type: AppToastType.warning,
        );
        AppService.tryPop();
        return;
      }

      final galleryData = GalleryDownloadExtData.fromJson(ext.data);

      // ── 检查本地资源是否存在 ──────────────────────────────────────────
      //
      // ⛔ 逐张 `existsSync` 放到后台 isolate：一个几百张的图库就是几百次同步
      // stat，摆在主 isolate 上是进页那一下的长卡顿。期间标题胶囊照旧转圈
      // （`busy: _loading`）。
      final candidates = <(String, String)>[
        for (final id in galleryData.imageList.keys)
          if (galleryData.localPaths[id]?.trim() case final localPath?
              when localPath.isNotEmpty)
            (id, localPath),
      ];
      final checked = await compute(_checkGalleryFiles, (
        task.savePath,
        candidates,
      ));
      if (!mounted) return;
      final dirExists = checked.dirExists;
      final validImages = checked.images;

      // 目录不在、一张图也摸不到。⛔ 不能就此认定「被删了」自动删记录：
      // SD 卡没插、用户自己挪过文件夹、iOS 更新换了容器，都长这样。
      // 交给用户：去别处找回（找到就重新加载），或确认删记录。
      if (!dirExists && validImages.isEmpty) {
        LogUtils.w('图库本地资源找不到: taskId=${widget.taskId}', _tag);
        if (!mounted) return;
        final outcome = await showMissingDownloadDialog(task);
        if (!mounted) return;
        if (outcome == MissingDownloadOutcome.located) {
          await _loadData();
          return;
        }
        AppService.tryPop();
        return;
      }

      if (!mounted) return;
      setState(() {
        _task = task;
        _galleryData = galleryData;
        _validImages = validImages;
        _loading = false;
      });
    } catch (e, s) {
      LogUtils.e('加载图库失败: $e', tag: _tag, error: e, stackTrace: s);
      if (!mounted) return;
      showAppToast(
        slang.t.localMedia.browse.galleryResourceMissing,
        type: AppToastType.warning,
      );
      AppService.tryPop();
    }
  }

  void _openImage(int index) {
    if (_validImages.isEmpty) return;
    final initial = _validImages[index.clamp(0, _validImages.length - 1)];
    openLocalImageViewer(
      context,
      _validImages.map((img) => img.path).toList(),
      initial.path,
      // 图库里混着的视频：把它那张静图海报的地址一并交出去，空间画廊的胶片格
      // 才有封面可画（本地已经存过就直接用本地那张，见 [ensureGalleryVideoPoster]）。
      videoPosterUrls: <String, String>{
        for (final img in _validImages)
          if (isGalleryVideoFileName(img.path))
            img.path: iwaraPosterUrlFrom(_galleryData?.imageList[img.id] ?? ''),
      },
    );
  }

  Future<void> _showMoreMenu(BuildContext anchorContext) async {
    final t = slang.t;
    final galleryId = _galleryData?.id;

    final entries = <GlassMenuEntry>[
      GlassMenuOption<String>(
        value: 'detail',
        label: t.localMedia.browse.viewDownloadDetail,
        icon: Icons.download_done_rounded,
      ),
      if (galleryId != null && galleryId.isNotEmpty)
        GlassMenuOption<String>(
          value: 'online',
          label: t.localMedia.browse.viewOnlineGallery,
          icon: Icons.public,
        ),
      const GlassMenuSeparator(),
      GlassMenuOption<String>(
        value: 'delete',
        label: t.download.deleteTask,
        icon: Icons.delete_outline,
        destructive: true,
      ),
    ];

    final selected = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: entries,
    );

    if (!mounted || selected == null) return;

    switch (selected) {
      case 'detail':
        NaviService.navigateToGalleryDownloadTaskDetailPage(widget.taskId);
        break;
      case 'online':
        if (galleryId != null) {
          NaviService.navigateToGalleryDetailPage(galleryId);
        }
        break;
      case 'delete':
        if (!anchorContext.mounted) return;
        _confirmDelete(anchorContext);
        break;
    }
  }

  void _confirmDelete(BuildContext context) {
    final t = slang.t;
    showAppDialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassAlertDialog(
            title: t.localMedia.browse.deleteGalleryTitle,
            content: Text(t.localMedia.browse.deleteGalleryBody(name: _title)),
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
                onPressed: () async {
                  AppService.tryPop(); // 关闭弹窗
                  if (Get.isRegistered<DownloadService>()) {
                    await DownloadService.to.deleteTask(
                      widget.taskId,
                      ignoreFileDeleteError: true,
                    );
                  }
                  showAppToast(t.localMedia.browse.deleted);
                  if (mounted) {
                    AppService.tryPop(); // 退出图库浏览页
                  }
                },
              ),
            ],
          ),
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        size: 24,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildScrollToTopFab(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: computeBottomSafeInset(MediaQuery.of(context)) + 16,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => ScrollToTopFab(
          visible: visible,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = slang.t;
    final galleryId = _galleryData?.id;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
          header: Padding(
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
                  child: GlassTitlePill(title: _title, busy: _loading),
                ),
                const SizedBox(width: 8),
                GlassButtonGroup(
                  children: [
                    if (galleryId != null && galleryId.isNotEmpty)
                      GlassIconButton(
                        icon: const Icon(Icons.photo_library),
                        tooltip: t.localMedia.browse.viewOnlineGallery,
                        onPressed: () =>
                            NaviService.navigateToGalleryDetailPage(galleryId),
                      ),
                    Builder(
                      builder: (menuContext) => GlassIconButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: t.common.more,
                        opensOverlay: true,
                        onPressed: () => _showMoreMenu(menuContext),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          extra: [_buildScrollToTopFab(context)],
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.depth == 0 &&
                  notification.metrics.axis == Axis.vertical) {
                _showBackToTop.value = notification.metrics.pixels >= 300;
              }
              return false;
            },
            child: RefreshIndicator(
              displacement: headerExtent,
              onRefresh: _loadData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth - 32;
                  final crossAxisCount =
                      MediaLayoutUtils.calculateCrossAxisCount(availableWidth);

                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: SizedBox(height: headerExtent)),
                      if (_validImages.isNotEmpty) ...[
                        _buildSectionHeader(
                          t.localMedia.browse.imageCount(
                            count: _validImages.length,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: MediaWaterfallSliver(
                            crossAxisCount: crossAxisCount,
                            itemCount: _validImages.length,
                            itemBuilder: (context, index, itemWidth) {
                              final item = _validImages[index];
                              // Iwara 的图库里混着短片（`.webm`），下载下来就躺在
                              // 同一个文件夹里。⛔ 这一格必须看得出「是一段视频」：
                              // 它解不成位图，不加记号的话就只剩一格灰占位，读起来
                              // 像「这张图坏了」。时长要解容器才知道，这条路上没有
                              // 派生服务，所以只给三角不给数字（[LocalPlaybackPill]
                              // 本来就允许没有时长）。
                              final isVideo = isGalleryVideoFileName(item.path);
                              return GestureDetector(
                                onTap: () => _openImage(index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // 视频那一格画的是它旁边那张封面；不在就照
                                        // 任务里存的地址取一次存下来（见
                                        // [ensureGalleryVideoPoster]）。
                                        LocalCoverImage(
                                          path: item.path,
                                          posterUrl: isVideo
                                              ? iwaraPosterUrlFrom(
                                                  _galleryData?.imageList[item
                                                          .id] ??
                                                      '',
                                                )
                                              : null,
                                          placeholder: _buildImagePlaceholder(
                                            context,
                                          ),
                                        ),
                                        if (isVideo)
                                          const Positioned(
                                            right: 6,
                                            bottom: 6,
                                            child: LocalPlaybackPill(),
                                          ),
                                        // 序号胶囊角标
                                        Positioned(
                                          top: LocalContainerCard.badgeInset,
                                          left: LocalContainerCard.badgeInset,
                                          child: LocalCardBadge(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                  ),
                                              child: Text(
                                                '#${item.index}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (_validImages.isEmpty && !_loading)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  t.localMedia.browse.emptyFolder,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [_DownloadedGalleryBrowsePageState._loadData] 的后台那一半：落盘目录还在不在、
/// 哪几张图还在（保持图库原始顺序，序号从 1 起按「还在的」重排）。
///
/// ⛔ 顶层函数、只碰参数：跑在另一个 isolate 上。
({bool dirExists, List<({String id, String path, int index})> images})
_checkGalleryFiles((String, List<(String, String)>) input) {
  final (savePath, candidates) = input;
  final dirExists = savePath.isNotEmpty && Directory(savePath).existsSync();
  final images = <({String id, String path, int index})>[];
  var index = 1;
  for (final (id, path) in candidates) {
    if (File(path).existsSync()) {
      images.add((id: id, path: path, index: index++));
    }
  }
  return (dirExists: dirExists, images: images);
}
