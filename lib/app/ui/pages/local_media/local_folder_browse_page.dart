import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/local_folder_route.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/downloaded_gallery_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_menu.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_image_viewer.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_menu.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_search_input_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
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
/// 这一页此刻在看哪一类东西。
///
/// # 为什么需要它
///
/// 一个真实的 `Download` 目录里同时躺着几百个子文件夹、几百个视频和上千张图片。
/// 原先这一页把四个区块**首尾相接**地排成一条长列表，于是「我想看这层的视频」
/// 要先滚过两百个文件夹卡片——而那两百个卡片是用户此刻完全不关心的东西。
///
/// 现在 [all] 是**预览**：每个区块最多铺 [_LocalFolderBrowsePageState._previewRows]
/// 行，剩下的折成一条「查看全部 N 个」，点下去就是切到这里的某一档，那一档才是
/// 完整的、可无限翻页的列表。
enum _BrowseFilter { all, folders, videos, images, galleries }

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
  List<DownloadedGalleryRow> _visibleGalleries = const <DownloadedGalleryRow>[];
  int _galleryGeneration = 0;

  // ── 类型筛选 + 目录内搜索 ────────────────────────────────────────────────
  _BrowseFilter _filter = _BrowseFilter.all;

  /// 已经**生效**的关键词（去抖之后的），空串＝没在搜。
  ///
  /// ⛔ 不要直接读 [_searchController].text：每敲一个字都重查一次库，而这一层
  /// 可能有上千条——sqlite3 在主 isolate 上是同步的，逐字重查就是逐字掉帧。
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchDebounce;

  /// 搜索框是否展开。展开时它顶掉筛选胶囊那一行——两样东西都塞进去，窄屏上
  /// 输入框只剩三个字宽。
  bool _searchOpen = false;

  /// 这一层各类东西的总数。**不带搜索词**，只用来决定筛选胶囊上出现哪几段：
  /// 跟着搜索词变的话，用户每敲一个字胶囊就少一段、整行宽度跟着抖。
  int _videoTotal = 0;
  int _imageTotal = 0;

  /// 当前口径（含搜索词）下的条数，用于段标签与「查看全部 N 个」。
  int _videoCount = 0;
  int _imageCount = 0;

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

  /// 这个源里被隐藏的相对路径。开着「显示隐藏的文件夹」时靠它把卡片画成半透明。
  ///
  /// ⛔ 同 [_pinnedKeys]：一次查完存着，别在 itemBuilder 里现问库——sqlite3 在主
  /// isolate 上是同步的，几十张卡在滚动中反复 build 就是每帧几十次同步查询。
  Set<String> _hiddenRelPaths = const <String>{};

  /// 脚下这一层自己是不是被隐藏的（顶栏 ⋮ 要据此显示「取消隐藏」）。
  bool _isHidden = false;

  /// 「显示隐藏的文件夹」开着没有。菜单里那一条切它，见 [LocalFolderActions]。
  bool get _showHidden => LocalFolderActions.showHiddenFolders;

  // ── 分页 ────────────────────────────────────────────────────────────────
  //
  // ⛔ 这里曾经是「先把视频翻完再翻图片」的**双段顺序游标**。它和类型筛选天生
  // 不兼容：一个有 500 个视频的目录，图片那一段永远轮不到加载，于是「全部」视图
  // 里的图片区块恒为空——而它下面明明写着「1243 张」。
  //
  // 现在游标只属于**当前正在看的那一类**：
  //   - [_BrowseFilter.videos] / [_BrowseFilter.images] ＝ 真分页，滚到底加载下一页；
  //   - [_BrowseFilter.all] ＝ 两类各读一小撮当预览（[_previewLoadCap]），不翻页；
  //   - 文件夹 / 图库两类本来就一次性全在内存里，没有游标可言。
  int _cursorOffset = 0;
  bool _exhausted = false;
  bool _loading = false;
  final List<LocalMediaItem> _videos = <LocalMediaItem>[];
  final List<LocalMediaItem> _images = <LocalMediaItem>[];
  static const int _pageSize = 120;

  /// 「全部」视图下每类最多读这么多条。
  ///
  /// 画的时候还会按实际列数裁到 [_previewRows] 行；多读一点是给宽屏留的余量
  /// （桌面横屏能排到七八列，读 12 条就凑不满两行了）。
  static const int _previewLoadCap = 24;

  /// 「全部」视图下每个区块铺几行。两行足够看出"这层大概有些什么"，又不至于
  /// 把下一个区块顶出屏幕——一屏之内看得见第二个区块的标题，用户才知道还有别的。
  static const int _previewRows = 2;

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
  ///
  /// ⛔ 记的是**正在扫哪一层**（`sourceId\u0000relPath`），不是一个布尔：同一个
  /// State 会被 [didUpdateWidget] 换到另一层去，那时旧那一轮还在飞——布尔闸门会把
  /// 新那一层的扫描当成重入拦掉，旧那一轮收尾时还会替新那一层清掉转圈、重载。
  /// null ＝ 没有在飞的。
  String? _scanInFlightKey;

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
    _sort = _restoreSort();
    _loadInitialData();
    _loadItems();
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
    //
    // ⛔ 面包屑也不在这里重算（它只随 relPath 变，见 [_loadBreadcrumb]），
    // 已下载图库更不在这里重拉（那是 500 个任务的一次读库 + 解析，见
    // [_loadDownloadedGalleries]）。
    _folderWorker = debounce<int>(LocalMediaRepository.folderRevision, (_) {
      if (!mounted) return;
      setState(() {
        _loadFolderData();
        // 唯一的例外：这一层第一次进来时库里还没有目录行，面包屑是空的——
        // 扫描把行写进来之后得补一次，否则位置菜单一直打不开。
        if (_breadcrumb.isEmpty) _loadBreadcrumb();
      });
    }, time: const Duration(milliseconds: 400));
    unawaited(_loadDownloadedGalleries());
    unawaited(_scanThisFolder());
  }

  @override
  void didUpdateWidget(covariant LocalFolderBrowsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceId != widget.sourceId ||
        oldWidget.relPath != widget.relPath) {
      // 旧那一层的扫描可能还在飞：放掉它的闸门与转圈，它收尾时认出 key 对不上，
      // 不会再动这一层的状态（见 [_scanInFlightKey]）。
      _scanInFlightKey = null;
      _scanning = false;
      // 换了一层目录：筛选与搜索都是"对这一层"说的话，跟着一起清。
      // ⛔ 不清的话，从一个全是视频的目录点进一个全是图片的子目录，用户会撞上
      // 一屏「没有内容」——而筛选胶囊上那一段"视频"此刻连出现的理由都没有。
      _filter = _BrowseFilter.all;
      // 上一层读条目时的口径，对这一层不作数；不清的话下面 [_loadInitialData]
      // 会拿它和新一层的构成比，平白先按半截数据重读一次条目。
      _loadedFilter = null;
      _toolRowLatched = false;
      // ⛔ 计数必须跟着清零。[_loadInitialData] 会在 [_loadItems] **之前**跑
      // `_recomputeVisibleChildren` → `_updateToolRowLatch`，那一刻这几个数还是
      // **上一层**的；不清的话，从一个有上千条的目录点进一个空目录，那一行筛选/
      // 搜索会凭着上一层的数字当场上闩，而它的高度算在 headerExtent 里。
      _videoTotal = 0;
      _imageTotal = 0;
      _videoCount = 0;
      _imageCount = 0;
      _galleries = const <DownloadedGalleryRow>[];
      _visibleGalleries = const <DownloadedGalleryRow>[];
      _clearSearch(rebuild: false);
      _loadInitialData();
      _loadItems();
      unawaited(_loadDownloadedGalleries());
      unawaited(_scanThisFolder());
    }
  }

  @override
  void dispose() {
    _repoWorker?.dispose();
    _folderWorker?.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
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
    final relPath = widget.relPath;
    final key = _pinKey(source.id, relPath);
    if (_scanInFlightKey == key) {
      LogUtils.i('本页已有一轮目录扫描在跑，忽略本次', 'LocalFolderBrowsePage');
      return;
    }
    _scanInFlightKey = key;
    if (mounted) {
      setState(() {
        _scanning = true;
        _recomputeVisibleChildren();
      });
    }
    try {
      await LocalMediaScanService.to.scanFolder(
        source: source,
        relPath: relPath,
      );
    } catch (e) {
      LogUtils.w('目录级扫描失败: $e', 'LocalFolderBrowsePage');
    } finally {
      // 页面在扫描期间被换到了别的层：这一轮的结果不属于现在这一层，什么都不动。
      final stillOurs = _scanInFlightKey == key;
      if (stillOurs) _scanInFlightKey = null;
      if (mounted && stillOurs) {
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

  /// 挡掉"还没探过"之后、**搜索之前**的那一批。筛选胶囊上"文件夹 N"里的 N 读它
  /// ——见 [_videoTotal] 那条同样的理由。
  List<LocalMediaFolder> _probedChildren = const <LocalMediaFolder>[];

  void _recomputeVisibleChildren() {
    _probedChildren = _scanning
        ? _children.where((folder) => folder.probedAt != null).toList()
        : _children;
    // 文件夹与图库都**整份在内存里**（`childFolders` 一次查完、图库上限 500），
    // 所以这两类的搜索就地过滤，不必也不该再去打一次库。
    final needle = _query.toLowerCase();
    // ⛔ 只按 `name` 折小写比，**不要**碰 `sortName`：那是自然序 key，数字段被
    // 重写过（`EP5` → `ep015`），拿它比等于给带数字的关键词判死刑。理由的全文在
    // `LocalMediaRepository._itemFilter` 里——两边必须是同一个口径，否则同一个词
    // 文件夹搜得到、文件搜不到。
    _visibleChildren = needle.isEmpty
        ? _probedChildren
        : _probedChildren
              .where((folder) => folder.name.toLowerCase().contains(needle))
              .toList();
    _visibleGalleries = needle.isEmpty
        ? _galleries
        : _galleries
              .where((row) => row.title.toLowerCase().contains(needle))
              .toList();
    _updateToolRowLatch();
    // 子目录 / 图库这一半变了，可能让这一层从「只有一类」变成「混着几类」或反过来
    // ——条目那一半得跟着换口径（整页 ↔ 预览）。⛔ 只在真的变了时重读：这里在
    // 扫描期间随 folderRevision 频繁进来，逐次重查条目就是逐次同步读库。
    if (_loadedFilter != null && _effectiveFilter != _loadedFilter) {
      _loadItems(keepLoaded: true);
    }
  }

  /// 重新从库里读一遍这一层（目录 + 条目），滚动位置不动。
  ///
  /// ⛔ 条目**不许先清空再拉第一页**：那样用户滚到半截时来一次 `changeRevision`，
  /// 列表当场缩回一页，滚动长度塌掉、位置被夹回去。见 [_reloadItemsKeepingLoaded]。
  void _reloadFromDb() {
    if (!mounted) return;
    setState(() {
      _loadInitialData();
      _loadItems(keepLoaded: true);
    });
  }

  /// 目录那一半（来源、这一层、子目录、置顶）+ 面包屑。不碰条目，不碰已下载图库。
  void _loadInitialData() {
    _loadFolderData();
    _loadBreadcrumb();
  }

  /// 目录行那一半。`folderRevision` 只走这里。
  void _loadFolderData() {
    _source = _repo.getSource(widget.sourceId);
    _folder = _repo.getFolder(
      sourceId: widget.sourceId,
      relPath: widget.relPath,
    );
    _children = _folder != null
        ? _repo.childFolders(
            sourceId: widget.sourceId,
            parentRelPath: widget.relPath,
            // 开关关着时，被隐藏的子目录**在仓储层就被滤掉了**（见
            // `childFolders` 的文档）：这一页不必也不该自己再过滤一遍。
            includeHidden: _showHidden,
          )
        : const <LocalMediaFolder>[];
    _hiddenRelPaths = _repo.hiddenRelPaths(widget.sourceId);
    _isHidden = _hiddenRelPaths.contains(widget.relPath);
    _recomputeVisibleChildren();
    _reloadPinnedKeys();
  }

  /// 面包屑只随 `(sourceId, relPath)` 变，目录行的封面 / 计数变化与它无关。
  void _loadBreadcrumb() {
    _breadcrumb = _repo.breadcrumb(
      sourceId: widget.sourceId,
      relPath: widget.relPath,
    );
  }

  /// 这一层此刻该有哪些条目：按 [_filter] 决定读哪一类、读多少。
  ///
  /// [keepLoaded] ＝ 「别把用户已经翻出来的几页缩回去」。扫描落批 / 封面回填那条
  /// `changeRevision` 信号走这里，它随时可能在用户滚到第 500 条时到来——重拉第一页
  /// 的话列表当场缩短，滚动长度塌掉、位置被夹回顶上。
  void _loadItems({bool keepLoaded = false}) {
    if (_loading) return;
    _loading = true;
    try {
      // 两类计数各查一次。⛔ 不能拿 `_videos.length` 当总数：它只是已经翻出来的
      // 那几页，而「查看全部 1243 张」里的 1243 必须是真的总数。
      _videoTotal = _countOf(LocalMediaItemKind.video, withQuery: false);
      _imageTotal = _countOf(LocalMediaItemKind.image, withQuery: false);
      if (_query.isEmpty) {
        _videoCount = _videoTotal;
        _imageCount = _imageTotal;
      } else {
        _videoCount = _countOf(LocalMediaItemKind.video, withQuery: true);
        _imageCount = _countOf(LocalMediaItemKind.image, withQuery: true);
      }

      // ⛔ 先确认「当前这一档还存在吗」，再决定读什么。
      //
      // 筛在"视频"档时把最后一个视频删掉（或者重扫之后这一类整个没了），这一档就
      // 成了一张不存在的门牌：筛选胶囊上那一段消失、高亮兜底跳回「全部」，而
      // `_filter` 还指着 videos，于是 [_currentViewIsEmpty] 为真、整屏写着
      // 「这个文件夹是空的」——可这一层还有两百个子文件夹。
      if (!_filterStillExists) _filter = _BrowseFilter.all;

      final effective = _effectiveFilter;
      _loadedFilter = effective;
      switch (effective) {
        case _BrowseFilter.all:
          // 预览：两类各读一小撮，不翻页。
          _replace(
            _videos,
            _queryPage(LocalMediaItemKind.video, 0, _previewLoadCap),
          );
          _replace(
            _images,
            _queryPage(LocalMediaItemKind.image, 0, _previewLoadCap),
          );
          _cursorOffset = 0;
          _exhausted = true;
        case _BrowseFilter.videos:
          final limit = keepLoaded
              ? math.max(_pageSize, _videos.length)
              : _pageSize;
          _replace(_videos, _queryPage(LocalMediaItemKind.video, 0, limit));
          _images.clear();
          _cursorOffset = _videos.length;
          _exhausted = _videos.length >= _videoCount;
        case _BrowseFilter.images:
          final limit = keepLoaded
              ? math.max(_pageSize, _images.length)
              : _pageSize;
          _replace(_images, _queryPage(LocalMediaItemKind.image, 0, limit));
          _videos.clear();
          _cursorOffset = _images.length;
          _exhausted = _images.length >= _imageCount;
        case _BrowseFilter.folders:
        case _BrowseFilter.galleries:
          // 这两类整份在内存里（见 [_recomputeVisibleChildren]），一条库都不用查。
          _videos.clear();
          _images.clear();
          _cursorOffset = 0;
          _exhausted = true;
      }
      _updateToolRowLatch();
    } finally {
      _loading = false;
    }
  }

  /// 这一层**实际**按哪一档来读、来画。
  ///
  /// 停在「全部」、而这一层只有一类东西（只有视频 / 只有子文件夹 / 只有图库…）时，
  /// 预览就没有意义了：两行之后挂一条「查看全部」，逼用户多点一下才看得到其余的——
  /// 可这一层根本没有别的东西要让位。这时直接当成那一档：完整列表、可翻页。
  ///
  /// ⛔ 只改读法与画法，**不改 [_filter]**：这一层后来又多出第二类东西（扫描落批、
  /// 图库异步读回来）时，要自动回到预览，而不是被钉在某一档上。筛选胶囊此时本来
  /// 就不出现（只有「全部」+ 一段，见 build 里的 `showSegments`）。
  /// 口径与 [_segments] 一致：看不带搜索词的总数。
  _BrowseFilter get _effectiveFilter {
    if (_filter != _BrowseFilter.all) return _filter;
    final present = <_BrowseFilter>[
      if (_probedChildren.isNotEmpty) _BrowseFilter.folders,
      if (_galleries.isNotEmpty) _BrowseFilter.galleries,
      if (_videoTotal > 0) _BrowseFilter.videos,
      if (_imageTotal > 0) _BrowseFilter.images,
    ];
    return present.length == 1 ? present.single : _BrowseFilter.all;
  }

  /// [_loadItems] 上一次是按哪一档读的。与 [_effectiveFilter] 对不上＝这一层的构成
  /// 变了（多出/少了一类），条目得按新口径重读，见 [_recomputeVisibleChildren]。
  _BrowseFilter? _loadedFilter;

  /// 当前这一档筛选在这一层还有没有对应的东西。
  ///
  /// 口径必须与 [_segments] 里"哪几段在场"**一字不差**：段没了而 `_filter` 还指着
  /// 它，就是一张点不回去的门牌。同样用不带搜索词的总数——搜不到结果是"这次没搜着"，
  /// 不是"这一类不存在"，那时候该留在这一档让用户改词。
  bool get _filterStillExists => switch (_filter) {
    _BrowseFilter.all => true,
    _BrowseFilter.folders => _probedChildren.isNotEmpty,
    _BrowseFilter.galleries => _galleries.isNotEmpty,
    _BrowseFilter.videos => _videoTotal > 0,
    _BrowseFilter.images => _imageTotal > 0,
  };

  static void _replace(List<LocalMediaItem> target, List<LocalMediaItem> next) {
    target
      ..clear()
      ..addAll(next);
  }

  int _countOf(LocalMediaItemKind kind, {required bool withQuery}) {
    return _repo.countItems(
      sourceId: widget.sourceId,
      kind: kind,
      folderPath: _folder?.folderPath,
      nameQuery: withQuery ? _query : null,
    );
  }

  List<LocalMediaItem> _queryPage(
    LocalMediaItemKind kind,
    int offset,
    int limit,
  ) {
    return _repo.queryItems(
      sourceId: widget.sourceId,
      kind: kind,
      sort: _sort,
      folderPath: _folder?.folderPath,
      nameQuery: _query.isEmpty ? null : _query,
      offset: offset,
      limit: limit,
    );
  }

  /// 「已下载」根层那一格格图库。
  ///
  /// ⛔ 只在进页、换层、下拉刷新时调：它是一次 500 条的任务表查询 + 整批 JSON
  /// 解析，挂在 `changeRevision` / `folderRevision` 上的话，扫描落批、封面回填
  /// 每来一次就重拉一遍——而这些信号跟下载任务表毫无关系。
  Future<void> _loadDownloadedGalleries() async {
    if (!_showsDownloadedGalleries) {
      // 作废可能还在飞的那一次（换层前发出去的），它回来时不许再把图库塞回来。
      // 直接赋值不 setState：调用方（换层 / 刷新）紧接着就会重建。
      _galleryGeneration++;
      _galleries = const <DownloadedGalleryRow>[];
      _visibleGalleries = const <DownloadedGalleryRow>[];
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
      final rows = await DownloadedGalleryRow.parseAllInBackground(tasks);
      if (!mounted || generation != _galleryGeneration) return;
      setState(() {
        _galleries = rows;
        _recomputeVisibleChildren();
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
        _recomputeVisibleChildren();
      });
    }
  }

  /// 翻下一页。**只有**视频档与图片档有下一页可翻（见 [_loadItems] 的注释）。
  void _loadMore() {
    if (_loading || _exhausted) return;
    final kind = switch (_effectiveFilter) {
      _BrowseFilter.videos => LocalMediaItemKind.video,
      _BrowseFilter.images => LocalMediaItemKind.image,
      _ => null,
    };
    if (kind == null) return;

    _loading = true;
    try {
      final items = _queryPage(kind, _cursorOffset, _pageSize);
      (kind == LocalMediaItemKind.video ? _videos : _images).addAll(items);
      _cursorOffset += items.length;
      if (items.length < _pageSize) _exhausted = true;
    } finally {
      _loading = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// 换一档筛选：列表整只换人，所以回到顶上。
  ///
  /// ⛔ 不回顶的话，从"文件夹（218 个，滚到第 180 个）"切到"视频（只有 6 个）"，
  /// 新列表撑不出那么长的滚动区，位置被夹到底部——用户看到的是一片空白，以为
  /// 这一档什么都没有。
  void _switchFilter(_BrowseFilter next) {
    if (_filter == next) return;
    setState(() {
      _filter = next;
      _loadItems();
    });
    _resetScroll();
  }

  /// 列表整只换过人之后回到顶上。
  ///
  /// ⛔ **凡是会让列表变短的路径都得叫它**，不只是换筛选：换排序、搜索词生效、
  /// 清空搜索，三条都会把已经翻出来的几百条缩回第一页（[_loadItems] 不带
  /// `keepLoaded` 时只读 [_pageSize] 条）。不回顶的话 `maxScrollExtent` 塌下来，
  /// `ScrollPosition` 会把位置夹到新列表的**末尾**——用户换了个排序，视图直接落在
  /// 一堆毫不相干的内容的最后一行上。
  void _resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  // ── 目录内搜索 ──────────────────────────────────────────────────────────

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    // 260ms：比连续打字的间隔长，比"停手了"的感知阈值短。⛔ 别去掉去抖，理由
    // 见 [_query] 的文档。
    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      final next = _searchController.text.trim();
      if (next == _query) return;
      setState(() {
        _query = next;
        _loadItems();
        _recomputeVisibleChildren();
      });
      _resetScroll();
    });
  }

  void _clearSearch({bool rebuild = true}) {
    _searchDebounce?.cancel();
    _searchController.clear();
    final changed = _query.isNotEmpty || _searchOpen;
    _query = '';
    _searchOpen = false;
    if (!rebuild || !changed) return;
    setState(() {
      _loadItems();
      _recomputeVisibleChildren();
    });
    _resetScroll();
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
    unawaited(_loadDownloadedGalleries());
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

  // ── 排序记忆 ────────────────────────────────────────────────────────────
  //
  // 排序是**跨目录共享**的一档：用户切到「按大小」就是宣布自己此刻在找大文件，
  // 每进一层子目录都要重设一遍很荒谬。读不到就用默认档，一句错都不报。

  LocalMediaSort _restoreSort() {
    if (!Get.isRegistered<ConfigService>()) return LocalMediaSort.nameAsc;
    final stored =
        Get.find<ConfigService>()[ConfigKey.LOCAL_MEDIA_BROWSE_SORT_KEY];
    if (stored is! String) return LocalMediaSort.nameAsc;
    for (final sort in _browseSorts) {
      if (sort.name == stored) return sort;
    }
    return LocalMediaSort.nameAsc;
  }

  void _persistSort(LocalMediaSort sort) {
    if (!Get.isRegistered<ConfigService>()) return;
    Get.find<ConfigService>()[ConfigKey.LOCAL_MEDIA_BROWSE_SORT_KEY] =
        sort.name;
  }

  /// ⛔ 这一页的 ⋮ 菜单里**真的列得出来**的那几档。存档里是别的档（老版本写的、
  /// 或者哪天我们收窄了这张表）就退回默认——一个选不中的排序会让菜单里一条勾都
  /// 没有，而列表却按某种没人认得的顺序排着。
  static const List<LocalMediaSort> _browseSorts = <LocalMediaSort>[
    LocalMediaSort.nameAsc,
    LocalMediaSort.modifiedDesc,
    LocalMediaSort.sizeDesc,
  ];

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
    // ⚠️ 搜索着的时候池里仍是**整层**的视频，不是搜出来的那几条：池的身份只由
    // （来源 + 目录 + 排序）构成，没有"关键词"这一维，硬塞进去等于给每个关键词
    // 造一个池。代价是此刻按「下一个」可能跳到一条没在列表里的视频——比起为一次
    // 临时的查找污染池身份（它还要被播放器、抽屉、XR 面板三处认），这是轻的那头。
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

  /// 大图页的顺序必须与网格一致：同一个口径（来源 + 这一层 + [_sort]），不是
  /// 写死按名称排。
  ///
  /// ⛔ 不能只拿 [_images]：那只是已经翻出来的几页，点第 3 张开出来的相册会在
  /// 第 120 张戛然而止。[_imageViewerLimit] 是防一个几十万张的目录一次性把路径
  /// 全读进内存的上限。
  static const int _imageViewerLimit = 5000;

  void _openImage(LocalMediaItem item) {
    var paths = <String>[];
    try {
      paths = _repo
          .itemPathsPage(
            kind: LocalMediaItemKind.image,
            sourceId: widget.sourceId,
            folderPath: _folder?.folderPath,
            sort: _sort,
            // 搜索着的时候，相册里也只该有搜出来的那几张：网格上看得见的是什么，
            // 左右滑过去的就该是什么。
            nameQuery: _query.isEmpty ? null : _query,
            limit: _imageViewerLimit,
          )
          .map((row) => row.path)
          .toList();
    } catch (e) {
      LogUtils.w('读取大图页路径失败: $e', 'LocalFolderBrowsePage');
    }
    if (paths.isEmpty) paths = _images.map((e) => e.path).toList();
    openLocalImageViewer(context, paths, item.path);
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
        if (!mounted) return;
        setState(() {
          final videosBefore = _videos.length;
          final imagesBefore = _images.length;
          _videos.removeWhere((e) => e.id == deletedItem.id);
          _images.removeWhere((e) => e.id == deletedItem.id);
          final removedVideos = videosBefore - _videos.length;
          final removedImages = imagesBefore - _images.length;
          // 结果集缩短了：**正在翻页的那一类**删掉几条游标就退几条，否则下一页漏条。
          final removed = _effectiveFilter == _BrowseFilter.videos
              ? removedVideos
              : _effectiveFilter == _BrowseFilter.images
              ? removedImages
              : 0;
          _cursorOffset = math.max(0, _cursorOffset - removed);
          // 计数跟着走：不减的话「查看全部 96 个」会一直比实际多，而那一档点进去
          // 只有 95 条——一个永远对不上的数字比没有数字更让人疑心。
          _videoTotal = math.max(0, _videoTotal - removedVideos);
          _imageTotal = math.max(0, _imageTotal - removedImages);
          _videoCount = math.max(0, _videoCount - removedVideos);
          _imageCount = math.max(0, _imageCount - removedImages);
          // 删掉的正好是这一档的最后一条：这一档就此不存在了，得退回「全部」，
          // 否则筛选胶囊上那一段消失、整屏却报「这个文件夹是空的」（而这一层
          // 可能还有两百个子文件夹）。[_loadItems] 里那道归一化会接手。
          if (!_filterStillExists || _effectiveFilter != _loadedFilter) {
            _loadItems();
          }
        });
      },
    );
  }

  /// 拿这一条当目录封面时用哪张图。
  ///
  /// 图片就是它自己；视频用卡片上正显示的那张（[LocalMediaItem.coverImagePath]：
  /// 自定义封面 > sidecar > 抓帧缓存）——⛔ 别在这里另写一份优先级，卡片上看到
  /// 的和设成目录封面的必须是同一张。
  /// 视频还没派生出封面时返回 null——那一条菜单干脆不出现，比出现了点下去没反应好。
  String? _folderCoverSourceOf(LocalMediaItem item) {
    if (_folder == null) return null;
    if (item.kind == LocalMediaItemKind.image) {
      return item.path.isEmpty ? null : item.path;
    }
    final cover = item.coverImagePath;
    return cover == null || cover.isEmpty ? null : cover;
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
      setState(_loadFolderData);
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
    hidden: _isHidden,
    displayName: (_folder == null || _folder!.name.isEmpty)
        ? (_source?.displayName ?? '')
        : _folder!.name,
    canRescan: _source != null && Get.isRegistered<LocalMediaScanService>(),
    // 「移除来源」：只要当前脚下这个源不是内建源，随时支持从浏览页中移除。
    // 删完后 pop 弹回外层页面。
    onRemove: (_source != null && !_source!.isBuiltIn)
        ? () => unawaited(_removeThisSource())
        : null,
    // ⛔ 删的就是脚下这一层：留在原地是一屏空壳，而顶栏那些动作还都点得动
    // （同 [_removeThisSource] 里那条 pop 的理由）。
    onDeleted: () {
      if (mounted) appRouter.pop();
    },
    // 刚把**脚下这一层**藏起来：开关开着就留在原地（卡片会变半透明，取消隐藏
    // 的路还在原处），关着就得走——按约定这一层此刻不该存在，留着就是一页
    // 「从目录树里再也走不回来」的内容。
    onHidden: () {
      if (!mounted) return;
      if (_showHidden) {
        setState(_loadFolderData);
      } else {
        appRouter.pop();
      }
    },
    onChanged: () {
      if (!mounted) return;
      setState(_loadFolderData);
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
          _loadItems();
        });
        // 换了排序，第一页的内容跟刚才毫无关系——不回顶就会落在新列表的末尾。
        _resetScroll();
        _persistSort(selected);
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

  String get _emptyStateText => _scanning
      ? slang.t.localMedia.browse.scanning
      : _query.isNotEmpty
      ? slang.t.localMedia.browse.searchNoResult(query: _query)
      : _folder == null
      ? slang.t.localMedia.browse.notScannedYet
      : slang.t.localMedia.browse.emptyFolder;

  /// 当前这一档视图里一样东西都没有。
  ///
  /// ⛔ 不能只问「四个列表是不是都空」：筛在"文件夹"档时视频列表**本来就**是空的
  /// （[_loadItems] 根本没去读），照那个问法，一个有 96 个视频的目录切到文件夹档
  /// 会因为"文件夹是空的"之外的三个也空而显示整屏空态。
  bool get _currentViewIsEmpty => switch (_effectiveFilter) {
    _BrowseFilter.all =>
      _visibleChildren.isEmpty &&
          _videos.isEmpty &&
          _images.isEmpty &&
          _visibleGalleries.isEmpty,
    _BrowseFilter.folders => _visibleChildren.isEmpty,
    _BrowseFilter.videos => _videos.isEmpty,
    _BrowseFilter.images => _images.isEmpty,
    _BrowseFilter.galleries => _visibleGalleries.isEmpty,
  };

  /// 这一层一共有多少样东西（不含搜索词）。只用来决定"要不要给搜索留个入口"。
  int get _totalEntryCount =>
      _probedChildren.length + _videoTotal + _imageTotal + _galleries.length;

  /// 顶栏第二行（筛选 + 搜索）在不在场。**只上不下**，换一层目录才复位。
  ///
  /// ⛔ 不能让 build 直接按当下的计数算：进这一层的头一两秒还在扫，计数全是 0
  /// ——那一行会先不在、扫完再冒出来，把整片内容往下顶一截。它的高度是
  /// `headerExtent` 的一部分，跳的是**整页**，不是一行。
  /// 一旦够格就钉住：这一层后来即使被删空，多出一行搜索框也好过当场跳一下。
  bool _toolRowLatched = false;

  void _updateToolRowLatch() {
    if (_toolRowLatched) return;
    if (_segments.length >= 3 || _totalEntryCount > 24 || _query.isNotEmpty) {
      _toolRowLatched = true;
    }
  }

  /// 筛选胶囊上摆哪几段。
  ///
  /// **有没有这一段**看的是不带搜索词的总数（[_videoTotal] 那一族），**段上写的数**
  /// 才跟着搜索词走——否则用户每敲一个字，整行胶囊就少一段、宽度跟着抖一下。
  List<({_BrowseFilter filter, String label, IconData icon})> get _segments {
    final t = slang.t.localMedia.browse;
    return <({_BrowseFilter filter, String label, IconData icon})>[
      (
        filter: _BrowseFilter.all,
        label: t.filterAll,
        icon: Icons.apps_outlined,
      ),
      if (_probedChildren.isNotEmpty)
        (
          filter: _BrowseFilter.folders,
          label: '${t.sourcesSection} ${_visibleChildren.length}',
          icon: Icons.folder_outlined,
        ),
      if (_galleries.isNotEmpty)
        (
          filter: _BrowseFilter.galleries,
          label: '${t.galleriesSection} ${_visibleGalleries.length}',
          icon: Icons.collections_bookmark_outlined,
        ),
      if (_videoTotal > 0)
        (
          filter: _BrowseFilter.videos,
          label: '${t.videosSection} $_videoCount',
          icon: Icons.video_library_outlined,
        ),
      if (_imageTotal > 0)
        (
          filter: _BrowseFilter.images,
          label: '${t.imagesSection} $_imageCount',
          icon: Icons.photo_library_outlined,
        ),
    ];
  }

  /// 「查看全部 N 个 ›」——预览视图里每个区块的收尾。
  ///
  /// ⛔ 它不是"展开这一段"，而是**切到那一档**：展开 1243 张图片仍旧会把下面的
  /// 区块推到天边去，那正是这次要解决的毛病。
  Widget _buildViewAllSliver(String label, _BrowseFilter target) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Align(
          alignment: Alignment.center,
          child: GlassButtonGroup(
            children: [
              GlassTextActionButton(
                label: label,
                onPressed: () => _switchFilter(target),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 顶栏两行之间的缝。与 `local_home_page.dart` 的 `_headerRowGap` 同值——两页
  /// 的 header 上下相连（从根页点进来），缝不一样宽会在切换的那一下看出跳动。
  static const double _toolRowGap = 6;

  /// 没有区块标题时，内容与 header 之间的缝。
  static const double _contentTopGap = 12;

  /// 顶栏第二行：筛选胶囊 + 搜索。两者**互斥地占用这一行**。
  ///
  /// ⛔ 别想把它们并排塞进去：窄屏上 5 段胶囊本来就要退化成下拉钮，再分一半宽度
  /// 给输入框，剩下的够写三个字。
  Widget _buildToolRow(
    BuildContext context,
    List<({_BrowseFilter filter, String label, IconData icon})> segments,
    bool showSegments,
  ) {
    final t = slang.t.localMedia.browse;
    final colorScheme = Theme.of(context).colorScheme;

    // 没有可筛的东西（只有一类）时，这一行本来就是为搜索而在的，不必再点一下展开。
    final bool searchTakesRow = _searchOpen || !showSegments;
    if (searchTakesRow) {
      return Row(
        children: [
          Expanded(
            // 取焦层包在玻璃**外面**：内边距在 child 外层，当 child 会漏掉左边
            // 那一条最常被点到的死区（见 [GlassSearchPillTapArea] 的类注释）。
            child: GlassSearchPillTapArea(
              focusNode: _searchFocus,
              child: GlassSurface(
                height: GlassTokens.pillHeight,
                borderRadius: BorderRadius.circular(GlassTokens.pillHeight / 2),
                padding: const EdgeInsets.only(left: 12, right: 6),
                liquidTouch: false,
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassSearchInputField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        hintText: t.searchHint,
                        onChanged: _onSearchChanged,
                        // 这里的回车不"提交"——结果早就跟着输入变了。它只是收键盘。
                        onSubmitted: (_) => _searchFocus.unfocus(),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: t.clearSearch,
                        onPressed: () {
                          _searchDebounce?.cancel();
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _loadItems();
                            _recomputeVisibleChildren();
                          });
                          _searchFocus.requestFocus();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (showSegments) ...[
            const SizedBox(width: 8),
            GlassButtonGroup(
              children: [
                GlassIconButton(
                  icon: const Icon(Icons.close),
                  tooltip: t.clearSearch,
                  onPressed: _clearSearch,
                ),
              ],
            ),
          ],
        ],
      );
    }

    final selected = segments.indexWhere((s) => s.filter == _filter);
    return Row(
      children: [
        Expanded(
          child: GlassAdaptiveSegmentedControl(
            // ⛔ 找不到就落回 0（「全部」）。重扫之后某一类可能整个消失，而
            // `_filter` 还指着它——传 -1 进去分段控件会画不出高亮块。
            selectedIndex: selected < 0 ? 0 : selected,
            onChanged: (index) => _switchFilter(segments[index].filter),
            items: <GlassSegmentItem>[
              for (final segment in segments)
                GlassSegmentItem(
                  label: segment.label,
                  icon: Icon(segment.icon),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GlassButtonGroup(
          children: [
            GlassIconButton(
              icon: const Icon(Icons.search),
              tooltip: t.searchInFolder,
              onPressed: () {
                setState(() => _searchOpen = true);
                // 展开那一帧输入框还没进树，这一下取焦得等它落位。
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocus.requestFocus();
                });
              },
            ),
          ],
        ),
      ],
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
    final segments = _segments;
    // 第二行（筛选 + 搜索）什么时候在场：混着两类以上东西时要筛，东西多到一屏
    // 翻不完时要搜。两个条件都不成立的小目录（三五个视频）就不该多这一行。
    final bool showSegments = segments.length >= 3;
    // ⛔ 读的是钉住的那个，不是当下现算的——理由见 [_toolRowLatched]。
    final bool showToolRow = _toolRowLatched;
    final double headerHeight =
        GlassTokens.headerRowHeight +
        (showToolRow ? _toolRowGap + GlassTokens.pillHeight : 0);
    final double headerExtent = statusBarHeight + headerHeight;

    final String currentTitle = _queueTitle;

    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        headerHeight: headerHeight,
        solidExtent: statusBarHeight,
        header: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: GlassTokens.headerRowHeight,
              child: Padding(
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
                            icon: Icon(
                              _isPinned ? Icons.star : Icons.star_border,
                            ),
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
            ),
            if (showToolRow) ...[
              const SizedBox(height: _toolRowGap),
              SizedBox(
                height: GlassTokens.pillHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildToolRow(context, segments, showSegments),
                ),
              ),
            ],
          ],
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

              // ── 这一屏画哪几块、每块画几个 ──────────────────────────────
              //
              // 「全部」＝预览：四块都在，每块最多 [_previewRows] 行，末尾一条
              // 「查看全部」。选了某一类＝只有那一块，完整、可无限翻页。
              final effective = _effectiveFilter;
              final bool preview = effective == _BrowseFilter.all;
              final int previewCap = _previewRows * crossAxisCount;
              int shownOf(int length, bool visible) => visible
                  ? (preview ? math.min(length, previewCap) : length)
                  : 0;

              final int galleryShown = shownOf(
                _visibleGalleries.length,
                preview || effective == _BrowseFilter.galleries,
              );
              final int folderShown = shownOf(
                _visibleChildren.length,
                preview || effective == _BrowseFilter.folders,
              );
              final int videoShown = shownOf(
                _videos.length,
                preview || effective == _BrowseFilter.videos,
              );
              final int imageShown = shownOf(
                _images.length,
                preview || effective == _BrowseFilter.images,
              );

              // 区块标题只在预览视图里、且这一屏不止一块时出现：只有一块时标题
              // 是废话（上面的筛选胶囊已经写着它是什么），选了某一类时更是。
              final int sectionCount =
                  (galleryShown > 0 ? 1 : 0) +
                  (folderShown > 0 ? 1 : 0) +
                  (videoShown > 0 ? 1 : 0) +
                  (imageShown > 0 ? 1 : 0);
              final bool showHeaders = preview && sectionCount > 1;
              final t = slang.t.localMedia.browse;

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 有区块标题时，缝由标题自己的上边距给；没有时（只有一类东西、
                  // 或选了某一档）第一排卡片会直接贴着 header 的下沿——留一道与
                  // `local_home_page.dart` 同宽的缝。
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: headerExtent + (showHeaders ? 0 : _contentTopGap),
                    ),
                  ),
                  // ⛔ 这里原先顶着一条 `LinearProgressIndicator(minHeight: 2)`。
                  // 已经删掉——「还在扫」现在画在 header 的标题胶囊上（见上面的
                  // `busy: _scanning`）。那条横线不属于任何东西、出现消失还是硬
                  // 切，把它底下整列内容顶上顶下。别再加回来。
                  if (_needsRescanForTree) _buildRescanHint(context),
                  if (galleryShown > 0) ...[
                    if (showHeaders) _buildSectionHeader(t.galleriesSection),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: folderMetrics.delegate(
                          DownloadedGalleryCard.extentFor(
                            context,
                            folderMetrics.cellWidth,
                          ),
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final gallery = _visibleGalleries[index];
                          return DownloadedGalleryCard(
                            row: gallery,
                            onDeleted: () {
                              if (mounted) {
                                setState(() {
                                  _galleries = _galleries
                                      .where((e) => e.taskId != gallery.taskId)
                                      .toList();
                                  _recomputeVisibleChildren();
                                });
                              }
                            },
                          );
                        }, childCount: galleryShown),
                      ),
                    ),
                    if (_visibleGalleries.length > galleryShown)
                      _buildViewAllSliver(
                        t.viewAllGalleries(count: _visibleGalleries.length),
                        _BrowseFilter.galleries,
                      ),
                  ],
                  if (folderShown > 0) ...[
                    if (showHeaders) _buildSectionHeader(t.sourcesSection),
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
                              hidden: _hiddenRelPaths.contains(child.relPath),
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
                                  hidden: _hiddenRelPaths.contains(
                                    child.relPath,
                                  ),
                                  displayName: child.name.isEmpty
                                      ? (_source?.displayName ?? '')
                                      : child.name,
                                  canRescan: true,
                                  onChanged: _reloadFromDb,
                                ),
                              ),
                            ),
                          );
                        }, childCount: folderShown),
                      ),
                    ),
                    if (_visibleChildren.length > folderShown)
                      _buildViewAllSliver(
                        t.viewAllFolders(count: _visibleChildren.length),
                        _BrowseFilter.folders,
                      ),
                  ],
                  if (videoShown > 0) ...[
                    if (showHeaders) _buildSectionHeader(t.videosSection),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: MediaWaterfallSliver(
                        crossAxisCount: crossAxisCount,
                        itemCount: videoShown,
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
                    // ⛔ 必须夹一道 `preview`：视频档下列表本来就是分页的
                    // （首屏 120 条 / 总数 96 以上），不夹的话完整视图底下会一直
                    // 挂着一条「查看全部 500 个」——而用户正在看的就是那 500 个。
                    if (preview && _videoCount > videoShown)
                      _buildViewAllSliver(
                        t.viewAllVideos(count: _videoCount),
                        _BrowseFilter.videos,
                      ),
                  ],
                  if (imageShown > 0) ...[
                    if (showHeaders) _buildSectionHeader(t.imagesSection),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: MediaWaterfallSliver(
                        crossAxisCount: crossAxisCount,
                        itemCount: imageShown,
                        itemBuilder: (context, index, itemWidth) {
                          final item = _images[index];
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
                                      child: LocalCoverImage(
                                        path: item.path,
                                        placeholder: _buildImagePlaceholder(
                                          context,
                                        ),
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
                    if (preview && _imageCount > imageShown)
                      _buildViewAllSliver(
                        t.viewAllImages(count: _imageCount),
                        _BrowseFilter.images,
                      ),
                  ],
                  // ⛔ 这里没有加载指示器，也不该有：[_loadMore] 从头到尾是同步的
                  // （sqlite3 在主 isolate 上是同步 API），`_loading` 只在那一个
                  // 函数调用栈内为真，build 时永远读到 false——画出来的转圈是一帧
                  // 都不会出现的死代码。翻页那一下的代价是主线程阻塞，不是等待。
                  if (_currentViewIsEmpty)
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
                            //
                            // ⛔ 转圈 ↔ 空夹子、「正在读取」↔「是空的」都走
                            // AnimatedSwitcher，不许硬切：扫完那一下正是用户
                            // 盯着看的时刻。
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: _scanning
                                  ? const GlassSpinningArc(
                                      key: ValueKey<String>('empty_scanning'),
                                      size: 36,
                                    )
                                  : Icon(
                                      Icons.folder_open_outlined,
                                      key: const ValueKey<String>('empty_idle'),
                                      size: 64,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                            ),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: Builder(
                                key: ValueKey<String>(_emptyStateText),
                                builder: (context) => Text(
                                  _emptyStateText,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
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
