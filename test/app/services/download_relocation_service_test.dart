import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/download_missing_diagnosis.dart';
import 'package:i_iwara/app/services/download_relocation_service.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 真在磁盘上搬文件：同卷 rename、撞名、跨卷复制、以及被杀进程后的收尾。
///
/// 跨卷那条「复制 → 核对 → 转正」在单机临时目录里天然触发不了（同一个卷上
/// rename 总是成功），用 `forceCopyForTesting` 强制走它；真实的 EXDEV 仍需真机。
void main() {
  late CommonDatabase db;
  late DownloadTaskRepository repo;
  late DownloadRelocationService service;
  late Directory root;

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() async {
    db = sqlite3.openInMemory();
    await MigrationManager(
      migrations: MigrationManager.defaultMigrations()
          .where((m) => m.version != 7)
          .toList(),
    ).runMigrations(db);
    repo = DownloadTaskRepository(db);
    Get.put(DownloadService(repository: repo));
    // 注册真实的「已下载」同步：移动期间会挂起它的全量同步，而移除任务要等它
    // 同步一次——不注册的话两者互等的死锁在测试里永远暴露不出来。
    Get.put(
      DownloadsLibrarySyncService(
        repository: LocalMediaRepository(db),
        downloads: repo,
      ),
    );
    service = DownloadRelocationService(repository: repo);
    root = await Directory.systemTemp.createTemp('relocation_test_');
  });

  tearDown(() async {
    Get.reset();
    db.close();
    await root.delete(recursive: true);
  });

  String at(String relative) => p.join(root.path, relative);

  Future<File> writeFile(String relative, String content) async {
    final file = File(at(relative));
    await file.parent.create(recursive: true);
    return file.writeAsString(content);
  }

  void insertTask(
    String id,
    String savePath, {
    String mediaType = 'video',
    String? extData,
  }) {
    db.execute(
      'INSERT INTO download_tasks (id, url, save_path, file_name, status, '
      "ext_data, media_type) VALUES (?, 'u', ?, 'f', 'completed', ?, ?)",
      [id, savePath, extData, mediaType],
    );
  }

  String savePathOf(String id) =>
      db.select('SELECT save_path FROM download_tasks WHERE id = ?', [
            id,
          ]).single['save_path']
          as String;

  test('视频：搬到新文件夹，旧的消失，库指向新处，账本清空', () async {
    await writeFile('old/v.mp4', 'video-bytes');
    insertTask('t1', at('old/v.mp4'));

    final plan = await service.plan(['t1'], at('new'));
    final result = await service.run(plan);

    expect(result.moved, 1);
    expect(File(at('new/v.mp4')).readAsStringSync(), 'video-bytes');
    expect(File(at('old/v.mp4')).existsSync(), isFalse);
    expect(savePathOf('t1'), at('new/v.mp4'));
    expect(repo.pendingRelocations(), isEmpty);
  });

  String galleryExt(Map<String, String> localPaths) => jsonEncode({
    'type': 'gallery',
    'data': {'local_paths': localPaths},
  });

  test('删图库连文件：只删自己写的图，混着别人文件的文件夹原样留下', () async {
    // 模拟 savePath 指向一个混放目录（找回时挑中了它，或记录被污染）。
    await writeFile('mixed/1.jpg', 'a');
    await writeFile('mixed/1.jpg.poster.jpg', 'poster');
    await writeFile('mixed/holiday.png', 'not ours');
    await writeFile('mixed/sub/keep.txt', 'not ours either');
    insertTask(
      'g1',
      at('mixed'),
      mediaType: 'gallery',
      extData: galleryExt({'1': at('mixed/1.jpg')}),
    );

    final ok = await DownloadService.to.deleteTask('g1', silent: true);

    expect(ok, isTrue);
    expect(File(at('mixed/1.jpg')).existsSync(), isFalse);
    expect(File(at('mixed/1.jpg.poster.jpg')).existsSync(), isFalse);
    expect(File(at('mixed/holiday.png')).readAsStringSync(), 'not ours');
    expect(File(at('mixed/sub/keep.txt')).existsSync(), isTrue);
  });

  test('删图库连文件：文件夹里只有自己的图（外加系统元数据）就连夹子一起删', () async {
    await writeFile('g/1.jpg', 'a');
    await writeFile('g/.DS_Store', 'meta');
    insertTask(
      'g1',
      at('g'),
      mediaType: 'gallery',
      extData: galleryExt({'1': at('g/1.jpg')}),
    );

    expect(await DownloadService.to.deleteTask('g1', silent: true), isTrue);
    expect(Directory(at('g')).existsSync(), isFalse);
  });

  test('找回图库：混着别人文件的文件夹不认（否则之后移动会整夹搬走）', () async {
    await writeFile('pics/1.jpg', 'a');
    await writeFile('pics/holiday.png', 'not ours');
    insertTask(
      'g1',
      at('gone/g'),
      mediaType: 'gallery',
      extData: galleryExt({'1': at('gone/g/1.jpg')}),
    );
    final task = (await repo.getTaskById('g1'))!;

    expect(await service.relinkFromFolder(task, at('pics')), isFalse);
    expect(savePathOf('g1'), at('gone/g'));
  });

  test('目标处已有同名文件：绝不覆盖，换成带序号的名字', () async {
    await writeFile('old/v.mp4', 'mine');
    await writeFile('new/v.mp4', 'someone-else');
    insertTask('t1', at('old/v.mp4'));

    final result = await service.run(await service.plan(['t1'], at('new')));

    expect(result.moved, 1);
    expect(File(at('new/v.mp4')).readAsStringSync(), 'someone-else');
    expect(File(at('new/v (1).mp4')).readAsStringSync(), 'mine');
    expect(savePathOf('t1'), at('new/v (1).mp4'));
  });

  test('图库文件夹整个搬走，逐张路径跟着换', () async {
    await writeFile('old/g/1.jpg', 'a');
    await writeFile('old/g/2.jpg', 'b');
    insertTask(
      'g1',
      at('old/g'),
      mediaType: 'gallery',
      extData: jsonEncode({
        'type': 'gallery',
        'data': {
          'local_paths': {'1': at('old/g/1.jpg'), '2': at('old/g/2.jpg')},
        },
      }),
    );

    final result = await service.run(await service.plan(['g1'], at('new')));

    expect(result.moved, 1);
    expect(File(at('new/g/2.jpg')).readAsStringSync(), 'b');
    expect(Directory(at('old/g')).existsSync(), isFalse);
    final ext = jsonDecode(
      db.select('SELECT ext_data FROM download_tasks').single['ext_data']
          as String,
    );
    expect(ext['data']['local_paths']['1'], at('new/g/1.jpg'));
  });

  test('文件已不在的、本来就在目标处的跳过；没下完的照样纳入（只改路径）', () async {
    await writeFile('new/here.mp4', 'x');
    insertTask('here', at('new/here.mp4'));
    insertTask('gone', at('old/gone.mp4'));
    db.execute(
      "INSERT INTO download_tasks (id, url, save_path, file_name, status, "
      "media_type) VALUES ('half', 'u', ?, 'f', 'paused', 'video')",
      [at('old/half.mp4')],
    );

    final plan = await service.plan(['here', 'gone', 'half'], at('new'));

    expect(
      {for (final s in plan.skipped) s.task.id: s.reason},
      {
        'here': RelocationSkipReason.alreadyThere,
        'gone': RelocationSkipReason.sourceMissing,
      },
    );
    // 找不到的那条带着具体诊断：上级文件夹 old/ 本身就不存在。
    final gone = plan.skipped.firstWhere((s) => s.task.id == 'gone');
    expect(gone.diagnosis?.kind, MissingKind.folderMissing);
    expect(gone.diagnosis?.existingPrefix, root.path);
    // 暂停中、还没落盘的任务：纳入移动，但没有东西可搬。
    final half = plan.entries.single;
    expect(half.task.id, 'half');
    expect(half.hasSource, isFalse);

    final result = await service.run(plan);
    expect(result.moved, 1);
    expect(savePathOf('half'), at('new/half.mp4'));
  });

  test('暂停中的半截文件跟着搬，续传所需的字节一个不少', () async {
    await writeFile('old/half.mp4', 'partial-bytes');
    db.execute(
      "INSERT INTO download_tasks (id, url, save_path, file_name, status, "
      "downloaded_bytes, total_bytes, media_type) "
      "VALUES ('p', 'u', ?, 'f', 'paused', 13, 100, 'video')",
      [at('old/half.mp4')],
    );

    final result = await service.run(await service.plan(['p'], at('new')));

    expect(result.moved, 1);
    expect(File(at('new/half.mp4')).readAsStringSync(), 'partial-bytes');
    expect(File(at('old/half.mp4')).existsSync(), isFalse);
    expect(savePathOf('p'), at('new/half.mp4'));
  });

  test('找不到文件的选「移除记录」：删掉记录，存储没挂上的除外', () async {
    insertTask('gone', at('old/gone.mp4'));

    final plan = await service.plan(['gone'], at('new'));
    final result = await service.run(
      plan,
      options: const RelocationOptions(missingAction: MissingAction.remove),
    );

    expect(result.removed, ['gone']);
    expect(
      db.select('SELECT 1 FROM download_tasks WHERE id = ?', ['gone']),
      isEmpty,
    );
  });

  test('⛔ 移除与挂起的同步不互等：选「移除」的一批必须能走完', () async {
    await writeFile('old/v.mp4', 'v');
    insertTask('t1', at('old/v.mp4'));
    insertTask('gone', at('old/gone.mp4'));
    db.execute(
      "INSERT INTO download_tasks (id, url, save_path, file_name, status, "
      "media_type) VALUES ('bad', 'u', ?, 'f', 'failed', 'video')",
      [at('old/bad.mp4')],
    );

    final plan = await service.plan(['t1', 'gone', 'bad'], at('new'));
    final result = await service
        .run(
          plan,
          options: const RelocationOptions(
            missingAction: MissingAction.remove,
            failedAction: FailedAction.remove,
          ),
        )
        .timeout(const Duration(seconds: 10));

    expect(result.moved, 1);
    expect(result.removed, containsAll(['gone', 'bad']));
    expect(service.running.value, isFalse);
  });

  test('⛔ 「移除记录」只删记录：文件在确认之后回来了也不许删', () async {
    insertTask('gone', at('old/gone.mp4'));
    final plan = await service.plan(['gone'], at('new'));
    // 用户在确认框停留期间把卡插回 / 把文件挪回来了。
    await writeFile('old/gone.mp4', 'came-back');

    final result = await service.run(
      plan,
      options: const RelocationOptions(missingAction: MissingAction.remove),
    );

    expect(result.removed, ['gone']);
    expect(File(at('old/gone.mp4')).readAsStringSync(), 'came-back');
  });

  test('跨卷删源失败撤回：库指回原文件，本地条目的指纹也写回原文件的', () async {
    service.forceCopyForTesting = true;
    // 副本的修改时间带不过去（FAT/exFAT 那种卷）：这样副本与原文件的指纹不同，
    // 撤回时不写回原文件的指纹，断言就会失败。
    DownloadRelocationService.preserveModifiedTimeForTesting = false;
    addTearDown(
      () => DownloadRelocationService.preserveModifiedTimeForTesting = true,
    );
    final source = await writeFile('old/v.mp4', 'video-bytes');
    await source.setLastModified(DateTime(2020, 1, 1, 12));
    insertTask('t1', at('old/v.mp4'));
    final hash = LocalMediaItem.hashPath(at('old/v.mp4'));
    db.execute(
      'INSERT INTO local_media_items (id, source_id, path_hash, path, kind, '
      'name, sort_name, added_at, size_bytes, modified_at) '
      "VALUES (?, ?, ?, ?, 'video', 'v', 'v', 1, 11, ?)",
      [
        LocalMediaItem.buildId(kDownloadsSourceId, hash),
        kDownloadsSourceId,
        hash,
        at('old/v.mp4'),
        DateTime(2020, 1, 1, 12).millisecondsSinceEpoch,
      ],
    );
    // 源所在目录只读 → 能复制出去、删不掉源（模拟 Windows 上文件被占用）。
    await Process.run('chmod', ['555', at('old')]);
    addTearDown(() => Process.run('chmod', ['755', at('old')]));

    final result = await service.run(await service.plan(['t1'], at('new')));

    expect(result.failed['t1'], RelocationFailure.sourceLocked);
    expect(savePathOf('t1'), at('old/v.mp4'));
    expect(File(at('new/v.mp4')).existsSync(), isFalse);
    final item = db
        .select(
          'SELECT path, size_bytes, modified_at '
          'FROM local_media_items',
        )
        .single;
    expect(item['path'], at('old/v.mp4'));
    expect(item['size_bytes'], 11);
    expect(
      item['modified_at'],
      DateTime(2020, 1, 1, 12).millisecondsSinceEpoch,
    );
    expect(repo.pendingRelocations(), isEmpty);
    // 只读目录挡不住 root，Windows 上也没有 chmod：这两种环境跳过。
  }, skip: _cannotSimulateLockedSource());

  test('清理扫描：只报文件不在的已完成任务，并带诊断', () async {
    await writeFile('ok/a.mp4', 'a');
    insertTask('ok', at('ok/a.mp4'));
    insertTask('gone', at('old/gone.mp4'));

    final scan = await service.scanMissingCompleted();

    expect(scan.checked, 2);
    expect(scan.missing.map((s) => s.task.id), ['gone']);
    expect(scan.missing.single.diagnosis?.kind, MissingKind.folderMissing);
  });

  group('跨卷（强制走复制）', () {
    setUp(() => service.forceCopyForTesting = true);

    test('视频：复制后核对、改库、删源，不留临时文件', () async {
      await writeFile('old/v.mp4', 'video-bytes');
      insertTask('t1', at('old/v.mp4'));

      final progress = <int>[];
      final result = await service.run(
        await service.plan(['t1'], at('new')),
        onProgress: (p) => progress.add(p.doneBytes),
      );

      expect(result.moved, 1);
      expect(File(at('new/v.mp4')).readAsStringSync(), 'video-bytes');
      expect(File(at('old/v.mp4')).existsSync(), isFalse);
      expect(File(at('new/v.mp4.iwmove')).existsSync(), isFalse);
      expect(savePathOf('t1'), at('new/v.mp4'));
      expect(repo.pendingRelocations(), isEmpty);
      expect(progress.last, 'video-bytes'.length);
    });

    test('图库文件夹：整棵复制过去再删旧的', () async {
      await writeFile('old/g/1.jpg', 'a');
      await writeFile('old/g/sub/2.jpg', 'bb');
      insertTask('g1', at('old/g'), mediaType: 'gallery');

      final result = await service.run(await service.plan(['g1'], at('new')));

      expect(result.moved, 1);
      expect(File(at('new/g/sub/2.jpg')).readAsStringSync(), 'bb');
      expect(Directory(at('old/g')).existsSync(), isFalse);
      expect(Directory(at('new/g.iwmove')).existsSync(), isFalse);
      expect(savePathOf('g1'), at('new/g'));
    });

    test('复制到一半取消：半截临时文件清掉，源和库原样', () async {
      await writeFile('old/v.mp4', 'video-bytes');
      insertTask('t1', at('old/v.mp4'));
      final token = RelocationCancelToken();

      final result = await service.run(
        await service.plan(['t1'], at('new')),
        cancelToken: token,
        // 第一块写进临时文件之后按下停止。
        onProgress: (p) {
          if (p.doneBytes > 0) token.cancel();
        },
      );

      expect(result.cancelled, isTrue);
      expect(result.moved, 0);
      expect(File(at('old/v.mp4')).existsSync(), isTrue);
      expect(File(at('new/v.mp4')).existsSync(), isFalse);
      expect(File(at('new/v.mp4.iwmove')).existsSync(), isFalse);
      expect(savePathOf('t1'), at('old/v.mp4'));
    });
  });

  group('被杀进程后的收尾', () {
    test('复制已转正、库还指旧处、两边一样大：删掉新那份，源不动', () async {
      await writeFile('old/v.mp4', 'same');
      await writeFile('new/v.mp4', 'same');
      insertTask('t1', at('old/v.mp4'));
      repo.recordRelocation(
        taskId: 't1',
        srcPath: at('old/v.mp4'),
        destPath: at('new/v.mp4'),
      );

      await service.recoverJournal();

      expect(File(at('old/v.mp4')).existsSync(), isTrue);
      expect(File(at('new/v.mp4')).existsSync(), isFalse);
      expect(savePathOf('t1'), at('old/v.mp4'));
      expect(repo.pendingRelocations(), isEmpty);
    });

    test('rename 完、改库前被杀（源已不在）：补改库，不删任何东西', () async {
      await writeFile('new/v.mp4', 'moved');
      insertTask('t1', at('old/v.mp4'));
      repo.recordRelocation(
        taskId: 't1',
        srcPath: at('old/v.mp4'),
        destPath: at('new/v.mp4'),
      );

      await service.recoverJournal();

      expect(File(at('new/v.mp4')).readAsStringSync(), 'moved');
      expect(savePathOf('t1'), at('new/v.mp4'));
    });

    test('库已指新处、源还在且一样大：删掉残留的源', () async {
      await writeFile('old/v.mp4', 'same');
      await writeFile('new/v.mp4', 'same');
      insertTask('t1', at('new/v.mp4'));
      repo.recordRelocation(
        taskId: 't1',
        srcPath: at('old/v.mp4'),
        destPath: at('new/v.mp4'),
      );

      await service.recoverJournal();

      expect(File(at('old/v.mp4')).existsSync(), isFalse);
      expect(File(at('new/v.mp4')).existsSync(), isTrue);
    });

    test('⛔ 目标处的文件和源大小不一致：两边都不许动', () async {
      await writeFile('old/v.mp4', 'the-real-one');
      await writeFile('new/v.mp4', 'user-copied-something-else');
      insertTask('t1', at('old/v.mp4'));
      repo.recordRelocation(
        taskId: 't1',
        srcPath: at('old/v.mp4'),
        destPath: at('new/v.mp4'),
      );

      await service.recoverJournal();

      expect(File(at('old/v.mp4')).readAsStringSync(), 'the-real-one');
      expect(
        File(at('new/v.mp4')).readAsStringSync(),
        'user-copied-something-else',
      );
      expect(savePathOf('t1'), at('old/v.mp4'));
      expect(repo.pendingRelocations(), isEmpty);
    });

    test('半截临时文件一律清掉', () async {
      await writeFile('old/v.mp4', 'src');
      await writeFile('new/v.mp4.iwmove', 'half');
      insertTask('t1', at('old/v.mp4'));
      repo.recordRelocation(
        taskId: 't1',
        srcPath: at('old/v.mp4'),
        destPath: at('new/v.mp4'),
        tempPath: at('new/v.mp4.iwmove'),
      );

      await service.recoverJournal();

      expect(File(at('new/v.mp4.iwmove')).existsSync(), isFalse);
      expect(File(at('old/v.mp4')).readAsStringSync(), 'src');
    });
  });
}

bool _cannotSimulateLockedSource() {
  if (Platform.isWindows) return true;
  final uid = Process.runSync('id', ['-u']).stdout.toString().trim();
  return uid == '0';
}
