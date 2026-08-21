import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download/download_state_log.dart';

/// 单条活跃任务的可观察句柄。
///
/// 每一行列表项只订阅自己的 [revision]，因此任意一条任务状态变化都**只**重建
/// 那一行，不会牵动整列（更不会牵动底部分页的历史区）。
///
/// 句柄持有的是与 `DownloadService` 内存中**同一个** [DownloadTask] 实例，不是
/// 副本——避免「服务改了一份、UI 看的是另一份」的经典分叉。也正因为是同一实例，
/// 就地改字段不会改变对象身份，用 `Rx<DownloadTask>` 的相等性判断会认为「没变」；
/// 所以这里用一个自增的版本号当通知信号，语义明确且不依赖对象是否被替换。
class DownloadTaskHandle {
  DownloadTaskHandle(this._task);

  DownloadTask _task;

  /// 变更计数。UI 侧 `Obx` 读一下它即可订阅这一行。
  final RxInt revision = 0.obs;

  DownloadTask get task => _task;

  /// 绑定最新的任务对象（可能是同一实例被就地改过）并通知该行重建。
  void bind(DownloadTask task) {
    _task = task;
    revision.value++;
  }
}

/// 活跃任务（pending / downloading / paused / failed）的内存单一真源。
///
/// 为什么需要它：此前每个区（下载中 / 等待 / 失败 / 历史）各自查一次 DB，靠一个
/// 全局版本号广播触发「各区全量重查」。这个模式不保证一致性——各区的重查是独立的
/// 异步过程，同一条任务在两个区的快照可以来自不同时刻，于是要靠脏标记重跑、刷新
/// 串行化、删除墓碑、跨区去重四套补丁去兜；补丁只压住症状，压不住成因。
///
/// 改成 Store 之后：
/// - 活跃任务只有一份内存真源，一条任务在任一时刻只归属一个区，跨区重复不再可能；
/// - 区的划分由 [downloadingIds] 等 id 列表表达，只有**结构变化**（新增/删除/换区）
///   才触发列表重建，进度这类高频字段走各自的 progress trigger，不动结构；
/// - 已完成任务量大且只读，仍留在 DB 分页，由 [completedRevision] 做精确失效。
///
/// 活跃任务的量级天然有限（队列 + 失败 + 暂停），全量常驻内存没有负担。
class DownloadTaskStore {
  DownloadTaskStore();

  final Map<String, DownloadTaskHandle> _handles =
      <String, DownloadTaskHandle>{};

  /// 各区的任务 id（已排序）。UI 订阅这些列表来决定「有哪些行、什么顺序」。
  final RxList<String> downloadingIds = <String>[].obs;
  final RxList<String> pendingIds = <String>[].obs;
  final RxList<String> pausedIds = <String>[].obs;
  final RxList<String> failedIds = <String>[].obs;

  /// 历史区（completed，DB 分页）的失效信号：+1 表示「已完成集合可能变了，重拉」。
  final RxInt completedRevision = 0.obs;

  /// 判断某状态是否属于「活跃」——即常驻内存、由 Store 管辖的状态。
  static bool isActiveStatus(DownloadStatus status) =>
      status == DownloadStatus.downloading ||
      status == DownloadStatus.pending ||
      status == DownloadStatus.paused ||
      status == DownloadStatus.failed;

  DownloadTaskHandle? handleOf(String id) => _handles[id];

  DownloadTask? taskOf(String id) => _handles[id]?.task;

  bool contains(String id) => _handles.containsKey(id);

  int get activeCount => _handles.length;

  /// 当前全部活跃任务（顺序无保证，供筛选 / 统计使用）。
  Iterable<DownloadTask> get activeTasks =>
      _handles.values.map((handle) => handle.task);

  /// 全量装载活跃任务（启动时调用）。会丢弃此前的全部句柄。
  void hydrate(Iterable<DownloadTask> tasks) {
    _handles.clear();
    for (final task in tasks) {
      if (!isActiveStatus(task.status)) continue;
      _handles[task.id] = DownloadTaskHandle(task);
    }
    _rebuildRegions();
    DownloadStateLog.emit(
      this,
      'store/hydrate',
      detail: '${_handles.length} 条',
    );
  }

  /// 新增或更新一条任务。
  ///
  /// 任务离开活跃状态（完成）时自动移出内存并让历史区失效；
  /// 只改了元数据（如分类）时用 [touch]，不必走这里。
  void upsert(DownloadTask task) {
    final existing = _handles[task.id];

    if (!isActiveStatus(task.status)) {
      if (existing != null) {
        _handles.remove(task.id);
        _rebuildRegions();
      }
      // 活跃 -> 完成：这一条现在归历史区管，通知历史区重拉。
      invalidateCompleted();
      return;
    }

    if (existing == null) {
      _handles[task.id] = DownloadTaskHandle(task);
    } else {
      existing.bind(task);
    }
    _rebuildRegions();
  }

  /// 仅刷新某条任务所在行（元数据变更，如分类归属、文件名），不影响分区。
  void touch(String id) {
    _handles[id]?.bind(_handles[id]!.task);
  }

  /// 移除一条任务（删除）。返回它是否曾是活跃任务。
  bool remove(String id) {
    final removed = _handles.remove(id) != null;
    if (removed) {
      _rebuildRegions();
    } else {
      // 删的是历史区里的已完成任务，历史区需要重拉。
      invalidateCompleted();
    }
    return removed;
  }

  /// 批量移除（批量删除）。
  void removeAll(Iterable<String> ids) {
    var structureChanged = false;
    var touchedHistory = false;
    for (final id in ids) {
      if (_handles.remove(id) != null) {
        structureChanged = true;
      } else {
        touchedHistory = true;
      }
    }
    if (structureChanged) _rebuildRegions();
    if (touchedHistory) invalidateCompleted();
  }

  /// 让历史区（已完成，DB 分页）失效重拉。
  void invalidateCompleted() {
    completedRevision.value++;
  }

  /// 清空（服务销毁时）。
  void clear() {
    _handles.clear();
    downloadingIds.clear();
    pendingIds.clear();
    pausedIds.clear();
    failedIds.clear();
  }

  /// 按状态重算各区 id 列表。
  ///
  /// 活跃任务数量有限，每次结构变化重算一遍的成本可以忽略；换来的是「分区由状态
  /// 唯一决定」这个不变式——一条任务不可能同时出现在两个区，跨区去重逻辑因此消失。
  void _rebuildRegions() {
    final downloading = <DownloadTask>[];
    final pending = <DownloadTask>[];
    final paused = <DownloadTask>[];
    final failed = <DownloadTask>[];

    for (final handle in _handles.values) {
      switch (handle.task.status) {
        case DownloadStatus.downloading:
          downloading.add(handle.task);
        case DownloadStatus.pending:
          pending.add(handle.task);
        case DownloadStatus.paused:
          paused.add(handle.task);
        case DownloadStatus.failed:
          failed.add(handle.task);
        case DownloadStatus.completed:
          break;
      }
    }

    // 下载中 / 等待中按入队顺序（创建时间升序），符合队列语义；
    // 暂停 / 失败按最近变更在前，用户最关心的是刚出问题的那条。
    downloading.sort(_byCreatedAtAsc);
    pending.sort(_byCreatedAtAsc);
    paused.sort(_byUpdatedAtDesc);
    failed.sort(_byUpdatedAtDesc);

    downloadingIds.assignAll(downloading.map((t) => t.id));
    pendingIds.assignAll(pending.map((t) => t.id));
    pausedIds.assignAll(paused.map((t) => t.id));
    failedIds.assignAll(failed.map((t) => t.id));
  }

  static int _byCreatedAtAsc(DownloadTask a, DownloadTask b) {
    final ax = a.createdAt;
    final bx = b.createdAt;
    if (ax == null && bx == null) return a.id.compareTo(b.id);
    if (ax == null) return 1;
    if (bx == null) return -1;
    final cmp = ax.compareTo(bx);
    return cmp != 0 ? cmp : a.id.compareTo(b.id);
  }

  static int _byUpdatedAtDesc(DownloadTask a, DownloadTask b) {
    final ax = a.updatedAt ?? a.createdAt;
    final bx = b.updatedAt ?? b.createdAt;
    if (ax == null && bx == null) return a.id.compareTo(b.id);
    if (ax == null) return 1;
    if (bx == null) return -1;
    final cmp = bx.compareTo(ax);
    return cmp != 0 ? cmp : a.id.compareTo(b.id);
  }
}
