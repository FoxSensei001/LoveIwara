import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/download_missing_diagnosis.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/relocation_dialogs.dart'
    show MissingDiagnosisBody;
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 本机文件库里一条「点开时找不到了」的条目：说清是哪一种找不到，给出路。
///
/// 以前这里只有一句 toast「这个文件已经不在磁盘上了」然后什么都不发生——用户
/// 既不知道为什么，也不知道能做什么（2026-09-18 用户原话：「一点人性化设计没有」）。
/// 现在与下载那侧同一套诊断（[diagnoseMissingPath]）：
/// - 卷没挂上 / 没权限 → 插回 / 授权后「再检查一次」；
/// - 文件夹没了 / 文件没了 → 「重新扫描文件夹」（改名、挪动的文件会以新条目回来）；
/// - 原文件夹里有大小分毫不差的同类文件 → 逐个「就是它」，扫一遍后直接打开那个；
/// - 任何时候都能「从列表移除」（只删记录，不碰磁盘）。
///
/// NAS 条目没有「磁盘」可诊断：只说 NAS 上找不到了，给「重新列这个文件夹」。
///
/// 返回值：找回来的条目（原条目回来了，或用户认领的那个改名件），调用方直接
/// 打开它；关掉 / 移除了返回 null。
Future<LocalMediaItem?> showLocalItemMissingDialog(LocalMediaItem item) {
  return showAppDialog<LocalMediaItem>(_LocalItemMissingDialog(item: item));
}

void _pop<T>(T value) => rootNavigatorKey.currentState?.pop(value);

class _LocalItemMissingDialog extends StatefulWidget {
  const _LocalItemMissingDialog({required this.item});

  final LocalMediaItem item;

  @override
  State<_LocalItemMissingDialog> createState() =>
      _LocalItemMissingDialogState();
}

class _LocalItemMissingDialogState extends State<_LocalItemMissingDialog> {
  static const String _tag = 'LocalItemMissingDialog';

  final LocalMediaRepository _repository = LocalMediaRepository();
  MissingDiagnosis? _diagnosis;
  bool _busy = false;

  bool get _isRemote => DavPath.isDav(widget.item.path);

  @override
  void initState() {
    super.initState();
    if (!_isRemote) _diagnose();
  }

  Future<void> _diagnose({bool announce = false}) async {
    setState(() => _busy = true);
    MissingDiagnosis? diagnosis;
    try {
      diagnosis = await diagnoseMissingPath(
        widget.item.path,
        sizeBytes: widget.item.sizeBytes,
      );
    } catch (e, s) {
      LogUtils.e('诊断找不到的本机文件失败', tag: _tag, error: e, stackTrace: s);
    }
    if (!mounted) return;
    setState(() {
      _diagnosis = diagnosis;
      _busy = false;
    });
    if (announce) {
      showAppToast(
        slang.t.download.relocation.stillMissing,
        type: AppToastType.warning,
      );
    }
  }

  LocalMediaSource? get _source => _repository.getSource(widget.item.sourceId);

  /// 条目所在那一层的 rel_path；没有目录树的源（「设备视频」）返回 null。
  String? get _folderRelPath {
    final folderPath = widget.item.folderPath;
    if (folderPath == null || folderPath.isEmpty) return null;
    return _repository
        .findFolderByPath(
          sourceId: widget.item.sourceId,
          folderPath: folderPath,
        )
        ?.relPath;
  }

  bool get _canRescan =>
      _source != null &&
      _folderRelPath != null &&
      Get.isRegistered<LocalMediaScanService>();

  Future<bool> _rescanFolder() async {
    final source = _source;
    final relPath = _folderRelPath;
    if (source == null || relPath == null) return false;
    if (!Get.isRegistered<LocalMediaScanService>()) return false;
    try {
      await LocalMediaScanService.to.scanFolder(
        source: source,
        relPath: relPath,
      );
      return true;
    } catch (e, s) {
      LogUtils.e('重新扫描文件夹失败', tag: _tag, error: e, stackTrace: s);
      return false;
    }
  }

  /// 扫完之后原条目回来了没有。
  LocalMediaItem? _revivedOriginal() {
    final latest = _repository.getItem(widget.item.id);
    if (latest == null || latest.missing) return null;
    return latest.isPlayableNow ? latest : null;
  }

  Future<void> _onRescan() async {
    setState(() => _busy = true);
    await _rescanFolder();
    if (!mounted) return;
    final revived = _revivedOriginal();
    if (revived != null) {
      showAppToast(
        slang.t.localMedia.missing.found,
        type: AppToastType.success,
      );
      _pop(revived);
      return;
    }
    if (_isRemote) {
      setState(() => _busy = false);
      showAppToast(
        slang.t.download.relocation.stillMissing,
        type: AppToastType.warning,
      );
      return;
    }
    await _diagnose(announce: true);
  }

  /// 认领一个疑似改名件：扫一遍这层让它入库，再把它交给调用方打开。
  Future<void> _useCandidate(String path) async {
    setState(() => _busy = true);
    await _rescanFolder();
    if (!mounted) return;
    final id = LocalMediaItem.buildId(
      widget.item.sourceId,
      LocalMediaItem.hashPath(path),
    );
    final found = _repository.getItem(id);
    if (found != null && !found.missing) {
      showAppToast(
        slang.t.localMedia.missing.found,
        type: AppToastType.success,
      );
      _pop(found);
      return;
    }
    await _diagnose(announce: true);
  }

  Future<void> _grantPermission() async {
    if (Get.isRegistered<PermissionService>()) {
      await Get.find<PermissionService>().requestStoragePermission();
    }
    if (mounted) await _diagnose(announce: true);
  }

  Future<void> _remove() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // 只删记录：诊断之后文件可能又回来了，这里绝不碰磁盘。
      _repository.deleteItems(<String>[widget.item.id]);
      showAppToast(slang.t.localMedia.missing.removed);
    } catch (e, s) {
      LogUtils.e('从列表移除失败', tag: _tag, error: e, stackTrace: s);
    }
    _pop<LocalMediaItem?>(null);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final diagnosis = _diagnosis;
    final actions = <GlassDialogAction>[
      GlassDialogAction(
        label: t.localMedia.missing.removeFromList,
        destructive: true,
        emphasized: false,
        onPressed: _busy ? null : _remove,
      ),
      if (diagnosis?.kind == MissingKind.noAccess)
        GlassDialogAction(
          label: t.download.relocation.grantPermission,
          onPressed: _busy ? null : _grantPermission,
        )
      else if (diagnosis?.kind == MissingKind.volumeUnavailable)
        GlassDialogAction(
          label: t.download.relocation.checkAgain,
          onPressed: _busy ? null : () => _diagnose(announce: true),
        )
      else if (_canRescan)
        GlassDialogAction(
          label: _isRemote
              ? t.localMedia.missing.relistNas
              : t.localMedia.missing.rescanFolder,
          onPressed: _busy ? null : _onRescan,
        ),
    ];

    return GlassAlertDialog(
      title: t.localMedia.missing.title,
      maxWidth: 560,
      scrollable: true,
      actions: actions,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemHeader(item: widget.item),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isRemote
                ? _RemoteGone(key: const ValueKey('nas'), item: widget.item)
                : diagnosis == null
                ? const Padding(
                    key: ValueKey('busy'),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LinearProgressIndicator(),
                  )
                : MissingDiagnosisBody(
                    key: ValueKey(diagnosis.kind),
                    diagnosis: diagnosis,
                    busy: _busy,
                    onUseCandidate: _useCandidate,
                  ),
          ),
          if (_busy && diagnosis != null) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

/// 是哪一条：图标、文件名、大小。
class _ItemHeader extends StatelessWidget {
  const _ItemHeader({required this.item});

  final LocalMediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = item.sizeBytes;
    return Row(
      children: [
        Icon(
          item.kind == LocalMediaItemKind.video
              ? Icons.movie_outlined
              : Icons.image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ),
        if (size != null && size > 0) ...[
          const SizedBox(width: 8),
          Text(
            _formatBytes(size),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// NAS 条目：没有本机磁盘可诊断，照实说在 NAS 上找不到了。
class _RemoteGone extends StatelessWidget {
  const _RemoteGone({super.key, required this.item});

  final LocalMediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_outlined, color: tone, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              slang.t.localMedia.missing.nasGone(name: item.name),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
