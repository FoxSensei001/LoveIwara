import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_image_viewer.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_menu.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_waterfall_grid.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 本机文件聚合列表（精选视频 / 所有视频 / 所有图片 / 下载完成视频）。
///
/// ⛔ 这几张墙的取数口径必须与「接着看」里同名的那几个池**逐字一致**（见
/// `LocalLibraryPlaybackQueue.fetchPage`）：池的顺序就是"接下来播什么"，墙里
/// 有而池里没有的东西会让用户点第 3 条、下一条跳过好几个。改这里之前先去看
/// 那一段。
class LocalMediaWall extends StatefulWidget {
  const LocalMediaWall({
    super.key,
    required this.kind,
    this.favoritedOnly = false,
    this.sourceId,
    required this.order,
    required this.queueTitle,
    required this.headerExtent,
  });

  final LocalMediaItemKind kind;
  final bool favoritedOnly;

  /// 只看这一个源。null = **不限源，内建的「已下载」也算在内**。
  /// 「下载完成视频」那一栏传的是 [kDownloadsSourceId]。
  ///
  /// # ⛔ 别再给「所有视频 / 所有图片」加回「排除已下载」
  ///
  /// 加过（`excludeBuiltInSource`），2026-09-11 用户报「割裂」后整只删掉了。当时
  /// 的理由是"「下载完成视频」自己是一栏，两边都列就是同一批文件出现两次"——那条
  /// 理由站不住：
  ///
  /// 1. 栏目就叫**所有**。一个在这台机器上、扫进了库的视频不在「所有视频」里，
  ///    用户第一反应是"没扫到"，然后去重新扫描——而扫描永远修不好它。
  /// 2. 「全集 + 子集」本来就该重复。「精选视频」一直就和「所有视频」重着，
  ///    没有人觉得那是 bug；「下载完成视频」是同一种关系。
  ///
  /// 排除口径没了以后，仓库那三个查询（`queryItems` / `itemPathsPage` /
  /// `countItems`）也不再有这个参数——不限源就是真的不限源，没有第二种解释。
  final String? sourceId;

  final LocalMediaOrder order;

  /// 这一栏建出来的播放池叫什么（「接着看」胶囊上显示的就是它）。
  ///
  /// ⛔ 必填：三张视频墙建出来的是**三个不同的池**（精选 / 所有 / 下载完成），
  /// 名字缺了的话抽屉上三条都写「本机文件」，用户分不清自己在哪一池里。
  final String queueTitle;

  final double headerExtent;

  @override
  State<LocalMediaWall> createState() => _LocalMediaWallState();
}

class _LocalMediaWallState extends State<LocalMediaWall>
    with AutomaticKeepAliveClientMixin {
  /// 切 Tab 时保活：用户从「所有视频」滚到第 300 条、切去「常用目录」看一眼再
  /// 回来，不该被弹回顶部重拉。
  ///
  /// ⛔ 保活的前提是后台那几面墙**不会被无关信号反复重拉**：目录行变化走
  /// `folderRevision`（墙不听）、墙自己剔除失效条目不发 `changeRevision`（见
  /// [_pruneMissing]）、重载不清空列表（见 [_reloadFromDb]）。这几条任何一条
  /// 退回去，保活就变成「看不见的几面墙在后台一遍遍整页重查」。
  @override
  bool get wantKeepAlive => true;

  final LocalMediaRepository _repo = LocalMediaRepository();
  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 120;

  final List<LocalMediaItem> _items = <LocalMediaItem>[];
  int _offset = 0;
  bool _loading = false;
  bool _exhausted = false;
  Worker? _repoWorker;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
    _repoWorker = debounce<int>(
      LocalMediaRepository.changeRevision,
      (_) => _reloadFromDb(),
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant LocalMediaWall oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order ||
        oldWidget.kind != widget.kind ||
        oldWidget.sourceId != widget.sourceId ||
        oldWidget.favoritedOnly != widget.favoritedOnly) {
      // 查询口径换了（排序 / 筛选），旧的已加载条数没有意义，从第一页重来。
      _reloadFromDb(keepLoaded: false);
    }
  }

  @override
  void dispose() {
    _repoWorker?.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 每次 [_reloadFromDb] 自增。在途的 [_pruneMissing] 靠它判断自己那一页
  /// 说的还是不是现在这张墙。
  int _generation = 0;

  /// 按当前口径从库里重读。
  ///
  /// # ⛔ [keepLoaded] 为真时不许先清空
  ///
  /// 原来是 `_items.clear()` 再只拉第 0 页：用户滚到第 300 条时来一次
  /// `changeRevision`（扫描落批、下载同步），列表当场缩回 120 条，滚动长度塌掉、
  /// 位置被夹回去——看起来就是「自己弹回顶部」。
  ///
  /// 现在一次拉回**已加载的条数**（至少一页），在同一个 setState 里整只换掉，
  /// 滚动长度与位置都不动。sqlite3 是同步调用，这一下的代价是一次稍大的查询，
  /// 不是等待。
  void _reloadFromDb({bool keepLoaded = true}) {
    if (!mounted) return;
    _generation++;
    final limit = keepLoaded ? math.max(_pageSize, _items.length) : _pageSize;
    final List<LocalMediaItem> page;
    try {
      page = _repo.queryItems(
        kind: widget.kind,
        sourceId: widget.sourceId,
        order: widget.order,
        favoritedOnly: widget.favoritedOnly,
        offset: 0,
        limit: limit,
      );
    } catch (e, s) {
      LogUtils.e('本机文件墙重载失败', tag: 'LocalMediaWall', error: e, stackTrace: s);
      return;
    }
    setState(() {
      _items
        ..clear()
        ..addAll(page);
      _offset = page.length;
      _exhausted = page.length < limit;
      _loading = false;
    });
    if (page.isNotEmpty) unawaited(_pruneMissing(page));
  }

  void _loadMore() {
    if (_loading || _exhausted) return;
    _loading = true;

    try {
      final page = _repo.queryItems(
        kind: widget.kind,
        sourceId: widget.sourceId,
        order: widget.order,
        favoritedOnly: widget.favoritedOnly,
        offset: _offset,
        limit: _pageSize,
      );

      _items.addAll(page);
      _offset += page.length;
      if (page.length < _pageSize) {
        _exhausted = true;
      }

      if (mounted) {
        setState(() {});
      }

      // 后台异步校验失效，不阻塞首屏渲染
      if (page.isNotEmpty) {
        unawaited(_pruneMissing(page));
      }
    } finally {
      _loading = false;
    }
  }

  /// 在后台异步检验已拉出条目的物理存在性，并即时剔除与标记失效条目。
  ///
  /// ⛔ 必须使用 File.existsSync()，绝对不使用 statSync()。
  ///
  /// # ⛔ 「文件不在」和「整个卷不在」是两回事，落库前必须分开
  ///
  /// `existsSync()` 在外置存储没挂上、权限被回收（安卓升级后 MANAGE_EXTERNAL_STORAGE
  /// 被撤、Quest 上尤其频繁）时对**每一条**都返回 false——EACCES 不抛异常，直接
  /// 返回 false。不分辨的话，用户打开「所有视频」往下滚三屏就把 360 条全标成
  /// missing，库看起来空了，而唯一的恢复路径是对每个源跑一次全量扫描，用户根本
  /// 不知道要这么做。
  ///
  /// [LocalMediaRepository.markMissingExcept] 的类注释早把这条纪律写死了
  /// （「外置存储没挂上、目录临时不可读时，missing 是假警报」），那边靠「扫描确实
  /// 跑完才收敛」兜住；这条 UI 路径是「翻到哪页就地落库」，绕开了它，得自己兜。
  ///
  /// 判据：文件不在、**但它所在的目录还在**，才算真没了。目录也读不到就只当这一页
  /// 没看见，不写库——下次进来自然会重试。
  Future<void> _pruneMissing(List<LocalMediaItem> page) async {
    // ⛔ 后台那一趟期间 [_reloadFromDb] 可能已经把 `_items`/`_offset` 整个重建了
    // ——那时旧结果再去 `removeWhere` 并扣 `_offset`，扣的是**新结果集**的口径：
    // 被剔的条目确实 missing，不会删错东西，但 offset 的补偿对不上，下一页会跳过
    // 几条。所以带着代号去、带着代号回。
    final generation = _generation;
    final candidates = <(String, String)>[
      for (final item in page)
        // MediaStore 句柄没有真实路径，不能按路径判，跳过。
        if (!item.path.startsWith('content://')) (item.id, item.path),
    ];
    if (candidates.isEmpty) return;

    // ⛔ stat 挪到后台 isolate：一页 120 条（重载时可能是上千条）逐个
    // `existsSync` 摆在主 isolate 上，外置存储慢的时候就是一次看得见的卡顿。
    final List<String> confirmedGone;
    try {
      confirmedGone = await compute(_findGoneLocalItems, candidates);
    } catch (e) {
      LogUtils.w('本机文件墙失效校验失败: $e', 'LocalMediaWall');
      return;
    }

    if (confirmedGone.isEmpty || !mounted) return;
    // 落库照做（那几条确实没了，写库对哪一代都成立），只是不再动这一代的列表。
    //
    // ⛔ `notify: false`：这面墙自己已经就地剔掉了，再发 `changeRevision` 就是
    // 让自己（和另外几面保活着的墙）整墙重拉一遍——剔一条、重拉、再剔下一页、
    // 再重拉，没完没了。
    _repo.markItemsMissing(confirmedGone, notify: false);
    if (generation != _generation) return;

    final goneSet = confirmedGone.toSet();
    setState(() {
      final before = _items.length;
      _items.removeWhere((item) => goneSet.contains(item.id));
      // ⛔ `_offset` 必须跟着退。那几行的 missing 已经置 1，`queryItems` 的
      // `missing = 0` 过滤让**结果集整体缩短了**同样的条数；offset 还停在原处的话，
      // 下一页会从新结果集的更后面取，中间那几条永远不出现。
      _offset = math.max(0, _offset - (before - _items.length));
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600 &&
        !_loading &&
        !_exhausted) {
      _loadMore();
    }
  }

  Future<void> _openItem(LocalMediaItem item) async {
    if (item.kind == LocalMediaItemKind.video) {
      if (!item.isPlayableNow) {
        showAppToast(slang.t.localMedia.fileMissing, type: AppToastType.error);
        return;
      }
      // 按**这一栏自己的查询**建池，让播放器右侧的「接着看」一开就落在这一栏上、
      // 底栏那枚「下一个」给的也是墙上紧挨着的下一格。
      //
      // ⛔ 参数必须与 [_loadMore] 里那次 `queryItems` 同源（排序尤其）：池的顺序
      // 就是"接下来播什么"，两边不一致时用户点第 3 条，下一条是个毫不相干的东西。
      PlaybackQueueRef? queueRef;
      try {
        final queue = PlaybackQueueService.to.openLocalLibrary(
          sourceId: widget.sourceId,
          order: widget.order,
          favoritedOnly: widget.favoritedOnly,
          title: widget.queueTitle,
        );
        queueRef = PlaybackQueueRef(
          queueId: queue.queueId,
          currentItemId: item.id,
        );
      } catch (e) {
        // 建池失败（读库出错、服务还没起来）不该拦住播放：照旧只带播放目标过去，
        // 无非是这一次没有「下一个」。同 `local_folder_browse_page._openVideo`。
        LogUtils.e('本机文件墙建播放池失败', tag: 'LocalMediaWall', error: e);
      }

      NaviService.navigateToLocalVideoPlayerPage(
        localPath: item.resolvePlaybackTarget(),
        localLibraryItemId: item.id,
        playbackQueueRef: queueRef,
      );
    } else {
      openLocalImageViewer(
        context,
        _items.map((e) => e.path).toList(),
        item.path,
      );
    }
  }

  Future<void> _showItemMenu(
    BuildContext anchorContext,
    LocalMediaItem item,
  ) async {
    await showLocalMediaItemMenu(
      anchorContext: anchorContext,
      item: item,
      onChanged: () {
        if (!mounted) return;
        // ⛔ 「精选」在这几页里是两种完全不同的事，不能一律整墙重载：
        // - 「精选视频」页：取消精选＝这一条要从列表里消失，是集合变化，得重拉。
        // - 「所有视频 / 所有图片」页：只是那一行的角标变了，重拉会把用户的滚动
        //   位置整个丢掉——为一个角标付这个代价荒谬。就地把那一行换成库里的新版本。
        if (widget.favoritedOnly) {
          _reloadFromDb();
          return;
        }
        final index = _items.indexWhere((e) => e.id == item.id);
        if (index < 0) return;
        final latest = _repo.getItem(item.id);
        if (latest == null) return;
        setState(() => _items[index] = latest);
      },
      onDeleted: (deletedItem) {
        if (!mounted) return;
        setState(() {
          final before = _items.length;
          _items.removeWhere((e) => e.id == deletedItem.id);
          // 同 [_pruneMissing]：结果集缩短了，游标跟着退，否则下一页漏条。
          _offset = math.max(0, _offset - (before - _items.length));
        });
      },
    );
  }

  String get _emptyText {
    final b = slang.t.localMedia.browse;
    if (widget.sourceId == kDownloadsSourceId) {
      return b.emptyDownloadedVideos;
    }
    if (widget.favoritedOnly) {
      return b.emptyFavorites;
    }
    if (widget.kind == LocalMediaItemKind.video) {
      return b.emptyAllVideos;
    }
    return b.emptyAllImages;
  }

  IconData get _emptyIcon {
    if (widget.sourceId == kDownloadsSourceId) {
      return Icons.download_done_outlined;
    }
    if (widget.favoritedOnly) {
      return Icons.star_outline;
    }
    if (widget.kind == LocalMediaItemKind.video) {
      return Icons.video_library_outlined;
    }
    return Icons.photo_library_outlined;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 32;
        final crossAxisCount = MediaLayoutUtils.calculateCrossAxisCount(
          availableWidth,
        );
        final metrics = LocalGridMetrics(
          crossAxisCount: crossAxisCount,
          cellWidth: MediaLayoutUtils.calculateCardWidth(availableWidth),
          spacing: MediaLayoutUtils.crossAxisSpacing,
        );

        return RefreshIndicator(
          displacement: widget.headerExtent,
          onRefresh: () async => _reloadFromDb(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: widget.headerExtent + 12),
              ),
              // ⛔ 判据只能是 `_items.isEmpty`，别再往里加 `!_loading`：
              // [_loadMore] 全程同步（sqlite3 是同步调用），`finally` 在同一个
              // 微任务里就把 `_loading` 复位了，外面**永远**观察不到它为 true。
              // 写成 `_items.isEmpty && !_loading` 会让人以为这里挡住了加载中的
              // 闪烁，其实那个条件恒等于前一半，纯属误导。
              if (_items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _emptyIcon,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _emptyText,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: MediaWaterfallSliver(
                    crossAxisCount: metrics.crossAxisCount,
                    itemCount: _items.length,
                    itemBuilder: (context, index, itemWidth) {
                      final item = _items[index];
                      return LocalMediaItemCard(
                        item: item,
                        width: itemWidth,
                        onOpen: () => _openItem(item),
                        onMenu: (anchorContext) =>
                            _showItemMenu(anchorContext, item),
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// [_LocalMediaWallState._pruneMissing] 的后台那一半：返回确认已经消失的条目 id。
///
/// ⛔ 必须使用 `File.existsSync()`，绝对不使用 `statSync()`（后者失败不抛异常、
/// 返回 `type = notFound`、`size = -1` 的哨兵值）。
///
/// ⛔ 顶层函数、只碰参数：跑在另一个 isolate 上。
///
/// 判据（理由见 [_LocalMediaWallState._pruneMissing] 的文档）：文件不在、**但它
/// 所在的目录还在**，才算真没了。目录也读不到就只当没看见——外置存储没挂上、
/// 权限被回收时 `existsSync` 对每一条都返回 false，不分辨就会把整库标成 missing。
List<String> _findGoneLocalItems(List<(String, String)> candidates) {
  final gone = <String>[];
  // 目录可达性按目录缓存，一页里同目录的条目很多，别对同一个目录反复 stat。
  final directoryReachable = <String, bool>{};
  for (final (id, path) in candidates) {
    if (File(path).existsSync()) continue;
    final directory = p.dirname(path);
    final reachable = directoryReachable.putIfAbsent(
      directory,
      () => Directory(directory).existsSync(),
    );
    if (reachable) gone.add(id);
  }
  return gone;
}
