import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/db/migrations/migration_v21_watch_later.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

/// 稍后再看的本地队列。跑真 sqlite（内存库），因为要验的多半就是 SQL 本身：
/// 淘汰序、未看完筛选、进度只增不减。
void main() {
  late Database db;
  late WatchLaterService service;
  var foreground = true;

  Video video(String id, {bool external = false}) {
    return Video(
      id: id,
      title: 'video $id',
      embedUrl: external ? 'https://www.youtube.com/watch?v=$id' : null,
    );
  }

  ImageModel gallery(String id) => ImageModel(id: id, title: 'gallery $id');

  /// 直接改 added_at，让"谁更旧"可控（服务写的是当前秒，同一测试里全都相同）。
  void setAddedAt(String itemId, int seconds) {
    db.execute('UPDATE watch_later SET added_at = ? WHERE item_id = ?', [
      seconds,
      itemId,
    ]);
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 迁移与 service 内部都会写日志，未初始化 logger 会抛 LateInitializationError
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    MigrationV21WatchLater().up(db);
    foreground = true;
    service = WatchLaterService(database: db, isForeground: () => foreground);
  });

  tearDown(() => db.close());

  group('加入与去重', () {
    test('加入视频后 contains 为真，重复加入返回 alreadyExists 且不产生第二条', () {
      expect(service.addVideo(video('v1')), WatchLaterAddResult.added);
      expect(service.contains('v1', WatchLaterItemType.video), isTrue);

      expect(service.addVideo(video('v1')), WatchLaterAddResult.alreadyExists);
      expect(service.count(), 1);
    });

    test('视频与图库用同一个 id 不会互相顶掉（唯一键是 id + 类型）', () {
      expect(service.addVideo(video('same')), WatchLaterAddResult.added);
      expect(service.addImageModel(gallery('same')), WatchLaterAddResult.added);
      expect(service.count(), 2);
    });

    test('站外视频加入时就被标成已看完——它永远不会在内置播放器里被看完', () {
      service.addVideo(video('ext', external: true));
      final item = service.query().single;
      expect(item.isExternal, isTrue);
      expect(item.isWatched, isTrue);
    });

    test('写操作会推 watchLaterChangedNotifier', () {
      final before = service.watchLaterChangedNotifier.value;
      service.addVideo(video('v1'));
      expect(service.watchLaterChangedNotifier.value, greaterThan(before));
    });
  });

  group('查询与筛选', () {
    setUp(() {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      service.addImageModel(gallery('g1'));
      setAddedAt('v1', 100);
      setAddedAt('v2', 200);
      setAddedAt('g1', 300);
    });

    test('按类型分家', () {
      expect(service.query(itemType: WatchLaterItemType.video).length, 2);
      expect(service.query(itemType: WatchLaterItemType.image).length, 1);
    });

    test('最近添加 / 最早添加两档排序方向相反', () {
      final recent = service
          .query(sort: WatchLaterSort.recentlyAdded)
          .map((e) => e.itemId)
          .toList();
      final earliest = service
          .query(sort: WatchLaterSort.earliestAdded)
          .map((e) => e.itemId)
          .toList();
      expect(recent, ['g1', 'v2', 'v1']);
      expect(earliest, ['v1', 'v2', 'g1']);
    });

    test('未看完筛选把已看完的排除掉', () {
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );
      final unwatched = service
          .query(unwatchedOnly: true)
          .map((e) => e.itemId)
          .toList();
      expect(unwatched, isNot(contains('v1')));
      expect(unwatched.length, 2);
    });

    test('excludeExternal 供抽屉用：站外视频不进连播队列', () {
      service.addVideo(video('ext', external: true));
      final queue = service.query(
        itemType: WatchLaterItemType.video,
        excludeExternal: true,
      );
      expect(queue.map((e) => e.itemId), isNot(contains('ext')));
    });

    test('分页在同秒加入时仍然稳定（次级键是自增 id）', () {
      db.execute('UPDATE watch_later SET added_at = 500');
      final page1 = service.query(limit: 2, offset: 0).map((e) => e.itemId);
      final page2 = service.query(limit: 2, offset: 2).map((e) => e.itemId);
      expect({...page1, ...page2}.length, 3);
    });
  });

  group('观看状态', () {
    test('进度 ≥90% 判为看完', () {
      service.addVideo(video('v1'));
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 9),
        duration: const Duration(minutes: 10),
      );
      expect(service.query().single.isWatched, isTrue);
    });

    test('剩余不足 10 秒也判为看完（长视频的片尾不该拖着不算）', () {
      service.addVideo(video('v1'));
      service.reportPlaybackProgress(
        videoId: 'v1',
        // 3 小时里的 5 秒尾巴，百分比只有 99.95%，但剩余 5 秒
        position: const Duration(hours: 2, minutes: 59, seconds: 55),
        duration: const Duration(hours: 3),
      );
      expect(service.query().single.isWatched, isTrue);
    });

    test('⛔ 应用不在前台时不写已看完，但进度照记', () {
      service.addVideo(video('v1'));
      foreground = false;
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );

      final item = service.query().single;
      expect(item.isWatched, isFalse, reason: '后台自动连播划过的不算看完');
      expect(item.progressPermil, 1000);
    });

    test('进度只往前推，不因为拖回开头而倒退', () {
      service.addVideo(video('v1'));
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 5),
        duration: const Duration(minutes: 10),
      );
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 1),
        duration: const Duration(minutes: 10),
      );
      expect(service.query().single.progressPermil, 500);
    });

    test('图库打开即已看', () {
      service.addImageModel(gallery('g1'));
      service.markGalleryOpened('g1');
      expect(service.query().single.isWatched, isTrue);
    });

    test('⛔ 失效标记可以恢复——瞬时 404 不该把条目永久废掉', () {
      service.addVideo(video('v1'));
      service.markInvalid('v1', WatchLaterItemType.video);
      expect(service.query().single.isInvalid, isTrue);

      // 下次能正常打开了
      service.clearInvalid('v1', WatchLaterItemType.video);
      expect(
        service.query().single.isInvalid,
        isFalse,
        reason: '没有恢复路径的话，一次 CDN 抖动就把用户的条目变灰废掉了',
      );
    });

    test('markInvalid 同时打失效与已看完，且不删除记录', () {
      service.addVideo(video('v1'));
      service.markInvalid('v1', WatchLaterItemType.video);

      final item = service.query().single;
      expect(item.isInvalid, isTrue);
      expect(item.isWatched, isTrue, reason: '永远看不完的东西不该在未看完里排队');
      expect(service.count(), 1, reason: '失效只标记、不自动删');
    });
  });

  group('容量淘汰', () {
    test('未超上限时一条都不淘汰', () {
      for (var i = 0; i < 10; i++) {
        service.addVideo(video('v$i'));
      }
      expect(service.count(), 10);
    });

    test('超上限时优先淘汰"已看完里最旧的"，没看完的留着', () {
      // 直接灌满到上限，绕开逐条 addVideo 的开销
      final stmt = db.prepare(
        'INSERT INTO watch_later (item_id, item_type, title, added_at, watched_at) '
        "VALUES (?, 'video', ?, ?, ?)",
      );
      try {
        for (var i = 0; i < WatchLaterService.capacity; i++) {
          // 前 3 条：最旧、且未看完 —— 这三条必须活下来
          // 第 4 条：稍新一点、但已看完 —— 它才是该被淘汰的
          final watched = i == 3 ? 50 : null;
          stmt.execute(['seed$i', 'seed $i', i, watched]);
        }
      } finally {
        stmt.close();
      }
      expect(service.count(), WatchLaterService.capacity);

      service.addVideo(video('newcomer'));

      expect(service.count(), WatchLaterService.capacity);
      expect(service.contains('newcomer', WatchLaterItemType.video), isTrue);
      expect(
        service.contains('seed3', WatchLaterItemType.video),
        isFalse,
        reason: '已看完的应该先出列',
      );
      expect(
        service.contains('seed0', WatchLaterItemType.video),
        isTrue,
        reason: '更旧但没看完的必须留着——静默删掉攒了很久还没看的是最伤的失败模式',
      );
    });

    test('全都没看完时退回 FIFO，淘汰最旧的那条', () {
      final stmt = db.prepare(
        'INSERT INTO watch_later (item_id, item_type, title, added_at) '
        "VALUES (?, 'video', ?, ?)",
      );
      try {
        for (var i = 0; i < WatchLaterService.capacity; i++) {
          stmt.execute(['seed$i', 'seed $i', i + 1]);
        }
      } finally {
        stmt.close();
      }

      service.addVideo(video('newcomer'));

      expect(service.count(), WatchLaterService.capacity);
      expect(service.contains('seed0', WatchLaterItemType.video), isFalse);
      expect(service.contains('seed1', WatchLaterItemType.video), isTrue);
    });
  });

  group('一键清除已看完', () {
    test('只清已看完的，返回清掉的条数', () {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );

      expect(service.clearWatched(), 1);
      expect(service.query().map((e) => e.itemId), ['v2']);
    });

    test('按类型清除时不动另一类', () {
      service.addImageModel(gallery('g1'));
      service.addVideo(video('v1'));
      service.markGalleryOpened('g1');
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );

      expect(service.clearWatched(itemType: WatchLaterItemType.image), 1);
      expect(service.contains('v1', WatchLaterItemType.video), isTrue);
    });
  });

  group('批量移除', () {
    test('整批删掉，空输入不报错', () {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      service.addImageModel(gallery('g1'));

      expect(service.removeAll(const <WatchLaterItem>[]), 0);
      final targets = service.query(itemType: WatchLaterItemType.video);
      expect(service.removeAll(targets), 2);
      expect(service.query().map((e) => e.itemId), ['g1']);
    });
  });

  group('⛔ 通知节流：播完那一段不许把 notifier 刷爆', () {
    test('已看完之后再上报进度，不再重复推 notifier', () {
      service.addVideo(video('v1'));
      final before = service.watchLaterChangedNotifier.value;

      // 第一次跨过阈值：应该推一次（未看完 → 已看完的跃迁）
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 9),
        duration: const Duration(minutes: 10),
      );
      final afterFirst = service.watchLaterChangedNotifier.value;
      expect(afterFirst, greaterThan(before));

      // 之后 position 流还会回调很多次，一次都不该再推
      for (var i = 0; i < 20; i++) {
        service.reportPlaybackProgress(
          videoId: 'v1',
          position: Duration(minutes: 9, seconds: i),
          duration: const Duration(minutes: 10),
        );
      }
      expect(
        service.watchLaterChangedNotifier.value,
        afterFirst,
        reason: '每次都推的话，一条长视频最后 10% 会连锁触发上千次 DB 重查 + 整页重建',
      );
    });

    test('不在稍后再看里的视频，上报进度一次也不推 notifier', () {
      final before = service.watchLaterChangedNotifier.value;
      service.reportPlaybackProgress(
        videoId: 'not-in-list',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );
      expect(
        service.watchLaterChangedNotifier.value,
        before,
        reason: 'UPDATE 命中 0 行也推的话，全 App 所有播放都在交这份税',
      );
    });
  });

  group('撤销移除', () {
    test('restore 连加入时间一起还原，不会跑到列表顶端', () {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      setAddedAt('v1', 100);
      setAddedAt('v2', 200);

      final removed = service
          .query(sort: WatchLaterSort.earliestAdded)
          .firstWhere((e) => e.itemId == 'v1');
      service.remove('v1', WatchLaterItemType.video);
      expect(service.query().map((e) => e.itemId), ['v2']);

      service.restore(removed);
      expect(
        service.query(sort: WatchLaterSort.earliestAdded).map((e) => e.itemId),
        ['v1', 'v2'],
        reason: '当成新条目重加的话，撤销之后它会跑到最前面，用户会以为顺序被弄乱了',
      );
    });

    test('restore 保留已看完与进度', () {
      service.addVideo(video('v1'));
      service.reportPlaybackProgress(
        videoId: 'v1',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );
      final removed = service.query().single;
      service.remove('v1', WatchLaterItemType.video);
      service.restore(removed);

      final back = service.query().single;
      expect(back.isWatched, isTrue);
      expect(back.progressPermil, 1000);
    });
  });
}
