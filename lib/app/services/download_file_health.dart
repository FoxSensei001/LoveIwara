import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/download/download_task.model.dart'
    hide FileSystemException;
import 'package:i_iwara/app/services/download_missing_diagnosis.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_relocation_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/rx_ever.dart';

/// 一条已完成任务的文件现在是什么状况。
enum DownloadFileState {
  /// 文件（图库是文件夹）还在记录的位置。
  present,

  /// 不在了，而且诊断不出「还能找回」的迹象——强提醒计数只数这一类。
  missing,

  /// 不在记录的位置，但像是还能找回（卷没挂上、没权限、iOS 容器换了、旁边
  /// 有疑似改名件，见 [isRecoverableMissing]）。只算「待确认」，不催用户。
  pending,
}

/// 已完成下载「文件还在不在」的会话级缓存。
///
/// # 为什么需要它
///
/// 文件被外部删掉 / 挪走之后，下载列表上那一行跟完好的一模一样，只有点开才
/// 弹「找不到文件」。清理入口又藏在 ⋮ 菜单里——用户根本不知道该去点。这里把
/// 「失效」变成一个随时可读的状态，列表的横幅、「需处理」筛选片和卡片上的
/// 标签都读它。
///
/// # 三条进料
///
/// 1. **可见卡片**：卡片第一次建出来时 [noteVisible]，攒一小批再统一 stat
///    （节流，不在 build 里做 IO）；
/// 2. **空闲全量**：启动后等一会儿，借 [DownloadRelocationService
///    .scanMissingCompleted] 全量扫一次（每个会话只扫一次）；
/// 3. **失效**：不靠各个入口记得调——订阅下载真源的 `completedRevision`
///    （删除 / 移动 / 重下 / 完成都会让它 +1），届时把已知失效 / 待确认的那几条
///    按库里的最新路径复查一遍；删掉的、不再是「已完成」的直接出列。卡片那一侧
///    按「记录的路径变了就重查」自愈，所以移动后不需要谁来清缓存。
///    [invalidate] 仍然留着，给确知某几条变了的调用点立即生效用。
///
/// 另外顺带维护 [outsideIds]：已完成、却不在当前下载目录里的任务（列表横幅
/// 「旧下载目录里还有 N 项」用），同样随真源与下载目录的变化重算。
class DownloadFileHealth extends GetxService {
  DownloadFileHealth({
    Future<DownloadTask?> Function(String id)? loadTask,
    Future<bool> Function(String path)? exists,
    Future<bool> Function(DownloadTask task)? isRecoverable,
    Future<List<({String id, String savePath, bool recoverable})>?> Function()?
    fullScan,
    Future<List<String>?> Function()? computeOutside,
    this.autoWire = true,
    this.batchDelay = const Duration(milliseconds: 250),
    this.recheckDelay = const Duration(milliseconds: 400),
    this.idleScanDelay = const Duration(seconds: 20),
  }) : _loadTask = loadTask ?? _defaultLoadTask,
       _exists = exists ?? _defaultExists,
       _isRecoverable = isRecoverable ?? _defaultIsRecoverable,
       _fullScan = fullScan ?? _defaultFullScan,
       _computeOutside = computeOutside ?? _defaultComputeOutside;

  static DownloadFileHealth get to => Get.find<DownloadFileHealth>();

  /// 页面 / 卡片读之前先问一句：测试环境、启动早期可能还没注册。
  static bool get isReady => Get.isRegistered<DownloadFileHealth>();

  static const _tag = 'DownloadFileHealth';

  /// 一批最多 stat 多少条。可见卡片一屏也就十几张，这里只是防止快速甩动时
  /// 攒下几百条一口气查完才更新界面。
  static const int _batchSize = 48;

  final Future<DownloadTask?> Function(String id) _loadTask;
  final Future<bool> Function(String path) _exists;
  final Future<bool> Function(DownloadTask task) _isRecoverable;
  final Future<List<({String id, String savePath, bool recoverable})>?>
  Function()
  _fullScan;
  final Future<List<String>?> Function() _computeOutside;

  /// false 时不订阅真源、不排空闲全量（测试用）。
  final bool autoWire;
  final Duration batchDelay;
  final Duration recheckDelay;
  final Duration idleScanDelay;

  /// 确认失效（不可找回）的已完成任务 id。
  final RxSet<String> missingIds = <String>{}.obs;

  /// 找不到、但可能还能找回的已完成任务 id（待确认）。
  final RxSet<String> pendingIds = <String>{}.obs;

  /// 已完成、却不在当前下载目录里的任务 id。
  final RxList<String> outsideIds = <String>[].obs;

  /// 强提醒计数：只数确认失效的那些。
  int get count => missingIds.length;

  /// 这条任务的文件状况；还没查过（或不是已完成任务）返回 null。
  ///
  /// 读的是 Rx，放在 Obx 里会随检查结果刷新。
  DownloadFileState? stateOf(String id) {
    // 两个都读，别短路：Obx 要把两者都登记成依赖。
    final missing = missingIds.contains(id);
    final pending = pendingIds.contains(id);
    if (missing) return DownloadFileState.missing;
    if (pending) return DownloadFileState.pending;
    return _checkedPath.containsKey(id) ? DownloadFileState.present : null;
  }

  /// id → 上次检查时的路径。路径变了（移动过）就当没查过。
  final Map<String, String> _checkedPath = {};

  /// 等着 stat 的任务（id → 任务快照）。
  final Map<String, DownloadTask> _queue = {};
  Timer? _batchTimer;
  bool _flushing = false;

  Timer? _recheckTimer;
  bool _rechecking = false;
  bool _recheckDirty = false;

  Timer? _idleTimer;
  bool _fullScanStarted = false;

  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    if (!autoWire) return;
    // 其它服务可能在本服务之后才 onInit 完，挪到微任务里再接线。
    Future.microtask(_wire);
  }

  void _wire() {
    if (Get.isRegistered<DownloadService>()) {
      _workers.add(
        // ⛔ rxEver 不是 ever：后者在「订阅→取消→再订阅」后永久失聪。
        rxEver(
          DownloadService.to.store.completedRevision,
          (_) => _scheduleRecheck(),
        ),
      );
    }
    if (Get.isRegistered<DownloadPathService>()) {
      _workers.add(
        rxEver(DownloadPathService.to.pathStatusRx, (_) => _scheduleRecheck()),
      );
    }
    _idleTimer = Timer(idleScanDelay, () => unawaited(runFullScan()));
  }

  @override
  void onClose() {
    for (final w in _workers) {
      w.dispose();
    }
    _workers.clear();
    _batchTimer?.cancel();
    _recheckTimer?.cancel();
    _idleTimer?.cancel();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // 进料 1：可见卡片
  // ---------------------------------------------------------------------------

  /// 一张已完成任务的卡片出现在屏幕上。查过且路径没变的直接跳过；其余攒进
  /// 队列，[batchDelay] 后统一查一批。可以在 build 里调：这里只记账、起定时器，
  /// 不碰 IO 也不改 Rx。
  void noteVisible(DownloadTask task) {
    if (task.status != DownloadStatus.completed) return;
    if (_checkedPath[task.id] == task.savePath) return;
    _queue[task.id] = task;
    _batchTimer ??= Timer(batchDelay, () {
      _batchTimer = null;
      unawaited(flushNow());
    });
  }

  /// 立即处理队列（测试也直接调它）。
  @visibleForTesting
  Future<void> flushNow() async {
    if (_flushing) return;
    _flushing = true;
    try {
      while (_queue.isNotEmpty) {
        final batch = _queue.values.take(_batchSize).toList();
        for (final task in batch) {
          _queue.remove(task.id);
        }
        final results = <String, DownloadFileState>{};
        for (final task in batch) {
          results[task.id] = await _check(task);
          _checkedPath[task.id] = task.savePath;
        }
        _apply(results);
      }
    } catch (e, s) {
      LogUtils.e('检查下载文件失败', tag: _tag, error: e, stackTrace: s);
    } finally {
      _flushing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 进料 2：空闲全量
  // ---------------------------------------------------------------------------

  /// 全量扫一次。每个会话只做一次；正在搬文件时让路（晚点真源变化会复查）。
  Future<void> runFullScan() async {
    if (_fullScanStarted) return;
    _fullScanStarted = true;
    try {
      final found = await _fullScan();
      if (found == null) {
        // 没扫成（服务没注册 / 正在搬文件）：下次真源变化后再试。
        _fullScanStarted = false;
        return;
      }
      absorbFullScan(found);
      await refreshOutside();
    } catch (e, s) {
      _fullScanStarted = false;
      LogUtils.e('全量检查下载文件失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  /// 收下一次**全量**扫描的结果（空闲全量，或用户手动点「检查文件完整性」
  /// 那一趟），以它为准整体替换失效 / 待确认集合。
  void absorbFullScan(
    Iterable<({String id, String savePath, bool recoverable})> found,
  ) {
    final missing = <String>{};
    final pending = <String>{};
    for (final row in found) {
      (row.recoverable ? pending : missing).add(row.id);
      _checkedPath[row.id] = row.savePath;
    }
    _fullScanStarted = true;
    _replace(missingIds, missing);
    _replace(pendingIds, pending);
  }

  // ---------------------------------------------------------------------------
  // 进料 3：失效
  // ---------------------------------------------------------------------------

  /// 确知这几条变了（删除 / 移动 / 重新下载之后）：丢掉缓存结果，下次卡片
  /// 出现时重查。
  void invalidate(Iterable<String> ids) {
    final list = ids.toList();
    if (list.isEmpty) return;
    for (final id in list) {
      _checkedPath.remove(id);
      _queue.remove(id);
    }
    missingIds.removeAll(list);
    pendingIds.removeAll(list);
  }

  void _scheduleRecheck() {
    _recheckTimer?.cancel();
    _recheckTimer = Timer(recheckDelay, () => unawaited(recheckKnown()));
  }

  /// 按库里的最新状况复查已知失效 / 待确认的那几条，并重算 [outsideIds]。
  ///
  /// 删掉的、被重新下载（不再是已完成）的出列；被移动过的按新路径重查。
  Future<void> recheckKnown() async {
    if (_rechecking) {
      _recheckDirty = true;
      return;
    }
    _rechecking = true;
    try {
      do {
        _recheckDirty = false;
        final ids = {...missingIds, ...pendingIds};
        final results = <String, DownloadFileState>{};
        final gone = <String>[];
        for (final id in ids) {
          final task = await _loadTask(id);
          if (task == null || task.status != DownloadStatus.completed) {
            gone.add(id);
            continue;
          }
          // 路径没变：只 stat 一下看它回没回来（SD 卡插回去了），不再重做
          // 列目录的诊断——批量下载时每完成一条都会走到这里，几百条待确认
          // 各诊断一遍就是持续的 IO。
          if (_checkedPath[id] == task.savePath) {
            if (await _exists(task.savePath)) {
              results[id] = DownloadFileState.present;
            }
            continue;
          }
          results[id] = await _check(task);
          _checkedPath[id] = task.savePath;
        }
        invalidate(gone);
        _apply(results);
        await refreshOutside();
        // 上次全量没扫成的，借这次机会补上。
        if (!_fullScanStarted && autoWire && _idleTimer?.isActive != true) {
          unawaited(runFullScan());
        }
      } while (_recheckDirty);
    } catch (e, s) {
      LogUtils.e('复查下载文件失败', tag: _tag, error: e, stackTrace: s);
    } finally {
      _rechecking = false;
    }
  }

  /// 重算「不在当前下载目录里」的已完成任务。
  Future<void> refreshOutside() async {
    try {
      final ids = await _computeOutside();
      if (ids == null) {
        if (outsideIds.isNotEmpty) outsideIds.clear();
        return;
      }
      if (!listEquals(outsideIds, ids)) outsideIds.assignAll(ids);
    } catch (e) {
      LogUtils.w('统计目录外的下载失败: $e', _tag);
    }
  }

  // ---------------------------------------------------------------------------
  // 内部
  // ---------------------------------------------------------------------------

  Future<DownloadFileState> _check(DownloadTask task) async {
    if (await _exists(task.savePath)) return DownloadFileState.present;
    try {
      return await _isRecoverable(task)
          ? DownloadFileState.pending
          : DownloadFileState.missing;
    } catch (e) {
      LogUtils.w('诊断失效下载失败，按失效处理: $e', _tag);
      return DownloadFileState.missing;
    }
  }

  void _apply(Map<String, DownloadFileState> results) {
    if (results.isEmpty) return;
    final addMissing = <String>[];
    final addPending = <String>[];
    final clearMissing = <String>[];
    final clearPending = <String>[];
    results.forEach((id, state) {
      switch (state) {
        case DownloadFileState.present:
          clearMissing.add(id);
          clearPending.add(id);
        case DownloadFileState.missing:
          addMissing.add(id);
          clearPending.add(id);
        case DownloadFileState.pending:
          addPending.add(id);
          clearMissing.add(id);
      }
    });
    // 只在集合真的变了时才动 Rx：每动一次都会让订阅它的 Obx 重建。
    if (clearMissing.any(missingIds.contains)) {
      missingIds.removeAll(clearMissing);
    }
    if (clearPending.any(pendingIds.contains)) {
      pendingIds.removeAll(clearPending);
    }
    if (!addMissing.every(missingIds.contains)) missingIds.addAll(addMissing);
    if (!addPending.every(pendingIds.contains)) pendingIds.addAll(addPending);
  }

  static void _replace(RxSet<String> target, Set<String> next) {
    if (setEquals(target, next)) return;
    target
      ..removeWhere((id) => !next.contains(id))
      ..addAll(next);
  }

  static Future<DownloadTask?> _defaultLoadTask(String id) async {
    if (!Get.isRegistered<DownloadService>()) return null;
    return DownloadService.to.repository.getTaskById(id);
  }

  static Future<bool> _defaultExists(String path) async =>
      await FileSystemEntity.type(path) != FileSystemEntityType.notFound;

  static Future<bool> _defaultIsRecoverable(DownloadTask task) async =>
      isRecoverableMissing(await diagnoseMissingDownload(task));

  static Future<List<({String id, String savePath, bool recoverable})>?>
  _defaultFullScan() async {
    if (!Get.isRegistered<DownloadRelocationService>()) return null;
    final relocation = DownloadRelocationService.to;
    if (relocation.running.value) return null;
    final scan = await relocation.scanMissingCompleted();
    return [
      for (final item in scan.missing)
        (
          id: item.task.id,
          savePath: item.task.savePath,
          recoverable: isRecoverableMissing(item.diagnosis),
        ),
    ];
  }

  static Future<List<String>?> _defaultComputeOutside() async {
    if (!Get.isRegistered<DownloadPathService>() ||
        !Get.isRegistered<DownloadRelocationService>()) {
      return null;
    }
    final pathService = DownloadPathService.to;
    final directory = await pathService.migrationTargetDirectory();
    if (directory == null) return null;
    // 对这个目录说过「不搬」就别再用横幅催（设置页那张卡片照常显示）。
    if (pathService.isOutsideDismissedFor(directory)) return null;
    return DownloadRelocationService.to.movableTaskIdsOutside(directory);
  }
}
