import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/download/download_task.model.dart'
    hide FileSystemException;
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/download_missing_diagnosis.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/media_scan_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 一条没被纳入这次移动的原因。
///
/// 未下完的任务（下载中 / 等待 / 暂停 / 失败）**不在这里**：它们照样能搬，
/// 半截文件跟着走、搬完接着续传，见 [RelocationEntry.hasSource]。
enum RelocationSkipReason {
  /// 已完成、但原位置已经找不到文件。可在确认页选「重新下载 / 移除记录」，
  /// 见 [MissingAction]。
  sourceMissing,

  /// 本来就在目标位置。
  alreadyThere,

  /// 目标文件夹在这个图库文件夹里面——自己装不进自己。
  destinationInsideSource,
}

/// 选中的任务里「已完成但文件找不到」的那些怎么处理。
enum MissingAction {
  /// 不动（默认）。
  skip,

  /// 在目标文件夹里重新下载。
  redownload,

  /// 移除记录。⛔ 存储卷没挂上的那些一律不移除：插回卡就回来了。
  remove,
}

/// 选中的任务里「下载失败」的那些怎么处理。
enum FailedAction {
  /// 只改保存位置（默认），仍停在失败状态。
  moveOnly,

  /// 改完位置顺手重试。
  moveAndRetry,

  /// 移除任务（连同半截文件）。
  remove,
}

class RelocationOptions {
  const RelocationOptions({
    this.missingAction = MissingAction.skip,
    this.failedAction = FailedAction.moveOnly,
  });

  final MissingAction missingAction;
  final FailedAction failedAction;
}

/// 一条搬失败的原因。
enum RelocationFailure {
  /// 被别的操作占着（正在删除 / 另一次移动）。
  busy,

  /// 原文件被占用删不掉（多半正在播放）；已撤回，原文件原样保留。
  sourceLocked,

  /// 目标盘满了。整批随之停下：后面的只会一样失败。
  noSpace,

  /// 复制后大小对不上；已撤回。
  verifyFailed,

  /// 其余读写错误；已撤回。
  ioError,
}

class RelocationEntry {
  const RelocationEntry({
    required this.task,
    required this.sourcePath,
    required this.desiredPath,
    required this.destinationPath,
    required this.isDirectory,
    required this.bytes,
    this.hasSource = true,
  });

  final DownloadTask task;
  final String sourcePath;

  /// 磁盘上有没有东西要搬。没下完、一个字节都还没落盘的任务没有：只改保存位置。
  final bool hasSource;

  /// 按布局规则本该落到的位置；被占用时 [destinationPath] 会带上序号。
  final String desiredPath;
  final String destinationPath;
  final bool isDirectory;
  final int bytes;

  /// 目标处已有同名的东西，这一条会换个带序号的名字。
  bool get renamedForConflict => !p.equals(desiredPath, destinationPath);
}

/// 一条没纳入移动的任务，连同说得出口的具体原因。
class RelocationSkip {
  const RelocationSkip({
    required this.task,
    required this.reason,
    this.diagnosis,
  });

  final DownloadTask task;
  final RelocationSkipReason reason;

  /// [RelocationSkipReason.sourceMissing] 时：到底是怎么找不到的。
  final MissingDiagnosis? diagnosis;
}

class RelocationPlan {
  const RelocationPlan({
    required this.destinationDir,
    required this.entries,
    required this.skipped,
  });

  final String destinationDir;
  final List<RelocationEntry> entries;
  final List<RelocationSkip> skipped;

  int get totalBytes => entries.fold(0, (sum, e) => sum + e.bytes);

  /// 已完成但文件找不到的那些（确认页的「重新下载 / 移除记录」选项作用于它们）。
  List<RelocationSkip> get missing => [
    for (final s in skipped)
      if (s.reason == RelocationSkipReason.sourceMissing) s,
  ];

  /// 下载失败的那些（确认页的「移动后重试 / 移除任务」选项作用于它们）。
  List<RelocationEntry> get failedEntries => [
    for (final e in entries)
      if (e.task.status == DownloadStatus.failed) e,
  ];
}

class RelocationProgress {
  const RelocationProgress({
    required this.doneItems,
    required this.totalItems,
    required this.doneBytes,
    required this.totalBytes,
    required this.currentName,
  });

  final int doneItems;
  final int totalItems;
  final int doneBytes;
  final int totalBytes;
  final String currentName;
}

class RelocationResult {
  const RelocationResult({
    required this.moved,
    required this.failed,
    required this.cancelled,
    required this.leftovers,
    this.movedTo = const {},
    this.failureMessages = const {},
    this.redownloaded = const [],
    this.redownloadFailed = const [],
    this.removed = const [],
    this.keptMissing = const [],
    this.notAttempted = const [],
    this.unexpectedError,
  });

  /// 停止 / 空间不足 / 出错时一条都没轮到的任务 id（原样没动）。
  final List<String> notAttempted;

  /// 批次中途抛出的意外错误原文；为 null 表示正常走完（含用户停止）。
  final String? unexpectedError;

  /// 按选项重新入队下载的任务 id（找不到文件的 / 失败后重试的）。
  final List<String> redownloaded;

  /// 想重新下载却没排上的（链接刷新失败等）。
  final List<String> redownloadFailed;

  /// 按选项移除的任务 id。
  final List<String> removed;

  /// 选了「移除」但因为存储没挂上而保留下来的。
  final List<String> keptMissing;

  final int moved;
  final Map<String, RelocationFailure> failed;
  final bool cancelled;

  /// 任务 id → 实际落到的位置（动手前可能又换过一次名，以这里为准）。
  final Map<String, String> movedTo;

  /// 任务 id → 系统给的原始错误（如 `Permission denied (errno 13)`），给用户排查用。
  final Map<String, String> failureMessages;

  /// 搬成功了、但旧位置没删干净的（图库文件夹删到一半被占用）。数据以新位置为准。
  final List<String> leftovers;
}

/// 一批移动过程中逐步累积的结果；两段（搬 / 收尾）共用一份。
class _BatchState {
  final failed = <String, RelocationFailure>{};
  final leftovers = <String>[];
  final movedTo = <String, String>{};
  final failureMessages = <String, String>{};
  final redownloaded = <String>[];
  final redownloadFailed = <String>[];
  final removed = <String>[];
  final keptMissing = <String>[];
  final notAttempted = <String>[];
  var moved = 0;
  var cancelled = false;

  /// 目标盘满了，后面的都不做了（包括收尾那段的重新下载 / 移除）。
  var aborted = false;
  String? unexpectedError;

  RelocationResult toResult() => RelocationResult(
    moved: moved,
    failed: failed,
    cancelled: cancelled,
    leftovers: leftovers,
    movedTo: movedTo,
    failureMessages: failureMessages,
    redownloaded: redownloaded,
    redownloadFailed: redownloadFailed,
    removed: removed,
    keptMissing: keptMissing,
    notAttempted: notAttempted,
    unexpectedError: unexpectedError,
  );
}

class RelocationCancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class _RelocationCancelled implements Exception {
  const _RelocationCancelled();
}

class _VerifyFailed implements Exception {
  const _VerifyFailed();
}

/// 移动已下载的文件，并让所有记着路径的地方跟着改。
///
/// # 每一条的顺序（不能换）
///
/// 1. 记账（v42 `download_relocation_journal`）；
/// 2. 同卷：rename → 改库；
///    跨卷：复制到 `<目标>.iwmove` 临时名 → 核对大小 → 改成正式名 → 改库 → 删源；
/// 3. 销账，通知安卓媒体库（旧路径移除、新路径登记）。
///
/// **源只在库已指向一份核对过的新文件之后才删**；被杀进程后由
/// [recoverJournal] 按磁盘现状收尾，删东西之前一律先核对两边大小。
///
/// 删源失败（文件正被播放、Windows 上被占用）时撤回：库改回旧路径、删掉新
/// 复制的那份。宁可这一条没搬，也不能两边各留一半。
class DownloadRelocationService extends GetxService {
  DownloadRelocationService({DownloadTaskRepository? repository})
    : _injectedRepository = repository;

  static DownloadRelocationService get to => Get.find();

  static const _tag = 'DownloadRelocation';
  static const _tempSuffix = '.iwmove';
  static const _copyChunkSize = 1 << 20;

  final DownloadTaskRepository? _injectedRepository;
  DownloadTaskRepository get _repository =>
      _injectedRepository ?? DownloadService.to.repository;

  /// 测试用：跳过 rename、一律走跨卷的复制路径（单机临时目录里触发不了跨卷）。
  @visibleForTesting
  bool forceCopyForTesting = false;

  /// 测试用：复制时不把修改时间带过去，模拟 FAT/exFAT 那种带不过去的卷。
  @visibleForTesting
  static bool preserveModifiedTimeForTesting = true;

  /// 同一时刻只跑一批：两批交叉搬同一批文件没有意义，还会互相抢临时名。
  final RxBool running = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(recoverJournal);
  }

  // ---------------------------------------------------------------------------
  // 规划
  // ---------------------------------------------------------------------------

  /// 一条任务搬到新文件夹后，相对新文件夹的路径。与 [DownloadPathService]
  /// 生成路径的形状对齐：视频、图库文件夹直接放在根下；单图是
  /// `<标题>/<文件>`，那一层标题目录保留。
  static String relativeLayoutOf(
    DownloadTask task, {
    required bool isDirectory,
  }) {
    final name = p.basename(task.savePath);
    // 早期（v13 之前）的视频任务 media_type 为空，靠 ext_data 的类型认。
    final isVideo =
        task.mediaType == 'video' ||
        task.extData?.type == DownloadTaskExtDataType.video;
    if (isDirectory || isVideo) return name;
    final parent = p.basename(p.dirname(task.savePath));
    return parent.isEmpty ? name : p.join(parent, name);
  }

  Future<RelocationPlan> plan(
    Iterable<String> taskIds,
    String destinationDir,
  ) async {
    final destination = p.normalize(destinationDir);
    final entries = <RelocationEntry>[];
    final skipped = <RelocationSkip>[];
    final reserved = <String>{};
    final cache = MissingDiagnosisCache();

    for (final id in taskIds) {
      final task = await _repository.getTaskById(id);
      if (task == null) continue;
      final source = p.normalize(task.savePath);
      final type = await FileSystemEntity.type(source, followLinks: false);
      final hasSource = type != FileSystemEntityType.notFound;
      if (!hasSource && task.status == DownloadStatus.completed) {
        skipped.add(
          RelocationSkip(
            task: task,
            reason: RelocationSkipReason.sourceMissing,
            diagnosis: await diagnoseMissingDownload(task, cache: cache),
          ),
        );
        continue;
      }
      // 还没落盘的图库也按文件夹排布，下载时会在那里建目录。
      final isDirectory = hasSource
          ? type == FileSystemEntityType.directory
          : task.extData?.type == DownloadTaskExtDataType.gallery;
      if (hasSource &&
          isDirectory &&
          (p.equals(
                canonicalStoragePath(source),
                canonicalStoragePath(destination),
              ) ||
              p.isWithin(
                canonicalStoragePath(source),
                canonicalStoragePath(destination),
              ))) {
        skipped.add(
          RelocationSkip(
            task: task,
            reason: RelocationSkipReason.destinationInsideSource,
          ),
        );
        continue;
      }
      final desired = p.join(
        destination,
        relativeLayoutOf(task, isDirectory: isDirectory),
      );
      if (p.equals(
        canonicalStoragePath(desired),
        canonicalStoragePath(source),
      )) {
        skipped.add(
          RelocationSkip(task: task, reason: RelocationSkipReason.alreadyThere),
        );
        continue;
      }

      final target = await DownloadPathService.resolveAvailablePath(
        desired,
        isDirectory: isDirectory,
        isReserved: (candidate) async =>
            reserved.contains(p.canonicalize(candidate)) ||
            await FileSystemEntity.type('$candidate$_tempSuffix') !=
                FileSystemEntityType.notFound ||
            await _repository.existsTaskBySavePath(candidate),
      );
      reserved.add(p.canonicalize(target));

      entries.add(
        RelocationEntry(
          task: task,
          sourcePath: source,
          desiredPath: desired,
          destinationPath: target,
          isDirectory: isDirectory,
          hasSource: hasSource,
          bytes: !hasSource
              ? 0
              : isDirectory
              ? await _directorySize(source)
              : await File(source).length(),
        ),
      );
    }
    return RelocationPlan(
      destinationDir: destination,
      entries: entries,
      skipped: skipped,
    );
  }

  /// 找出所有「已完成但文件不在」的任务，并逐条诊断（清理失效记录用）。
  ///
  /// 先逐条 stat（进度按这一步报），再只对找不到的那些做诊断——诊断要列目录，
  /// 几千条完好的任务没必要陪跑。
  Future<({int checked, List<RelocationSkip> missing})> scanMissingCompleted({
    void Function(int done, int total)? onProgress,
  }) async {
    final rows = _repository.completedTaskPaths();
    final missingIds = <String>[];
    for (var i = 0; i < rows.length; i++) {
      if (await FileSystemEntity.type(rows[i].savePath) ==
          FileSystemEntityType.notFound) {
        missingIds.add(rows[i].id);
      }
      if (i % 25 == 0) onProgress?.call(i, rows.length);
    }
    final cache = MissingDiagnosisCache();
    final result = <RelocationSkip>[];
    for (final id in missingIds) {
      final task = await _repository.getTaskById(id);
      if (task == null) continue;
      result.add(
        RelocationSkip(
          task: task,
          reason: RelocationSkipReason.sourceMissing,
          diagnosis: await diagnoseMissingDownload(task, cache: cache),
        ),
      );
    }
    onProgress?.call(rows.length, rows.length);
    return (checked: rows.length, missing: result);
  }

  /// 单条「找不到」的任务重新下载时该下到哪。
  ///
  /// 原文件夹没了 / 文件没了：原地重下（下载器会把文件夹建回来）；所在的卷
  /// 整个不在、没有权限、iOS 容器换了：原处写不进去，改到当前下载目录。
  Future<String?> redownloadDirFor(MissingDiagnosis? diagnosis) async {
    switch (diagnosis?.kind) {
      case null:
      case MissingKind.folderMissing:
      case MissingKind.fileMissing:
        return null;
      case MissingKind.volumeUnavailable:
      case MissingKind.noAccess:
      case MissingKind.containerChanged:
        if (!Get.isRegistered<DownloadPathService>()) return null;
        final pathService = DownloadPathService.to;
        if (!pathService.hasFixedDownloadDirectory) return null;
        return pathService.currentDownloadDirectory();
    }
  }

  /// 已完成、且不在 [baseDir] 之下的任务 id——设置页「旧位置还有 N 项」用。
  List<String> completedTaskIdsOutside(String baseDir) {
    final base = canonicalStoragePath(baseDir);
    return [
      for (final row in _repository.completedTaskPaths())
        if (!p.isWithin(base, canonicalStoragePath(row.savePath)) &&
            !p.equals(base, canonicalStoragePath(row.savePath)))
          row.id,
    ];
  }

  /// [completedTaskIdsOutside] 里文件**确实还在**的那些——「旧位置还有 N 项、
  /// 要不要搬过来」只该数搬得动的。文件早就没了的交给「检查文件完整性」处理，
  /// 算进来只会让人以为旧位置还躺着一大堆东西。
  Future<List<String>> movableTaskIdsOutside(String baseDir) async {
    final base = canonicalStoragePath(baseDir);
    final result = <String>[];
    for (final row in _repository.completedTaskPaths()) {
      final path = canonicalStoragePath(row.savePath);
      if (p.isWithin(base, path) || p.equals(base, path)) continue;
      try {
        if (await FileSystemEntity.type(row.savePath) ==
            FileSystemEntityType.notFound) {
          continue;
        }
      } catch (_) {
        continue;
      }
      result.add(row.id);
    }
    return result;
  }

  /// 安卓主存储的三个别名（`/sdcard`、`/storage/self/primary`、
  /// `/storage/emulated/0`）是同一块地方，比较前统一成最后那种。否则手输
  /// `/sdcard/...` 当下载目录时，存量记录全被算成「在目录外」，搬的时候又在
  /// 同一个文件夹里改名成 `(1)`。
  static String canonicalStoragePath(String raw) {
    final normalized = p.posix.normalize(raw);
    for (final alias in const ['/sdcard', '/storage/self/primary']) {
      if (normalized == alias) return '/storage/emulated/0';
      if (normalized.startsWith('$alias/')) {
        return '/storage/emulated/0${normalized.substring(alias.length)}';
      }
    }
    return raw;
  }

  // ---------------------------------------------------------------------------
  // 执行
  // ---------------------------------------------------------------------------

  Future<RelocationResult> run(
    RelocationPlan plan, {
    RelocationOptions options = const RelocationOptions(),
    void Function(RelocationProgress progress)? onProgress,
    RelocationCancelToken? cancelToken,
  }) async {
    if (running.value) {
      throw StateError('another relocation is running');
    }
    running.value = true;
    final state = _BatchState();
    try {
      Future<void> movePhase() => _movePhase(
        plan,
        options: options,
        state: state,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
      // 只有「搬」这一段挂起全量同步（见 holdFullSync）。
      //
      // ⛔ 重新下载 / 移除必须放到挂起**之外**：移除走 deleteTask，它默认要等一次
      // 「已下载」同步（syncAfterPending）——而同步正被这里挂着，挂起又要等本批
      // 结束才放。两头互等，进度弹窗关不掉、只能杀进程。
      if (Get.isRegistered<DownloadsLibrarySyncService>()) {
        await DownloadsLibrarySyncService.to.holdFullSync(movePhase);
      } else {
        await movePhase();
      }
      if (!state.cancelled && !state.aborted) {
        await _postPhase(plan, options: options, state: state);
      }
    } catch (e, s) {
      LogUtils.e('移动已下载文件中途出错', tag: _tag, error: e, stackTrace: s);
      state.unexpectedError = '$e';
    } finally {
      running.value = false;
    }
    LogUtils.i(
      '移动已下载文件结束：成功 ${state.moved}，失败 ${state.failed.length}，'
      '重新下载 ${state.redownloaded.length}，移除 ${state.removed.length}'
      '${state.cancelled ? '（已取消）' : ''}${state.aborted ? '（空间不足中止）' : ''}',
      _tag,
    );
    return state.toResult();
  }

  /// 搬的那一段（在「已下载」全量同步挂起期间跑）：
  ///
  /// 1. 选了「移除」的失败任务不搬；
  /// 2. 正在下 / 排队中的先暂停（等它松开文件句柄，见 `pauseTask`），没停下来的
  ///    记「忙」、不搬；
  /// 3. 逐条搬（未落盘的只改路径），**持锁期间**同步内存里那份；
  /// 4. 第 2 步暂停的那些恢复下载——停止 / 出错也照做：暂停是我们为了搬才做的，
  ///    不能把它留给用户。
  Future<void> _movePhase(
    RelocationPlan plan, {
    required RelocationOptions options,
    required _BatchState state,
    void Function(RelocationProgress progress)? onProgress,
    RelocationCancelToken? cancelToken,
  }) async {
    final removeFailed = options.failedAction == FailedAction.remove;
    final toMove = [
      for (final e in plan.entries)
        if (!(removeFailed && e.task.status == DownloadStatus.failed)) e,
    ];
    final totalBytes = toMove.fold<int>(0, (sum, e) => sum + e.bytes);
    var doneItems = 0;
    var doneBytes = 0;

    void report(String name) => onProgress?.call(
      RelocationProgress(
        doneItems: doneItems,
        totalItems: toMove.length,
        doneBytes: doneBytes,
        totalBytes: totalBytes,
        currentName: name,
      ),
    );

    final resumeAfter = <String>[];
    // 没暂停成的（正被别的操作占着 / 写库失败回滚）不能搬：它还在往那个文件里写。
    final stillActive = <String>{};
    for (final e in toMove) {
      final live = DownloadService.to.store.taskOf(e.task.id)?.status;
      if (live == DownloadStatus.downloading ||
          live == DownloadStatus.pending) {
        await DownloadService.to.pauseTask(e.task.id);
        if (DownloadService.to.store.taskOf(e.task.id)?.status ==
            DownloadStatus.paused) {
          resumeAfter.add(e.task.id);
        } else {
          stillActive.add(e.task.id);
        }
      }
    }

    final attempted = <String>{};
    try {
      for (final entry in toMove) {
        if (cancelToken?.isCancelled ?? false) {
          state.cancelled = true;
          break;
        }
        final taskId = entry.task.id;
        final name = p.basename(entry.sourcePath);
        attempted.add(taskId);
        report(name);

        if (stillActive.contains(taskId) ||
            !DownloadService.to.tryLockTask(taskId)) {
          state.failed[taskId] = RelocationFailure.busy;
          doneItems++;
          doneBytes += entry.bytes;
          continue;
        }
        final bytesBefore = doneBytes;
        try {
          final outcome = await _moveOne(
            entry,
            onBytes: (n) {
              doneBytes += n;
              report(name);
            },
            cancelToken: cancelToken,
          );
          if (outcome.leftover) state.leftovers.add(entry.sourcePath);
          state.movedTo[taskId] = outcome.destination;
          state.moved++;
          // 持锁期间把内存那份对上：锁一放，恢复下载就会拿内存对象整行写库。
          // 文件已经搬好、库也改好了，同步失败只记日志，不能把这一条再记成失败。
          if (entry.task.status != DownloadStatus.completed) {
            try {
              await DownloadService.to.syncRelocatedTask(taskId);
            } catch (e) {
              LogUtils.w('移动后同步内存任务失败: $taskId ($e)', _tag);
            }
          }
        } on _RelocationCancelled {
          state.cancelled = true;
          attempted.remove(taskId);
          break;
        } on _VerifyFailed {
          state.failed[taskId] = RelocationFailure.verifyFailed;
        } on _SourceLocked {
          state.failed[taskId] = RelocationFailure.sourceLocked;
        } on FileSystemException catch (e) {
          LogUtils.e('移动失败: ${entry.sourcePath}', tag: _tag, error: e);
          state.failureMessages[taskId] = _describeFsError(e);
          if (_isNoSpace(e)) {
            state.failed[taskId] = RelocationFailure.noSpace;
            state.aborted = true;
            break;
          }
          state.failed[taskId] = RelocationFailure.ioError;
        } catch (e, s) {
          LogUtils.e(
            '移动失败: ${entry.sourcePath}',
            tag: _tag,
            error: e,
            stackTrace: s,
          );
          state.failureMessages[taskId] = '$e';
          state.failed[taskId] = RelocationFailure.ioError;
        } finally {
          DownloadService.to.unlockTask(taskId);
        }
        doneItems++;
        doneBytes = bytesBefore + entry.bytes;
        report(name);
      }
    } finally {
      for (final id in resumeAfter) {
        await DownloadService.to.resumeTask(id);
      }
      if (state.moved > 0) _afterPathsChanged();
      // 停止 / 空间不足 / 出错时一条都没轮到的那些，结果页要能看见。
      state.notAttempted.addAll([
        for (final e in toMove)
          if (!attempted.contains(e.task.id)) e.task.id,
      ]);
    }
  }

  /// 搬完之后的收尾（挂起已放开）：失败任务按选项重试或移除，找不到文件的
  /// 按选项重新下载或移除。停止 / 空间不足时整段不做（见 [run]）。
  Future<void> _postPhase(
    RelocationPlan plan, {
    required RelocationOptions options,
    required _BatchState state,
  }) async {
    if (options.failedAction == FailedAction.moveAndRetry) {
      for (final e in plan.failedEntries) {
        if (!state.movedTo.containsKey(e.task.id)) continue;
        if (await DownloadService.to.redownloadTask(e.task.id)) {
          state.redownloaded.add(e.task.id);
        } else {
          state.redownloadFailed.add(e.task.id);
        }
      }
    }
    for (final skip in plan.missing) {
      final id = skip.task.id;
      switch (options.missingAction) {
        case MissingAction.skip:
          break;
        case MissingAction.redownload:
          if (await redownloadInto(skip.task, plan.destinationDir)) {
            state.redownloaded.add(id);
          } else {
            state.redownloadFailed.add(id);
          }
        case MissingAction.remove:
          if (skip.diagnosis?.kind == MissingKind.volumeUnavailable) {
            state.keptMissing.add(id);
          } else if (await _removeTask(id, deleteFiles: false)) {
            state.removed.add(id);
          }
      }
    }
    if (options.failedAction == FailedAction.remove) {
      for (final e in plan.failedEntries) {
        // 确认框开着的时候用户可能已经点了重试：那就不再是「失败任务」了，不删。
        final live =
            DownloadService.to.store.taskOf(e.task.id)?.status ??
            (await _repository.getTaskById(e.task.id))?.status;
        if (live != DownloadStatus.failed) continue;
        // 失败任务连同半截文件一起删：那是我们自己下了一半的东西。
        if (await _removeTask(e.task.id, deleteFiles: true)) {
          state.removed.add(e.task.id);
        }
      }
    }
  }

  Future<bool> _removeTask(String taskId, {required bool deleteFiles}) async {
    try {
      return await DownloadService.to.deleteTask(
        taskId,
        ignoreFileDeleteError: true,
        silent: true,
        deleteFiles: deleteFiles,
      );
    } catch (e) {
      LogUtils.e('移除任务失败: $taskId', tag: _tag, error: e);
      return false;
    }
  }

  /// 把任务改指到 [targetDir] 下（按布局规则、避开占用），再从头下载。
  /// [targetDir] 为 null 或本来就在那儿时不改路径，原地重下。
  Future<bool> redownloadInto(DownloadTask task, String? targetDir) async {
    try {
      if (targetDir != null) {
        final isDirectory =
            task.extData?.type == DownloadTaskExtDataType.gallery;
        final desired = p.join(
          targetDir,
          relativeLayoutOf(task, isDirectory: isDirectory),
        );
        if (!p.equals(desired, task.savePath)) {
          final target = await _freshDestination(desired, isDirectory);
          _repository.relocateTaskPath(
            taskId: task.id,
            oldPath: task.savePath,
            newPath: target,
          );
          await DownloadService.to.syncRelocatedTask(task.id);
        }
      }
      return await DownloadService.to.redownloadTask(task.id);
    } catch (e, s) {
      LogUtils.e('重新下载失败: ${task.id}', tag: _tag, error: e, stackTrace: s);
      return false;
    }
  }

  /// `Permission denied (OS Error: errno = 13)` 这类，给结果页原样展示。
  static String _describeFsError(FileSystemException e) {
    final os = e.osError;
    if (os == null) return e.message;
    return '${os.message} (errno ${os.errorCode})';
  }

  /// 搬一条。返回实际落点，以及旧位置是否留了残渣（只有图库文件夹删到一半才会）。
  ///
  /// ⛔ 源只在「库已指向一份核对过大小的新文件」之后才删。反过来（先删源
  /// 再改库）的话，改库一失败就是两头落空：跨卷时新文件也挪不回去。
  Future<({String destination, bool leftover})> _moveOne(
    RelocationEntry entry, {
    required void Function(int bytes) onBytes,
    RelocationCancelToken? cancelToken,
  }) async {
    final source = entry.sourcePath;
    final isDirectory = entry.isDirectory;
    // 规划到现在可能过去了几十分钟（前面的大文件在复制、用户在确认框上停留），
    // 目标位置可能已经冒出同名的东西。而 POSIX 的 rename 会**静默覆盖**已存在
    // 的目标——所以动手前再挑一次空位。
    final destination = await _freshDestination(
      entry.destinationPath,
      isDirectory,
    );
    final temp = '$destination$_tempSuffix';
    final removedMediaPaths = isDirectory
        ? MediaScanService.listFilesForRemoval(source)
        : <String>[source];

    // 还没落盘的未完成任务：没东西可搬，只改保存位置。
    if (!entry.hasSource) {
      _repository.relocateTaskPath(
        taskId: entry.task.id,
        oldPath: entry.task.savePath,
        newPath: destination,
      );
      return (destination: destination, leftover: false);
    }

    _repository.recordRelocation(
      taskId: entry.task.id,
      srcPath: source,
      destPath: destination,
      tempPath: temp,
    );
    try {
      await Directory(p.dirname(destination)).create(recursive: true);

      // ── 同卷：rename 一步到位，改库失败就原路改回来 ──────────────────
      if (!forceCopyForTesting &&
          await _tryRename(source, destination, isDirectory)) {
        onBytes(entry.bytes);
        try {
          await _commitPath(entry, source, destination);
        } catch (_) {
          // 改不回去就把账本留着：下次启动按「源不在、目标在」补改库。
          if (await _tryRename(destination, source, isDirectory)) {
            _repository.clearRelocation(entry.task.id);
          }
          rethrow;
        }
        unawaited(MediaScanService.scan([...removedMediaPaths, destination]));
        return (destination: destination, leftover: false);
      }

      // ── 跨卷：复制 → 核对 → 转正 → 改库 → 删源 ─────────────────────
      try {
        if (isDirectory) {
          await _copyDirectory(source, temp, onBytes, cancelToken);
        } else {
          await _copyFile(File(source), temp, onBytes, cancelToken);
        }
        if (!await _sameContentSize(source, temp, isDirectory)) {
          throw const _VerifyFailed();
        }
        if (await FileSystemEntity.type(destination) !=
            FileSystemEntityType.notFound) {
          throw FileSystemException('destination appeared', destination);
        }
        await _renameEntity(temp, destination, isDirectory);
      } catch (_) {
        await _deleteQuietly(temp);
        _repository.clearRelocation(entry.task.id);
        rethrow;
      }

      try {
        await _commitPath(entry, source, destination, clearJournal: false);
      } catch (_) {
        // 源还原封不动：删掉新复制的那份即可。
        await _deleteQuietly(destination);
        _repository.clearRelocation(entry.task.id);
        rethrow;
      }

      var leftover = false;
      try {
        if (isDirectory) {
          await Directory(source).delete(recursive: true);
        } else {
          await File(source).delete();
        }
      } on FileSystemException catch (e) {
        if (!isDirectory) {
          // 单个文件删不掉（正在播放 / Windows 占用）就整条撤回：库改回旧路径，
          // 新复制的那份删掉。宁可这一条没搬，也不留两份。
          LogUtils.w('原文件被占用，撤回本条移动: $source ($e)', _tag);
          // ⛔ 指纹要写回**原文件**的：库里此刻是新副本的大小 / 修改时间，有的卷
          // 修改时间带不过去（FAT/exFAT 取整到 2 秒、有的卷不让设），不改回来的话
          // 下一次同步会判「文件被换过」，把观看进度当陈旧数据清掉。
          final original = await File(source).stat();
          _repository.relocateTaskPath(
            taskId: entry.task.id,
            oldPath: destination,
            newPath: entry.task.savePath,
            newSizeBytes: original.size,
            newModifiedAt: original.modified.millisecondsSinceEpoch,
          );
          await _deleteQuietly(destination);
          throw const _SourceLocked();
        }
        // 文件夹可能已删掉一部分，撤不回了：新位置那份是完整的，以它为准。
        LogUtils.w('旧图库文件夹没删干净，以新位置为准: $source ($e)', _tag);
        leftover = true;
      }
      _repository.clearRelocation(entry.task.id);
      unawaited(MediaScanService.scan([...removedMediaPaths, destination]));
      return (destination: destination, leftover: leftover);
    } on _SourceLocked {
      rethrow;
    } catch (e) {
      // 上面各条失败路径已各自复原磁盘、决定销不销账；这里只兜「账本写了、
      // 还没动磁盘」就出错（建目录失败等）的那种。
      if (await FileSystemEntity.type(destination) ==
              FileSystemEntityType.notFound &&
          await FileSystemEntity.type(source) !=
              FileSystemEntityType.notFound) {
        _repository.clearRelocation(entry.task.id);
      }
      rethrow;
    }
  }

  /// 在 [desired] 处（或其带序号的变体）挑一个此刻真正空着的位置。
  Future<String> _freshDestination(String desired, bool isDirectory) {
    return DownloadPathService.resolveAvailablePath(
      desired,
      isDirectory: isDirectory,
      isReserved: (candidate) async =>
          await FileSystemEntity.type('$candidate$_tempSuffix') !=
              FileSystemEntityType.notFound ||
          await _repository.existsTaskBySavePath(candidate),
    );
  }

  /// 改库。文件的指纹按新文件实测值写，见 [DownloadTaskRepository.relocateTaskPath]。
  Future<void> _commitPath(
    RelocationEntry entry,
    String source,
    String destination, {
    bool clearJournal = true,
  }) async {
    final stat = entry.isDirectory ? null : await File(destination).stat();
    _repository.relocateTaskPath(
      taskId: entry.task.id,
      // 用库里记的原样路径：「已下载」条目的 id 是按它算的哈希，规整过的路径
      // 对不上就找不到那一行，进度搬不过去。
      oldPath: entry.task.savePath,
      newPath: destination,
      newSizeBytes: stat?.size,
      newModifiedAt: stat?.modified.millisecondsSinceEpoch,
      clearJournal: clearJournal,
    );
  }

  /// 同卷直接改名。跨卷（EXDEV）、Windows 跨盘或被占用时失败，交给复制兜底。
  Future<bool> _tryRename(String from, String to, bool isDirectory) async {
    try {
      await _renameEntity(from, to, isDirectory);
      return true;
    } on FileSystemException catch (e) {
      LogUtils.d('rename 不可用，改走复制: $from ($e)', _tag);
      return false;
    }
  }

  static Future<void> _renameEntity(String from, String to, bool isDirectory) {
    return isDirectory ? Directory(from).rename(to) : File(from).rename(to);
  }

  /// 分块读写，读写之间有背压：一个几 GB 的视频不会整个堆进内存。
  static Future<void> _copyFile(
    File source,
    String destination,
    void Function(int bytes) onBytes,
    RelocationCancelToken? cancelToken,
  ) async {
    final reader = await source.open();
    final writer = await File(destination).open(mode: FileMode.write);
    final buffer = Uint8List(_copyChunkSize);
    try {
      while (true) {
        if (cancelToken?.isCancelled ?? false) {
          throw const _RelocationCancelled();
        }
        final read = await reader.readInto(buffer);
        if (read <= 0) break;
        await writer.writeFrom(buffer, 0, read);
        onBytes(read);
      }
      await writer.flush();
    } finally {
      await reader.close();
      await writer.close();
    }
    // 修改时间尽量带过去：「本机文件」拿大小 + 修改时间认同一个文件。有的卷
    // 不让设（安卓共享存储），设不上也无妨，改库时会按新文件的真值写指纹。
    try {
      if (preserveModifiedTimeForTesting) {
        await File(destination).setLastModified(await source.lastModified());
      }
    } catch (_) {}
  }

  static Future<void> _copyDirectory(
    String source,
    String destination,
    void Function(int bytes) onBytes,
    RelocationCancelToken? cancelToken,
  ) async {
    await Directory(destination).create(recursive: true);
    await for (final entity in Directory(
      source,
    ).list(recursive: true, followLinks: false)) {
      final relative = p.relative(entity.path, from: source);
      final target = p.join(destination, relative);
      if (entity is Directory) {
        await Directory(target).create(recursive: true);
      } else if (entity is File) {
        await Directory(p.dirname(target)).create(recursive: true);
        await _copyFile(entity, target, onBytes, cancelToken);
      }
    }
  }

  static Future<bool> _sameContentSize(
    String source,
    String copy,
    bool isDirectory,
  ) async {
    if (!isDirectory) {
      return await File(source).length() == await File(copy).length();
    }
    final a = await _directoryStats(source);
    final b = await _directoryStats(copy);
    return a.files == b.files && a.bytes == b.bytes;
  }

  static Future<int> _directorySize(String dir) async =>
      (await _directoryStats(dir)).bytes;

  static Future<({int files, int bytes})> _directoryStats(String dir) async {
    var files = 0;
    var bytes = 0;
    await for (final entity in Directory(
      dir,
    ).list(recursive: true, followLinks: false)) {
      if (entity is File) {
        files++;
        bytes += await entity.length();
      }
    }
    return (files: files, bytes: bytes);
  }

  static Future<void> _deleteQuietly(String target) async {
    try {
      final type = await FileSystemEntity.type(target, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        await Directory(target).delete(recursive: true);
      } else if (type != FileSystemEntityType.notFound) {
        await File(target).delete();
      }
    } catch (e) {
      LogUtils.w('清理临时文件失败: $target ($e)', _tag);
    }
  }

  /// ENOSPC（POSIX 28）/ ERROR_DISK_FULL（112）/ ERROR_HANDLE_DISK_FULL（39）。
  static bool _isNoSpace(FileSystemException e) {
    final code = e.osError?.errorCode;
    if (Platform.isWindows) return code == 112 || code == 39;
    return code == 28;
  }

  void _afterPathsChanged() {
    if (Get.isRegistered<DownloadService>()) {
      DownloadService.to.store.invalidateCompleted();
    }
    if (Get.isRegistered<DownloadsLibrarySyncService>()) {
      unawaited(DownloadsLibrarySyncService.to.syncAfterPending());
    }
  }

  // ---------------------------------------------------------------------------
  // 被杀进程后的收尾
  // ---------------------------------------------------------------------------

  /// 按磁盘现状收掉账本里每一笔没做完的搬运。启动时跑一次。
  ///
  /// ⛔ 两条铁律：**删任何东西之前先核对两边大小一致**（目标位置那份可能根本
  /// 不是我们复制的——用户以为崩了自己拷了一份、同步工具塞了个同名文件）；
  /// **先改库、后删源**。拿不准的一律两边都不动，只销账。
  ///
  /// | 库指向 | 源 | 目标 | 处置 |
  /// |---|---|---|---|
  /// | 目标 | 在 | 在 | 大小一致 → 删源（删源前被杀）；不一致 → 不动 |
  /// | 目标 | 不在 | 在 | 已搬完，只差销账 |
  /// | 源 | 不在 | 在 | 同卷 rename 后、改库前被杀 → 补改库 |
  /// | 源 | 在 | 在 | 复制转正后、改库前被杀 → 大小一致删目标那份；不一致不动 |
  /// | 源 | * | 不在 | 什么都没发生 |
  ///
  /// 临时名 `.iwmove` 一律删：它从来不是完整的那份。
  Future<void> recoverJournal() async {
    List<DownloadRelocationJournalEntry> pending;
    try {
      pending = _repository.pendingRelocations();
    } catch (e) {
      LogUtils.w('读取移动账本失败: $e', _tag);
      return;
    }
    if (pending.isEmpty) return;
    LogUtils.i('发现 ${pending.length} 笔未收尾的移动，开始收尾', _tag);

    var changed = false;
    for (final entry in pending) {
      try {
        if (entry.tempPath != null) await _deleteQuietly(entry.tempPath!);
        final task = await _repository.getTaskById(entry.taskId);
        final destType = await FileSystemEntity.type(
          entry.destPath,
          followLinks: false,
        );
        final srcType = await FileSystemEntity.type(
          entry.srcPath,
          followLinks: false,
        );
        final destExists = destType != FileSystemEntityType.notFound;
        final srcExists = srcType != FileSystemEntityType.notFound;
        final isDirectory = destType == FileSystemEntityType.directory;

        if (task == null || !destExists) {
          // 任务没了 / 目标根本没出现：磁盘上不动任何东西。
        } else if (p.equals(task.savePath, entry.destPath)) {
          if (srcExists &&
              srcType == destType &&
              await _sameContentSize(
                entry.srcPath,
                entry.destPath,
                isDirectory,
              )) {
            await _deleteQuietly(entry.srcPath);
          }
        } else if (!srcExists) {
          final stat = isDirectory ? null : await File(entry.destPath).stat();
          _repository.relocateTaskPath(
            taskId: entry.taskId,
            oldPath: task.savePath,
            newPath: entry.destPath,
            newSizeBytes: stat?.size,
            newModifiedAt: stat?.modified.millisecondsSinceEpoch,
          );
          // 未完成的任务启动时已进内存：不同步的话它一恢复下载就把旧路径写回库。
          if (Get.isRegistered<DownloadService>()) {
            await DownloadService.to.syncRelocatedTask(entry.taskId);
          }
          changed = true;
        } else if (srcType == destType &&
            await _sameContentSize(
              entry.srcPath,
              entry.destPath,
              isDirectory,
            )) {
          await _deleteQuietly(entry.destPath);
        }
        _repository.clearRelocation(entry.taskId);
      } catch (e) {
        LogUtils.e('收尾移动失败: ${entry.srcPath}', tag: _tag, error: e);
      }
    }
    if (changed) _afterPathsChanged();
  }

  // ---------------------------------------------------------------------------
  // 重新定位：用户自己挪过文件，只改记录不动文件
  // ---------------------------------------------------------------------------

  /// 在 [folder] 里找这条任务的文件，找到就把记录改指过去。
  ///
  /// 认三种摆法：`folder/<文件或图库文件夹名>`；单图的 `folder/<标题>/<文件>`；
  /// 图库任务时用户直接挑中了图库文件夹本身。视频按大小再核一次，
  /// 免得认到一个同名的别的文件。
  Future<bool> relinkFromFolder(DownloadTask task, String folder) async {
    final isGallery = task.extData?.type == DownloadTaskExtDataType.gallery;
    final name = p.basename(task.savePath);
    final candidates = <String>[
      p.join(folder, name),
      if (!isGallery)
        p.join(folder, relativeLayoutOf(task, isDirectory: false)),
      if (isGallery) folder,
    ];
    for (final candidate in candidates) {
      if (await relinkTo(task, candidate)) return true;
    }
    return false;
  }

  Future<bool> _holdsOnlyGalleryFiles(DownloadTask task, String folder) async {
    final owned = DownloadService.galleryOwnedFileNames(task);
    try {
      await for (final entity in Directory(folder).list(followLinks: false)) {
        if (entity is! File) return false;
        final name = p.basename(entity.path);
        // 系统自己丢进来的元数据文件不算「别人的东西」。
        if (DownloadService.systemMetadataFileNames.contains(name)) continue;
        if (!owned.contains(name)) return false;
      }
    } catch (e) {
      LogUtils.w('列不出候选图库文件夹: $folder ($e)', _tag);
      return false;
    }
    return true;
  }

  /// 核对 [candidate] 确实是这条任务的文件（图库：里面有我们记着的图；
  /// 视频 / 单图：大小分毫不差），是就把记录改指过去。
  Future<bool> relinkTo(DownloadTask task, String candidate) async {
    final isGallery = task.extData?.type == DownloadTaskExtDataType.gallery;
    final type = await FileSystemEntity.type(candidate);
    if (isGallery) {
      if (type != FileSystemEntityType.directory) return false;
      if (!await looksLikeGalleryFolder(task, candidate)) return false;
      // 混着别人文件的文件夹不能认作图库：之后「移动文件」会整夹搬走它，
      // 「删除」虽只删自己的图，搬家却不会只搬一半。
      if (!await _holdsOnlyGalleryFiles(task, candidate)) return false;
    } else {
      if (type != FileSystemEntityType.file) return false;
      if (task.totalBytes > 0 &&
          await File(candidate).length() != task.totalBytes) {
        return false;
      }
    }
    final stat = isGallery ? null : await File(candidate).stat();
    _repository.relocateTaskPath(
      taskId: task.id,
      oldPath: task.savePath,
      newPath: p.normalize(candidate),
      newSizeBytes: stat?.size,
      newModifiedAt: stat?.modified.millisecondsSinceEpoch,
    );
    LogUtils.i('已重新定位: ${task.savePath} -> $candidate', _tag);
    _afterPathsChanged();
    return true;
  }
}

class _SourceLocked implements Exception {
  const _SourceLocked();
}
