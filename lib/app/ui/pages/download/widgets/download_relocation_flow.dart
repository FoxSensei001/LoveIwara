import 'dart:async';

import 'package:flutter/material.dart';

import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/download_file_health.dart';
import 'package:i_iwara/app/services/download_missing_diagnosis.dart'
    show isRecoverableMissing;
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_relocation_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/relocation_detail_widgets.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/relocation_dialogs.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

export 'relocation_dialogs.dart'
    show MissingDownloadOutcome, showMissingDownloadDialog;

// 清理入口挂在下载列表 ⋮ 菜单的「整理 › 检查文件完整性…」与失效横幅上，
// 见 [startMissingCleanup]。

const _tag = 'DownloadRelocationFlow';

/// 「移动已下载文件」的整条交互：选目标 → 检查 → 确认 → 进度 → 结果。
///
/// [destination] 给定时跳过选目标（设置页「移到这里」）。返回是否真的搬了东西。
Future<bool> startDownloadRelocation(
  List<String> taskIds, {
  String? destination,
}) async {
  final t = slang.t;
  final service = DownloadRelocationService.to;
  if (service.running.value) {
    showAppToast(t.download.relocation.alreadyRunning);
    return false;
  }
  if (taskIds.isEmpty) return false;

  final target = destination ?? await _pickDestination();
  if (target == null) return false;

  final plan = await runWithProgressDialog(
    label: (_, _) => t.download.relocation.planning,
    job: (_) => service.plan(taskIds, target),
  );
  if (plan == null) return false;

  // 一条可移动的都没有时也照样打开明细：用户要看的正是每一条为什么不能动，
  // 找不到文件的那些也可能要在这里选「重新下载 / 移除」。
  final options = await showRelocationPlanReview(plan);
  if (options == null) return false;

  final result = await showAppDialog<RelocationResult>(
    _RelocationProgressDialog(plan: plan, options: options),
    barrierDismissible: false,
  );
  if (result == null) return false;
  await showRelocationResult(plan, result);
  return result.moved > 0 ||
      result.redownloaded.isNotEmpty ||
      result.removed.isNotEmpty;
}

/// 「清理失效记录」：扫出所有已完成但文件不在的任务 → 逐条诊断 → 勾选确认 →
/// 移除记录或重新下载。
///
/// 可能还能找回的（存储没插、没权限、疑似改名）默认不勾，见
/// [isRecoverableMissing]；点开任一条可进单条的「找不到文件」弹窗处理。
Future<void> startMissingCleanup() async {
  final t = slang.t.download.relocation;
  final service = DownloadRelocationService.to;
  if (service.running.value) {
    showAppToast(t.alreadyRunning);
    return;
  }
  final scan = await runWithProgressDialog(
    label: (done, total) => t.cleanupScanning(done: done, total: total),
    job: (onProgress) => service.scanMissingCompleted(onProgress: onProgress),
  );
  if (scan == null) return;
  // 这一趟就是一次全量检查：结果顺手交给文件健康缓存，列表的横幅 / 需处理
  // 计数立刻对得上，不用等它自己的空闲扫描。
  if (DownloadFileHealth.isReady) {
    DownloadFileHealth.to.absorbFullScan([
      for (final item in scan.missing)
        (
          id: item.task.id,
          savePath: item.task.savePath,
          recoverable: isRecoverableMissing(item.diagnosis),
        ),
    ]);
  }
  if (scan.missing.isEmpty) {
    showAppToast(
      t.cleanupNone(count: scan.checked),
      type: AppToastType.success,
    );
    return;
  }

  final decision = await showMissingCleanupReview(
    checked: scan.checked,
    items: scan.missing,
  );
  if (decision == null || decision.selected.isEmpty) return;

  if (decision.redownload) {
    var started = 0;
    await runWithProgressDialog(
      label: (done, total) => t.processing(done: done, total: total),
      job: (onProgress) async {
        final total = decision.selected.length;
        for (var i = 0; i < total; i++) {
          final item = decision.selected[i];
          final ok = await service.redownloadInto(
            item.task,
            await service.redownloadDirFor(item.diagnosis),
          );
          if (ok) started++;
          onProgress(i + 1, total);
        }
      },
    );
    showAppToast(
      t.cleanupRedownloaded(count: started),
      type: started > 0 ? AppToastType.success : AppToastType.warning,
    );
    return;
  }

  final result = await runWithProgressDialog(
    label: (done, total) => t.processing(done: done, total: total),
    job: (onProgress) => DownloadService.to.deleteTasksWithProgress(
      [for (final item in decision.selected) item.task],
      ignoreFileDeleteError: true,
      // 只删记录：扫描之后文件可能又回来了（卡插回、文件夹挪回）。
      deleteFiles: false,
      onProgress: onProgress,
    ),
  );
  if (result != null) {
    showAppToast(
      t.cleanupRemoved(count: result.deleted),
      type: AppToastType.success,
    );
  }
}

/// 两个去处：当前下载目录 / 自己挑一个文件夹。只剩一个时直接用它。
Future<String?> _pickDestination() async {
  final t = slang.t.download.relocation;
  final pathService = DownloadPathService.to;
  final canPick = pathService.supportsDirectoryPicker;
  final hasCurrent = pathService.hasFixedDownloadDirectory;

  String? current;
  if (hasCurrent) {
    try {
      current = await pathService.migrationTargetDirectory();
    } catch (e) {
      LogUtils.w('取当前下载目录失败: $e', _tag);
    }
  }

  if (current == null && !canPick) {
    showAppToast(t.pickerUnsupported, type: AppToastType.warning);
    return null;
  }
  if (current != null && !canPick) return current;
  if (current == null) return pickRelocationFolder();

  // 真实路径不会以 NUL 开头，拿它当「去挑一个」的记号。
  const pickOther = '\u0000pick';
  final choice = await showGlassAlertDialog<String>(
    title: t.chooseDestination,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_outlined),
          title: Text(t.currentDownloadDir),
          subtitle: Text(current, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => _popDialog(current),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.folder_open_outlined),
          title: Text(t.otherFolder),
          onTap: () => _popDialog(pickOther),
        ),
      ],
    ),
  );
  if (choice == null) return null;
  if (choice == pickOther) return pickRelocationFolder();
  return choice;
}

/// 弹窗挂在 root navigator 上，按钮回调里从它 pop（见 [GlassDialogAction.onPressed]）。
void _popDialog<T>(T value) => rootNavigatorKey.currentState?.pop(value);

/// 跑一段可能要几秒的活，期间挡一张不可关的进度弹窗；[label] 按进度出字。
///
/// 规划要遍历图库文件夹量大小、清理要逐条 stat 几千个文件——不给个进度，
/// 用户只会以为点了没反应。出错返回 null 并提示。
Future<T?> runWithProgressDialog<T>({
  required String Function(int done, int total) label,
  required Future<T> Function(void Function(int done, int total) onProgress)
  job,
}) async {
  T? value;
  Object? error;
  await showAppDialog<void>(
    _ProgressDialog(
      label: label,
      job: (onProgress) async {
        try {
          value = await job(onProgress);
        } catch (e, s) {
          error = e;
          LogUtils.e('后台处理失败', tag: _tag, error: e, stackTrace: s);
        }
      },
    ),
    barrierDismissible: false,
  );
  if (error != null) {
    showAppToast(
      slang.t.download.relocation.reasonIoError,
      type: AppToastType.error,
    );
    return null;
  }
  return value;
}

class _ProgressDialog extends StatefulWidget {
  const _ProgressDialog({required this.label, required this.job});

  final String Function(int done, int total) label;
  final Future<void> Function(void Function(int done, int total) onProgress)
  job;

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
  int _done = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.job((done, total) {
        if (mounted) {
          setState(() {
            _done = done;
            _total = total;
          });
        }
      });
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GlassAlertDialog(
        title: null,
        showCloseButton: false,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: _total > 0 ? (_done / _total).clamp(0.0, 1.0) : null,
            ),
            const SizedBox(height: 16),
            Text(widget.label(_done, _total)),
          ],
        ),
      ),
    );
  }
}

class _RelocationProgressDialog extends StatefulWidget {
  const _RelocationProgressDialog({required this.plan, required this.options});

  final RelocationPlan plan;
  final RelocationOptions options;

  @override
  State<_RelocationProgressDialog> createState() =>
      _RelocationProgressDialogState();
}

class _RelocationProgressDialogState extends State<_RelocationProgressDialog> {
  final _cancelToken = RelocationCancelToken();
  RelocationProgress? _progress;
  bool _stopping = false;
  DateTime _lastPaint = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    RelocationResult result;
    try {
      result = await DownloadRelocationService.to.run(
        widget.plan,
        options: widget.options,
        cancelToken: _cancelToken,
        onProgress: (progress) {
          // 1MB 一块地回调，几 GB 的片子就是几千次；限到每秒十来次重建。
          final now = DateTime.now();
          if (progress.doneItems < progress.totalItems &&
              now.difference(_lastPaint) < const Duration(milliseconds: 80)) {
            _progress = progress;
            return;
          }
          _lastPaint = now;
          if (mounted) setState(() => _progress = progress);
        },
      );
    } catch (e, s) {
      LogUtils.e('移动已下载文件失败', tag: _tag, error: e, stackTrace: s);
      result = const RelocationResult(
        moved: 0,
        failed: {},
        cancelled: true,
        leftovers: [],
      );
    }
    if (mounted) Navigator.of(context, rootNavigator: true).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final progress = _progress;
    // 选了「移除」的失败任务不搬，实际要搬的条数以进度回报为准。
    final total = progress?.totalItems ?? widget.plan.entries.length;
    final done = progress?.doneItems ?? 0;
    final fraction = progress == null || progress.totalBytes <= 0
        ? null
        : (progress.doneBytes / progress.totalBytes).clamp(0.0, 1.0);

    return PopScope(
      canPop: false,
      child: GlassAlertDialog(
        title: null,
        showCloseButton: false,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: fraction),
            const SizedBox(height: 16),
            Text(
              total == 0
                  ? t.processing(done: 0, total: 0)
                  : t.moving(done: (done + 1).clamp(1, total), total: total),
            ),
            if (progress != null) ...[
              const SizedBox(height: 4),
              Text(
                progress.currentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${formatRelocationBytes(progress.doneBytes)} / '
                '${formatRelocationBytes(progress.totalBytes)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_stopping) ...[
              const SizedBox(height: 8),
              Text(t.stopping, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
        actions: [
          GlassDialogAction(
            label: t.stop,
            emphasized: false,
            onPressed: _stopping
                ? null
                : () {
                    _cancelToken.cancel();
                    setState(() => _stopping = true);
                  },
          ),
        ],
      ),
    );
  }
}
