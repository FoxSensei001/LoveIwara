// 回归测试：目录树的完整性与「被跳过的目录」的可见性。
//
// 背景（真机报告）：把 Android 的 `/storage/emulated/0/Download` 加成本地源之后，
// 只有**顶层**的视频/图片被识别，它下面那一堆子文件夹一个都不出现，用户点不进去。
//
// 同一个 bug 有两条出口，都长成「目录在磁盘上明明在，库里一行都没有」：
//
// 1. `listSync` 抛异常（Android 只有 `READ_MEDIA_*`、没有「所有文件访问」时，
//    scoped storage 的 FUSE 会拦住对子目录的 list —— Download 根列得动，它下面
//    每个子目录都抛 EACCES）。原来只把它记进 `failedFolders` 就 `continue`。
// 2. 目录里有 `.nomedia`（第三方下载器会在每集目录里塞一个，把内容挡在系统相册
//    之外）。原来 `blocked = true; break;` 整棵子树跳过，同样一行不留。
//
// 父目录列得出子目录（它是 entries 里的一个 Directory），所以子目录被压进栈；
// 但两条出口都不会给它写行。浏览页的 `childFolders` 是按 `parent_rel_path`
// 点查那张表的，查不到就是不存在 —— 用户看到一张写着「这个文件夹是空的」的卡片。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 只建被扫描链路碰到的列/表，不复刻生产 DDL（那是迁移的事）。
CommonDatabase openTestDb() {
  final db = sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE local_media_sources(
      id TEXT PRIMARY KEY,
      kind TEXT NOT NULL,
      display_name TEXT NOT NULL,
      path TEXT,
      uri TEXT,
      media_kinds TEXT NOT NULL DEFAULT 'both',
      recursive INTEGER NOT NULL DEFAULT 1,
      auto_rescan INTEGER NOT NULL DEFAULT 1,
      sort_order INTEGER NOT NULL DEFAULT 0,
      scan_state TEXT NOT NULL DEFAULT 'idle',
      scan_cursor TEXT,
      offline INTEGER NOT NULL DEFAULT 0,
      last_scan_at INTEGER,
      item_count INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL
    );
  ''');
  db.execute('''
    CREATE TABLE local_media_items(
      id TEXT PRIMARY KEY,
      source_id TEXT NOT NULL,
      path_hash TEXT NOT NULL,
      path TEXT NOT NULL,
      kind TEXT NOT NULL,
      name TEXT NOT NULL,
      sort_name TEXT NOT NULL,
      ext TEXT,
      size_bytes INTEGER,
      modified_at INTEGER,
      duration_ms INTEGER,
      width INTEGER,
      height INTEGER,
      thumb_path TEXT,
      sidecar_image_path TEXT,
      vr_format_json TEXT,
      folder_path TEXT,
      category_id TEXT,
      download_task_id TEXT,
      last_played_at INTEGER,
      media_store_uri TEXT,
      favorited_at INTEGER,
      fps REAL,
      fps_probed_at INTEGER,
      added_at INTEGER NOT NULL,
      missing INTEGER NOT NULL DEFAULT 0,
      UNIQUE(source_id, path_hash)
    );
  ''');
  db.execute('''
    CREATE TABLE local_media_folders(
      id TEXT PRIMARY KEY,
      source_id TEXT NOT NULL,
      rel_path TEXT NOT NULL,
      parent_rel_path TEXT,
      name TEXT NOT NULL,
      sort_name TEXT NOT NULL,
      folder_path TEXT,
      video_count INTEGER NOT NULL DEFAULT 0,
      image_count INTEGER NOT NULL DEFAULT 0,
      child_folder_count INTEGER NOT NULL DEFAULT 0,
      cover_path TEXT,
      modified_at INTEGER,
      missing INTEGER NOT NULL DEFAULT 0,
      probed_at INTEGER,
      cover_pinned INTEGER NOT NULL DEFAULT 0,
      cover_borrowed INTEGER NOT NULL DEFAULT 0,
      UNIQUE(source_id, rel_path)
    );
  ''');
  db.execute('''
    CREATE TABLE local_media_progress(
      item_id TEXT PRIMARY KEY,
      position_ms INTEGER NOT NULL,
      duration_ms INTEGER,
      completed INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL
    );
  ''');
  return db;
}

/// 这一屏真正会画出来的子目录（浏览页用的就是 `includeEmpty: false` 这个口径）。
List<String> visibleChildRelPaths(LocalMediaRepository repo, String sourceId) {
  return repo
      .childFolders(sourceId: sourceId, parentRelPath: '')
      .map((folder) => folder.relPath)
      .toList();
}

void main() {
  test('多层嵌套子目录全部入库，且根目录下能查到它们', () async {
    final root = Directory.systemTemp.createTempSync('lm_tree_');
    try {
      Directory('${root.path}/Series A/Season 1').createSync(recursive: true);
      Directory('${root.path}/Series B').createSync(recursive: true);
      Directory('${root.path}/empty-cache').createSync(recursive: true);
      File('${root.path}/top.mp4').writeAsStringSync('x');
      File('${root.path}/cover.png').writeAsStringSync('x');
      File('${root.path}/Series A/ep1.mp4').writeAsStringSync('x');
      File('${root.path}/Series A/ep2.mp4').writeAsStringSync('x');
      File('${root.path}/Series A/Season 1/s1e1.mp4').writeAsStringSync('x');
      File('${root.path}/Series B/b1.mkv').writeAsStringSync('x');

      final repo = LocalMediaRepository(openTestDb());
      final source = LocalMediaSource(
        id: 'src-tree',
        kind: LocalMediaSourceKind.directory,
        displayName: 'Download',
        path: root.path,
        createdAt: 0,
      );
      repo.upsertSource(source);

      final service = LocalMediaScanService(repository: repo);
      // 加源时的全量扫描。
      await service.scanSource(source);
      // 进浏览页时的那一轮目录级懒扫描（两者都要成立）。
      await service.scanFolder(source: source, relPath: '');

      expect(
        visibleChildRelPaths(repo, source.id),
        containsAll(<String>['Series A', 'Series B']),
      );
      // 真的空目录照旧藏起来——别为了修上面那条把「藏空目录」整条规则推翻。
      expect(
        visibleChildRelPaths(repo, source.id),
        isNot(contains('empty-cache')),
      );
      // 第三层也要在（它挂在 Series A 下面）。
      expect(
        repo
            .childFolders(sourceId: source.id, parentRelPath: 'Series A')
            .map((folder) => folder.relPath),
        contains('Series A/Season 1'),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('读不动的子目录必须留一行占位，否则它在树里彻底消失', () async {
    final root = Directory.systemTemp.createTempSync('lm_denied_');
    final blocked = Directory('${root.path}/Blocked Series');
    try {
      blocked.createSync(recursive: true);
      Directory('${root.path}/Readable Series').createSync(recursive: true);
      File('${root.path}/top.mp4').writeAsStringSync('x');
      File('${root.path}/Readable Series/r1.mp4').writeAsStringSync('x');
      File('${blocked.path}/hidden.mp4').writeAsStringSync('x');

      // 让这个子目录读不动：非 root 下 listSync 会抛 FileSystemException。
      // 这与 Android 上 scoped storage 拦住子目录 list 的效果是同一条代码路径。
      Process.runSync('chmod', ['000', blocked.path]);

      final repo = LocalMediaRepository(openTestDb());
      final source = LocalMediaSource(
        id: 'src-denied',
        kind: LocalMediaSourceKind.directory,
        displayName: 'Download',
        path: root.path,
        createdAt: 0,
      );
      repo.upsertSource(source);

      await LocalMediaScanService(repository: repo).scanSource(source);

      expect(
        visibleChildRelPaths(repo, source.id),
        contains('Blocked Series'),
        reason: '读不动的子目录也必须有行，否则用户在树里根本看不到它',
      );
      // 占位行的语义必须是「不知道」而不是「探过且是空的」：probed_at 保持 NULL，
      // 用户点进去才会再触发一轮目录级扫描去重试。
      expect(
        repo.getFolder(sourceId: source.id, relPath: 'Blocked Series')?.probedAt,
        isNull,
      );
      // 能读的那一支照旧。
      expect(
        visibleChildRelPaths(repo, source.id),
        contains('Readable Series'),
      );
    } finally {
      Process.runSync('chmod', ['755', blocked.path]);
      root.deleteSync(recursive: true);
    }
  });

  test('含 .nomedia 的目录不再整棵跳过，里面的视频必须点得进去', () async {
    // 复刻真机现场：下载器在每集目录里放了一个 .nomedia。
    final root = Directory.systemTemp.createTempSync('lm_nomedia_');
    try {
      final episode = Directory('${root.path}/hanime_download/407963')
        ..createSync(recursive: true);
      File('${root.path}/top.mp4').writeAsStringSync('x');
      File('${episode.path}/.nomedia').writeAsStringSync('');
      File('${episode.path}/ep_480P.mp4').writeAsStringSync('x');
      File('${episode.path}/ep.png').writeAsStringSync('x');
      File('${episode.path}/info.json').writeAsStringSync('{}');

      final db = openTestDb();
      final repo = LocalMediaRepository(db);
      final source = LocalMediaSource(
        id: 'src-nomedia',
        kind: LocalMediaSourceKind.directory,
        displayName: 'Download',
        path: root.path,
        createdAt: 0,
      );
      repo.upsertSource(source);

      final service = LocalMediaScanService(repository: repo);
      // 加源时的全量扫描。
      await service.scanSource(source);
      // 进源根那一轮。
      await service.scanFolder(source: source, relPath: '');
      // ⛔ 用户点进 hanime_download 的那一轮 —— 原来正是这一步把 407963 收敛成
      // missing=1，于是父目录三个计数全 0、整张卡片变成「这个文件夹是空的」。
      await service.scanFolder(source: source, relPath: 'hanime_download');

      expect(
        repo
            .childFolders(
              sourceId: source.id,
              parentRelPath: 'hanime_download',
            )
            .map((folder) => folder.relPath),
        contains('hanime_download/407963'),
        reason: '父目录的懒扫描收敛不能把这一层判成 missing',
      );
      expect(
        visibleChildRelPaths(repo, source.id),
        contains('hanime_download'),
        reason: '子树里有媒体，父目录就该在源根这一屏出现',
      );

      final aliveVideos =
          db.select(
                'SELECT COUNT(*) AS c FROM local_media_items '
                "WHERE source_id = ? AND missing = 0 AND kind = 'video'",
                [source.id],
              ).first['c']
              as int;
      expect(
        aliveVideos,
        2,
        reason: '.nomedia 不该把 407963 里的视频挡在库外（top.mp4 + ep_480P.mp4）',
      );
      // `.nomedia` / `info.json` 不是媒体扩展名，不该变成条目。
      final aliveImages =
          db.select(
                'SELECT COUNT(*) AS c FROM local_media_items '
                "WHERE source_id = ? AND missing = 0 AND kind = 'image'",
                [source.id],
              ).first['c']
              as int;
      expect(aliveImages, 1, reason: '只有 ep.png 是图片');
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
