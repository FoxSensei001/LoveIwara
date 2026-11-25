import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/frame_interp/frame_interp_task.model.dart';
import 'package:i_iwara/app/repositories/frame_interp_task_repository.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_component.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_service.dart';
import 'package:i_iwara/db/migrations/migration_v49_frame_interp_tasks.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// 补帧服务的测试分两半：
///
/// - 上半不碰引擎，任何机器上都跑。
/// - 下半是真刀真枪跑一遍补帧，需要一份编译好的组件和一段测试视频，由两个
///   环境变量指过来；没设就整组跳过（CI 上没有显卡，也没有组件）：
///     FRAME_INTERP_COMPONENT_DIR  组件目录（native/frame_interp 的 install 产物）
///     FRAME_INTERP_TEST_VIDEO     一段几秒长、帧率低于 50 的视频
void main() {
  group('成品路径', () {
    test('mp4 保持 mp4，其余落到 mkv', () {
      expect(
        FrameInterpService.outputPathFor(p.join('d', 'clip.mp4')),
        p.join('d', 'clip.fi2x.mp4'),
      );
      // mov 常带 PCM 音轨，mp4 不收，所以也归 mkv。
      expect(
        FrameInterpService.outputPathFor(p.join('d', 'clip.MOV')),
        p.join('d', 'clip.fi2x.mkv'),
      );
      expect(
        FrameInterpService.outputPathFor(p.join('d', 'clip.webm')),
        p.join('d', 'clip.fi2x.mkv'),
      );
      // 文件名里本来就带点号的，只换最后一段。
      expect(
        FrameInterpService.outputPathFor(p.join('d', 'a.b.c.mkv')),
        p.join('d', 'a.b.c.fi2x.mkv'),
      );
    });
  });

  group('成品重名', () {
    test('同名不同扩展名的两个片源不会落到同一个成品上', () {
      final taken = <String>{p.join('d', 'clip.fi2x.mp4')};
      final second = FrameInterpService.outputPathFor(
        p.join('d', 'clip.m4v'),
        taken: taken.contains,
      );
      expect(second, p.join('d', 'clip.m4v.fi2x.mp4'));

      taken.add(second);
      expect(
        FrameInterpService.outputPathFor(
          p.join('d', 'clip.m4v'),
          taken: taken.contains,
        ),
        p.join('d', 'clip.m4v.fi2x.2.mp4'),
      );
    });
  });

  group('任务表', () {
    late Database db;
    late FrameInterpTaskRepository repository;

    setUp(() {
      db = sqlite3.openInMemory();
      MigrationV49FrameInterpTasks().up(db);
      repository = FrameInterpTaskRepository(db);
    });

    tearDown(() => db.close());

    FrameInterpTask sample(String id, int createdAt) => FrameInterpTask(
      id: id,
      sourcePath: p.join('videos', '$id.mp4'),
      outputPath: p.join('videos', '$id.fi2x.mp4'),
      title: id,
      status: FrameInterpStatus.pending,
      width: 1920,
      height: 1080,
      sourceFps: 29.97,
      durationMs: 1000,
      sourceSize: 42,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    test('写进去的读得回来，新的排前面', () {
      repository.insert(sample('old', 1));
      repository.insert(sample('new', 2));

      final loaded = repository.loadAll();
      expect(loaded.map((task) => task.id), ['new', 'old']);
      expect(loaded.first.sourceFps, closeTo(29.97, 1e-9));
      expect(loaded.first.outputFps, closeTo(59.94, 1e-9));
      expect(loaded.first.status, FrameInterpStatus.pending);
    });

    test('状态更新只动状态相关的列', () {
      final task = sample('a', 1);
      repository.insert(task);
      repository.updateState(
        task.copyWith(
          status: FrameInterpStatus.failed,
          errorCode: FrameInterpError.write,
          error: 'disk full',
          progress: 0.4,
          updatedAt: 9,
        ),
      );

      final loaded = repository.loadAll().single;
      expect(loaded.status, FrameInterpStatus.failed);
      expect(loaded.errorCode, FrameInterpError.write);
      expect(loaded.error, 'disk full');
      expect(loaded.progress, closeTo(0.4, 1e-9));
      expect(loaded.sourcePath, task.sourcePath);
      expect(loaded.width, 1920);
    });

    test('库里出现认不得的状态时当作失败，而不是抛错', () {
      repository.insert(sample('a', 1));
      db.execute("UPDATE frame_interp_tasks SET status = 'from_the_future'");
      expect(repository.loadAll().single.status, FrameInterpStatus.failed);
    });
  });

  final componentDir = Platform.environment['FRAME_INTERP_COMPONENT_DIR'];
  final testVideo = Platform.environment['FRAME_INTERP_TEST_VIDEO'];
  final canRunEngine =
      componentDir != null &&
      componentDir.isNotEmpty &&
      testVideo != null &&
      testVideo.isNotEmpty;

  group('真实引擎', skip: canRunEngine ? false : '未提供组件目录和测试视频', () {
    late Database db;
    late Directory workDir;
    late FrameInterpService service;
    late List<FrameInterpTask> finished;

    setUp(() async {
      db = sqlite3.openInMemory();
      MigrationV49FrameInterpTasks().up(db);
      workDir = await Directory.systemTemp.createTemp('frame_interp_test_');
      finished = [];
      service = FrameInterpService(
        repository: FrameInterpTaskRepository(db),
        component: FrameInterpComponent(),
        onTaskFinished: finished.add,
      );
      service.onInit();
      await _until(() => service.component.isReady, 'component ready');
    });

    tearDown(() async {
      service.shutdownSync();
      db.close();
      await workDir.delete(recursive: true);
    });

    Future<String> copyVideo(String name) async {
      final target = p.join(workDir.path, '$name${p.extension(testVideo!)}');
      await File(testVideo).copy(target);
      return target;
    }

    test('排队 → 跑完 → 成品落在片源旁边，且不会被再次补帧', () async {
      final source = await copyVideo('clip');
      final result = await service.enqueue(sourcePath: source, title: 'clip');
      expect(result.ok, isTrue, reason: '被拒: ${result.reject}');

      // 同一个片源再点一次：认出已经在队列里。
      final again = await service.enqueue(sourcePath: source);
      expect(again.reject, FrameInterpReject.alreadyQueued);

      await _until(
        () => !service.tasks.single.status.isActive,
        'task finished',
        timeout: const Duration(minutes: 5),
      );
      final task = service.tasks.single;
      expect(task.status, FrameInterpStatus.completed, reason: '${task.error}');
      expect(task.encoder, isNotEmpty);
      expect(File(task.outputPath).existsSync(), isTrue);
      expect(File('${task.outputPath}.part').existsSync(), isFalse);
      expect(task.outputSize, File(task.outputPath).lengthSync());
      expect(finished.single.id, task.id);

      expect(service.isInterpolatedOutput(task.outputPath), isTrue);
      expect(service.completedOutputFor(source), task.outputPath);
      expect(service.activeProgress.value, isNull);

      final onOutput = await service.enqueue(sourcePath: task.outputPath);
      expect(onOutput.reject, FrameInterpReject.alreadyInterpolated);
      final onSource = await service.enqueue(sourcePath: source);
      expect(onSource.reject, FrameInterpReject.alreadyDone);

      // 落库的状态和内存一致。
      final stored = FrameInterpTaskRepository(db).loadAll().single;
      expect(stored.status, FrameInterpStatus.completed);
      expect(stored.outputSize, task.outputSize);
    }, timeout: const Timeout(Duration(minutes: 6)));

    test('跑到一半取消：不留半成品，可以重试', () async {
      final source = await copyVideo('cancel_me');
      final result = await service.enqueue(sourcePath: source);
      expect(result.ok, isTrue, reason: '被拒: ${result.reject}');
      final id = result.task!.id;

      await _until(
        () => (service.activeProgress.value?.framesWritten ?? 0) > 0,
        'first frames written',
        timeout: const Duration(minutes: 2),
      );
      service.cancel(id);
      await _until(
        () => !service.tasks.single.status.isActive,
        'task stopped',
        timeout: const Duration(seconds: 30),
      );

      final task = service.tasks.single;
      expect(task.status, FrameInterpStatus.cancelled);
      expect(File(task.outputPath).existsSync(), isFalse);
      expect(File('${task.outputPath}.part').existsSync(), isFalse);
      expect(service.completedOutputFor(source), isNull);
      // 取消是用户自己点的，不该再弹「失败」。
      expect(finished, isEmpty);

      service.retry(id);
      expect(service.tasks.single.status.isActive, isTrue);
      await service.delete(id);
      await _until(() => service.tasks.isEmpty, 'task removed');
      expect(File('${task.outputPath}.part').existsSync(), isFalse);
    }, timeout: const Timeout(Duration(minutes: 4)));
  });
}

Future<void> _until(
  bool Function() condition,
  String what, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final clock = Stopwatch()..start();
  while (!condition()) {
    if (clock.elapsed > timeout) {
      fail('等了 ${timeout.inSeconds} 秒也没等到：$what');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
