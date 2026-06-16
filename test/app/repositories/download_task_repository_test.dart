import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/db/migrations/migration_v17_download_task_conflict_triggers.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

void createDownloadTasksTable(CommonDatabase db) {
  db.execute('''
    CREATE TABLE download_tasks(
      id TEXT PRIMARY KEY,
      url TEXT NOT NULL,
      save_path TEXT NOT NULL,
      file_name TEXT NOT NULL,
      total_bytes INTEGER NOT NULL DEFAULT 0,
      downloaded_bytes INTEGER NOT NULL DEFAULT 0,
      status TEXT NOT NULL,
      supports_range INTEGER NOT NULL DEFAULT 0,
      error TEXT,
      ext_data TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      media_type TEXT,
      media_id TEXT,
      quality TEXT,
      completed_at INTEGER
    );
  ''');
}

DownloadTask taskWithStatus(String id, DownloadStatus status) {
  return DownloadTask(
    id: id,
    url: 'https://example.test/$id',
    savePath: '/tmp/$id',
    fileName: 'matched_$id',
    status: status,
  );
}

DownloadTask videoTask({
  required String id,
  required String mediaId,
  required String quality,
  required String savePath,
}) {
  return DownloadTask(
    id: id,
    url: 'https://example.test/$id',
    savePath: savePath,
    fileName: '$id.mp4',
    status: DownloadStatus.pending,
    mediaType: 'video',
    mediaId: mediaId,
    quality: quality,
  );
}

void main() {
  late CommonDatabase db;
  late DownloadTaskRepository repository;

  setUp(() {
    db = sqlite3.openInMemory();
    createDownloadTasksTable(db);
    MigrationV17DownloadTaskConflictTriggers.createTriggers(db);
    repository = DownloadTaskRepository(db);
  });

  tearDown(() {
    db.close();
  });

  group('DownloadTaskRepository.searchTasks', () {
    test('history filter only returns paused and completed tasks', () async {
      await repository.insertTask(
        taskWithStatus('pending-task', DownloadStatus.pending),
      );
      await repository.insertTask(
        taskWithStatus('downloading-task', DownloadStatus.downloading),
      );
      await repository.insertTask(
        taskWithStatus('failed-task', DownloadStatus.failed),
      );
      await repository.insertTask(
        taskWithStatus('paused-task', DownloadStatus.paused),
      );
      await repository.insertTask(
        taskWithStatus('completed-task', DownloadStatus.completed),
      );

      final tasks = await repository.searchTasks(
        offset: 0,
        limit: 20,
        searchQuery: 'matched',
        statusFilter: 'history',
      );

      expect(tasks.map((task) => task.status).toSet(), {
        DownloadStatus.paused,
        DownloadStatus.completed,
      });
    });
  });

  group('DownloadTaskRepository.insertTask conflict protection', () {
    test(
      'rejects duplicate video media and quality at database boundary',
      () async {
        await repository.insertTask(
          videoTask(
            id: 'first',
            mediaId: 'video-1',
            quality: '720',
            savePath: '/tmp/first.mp4',
          ),
        );

        await expectLater(
          repository.insertTask(
            videoTask(
              id: 'second',
              mediaId: 'video-1',
              quality: '720',
              savePath: '/tmp/second.mp4',
            ),
          ),
          throwsA(
            isA<DuplicateDownloadTaskException>().having(
              (error) => error.type,
              'type',
              DownloadTaskConflictType.media,
            ),
          ),
        );
      },
    );

    test('allows the same video in a different quality', () async {
      await repository.insertTask(
        videoTask(
          id: 'source-task',
          mediaId: 'video-2',
          quality: 'source',
          savePath: '/tmp/source.mp4',
        ),
      );

      await repository.insertTask(
        videoTask(
          id: 'preview-task',
          mediaId: 'video-2',
          quality: '720',
          savePath: '/tmp/preview.mp4',
        ),
      );

      final tasks = await repository.getVideoTasksByMedia('video-2');
      expect(tasks.map((task) => task.quality).toSet(), {'source', '720'});
    });

    test('rejects duplicate save paths for new tasks', () async {
      await repository.insertTask(
        videoTask(
          id: 'path-owner',
          mediaId: 'video-3',
          quality: '720',
          savePath: '/tmp/shared.mp4',
        ),
      );

      await expectLater(
        repository.insertTask(
          videoTask(
            id: 'path-conflict',
            mediaId: 'video-4',
            quality: '720',
            savePath: '/tmp/shared.mp4',
          ),
        ),
        throwsA(
          isA<DuplicateDownloadTaskException>().having(
            (error) => error.type,
            'type',
            DownloadTaskConflictType.savePath,
          ),
        ),
      );
    });
  });

  group('DownloadTaskRepository history ordering', () {
    test('completed tasks are ordered by completed_at first', () async {
      final early = taskWithStatus('early-complete', DownloadStatus.completed)
        ..completedAt = DateTime.fromMillisecondsSinceEpoch(2000);
      final late = taskWithStatus('late-complete', DownloadStatus.completed)
        ..completedAt = DateTime.fromMillisecondsSinceEpoch(3000);

      await repository.insertTask(early);
      await repository.insertTask(late);

      final tasks = await repository.getCompletedTasks();

      expect(tasks.map((task) => task.id), ['late-complete', 'early-complete']);
    });
  });

  group('DownloadTask timestamp parsing', () {
    test(
      'created_at accepts millisecond timestamps for migrated data',
      () async {
        final createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);
        db.execute(
          '''
        INSERT INTO download_tasks
        (id, url, save_path, file_name, total_bytes, downloaded_bytes, status, supports_range, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            'millis-created',
            'https://example.test/millis-created',
            '/tmp/millis-created.mp4',
            'millis-created.mp4',
            0,
            0,
            DownloadStatus.pending.name,
            0,
            createdAt.millisecondsSinceEpoch,
            createdAt.millisecondsSinceEpoch,
          ],
        );

        final task = await repository.getTaskById('millis-created');

        expect(task?.createdAt?.toUtc(), createdAt);
      },
    );
  });
}
