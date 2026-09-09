import 'dart:async';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 沉浸面板「接着看」的**来源目录**：与 2D 抽屉里那张两级菜单同一套东西。
///
/// # 为什么要有它
///
/// 详情页手上的池（[XrQueueSnapshot.queues]）只有来源 + 稍后再看 + 换片带过来的那一个；
/// 「最爱 / 我的播放列表 / 本地收藏 / 已下载 / 作者的视频 / 作者的播放列表 / 他人的播放列表」
/// 在 2D 抽屉里都是**点了才现开**的。之前沉浸面板只推已开的池，于是分区只剩稍后再看
/// （用户 2026-09-05：「接着看列表不全」）。
///
/// 目录是**两级**的：分组（= 抽屉第一级）→ 选项（= 抽屉第二级：哪张播放列表 / 哪个收藏夹 /
/// 哪个下载分类 / 稍后再看的筛选）。每个选项对应一个 `queueId`，面板点了还没开的选项，
/// 原生回来喊 `openQueue {queueId}`，这里按 [opener] 把池开出来交给详情页收养。
///
/// 清单（播放列表 / 收藏夹 / 下载分类）是异步拉的：[build] 立即返回手上有的，没拉到的分组标
/// `loading`，拉完通过 [onChanged] 让服务重推一次。
class XrQueueCatalog {
  XrQueueCatalog({required this.onChanged});

  /// 某份清单拉完了：调用方应当重推整套目录。
  final void Function() onChanged;

  static const String _tag = 'XrQueueCatalog';

  final Map<String, _Feed> _feeds = <String, _Feed>{};

  /// `queueId → 怎么开这个池`，随每次 [build] 重算。
  final Map<String, PlaybackQueue Function()> _openers =
      <String, PlaybackQueue Function()>{};

  /// 用户点了刷新：清单重拉。
  void invalidate() {
    _feeds.clear();
  }

  /// 按 [queueId] 开池；目录里没有这个 id 返回 null。
  PlaybackQueue? open(String queueId) => _openers[queueId]?.call();

  /// 组装目录。同步返回，清单没到的分组标 `loading`。
  List<XrQueueGroup> build({
    required List<PlaybackQueue> queues,
    required String currentItemId,
    required User? author,
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) {
    final t = slang.t;
    final service = PlaybackQueueService.to;
    final self = Get.isRegistered<UserService>()
        ? Get.find<UserService>().currentUser.value
        : null;
    _openers.clear();
    final groups = <XrQueueGroup>[];

    XrQueueChoice choice({
      required String queueId,
      required String title,
      int? count,
      required PlaybackQueue Function() open,
    }) {
      _openers[queueId] = open;
      return XrQueueChoice(queueId: queueId, title: title, count: count);
    }

    // 图库池的目录另走一套：图库没有播放列表 / 订阅 / 已下载，作者那一支是「作者的图库」。
    if (mediaType.isGallery) {
      _buildGalleryGroups(groups, choice, queues: queues, author: author, self: self);
      return groups;
    }

    // 1. 来源：只有真有来源池时才出现。
    final source = queues.firstWhereOrNull(
      (q) => q.kind == PlaybackQueueKind.source,
    );
    if (source != null) {
      groups.add(
        XrQueueGroup(
          id: 'source',
          title: t.playbackQueue.sourceTab,
          choices: [
            choice(
              queueId: source.queueId,
              title: t.playbackQueue.sourceTab,
              open: () => source,
            ),
          ],
        ),
      );
    }

    // 2. 订阅：要登录（未登录时 subscribed=true 会被服务端静默忽略）。
    if (self != null) {
      groups.add(
        XrQueueGroup(
          id: 'subscriptions',
          title: t.common.subscriptions,
          choices: [
            choice(
              queueId: PlaybackQueueService.subscriptionsQueueId(),
              title: t.common.subscriptions,
              open: () =>
                  service.openSubscriptions() ??
                  service.openWatchLater(unwatchedOnly: false),
            ),
          ],
        ),
      );
    }

    // 3. 我的播放列表
    if (self != null) {
      final feed = _feed('own:${self.id}', () => _fetchOwnPlaylists(currentItemId));
      groups.add(
        XrQueueGroup(
          id: 'playlists',
          title: t.playbackQueue.myPlaylists,
          loading: !feed.ready,
          choices: [
            for (final row in feed.value ?? const <_Row>[])
              choice(
                queueId: PlaybackQueueService.playlistQueueId(row.id),
                title: row.title,
                count: row.count,
                open: () =>
                    service.openPlaylist(row.id, title: row.title, owner: self),
              ),
          ],
        ),
      );
    }

    // 4. 最爱
    if (self != null) {
      groups.add(
        XrQueueGroup(
          id: 'favorites',
          title: t.common.favorites,
          choices: [
            choice(
              queueId: PlaybackQueueService.favoritesQueueId(),
              title: t.common.favorites,
              open: service.openFavorites,
            ),
          ],
        ),
      );
    }

    // 5. 本地收藏（按收藏夹）
    {
      final feed = _feed('localFolders', _fetchLocalFolders);
      groups.add(
        XrQueueGroup(
          id: 'localFolders',
          title: t.playbackQueue.favoriteFolders,
          loading: !feed.ready,
          choices: [
            for (final row in feed.value ?? const <_Row>[])
              choice(
                queueId: PlaybackQueueService.localFavoriteQueueId(row.id),
                title: row.title,
                count: row.count,
                open: () => service.openLocalFavorite(row.id, title: row.title),
              ),
          ],
        ),
      );
    }

    // 6. 已下载（按分类）
    {
      final feed = _feed('downloads', _fetchDownloadCategories);
      groups.add(
        XrQueueGroup(
          id: 'downloads',
          title: t.playbackQueue.downloads,
          loading: !feed.ready,
          choices: [
            for (final row in feed.value ?? const <_Row>[])
              choice(
                // ⛔ 走服务里的拼法，别在这儿手写字面量：面板注册的 id 和抽屉
                // 判"正开着的是不是这一支"用的 id 一旦分头写，改一处就静默丢
                // 高亮（不报错，只是永远不亮）。
                queueId: PlaybackQueueService.downloadsQueueId(row.id),
                title: row.title,
                count: row.count,
                open: () => service.openDownloads(
                  categoryFilter: row.id,
                  title: row.id == 'all' ? null : row.title,
                ),
              ),
          ],
        ),
      );
    }

    // 6b. 本机文件（按源）。⛔ 一个源都没加过时整组不出现——本地库是可选功能，
    // 绝大多数用户一个源都没有，给他们在面板里留一个空分组只是噪音。
    {
      final feed = _feed('localSources', _fetchLocalSources);
      final rows = feed.value ?? const <_Row>[];
      if (!feed.ready || rows.isNotEmpty) {
        groups.add(
          XrQueueGroup(
            id: 'localLibrary',
            title: t.playbackQueue.localFiles,
            loading: !feed.ready,
            choices: [
              // ⛔ 「全部」必须和 2D 抽屉那边一起有：抽屉在源多于一个时给出这一
              // 支（`localLibrary:all:nameAsc`），面板这边不列的话，用户从抽屉切
              // 到「全部」之后，沉浸面板里**没有任何一行会高亮**——面板认的是
              // queueId，目录里没登记的 id 就是一支它不认识的池。
              if (rows.length > 1)
                choice(
                  queueId: PlaybackQueueService.localLibraryQueueId(
                    sort: LocalMediaSort.nameAsc,
                  ),
                  title: t.common.all,
                  count: rows.fold<int>(0, (sum, r) => sum + (r.count ?? 0)),
                  open: () => service.openLocalLibrary(
                    sort: LocalMediaSort.nameAsc,
                  ),
                ),
              // 一条都没有的源不列：点进去是个空池，而面板上没有地方解释为什么
              //（2D 抽屉那边是靠 `enabled: count > 0` 置灰的）。
              for (final row in rows.where((r) => (r.count ?? 0) > 0))
                choice(
                  queueId: PlaybackQueueService.localLibraryQueueId(
                    sourceId: row.id,
                    sort: LocalMediaSort.nameAsc,
                  ),
                  title: row.title,
                  count: row.count,
                  // ⛔ 排序必须和 2D 抽屉那边一致（都是 `nameAsc`）：排序是池
                  // 身份的一部分，两边不一致就是两个池，面板里点了不会命中抽屉
                  // 已经开着的那一支。
                  open: () => service.openLocalLibrary(
                    sourceId: row.id,
                    sort: LocalMediaSort.nameAsc,
                    title: row.title,
                  ),
                ),
            ],
          ),
        );
      }
    }

    // 7. 稍后再看：全部 / 未看完
    groups.add(
      XrQueueGroup(
        id: 'watchLater',
        title: t.watchLater.title,
        choices: [
          choice(
            queueId: PlaybackQueueService.watchLaterQueueId(unwatchedOnly: false),
            title: t.watchLater.filterAll,
            open: () => service.openWatchLater(unwatchedOnly: false),
          ),
          choice(
            queueId: PlaybackQueueService.watchLaterQueueId(unwatchedOnly: true),
            title: t.watchLater.filterUnwatched,
            open: () => service.openWatchLater(unwatchedOnly: true),
          ),
        ],
      ),
    );

    // 8 / 9. 作者的视频、作者的播放列表
    if (author != null) {
      groups.add(
        XrQueueGroup(
          id: 'authorVideos',
          title: t.playbackQueue.authorVideos,
          subtitle: author.name,
          choices: [
            choice(
              queueId: PlaybackQueueService.authorMediaQueueId(author.id),
              title: author.name,
              open: () => service.openAuthorVideos(author.id, title: author.name),
            ),
          ],
        ),
      );
      if (author.id != self?.id) {
        final feed = _feed(
          'playlistsOf:${author.id}',
          () => _fetchPlaylistsOf(author.id),
        );
        groups.add(
          XrQueueGroup(
            id: 'authorPlaylists',
            title: t.playbackQueue.authorPlaylists,
            subtitle: author.name,
            loading: !feed.ready,
            choices: [
              for (final row in feed.value ?? const <_Row>[])
                choice(
                  queueId: PlaybackQueueService.playlistQueueId(row.id),
                  title: row.title,
                  count: row.count,
                  open: () => service.openPlaylist(
                    row.id,
                    title: row.title,
                    owner: author,
                  ),
                ),
            ],
          ),
        );
      }
    }

    // 10. 他人的播放列表：只在正开着一张既不是我的、也不是作者的列表时才在场。
    final other = _otherPlaylistOwner(queues, self: self, author: author);
    if (other != null) {
      final feed = _feed(
        'playlistsOf:${other.id}',
        () => _fetchPlaylistsOf(other.id),
      );
      groups.add(
        XrQueueGroup(
          id: 'otherPlaylists',
          title: t.playbackQueue.otherPlaylists,
          subtitle: other.name,
          loading: !feed.ready,
          choices: [
            for (final row in feed.value ?? const <_Row>[])
              choice(
                queueId: PlaybackQueueService.playlistQueueId(row.id),
                title: row.title,
                count: row.count,
                open: () =>
                    service.openPlaylist(row.id, title: row.title, owner: other),
              ),
          ],
        ),
      );
    }

    // 已经开着的池即便不在目录里（例如从别处交接来的），也要能点到：给它们各自登记 opener。
    for (final queue in queues) {
      _openers.putIfAbsent(queue.queueId, () => () => queue);
    }
    return groups;
  }

  User? _otherPlaylistOwner(
    List<PlaybackQueue> queues, {
    required User? self,
    required User? author,
  }) {
    for (final queue in queues) {
      if (queue is! PlaylistPlaybackQueue) continue;
      final owner = queue.owner;
      if (owner == null) continue;
      if (owner.id == self?.id || owner.id == author?.id) continue;
      return owner;
    }
    return null;
  }

  // ────────────────────────────────────────────── 清单

  /// 图库详情页的来源目录（= 图库抽屉那几个 tab）：来源 / 最爱的图库 / 本地收藏夹 / 稍后再看 / 作者的图库。
  void _buildGalleryGroups(
    List<XrQueueGroup> groups,
    XrQueueChoice Function({
      required String queueId,
      required String title,
      int? count,
      required PlaybackQueue Function() open,
    }) choice, {
    required List<PlaybackQueue> queues,
    required User? author,
    required User? self,
  }) {
    final t = slang.t;
    final service = PlaybackQueueService.to;
    const gallery = PlaybackMediaType.gallery;

    final source = queues.firstWhereOrNull(
      (q) => q.kind == PlaybackQueueKind.source,
    );
    if (source != null) {
      groups.add(
        XrQueueGroup(
          id: 'source',
          title: t.playbackQueue.sourceTab,
          choices: [
            choice(
              queueId: source.queueId,
              title: t.playbackQueue.sourceTab,
              open: () => source,
            ),
          ],
        ),
      );
    }

    if (self != null) {
      groups.add(
        XrQueueGroup(
          id: 'favorites',
          title: t.common.favorites,
          choices: [
            choice(
              queueId: PlaybackQueueService.favoritesQueueId(gallery),
              title: t.common.favorites,
              open: service.openFavoriteGalleries,
            ),
          ],
        ),
      );
    }

    {
      final feed = _feed('localFolders', _fetchLocalFolders);
      groups.add(
        XrQueueGroup(
          id: 'localFolders',
          title: t.playbackQueue.favoriteFolders,
          loading: !feed.ready,
          choices: [
            for (final row in feed.value ?? const <_Row>[])
              choice(
                queueId: PlaybackQueueService.localFavoriteQueueId(
                  row.id,
                  mediaType: gallery,
                ),
                title: row.title,
                count: row.count,
                open: () => service.openLocalFavorite(
                  row.id,
                  title: row.title,
                  mediaType: gallery,
                ),
              ),
          ],
        ),
      );
    }

    groups.add(
      XrQueueGroup(
        id: 'watchLater',
        title: t.watchLater.title,
        choices: [
          choice(
            queueId: PlaybackQueueService.watchLaterQueueId(
              unwatchedOnly: false,
              mediaType: gallery,
            ),
            title: t.watchLater.filterAll,
            open: () =>
                service.openWatchLater(unwatchedOnly: false, mediaType: gallery),
          ),
          choice(
            queueId: PlaybackQueueService.watchLaterQueueId(
              unwatchedOnly: true,
              mediaType: gallery,
            ),
            title: t.watchLater.filterUnwatched,
            open: () =>
                service.openWatchLater(unwatchedOnly: true, mediaType: gallery),
          ),
        ],
      ),
    );

    if (author != null) {
      groups.add(
        XrQueueGroup(
          id: 'authorGalleries',
          title: t.playbackQueue.authorGalleries,
          subtitle: author.name,
          choices: [
            choice(
              queueId: PlaybackQueueService.authorMediaQueueId(
                author.id,
                mediaType: gallery,
              ),
              title: author.name,
              open: () =>
                  service.openAuthorGalleries(author.id, title: author.name),
            ),
          ],
        ),
      );
    }
  }

  _Feed _feed(String key, Future<List<_Row>?> Function() load) {
    final existing = _feeds[key];
    if (existing != null) return existing;
    final feed = _Feed();
    _feeds[key] = feed;
    unawaited(_load(key, feed, load));
    return feed;
  }

  Future<void> _load(
    String key,
    _Feed feed,
    Future<List<_Row>?> Function() load,
  ) async {
    List<_Row>? rows;
    try {
      rows = await load();
    } catch (e) {
      LogUtils.e('拉取清单失败 $key', tag: _tag, error: e);
    }
    if (rows == null) {
      // 失败不缓存：下次 build 重拉。
      if (identical(_feeds[key], feed)) _feeds.remove(key);
      feed.value = const <_Row>[];
      feed.ready = true;
    } else {
      feed.value = rows;
      feed.ready = true;
    }
    onChanged();
  }

  Future<List<_Row>?> _fetchOwnPlaylists(String videoId) async {
    final result = await Get.find<PlayListService>().getLightPlaylists(
      videoId: videoId,
    );
    if (!result.isSuccess || result.data == null) return null;
    return [
      for (final p in result.data!)
        (id: p.id, title: p.title, count: p.numVideos),
    ];
  }

  Future<List<_Row>?> _fetchPlaylistsOf(String userId) async {
    final result = await Get.find<PlayListService>().getPlaylists(
      userId: userId,
      page: 0,
    );
    if (!result.isSuccess || result.data == null) return null;
    return [
      for (final p in result.data!.results)
        (id: p.id, title: p.title, count: p.numVideos),
    ];
  }

  Future<List<_Row>?> _fetchLocalFolders() async {
    if (!Get.isRegistered<FavoriteService>()) return const <_Row>[];
    final folders = await FavoriteService.to.getAllFolders();
    return [
      for (final f in folders) (id: f.id, title: f.title, count: f.itemCount),
    ];
  }

  /// 本机文件的源清单。
  ///
  /// ⛔ 条数另查一次真数，不能用 `local_media_sources.item_count`：那一列是上次
  /// 扫描结束时的快照（含图片、不排除 missing），而池里只装可播的视频。
  Future<List<_Row>?> _fetchLocalSources() async {
    try {
      final repository = LocalMediaRepository();
      return [
        for (final source in repository.getSources())
          (
            id: source.id,
            title: source.displayName,
            count: repository.countItems(sourceId: source.id),
          ),
      ];
    } catch (e) {
      // ⛔ 这里返回 `const []` 而**不是** null（与那些网络清单相反）。
      //
      // `_feed` 对失败的处理是"不缓存、下次重来"，而 [onChanged] 会让服务重推
      // 整套目录 → 又 build 一次 → 又发一次这个 feed。网络失败是**偶发**的，
      // 重来一次通常就好了；而这是一次纯本地读库，失败的原因（库还没开、路径不
      // 可用）是**持续**的——重来一次还是失败，于是转成一个紧循环。
      // 读不到就当"这台机器上没有本机来源"，那也正是用户看到的事实。
      LogUtils.w('读取本机来源失败，本轮按「没有本机来源」处理: $e', _tag);
      return const <_Row>[];
    }
  }

  Future<List<_Row>?> _fetchDownloadCategories() async {
    if (!Get.isRegistered<DownloadService>()) return const <_Row>[];
    final t = slang.t;
    final service = DownloadService.to;
    final counts = await service.repository.getCompletedVideoCounts();
    final categories = await service.getAllCategories();
    return [
      (id: 'all', title: t.common.all, count: counts.total),
      if (categories.isNotEmpty)
        (
          id: 'uncategorized',
          title: t.download.category.uncategorized,
          count: counts.uncategorized,
        ),
      for (final c in categories)
        (id: c.id, title: c.title, count: counts.byCategory[c.id] ?? 0),
    ];
  }
}

typedef _Row = ({String id, String title, int? count});

class _Feed {
  bool ready = false;
  List<_Row>? value;
}

/// 目录里的一个分组（= 抽屉第一级）。
class XrQueueGroup {
  const XrQueueGroup({
    required this.id,
    required this.title,
    required this.choices,
    this.subtitle,
    this.loading = false,
  });

  final String id;
  final String title;

  /// 作者名一类的副标题。
  final String? subtitle;
  final List<XrQueueChoice> choices;

  /// 清单还在拉。
  final bool loading;

  Map<String, dynamic> toChannelMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle ?? '',
    'loading': loading,
    'choices': choices.map((c) => c.toChannelMap()).toList(),
  };
}

/// 分组里的一个选项（= 抽屉第二级），对应一个池。
class XrQueueChoice {
  const XrQueueChoice({
    required this.queueId,
    required this.title,
    this.count,
  });

  final String queueId;
  final String title;
  final int? count;

  Map<String, dynamic> toChannelMap() => {
    'queueId': queueId,
    'title': title,
    'count': count ?? -1,
  };
}
