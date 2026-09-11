import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 本地媒体库中的目录实体。
///
/// # ⛔ `rel_path` 是树的权威，`folder_path` 只是附属
///
/// iOS 沙盒容器 UUID 会随升级漂移，bookmark 重解析出的新根路径会让所有绝对路径失效；
/// rel_path 不含根前缀（源根为 ''，子路径为 'a' / 'a/b'），所以漂移后重扫只更新 folder_path，
/// 树结构一行都不用动。
///
/// # ⛔ [id] 的构造口径
///
/// 与 `LocalMediaItem.id` 完全一致：`'$sourceId-${sha1(relPath)}'`，
/// 同源同相对路径具有唯一且跨设备/跨重扫稳定的 id。
class LocalMediaFolder {
  const LocalMediaFolder({
    required this.id,
    required this.sourceId,
    required this.relPath,
    this.parentRelPath,
    required this.name,
    required this.sortName,
    this.folderPath,
    this.videoCount = 0,
    this.imageCount = 0,
    this.childFolderCount = 0,
    this.coverPath,
    this.modifiedAt,
    this.missing = false,
    this.probedAt,
    this.coverPinned = false,
    this.coverBorrowed = false,
  });

  final String id;
  final String sourceId;

  /// 相对源根的路径，源根本身为空字符串 ''，用 '/' 分隔，不带前导斜杠。
  final String relPath;

  /// 源根这一行为 NULL；'a' 的 parent 是 ''；'a/b' 的 parent 是 'a'。
  final String? parentRelPath;

  /// 目录名（rel_path 的最后一段）；源根这一行存源的 displayName。
  final String name;

  /// 自然排序键，口径与 items.sort_name 完全一致。
  final String sortName;

  /// 扫描时看到的绝对路径，用于跟 items.folder_path join 和展示。
  final String? folderPath;

  /// 直接子视频数（不含子目录里的）。
  final int videoCount;

  /// 直接子图片数（不含子目录里的）。
  final int imageCount;

  /// 直接子目录数。
  final int childFolderCount;

  /// 封面文件绝对路径，可空。
  final String? coverPath;

  final int? modifiedAt;
  final bool missing;

  /// 上一次**真的把这个目录列出来看过**的时间戳；null ＝ 还没看过。
  ///
  /// # ⛔ 它不是 `lastScanAt` 的目录版，是「藏空目录」那条规则的前提
  ///
  /// 懒扫描下，一个目录的三个计数为 0 有两种完全不同的含义：**看过、里面确实
  /// 什么都没有**（该藏），和**压根还没看过**（不知道，必须显示）。没有这一列
  /// 就分不开，于是「藏空目录」会顺手把所有还没走到的子目录一起藏掉——用户点进
  /// 一个大目录会看到一片空白，而里面明明有东西。
  ///
  /// 写它的只有目录级扫描（[LocalMediaScanService.scanFolder]）和全量扫描收尾。
  final int? probedAt;

  /// 用户自己指定过这个目录的封面。
  ///
  /// ⛔ 置位之后扫描器**不许再覆盖 `cover_path`**（见
  /// `LocalMediaRepository.upsertFolders` 里那段 CASE）：扫描每次都会挑一张"它认为
  /// 合适"的封面，不拦住的话用户设完下一次进这一层就被换回去了，表现成"设置没生效"。
  final bool coverPinned;

  /// 当前封面是不是「借」自子目录（四层降级里最低的一档）。
  ///
  /// 打这个标是为了让第 3 档（本目录直属视频的缩略图）能顶掉它——借来的封面往往
  /// 最先落地，不分辨的话父目录会永远挂着子目录那张图。
  final bool coverBorrowed;

  /// 对相对路径计算 sha1。
  static String hashRelPath(String relPath) =>
      sha1.convert(utf8.encode(relPath)).toString();

  /// 拼 id：与 items 保持一致，用 `sourceId-sha1(relPath)`。
  static String buildId(String sourceId, String relPath) =>
      '$sourceId-${hashRelPath(relPath)}';

  bool get isRoot => relPath.isEmpty;
  int get totalCount => videoCount + imageCount;
  bool get hasOnlyImages => videoCount == 0 && imageCount > 0;
  bool get hasOnlyVideos => imageCount == 0 && videoCount > 0;
  bool get isEmptyLeaf => totalCount == 0 && childFolderCount == 0;

  Map<String, Object?> toRow() => <String, Object?>{
    'id': id,
    'source_id': sourceId,
    'rel_path': relPath,
    'parent_rel_path': parentRelPath,
    'name': name,
    'sort_name': sortName,
    'folder_path': folderPath,
    'video_count': videoCount,
    'image_count': imageCount,
    'child_folder_count': childFolderCount,
    'cover_path': coverPath,
    'modified_at': modifiedAt,
    'missing': missing ? 1 : 0,
    'probed_at': probedAt,
    'cover_pinned': coverPinned ? 1 : 0,
    'cover_borrowed': coverBorrowed ? 1 : 0,
  };

  Map<String, Object?> toMap() => toRow();

  factory LocalMediaFolder.fromRow(Map<String, Object?> row) {
    return LocalMediaFolder(
      id: row['id'] as String,
      sourceId: row['source_id'] as String,
      relPath: (row['rel_path'] as String?) ?? '',
      parentRelPath: row['parent_rel_path'] as String?,
      name: (row['name'] as String?) ?? '',
      sortName: (row['sort_name'] as String?) ?? '',
      folderPath: row['folder_path'] as String?,
      videoCount: (row['video_count'] as int?) ?? 0,
      imageCount: (row['image_count'] as int?) ?? 0,
      childFolderCount: (row['child_folder_count'] as int?) ?? 0,
      coverPath: row['cover_path'] as String?,
      modifiedAt: row['modified_at'] as int?,
      missing: (row['missing'] as int? ?? 0) != 0,
      probedAt: row['probed_at'] as int?,
      coverPinned: (row['cover_pinned'] as int? ?? 0) != 0,
      coverBorrowed: (row['cover_borrowed'] as int? ?? 0) != 0,
    );
  }

  LocalMediaFolder copyWith({
    String? id,
    String? sourceId,
    String? relPath,
    String? parentRelPath,
    bool setParentRelPathNull = false,
    String? name,
    String? sortName,
    String? folderPath,
    bool setFolderPathNull = false,
    int? videoCount,
    int? imageCount,
    int? childFolderCount,
    String? coverPath,
    bool setCoverPathNull = false,
    int? modifiedAt,
    int? probedAt,
    bool? coverPinned,
    bool? coverBorrowed,
    bool setModifiedAtNull = false,
    bool? missing,
  }) {
    return LocalMediaFolder(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      relPath: relPath ?? this.relPath,
      parentRelPath: setParentRelPathNull
          ? null
          : (parentRelPath ?? this.parentRelPath),
      name: name ?? this.name,
      sortName: sortName ?? this.sortName,
      folderPath: setFolderPathNull ? null : (folderPath ?? this.folderPath),
      videoCount: videoCount ?? this.videoCount,
      imageCount: imageCount ?? this.imageCount,
      childFolderCount: childFolderCount ?? this.childFolderCount,
      coverPath: setCoverPathNull ? null : (coverPath ?? this.coverPath),
      modifiedAt: setModifiedAtNull ? null : (modifiedAt ?? this.modifiedAt),
      missing: missing ?? this.missing,
      probedAt: probedAt ?? this.probedAt,
      coverPinned: coverPinned ?? this.coverPinned,
      coverBorrowed: coverBorrowed ?? this.coverBorrowed,
    );
  }
}

/// 常用目录（置顶目录）。
class LocalPinnedFolder {
  const LocalPinnedFolder({
    required this.id,
    required this.sourceId,
    required this.relPath,
    required this.displayName,
    required this.createdAt,
    this.sortOrder = 0,
  });

  final String id;
  final String sourceId;
  final String relPath;

  /// 置顶时快照的名字，源被改名也不影响这里显示。
  final String displayName;

  final int createdAt;
  final int sortOrder;

  static String buildId(String sourceId, String relPath) =>
      '$sourceId-${LocalMediaFolder.hashRelPath(relPath)}';

  Map<String, Object?> toRow() => <String, Object?>{
    'id': id,
    'source_id': sourceId,
    'rel_path': relPath,
    'display_name': displayName,
    'created_at': createdAt,
    'sort_order': sortOrder,
  };

  Map<String, Object?> toMap() => toRow();

  factory LocalPinnedFolder.fromRow(Map<String, Object?> row) {
    return LocalPinnedFolder(
      id: row['id'] as String,
      sourceId: row['source_id'] as String,
      relPath: (row['rel_path'] as String?) ?? '',
      displayName: (row['display_name'] as String?) ?? '',
      createdAt: (row['created_at'] as int?) ?? 0,
      sortOrder: (row['sort_order'] as int?) ?? 0,
    );
  }

  LocalPinnedFolder copyWith({
    String? id,
    String? sourceId,
    String? relPath,
    String? displayName,
    int? createdAt,
    int? sortOrder,
  }) {
    return LocalPinnedFolder(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      relPath: relPath ?? this.relPath,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
