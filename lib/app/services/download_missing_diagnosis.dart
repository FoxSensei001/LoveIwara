import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/download/download_task.model.dart'
    hide FileSystemException;
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 一条下载「在记录的位置找不到」时，到底是哪一种找不到。
///
/// 界面拿它说具体的话（哪个卷没挂上、哪一级文件夹没了、旁边有没有一个大小
/// 完全相同的文件），而不是笼统一句「可能被移动或删除了」。
enum MissingKind {
  /// 文件所在的存储卷整个不在：SD 卡没插、移动硬盘没接、网络盘没挂。
  volumeUnavailable,

  /// iOS 更新后沙盒容器换了路径，文件其实还在新容器里。
  containerChanged,

  /// 没有读这个位置的权限（安卓共享存储缺「所有文件访问」）。
  noAccess,

  /// 某一级上级文件夹已经不在了。
  folderMissing,

  /// 上级文件夹还在，只是里面没有这个文件 / 图库文件夹。
  fileMissing,
}

class MissingCandidate {
  const MissingCandidate({
    required this.path,
    required this.isDirectory,
    this.sizeBytes,
    this.modified,
  });

  final String path;
  final bool isDirectory;
  final int? sizeBytes;
  final DateTime? modified;
}

class MissingDiagnosis {
  const MissingDiagnosis({
    required this.kind,
    required this.recordedPath,
    this.existingPrefix,
    this.volumeRoot,
    this.rebasedPath,
    this.candidates = const [],
  });

  final MissingKind kind;
  final String recordedPath;

  /// [recordedPath] 里从根开始、**仍然存在**的最长那一段。界面据此把路径
  /// 分成「还在」与「没了」两截高亮，一眼看出断在哪一级。
  final String? existingPrefix;

  /// [MissingKind.volumeUnavailable] 时不在的那个卷根。
  final String? volumeRoot;

  /// [MissingKind.containerChanged] 时文件在新容器里的实际路径。
  final String? rebasedPath;

  /// [MissingKind.fileMissing] 时在原文件夹里找到的疑似改过名的那几份。
  final List<MissingCandidate> candidates;
}

/// 批量诊断时共用的磁盘缓存：同一个文件夹只列一次、同一个卷根只查一次。
///
/// 清理几千条失效记录时，它们多半挤在同一两个下载目录里；不缓存的话每一条
/// 都要把那个目录（可能上万个文件）重新列一遍、逐个 stat。
/// 「可能还能找回」的：卷没挂上、没权限、iOS 容器换了、旁边有疑似改名件。
/// 清理时默认不选，移动时选「移除记录」也跳过卷没挂上的那些；下载列表的
/// 文件健康缓存把它们只算「待确认」，不进强提醒计数。
bool isRecoverableMissing(MissingDiagnosis? d) {
  if (d == null) return false;
  return switch (d.kind) {
    MissingKind.volumeUnavailable ||
    MissingKind.noAccess ||
    MissingKind.containerChanged => true,
    MissingKind.fileMissing => d.candidates.isNotEmpty,
    MissingKind.folderMissing => false,
  };
}

class MissingDiagnosisCache {
  final Map<String, bool> _exists = {};
  final Map<String, Future<List<MissingCandidate>>> _listings = {};
}

/// 诊断一条找不到的下载。只读磁盘，不改任何东西。
///
/// 传 [cache] 即批量模式：目录列举与存在性判断会复用；图库的「疑似改名」
/// 探测（要逐个兄弟文件夹去翻图）在批量模式下略过，单条点开时再做。
Future<MissingDiagnosis> diagnoseMissingDownload(
  DownloadTask task, {
  MissingDiagnosisCache? cache,
}) async {
  Future<bool> exists(String target) async {
    if (cache == null) return _exists(target);
    return cache._exists[target] ??= await _exists(target);
  }

  final recorded = p.normalize(task.savePath);
  final isGallery = task.extData?.type == DownloadTaskExtDataType.gallery;

  // iOS：容器 UUID 换了，文件多半原样躺在新容器的同一相对位置。
  if (GetPlatform.isIOS) {
    try {
      final anchor = (await CommonUtils.getAppDirectory()).path;
      final rebased = DownloadPathService.rebaseSandboxPath(recorded, anchor);
      if (rebased != null && await exists(rebased)) {
        return MissingDiagnosis(
          kind: MissingKind.containerChanged,
          recordedPath: recorded,
          rebasedPath: rebased,
        );
      }
    } catch (e) {
      LogUtils.w('诊断 iOS 容器路径失败: $e', _tag);
    }
  }

  final existingPrefix = await _deepestExistingAncestor(recorded, exists);

  final volume = storageVolumeRootOf(recorded);
  if (volume != null && !await exists(volume)) {
    return MissingDiagnosis(
      kind: MissingKind.volumeUnavailable,
      recordedPath: recorded,
      existingPrefix: existingPrefix,
      volumeRoot: volume,
    );
  }

  if (await _lacksAndroidStorageAccess(recorded)) {
    return MissingDiagnosis(
      kind: MissingKind.noAccess,
      recordedPath: recorded,
      existingPrefix: existingPrefix,
    );
  }

  final parent = p.dirname(recorded);
  if (!await exists(parent)) {
    return MissingDiagnosis(
      kind: MissingKind.folderMissing,
      recordedPath: recorded,
      existingPrefix: existingPrefix,
    );
  }

  final List<MissingCandidate> candidates;
  try {
    candidates = isGallery && cache != null
        ? const []
        : await _findCandidates(
            task,
            parent,
            isGallery: isGallery,
            cache: cache,
          );
  } on FileSystemException catch (e) {
    LogUtils.w('列不出上级文件夹: $parent ($e)', _tag);
    return MissingDiagnosis(
      kind: MissingKind.noAccess,
      recordedPath: recorded,
      existingPrefix: existingPrefix,
    );
  }
  return MissingDiagnosis(
    kind: MissingKind.fileMissing,
    recordedPath: recorded,
    existingPrefix: existingPrefix,
    candidates: candidates,
  );
}

const _tag = 'DownloadMissingDiagnosis';

/// 一次最多翻看原文件夹里多少项。下载目录可能有上万个文件，诊断不能卡住弹窗。
const _scanLimit = 2000;
const _candidateLimit = 3;

Future<bool> _exists(String target) async =>
    await FileSystemEntity.type(target) != FileSystemEntityType.notFound;

Future<String?> _deepestExistingAncestor(
  String target,
  Future<bool> Function(String) exists,
) async {
  var current = p.dirname(target);
  while (true) {
    if (await exists(current)) return current;
    final parent = p.dirname(current);
    if (parent == current) return null;
    current = parent;
  }
}

/// 可插拔的存储卷根：只有这类位置「整个不在」才说得上是「卷没挂上」。
/// 系统盘 / 主存储永远在，返回 null。
String? storageVolumeRootOf(String target) {
  if (GetPlatform.isAndroid) {
    final root = DownloadPathService.storageVolumeRootOf(target);
    // 主存储永远在；它「不在」只能是权限问题，交给 noAccess 那一支。
    if (root == null || root.startsWith('/storage/emulated')) return null;
    if (root == '/sdcard' || root == '/storage/self/primary') return null;
    return root;
  }
  if (GetPlatform.isWindows) {
    final prefix = p.rootPrefix(target);
    return prefix.isEmpty ? null : prefix;
  }
  final parts = p.split(target);
  if (GetPlatform.isMacOS && parts.length >= 3 && parts[1] == 'Volumes') {
    return p.joinAll(parts.take(3));
  }
  if (GetPlatform.isLinux) {
    if (parts.length >= 4 && parts[1] == 'media') {
      return p.joinAll(parts.take(4));
    }
    if (parts.length >= 5 && parts[1] == 'run' && parts[2] == 'media') {
      return p.joinAll(parts.take(5));
    }
    if (parts.length >= 3 && parts[1] == 'mnt') return p.joinAll(parts.take(3));
  }
  return null;
}

Future<bool> _lacksAndroidStorageAccess(String target) async {
  if (!GetPlatform.isAndroid || !Get.isRegistered<DownloadPathService>()) {
    return false;
  }
  if (!DownloadPathService.to.isPublicDirectory(target)) return false;
  if (!Get.isRegistered<PermissionService>()) return false;
  try {
    return !await Get.find<PermissionService>().hasStoragePermission();
  } catch (_) {
    return false;
  }
}

/// 原文件夹里疑似「被改了名的它」：视频 / 单图认同扩展名且大小分毫不差；
/// 图库认「里面至少有一张我们记着的图」的兄弟文件夹。
Future<List<MissingCandidate>> _findCandidates(
  DownloadTask task,
  String parent, {
  required bool isGallery,
  MissingDiagnosisCache? cache,
}) async {
  if (cache != null && !isGallery) {
    final listing = await (cache._listings[parent] ??= _listFiles(parent));
    final wantExt = p.extension(task.savePath).toLowerCase();
    return [
      for (final c in listing)
        if (task.totalBytes > 0 &&
            c.sizeBytes == task.totalBytes &&
            p.extension(c.path).toLowerCase() == wantExt)
          c,
    ].take(_candidateLimit).toList();
  }
  final result = <MissingCandidate>[];
  final wantExt = p.extension(task.savePath).toLowerCase();
  var scanned = 0;
  await for (final entity in Directory(parent).list(followLinks: false)) {
    if (++scanned > _scanLimit || result.length >= _candidateLimit) break;
    if (isGallery) {
      if (entity is! Directory) continue;
      if (await looksLikeGalleryFolder(task, entity.path)) {
        result.add(MissingCandidate(path: entity.path, isDirectory: true));
      }
      continue;
    }
    if (entity is! File) continue;
    if (p.extension(entity.path).toLowerCase() != wantExt) continue;
    if (task.totalBytes <= 0) continue;
    final stat = await entity.stat();
    if (stat.size != task.totalBytes) continue;
    result.add(
      MissingCandidate(
        path: entity.path,
        isDirectory: false,
        sizeBytes: stat.size,
        modified: stat.modified,
      ),
    );
  }
  return result;
}

/// 批量模式下的目录快照：只收普通文件，带大小与修改时间。
Future<List<MissingCandidate>> _listFiles(String parent) async {
  final result = <MissingCandidate>[];
  var scanned = 0;
  await for (final entity in Directory(parent).list(followLinks: false)) {
    if (++scanned > _scanLimit) break;
    if (entity is! File) continue;
    final stat = await entity.stat();
    result.add(
      MissingCandidate(
        path: entity.path,
        isDirectory: false,
        sizeBytes: stat.size,
        modified: stat.modified,
      ),
    );
  }
  return result;
}

/// 图库文件夹里至少得有一张我们记着的图，才认它是这个图库。
Future<bool> looksLikeGalleryFolder(DownloadTask task, String folder) async {
  final data = task.extData?.data;
  if (data == null) return false;
  final localPaths = GalleryDownloadExtData.fromJson(data).localPaths.values;
  var checked = 0;
  for (final original in localPaths) {
    // 前几张就够判断了，几百张的图库不必逐张 stat。
    if (++checked > 20) break;
    // 只认直属文件：图库的图就平铺在自己文件夹里。拿相对路径去拼的话，
    // savePath 被污染成上级目录时 `G/1.jpg` 也能在上级里找到，会把上级误认成图库。
    if (await File(p.join(folder, p.basename(original))).exists()) return true;
  }
  return false;
}
