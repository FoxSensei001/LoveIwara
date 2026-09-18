import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_file_health.dart';
import 'package:i_iwara/utils/logger_utils.dart';

DownloadTask _task(String id, {String? path, DownloadStatus? status}) =>
    DownloadTask(
      id: id,
      url: 'https://example.test/$id',
      savePath: path ?? '/data/$id',
      fileName: id,
      status: status ?? DownloadStatus.completed,
    );

void main() {
  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  late Set<String> onDisk;
  late Set<String> recoverable;
  late Map<String, DownloadTask> db;
  late int statCalls;
  late DownloadFileHealth health;

  setUp(() {
    onDisk = {};
    recoverable = {};
    db = {};
    statCalls = 0;
    health = DownloadFileHealth(
      autoWire: false,
      loadTask: (id) async => db[id],
      exists: (path) async {
        statCalls++;
        return onDisk.contains(path);
      },
      isRecoverable: (task) async => recoverable.contains(task.id),
      fullScan: () async => null,
      computeOutside: () async => null,
    );
  });

  test('可见卡片攒批检查：失效 / 待确认分开，只数失效', () async {
    final a = _task('a');
    final b = _task('b');
    final c = _task('c');
    onDisk.add(a.savePath);
    recoverable.add('c');

    health
      ..noteVisible(a)
      ..noteVisible(b)
      ..noteVisible(c);
    await health.flushNow();

    expect(health.missingIds, {'b'});
    expect(health.pendingIds, {'c'});
    expect(health.count, 1);
    expect(health.stateOf('a'), DownloadFileState.present);
    expect(health.stateOf('b'), DownloadFileState.missing);
    expect(health.stateOf('c'), DownloadFileState.pending);
  });

  test('查过且路径没变的不再重复 stat；路径变了（移动过）就重查', () async {
    final a = _task('a');
    health.noteVisible(a);
    await health.flushNow();
    expect(statCalls, 1);

    health.noteVisible(a);
    await health.flushNow();
    expect(statCalls, 1);

    final moved = _task('a', path: '/new/a');
    onDisk.add(moved.savePath);
    health.noteVisible(moved);
    await health.flushNow();
    expect(statCalls, 2);
    expect(health.missingIds, isEmpty);
  });

  test('未完成的任务不进缓存', () async {
    health.noteVisible(_task('p', status: DownloadStatus.paused));
    await health.flushNow();
    expect(statCalls, 0);
    expect(health.stateOf('p'), isNull);
  });

  test('invalidate 丢掉结果，下次可见时重查', () async {
    final a = _task('a');
    health.noteVisible(a);
    await health.flushNow();
    expect(health.missingIds, {'a'});

    health.invalidate(['a']);
    expect(health.missingIds, isEmpty);
    expect(health.stateOf('a'), isNull);

    health.noteVisible(a);
    await health.flushNow();
    expect(health.missingIds, {'a'});
  });

  test('真源变化后的复查：删掉的 / 重新下载的出列，移回来的恢复', () async {
    final deleted = _task('deleted');
    final redownloading = _task('redl');
    final relocated = _task('moved');
    final stillGone = _task('gone');
    for (final t in [deleted, redownloading, relocated, stillGone]) {
      health.noteVisible(t);
    }
    await health.flushNow();
    expect(health.count, 4);

    // 删除：库里没了；重下：不再是已完成；移动：库里是新路径且文件在。
    db['redl'] = _task('redl', status: DownloadStatus.downloading);
    db['moved'] = _task('moved', path: '/new/moved');
    onDisk.add('/new/moved');
    db['gone'] = stillGone;

    await health.recheckKnown();

    expect(health.missingIds, {'gone'});
    expect(health.stateOf('deleted'), isNull);
    expect(health.stateOf('redl'), isNull);
    expect(health.stateOf('moved'), DownloadFileState.present);
  });
}
