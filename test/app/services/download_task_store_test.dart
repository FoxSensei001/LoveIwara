import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download/download_task_store.dart';
import 'package:i_iwara/utils/logger_utils.dart';

DownloadTask task(
  String id,
  DownloadStatus status, {
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return DownloadTask(
    id: id,
    url: 'https://example.test/$id',
    savePath: '/tmp/$id',
    fileName: '$id.mp4',
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

void main() {
  late DownloadTaskStore store;

  setUpAll(() async {
    // Store 的装载路径会打诊断埋点（DownloadStateLog），需先初始化 late logger。
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() => store = DownloadTaskStore());

  group('分区不变式', () {
    test('活跃任务按状态各归其位，一条任务只出现在一个区', () {
      store.hydrate([
        task('a', DownloadStatus.downloading),
        task('b', DownloadStatus.pending),
        task('c', DownloadStatus.paused),
        task('d', DownloadStatus.failed),
      ]);

      expect(store.downloadingIds, ['a']);
      expect(store.pendingIds, ['b']);
      expect(store.pausedIds, ['c']);
      expect(store.failedIds, ['d']);

      final all = [
        ...store.downloadingIds,
        ...store.pendingIds,
        ...store.pausedIds,
        ...store.failedIds,
      ];
      expect(all.toSet().length, all.length, reason: '同一 id 不能出现在两个区');
    });

    test('已完成任务不进内存真源（它归 DB 分页的历史区）', () {
      store.hydrate([
        task('a', DownloadStatus.completed),
        task('b', DownloadStatus.pending),
      ]);

      expect(store.contains('a'), isFalse);
      expect(store.activeCount, 1);
    });
  });

  group('状态迁移', () {
    test('暂停：从下载中区搬到暂停区，不留残影', () {
      final t = task('a', DownloadStatus.downloading);
      store.hydrate([t]);

      t.status = DownloadStatus.paused;
      store.upsert(t);

      expect(store.downloadingIds, isEmpty);
      expect(store.pausedIds, ['a']);
    });

    test('继续：从暂停区回到等待区', () {
      final t = task('a', DownloadStatus.paused);
      store.hydrate([t]);

      t.status = DownloadStatus.pending;
      store.upsert(t);

      expect(store.pausedIds, isEmpty);
      expect(store.pendingIds, ['a']);
    });

    test('完成：移出活跃区并让历史区失效', () {
      final t = task('a', DownloadStatus.downloading);
      store.hydrate([t]);
      final before = store.completedRevision.value;

      t.status = DownloadStatus.completed;
      store.upsert(t);

      expect(store.contains('a'), isFalse);
      expect(store.downloadingIds, isEmpty);
      expect(store.completedRevision.value, greaterThan(before));
    });

    test('就地改状态后 upsert 会通知该行（同一实例也能触发）', () {
      final t = task('a', DownloadStatus.downloading);
      store.hydrate([t]);
      final handle = store.handleOf('a')!;
      final before = handle.revision.value;

      t.status = DownloadStatus.paused;
      store.upsert(t);

      expect(handle.revision.value, greaterThan(before));
      expect(
        identical(store.taskOf('a'), t),
        isTrue,
        reason: '不得复制任务对象，避免两份状态分叉',
      );
    });
  });

  group('删除', () {
    test('删除活跃任务：该行立刻消失', () {
      store.hydrate([
        task('a', DownloadStatus.pending),
        task('b', DownloadStatus.pending),
      ]);

      expect(store.remove('a'), isTrue);
      expect(store.pendingIds, ['b']);
    });

    test('删除已完成任务：不在内存里，但要让历史区重拉', () {
      store.hydrate([task('a', DownloadStatus.pending)]);
      final before = store.completedRevision.value;

      expect(store.remove('completed-one'), isFalse);
      expect(store.completedRevision.value, greaterThan(before));
    });

    test('批量删除混合任务：活跃行消失且历史区失效一次', () {
      store.hydrate([
        task('a', DownloadStatus.pending),
        task('b', DownloadStatus.failed),
      ]);
      final before = store.completedRevision.value;

      store.removeAll(['a', 'completed-one']);

      expect(store.pendingIds, isEmpty);
      expect(store.failedIds, ['b']);
      expect(store.completedRevision.value, before + 1);
    });
  });

  group('排序', () {
    test('下载中 / 等待中按创建时间升序（队列语义）', () {
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 2, 1);
      store.hydrate([
        task('new', DownloadStatus.pending, createdAt: newer),
        task('old', DownloadStatus.pending, createdAt: older),
      ]);

      expect(store.pendingIds, ['old', 'new']);
    });

    test('暂停 / 失败按最近变更在前', () {
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 2, 1);
      store.hydrate([
        task('old', DownloadStatus.failed, createdAt: older, updatedAt: older),
        task('new', DownloadStatus.failed, createdAt: older, updatedAt: newer),
      ]);

      expect(store.failedIds, ['new', 'old']);
    });
  });

  test('touch 只刷新行，不改变分区', () {
    final t = task('a', DownloadStatus.pending);
    store.hydrate([t]);
    final handle = store.handleOf('a')!;
    final before = handle.revision.value;

    t.categoryId = 'cat-1';
    store.touch('a');

    expect(handle.revision.value, greaterThan(before));
    expect(store.pendingIds, ['a']);
  });
}
