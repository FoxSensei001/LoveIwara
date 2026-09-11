import 'dart:io';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

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
}) async {
  final repo = LocalMediaRepository();
  // 图片没有精选（见 [LocalMediaItem.supportsFavorite]），连这一次查库都省掉。
  final isFavorited = item.supportsFavorite && repo.isItemFavorited(item.id);

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
      if (item.kind == LocalMediaItemKind.video)
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
    final confirmed = await showGlassAlertDialog<bool>(
      title: slang.t.localMedia.browse.deleteFileTitle,
      content: Text(slang.t.localMedia.browse.deleteFileBody(name: item.name)),
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
