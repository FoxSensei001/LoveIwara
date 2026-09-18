import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 「移动已下载文件」改库那一步：路径一变，所有记着它的地方必须一起变。
void main() {
  late CommonDatabase db;
  late DownloadTaskRepository repo;

  setUpAll(() async {
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() async {
    db = sqlite3.openInMemory();
    // 用真实迁移建表：这里要验的正是生产 schema 上几张表之间的联动。
    await MigrationManager(
      migrations: MigrationManager.defaultMigrations()
          .where((m) => m.version != 7)
          .toList(),
    ).runMigrations(db);
    repo = DownloadTaskRepository(db);
  });

  tearDown(() => db.close());

  void insertTask(String id, String savePath, {String? extData}) {
    db.execute(
      'INSERT INTO download_tasks (id, url, save_path, file_name, status, '
      "ext_data, media_type) VALUES (?, 'u', ?, 'f', 'completed', ?, 'video')",
      [id, savePath, extData],
    );
  }

  test('视频：本地条目改主键，观看进度与 VR 覆盖跟着走', () {
    const oldPath = '/old/a.mp4';
    const newPath = '/new/a.mp4';
    insertTask('t1', oldPath);
    final oldId = LocalMediaItem.buildId(
      kDownloadsSourceId,
      LocalMediaItem.hashPath(oldPath),
    );
    final newId = LocalMediaItem.buildId(
      kDownloadsSourceId,
      LocalMediaItem.hashPath(newPath),
    );
    db.execute(
      'INSERT INTO local_media_items (id, source_id, path_hash, path, kind, '
      'name, sort_name, added_at, favorited_at, download_task_id) '
      "VALUES (?, ?, ?, ?, 'video', 'a', 'a', 1, 42, 't1')",
      [oldId, kDownloadsSourceId, LocalMediaItem.hashPath(oldPath), oldPath],
    );
    db.execute(
      'INSERT INTO local_media_progress (item_id, position_ms, updated_at) '
      'VALUES (?, 5000, 1)',
      [oldId],
    );
    db.execute(
      "INSERT INTO video_vr_override (video_id, projection, updated_at) "
      "VALUES (?, 'equirect180', 1)",
      [oldId],
    );
    repo.recordRelocation(taskId: 't1', srcPath: oldPath, destPath: newPath);

    repo.relocateTaskPath(
      taskId: 't1',
      oldPath: oldPath,
      newPath: newPath,
      newSizeBytes: 10,
      newModifiedAt: 20,
    );

    expect(
      db.select('SELECT save_path FROM download_tasks').first['save_path'],
      newPath,
    );
    final item = db.select('SELECT * FROM local_media_items').single;
    expect(item['id'], newId);
    expect(item['path'], newPath);
    expect(item['folder_path'], '/new');
    expect(item['favorited_at'], 42, reason: '原地改行，收藏这类列不能丢');
    expect(item['size_bytes'], 10);
    expect(item['modified_at'], 20);
    expect(
      db.select('SELECT item_id FROM local_media_progress').single['item_id'],
      newId,
    );
    expect(
      db.select('SELECT video_id FROM video_vr_override').single['video_id'],
      newId,
    );
    expect(repo.pendingRelocations(), isEmpty, reason: '改库与销账同一事务');
  });

  test('图库：ext_data 里落在旧文件夹下的逐张路径换到新文件夹，其余字段原样', () {
    const oldDir = '/old/gallery';
    const newDir = '/new/gallery (1)';
    final ext = jsonEncode({
      'type': 'gallery',
      'data': {
        'title': 'g',
        'unknown_future_key': 7,
        'local_paths': {
          'a': '$oldDir/1.jpg',
          'b': '$oldDir/sub/2.png',
          'c': '/elsewhere/3.jpg',
        },
      },
    });
    insertTask('g1', oldDir, extData: ext);

    repo.relocateTaskPath(taskId: 'g1', oldPath: oldDir, newPath: newDir);

    final row = db
        .select('SELECT save_path, ext_data FROM download_tasks')
        .single;
    expect(row['save_path'], newDir);
    final data = (jsonDecode(row['ext_data'] as String) as Map)['data'] as Map;
    expect(data['unknown_future_key'], 7);
    expect(data['local_paths'], {
      'a': '$newDir/1.jpg',
      'b': '$newDir/sub/2.png',
      'c': '/elsewhere/3.jpg',
    });
  });

  test('前缀相同但不是子目录的路径不会被误换', () {
    expect(
      DownloadTaskRepository.rebasePath(
        '/old/gallery2/x.jpg',
        '/old/gallery',
        '/n',
      ),
      '/old/gallery2/x.jpg',
    );
  });
}
