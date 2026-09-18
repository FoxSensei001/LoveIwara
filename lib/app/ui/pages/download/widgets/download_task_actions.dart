import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:super_clipboard/super_clipboard.dart';

import 'package:i_iwara/app/models/download/download_task.model.dart'
    hide FileSystemException;
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_file_health.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart'
    show showDownloadDetailDialog;
import 'package:i_iwara/app/ui/pages/download/widgets/download_relocation_flow.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/move_to_category_sheet.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/relocation_detail_widgets.dart'
    show formatRelocationBytes;
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

const _tag = 'DownloadTaskActions';

/// 下载任务上能做的事。单条卡片的 ⋮ 菜单、右键菜单、批量坞全部从
/// [DownloadActionResolver] 取，不再各写一份。
enum DownloadAction {
  /// 打开 / 播放（视频本地播放、图库进图库详情、其它交给系统打开）。
  open,

  /// 视频：交给系统里别的应用打开。
  openWith,
  pause,
  resume,
  retry,

  /// 已完成但文件不在了：从头再下。
  redownload,

  /// 把文件搬到别的文件夹（任何状态都行，见 DownloadRelocationService）。
  relocate,

  /// 列表里的归组（不动磁盘）。
  categorize,

  /// 桌面：在文件管理器里定位。
  revealInFolder,
  copyLink,

  /// 在线详情页（视频详情 / 图库详情）。
  viewOnline,
  detail,
  delete,
}

/// 状态 → 动作的唯一映射。
///
/// # 为什么要收口
///
/// 三张卡片原来各写一份菜单，结果「移动文件」只对已完成显示（服务层其实
/// 支持任意状态），「在文件夹中显示」视频只在完成时有、图库什么状态都有，
/// 删除还分成「删除任务 / 强制删除」两条。这里一处说了算。
class DownloadActionResolver {
  const DownloadActionResolver._();

  /// 批量坞只放这些（其余都是单条语境才有意义的）。
  static const Set<DownloadAction> batchCapable = {
    DownloadAction.pause,
    DownloadAction.resume,
    DownloadAction.retry,
    DownloadAction.redownload,
    DownloadAction.relocate,
    DownloadAction.categorize,
    DownloadAction.delete,
  };

  /// [tasks] 上可做的动作，按菜单顺序排好。
  ///
  /// [isFileMissing]：这条已完成任务的文件是否已知不在（决定有没有「重新
  /// 下载」）。[isDesktop] 决定有没有「在文件夹中显示」。
  static List<DownloadAction> resolve(
    Set<DownloadTask> tasks, {
    bool? isDesktop,
    bool Function(DownloadTask task)? isFileMissing,
  }) {
    if (tasks.isEmpty) return const [];
    final desktop =
        isDesktop ??
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final missing = isFileMissing ?? (_) => false;
    final single = tasks.length == 1 ? tasks.first : null;

    bool any(bool Function(DownloadTask t) test) => tasks.any(test);
    bool isStatus(DownloadTask t, DownloadStatus s) => t.status == s;

    final canPause = any(
      (t) =>
          isStatus(t, DownloadStatus.pending) ||
          isStatus(t, DownloadStatus.downloading),
    );
    final canResume = any((t) => isStatus(t, DownloadStatus.paused));
    final canRetry = any((t) => isStatus(t, DownloadStatus.failed));
    final canRedownload = any(
      (t) => isStatus(t, DownloadStatus.completed) && missing(t),
    );

    return [
      if (single != null && single.status == DownloadStatus.completed) ...[
        DownloadAction.open,
        if (downloadTaskKind(single) == DownloadTaskKind.video)
          DownloadAction.openWith,
      ],
      if (canPause) DownloadAction.pause,
      if (canResume) DownloadAction.resume,
      if (canRetry) DownloadAction.retry,
      if (canRedownload) DownloadAction.redownload,
      DownloadAction.relocate,
      DownloadAction.categorize,
      if (single != null && desktop && _canReveal(single))
        DownloadAction.revealInFolder,
      if (single != null &&
          downloadTaskKind(single) != DownloadTaskKind.gallery &&
          single.url.isNotEmpty)
        DownloadAction.copyLink,
      if (single != null && onlineMediaIdOf(single) != null)
        DownloadAction.viewOnline,
      if (single != null) DownloadAction.detail,
      DownloadAction.delete,
    ];
  }

  /// 能在文件管理器里定位的：已完成的任何任务；图库文件夹边下边有，
  /// 下载中也能看（原图库卡片就是这么做的）。
  static bool _canReveal(DownloadTask task) =>
      task.status == DownloadStatus.completed ||
      (downloadTaskKind(task) == DownloadTaskKind.gallery &&
          task.status != DownloadStatus.pending);
}

enum DownloadTaskKind { video, gallery, other }

DownloadTaskKind downloadTaskKind(DownloadTask task) =>
    switch (task.extData?.type) {
      DownloadTaskExtDataType.video => DownloadTaskKind.video,
      DownloadTaskExtDataType.gallery => DownloadTaskKind.gallery,
      _ => DownloadTaskKind.other,
    };

/// 在线详情页要用的媒体 id（视频 / 图库）；老数据解析不出来返回 null。
String? onlineMediaIdOf(DownloadTask task) {
  final data = task.extData?.data;
  if (data == null) return null;
  try {
    final id = switch (downloadTaskKind(task)) {
      DownloadTaskKind.video => VideoDownloadExtData.fromJson(data).id,
      DownloadTaskKind.gallery => GalleryDownloadExtData.fromJson(data).id,
      DownloadTaskKind.other => null,
    };
    return (id == null || id.isEmpty) ? null : id;
  } catch (_) {
    return null;
  }
}

/// 文件健康缓存里「已知不在」（失效或待确认）。
bool isDownloadFileKnownMissing(DownloadTask task) {
  if (task.status != DownloadStatus.completed || !DownloadFileHealth.isReady) {
    return false;
  }
  final state = DownloadFileHealth.to.stateOf(task.id);
  return state == DownloadFileState.missing ||
      state == DownloadFileState.pending;
}

/// 卡片自己才知道怎么做的那几件事（例如视频要带上列表页的分类池去播放）。
/// 不给就走通用实现。
class DownloadTaskActionHandlers {
  const DownloadTaskActionHandlers({this.onOpen, this.onViewOnline});

  final Future<void> Function()? onOpen;
  final Future<void> Function()? onViewOnline;
}

// -----------------------------------------------------------------------------
// 菜单
// -----------------------------------------------------------------------------

/// 动作的图标。归类与移动文件刻意拉开：一个是「贴标签」，一个是「搬走」。
IconData downloadActionIcon(DownloadAction action, {DownloadTask? task}) {
  return switch (action) {
    DownloadAction.open => switch (task == null
        ? DownloadTaskKind.other
        : downloadTaskKind(task)) {
      DownloadTaskKind.video => Icons.play_circle_outline,
      DownloadTaskKind.gallery => Icons.photo_library_outlined,
      DownloadTaskKind.other => Icons.open_in_new,
    },
    DownloadAction.openWith => Icons.open_in_new,
    DownloadAction.pause => Icons.pause,
    DownloadAction.resume => Icons.play_arrow,
    DownloadAction.retry => Icons.refresh,
    DownloadAction.redownload => Icons.download_for_offline_outlined,
    DownloadAction.relocate => Icons.drive_file_move_outline,
    DownloadAction.categorize => Icons.label_outline,
    DownloadAction.revealInFolder => Icons.folder_open,
    DownloadAction.copyLink => Icons.link,
    DownloadAction.viewOnline => Icons.public,
    DownloadAction.detail => Icons.info_outline,
    DownloadAction.delete => Icons.delete_outline,
  };
}

String downloadActionLabel(DownloadAction action, {DownloadTask? task}) {
  final t = slang.t.download;
  return switch (action) {
    DownloadAction.open =>
      task != null && downloadTaskKind(task) == DownloadTaskKind.video
          ? t.actions.play
          : t.actions.open,
    DownloadAction.openWith => t.actions.openWith,
    DownloadAction.pause => t.pause,
    DownloadAction.resume => t.resume,
    DownloadAction.retry => slang.t.common.retry,
    DownloadAction.redownload => t.actions.redownload,
    DownloadAction.relocate => t.actions.relocate,
    DownloadAction.categorize => t.actions.categorize,
    DownloadAction.revealInFolder => t.showInFolder,
    DownloadAction.copyLink => t.copyDownloadUrl,
    DownloadAction.viewOnline =>
      task != null && downloadTaskKind(task) == DownloadTaskKind.gallery
          ? t.viewGalleryDetail
          : task != null && downloadTaskKind(task) == DownloadTaskKind.video
          ? t.viewVideoDetail
          : t.actions.viewOnline,
    DownloadAction.detail => t.downloadDetail,
    DownloadAction.delete => t.actions.delete,
  };
}

/// 菜单分组：播放控制 / 文件 / 信息 / 删除，组间一条分隔线。
int _groupOf(DownloadAction action) => switch (action) {
  DownloadAction.open ||
  DownloadAction.openWith ||
  DownloadAction.pause ||
  DownloadAction.resume ||
  DownloadAction.retry ||
  DownloadAction.redownload => 0,
  DownloadAction.relocate ||
  DownloadAction.categorize ||
  DownloadAction.revealInFolder => 1,
  DownloadAction.copyLink ||
  DownloadAction.viewOnline ||
  DownloadAction.detail => 2,
  DownloadAction.delete => 3,
};

/// 把 [actions] 排成玻璃菜单条目。
List<GlassMenuEntry> buildDownloadActionMenuEntries(
  List<DownloadAction> actions, {
  DownloadTask? task,
}) {
  final entries = <GlassMenuEntry>[];
  int? lastGroup;
  for (final action in actions) {
    final group = _groupOf(action);
    if (lastGroup != null && group != lastGroup) {
      entries.add(const GlassMenuSeparator());
    }
    lastGroup = group;
    entries.add(
      GlassMenuOption<DownloadAction>(
        value: action,
        icon: downloadActionIcon(action, task: task),
        label: downloadActionLabel(action, task: task),
        destructive: action == DownloadAction.delete,
      ),
    );
  }
  return entries;
}

/// 单条任务的操作菜单：卡片的 ⋮ 与右键共用。
///
/// 右键时没有「触发件」，落点用指针处一个零尺寸的 `Rect`（[globalPosition]）；
/// ⋮ 则贴着按钮自己弹。
Future<void> showDownloadTaskMenu(
  BuildContext anchorContext,
  DownloadTask task, {
  Offset? globalPosition,
  DownloadTaskActionHandlers handlers = const DownloadTaskActionHandlers(),
}) async {
  final actions = DownloadActionResolver.resolve({
    task,
  }, isFileMissing: isDownloadFileKnownMissing);
  final picked = await showGlassMenu<DownloadAction>(
    anchorContext: anchorContext,
    globalAnchor: globalPosition == null ? null : globalPosition & Size.zero,
    entries: buildDownloadActionMenuEntries(actions, task: task),
  );
  if (picked == null || !anchorContext.mounted) return;
  await runDownloadAction(anchorContext, picked, [task], handlers: handlers);
}

/// 卡片右下角的 ⋮：点开就是 [showDownloadTaskMenu]。
class DownloadTaskMoreButton extends StatelessWidget {
  const DownloadTaskMoreButton({
    super.key,
    required this.task,
    this.handlers = const DownloadTaskActionHandlers(),
  });

  final DownloadTask task;
  final DownloadTaskActionHandlers handlers;

  @override
  Widget build(BuildContext context) {
    return DownloadMoreButton(
      tooltip: slang.Translations.of(context).download.moreOptions,
      onPressed: (anchorContext) =>
          showDownloadTaskMenu(anchorContext, task, handlers: handlers),
    );
  }
}

// -----------------------------------------------------------------------------
// 执行
// -----------------------------------------------------------------------------

/// 执行一个动作。返回是否真的做了点什么（批量坞据此退出选择态）。
Future<bool> runDownloadAction(
  BuildContext context,
  DownloadAction action,
  List<DownloadTask> tasks, {
  DownloadTaskActionHandlers handlers = const DownloadTaskActionHandlers(),
}) async {
  if (tasks.isEmpty) return false;
  final service = DownloadService.to;
  final single = tasks.length == 1 ? tasks.first : null;
  final ids = [for (final t in tasks) t.id];

  switch (action) {
    case DownloadAction.open:
      if (single == null) return false;
      final onOpen = handlers.onOpen;
      if (onOpen != null) {
        await onOpen();
      } else if (downloadTaskKind(single) == DownloadTaskKind.gallery) {
        NaviService.navigateToGalleryDownloadTaskDetailPage(single.id);
      } else {
        await openDownloadedFile(single);
      }
      return true;
    case DownloadAction.openWith:
      if (single == null) return false;
      await openDownloadedFile(single);
      return true;
    case DownloadAction.pause:
      for (final t in tasks) {
        if (t.status == DownloadStatus.pending ||
            t.status == DownloadStatus.downloading) {
          await service.pauseTask(t.id);
        }
      }
      return true;
    case DownloadAction.resume:
      for (final t in tasks) {
        if (t.status == DownloadStatus.paused) await service.resumeTask(t.id);
      }
      return true;
    case DownloadAction.retry:
      for (final t in tasks) {
        if (t.status == DownloadStatus.failed) await service.retryTask(t.id);
      }
      return true;
    case DownloadAction.redownload:
      var started = 0;
      for (final t in tasks) {
        if (t.status != DownloadStatus.completed) continue;
        if (await service.redownloadTask(t.id)) started++;
      }
      if (DownloadFileHealth.isReady) DownloadFileHealth.to.invalidate(ids);
      showAppToast(
        started > 0
            ? slang.t.download.actions.redownloadStarted(count: started)
            : slang.t.download.actions.redownloadNone,
        type: started > 0 ? AppToastType.success : AppToastType.warning,
      );
      return started > 0;
    case DownloadAction.relocate:
      return startDownloadRelocation(ids);
    case DownloadAction.categorize:
      return await showMoveToCategorySheet(context, ids) == true;
    case DownloadAction.revealInFolder:
      if (single == null) return false;
      await revealDownloadInFolder(single);
      return true;
    case DownloadAction.copyLink:
      if (single == null) return false;
      await copyDownloadLink(single);
      return true;
    case DownloadAction.viewOnline:
      if (single == null) return false;
      final onViewOnline = handlers.onViewOnline;
      if (onViewOnline != null) {
        await onViewOnline();
        return true;
      }
      final id = onlineMediaIdOf(single);
      if (id == null) return false;
      if (downloadTaskKind(single) == DownloadTaskKind.gallery) {
        NaviService.navigateToGalleryDetailPage(id);
      } else {
        NaviService.navigateToVideoDetailPage(id);
      }
      return true;
    case DownloadAction.detail:
      if (single == null) return false;
      showDownloadDetailDialog(context, single);
      return true;
    case DownloadAction.delete:
      return showDeleteDownloadTasksDialog(tasks);
  }
}

/// 下载内容在磁盘上的路径（只做分隔符规范化，不生成唯一名）。
String _normalizedSavePath(DownloadTask task) {
  final raw = task.savePath;
  return Platform.isWindows ? raw.replaceAll('/', '\\') : p.normalize(raw);
}

/// 交给系统默认程序打开。找不到文件时走「找不到文件」弹窗（找回 / 重下 /
/// 删记录），而不是笼统报错。
Future<void> openDownloadedFile(DownloadTask task) async {
  final t = slang.t.download;
  try {
    final filePath = _normalizedSavePath(task);
    if (FileSystemEntity.typeSync(filePath) == FileSystemEntityType.notFound) {
      await showMissingDownloadDialog(task);
      return;
    }
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      LogUtils.e('打开文件失败: ${result.message}', tag: _tag);
      showAppToast(
        t.errors.openFileFailedWithMessage(message: result.message),
        type: AppToastType.error,
      );
    }
  } catch (e) {
    LogUtils.e('打开文件失败', tag: _tag, error: e);
    showAppToast(t.errors.openFileFailed, type: AppToastType.error);
  }
}

/// 桌面：在文件管理器里选中这条下载（图库是文件夹）。
Future<void> revealDownloadInFolder(DownloadTask task) async {
  try {
    final filePath = _normalizedSavePath(task);
    if (FileSystemEntity.typeSync(filePath) == FileSystemEntityType.notFound) {
      // 找不到不等于删掉了：让用户去别处找回，或自己确认删记录。
      await showMissingDownloadDialog(task);
      return;
    }
    if (Platform.isWindows) {
      await Process.run('explorer.exe', ['/select,', filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [p.dirname(filePath)]);
    }
  } catch (e) {
    LogUtils.e('打开文件夹失败', tag: _tag, error: e);
    showAppToast(
      slang.t.download.errors.openFolderFailed,
      type: AppToastType.error,
    );
  }
}

Future<void> copyDownloadLink(DownloadTask task) async {
  final t = slang.t.download;
  try {
    final item = DataWriterItem();
    item.add(Formats.plainText(task.url));
    await SystemClipboard.instance?.write([item]);
    showAppToast(t.copyDownloadUrlSuccess, type: AppToastType.success);
  } catch (e) {
    showAppToast(t.errors.copyDownloadUrlFailed, type: AppToastType.error);
  }
}

// -----------------------------------------------------------------------------
// 删除
// -----------------------------------------------------------------------------

/// 单条与批量共用的删除确认。返回是否删掉了至少一条。
///
/// - 显示条数与总大小；「同时删除磁盘文件」默认勾上；
/// - 所选全是文件已不在的已完成任务时，开关自动关闭并置灰（按路径删一个
///   不存在的东西没有意义，而且文件可能正要被找回来）；
/// - 没有「强制删除」：删不掉文件的那几条，结果提示里给「仍移除记录」。
Future<bool> showDeleteDownloadTasksDialog(List<DownloadTask> tasks) async {
  if (tasks.isEmpty) return false;
  final t = slang.t.download.actions;

  final allMissing = tasks.every(_isFileGone);
  final deleteFiles = ValueNotifier<bool>(!allMissing);

  final confirmed = await showGlassAlertDialog<bool>(
    title: t.deleteTitle(count: tasks.length),
    content: _DeleteDownloadsContent(
      tasks: tasks,
      deleteFiles: deleteFiles,
      filesGone: allMissing,
    ),
    actions: [
      GlassDialogAction(
        label: slang.t.common.cancel,
        emphasized: false,
        onPressed: () => rootNavigatorKey.currentState?.pop(false),
      ),
      GlassDialogAction(
        label: slang.t.common.delete,
        destructive: true,
        onPressed: () => rootNavigatorKey.currentState?.pop(true),
      ),
    ],
  );
  // ⛔ 这里不 dispose：弹窗的 future 在 pop 那一刻就完成，退场动画还在画，
  // 开关的 ValueListenableBuilder 此时仍挂着它。它没有外部资源，交给 GC；
  // 监听者随弹窗子树卸载自己摘掉。
  final withFiles = deleteFiles.value;
  if (confirmed != true) return false;

  final ids = [for (final task in tasks) task.id];
  DeleteTasksResult? result;
  if (tasks.length == 1) {
    // 单条不挡进度弹窗：卡片上的主按钮会转圈（isTaskProcessing）。
    result = await DownloadService.to.deleteTasksWithProgress(
      tasks,
      deleteFiles: withFiles,
    );
  } else {
    result = await runWithProgressDialog(
      label: (done, total) =>
          slang.t.download.deleteByDate.deleting(done: done, total: total),
      job: (onProgress) => DownloadService.to.deleteTasksWithProgress(
        tasks,
        deleteFiles: withFiles,
        onProgress: onProgress,
      ),
    );
  }
  if (DownloadFileHealth.isReady) DownloadFileHealth.to.invalidate(ids);
  if (result == null) return false;
  _showDeleteResult(result, tasks);
  return result.deleted > 0;
}

bool _isFileGone(DownloadTask task) {
  if (task.status != DownloadStatus.completed) return false;
  if (isDownloadFileKnownMissing(task)) return true;
  try {
    return FileSystemEntity.typeSync(task.savePath) ==
        FileSystemEntityType.notFound;
  } catch (_) {
    return false;
  }
}

void _showDeleteResult(DeleteTasksResult result, List<DownloadTask> tasks) {
  final t = slang.t.download.actions;
  if (result.skipped == 0) {
    showAppToast(
      t.deleteDone(count: result.deleted),
      type: AppToastType.success,
    );
    return;
  }
  final skipped = {...result.skippedIds};
  final leftovers = [
    for (final task in tasks)
      if (skipped.contains(task.id)) task,
  ];
  showAppToast(
    t.deletePartial(failed: result.skipped),
    type: AppToastType.warning,
    duration: const Duration(seconds: 8),
    actionLabel: t.removeRecordAnyway,
    onAction: leftovers.isEmpty
        ? null
        : () async {
            // 只删记录、磁盘一个字节不碰（文件多半正被占用）。
            final again = await DownloadService.to.deleteTasksWithProgress(
              leftovers,
              deleteFiles: false,
              ignoreFileDeleteError: true,
            );
            showAppToast(
              t.deleteDone(count: again.deleted),
              type: AppToastType.success,
            );
          },
  );
}

class _DeleteDownloadsContent extends StatelessWidget {
  const _DeleteDownloadsContent({
    required this.tasks,
    required this.deleteFiles,
    required this.filesGone,
  });

  final List<DownloadTask> tasks;
  final ValueNotifier<bool> deleteFiles;
  final bool filesGone;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.actions;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    // 图库的 downloadedBytes 是「张数」不是字节，不能加进总大小。
    var bytes = 0;
    var galleries = 0;
    for (final task in tasks) {
      if (downloadTaskKind(task) == DownloadTaskKind.gallery) {
        galleries++;
      } else {
        bytes += task.downloadedBytes;
      }
    }
    final summary = bytes > 0
        ? t.deleteSummary(
            count: tasks.length,
            size: formatRelocationBytes(bytes),
          )
        : t.deleteSummaryNoSize(count: tasks.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(summary, style: theme.textTheme.bodyMedium),
        if (galleries > 0 && bytes > 0) ...[
          const SizedBox(height: 2),
          Text(t.deleteGalleryNote(count: galleries), style: muted),
        ],
        if (tasks.length <= 3) ...[
          const SizedBox(height: 8),
          for (final task in tasks)
            Text(
              task.fileName.trim().isEmpty ? task.id : task.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted,
            ),
        ],
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: deleteFiles,
          builder: (context, value, _) => SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: value,
            onChanged: filesGone ? null : (v) => deleteFiles.value = v,
            title: Text(t.deleteFiles),
            subtitle: Text(
              filesGone ? t.deleteFilesAllMissing : t.deleteFilesDesc,
              style: muted,
            ),
          ),
        ),
      ],
    );
  }
}
