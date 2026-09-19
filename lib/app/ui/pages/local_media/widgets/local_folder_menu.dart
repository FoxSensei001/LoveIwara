import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/services/webdav/webdav_service.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_cover_picker_dialog.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_info_dialog.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_webdav_connect_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_saved_items_drawer.dart'
    show showGlassPromptNameDialog;
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
    this.hidden = false,
    this.displayName = '',
    this.canRescan = false,
    this.canSetCover = true,
    this.onRemove,
    this.onRescan,
    this.onChanged,
    this.onDeleted,
    this.onHidden,
  });

  final String sourceId;

  /// 源内相对路径。空串 = **来源根**，这时「重新扫描」是整源递归重扫，
  /// 非空则只重列这一层（见 [handle]）。
  final String relPath;

  final String? folderPath;
  final bool pinned;
  final bool coverPinned;

  /// 这个目录此刻是不是被隐藏的。菜单据此在「隐藏此文件夹 / 取消隐藏」之间换脸。
  ///
  /// ⚠️ 由调用点给（它们本来就要一份隐藏集合去把卡片画成半透明），这里不自己查库
  /// ——菜单每开一次查一遍不算什么，但卡片那侧本来就有，两处各查各的迟早说不一样的话。
  final bool hidden;
  final String displayName;
  final bool canRescan;

  /// 这个目录能不能挑封面。⚠️ 它只是个额外的闸门——真正的判据见 [_canSetCover]：
  /// 有绝对路径就从目录直属的图里挑，没有（平的源）就从整个源里挑。
  final bool canSetCover;

  /// 这个目录能不能挑封面。
  ///
  /// 有绝对路径的目录从**目录直属**的图里挑；没有真实目录树的源（「已下载」按任务
  /// 同步、「设备视频」是系统媒体索引）只有源根这一层，从**整个源**里挑。
  ///
  /// ⛔ 以前这里要求必须有绝对路径，于是「已下载」上连「设为封面」这一条都不出现
  /// ——卡片空着，用户也没有任何办法自己给它一张图（2026-09-11 用户报的）。更深的
  /// 一层没有路径是真的出了问题，那时仍然不给。
  bool get _canSetCover =>
      canSetCover &&
      // NAS 目录：挑封面的弹窗按本机路径 `Image.file` 画候选图，远端的画不出来。
      // 等远端图片走本机缓存之后再开。
      !DavPath.isDav(folderPath) &&
      ((folderPath != null && folderPath!.isNotEmpty) || _isSourceRoot);

  /// 「移除来源」。只有来源根那一层给得出来（子目录没有"移除"这回事）。
  final VoidCallback? onRemove;

  /// 覆盖「重新扫描」。内建「已下载」源不走扫描器，它是从 `download_tasks`
  /// 同步过来的（见 `DownloadsLibrarySyncService`），必须由调用点接管。
  final Future<void> Function()? onRescan;

  final VoidCallback? onChanged;

  /// 这个目录**刚被隐藏**之后叫谁。没给就退回 [onChanged]。
  ///
  /// 站在这一层的详情页要用它决定去留：「显示隐藏的文件夹」关着的时候，用户刚把
  /// 脚下这一层藏起来，页面却还开着——那是一页"按约定不该存在"的内容。
  final VoidCallback? onHidden;

  /// 这个目录**被真删了**之后叫谁。没给就退回 [onChanged]。
  ///
  /// ⛔ 站在这一层的详情页必须给：它整页的内容都来自那个目录，删完留在原地就是
  /// 一屏空壳，顶栏那些动作还都点得动（同 `confirmAndRemoveLocalSource` 删完要 pop
  /// 的理由）。卡片上的 ⋮ 不用给，重查一次列表就够。
  final VoidCallback? onDeleted;

  bool get _isSourceRoot => relPath.isEmpty;

  bool get _isRemoteSource =>
      DavPath.isDav(folderPath) ||
      (LocalMediaRepository().getSource(sourceId)?.isRemote ?? false);

  /// 来源根可以改名（内建源的名字由应用给，不给改）。
  bool get _canRename {
    if (!_isSourceRoot) return false;
    final source = LocalMediaRepository().getSource(sourceId);
    return source != null && !source.isBuiltIn && !source.isInert;
  }

  /// 来源根上给「扫描 . 开头的文件夹」。
  ///
  /// ⛔ iOS 的书签源不给：「文件」App 本来就不显示 `.` 开头的目录，用户无从知道
  /// 它们存在，这一条只会是噪音。内建源（已下载 / 设备视频）不走目录遍历，也不给。
  bool get _canToggleDotFolders {
    if (!_isSourceRoot) return false;
    final kind = LocalMediaRepository().getSource(sourceId)?.kind;
    return kind == LocalMediaSourceKind.directory ||
        kind == LocalMediaSourceKind.webdav;
  }

  bool get _includeDotFolders =>
      LocalMediaRepository().getSource(sourceId)?.includeDotEntries ?? false;

  /// 这个目录能不能**真删**（磁盘 + 库）。
  ///
  /// ⛔ 来源根一律不给。它已经有「移除来源」（只解除关联、不动磁盘），而把一个源的
  /// 根目录连同里面的一切从磁盘上抹掉是这个模块能做的最重的事——它不该和"删个子
  /// 文件夹"长在同一条菜单项上，更不该和只是"移除"的那一条挨着，点错的代价不对等。
  ///
  /// ⛔ 没有绝对路径 / `content://` 的也不给：「已下载」按任务同步、「设备视频」是
  /// 系统媒体索引，两者都没有可删的真目录（同 `local_media_item_menu.dart` 里
  /// 那条 `content://` 判据——那次的教训是漏了它就会谎报"删掉了"）。
  bool get _canDeleteFolder =>
      _hasRealFolderTree &&
      // ⛔ NAS 目录不在本机：`Directory(path).delete` 碰的会是本机磁盘。
      !DavPath.isDav(folderPath);

  /// 不是来源根、有一条真目录路径（不是 `content://`、不是平的源）。
  bool get _hasRealFolderTree {
    if (_isSourceRoot) return false;
    final path = folderPath;
    if (path == null || path.isEmpty) return false;
    return !path.startsWith('content://');
  }

  /// 这个目录能不能隐藏。判据与 [_canDeleteFolder] 同源（只是不排除 NAS）：
  ///
  /// ⛔ 来源根不给。整个源在目录树里消失，用户第一反应是"我加的文件夹没了"，
  /// 而「显示隐藏的文件夹」那个开关在根页上够不着它（根页画的是**来源卡**，
  /// 不是目录卡）。不想看某个源，那是「移除来源」。
  ///
  /// 没有真实目录树的源（`content://`、平的源）也不给：隐藏的另一半价值是
  /// 「扫描不进去」，而它们根本不走目录遍历，藏了只是半件事。
  ///
  /// NAS 目录可以藏：隐藏只是库里的一句用户意图，不碰文件。
  bool get _canHideFolder => _hasRealFolderTree;

  /// 「显示隐藏的文件夹」此刻开着没有。读不到配置就当关着。
  static bool get showHiddenFolders {
    if (!Get.isRegistered<ConfigService>()) return false;
    return Get.find<ConfigService>()[ConfigKey
            .LOCAL_MEDIA_SHOW_HIDDEN_FOLDERS_KEY] ==
        true;
  }

  /// 这台设备上**存在**被隐藏的目录（跨源）。只在开菜单时问一次库。
  bool get _hasHiddenFolders =>
      LocalMediaRepository().getHiddenFolders().isNotEmpty;

  /// 菜单条目。取值一律是 [String]，与详情页混在一起的排序项（[LocalMediaSort]）
  /// 天然分得开。
  List<GlassMenuEntry> entries() {
    final t = slang.t.localMedia;
    return <GlassMenuEntry>[
      GlassMenuOption<String>(
        value: pinned ? 'unpin' : 'pin',
        label: pinned ? t.browse.unpin : t.browse.pin,
        icon: pinned ? Icons.push_pin_outlined : Icons.push_pin,
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
      // 「扫描 . 开头的文件夹」跟着「重新扫描」：两条都在回答"这个源扫什么"。
      // ⛔ 它和下面「显示隐藏的文件夹」是两回事——那边是用户自己藏的目录，这边是
      // 名字以 `.` 开头的目录。文案里刻意不出现「隐藏」二字，别让两条撞名。
      if (_canToggleDotFolders)
        GlassMenuOption<String>(
          value: 'toggleDotFolders',
          label: t.browse.includeDotFolders,
          icon: Icons.folder_open_outlined,
          selected: _includeDotFolders,
        ),
      // 「显示隐藏的文件夹」是个**视图开关**，不是对这个目录做什么——所以它摆在
      // 分隔线之后、和「隐藏此文件夹」挨着：用户刚藏完一个、想反悔时，反悔的路
      // 就在原地。
      //
      // ⛔ 一个隐藏目录都没有、开关也没开时不出现：那是一条对谁都没用的选项，
      // 而这张菜单已经不短了。开关开着时必须出现，否则用户关不掉它。
      if (showHiddenFolders || _hasHiddenFolders)
        GlassMenuOption<String>(
          value: 'toggleShowHidden',
          label: t.browse.showHiddenFolders,
          icon: showHiddenFolders
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          selected: showHiddenFolders,
        ),
      if (_canHideFolder)
        GlassMenuOption<String>(
          value: hidden ? 'unhide' : 'hide',
          label: hidden ? t.browse.unhideFolder : t.browse.hideFolder,
          icon: hidden
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      if (_canRename)
        GlassMenuOption<String>(
          value: 'rename',
          label: t.renameSource,
          icon: Icons.drive_file_rename_outline,
        ),
      // NAS 源根：改密码 / 证书变了之后重新确认，都走这一条。
      //
      // ⛔ 按源的种类判，不按 [folderPath]：第一次就没连上时根目录行还没写进库，
      // 调用点给的 folderPath 是空的——恰恰是最需要重新登录的时候这条不出现。
      if (_isSourceRoot && _isRemoteSource)
        GlassMenuOption<String>(
          value: 'relogin',
          label: t.webdav.relogin,
          icon: Icons.key_outlined,
        ),
      if (onRemove != null)
        GlassMenuOption<String>(
          value: 'remove',
          label: t.remove,
          icon: Icons.remove_circle_outline,
          destructive: true,
        ),
      if (_canDeleteFolder)
        GlassMenuOption<String>(
          value: 'deleteFolder',
          label: t.browse.deleteFolder,
          icon: Icons.folder_delete_outlined,
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
        // 路径为空 = 平的源（见 [_canSetCover]）：候选从整个源里取。
        final changed = await showLocalFolderCoverPickerDialog(
          context: anchorContext,
          sourceId: sourceId,
          relPath: relPath,
          folderPath: resolved.isEmpty ? null : resolved,
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
          _announceRescan(repository);
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
          _announceRescan(repository);
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
          _announceRescan(repository);
          onChanged?.call();
        } catch (e) {
          LogUtils.w('目录级扫描失败: $e', 'LocalFolderMenu');
          showAppToast(
            slang.t.localMedia.scanFailed(reason: '$e'),
            type: AppToastType.error,
          );
          onChanged?.call();
        }

      case 'relogin':
        final source = repository.getSource(sourceId);
        if (source == null || !source.isRemote) return;
        await reloginRemoteSource(context: anchorContext, source: source);
        onChanged?.call();

      case 'rename':
        final source = repository.getSource(sourceId);
        if (source == null || !anchorContext.mounted) return;
        final name = await showGlassPromptNameDialog(
          title: slang.t.localMedia.renameSourceTitle,
          hint: slang.t.localMedia.renameSourceLabel,
          initialText: source.displayName,
        );
        if (name == null || name.isEmpty || name == source.displayName) {
          return;
        }
        // 弹窗期间扫描 / 开关可能改过这一行，upsertSource 是整行覆盖，重读再改。
        final latest = repository.getSource(sourceId);
        if (latest == null) return;
        repository.upsertSource(latest.copyWith(displayName: name));
        showAppToast(slang.t.localMedia.renamed);
        onChanged?.call();

      case 'hide':
        if (relPath.isEmpty) return;
        repository.hideFolder(
          sourceId: sourceId,
          relPath: relPath,
          displayName: displayName,
        );
        showAppToast(slang.t.localMedia.browse.folderHidden);
        // 「显示隐藏的文件夹」开着的时候它还看得见（只是变成半透明），页面留在
        // 原地即可；关着的时候脚下这一层已经不该存在了，由调用点决定去留。
        (onHidden ?? onChanged)?.call();

      case 'unhide':
        repository.unhideFolder(sourceId: sourceId, relPath: relPath);
        showAppToast(slang.t.localMedia.browse.folderUnhidden);
        // ⛔ 取消隐藏之后要补扫一次。藏着的这段时间里扫描器一次都没进去过
        // （`skipPaths`），里面新增的东西一个都不在库里——不补扫的话用户看到的是
        // 一个"内容停留在被隐藏那天"的目录，而重扫入口还藏在另一层菜单里。
        final source = repository.getSource(sourceId);
        if (source != null &&
            relPath.isNotEmpty &&
            Get.isRegistered<LocalMediaScanService>() &&
            (source.kind == LocalMediaSourceKind.directory ||
                source.kind == LocalMediaSourceKind.bookmark ||
                source.kind == LocalMediaSourceKind.webdav)) {
          unawaited(
            LocalMediaScanService.to.scanFolder(
              source: source,
              relPath: relPath,
            ),
          );
        }
        onChanged?.call();

      case 'toggleShowHidden':
        if (!Get.isRegistered<ConfigService>()) return;
        final next = !showHiddenFolders;
        Get.find<ConfigService>()[ConfigKey
                .LOCAL_MEDIA_SHOW_HIDDEN_FOLDERS_KEY] =
            next;
        // 别的页面（根页的常用目录、播放器的「接着看」抽屉）靠这条信号跟上。
        LocalMediaRepository.notifyFolderChanged();
        onChanged?.call();

      case 'toggleDotFolders':
        if (!Get.isRegistered<LocalMediaScanService>()) return;
        final next = !_includeDotFolders;
        // 改库、关掉时的收敛都在 setIncludeDotEntries 的第一个 await 之前同步做完，
        // 所以不等整源重扫结束，页面这就能刷新；扫描进度由来源卡自己的转圈交代。
        // async 函数里同步段抛的错也会落进返回的 future，这里一并兜住。
        unawaited(
          LocalMediaScanService.to
              .setIncludeDotEntries(sourceId, next)
              .catchError((Object e) {
                LogUtils.w('切换 . 开头文件夹扫描失败: $e', 'LocalFolderMenu');
                showAppToast(
                  slang.t.localMedia.scanFailed(reason: '$e'),
                  type: AppToastType.error,
                );
              }),
        );
        showAppToast(
          next
              ? slang.t.localMedia.browse.dotFoldersIncluded
              : slang.t.localMedia.browse.dotFoldersExcluded,
        );
        onChanged?.call();

      case 'remove':
        onRemove?.call();

      case 'deleteFolder':
        await _confirmAndDeleteFolder(anchorContext, repository);
    }
  }

  /// 扫完了说一声：扫描本身不在这一页画转圈的地方（子目录卡、菜单），不说的话
  /// 用户点完「重新扫描」什么都看不到，只能猜它做没做。
  ///
  /// NAS 列目录失败不抛异常，只把源标成用不了——这里照源状态说实话。
  void _announceRescan(LocalMediaRepository repository) {
    final source = repository.getSource(sourceId);
    final state = source?.remoteState;
    if (source != null &&
        source.isRemote &&
        state != null &&
        state != LocalMediaRemoteState.ok) {
      showAppToast(
        WebDavService.describeState(state),
        type: AppToastType.error,
      );
      return;
    }
    final name = displayName.isNotEmpty
        ? displayName
        : (source?.displayName ?? '');
    showAppToast(
      slang.t.localMedia.rescanDone(name: name),
      type: AppToastType.success,
    );
  }

  /// 真删这个文件夹：确认 → 删磁盘 → 删库行。
  ///
  /// ⛔ 顺序只有一种是对的（见 [LocalMediaRepository.deleteFolderSubtree]）。
  Future<void> _confirmAndDeleteFolder(
    BuildContext anchorContext,
    LocalMediaRepository repository,
  ) async {
    final t = slang.t.localMedia;
    final path = folderPath;
    if (path == null || path.isEmpty) return;

    final source = repository.getSource(sourceId);
    final sourcePath = source?.path;
    // ⛔ 双保险：只删**确实落在这个来源里面**的目录。
    //
    // 这一条不是形式主义：`folderPath` 一路从库行传下来，而删的是磁盘。万一哪天
    // 有人把别处的路径塞进这个对象（脏行、拼错的相对路径、以后新加的调用点），
    // 没有这道闸门就是一次递归删除打在用户的别的目录上，没有任何撤销余地。
    if (sourcePath == null ||
        sourcePath.isEmpty ||
        !p.isWithin(sourcePath, path)) {
      LogUtils.e(
        '拒绝删除：目录不在来源内 source=$sourcePath folder=$path',
        tag: 'LocalFolderMenu',
      );
      showAppToast(t.browse.deleteFolderFailed, type: AppToastType.error);
      return;
    }

    final row = repository.getFolder(sourceId: sourceId, relPath: relPath);
    final name = displayName.isNotEmpty
        ? displayName
        : (row?.name.isNotEmpty == true ? row!.name : p.basename(path));
    // 里面有什么，得按**整棵子树**报——删的是 `recursive: true`。
    //
    // ⛔ 这里曾经用目录行自己那三个计数（也就是卡片上那一行），那是**直属**口径：
    // 一个自己没有直属媒体、底下八个子目录各装两千个视频的目录，会报成
    // 「8 个文件夹」，而按下去删掉的是一万六千个文件。见 [folderSubtreeSummary]。
    final subtree = repository.folderSubtreeSummary(
      sourceId: sourceId,
      relPath: relPath,
    );
    final summary = formatLocalFolderCounts(
      childFolderCount: subtree.folders,
      videoCount: subtree.videos,
      imageCount: subtree.images,
      // 没探过就返回空串，由下面那句定性的警告顶上——报一个偏小的数比不报更坏。
      probed: subtree.probed,
    );

    if (!anchorContext.mounted) return;
    final confirmed = await showGlassAlertDialog<bool>(
      title: t.browse.deleteFolderTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(t.browse.deleteFolderBody(name: name)),
          const SizedBox(height: 8),
          Text(
            // 有数就报数，没数（还没探过这一层）就只留那句"里面的东西一并删掉"
            // ——这条永远在场，因为库里那几个数**只含扫进来的媒体**：压缩包、
            // 字幕、文档一概不在其中，而它们同样会被删掉。
            summary.isEmpty
                ? t.browse.deleteFolderIncludesOthers
                : '$summary · ${t.browse.deleteFolderIncludesOthers}',
            style: Theme.of(anchorContext).textTheme.bodySmall?.copyWith(
              color: Theme.of(anchorContext).colorScheme.onSurfaceVariant,
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
          // ⛔ rootNavigator: true。这张弹窗挂在 root 上，拿调用点的 navigator
          // pop 会把**调用它的那一页**弹掉、弹窗纹丝不动，且不报任何错。
          onPressed: () =>
              Navigator.of(anchorContext, rootNavigator: true).pop(true),
        ),
      ],
    );
    if (confirmed != true) return;

    final directory = Directory(path);
    try {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      } else {
        // 目录本来就不在了。⛔ 但「不在」有两种：真没了，和卷没挂上 / 权限被回收。
        // 后者删库行就是数据丢失（连观看进度一起），所以拿父目录可不可达来分辨
        // ——同 `local_media_item_menu.dart` 里删文件那条判据。
        if (!await Directory(p.dirname(path)).exists()) {
          showAppToast(t.browse.deleteFolderFailed, type: AppToastType.error);
          return;
        }
      }
    } catch (e) {
      // ⛔ 「删失败」不等于「什么都没发生」：`delete(recursive: true)` 是**边走边
      // 删**的，撞上一个删不掉的文件（Windows 上被播放器占着的那个）时抛出来，此前
      // 已经 unlink 掉的文件不会回来。所以日志要把"可能删了一半"写清楚——库行一行
      // 没动，用户看到的却是「删除失败」，不写下来的话下次查这种半棵树无从查起。
      // 库那头能自愈：下次扫这一层会把没了的收敛成 missing。
      LogUtils.w(
        '删除文件夹失败（可能已删掉一部分，库行未动，等下次扫描收敛）: $path: $e',
        'LocalFolderMenu',
      );
      showAppToast(t.browse.deleteFolderFailed, type: AppToastType.error);
      // 让调用点重查一次：万一删掉了一部分，至少列表与库保持一致地刷新一遍。
      onChanged?.call();
      return;
    }

    try {
      repository.deleteFolderSubtree(
        sourceId: sourceId,
        relPath: relPath,
        folderPath: path,
      );
    } catch (e) {
      // 磁盘已经删掉了，库行没删干净。这一头是**能自愈**的：下次扫这一层会把
      // 它们收敛成 missing。所以只记日志，不把它说成"删除失败"——东西是真没了。
      LogUtils.w('删除目录库行失败（磁盘已删）: $e', 'LocalFolderMenu');
    }

    showAppToast(t.browse.folderDeleted);
    (onDeleted ?? onChanged)?.call();
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

/// 「重新登录」一个 NAS 源：弹窗测通 → 存新凭据 → 源状态复位 → 交给网关。
/// 返回真表示登上了。
///
/// ⛔ 只此一份：源卡上的状态角标和 ⋮ 菜单都走这里，别在调用点各写一遍。
Future<bool> reloginRemoteSource({
  required BuildContext context,
  required LocalMediaSource source,
}) async {
  final origin = source.uri;
  final root = source.path;
  if (origin == null || root == null || !DavPath.isDav(root)) return false;
  final service = WebDavService.instance;
  final saved = await service.readCredentials(source.id);
  if (!context.mounted) return false;
  final result = await showWebDavReloginDialog(
    context: context,
    origin: origin,
    rootDavPath: root,
    displayName: source.displayName,
    username: saved.value?.username,
    tlsFingerprint: source.tlsFingerprint,
  );
  if (result == null) return false;
  if (!await service.writeCredentials(source.id, result.credentials)) {
    showAppToast(slang.t.localMedia.addSourceFailed, type: AppToastType.error);
    return false;
  }
  // 弹窗期间这一行可能被扫描 / 开关改过，upsertSource 是整行覆盖，重读再改。
  final latest = LocalMediaRepository().getSource(source.id);
  if (latest == null) return false;
  final updated = latest.copyWith(
    offline: false,
    remoteState: LocalMediaRemoteState.ok,
    tlsFingerprint: result.tlsFingerprint,
  );
  LocalMediaRepository().upsertSource(updated);
  // 网关里旧的连接信息（旧密码 / 旧指纹）作废，换新的。
  await service.endpointFor(updated);
  showAppToast(slang.t.localMedia.webdav.connected);
  // 登上了就顺手重列一遍：失效期间卡片和目录停在旧样子，不重列的话用户还得
  // 自己再去找「重新扫描」。
  if (Get.isRegistered<LocalMediaScanService>()) {
    unawaited(LocalMediaScanService.to.scanSource(updated));
  }
  return true;
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
  final impact = LocalMediaRepository().sourceRemovalImpact(source.id);
  final losses = <String>[
    if (impact.progress > 0) t.loseProgress(count: impact.progress),
    if (impact.favorites > 0) t.loseFavorites(count: impact.favorites),
    if (impact.pinned > 0) t.losePinned(count: impact.pinned),
    if (impact.hidden > 0) t.loseHidden(count: impact.hidden),
    if (impact.covers > 0) t.loseCovers(count: impact.covers),
  ];
  final confirmed = await showGlassAlertDialog<bool>(
    title: t.removeSourceTitle(name: source.displayName),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(t.removeSourceBody),
        if (losses.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            t.removeSourceLoses(items: losses.join(' · ')),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    ),
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
  // NAS 源：secure storage 里的账号密码与网关里的连接信息一并清掉，
  // 不留一份「源已删、凭据还在」的孤儿。
  if (source.isRemote) {
    await WebDavService.instance.forgetSource(source.id);
  }
  return true;
}
