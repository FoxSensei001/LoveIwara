import 'dart:io';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/local_media/local_vr_hints.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/utils/local_vr_filename_detector.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/services/webdav/webdav_service.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
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
import 'package:i_iwara/app/services/x_version_salt_service.dart';
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

  /// 兜底：没有详情页在场时，「接着看」就是稍后再看这一个分区。
  ///
  /// 分区 id 是自定的哨兵，原生侧点选时 Dart 认不出这个池，会走「直接解析地址」那条路。
  ///
  /// ⛔ 不排除站外视频，而是标成 `playable = false` 留在列表里——用户在应用里加过它们，
  /// 列表里凭空少几条比「点不动」更让人困惑。
  static XrPlaylistSection fallbackSection({int limit = 200}) {
    final items = Get.isRegistered<WatchLaterService>()
        ? WatchLaterService.to.query(
            itemType: WatchLaterItemType.video,
            excludeInvalid: true,
            limit: limit,
          )
        : const <WatchLaterItem>[];
    return XrPlaylistSection(
      queueId: fallbackQueueId,
      title: slang.t.watchLater.title,
      icon: 'watchLater',
      hasMore: false,
      items: items.map(XrPlaylistEntry.fromWatchLater).toList(growable: false),
    );
  }

  static const String fallbackQueueId = 'xr:watchLater';

  /// 一个池 → 沉浸面板的一个分区。
  static XrPlaylistSection sectionFromQueue(PlaybackQueue queue) {
    return XrPlaylistSection(
      queueId: queue.queueId,
      title: queueLabel(queue),
      icon: queueIcon(queue.kind),
      hasMore: queue.hasMore,
      // ⛔ 只报真的在加载。「一条都没有、不在加载、还有下一页」= 上一次请求失败了，
      // 面板据此画「加载失败，点击重试」（同 2D 抽屉 `_buildList`）。原来这里把
      // `loaded.isEmpty && hasMore` 也算成 loading，失败的池会永远转圈。
      loading: queue.isLoading,
      skipWatched: queue is WatchLaterPlaybackQueue && queue.unwatchedOnly,
      mediaType: queue.mediaType.isGallery ? 'gallery' : 'video',
      items: queue.loaded
          .map(XrPlaylistEntry.fromSnapshot)
          .toList(growable: false),
    );
  }

  /// 池名：**逐字等于 2D 抽屉胶囊上那行字**（`_pillLabel`，不含截断——面板自己省略）。
  static String queueLabel(PlaybackQueue queue) {
    final t = slang.t;
    String titled(String fallback) {
      final custom = queue.title?.trim();
      return custom == null || custom.isEmpty ? fallback : custom;
    }

    String suffixed(String base) {
      final custom = queue.title?.trim();
      return custom == null || custom.isEmpty ? base : '$base · $custom';
    }

    return switch (queue.kind) {
      PlaybackQueueKind.source => t.playbackQueue.sourceTab,
      PlaybackQueueKind.subscriptions => t.common.subscriptions,
      PlaybackQueueKind.playlist => titled(t.common.playList),
      PlaybackQueueKind.authorVideos => titled(t.playbackQueue.authorVideos),
      PlaybackQueueKind.authorGalleries => titled(
        t.playbackQueue.authorGalleries,
      ),
      PlaybackQueueKind.favorites => t.common.favorites,
      PlaybackQueueKind.localFavorite => titled(t.favorite.localizeFavorite),
      PlaybackQueueKind.downloads => suffixed(t.playbackQueue.downloads),
      PlaybackQueueKind.localLibrary => suffixed(t.playbackQueue.localFiles),
      PlaybackQueueKind.watchLater =>
        queue is WatchLaterPlaybackQueue && queue.unwatchedOnly
            ? '${t.watchLater.title} · ${t.watchLater.filterUnwatched}'
            : t.watchLater.title,
      PlaybackQueueKind.history => titled(t.common.history),
    };
  }

  /// 池的图标键（= 2D 抽屉 `_pillIcon`），面板侧映射成 UI Set 图标。
  static String queueIcon(PlaybackQueueKind kind) => switch (kind) {
    PlaybackQueueKind.source => 'source',
    PlaybackQueueKind.subscriptions => 'subscriptions',
    PlaybackQueueKind.playlist => 'playlist',
    PlaybackQueueKind.authorVideos => 'videos',
    PlaybackQueueKind.authorGalleries => 'gallery',
    PlaybackQueueKind.favorites => 'favorite',
    PlaybackQueueKind.localFavorite => 'folder',
    PlaybackQueueKind.downloads => 'download',
    PlaybackQueueKind.localLibrary => 'devices',
    PlaybackQueueKind.watchLater => 'watchLater',
    // 图标复用 watchLater：Quest 端图标表里还没有 history 语义的那颗（手机端
    // 抽屉用的是 Icons.history）。图标表扩充后两处一起换，见 xr_queue_catalog。
    PlaybackQueueKind.history => 'watchLater',
  };

  /// 把一条视频解析成沉浸场景能直接吃的东西。解析不出来返回 null。
  static Future<XrPlayableVideo?> resolve(String videoId) async {
    if (videoId.isEmpty) return null;

    // ⛔ 本机文件先问一句，不能直接往下走 Iwara 那条路：本机文件池里的 id 是
    // `local_media_items.id`，服务端根本不认识它——硬拉一遍详情只会得到一个
    // 404，而面板上的表现是「点了这一条什么都没发生」。
    final local = await _resolveLocalLibrary(videoId);
    if (local != null) return local;

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
      // 这是播放：盐值失效时宁可先放 360，也别让这条整个放不出来
      final sources = await videoService.getVideoSourcesBy(
        fileUrl,
        site: site,
        keepFirstOnRetryFailure: true,
        checkSiteTimeout: XVersionSaltService.playbackCheckSiteTimeout,
      );
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
        videoId: video.id,
        title: video.title?.trim() ?? '',
        author: video.user?.name ?? '',
        url: url,
        sources: [for (final r in resolutions) (label: r.label, url: r.url)],
        sourceLabel: resolutions.firstWhere((r) => r.url == url).label,
        format: await _formatOf(video.id, video),
        width: video.file?.width ?? 0,
        height: video.file?.height ?? 0,
        // 续播与退出时回写成对（`_saveHistory`）：不续播的话，看过半小时的片子从 0 起，
        // 5 秒内退出还会把原记录删掉（`recordPosition` 的开头几秒当没看）。
        positionMs: (await _localResumePosition(null, video.id)).inMilliseconds,
      );
    } catch (e) {
      LogUtils.e('沉浸态换片解析失败 videoId=$videoId', tag: _tag, error: e);
      return null;
    }
  }

  /// 本机文件那一条：库里查得到就直接给磁盘地址，查不到返回 null 让调用方走
  /// Iwara 那条路（在线 id 长得完全不一样，不会误命中）。
  static Future<XrPlayableVideo?> _resolveLocalLibrary(String itemId) async {
    final LocalMediaItem? item;
    try {
      item = LocalMediaRepository().getItem(itemId);
    } catch (e) {
      LogUtils.w('沉浸态换片：读本机条目失败 $itemId: $e', _tag);
      return null;
    }
    if (item == null) return null;
    return resolveLocalTarget(
      LocalPlaybackTarget(
        localPath: item.resolvePlaybackTarget(),
        localLibraryItemId: itemId,
      ),
    );
  }

  /// 把「这一条用本地文件播」（本机文件墙 / 目录页 / 下载列表 / 两个本地池）解析成
  /// 能直接交给沉浸场景的请求。解析不出来（文件没了、不是视频、没有任何身份）返回 null。
  ///
  /// Quest 上从列表点视频**不进本地播放页**（用户 2026-11-05），所以本地播放页在交给
  /// 空间之前替用户做的几件事都收在这里，口径逐条照 `MyVideoStateController`：
  ///
  /// - **身份**：本机库条目 id 优先（进度记在 `local_media_progress`），其次在线 id
  ///   （下载任务带的，与 `MyVideoStateController.immersiveMediaId` 同一口径）。两样都没有就不接——匿名文件没有
  ///   进度可续、没有池可认，让调用方照旧开页面。
  /// - **清晰度**：下载任务把同一视频已完成、文件还在的各档都列上（同本地播放页
  ///   `_buildLocalVideoResolutions`），按偏好挑哪一档由 `XrImmersiveService` 做。
  /// - **续播**：本机库条目读 `local_media_progress`（看完的从头、回退 4 秒）；只有下载任务
  ///   的读在线观看历史——退出空间时服务正是把进度写回这两处。
  /// - **视频类型**：用户覆盖由 `XrImmersiveService.present` 按钥匙读，这里只给推断：
  ///   派生阶段存下的 VR 线索 > 标题推断，宽高取库里派生出的那份。头显里没有「不选」，
  ///   推断不出来才是平面（理由见 `MyVideoStateController.vrFormatForImmersive`）。
  static Future<XrPlayableVideo?> resolveLocalTarget(
    LocalPlaybackTarget target,
  ) async {
    try {
      final libraryId = target.localLibraryItemId?.trim();
      final itemId = libraryId != null && libraryId.isNotEmpty
          ? libraryId
          : null;
      final repo = LocalMediaRepository();
      final item = itemId == null ? null : repo.getItem(itemId);
      // ⛔ 图片不是能播的东西。本机文件池现在也装得下图片（图库那侧，见
      // `LocalLibraryPlaybackQueue.itemKind`），而沉浸态在"池找不到 / 池被 LRU
      // 淘汰"时会退回按 id 解析的兜底路——不拦的话，一张 jpg 的路径会被当
      // 视频交给原生播放器。这道闸钉在解析入口上而不是靠调用方自觉。
      if (item != null && item.kind != LocalMediaItemKind.video) {
        LogUtils.w('沉浸态：$itemId 不是视频（${item.kind.name}），不解析', _tag);
        return null;
      }

      final task = target.task;
      final ext = _videoExtOf(task);
      final onlineId = ext?.id?.trim();
      final videoId = onlineId != null && onlineId.isNotEmpty ? onlineId : null;
      final mediaId = itemId ?? videoId;
      if (mediaId == null) return null;

      final path = target.localPath.trim();
      final isContentUri = path.startsWith('content://');
      // NAS 条目：原生播放器只连本机网关，地址此刻现算（端口/token 进程级）。
      String? remoteUrl;
      if (DavPath.isDav(path)) {
        if (itemId == null) return null;
        try {
          remoteUrl = await WebDavService.instance.gatewayUrlForItem(itemId);
        } catch (e) {
          LogUtils.w('沉浸态：NAS 条目 $itemId 取不到网关地址: $e', _tag);
          return null;
        }
      }
      if (path.isEmpty ||
          (remoteUrl == null && !isContentUri && !await File(path).exists())) {
        LogUtils.w('沉浸态：本地文件 $mediaId 在磁盘上已不存在', _tag);
        return null;
      }
      final url =
          remoteUrl ?? (isContentUri ? path : Uri.file(path).toString());

      final clickedLabel = ext?.quality?.trim().isNotEmpty == true
          ? ext!.quality!.trim()
          : slang.t.mediaPlayer.local;
      final byLabel = <String, ({String label, String url})>{};
      for (final other in target.allQualityTasks) {
        if (other.status != DownloadStatus.completed) continue;
        final quality = _videoExtOf(other)?.quality?.trim();
        if (quality == null || quality.isEmpty) continue;
        final otherPath = other.savePath;
        if (otherPath.isEmpty || !await File(otherPath).exists()) continue;
        byLabel[quality] = (label: quality, url: Uri.file(otherPath).toString());
      }
      // 点的那一档必在：清单查不到它（任务表与磁盘对不上）也照样能播。
      byLabel[clickedLabel] = (label: clickedLabel, url: url);
      // 从高到低排（[pickPreferredSource] 的「向下降级」按位置找）；同档保持插入顺序。
      final sorted = byLabel.values.indexed.toList()
        ..sort((a, b) {
          final byRank = CommonUtils.qualityRank(
            a.$2.label,
          ).compareTo(CommonUtils.qualityRank(b.$2.label));
          return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
        });

      final title = ext?.title?.trim().isNotEmpty == true
          ? ext!.title!.trim()
          : item?.name ??
                (task != null && task.fileName.isNotEmpty
                    ? task.fileName
                    : (DavPath.isDav(path)
                          ? DavPath.basename(path)
                          : p.basename(path)));

      return XrPlayableVideo(
        id: mediaId,
        videoId: videoId,
        title: title,
        // 只有下载任务记着作者；本机文件没有作者——别编一个。
        author: ext?.authorName?.trim() ?? '',
        url: url,
        sources: [for (final e in sorted) e.$2],
        sourceLabel: clickedLabel,
        localSources: remoteUrl == null,
        localLibraryItemId: itemId,
        localPath: path,
        localTask: task,
        localAllQualityTasks: target.allQualityTasks,
        format: _inferLocalFormat(item, title),
        width: item?.width ?? 0,
        height: item?.height ?? 0,
        positionMs: (await _localResumePosition(itemId, videoId)).inMilliseconds,
      );
    } catch (e) {
      LogUtils.w('沉浸态：解析本地文件失败: $e', _tag);
      return null;
    }
  }

  static VideoDownloadExtData? _videoExtOf(DownloadTask? task) {
    final ext = task?.extData;
    if (ext == null || ext.type != DownloadTaskExtDataType.video) return null;
    try {
      return VideoDownloadExtData.fromJson(ext.data);
    } catch (_) {
      return null;
    }
  }

  /// 本地片源的推断格式（不含用户覆盖，那一层在 `XrImmersiveService.present`）。
  ///
  /// 口径照本地播放页：库里有派生阶段的 VR 线索就只用线索（`_seedVrSuspicionFromLocalLibrary`
  /// 之后不再按标题重算），没有才按标题推断；宽高都取库里那份。
  static VrSourceFormat _inferLocalFormat(LocalMediaItem? item, String title) {
    final hints = LocalVrHints.fromJson(item?.vrFormatJson);
    final suspicion = hints != null && hints.strength != LocalVrSignalStrength.none
        ? VrSuspicion(
            suspected: true,
            negated: false,
            projectionHint: hints.projection,
            stereoHint: hints.stereo,
            width: item?.width,
            height: item?.height,
          )
        : VrFormatDetector.suspectFromMetadata(
            title: title,
            width: item?.width,
            height: item?.height,
          );
    return VrFormatDetector.decideWithDimensions(suspicion)?.format ??
        VrSourceFormat.flatMono;
  }

  /// 续播起点，与退出空间时的回写成对：本机库条目读 `local_media_progress`，
  /// 只有在线 id（下载任务）的读观看历史。关了「记录并恢复播放进度」就从头。
  static Future<Duration> _localResumePosition(
    String? itemId,
    String? videoId,
  ) async {
    if (!Get.isRegistered<ConfigService>() ||
        Get.find<ConfigService>()[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS] !=
            true) {
      return Duration.zero;
    }
    try {
      if (itemId != null) {
        final row = LocalMediaRepository().getProgress(itemId);
        if (row == null || row.completed) return Duration.zero;
        final total = row.durationMs;
        final target = row.positionMs - 4000;
        if (target <= 0) return Duration.zero;
        return Duration(
          milliseconds: total != null && total > 0
              ? target.clamp(0, total)
              : target,
        );
      }
      if (videoId != null && Get.isRegistered<PlaybackHistoryService>()) {
        return await PlaybackHistoryService.to.resumePosition(videoId);
      }
    } catch (e) {
      LogUtils.w('沉浸态：读续播位置失败: $e', _tag);
    }
    return Duration.zero;
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

/// 沉浸面板列表里的一张卡。字段与 Kotlin 侧的 `PlaylistEntry` 一一对应。
///
/// ⛔ 显示什么**逐项照 2D 抽屉的 `_QueueRow`**：封面左下「时长 / 张数 / 站外视频」、
/// 右下播放量、左上本地清晰度（只有已下载池有）、底沿进度条（有进度才画）；文字区
/// 标题两行 + 「作者 · 🔒 · ♥ 点赞 · 时间」一行。**有才画**：统计是 null 就整段不占
/// 地方，而不是显示 0。文案全在 Dart 这边按应用语言格式化好，面板只管摆。
///
/// 原先空间版多出来的「已看完」「已下载」角标与压暗、少掉的播放量 / 点赞 / 时间，
/// 都是两边各长各的结果（2026-09-14 按 2D 收口）。
class XrPlaylistEntry {
  const XrPlaylistEntry({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.leadKind,
    required this.leadText,
    required this.viewsText,
    required this.likesText,
    required this.timeText,
    required this.isPrivate,
    required this.qualityText,
    required this.progressRatio,
    required this.watched,
    required this.playable,
  });

  final String id;
  final String title;

  /// 作者显示名；没有显示名时是 `@username`；都没有是空串。
  final String author;
  final String thumbnailUrl;

  /// 封面左下那一枚是什么：`external` / `images` / `duration`；空串 = 不画。
  final String leadKind;
  final String leadText;
  final String viewsText;
  final String likesText;
  final String timeText;
  final bool isPrivate;

  /// 本地存的清晰度显示名（只有已下载池有）。
  final String qualityText;
  final double progressRatio;

  /// 看完了（进度 ≥ 95%）：不画角标，只给「跳过已看完」的续播用。
  final bool watched;

  /// 站外视频在沉浸空间里放不了：卡片照常列出、点不动。
  final bool playable;

  factory XrPlaylistEntry.fromWatchLater(WatchLaterItem item) {
    final t = slang.t;
    final durationMs = item.durationMs;
    final (lead, leadText) = item.isExternal
        ? ('external', t.common.externalVideo)
        : durationMs == null || durationMs <= 0
        ? ('', '')
        : (
            'duration',
            CommonUtils.formatDuration(Duration(milliseconds: durationMs)),
          );
    final author = item.author?.trim().isNotEmpty == true
        ? item.author!.trim()
        : (item.authorUsername?.trim().isNotEmpty == true
              ? '@${item.authorUsername!.trim()}'
              : '');
    return XrPlaylistEntry(
      id: item.itemId,
      title: item.title,
      author: author,
      thumbnailUrl: item.thumbnailUrl ?? '',
      leadKind: lead,
      leadText: leadText,
      viewsText: '',
      likesText: '',
      timeText: '',
      isPrivate: false,
      qualityText: '',
      progressRatio: item.progressPermil > 0 ? item.progressRatio : 0,
      watched: item.isWatched,
      playable: !item.isExternal,
    );
  }

  /// 池里的一条快照。
  factory XrPlaylistEntry.fromSnapshot(InnerPlaylistItemSnapshot item) {
    final t = slang.t;
    final String lead;
    final String leadText;
    if (item.isExternalVideo) {
      lead = 'external';
      leadText = t.common.externalVideo;
    } else if (item.numImages != null) {
      lead = 'images';
      leadText = '${item.numImages}';
    } else if (item.durationSeconds != null) {
      lead = 'duration';
      leadText = CommonUtils.formatDuration(
        Duration(seconds: item.durationSeconds!),
      );
    } else {
      lead = '';
      leadText = '';
    }
    final author = item.authorName?.trim().isNotEmpty == true
        ? item.authorName!.trim()
        : (item.authorUsername?.trim().isNotEmpty == true
              ? '@${item.authorUsername!.trim()}'
              : '');
    final quality = item.localQuality?.trim();
    final progress = (item.progressPermil / 1000).clamp(0.0, 1.0).toDouble();
    return XrPlaylistEntry(
      id: item.id,
      title: item.title,
      author: author,
      thumbnailUrl: item.thumbnailUrl,
      leadKind: lead,
      leadText: leadText,
      viewsText: item.numViews == null
          ? ''
          : CommonUtils.formatFriendlyNumber(item.numViews),
      likesText: item.numLikes == null
          ? ''
          : CommonUtils.formatFriendlyNumber(item.numLikes),
      timeText: CommonUtils.formatFriendlyTimestamp(
        item.createdAt,
        includeTime: false,
      ),
      isPrivate: item.isPrivate,
      qualityText: quality == null || quality.isEmpty
          ? ''
          : CommonUtils.getQualityDisplayLabel(t, quality),
      progressRatio: item.progressPermil > 0 ? progress : 0,
      watched: progress >= 0.95,
      playable: !item.isExternalVideo,
    );
  }

  Map<String, dynamic> toChannelMap() => {
    'id': id,
    'title': title,
    'author': author,
    'thumbnailUrl': thumbnailUrl,
    'leadKind': leadKind,
    'leadText': leadText,
    'viewsText': viewsText,
    'likesText': likesText,
    'timeText': timeText,
    'private': isPrivate,
    'qualityText': qualityText,
    'progress': progressRatio,
    'watched': watched,
    'playable': playable,
  };
}

/// 一条解析完成、可以直接交给沉浸场景的视频。
class XrPlayableVideo {
  const XrPlayableVideo({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.format,
    required this.width,
    required this.height,
    this.sources = const [],
    this.sourceLabel = '',
    this.localSources = false,
    this.videoId,
    this.localLibraryItemId,
    this.localPath,
    this.localTask,
    this.localAllQualityTasks = const [],
    this.positionMs = 0,
  });

  final String id;
  final String title;

  /// 作者名；面板标题下面那行小字。取不到就是空串。
  final String author;
  final String url;
  final VrSourceFormat format;
  final int width;
  final int height;
  final List<({String label, String url})> sources;
  final String sourceLabel;

  /// [sources] 全是本机文件（不会过期，刷新清单时要留着）。
  final bool localSources;

  /// 在线视频 id：退出空间时进度回写观看历史用。本机自己拷进来的文件为 null。
  final String? videoId;
  final String? localLibraryItemId;
  final String? localPath;

  /// 下载任务那一路的材料；退出空间后要回到本地播放页时原样带上。
  final DownloadTask? localTask;
  final List<DownloadTask> localAllQualityTasks;

  /// 续播起点。
  final int positionMs;
}

/// 沉浸面板「接着看」的一个分区 = 一个池。
///
/// 面板上真正画出来的只有**正在浏览的那一个**；播放器在用的那个（active）另外
/// 带着，给「上一个 / 下一个 / 播完接着放」和「正在播」标记用。
class XrPlaylistSection {
  const XrPlaylistSection({
    required this.queueId,
    required this.title,
    required this.icon,
    required this.hasMore,
    required this.items,
    this.loading = false,
    this.skipWatched = false,
    this.mediaType = 'video',
  });

  final String queueId;

  /// 池名（= 2D 胶囊上那行字）。
  final String title;

  /// 图标键，见 [XrPlaylistSource.queueIcon]。
  final String icon;
  final bool hasMore;
  final List<XrPlaylistEntry> items;

  /// 池正在拉一页。
  final bool loading;

  /// 顺着这个池往下放时跳过已看完的（稍后再看 · 未看完，同 2D 抽屉点播时的 skipWatched）。
  final bool skipWatched;

  /// `video` / `gallery`：面板空态文案按它二选一。
  final String mediaType;

  Map<String, dynamic> toChannelMap() => {
    'queueId': queueId,
    'title': title,
    'icon': icon,
    'hasMore': hasMore,
    'loading': loading,
    'skipWatched': skipWatched,
    'mediaType': mediaType,
    'items': items.map((e) => e.toChannelMap()).toList(),
  };
}
