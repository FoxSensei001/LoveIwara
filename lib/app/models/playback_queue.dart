import 'package:flutter/foundation.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

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
}

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

  /// 还有页面/抽屉在听它。
  ///
  /// LRU 淘汰要看这个：把一个仍被监听的池 dispose 掉，下一次它通知时就会炸
  /// 「A ChangeNotifier was used after being disposed」，而且监听方
  /// `removeListener` 也会在 debug 下抛异常。
  bool get isInUse => hasListeners;

  /// 供 [itemAfter] 判断"这条看完没有"。只有本地池答得上来。
  bool _isWatched(String id) => false;
}

/// 来源池：进详情页之前那个列表的快照，不分页。
class SourcePlaybackQueue extends PlaybackQueue {
  SourcePlaybackQueue({required super.queueId, required this.context});

  final InnerPlaylistContext context;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.source;

  @override
  List<InnerPlaylistItemSnapshot> get loaded => context.items;
}

/// 播放列表池：接口分页，**不设 100 上限、不打乱**。
///
/// 和来源池的区别不只是"能翻页"：来源池打乱是有意的（那是一次随机推荐），
/// 而播放列表是作者排好的顺序，打乱就把它的意义毁了。
class PlaylistPlaybackQueue extends PlaybackQueue {
  PlaylistPlaybackQueue({
    required super.queueId,
    required this.playlistId,
    required PlayListService service,
    String? title,
  }) : _service = service,
       _title = title;

  static const int pageSize = 32;

  final String playlistId;
  final PlayListService _service;
  String? _title;

  final List<InnerPlaylistItemSnapshot> _items = [];
  int _nextPage = 0;
  bool _hasMore = true;
  bool _loading = false;

  @override
  PlaybackQueueKind get kind => PlaybackQueueKind.playlist;

  @override
  String? get title => _title;

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
      final result = await _service.getPlaylistVideos(
        playlistId: playlistId,
        page: _nextPage,
        limit: pageSize,
      );
      if (result.isSuccess && result.data != null) {
        final page = result.data!;
        final seen = _items.map((e) => e.id).toSet();
        for (final Video video in page.results) {
          if (video.id.trim().isEmpty || !seen.add(video.id)) continue;
          _items.add(InnerPlaylistItemSnapshot.fromVideo(video));
        }
        _nextPage++;
        // 后端给的 count 在有些接口上是"已加载+1"的哨兵而不是总数（作者页作品数
        // 那次踩过），所以**不拿 count 判有没有下一页**，只看这一页是不是满的。
        _hasMore = page.results.length >= pageSize;
      }
      // ⛔ 请求失败**不动 `_hasMore`**：一次网络抖动就把它钉成 false 的话，
      // 这个池在被 LRU 淘汰之前都再也翻不出下一页了（而它是缓存的，可能活很久）。
      // 只有"这一页没装满"才是真的到底。
    } catch (e) {
      LogUtils.e('播放列表分页加载失败', tag: 'PlaylistPlaybackQueue', error: e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void updateTitle(String? title) {
    if (title == null || title.isEmpty || title == _title) return;
    _title = title;
    notifyListeners();
  }
}

/// 稍后再看池。
///
/// ⛔ **只装视频、且排除站外视频**：抽屉的契约是"接下来能在这个播放器里看的
/// 东西"，装一个点了就跳走的图库自相矛盾。
///
/// 筛选（`全部 | 未看完`）是**池身份的一部分**——切筛选就是换了一个池，所以它
/// 编进了 [queueId]。
class WatchLaterPlaybackQueue extends PlaybackQueue {
  WatchLaterPlaybackQueue({
    required super.queueId,
    required this.unwatchedOnly,
    required WatchLaterService service,
    required WatchLaterSort sort,
  }) : _service = service,
       _sort = sort {
    _service.watchLaterChangedNotifier.addListener(_reload);
    _reload();
  }

  final bool unwatchedOnly;
  final WatchLaterService _service;
  WatchLaterSort _sort;

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
      itemType: WatchLaterItemType.video,
      // 「未看完」池钉住成员之后就不能再按 watched 过滤了——否则刚看完的那条
      // 会被查询本身剔掉，钉住也没用。成员资格由 [_pinnedIds] 说了算。
      unwatchedOnly: unwatchedOnly && _pinnedIds == null,
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
