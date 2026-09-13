import 'dart:io';

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
    this.mediaStoreUri,
    this.lastPlayedAt,
    this.favoritedAt,
    this.fps,
    this.fpsProbedAt,
    this.metaProbedAt,
    this.thumbIsCustom = false,
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

  /// MediaStore 的原始 content:// URI 句柄。
  ///
  /// 当条目身份按真实路径重建后，原本的 content:// 句柄保留在这一列，作为路径
  /// 直读不可用（如仅有 READ_MEDIA_VIDEO 权限而受 scoped storage 限制）时的
  /// 播放兜底。
  final String? mediaStoreUri;

  /// 最近一次保存观看进度的时间，供本地库「最近播放」排序使用。
  ///
  /// 与 [local_media_progress.updated_at] 同步维护，但放在条目表上才能让
  /// 分页查询直接走复合索引，而不是对每条结果执行相关子查询。
  final int? lastPlayedAt;

  /// 用户把这一条标为「精选」的时间戳。为 null 表示未标为精选。
  final int? favoritedAt;

  /// 视频帧率。为 null 表示尚未探测出来（图片永远为 null）。
  final double? fps;

  /// 什么时候探测过帧率（毫秒时间戳），NULL 表示从没探测过。
  ///
  /// ⛔ 不能用 `fps == null` 当「还没探测过」：容器里本来就不写帧率的文件永远探不出
  /// 值，那样每次冷启动后第一次滚到它都要重付一遍轮询。内存里那份负缓存挡不住——
  /// 它随进程清零。
  final int? fpsProbedAt;

  /// 什么时候探测过时长/宽高（毫秒时间戳），NULL 表示从没探测过。
  ///
  /// ⛔ 理由同 [fpsProbedAt]：探不出元数据的坏文件（截断、编码不认识）永远是
  /// `durationMs == null`，只靠内存负缓存的话，每次冷启动都要把它们重新排队开一次
  /// Player。文件指纹变了（换了个文件）时 `upsertItems` 会把它清回 NULL。
  final int? metaProbedAt;

  /// [thumbPath] 是不是用户**手动指定**的封面。
  ///
  /// ⛔ 挑封面的默认口径是「同名 sidecar 优先、其次我们抽的帧」——sidecar 是下载器
  /// 写的现成图，比抽帧好。但用户亲手挑过的那张必须压过 sidecar，否则「设为封面」
  /// 点完卡片纹丝不动。判据收口在 [coverImagePath]，SQL 侧挑封面的几处同一口径。
  final bool thumbIsCustom;

  final int addedAt;
  final bool missing;

  /// 拼 id。两处（建条目、按 id 查进度）必须用同一个拼法，所以收口在这里。
  static String buildId(String sourceId, String pathHash) =>
      '$sourceId-$pathHash';

  /// 这一条拿来当封面的那张图。
  ///
  /// 图片就是它自己；视频按「手动指定的缩略图 > 同名 sidecar > 自动抽的帧」。
  /// ⛔ 仓库里 `folderCoverCandidates` / `sourceCoverCandidates` 挑候选时是同一条
  /// 优先级，改这里要一起改。
  String? get coverImagePath {
    if (kind == LocalMediaItemKind.image) return path;
    final thumb = thumbPath;
    if (thumbIsCustom && thumb != null && thumb.isNotEmpty) return thumb;
    final sidecar = sidecarImagePath;
    if (sidecar != null && sidecar.isNotEmpty) return sidecar;
    return thumb;
  }

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
    'media_store_uri': mediaStoreUri,
    'last_played_at': lastPlayedAt,
    'favorited_at': favoritedAt,
    'fps': fps,
    'fps_probed_at': fpsProbedAt,
    'meta_probed_at': metaProbedAt,
    'thumb_is_custom': thumbIsCustom ? 1 : 0,
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
      mediaStoreUri: row['media_store_uri'] as String?,
      lastPlayedAt: row['last_played_at'] as int?,
      favoritedAt: row['favorited_at'] as int?,
      fps: (row['fps'] as num?)?.toDouble(),
      fpsProbedAt: row['fps_probed_at'] as int?,
      metaProbedAt: row['meta_probed_at'] as int?,
      thumbIsCustom: (row['thumb_is_custom'] as int? ?? 0) != 0,
      addedAt: row['added_at'] as int? ?? 0,
      missing: (row['missing'] as int? ?? 0) != 0,
    );
  }
}

enum LocalMediaItemKind { video, image }

extension LocalMediaPlaybackTarget on LocalMediaItem {
  /// 播放 / 解码时该喂给底层的那个串。
  ///
  /// ⛔ 优先真实路径：拿到真实路径，mpv 能直接放，`content://` 那条"先把整个文件
  /// 拷进缓存"的路就整个不需要了。只有在路径读不到时才回退到 MediaStore 句柄
  /// ——只授予 `READ_MEDIA_VIDEO`（没给「所有文件访问」）时，按路径直读会被
  /// scoped storage 挡住，那时只有 URI 能用。
  String resolvePlaybackTarget() {
    if (!path.startsWith('content://') && File(path).existsSync()) return path;
    final uri = mediaStoreUri;
    return uri != null && uri.isNotEmpty ? uri : path;
  }

  /// 这一条还缺派生出来的元数据吗。
  ///
  /// # ⛔ 卡片的短路判断与派生服务的开工判断必须共用这一个判据
  ///
  /// 卡片为了省掉一次队列往返，会在「封面有了、元数据也齐了」时直接不问派生服务。
  /// 一旦这里和服务端各写一份"齐了"的定义，新加的字段就会静默失效：派生服务明明
  /// 判定要补，卡片却提前 return，那个字段永远是 NULL 而且**一条日志都不会有**。
  ///
  /// 加帧率那次就是这么翻的车——服务层加好了 `needFps`，卡片这边的判据还停在
  /// 「时长 + 宽高」，于是全库 138 个视频的 fps 一个都没补上。
  ///
  /// 以后再加可派生字段，**只改这里**。
  bool get needsDerivedMetadata => switch (kind) {
    // 图片没有时长也没有帧率，只有宽高可派生。
    LocalMediaItemKind.image => width == null || height == null,
    // ⛔ 帧率判「探测过没有」而不是「有没有值」，否则容器不写帧率的文件每次
    // 冷启动都会被重新排进派生队列，白开一次 Player。
    // 时长/宽高同理：[metaProbedAt] 非空＝这个文件版本探过了（探没探出值都算），
    // 不然读不出元数据的坏文件每次冷启动滚进视野都要白开一次 Player。
    LocalMediaItemKind.video =>
      (metaProbedAt == null &&
              (durationMs == null || width == null || height == null)) ||
          (fps == null && fpsProbedAt == null),
  };

  /// 这一条能不能被「精选」。
  ///
  /// ⛔ **精选是视频独有的**。图片没有精选这回事：聚合 Tab 只有「精选视频」
  /// （`countFavorited` 默认按 video 数），图片的排序字段表里也从来没有精选那一档。
  /// 给图片标上的精选是**标了也没地方看**的死状态——菜单里能标，标完哪儿都不显示。
  ///
  /// 所以判据只有这一份，菜单要不要出那一条、卡片要不要画那颗星，都读它。
  /// （2026-09-11 用户发现图片卡片上还有精选入口，明确说了只有视频有。）
  bool get supportsFavorite => kind == LocalMediaItemKind.video;

  /// 这一条现在还放得出来吗（真实路径在，或者有 MediaStore 句柄）。
  bool get isPlayableNow {
    if (path.startsWith('content://')) return true;
    if (File(path).existsSync()) return true;
    final uri = mediaStoreUri;
    return uri != null && uri.isNotEmpty;
  }
}
