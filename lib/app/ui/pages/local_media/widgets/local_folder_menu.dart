import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_cover_picker_dialog.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_info_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 文件夹这一族（来源根 / 子目录）的「更多操作」**唯一**一份定义。
///
/// # ⛔ 外层卡片和内层详情页必须是同一份
///
/// 2026-09-11 用户报的第二件事：来源卡的 ⋮ 里根本没有「设为常用」，想把一个目录
/// 设成常用**必须先点进详情页**去按那颗 ☆；反过来详情页的 ⋮ 里又没有「设为封面」
/// 「恢复自动封面」「移除来源」。同一个东西，在外面能做的和进去之后能做的不是一套，
/// 用户得先猜自己站在哪一层才知道该怎么操作。
///
/// 所以这里把菜单拆成**列条目**（[entries]）和**执行动作**（[handle]）两半：
/// 卡片上的 ⋮ 直接用 [showLocalFolderMenu]（两半都用）；详情页要在同一张菜单里
/// 先摆排序，就自己拼 `[...排序项, 分隔线, ...actions.entries()]`，选中之后把不是
/// 排序的那一支交回 [handle]。两处从此不可能再各长各的。
///
/// ⛔ 新增能力**只能加在这里**，不许在任何调用点单独补一条——那正是上一版分家的
/// 起点（本项目已有明确要求：同类问题按机制修，见 `prefer-mechanism-fix-over-per-callsite`）。
class LocalFolderActions {
  const LocalFolderActions({
    required this.sourceId,
    required this.relPath,
    required this.folderPath,
    required this.pinned,
    required this.coverPinned,
    this.displayName = '',
    this.canRescan = false,
    this.canSetCover = true,
    this.onRemove,
    this.onRescan,
    this.onChanged,
  });

  final String sourceId;

  /// 源内相对路径。空串 = **来源根**，这时「重新扫描」是整源递归重扫，
  /// 非空则只重列这一层（见 [handle]）。
  final String relPath;

  final String? folderPath;
  final bool pinned;
  final bool coverPinned;
  final String displayName;
  final bool canRescan;

  /// 这个目录能不能挑封面。⚠️ 它只是个额外的闸门——真正的判据是**有没有一条能
  /// 用的绝对路径**，见 [_canSetCover]。
  final bool canSetCover;

  /// 封面选择器要靠绝对路径去列这个目录里的图片。
  ///
  /// ⛔ 没有真实目录树的源（「已下载」按任务同步、「设备视频」是系统媒体索引）
  /// 拿不到这条路径，摆出来就是一条点进去永远空白的项。判据放在这里而不是让每个
  /// 调用点各自去查 `source.kind`：调用点在卡片的 build 里，多查一次库就是滚动中
  /// 每帧一次同步查询。
  bool get _canSetCover =>
      canSetCover && folderPath != null && folderPath!.isNotEmpty;

  /// 「移除来源」。只有来源根那一层给得出来（子目录没有"移除"这回事）。
  final VoidCallback? onRemove;

  /// 覆盖「重新扫描」。内建「已下载」源不走扫描器，它是从 `download_tasks`
  /// 同步过来的（见 `DownloadsLibrarySyncService`），必须由调用点接管。
  final Future<void> Function()? onRescan;

  final VoidCallback? onChanged;

  bool get _isSourceRoot => relPath.isEmpty;

  /// 菜单条目。取值一律是 [String]，与详情页混在一起的排序项（[LocalMediaSort]）
  /// 天然分得开。
  List<GlassMenuEntry> entries() {
    final t = slang.t.localMedia;
    return <GlassMenuEntry>[
      GlassMenuOption<String>(
        value: pinned ? 'unpin' : 'pin',
        label: pinned ? t.browse.unpin : t.browse.pin,
        icon: pinned ? Icons.star_border : Icons.star,
        destructive: pinned,
      ),
      if (_canSetCover) ...[
        GlassMenuOption<String>(
          value: 'cover',
          label: t.browse.setFolderCoverPick,
          icon: Icons.image_outlined,
        ),
        if (coverPinned)
          GlassMenuOption<String>(
            value: 'restoreCover',
            label: t.browse.restoreAutoCover,
            icon: Icons.auto_awesome_outlined,
          ),
      ],
      const GlassMenuSeparator(),
      // 「文件夹信息」：只读，摆在这一组的头一条。
      //
      // ⛔ 它**不设开关**，任何一层都有——包括没有真实目录的那两个内建源
      // （「已下载」「设备视频」）：那两个源恰恰是用户最想问一句"这到底是什么"
      // 的，弹窗里会照实说它没有可打开的目录，而不是让这一条消失。
      GlassMenuOption<String>(
        value: 'info',
        label: t.browse.folderInfo,
        icon: Icons.info_outline,
      ),
      if (canRescan)
        GlassMenuOption<String>(
          value: 'rescan',
          // 来源根重扫的是整个源，子目录只重列这一层——文案得说的是实情。
          label: _isSourceRoot ? t.rescan : t.browse.rescanFolder,
          icon: Icons.refresh,
        ),
      if (onRemove != null)
        GlassMenuOption<String>(
          value: 'remove',
          label: t.remove,
          icon: Icons.remove_circle_outline,
          destructive: true,
        ),
    ];
  }

  /// 执行 [entries] 里选中的那一条。传进来的不是这张菜单的取值时静默放过——
  /// 详情页那张混合菜单会把排序项也递过来。
  Future<void> handle(BuildContext anchorContext, Object? action) async {
    if (action is! String) return;
    final repository = LocalMediaRepository();

    switch (action) {
      case 'pin':
        final effectiveDisplayName = displayName.isNotEmpty
            ? displayName
            : (repository.getSource(sourceId)?.displayName ?? '');
        repository.pinFolder(
          LocalPinnedFolder(
            id: LocalPinnedFolder.buildId(sourceId, relPath),
            sourceId: sourceId,
            relPath: relPath,
            displayName: effectiveDisplayName,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            sortOrder: repository.getPinnedFolders().length,
          ),
        );
        showAppToast(slang.t.localMedia.browse.pinned);
        onChanged?.call();

      case 'unpin':
        repository.unpinFolder(sourceId: sourceId, relPath: relPath);
        showAppToast(slang.t.localMedia.browse.unpinned);
        onChanged?.call();

      case 'cover':
        final resolved = (folderPath != null && folderPath!.isNotEmpty)
            ? folderPath!
            : (repository
                      .getFolder(sourceId: sourceId, relPath: relPath)
                      ?.folderPath ??
                  '');
        if (!anchorContext.mounted) return;
        final changed = await showLocalFolderCoverPickerDialog(
          context: anchorContext,
          sourceId: sourceId,
          relPath: relPath,
          folderPath: resolved,
        );
        if (changed) onChanged?.call();

      case 'restoreCover':
        if (repository.clearFolderCoverPin(
          sourceId: sourceId,
          relPath: relPath,
        )) {
          showAppToast(slang.t.localMedia.browse.autoCoverRestored);
          onChanged?.call();
        }

      case 'info':
        if (!anchorContext.mounted) return;
        await showLocalFolderInfoDialog(
          context: anchorContext,
          sourceId: sourceId,
          relPath: relPath,
          folderPath: folderPath,
          displayName: displayName,
        );

      case 'rescan':
        final override = onRescan;
        if (override != null) {
          await override();
          onChanged?.call();
          return;
        }
        final source = repository.getSource(sourceId);
        if (source == null) return;
        // ⛔ 「已下载」不走目录扫描：它是从 `download_tasks` 同步过来的
        // （`LocalMediaScanService.scanSource` 对这一类只会打一条日志就返回，
        // 也就是说这条菜单在详情页上一直是颗死钮）。调用点给了 [onRescan] 的
        // 就走它自己那条（来源卡要顺带点亮扫描转圈），没给就在这儿兜住。
        if (source.kind == LocalMediaSourceKind.downloads) {
          if (!Get.isRegistered<DownloadsLibrarySyncService>()) return;
          await DownloadsLibrarySyncService.to.sync();
          onChanged?.call();
          return;
        }
        if (!Get.isRegistered<LocalMediaScanService>()) return;
        try {
          // ⛔ 根这一层必须整源递归重扫：老来源（v31 之前加进来的）压根没有目录
          // 树，只重列根目录那一层的话，子目录还是一个都出不来。
          if (_isSourceRoot) {
            await LocalMediaScanService.to.scanSource(source);
          } else {
            await LocalMediaScanService.to.scanFolder(
              source: source,
              relPath: relPath,
            );
          }
          onChanged?.call();
        } catch (e) {
          LogUtils.w('目录级扫描失败: $e', 'LocalFolderMenu');
        }

      case 'remove':
        onRemove?.call();
    }
  }
}

/// 文件夹卡片（来源卡 / 子目录卡）的「更多操作」菜单：列条目 + 执行，一步到位。
///
/// 详情页那张菜单要先摆排序，所以它不走这个入口，而是自己拼
/// [LocalFolderActions.entries] 再交回 [LocalFolderActions.handle]。
Future<void> showLocalFolderMenu({
  required BuildContext anchorContext,
  required LocalFolderActions actions,
}) async {
  final action = await showGlassMenu<String>(
    anchorContext: anchorContext,
    entries: actions.entries(),
  );
  if (action == null || !anchorContext.mounted) return;
  await actions.handle(anchorContext, action);
}

/// 「移除来源」：确认 → 停掉这个源正在跑的扫描 → 删库行。返回真表示**真的删了**。
///
/// ⛔ 只此一份。外面（首页来源卡）和里面（目录详情页顶栏）都得能移除，而"删之前
/// 先 cancel 扫描"这一步一旦有人漏写，删掉的源还会被那一轮扫描继续往库里写。
/// 删完之后做什么由调用方决定：首页重查列表，详情页得把自己弹掉——它站的那个源
/// 已经不存在了。
Future<bool> confirmAndRemoveLocalSource({
  required BuildContext context,
  required LocalMediaSource source,
}) async {
  final t = slang.t.localMedia;
  final confirmed = await showGlassAlertDialog<bool>(
    title: t.removeSourceTitle(name: source.displayName),
    content: Text(t.removeSourceBody),
    actions: <GlassDialogAction>[
      GlassDialogAction(
        label: slang.t.common.cancel,
        emphasized: false,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
      ),
      GlassDialogAction(
        label: t.remove,
        destructive: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
      ),
    ],
  );
  if (confirmed != true) return false;
  if (Get.isRegistered<LocalMediaScanService>()) {
    LocalMediaScanService.to.cancel(source.id);
  }
  LocalMediaRepository().deleteSource(source.id);
  return true;
}
