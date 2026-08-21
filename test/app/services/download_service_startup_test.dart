import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/db/migrations/migration_v17_download_task_conflict_triggers.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

import '../repositories/download_task_repository_test.dart'
    show createDownloadTasksTable, taskWithStatus;

/// 启动恢复语义：上次没跑完的任务一律置为暂停，不自动续传。
///
/// 这条语义直接关系到「杀进程/被系统杀掉之后重开应用会不会偷跑流量」，
/// 靠真机反复复现代价太高，用内存库把它钉死在单测里。
void main() {
  late CommonDatabase db;
  late DownloadTaskRepository repository;
  late DownloadService service;

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    createDownloadTasksTable(db);
    MigrationV17DownloadTaskConflictTriggers.createTriggers(db);
    repository = DownloadTaskRepository(db);
    service = DownloadService(repository: repository);
  });

  tearDown(() {
    db.close();
  });

  test('启动时 downloading 与 pending 一律置为暂停，且不进下载队列', () async {
    await repository.insertTask(
      taskWithStatus('was-downloading', DownloadStatus.downloading),
    );
    await repository.insertTask(
      taskWithStatus('was-pending', DownloadStatus.pending),
    );

    await service.onInit();

    expect(
      (await repository.getTaskById('was-downloading'))!.status,
      DownloadStatus.paused,
    );
    expect(
      (await repository.getTaskById('was-pending'))!.status,
      DownloadStatus.paused,
    );
    expect(service.getQueueIds(), isEmpty, reason: '不应自动续传');
    expect(service.store.pausedIds, containsAll(['was-downloading', 'was-pending']));
  });

  test('被自动暂停的任务会记进召回名单，供「全部继续」使用', () async {
    await repository.insertTask(
      taskWithStatus('was-downloading', DownloadStatus.downloading),
    );
    // 用户很早以前手动暂停的任务不该混进召回名单
    await repository.insertTask(
      taskWithStatus('manually-paused', DownloadStatus.paused),
    );

    await service.onInit();

    expect(service.restoredPausedIds, ['was-downloading']);
    expect(service.store.pausedIds, containsAll(['was-downloading', 'manually-paused']));
  });

  test('启动时把暂停与失败任务一并装载进内存真源', () async {
    await repository.insertTask(
      taskWithStatus('paused-one', DownloadStatus.paused),
    );
    await repository.insertTask(
      taskWithStatus('failed-one', DownloadStatus.failed),
    );
    await repository.insertTask(
      taskWithStatus('completed-one', DownloadStatus.completed),
    );

    await service.onInit();

    expect(service.store.pausedIds, ['paused-one']);
    expect(service.store.failedIds, ['failed-one']);
    expect(
      service.store.contains('completed-one'),
      isFalse,
      reason: '已完成任务归 DB 分页的历史区，不进内存',
    );
  });

  test('忽略提示条后召回名单清空', () async {
    await repository.insertTask(
      taskWithStatus('was-pending', DownloadStatus.pending),
    );
    await service.onInit();
    expect(service.restoredPausedIds, isNotEmpty);

    service.dismissRestoredPaused();

    expect(service.restoredPausedIds, isEmpty);
  });
}
