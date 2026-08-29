import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';

/// 稍后再看能装的两种东西。
///
/// 刻意不复用 `FavoriteItemType`——那个枚举里还有 `user`，而"把一个人加进稍后
/// 再看"没有意义；共用会让调用点不得不处理一个永远不会出现的分支。
enum WatchLaterItemType {
  video,
  image;

  static WatchLaterItemType? tryParse(String? raw) {
    for (final value in WatchLaterItemType.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

/// 列表页与抽屉共用的排序。只有两档，对应"临时队列"的两种用法：
/// 新加的先看（[recentlyAdded]）、先进先出（[earliestAdded]）。
enum WatchLaterSort {
  recentlyAdded,
  earliestAdded;

  /// 从配置里存的字符串还原。解析只放这一处——列表页与播放器抽屉共享同一份
  /// 排序偏好，两边各写一份解析迟早会分叉。
  static WatchLaterSort fromConfigValue(String? raw) =>
      raw == earliestAdded.name ? earliestAdded : recentlyAdded;
}

/// 稍后再看里的一条。
///
/// # ⛔ 为什么只存精简字段，不像 history 那样存整份 JSON
///
/// `Video.toJson()` 里带 `fileUrl` 和 `videoSources`——**会过期的播放地址**。
/// 而 `initialVideoInfo → cacheVideoInfo → fetchVideoDetail 命中缓存 → 直接拿
/// 缓存里的 fileUrl 起播` 这条链路在 `MyVideoStateController` 里**已经存在**，
/// 一旦把整份 JSON 存进本地库再回灌，等于给稍后再看内建了一个"点开先 404
/// 一次"的坑（下载模块的死链问题就是同一个形状）。
///
/// 所以这里把两件事分开：**画卡片**用本地快照（本类的字段），**真要播**时才
/// 拉一次详情拿新地址。
class WatchLaterItem {
  const WatchLaterItem({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.addedAt,
    this.thumbnailUrl,
    this.author,
    this.authorId,
    this.authorUsername,
    this.durationMs,
    this.numImages,
    this.isExternal = false,
    this.externalDomain,
    this.watchedAt,
    this.progressPermil = 0,
    this.invalidAt,
  });

  /// 自增主键。未落库的实例为 0。
  final int id;
  final String itemId;
  final WatchLaterItemType itemType;
  final String title;
  final String? thumbnailUrl;
  final String? author;
  final String? authorId;
  final String? authorUsername;

  /// 视频时长；图库为 null。
  final int? durationMs;

  /// 图库图片数；视频为 null。
  final int? numImages;

  final bool isExternal;
  final String? externalDomain;

  final DateTime addedAt;

  /// NULL = 未看完。只有应用在前台的观看才会写它，见 [WatchLaterService]。
  final DateTime? watchedAt;

  /// 千分比。与 [watchedAt] 是两件事——看到 30% 也该有进度条。
  final int progressPermil;

  /// 撞到"私有无权限 / 已删除"时的打点。只标记，不自动删。
  final DateTime? invalidAt;

  bool get isWatched => watchedAt != null;
  bool get isInvalid => invalidAt != null;

  /// 卡片进度条要显示的比例（0.0–1.0）。已看完的按满格画。
  double get progressRatio =>
      isWatched ? 1.0 : (progressPermil.clamp(0, 1000)) / 1000.0;

  factory WatchLaterItem.fromRow(Map<String, dynamic> row) {
    DateTime? seconds(Object? value) => value is int
        ? DateTime.fromMillisecondsSinceEpoch(value * 1000)
        : null;

    return WatchLaterItem(
      id: (row['id'] as int?) ?? 0,
      itemId: row['item_id'] as String,
      itemType:
          WatchLaterItemType.tryParse(row['item_type'] as String?) ??
          WatchLaterItemType.video,
      title: (row['title'] as String?) ?? '',
      thumbnailUrl: row['thumbnail_url'] as String?,
      author: row['author'] as String?,
      authorId: row['author_id'] as String?,
      authorUsername: row['author_username'] as String?,
      durationMs: row['duration_ms'] as int?,
      numImages: row['num_images'] as int?,
      isExternal: (row['is_external'] as int? ?? 0) != 0,
      externalDomain: row['external_domain'] as String?,
      addedAt: seconds(row['added_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      watchedAt: seconds(row['watched_at']),
      progressPermil: (row['progress_permil'] as int?) ?? 0,
      invalidAt: seconds(row['invalid_at']),
    );
  }

  /// 从列表/详情里拿到的 [Video] 建一条待写入的快照。
  ///
  /// 站外视频（`embedUrl` 非空）在加入那一刻就能判出来，直接把
  /// `isExternal` 记下——后面抽屉的连播队列要靠它把站外视频排除掉，
  /// 不然连播链会撞上跨站 301 断掉。
  factory WatchLaterItem.fromVideo(Video video) {
    final durationSeconds = video.file?.duration;
    return WatchLaterItem(
      id: 0,
      itemId: video.id,
      itemType: WatchLaterItemType.video,
      title: video.title?.trim() ?? '',
      thumbnailUrl: video.thumbnailUrl,
      author: video.user?.name,
      authorId: video.user?.id,
      authorUsername: video.user?.username,
      durationMs: durationSeconds == null ? null : durationSeconds * 1000,
      isExternal: video.isExternalVideo,
      externalDomain: video.isExternalVideo ? video.externalVideoDomain : null,
      addedAt: DateTime.now(),
    );
  }

  factory WatchLaterItem.fromImageModel(ImageModel image) {
    return WatchLaterItem(
      id: 0,
      itemId: image.id,
      itemType: WatchLaterItemType.image,
      title: image.title.trim(),
      thumbnailUrl: image.thumbnailUrl,
      author: image.user?.name,
      authorId: image.user?.id,
      authorUsername: image.user?.username,
      numImages: image.numImages,
      addedAt: DateTime.now(),
    );
  }

  WatchLaterItem copyWith({
    int? id,
    String? title,
    String? thumbnailUrl,
    int? progressPermil,
    DateTime? watchedAt,
    DateTime? invalidAt,
  }) {
    return WatchLaterItem(
      id: id ?? this.id,
      itemId: itemId,
      itemType: itemType,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author,
      authorId: authorId,
      authorUsername: authorUsername,
      durationMs: durationMs,
      numImages: numImages,
      isExternal: isExternal,
      externalDomain: externalDomain,
      addedAt: addedAt,
      watchedAt: watchedAt ?? this.watchedAt,
      progressPermil: progressPermil ?? this.progressPermil,
      invalidAt: invalidAt ?? this.invalidAt,
    );
  }
}
