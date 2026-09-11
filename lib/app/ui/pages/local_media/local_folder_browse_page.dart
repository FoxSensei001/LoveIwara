import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/pages/local_media/local_folder_route.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/downloaded_gallery_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_menu.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_menu.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_waterfall_grid.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本地媒体库的目录浏览页。
///
/// # 地址口径
///
/// 这一页的地址口径是 `(sourceId, relPath)`，见 [LocalFolderRoute]。
/// 目录在媒体库树结构中由源 ID 与相对路径唯一确定，相对路径通过 query 参数传递，
/// 规避路径中的 `/` 干扰路由段匹配。
///
/// # 退化分支 (`_folder == null`)
///
/// 当根据 `(sourceId, relPath)` 查不到对应目录时（例如「已下载」和「设备视频」这两种
/// 来源没有物理目录树：前者下载路径不固定、没有稳定根路径，后者是系统的媒体库索引而非
/// 真实文件系统），页面退化成「整个来源的扁平列表」展示。此时子目录列表为空，条目查询
/// 不传 `folderPath`，标题直接取该来源的名称。
///
/// # 为什么不接项目的传统分页契约
///
/// 项目通用的分页流通常基于 `ExtendedLoadingMoreBase` 并绑定全量页码，但在文件管理器
/// 语义中传统翻页交互并不贴切；且单个物理目录内的文件数量天然有界，因此这里采用轻量的
/// 双段顺序游标增量加载（先翻完视频再翻图片）。
class LocalFolderBrowsePage extends StatefulWidget {
  const LocalFolderBrowsePage({
    super.key,
    required this.sourceId,
    this.relPath = '',
  });

  final String sourceId;
  final String relPath;

  @override
  State<LocalFolderBrowsePage> createState() => _LocalFolderBrowsePageState();
}

class _LocalFolderBrowsePageState extends State<LocalFolderBrowsePage> {
  final LocalMediaRepository _repo = LocalMediaRepository();
  final ScrollController _scrollController = ScrollController();

  LocalMediaSource? _source;
  LocalMediaFolder? _folder;
  List<LocalMediaFolder> _breadcrumb = const <LocalMediaFolder>[];
  List<LocalMediaFolder> _children = const <LocalMediaFolder>[];
  bool _isPinned = false;

  List<DownloadedGalleryRow> _galleries = const <DownloadedGalleryRow>[];
  int _galleryGeneration = 0;

  bool get _showsDownloadedGalleries =>
      widget.sourceId == kDownloadsSourceId && widget.relPath.isEmpty;

  /// 已置顶目录的 `sourceId\u0000relPath` 集合，[_loadInitialData] 与每次
  /// 置顶/取消置顶后重算一次。
  ///
  /// ⛔ 不要在 itemBuilder 里调 `isPinned()`：那是一次真的 sqlite 查询，而
  /// sqlite3 在主 isolate 上是同步的——五十个子目录卡在滚动中反复 build，
  /// 就是每帧几十次同步查询，直接卡在光栅线程前面。
  Set<String> _pinnedKeys = const <String>{};

  static String _pinKey(String sourceId, String relPath) =>
      '$sourceId\u0000$relPath';

  void _reloadPinnedKeys() {
    _pinnedKeys = <String>{
      for (final pinned in _repo.getPinnedFolders())
        _pinKey(pinned.sourceId, pinned.relPath),
    };
    _isPinned = _pinnedKeys.contains(_pinKey(widget.sourceId, widget.relPath));
  }

  // ── 顺序游标分页 ──────────────────────────────────────────────────────────
  //
  // 加载游标：先把视频翻完，再翻图片。展示顺序也是视频在上、图片在下，
  // 所以「加载到哪儿」与「画到哪儿」是同一条线，不需要两套独立的分页状态。
  LocalMediaItemKind _cursorKind = LocalMediaItemKind.video;
  int _cursorOffset = 0;
  bool _exhausted = false;
  bool _loading = false;
  final List<LocalMediaItem> _videos = <LocalMediaItem>[];
  final List<LocalMediaItem> _images = <LocalMediaItem>[];
  static const int _pageSize = 120;

  LocalMediaSort _sort = LocalMediaSort.nameAsc;

  // ⛔ 这一页只有一种密度，别再加「网格 / 列表」切换。
  //
  // 加过，当天就删了：两档的差别只是"卡片大一点还是小一点"，没有哪一档能做到
  // 另一档做不到的事——而它换来的是每个区块两条渲染分支、一个每进一层子目录
  // 就复位的页面状态，以及顶栏一枚常年占位的钮。用户的原话是「鸡肋」。
  // 真要控制密度，那是**全局**的事（设置里的列数/断点，`MediaLayoutUtils`
  // 已经在读），不是每一页各挂一枚钮。

  /// 正在扫这一层。只驱动加载态，内容始终直接读库。
  bool _scanning = false;

  /// 这一页自己发出去的那一轮扫描还没回来。
  ///
  /// ⛔ 与 [_scanning] 不是一回事：那个是给界面看的（转圈 + 挡住没探过的子目录），
  /// 这个是重入闸门。`scanFolder` 撞上别的扫描时最长要排队等 20 秒，期间
  /// initState / didUpdateWidget / 下拉刷新都能再叫一次；两次重叠时先结束的
  /// 那一次会把 `_scanning` 清 false 并 `_reloadFromDb()`，而另一轮还在跑——
  /// 用户看到的是「转完了，可目录是空的」。
  bool _scanInFlight = false;

  /// 扫描落批时刷新页面的订阅。
  ///
  /// ⛔ 必须 debounce 不能用 `ever`：扫描器每落一批（300 条）就 `notifyChanged()`
  /// 一次，一个大目录能发出几十上百次，逐次整页 setState 正好压在扫描本来就吃紧
  /// 的主 isolate 上。同 `local_home_page.dart` 里那条的理由。
  Worker? _repoWorker;
  Worker? _folderWorker;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadMore();
    _scrollController.addListener(_onScroll);
    _repoWorker = debounce<int>(
      LocalMediaRepository.changeRevision,
      (_) => _reloadFromDb(),
      time: const Duration(milliseconds: 400),
    );
    // ⛔ 目录行的变化（封面回填、pin）走**另一条**信号，而且只重读目录那一半。
    // 走 [_reloadFromDb] 的话，用户滚到半截时后台给某个视频生成了缩略图、顺手
    // 回填了目录封面，这一页的条目列表就被清空重拉、当场弹回顶部——为一张目录
    // 卡片的封面付这个代价荒谬。[_loadInitialData] 不碰条目列表。
    _folderWorker = debounce<int>(LocalMediaRepository.folderRevision, (_) {
      if (mounted) setState(_loadInitialData);
    }, time: const Duration(milliseconds: 400));
    unawaited(_scanThisFolder());
  }

  @override
  void didUpdateWidget(covariant LocalFolderBrowsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceId != widget.sourceId ||
        oldWidget.relPath != widget.relPath) {
      _loadInitialData();
      _resetPagination();
      _loadMore();
      unawaited(_scanThisFolder());
    }
  }

  @override
  void dispose() {
    _repoWorker?.dispose();
    _folderWorker?.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 进到这一层就把它**重新列一遍**。
  ///
  /// 这是本地库唯一的"自动刷新"通道，也是它存在的主要理由：目录源不会自己重扫，
  /// 用户在应用里下完一套图库、或者从 PC 拷了一批文件进来，全靠"再点进来看一眼"
  /// 这一下把新东西收进库。扫的只有这一层 + 每个子目录浅探一层，代价有界。
  Future<void> _scanThisFolder() async {
    final source = _source;
    if (source == null) return;
    // 「已下载」和「设备视频」没有目录树可走：前者从下载任务同步，后者是系统
    // 媒体索引。对它们叫目录扫描是空转。
    if (source.kind != LocalMediaSourceKind.directory &&
        source.kind != LocalMediaSourceKind.bookmark) {
      return;
    }
    if (!Get.isRegistered<LocalMediaScanService>()) return;
    if (_scanInFlight) {
      LogUtils.i('本页已有一轮目录扫描在跑，忽略本次', 'LocalFolderBrowsePage');
      return;
    }
    _scanInFlight = true;
    if (mounted) {
      setState(() {
        _scanning = true;
        _recomputeVisibleChildren();
      });
    }
    try {
      await LocalMediaScanService.to.scanFolder(
        source: source,
        relPath: widget.relPath,
      );
    } catch (e) {
      LogUtils.w('目录级扫描失败: $e', 'LocalFolderBrowsePage');
    } finally {
      _scanInFlight = false;
      if (mounted) {
        setState(() {
          _scanning = false;
          _recomputeVisibleChildren();
        });
        _reloadFromDb();
      }
    }
  }

  /// 这一屏该画的子目录。
  ///
  /// # ⛔ 扫描进行中要把「还没探过」的挡掉
  ///
  /// `childFolders` 会放行 `probed_at IS NULL` 的行（不知道里面有什么，先显示着），
  /// 这在静态时是对的。但扫描**进行中**它就是灾难：`Download` 底下两千多个空目录
  /// 的行是先落库、最后才统一标探过的，中间那十几秒用户看到的正是一整屏灰块，
  /// 每张还写着「这个文件夹是空的」——我们其实还不知道，卡片却在下结论。
  ///
  /// 扫这一层的时候只画已经有结论的，剩下的等扫完一次性出来。第一次进来因此是
  /// 转圈 + 「正在读取这个文件夹…」，正是该有的样子。
  /// ⛔ 存成字段而不是 getter：build 里要读它六七次，扫 `Download` 那种目录时
  /// `_children` 有两千多条——每帧过六七遍是白烧的。它只在 [_children] 或
  /// [_scanning] 变化时重算。
  List<LocalMediaFolder> _visibleChildren = const <LocalMediaFolder>[];

  void _recomputeVisibleChildren() {
    _visibleChildren = _scanning
        ? _children.where((folder) => folder.probedAt != null).toList()
        : _children;
  }

  /// 重新从库里读一遍这一层（目录 + 条目），滚动位置不动。
  void _reloadFromDb() {
    if (!mounted) return;
    setState(() {
      _loadInitialData();
      _resetPagination();
      _loadMore();
    });
  }

  void _loadInitialData() {
    _source = _repo.getSource(widget.sourceId);
    _folder = _repo.getFolder(
      sourceId: widget.sourceId,
      relPath: widget.relPath,
    );
    _breadcrumb = _repo.breadcrumb(
      sourceId: widget.sourceId,
      relPath: widget.relPath,
    );
    _children = _folder != null
        ? _repo.childFolders(
            sourceId: widget.sourceId,
            parentRelPath: widget.relPath,
          )
        : const <LocalMediaFolder>[];
    _recomputeVisibleChildren();
    _reloadPinnedKeys();
    unawaited(_loadDownloadedGalleries());
  }

  Future<void> _loadDownloadedGalleries() async {
    if (!_showsDownloadedGalleries) {
      _galleries = const <DownloadedGalleryRow>[];
      return;
    }
    if (!Get.isRegistered<DownloadService>()) return;
    final generation = ++_galleryGeneration;
    try {
      // 已下载的图库超过 500 个时这一页只画前 500 个——那一栏「下载完成图库」是分页的，去那儿看全部。
      final tasks = await DownloadService.to.repository
          .getCompletedDownloadTasks(
            offset: 0,
            limit: 500,
            mediaType: 'gallery',
          );
      if (!mounted || generation != _galleryGeneration) return;
      final rows = tasks.map(DownloadedGalleryRow.of).nonNulls.toList();
      setState(() {
        _galleries = rows;
      });
    } catch (e, s) {
      LogUtils.e(
        '读取已下载图库失败',
        tag: 'LocalFolderBrowsePage',
        error: e,
        stackTrace: s,
      );
      if (!mounted || generation != _galleryGeneration) return;
      setState(() {
        _galleries = const <DownloadedGalleryRow>[];
      });
    }
  }

  void _resetPagination() {
    _cursorKind = LocalMediaItemKind.video;
    _cursorOffset = 0;
    _exhausted = false;
    _loading = false;
    _videos.clear();
    _images.clear();
  }

  void _loadMore() {
    if (_loading || _exhausted) return;
    _loading = true;

    try {
      while (!_exhausted) {
        final items = _repo.queryItems(
          sourceId: widget.sourceId,
          kind: _cursorKind,
          sort: _sort,
          folderPath: _folder?.folderPath,
          offset: _cursorOffset,
          limit: _pageSize,
        );

        if (_cursorKind == LocalMediaItemKind.video) {
          _videos.addAll(items);
          _cursorOffset += items.length;
          if (items.length < _pageSize) {
            // 视频翻完了，**同一轮里**接着翻第一批图片，不能就此收手。
            //
            // ⛔ 继续加载全靠 [_onScroll]，而它只在真的能滚时才会响。一个「3 个
            // 视频 + 200 张图」的目录，3 张卡片撑不满一屏 → maxScrollExtent 为 0
            // → 滚动回调一次都不发 → 那 200 张图永远不出现。所以「短的一页」既是
            // 「这一类翻完了」的信号，也必须当场把下一类的第一页读进来，让首屏
            // 自己就够长、后续增量加载才有得触发。
            _cursorKind = LocalMediaItemKind.image;
            _cursorOffset = 0;
            continue;
          } else {
            break;
          }
        } else {
          _images.addAll(items);
          _cursorOffset += items.length;
          if (items.length < _pageSize) {
            _exhausted = true;
          }
          break;
        }
      }
    } finally {
      _loading = false;
    }

    if (mounted) {
      setState(() {});
    }
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

  Future<void> _refresh() async {
    _reloadFromDb();
    await _scanThisFolder();
  }

  /// 这一层的显示名：有目录就用目录名，退化分支（见类注释）用来源名。
  ///
  /// 顶栏标题和播放池的标题共用它——两处各写一遍的话，改了一处另一处就会开始
  /// 说不一样的话。
  String get _queueTitle =>
      (_folder == null || _folder!.isRoot || _folder!.name.isEmpty)
      ? (_source?.displayName ?? slang.t.localMedia.title)
      : _folder!.name;

  Future<void> _openVideo(LocalMediaItem item) async {
    if (!item.isPlayableNow) {
      showAppToast(slang.t.localMedia.fileMissing, type: AppToastType.error);
      return;
    }
    // 按**当前这一层目录**建池，让播放器底栏的「下一个」和播完续播都留在同目录里。
    //
    // ⛔ `sort` 必须是页面此刻正在用的那一档（[_sort]），不能图省事写死一个默认值：
    // 排序是池身份的一部分（见 `PlaybackQueueService.localLibraryQueueId` 与
    // `LocalLibraryPlaybackQueue` 的类注释）。池按添加时间排、列表按名称排的话，
    // 用户点第 3 集，「下一个」会是个毫不相干的东西。
    //
    // `folderPath` 传 `_folder?.folderPath`——和本页列条目时用的是同一个值
    // （见 [_loadMore]），退化分支（`_folder == null`，见类注释）自然落成
    // 「整个来源的扁平列表」，与页面显示的范围仍旧一致。
    PlaybackQueueRef? queueRef;
    try {
      final queue = PlaybackQueueService.to.openLocalLibrary(
        sourceId: widget.sourceId,
        folderPath: _folder?.folderPath,
        sort: _sort,
        title: _queueTitle,
      );
      queueRef = PlaybackQueueRef(
        queueId: queue.queueId,
        currentItemId: item.id,
      );
    } catch (e) {
      // 建池失败（读库出错、服务还没起来）不该拦住播放：照旧只带播放目标过去，
      // 无非是这一次没有「下一个」。
      LogUtils.e('本机目录建播放池失败', tag: 'LocalFolderBrowsePage', error: e);
    }

    NaviService.navigateToLocalVideoPlayerPage(
      localPath: item.resolvePlaybackTarget(),
      localLibraryItemId: item.id,
      playbackQueueRef: queueRef,
    );
  }

  void _openImage(LocalMediaItem item) {
    final folderPath = _folder?.folderPath;
    final List<String> paths;
    if (folderPath != null && folderPath.isNotEmpty) {
      final dbPaths = _repo.imagePathsInFolder(
        sourceId: widget.sourceId,
        folderPath: folderPath,
      );
      paths = dbPaths.isNotEmpty
          ? dbPaths
          : _images.map((e) => e.path).toList();
    } else {
      paths = _images.map((e) => e.path).toList();
    }

    if (paths.isEmpty) {
      showAppToast(slang.t.localMedia.fileMissing, type: AppToastType.error);
      return;
    }

    final index = paths.indexOf(item.path);
    final initialIndex = index >= 0 ? index : 0;

    // ⛔ 必须裸拼，不许换成 `Uri.file(path)`——理由见
    // `local_media_wall.dart` 里同一处的长注释（消费方是字符串剥前缀，
    // 编码过的 `%23` 会原样进文件系统调用，真机上当场 PathNotFoundException）。
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

  /// 长按一个文件 → 「设置封面」（只有视频有）与「删除」。
  ///
  /// ⛔ 这两条是有门槛的，别顺手往里加。这张卡上曾经挂过「预览」和「移到分类」，
  /// 两个都是把下载列表的语义搬到了本机文件上，已经整只删掉（见
  /// `local_media_item_card.dart` 的类文档）。留下来的这两条都是**文件管理器本来
  /// 就该有**的动作：一个改磁盘上的文件，一个改这条内容的门面。
  ///
  /// 「设置封面」只给视频：图片自己就是封面，给它挑封面没有意义。
  Future<void> _showItemMenu(
    BuildContext anchorContext,
    LocalMediaItem item,
  ) async {
    final folderCoverSource = _folderCoverSourceOf(item);
    await showLocalMediaItemMenu(
      anchorContext: anchorContext,
      item: item,
      folderCoverSource: folderCoverSource,
      onSetAsFolderCover: folderCoverSource != null
          ? () => _setFolderCover(folderCoverSource)
          : null,
      onChanged: () {
        if (mounted) _reloadFromDb();
      },
      onDeleted: (deletedItem) {
        if (mounted) {
          setState(() {
            _videos.removeWhere((e) => e.id == deletedItem.id);
            _images.removeWhere((e) => e.id == deletedItem.id);
          });
        }
      },
    );
  }

  /// 拿这一条当目录封面时用哪张图。
  ///
  /// 图片就是它自己；视频用已经派生出来的封面（sidecar 优先，其次抓帧缓存）。
  /// 视频还没派生出封面时返回 null——那一条菜单干脆不出现，比出现了点下去没反应好。
  String? _folderCoverSourceOf(LocalMediaItem item) {
    if (_folder == null) return null;
    if (item.kind == LocalMediaItemKind.image) {
      return item.path.isEmpty ? null : item.path;
    }
    final sidecar = item.sidecarImagePath;
    if (sidecar != null && sidecar.isNotEmpty) return sidecar;
    final thumb = item.thumbPath;
    if (thumb != null && thumb.isNotEmpty) return thumb;
    return null;
  }

  void _setFolderCover(String coverPath) {
    final ok = _repo.setFolderCover(
      sourceId: widget.sourceId,
      relPath: widget.relPath,
      coverPath: coverPath,
    );
    if (!mounted) return;
    if (ok) {
      showAppToast(slang.t.localMedia.browse.folderCoverSet);
      setState(_loadInitialData);
    }
  }

  /// 顶栏那颗 ☆：「设为常用 / 取消常用」的快捷键。
  ///
  /// ⛔ 它和 ⋮ 菜单里那一条是**同一份实现**（[LocalFolderActions.handle]），不许
  /// 在这里再写一遍置顶逻辑——两份各自算 `sortOrder`、各自发 toast，改一处另一处
  /// 就开始说不一样的话。这里只负责"按下去"这件事。
  void _togglePin() {
    if (_folder == null) return;
    unawaited(_folderActions.handle(context, _isPinned ? 'unpin' : 'pin'));
  }

  Future<void> _showLocationMenu(BuildContext anchorContext) async {
    if (_breadcrumb.isEmpty) return;

    final entries = <GlassMenuEntry>[
      GlassMenuSectionHeader(slang.t.localMedia.browse.location),
      for (final crumb in _breadcrumb)
        GlassMenuOption<String>(
          value: crumb.relPath,
          label: crumb.isRoot
              ? (_source?.displayName ?? slang.t.localMedia.title)
              : (crumb.name.isNotEmpty
                    ? crumb.name
                    : (_source?.displayName ?? slang.t.localMedia.title)),
          icon: crumb.isRoot ? Icons.storage_outlined : Icons.folder_outlined,
          selected: crumb.relPath == widget.relPath,
        ),
    ];

    final selectedRelPath = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: entries,
    );

    if (!mounted || selectedRelPath == null) return;
    if (selectedRelPath != widget.relPath) {
      appRouter.push(
        LocalFolderRoute.location(
          sourceId: widget.sourceId,
          relPath: selectedRelPath,
        ),
      );
    }
  }

  /// 这一层目录能做的事，与**外面那张卡的 ⋮ 一模一样**（见 [LocalFolderActions]
  /// 的类注释）。顶栏那颗 ☆ 只是「设为常用」的快捷键，不是它的唯一入口。
  LocalFolderActions get _folderActions => LocalFolderActions(
    sourceId: widget.sourceId,
    relPath: widget.relPath,
    folderPath: _folder?.folderPath,
    pinned: _isPinned,
    coverPinned: _folder?.coverPinned ?? false,
    displayName: (_folder == null || _folder!.name.isEmpty)
        ? (_source?.displayName ?? '')
        : _folder!.name,
    canRescan: _source != null && Get.isRegistered<LocalMediaScanService>(),
    // 「移除来源」：只要当前脚下这个源不是内建源，随时支持从浏览页中移除。
    // 删完后 pop 弹回外层页面。
    onRemove: (_source != null && !_source!.isBuiltIn)
        ? () => unawaited(_removeThisSource())
        : null,
    onChanged: () {
      if (!mounted) return;
      setState(() {
        _reloadPinnedKeys();
        _loadInitialData();
      });
    },
  );

  /// 在自己这一页上把脚下这个源删掉，然后把自己弹掉。
  ///
  /// ⛔ 删完必须 pop：这一页的全部内容都来自那个源，留在原地就是一屏"来源已经不
  /// 在了"的空壳，而且顶栏那些动作还都点得动。
  Future<void> _removeThisSource() async {
    final source = _source;
    if (source == null) return;
    final removed = await confirmAndRemoveLocalSource(
      context: context,
      source: source,
    );
    if (!removed || !mounted) return;
    appRouter.pop();
  }

  /// 顶栏的 ⋮：**排序**（这一页独有）+ 这一层目录的全套操作。
  ///
  /// ⛔ 下半截不许在这里手写。它原来只有「重新扫描」一条，于是"设为封面/恢复自动
  /// 封面"这些外面卡片上有的事，进来之后反而做不了了（2026-09-11 用户报的"内外没
  /// 对齐"）。条目和执行都从 [LocalFolderActions] 拿，加能力只改那一处。
  Future<void> _showMoreMenu(BuildContext anchorContext) async {
    final actions = _folderActions;
    final selected = await showGlassMenu<Object>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<LocalMediaSort>(
          value: LocalMediaSort.nameAsc,
          label: slang.t.localMedia.sortName,
          icon: Icons.sort_by_alpha,
          selected: _sort == LocalMediaSort.nameAsc,
        ),
        GlassMenuOption<LocalMediaSort>(
          value: LocalMediaSort.modifiedDesc,
          label: slang.t.localMedia.sortRecentlyModified,
          icon: Icons.schedule,
          selected: _sort == LocalMediaSort.modifiedDesc,
        ),
        GlassMenuOption<LocalMediaSort>(
          value: LocalMediaSort.sizeDesc,
          label: slang.t.localMedia.sortSize,
          icon: Icons.data_usage,
          selected: _sort == LocalMediaSort.sizeDesc,
        ),
        const GlassMenuSeparator(),
        ...actions.entries(),
      ],
    );

    if (!mounted || selected == null) return;

    if (selected is LocalMediaSort) {
      if (_sort != selected) {
        setState(() {
          _sort = selected;
          _resetPagination();
          _loadMore();
        });
      }
      return;
    }
    if (!anchorContext.mounted) return;
    await actions.handle(anchorContext, selected);
  }

  /// 这个来源本该有目录树，但库里一行都没有——只可能是它上次扫描时
  /// 目录表还不存在（v31 之前加进来的源）。
  ///
  /// 迁移没法替它补：目录树要靠走一遍文件系统才拿得到，迁移只动数据库。
  /// 所以老用户升级上来点进任何一个老来源，看到的都会是一条没有层级的
  /// 平铺列表——不说一声的话，他会以为「文件夹浏览」根本没做出来。
  ///
  /// 「已下载」和「设备视频」不在此列：它们本来就没有真实的目录树
  /// （前者没有稳定根路径，后者是系统媒体索引），对它们平铺才是对的。
  bool get _needsRescanForTree {
    if (_folder != null) return false;
    final kind = _source?.kind;
    return kind == LocalMediaSourceKind.directory ||
        kind == LocalMediaSourceKind.bookmark;
  }

  Widget _buildRescanHint(BuildContext context) {
    final theme = Theme.of(context);
    final canRescan =
        _source != null && Get.isRegistered<LocalMediaScanService>();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    slang.t.localMedia.browse.notScannedYet,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (canRescan) ...[
                  const SizedBox(width: 8),
                  GlassButtonGroup(
                    children: [
                      GlassTextActionButton(
                        label: slang.t.localMedia.rescan,
                        emphasized: true,
                        onPressed: () => unawaited(
                          LocalMediaScanService.to.scanSource(_source!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        size: 24,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    final String currentTitle = _queueTitle;

    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: slang.t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Builder(
                  builder: (pillContext) => GlassTitlePill(
                    title: currentTitle,
                    // 扫这一层的时候，标题左边转一枚小弧。见 [GlassInlineBusy]：
                    // 这取代了原先顶在列表上方的那条横进度条。
                    busy: _scanning,
                    onTap: () => _showLocationMenu(pillContext),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GlassButtonGroup(
                children: [
                  if (_folder != null)
                    GlassIconButton(
                      icon: Icon(_isPinned ? Icons.star : Icons.star_border),
                      tooltip: _isPinned
                          ? slang.t.localMedia.browse.unpin
                          : slang.t.localMedia.browse.pin,
                      onPressed: _togglePin,
                    ),
                  Builder(
                    builder: (menuContext) => GlassIconButton(
                      icon: const Icon(Icons.more_vert),
                      tooltip: slang.t.common.more,
                      opensOverlay: true,
                      onPressed: () => _showMoreMenu(menuContext),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          displacement: headerExtent,
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 32;
              final crossAxisCount = MediaLayoutUtils.calculateCrossAxisCount(
                availableWidth,
              );
              // 目录**跟着媒体墙的列走**：同样的列数、同样的沟宽。各算各的会让
              // 目录卡比视频卡窄一截，两个区块的右边界错开——一眼就看得出是两套
              // 网格拼在一起的。
              final folderMetrics = LocalGridMetrics(
                crossAxisCount: crossAxisCount,
                cellWidth: MediaLayoutUtils.calculateCardWidth(availableWidth),
                spacing: MediaLayoutUtils.crossAxisSpacing,
              );

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: headerExtent)),
                  // ⛔ 这里原先顶着一条 `LinearProgressIndicator(minHeight: 2)`。
                  // 已经删掉——「还在扫」现在画在 header 的标题胶囊上（见上面的
                  // `busy: _scanning`）。那条横线不属于任何东西、出现消失还是硬
                  // 切，把它底下整列内容顶上顶下。别再加回来。
                  if (_needsRescanForTree) _buildRescanHint(context),
                  if (_galleries.isNotEmpty) ...[
                    _buildSectionHeader(
                      slang.t.localMedia.browse.galleriesSection,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: folderMetrics.delegate(
                          DownloadedGalleryCard.extentFor(
                            context,
                            folderMetrics.cellWidth,
                          ),
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final gallery = _galleries[index];
                            return DownloadedGalleryCard(
                              row: gallery,
                              onDeleted: () {
                                if (mounted) {
                                  setState(() {
                                    _galleries = _galleries
                                        .where((e) => e.taskId != gallery.taskId)
                                        .toList();
                                  });
                                }
                              },
                            );
                          },
                          childCount: _galleries.length,
                        ),
                      ),
                    ),
                  ],
                  if (_visibleChildren.isNotEmpty) ...[
                    _buildSectionHeader(
                      slang.t.localMedia.browse.sourcesSection,
                    ),
                    // 网格模式下是封面卡（一眼看见里面有什么），列表模式下是紧凑行（目录多到几十上百个时一屏塞得下更多），
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: folderMetrics.delegate(
                          LocalFolderCardWidget.extentFor(
                            context,
                            folderMetrics.cellWidth,
                          ),
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final child = _visibleChildren[index];
                          return Builder(
                            builder: (cardContext) => LocalFolderCardWidget(
                              folder: child,
                              pinned: _pinnedKeys.contains(
                                _pinKey(child.sourceId, child.relPath),
                              ),
                              onOpen: () {
                                appRouter.push(
                                  LocalFolderRoute.locationForFolder(child),
                                );
                              },
                              onMenu: (anchorContext) => showLocalFolderMenu(
                                anchorContext: anchorContext,
                                actions: LocalFolderActions(
                                  sourceId: child.sourceId,
                                  relPath: child.relPath,
                                  folderPath: child.folderPath,
                                  pinned: _pinnedKeys.contains(
                                    _pinKey(child.sourceId, child.relPath),
                                  ),
                                  coverPinned: child.coverPinned,
                                  displayName: child.name.isEmpty
                                      ? (_source?.displayName ?? '')
                                      : child.name,
                                  canRescan: true,
                                  onChanged: _reloadFromDb,
                                ),
                              ),
                            ),
                          );
                        }, childCount: _visibleChildren.length),
                      ),
                    ),
                  ],
                  if (_videos.isNotEmpty) ...[
                    // 只有一种东西时不必分组；一旦这一屏还有别的区块（子目录，
                    // 或另一类媒体），就必须标出来——不然视频会看着像是挂在
                    // 上面那条「文件夹」标题底下的。
                    if (_images.isNotEmpty ||
                        _visibleChildren.isNotEmpty ||
                        _galleries.isNotEmpty)
                      _buildSectionHeader(
                        slang.t.localMedia.browse.videosSection,
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: MediaWaterfallSliver(
                        crossAxisCount: crossAxisCount,
                        itemCount: _videos.length,
                        itemBuilder: (context, index, itemWidth) {
                          final item = _videos[index];
                          return LocalMediaItemCard(
                            item: item,
                            width: itemWidth,
                            onOpen: () => _openVideo(item),
                            onMenu: (anchorContext) =>
                                _showItemMenu(anchorContext, item),
                          );
                        },
                      ),
                    ),
                  ],
                  if (_images.isNotEmpty) ...[
                    if (_videos.isNotEmpty ||
                        _visibleChildren.isNotEmpty ||
                        _galleries.isNotEmpty)
                      _buildSectionHeader(
                        slang.t.localMedia.browse.imagesSection,
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: MediaWaterfallSliver(
                        crossAxisCount: crossAxisCount,
                        itemCount: _images.length,
                        itemBuilder: (context, index, itemWidth) {
                          final item = _images[index];
                          final dpr = MediaQuery.of(context).devicePixelRatio;
                          // ⛔ 图片格也要一枚看得见的 ⋮：只留长按等于没有入口，
                          // 用户不知道有这个功能（同 `local_media_item_card.dart`
                          // 的类文档）。
                          // ⛔ 锚点必须是**这一格**自己的 context。原来传的是
                          // itemBuilder 那个 `context`——它是整条 sliver 的，长按
                          // 哪一格菜单都贴着同一个位置开。
                          return Builder(
                            builder: (cellContext) => Stack(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => _openImage(item),
                                  onLongPress: () =>
                                      _showItemMenu(cellContext, item),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.file(
                                        File(item.path),
                                        fit: BoxFit.cover,
                                        cacheWidth: (itemWidth * dpr)
                                            .round()
                                            .clamp(1, 4096),
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildImagePlaceholder(context),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: LocalContainerCard.badgeInset,
                                  right: LocalContainerCard.badgeInset,
                                  child: LocalCardMenuBadge(
                                    onMenu: (anchorContext) =>
                                        _showItemMenu(anchorContext, item),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  // ⛔ 这里没有加载指示器，也不该有：[_loadMore] 从头到尾是同步的
                  // （sqlite3 在主 isolate 上是同步 API），`_loading` 只在那一个
                  // 函数调用栈内为真，build 时永远读到 false——画出来的转圈是一帧
                  // 都不会出现的死代码。翻页那一下的代价是主线程阻塞，不是等待。
                  if (_visibleChildren.isEmpty &&
                      _videos.isEmpty &&
                      _images.isEmpty &&
                      _galleries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 还在读这一层时不要报「这个文件夹是空的」——那句话
                            // 是个结论，而此刻我们还没有资格下结论。
                            // 空态这枚是大号的同一枚弧——整屏转圈与标题旁那枚
                            // 小的必须是同一种画法，否则一页上会出现两种"正在忙"。
                            if (_scanning)
                              const GlassSpinningArc(size: 36)
                            else
                              Icon(
                                Icons.folder_open_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            const SizedBox(height: 16),
                            Text(
                              _scanning
                                  ? slang.t.localMedia.browse.scanning
                                  : _folder == null
                                  ? slang.t.localMedia.browse.notScannedYet
                                  : slang.t.localMedia.browse.emptyFolder,
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
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 24,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
