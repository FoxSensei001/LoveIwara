import 'package:i_iwara/app/utils/natural_sort_key.dart';

/// 本地库里的一条。
///
/// # ⛔ [id] 的形状是有约束的，不能随手改
///
/// 它会被 `localVideoRouteId()` 包成 `local_<id>` 再进 go_router 的**路径段**，
/// 所以只能用 URL 安全字符——`sourceId`（uuid）与 `pathHash`（十六进制）之间
/// **用 `-` 连接，不能用 `:`**。
///
/// 用 `(sourceId, pathHash)` 而不是单纯的 `hash(path)`，是因为源 A 完全可能是源 B
/// 的父目录（先加了 `Download/`，后来又加了 `Download/Anim/`）：只按路径做主键，
/// 同一个文件会在两个源之间互相顶掉 `source_id`，"按来源筛选"随之飘。
class LocalMediaItem {
  const LocalMediaItem({
    required this.id,
    required this.sourceId,
    required this.pathHash,
    required this.path,
    required this.kind,
    required this.name,
    required this.sortName,
    this.ext,
    this.sizeBytes,
    this.modifiedAt,
    this.durationMs,
    this.width,
    this.height,
    this.thumbPath,
    this.sidecarImagePath,
    this.vrFormatJson,
    this.folderPath,
    this.categoryId,
    this.downloadTaskId,
    this.lastPlayedAt,
    required this.addedAt,
    this.missing = false,
  });

  final String id;
  final String sourceId;
  final String pathHash;
  final String path;
  final LocalMediaItemKind kind;
  final String name;

  /// 自然序排序 key，入库时预计算（见 [naturalSortKey]）。
  /// 列表是 DB 分页的，"按名称排序"只能靠 `ORDER BY`，不能在 Dart 里比。
  final String sortName;

  final String? ext;
  final int? sizeBytes;
  final int? modifiedAt;
  final int? durationMs;
  final int? width;
  final int? height;

  /// 我们自己生成并落盘的缩略图。
  final String? thumbPath;

  /// ⭐ 同目录同名的现成封面（下载器普遍会写一张）。
  ///
  /// 有它就**不用抽帧**：零成本、不占并发闸，而且桌面端没有 `video_thumbnail`
  /// 这个包，读文件这条路三端一致——对下载器产出的那一大类文件，缩略图这件事
  /// 直接不用做。
  final String? sidecarImagePath;

  final String? vrFormatJson;
  final String? folderPath;
  final String? categoryId;

  /// 关联到的下载任务：只作**元数据装饰**（标题/作者/封面/可退回在线播）。
  /// ⛔ 反过来不成立——绝不往 `download_tasks` 塞假任务。
  final String? downloadTaskId;

  /// 最近一次保存观看进度的时间，供本地库「最近播放」排序使用。
  ///
  /// 与 [local_media_progress.updated_at] 同步维护，但放在条目表上才能让
  /// 分页查询直接走复合索引，而不是对每条结果执行相关子查询。
  final int? lastPlayedAt;

  final int addedAt;
  final bool missing;

  /// 拼 id。两处（建条目、按 id 查进度）必须用同一个拼法，所以收口在这里。
  static String buildId(String sourceId, String pathHash) =>
      '$sourceId-$pathHash';

  Map<String, Object?> toRow() => <String, Object?>{
    'id': id,
    'source_id': sourceId,
    'path_hash': pathHash,
    'path': path,
    'kind': kind.name,
    'name': name,
    'sort_name': sortName,
    'ext': ext,
    'size_bytes': sizeBytes,
    'modified_at': modifiedAt,
    'duration_ms': durationMs,
    'width': width,
    'height': height,
    'thumb_path': thumbPath,
    'sidecar_image_path': sidecarImagePath,
    'vr_format_json': vrFormatJson,
    'folder_path': folderPath,
    'category_id': categoryId,
    'download_task_id': downloadTaskId,
    'last_played_at': lastPlayedAt,
    'added_at': addedAt,
    'missing': missing ? 1 : 0,
  };

  factory LocalMediaItem.fromRow(Map<String, Object?> row) {
    return LocalMediaItem(
      id: row['id'] as String,
      sourceId: row['source_id'] as String,
      pathHash: (row['path_hash'] as String?) ?? '',
      path: (row['path'] as String?) ?? '',
      kind: (row['kind'] as String?) == LocalMediaItemKind.image.name
          ? LocalMediaItemKind.image
          : LocalMediaItemKind.video,
      name: (row['name'] as String?) ?? '',
      sortName: (row['sort_name'] as String?) ?? '',
      ext: row['ext'] as String?,
      sizeBytes: row['size_bytes'] as int?,
      modifiedAt: row['modified_at'] as int?,
      durationMs: row['duration_ms'] as int?,
      width: row['width'] as int?,
      height: row['height'] as int?,
      thumbPath: row['thumb_path'] as String?,
      sidecarImagePath: row['sidecar_image_path'] as String?,
      vrFormatJson: row['vr_format_json'] as String?,
      folderPath: row['folder_path'] as String?,
      categoryId: row['category_id'] as String?,
      downloadTaskId: row['download_task_id'] as String?,
      lastPlayedAt: row['last_played_at'] as int?,
      addedAt: row['added_at'] as int? ?? 0,
      missing: (row['missing'] as int? ?? 0) != 0,
    );
  }
}

enum LocalMediaItemKind { video, image }
