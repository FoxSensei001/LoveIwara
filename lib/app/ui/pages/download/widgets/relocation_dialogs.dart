import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/download/download_task.model.dart'
    hide FileSystemException;
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/download_missing_diagnosis.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_relocation_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/relocation_detail_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

const _tag = 'RelocationDialogs';

/// 分组里一次最多铺多少行。几千条的「全部移动」全铺出来只会卡住弹窗，
/// 用户也不会逐条看——超出的只报个数。
const _maxRowsPerSection = 300;

/// 条目多到这个数，「将移动 / 已移动」组默认收起，把视线让给跳过 / 失败的原因。
const _collapseThreshold = 12;

void _pop<T>(T value) => rootNavigatorKey.currentState?.pop(value);

GlassAlertDialog _shell(
  BuildContext context, {
  required String title,
  required Widget content,
  List<GlassDialogAction> actions = const [],
  double? maxWidth,
}) {
  return GlassAlertDialog(
    title: title,
    maxWidth: maxWidth ?? relocationDialogMaxWidth,
    insetPadding: relocationDialogInset(context),
    content: content,
    actions: actions,
  );
}

List<Widget> _capped(List<Widget> rows) {
  if (rows.length <= _maxRowsPerSection) return rows;
  return [
    ...rows.take(_maxRowsPerSection),
    Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 4, 4, 8),
        child: Text(
          slang.Translations.of(
            context,
          ).common.andMoreItems(num: rows.length - _maxRowsPerSection),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ),
  ];
}

// ---------------------------------------------------------------------------
// 文案：把「为什么」「会怎样」说成具体的一句话
// ---------------------------------------------------------------------------

int _percentOf(DownloadTask task) => task.totalBytes > 0
    ? (task.downloadedBytes * 100 / task.totalBytes).clamp(0, 100).round()
    : 0;

/// 未下完的任务搬的时候会发生什么。已完成的返回 null。
String? _entryNote(RelocationEntry entry) {
  final t = slang.t.download.relocation;
  final task = entry.task;
  if (task.status == DownloadStatus.completed) return null;
  if (!entry.hasSource &&
      (task.status == DownloadStatus.paused ||
          task.status == DownloadStatus.failed)) {
    return t.noDataYet;
  }
  return switch (task.status) {
    DownloadStatus.downloading => t.unfinishedDownloading(
      percent: _percentOf(task),
    ),
    DownloadStatus.pending => t.unfinishedPending,
    DownloadStatus.paused => t.unfinishedPaused(percent: _percentOf(task)),
    DownloadStatus.failed => t.unfinishedFailed,
    DownloadStatus.completed => null,
  };
}

/// 路径里第一级「已经不在」的名字：诊断说「文件夹 X 不存在」时的那个 X。
String _firstMissingSegment(MissingDiagnosis d) {
  final prefix = d.existingPrefix;
  final rest = prefix == null
      ? d.recordedPath
      : p.relative(d.recordedPath, from: prefix);
  final parts = p.split(rest);
  return parts.isEmpty ? p.basename(d.recordedPath) : parts.first;
}

String diagnosisShortText(MissingDiagnosis d) {
  final t = slang.t.download.relocation;
  return switch (d.kind) {
    MissingKind.volumeUnavailable => t.diagVolumeShort(
      volume: d.volumeRoot ?? '',
    ),
    MissingKind.containerChanged => t.diagContainerShort,
    MissingKind.noAccess => t.diagNoAccessShort,
    MissingKind.folderMissing => t.diagFolderShort(
      folder: _firstMissingSegment(d),
    ),
    MissingKind.fileMissing =>
      d.candidates.isEmpty ? t.diagFileShort : t.diagFileShortWithCandidates,
  };
}

// isRecoverableMissing 挪到了 download_missing_diagnosis.dart：文件健康缓存
// （服务层）也要按它分「失效 / 待确认」，服务不该反过来依赖界面文件。

String _diagnosisLongText(MissingDiagnosis d) {
  final t = slang.t.download.relocation;
  return switch (d.kind) {
    MissingKind.volumeUnavailable => t.diagVolume(volume: d.volumeRoot ?? ''),
    MissingKind.containerChanged => t.diagContainer,
    MissingKind.noAccess => t.diagNoAccess,
    MissingKind.folderMissing => t.diagFolder(folder: _firstMissingSegment(d)),
    MissingKind.fileMissing => t.diagFile(name: p.basename(d.recordedPath)),
  };
}

IconData _diagnosisIcon(MissingKind kind) => switch (kind) {
  MissingKind.volumeUnavailable => Icons.sd_card_alert_outlined,
  MissingKind.containerChanged => Icons.drive_file_move_outline,
  MissingKind.noAccess => Icons.lock_outline,
  MissingKind.folderMissing => Icons.folder_off_outlined,
  MissingKind.fileMissing => Icons.search_off_outlined,
};

String _skipText(RelocationSkip skip) {
  final t = slang.t.download.relocation;
  return switch (skip.reason) {
    RelocationSkipReason.sourceMissing =>
      skip.diagnosis == null ? '' : diagnosisShortText(skip.diagnosis!),
    RelocationSkipReason.alreadyThere => t.skipAlreadyThere,
    RelocationSkipReason.destinationInsideSource => t.skipInsideSource,
  };
}

String _failureText(RelocationFailure failure) {
  final t = slang.t.download.relocation;
  return switch (failure) {
    RelocationFailure.busy => t.reasonBusy,
    RelocationFailure.sourceLocked => t.reasonSourceLocked,
    RelocationFailure.noSpace => t.reasonNoSpace,
    RelocationFailure.verifyFailed => t.reasonVerifyFailed,
    RelocationFailure.ioError => t.reasonIoError,
  };
}

// ---------------------------------------------------------------------------
// 确认：逐条列出要搬什么、搬到哪、哪些不搬以及为什么；异常项给处理选项
// ---------------------------------------------------------------------------

/// 返回用户选定的处理选项；取消返回 null。
Future<RelocationOptions?> showRelocationPlanReview(RelocationPlan plan) {
  return showAppDialog<RelocationOptions>(_PlanReviewDialog(plan: plan));
}

class _PlanReviewDialog extends StatefulWidget {
  const _PlanReviewDialog({required this.plan});

  final RelocationPlan plan;

  @override
  State<_PlanReviewDialog> createState() => _PlanReviewDialogState();
}

class _PlanReviewDialogState extends State<_PlanReviewDialog> {
  MissingAction _missing = MissingAction.skip;
  FailedAction _failed = FailedAction.moveOnly;

  RelocationPlan get plan => widget.plan;

  bool _isRemovedFailed(RelocationEntry e) =>
      _failed == FailedAction.remove && e.task.status == DownloadStatus.failed;

  (String, RelocationTone)? _missingAction(RelocationSkip skip) {
    final t = slang.t.download.relocation;
    return switch (_missing) {
      MissingAction.skip => null,
      MissingAction.redownload => (
        t.actionWillRedownload,
        RelocationTone.positive,
      ),
      MissingAction.remove =>
        skip.diagnosis?.kind == MissingKind.volumeUnavailable
            ? (t.actionWillKeep, RelocationTone.neutral)
            : (t.actionWillRemove, RelocationTone.danger),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final missing = plan.missing;
    final failedCount = plan.failedEntries.length;
    final moving = [
      for (final e in plan.entries)
        if (!_isRemovedFailed(e)) e,
    ];
    final movingBytes = moving.fold<int>(0, (sum, e) => sum + e.bytes);
    final renamed = moving.where((e) => e.renamedForConflict).length;
    final otherSkips = [
      for (final s in plan.skipped)
        if (s.reason != RelocationSkipReason.sourceMissing) s,
    ];
    final volumeKept = missing
        .where((s) => s.diagnosis?.kind == MissingKind.volumeUnavailable)
        .length;
    final redownloadCount = _missing == MissingAction.redownload
        ? missing.length
        : 0;
    final removeCount =
        (_missing == MissingAction.remove ? missing.length - volumeKept : 0) +
        (_failed == FailedAction.remove ? failedCount : 0);
    final hasWork = moving.isNotEmpty || redownloadCount > 0 || removeCount > 0;

    return _shell(
      context,
      title: t.confirmTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelocationStatsBar(
            stats: [
              RelocationStat(
                label: t.statMove,
                value: '${moving.length}',
                caption: formatRelocationBytes(movingBytes),
                tone: RelocationTone.positive,
              ),
              if (redownloadCount > 0)
                RelocationStat(
                  label: t.statRedownload,
                  value: '$redownloadCount',
                  tone: RelocationTone.positive,
                ),
              if (removeCount > 0)
                RelocationStat(
                  label: t.missingRemove,
                  value: '$removeCount',
                  tone: RelocationTone.danger,
                ),
              if (redownloadCount == 0 && removeCount == 0)
                RelocationStat(
                  label: t.statSkip,
                  value: '${plan.skipped.length}',
                  tone: plan.skipped.isEmpty
                      ? RelocationTone.neutral
                      : RelocationTone.warning,
                ),
              if (renamed > 0)
                RelocationStat(
                  label: t.statRenamed,
                  value: '$renamed',
                  tone: RelocationTone.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          RelocationDestinationBox(path: plan.destinationDir),
          if (!hasWork && missing.isEmpty && failedCount == 0) ...[
            const SizedBox(height: 12),
            Text(t.nothingToMove),
          ],
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (missing.isNotEmpty) ...[
                  _OptionGroup<MissingAction>(
                    title: t.missingGroup(count: missing.length),
                    value: _missing,
                    onChanged: (v) => setState(() => _missing = v),
                    choices: [
                      (MissingAction.skip, t.missingSkip),
                      (MissingAction.redownload, t.missingRedownload),
                      (MissingAction.remove, t.missingRemove),
                    ],
                    note: _missing == MissingAction.remove && volumeKept > 0
                        ? t.missingRemoveVolumeNote(count: volumeKept)
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
                if (failedCount > 0) ...[
                  _OptionGroup<FailedAction>(
                    title: t.failedGroup(count: failedCount),
                    value: _failed,
                    onChanged: (v) => setState(() => _failed = v),
                    choices: [
                      (FailedAction.moveOnly, t.failedMoveOnly),
                      (FailedAction.moveAndRetry, t.failedMoveAndRetry),
                      (FailedAction.remove, t.failedRemove),
                    ],
                    note: _failed == FailedAction.remove
                        ? t.failedRemoveNote
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
                if (missing.isNotEmpty)
                  RelocationSection(
                    icon: Icons.search_off_outlined,
                    title: t.missingGroup(count: missing.length),
                    count: missing.length,
                    tone: RelocationTone.warning,
                    children: _capped([
                      for (final skip in missing)
                        RelocationItemRow(
                          task: skip.task,
                          size: relocationTaskSize(skip.task),
                          detail: _skipText(skip),
                          detailTone: RelocationTone.warning,
                          action: _missingAction(skip)?.$1,
                          actionTone:
                              _missingAction(skip)?.$2 ??
                              RelocationTone.neutral,
                          fromPath: skip.task.savePath,
                          fromRevealable: false,
                        ),
                    ]),
                  ),
                if (otherSkips.isNotEmpty)
                  RelocationSection(
                    icon: Icons.block_outlined,
                    title: t.sectionSkip,
                    count: otherSkips.length,
                    tone: RelocationTone.neutral,
                    initiallyExpanded: otherSkips.length <= _collapseThreshold,
                    children: _capped([
                      for (final skip in otherSkips)
                        RelocationItemRow(
                          task: skip.task,
                          size: relocationTaskSize(skip.task),
                          detail: _skipText(skip),
                          fromPath: skip.task.savePath,
                        ),
                    ]),
                  ),
                if (plan.entries.isNotEmpty)
                  RelocationSection(
                    icon: Icons.drive_file_move_outline,
                    title: t.sectionMove,
                    count: moving.length,
                    tone: RelocationTone.positive,
                    initiallyExpanded:
                        plan.entries.length <= _collapseThreshold ||
                        plan.skipped.isEmpty,
                    children: _capped([
                      for (final entry in plan.entries) _entryRow(entry),
                    ]),
                  ),
              ],
            ),
          ),
          if (moving.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              t.confirmNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (hasWork)
          GlassDialogAction(
            label: moving.isNotEmpty ? t.move : t.execute,
            onPressed: () => _pop(
              RelocationOptions(missingAction: _missing, failedAction: _failed),
            ),
          ),
      ],
    );
  }

  Widget _entryRow(RelocationEntry entry) {
    final t = slang.t.download.relocation;
    final note = _entryNote(entry);
    final lines = [
      ?note,
      if (entry.renamedForConflict)
        t.renamedBadge(name: p.basename(entry.destinationPath)),
    ];
    final isFailed = entry.task.status == DownloadStatus.failed;
    final (String?, RelocationTone) action = !isFailed
        ? (null, RelocationTone.neutral)
        : switch (_failed) {
            FailedAction.moveOnly => (null, RelocationTone.neutral),
            FailedAction.moveAndRetry => (
              t.actionWillRetry,
              RelocationTone.positive,
            ),
            FailedAction.remove => (
              t.actionWillRemoveTask,
              RelocationTone.danger,
            ),
          };
    return RelocationItemRow(
      task: entry.task,
      size: entry.hasSource
          ? relocationTaskSize(entry.task, bytes: entry.bytes)
          : null,
      detail: lines.isEmpty ? null : lines.join('\n'),
      detailTone: isFailed ? RelocationTone.danger : RelocationTone.warning,
      action: action.$1,
      actionTone: action.$2,
      fromPath: entry.hasSource ? entry.sourcePath : null,
      toPath: _isRemovedFailed(entry) ? null : entry.destinationPath,
      toRevealable: false,
    );
  }
}

/// 一组互斥选项：标题 + 一排可换行的选择片。窄屏自动折成两三行，不挤。
class _OptionGroup<T> extends StatelessWidget {
  const _OptionGroup({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.choices,
    this.note,
  });

  final String title;
  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String)> choices;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final (choice, label) in choices)
                ChoiceChip(
                  label: Text(label),
                  selected: choice == value,
                  onSelected: (_) => onChanged(choice),
                ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topLeft,
            child: note == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 结果：搬到哪了、哪些没搬以及系统原话、旧处残留、重新下载 / 移除了哪些
// ---------------------------------------------------------------------------

Future<void> showRelocationResult(
  RelocationPlan plan,
  RelocationResult result,
) async {
  final clean =
      result.failed.isEmpty &&
      !result.cancelled &&
      result.leftovers.isEmpty &&
      result.redownloadFailed.isEmpty &&
      result.keptMissing.isEmpty &&
      result.redownloaded.isEmpty &&
      result.removed.isEmpty &&
      result.notAttempted.isEmpty &&
      result.unexpectedError == null;
  if (clean) {
    // 只有移动、且全部顺利时一句 toast 就够，明细留给有事可说的时候。
    showAppToast(
      slang.t.download.relocation.resultMoved(count: result.moved),
      type: AppToastType.success,
    );
    return;
  }
  await showAppDialog<void>(_ResultDialog(plan: plan, result: result));
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({required this.plan, required this.result});

  final RelocationPlan plan;
  final RelocationResult result;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bySource = {for (final e in plan.entries) e.sourcePath: e};
    final tasks = <String, DownloadTask>{
      for (final e in plan.entries) e.task.id: e.task,
      for (final s in plan.skipped) s.task.id: s.task,
    };
    final failedEntries = [
      for (final e in plan.entries)
        if (result.failed.containsKey(e.task.id)) e,
    ];
    final movedEntries = [
      for (final e in plan.entries)
        if (result.movedTo.containsKey(e.task.id)) e,
    ];
    List<Widget> simpleRows(List<String> ids, {String? detail}) => _capped([
      for (final id in ids)
        if (tasks[id] case final task?)
          RelocationItemRow(
            task: task,
            size: relocationTaskSize(task),
            detail: detail,
            fromPath: result.movedTo[id] ?? task.savePath,
            fromRevealable: false,
          ),
    ]);

    return _shell(
      context,
      title: t.resultTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelocationStatsBar(
            stats: [
              RelocationStat(
                label: t.statMoved,
                value: '${result.moved}',
                tone: RelocationTone.positive,
              ),
              if (result.failed.isNotEmpty || result.redownloaded.isEmpty)
                RelocationStat(
                  label: t.statFailed,
                  value: '${result.failed.length}',
                  tone: result.failed.isEmpty
                      ? RelocationTone.neutral
                      : RelocationTone.danger,
                ),
              if (result.redownloaded.isNotEmpty)
                RelocationStat(
                  label: t.statRedownload,
                  value: '${result.redownloaded.length}',
                  tone: RelocationTone.positive,
                ),
              if (result.removed.isNotEmpty)
                RelocationStat(
                  label: t.statRemoved,
                  value: '${result.removed.length}',
                  tone: RelocationTone.danger,
                ),
              if (result.leftovers.isNotEmpty)
                RelocationStat(
                  label: t.statLeftover,
                  value: '${result.leftovers.length}',
                  tone: RelocationTone.warning,
                ),
            ],
          ),
          if (result.unexpectedError != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 18, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    t.unexpectedError(message: result.unexpectedError!),
                  ),
                ),
              ],
            ),
          ] else if (result.cancelled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.pause_circle_outline, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(t.cancelled)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (failedEntries.isNotEmpty)
                  RelocationSection(
                    icon: Icons.error_outline,
                    title: t.sectionFailed,
                    count: failedEntries.length,
                    tone: RelocationTone.danger,
                    children: _capped([
                      for (final e in failedEntries)
                        RelocationItemRow(
                          task: e.task,
                          size: relocationTaskSize(e.task, bytes: e.bytes),
                          detail: _failureText(result.failed[e.task.id]!),
                          detailTone: RelocationTone.danger,
                          extraDetail: result.failureMessages[e.task.id] == null
                              ? null
                              : t.systemMessage(
                                  message: result.failureMessages[e.task.id]!,
                                ),
                          fromPath: e.sourcePath,
                        ),
                    ]),
                  ),
                if (result.notAttempted.isNotEmpty)
                  RelocationSection(
                    icon: Icons.pending_outlined,
                    title: t.sectionNotAttempted,
                    count: result.notAttempted.length,
                    tone: RelocationTone.neutral,
                    initiallyExpanded:
                        result.notAttempted.length <= _collapseThreshold,
                    children: simpleRows(result.notAttempted),
                  ),
                if (result.redownloadFailed.isNotEmpty)
                  RelocationSection(
                    icon: Icons.cloud_off_outlined,
                    title: t.sectionRedownloadFailed,
                    subtitle: t.redownloadFailedHint,
                    count: result.redownloadFailed.length,
                    tone: RelocationTone.danger,
                    children: simpleRows(result.redownloadFailed),
                  ),
                if (result.leftovers.isNotEmpty)
                  RelocationSection(
                    icon: Icons.cleaning_services_outlined,
                    title: t.sectionLeftover,
                    subtitle: t.leftoverHint,
                    count: result.leftovers.length,
                    tone: RelocationTone.warning,
                    children: _capped([
                      for (final path in result.leftovers)
                        if (bySource[path] case final entry?)
                          RelocationItemRow(
                            task: entry.task,
                            fromPath: path,
                            toPath: result.movedTo[entry.task.id],
                          ),
                    ]),
                  ),
                if (result.keptMissing.isNotEmpty)
                  RelocationSection(
                    icon: Icons.sd_card_alert_outlined,
                    title: t.sectionKept,
                    count: result.keptMissing.length,
                    tone: RelocationTone.warning,
                    children: simpleRows(result.keptMissing),
                  ),
                if (result.redownloaded.isNotEmpty)
                  RelocationSection(
                    icon: Icons.download_outlined,
                    title: t.sectionRedownloaded,
                    count: result.redownloaded.length,
                    tone: RelocationTone.positive,
                    initiallyExpanded:
                        result.redownloaded.length <= _collapseThreshold,
                    children: simpleRows(result.redownloaded),
                  ),
                if (result.removed.isNotEmpty)
                  RelocationSection(
                    icon: Icons.delete_outline,
                    title: t.sectionRemoved,
                    count: result.removed.length,
                    tone: RelocationTone.neutral,
                    initiallyExpanded:
                        result.removed.length <= _collapseThreshold,
                    children: simpleRows(result.removed),
                  ),
                if (movedEntries.isNotEmpty)
                  RelocationSection(
                    icon: Icons.check_circle_outline,
                    title: t.sectionMoved,
                    count: movedEntries.length,
                    tone: RelocationTone.positive,
                    initiallyExpanded:
                        movedEntries.length <= _collapseThreshold &&
                        failedEntries.isEmpty,
                    children: _capped([
                      for (final e in movedEntries)
                        RelocationItemRow(
                          task: e.task,
                          size: e.hasSource
                              ? relocationTaskSize(e.task, bytes: e.bytes)
                              : null,
                          fromPath: e.hasSource ? e.sourcePath : null,
                          fromRevealable: false,
                          toPath: result.movedTo[e.task.id],
                          toRevealable: e.hasSource,
                        ),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 找不到文件：诊断到底断在哪，给出对症的那一个动作
// ---------------------------------------------------------------------------

enum MissingDownloadOutcome { located, deleted, redownloading, dismissed }

/// 一条下载的文件在原位置找不到时，说清楚是**哪一种**找不到，并给对症的动作：
///
/// | 诊断 | 主动作 |
/// |---|---|
/// | 存储卷没挂上 | 再检查一次（插好卡再点） |
/// | iOS 更新换了容器 | 修复路径（一键） |
/// | 没有读取权限 | 授予权限 → 自动再检查 |
/// | 原文件夹里有大小相同的疑似改名件 | 逐个「就是它」 |
/// | 文件夹 / 文件确实没了 | 重新下载（原地；卷不在时改到当前下载目录） |
///
/// 「去其他文件夹找…」各种情况下都在。
///
/// 「删除记录」始终在，但只作为次要动作。
///
/// ⛔ 以前这里是**直接删记录**：SD 卡没插、用户用文件管理器挪过、iOS 更新后
/// 容器路径变了，三种情况都会把一条完好的记录永久抹掉。
Future<MissingDownloadOutcome> showMissingDownloadDialog(
  DownloadTask task,
) async {
  final outcome = await showAppDialog<MissingDownloadOutcome>(
    _MissingDownloadDialog(task: task),
  );
  return outcome ?? MissingDownloadOutcome.dismissed;
}

class _MissingDownloadDialog extends StatefulWidget {
  const _MissingDownloadDialog({required this.task});

  final DownloadTask task;

  @override
  State<_MissingDownloadDialog> createState() => _MissingDownloadDialogState();
}

class _MissingDownloadDialogState extends State<_MissingDownloadDialog> {
  MissingDiagnosis? _diagnosis;
  bool _busy = true;

  /// 正在改东西（删记录 / 重新定位 / 重新下载）：这时才不许关，动作结束会
  /// 自己 pop。诊断中（只读磁盘）照样能关——网络盘 / 掉线的 U 盘上 stat 可能
  /// 卡很久，不能把用户困在弹窗里。
  bool _mutating = false;

  @override
  void initState() {
    super.initState();
    _diagnose();
  }

  Future<void> _diagnose({bool announce = false}) async {
    setState(() => _busy = true);
    // 可能是用户刚把卡插回去 / 刚授了权：先看文件是不是已经回来了。
    if (await FileSystemEntity.type(widget.task.savePath) !=
        FileSystemEntityType.notFound) {
      if (!mounted) return;
      showAppToast(
        slang.t.download.relocation.located,
        type: AppToastType.success,
      );
      _pop(MissingDownloadOutcome.located);
      return;
    }
    MissingDiagnosis? diagnosis;
    try {
      diagnosis = await diagnoseMissingDownload(widget.task);
    } catch (e, s) {
      LogUtils.e('诊断找不到的下载失败', tag: _tag, error: e, stackTrace: s);
    }
    if (!mounted) return;
    setState(() {
      _diagnosis = diagnosis;
      _busy = false;
    });
    if (announce) {
      showAppToast(
        slang.t.download.relocation.stillMissing,
        type: AppToastType.warning,
      );
    }
  }

  Future<void> _relinkTo(String candidate) async {
    setState(() => _busy = _mutating = true);
    var ok = false;
    try {
      ok = await DownloadRelocationService.to.relinkTo(widget.task, candidate);
    } on DuplicateDownloadTaskException catch (e) {
      LogUtils.w('重新定位撞上别的任务: $e', _tag);
    } catch (e, s) {
      LogUtils.e('重新定位失败', tag: _tag, error: e, stackTrace: s);
    }
    if (!mounted) return;
    if (ok) {
      showAppToast(
        slang.t.download.relocation.located,
        type: AppToastType.success,
      );
      _pop(MissingDownloadOutcome.located);
      return;
    }
    setState(() => _busy = _mutating = false);
    showAppToast(
      slang.t.download.relocation.locateNotFound,
      type: AppToastType.warning,
    );
  }

  Future<void> _locateElsewhere() async {
    final folder = await pickRelocationFolder();
    if (folder == null || !mounted) return;
    setState(() => _busy = _mutating = true);
    var ok = false;
    try {
      ok = await DownloadRelocationService.to.relinkFromFolder(
        widget.task,
        folder,
      );
    } on DuplicateDownloadTaskException catch (e) {
      LogUtils.w('重新定位撞上别的任务: $e', _tag);
    } catch (e, s) {
      LogUtils.e('重新定位失败', tag: _tag, error: e, stackTrace: s);
    }
    if (!mounted) return;
    if (ok) {
      showAppToast(
        slang.t.download.relocation.located,
        type: AppToastType.success,
      );
      _pop(MissingDownloadOutcome.located);
      return;
    }
    setState(() => _busy = _mutating = false);
    showAppToast(
      slang.t.download.relocation.locateNotFound,
      type: AppToastType.warning,
    );
  }

  Future<void> _grantPermission() async {
    if (Get.isRegistered<PermissionService>()) {
      await Get.find<PermissionService>().requestStoragePermission();
    }
    if (mounted) await _diagnose(announce: true);
  }

  Future<void> _redownload() async {
    setState(() => _busy = _mutating = true);
    var ok = false;
    try {
      final service = DownloadRelocationService.to;
      ok = await service.redownloadInto(
        widget.task,
        await service.redownloadDirFor(_diagnosis),
      );
    } catch (e, s) {
      LogUtils.e('重新下载失败', tag: _tag, error: e, stackTrace: s);
    }
    if (!mounted) return;
    final t = slang.t.download.relocation;
    if (ok) {
      showAppToast(t.redownloadStarted, type: AppToastType.success);
      _pop(MissingDownloadOutcome.redownloading);
      return;
    }
    setState(() => _busy = _mutating = false);
    showAppToast(t.redownloadNotStarted, type: AppToastType.error);
  }

  Future<void> _deleteRecord() async {
    // 先占住按钮：删记录要等一次库同步，这期间连点 / 点遮罩会 pop 两次，第二次
    // 就把弹窗底下的页面关掉了。
    if (_busy) return;
    setState(() => _busy = _mutating = true);
    var ok = false;
    try {
      if (Get.isRegistered<DownloadService>()) {
        // 只删记录：诊断之后文件可能又回来了（卡插回、文件夹挪回），按路径删会
        // 把用户刚找回的真文件一起删掉。
        ok = await DownloadService.to.deleteTask(
          widget.task.id,
          ignoreFileDeleteError: true,
          deleteFiles: false,
        );
      }
    } catch (e, s) {
      LogUtils.e('删除记录失败', tag: _tag, error: e, stackTrace: s);
    }
    if (!mounted) return;
    if (ok) {
      _pop(MissingDownloadOutcome.deleted);
      return;
    }
    setState(() => _busy = _mutating = false);
    showAppToast(
      slang.t.download.relocation.deleteRecordFailed,
      type: AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final diagnosis = _diagnosis;
    final canPick =
        Get.isRegistered<DownloadPathService>() &&
        DownloadPathService.to.supportsDirectoryPicker;

    final actions = <GlassDialogAction>[
      GlassDialogAction(
        label: t.deleteRecord,
        destructive: true,
        emphasized: false,
        onPressed: _busy ? null : _deleteRecord,
      ),
      if (canPick)
        GlassDialogAction(
          label: t.locate,
          emphasized: false,
          onPressed: _busy ? null : _locateElsewhere,
        ),
      if (diagnosis != null)
        ...switch (diagnosis.kind) {
          MissingKind.containerChanged when diagnosis.rebasedPath != null => [
            GlassDialogAction(
              label: t.fixPath,
              onPressed: _busy ? null : () => _relinkTo(diagnosis.rebasedPath!),
            ),
          ],
          MissingKind.noAccess => [
            GlassDialogAction(
              label: t.grantPermission,
              onPressed: _busy ? null : _grantPermission,
            ),
          ],
          MissingKind.volumeUnavailable => [
            GlassDialogAction(
              label: t.checkAgain,
              onPressed: _busy ? null : () => _diagnose(announce: true),
            ),
          ],
          // 旁边有疑似改名件时主动作是逐个「就是它」，不再抢一枚键位。
          MissingKind.fileMissing when diagnosis.candidates.isNotEmpty =>
            const <GlassDialogAction>[],
          MissingKind.folderMissing || MissingKind.fileMissing => [
            GlassDialogAction(
              label: t.redownload,
              onPressed: _busy ? null : _redownload,
            ),
          ],
          _ => const <GlassDialogAction>[],
        },
    ];

    return PopScope(
      // 改东西中（删记录 / 重下 / 找回）不许关：动作一结束会自己 pop 一次。
      canPop: !_mutating,
      child: _shell(
        context,
        title: t.missingTitle,
        maxWidth: 600,
        actions: actions,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskHeader(task: widget.task),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: diagnosis == null
                    ? Padding(
                        key: const ValueKey('busy'),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _busy
                            ? const LinearProgressIndicator()
                            : PathBreakView(
                                path: widget.task.savePath,
                                existingPrefix: null,
                              ),
                      )
                    : MissingDiagnosisBody(
                        key: ValueKey(diagnosis.kind),
                        diagnosis: diagnosis,
                        busy: _busy,
                        onUseCandidate: _relinkTo,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 是哪一条下载：图标、标题、体积、下载时间。
class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final meta = [
      relocationTaskSize(task),
      if (task.completedAt != null)
        t.downloadedOn(date: formatRelocationDate(task.completedAt!.toLocal())),
    ].where((s) => s.isNotEmpty).join(' · ');
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(relocationTaskIcon(task), color: cs.onSecondaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                relocationTaskTitle(task),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              if (meta.isNotEmpty)
                Text(
                  meta,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 「找不到」的诊断结论 + 断在哪一级 + 疑似改名件（逐个「就是它」）。下载与
/// 本机文件库共用（`local_item_missing_dialog.dart`）。
class MissingDiagnosisBody extends StatelessWidget {
  const MissingDiagnosisBody({
    super.key,
    required this.diagnosis,
    required this.busy,
    required this.onUseCandidate,
  });

  final MissingDiagnosis diagnosis;
  final bool busy;
  final ValueChanged<String> onUseCandidate;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final wide = isRelocationWide(context);
    final recoverable =
        diagnosis.kind == MissingKind.containerChanged ||
        diagnosis.candidates.isNotEmpty;
    final tone = recoverable ? cs.primary : cs.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 结论：具体到哪一种找不到。
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tone.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_diagnosisIcon(diagnosis.kind), color: tone, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _diagnosisLongText(diagnosis),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 断在哪一级：还在的那截正常色，没了的那截标红划掉。
        PathBreakView(
          path: diagnosis.recordedPath,
          existingPrefix: diagnosis.existingPrefix,
        ),
        if (diagnosis.kind == MissingKind.containerChanged &&
            diagnosis.rebasedPath != null) ...[
          const SizedBox(height: 10),
          RelocationDestinationBox(path: diagnosis.rebasedPath!),
        ],
        if (diagnosis.kind == MissingKind.fileMissing) ...[
          const SizedBox(height: 12),
          Text(
            diagnosis.candidates.isEmpty
                ? t.diagNoCandidates
                : t.diagCandidates,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          for (final candidate in diagnosis.candidates)
            _CandidateRow(
              candidate: candidate,
              wide: wide,
              busy: busy,
              onUse: () => onUseCandidate(candidate.path),
            ),
        ],
      ],
    );
  }
}

/// 疑似改过名的那一份：名字、大小、修改时间，一键「就是它」。
class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.candidate,
    required this.wide,
    required this.busy,
    required this.onUse,
  });

  final MissingCandidate candidate;
  final bool wide;
  final bool busy;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final meta = [
      if (candidate.sizeBytes != null)
        formatRelocationBytes(candidate.sizeBytes!),
      if (candidate.modified != null)
        formatRelocationDate(candidate.modified!.toLocal()),
    ].join(' · ');
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.basename(candidate.path),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (meta.isNotEmpty)
          Text(
            meta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
      ],
    );
    final button = GlassButtonGroup(
      children: [
        GlassTextActionButton(
          label: t.useThis,
          emphasized: true,
          onPressed: busy ? null : onUse,
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        // 宽屏一行摆下；窄屏按钮挪到下一行靠右，免得把文件名挤成几个字。
        child: wide
            ? Row(
                children: [
                  Icon(
                    candidate.isDirectory
                        ? Icons.folder_outlined
                        : Icons.insert_drive_file_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: info),
                  const SizedBox(width: 8),
                  button,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  info,
                  const SizedBox(height: 6),
                  Align(alignment: Alignment.centerRight, child: button),
                ],
              ),
      ),
    );
  }
}

/// 挑一个文件夹（找回 / 选目标共用）。出错时按错误码给人话 toast。
Future<String?> pickRelocationFolder() async {
  final settingsT = slang.t.settings.downloadSettings;
  try {
    return await DownloadPathService.to.pickDirectoryPath();
  } on PlatformException catch (e) {
    LogUtils.e('选择文件夹失败', error: e, tag: _tag);
    showAppToast(switch (e.code) {
      'ALREADY_ACTIVE' => settingsT.pickerAlreadyActive,
      'UNSUPPORTED_VOLUME' => settingsT.unsupportedStorageVolume,
      'UNSUPPORTED_PLATFORM' => slang.t.download.relocation.pickerUnsupported,
      _ => settingsT.selectPathFailed,
    }, type: AppToastType.error);
  } catch (e) {
    LogUtils.e('选择文件夹失败', error: e, tag: _tag);
    showAppToast(settingsT.selectPathFailed, type: AppToastType.error);
  }
  return null;
}

// ---------------------------------------------------------------------------
// 清理失效记录：逐条列出找不到的、为什么找不到，勾选后移除或重新下载
// ---------------------------------------------------------------------------

/// 用户在清理页的决定：对 [selected] 重新下载（[redownload] 为 true）或移除记录。
typedef MissingCleanupDecision = ({
  bool redownload,
  List<RelocationSkip> selected,
});

Future<MissingCleanupDecision?> showMissingCleanupReview({
  required int checked,
  required List<RelocationSkip> items,
}) {
  return showAppDialog<MissingCleanupDecision>(
    _CleanupReviewDialog(checked: checked, items: items),
  );
}

class _CleanupReviewDialog extends StatefulWidget {
  const _CleanupReviewDialog({required this.checked, required this.items});

  final int checked;
  final List<RelocationSkip> items;

  @override
  State<_CleanupReviewDialog> createState() => _CleanupReviewDialogState();
}

class _CleanupReviewDialogState extends State<_CleanupReviewDialog> {
  late final List<RelocationSkip> _items = [...widget.items];

  /// 默认只勾「文件确实没了」的；可能还能找回的交给用户自己决定。
  late final Set<String> _selected = {
    for (final item in _items)
      if (!isRecoverableMissing(item.diagnosis)) item.task.id,
  };

  List<RelocationSkip> get _gone => [
    for (final i in _items)
      if (!isRecoverableMissing(i.diagnosis)) i,
  ];

  List<RelocationSkip> get _recoverable => [
    for (final i in _items)
      if (isRecoverableMissing(i.diagnosis)) i,
  ];

  /// 点开单条：在完整的「找不到文件」弹窗里找回 / 重下 / 删除。处理完的这一条
  /// 就不该再留在清单里。
  Future<void> _openDetail(RelocationSkip item) async {
    final outcome = await showMissingDownloadDialog(item.task);
    if (!mounted || outcome == MissingDownloadOutcome.dismissed) return;
    setState(() {
      _items.removeWhere((i) => i.task.id == item.task.id);
      _selected.remove(item.task.id);
    });
  }

  void _toggleAll(List<RelocationSkip> group, bool select) {
    setState(() {
      for (final item in group) {
        if (select) {
          _selected.add(item.task.id);
        } else {
          _selected.remove(item.task.id);
        }
      }
    });
  }

  Widget _groupToggle(List<RelocationSkip> group) {
    final t = slang.t.download.relocation;
    final allSelected = group.every((i) => _selected.contains(i.task.id));
    return RelocationTextLink(
      onTap: () => _toggleAll(group, !allSelected),
      label: allSelected ? t.selectNone : t.selectAll,
    );
  }

  Widget _row(RelocationSkip item) {
    final selected = _selected.contains(item.task.id);
    return RelocationItemRow(
      key: ValueKey(item.task.id),
      task: item.task,
      size: relocationTaskSize(item.task),
      detail: item.diagnosis == null
          ? null
          : diagnosisShortText(item.diagnosis!),
      detailTone: isRecoverableMissing(item.diagnosis)
          ? RelocationTone.warning
          : RelocationTone.danger,
      fromPath: item.task.savePath,
      fromRevealable: false,
      onTap: () => _openDetail(item),
      leading: SizedBox(
        width: 36,
        height: 20,
        // 缩掉 48 的触控框：否则勾选框把标题行撑高，标题与原因之间空出一大截。
        // 整行仍可点（打开详情），勾选框本身 36 宽够手指点。
        child: Checkbox(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: selected,
          onChanged: (v) => setState(() {
            if (v ?? false) {
              _selected.add(item.task.id);
            } else {
              _selected.remove(item.task.id);
            }
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final gone = _gone;
    final recoverable = _recoverable;
    final chosen = [
      for (final i in _items)
        if (_selected.contains(i.task.id)) i,
    ];

    return _shell(
      context,
      title: t.cleanupTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelocationStatsBar(
            stats: [
              RelocationStat(label: t.statChecked, value: '${widget.checked}'),
              RelocationStat(
                label: t.statMissing,
                value: '${_items.length}',
                tone: RelocationTone.danger,
              ),
              RelocationStat(
                label: t.statKeep,
                value: '${recoverable.length}',
                tone: recoverable.isEmpty
                    ? RelocationTone.neutral
                    : RelocationTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (gone.isNotEmpty)
                  RelocationSection(
                    icon: Icons.delete_sweep_outlined,
                    title: t.cleanupGroupGone,
                    count: gone.length,
                    tone: RelocationTone.danger,
                    trailing: _groupToggle(gone),
                    children: _capped([for (final i in gone) _row(i)]),
                  ),
                if (recoverable.isNotEmpty)
                  RelocationSection(
                    icon: Icons.restore_outlined,
                    title: t.cleanupGroupRecoverable,
                    subtitle: t.cleanupRecoverableHint,
                    count: recoverable.length,
                    tone: RelocationTone.warning,
                    trailing: _groupToggle(recoverable),
                    children: _capped([for (final i in recoverable) _row(i)]),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: t.redownloadSelected(count: chosen.length),
          emphasized: false,
          onPressed: chosen.isEmpty
              ? null
              : () => _pop<MissingCleanupDecision>((
                  redownload: true,
                  selected: chosen,
                )),
        ),
        GlassDialogAction(
          label: t.removeSelected(count: chosen.length),
          destructive: true,
          onPressed: chosen.isEmpty
              ? null
              : () => _pop<MissingCleanupDecision>((
                  redownload: false,
                  selected: chosen,
                )),
        ),
      ],
    );
  }
}
