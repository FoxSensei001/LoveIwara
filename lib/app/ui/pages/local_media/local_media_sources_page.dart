import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 管理视频来源的页面。
///
/// 视频页只负责切换来源和展示卡片；添加目录、移除来源、重新扫描和清除本机观看
/// 记录都集中在这里，避免把管理状态塞进列表页的每一个排序池。
class LocalMediaSourcesPage extends StatefulWidget {
  const LocalMediaSourcesPage({super.key});

  @override
  State<LocalMediaSourcesPage> createState() => _LocalMediaSourcesPageState();
}

class _LocalMediaSourcesPageState extends State<LocalMediaSourcesPage> {
  static const String _tag = 'LocalMediaSourcesPage';

  final LocalMediaRepository _repository = LocalMediaRepository();
  List<LocalMediaSource> _sources = const <LocalMediaSource>[];
  bool _addingSource = false;
  bool _permissionDenied = false;
  String? _scanningSourceId;
  Worker? _scanWorker;

  @override
  void initState() {
    super.initState();
    _reloadSources();
    if (Get.isRegistered<LocalMediaScanService>()) {
      _scanWorker = ever<LocalMediaScanProgress?>(
        LocalMediaScanService.to.progress,
        _onScanProgress,
      );
    }
    unawaited(_syncDownloads());
  }

  @override
  void dispose() {
    _scanWorker?.dispose();
    super.dispose();
  }

  void _reloadSources() {
    if (!mounted) return;
    setState(() => _sources = _repository.getSources());
  }

  void _onScanProgress(LocalMediaScanProgress? progress) {
    if (!mounted || progress == null) return;
    setState(() {
      _scanningSourceId = progress.finished ? null : progress.sourceId;
    });
    if (!progress.finished) return;
    _reloadSources();
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
    if (mounted) _reloadSources();
  }

  /// 添加目录。候选目录传入时直接添加，不再把用户扔进系统选择器。
  Future<void> _addSource([String? candidatePath]) async {
    if (_addingSource) return;
    setState(() => _addingSource = true);
    try {
      final permission = Get.find<PermissionService>();
      if (!await permission.hasStoragePermission()) {
        final granted = await permission.requestStoragePermission();
        if (!granted) {
          if (mounted) setState(() => _permissionDenied = true);
          return;
        }
      }
      if (mounted) setState(() => _permissionDenied = false);

      final picked =
          candidatePath ??
          await Get.find<DownloadPathService>().pickDirectoryPath();
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
        sortOrder: _sources.where((source) => !source.isBuiltIn).length,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _repository.upsertSource(source);
      _reloadSources();
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
    }
  }

  Future<void> _rescan(LocalMediaSource source) async {
    if (source.kind == LocalMediaSourceKind.downloads) {
      await _syncDownloads();
      return;
    }
    await _scan(source);
  }

  Future<void> _remove(LocalMediaSource source) async {
    final t = slang.t.localMedia;
    final confirmed = await showGlassAlertDialog<bool>(
      title: t.removeSourceTitle(name: source.displayName),
      content: Text(t.removeSourceBody),
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: t.remove,
          destructive: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    _repository.deleteSource(source.id);
    _reloadSources();
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: t.clearAction,
          destructive: true,
          onPressed: () => Navigator.of(context).pop(true),
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

  Future<void> _openSourceMenu(
    BuildContext anchorContext,
    LocalMediaSource source,
  ) async {
    final t = slang.t.localMedia;
    final action = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<String>(
          value: 'rescan',
          label: t.rescan,
          icon: Icons.refresh,
          enabled: _scanningSourceId == null,
        ),
        if (!source.isBuiltIn)
          GlassMenuOption<String>(
            value: 'remove',
            label: t.remove,
            icon: Icons.remove_circle_outline,
            destructive: true,
          ),
      ],
    );
    if (!mounted || action == null) return;
    if (action == 'rescan') unawaited(_rescan(source));
    if (action == 'remove') unawaited(_remove(source));
  }

  List<String> _candidatePaths() {
    if (!GetPlatform.isAndroid) return const <String>[];
    const roots = <String>[
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Movies',
    ];
    return [
      for (final path in roots)
        if (_hasVideoWithinDepth(path)) path,
    ];
  }

  static const int _candidateDirectoryDepth = 2;

  bool _hasVideoWithinDepth(String path) =>
      _directoryContainsVideo(Directory(path), _candidateDirectoryDepth);

  bool _directoryContainsVideo(Directory directory, int remainingDepth) {
    try {
      if (!directory.existsSync()) return false;
      for (final entity in directory.listSync(followLinks: false)) {
        if (entity is File &&
            kLocalVideoExtensions.contains(
              p.extension(entity.path).replaceFirst('.', '').toLowerCase(),
            )) {
          return true;
        }
        if (remainingDepth > 0 &&
            entity is Directory &&
            _directoryContainsVideo(entity, remainingDepth - 1)) {
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
    final t = slang.t.localMedia;
    final candidates = _candidatePaths();
    return Scaffold(
      appBar: AppBar(
        title: Text(t.manageSources),
        actions: <Widget>[
          IconButton(
            tooltip: t.addFolder,
            onPressed: _addingSource ? null : _addSource,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          Builder(
            builder: (anchorContext) => IconButton(
              tooltip: slang.t.common.more,
              onPressed: () async {
                final action = await showGlassMenu<String>(
                  anchorContext: anchorContext,
                  entries: <GlassMenuEntry>[
                    GlassMenuOption<String>(
                      value: 'clear',
                      label: t.clearProgress,
                      icon: Icons.history_toggle_off,
                    ),
                  ],
                );
                if (action == 'clear') unawaited(_clearProgress());
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: _sources.isEmpty
          ? _buildEmpty(context, candidates)
          : RefreshIndicator(
              onRefresh: () async {
                await _syncDownloads();
                _reloadSources();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: <Widget>[
                  if (_permissionDenied) _permissionBanner(context),
                  for (final source in _sources) _sourceTile(context, source),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addingSource ? null : _addSource,
                    icon: const Icon(Icons.add),
                    label: Text(t.addFolder),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, List<String> candidates) {
    final t = slang.t.localMedia;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
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
        FilledButton.icon(
          onPressed: _addingSource ? null : _addSource,
          icon: const Icon(Icons.create_new_folder_outlined),
          label: Text(t.addFolder),
        ),
      ],
    );
  }

  Widget _permissionBanner(BuildContext context) {
    final t = slang.t.localMedia;
    return MaterialBanner(
      content: Text(t.permissionDenied),
      leading: const Icon(Icons.lock_outline),
      actions: <Widget>[
        TextButton(onPressed: _addSource, child: Text(t.addFolder)),
      ],
    );
  }

  Widget _sourceTile(BuildContext context, LocalMediaSource source) {
    final t = slang.t.localMedia;
    final scanning = _scanningSourceId == source.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          source.isBuiltIn
              ? Icons.download_outlined
              : Icons.folder_open_outlined,
        ),
        title: Text(source.displayName),
        subtitle: Text(
          source.isBuiltIn ? t.builtInSourceHint : source.path ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: scanning
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Builder(
                builder: (anchorContext) => IconButton(
                  tooltip: slang.t.common.more,
                  onPressed: () => _openSourceMenu(anchorContext, source),
                  icon: const Icon(Icons.more_vert),
                ),
              ),
      ),
    );
  }
}
