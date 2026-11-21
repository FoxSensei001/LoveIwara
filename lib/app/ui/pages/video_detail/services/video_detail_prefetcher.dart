import 'dart:async';

import 'package:dio/dio.dart' as d_dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart' as video_model;
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/services/iwara_network_service.dart';
import 'package:i_iwara/app/services/x_version_salt_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/services/video_cache_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';

typedef VideoDetailFetcher = Future<video_model.Video> Function(String videoId);

/// 返回 null 表示「拿到了但不该进缓存」（签名失效的 360 清单、空清单）。
typedef VideoSourcesFetcher =
    Future<List<VideoSource>?> Function(String fileUrl);

/// 用户**还没点进去**时，先把视频详情页起播要的两跳拉回来放进
/// [VideoCacheManager]：详情接口（拿签过名的 `fileUrl`）→ 视频源接口。
///
/// 两跳必须串行（视频源要用详情里的 `fileUrl`），经代理合计约 2.3 s，是从列表
/// 点进去之后起播前等待的一半。触发点（鼠标悬停够久、长按 / 菜单预览）见
/// `MediaCardActionState`。
///
/// 规矩：
/// - **不报错、不弹窗**。失败只记 debug 日志并冷却一会儿；用户点进去时详情页
///   自己重新请求，错误页（私密、已删、跨站）照旧由它给。请求带
///   [IwaraNetworkService.backgroundRequestKey]，撞上 Cloudflare 也不弹验证页；
///   不做网络重试。token 要刷新时整个跳过（刷新走的 Dio 会弹验证页）。
/// - 刚预取回来的详情算**新鲜**（[consumeFresh]），详情页直接显示它的点赞态，
///   不再清空、不再补拉一次；卡片上点过赞就 [markStale] 作废。
/// - **进页面时预取还在路上就接着等它**（[pendingDetail] / [pendingSources]），
///   不另发一份——否则悬停 300ms 就点的人反而多发两次请求、一点没快。
/// - 同时最多 [maxConcurrent] 条在途，超出的直接不做：滚轮扫过一排卡片不该
///   排起一长串请求。
class VideoDetailPrefetcher {
  VideoDetailPrefetcher({
    VideoCacheManager? cache,
    VideoDetailFetcher? fetchDetail,
    VideoSourcesFetcher? fetchSources,
    bool Function()? canRunInBackground,
    DateTime Function()? now,
  }) : _cache = cache ?? VideoCacheManager(),
       _fetchDetail = fetchDetail ?? _defaultFetchDetail,
       _fetchSources = fetchSources ?? _defaultFetchSources,
       _canRunInBackground = canRunInBackground ?? _defaultCanRunInBackground,
       _now = now ?? DateTime.now;

  static final VideoDetailPrefetcher instance = VideoDetailPrefetcher();

  static const String _tag = 'VideoDetailPrefetcher';

  @visibleForTesting
  static const int maxConcurrent = 3;

  /// 失败（或拿到的详情不能播）之后多久内不再为同一条预取，免得来回悬停时
  /// 对着一条私密 / 已删的视频一直发。
  @visibleForTesting
  static const Duration failureCooldown = Duration(minutes: 1);

  /// 预取回来的详情在这么久之内算新鲜，详情页直接用它的点赞态。
  @visibleForTesting
  static const Duration freshFor = Duration(minutes: 1);

  final VideoCacheManager _cache;
  final VideoDetailFetcher _fetchDetail;
  final VideoSourcesFetcher _fetchSources;
  final bool Function() _canRunInBackground;
  final DateTime Function() _now;

  /// videoId → 详情那一跳的在途闸门。只会正常完成，不带错误。
  final Map<String, Future<void>> _detailInFlight = {};

  /// fileUrl → 视频源那一跳的在途闸门。只会正常完成，不带错误。
  final Map<String, Future<void>> _sourcesInFlight = {};

  final Map<String, DateTime> _cooldownUntil = {};

  /// videoId → 预取写进缓存的**那一份**详情，以及它新鲜到什么时候。
  ///
  /// 绑定对象而不只记 id：缓存条目之后可能被别的数据换掉（详情页 onInit 用
  /// `initialVideoInfo` 覆盖、点赞后改字段），换掉的那份不是这次取的，不能顶着
  /// 「新鲜」跳过补拉。
  final Map<String, ({video_model.Video video, DateTime until})> _fresh = {};

  /// 详情请求在路上时被 [markStale] 过的视频：回来的数据可能早于那次点赞，
  /// 照常进缓存，但不算新鲜。
  final Set<String> _staleWhileInFlight = {};

  int _activeChains = 0;

  /// [cached] 是不是刚预取回来的那一份（[freshFor] 之内、没被 [markStale]）。
  /// 一次性：问过就作废，下次进页面照常补拉点赞。
  bool consumeFresh(String videoId, video_model.Video cached) {
    final entry = _fresh.remove(videoId);
    return entry != null &&
        identical(entry.video, cached) &&
        _now().isBefore(entry.until);
  }

  /// 点赞态在别处变了（卡片 / 预览里点了赞），预取的那份不能再当新鲜数据用。
  ///
  /// ⛔ 详情请求还在路上时也要记下来：卡片上的点赞要等 POST 成功才回调到这里，
  /// 而预取的 GET 可能比它晚回来、带的却是点赞前的状态。只删 [_fresh] 的话，
  /// 那份旧数据回来后照样被标成新鲜，详情页显示没点赞、也不补拉（Opus 审查
  /// 2026-11-21）。
  void markStale(String videoId) {
    _fresh.remove(videoId);
    if (_detailInFlight.containsKey(videoId)) _staleWhileInFlight.add(videoId);
  }

  /// 这条视频的详情预取还在路上就返回它的闸门（完成后去查缓存），否则 null。
  Future<void>? pendingDetail(String videoId) => _detailInFlight[videoId];

  /// 这个 `fileUrl` 的视频源预取还在路上就返回它的闸门，否则 null。
  Future<void>? pendingSources(String fileUrl) => _sourcesInFlight[fileUrl];

  /// 发起预取。已在途、已在缓存、冷却中、在途已满时什么都不做。
  void prefetch(String videoId) {
    if (videoId.isEmpty || _detailInFlight.containsKey(videoId)) return;
    if (_isCoolingDown(videoId)) return;

    final cached = _cache.getVideoInfo(videoId);
    if (cached != null && _sourcesUrlToFetch(cached) == null) return;
    if (_activeChains >= maxConcurrent) return;
    if (!_canRunInBackground()) return;

    unawaited(_run(videoId, cached));
  }

  Future<void> _run(String videoId, video_model.Video? cached) async {
    _activeChains++;
    Completer<void>? detailGate;
    // 发请求时是哪个站点、哪个账号。请求回来时变了（中途切站 / 换号），这次的
    // 结果就不要了：缓存条目的身份标记是写入那一刻取的，写进去会被当成新身份的
    // 数据（Opus 审查 2026-11-21）。
    final contextAtStart = VideoCacheManager.currentContextKey();
    bool contextChanged() => VideoCacheManager.currentContextKey() != contextAtStart;
    try {
      var video = cached;
      if (video == null) {
        detailGate = Completer<void>();
        _detailInFlight[videoId] = detailGate.future;
        video = await _fetchDetail(videoId);
        if (contextChanged()) return;
        if (!_isPlayable(video)) {
          // 转码中 / 无可播文件：详情页拿到它也要重新请求，缓存了没用。
          _coolDown(videoId);
          return;
        }
        _cache.cacheVideoInfo(videoId, video);
        final now = _now();
        _fresh.removeWhere((_, entry) => !now.isBefore(entry.until));
        if (!_staleWhileInFlight.remove(videoId)) {
          _fresh[videoId] = (video: video, until: now.add(freshFor));
        }
      }

      final fileUrl = _sourcesUrlToFetch(video);
      if (fileUrl == null) return;

      // ⛔ 先登记视频源的在途，再放开等详情的人：详情页一拿到详情就会去查
      // [pendingSources]，晚一步登记它就会另发一份视频源请求。
      final sourcesGate = Completer<void>();
      _sourcesInFlight[fileUrl] = sourcesGate.future;
      _releaseDetail(videoId, detailGate);
      detailGate = null;
      try {
        final sources = await _fetchSources(fileUrl);
        if (sources != null && sources.isNotEmpty && !contextChanged()) {
          _cache.cacheVideoSources(fileUrl, sources);
        }
      } finally {
        if (identical(_sourcesInFlight[fileUrl], sourcesGate.future)) {
          _sourcesInFlight.remove(fileUrl);
        }
        sourcesGate.complete();
      }
      LogUtils.d('预取完成: $videoId', _tag);
    } catch (e) {
      _coolDown(videoId);
      LogUtils.d('预取失败（进详情页时会自己重新请求）: $videoId, $e', _tag);
    } finally {
      _staleWhileInFlight.remove(videoId);
      _releaseDetail(videoId, detailGate);
      _activeChains--;
    }
  }

  void _releaseDetail(String videoId, Completer<void>? gate) {
    if (gate == null) return;
    if (identical(_detailInFlight[videoId], gate.future)) {
      _detailInFlight.remove(videoId);
    }
    if (!gate.isCompleted) gate.complete();
  }

  /// 还需要预取视频源就返回它的 `fileUrl`；站外视频、已缓存、已在途返回 null。
  String? _sourcesUrlToFetch(video_model.Video video) {
    final fileUrl = video.fileUrl;
    if (fileUrl == null || video.isExternalVideo) return null;
    if (_sourcesInFlight.containsKey(fileUrl)) return null;
    if (_cache.getVideoSources(fileUrl) != null) return null;
    return fileUrl;
  }

  static bool _isPlayable(video_model.Video video) =>
      video.fileUrl != null || video.isExternalVideo;

  bool _isCoolingDown(String videoId) {
    final until = _cooldownUntil[videoId];
    if (until == null) return false;
    if (_now().isBefore(until)) return true;
    _cooldownUntil.remove(videoId);
    return false;
  }

  void _coolDown(String videoId) {
    final now = _now();
    _cooldownUntil.removeWhere((_, until) => !now.isBefore(until));
    _cooldownUntil[videoId] = now.add(failureCooldown);
  }

  /// token 要刷新时不预取：ApiService 会在发请求前先刷 token，刷新走的
  /// TokenManager 那只 Dio 撞上 Cloudflare 会弹全屏验证页，后台标记管不到它。
  static bool _defaultCanRunInBackground() {
    if (!Get.isRegistered<ApiService>() || !Get.isRegistered<AuthService>()) {
      return false;
    }
    final auth = Get.find<AuthService>();
    if (!auth.hasRefreshToken || auth.isAuthTokenExpired) return true;
    final tokens = auth.tokenManager;
    return !tokens.isRefreshing && !tokens.isAccessTokenExpired;
  }

  /// 每次新建：ApiService 会往 `options.extra` 里写自己的键。
  static d_dio.Options _backgroundOptions() =>
      d_dio.Options(extra: {IwaraNetworkService.backgroundRequestKey: true});

  static Future<video_model.Video> _defaultFetchDetail(String videoId) async {
    final res = await Get.find<ApiService>().get(
      '/video/$videoId',
      options: _backgroundOptions(),
      maxNetworkRetries: 0,
    );
    return video_model.Video.fromJson(res.data);
  }

  /// 参数与详情页 `_fetchVideoSourceInternal` 一致，拿到的清单可以原样给它用。
  static Future<List<VideoSource>?> _defaultFetchSources(String fileUrl) async {
    final api = Get.find<ApiService>();
    final res = await XVersionSaltService.instance.requestVideoSources(
      fileUrl,
      (headers) => api.get(
        fileUrl,
        headers: headers,
        options: _backgroundOptions(),
        maxNetworkRetries: 0,
      ),
      keepFirstOnRetryFailure: true,
      checkSiteTimeout: XVersionSaltService.playbackCheckSiteTimeout,
    );
    final data = res.data;
    // 签名失效时的 360 清单不进缓存（同详情页）：留给详情页自己去换盐值重签。
    if (data is! List || XVersionSaltService.looksUnsigned(data)) return null;
    return data
        .map((item) => VideoSource.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
