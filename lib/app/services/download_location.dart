import 'package:path/path.dart' as p;

import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 下载目录「是哪一类地方」——决定要不要权限、卸载会不会被删、怎么给用户起名字。
enum DownloadLocationKind {
  /// App 专属空间（`Android/data/<包名>`、`/data/user/<n>/<包名>`、iOS 沙盒……）。
  /// 卸载即删、系统相册看不到。
  appPrivate,

  /// Android 主存储公共 `Download/` 之下。Android 11+ 不用任何权限就能写自己的文件。
  publicDownloads,

  /// Android 主存储上 `Download/` 以外的共享存储（`Movies/`、自建目录……）。
  sharedStorage,

  /// Android 的可移除卷（SD / TF 卡、U 盘）上、App 专属目录以外的地方。
  removableVolume,

  /// 桌面端系统「下载」文件夹之下。
  desktopDownloads,

  /// 桌面端其它任意位置。
  desktopOther,

  /// 认不出来的路径（不在任何已知卷上）。
  other,
}

/// 目录所在的「卷」，给用户看的第一层名字。
enum DownloadVolumeKind {
  /// 手机的内部存储（Android 主存储）。
  internal,

  /// Android 可移除卷。
  sdCard,

  /// 桌面端外接盘（macOS `/Volumes/…`、Linux `/media/…`）。
  externalDrive,

  /// App 专属空间——对用户来说它本身就是一个「地方」，不再细分卷。
  appSpace,

  /// 不显示卷名（桌面系统盘、认不出来的路径）。
  none,
}

/// 一个下载目录的结构化描述：UI 拿它拼友好名，流程拿它判要不要授权。
///
/// 友好名的规则：先判卷（内部存储 / SD 卡 / 外置盘 / 应用专属空间），再把卷根
/// （或系统「下载」文件夹）之下的相对路径按 `›` 连起来。**本地化不在这里做**：
/// [segments] 保留磁盘上的原名，[startsWithDownloads] 告诉 UI 第一段是系统的
/// 「下载」文件夹、要换成当前语言的叫法。
class DownloadLocation {
  const DownloadLocation({
    required this.path,
    required this.kind,
    required this.volume,
    required this.segments,
    this.volumeLabel,
    this.access = StorageAccessNeed.none,
    this.startsWithDownloads = false,
    this.truncated = false,
  });

  /// 绝对路径（原样，未归一化）。
  final String path;
  final DownloadLocationKind kind;
  final DownloadVolumeKind volume;

  /// 卷的原始标识：SD 卡的 `XXXX-XXXX`、外置盘的名字。内部存储为 null。
  final String? volumeLabel;

  /// 卷根（或系统「下载」文件夹）之下的相对路径段。
  final List<String> segments;

  /// 写这里要先拿到哪一档存储权限。
  final StorageAccessNeed access;

  /// [segments] 的第一段是系统的「下载」文件夹。
  final bool startsWithDownloads;

  /// [segments] 只留了末尾几段（路径太深），UI 在前面补一个 `…`。
  final bool truncated;

  bool get requiresPermission => access != StorageAccessNeed.none;

  /// 友好名里最多保留几段；再深的只留尾巴，前面用 `…` 代替。
  static const int maxSegments = 3;

  /// Android 主存储的三种别名。
  static final RegExp _primaryVolumeRoot = RegExp(
    r'^(/storage/emulated/\d+|/storage/self/primary|/sdcard)$',
  );

  /// 卷根是不是主存储（内部存储），而不是 SD 卡 / U 盘。
  static bool isPrimaryVolumeRoot(String volumeRoot) =>
      _primaryVolumeRoot.hasMatch(volumeRoot);

  static List<String> _tail(List<String> segments, {required bool keepHead}) {
    if (segments.length <= maxSegments) return segments;
    if (keepHead) {
      // 保住第一段（「下载」）+ 最后两段：「下载 › … › A › B」读起来比砍掉
      // 「下载」更有用。
      return [segments.first, ...segments.sublist(segments.length - 2)];
    }
    return segments.sublist(segments.length - maxSegments);
  }

  /// 按 Android 的存储规则算写 [dirPath] 要哪一档权限。
  ///
  /// [volumeRootOf] 与 [isAppPrivate] 由调用方注入（它们在
  /// `DownloadPathService` 里，那边也有自己的单测），这里只管三态判定：
  ///   - App 专属目录、以及不在任何卷上的路径 → none（权限也救不了后者，交给 probe）；
  ///   - API 30+：主存储的 `Download/` 及其子目录 → none，其余共享存储 → allFilesAccess；
  ///   - API 29 及以下 → legacyStorage。
  static StorageAccessNeed androidAccessNeedFor(
    String dirPath, {
    required int sdkInt,
    required bool isAppPrivate,
    required String? volumeRoot,
  }) {
    if (dirPath.isEmpty || isAppPrivate || volumeRoot == null) {
      return StorageAccessNeed.none;
    }
    if (sdkInt >= 30) {
      if (isPrimaryVolumeRoot(volumeRoot)) {
        final rel = _relativeSegments(dirPath, volumeRoot);
        if (rel.isNotEmpty && rel.first == 'Download') {
          return StorageAccessNeed.none;
        }
      }
      return StorageAccessNeed.allFilesAccess;
    }
    return StorageAccessNeed.legacyStorage;
  }

  static List<String> _relativeSegments(String dirPath, String root) {
    final normalized = p.posix.normalize(dirPath);
    if (normalized == root) return const [];
    return p.posix
        .split(p.posix.relative(normalized, from: root))
        .where((s) => s.isNotEmpty && s != '.')
        .toList();
  }

  /// 描述一个 Android 路径。
  static DownloadLocation describeAndroid(
    String dirPath, {
    required int sdkInt,
    required bool isAppPrivate,
    required String? volumeRoot,
  }) {
    final access = androidAccessNeedFor(
      dirPath,
      sdkInt: sdkInt,
      isAppPrivate: isAppPrivate,
      volumeRoot: volumeRoot,
    );
    if (isAppPrivate) {
      return DownloadLocation(
        path: dirPath,
        kind: DownloadLocationKind.appPrivate,
        volume: DownloadVolumeKind.appSpace,
        segments: const [],
        access: access,
      );
    }
    if (volumeRoot == null) {
      final parts = p.posix
          .split(p.posix.normalize(dirPath))
          .where((s) => s.isNotEmpty && s != '/')
          .toList();
      final tail = _tail(parts, keepHead: false);
      return DownloadLocation(
        path: dirPath,
        kind: DownloadLocationKind.other,
        volume: DownloadVolumeKind.none,
        segments: tail,
        truncated: tail.length < parts.length,
        access: access,
      );
    }
    final primary = isPrimaryVolumeRoot(volumeRoot);
    final rel = _relativeSegments(dirPath, volumeRoot);
    final inDownloads = rel.isNotEmpty && rel.first == 'Download';
    final tail = _tail(rel, keepHead: inDownloads);
    return DownloadLocation(
      path: dirPath,
      kind: !primary
          ? DownloadLocationKind.removableVolume
          : inDownloads
          ? DownloadLocationKind.publicDownloads
          : DownloadLocationKind.sharedStorage,
      volume: primary ? DownloadVolumeKind.internal : DownloadVolumeKind.sdCard,
      volumeLabel: primary ? null : p.posix.basename(volumeRoot),
      segments: tail,
      startsWithDownloads: inDownloads,
      truncated: tail.length < rel.length,
      access: access,
    );
  }

  /// 桌面路径所在的外接卷根；系统盘 / 认不出来返回 null。
  ///
  /// macOS 认 `/Volumes/<名字>`，Linux 认 `/media/<用户>/<名字>`、
  /// `/run/media/<用户>/<名字>`、`/mnt/<名字>`。Windows 的盘符不算「外接」——
  /// 看不出 D: 是第二块内置盘还是 U 盘，只把它当卷名显示（见 [describeDesktop]）。
  static String? desktopExternalVolumeRoot(
    String dirPath, {
    required p.Context context,
    required bool isMacOS,
    required bool isLinux,
  }) {
    final parts = context.split(context.normalize(dirPath));
    if (isMacOS && parts.length >= 3 && parts[1] == 'Volumes') {
      return context.joinAll(parts.take(3));
    }
    if (isLinux) {
      if (parts.length >= 4 && parts[1] == 'media') {
        return context.joinAll(parts.take(4));
      }
      if (parts.length >= 5 && parts[1] == 'run' && parts[2] == 'media') {
        return context.joinAll(parts.take(5));
      }
      if (parts.length >= 3 && parts[1] == 'mnt') {
        return context.joinAll(parts.take(3));
      }
    }
    return null;
  }

  /// 描述一个桌面路径。[downloadsDir] 是系统「下载」文件夹（拿不到传 null）。
  static DownloadLocation describeDesktop(
    String dirPath, {
    required p.Context context,
    required String? downloadsDir,
    required bool isMacOS,
    required bool isLinux,
    required bool isWindows,
  }) {
    final normalized = context.normalize(dirPath);
    if (downloadsDir != null &&
        (context.equals(downloadsDir, normalized) ||
            context.isWithin(downloadsDir, normalized))) {
      final rel = context.equals(downloadsDir, normalized)
          ? const <String>[]
          : context.split(context.relative(normalized, from: downloadsDir));
      final segments = [context.basename(downloadsDir), ...rel];
      final tail = _tail(segments, keepHead: true);
      return DownloadLocation(
        path: dirPath,
        kind: DownloadLocationKind.desktopDownloads,
        volume: DownloadVolumeKind.none,
        segments: tail,
        startsWithDownloads: true,
        truncated: tail.length < segments.length,
      );
    }

    final external = desktopExternalVolumeRoot(
      normalized,
      context: context,
      isMacOS: isMacOS,
      isLinux: isLinux,
    );
    final String root;
    DownloadVolumeKind volume = DownloadVolumeKind.none;
    String? volumeLabel;
    if (external != null) {
      root = external;
      volume = DownloadVolumeKind.externalDrive;
      volumeLabel = context.basename(external);
    } else {
      root = context.rootPrefix(normalized);
      if (isWindows && root.isNotEmpty) {
        // 「C:」这样的盘符对 Windows 用户是有意义的卷名。
        volumeLabel = root.replaceAll(RegExp(r'[\\/]+$'), '');
      }
    }
    final rel = root.isEmpty
        ? context.split(normalized)
        : context.split(context.relative(normalized, from: root));
    final cleaned = rel.where((s) => s.isNotEmpty && s != '.').toList();
    final tail = _tail(cleaned, keepHead: false);
    return DownloadLocation(
      path: dirPath,
      kind: DownloadLocationKind.desktopOther,
      volume: volume,
      volumeLabel: volumeLabel,
      segments: tail,
      truncated: tail.length < cleaned.length,
    );
  }
}

/// 「这个目录现在能不能用」的检查结果（[DownloadPathService.probe]）。
enum DownloadProbeOutcome {
  ok,

  /// 建不了目录 / 写不了文件（只读、被系统保护、卷在但拒绝写入……）。
  notWritable,

  /// 所在的卷不在（SD 卡拔了、外置盘没接）。
  volumeMissing,

  /// 缺存储权限（见 [DownloadProbeResult.access]）。
  needsPermission,
}

class DownloadProbeResult {
  const DownloadProbeResult({
    required this.path,
    required this.outcome,
    this.access = StorageAccessNeed.none,
    this.freeBytes,
    this.error,
    this.createdDirectories = const [],
  });

  final String path;
  final DownloadProbeOutcome outcome;

  /// 探测时新建出来的目录（由浅到深）。用户在确认一步取消时要把它们收回，
  /// 否则只是「看了一眼」就在磁盘上留下一个空文件夹。
  final List<String> createdDirectories;
  final StorageAccessNeed access;

  /// 可用空间（字节）；拿不到为 null。
  final int? freeBytes;

  /// 原始错误（只进日志 / 诊断，不直接给用户看）。
  final Object? error;

  bool get ok => outcome == DownloadProbeOutcome.ok;
}

/// 下载为什么没落到用户选的目录、临时退回了 App 专属空间。
enum DownloadFallbackReason {
  /// 缺存储权限。
  needsPermission,

  /// 所在的卷不在。
  volumeMissing,

  /// 目录建不出来。
  cannotCreate,

  /// 目录在，但写不进去。
  notWritable,
}

/// 回退原因的人话标签。
///
/// 放在 enum 旁边而不是某一层里：位置卡要用它写横幅，下载服务要用它写完成
/// 回执——两边说的必须是同一句话，各抄一份 switch 迟早分叉。
String downloadFallbackReasonLabel(DownloadFallbackReason reason) {
  final t = slang.t.download.location;
  return switch (reason) {
    DownloadFallbackReason.needsPermission => t.fallbackReasonPermission,
    DownloadFallbackReason.volumeMissing => t.fallbackReasonVolumeMissing,
    DownloadFallbackReason.cannotCreate => t.fallbackReasonCannotCreate,
    DownloadFallbackReason.notWritable => t.fallbackReasonNotWritable,
  };
}
