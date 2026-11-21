import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/services/video_cache_manager.dart';
import 'package:i_iwara/app/ui/pages/video_detail/services/video_detail_prefetcher.dart';

Video _video(String id, {String? fileUrl}) =>
    Video.fromJson({'id': id, 'title': 't', 'fileUrl': fileUrl});

List<VideoSource> _sources() => [
  VideoSource.fromJson({
    'id': 's',
    'name': 'Source',
    'src': {'view': '//cdn/x.mp4', 'download': '//cdn/x.mp4'},
  }),
];

void main() {
  final cache = VideoCacheManager();
  setUp(() {
    VideoCacheManager.contextKey = () => 'main|-';
    cache.clearAll();
  });

  test('视频源在途先登记、再放开等详情的人；完成后两样都进缓存', () async {
    final detail = Completer<Video>();
    final sources = Completer<List<VideoSource>?>();
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => true,
      fetchDetail: (_) => detail.future,
      fetchSources: (_) => sources.future,
    );

    p.prefetch('v1');
    final gate = p.pendingDetail('v1');
    expect(gate, isNotNull);

    detail.complete(_video('v1', fileUrl: 'https://api/file/1'));
    await gate;
    // 详情页等完详情紧接着查视频源的在途：这时必须已经能查到。
    expect(cache.getVideoInfo('v1'), isNotNull);
    final sourcesGate = p.pendingSources('https://api/file/1');
    expect(sourcesGate, isNotNull);

    sources.complete(_sources());
    await sourcesGate;
    expect(cache.getVideoSources('https://api/file/1'), isNotNull);
    expect(p.pendingSources('https://api/file/1'), isNull);
  });

  test('同一条在途不重发；在途满了不再接新的', () async {
    var detailCalls = 0;
    final hold = Completer<Video>();
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => true,
      fetchDetail: (_) {
        detailCalls++;
        return hold.future;
      },
      fetchSources: (_) async => null,
    );

    p.prefetch('a');
    p.prefetch('a');
    expect(detailCalls, 1);

    for (var i = 0; i < VideoDetailPrefetcher.maxConcurrent + 2; i++) {
      p.prefetch('x$i');
    }
    expect(detailCalls, VideoDetailPrefetcher.maxConcurrent);
    hold.completeError(Exception('stop'));
    await Future<void>.delayed(Duration.zero);
  });

  test('失败后冷却期内不再为同一条发请求，闸门正常完成不带错误', () async {
    var now = DateTime(2026, 1, 1);
    var calls = 0;
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => true,
      fetchDetail: (_) async {
        calls++;
        throw Exception('403');
      },
      fetchSources: (_) async => null,
      now: () => now,
    );

    p.prefetch('v');
    await p.pendingDetail('v');
    expect(calls, 1);

    p.prefetch('v');
    expect(calls, 1);

    now = now.add(VideoDetailPrefetcher.failureCooldown);
    p.prefetch('v');
    expect(calls, 2);
    await p.pendingDetail('v');
  });

  test('详情与视频源都已在缓存时什么都不做', () async {
    cache.cacheVideoInfo('c', _video('c', fileUrl: 'https://api/file/c'));
    cache.cacheVideoSources('https://api/file/c', _sources());
    var calls = 0;
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => true,
      fetchDetail: (_) async {
        calls++;
        return _video('c');
      },
      fetchSources: (_) async {
        calls++;
        return null;
      },
    );
    p.prefetch('c');
    expect(calls, 0);
  });

  test('刚预取的详情算新鲜、只认一次；卡片点过赞就作废；不许后台跑时不发', () async {
    var allowed = false;
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => allowed,
      fetchDetail: (id) async => _video(id, fileUrl: 'https://api/file/$id'),
      fetchSources: (_) async => _sources(),
    );

    p.prefetch('f');
    expect(p.pendingDetail('f'), isNull, reason: 'token 要刷新时不预取');

    allowed = true;
    p.prefetch('f');
    await p.pendingDetail('f');
    final f = cache.getVideoInfo('f')!;
    expect(p.consumeFresh('f', f), isTrue);
    expect(p.consumeFresh('f', f), isFalse);

    p.prefetch('g');
    await p.pendingDetail('g');
    p.markStale('g');
    expect(p.consumeFresh('g', cache.getVideoInfo('g')!), isFalse);

    // 缓存条目被别的数据换掉了（例如详情页用 initialVideoInfo 覆盖）：不是
    // 预取的那一份，不算新鲜。
    p.prefetch('h');
    await p.pendingDetail('h');
    final replaced = _video('h', fileUrl: 'https://api/file/h');
    cache.cacheVideoInfo('h', replaced);
    expect(p.consumeFresh('h', replaced), isFalse);
  });

  test('详情还在路上时点了赞：回来的那份进缓存，但不算新鲜', () async {
    final detail = Completer<Video>();
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => true,
      fetchDetail: (_) => detail.future,
      fetchSources: (_) async => _sources(),
    );
    p.prefetch('s');
    p.markStale('s');
    detail.complete(_video('s', fileUrl: 'https://api/file/s'));
    await p.pendingDetail('s');
    final cached = cache.getVideoInfo('s');
    expect(cached, isNotNull);
    expect(p.consumeFresh('s', cached!), isFalse);
  });

  test('请求途中换了站点 / 账号：结果不进缓存', () async {
    final detail = Completer<Video>();
    final p = VideoDetailPrefetcher(
      cache: cache,
      canRunInBackground: () => true,
      fetchDetail: (_) => detail.future,
      fetchSources: (_) async => _sources(),
    );
    p.prefetch('x');
    final gate = p.pendingDetail('x');
    VideoCacheManager.contextKey = () => 'ai|-';
    detail.complete(_video('x', fileUrl: 'https://api/file/x'));
    await gate;
    expect(cache.getVideoInfo('x'), isNull);
    VideoCacheManager.contextKey = () => 'main|-';
    expect(cache.getVideoInfo('x'), isNull);
  });

  test('换了站点 / 账号，缓存条目当作没有', () {
    cache.cacheVideoInfo('s', _video('s', fileUrl: 'https://api/file/s'));
    expect(cache.getVideoInfo('s'), isNotNull);
    VideoCacheManager.contextKey = () => 'ai|-';
    expect(cache.getVideoInfo('s'), isNull);
  });
}
