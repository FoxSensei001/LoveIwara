import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
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

  /// 同时留几个池。
  ///
  /// 视频抽屉能开出八种（来源 / 订阅 / 播放列表 / 作者作品 / 最爱 / 稍后再看 /
  /// 本地收藏夹 / 已下载），图库抽屉另有六种（来源 / 订阅 / 最爱 / 本地收藏夹 /
  /// 稍后再看 / 作者的图库），再加上 `详情页1 → 作者页 → 详情页2` 回退时要
  /// 命中的那一个。12 是"在视频与图库之间来回逛也不至于把刚看过的池挤掉"的量。
  /// 真超了也只淘汰**没人听**的（见 [_evictIfNeeded]）。
  static const int _maxQueues = 12;

  // ---- queueId 的拼法收在这里 ----
  //
  // ⛔ 别在调用点拼字面量：抽屉要判断"正开着的是不是这一支"（`_isCurrentQueue`），
  // 判断用的串和登记用的串一旦分头写，加一个媒体类型后缀就会让所有高亮静默
  // 失效——不报错，只是永远不亮。

  /// 媒体类型后缀。视频**不带后缀**：视频那套 id 早就散在日志和既有测试里，
  /// 保持原样；图库另起一个命名空间。
  static String _suffix(PlaybackMediaType mediaType) =>
      mediaType.isGallery ? ':gallery' : '';

  static String watchLaterQueueId({
    required bool unwatchedOnly,
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) => 'watchLater:${unwatchedOnly ? 'unwatched' : 'all'}${_suffix(mediaType)}';

  static String favoritesQueueId([
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  ]) => 'favorites${_suffix(mediaType)}';

  static String localFavoriteQueueId(
    String folderId, {
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) => 'localFavorite:$folderId${_suffix(mediaType)}';

  static String playlistQueueId(String playlistId) => 'playlist:$playlistId';

  /// 接口列表池（「来源」的分页版，见 [RemoteListPlaybackQueue]）。
  ///
  /// ⛔ 身份**只由查询本身决定**，不带页面实例、不带 ownerKey：同一份查询就是
  /// 同一个池，从热门页点进去、返回、再点另一条，命中的是同一个池，连带翻到
  /// 第几页一起复用。这正是快照池做不到而它能做到的事。
  static String remoteListQueueId(MediaListQuery query) =>
      'remoteList:${query.signature}';

  static String subscriptionsQueueId([
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  ]) => 'subscriptions${_suffix(mediaType)}';

  static String authorMediaQueueId(
    String userId, {
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) => mediaType.isGallery
      ? 'authorGalleries:$userId'
      : 'authorVideos:$userId';

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
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) {
    final id = 'source:${context.source.name}:$ownerKey${_suffix(mediaType)}';
    final existing = _queues[id];
    if (existing != null) {
      _touch(id);
      return existing;
    }
    return _register(
      SourcePlaybackQueue(queueId: id, context: context, mediaType: mediaType),
    );
  }

  /// 接口列表池：拿列表页那份查询接着往下翻（见 [RemoteListPlaybackQueue]）。
  ///
  /// [seed] 是列表页**已经加载出来**的那些条目，按自然顺序传进来；命中缓存时
  /// 不再重种——池自己翻到的那份比种子新，重种会把游标推回去。
  RemoteListPlaybackQueue openRemoteList(
    MediaListQuery query, {
    List<InnerPlaylistItemSnapshot> seed = const [],
    String? title,
    PlaybackQueueKind kind = PlaybackQueueKind.source,
    String? queueId,
  }) {
    final id = queueId ?? remoteListQueueId(query);
    final existing = _queues[id];
    if (existing is RemoteListPlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      RemoteListPlaybackQueue(
        queueId: id,
        query: query,
        videoService: Get.find<VideoService>(),
        galleryService: Get.find<GalleryService>(),
        searchService: Get.find<SearchService>(),
        kind: kind,
        title: title,
        seed: seed,
      ),
    );
  }

  /// 订阅动态池（已关注作者的全部作品）。
  ///
  /// ⛔ **未登录时返回 null**：`subscribed=true` 在未登录时会被服务端**静默忽略**
  /// （这个仓库踩过，见 `iwara-list-filter-params` 那条），返回的是全站内容——
  /// 摆一条点进去是"全站热门"的「订阅」比不摆糟得多。
  RemoteListPlaybackQueue? openSubscriptions({
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) {
    if (Get.find<UserService>().currentUser.value == null) return null;
    return openRemoteList(
      MediaListQuery.subscriptions(mediaType: mediaType),
      kind: PlaybackQueueKind.subscriptions,
      queueId: subscriptionsQueueId(mediaType),
    );
  }

  /// 播放列表池。同一个播放列表重复打开会命中缓存，**连带已翻到第几页一起复用**。
  ///
  /// [owner] 是这张列表的主人。命中缓存时也会补写——列表名与主人都是
  /// `/playlist/{id}` 异步回来的，池常常先于它们建好。
  PlaylistPlaybackQueue openPlaylist(
    String playlistId, {
    String? title,
    User? owner,
  }) {
    final id = playlistQueueId(playlistId);
    final existing = _queues[id];
    if (existing is PlaylistPlaybackQueue) {
      _touch(id);
      existing.updateTitle(title);
      existing.updateOwner(owner);
      return existing;
    }
    final queue = PlaylistPlaybackQueue(
      queueId: id,
      playlistId: playlistId,
      service: Get.find<PlayListService>(),
      title: title,
      owner: owner,
    );
    _register(queue);
    return queue;
  }

  /// 下载池（已下载到本地的视频）。条目用**本地文件**播，见
  /// [DownloadsPlaybackQueue]。
  ///
  /// [categoryFilter] 是池身份的一部分（`'all'` / `'uncategorized'` / 分类 id），
  /// 所以编进 [PlaybackQueue.queueId]——换一个分类就是换一个池。
  DownloadsPlaybackQueue openDownloads({
    String categoryFilter = 'all',
    String? title,
  }) {
    final id = 'downloads:$categoryFilter';
    final existing = _queues[id];
    if (existing is DownloadsPlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      DownloadsPlaybackQueue(
        queueId: id,
        repository: DownloadService.to.repository,
        categoryFilter: categoryFilter,
        title: title,
      ),
    );
  }

  /// 稍后再看池。筛选**与媒体类型**都是池身份的一部分——切 `全部 / 未看完`
  /// 是换一个池，视频与图库更是两个各自独立的池。
  WatchLaterPlaybackQueue openWatchLater({
    required bool unwatchedOnly,
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) {
    final id = watchLaterQueueId(
      unwatchedOnly: unwatchedOnly,
      mediaType: mediaType,
    );
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
      mediaType: mediaType,
    );
    _register(queue);
    return queue;
  }

  /// 作者作品池。**不排除当前这条**，理由见 [AuthorVideosPlaybackQueue]。
  AuthorVideosPlaybackQueue openAuthorVideos(String userId, {String? title}) {
    final id = authorMediaQueueId(userId);
    final existing = _queues[id];
    if (existing is AuthorVideosPlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      AuthorVideosPlaybackQueue(
        queueId: id,
        userId: userId,
        service: Get.find<VideoService>(),
        title: title,
      ),
    );
  }

  /// 最爱池（Iwara 服务端那份，要登录）。
  FavoriteVideosPlaybackQueue openFavorites() {
    final id = favoritesQueueId();
    final existing = _queues[id];
    if (existing is FavoriteVideosPlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      FavoriteVideosPlaybackQueue(
        queueId: id,
        service: Get.find<VideoService>(),
      ),
    );
  }

  /// 最爱池（图库那份）。
  FavoriteGalleriesPlaybackQueue openFavoriteGalleries() {
    final id = favoritesQueueId(PlaybackMediaType.gallery);
    final existing = _queues[id];
    if (existing is FavoriteGalleriesPlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      FavoriteGalleriesPlaybackQueue(
        queueId: id,
        service: Get.find<GalleryService>(),
      ),
    );
  }

  /// 作者图库池。**不排除当前这条**，理由见 [AuthorGalleriesPlaybackQueue]。
  AuthorGalleriesPlaybackQueue openAuthorGalleries(
    String userId, {
    String? title,
  }) {
    final id = authorMediaQueueId(userId, mediaType: PlaybackMediaType.gallery);
    final existing = _queues[id];
    if (existing is AuthorGalleriesPlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      AuthorGalleriesPlaybackQueue(
        queueId: id,
        userId: userId,
        service: Get.find<GalleryService>(),
        title: title,
      ),
    );
  }

  /// 本地收藏夹池。夹子是池身份的一部分，所以夹子 id 编进 [PlaybackQueue.queueId]。
  LocalFavoritePlaybackQueue openLocalFavorite(
    String folderId, {
    String? title,
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) {
    final id = localFavoriteQueueId(folderId, mediaType: mediaType);
    final existing = _queues[id];
    if (existing is LocalFavoritePlaybackQueue) {
      _touch(id);
      return existing;
    }
    return _register(
      LocalFavoritePlaybackQueue(
        queueId: id,
        folderId: folderId,
        service: FavoriteService.to,
        title: title,
        mediaType: mediaType,
      ),
    );
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

  /// ⛔ **仍被监听的池不淘汰**，**刚用过的那个（队尾）也不淘汰**。
  ///
  /// 把一个还有页面在听的池 dispose 掉，下一次它通知时会炸
  /// 「A ChangeNotifier was used after being disposed」，监听方 `removeListener`
  /// 在 debug 下也会抛。所以这里从最旧的一头往后找**第一个没人听的**下手；
  /// 全都在用就先超一点，等它们各自被松开。
  ///
  /// ⛔ 队尾（MRU）必须豁免，否则 [_register] 会把**自己刚造好的那个池**淘汰掉：
  /// 新池身上还没有任何监听（[PlaybackQueue.isInUse] 为假），而抽屉里那三个池
  /// 都有人听，于是"第一个没人听的"恰恰就是它——`openPlaylist` 造完、
  /// dispose 掉、再把尸体还给调用方，调用方 `addListener` 当场炸
  /// 「A PlaylistPlaybackQueue was used after being disposed」（2026-08-29 真机
  /// 报障：抽屉里换一张播放列表必现）。淘汰 MRU 本来也不是 LRU 的语义。
  void _evictIfNeeded() {
    while (_lru.length > _maxQueues) {
      final victimIndex = _lru.indexWhere((id) => _queues[id]?.isInUse != true);
      // 没有没人听的，或者唯一的候选就是刚用过的那个 → 先超一点，等它们松开
      if (victimIndex < 0 || victimIndex == _lru.length - 1) return;
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

  /// 同时保留的池上限。测试直接读它，别在用例里抄字面量——改这个数不该让
  /// 淘汰规则的用例跟着红。
  @visibleForTesting
  static int get maxQueues => _maxQueues;
}
