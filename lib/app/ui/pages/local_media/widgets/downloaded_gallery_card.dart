import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_relocation_flow.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

const String _tag = 'DownloadedGalleryCard';

/// 一格所需要的全部东西，从下载任务里榨一次就不再回头看任务对象。
///
/// ⛔ **这一族（行 + 卡）有两个调用方**，改之前两边都要想到：
/// `DownloadedGalleryWall`（「下载完成图库」那一栏，分页）和
/// `LocalFolderBrowsePage`（「文件目录 › 已下载」的根层，硬上限 500）。
/// 它们从前各画各的，2026-09-11 用户报「割裂」后收口到这里——别再抄第三份。
/// 为什么图库不进本地库、封面为什么只认已落盘的本地图，见
/// [DownloadedGalleryWall] 的类注释。
class DownloadedGalleryRow {
  const DownloadedGalleryRow({
    required this.taskId,
    required this.title,
    required this.coverPath,
    required this.imageCount,
    this.coverPosterUrl,
    this.savePath,
    this.galleryId,
  });

  final String taskId;
  final String title;

  /// 封面：**已经躺在磁盘上的第一张图**。
  ///
  /// ⛔ 不用 `preview_urls` 那几条在线预览图：这一栏说的就是"东西已经在机器上
  /// 了"，封面却要联网才画得出来，离线时整面墙就是一排占位图。拿不到本地路径
  /// 时宁可留 null，占位图至少不撒谎。
  final String? coverPath;

  /// [coverPath] 指向一段**视频**时，它那张静图海报的网络地址。
  ///
  /// 封面本身还是要落到本地文件（见 [ensureGalleryVideoPoster]）——这条地址只是
  /// 「本地还没有时上哪儿取一次」。图片封面用不着它，恒为 null。
  final String? coverPosterUrl;

  final int imageCount;

  /// 本地图库落盘目录路径（`task.savePath`）。
  final String? savePath;

  /// 线上图库 ID（如果有）。
  final String? galleryId;

  /// ⛔ 单条脏 `ext_data` 只能丢这一条，不能把整页掀了。
  ///
  /// 没有这个 try 的话，[GalleryDownloadExtData.fromJson] 抛出来会被上面
  /// `_loadMore` 的 catch 接住并把 `_exhausted` 置成 true——一行坏数据让整栏
  /// **永久**停止加载，用户看到的是「下载过的图库少了一半」。
  static DownloadedGalleryRow? of(DownloadTask task) {
    try {
      return _parse(task);
    } catch (e) {
      LogUtils.w('跳过解析失败的图库下载任务 ${task.id}: $e', _tag);
      return null;
    }
  }

  /// 同 [of]，但把整批解析挪到后台 isolate 上做。
  ///
  /// 一个几百张的图库，`image_list` / `local_paths` 两张表就是几百项；500 个图库
  /// 摆在主 isolate 上现解，就是进「已下载」那一下的一次长卡顿。
  ///
  /// ⛔ 只把**纯数据**（任务 id / 文件名 / 落盘目录 / ext_data 那张 Map）送过去，
  /// 不送 [DownloadTask] 本体；解析失败的 id 带回主 isolate 再记日志——后台
  /// isolate 里没有日志服务可用。
  static Future<List<DownloadedGalleryRow>> parseAllInBackground(
    List<DownloadTask> tasks,
  ) async {
    final inputs = <_GalleryRowInput>[
      for (final task in tasks)
        if (task.extData?.type == DownloadTaskExtDataType.gallery)
          (
            taskId: task.id,
            fileName: task.fileName,
            savePath: task.savePath,
            data: task.extData!.data,
          ),
    ];
    if (inputs.isEmpty) return const <DownloadedGalleryRow>[];
    final result = await compute(_parseGalleryRowInputs, inputs);
    for (final failure in result.failures) {
      LogUtils.w('跳过解析失败的图库下载任务 $failure', _tag);
    }
    return result.rows;
  }

  static DownloadedGalleryRow? _parse(DownloadTask task) {
    final ext = task.extData;
    if (ext == null || ext.type != DownloadTaskExtDataType.gallery) return null;
    return _fromData(
      taskId: task.id,
      fileName: task.fileName,
      savePath: task.savePath,
      json: ext.data,
    );
  }

  static DownloadedGalleryRow _fromData({
    required String taskId,
    required String fileName,
    required String savePath,
    required Map<String, dynamic> json,
  }) {
    final data = GalleryDownloadExtData.fromJson(json);
    // `image_list` 的键序就是图库里的原始顺序（JSON 对象保序）。
    //
    // ⛔ 挑封面**优先静图**：图库里混着的 webm 要先解一帧才画得出来
    // （[LocalCoverImage] 会去做，见 [LocalMediaDerivationService.posterForFile]），
    // 而现成的静图一次 `Image.file` 就够。一张静图都没有时才回头用那段视频。
    String? cover;
    String? videoCover;
    String? videoCoverId;
    for (final id in data.imageList.keys) {
      final local = data.localPaths[id]?.trim();
      if (local == null || local.isEmpty) continue;
      if (isGalleryVideoFileName(local)) {
        if (videoCover == null) {
          videoCover = local;
          videoCoverId = id;
        }
        continue;
      }
      cover = local;
      break;
    }
    final title = data.title?.trim();
    return DownloadedGalleryRow(
      taskId: taskId,
      title: title == null || title.isEmpty ? fileName : title,
      coverPath: cover ?? videoCover,
      coverPosterUrl: cover == null && videoCover != null
          ? iwaraPosterUrlFrom(data.imageList[videoCoverId] ?? '')
          : null,
      imageCount: data.totalImages > 0
          ? data.totalImages
          : data.imageList.length,
      savePath: savePath,
      galleryId: data.id,
    );
  }
}

typedef _GalleryRowInput = ({
  String taskId,
  String fileName,
  String savePath,
  Map<String, dynamic> data,
});

/// [DownloadedGalleryRow.parseAllInBackground] 的后台那一半。
///
/// ⛔ 顶层函数、只碰参数：跑在另一个 isolate 上，不能摸任何单例或日志服务。
({List<DownloadedGalleryRow> rows, List<String> failures})
_parseGalleryRowInputs(List<_GalleryRowInput> inputs) {
  final rows = <DownloadedGalleryRow>[];
  final failures = <String>[];
  for (final input in inputs) {
    try {
      rows.add(
        DownloadedGalleryRow._fromData(
          taskId: input.taskId,
          fileName: input.fileName,
          savePath: input.savePath,
          json: input.data,
        ),
      );
    } catch (e) {
      failures.add('${input.taskId}: $e');
    }
  }
  return (rows: rows, failures: failures);
}

class DownloadedGalleryCard extends StatelessWidget {
  const DownloadedGalleryCard({super.key, required this.row, this.onDeleted});

  static double extentFor(BuildContext context, double cellWidth) =>
      LocalContainerCard.extentFor(context, cellWidth);

  final DownloadedGalleryRow row;
  final VoidCallback? onDeleted;

  /// 检查资源是否存在：目录和封面都摸不到时先问用户（找回 / 删记录），再决定进不进。
  Future<void> _handleOpen(BuildContext context) async {
    final dirExists =
        row.savePath != null &&
        row.savePath!.isNotEmpty &&
        Directory(row.savePath!).existsSync();
    final coverExists =
        row.coverPath != null &&
        row.coverPath!.isNotEmpty &&
        File(row.coverPath!).existsSync();

    // 找不到不等于删掉了（SD 卡没插 / 文件夹被挪过），由用户决定找回还是删记录。
    if (!dirExists && !coverExists) {
      LogUtils.w('图库本地资源找不到: taskId=${row.taskId}', _tag);
      final task = Get.isRegistered<DownloadService>()
          ? await DownloadService.to.repository.getTaskById(row.taskId)
          : null;
      if (task == null) {
        onDeleted?.call();
        return;
      }
      // 行数据可能是重新定位之前查的：以库里的最新路径为准再看一眼。
      if (!Directory(task.savePath).existsSync()) {
        final outcome = await showMissingDownloadDialog(task);
        if (outcome == MissingDownloadOutcome.deleted) onDeleted?.call();
        if (outcome != MissingDownloadOutcome.located) return;
      }
    }

    NaviService.navigateToDownloadedGalleryBrowsePage(row.taskId);
  }

  Future<void> _showMenu(BuildContext anchorContext) async {
    final t = slang.t;
    final entries = <GlassMenuEntry>[
      GlassMenuOption<String>(
        value: 'open',
        label: t.localMedia.browse.openFolder,
        icon: Icons.folder_open_outlined,
      ),
      GlassMenuOption<String>(
        value: 'detail',
        label: t.localMedia.browse.viewDownloadDetail,
        icon: Icons.download_done_rounded,
      ),
      if (row.galleryId != null && row.galleryId!.isNotEmpty)
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

    if (selected == null || !anchorContext.mounted) return;

    switch (selected) {
      case 'open':
        await _handleOpen(anchorContext);
        break;
      case 'detail':
        NaviService.navigateToGalleryDownloadTaskDetailPage(row.taskId);
        break;
      case 'online':
        if (row.galleryId != null) {
          NaviService.navigateToGalleryDetailPage(row.galleryId!);
        }
        break;
      case 'delete':
        _showDeleteConfirmDialog(anchorContext);
        break;
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final t = slang.t;
    showAppDialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassAlertDialog(
            title: t.localMedia.browse.deleteGalleryTitle,
            content: Text(
              t.localMedia.browse.deleteGalleryBody(name: row.title),
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
                onPressed: () async {
                  AppService.tryPop();
                  if (Get.isRegistered<DownloadService>()) {
                    await DownloadService.to.deleteTask(
                      row.taskId,
                      ignoreFileDeleteError: true,
                    );
                  }
                  showAppToast(t.localMedia.browse.deleted);
                  onDeleted?.call();
                },
              ),
            ],
          ),
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LocalContainerCard(
      onTap: () => _handleOpen(context),
      onMenu: (cardContext) => _showMenu(cardContext),
      cover: _buildCover(context),
      // 一枚下载完成的角标：这一族卡片（目录/来源/图库）长得一样，得有个记号说
      // 清"这一格是应用下载来的"。
      leading: LocalCardBadge(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.download_done_rounded,
            size: 15,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      title: row.title,
      titleIcon: Icons.photo_library_outlined,
      countIcon: Icons.photo_library_outlined,
      itemCount: row.imageCount,
      meta: LocalCardText.metaText(
        context,
        slang.t.localMedia.browse.imageCount(count: row.imageCount),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.photo_library_rounded,
          size: 30,
          color: colorScheme.outline,
        ),
      ),
    );
    final path = row.coverPath;
    if (path == null) return placeholder;
    // 下载下来的原图可能有几千像素宽，解码尺寸归 [LocalCoverImage]；整本都是视频时
    // 由它去拿视频旁边那张封面（不在就照 [coverPosterUrl] 取一次存下来）。
    return LocalCoverImage(
      path: path,
      posterUrl: row.coverPosterUrl,
      placeholder: placeholder,
    );
  }
}
