import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 「本地媒体」页（P0）。
///
/// # 这一版故意很朴素
///
/// P0 的目的是把「权限 → 选目录 → 扫描 → 建库 → 列表 → 播放」端到端穿一遍，
/// 证伪扫描/写库架构。**它不是最终形态**：正式的入口是「视频」「图库」板块
/// header 上的来源切换（见工作线文档 §3.1），那时这一页会被拆掉，列表并回
/// 主卡片墙。所以这里不投资玻璃化与形变，只保证行为正确。
///
/// # 首屏不等扫描
///
/// 列表**永远直接读库**（[_loadPage]），扫描是后台增量 upsert；第一次加源时
/// 列表边扫边长出来，而不是摆一个转圈等它扫完。
class LocalMediaPage extends StatefulWidget {
  const LocalMediaPage({super.key});

  @override
  State<LocalMediaPage> createState() => _LocalMediaPageState();
}

class _LocalMediaPageState extends State<LocalMediaPage> {
  static const String _tag = 'LocalMediaPage';
  static const int _pageSize = 60;

  final LocalMediaRepository _repository = LocalMediaRepository();
  final ScrollController _scrollController = ScrollController();

  List<LocalMediaSource> _sources = const <LocalMediaSource>[];
  String? _activeSourceId;

  /// 分类筛选：null = 全部，[kLocalMediaUncategorized] = 只看未分类，其余是分类
  /// id。⭐ 它和「来源」是**两个独立维度**（§10.7）——分类跟着文件走，下载来的
  /// 和拷进来的一视同仁。
  String? _categoryFilter;
  final List<LocalMediaItem> _items = <LocalMediaItem>[];

  bool _loading = false;
  bool _hasMore = true;
  bool _addingSource = false;

  /// 用户拒过一次权限。⛔ 拒了就**不再自动弹**，改成顶部一条可点的横幅——
  /// 反复弹系统页是这类功能最招人烦的地方。
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _reloadSources();
    // 「已下载」是内建源，用户没有"添加"它的动作，所以每次进来同步一次：
    // 它读的是 `download_tasks`（几十到几百行）+ 每条一次 stat，比走目录树
    // 便宜得多，而且不同步的话刚下完的片子要等到下次才出现。
    unawaited(_syncDownloads());
    // 扫描每推进一批就把新条目接上，用户看得到列表在长。
    ever<LocalMediaScanProgress?>(
      LocalMediaScanService.to.progress,
      _onScanProgress,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScanProgress(LocalMediaScanProgress? progress) {
    if (!mounted || progress == null) return;
    if (progress.finished) {
      _reloadSources();
      if (progress.error != null) {
        showAppToast(
          slang.t.localMedia.scanFailed(reason: progress.error!),
          type: AppToastType.error,
        );
      } else if (progress.truncated) {
        showAppToast(slang.t.localMedia.scanTruncated(count: kMaxScanFiles));
      }
    }
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      _loadPage();
    }
  }

  void _reloadSources() {
    if (!mounted) return;
    final sources = _repository.getSources();
    // 分类可能在别处被删了（长按菜单里就有一条「管理分类」直通那一页）。
    // 留着一个死 id，墙上一条都筛不出来，而 [_categoryFilterLabel] 会在
    // 找不到它时退回「全部」——菜单说全部、墙上空的，两句话互相打脸。
    final filter = _categoryFilter;
    if (filter != null &&
        filter != kLocalMediaUncategorized &&
        !_categories().any((c) => c.id == filter)) {
      _categoryFilter = null;
    }
    setState(() {
      _sources = sources;
      if (_activeSourceId != null &&
          sources.every((s) => s.id != _activeSourceId)) {
        _activeSourceId = null;
      }
      _activeSourceId ??= sources.isEmpty ? null : sources.first.id;
      _items.clear();
      _hasMore = true;
    });
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    final sourceId = _activeSourceId;
    if (sourceId == null) return;
    setState(() => _loading = true);
    try {
      final page = _repository.queryItems(
        sourceId: sourceId,
        categoryId: _categoryFilter,
        sort: LocalMediaSort.nameAsc,
        offset: _items.length,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length >= _pageSize;
      });
    } catch (e) {
      LogUtils.e('读取本地条目失败', tag: _tag, error: e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 添加一个源：权限 → 选目录 → 查重叠 → 入库 → 扫。
  Future<void> _addSource() async {
    if (_addingSource) return;
    setState(() => _addingSource = true);
    try {
      final permission = Get.find<PermissionService>();
      if (!await permission.hasStoragePermission()) {
        final granted = await permission.requestStoragePermission();
        if (!granted) {
          // ⛔ 不重试、不追问。把主动权交回去，横幅一直在那儿等他改主意。
          if (mounted) setState(() => _permissionDenied = true);
          return;
        }
      }
      if (mounted) setState(() => _permissionDenied = false);

      final picked = await Get.find<DownloadPathService>().pickDirectoryPath();
      if (picked == null || picked.isEmpty) return;

      // ⛔ 源之间不许互相包含：否则同一个文件在两个源里各存一份，
      // "按来源筛选"的结果开始飘，而用户完全看不出为什么。
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
        // 内建源占着 -1，别把它数进来（否则两个文件夹会拿到同一个次序）。
        sortOrder: _sources.where((s) => !s.isBuiltIn).length,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _repository.upsertSource(source);
      setState(() => _activeSourceId = source.id);
      _reloadSources();
      _startScan(source);
    } catch (e) {
      LogUtils.e('添加本地源失败', tag: _tag, error: e);
      showAppToast(
        slang.t.localMedia.addSourceFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _addingSource = false);
    }
  }

  void _startScan(LocalMediaSource source) {
    LocalMediaScanService.to.scanSource(source).catchError((Object e) {
      LogUtils.e('扫描失败', tag: _tag, error: e);
    });
  }

  Future<void> _syncDownloads() async {
    if (!Get.isRegistered<DownloadsLibrarySyncService>()) return;
    // sync() 自己把异常吞在里面并落日志（同步失败不该让这一页打不开），
    // 所以这里没有 catch——加一个也永远进不去。
    await DownloadsLibrarySyncService.to.sync();
    if (!mounted) return;
    _reloadSources();
  }

  Future<void> _rescan() async {
    final sourceId = _activeSourceId;
    if (sourceId == null) return;
    final source = _repository.getSource(sourceId);
    if (source == null) return;
    // 「已下载」不走目录扫描，见 [DownloadsLibrarySyncService] 的类文档。
    if (source.kind == LocalMediaSourceKind.downloads) {
      await _syncDownloads();
      return;
    }
    await LocalMediaScanService.to.scanSource(source);
    _reloadSources();
  }

  /// 移除一个源。**只从库里移除，磁盘文件一个不动**——本应用不是文件管理器。
  /// 进度行跟着一起清（见 [LocalMediaRepository.deleteSource]）。
  Future<void> _confirmRemoveSource(LocalMediaSource source) async {
    final t = slang.t.localMedia;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.removeSourceTitle(name: source.displayName)),
        content: Text(t.removeSourceBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(slang.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.remove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _repository.deleteSource(source.id);
    _reloadSources();
  }

  Future<void> _openMoreMenu(BuildContext anchorContext) async {
    final t = slang.t.localMedia;
    // 条数在开菜单这一刻现读一次：一条主键 COUNT，而且是事件里读不是 build 里读。
    final count = _repository.progressCount();
    final picked = await showGlassMenu<_LocalMediaMenuAction>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<_LocalMediaMenuAction>(
          value: _LocalMediaMenuAction.filterByCategory,
          label: t.filterByCategory,
          description: _categoryFilterLabel(),
          icon: Icons.folder_special_outlined,
        ),
        GlassMenuOption<_LocalMediaMenuAction>(
          value: _LocalMediaMenuAction.clearProgress,
          label: t.clearProgress,
          // 一条都没有时不藏起来而是置灰 + 说明白——藏起来会让人以为没这个功能。
          description: count > 0
              ? t.clearProgressCount(count: count)
              : t.clearProgressEmpty,
          icon: Icons.history_toggle_off,
          destructive: true,
          enabled: count > 0,
        ),
      ],
    );
    // ⛔ 菜单是个路由/浮层，await 期间这一页、以及那枚 ⋮ 钮本身都可能已经没了。
    //    State 和 anchorContext 两个都得问一遍：下一步既要用 State.context 弹
    //    确认框，也要拿 anchorContext 当第二张菜单的落点。
    if (!mounted || !anchorContext.mounted) return;
    switch (picked) {
      case _LocalMediaMenuAction.clearProgress:
        await _confirmClearProgress();
      case _LocalMediaMenuAction.filterByCategory:
        await _pickCategoryFilter(anchorContext);
      case null:
        break;
    }
  }

  /// 分类清单。⛔ 三处都得走它：漏一处 `Get.isRegistered` 守卫，服务还没注册
  /// 时就是一次 `Get.find` 抛异常。
  List<DownloadCategory> _categories() => Get.isRegistered<DownloadService>()
      ? DownloadService.to.categories
      : const <DownloadCategory>[];

  String _categoryFilterLabel() {
    final t = slang.t.localMedia;
    final filter = _categoryFilter;
    if (filter == null) return slang.t.common.all;
    if (filter == kLocalMediaUncategorized) return t.uncategorized;
    return _categories().firstWhereOrNull((c) => c.id == filter)?.title ??
        slang.t.common.all;
  }

  /// 分类清单从 [DownloadService.categories] 拿（桶本身仍共用
  /// `download_categories` 表——那只是一张"名字 + 顺序"的表），条数从**本地库**
  /// 现算。⛔ 不能拿分类行自带的 `item_count`：那数的是下载任务（含图库、含
  /// 下载中/失败、同一视频两档清晰度算两条），和这张墙上的文件数对不上，
  /// 菜单就会出现「显示 5 条、点进去 3 条」。
  Future<void> _pickCategoryFilter(BuildContext anchorContext) async {
    final t = slang.t.localMedia;
    // 数字与点进去看到的那张墙同口径：墙按来源筛过，数字也得按来源数。
    final sourceId = _activeSourceId;
    final counts = _repository.categoryCounts(sourceId: sourceId);
    final categories = _categories();
    final total = _repository.countItems(sourceId: sourceId);
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<String>(
          value: _kCategoryAll,
          label: slang.t.common.all,
          description: '$total',
          icon: Icons.apps,
        ),
        GlassMenuOption<String>(
          value: kLocalMediaUncategorized,
          label: t.uncategorized,
          description: '${counts.uncategorized}',
          icon: Icons.folder_outlined,
          enabled: counts.uncategorized > 0,
        ),
        for (final category in categories)
          GlassMenuOption<String>(
            value: category.id,
            label: category.title,
            description: '${counts.byCategory[category.id] ?? 0}',
            icon: Icons.folder,
            enabled: (counts.byCategory[category.id] ?? 0) > 0,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _categoryFilter = picked == _kCategoryAll ? null : picked;
      _items.clear();
      _hasMore = true;
    });
    _loadPage();
  }

  /// 把一条本地条目移到某个分类。
  ///
  /// ⭐ 这就是 §10.7 要的那件事：**拷进来的文件也能分类**。写的是
  /// `local_media_items.category_id`；如果这条恰好是下载来的，
  /// [LocalMediaRepository.setItemsCategory] 会把它镜像回 `download_tasks`，
  /// 于是下载页和这里永远是同一个答案。
  Future<void> _pickItemCategory(
    BuildContext anchorContext,
    LocalMediaItem item,
  ) async {
    final t = slang.t.localMedia;
    final categories = _categories();
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<String>(
          value: kLocalMediaUncategorized,
          label: t.uncategorized,
          icon: Icons.folder_off_outlined,
          enabled: item.categoryId != null,
        ),
        for (final category in categories)
          GlassMenuOption<String>(
            value: category.id,
            label: category.title,
            icon: Icons.folder,
            enabled: category.id != item.categoryId,
          ),
        // ⛔ 一个分类都没建过时，上面那些条目一条都不存在，「未分类」也是灰的
        // ——长按弹出一张点不动的菜单等于告诉用户"这个功能坏了"。给条出路。
        GlassMenuOption<String>(
          value: _kManageCategories,
          label: slang.t.download.category.manageTitle,
          icon: Icons.settings_outlined,
        ),
      ],
    );
    if (picked == null || !mounted) return;
    if (picked == _kManageCategories) {
      openDownloadCategoryManagePage(context);
      return;
    }
    final categoryId = picked == kLocalMediaUncategorized ? null : picked;
    try {
      _repository.setItemsCategory(<String>[item.id], categoryId);
    } catch (e) {
      LogUtils.e('设置分类失败', tag: _tag, error: e);
      showAppToast(t.setCategoryFailed, type: AppToastType.error);
      return;
    }
    if (!mounted) return;
    // 下载页那边的胶囊与历史区都得跟上，见 notifyLocalCategoryChanged 的说明。
    if (Get.isRegistered<DownloadService>()) {
      unawaited(DownloadService.to.notifyLocalCategoryChanged());
    }
    showAppToast(t.categoryUpdated);
    _reloadSources();
  }

  /// 清除本机观看记录。**只删记录**——这是隐私入口，不是删片入口，
  /// 所以确认框里把"文件一个不动"说在明处（同 [_confirmRemoveSource] 的口径）。
  Future<void> _confirmClearProgress() async {
    final t = slang.t.localMedia;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.clearProgressTitle),
        content: Text(t.clearProgressBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(slang.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.clearAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final removed = _repository.clearAllProgress();
    // ⛔ 缓存着的本机文件池必须一起丢：它们手里的进度是翻页那一刻的快照，
    // 不丢的话清完再开「接着看」，进度条原样还在（看上去就是没清掉）。
    if (Get.isRegistered<PlaybackQueueService>()) {
      PlaybackQueueService.to.invalidateLocalLibraryProgress();
    }
    if (!mounted) return;
    showAppToast(t.clearProgressDone(count: removed));
  }

  Future<void> _play(LocalMediaItem item) async {
    // ⛔ 先 stat 一次再跳：库里那一行可能已经指向一个被删掉/被移走的文件，
    // 直接跳过去只会得到一个播放器里的黑屏加一句看不懂的错误。
    if (!File(item.path).existsSync()) {
      showAppToast(
        slang.t.localMedia.fileMissing,
        type: AppToastType.error,
      );
      return;
    }
    NaviService.navigateToLocalVideoPlayerPage(
      localPath: item.path,
      localLibraryItemId: item.id,
      // **把本机文件池一起交出去**：播放器里的「接着看」一开就落在这个源上，
      // 下一条同样用磁盘文件播（见 [LocalLibraryPlaybackQueue]）。
      //
      // ⛔ 排序必须与本页这张墙一致（都用 `nameAsc`），否则用户点第 3 集、
      // 续播给出的是个毫不相干的东西——排序是池身份的一部分。
      playbackQueueRef: await _openQueueRef(item),
    );
  }

  /// 建/取本机文件池，并给出指向 [item] 的引用。
  ///
  /// 第一页先拉起来：池空着交过去的话，详情页那枚「下一个」会因为 `loaded`
  /// 为空而缺席一小会儿（同下载列表那条路）。
  Future<PlaybackQueueRef?> _openQueueRef(LocalMediaItem item) async {
    final sourceId = _activeSourceId;
    if (sourceId == null) return null;
    try {
      final queue = PlaybackQueueService.to.openLocalLibrary(
        sourceId: sourceId,
        sort: LocalMediaSort.nameAsc,
        title: _sources
            .firstWhereOrNull((s) => s.id == sourceId)
            ?.displayName,
      );
      if (queue.loaded.isEmpty) await queue.loadMore();
      return PlaybackQueueRef(queueId: queue.queueId, currentItemId: item.id);
    } catch (e) {
      // 池开不出来不该把"能播"变成"播不了"：没有池就是没有「接着看」而已。
      LogUtils.w('本机文件池创建失败: $e', _tag);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t.localMedia;
    final scan = LocalMediaScanService.to;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.title),
        actions: <Widget>[
          if (_sources.isNotEmpty)
            IconButton(
              tooltip: t.rescan,
              onPressed: scan.isScanning ? null : _rescan,
              icon: const Icon(Icons.refresh),
            ),
          IconButton(
            tooltip: t.addFolder,
            onPressed: _addingSource ? null : _addSource,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          // anchorContext 必须是这枚钮自己的 context——玻璃菜单的落点和材质档
          // 都是从触发件身上量的，包一层 Builder 最省事（见 showGlassMenu）。
          Builder(
            builder: (anchorContext) => IconButton(
              tooltip: slang.t.common.more,
              onPressed: () => _openMoreMenu(anchorContext),
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_permissionDenied) _permissionBanner(context),
          Obx(() {
            final progress = scan.progress.value;
            if (progress == null || progress.finished) {
              return const SizedBox.shrink();
            }
            return _scanBanner(context, progress);
          }),
          // ⛔ 条件是「有源」而不是「源多于一个」：移除动作挂在 chip 的长按上，
          // 按数量藏起来会让**只有一个源**的用户彻底没有入口把它删掉
          // （真机验证时就是这么撞上的）。
          if (_sources.isNotEmpty) _sourceChips(context),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _permissionBanner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: InkWell(
        onTap: () async {
          final granted = await Get.find<PermissionService>()
              .requestStoragePermission();
          if (mounted) setState(() => _permissionDenied = !granted);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(Icons.folder_off_outlined, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  slang.t.localMedia.permissionDenied,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onErrorContainer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scanBanner(BuildContext context, LocalMediaScanProgress progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              slang.t.localMedia.scanning(count: progress.discovered),
            ),
          ),
          TextButton(
            onPressed: LocalMediaScanService.to.cancel,
            child: Text(slang.t.common.cancel),
          ),
        ],
      ),
    );
  }

  Widget _sourceChips(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _sources.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final source = _sources[index];
          // ⛔ 内建源（「已下载」）没有移除入口：它不是用户加进来的一个目录，
          // 而是下载模块的产物在本地库里的那一面。删掉它只会在下一次同步时
          // 原样长回来，中间还白丢一次观看进度。
          final removable = !source.isBuiltIn;
          return GestureDetector(
            // 长按移除这个源。P0 只给这一个管理动作——正式的源管理页在 P1a。
            // 长按本身不好发现，所以挂一条 tooltip 把它说出来。
            onLongPress: removable ? () => _confirmRemoveSource(source) : null,
            child: Tooltip(
              message: removable
                  ? slang.t.localMedia.longPressToRemove
                  : slang.t.localMedia.builtInSourceHint,
              child: ChoiceChip(
              selected: source.id == _activeSourceId,
              label: Text(source.displayName),
              onSelected: (_) {
                setState(() {
                  _activeSourceId = source.id;
                  // ⛔ 换来源必须把分类筛选一起清掉。留着的话，一个只存在于
                  // 「已下载」里的分类会把刚切过去的文件夹筛成空的，而页面会
                  // 一本正经地说「这个文件夹里没有视频」——那是句假话，而且
                  // 唯一能看见筛选还开着的地方是 ⋮ 菜单里的一行副标题。
                  _categoryFilter = null;
                  _items.clear();
                  _hasMore = true;
                });
                _loadPage();
              },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    final t = slang.t.localMedia;
    if (_sources.isEmpty) {
      return _emptyState(context);
    }
    if (_items.isEmpty && !_loading) {
      // ⛔ 只有内建的「已下载」、而且它也是空的时候，这一页对用户来说**仍然是
      // 空的**：该出的是上手引导（含那句"只在本机读取，不上传任何东西"），不是
      // 一句「这个文件夹里没有视频」——他还一个文件夹都没加过。
      final hasUserSources = _sources.any((s) => !s.isBuiltIn);
      if (!hasUserSources) return _emptyState(context);
      return Center(child: Text(t.noVideosFound));
    }
    final width = MediaQuery.sizeOf(context).width;
    final columns = (width / 220).floor().clamp(2, 8);
    return RefreshIndicator(
      onRefresh: _rescan,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 16 / 12,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) => _card(context, _items[index]),
      ),
    );
  }

  Widget _card(BuildContext context, LocalMediaItem item) {
    final scheme = Theme.of(context).colorScheme;
    // ⭐ sidecar：下载器普遍在同目录写一张同名封面，有就白捡一个缩略图，
    // 不用抽帧、不用引包，桌面端也一样能用。
    final sidecar = item.sidecarImagePath;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      // anchorContext 必须是卡片自己的 context（玻璃菜单的落点与材质档都从触发件
      // 身上量），所以包一层 Builder。
      child: Builder(
        builder: (anchorContext) => Tooltip(
          message: slang.t.localMedia.longPressToCategorize,
          child: InkWell(
        onTap: () => _play(item),
        // 长按本身不好发现，所以挂一条 tooltip 把它说出来——同本页来源胶囊的
        // 做法（正式形态里这会是卡片上的三点钮，见 media_action_menu）。
        onLongPress: () => unawaited(_pickItemCategory(anchorContext, item)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: sidecar != null
                  ? Image.file(
                      File(sidecar),
                      fit: BoxFit.cover,
                      // 一格两百来像素，按原图解码是纯浪费。
                      cacheWidth: 480,
                      errorBuilder: (_, _, _) => _placeholder(scheme),
                    )
                  : _placeholder(scheme),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => ColoredBox(
    color: scheme.surfaceContainerHighest,
    child: Center(
      child: Icon(Icons.movie_outlined, color: scheme.onSurfaceVariant),
    ),
  );

  Widget _emptyState(BuildContext context) {
    final t = slang.t.localMedia;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              t.emptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.emptyPrivacyNote,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addingSource ? null : _addSource,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: Text(t.addFolder),
            ),
          ],
        ),
      ),
    );
  }
}

/// 本地媒体页右上角溢出菜单里的动作。
enum _LocalMediaMenuAction { filterByCategory, clearProgress }

/// 分类筛选菜单里「全部」那一项的值。用哨兵而不是 null，是因为 showGlassMenu
/// 用 null 表示"用户什么都没选就关掉了"，两者必须分得开。
const String _kCategoryAll = '\u0000all';

/// 同上：「管理分类」那一项，选中后跳页而不是设分类。
const String _kManageCategories = '\u0000manage';
