import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/vr_format_override_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/utils/iwara_different_site_recovery.dart';
import 'package:i_iwara/app/utils/vr_format_detector.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 沉浸空间「播放列表」页要的两件事：**列出接着看**、**把某一条变成可播的地址**。
///
/// # ⛔ 为什么不走既有的 `PlaybackQueueNavigator`
///
/// 那条路是「导航到视频详情页，让页面自己起播」。在沉浸态里它走不通：
/// 看视频时 Flutter 面板被显式暂停出帧（`ImmersiveBridge.setPanelRenderingPaused`），
/// 而 `pushReplacement` 要建 widget、要出帧 —— 页面根本不会被构建出来。
///
/// 所以沉浸态换片是**自足**的：Dart 只做「id → 地址 + 格式」的解析，
/// 解析完直接把结果交给原生场景。这与设计文档 §6.6 的既有决定一致：
/// 「沉浸端持续回打 Dart 的瘦客户端架构 —— 明确不采用……改为队列一次性传入 +
/// 原生自足」。
///
/// # ⚠️ 已知欠账（别当已解决）
///
/// 这条路**不经过 `MyVideoStateController`**，所以它不写观看历史、不更新稍后再看的
/// 进度、也不触发「已看完」判定。沉浸态里换过的片子，回到应用里看进度是旧的。
/// 要补，正确的位置是退出沉浸时的一次性回写（设计文档 §6.6-4「退出（含换过视频后的
/// 对齐）纪律」），那是另一条线。
class XrPlaylistSource {
  const XrPlaylistSource._();

  static const String _tag = 'XrPlaylistSource';

  /// 「接着看」在沉浸面板里要显示的那一串。
  ///
  /// - 只要**视频**：图库在沉浸空间里没有承载形式。
  /// - ⛔ 不排除站外视频，而是把它们标成 `playable = false` 留在列表里 ——
  ///   用户在应用里加过它们，列表里凭空少几条比「点不动」更让人困惑。
  ///   （`PlaybackQueue` 那边选择直接排除，因为自动连播撞上站外会断链；
  ///   这里是手动选片，不存在断链问题。）
  static List<XrPlaylistEntry> watchLaterEntries({int limit = 200}) {
    if (!Get.isRegistered<WatchLaterService>()) return const <XrPlaylistEntry>[];
    final items = WatchLaterService.to.query(
      itemType: WatchLaterItemType.video,
      excludeInvalid: true,
      limit: limit,
    );
    return items.map(XrPlaylistEntry.fromWatchLater).toList(growable: false);
  }

  /// 兜底：没有详情页在场时，「接着看」就是稍后再看这一个分区。
  ///
  /// 分区 id 是自定的哨兵，原生侧点选时 Dart 认不出这个池，会走「直接解析地址」那条路。
  static List<XrPlaylistSection> fallbackSections() => [
    XrPlaylistSection(
      queueId: fallbackQueueId,
      title: slang.t.watchLater.title,
      hasMore: false,
      items: watchLaterEntries(),
    ),
  ];

  static const String fallbackQueueId = 'xr:watchLater';

  /// 详情页交来的视频池 → 沉浸面板的分区。图库池不进（沉浸空间没有承载形式）。
  ///
  /// [downloadedIds] 是已下载完成的视频 id，用来给卡片打「已下载」角标。
  static List<XrPlaylistSection> sectionsFromQueues(
    List<PlaybackQueue> queues, {
    Set<String> downloadedIds = const <String>{},
  }) {
    return queues
        .where((q) => !q.mediaType.isGallery)
        .map(
          (q) => XrPlaylistSection(
            queueId: q.queueId,
            title: _queueTitle(q),
            hasMore: q.hasMore,
            // 刚开的池在 adopt 那一刻就会被推一次（第一页还没到）：也算 loading，面板画转圈不画空态。
            loading: q.isLoading || (q.loaded.isEmpty && q.hasMore),
            items: q.loaded
                .map(
                  (item) => XrPlaylistEntry.fromSnapshot(
                    item,
                    downloaded:
                        item.localQuality != null ||
                        downloadedIds.contains(item.id),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  /// 分区标题：与详情页抽屉里的池名同一套文案。
  static String _queueTitle(PlaybackQueue queue) {
    final t = slang.t;
    final custom = queue.title?.trim();
    return switch (queue.kind) {
      PlaybackQueueKind.source => t.playbackQueue.sourceTab,
      PlaybackQueueKind.subscriptions => t.common.subscriptions,
      PlaybackQueueKind.playlist =>
        custom == null || custom.isEmpty ? t.common.playList : custom,
      PlaybackQueueKind.authorVideos => t.playbackQueue.authorVideos,
      PlaybackQueueKind.authorGalleries => t.playbackQueue.authorGalleries,
      PlaybackQueueKind.favorites => t.common.favorites,
      PlaybackQueueKind.localFavorite =>
        custom == null || custom.isEmpty ? t.favorite.localizeFavorite : custom,
      PlaybackQueueKind.downloads =>
        custom == null || custom.isEmpty
            ? t.playbackQueue.downloads
            : '${t.playbackQueue.downloads} · $custom',
      PlaybackQueueKind.watchLater => t.watchLater.title,
    };
  }

  /// 把一条视频解析成沉浸场景能直接吃的东西。解析不出来返回 null。
  static Future<XrPlayableVideo?> resolve(String videoId) async {
    if (videoId.isEmpty) return null;
    try {
      final videoService = Get.find<VideoService>();
      var detail = await videoService.fetchVideoInfoResult(videoId);
      // 跨站（主站模式点到 AI 站的片，或反之）：服务端回 errors.differentSite 并告知它属于哪个站。
      // 这条路不切全局站点（没有详情页可重开），把这一次请求钉到那个站上再要一遍。
      IwaraSite? site;
      if (!detail.isSuccess) {
        site = IwaraDifferentSiteRecovery.resolveTargetSite(detail.exception);
        if (site != null) {
          LogUtils.i('沉浸态换片：$videoId 属于 ${site.name} 站，按该站重拉', _tag);
          detail = await videoService.fetchVideoInfoResult(videoId, site: site);
        }
      }
      final video = detail.data;
      if (!detail.isSuccess || video == null) {
        LogUtils.w('沉浸态换片：拉不到详情 videoId=$videoId', _tag);
        return null;
      }
      // 站外视频（youtube 一类的嵌入）没有我们能播的直链。
      if (video.isExternalVideo) return null;

      // ⛔ 详情接口给的是 `fileUrl` **不是源清单**（`Video.fromJson` 里 videoSources
      // 恒为 null），所以拉完详情还得照着 fileUrl 再要一次源。少这一步必定拿不到地址
      // ——与下载模块踩过的是同一个坑，见 media_download_launcher 的注释。
      final fileUrl = video.fileUrl;
      if (fileUrl == null || fileUrl.isEmpty) return null;
      final sources = await videoService.getVideoSourcesBy(fileUrl, site: site);
      if (sources.isEmpty) return null;

      final resolutions = CommonUtils.convertVideoSourcesToResolutions(sources);
      if (resolutions.isEmpty) return null;
      final preferred = Get.isRegistered<ConfigService>()
          ? Get.find<ConfigService>()[ConfigKey.DEFAULT_QUALITY_KEY] as String?
          : null;
      final url = CommonUtils.findUrlByResolutionTag(resolutions, preferred);
      if (url == null || url.isEmpty) return null;

      return XrPlayableVideo(
        id: video.id,
        title: video.title?.trim() ?? '',
        url: url,
        format: await _formatOf(video.id, video),
        width: video.file?.width ?? 0,
        height: video.file?.height ?? 0,
      );
    } catch (e) {
      LogUtils.e('沉浸态换片解析失败 videoId=$videoId', tag: _tag, error: e);
      return null;
    }
  }

  /// 片源格式：**用户覆盖优先**，没有才用推断。
  ///
  /// ⛔ 这个优先级不是可选的（设计文档约束 C6）：Iwara 不给格式元数据、文件里也不带
  /// 球面标记，自动推断**必然有错**，用户在播放器里选过的那一档才是权威。
  static Future<VrSourceFormat> _formatOf(String id, Video video) async {
    if (Get.isRegistered<VrFormatOverrideService>()) {
      final stored = await Get.find<VrFormatOverrideService>().get(id);
      if (stored != null) return stored;
    }
    final suspicion = VrFormatDetector.suspectFromMetadata(
      title: video.title,
      body: video.body,
      tags: video.tags?.map((t) => t.id).toList(),
      width: video.file?.width,
      height: video.file?.height,
    );
    final verdict = VrFormatDetector.decideWithDimensions(suspicion);
    return verdict?.format ?? VrSourceFormat.flatMono;
  }
}

/// 沉浸面板列表里的一行。字段与 Kotlin 侧的 `PlaylistEntry` 一一对应。
class XrPlaylistEntry {
  const XrPlaylistEntry({
    required this.id,
    required this.title,
    required this.author,
    required this.durationText,
    required this.thumbnailUrl,
    required this.progressRatio,
    required this.watched,
    required this.playable,
    this.downloaded = false,
  });

  final String id;
  final String title;
  final String author;
  final String durationText;
  final String thumbnailUrl;
  final double progressRatio;
  final bool watched;
  final bool playable;

  /// 本机有下载完成的文件（面板打「已下载」角标；沉浸态选中它会用本地文件播）。
  final bool downloaded;

  factory XrPlaylistEntry.fromWatchLater(WatchLaterItem item) =>
      XrPlaylistEntry(
        id: item.itemId,
        title: item.title,
        author: item.author ?? '',
        durationText: _formatDuration(item.durationMs),
        thumbnailUrl: item.thumbnailUrl ?? '',
        progressRatio: item.progressRatio,
        watched: item.isWatched,
        playable: !item.isExternal,
      );

  /// 视频池里的一条快照。「看完」按进度 ≥ 95% 判，与稍后再看的口径一致。
  factory XrPlaylistEntry.fromSnapshot(
    InnerPlaylistItemSnapshot item, {
    bool downloaded = false,
  }) {
    final progress = (item.progressPermil / 1000).clamp(0.0, 1.0).toDouble();
    return XrPlaylistEntry(
      id: item.id,
      title: item.title,
      author: item.authorName ?? '',
      durationText: _formatDuration(
        item.durationSeconds == null ? null : item.durationSeconds! * 1000,
      ),
      thumbnailUrl: item.thumbnailUrl,
      progressRatio: progress,
      watched: progress >= 0.95,
      playable: !item.isExternalVideo,
      downloaded: downloaded,
    );
  }

  Map<String, dynamic> toChannelMap() => {
    'id': id,
    'title': title,
    'author': author,
    'durationText': durationText,
    'thumbnailUrl': thumbnailUrl,
    'progress': progressRatio,
    'watched': watched,
    'playable': playable,
    'downloaded': downloaded,
  };

  static String _formatDuration(int? ms) {
    if (ms == null || ms <= 0) return '--:--';
    final total = ms ~/ 1000;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
  }
}

/// 一条解析完成、可以直接交给沉浸场景的视频。
class XrPlayableVideo {
  const XrPlayableVideo({
    required this.id,
    required this.title,
    required this.url,
    required this.format,
    required this.width,
    required this.height,
  });

  final String id;
  final String title;
  final String url;
  final VrSourceFormat format;
  final int width;
  final int height;
}

/// 沉浸面板「接着看」的一个分区 = 详情页的一个视频池。
class XrPlaylistSection {
  const XrPlaylistSection({
    required this.queueId,
    required this.title,
    required this.hasMore,
    required this.items,
    this.loading = false,
  });

  final String queueId;
  final String title;
  final bool hasMore;
  final List<XrPlaylistEntry> items;

  /// 池正在拉第一页 / 翻页，或还没装过任何一页。面板据此在空列表上画转圈。
  final bool loading;

  Map<String, dynamic> toChannelMap() => {
    'queueId': queueId,
    'title': title,
    'hasMore': hasMore,
    'loading': loading,
    'items': items.map((e) => e.toChannelMap()).toList(),
  };
}
