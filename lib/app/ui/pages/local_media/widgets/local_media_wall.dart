import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
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
    this.excludeBuiltInSource = false,
    required this.order,
    required this.queueTitle,
    required this.headerExtent,
  }) : assert(
         excludeBuiltInSource == (sourceId == null && !favoritedOnly),
         '墙的取数口径与 LocalLibraryPlaybackQueue.fetchPage 里那一行是同一条规则，'
         '不能各写各的——池是照着 sourceId/favoritedOnly 自己推的（见 [_openItem]）',
       );

  final LocalMediaItemKind kind;
  final bool favoritedOnly;

  /// 只看这一个源。null = 不限源。「下载完成视频」那一栏传的是
  /// [kDownloadsSourceId]。
  final String? sourceId;

  /// 不限源时，把内建的「已下载」排除在外。
  ///
  /// ⛔ 「所有视频 / 所有图片」必须开着它：「下载完成视频」自己是一栏，两边都列
  /// 就是同一批文件在这一页里出现两次。精选那一栏则必须关着——精选是用户跨源
  /// 挑出来的一小撮，下载来的片子照样能被精选，剔掉等于让星号凭空失效。
  final bool excludeBuiltInSource;

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

class _LocalMediaWallState extends State<LocalMediaWall> {
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
        oldWidget.excludeBuiltInSource != widget.excludeBuiltInSource ||
        oldWidget.favoritedOnly != widget.favoritedOnly) {
      _reloadFromDb();
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

  void _reloadFromDb() {
    if (!mounted) return;
    _generation++;
    setState(() {
      _items.clear();
      _offset = 0;
      _exhausted = false;
      _loading = false;
      _loadMore();
    });
  }

  void _loadMore() {
    if (_loading || _exhausted) return;
    _loading = true;

    try {
      final page = _repo.queryItems(
        kind: widget.kind,
        sourceId: widget.sourceId,
        excludeBuiltInSource: widget.excludeBuiltInSource,
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
    // ⛔ 这一趟会跨很多帧（每 20 条让一帧）。期间 [_reloadFromDb] 可能已经把
    // `_items`/`_offset` 整个重建了——那时旧回调再去 `removeWhere` 并扣
    // `_offset`，扣的是**新结果集**的口径：被剔的条目确实 missing，不会删错
    // 东西，但 offset 的补偿对不上，下一页会跳过几条。
    final generation = _generation;
    final confirmedGone = <String>[];
    // 目录可达性按目录缓存，一页里同目录的条目很多，别对同一个目录反复 stat。
    final directoryReachable = <String, bool>{};

    for (var i = 0; i < page.length; i++) {
      final item = page[i];
      // MediaStore 句柄没有真实路径，不能按路径判，跳过。
      if (item.path.startsWith('content://')) continue;
      if (File(item.path).existsSync()) continue;

      final directory = p.dirname(item.path);
      final reachable = directoryReachable.putIfAbsent(
        directory,
        () => Directory(directory).existsSync(),
      );
      if (reachable) confirmedGone.add(item.id);

      // 每 20 条让出一帧，别把同步 IO 堆成一次长卡顿
      if (i % 20 == 19) {
        await Future<void>.delayed(Duration.zero);
        if (!mounted || generation != _generation) return;
      }
    }

    if (confirmedGone.isEmpty || !mounted) return;
    // 落库照做（那几条确实没了，写库对哪一代都成立），只是不再动这一代的列表。
    _repo.markItemsMissing(confirmedGone);
    if (generation != _generation) return;

    final goneSet = confirmedGone.toSet();
    setState(() {
      final before = _items.length;
      _items.removeWhere((item) => goneSet.contains(item.id));
      // ⛔ `_offset` 必须跟着退。那几行的 missing 已经置 1，`queryItems` 的
      // `missing = 0` 过滤让**结果集整体缩短了**同样的条数；offset 还停在原处的话，
      // 下一页会从新结果集的更后面取，中间那几条永远不出现。
      _offset -= before - _items.length;
      if (_offset < 0) _offset = 0;
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
      // `excludeBuiltInSource` 不用传——池按 `sourceId == null && !favoritedOnly`
      // 自己推，构造函数上那条 assert 守着这两边同真同假。
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
      final paths = _items.map((e) => e.path).toList();
      final index = paths.indexOf(item.path);
      final initialIndex = index >= 0 ? index : 0;

      if (paths.isEmpty) {
        showAppToast(slang.t.localMedia.fileMissing, type: AppToastType.error);
        return;
      }

      // ⛔⭐ 这里必须**裸拼** `'file://$path'`，不许换成 `Uri.file(path)`。
      //
      // 看着像个待修的 bug（文件名里的 `#`/`?` 在真 URI 里会被当分隔符），实际不是：
      // 消费方 `my_gallery_photo_view_wrapper.dart:1766` 拿到的是
      // `imageUrl.replaceFirst('file://', '')` ——**纯字符串剥前缀，从不解析 URI**。
      // 所以裸拼进去什么、剥出来就是什么，`#` 一路安然无恙。
      //
      // 换成 `Uri.file()` 反而当场坏掉：它会把 `#` 正确编码成 `%23`，而剥前缀那头
      // 不做解码，`%23` 就原样进了文件系统调用。真机实证（2026-09-11）：
      //   PathNotFoundException: Cannot retrieve length of file,
      //   path = '/storage/emulated/0/Movies/ClaudeProbe/tag%231_test.png'
      //
      // 要改只能连**下游一起**改（把所有 `replaceFirst('file://','')` 换成
      // `Uri.parse(url).toFilePath()`）——那是全站图库的事，不是这一页能单方面决定的。
      final imageItems = paths
          .map(
            (path) => ImageItem(
              url: 'file://$path',
              data: ImageItemData(
                id: path,
                url: 'file://$path',
                originalUrl: 'file://$path',
              ),
            ),
          )
          .toList();

      pushPhotoViewWrapperOverlay(
        context: context,
        imageItems: imageItems,
        initialIndex: initialIndex,
        menuItemsBuilder: (context, item) => const [],
        enableMenu: false,
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
        if (mounted) {
          setState(() {
            _items.removeWhere((e) => e.id == deletedItem.id);
          });
        }
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
