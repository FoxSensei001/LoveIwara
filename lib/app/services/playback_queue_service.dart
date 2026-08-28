import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';

/// 视频池的登记处。
///
/// # ⛔ 为什么池必须活在这里，而不是活在页面里
///
/// 池要跨三种生命周期存活：
/// 1. **连播换片**：走「原地换片」，页面实例不变，但池得跨条目保持游标；
/// 2. **抽屉进出**：抽屉是一条 root 路由，开一次建一次，池不能跟着它生灭；
/// 3. **`详情页1 → 作者页 → 详情页2`**：每层详情页各有各的池，返回时详情页1
///    的池必须还在——用"全局唯一的当前池"会让下游页面把上游的上下文篡改掉。
///
/// 所以页面只持有一个 [PlaybackQueueRef]（两个字符串，能塞进路由 extra），
/// 池的真身与游标由本服务持有。
///
/// # 淘汰
///
/// LRU 留最近 [_maxQueues] 个。刻意**不用引用计数**：原地换片之后没有一个清晰
/// 的"引用释放"时点，计数只会越积越多或者提前归零。
class PlaybackQueueService extends GetxService {
  static PlaybackQueueService get to => Get.find();

  /// 同时留几个池。3 够覆盖"来源 + 播放列表 + 稍后再看"这一整屏抽屉，
  /// 也够 `详情页1 → 作者页 → 详情页2` 回退时命中详情页1 的池。
  static const int _maxQueues = 3;

  final Map<String, PlaybackQueue> _queues = <String, PlaybackQueue>{};

  /// 最近使用顺序，队尾最新。
  final List<String> _lru = <String>[];

  PlaybackQueue? byId(String queueId) {
    final queue = _queues[queueId];
    if (queue != null) _touch(queueId);
    return queue;
  }

  /// 来源池。[ownerKey] 让不同页面实例的同源列表互不覆盖
  /// （两层作者页看的是不同作者，池不能串）。
  PlaybackQueue openSource(
    InnerPlaylistContext context, {
    required String ownerKey,
  }) {
    final id = 'source:${context.source.name}:$ownerKey';
    final existing = _queues[id];
    if (existing != null) {
      _touch(id);
      return existing;
    }
    return _register(SourcePlaybackQueue(queueId: id, context: context));
  }

  /// 播放列表池。同一个播放列表重复打开会命中缓存，**连带已翻到第几页一起复用**。
  PlaylistPlaybackQueue openPlaylist(String playlistId, {String? title}) {
    final id = 'playlist:$playlistId';
    final existing = _queues[id];
    if (existing is PlaylistPlaybackQueue) {
      _touch(id);
      existing.updateTitle(title);
      return existing;
    }
    final queue = PlaylistPlaybackQueue(
      queueId: id,
      playlistId: playlistId,
      service: Get.find<PlayListService>(),
      title: title,
    );
    _register(queue);
    return queue;
  }

  /// 稍后再看池。筛选是池身份的一部分——切 `全部 / 未看完` 就是换了一个池。
  WatchLaterPlaybackQueue openWatchLater({required bool unwatchedOnly}) {
    final id = 'watchLater:${unwatchedOnly ? 'unwatched' : 'all'}';
    final sort = currentWatchLaterSort();
    final existing = _queues[id];
    if (existing is WatchLaterPlaybackQueue) {
      _touch(id);
      existing.applySort(sort);
      return existing;
    }
    final queue = WatchLaterPlaybackQueue(
      queueId: id,
      unwatchedOnly: unwatchedOnly,
      service: WatchLaterService.to,
      sort: sort,
    );
    _register(queue);
    return queue;
  }

  /// 列表页与抽屉共享的那一份排序偏好。
  static WatchLaterSort currentWatchLaterSort() {
    return WatchLaterSort.fromConfigValue(
      Get.find<ConfigService>()[ConfigKey.WATCH_LATER_SORT_KEY] as String?,
    );
  }

  T _register<T extends PlaybackQueue>(T queue) {
    _queues[queue.queueId] = queue;
    _touch(queue.queueId);
    _evictIfNeeded();
    return queue;
  }

  void _touch(String queueId) {
    _lru
      ..remove(queueId)
      ..add(queueId);
  }

  /// ⛔ **仍被监听的池不淘汰**。
  ///
  /// 把一个还有页面在听的池 dispose 掉，下一次它通知时会炸
  /// 「A ChangeNotifier was used after being disposed」，监听方 `removeListener`
  /// 在 debug 下也会抛。所以这里从最旧的一头往后找**第一个没人听的**下手；
  /// 全都在用就先超一点，等它们各自被松开。
  void _evictIfNeeded() {
    while (_lru.length > _maxQueues) {
      final victimIndex = _lru.indexWhere(
        (id) => _queues[id]?.isInUse != true,
      );
      if (victimIndex < 0) return;
      final victim = _lru.removeAt(victimIndex);
      _queues.remove(victim)?.dispose();
    }
  }

  @override
  void onClose() {
    for (final queue in _queues.values) {
      queue.dispose();
    }
    _queues.clear();
    _lru.clear();
    super.onClose();
  }

  @visibleForTesting
  int get queueCount => _queues.length;
}
