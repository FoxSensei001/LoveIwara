import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/db/migrations/migration_v21_watch_later.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

/// 视频池的推进规则。
///
/// 这里盯住的是**自动连播不许把用户扔进死胡同**的那几条：站外视频要跳过、
/// 「未看完」池要跳过已看完的、池到底了要老实返回 null（而不是绕回头无限刷）。
void main() {
  Video video(String id, {bool external = false}) => Video(
    id: id,
    title: 'video $id',
    embedUrl: external ? 'https://www.youtube.com/watch?v=$id' : null,
  );

  SourcePlaybackQueue sourceQueue(List<Video> videos, {String current = 'v0'}) {
    return SourcePlaybackQueue(
      queueId: 'test',
      context: InnerPlaylistContext.fromVideos(
        source: InnerPlaylistSource.popularVideoList,
        videos: videos,
        currentVideoId: current,
      ),
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  group('itemAfter：推进到下一条', () {
    test('按顺序给出下一条', () {
      final queue = sourceQueue([video('v0'), video('v1'), video('v2')]);
      expect(queue.itemAfter('v0')?.id, 'v1');
      expect(queue.itemAfter('v1')?.id, 'v2');
    });

    test('⛔ 站外视频一律跳过——自动推进撞上去会让连播链莫名其妙地断掉', () {
      final queue = sourceQueue([
        video('v0'),
        video('ext', external: true),
        video('v2'),
      ]);
      expect(queue.itemAfter('v0')?.id, 'v2');
    });

    test('池到底了返回 null，不绕回头', () {
      final queue = sourceQueue([video('v0'), video('v1')]);
      expect(
        queue.itemAfter('v1'),
        isNull,
        reason: '绕回头就是无限刷，和"临时队列"的定位相反；到底应该停在最后一条',
      );
    });

    test('全是站外视频时也返回 null，而不是死循环', () {
      final queue = sourceQueue([
        video('v0'),
        video('e1', external: true),
        video('e2', external: true),
      ]);
      expect(queue.itemAfter('v0'), isNull);
    });

    test('⛔ 当前条不在池里时返回 null，而不是从头挑一条', () {
      final queue = sourceQueue([video('v1'), video('v2')]);
      expect(
        queue.itemAfter('gone'),
        isNull,
        reason: '从头再挑一条正是"续播莫名跳回列表顶部"的成因；停下比跳到没预期的位置好',
      );
    });

    test('空池返回 null', () {
      expect(sourceQueue(const []).itemAfter('v0'), isNull);
    });
  });

  group('稍后再看池', () {
    late Database db;
    late WatchLaterService service;

    setUp(() {
      db = sqlite3.openInMemory();
      MigrationV21WatchLater().up(db);
      service = WatchLaterService(database: db, isForeground: () => true);
    });

    tearDown(() => db.close());

    WatchLaterPlaybackQueue queue({required bool unwatchedOnly}) =>
        WatchLaterPlaybackQueue(
          queueId: 'wl',
          unwatchedOnly: unwatchedOnly,
          service: service,
          sort: WatchLaterSort.earliestAdded,
        );

    test('只装视频，图库不进连播队列', () {
      service.addVideo(video('v1'));
      service.addImageModel(ImageModel(id: 'g1', title: 'gallery'));
      expect(queue(unwatchedOnly: false).loaded.map((e) => e.id), ['v1']);
    });

    test('站外视频不进连播队列', () {
      service.addVideo(video('v1'));
      service.addVideo(video('ext', external: true));
      expect(queue(unwatchedOnly: false).loaded.map((e) => e.id), ['v1']);
    });

    test('⛔ 「未看完」池按进入时快照钉住：当前这条播完不会把自己从池里删掉', () {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      service.addVideo(video('v3'));
      db.execute("UPDATE watch_later SET added_at = 1 WHERE item_id = 'v1'");
      db.execute("UPDATE watch_later SET added_at = 2 WHERE item_id = 'v2'");
      db.execute("UPDATE watch_later SET added_at = 3 WHERE item_id = 'v3'");

      final q = queue(unwatchedOnly: true);
      expect(q.loaded.map((e) => e.id), ['v1', 'v2', 'v3']);

      // 播完 v2（这会推 notifier，池跟着重查）
      service.reportPlaybackProgress(
        videoId: 'v2',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );

      expect(
        q.loaded.map((e) => e.id),
        ['v1', 'v2', 'v3'],
        reason: '刚看完的那条不能从池里消失，否则推进时找不到自己就会跳回顶部',
      );
      expect(
        q.itemAfter('v2', skipWatched: true)?.id,
        'v3',
        reason: '应该接着往下播，而不是跳回 v1',
      );
    });

    test('用户主动删掉的条目会离开已钉住的池', () {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      final q = queue(unwatchedOnly: true);
      expect(q.loaded.length, 2);

      service.remove('v1', WatchLaterItemType.video);
      expect(
        q.loaded.map((e) => e.id),
        ['v2'],
        reason: '删除是明确意图，和"刚看完"不是一回事',
      );
    });

    test('「全部」池不跳过已看完，「未看完」池跳过', () {
      service.addVideo(video('v1'));
      service.addVideo(video('v2'));
      service.addVideo(video('v3'));
      db.execute("UPDATE watch_later SET added_at = 1 WHERE item_id = 'v1'");
      db.execute("UPDATE watch_later SET added_at = 2 WHERE item_id = 'v2'");
      db.execute("UPDATE watch_later SET added_at = 3 WHERE item_id = 'v3'");
      service.reportPlaybackProgress(
        videoId: 'v2',
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );

      // 「全部」池里 v2 还在，skipWatched 决定跳不跳
      final all = queue(unwatchedOnly: false);
      expect(all.itemAfter('v1', skipWatched: false)?.id, 'v2');
      expect(all.itemAfter('v1', skipWatched: true)?.id, 'v3');

      // 「未看完」池干脆不装已看完的
      expect(queue(unwatchedOnly: true).loaded.map((e) => e.id), ['v1', 'v3']);
    });

    test('库里变了池会自己跟着重查', () {
      final q = queue(unwatchedOnly: false);
      expect(q.loaded, isEmpty);
      service.addVideo(video('v1'));
      expect(q.loaded.map((e) => e.id), ['v1']);
    });

    test('失效项不进连播队列——点了只会撞一次错误', () {
      service.addVideo(video('v1'));
      service.addVideo(video('dead'));
      service.markInvalid('dead', WatchLaterItemType.video);
      expect(queue(unwatchedOnly: false).loaded.map((e) => e.id), ['v1']);
    });
  });

  group('⛔ 分页边界：itemAfter 返回 null ≠ 池到底了', () {
    test('已加载部分到头但还有下一页时，needsMoreToAdvance 为真', () async {
      final queue = _FakePagedQueue([
        ['v0', 'v1'],
        ['v2'],
      ]);
      await queue.loadMore(); // 只拉第 0 页

      expect(queue.itemAfter('v1'), isNull, reason: '第 2 页还没拉进来');
      expect(
        queue.needsMoreToAdvance('v1'),
        isTrue,
        reason: '不区分这两种 null，40 条的播放列表连播到第 32 条就会停',
      );
    });

    test('翻完最后一页之后 needsMoreToAdvance 为假', () async {
      final queue = _FakePagedQueue([
        ['v0', 'v1'],
        ['v2'],
      ]);
      await queue.loadMore();
      await queue.loadMore();

      expect(queue.itemAfter('v1')?.id, 'v2');
      expect(queue.needsMoreToAdvance('v2'), isFalse);
    });

    test('⛔ 请求失败不把 hasMore 钉成 false——一次网络抖动不该永久停止翻页', () async {
      final queue = _FakePagedQueue([
        ['v0'],
        ['v1'],
      ], failNextLoad: true);

      await queue.loadMore(); // 这次失败
      expect(queue.hasMore, isTrue, reason: '失败只是这一次失败，不是到底了');

      await queue.loadMore(); // 重试成功
      expect(queue.loaded.map((e) => e.id), ['v0']);
    });
  });
}

/// 一个受控的分页池：用来验"到分页边界"与"真到底"必须分开。
class _FakePagedQueue extends PlaybackQueue {
  _FakePagedQueue(this._pages, {bool failNextLoad = false})
    : _failNext = failNextLoad,
      super(queueId: 'fake');

  final List<List<String>> _pages;
  final List<InnerPlaylistItemSnapshot> _items = [];
  int _next = 0;
  bool _hasMore = true;
  bool _failNext;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.playlist;

  @override
  List<InnerPlaylistItemSnapshot> get loaded => _items;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<void> loadMore() async {
    if (!_hasMore) return;
    if (_failNext) {
      _failNext = false;
      return; // 失败：**不动 _hasMore**
    }
    if (_next >= _pages.length) {
      _hasMore = false;
      return;
    }
    final page = _pages[_next++];
    _items.addAll(
      page.map(
        (id) => InnerPlaylistItemSnapshot(
          id: id,
          title: id,
          thumbnailUrl: '',
          numViews: 0,
          numLikes: 0,
          numComments: 0,
          liked: false,
          isPrivate: false,
          isExternalVideo: false,
          externalVideoDomain: '',
        ),
      ),
    );
    _hasMore = _next < _pages.length;
  }
}
