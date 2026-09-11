import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/ios_folder_picker_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/local_media/local_folder_route.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/downloaded_gallery_wall.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_directory_picker_dialog.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_menu.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_wall.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_sort_controls.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_source_card.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/identity_avatar_button.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/device_form_factor_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 本机文件栏目的根页面，等价于文件管理器的「设备根」。
///
/// 上半部分展示用户置顶的常用目录（快捷入口），主体部分展示所有已添加的媒体来源。
/// 添加目录、添加媒体库、移除来源、重新扫描与清理记录等管理动作均直接收敛在根这一层，
/// 因此不再设立单独的「管理来源」页面。
/// 点击来源行将直接进入对应源的根目录浏览，兼顾管理与导航职责。
class LocalHomePage extends StatefulWidget implements HomeWidgetInterface {
  const LocalHomePage({super.key, this.contentResetVersion = 0});

  static final GlobalKey<State<LocalHomePage>> globalKey =
      GlobalKey<State<LocalHomePage>>();

  final int contentResetVersion;

  @override
  void refreshCurrent() {
    final state = globalKey.currentState;
    if (state is _LocalHomePageState) {
      state.refreshCurrent();
    }
  }

  @override
  State<LocalHomePage> createState() => _LocalHomePageState();
}

class _LocalHomePageState extends State<LocalHomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const String _tag = 'LocalHomePage';
  static const double _headerRowGap = 6;

  late TabController _tabController;

  /// 栏目。⛔ 顺序就是 [_tabIndex] 那几个常量，改这里必须一起改那边。
  ///
  /// 「常用目录」2026-09-11 从「文件目录」里**搬出来**单独成栏（用户要求）：
  /// 它原来是文件目录页顶上的一个区块，和下面的来源网格挤在一起，置顶多了就把
  /// 真正的来源压到屏幕外面。搬出来之后文件目录那一栏只剩「文件夹」一个区块。
  static const int _tabFolders = 0;
  static const int _tabPinned = 1;
  static const int _tabFavoriteVideos = 2;
  static const int _tabAllVideos = 3;
  static const int _tabAllImages = 4;
  static const int _tabDownloadedVideos = 5;
  static const int _tabDownloadedGalleries = 6;
  static const int _tabCount = 7;

  LocalMediaOrder _favVideoOrder = const LocalMediaOrder(
    LocalMediaSortField.favorited,
    ascending: false,
  );
  LocalMediaOrder _downloadedVideoOrder = const LocalMediaOrder(
    LocalMediaSortField.modified,
    ascending: false,
  );
  LocalMediaOrder _allVideoOrder = const LocalMediaOrder(
    LocalMediaSortField.modified,
    ascending: false,
  );
  LocalMediaOrder _allImageOrder = const LocalMediaOrder(
    LocalMediaSortField.modified,
    ascending: false,
  );

  static const List<LocalMediaSortField> _imageSortFields = [
    LocalMediaSortField.name,
    LocalMediaSortField.modified,
    LocalMediaSortField.size,
    LocalMediaSortField.resolution,
    LocalMediaSortField.fileType,
  ];

  static const List<LocalMediaSortField> _videoSortFields = [
    LocalMediaSortField.name,
    LocalMediaSortField.modified,
    LocalMediaSortField.duration,
    LocalMediaSortField.size,
    LocalMediaSortField.resolution,
    LocalMediaSortField.fileType,
    LocalMediaSortField.fps,
  ];

  static const List<LocalMediaSortField> _favVideoSortFields = [
    ..._videoSortFields,
    LocalMediaSortField.favorited,
  ];

  final LocalMediaRepository _repository = LocalMediaRepository();
  final ScrollController _scrollController = ScrollController();

  /// ⛔ 「常用目录」那一栏要有**自己**的滚动控制器：一个 ScrollController 同时挂
  /// 到两条还活着的滚动视图上，`animateTo` 会当场抛断言（TabBarView 会把相邻页
  /// 一起保活）。
  final ScrollController _pinnedScrollController = ScrollController();

  List<LocalMediaSource> _sources = const <LocalMediaSource>[];
  List<LocalPinnedFolder> _pinnedFolders = const <LocalPinnedFolder>[];

  /// 常用目录的目录行，键是 `sourceId\u0000relPath`，随 [_reloadPinnedFolders] 一起算。
  ///
  /// ⛔ 不要在 build 里现查 `getFolder()`：sqlite3 在主 isolate 上是同步的，
  /// 而常用目录那一格格卡片在滚动中每帧都要重建——现查就是每帧 N 次同步查询
  /// 卡在光栅前面。置顶目录本来就没几个，一次性查完存着即可。
  Map<String, LocalMediaFolder> _pinnedFolderRows =
      const <String, LocalMediaFolder>{};

  /// 哪些「源 + 相对路径」被设为常用了，键同 [_pinKey]。
  ///
  /// ⛔ 预先算好而不是在卡片 build 里 `_pinnedFolders.any(...)` 现找：来源网格在
  /// 滚动中每帧重建每一格，线性找就是每帧 N×M 次比较。这一份随
  /// [_reloadPinnedFolders] 一起更新。
  Set<String> _pinnedKeys = const <String>{};

  /// 每个来源的封面与条目数，随 [_reloadSources] 一起算一次。
  ///
  /// ⛔ 不要在 build 里现查：sqlite3 在主 isolate 上是同步的，卡片在滚动中反复
  /// build，现查就是每帧 N 次同步查询卡在光栅前面。来源本来就没几个，一次性
  /// 查完存着即可。
  Map<String, ({String? cover, int videos, int images})> _sourceStats =
      const {};
  bool _addingSource = false;
  bool _permissionDenied = false;
  String? _scanningSourceId;
  Worker? _scanWorker;
  Worker? _repoWorker;
  Worker? _folderWorker;
  List<String>? _cachedCandidates;

  /// 后台探测在飞——防止每一帧都丢一个任务出去。
  bool _candidatesPending = false;

  /// 正在等「从系统页回来」的那一次。见 [_requestStoragePermissionResilient]。
  Completer<void>? _resumeSignal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
    _reloadSources();
    _reloadPinnedFolders();
    if (Get.isRegistered<LocalMediaScanService>()) {
      _scanWorker = ever<LocalMediaScanProgress?>(
        LocalMediaScanService.to.progress,
        _onScanProgress,
      );
    }
    // ⛔ 这里必须 debounce，不能用 ever。
    //
    // `changeRevision` 是**逐批**发的：扫描器每落一批条目就走一次
    // `upsertItems` → `notifyChanged()`，扫一个大目录能发出几百次。用 ever
    // 接就是几百次「重查来源 + 重查常用目录 + 整页 setState」，正好压在扫描
    // 本来就吃紧的主 isolate 上。这一页要的只是「事情消停之后对一次账」，
    // 400ms 的静默窗口足够，也不会让跨页置顶/取消置顶的同步显得迟钝。
    _repoWorker = debounce<int>(LocalMediaRepository.changeRevision, (_) {
      _reloadSources();
      _reloadPinnedFolders();
    }, time: const Duration(milliseconds: 400));
    // 目录行的变化（封面回填、pin）走**另一条**信号，见 [LocalMediaRepository
    // .folderRevision]。这一页的置顶目录卡片要跟着换封面，来源计数则与它无关，
    // 所以只重查置顶那一半。
    _folderWorker = debounce<int>(
      LocalMediaRepository.folderRevision,
      (_) => _reloadPinnedFolders(),
      time: const Duration(milliseconds: 400),
    );
    unawaited(_syncDownloads());
  }

  @override
  void didUpdateWidget(covariant LocalHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contentResetVersion != oldWidget.contentResetVersion) {
      refreshCurrent();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;

    _resumeSignal?.complete();
    _resumeSignal = null;

    // ⛔ 兜底：`_addingSource` 是「添加文件夹」那颗钮的禁用条件，它**绝不能**
    // 因为某个永不完成的 await 卡在 true 上。
    //
    // 真机上就这么坏过（2026-09-10，Quest）：点了添加 → 系统页弹出来 → 回来之后
    // 那颗钮一直是灰的，怎么点都没反应，只能杀进程。根因是下面那条注释里说的
    // 「系统页不回结果」，但**不管根因是什么**，回到前台就意味着那次交互已经结束，
    // 旗子必须落下来。重复添加没有危险：`findOverlappingSource` 拦得住。
    if (_addingSource && mounted) {
      setState(() => _addingSource = false);
    }
  }

  /// 请求「所有文件访问权限」，并且**不把自己压在一个可能永不完成的 future 上**。
  ///
  /// ⛔ 那张系统页没有 onActivityResult 可回（Quest 的沉浸 Activity 上尤其明显：
  /// 它开在另一个虚拟显示上，结果回不到发起方）。`permission_handler` 的
  /// `request()` 因此可能一直挂着——挂住了，调用它的 `try/finally` 就永远跑不到
  /// `finally`，旗子落不下来。
  ///
  /// 所以判据换成「谁先到算谁」：要么 request 自己回来，要么用户回到前台、我们
  /// 直接重新查一次状态。
  Future<bool> _requestStoragePermissionResilient(
    PermissionService permission,
  ) async {
    final resumed = Completer<void>();
    _resumeSignal = resumed;
    try {
      final result = await Future.any<bool?>(<Future<bool?>>[
        permission.requestStoragePermission(),
        resumed.future.then<bool?>((_) => null),
      ]);
      if (result != null) return result;
      return await permission.hasStoragePermission();
    } finally {
      if (identical(_resumeSignal, resumed)) _resumeSignal = null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _resumeSignal = null;
    _scanWorker?.dispose();
    _repoWorker?.dispose();
    _folderWorker?.dispose();
    _scrollController.dispose();
    _pinnedScrollController.dispose();
    super.dispose();
  }

  void refreshCurrent() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    _reloadSources();
    _reloadPinnedFolders();
  }

  void _reloadSources() {
    if (!mounted) return;
    final sources = _repository.getSources();
    final stats = <String, ({String? cover, int videos, int images})>{};
    for (final source in sources) {
      final videos = _repository.countItems(
        sourceId: source.id,
        kind: LocalMediaItemKind.video,
      );
      final images = _repository.countItems(
        sourceId: source.id,
        kind: LocalMediaItemKind.image,
      );
      String? cover = _repository
          .getFolder(sourceId: source.id, relPath: '')
          ?.coverPath;
      if (cover == null || cover.isEmpty) {
        final videoItems = _repository.queryItems(
          sourceId: source.id,
          kind: LocalMediaItemKind.video,
          sort: LocalMediaSort.addedDesc,
          offset: 0,
          limit: 1,
        );
        if (videoItems.isNotEmpty) {
          cover =
              videoItems.first.sidecarImagePath ?? videoItems.first.thumbPath;
        }
      }
      if (cover == null || cover.isEmpty) {
        final imageItems = _repository.queryItems(
          sourceId: source.id,
          kind: LocalMediaItemKind.image,
          sort: LocalMediaSort.addedDesc,
          offset: 0,
          limit: 1,
        );
        if (imageItems.isNotEmpty) {
          cover = imageItems.first.path;
        }
      }
      stats[source.id] = (cover: cover, videos: videos, images: images);
    }
    setState(() {
      _sources = sources;
      _sourceStats = stats;
      if (_sources.isNotEmpty) _cachedCandidates = null;
    });
  }

  void _reloadPinnedFolders() {
    if (!mounted) return;
    final pinned = _repository.getPinnedFolders();
    final rows = <String, LocalMediaFolder>{};
    for (final folder in pinned) {
      final row =
          _repository.getFolder(
            sourceId: folder.sourceId,
            relPath: folder.relPath,
          ) ??
          _syntheticSourceRoot(folder);
      if (row != null) {
        rows[_pinKey(folder.sourceId, folder.relPath)] = row;
      }
    }
    setState(() {
      _pinnedFolders = pinned;
      _pinnedFolderRows = rows;
      _pinnedKeys = <String>{
        for (final folder in pinned) _pinKey(folder.sourceId, folder.relPath),
      };
    });
  }

  /// 置顶的是一个**没有目录行**的来源根，替它现编一行。
  ///
  /// # ⛔ 「查不到目录行」不等于「这个目录没了」
  ///
  /// 「已下载」和「设备视频」这两类源本来就一行 `local_media_folders` 都不写
  /// （前者从 `download_tasks` 同步、后者是系统媒体索引，都没有真实目录树，见
  /// `DownloadsLibrarySyncService` 与 `LocalMediaScanService._scanMediaStoreSource`）。
  /// 拿"查不到"当"不存在"，卡片就会被 `missing` 画成半透明的灰——而它明明点得进去，
  /// 里面也有东西（2026-09-11 用户报的正是这个）。
  ///
  /// 这个洞是今天才够得着的：以前只有真实子目录能设为常用，那些一定有目录行；
  /// 来源根能设为常用是今天才加的（见 [_openSourceMenu]）。
  ///
  /// 真的没了只有一种：**源本身被删了**。那时才返回 null，由调用点那条
  /// `missing: true` 的兜底接手。
  LocalMediaFolder? _syntheticSourceRoot(LocalPinnedFolder pinned) {
    // 只有根这一层配得上这条退路。更深的一层查不到目录行是真的出了问题
    // （同 `PlaybackQueueDrawer._loadLocalLevel` 里那条"只在源根退化"）。
    if (pinned.relPath.isNotEmpty) return null;
    final source = _repository.getSource(pinned.sourceId);
    if (source == null) return null;
    final name = pinned.displayName.isNotEmpty
        ? pinned.displayName
        : source.displayName;
    final stats = _sourceStats[source.id];
    return LocalMediaFolder(
      id: LocalMediaFolder.buildId(source.id, ''),
      sourceId: source.id,
      relPath: '',
      name: name,
      sortName: name.toLowerCase(),
      folderPath: source.path,
      // 计数与封面直接借来源那一份（[_reloadSources] 已经算过，别再查一遍库）。
      videoCount: stats?.videos ?? 0,
      imageCount: stats?.images ?? 0,
      coverPath: stats?.cover,
      // ⛔ `probed` 必须是真：写 null 的话计数行会变成空串，卡片上只剩一个名字。
      probedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static String _pinKey(String sourceId, String relPath) =>
      '$sourceId\u0000$relPath';

  void _onScanProgress(LocalMediaScanProgress? progress) {
    if (!mounted || progress == null) return;
    setState(() {
      _scanningSourceId = progress.finished ? null : progress.sourceId;
    });
    if (!progress.finished) return;
    _reloadSources();
    _reloadPinnedFolders();
    if (progress.error != null) {
      showAppToast(
        slang.t.localMedia.scanFailed(reason: progress.error!),
        type: AppToastType.error,
      );
    } else if (progress.truncated) {
      showAppToast(
        slang.t.localMedia.scanTruncated(count: kMaxScanFiles),
        type: AppToastType.info,
      );
    }
  }

  Future<void> _syncDownloads() async {
    if (!Get.isRegistered<DownloadsLibrarySyncService>()) return;
    await DownloadsLibrarySyncService.to.sync();
    if (mounted) {
      _reloadSources();
      _reloadPinnedFolders();
    }
  }

  /// 添加目录。候选目录传入时直接添加，不再把用户扔进系统选择器。
  Future<void> _addSource([String? candidatePath]) async {
    if (_addingSource) return;
    setState(() => _addingSource = true);
    try {
      if (GetPlatform.isIOS) {
        final pickedResult = await IosFolderPickerService.to.pickFolder();
        if (pickedResult == null) return;
        final picked = pickedResult.path;
        final overlapping = _repository.findOverlappingSource(picked);
        if (overlapping != null) {
          showAppToast(
            slang.t.localMedia.sourceOverlaps(name: overlapping.displayName),
            type: AppToastType.error,
          );
          return;
        }

        final source = LocalMediaSource(
          id: const Uuid().v4(),
          kind: LocalMediaSourceKind.bookmark,
          displayName: pickedResult.displayName.isNotEmpty
              ? pickedResult.displayName
              : (p.basename(picked).isEmpty ? picked : p.basename(picked)),
          path: picked,
          uri: pickedResult.bookmark,
          mediaKinds: LocalMediaKinds.both,
          sortOrder: _sources.where((source) => !source.isBuiltIn).length,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        _repository.upsertSource(source);
        _reloadSources();
        _reloadPinnedFolders();
        unawaited(_scan(source));
        return;
      }

      final permission = Get.find<PermissionService>();
      if (!await permission.hasStoragePermission()) {
        final granted = await _requestStoragePermissionResilient(permission);
        if (!granted) {
          if (mounted) setState(() => _permissionDenied = true);
          return;
        }
      }
      if (mounted) setState(() => _permissionDenied = false);

      // 为什么不走 SAF：Quest 头显上系统 documentsui 选择器在手柄射线点击下无响应，
      // 用户无法选中任何文件夹；且应用已持有 MANAGE_EXTERNAL_STORAGE（所有文件访问权限），
      // 本来就能直接走文件系统，故优先使用应用内的文件夹选择器，不再依赖有缺陷的系统 UI。
      final picked =
          candidatePath ??
          (mounted
              ? await showLocalDirectoryPickerDialog(context: context)
              : null);
      if (picked == null || picked.isEmpty) return;
      final overlapping = _repository.findOverlappingSource(picked);
      if (overlapping != null) {
        showAppToast(
          slang.t.localMedia.sourceOverlaps(name: overlapping.displayName),
          type: AppToastType.error,
        );
        return;
      }

      final source = LocalMediaSource(
        id: const Uuid().v4(),
        kind: LocalMediaSourceKind.directory,
        displayName: p.basename(picked).isEmpty ? picked : p.basename(picked),
        path: picked,
        mediaKinds: LocalMediaKinds.both,
        sortOrder: _sources.where((source) => !source.isBuiltIn).length,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _repository.upsertSource(source);
      _reloadSources();
      _reloadPinnedFolders();
      unawaited(_scan(source));
    } catch (e, s) {
      LogUtils.e('添加本地源失败', tag: _tag, error: e, stackTrace: s);
      showAppToast(
        slang.t.localMedia.addSourceFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _addingSource = false);
    }
  }

  Future<void> _scan(LocalMediaSource source) async {
    if (!mounted || !Get.isRegistered<LocalMediaScanService>()) return;
    setState(() => _scanningSourceId = source.id);
    try {
      await LocalMediaScanService.to.scanSource(source);
    } catch (e, s) {
      LogUtils.e('扫描本地源失败', tag: _tag, error: e, stackTrace: s);
    } finally {
      // ⛔ 不能只靠进度广播的 `finished` 复位（见 [_onScanProgress]）：
      // `scanSource` 抛异常、或它在还没发出第一条进度前就早退，广播根本不会来，
      // 源卡片会永远转圈，而 `canRescan` 又恒 false——那张卡就此点不动了。
      if (mounted && _scanningSourceId == source.id) {
        setState(() => _scanningSourceId = null);
      }
    }
  }

  Future<void> _addMediaStoreSource() async {
    if (_addingSource) return;
    final t = slang.t.localMedia;
    // 入口在 XR 上已经藏掉了（[_canScanDeviceVideos]），这里是兜底：万一哪天有别的
    // 调用点，也绝不能把用户送进那张会让整块面板变品红的系统权限页。
    if (!_canScanDeviceVideos) {
      showAppToast(t.mediaStoreUnavailable, type: AppToastType.info);
      return;
    }

    setState(() => _addingSource = true);
    try {
      final permission = Get.find<PermissionService>();
      if (!await permission.hasMediaStorePermission() &&
          !await permission.requestMediaStorePermission()) {
        showAppToast(t.mediaStorePermissionDenied, type: AppToastType.error);
        return;
      }

      final existing = _repository.getSource(kAndroidMediaStoreSourceId);
      final source =
          existing ??
          LocalMediaSource(
            id: kAndroidMediaStoreSourceId,
            kind: LocalMediaSourceKind.mediastore,
            displayName: t.mediaStoreSourceName,
            uri: 'content://media/external/video/media',
            sortOrder: _sources.where((source) => !source.isBuiltIn).length,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );
      _repository.upsertSource(source);
      _reloadSources();
      _reloadPinnedFolders();
      unawaited(_scan(source));
    } catch (e, s) {
      LogUtils.e('添加 MediaStore 源失败', tag: _tag, error: e, stackTrace: s);
      showAppToast(t.addSourceFailed, type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _addingSource = false);
    }
  }

  Future<void> _rescan(LocalMediaSource source) async {
    if (source.kind == LocalMediaSourceKind.downloads) {
      await _syncDownloads();
      return;
    }
    await _scan(source);
  }

  /// 移除一个来源。确认与删除都在 [confirmAndRemoveLocalSource] 里——目录详情页
  /// 顶栏那条走的是同一份，这边只负责删完之后重查列表。
  Future<void> _remove(LocalMediaSource source) async {
    final removed = await confirmAndRemoveLocalSource(
      context: context,
      source: source,
    );
    if (!removed || !mounted) return;
    _reloadSources();
    _reloadPinnedFolders();
  }

  Future<void> _clearProgress() async {
    final t = slang.t.localMedia;
    final count = _repository.progressCount();
    if (count == 0) {
      showAppToast(t.clearProgressEmpty, type: AppToastType.info);
      return;
    }
    final confirmed = await showGlassAlertDialog<bool>(
      title: t.clearProgressTitle,
      content: Text(t.clearProgressBody),
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
        GlassDialogAction(
          label: t.clearAction,
          destructive: true,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    final removed = _repository.clearAllProgress();
    if (Get.isRegistered<PlaybackQueueService>()) {
      PlaybackQueueService.to.invalidateLocalLibraryProgress();
    }
    showAppToast(t.clearProgressDone(count: removed));
  }

  /// 来源卡的「更多操作」。
  ///
  /// ⛔ 走 [LocalFolderActions]（和子目录卡、详情页同一份），**不要**在这里另写一
  /// 张菜单：上一版就是这么写的，结果它只有「重新扫描 / 移除」两条——想把一个来源
  /// 设为常用，用户必须先点进详情页去按那颗 ☆（2026-09-11 用户报的）。
  ///
  /// 来源根的相对路径是空串，这也正是 [LocalFolderActions] 用来分辨"整源重扫 vs
  /// 只重列这一层"的判据。
  Future<void> _openSourceMenu(
    BuildContext anchorContext,
    LocalMediaSource source,
  ) async {
    final root = _repository.getFolder(sourceId: source.id, relPath: '');
    await showLocalFolderMenu(
      anchorContext: anchorContext,
      actions: LocalFolderActions(
        sourceId: source.id,
        relPath: '',
        folderPath: root?.folderPath ?? source.path,
        pinned: _pinnedKeys.contains(_pinKey(source.id, '')),
        coverPinned: root?.coverPinned ?? false,
        displayName: source.displayName,
        canRescan: _scanningSourceId == null,
        // 「已下载」不走扫描器，它是从 download_tasks 同步过来的。
        onRescan: () => _rescan(source),
        onRemove: source.isBuiltIn ? null : () => unawaited(_remove(source)),
        onChanged: () {
          if (!mounted) return;
          _reloadSources();
          _reloadPinnedFolders();
        },
      ),
    );
  }

  /// 这台设备上「扫描设备视频」这条路走不走得通。
  ///
  /// # ⛔ XR 头显上必须整条藏掉，不是"点了给个提示"
  ///
  /// 那条路要向系统申请 `READ_MEDIA_VIDEO`，而 Quest 上弹出来的是**照片选择器那套
  /// 权限页**，它在 Horizon OS 上根本没有实现——真机上的样子是：整块应用面板变成
  /// 一片品红（Spatial SDK 的"没有纹理"底色），上面糊着一句
  /// 「需要权限，目前无法在您的 Android 13 上访问此内容。您可以尝试在手机上访问。」
  /// 用户点确定之后面板才回来（2026-09-10 真机，见 [[quest-immersive-launch-procedure]]）。
  ///
  /// 而且就算权限拿得到也没用：头显上没有手机那种"相机胶卷"，MediaStore 的视频索引
  /// 里除了系统录屏没有别的。所以这条入口在 XR 上**没有任何价值，只有代价**。
  bool get _canScanDeviceVideos =>
      GetPlatform.isAndroid && !DeviceFormFactorUtils.isXrDevice;

  Future<void> _showAddMenu(BuildContext anchorContext) async {
    final t = slang.t.localMedia;
    final action = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<String>(
          value: 'addFolder',
          label: t.addFolder,
          icon: Icons.create_new_folder_outlined,
          enabled: !_addingSource,
        ),
        if (_canScanDeviceVideos)
          GlassMenuOption<String>(
            value: 'addDeviceVideos',
            label: t.addDeviceVideos,
            icon: Icons.video_library_outlined,
            enabled: !_addingSource,
          ),
      ],
    );
    if (!mounted || action == null) return;
    if (action == 'addFolder') unawaited(_addSource());
    if (action == 'addDeviceVideos') unawaited(_addMediaStoreSource());
  }

  /// 空态上那几枚「一键加这个目录」的建议。
  ///
  /// ⛔ **摸盘必须在后台 isolate 上**。这段判断是深度 2 的 `listSync` 递归，
  /// 目录里**没有**视频时没有早退可言——三层全走完才知道答案。而它出现的场合
  /// 恰恰是首次启动那一屏（一个源都没加），在 `build` 里同步跑就是掉帧甚至 ANR。
  ///
  /// 所以这里只读缓存：没算过就丢一个后台任务出去，算完 `setState` 再来一帧。
  /// 那一帧之前不显示建议——首屏少两枚按钮，好过整屏卡住。
  List<String> _candidatePaths() {
    if (!GetPlatform.isAndroid || _sources.isNotEmpty) return const <String>[];
    if (_cachedCandidates != null) return _cachedCandidates!;
    if (!_candidatesPending) {
      _candidatesPending = true;
      unawaited(_computeCandidatePaths());
    }
    return const <String>[];
  }

  Future<void> _computeCandidatePaths() async {
    try {
      // ⛔ 用 [compute] 而不是 `Isolate.run(() => …)`：后者要在**实例方法里**
      // 写闭包，一旦哪天有人往里加一句用到 `this` 的代码，整个 State
      // （连着 BuildContext）就会被塞进 isolate 消息，运行时当场抛。
      // `compute` 收的是「顶层/static 函数 + 一个可发送的参数」，不给这种机会。
      final found = await compute(
        _probeCandidateRoots,
        kLocalVideoExtensions.toSet(),
      );
      if (!mounted) return;
      // 期间用户可能已经自己加了源——那就不再给建议了。
      if (_sources.isNotEmpty) return;
      setState(() => _cachedCandidates = found);
    } catch (e) {
      LogUtils.w('探测候选目录失败: $e', _tag);
      if (mounted) setState(() => _cachedCandidates = const <String>[]);
    } finally {
      _candidatesPending = false;
    }
  }

  static const List<String> _candidateRoots = <String>[
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Movies',
  ];

  static const int _candidateDirectoryDepth = 2;

  /// 摸盘上限：巨型目录（几万条的 Download）不该把后台 isolate 也拖住几秒。
  static const int _candidateMaxEntries = 4000;

  /// ⛔ 在后台 isolate 上跑，不能碰任何 `this`、GetX 单例或 Flutter binding。
  /// （[_candidateRoots] 是 static const，新 isolate 里照样读得到。）
  static List<String> _probeCandidateRoots(Set<String> videoExtensions) {
    final result = <String>[];
    for (final path in _candidateRoots) {
      final budget = [_candidateMaxEntries];
      if (_directoryContainsVideo(
        Directory(path),
        _candidateDirectoryDepth,
        videoExtensions,
        budget,
      )) {
        result.add(path);
      }
    }
    return result;
  }

  static bool _directoryContainsVideo(
    Directory directory,
    int remainingDepth,
    Set<String> videoExtensions,
    List<int> budget,
  ) {
    try {
      if (!directory.existsSync()) return false;
      for (final entity in directory.listSync(followLinks: false)) {
        if (--budget[0] <= 0) return false;
        if (entity is File &&
            videoExtensions.contains(
              p.extension(entity.path).replaceFirst('.', '').toLowerCase(),
            )) {
          return true;
        }
        if (remainingDepth > 0 &&
            entity is Directory &&
            _directoryContainsVideo(
              entity,
              remainingDepth - 1,
              videoExtensions,
              budget,
            )) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerHeight =
        GlassTokens.headerRowHeight + _headerRowGap + GlassTokens.pillHeight;
    final double headerExtent = statusBarHeight + headerHeight;

    // ⛔ 顺序必须与 [_tabFolders] 那几个常量、以及下面 TabBarView 的 children
    // 一一对上。七栏在手机上肯定摆不下——[GlassAdaptiveSegmentedControl] 会自己
    // 退化成一枚下拉钮，不要在这里另做窄屏分支。
    final tabItems = [
      GlassSegmentItem(
        label: slang.t.localMedia.tabFolders,
        icon: const Icon(Icons.folder_outlined),
      ),
      GlassSegmentItem(
        label: slang.t.localMedia.browse.pinnedSection,
        icon: const Icon(Icons.push_pin_outlined),
      ),
      GlassSegmentItem(
        label: slang.t.localMedia.tabFavoriteVideos,
        icon: const Icon(Icons.star_outline),
      ),
      GlassSegmentItem(
        label: slang.t.localMedia.tabAllVideos,
        icon: const Icon(Icons.video_library_outlined),
      ),
      GlassSegmentItem(
        label: slang.t.localMedia.tabAllImages,
        icon: const Icon(Icons.photo_library_outlined),
      ),
      GlassSegmentItem(
        label: slang.t.localMedia.tabDownloadedVideos,
        icon: const Icon(Icons.download_done_outlined),
      ),
      GlassSegmentItem(
        label: slang.t.localMedia.tabDownloadedGalleries,
        icon: const Icon(Icons.collections_bookmark_outlined),
      ),
    ];

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
                    const IdentityAvatarButton(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassTitlePill(title: slang.t.localMedia.title),
                    ),
                    const SizedBox(width: 8),
                    _buildHeaderActions(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _headerRowGap),
            SizedBox(
              height: GlassTokens.pillHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassAdaptiveSegmentedControl(
                        selectedIndex: _tabController.index,
                        progress: _tabController.animation,
                        onChanged: (index) {
                          _tabController.animateTo(index);
                          setState(() {});
                        },
                        items: tabItems,
                      ),
                    ),
                    _buildSortControls(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            _buildResponsiveBody(context, headerExtent),
            _buildPinnedTab(context, headerExtent),
            LocalMediaWall(
              kind: LocalMediaItemKind.video,
              favoritedOnly: true,
              order: _favVideoOrder,
              queueTitle: slang.t.localMedia.tabFavoriteVideos,
              headerExtent: headerExtent,
            ),
            LocalMediaWall(
              kind: LocalMediaItemKind.video,
              // ⛔ 「所有视频 / 所有图片」把内建的「已下载」排除在外：它自己是
              // 右边那一栏，两边都列就是同一批文件在这一页里出现两次。精选那一栏
              // 则必须**不排除**（精选是用户跨源挑出来的）。这两句的口径与
              // 「接着看」里同名的池逐字一致，见 `LocalLibraryPlaybackQueue`。
              excludeBuiltInSource: true,
              order: _allVideoOrder,
              queueTitle: slang.t.localMedia.tabAllVideos,
              headerExtent: headerExtent,
            ),
            LocalMediaWall(
              kind: LocalMediaItemKind.image,
              excludeBuiltInSource: true,
              order: _allImageOrder,
              queueTitle: slang.t.localMedia.tabAllImages,
              headerExtent: headerExtent,
            ),
            LocalMediaWall(
              kind: LocalMediaItemKind.video,
              // 内建的「已下载」源就是下载模块同步过来的那些视频（见
              // `DownloadsLibrarySyncService`）——白拿缩略图、时长和观看进度条。
              sourceId: kDownloadsSourceId,
              order: _downloadedVideoOrder,
              queueTitle: slang.t.localMedia.tabDownloadedVideos,
              headerExtent: headerExtent,
            ),
            // ⛔ 图库那一栏走的是**下载任务表**，不是本地库：图库压根没同步进去。
            // 完整理由见 [DownloadedGalleryWall] 的类注释。
            DownloadedGalleryWall(headerExtent: headerExtent),
          ],
        ),
      ),
    );
  }

  Widget _buildSortControls(BuildContext context) {
    final index = _tabController.index;
    final (order, fields, onChanged) = switch (index) {
      _tabFavoriteVideos => (
        _favVideoOrder,
        _favVideoSortFields,
        (LocalMediaOrder o) => setState(() => _favVideoOrder = o),
      ),
      _tabAllVideos => (
        _allVideoOrder,
        _videoSortFields,
        (LocalMediaOrder o) => setState(() => _allVideoOrder = o),
      ),
      _tabAllImages => (
        _allImageOrder,
        _imageSortFields,
        (LocalMediaOrder o) => setState(() => _allImageOrder = o),
      ),
      _tabDownloadedVideos => (
        _downloadedVideoOrder,
        _videoSortFields,
        (LocalMediaOrder o) => setState(() => _downloadedVideoOrder = o),
      ),
      // 文件目录 / 常用目录 / 下载完成图库这三栏摆的是**容器**不是条目，没有
      // 「按时长排」这回事，整组排序控件让位（`AnimatedSwitcher` 会收进去）。
      //
      // ⛔ 这三个常量在这里**明写**而不是并进下面那条兜底：它们是这张表唯一
      // 会被编译器检查的地方，加一栏忘了接排序时，改常量的人至少要路过这一行。
      _tabFolders ||
      _tabPinned ||
      _tabDownloadedGalleries => (null, null, null),
      _ => (null, null, null),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.horizontal,
          alignment: Alignment.centerRight,
          child: child,
        ),
      ),
      child: (order != null && fields != null && onChanged != null)
          ? Row(
              key: const ValueKey('sort_controls'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                LocalSortControls(
                  order: order,
                  fields: fields,
                  onChanged: onChanged,
                ),
              ],
            )
          : const SizedBox.shrink(key: ValueKey('no_sort_controls')),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final t = slang.t.localMedia;
    return GlassButtonGroup(
      children: [
        Builder(
          builder: (anchorContext) => GlassIconButton(
            icon: const Icon(Icons.more_vert),
            opensOverlay: true,
            tooltip: slang.t.common.more,
            onPressed: () async {
              final action = await showGlassMenu<String>(
                anchorContext: anchorContext,
                entries: <GlassMenuEntry>[
                  GlassMenuOption<String>(
                    value: 'addFolder',
                    label: t.addFolder,
                    icon: Icons.create_new_folder_outlined,
                    enabled: !_addingSource,
                  ),
                  if (_canScanDeviceVideos)
                    GlassMenuOption<String>(
                      value: 'addDeviceVideos',
                      label: t.addDeviceVideos,
                      icon: Icons.video_library_outlined,
                      enabled: !_addingSource,
                    ),
                  GlassMenuOption<String>(
                    value: 'clearProgress',
                    label: t.clearProgress,
                    icon: Icons.history_toggle_off,
                  ),
                ],
              );
              if (!mounted || action == null) return;
              if (action == 'addFolder') unawaited(_addSource());
              if (action == 'addDeviceVideos') {
                unawaited(_addMediaStoreSource());
              }
              if (action == 'clearProgress') unawaited(_clearProgress());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveBody(BuildContext context, double headerExtent) {
    final candidates = _candidatePaths();
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 32;
        return RefreshIndicator(
          displacement: headerExtent,
          onRefresh: () async {
            await _syncDownloads();
            _reloadSources();
            _reloadPinnedFolders();
          },
          child: _sources.isEmpty
              ? _buildEmpty(context, candidates, headerExtent)
              : _buildContentList(context, headerExtent, availableWidth),
        );
      },
    );
  }

  Widget _buildContentList(
    BuildContext context,
    double headerExtent,
    double availableWidth,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(child: SizedBox(height: headerExtent + 12)),
        if (_permissionDenied)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _permissionBanner(context),
            ),
          ),
        if (GetPlatform.isIOS)
          SliverToBoxAdapter(child: _iosManualScanNoticeWidget(context)),
        // ⛔ 这里原先顶着「常用目录」那一块。2026-09-11 按用户要求搬去了自己的
        // 栏目（见 [_buildPinnedTab]）：置顶几个之后它会把真正的来源网格整个挤到
        // 屏幕外面，而来源才是这一栏的主体。别再加回来。
        _sectionHeader(slang.t.localMedia.browse.sourcesSection),
        _buildSourcesSection(context, availableWidth),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }

  /// 「常用目录」那一栏：用户置顶过的那几个目录，一格一张夹子卡。
  ///
  /// ⛔ 这一栏与「文件目录」栏读的是**同一份**状态（[_pinnedFolders] /
  /// [_pinnedFolderRows]，由 [_reloadPinnedFolders] 一次查完）。别在这里另起一套
  /// 查询：置顶目录的封面是扫描器回填的，跨栏两份数据会立刻开始说不一样的话。
  Widget _buildPinnedTab(BuildContext context, double headerExtent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 32;
        return RefreshIndicator(
          displacement: headerExtent,
          onRefresh: () async => _reloadPinnedFolders(),
          child: CustomScrollView(
            controller: _pinnedScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(child: SizedBox(height: headerExtent + 12)),
              if (_pinnedFolders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slang.t.localMedia.browse.emptyPinned,
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
                _buildPinnedSection(context, availableWidth),
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

  Widget _buildPinnedSection(BuildContext context, double availableWidth) {
    // ⚠️ 这里的 260 必须与来源网格的一致：两个区块紧挨着上下排，格宽一差，
    // 卡片边界就错开成两套竖线，一眼就看得出没对齐。
    final metrics = LocalGridMetrics.resolve(
      availableWidth: availableWidth,
      maxCellWidth: 260,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: metrics.delegate(
          LocalFolderCardWidget.extentFor(context, metrics.cellWidth),
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final pinned = _pinnedFolders[index];
          final folder =
              _pinnedFolderRows[_pinKey(pinned.sourceId, pinned.relPath)] ??
              LocalMediaFolder(
                id: LocalMediaFolder.buildId(pinned.sourceId, pinned.relPath),
                sourceId: pinned.sourceId,
                relPath: pinned.relPath,
                name: pinned.displayName,
                sortName: pinned.displayName.toLowerCase(),
                missing: true,
              );
          return Builder(
            builder: (cardContext) => LocalFolderCardWidget(
              folder: folder,
              pinned: true,
              onOpen: () {
                appRouter.push(
                  LocalFolderRoute.location(
                    sourceId: pinned.sourceId,
                    relPath: pinned.relPath,
                  ),
                );
              },
              onMenu: (ctx) => showLocalFolderMenu(
                anchorContext: ctx,
                actions: LocalFolderActions(
                  sourceId: pinned.sourceId,
                  relPath: pinned.relPath,
                  folderPath: folder.folderPath,
                  pinned: true,
                  coverPinned: folder.coverPinned,
                  displayName: pinned.displayName,
                  // ⛔ 与「文件目录」里同一个目录的卡片必须是**同一张菜单**：从
                  // 常用目录进和从文件目录进看到的能力不一样，正是用户说的"内外
                  // 没对齐"那个毛病的另一半。
                  canRescan: true,
                  onChanged: () {
                    if (!mounted) return;
                    _reloadPinnedFolders();
                    _reloadSources();
                  },
                ),
              ),
            ),
          );
        }, childCount: _pinnedFolders.length),
      ),
    );
  }

  Widget _buildSourcesSection(BuildContext context, double availableWidth) {
    final metrics = LocalGridMetrics.resolve(
      availableWidth: availableWidth,
      maxCellWidth: 260,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: metrics.delegate(
          LocalSourceCardWidget.extentFor(context, metrics.cellWidth),
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == _sources.length) {
            return Builder(
              builder: (cardContext) => LocalAddSourceCard(
                enabled: !_addingSource,
                onTap: () => _showAddMenu(cardContext),
              ),
            );
          }
          final source = _sources[index];
          final stats = _sourceStats[source.id];
          return LocalSourceCardWidget(
            source: source,
            // 来源根也能设为常用（见 [_openSourceMenu]），设了就得在卡片上看得见。
            pinned: _pinnedKeys.contains(_pinKey(source.id, '')),
            coverPath: stats?.cover,
            videoCount: stats?.videos ?? 0,
            imageCount: stats?.images ?? 0,
            scanning: _scanningSourceId == source.id,
            onOpen: () =>
                appRouter.push(LocalFolderRoute.location(sourceId: source.id)),
            onMenu: (anchorContext) => _openSourceMenu(anchorContext, source),
          );
        }, childCount: _sources.length + 1),
      ),
    );
  }

  /// 「添加文件夹 / 扫描设备视频」这一组动作。
  ///
  /// ⛔ 走 [GlassButtonGroup] + [GlassTextActionButton]，不要用裸的
  /// `OutlinedButton` / `FilledButton`——`glass_style_guard_test.dart` 有条
  /// 只降不升的棘轮盯着，新文件里出现裸 Material 按钮就是红的。
  ///
  /// 只剩空态在用：有来源时，添加动作是来源网格末尾那一格 [LocalAddSourceCard]，
  /// 不再是悬在列表底下的一排按钮。
  Widget _buildAddActions(BuildContext context) {
    final t = slang.t.localMedia;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: t.addFolder,
              emphasized: true,
              onPressed: _addingSource ? null : _addSource,
            ),
            if (_canScanDeviceVideos)
              GlassTextActionButton(
                label: t.addDeviceVideos,
                onPressed: _addingSource ? null : _addMediaStoreSource,
              ),
          ],
        ),
      ),
    );
  }

  Widget _iosManualScanNoticeWidget(BuildContext context) {
    final t = slang.t.localMedia;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        margin: EdgeInsets.zero,
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.iosManualRescanNotice,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionBanner(BuildContext context) {
    final t = slang.t.localMedia;
    return MaterialBanner(
      content: Text(t.permissionDenied),
      leading: const Icon(Icons.lock_outline),
      actions: <Widget>[
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: t.addFolder,
              emphasized: true,
              onPressed: _addSource,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpty(
    BuildContext context,
    List<String> candidates,
    double headerExtent,
  ) {
    final t = slang.t.localMedia;
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        28,
        headerExtent + 24,
        28,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      children: <Widget>[
        Icon(
          Icons.folder_open_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 18),
        Text(
          t.emptyTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          t.emptyPrivacyNote,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (GetPlatform.isIOS) ...[
          const SizedBox(height: 8),
          Text(
            t.iosManualRescanNotice,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
        if (_permissionDenied) ...[
          const SizedBox(height: 18),
          _permissionBanner(context),
        ],
        if (candidates.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            t.suggestedFolders,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final path in candidates)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.video_library_outlined),
              title: Text(p.basename(path)),
              subtitle: Text(
                path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: t.addFolder,
                onPressed: _addingSource ? null : () => _addSource(path),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
        ],
        const SizedBox(height: 18),
        _buildAddActions(context),
      ],
    );
  }
}
