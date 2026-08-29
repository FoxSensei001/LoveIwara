import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:flutter/foundation.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/models/favorite/favorite_item.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

// 池的媒体类型定义在条目模型那边（条目也要带它），但它属于**池的 API**——
// 用到池的地方不该为了一个枚举再去 import 另一个文件。
export 'package:i_iwara/app/models/inner_playlist.model.dart'
    show PlaybackMediaType;

/// 播放器抽屉里的「视频池」。
///
/// # 为什么不能继续用 `InnerPlaylistContext`
///
/// 那个模型有三个特性和新需求正面冲突：**不可变快照**、**上限 100 条**、
/// **超限就 `shuffle()` 抽样**。播放列表池要分页无限加载，而 shuffle 抽样会把
/// "第 5 页才加载进来的那些"在下一次 copy 时随机丢掉——翻得越多丢得越多。
///
/// 所以池改成一个**可翻页的只读序列**：`InnerPlaylistContext` 作为
/// [SourcePlaybackQueue] 的内部实现被包进来（来源池**保留**打乱，那是有意的），
/// 分页池与本地池各自实现自己的取数。
///
/// # ⛔ 游标必须活在页面之外
///
/// 池的已加载页与游标由 `PlaybackQueueService` 持有，**不能**放在页面实例或
/// 页面 controller 里：连播是「原地换片」，页面实例虽然不变，但抽屉是一条
/// root 路由、进出会重建；更要命的是池要跨"详情页1 → 作者页 → 详情页2"存活。
/// 路由 extra 只传 [PlaybackQueueRef]（两个字符串）。
enum PlaybackQueueKind {
  /// 进详情页之前那个列表的快照（首页/搜索/作者页/订阅…）。
  source,

  /// Iwara 的播放列表，接口分页。
  playlist,

  /// 本地的稍后再看。
  watchLater,

  /// 这条视频作者的全部作品，接口分页。
  authorVideos,

  /// 这个图库作者的全部图库，接口分页。
  ///
  /// 与 [authorVideos] 分成两条而不是共用一条：抽屉里"一种池只占一个槽"是按
  /// kind 判的（`_useQueue`），而作者的视频与作者的图库是两个不同的东西——
  /// 共用一条的话，将来同一页里两者并存会互相顶掉。
  authorGalleries,

  /// Iwara 的「最爱」，接口分页。
  favorites,

  /// 本地收藏夹里的一个夹子，本地库分页。
  localFavorite,

  /// 已下载到本地的视频，本地库分页。**这个池里的条目用本地文件播**
  /// （见 [PlaybackQueue.localTargetFor]）。
  downloads,
}

/// 「这一条用本地文件播」的全部材料。
///
/// 下载池是唯一会给出它的池：池的身份就是"磁盘上这些文件"，从它里面接着看
/// 却回头去联网拉流，等于把这个池的意义抹掉（离线时更是直接播不了）。
@immutable
class LocalPlaybackTarget {
  const LocalPlaybackTarget({
    required this.localPath,
    required this.task,
    required this.allQualityTasks,
  });

  final String localPath;
  final DownloadTask task;

  /// 同一个视频的其它清晰度，本地播放页要用它做清晰度切换。
  final List<DownloadTask> allQualityTasks;
}

/// 本地播放页的路由 id。
///
/// ⛔ 必须**带 `local_` 前缀且每条片子各不相同**：前缀是全 App 认「这是本地
/// 视频」的记号（`NaviService.navigateToLocalVideoPlayerPage` 一直这么发），
/// 而把媒体 id 编进去是为了让详情页那道"同一个视频不重复入栈"的守卫仍然分得清
/// 两条片子。
String localVideoRouteId(String mediaId) => 'local_$mediaId';

/// 路由 extra 里传的东西：只有两个字符串。池的真身在 `PlaybackQueueService`。
@immutable
class PlaybackQueueRef {
  const PlaybackQueueRef({required this.queueId, required this.currentItemId});

  final String queueId;
  final String currentItemId;

  PlaybackQueueRef copyWith({String? currentItemId}) => PlaybackQueueRef(
    queueId: queueId,
    currentItemId: currentItemId ?? this.currentItemId,
  );
}

/// 一个视频池。
abstract class PlaybackQueue extends ChangeNotifier {
  PlaybackQueue({required this.queueId});

  /// 稳定标识。同一个池被重复打开时靠它命中缓存（连带游标一起复用）。
  final String queueId;

  PlaybackQueueKind get kind;

  /// 这个池装的是视频还是图库（见 [PlaybackMediaType]）。
  ///
  /// ⛔ 它决定**点一条会落到哪个详情页**（[PlaybackQueueNavigator] 据此选路由），
  /// 所以一个池里不许混装两种。绝大多数池是视频，默认就按视频。
  PlaybackMediaType get mediaType => PlaybackMediaType.video;

  /// 抽屉标题上显示的名字（播放列表名；来源池与稍后再看用固定文案，返回 null）。
  String? get title => null;

  /// 已加载的条目，顺序稳定。
  List<InnerPlaylistItemSnapshot> get loaded;

  bool get hasMore => false;
  bool get isLoading => false;

  /// 翻下一页。快照池是 no-op。
  Future<void> loadMore() async {}

  /// [currentId] 已经是**已加载部分**的最后一条可播项，但池还有下一页。
  ///
  /// 分页池到了边界时 [itemAfter] 会返回 null，而那**不是"池到底了"**——
  /// 调用方要靠这个方法把两者分开，否则一个 40 条的播放列表连播到第 32 条
  /// 就会停下（后 8 条还没拉进来）。
  bool needsMoreToAdvance(String currentId, {bool skipWatched = false}) =>
      hasMore && itemAfter(currentId, skipWatched: skipWatched) == null;

  /// 还能不能往下推进——播放器底栏那枚「下一个」据此决定在不在场。
  ///
  /// ⛔ [hasMore] 与"已经找得到下一条"是**并列**的，不是二选一：分页池走到已
  /// 加载部分的末尾时 [itemAfter] 返回 null，而那不是"池到底了"（同
  /// [needsMoreToAdvance]）。只看 [itemAfter] 的话，一个 40 条的播放列表播到
  /// 第 20 条按钮就凭空消失了——而它其实还能接着播。
  bool canAdvance(String currentId, {bool skipWatched = false}) =>
      hasMore || itemAfter(currentId, skipWatched: skipWatched) != null;

  /// 找出 [currentId] 之后该播的那一条。
  ///
  /// [skipWatched] 由用户点播时所在的筛选 tab 决定（`全部` 不跳 / `未看完` 跳）。
  /// 找不到就返回 null（池播完了 → 停在最后一条，恢复暂停/重播的老语义）。
  ///
  /// ⛔ **站外视频一律跳过**：它们在内置播放器里播不了，自动推进撞上去会让
  /// 连播链以一个莫名其妙的错误中断——比手动点开报错更伤，因为用户根本没操作。
  InnerPlaylistItemSnapshot? itemAfter(
    String currentId, {
    bool skipWatched = false,
  }) {
    final items = loaded;
    if (items.isEmpty) return null;

    final currentIndex = items.indexWhere((item) => item.id == currentId);
    // ⛔ 找不到当前条就**老实返回 null**，不要"从头再找一条"。
    //
    // 早先版本从 index 0 重扫，看着无害，实则是"续播跳回列表顶部"的直接成因：
    // 一条播完会先被标成已看完 → 池重查把它移出去 → 紧接着的推进已经找不到它
    // → 于是从头挑了第一条。用户从列表中间点播，播完却跳回了第一条。
    // 停在最后一条（恢复暂停/重播语义）比跳到一个用户没预期的位置好。
    if (currentIndex < 0) return null;
    for (var i = currentIndex + 1; i < items.length; i++) {
      final item = items[i];
      if (item.isExternalVideo) continue;
      if (skipWatched && _isWatched(item.id)) continue;
      return item;
    }
    return null;
  }

  /// 池里已经有这一条了吗。
  bool contains(String itemId) =>
      itemId.isNotEmpty && loaded.any((item) => item.id == itemId);

  /// 一直翻到**池里装得下 [itemId] 为止**（最多 [maxPages] 页）。
  ///
  /// ⛔ 这一步不是可有可无的：从「最爱」「本地收藏夹」「已下载」这类深列表的
  /// **中段**点进播放器时，池刚建好只有第 0 页，而当前这条可能在第 5 页——
  /// 找不到自己就意味着 [itemAfter] 恒为 null（推进彻底失效）、抽屉里也高亮
  /// 不到"正在播的那一条"。
  ///
  /// 上限是有意的：翻不到就老实收手（当前这条可能压根不在这个池里，比如用户
  /// 在抽屉里换到了别的池），无上限地翻下去等于对着一个几千条的列表发几十个
  /// 请求。翻不到返回 false，调用方照常按"到底了"处理。
  Future<bool> ensureContains(String itemId, {int maxPages = 8}) async {
    if (itemId.isEmpty) return false;
    var pages = 0;
    while (!contains(itemId) && hasMore && pages < maxPages) {
      pages++;
      final before = loaded.length;
      await loadMore();
      // 一页都没多出来（到底了 / 请求失败）就别再空转
      if (loaded.length == before) break;
    }
    return contains(itemId);
  }

  /// **确定**是空的：一条都没有、没有下一页、也不在加载中。
  ///
  /// 池选择菜单靠它把条目置灰——「还没查过」和「查过、真没有」必须分开：
  /// 前者不能置灰（等于替用户断言一件还不知道的事），后者不置灰就成了一条点了
  /// 什么都不发生的死项（2026-08-29 用户提的正是这个）。
  bool get isKnownEmpty => loaded.isEmpty && !hasMore && !isLoading;

  /// 已经被 LRU 淘汰掉了。
  ///
  /// ⛔ 池的取数是**异步**的，而淘汰只看"当前有没有人听"——一个在后台翻页、
  /// 身上恰好没有监听者的池会被 dispose 掉，等请求回来再 `notifyListeners()`
  /// 就炸「A ChangeNotifier was used after being disposed」。所有跨过 await
  /// 的通知都要先问一句这个。
  bool get isDisposed => _disposed;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// 还有页面/抽屉在听它。
  ///
  /// LRU 淘汰要看这个：把一个仍被监听的池 dispose 掉，下一次它通知时就会炸
  /// 「A ChangeNotifier was used after being disposed」，而且监听方
  /// `removeListener` 也会在 debug 下抛异常。
  bool get isInUse => hasListeners;

  /// 供 [itemAfter] 判断"这条看完没有"。只有本地池答得上来。
  bool _isWatched(String id) => false;

  /// 这一条要不要用**本地文件**播。返回 null = 照常走在线详情页。
  ///
  /// 只有下载池会答出东西来（见 [DownloadsPlaybackQueue]）。放在基类上是为了
  /// 让 `PlaybackQueueNavigator` 不必认识"下载"这件事——它只问池"这条怎么开"。
  Future<LocalPlaybackTarget?> localTargetFor(String itemId) async => null;
}

/// 来源池：进详情页之前那个列表的快照，不分页。
class SourcePlaybackQueue extends PlaybackQueue {
  SourcePlaybackQueue({
    required super.queueId,
    required this.context,
    this.mediaType = PlaybackMediaType.video,
  });

  final InnerPlaylistContext context;

  @override
  final PlaybackMediaType mediaType;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.source;

  @override
  List<InnerPlaylistItemSnapshot> get loaded => context.items;
}

/// 分页池的共同骨架：翻页、去重、"这一页装满了才可能还有下一页"、失败不动
/// [hasMore]。播放列表 / 作者作品 / 最爱 / 本地收藏夹都是它。
///
/// 和来源池的区别不只是"能翻页"：来源池打乱是有意的（那是一次随机推荐），
/// 而这些池都是别人排好的顺序，打乱就把它的意义毁了。
abstract class PagedPlaybackQueue extends PlaybackQueue {
  PagedPlaybackQueue({required super.queueId, this.pageSize = 32});

  final int pageSize;

  final List<InnerPlaylistItemSnapshot> _items = [];
  int _nextPage = 0;
  bool _hasMore = true;
  bool _loading = false;

  /// 取第 [page] 页。
  ///
  /// [rawCount] 是**过滤前**的条目数，[hasMore] 只看它——本地收藏夹这种"取 20
  /// 条、筛掉图片只剩 12 条"的池，拿过滤后的条数判断会被当成已经到底。
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  );

  /// 出错日志里用的名字。
  String get debugLabel;

  @override
  List<InnerPlaylistItemSnapshot> get loaded =>
      List<InnerPlaylistItemSnapshot>.unmodifiable(_items);

  @override
  bool get hasMore => _hasMore;

  @override
  bool get isLoading => _loading;

  @override
  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    notifyListeners();
    try {
      final page = await fetchPage(_nextPage, pageSize);
      final seen = _items.map((e) => e.id).toSet();
      for (final item in page.items) {
        if (item.id.trim().isEmpty || !seen.add(item.id)) continue;
        _items.add(item);
      }
      _nextPage++;
      // 后端给的 count 在有些接口上是"已加载+1"的哨兵而不是总数（作者页作品数
      // 那次踩过），所以**不拿 count 判有没有下一页**，只看这一页是不是满的。
      _hasMore = page.rawCount >= pageSize;
    } catch (e) {
      // ⛔ 请求失败**不动 `_hasMore`**：一次网络抖动就把它钉成 false 的话，
      // 这个池在被 LRU 淘汰之前都再也翻不出下一页了（而它是缓存的，可能活很久）。
      // 只有"这一页没装满"才是真的到底。
      LogUtils.e('$debugLabel 分页加载失败', tag: 'PagedPlaybackQueue', error: e);
    } finally {
      _loading = false;
      if (!isDisposed) notifyListeners();
    }
  }
}

/// 播放列表池。
class PlaylistPlaybackQueue extends PagedPlaybackQueue {
  PlaylistPlaybackQueue({
    required super.queueId,
    required this.playlistId,
    required PlayListService service,
    String? title,
    User? owner,
  }) : _service = service,
       _title = title,
       _owner = owner,
       super(pageSize: 32) {
    // 主人没给就自己去问一次。调用点不总是知道（抽屉里换一张播放列表时只带得
    // 出 id 和名字），而"这张列表是谁的"决定了抽屉里那条「他人的播放列表」在
    // 不在场——靠调用点一处处传，漏一处就少一条入口。
    if (_owner == null) unawaited(_resolveInfo());
  }

  final String playlistId;
  final PlayListService _service;
  String? _title;
  User? _owner;

  /// 已经问过 `/playlist/{id}` 了。失败会把它放回去，下次还能再问。
  bool _infoResolved = false;

  Future<void> _resolveInfo() async {
    if (_infoResolved) return;
    _infoResolved = true;
    try {
      final result = await _service.getPlaylistInfo(playlistId: playlistId);
      if (!result.isSuccess || result.data == null) {
        _infoResolved = false;
        return;
      }
      if (isDisposed) return;
      updateTitle(result.data!.title);
      updateOwner(result.data!.user);
    } catch (e) {
      _infoResolved = false;
      LogUtils.w('取播放列表主人失败：$playlistId（$e）', 'PlaylistPlaybackQueue');
    }
  }

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.playlist;

  @override
  String? get title => _title;

  /// 这张播放列表是**谁的**。
  ///
  /// 抽屉靠它认出「他人的播放列表」：菜单里原本只按"我的 / 作者的"分，而从
  /// 第三个人的播放列表进来时，那张列表既不属于我也不属于这条视频的作者——
  /// 没有这个字段，用户就没有任何办法在抽屉里换到那个人的另一张列表去。
  User? get owner => _owner;

  @override
  String get debugLabel => '播放列表 $playlistId';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final result = await _service.getPlaylistVideos(
      playlistId: playlistId,
      page: page,
      limit: limit,
    );
    if (!result.isSuccess || result.data == null) {
      // 交给骨架当"失败"处理：不动 hasMore。
      throw StateError(result.message);
    }
    final videos = result.data!.results;
    return (
      items: [
        for (final Video video in videos)
          InnerPlaylistItemSnapshot.fromVideo(video),
      ],
      rawCount: videos.length,
    );
  }

  void updateTitle(String? title) {
    if (title == null || title.isEmpty || title == _title) return;
    _title = title;
    notifyListeners();
  }

  /// 列表名与主人都是**异步**才拿得到的（`/playlist/{id}` 那一发），而池可能
  /// 在它回来之前就被建好了。所以两者都留了补写的口子，只补、不清空。
  void updateOwner(User? owner) {
    if (owner == null || owner.id == _owner?.id) return;
    _owner = owner;
    notifyListeners();
  }
}

/// 作者作品池：这条视频的作者上传过的全部视频。
///
/// ⛔ **不排除当前这条**：池的游标是靠"当前 id 在列表里的位置"找的
/// （[PlaybackQueue.itemAfter]），把它排掉就等于把游标弄丢，推进直接失效。
class AuthorVideosPlaybackQueue extends PagedPlaybackQueue {
  AuthorVideosPlaybackQueue({
    required super.queueId,
    required this.userId,
    required VideoService service,
    String? title,
  }) : _service = service,
       _title = title,
       super(pageSize: 32);

  final String userId;
  final VideoService _service;
  final String? _title;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.authorVideos;

  @override
  String? get title => _title;

  @override
  String get debugLabel => '作者作品 $userId';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final result = await _service.fetchVideosByParams(
      params: {'user': userId},
      page: page,
      limit: limit,
    );
    if (!result.isSuccess || result.data == null) {
      throw StateError(result.message);
    }
    final videos = result.data!.results;
    return (
      items: [
        for (final Video video in videos)
          InnerPlaylistItemSnapshot.fromVideo(video),
      ],
      rawCount: videos.length,
    );
  }
}

/// 最爱池：Iwara 服务端的「最爱」列表（要登录）。
class FavoriteVideosPlaybackQueue extends PagedPlaybackQueue {
  FavoriteVideosPlaybackQueue({
    required super.queueId,
    required VideoService service,
  }) : _service = service,
       super(pageSize: 32);

  final VideoService _service;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.favorites;

  @override
  String get debugLabel => '最爱';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final result = await _service.fetchFavoriteVideos(page: page, limit: limit);
    if (!result.isSuccess || result.data == null) {
      throw StateError(result.message);
    }
    final videos = result.data!.results;
    return (
      items: [
        for (final Video video in videos)
          InnerPlaylistItemSnapshot.fromVideo(video),
      ],
      rawCount: videos.length,
    );
  }
}

/// 本地收藏夹池：某一个夹子里的视频**或**图库。
///
/// ⛔ **一次只装一种**：夹子里视频、图库、用户混在一起，而"下一条"必须落在同
/// 一个详情页里（见 [PlaybackMediaType]）。过滤是在取回来之后做的，所以
/// [PagedPlaybackQueue] 判断有没有下一页只能看**过滤前**的条数。
///
/// 池是**进入时的快照**：这里刻意不监听 `favoriteChangedNotifier`——看到一半
/// 队伍在用户眼皮底下自己变短，"下一条是谁"就不可预期了（同稍后再看池那段说明）。
class LocalFavoritePlaybackQueue extends PagedPlaybackQueue {
  LocalFavoritePlaybackQueue({
    required super.queueId,
    required this.folderId,
    required FavoriteService service,
    String? title,
    this.mediaType = PlaybackMediaType.video,
  }) : _service = service,
       _title = title,
       super(pageSize: 32);

  final String folderId;
  final FavoriteService _service;
  final String? _title;

  @override
  final PlaybackMediaType mediaType;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.localFavorite;

  @override
  String? get title => _title;

  @override
  String get debugLabel => '本地收藏夹 $folderId';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final rows = await _service.getFolderItems(
      folderId,
      offset: page * limit,
      limit: limit,
    );
    final wanted = mediaType.isGallery
        ? FavoriteItemType.image
        : FavoriteItemType.video;
    return (
      items: [
        for (final row in rows)
          if (row.itemType == wanted)
            InnerPlaylistItemSnapshot(
              id: row.itemId,
              title: row.title,
              thumbnailUrl: row.previewUrl ?? '',
              // 统计三件套一个都没有（本地库不存），留 null 让列表整段让位，
              // 别拿 0 冒充"没人看过"——见 [InnerPlaylistItemSnapshot.numViews]。
              liked: false,
              isPrivate: false,
              isExternalVideo: false,
              externalVideoDomain: '',
              authorName: row.authorName,
              authorUsername: row.authorUsername,
            ),
      ],
      rawCount: rows.length,
    );
  }
}

/// 下载池：已经下载到本地的视频。
///
/// ⛔ **只装视频、按 media_id 去重**：图库在播放器里放不了（与稍后再看池同一条
/// 契约）；同一个视频下过两档清晰度是两条任务，不去重就会在「接着看」里排出
/// 两条一模一样的片子。去重在 SQL 里做（见
/// [DownloadTaskRepository.getCompletedVideoTasks]）。
///
/// # ⭐ 这个池里的条目**用本地文件播**
///
/// 池的身份就是"磁盘上这些文件"。从它里面接着看却回头去联网拉流，等于把这个
/// 池的意义抹掉——离线时更是直接播不了。所以 [localTargetFor] 会把文件路径连
/// 同同一视频的其它清晰度一起交出去，导航层据此开本地播放页。
///
/// 文件在池建好之后被删掉是可能的（用户去下载页删了、或者系统清了缓存），
/// 所以 [localTargetFor] **每次都 stat 一遍**：文件没了就答 null，让导航层
/// 老实退回在线详情页，而不是开一个黑屏播放器。
class DownloadsPlaybackQueue extends PagedPlaybackQueue {
  DownloadsPlaybackQueue({
    required super.queueId,
    required DownloadTaskRepository repository,
    this.categoryFilter = 'all',
    String? title,
  }) : _repository = repository,
       _title = title,
       super(pageSize: 32);

  /// 与下载列表页同一套字面量：`'all'` 全部 / `'uncategorized'` 未分类 /
  /// 其它值为具体分类 id。**它是池身份的一部分**，编进了 [queueId]——换一个
  /// 分类就是换一个池，和稍后再看的筛选同理。
  final String categoryFilter;

  final DownloadTaskRepository _repository;
  final String? _title;

  @override
  String? get title => _title;

  /// media_id → 那条任务。[localTargetFor] 靠它把 id 换回磁盘上的文件。
  final Map<String, DownloadTask> _tasksById = <String, DownloadTask>{};

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.downloads;

  @override
  String get debugLabel => '已下载';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final tasks = await _repository.getCompletedVideoTasks(
      offset: page * limit,
      limit: limit,
      categoryFilter: categoryFilter,
    );
    final items = <InnerPlaylistItemSnapshot>[];
    for (final task in tasks) {
      final mediaId = task.mediaId?.trim();
      if (mediaId == null || mediaId.isEmpty) continue;
      final ext = task.extData;
      VideoDownloadExtData? data;
      if (ext != null && ext.type == DownloadTaskExtDataType.video) {
        data = VideoDownloadExtData.fromJson(ext.data);
      }
      _tasksById[mediaId] = task;
      items.add(
        InnerPlaylistItemSnapshot(
          id: mediaId,
          title: data?.title?.trim().isNotEmpty == true
              ? data!.title!.trim()
              : task.fileName,
          thumbnailUrl: data?.thumbnail ?? '',
          // 统计三件套本地库一样没有，留 null 让列表整段让位（同稍后再看池）。
          liked: false,
          isPrivate: false,
          isExternalVideo: false,
          externalVideoDomain: '',
          authorName: data?.authorName,
          authorUsername: data?.authorUsername,
          durationSeconds: data?.duration,
        ),
      );
    }
    // rawCount 用**过滤前**的条数：上面丢掉了没有 media_id 的历史数据，
    // 拿过滤后的条数判断会把"这一页正好都是脏数据"当成池到底了。
    return (items: items, rawCount: tasks.length);
  }

  @override
  Future<LocalPlaybackTarget?> localTargetFor(String itemId) async {
    final task = _tasksById[itemId];
    if (task == null) return null;
    final filePath = path.normalize(task.savePath);
    if (!await File(filePath).exists()) return null;

    // 同一视频的其它清晰度：本地播放页要用它做清晰度切换。取不到就只带自己，
    // 别让一次数据库异常把「能播」变成「播不了」。
    List<DownloadTask> allQuality = <DownloadTask>[task];
    try {
      final rows = await _repository.getVideoTasksByMedia(itemId);
      final completed = rows
          .where((row) => row.status == DownloadStatus.completed)
          .toList();
      if (completed.isNotEmpty) allQuality = completed;
    } catch (e) {
      LogUtils.w('取同视频其它清晰度失败：$e', 'DownloadsPlaybackQueue');
    }

    return LocalPlaybackTarget(
      localPath: filePath,
      task: task,
      allQualityTasks: allQuality,
    );
  }
}

/// 最爱池（图库）：Iwara 服务端的「最爱」里的图库（要登录）。
///
/// 与 [FavoriteVideosPlaybackQueue] 是两条并列的池而不是一条带开关的：两边走的
/// 是两个不同的接口，条目也落在两个不同的详情页。
class FavoriteGalleriesPlaybackQueue extends PagedPlaybackQueue {
  FavoriteGalleriesPlaybackQueue({
    required super.queueId,
    required GalleryService service,
  }) : _service = service,
       super(pageSize: 32);

  final GalleryService _service;

  @override
  PlaybackMediaType get mediaType => PlaybackMediaType.gallery;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.favorites;

  @override
  String get debugLabel => '最爱（图库）';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final result = await _service.fetchFavoriteImages(page: page, limit: limit);
    if (!result.isSuccess || result.data == null) {
      throw StateError(result.message);
    }
    final galleries = result.data!.results;
    return (
      items: [
        for (final ImageModel gallery in galleries)
          InnerPlaylistItemSnapshot.fromGallery(gallery),
      ],
      rawCount: galleries.length,
    );
  }
}

/// 作者图库池：这个图库的作者发过的全部图库。
///
/// ⛔ **不排除当前这条**：池的游标是靠"当前 id 在列表里的位置"找的
/// （[PlaybackQueue.itemAfter]），把它排掉就等于把游标弄丢，推进直接失效。
/// 所以这里不能用 `GalleryService.fetchAuthorImages`——那一条是给"相关推荐"
/// 用的，签名上就要求传 `excludeImageId`。
class AuthorGalleriesPlaybackQueue extends PagedPlaybackQueue {
  AuthorGalleriesPlaybackQueue({
    required super.queueId,
    required this.userId,
    required GalleryService service,
    String? title,
  }) : _service = service,
       _title = title,
       super(pageSize: 32);

  final String userId;
  final GalleryService _service;
  final String? _title;

  @override
  PlaybackMediaType get mediaType => PlaybackMediaType.gallery;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.authorGalleries;

  @override
  String? get title => _title;

  @override
  String get debugLabel => '作者图库 $userId';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final result = await _service.fetchImageModelsByParams(
      params: {'user': userId},
      page: page,
      limit: limit,
    );
    if (!result.isSuccess || result.data == null) {
      throw StateError(result.message);
    }
    final galleries = result.data!.results;
    return (
      items: [
        for (final ImageModel gallery in galleries)
          InnerPlaylistItemSnapshot.fromGallery(gallery),
      ],
      rawCount: galleries.length,
    );
  }
}

/// 稍后再看池。
///
/// ⛔ **一次只装一种**（视频池排除站外视频）：抽屉的契约是"接下来能接着看的
/// 东西"，而视频和图库落在两个不同的详情页——视频池里排一个点了就跳走的图库
/// 自相矛盾，反过来也一样。图库那一份是**另一个池**（[mediaType] 编进了
/// [queueId]）。
///
/// 筛选（`全部 | 未看完`）同样是**池身份的一部分**——切筛选就是换了一个池。
///
/// ⛔ 图库的「未看完」判据和视频不一样：图库没有连续进度，**打开详情页即算
/// 已看**（见 `GalleryDetailController`）。这里不必区分，`watched_at` 那一列
/// 两边共用。
class WatchLaterPlaybackQueue extends PlaybackQueue {
  WatchLaterPlaybackQueue({
    required super.queueId,
    required this.unwatchedOnly,
    required WatchLaterService service,
    required WatchLaterSort sort,
    this.mediaType = PlaybackMediaType.video,
  }) : _service = service,
       _sort = sort {
    _service.watchLaterChangedNotifier.addListener(_reload);
    _reload();
  }

  final bool unwatchedOnly;
  final WatchLaterService _service;
  WatchLaterSort _sort;

  @override
  final PlaybackMediaType mediaType;

  List<WatchLaterItem> _rows = const [];
  List<InnerPlaylistItemSnapshot> _items = const [];

  /// 「未看完」池**进入时**的成员名单（有序）。
  ///
  /// ⛔ 台账定的是「池是进入时的快照」，这里必须钉住，否则会出两个问题：
  /// 1. 当前这条一播完就被标成已看完 → 活查询立刻把它移出池 → 推进时找不到
  ///    自己，顺序整个乱掉；
  /// 2. 用户眼皮底下列表在自己变短，"下一条是谁"不可预期。
  ///
  /// 名单只减不增：用户**主动删掉**的条目会消失（那是明确意图），但"刚看完"
  /// 不会。新加入的条目要等下次进池才算数。
  List<String>? _pinnedIds;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.watchLater;

  @override
  List<InnerPlaylistItemSnapshot> get loaded => _items;

  /// 排序变了就重查。列表页与抽屉共享同一份排序状态。
  void applySort(WatchLaterSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    // 换排序是用户明确要"换一个顺序看"，快照跟着重新钉一次。
    _pinnedIds = null;
    _reload();
  }

  void _reload() {
    final rows = _service.query(
      itemType: mediaType.isGallery
          ? WatchLaterItemType.image
          : WatchLaterItemType.video,
      // 「未看完」池钉住成员之后就不能再按 watched 过滤了——否则刚看完的那条
      // 会被查询本身剔掉，钉住也没用。成员资格由 [_pinnedIds] 说了算。
      unwatchedOnly: unwatchedOnly && _pinnedIds == null,
      // 站外只有视频才有这个概念，图库那边这一列恒为 0，加不加都一样。
      excludeExternal: true,
      excludeInvalid: true,
      sort: _sort,
    );

    if (unwatchedOnly) {
      if (_pinnedIds == null) {
        _pinnedIds = rows.map((row) => row.itemId).toList(growable: false);
        _rows = rows;
      } else {
        // 按进入时的顺序还原，并丢掉已经被用户删掉的。
        final byId = {for (final row in rows) row.itemId: row};
        _rows = [
          for (final id in _pinnedIds!)
            if (byId[id] != null) byId[id]!,
        ];
      }
    } else {
      _rows = rows;
    }
    _items = List<InnerPlaylistItemSnapshot>.unmodifiable(
      _rows.map(
        (row) => InnerPlaylistItemSnapshot(
          id: row.itemId,
          title: row.title,
          thumbnailUrl: row.thumbnailUrl ?? '',
          // 同上：本地库没有统计，留 null 而不是 0。
          liked: false,
          isPrivate: false,
          isExternalVideo: false,
          externalVideoDomain: '',
          authorName: row.author,
          authorUsername: row.authorUsername,
          // 稍后再看是唯一带得出「看到哪儿了」的池：时长与进度都存在本地行里。
          durationSeconds: row.durationMs == null
              ? null
              : row.durationMs! ~/ 1000,
          numImages: row.numImages,
          progressPermil: row.progressPermil,
        ),
      ),
    );
    notifyListeners();
  }

  @override
  bool _isWatched(String id) {
    for (final row in _rows) {
      if (row.itemId == id) return row.isWatched;
    }
    return false;
  }

  @override
  void dispose() {
    _service.watchLaterChangedNotifier.removeListener(_reload);
    super.dispose();
  }
}
