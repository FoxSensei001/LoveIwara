import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_service.dart';
import 'package:i_iwara/app/ui/pages/frame_interp/frame_interp_launcher.dart';
import 'package:i_iwara/app/ui/pages/local_media/local_folder_route.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_info_dialog.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 这条能不能真删本机文件：NAS 条目不在本机；「设备视频」（`content://`）要走
/// 系统的删除授权，本模块还没有这条路。
///
/// ⛔ 以前只排除了 NAS：设备视频的菜单里照样有「删除」，点了必失败，失败提示还
/// 说「文件可能正被占用或没有权限」——一条永远走不通、原因还说错的路。
bool _canDeleteFile(LocalMediaItem item) =>
    !DavPath.isDav(item.path) && !item.path.startsWith('content://');

/// 本地媒体条目（视频 / 图片）的「更多操作」菜单。
///
/// 浏览页与各聚合 Tab（精选、所有视频、所有图片）共用这一份逻辑：
///   - 精选 / 取消精选（仅视频，见 [LocalMediaItem.supportsFavorite]）
///   - 设置封面（仅视频）
///   - 设为文件夹封面（仅在文件夹浏览且有可用封面源时展示）
///   - 删除（先物理删除磁盘文件，成功后再清理数据库条目行）
Future<void> showLocalMediaItemMenu({
  required BuildContext anchorContext,
  required LocalMediaItem item,
  String? folderCoverSource,
  VoidCallback? onSetAsFolderCover,
  VoidCallback? onChanged,
  void Function(LocalMediaItem item)? onDeleted,
  bool showRevealInFolder = true,

  /// 卡片自己的「打开」（带着这一栏的播放池与进度 id）。有补帧成品时菜单里
  /// 的「播放补帧版本 / 播放原视频」走它；不给就退回只带路径打开。
  Future<void> Function({required bool original})? onPlay,
}) async {
  final repo = LocalMediaRepository();
  // 图片没有精选（见 [LocalMediaItem.supportsFavorite]），连这一次查库都省掉。
  final isFavorited = item.supportsFavorite && repo.isItemFavorited(item.id);
  // NAS 条目不在本机：删不了本机文件，手选封面帧也还没有能读远端的播放器。
  final isRemote = DavPath.isDav(item.path);

  // 「在文件夹中显示」：聚合栏跨源平铺，这一条来自哪个目录只有跳过去才看得见。
  // 目录页里本来就站在那个目录上，调用点传 false。
  final folderRelPath = showRevealInFolder
      ? _folderRelPathOf(repo, item)
      : null;

  // 补帧只认本机普通视频文件（判据同 [_canDeleteFile]）；成品自己不再补帧。
  // 不按片源帧率拦：用户要的就是无条件翻倍（2026-11-21 用户要求去掉帧率上限）。
  final interp = FrameInterpService.maybe;
  final interpolatedPath = interp?.completedOutputFor(item.path);
  final canInterpolate =
      interp != null &&
      interpolatedPath == null &&
      item.kind == LocalMediaItemKind.video &&
      _canDeleteFile(item) &&
      isFrameInterpSupported &&
      !interp.isInterpolatedOutput(item.path);

  final action = await showGlassMenu<String>(
    anchorContext: anchorContext,
    entries: <GlassMenuEntry>[
      if (item.supportsFavorite)
        GlassMenuOption<String>(
          value: isFavorited ? 'unfavorite' : 'favorite',
          label: isFavorited
              ? slang.t.localMedia.browse.unfavorite
              : slang.t.localMedia.browse.favorite,
          icon: isFavorited ? Icons.star_border : Icons.star,
        ),
      if (item.kind == LocalMediaItemKind.video && !isRemote)
        GlassMenuOption<String>(
          value: 'cover',
          label: slang.t.localMedia.browse.setCover,
          icon: Icons.image_outlined,
        ),
      if (folderCoverSource != null)
        GlassMenuOption<String>(
          value: 'folderCover',
          label: slang.t.localMedia.browse.setAsFolderCover,
          icon: Icons.folder_special_outlined,
        ),
      // 原片和补帧成品是同一张卡（2026-11-21 用户要求），点卡片默认就播补帧版，
      // 菜单里只给「另一个版本」。⛔ 别再把「播放补帧版本」也列进来：用户点开
      // ⋮ 看到的头一条是默认已经在做的事，会以为默认播的是原片（用户原话：
      // 「既然默认是用补帧版本去观看的，为什么……出现的选项是播放补帧视频，
      // 而不是播放原视频？」）。
      if (interpolatedPath != null)
        GlassMenuOption<String>(
          value: 'playOriginal',
          label: slang.t.frameInterp.playOriginal,
          icon: Icons.movie_outlined,
        ),
      if (canInterpolate)
        GlassMenuOption<String>(
          value: 'interpolate',
          label: slang.t.frameInterp.action,
          icon: Icons.auto_awesome_motion_outlined,
        ),
      const GlassMenuSeparator(),
      if (folderRelPath != null)
        GlassMenuOption<String>(
          value: 'reveal',
          label: slang.t.localMedia.revealInFolder,
          icon: Icons.folder_open_outlined,
        ),
      GlassMenuOption<String>(
        value: 'info',
        label: slang.t.localMedia.itemInfo,
        icon: Icons.info_outline,
      ),
      // 只删补帧版、留原片。原片删不了的条目（NAS / 设备视频）本来也补不了帧，
      // 所以这里只看有没有现成成品。
      if (interpolatedPath != null)
        GlassMenuOption<String>(
          value: 'deleteInterpolated',
          label: slang.t.frameInterp.deleteInterpolatedOnly,
          icon: Icons.auto_delete_outlined,
          destructive: true,
        ),
      if (_canDeleteFile(item))
        GlassMenuOption<String>(
          value: 'delete',
          label: slang.t.common.delete,
          icon: Icons.delete_outline,
          destructive: true,
        ),
    ],
  );

  if (!anchorContext.mounted || action == null) return;

  if (action == 'favorite' || action == 'unfavorite') {
    final nextFavorited = action == 'favorite';
    final ok = repo.setItemFavorited(itemId: item.id, favorited: nextFavorited);
    if (ok) {
      showAppToast(
        nextFavorited
            ? slang.t.localMedia.browse.favorited
            : slang.t.localMedia.browse.unfavorited,
      );
      onChanged?.call();
    }
    return;
  }

  if (action == 'playOriginal') {
    if (onPlay != null) {
      await onPlay(original: true);
    } else {
      NaviService.navigateToLocalVideoPlayerPageFromPath(
        item.resolvePlaybackTarget(),
      );
    }
    return;
  }

  if (action == 'deleteInterpolated') {
    if (await confirmAndDeleteInterpolated(item.path)) onChanged?.call();
    return;
  }

  if (action == 'interpolate') {
    await requestFrameInterpolation(
      sourcePath: item.path,
      title: item.name,
      thumbnail: item.coverImagePath,
    );
    return;
  }

  if (action == 'reveal' && folderRelPath != null) {
    appRouter.push(
      LocalFolderRoute.location(
        sourceId: item.sourceId,
        relPath: folderRelPath,
      ),
    );
    return;
  }

  if (action == 'info') {
    await showLocalMediaItemInfoDialog(context: anchorContext, item: item);
    return;
  }

  if (action == 'folderCover' && folderCoverSource != null) {
    onSetAsFolderCover?.call();
    return;
  }

  if (action == 'cover') {
    final changed = await showLocalCoverPickerDialog(
      context: anchorContext,
      item: item,
    );
    if (changed && anchorContext.mounted) {
      onChanged?.call();
    }
    return;
  }

  if (action == 'delete') {
    // 有补帧成品时一并问一句：卡片是一张，用户眼里删的是「这部片子」。
    final interpTask = interpolatedPath == null
        ? null
        : interp?.taskForSource(item.path);
    final deleteInterpolated = ValueNotifier<bool>(true);
    final confirmed = await showGlassAlertDialog<bool>(
      title: slang.t.localMedia.browse.deleteFileTitle,
      content: interpTask == null
          ? Text(slang.t.localMedia.browse.deleteFileBody(name: item.name))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slang.t.localMedia.browse.deleteFileBody(name: item.name)),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: deleteInterpolated,
                  builder: (context, value, _) => SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: value,
                    onChanged: (v) => deleteInterpolated.value = v,
                    title: Text(slang.t.frameInterp.deleteInterpolated),
                    subtitle: Text(slang.t.frameInterp.deleteInterpolatedDesc),
                  ),
                ),
              ],
            ),
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () =>
              Navigator.of(anchorContext, rootNavigator: true).pop(false),
        ),
        GlassDialogAction(
          label: slang.t.common.delete,
          destructive: true,
          onPressed: () =>
              Navigator.of(anchorContext, rootNavigator: true).pop(true),
        ),
      ],
    );
    if (confirmed != true || !anchorContext.mounted) return;
    final withInterpolated = interpTask != null && deleteInterpolated.value;

    // ⛔ 顺序不能反：先删磁盘，成功了再删库行。
    //
    // ⛔ 「文件不在」**不等于**「删成功」。这里原来把 `exists() == false` 静默当成
    // 删掉了，于是两种情况会谎报成功、且连观看进度一起删掉：
    //   1. MediaStore 条目的 path 是 `content://…`，`File(...)` 根本不认这种 URI，
    //      exists 恒 false → 文件完好无损，库行没了，下次扫描原样扫回来；
    //   2. SD 卡没挂上 / 权限被回收 → 文件完好，库行和进度却被删了。
    // 这个模块到处都在用 `startsWith('content://')` 这套判据，唯独这里漏了。
    if (item.path.startsWith('content://')) {
      // MediaStore 的条目要走系统的删除授权流程，本模块还没有这条路；
      // 与其谎报成功、把库行和进度一起吞掉，不如明说这里删不了。
      showAppToast(
        slang.t.localMedia.browse.deleteFailed,
        type: AppToastType.error,
      );
      return;
    }

    final file = File(item.path);
    try {
      if (!await file.exists()) {
        // 文件不在。可能是真没了，也可能只是卷没挂上、目录读不到——后者删库行
        // 就是数据丢失。用目录是否可达来分辨，同
        // [LocalMediaWall._pruneMissing] 的判据。
        final directoryReachable = await Directory(file.parent.path).exists();
        if (!directoryReachable) {
          showAppToast(
            slang.t.localMedia.browse.deleteFailed,
            type: AppToastType.error,
          );
          return;
        }
        // 目录在、文件不在：确实已经没了，继续往下清库行。
      } else {
        await file.delete();
      }
    } catch (e) {
      LogUtils.w('删除文件失败: $e', 'LocalMediaItemMenu');
      showAppToast(
        slang.t.localMedia.browse.deleteFailed,
        type: AppToastType.error,
      );
      return;
    }

    // 补帧成品排在原片**删成功之后**：原片删不掉（权限、卷没挂上）时上面已经
    // return，用户看到「删除失败」，补帧版不该已经先没了。
    if (withInterpolated) {
      await interp!.delete(interpTask.id, deleteOutput: true);
    }

    try {
      repo.deleteItems(<String>[item.id]);
    } catch (e) {
      LogUtils.w('删除条目行失败: $e', 'LocalMediaItemMenu');
    }

    if (!anchorContext.mounted) return;
    showAppToast(slang.t.localMedia.browse.deleted);
    onDeleted?.call(item);
  }
}

/// 条目所在目录在目录树里的相对路径；没有目录树的源（已下载、设备视频）返回 null。
String? _folderRelPathOf(LocalMediaRepository repo, LocalMediaItem item) {
  final folderPath = item.folderPath;
  if (folderPath == null || folderPath.isEmpty) return null;
  return repo
      .findFolderByPath(sourceId: item.sourceId, folderPath: folderPath)
      ?.relPath;
}
