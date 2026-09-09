import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:flutter/foundation.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/models/favorite/favorite_item.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
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

  /// 本机文件：用户加进来的源文件夹扫出来的那些（`local_media_items`）。
  ///
  /// 与 [downloads] 分成两条而不是共用：两者都是"磁盘上的文件"，但一个是
  /// **我们下的**（有作者、封面、官方标题、能退回在线播），另一个是**用户自己
  /// 拷进来的**（只有文件名）。共用一个槽会让两者在抽屉里互相顶掉，而用户完全
  /// 可能一边看本机片一边想切回已下载。
  ///
  /// ⛔ 与 [localFavorite] 更是两回事：那一条是**收藏夹**（`FavoriteService`），
  /// 名字里的"本地"说的是"存在本机的收藏关系"，不是磁盘目录。
  localLibrary,

  /// 订阅动态：已关注作者的全部作品，接口分页（要登录）。
  ///
  /// 与 [source] 分成两条而不是共用：从订阅页点进来时，[source] 装的是**那一页
  /// 当时的筛选**（可能只看某个作者、某个月、某个标签），而这一条是不带筛选的
  /// 整条订阅动态——两者能同时出现在抽屉里，共用一个槽会互相顶掉。
  subscriptions,
}

/// 「这一条用本地文件播」的全部材料。
///
/// 给得出它的是那两个"磁盘上的文件"池：[DownloadsPlaybackQueue] 与
/// [LocalLibraryPlaybackQueue]。从它们里面接着看却回头去联网拉流，等于把这个池
/// 的意义抹掉（离线时更是直接播不了）。
@immutable
class LocalPlaybackTarget {
  const LocalPlaybackTarget({
    required this.localPath,
    this.task,
    this.localLibraryItemId,
    this.allQualityTasks = const <DownloadTask>[],
  });

  final String localPath;

  /// ⛔ **可空**：本机文件池里的条目压根没有下载任务（用户自己拷进来的），
  /// 它们的标题就是文件名、也没有别的清晰度。原来这里是非空的，因为当时只有
  /// 下载池会给出 [LocalPlaybackTarget]。
  final DownloadTask? task;

  /// 本地库里这条的稳定 id（`local_media_items.id`）。只有本机文件池会给。
  /// 详情页拿它记进度，见 `MyVideoStateController.localLibraryItemId`。
  final String? localLibraryItemId;

  /// 同一个视频的其它清晰度，本地播放页要用它做清晰度切换。
  /// 本机文件只有一份，恒为空表。
  final List<DownloadTask> allQualityTasks;
}

/// 本地播放页的路由 id。
///
/// ⛔ 必须**带 `local_` 前缀且每条片子各不相同**：前缀是全 App 认「这是本地
/// 视频」的记号（`NaviService.navigateToLocalVideoPlayerPage` 一直这么发），
/// 而把媒体 id 编进去是为了让详情页那道"同一个视频不重复入栈"的守卫仍然分得清
/// 两条片子。
String localVideoRouteId(String mediaId) => 'local_$mediaId';

/// 路由 extra 里传的东西：只有几个字符串。池的真身在 `PlaybackQueueService`。
@immutable
class PlaybackQueueRef {
  const PlaybackQueueRef({
    required this.queueId,
    required this.currentItemId,
    this.companionQueueIds = const <String>[],
  });

  final String queueId;
  final String currentItemId;

  /// 上一页手上**其它**的池（来源 / 稍后再看 / 作者作品……），按原顺序。
  ///
  /// ⛔ 少了它，换片就会把「来源」弄丢：`pushReplacement` 只带得过 [queueId] 那
  /// 一个池，新页重建池清单时来源上下文（`innerPlaylistContext`）已经不在路由
  /// extra 里了——从「稍后再看」tab 点一条，新页的抽屉 / 沉浸面板里就只剩稍后再看
  /// （2026-09-05 Quest 用户报障）。新页按 id 从服务里把还活着的池重新接上。
  final List<String> companionQueueIds;

  PlaybackQueueRef copyWith({String? currentItemId}) => PlaybackQueueRef(
    queueId: queueId,
    currentItemId: currentItemId ?? this.currentItemId,
    companionQueueIds: companionQueueIds,
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
  PagedPlaybackQueue({
    required super.queueId,
    this.pageSize = 32,
    List<InnerPlaylistItemSnapshot> seed = const [],
  }) {
    if (seed.isNotEmpty) _seed(seed);
  }

  final int pageSize;

  final List<InnerPlaylistItemSnapshot> _items = [];
  int _nextPage = 0;
  bool _hasMore = true;
  bool _loading = false;

  /// 拿列表页**已经加载出来的那些条目**当种子，游标跟着往后挪。
  ///
  /// # 为什么要种
  ///
  /// 用户常常是在一份翻了好几页的列表**中段**点进详情页的。池要是从第 0 页
  /// 重新翻起，抽屉一打开既找不到"正在播的这一条"（[itemAfter] 恒为 null，推进
  /// 直接失效），又得靠 [ensureContains] 连发好几个请求才追得上——而那些数据
  /// 列表页手上明明就有。
  ///
  /// ⛔ 种子必须是列表的**自然顺序**（不许打乱、不许截断）：池接着往下翻回来的
  /// 是接口的原序，前半截乱了整条线就对不上了。所以带查询的来源快照不走
  /// `InnerPlaylistContext` 那套抽样（见那边的 `_limitItems`）。
  ///
  /// 游标按种子条数折算，多出来的重叠交给去重吃掉——列表页的 limit 与池的
  /// [pageSize] 不一定同一个数，宁可重复请求一页，也不能跳过一页。
  void _seed(List<InnerPlaylistItemSnapshot> seed) {
    final seen = <String>{};
    for (final item in seed) {
      if (item.id.trim().isEmpty || !seen.add(item.id)) continue;
      _items.add(item);
    }
    _nextPage = _items.length ~/ pageSize;
  }

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

/// 接口列表池：拿列表页**自己那份查询**接着往下翻。
///
/// # ⭐ 「来源」从快照升级成这个
///
/// 老的来源池是 [SourcePlaybackQueue]——进详情页那一刻的一份快照，上限 100、
/// 超限还要随机抽样，翻到底就没了。用户从一个带筛选的热门列表、图库列表或者
/// 订阅页点进来，抽屉里只有那几十条，来回看的永远是同一批（2026-08-29 用户报
/// 的正是这个）。
///
/// 现在列表页把**它真正发出去的那份参数**（[MediaListQuery]）一起交出来，池就
/// 用同一个接口、同一份参数接着翻，抽屉里可以一直滚下去。已经加载出来的条目
/// 当种子（见 [PagedPlaybackQueue._seed]），所以打开抽屉不必等一次请求。
///
/// 参数拿不到的列表（相关推荐、深链、搜索结果这类）仍旧走 [SourcePlaybackQueue]
/// ——**没有查询就没有下一页**，硬编一份"差不多的"参数只会让接下来的顺序和用户
/// 刚才看的那份列表对不上。
class RemoteListPlaybackQueue extends PagedPlaybackQueue {
  RemoteListPlaybackQueue({
    required super.queueId,
    required this.query,
    required VideoService videoService,
    required GalleryService galleryService,
    required SearchService searchService,
    this.kind = PlaybackQueueKind.source,
    String? title,
    super.seed,
  }) : _videoService = videoService,
       _galleryService = galleryService,
       _searchService = searchService,
       _title = title,
       // 与各列表页的 limit 对齐：种子的条数多半是它的整数倍，游标折算下来
       // 正好落在下一页的页首，重叠最少。
       super(pageSize: 20);

  final MediaListQuery query;
  final VideoService _videoService;
  final GalleryService _galleryService;
  final SearchService _searchService;
  final String? _title;

  /// 这个池在抽屉里占哪个槽。
  ///
  /// 默认是「来源」；订阅动态那一支传 [PlaybackQueueKind.subscriptions]——两者
  /// 能同时在场（从订阅页带筛选进来时，来源是那份筛选、订阅是整条动态），
  /// 共用一个槽会互相顶掉。
  @override
  final PlaybackQueueKind kind;

  @override
  PlaybackMediaType get mediaType => query.mediaType;

  @override
  String? get title => _title;

  @override
  String get debugLabel => '接口列表 ${query.signature}';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    // 搜索结果走 `/search`——那条接口的入参与 `/videos`、`/images` 完全不同
    // （见 `SearchService`），不能拿 params 硬凑。
    final String? keyword = query.search;
    if (keyword != null) {
      if (query.mediaType.isGallery) {
        final result = await _searchService.fetchImageByQuery(
          query: keyword,
          sort: query.searchSort,
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
      final result = await _searchService.fetchVideoByQuery(
        query: keyword,
        sort: query.searchSort,
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
    if (query.mediaType.isGallery) {
      final result = await _galleryService.fetchImageModelsByParams(
        params: query.params,
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
    final result = await _videoService.fetchVideosByParams(
      params: query.params,
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
          // 存的是哪一档清晰度——这个池独有的信息，列表上要看得见（下载列表页
          // 一直显示，抽屉里没有反而是缺的）。以 `quality` 列为准、ext_data
          // 兜底：列是 v17 之后才有的，老行只在 ext_data 里带着。
          localQuality: _qualityOf(task, data),
        ),
      );
    }
    // rawCount 用**过滤前**的条数：上面丢掉了没有 media_id 的历史数据，
    // 拿过滤后的条数判断会把"这一页正好都是脏数据"当成池到底了。
    return (items: items, rawCount: tasks.length);
  }

  /// 这条任务存的是哪一档清晰度。`quality` 列优先，老行退回 ext_data。
  static String? _qualityOf(DownloadTask task, VideoDownloadExtData? data) {
    final fromColumn = task.quality?.trim();
    if (fromColumn != null && fromColumn.isNotEmpty) return fromColumn;
    final fromExt = data?.quality?.trim();
    return fromExt == null || fromExt.isEmpty ? null : fromExt;
  }

  /// ⛔ **点的时候现查一次库**，不是回头去问 [_tasksById] 那份快照。
  ///
  /// 这个池是缓存的（`PlaybackQueueService` 的 LRU 能让它活很久），而 `_tasksById`
  /// 里那些 [DownloadTask] 是**建池那一刻**抓在手里的对象。中间只要发生过一次
  /// 「删了重下」「换清晰度重下」「迁移下载目录」，快照里的 `savePath` 就指向一个
  /// 已经不在的文件——[localTargetFor] 于是答 null，导航层老实退回在线详情页，
  /// 而用户看到的是"在已下载列表里点了一条，却以在线方式打开了"。现查库把这一
  /// 整类失效彻底去掉：磁盘上还有文件，就一定用本地播。
  ///
  /// 同一视频下过多档清晰度时，**先试这一行代表的那一档**（列表上写的就是它），
  /// 它的文件没了再退到其它还在的那一档——只要还有一档在，这条就仍旧是"已下载"。
  @override
  Future<LocalPlaybackTarget?> localTargetFor(String itemId) async {
    List<DownloadTask> completed = const <DownloadTask>[];
    try {
      final rows = await _repository.getVideoTasksByMedia(itemId);
      completed = rows
          .where((row) => row.status == DownloadStatus.completed)
          .toList();
    } catch (e) {
      // 一次数据库异常不该把「能播」变成「播不了」：退回快照里那一条。
      LogUtils.w('查已下载任务失败，退回池内快照：$e', 'DownloadsPlaybackQueue');
    }
    final cached = _tasksById[itemId];
    if (completed.isEmpty && cached != null) {
      completed = <DownloadTask>[cached];
    }
    if (completed.isEmpty) {
      LogUtils.w('已下载池里的 $itemId 在库里找不到已完成任务', 'DownloadsPlaybackQueue');
      return null;
    }

    // 列表这一行代表的那条排在最前，其余按原序垫后。
    final ordered = <DownloadTask>[
      ...completed.where((row) => row.id == cached?.id),
      ...completed.where((row) => row.id != cached?.id),
    ];

    for (final task in ordered) {
      final savePath = task.savePath.trim();
      if (savePath.isEmpty) continue;
      final filePath = path.normalize(savePath);
      if (!await File(filePath).exists()) continue;
      return LocalPlaybackTarget(
        localPath: filePath,
        task: task,
        // 本地播放页要用它做清晰度切换。
        allQualityTasks: completed,
      );
    }

    LogUtils.w(
      '已下载池里的 $itemId 有 ${completed.length} 条完成记录，但磁盘上一个文件都不在了',
      'DownloadsPlaybackQueue',
    );
    return null;
  }
}

/// 本机文件池：用户加进来的源文件夹扫出来的那些视频（`local_media_items`）。
///
/// # 为什么是一个带筛选参数的池，而不是好几种 kind
///
/// 「整个源」与「某个文件夹」是同一件事的两个粒度，和
/// [DownloadsPlaybackQueue.categoryFilter] 完全同构。多开一个 kind 要在抽屉、
/// XR 目录、导航层、服务里各接一遍（五处），而这里只是 [queueId] 上多一段。
///
/// # ⛔ 排序必须和用户看的那张卡片墙一致
///
/// 池的顺序就是"接下来播什么"。列表按名称自然序排着、池却按添加时间排，
/// 用户点第 3 集，下一条会是个毫不相干的东西。所以 [sort] 是**池身份的一部分**，
/// 一起编进 [queueId]。
///
/// # ⛔ 取数是同步的（sqlite3 同步 API）
///
/// `fetchPage` 声明成 Future 只是为了对上基类；里面那两句 `queryItems` /
/// `progressFor` 是**同步落在 UI 线程上**的。所以 [pageSize] 压到 32、
/// 进度一次批量取（见 `LocalMediaRepository.progressFor`），不能逐条查。
class LocalLibraryPlaybackQueue extends PagedPlaybackQueue {
  LocalLibraryPlaybackQueue({
    required super.queueId,
    required LocalMediaRepository repository,
    this.sourceId,
    this.folderPath,
    this.sort = LocalMediaSort.addedDesc,
    String? title,
  }) : _repository = repository,
       _title = title,
       super(pageSize: 32);

  /// 限定在哪个源里。null = 全部源（"本机文件 · 全部"）。
  final String? sourceId;

  /// 再限定到某个文件夹。null = 整个源。
  final String? folderPath;

  /// 与卡片墙同一档排序，见类注释。
  final LocalMediaSort sort;

  final LocalMediaRepository _repository;
  final String? _title;

  /// item id → 磁盘路径。[localTargetFor] 的快照，**只作兜底**（见那边注释）。
  final Map<String, String> _pathsById = <String, String>{};

  /// 建池时就已经看完的那些。
  ///
  /// ⚠️ **今天这份数据用不上**：`skipWatched` 只有从「稍后再看 · 未看完」那个
  /// tab 点播时才为真，本机文件池走不到那条路。留着是因为 [_isWatched] 是基类的
  /// 契约，答一个恒 false 比答一个错的强。
  ///
  /// ⛔ 真要用起来时，它也**必须是快照**，不能在 [_isWatched] 里现查库：
  /// `itemAfter` 会在 `canAdvance` 里被调到，而 `canAdvance` 每帧 build 都要问
  /// 一次——现查等于每帧对着整页条目发几十次同步 select（sqlite3 是同步 API，
  /// 全落在 UI 线程上）。快照语义本身也更对：要跳过的是「**打开这个池之前**就
  /// 看完的那些」，而不是刚刚播完的这一条。
  final Set<String> _watchedIds = <String>{};

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.localLibrary;

  @override
  String? get title => _title;

  @override
  String get debugLabel => '本机文件';

  @override
  Future<({List<InnerPlaylistItemSnapshot> items, int rawCount})> fetchPage(
    int page,
    int limit,
  ) async {
    final rows = _repository.queryItems(
      sourceId: sourceId,
      folderPath: folderPath,
      sort: sort,
      offset: page * limit,
      limit: limit,
    );
    final progress = _repository.progressFor([for (final r in rows) r.id]);
    final items = <InnerPlaylistItemSnapshot>[];
    for (final row in rows) {
      _pathsById[row.id] = row.path;
      final seen = progress[row.id];
      if (seen?.completed == true) _watchedIds.add(row.id);
      items.add(
        InnerPlaylistItemSnapshot(
          id: row.id,
          title: row.name,
          // ⭐ 同目录的现成封面（下载器普遍会写一张）。
          //
          // ⛔ 必须发成 `file://` **URI**，不能把裸路径塞进来：这个字段的消费方
          // 默认它是网址（抽屉里是 `CachedNetworkImage`，沉浸面板交给原生的
          // 图片加载器），喂一条 `/storage/emulated/0/...` 进去不是"加载不出来"
          // 而是**画一枚碎图图标**——比没有封面更糟。`file://` 则是本仓库既有的
          // 约定（大图页、胶片条都认），消费方一眼分得出这是本地文件。
          thumbnailUrl: _coverUriOf(row),
          // 统计三件套本地库一样没有，留 null 让列表整段让位（同下载池）。
          liked: false,
          isPrivate: false,
          isExternalVideo: false,
          externalVideoDomain: '',
          durationSeconds: row.durationMs == null
              ? null
              : (row.durationMs! / 1000).round(),
          progressPermil: _permilOf(seen),
        ),
      );
    }
    // rawCount 用**过滤前**的条数，与下载池同一条理由。
    return (items: items, rawCount: rows.length);
  }

  /// 封面地址。sidecar 优先、我们自己生成的缩略图垫后，都没有就空串。
  static String _coverUriOf(LocalMediaItem row) {
    final cover = row.sidecarImagePath ?? row.thumbPath;
    if (cover == null || cover.trim().isEmpty) return '';
    return Uri.file(cover).toString();
  }

  /// 看到哪儿了，千分比。看完的记满格——列表上"看完"和"没看过"不能长得一样。
  static int _permilOf(({int positionMs, int? durationMs, bool completed})? p) {
    if (p == null) return 0;
    if (p.completed) return 1000;
    final total = p.durationMs;
    if (total == null || total <= 0) return 0;
    return ((p.positionMs / total) * 1000).round().clamp(0, 1000);
  }

  /// 跳过看完的：`skipWatched` 那一路要用（见 [PlaybackQueue.itemAfter]）。
  /// 读的是 [_watchedIds] 那份快照——**不能现查库**，理由见那边。
  @override
  bool _isWatched(String id) => _watchedIds.contains(id);

  /// ⛔ **点的时候现查一次库**，理由与 [DownloadsPlaybackQueue.localTargetFor]
  /// 一字不差：池是缓存的（LRU 能让它活很久），而 `_pathsById` 是建池那一刻的
  /// 快照。中间只要重扫过一次（文件被改名 / 移动 / 删掉），快照里的路径就指向
  /// 一个已经不在的文件。
  ///
  /// 查不到、或者磁盘上确实没有这个文件，就返回 null——调用方会如实说一句，
  /// 而不是开一个黑屏播放器。
  @override
  Future<LocalPlaybackTarget?> localTargetFor(String itemId) async {
    String? path;
    try {
      path = _repository.getItem(itemId)?.path;
    } catch (e) {
      LogUtils.w('查本机文件失败，退回池内快照：$e', 'LocalLibraryPlaybackQueue');
    }
    path ??= _pathsById[itemId];
    if (path == null || path.trim().isEmpty) {
      LogUtils.w('本机文件池里的 $itemId 在库里找不到', 'LocalLibraryPlaybackQueue');
      return null;
    }
    if (!await File(path).exists()) {
      LogUtils.w('本机文件池里的 $itemId 在磁盘上已不存在', 'LocalLibraryPlaybackQueue');
      return null;
    }
    return LocalPlaybackTarget(localPath: path, localLibraryItemId: itemId);
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
