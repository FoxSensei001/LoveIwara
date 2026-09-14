import 'dart:async';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 沉浸面板「接着看」的**池选择器**：2D 抽屉那张多级菜单的逐项翻译。
///
/// # ⛔ 这里是照着 `playback_queue_drawer.dart` 抄的，不是另起一套
///
/// 空间版原先自己长了一套「分组 + 选项」的两层结构，与 2D 抽屉对不上的地方一大堆：
/// 图库那一路条目顺序不同、「已下载」空了整组消失而 2D 是置灰、「本机文件」是按源
/// 摊平而 2D 早就改成逐层目录、播放列表没有「正在播放」置顶节（切走就切不回来）、
/// 收藏夹在图库里写着一个对不上的条数……（2026-09-14 用户：「交互和显示效果不一样」）。
///
/// 现在这里输出的是一棵**与抽屉菜单同构的树**：一级 = `_openQueuePicker` 的条目，
/// 往下每一层 = 抽屉里对应的那张二级 / 三级菜单，条目顺序、显隐条件、副标题、置灰
/// 三态、行尾计数、勾与高亮的判据**逐条对应**（注释里标了抽屉那边的方法名）。要改
/// 其中一处，先去抽屉里改，再来这里跟——两边各改各的，就是这次返工的起因。
///
/// # 数据怎么来
///
/// 需要联网或查库的清单（播放列表 / 收藏夹 / 下载分类 / 本机来源 / 本机栏目）在
/// [build] 时后台预取（同抽屉的 `_warmUpChoices`），没到的那一支标 `loading`；逐层
/// 目录只在用户**钻进去**时才读（[expand]，含一次懒扫描，同抽屉的 `_loadLocalLevel`）。
/// 拉完经 [onChanged] 让服务整套重推。
///
/// # ⛔ 高亮看的是「正在浏览的池」，不是播放器在用的池
///
/// 抽屉里菜单的高亮 / 副标题都跟着 `_current`（抽屉当前浏览的那一池），这里的
/// [build] 同样收一个 `browsing`。「正在播」那枚标记（卡片上）另按 active 算，
/// 那是 [XrPlaylistSource] 的事。
class XrQueueCatalog {
  XrQueueCatalog({
    required this.onChanged,
    LocalMediaRepository? localRepository,
  }) : _localRepository = localRepository;

  LocalMediaRepository? _localRepository;
  LocalMediaRepository get _repository =>
      _localRepository ??= LocalMediaRepository();

  /// 某份清单拉完了：调用方应当重推整套目录。
  final void Function() onChanged;

  static const String _tag = 'XrQueueCatalog';

  /// 选择器根节点的 id。
  static const String rootId = 'root';

  final Map<String, _Lazy<Object?>> _caches = <String, _Lazy<Object?>>{};

  /// `queueId → 怎么开这个池`，随每次 [build] 重算。
  final Map<String, PlaybackQueue? Function()> _openers =
      <String, PlaybackQueue? Function()>{};

  /// 钻过的本机目录层：`nodeId → 那一层的数据`。只在 [expand] 里填。
  final Map<(PlaybackMediaType, String), _LocalLevel> _localLevels = {};

  /// 读失败的目录层：画一行「点击重试」，点了再 [expand] 一次。
  final Set<(PlaybackMediaType, String)> _localLevelFailures = {};
  int _localEpoch = 0;

  /// 用户点了刷新：清单与目录层都重拉。
  void invalidate() {
    _localEpoch++;
    _caches.clear();
    _localLevels.clear();
    _localLevelFailures.clear();
    _folderChoiceMemo = null;
  }

  /// 按 [queueId] 开池；目录里没有这个 id 返回 null。
  PlaybackQueue? open(String queueId) => _openers[queueId]?.call();

  /// 面板要钻进一个还没有数据（或上次失败）的节点。
  ///
  /// 返回后调用方整套重推一次。
  Future<void> expand(String nodeId) async {
    final mediaType = _lastMediaType;
    if (nodeId.startsWith(_kLocalDirPrefix)) {
      final epoch = _localEpoch;
      final cacheKey = (mediaType, nodeId);
      final rest = nodeId.substring(_kLocalDirPrefix.length);
      final split = rest.indexOf('|');
      if (split < 0) return;
      final sourceId = rest.substring(0, split);
      final relPath = rest.substring(split + 1);
      final level = await _loadLocalLevel(
        sourceId: sourceId,
        relPath: relPath,
        kind: _itemKind(mediaType),
      );
      // A refresh or media-type change retires both successful and failed reads.
      if (epoch != _localEpoch) return;
      if (level != null) {
        _localLevels[cacheKey] = level;
        _localLevelFailures.remove(cacheKey);
      } else {
        // 读失败也要让这一层**不再是懒节点**，否则面板上那枚转圈永远停不下来。
        _localLevelFailures.add(cacheKey);
      }
      return;
    }
    // 清单类节点：失败的那份丢掉、重拉一次并等它回来。
    final key = _nodeCacheKey[nodeId];
    if (key == null) return;
    final existing = _caches[key];
    if (existing != null && !existing.failed) {
      // 还在路上就等它；已经到了就什么都不用做。
      if (!existing.ready) await existing.future;
      return;
    }
    _caches.remove(key);
    final loader = _loaders[key];
    if (loader == null) return;
    await _cache(key, loader).future;
  }

  PlaybackMediaType _lastMediaType = PlaybackMediaType.video;

  /// 节点 id → 它背后那份清单的缓存键（给 [expand] 用）。
  final Map<String, String> _nodeCacheKey = <String, String>{};
  final Map<String, Future<Object?> Function()> _loaders =
      <String, Future<Object?> Function()>{};

  /// 组装选择器的整棵树。同步返回，没到的清单标 `loading`。
  ///
  /// - [queues]：详情页手上的池，**已按抽屉 `_useQueue` 的规则并入正在浏览的那一池**；
  /// - [browsing]：正在浏览的池（= 抽屉的 `_current`），决定高亮与副标题；
  /// - [playingLocalFile]：播放器里那一条是本机文件（= 抽屉的 `_playingLocalFile`）。
  XrCatalogNode build({
    required List<PlaybackQueue> queues,
    required PlaybackQueue browsing,
    required String currentItemId,
    required User? author,
    required bool playingLocalFile,
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) {
    if (_lastMediaType != mediaType) _localEpoch++;
    _lastMediaType = mediaType;
    _openers.clear();
    _nodeCacheKey.clear();
    for (final queue in queues) {
      _openers[queue.queueId] = () => queue;
    }
    return _Builder(
      catalog: this,
      queues: queues,
      current: browsing,
      currentItemId: currentItemId,
      author: author,
      playingLocalFile: playingLocalFile,
      mediaType: mediaType,
    ).build();
  }

  // ────────────────────────────────────────────── 缓存

  _Lazy<Object?> _cache(String key, Future<Object?> Function() load) {
    _loaders[key] = load;
    final existing = _caches[key];
    if (existing != null) return existing;
    final lazy = _Lazy<Object?>();
    _caches[key] = lazy;
    lazy.future = _run(key, lazy, load);
    return lazy;
  }

  Future<Object?> _run(
    String key,
    _Lazy<Object?> lazy,
    Future<Object?> Function() load,
  ) async {
    Object? value;
    try {
      value = await load();
    } catch (e) {
      LogUtils.e('拉取清单失败 $key', tag: _tag, error: e);
    }
    if (!identical(_caches[key], lazy)) return value;
    lazy
      ..value = value
      ..failed = value == null
      ..ready = true;
    onChanged();
    return value;
  }

  // ────────────────────────────────────────────── 取数（与抽屉逐字同口径）

  /// = 抽屉 `_fetchOwnPlaylists`。
  static Future<List<_Row>?> _fetchOwnPlaylists(String videoId) async {
    final result = await Get.find<PlayListService>().getLightPlaylists(
      videoId: videoId,
    );
    if (!result.isSuccess || result.data == null) return null;
    return [
      for (final p in result.data!)
        (id: p.id, title: p.title, count: p.numVideos),
    ];
  }

  /// = 抽屉 `_fetchPlaylistsOf`。
  static Future<List<_Row>?> _fetchPlaylistsOf(String userId) async {
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

  /// = 抽屉 `_fetchLocalFolders`。
  static Future<List<_Row>?> _fetchLocalFolders() async {
    if (!Get.isRegistered<FavoriteService>()) return const <_Row>[];
    final folders = await FavoriteService.to.getAllFolders();
    return [
      for (final f in folders)
        (id: f.id, title: f.title, count: f.itemCount ?? 0),
    ];
  }

  /// = 抽屉 `_fetchDownloadCategories`。
  static Future<List<_Row>?> _fetchDownloadCategories(
    PlaybackMediaType mediaType,
  ) async {
    if (!Get.isRegistered<DownloadService>()) return const <_Row>[];
    final t = slang.t;
    final service = DownloadService.to;
    final counts = await service.repository.getCompletedDownloadCounts(
      mediaType: mediaType.isGallery ? 'gallery' : 'video',
    );
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

  /// = 抽屉 `_fetchLocalSources`（内建「已下载」不进，理由同那边）。
  ///
  /// ⛔ 读库失败返回 `const []` 而**不是** null：失败的原因（库没开）是持续的，
  /// 返回 null 会在「失败 → onChanged 重推 → 再拉 → 再失败」里打转。
  Future<List<_Row>?> _fetchLocalSources(LocalMediaItemKind kind) async {
    try {
      final repository = _repository;
      return [
        for (final source in repository.getSources())
          if (!source.isBuiltIn)
            (
              id: source.id,
              title: source.displayName,
              count: repository.countItems(sourceId: source.id, kind: kind),
            ),
      ];
    } catch (e) {
      LogUtils.w('读取本机来源失败，本轮按「没有本机来源」处理: $e', _tag);
      return const <_Row>[];
    }
  }

  /// 「本机文件」第二张菜单要的几个数 + 常用目录（= 抽屉 `_pickLocalCategory`
  /// 与 `_pickLocalPinned` 开菜单前查的那些）。
  Future<_LocalCategories?> _fetchLocalCategories(
    LocalMediaItemKind kind,
  ) async {
    final isGallery = kind == LocalMediaItemKind.image;
    try {
      final repository = _repository;
      final allCount = repository.countItems(kind: kind);
      final favCount = isGallery
          ? 0
          : repository.countItems(kind: kind, favoritedOnly: true);
      final pinned = <_PinnedRow>[];
      for (final pin in repository.getPinnedFolders()) {
        final folder = repository.getFolder(
          sourceId: pin.sourceId,
          relPath: pin.relPath,
        );
        final path = folder?.folderPath;
        if (path == null || path.isEmpty) {
          // 查不到目录行的根那一层退化成「整个源」，同抽屉 `_pickLocalPinned`。
          if (pin.relPath.isNotEmpty) continue;
          if (repository.getSource(pin.sourceId) == null) continue;
          pinned.add((
            sourceId: pin.sourceId,
            path: null,
            name: pin.displayName,
            count: repository.countItems(sourceId: pin.sourceId, kind: kind),
          ));
          continue;
        }
        pinned.add((
          sourceId: pin.sourceId,
          path: path,
          name: pin.displayName,
          count: repository.countItems(
            sourceId: pin.sourceId,
            folderPath: path,
            kind: kind,
          ),
        ));
      }
      return (
        allCount: allCount,
        favCount: favCount,
        // ⛔ 在不在场、行尾写几，按**置顶了几条**算（= 抽屉 `_pickLocalCategory`），
        // 不按解析得出目录的那几条算——两边口径一分开，同一台机器上一边有一边没有。
        pinnedCount: repository.getPinnedFolders().length,
        pinned: pinned,
      );
    } catch (e) {
      LogUtils.w('读取本机栏目失败: $e', _tag);
      return null;
    }
  }

  /// = 抽屉 `_loadLocalLevel`（含懒扫描）。返回 null = 读库出错。
  Future<_LocalLevel?> _loadLocalLevel({
    required String sourceId,
    required String relPath,
    required LocalMediaItemKind kind,
  }) async {
    try {
      final repository = _repository;
      var folder = repository.getFolder(sourceId: sourceId, relPath: relPath);
      if (folder != null &&
          folder.probedAt == null &&
          Get.isRegistered<LocalMediaScanService>()) {
        final source = repository.getSource(sourceId);
        if (source != null) {
          try {
            await LocalMediaScanService.to.scanFolder(
              source: source,
              relPath: relPath,
            );
          } catch (e) {
            LogUtils.w('目录级扫描失败: $e', _tag);
          }
          folder = repository.getFolder(sourceId: sourceId, relPath: relPath);
        }
      }
      final children = repository.childFolders(
        sourceId: sourceId,
        parentRelPath: relPath,
        mediaKind: kind,
      );
      final path = folder?.folderPath;
      final flatSource =
          relPath.isEmpty &&
          children.isEmpty &&
          (folder == null || path == null || path.isEmpty);
      final hereCount = flatSource
          ? repository.countItems(sourceId: sourceId, kind: kind)
          : (path == null || path.isEmpty
                ? 0
                : repository.countItems(
                    sourceId: sourceId,
                    folderPath: path,
                    kind: kind,
                  ));
      return (
        folder: folder,
        children: children,
        hereCount: hereCount,
        flatSource: flatSource,
      );
    } catch (e) {
      LogUtils.w('读取本机目录失败: $e', _tag);
      return null;
    }
  }

  static LocalMediaItemKind _itemKind(PlaybackMediaType mediaType) =>
      mediaType.isGallery ? LocalMediaItemKind.image : LocalMediaItemKind.video;

  /// 「当前文件所在文件夹」那条的数据，按 (条目 id) 记一次，别每次重推都查库。
  ({String key, _FolderChoice? value})? _folderChoiceMemo;

  _FolderChoice? _currentFolderChoice(
    String currentItemId,
    LocalMediaItemKind kind,
  ) {
    final key = '$currentItemId|${kind.name}';
    final memo = _folderChoiceMemo;
    if (memo != null && memo.key == key) return memo.value;
    _FolderChoice? value;
    try {
      final repository = _repository;
      final item = repository.getItem(currentItemId);
      final path = item?.folderPath;
      if (item != null && path != null && path.isNotEmpty) {
        final counts = repository.folderCounts(item.sourceId, kind: kind);
        final here = counts.firstWhereOrNull((row) => row.folderPath == path);
        // 同抽屉 `_currentFolderChoice`：得比整个源小、又不止一条才值得摆。
        if (here != null && here.count >= 2 && counts.length >= 2) {
          value = (
            sourceId: item.sourceId,
            path: path,
            name: p.basename(path),
            count: here.count,
          );
        }
      }
    } catch (e) {
      LogUtils.w('取当前文件夹失败: $e', _tag);
    }
    _folderChoiceMemo = (key: key, value: value);
    return value;
  }
}

// ────────────────────────────────────────────────────────── 组装

const String _kLocalDirPrefix = 'local:dir:';

class _Builder {
  _Builder({
    required this.catalog,
    required this.queues,
    required this.current,
    required this.currentItemId,
    required this.author,
    required this.playingLocalFile,
    required this.mediaType,
  });

  final XrQueueCatalog catalog;
  final List<PlaybackQueue> queues;
  final PlaybackQueue current;
  final String currentItemId;
  final User? author;
  final bool playingLocalFile;
  final PlaybackMediaType mediaType;

  final slang.Translations t = slang.t;
  late final PlaybackQueueService service = PlaybackQueueService.to;
  late final User? self = Get.isRegistered<UserService>()
      ? Get.find<UserService>().currentUser.value
      : null;

  bool get isGallery => mediaType.isGallery;
  LocalMediaItemKind get itemKind => XrQueueCatalog._itemKind(mediaType);

  /// 稍后再看的筛选（= 抽屉 `_unwatchedOnly`）：看手上那个稍后再看池。
  bool get unwatchedOnly {
    for (final queue in queues) {
      if (queue is WatchLaterPlaybackQueue) return queue.unwatchedOnly;
    }
    return false;
  }

  PlaybackQueue? ofKind(PlaybackQueueKind kind) =>
      queues.firstWhereOrNull((q) => q.kind == kind);

  static String? countLabel(int? count) =>
      count == null ? null : CommonUtils.formatFriendlyNumber(count);

  _Lazy<Object?> cache(String key, Future<Object?> Function() load) =>
      catalog._cache(key, load);

  List<_Row>? rowsOf(_Lazy<Object?> lazy) =>
      lazy.ready && !lazy.failed ? lazy.value as List<_Row>? : null;

  /// 叶子：点了就换过去浏览这一池。
  XrCatalogNode leaf({
    required String id,
    required String title,
    required String queueId,
    required PlaybackQueue? Function() open,
    String? subtitle,
    String? trailing,
    String? icon,
    String? avatarUrl,
    bool enabled = true,
    bool selected = false,
    bool showCheck = true,
  }) {
    catalog._openers[queueId] = open;
    return XrCatalogNode.option(
      id: id,
      title: title,
      queueId: queueId,
      subtitle: subtitle,
      trailing: trailing,
      icon: icon,
      avatarUrl: avatarUrl,
      enabled: enabled,
      selected: selected,
      showCheck: showCheck,
    );
  }

  XrCatalogNode build() {
    final children = <XrCatalogNode>[
      ?_directEntry(
        id: 'source',
        kind: PlaybackQueueKind.source,
        title: t.playbackQueue.sourceTab,
        icon: 'source',
        requirePool: true,
        queueId: ofKind(PlaybackQueueKind.source)?.queueId,
        open: () => ofKind(PlaybackQueueKind.source),
      ),
      if (self != null)
        ?_directEntry(
          id: 'subscriptions',
          kind: PlaybackQueueKind.subscriptions,
          title: t.common.subscriptions,
          icon: 'subscriptions',
          queueId: PlaybackQueueService.subscriptionsQueueId(mediaType),
          open: () => service.openSubscriptions(mediaType: mediaType),
        ),
      ?_playlistEntry(_PlaylistGroup.mine),
      if (self != null)
        ?_directEntry(
          id: 'favorites',
          kind: PlaybackQueueKind.favorites,
          title: t.common.favorites,
          icon: 'favorite',
          queueId: PlaybackQueueService.favoritesQueueId(mediaType),
          open: () => isGallery
              ? service.openFavoriteGalleries()
              : service.openFavorites(),
        ),
      _localFoldersEntry(),
      _downloadsEntry(),
      ?_localLibraryEntry(),
      _watchLaterEntry(),
      if (author != null) ...[
        const XrCatalogNode.separator(),
        if (isGallery)
          ?_directEntry(
            id: 'authorGalleries',
            kind: PlaybackQueueKind.authorGalleries,
            title: t.playbackQueue.authorGalleries,
            subtitle: author!.name,
            avatarUrl: _avatarOf(author!),
            queueId: PlaybackQueueService.authorMediaQueueId(
              author!.id,
              mediaType: mediaType,
            ),
            open: () =>
                service.openAuthorGalleries(author!.id, title: author!.name),
          )
        else
          ?_directEntry(
            id: 'authorVideos',
            kind: PlaybackQueueKind.authorVideos,
            title: t.playbackQueue.authorVideos,
            subtitle: author!.name,
            avatarUrl: _avatarOf(author!),
            queueId: PlaybackQueueService.authorMediaQueueId(author!.id),
            open: () =>
                service.openAuthorVideos(author!.id, title: author!.name),
          ),
        ?_playlistEntry(_PlaylistGroup.author),
      ],
      if (_otherOwner != null) ...[
        const XrCatalogNode.separator(),
        ?_playlistEntry(_PlaylistGroup.other),
      ],
    ];
    return XrCatalogNode.branch(
      id: XrQueueCatalog.rootId,
      title: t.playbackQueue.upNext,
      children: children,
    );
  }

  static String _avatarOf(User user) => user.avatar?.avatarUrl ?? '';

  /// = 抽屉 `openVariant`：这一类里现在开着的是哪一支。
  String? openVariant(PlaybackQueueKind kind) {
    final queue = ofKind(kind);
    if (queue == null) return null;
    if (kind == PlaybackQueueKind.watchLater) {
      return unwatchedOnly ? t.watchLater.filterUnwatched : t.common.all;
    }
    final title = queue.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return kind == PlaybackQueueKind.downloads ? t.common.all : null;
  }

  /// = 抽屉 `directEntry`。
  XrCatalogNode? _directEntry({
    required String id,
    required PlaybackQueueKind kind,
    required String title,
    required String? queueId,
    required PlaybackQueue? Function() open,
    bool requirePool = false,
    String? icon,
    String? avatarUrl,
    String? subtitle,
  }) {
    final pool = ofKind(kind);
    if (requirePool && pool == null) return null;
    if (queueId == null) return null;
    final empty = pool != null && pool.isKnownEmpty;
    return leaf(
      id: id,
      title: title,
      // 已开着的那一池 id 可能与拼出来的不同（例如带筛选的来源），以手上的为准。
      queueId: pool?.queueId ?? queueId,
      open: pool != null ? () => pool : open,
      subtitle: empty ? t.playbackQueue.nothingHere : subtitle,
      icon: icon,
      avatarUrl: avatarUrl,
      enabled: !empty,
      selected: current.kind == kind,
      showCheck: false,
    );
  }

  /// = 抽屉 `branchEntry`。
  XrCatalogNode _branchEntry({
    required String id,
    required PlaybackQueueKind kind,
    required String title,
    required bool knownEmpty,
    required List<XrCatalogNode>? children,
    String? icon,
    bool loading = false,
  }) {
    return XrCatalogNode.branch(
      id: id,
      title: title,
      subtitle: knownEmpty ? t.playbackQueue.nothingHere : openVariant(kind),
      icon: icon,
      enabled: !knownEmpty,
      selected: current.kind == kind,
      showCheck: false,
      loading: loading,
      children: children,
    );
  }

  /// 清单类二级菜单的共同收尾：没到 → loading；失败 → 一行「点击重试」；
  /// 空 → 一行灰的「暂无内容」（抽屉那边是弹一句提示，面板上没有 toast，就把这句话
  /// 放进那一层里）。
  List<XrCatalogNode>? _feedChildren(
    String nodeId,
    String cacheKey,
    _Lazy<Object?> lazy,
    List<XrCatalogNode> Function(List<_Row> rows) rowsToNodes, {
    List<XrCatalogNode> pinned = const [],
  }) {
    catalog._nodeCacheKey[nodeId] = cacheKey;
    if (!lazy.ready) return pinned.isEmpty ? null : pinned;
    if (lazy.failed) {
      return [
        ...pinned,
        XrCatalogNode.retry(
          id: '$nodeId:retry',
          title: t.watchLater.playlistLoadFailed,
          expandNodeId: nodeId,
        ),
      ];
    }
    final rows = lazy.value as List<_Row>? ?? const <_Row>[];
    final nodes = rowsToNodes(rows);
    if (nodes.isEmpty && pinned.isEmpty) return [_nothingHere(nodeId)];
    return [...pinned, ...nodes];
  }

  XrCatalogNode _nothingHere(String parentId) => XrCatalogNode.option(
    id: '$parentId:empty',
    title: t.playbackQueue.nothingHere,
    enabled: false,
  );

  // ── 播放列表（= `_playlistSources` / `playlistEntry` / `_pickPlaylistFrom`）

  User? get _otherOwner {
    if (isGallery) return null;
    for (final queue in queues) {
      if (queue is! PlaylistPlaybackQueue) continue;
      final owner = queue.owner;
      if (owner == null) continue;
      if (owner.id == self?.id || owner.id == author?.id) continue;
      return owner;
    }
    return null;
  }

  PlaylistPlaybackQueue? get _openPlaylist =>
      queues.whereType<PlaylistPlaybackQueue>().firstOrNull;

  /// = 抽屉 `_openPlaylistGroup`。
  _PlaylistGroup? get _openPlaylistGroup {
    final queue = _openPlaylist;
    if (queue == null) return null;
    final owner = queue.owner;
    if (owner == null || owner.id == self?.id) return _PlaylistGroup.mine;
    if (owner.id == author?.id) return _PlaylistGroup.author;
    return _PlaylistGroup.other;
  }

  XrCatalogNode? _playlistEntry(_PlaylistGroup group) {
    // 图库没有播放列表；本机文件不拿本机 id 打 Iwara 接口（同 `_playlistSources`）。
    if (isGallery || playingLocalFile) return null;
    final User? owner = switch (group) {
      _PlaylistGroup.mine => self,
      _PlaylistGroup.author =>
        author != null && author!.id != self?.id ? author : null,
      _PlaylistGroup.other => _otherOwner,
    };
    final open = _openPlaylist;
    final bool openHere = open != null && _openPlaylistGroup == group;
    if (owner == null && !openHere) return null;

    final String title = switch (group) {
      _PlaylistGroup.mine => t.playbackQueue.myPlaylists,
      _PlaylistGroup.author => t.playbackQueue.authorPlaylists,
      _PlaylistGroup.other => t.playbackQueue.otherPlaylists,
    };
    final nodeId = 'playlists:${group.name}';

    _Lazy<Object?>? lazy;
    String? cacheKey;
    if (owner != null) {
      cacheKey = group == _PlaylistGroup.mine
          ? 'own:${owner.id}'
          : 'playlistsOf:${owner.id}';
      lazy = cache(
        cacheKey,
        group == _PlaylistGroup.mine
            ? () => XrQueueCatalog._fetchOwnPlaylists(currentItemId)
            : () => XrQueueCatalog._fetchPlaylistsOf(owner.id),
      );
    }
    final rows = lazy == null ? null : rowsOf(lazy);
    final knownEmpty = !openHere && rows != null && rows.isEmpty;

    // 「正在播放」置顶：正开着的那张不在清单里时（清单没回来 / 不在第一页）。
    final listed = {for (final row in rows ?? const <_Row>[]) row.id};
    final pinned = <XrCatalogNode>[];
    if (openHere && !listed.contains(open.playlistId)) {
      pinned
        ..add(
          XrCatalogNode.header(
            id: '$nodeId:now',
            title: t.playbackQueue.nowPlaying,
          ),
        )
        ..add(
          leaf(
            id: '$nodeId:${open.playlistId}',
            title: _playlistTitle(open),
            queueId: open.queueId,
            open: () => open,
            selected: current.queueId == open.queueId,
          ),
        );
    }

    List<XrCatalogNode> rowsToNodes(List<_Row> rows) => [
      if (pinned.isNotEmpty && rows.isNotEmpty)
        XrCatalogNode.header(id: '$nodeId:list', title: title),
      for (final row in rows)
        leaf(
          id: '$nodeId:${row.id}',
          title: row.title,
          trailing: countLabel(row.count),
          queueId: PlaybackQueueService.playlistQueueId(row.id),
          open: () =>
              service.openPlaylist(row.id, title: row.title, owner: owner),
          selected:
              current.queueId == PlaybackQueueService.playlistQueueId(row.id),
        ),
    ];

    final List<XrCatalogNode>? children = lazy == null
        ? pinned
        : _feedChildren(nodeId, cacheKey!, lazy, rowsToNodes, pinned: pinned);

    return XrCatalogNode.branch(
      id: nodeId,
      title: title,
      subtitle: knownEmpty
          ? t.playbackQueue.nothingHere
          : openHere
          ? _playlistTitle(open)
          : (group == _PlaylistGroup.mine ? null : owner?.name),
      icon: group == _PlaylistGroup.mine ? 'playlist' : null,
      avatarUrl: group == _PlaylistGroup.mine || owner == null
          ? null
          : _avatarOf(owner),
      enabled: !knownEmpty,
      selected: openHere && current.kind == PlaybackQueueKind.playlist,
      showCheck: false,
      loading: lazy != null && !lazy.ready,
      children: children,
    );
  }

  String _playlistTitle(PlaybackQueue queue) {
    final title = queue.title?.trim();
    return title == null || title.isEmpty ? t.common.playList : title;
  }

  // ── 收藏夹（= `_pickFromFeed` + `_localFolders`）

  XrCatalogNode _localFoldersEntry() {
    const nodeId = 'localFolders';
    const key = 'localFolders';
    final lazy = cache(key, XrQueueCatalog._fetchLocalFolders);
    final rows = rowsOf(lazy);
    return _branchEntry(
      id: nodeId,
      kind: PlaybackQueueKind.localFavorite,
      title: t.playbackQueue.favoriteFolders,
      knownEmpty: rows != null && rows.isEmpty,
      icon: 'folder',
      loading: !lazy.ready,
      children: _feedChildren(nodeId, key, lazy, (rows) {
        return [
          for (final row in rows)
            leaf(
              id: '$nodeId:${row.id}',
              title: row.title,
              // ⛔ 图库这一路不写条数：夹子里的数是所有类型加起来的，同抽屉。
              trailing: isGallery ? null : countLabel(row.count),
              queueId: PlaybackQueueService.localFavoriteQueueId(
                row.id,
                mediaType: mediaType,
              ),
              open: () => service.openLocalFavorite(
                row.id,
                title: row.title,
                mediaType: mediaType,
              ),
              selected:
                  current.queueId ==
                  PlaybackQueueService.localFavoriteQueueId(
                    row.id,
                    mediaType: mediaType,
                  ),
            ),
        ];
      }),
    );
  }

  // ── 已下载（= `_pickDownloadCategory`）

  XrCatalogNode _downloadsEntry() {
    const nodeId = 'downloads';
    final key = 'downloads:${mediaType.name}';
    final lazy = cache(
      key,
      () => XrQueueCatalog._fetchDownloadCategories(mediaType),
    );
    final rows = rowsOf(lazy);
    final String? currentFilter = current is DownloadsPlaybackQueue
        ? (current as DownloadsPlaybackQueue).categoryFilter
        : null;
    return _branchEntry(
      id: nodeId,
      kind: PlaybackQueueKind.downloads,
      title: t.playbackQueue.downloads,
      knownEmpty: rows != null && rows.every((row) => (row.count ?? 0) == 0),
      icon: 'download',
      loading: !lazy.ready,
      children: _feedChildren(nodeId, key, lazy, (rows) {
        return [
          for (final row in rows)
            leaf(
              id: '$nodeId:${row.id}',
              title: row.title,
              trailing: countLabel(row.count),
              queueId: PlaybackQueueService.downloadsQueueId(row.id, mediaType),
              open: () => service.openDownloads(
                categoryFilter: row.id,
                mediaType: mediaType,
                title: row.id == 'all' ? null : row.title,
              ),
              enabled: (row.count ?? 1) > 0,
              selected: row.id == currentFilter,
            ),
        ];
      }),
    );
  }

  // ── 稍后再看（= `_pickWatchLaterFilter`）

  XrCatalogNode _watchLaterEntry() {
    const nodeId = 'watchLater';
    final isCurrent = current.kind == PlaybackQueueKind.watchLater;
    // 只认「全部」那个池（= 抽屉 `_watchLaterKnownEmpty`）。
    final all = queues.firstWhereOrNull(
      (q) => q is WatchLaterPlaybackQueue && !q.unwatchedOnly,
    );
    return _branchEntry(
      id: nodeId,
      kind: PlaybackQueueKind.watchLater,
      title: t.watchLater.title,
      knownEmpty: all?.isKnownEmpty ?? false,
      icon: 'watchLater',
      children: [
        leaf(
          id: '$nodeId:all',
          title: t.watchLater.filterAll,
          queueId: PlaybackQueueService.watchLaterQueueId(
            unwatchedOnly: false,
            mediaType: mediaType,
          ),
          open: () => service.openWatchLater(
            unwatchedOnly: false,
            mediaType: mediaType,
          ),
          selected: isCurrent && !unwatchedOnly,
        ),
        leaf(
          id: '$nodeId:unwatched',
          title: t.watchLater.filterUnwatched,
          queueId: PlaybackQueueService.watchLaterQueueId(
            unwatchedOnly: true,
            mediaType: mediaType,
          ),
          open: () =>
              service.openWatchLater(unwatchedOnly: true, mediaType: mediaType),
          selected: isCurrent && unwatchedOnly,
        ),
      ],
    );
  }

  // ── 本机文件（= `_pickLocalCategory` / `_pickLocalPinned` / `_pickLocalSource`
  //    / `_pickLocalFolder`）

  LocalLibraryPlaybackQueue? get _openLocal =>
      current is LocalLibraryPlaybackQueue
      ? current as LocalLibraryPlaybackQueue
      : null;

  PlaybackQueue? Function() _openLocalLibrary({
    String? sourceId,
    String? folderPath,
    bool favoritedOnly = false,
    String? title,
  }) =>
      () => service.openLocalLibrary(
        sourceId: sourceId,
        folderPath: folderPath,
        sort: LocalMediaSort.nameAsc,
        mediaType: mediaType,
        favoritedOnly: favoritedOnly,
        title: title,
      );

  String _localQueueId({
    String? sourceId,
    String? folderPath,
    bool favoritedOnly = false,
  }) => PlaybackQueueService.localLibraryQueueId(
    sourceId: sourceId,
    folderPath: folderPath,
    sort: LocalMediaSort.nameAsc,
    mediaType: mediaType,
    favoritedOnly: favoritedOnly,
  );

  /// = 抽屉 `_isCurrentLocalCategory`：按形状比，不比排序。
  bool _isCurrentLocalCategory({bool favoritedOnly = false}) {
    final open = _openLocal;
    return open != null &&
        open.sourceId == null &&
        open.folderPath == null &&
        open.categoryId == null &&
        open.favoritedOnly == favoritedOnly;
  }

  XrCatalogNode? _localLibraryEntry() {
    const nodeId = 'localLibrary';
    final sourcesKey = 'localSources:${itemKind.name}';
    final sources = cache(
      sourcesKey,
      () => catalog._fetchLocalSources(itemKind),
    );
    final sourceRows = rowsOf(sources);
    final hasLocalSources = sourceRows != null && sourceRows.isNotEmpty;
    // 一个源都没加过时整条不出现；正在播本机文件时必须在场（同抽屉）。
    if (!hasLocalSources && !playingLocalFile) return null;

    final catKey = 'localCategories:${itemKind.name}';
    final categories = cache(
      catKey,
      () => catalog._fetchLocalCategories(itemKind),
    );
    catalog._nodeCacheKey[nodeId] = catKey;

    List<XrCatalogNode>? children;
    if (categories.ready) {
      final data = categories.value as _LocalCategories?;
      final allCount = data?.allCount ?? 0;
      final favCount = data?.favCount ?? 0;
      final pinned = data?.pinned ?? const <_PinnedRow>[];
      children = [
        _localSourcesNode(sources, sourcesKey),
        if ((data?.pinnedCount ?? 0) > 0)
          _localPinnedNode(pinned, data?.pinnedCount ?? 0),
        const XrCatalogNode.separator(),
        if (!isGallery)
          leaf(
            id: '$nodeId:fav',
            title: t.localMedia.tabFavoriteVideos,
            icon: 'star',
            trailing: countLabel(favCount),
            queueId: _localQueueId(favoritedOnly: true),
            open: _openLocalLibrary(
              favoritedOnly: true,
              title: t.localMedia.tabFavoriteVideos,
            ),
            enabled: favCount > 0,
            selected: _isCurrentLocalCategory(favoritedOnly: true),
          ),
        leaf(
          id: '$nodeId:all',
          title: isGallery
              ? t.localMedia.tabAllImages
              : t.localMedia.tabAllVideos,
          icon: isGallery ? 'gallery' : 'videos',
          trailing: countLabel(allCount),
          queueId: _localQueueId(),
          open: _openLocalLibrary(
            title: isGallery
                ? t.localMedia.tabAllImages
                : t.localMedia.tabAllVideos,
          ),
          enabled: allCount > 0,
          selected: _isCurrentLocalCategory(),
        ),
      ];
    }

    return _branchEntry(
      id: nodeId,
      kind: PlaybackQueueKind.localLibrary,
      title: t.playbackQueue.localFiles,
      knownEmpty:
          sourceRows != null &&
          sourceRows.every((row) => (row.count ?? 0) == 0),
      icon: 'devices',
      loading: !categories.ready,
      children: children,
    );
  }

  /// 「文件目录 ›」：挑一个来源（= `_pickLocalSource`）。
  XrCatalogNode _localSourcesNode(_Lazy<Object?> sources, String cacheKey) {
    const nodeId = 'localLibrary:folders';
    final open = _openLocal;
    final folder = open == null
        ? null
        : catalog._currentFolderChoice(currentItemId, itemKind);
    final children = _feedChildren(nodeId, cacheKey, sources, (rows) {
      // 一个来源都没有：抽屉那边 `_loadChoices` 直接说「暂无内容」、不开菜单，
      // 「当前文件所在文件夹」也就不会单独摆出来。
      if (rows.isEmpty) return const <XrCatalogNode>[];
      return [
        for (final row in rows)
          _localDirNode(
            sourceId: row.id,
            relPath: '',
            title: row.title,
            trailing: countLabel(row.count),
            enabled: (row.count ?? 1) > 0,
            selected: open != null && open.sourceId == row.id,
            showCheck: false,
          ),
        if (folder != null) ...[
          const XrCatalogNode.separator(),
          leaf(
            id: '$nodeId:current',
            title: folder.name,
            subtitle: t.playbackQueue.currentFolder,
            trailing: countLabel(folder.count),
            queueId: _localQueueId(
              sourceId: folder.sourceId,
              folderPath: folder.path,
            ),
            open: _openLocalLibrary(
              sourceId: folder.sourceId,
              folderPath: folder.path,
              title: folder.name,
            ),
            selected: open?.folderPath == folder.path,
          ),
        ],
      ];
    });
    return XrCatalogNode.branch(
      id: nodeId,
      title: t.localMedia.tabFolders,
      icon: 'folder',
      selected: open != null && open.folderPath != null,
      showCheck: false,
      loading: !sources.ready,
      children: children,
    );
  }

  /// 「常用目录 ›」（= `_pickLocalPinned`）。
  XrCatalogNode _localPinnedNode(List<_PinnedRow> rows, int pinnedCount) {
    const nodeId = 'localLibrary:pinned';
    final open = _openLocal;
    final openPath = open?.folderPath;
    return XrCatalogNode.branch(
      id: nodeId,
      title: t.localMedia.browse.pinnedSection,
      icon: 'pin',
      trailing: countLabel(pinnedCount),
      showCheck: false,
      children: [
        for (var i = 0; i < rows.length; i++)
          leaf(
            id: '$nodeId:$i',
            title: rows[i].name,
            icon: rows[i].path == null ? 'devices' : 'folder',
            trailing: countLabel(rows[i].count),
            queueId: _localQueueId(
              sourceId: rows[i].sourceId,
              folderPath: rows[i].path,
            ),
            open: _openLocalLibrary(
              sourceId: rows[i].sourceId,
              folderPath: rows[i].path,
              title: rows[i].name,
            ),
            enabled: rows[i].count > 0,
            selected: rows[i].path == null
                ? (open != null &&
                      open.sourceId == rows[i].sourceId &&
                      openPath == null)
                : (openPath != null && openPath == rows[i].path),
          ),
        if (rows.isEmpty) _nothingHere(nodeId),
      ],
    );
  }

  /// 某一层目录（= `_pickLocalFolder` 循环里的一张菜单）。没钻过 → 懒节点。
  XrCatalogNode _localDirNode({
    required String sourceId,
    required String relPath,
    required String title,
    String? trailing,
    bool enabled = true,
    bool selected = false,
    bool showCheck = true,
  }) {
    final nodeId = '$_kLocalDirPrefix$sourceId|$relPath';
    final cacheKey = (mediaType, nodeId);
    final level = catalog._localLevels[cacheKey];
    List<XrCatalogNode>? children;
    if (level == null && catalog._localLevelFailures.contains(cacheKey)) {
      children = [
        XrCatalogNode.retry(
          id: '$nodeId:retry',
          title: t.watchLater.queueLoadFailed,
          expandNodeId: nodeId,
        ),
      ];
    }
    if (level != null) {
      final open = _openLocal;
      final openPath = open?.folderPath;
      final herePath = level.folder?.folderPath;
      final canPlayHere =
          level.hereCount > 0 && (level.flatSource || herePath != null);
      children = [
        if (canPlayHere)
          leaf(
            id: '$nodeId:here',
            title: level.flatSource
                ? t.common.all
                : (isGallery
                      ? t.playbackQueue.browseThisFolder
                      : t.playbackQueue.playThisFolder),
            icon: isGallery ? 'gallery' : 'play',
            trailing: countLabel(level.hereCount),
            queueId: _localQueueId(
              sourceId: sourceId,
              folderPath: level.flatSource ? null : herePath,
            ),
            open: _openLocalLibrary(
              sourceId: sourceId,
              folderPath: level.flatSource ? null : herePath,
              title: level.folder?.name ?? title,
            ),
            selected: level.flatSource
                ? (open != null &&
                      open.sourceId == sourceId &&
                      openPath == null)
                : (openPath != null && openPath == herePath),
          ),
        if (canPlayHere && level.children.isNotEmpty)
          const XrCatalogNode.separator(),
        for (final child in level.children) _localChildNode(sourceId, child),
        if (!canPlayHere && level.children.isEmpty) _nothingHere(nodeId),
      ];
    }
    return XrCatalogNode.branch(
      id: nodeId,
      title: title,
      trailing: trailing,
      enabled: enabled,
      selected: selected,
      showCheck: showCheck,
      children: children,
    );
  }

  XrCatalogNode _localChildNode(String sourceId, LocalMediaFolder child) {
    final open = _openLocal;
    final openPath = open?.folderPath;
    final childPath = child.folderPath;
    final childCount = isGallery ? child.imageCount : child.videoCount;
    // = 抽屉 `_localFolderTrailing`：没探过的不写会骗人的 0。
    final trailing = child.probedAt != null && childCount > 0
        ? '$childCount'
        : null;
    final isOpen =
        childPath != null && openPath != null && openPath == childPath;
    final onPath =
        childPath != null &&
        openPath != null &&
        (openPath == childPath ||
            openPath.startsWith('$childPath${p.separator}'));
    // 没有下一层、而且这一层确实有东西 → 直接就是一池（同抽屉，不多开一层）。
    if (child.childFolderCount == 0 && childCount > 0 && childPath != null) {
      return leaf(
        id: '$_kLocalDirPrefix$sourceId|${child.relPath}:leaf',
        title: child.name,
        trailing: trailing,
        queueId: _localQueueId(sourceId: sourceId, folderPath: childPath),
        open: _openLocalLibrary(
          sourceId: sourceId,
          folderPath: childPath,
          title: child.name,
        ),
        selected: isOpen,
      );
    }
    return _localDirNode(
      sourceId: sourceId,
      relPath: child.relPath,
      title: child.name,
      trailing: trailing,
      selected: onPath,
      showCheck: isOpen,
    );
  }
}

enum _PlaylistGroup { mine, author, other }

typedef _Row = ({String id, String title, int? count});
typedef _PinnedRow = ({String sourceId, String? path, String name, int count});
typedef _FolderChoice = ({
  String sourceId,
  String path,
  String name,
  int count,
});
typedef _LocalCategories = ({
  int allCount,
  int favCount,
  int pinnedCount,
  List<_PinnedRow> pinned,
});
typedef _LocalLevel = ({
  LocalMediaFolder? folder,
  List<LocalMediaFolder> children,
  int hereCount,
  bool flatSource,
});

class _Lazy<T> {
  bool ready = false;
  bool failed = false;
  T? value;
  late Future<T?> future;
}

/// 选择器里的一个节点（= 抽屉玻璃菜单里的一行 / 一张子菜单）。
///
/// - `option`：一行。带 [queueId] 的是叶子（点了浏览那一池）；带 [children] 或
///   [lazy] 的是分支（点了进下一层，行尾一枚 `›`）；两样都没有就是一行说明文字
///   （「暂无内容」）。
/// - `separator` / `header`：分隔线与小节标题，与玻璃菜单同义。
/// - `retry`：清单拉失败，点了请 Dart 重拉 [expandNodeId]。
class XrCatalogNode {
  const XrCatalogNode._({
    required this.type,
    this.id = '',
    this.title = '',
    this.subtitle,
    this.trailing,
    this.icon,
    this.avatarUrl,
    this.queueId,
    this.children,
    this.branch = false,
    this.enabled = true,
    this.selected = false,
    this.showCheck = true,
    this.loading = false,
    this.expandNodeId,
  });

  const XrCatalogNode.option({
    required String id,
    required String title,
    String? queueId,
    String? subtitle,
    String? trailing,
    String? icon,
    String? avatarUrl,
    bool enabled = true,
    bool selected = false,
    bool showCheck = true,
  }) : this._(
         type: 'option',
         id: id,
         title: title,
         queueId: queueId,
         subtitle: subtitle,
         trailing: trailing,
         icon: icon,
         avatarUrl: avatarUrl,
         enabled: enabled,
         selected: selected,
         showCheck: showCheck,
       );

  /// [children] 为 null = 还没有数据，钻进去时请 Dart `expand`。
  const XrCatalogNode.branch({
    required String id,
    required String title,
    required List<XrCatalogNode>? children,
    String? subtitle,
    String? trailing,
    String? icon,
    String? avatarUrl,
    bool enabled = true,
    bool selected = false,
    bool showCheck = false,
    bool loading = false,
  }) : this._(
         type: 'option',
         id: id,
         title: title,
         children: children,
         branch: true,
         subtitle: subtitle,
         trailing: trailing,
         icon: icon,
         avatarUrl: avatarUrl,
         enabled: enabled,
         selected: selected,
         showCheck: showCheck,
         loading: loading,
       );

  const XrCatalogNode.separator() : this._(type: 'separator');

  const XrCatalogNode.header({required String id, required String title})
    : this._(type: 'header', id: id, title: title);

  const XrCatalogNode.retry({
    required String id,
    required String title,
    required String expandNodeId,
  }) : this._(type: 'retry', id: id, title: title, expandNodeId: expandNodeId);

  final String type;
  final String id;
  final String title;
  final String? subtitle;

  /// 行尾文字（已压短的计数）。分支的 `›` 由面板自己画，不在这里。
  final String? trailing;

  /// 图标键（面板侧映射成 UI Set 的图标）：source / subscriptions / playlist /
  /// favorite / folder / download / devices / watchLater / star / videos /
  /// gallery / play / pin。
  final String? icon;

  /// 头像地址（作者 / 他人那几条）；空串 = 有头像位但没有地址。
  final String? avatarUrl;
  final String? queueId;
  final List<XrCatalogNode>? children;
  final bool branch;
  final bool enabled;
  final bool selected;

  /// 选中时要不要打勾。一级菜单与「里面某一支被选中」的分支只做字体高亮。
  final bool showCheck;

  /// 这一支的清单还在拉。
  final bool loading;
  final String? expandNodeId;

  Map<String, dynamic> toChannelMap() => {
    'type': type,
    'id': id,
    'title': title,
    'subtitle': subtitle ?? '',
    'trailing': trailing ?? '',
    'icon': icon ?? '',
    'avatarUrl': avatarUrl,
    'queueId': queueId ?? '',
    'branch': branch,
    'lazy': branch && children == null,
    'enabled': enabled,
    'selected': selected,
    'showCheck': showCheck,
    'loading': loading,
    'expandNodeId': expandNodeId ?? '',
    'children': children?.map((c) => c.toChannelMap()).toList() ?? const [],
  };
}
