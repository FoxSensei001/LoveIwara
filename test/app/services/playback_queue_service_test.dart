import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 视频池登记处的淘汰规则。
///
/// ⛔ 这里最要紧的一条是 **仍被监听的池不许淘汰**：把一个还有页面在听的
/// `ChangeNotifier` dispose 掉，下一次通知会炸「used after being disposed」，
/// 监听方 `removeListener` 在 debug 下也会抛。而播放列表池被误淘汰还有第二层
/// 代价——翻到第 8 页的游标一起没了，用户回来得从头拉。
void main() {
  late PlaybackQueueService service;

  InnerPlaylistContext context(String id) => InnerPlaylistContext.fromVideos(
    source: InnerPlaylistSource.popularVideoList,
    videos: [Video(id: id, title: id)],
    currentVideoId: id,
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    Get.reset();
    service = PlaybackQueueService();
  });

  test('同一个 key 重复打开命中缓存，不会建第二份', () {
    final first = service.openSource(context('a'), ownerKey: 'page1');
    final second = service.openSource(context('a'), ownerKey: 'page1');
    expect(identical(first, second), isTrue);
    expect(service.queueCount, 1);
  });

  test('不同页面实例的同源列表互不覆盖', () {
    service.openSource(context('a'), ownerKey: 'page1');
    service.openSource(context('b'), ownerKey: 'page2');
    expect(service.queueCount, 2, reason: '两层作者页看的是不同作者，池不能串');
  });

  test('超出上限时淘汰最久没用的', () {
    final overflow = PlaybackQueueService.maxQueues + 2;
    for (var i = 0; i < overflow; i++) {
      service.openSource(context('v$i'), ownerKey: 'page$i');
    }
    expect(service.queueCount, PlaybackQueueService.maxQueues);
    expect(service.byId('source:popularVideoList:page0'), isNull);
    expect(
      service.byId('source:popularVideoList:page${overflow - 1}'),
      isNotNull,
    );
  });

  test('byId 会把池挪到 LRU 队尾，避免刚用过的被淘汰', () {
    final cap = PlaybackQueueService.maxQueues;
    for (var i = 0; i < cap; i++) {
      service.openSource(context('v$i'), ownerKey: 'p$i');
    }

    // 摸一下最老的那个，它就不该是下一个被淘汰的
    service.byId('source:popularVideoList:p0');
    service.openSource(context('extra'), ownerKey: 'p$cap');

    expect(service.byId('source:popularVideoList:p0'), isNotNull);
    expect(service.byId('source:popularVideoList:p1'), isNull);
  });

  test('⛔ 刚登记的池不许被自己那次登记淘汰掉', () {
    // 塞满且全都有人听 —— 抽屉开着逛过一圈就是这个局面
    void listener() {}
    final busy = <PlaybackQueue>[];
    for (var i = 0; i < PlaybackQueueService.maxQueues; i++) {
      final queue = service.openSource(context('v$i'), ownerKey: 'busy$i');
      queue.addListener(listener);
      busy.add(queue);
    }

    // 再来一个：身上一个监听都没有，正是"第一个没人听的"
    final fresh = service.openSource(context('new'), ownerKey: 'fresh');

    // 炸点在这里：上一版 openPlaylist 会把刚造好的池 dispose 掉再还给调用方
    expect(
      () => fresh.addListener(listener),
      returnsNormally,
      reason: '刚登记的池被自己那次 _evictIfNeeded 淘汰了',
    );
    expect(service.byId('source:popularVideoList:fresh'), isNotNull);

    fresh.removeListener(listener);
    for (final queue in busy) {
      queue.removeListener(listener);
    }
  });

  test('⛔ 仍被监听的池不许淘汰——dispose 掉它会让监听方在下一次通知时炸', () {
    void listener() {}
    final kept = service.openSource(context('keep'), ownerKey: 'keeper');
    kept.addListener(listener);

    for (var i = 0; i < 5; i++) {
      service.openSource(context('v$i'), ownerKey: 'filler$i');
    }

    expect(
      service.byId('source:popularVideoList:keeper'),
      isNotNull,
      reason: '有页面在听它，淘汰会把还在用的池 dispose 掉',
    );
    // 还活着 → 加/减监听都不该抛
    expect(() => kept.removeListener(listener), returnsNormally);
  });
}
