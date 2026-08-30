import 'dart:math';

import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/models/video.model.dart';

/// 一个池（以及池里的条目）装的是什么。
///
/// # 为什么是一个维度，而不是另开一套模型
///
/// 图库的「接着看」和视频的**结构完全一样**：同样是"从某个列表进来、按顺序往
/// 下一条走"，同样有稍后再看 / 最爱 / 本地收藏夹 / 作者的作品这几类来源。差别
/// 只有两处：条目落到哪个详情页（[PlaybackQueueNavigator] 据此选路由），以及
/// 列表行上那枚角标写时长还是写张数。另开一套模型等于把翻页、去重、游标、
/// LRU、抽屉那一整套逻辑抄第二遍。
///
/// ⛔ **一个池里不许混装两种**：抽屉的契约是"接下来能接着看的东西"，而视频和
/// 图库落在两个不同的详情页——混在一起的话"下一条"会把用户从播放器扔进图库
/// （稍后再看池一直排除图库就是这个道理）。所以类型是**池**的属性，条目跟着
/// 池走。
enum PlaybackMediaType {
  video,
  gallery;

  bool get isGallery => this == PlaybackMediaType.gallery;
}

enum InnerPlaylistSource {
  authorProfile,
  favoritesVideoList,
  playlistDetail,
  popularVideoList,
  searchResultVideoList,
  relatedVideosTab,
  subscriptionVideoList,

  /// 标签视频列表页（`/tag_videos/:tagId`）。
  tagMediaList,
}

class InnerPlaylistItemSnapshot {
  final String id;
  final String title;
  final String thumbnailUrl;

  /// 统计三件套。**null = 这个池不知道**，不是「零」——本地库（稍后再看 /
  /// 本地收藏夹）只存了标题封面作者，从来没有播放量。两者混成 0 之后，界面上
  /// 「0 次播放」既可能是真没人看，也可能是我们没这份数据，读的人分不出来，
  /// 于是只能整段不显示。分开之后有就显示、没有就让位。
  final int? numViews;
  final int? numLikes;
  final int? numComments;
  final bool liked;
  final bool isPrivate;
  final bool isExternalVideo;
  final String externalVideoDomain;
  final DateTime? createdAt;

  /// 作者显示名与 username（username 用来跳作者主页）。本地库那两个池也存着
  /// 这两样，所以「接着看」列表里每一条都认得出是谁的。
  final String? authorName;
  final String? authorUsername;

  /// 时长（秒）。站外视频与本地收藏夹拿不到，为 null。
  final int? durationSeconds;

  /// 图库的张数。视频恒为 null，图库拿不到时也为 null（同 [numViews] 那条：
  /// **null 是"不知道"，不是 0**）。
  final int? numImages;

  /// 这一条**在本地存的是哪一档清晰度**（`'1080'` / `'Source'` …）。
  ///
  /// 只有下载池答得上来：它装的就是磁盘上那些文件，而"存的是哪一档"是这类条目
  /// 独有、也是用户最想先看到的那个信息（同一部片子下过 720 还是原画，决定他
  /// 要不要点）。接口来的池一律为 null——在线视频的清晰度是进播放器之后才挑的，
  /// 列表上写一个数只会误导。
  final String? localQuality;

  /// 看到哪儿了（千分比，0 = 没记录）。目前只有稍后再看这个池带得出来。
  final int progressPermil;

  /// 列表页构建快照时携带的原始视频对象，用于侧边栏点击时立即跳转——
  /// 无需再预加载视频详情即可作为目标页的 initialVideoInfo（缩略图、标题等先行渲染）。
  /// 仅内存传递，不参与序列化/持久化。
  final Video? sourceVideo;

  const InnerPlaylistItemSnapshot({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    this.numViews,
    this.numLikes,
    this.numComments,
    required this.liked,
    required this.isPrivate,
    required this.isExternalVideo,
    required this.externalVideoDomain,
    this.createdAt,
    this.authorName,
    this.authorUsername,
    this.durationSeconds,
    this.numImages,
    this.localQuality,
    this.progressPermil = 0,
    this.sourceVideo,
  });

  factory InnerPlaylistItemSnapshot.fromVideo(Video video) {
    return InnerPlaylistItemSnapshot(
      id: video.id,
      title: video.title?.trim().isNotEmpty == true ? video.title!.trim() : '',
      thumbnailUrl: video.thumbnailUrl,
      numViews: video.numViews,
      numLikes: video.numLikes,
      numComments: video.numComments,
      liked: video.liked == true,
      isPrivate: video.private == true,
      isExternalVideo: video.isExternalVideo,
      externalVideoDomain: video.externalVideoDomain,
      createdAt: video.createdAt,
      authorName: video.user?.name,
      authorUsername: video.user?.username,
      durationSeconds: video.file?.duration,
      sourceVideo: video,
    );
  }

  /// 图库快照。与 [fromVideo] 一一对应，只是"时长"换成了"张数"。
  factory InnerPlaylistItemSnapshot.fromGallery(ImageModel gallery) {
    return InnerPlaylistItemSnapshot(
      id: gallery.id,
      title: gallery.title.trim(),
      thumbnailUrl: gallery.thumbnailUrl,
      numViews: gallery.numViews,
      numLikes: gallery.numLikes,
      numComments: gallery.numComments,
      liked: gallery.liked,
      isPrivate: false,
      isExternalVideo: false,
      externalVideoDomain: '',
      createdAt: gallery.createdAt,
      authorName: gallery.user?.name,
      authorUsername: gallery.user?.username,
      numImages: gallery.numImages,
    );
  }

  InnerPlaylistItemSnapshot copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    int? numViews,
    int? numLikes,
    int? numComments,
    bool? liked,
    bool? isPrivate,
    bool? isExternalVideo,
    String? externalVideoDomain,
    DateTime? createdAt,
    String? authorName,
    String? authorUsername,
    int? durationSeconds,
    int? numImages,
    String? localQuality,
    int? progressPermil,
    Video? sourceVideo,
  }) {
    return InnerPlaylistItemSnapshot(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      numViews: numViews ?? this.numViews,
      numLikes: numLikes ?? this.numLikes,
      numComments: numComments ?? this.numComments,
      liked: liked ?? this.liked,
      isPrivate: isPrivate ?? this.isPrivate,
      isExternalVideo: isExternalVideo ?? this.isExternalVideo,
      externalVideoDomain: externalVideoDomain ?? this.externalVideoDomain,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      numImages: numImages ?? this.numImages,
      localQuality: localQuality ?? this.localQuality,
      progressPermil: progressPermil ?? this.progressPermil,
      sourceVideo: sourceVideo ?? this.sourceVideo,
    );
  }
}

class InnerPlaylistContext {
  static const int maxPlaylistItems = 100;
  final InnerPlaylistSource source;
  final List<InnerPlaylistItemSnapshot> items;
  final String currentVideoId;

  /// 这份列表**是怎么查出来的**（接口 + 参数）。给得出来的列表页才有。
  ///
  /// 有它，详情页的「来源」池就不再是一份到底就没了的快照，而是能顺着同一份
  /// 查询一直翻下去（见 `RemoteListPlaybackQueue`）；[items] 那时只当种子用。
  ///
  /// ⛔ 给了它就**不再抽样**（见 [_limitItems]）：种子必须是列表的自然顺序，
  /// 打乱之后池接着翻回来的原序和前半截对不上。
  final MediaListQuery? query;

  const InnerPlaylistContext({
    required this.source,
    required this.items,
    required this.currentVideoId,
    this.query,
  });

  factory InnerPlaylistContext.fromVideos({
    required InnerPlaylistSource source,
    required Iterable<Video> videos,
    required String currentVideoId,
    int maxItems = maxPlaylistItems,
    MediaListQuery? query,
  }) {
    final seen = <String>{};
    final items = <InnerPlaylistItemSnapshot>[];
    final effectiveMaxItems = maxItems <= 0
        ? maxPlaylistItems
        : min(maxItems, maxPlaylistItems);

    for (final video in videos) {
      final id = video.id.trim();
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      items.add(InnerPlaylistItemSnapshot.fromVideo(video));
    }

    // ⛔ 带查询的列表**不抽样**：那份 items 是分页池的种子，顺序必须是列表的
    // 自然顺序（见 [query]）。翻不完的问题交给池自己翻，不再靠"随机留 100 条"
    // 凑一份看着够用的清单。
    final limitedItems = query != null
        ? items
        : _limitItems(
            items,
            currentVideoId: currentVideoId,
            maxItems: effectiveMaxItems,
          );

    return InnerPlaylistContext(
      source: source,
      items: List<InnerPlaylistItemSnapshot>.unmodifiable(limitedItems),
      currentVideoId: currentVideoId,
      query: query,
    );
  }

  InnerPlaylistContext copyWith({
    InnerPlaylistSource? source,
    List<InnerPlaylistItemSnapshot>? items,
    String? currentVideoId,
    MediaListQuery? query,
  }) {
    return InnerPlaylistContext(
      source: source ?? this.source,
      items: items ?? this.items,
      currentVideoId: currentVideoId ?? this.currentVideoId,
      query: query ?? this.query,
    );
  }

  InnerPlaylistContext copyWithVideoLikeState({
    required String videoId,
    required bool liked,
    required int numLikes,
  }) {
    final normalizedVideoId = videoId.trim();
    if (normalizedVideoId.isEmpty) {
      return this;
    }

    var changed = false;
    final patchedItems = items.map((item) {
      if (item.id.trim() != normalizedVideoId) {
        return item;
      }
      changed = true;
      return item.copyWith(liked: liked, numLikes: numLikes);
    }).toList(growable: false);

    if (!changed) {
      return this;
    }

    return copyWith(
      items: List<InnerPlaylistItemSnapshot>.unmodifiable(patchedItems),
    );
  }

  /// Returns a new context for continuing playback from [selectedVideoId].
  ///
  /// The current video and the selected video are both treated as already
  /// consumed in the detail-page handoff chain, so they are moved to the tail
  /// in consumption order. This keeps untouched items closer to the front of
  /// the next "up next" drawer without mutating the original context.
  InnerPlaylistContext copyForSelection(String selectedVideoId) {
    final normalizedSelectedId = selectedVideoId.trim();
    if (normalizedSelectedId.isEmpty) {
      return this;
    }

    final consumedIds = <String>{};

    void markConsumed(String id) {
      final normalizedId = id.trim();
      if (normalizedId.isEmpty) {
        return;
      }
      consumedIds.add(normalizedId);
    }

    markConsumed(currentVideoId);
    markConsumed(normalizedSelectedId);

    final reordered = <InnerPlaylistItemSnapshot>[];
    for (final item in items) {
      final id = item.id.trim();
      if (id.isEmpty || consumedIds.contains(id)) {
        continue;
      }
      reordered.add(item);
    }

    for (final consumedId in consumedIds) {
      for (final item in items) {
        if (item.id.trim() == consumedId) {
          reordered.add(item);
          break;
        }
      }
    }

    return InnerPlaylistContext(
      source: source,
      items: List<InnerPlaylistItemSnapshot>.unmodifiable(reordered),
      currentVideoId: normalizedSelectedId,
      query: query,
    );
  }

  List<InnerPlaylistItemSnapshot> itemsStartingAfterCurrent() {
    if (items.isEmpty) {
      return const <InnerPlaylistItemSnapshot>[];
    }

    final seen = <String>{};
    final ordered = <InnerPlaylistItemSnapshot>[];
    final currentIndex = items.indexWhere((item) => item.id == currentVideoId);

    void addItem(InnerPlaylistItemSnapshot item) {
      final id = item.id.trim();
      if (id.isEmpty || id == currentVideoId || !seen.add(id)) {
        return;
      }
      ordered.add(item);
    }

    if (currentIndex >= 0) {
      for (var i = currentIndex + 1; i < items.length; i++) {
        addItem(items[i]);
      }
      for (var i = 0; i < currentIndex; i++) {
        addItem(items[i]);
      }
    } else {
      for (final item in items) {
        addItem(item);
      }
    }

    return List<InnerPlaylistItemSnapshot>.unmodifiable(ordered);
  }

  static List<InnerPlaylistItemSnapshot> _limitItems(
    List<InnerPlaylistItemSnapshot> items, {
    required String currentVideoId,
    required int maxItems,
  }) {
    if (maxItems <= 0 || items.length <= maxItems) {
      return items;
    }

    // ⛔ 超限时**优先丢掉站外视频**是有意的，不是笔误：来源池的用途是"接着看"，
    // 而站外视频（youtube 一类的 embed）内置播放器根本放不了，留在池里只会让
    // 自动推进撞上去然后断链。名额有限时当然先给能播的。
    //
    // 注意这只影响**来源池**——它本来就是一次随机抽样（下面那行 shuffle 也是
    // 有意的）。播放列表池不走这里：那是作者排好的顺序，既不截断也不打乱。
    final candidates = items
        .where((item) => !item.isExternalVideo)
        .toList(growable: true);

    if (candidates.length <= maxItems) {
      return candidates;
    }

    final random = Random();
    final currentIndex = candidates.indexWhere(
      (item) => item.id == currentVideoId,
    );
    InnerPlaylistItemSnapshot? currentItem;

    if (currentIndex >= 0) {
      currentItem = candidates.removeAt(currentIndex);
    }

    candidates.shuffle(random);

    if (currentItem != null) {
      final selected = <InnerPlaylistItemSnapshot>[currentItem];
      selected.addAll(candidates.take(maxItems - 1));
      return selected;
    }

    return candidates.take(maxItems).toList(growable: false);
  }
}
