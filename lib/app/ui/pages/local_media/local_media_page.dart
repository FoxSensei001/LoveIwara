import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
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
        sortOrder: _sources.length,
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

  Future<void> _rescan() async {
    final sourceId = _activeSourceId;
    if (sourceId == null) return;
    final source = _repository.getSource(sourceId);
    if (source == null) return;
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
    if (confirmed != true) return;
    _repository.deleteSource(source.id);
    _reloadSources();
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
          return GestureDetector(
            // 长按移除这个源。P0 只给这一个管理动作——正式的源管理页在 P1a。
            // 长按本身不好发现，所以挂一条 tooltip 把它说出来。
            onLongPress: () => _confirmRemoveSource(source),
            child: Tooltip(
              message: slang.t.localMedia.longPressToRemove,
              child: ChoiceChip(
              selected: source.id == _activeSourceId,
              label: Text(source.displayName),
              onSelected: (_) {
                setState(() {
                  _activeSourceId = source.id;
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
      child: InkWell(
        onTap: () => _play(item),
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
