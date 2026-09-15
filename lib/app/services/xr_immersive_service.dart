import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/vr_format_override_service.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/services/playback_queue_navigator.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/xr_playlist_source.dart';
import 'package:i_iwara/app/services/xr_queue_catalog.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 把当前视频交给 XR 沉浸空间去呈现。
///
/// # 它对接的是什么
///
/// Quest（`quest` flavor）上，整个应用常驻在自建的沉浸空间里，现有 Flutter UI 是
/// 悬浮其中的一块面板。选中视频后，视频不再画在面板里，而是作为**独立的空间对象**
/// 呈现：平面片走幕布，180/360 片走球幕，配一条空间化的控制条。
///
/// 原生侧落点：`android/app/src/quest/kotlin/**/xr/XrBridge.kt`
/// 与 `**/vr/ImmersiveActivity.kt`。
///
/// # 为什么没有 `if (isQuest)`
///
/// `XrBridge` 在 `standard` / `quest` 两个源集里各有一份同名实现，standard 那份是
/// 空壳、**不注册这个通道**。于是在普通安卓/桌面上调用会直接抛
/// `MissingPluginException`，被这里吃掉并回报「不可用」。
/// 调用点只需要问 [isAvailable]，不需要知道自己跑在什么设备上。
class XrImmersiveService extends GetxService {
  XrImmersiveService({
    LocalMediaRepository? localRepository,
    Future<XrPlayableVideo?> Function(String)? resolveVideo,
    void Function(XrPlaybackReturn)? restorePage,
  }) : _localRepositoryOverride = localRepository,
       _resolveVideo = resolveVideo ?? XrPlaylistSource.resolve,
       _restorePage = restorePage ?? _navigateToPlayback;

  static const MethodChannel _channel = MethodChannel('i_iwara/immersive');
  final LocalMediaRepository? _localRepositoryOverride;
  late final LocalMediaRepository _localRepository =
      _localRepositoryOverride ?? LocalMediaRepository();
  final Future<XrPlayableVideo?> Function(String) _resolveVideo;
  final void Function(XrPlaybackReturn) _restorePage;
  int _nextRequestId = 0;
  int _latestRequestId = 0;
  int _presentationEpoch = 0;
  int _lastCommittedRequestId = 0;
  final Map<int, _XrVideoPresentation> _presentations = {};
  _XrVideoPresentation? _playing;
  bool _closed = false;

  void _setPlaying(_XrVideoPresentation? presentation) {
    if (identical(_playing, presentation)) return;
    for (final queue in _playing?.queues.toSet() ?? <PlaybackQueue>{}) {
      queue.removeListener(_schedulePushQueues);
    }
    _playing = presentation;
    nowPlayingId = presentation?.mediaId;
    _lastSources = presentation?.sources ?? const [];
    // 页面可以先被换成 B；只要 A 还在幕布上，其队列就不能被 LRU 淘汰。
    for (final queue in presentation?.queues.toSet() ?? <PlaybackQueue>{}) {
      if (!queue.isDisposed) queue.addListener(_schedulePushQueues);
    }
  }

  /// 供 UI 直接 Obx 的可用性。⚠️ 它是**缓存值**，进入播放器时刷一次即可 ——
  /// 沉浸场景的生死只会随「进/出沉浸空间」变化，不会在页面停留期间反复抖动。
  final RxBool available = false.obs;

  /// 看视频时原生为了省电把面板里的 Flutter 停帧，走的是 `appIsPaused()`——Dart 收到的
  /// 生命周期**不是真进后台**。为 true 期间应用锁 / token 刷新等「按生命周期判前后台」的逻辑
  /// 一律不认；真离开（摘头显、Meta 键回主页）由原生另发 `sceneLifecycle` 交给 [_onSceneLifecycle]。
  ///
  /// 静态字段：生命周期回调里不想碰 GetX 注册表。原生每次先发它、再发生命周期，顺序有保证。
  static bool panelSuspended = false;

  /// 沉浸场景本身的真实前后台切换，喂给应用锁（面板停帧期间 Flutter 生命周期被屏蔽，只能靠它）。
  ///
  /// 不看 [panelSuspended]：没停帧时 Flutter 自己的生命周期也会报，重复无害
  /// （onBackgrounded 是 `??=`，onResumed 结算后清零）；而按它过滤会在「恢复出帧与离开同一轮发生」时丢事件＝锁不上。
  void _onSceneLifecycle(bool foreground) {
    if (!Get.isRegistered<AppLockService>()) return;
    final lock = Get.find<AppLockService>();
    if (foreground) {
      lock.onResumed();
    } else {
      lock.onBackgrounded(AppLifecycleState.paused);
    }
  }

  /// 原生已提交的媒体身份（在线视频 id / 本机条目 id）。等待或失败的请求不改它。
  String? nowPlayingId;

  /// 最后一次推给原生的清晰度清单（[nowPlayingId] 那条的）。
  ///
  /// 留着只为一件事：**换语言时把它原样重推一遍**。清单里的显示名是推送那一刻按当时
  /// 语言算好的（[XrMediaSource.toChannelMap]），不重推的话，切完语言面板上别的字都变了、
  /// 唯独清晰度还是旧语言。原生对「地址没变的重推」是空操作（`swapSource` 首行就 return），
  /// 不会打断播放。
  List<XrMediaSource> _lastSources = const <XrMediaSource>[];

  /// 沉浸播放结束时的落点：当前活着的视频页控制器挂在这里，收到最后位置后
  /// 回写自己的播放器（观看历史随之保存）。没人挂着时由本服务导航到对应视频页。
  void Function(String mediaId, int positionMs, int durationMs)?
  onImmersiveEnded;

  /// [onImmersiveEnded] 挂着的那张页面的视频 id；ended 只在 id 对得上时才交给它。
  String? onImmersiveEndedMediaId;

  /// 原生播放器被服务端拒了（直链 `expires` 到期，Iwara 回 404）时的落点：当前活着的视频页
  /// 控制器挂在这里，收到后立刻重取一份清晰度清单并 [updateSources] 推回去。
  /// 只在 [videoId] 与页面这条对得上时才调（详情页自己判）。
  void Function(String videoId)? onSourceRefreshRequested;
  String? onSourceRefreshRequestedMediaId;

  /// 空间面板上定了视频类型时的落点：当前活着的视频页控制器挂在这里，按钥匙（在线 id /
  /// 本地库条目 id）对上了就把 2D 播放器改成同一档。落库不靠它，见 [_handleFormatPicked]。
  void Function(String formatKey, VrSourceFormat format)? onVrFormatPicked;

  /// ⛔ 视频没有「要不要交给空间播放器」这个选项：Quest 上详情页的播放器区域本来
  /// 就被换成了封面（见 `video_detail_page_v2._buildImmersiveCover`），不交出去就
  /// 没人放。图库不同——2D 大图页在面板里是好用的，所以下面那枚开关是真开关。
  ///
  /// Quest 上点开图库里的图片是否自动进空间画廊（设置项，默认开）。
  bool get galleryAutoEnterEnabled =>
      Get.find<ConfigService>()[ConfigKey.XR_GALLERY_AUTO_ENTER_KEY] == true;

  // ────────────────────────────────────────────── 空间画廊

  /// 幕布上正在浏览的那本图库的 id；不在画廊里为 null。
  String? nowShowingGalleryId;

  /// 当前活着的图库详情页挂在这里：幕布翻到第几项就把 2D 面板里的横向清单带到第几项。
  void Function(String galleryId, int index)? onGalleryIndexChanged;

  /// 空间画廊结束（回应用 / 被视频顶掉 / 场景退出）。
  void Function(String galleryId, int index)? onGalleryEnded;

  /// 幕布上那本图库的清单（按 id 找文件用），与 [nowShowingGalleryId] 成对。
  List<XrGalleryItem> _galleryItems = const <XrGalleryItem>[];

  /// 当前活着的视频详情页把它的「接着看」视频池交在这里；沉浸面板的播放列表就是这份。
  ///
  /// 没有页面挂着时退回「稍后再看」（[XrPlaylistSource.fallbackSections]）。
  XrQueueSnapshot Function()? get queueProvider => _queueProvider;
  XrQueueSnapshot Function()? _queueProvider;

  /// 换了一张页面（或页面走了）：面板里「正在浏览的池」是上一张页面的事，清掉。
  set queueProvider(XrQueueSnapshot Function()? value) {
    if (value == _queueProvider) return;
    _queueProvider = value;
    _setBrowse(null);
  }

  /// 面板里**正在浏览**、但播放器没在用的那个池（= 2D 抽屉里切了 tab 还没点播）。
  ///
  /// # ⛔ 切池只是浏览，点播才换池（与 2D 抽屉同一条规矩）
  ///
  /// 空间版原先在面板里一切分区就 `adopt` 进详情页，当前池当场被换掉——在来源池连播
  /// 时切过去瞄一眼稍后再看，下一条就从稍后再看冒出来了。2D 抽屉 2026-08-30 就为这件事
  /// 返工过（见 `playback_queue_drawer.dart` 的 `_isBrowsingActiveQueue`）。现在浏览的池
  /// 只挂在这里，[playQueueItem] 真的点播了一条才交给页面收养。
  ///
  /// 挂着一个监听：①让它算"在用"，不被 LRU 淘汰；②它翻完页自己会通知，合并成一次重推。
  PlaybackQueue? _browse;

  void _setBrowse(PlaybackQueue? queue) {
    if (identical(queue, _browse)) return;
    _browse?.removeListener(_onBrowseChanged);
    _browse = queue;
    queue?.addListener(_onBrowseChanged);
  }

  void _onBrowseChanged() => _schedulePushQueues();

  /// 「接着看」的来源目录（与 2D 抽屉同一套两级菜单），见 [XrQueueCatalog]。
  late final XrQueueCatalog _catalog = XrQueueCatalog(
    onChanged: _schedulePushQueues,
    localRepository: _localRepositoryOverride,
  );

  /// 目录里几路来源（自建列表 / 他人列表 / 本地收藏…）各自异步回来、各喊一次 onChanged：
  /// 直接推就是连着几次查库 + 整棵树序列化过通道 + 原生面板连续重组。合成一次再推。
  Timer? _catalogPushTimer;

  void _schedulePushQueues() {
    if (_closed) return;
    _catalogPushTimer?.cancel();
    _catalogPushTimer = Timer(
      const Duration(milliseconds: 150),
      () => unawaited(pushQueues()),
    );
  }

  @override
  void onClose() {
    _closed = true;
    _presentationEpoch++;
    _setPlaying(null);
    _setBrowse(null);
    _presentations.clear();
    _catalogPushTimer?.cancel();
    _channel.setMethodCallHandler(null);
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // ⛔ 无条件挂：standard 变体没注册这条通道，原生侧永远不会回调过来，
    // 挂一个处理器不会有任何副作用。调用点因此不需要 `if (isQuest)`。
    _channel.setMethodCallHandler(_onNativeCall);
    // 启动时就问一次：第一张详情页在 onInit 里要靠这个缓存值决定「进页面起不起播」。
    unawaited(refreshAvailability());
    unawaited(_logLaunchDiagnostics());
  }

  /// 「Quest 版打开是平面模式」的取证：把原生记下的启动形态写进应用日志，用户导出即可带回。
  ///
  /// 原生侧见 `LaunchDiagnostics.kt`：verdict 为 `flat_main_launched_directly` 即平面形态
  /// （MainActivity 被顶层拉起、沉浸 Activity 没建），配合 intent/referrer 看入口，
  /// 配合 launcherResolvesTo 看装的是不是还没带入口修复的老包；history 是落盘的最近几次启动经过。
  /// 场景就绪在 Dart 起来之后，所以隔几秒再补一条最终判定。
  Future<void> _logLaunchDiagnostics() async {
    const tag = 'XrLaunch';
    try {
      final snap = await _channel.invokeMapMethod<String, dynamic>(
        'launchDiagnostics',
      );
      if (snap == null) return;
      final history = (snap['history'] as List?)?.cast<Object?>() ?? const [];
      final summary = Map<String, dynamic>.of(snap)..remove('history');
      LogUtils.i('启动形态快照: $summary', tag);
      LogUtils.i('最近启动经过(${history.length}条):\n${history.join('\n')}', tag);

      await Future<void>.delayed(const Duration(seconds: 10));
      final later = await _channel.invokeMapMethod<String, dynamic>(
        'launchDiagnostics',
      );
      if (later == null) return;
      final verdict = later['verdict'];
      final line =
          '启动 10s 后形态: verdict=$verdict sceneAlive=${later['sceneAlive']} '
          'firstActivity=${later['firstActivity']} mainDisplayId=${later['mainDisplayId']}';
      if (verdict == 'immersive') {
        LogUtils.i(line, tag);
      } else {
        LogUtils.w('$line（非空间形态）', tag);
      }
    } on MissingPluginException {
      // standard 变体没有这条通道。
    } catch (e) {
      LogUtils.w('读取启动形态诊断失败: $e', tag);
    }
  }

  Future<void> refreshAvailability() async {
    available.value = await isAvailable();
    // 顺手对一次语言：进播放页是「面板马上要被唤出」的最后一个 Dart 侧时机。
    unawaited(syncLocale());
  }

  /// 上一次推给原生的语言标签；没变就不再发。
  String _pushedLocaleTag = '';

  /// 把应用内选定的界面语言告诉空间面板。
  ///
  /// ⛔ 原生面板**不能**跟系统语言走：应用的语言是用户自己在设置里选的，
  /// 完全可能与头显系统语言不同（Quest 英文 + 应用中文）。原生侧把它存进
  /// `PanelLocale`，面板与提示都用它取词（`:questui` 的 `res/values*/strings.xml`）。
  ///
  /// 调用点：启动、进播放页（[refreshAvailability]）、[present] 随包带、
  /// 以及设置页里换语言的那一刻（面板可能正开着）。
  Future<void> syncLocale() async {
    final tag = slang.LocaleSettings.currentLocale.languageTag;
    if (tag == _pushedLocaleTag) return;
    try {
      await _channel.invokeMethod<bool>('setLocale', {'locale': tag});
      _pushedLocaleTag = tag;
      // 面板自己会重组换词（`PanelLocale.tag` 是 Compose 状态），但清晰度的显示名是
      // Dart 算好推过去的死字符串，得重推一遍才跟着换。
      final playing = nowPlayingId;
      if (playing != null && playing.isNotEmpty && _lastSources.isNotEmpty) {
        unawaited(updateSources(mediaId: playing, sources: _lastSources));
      }
    } on MissingPluginException {
      // standard 变体没有这条通道，记下来别反复试。
      _pushedLocaleTag = tag;
    } catch (e) {
      LogUtils.d('推送面板语言失败: $e', 'XrImmersive');
    }
  }

  // ────────────────────────────────────────────── 原生 → Dart

  /// 沉浸面板反过来找 Dart 要东西时的落点。
  ///
  /// 只有几件事：**要播放列表**、**翻下一页**、**要换片**、**播完了回写位置**、**地址过期要新地址**。
  /// 刻意保持得这么窄 —— 设计文档 §6.6 已经否掉了「沉浸端持续回打 Dart 的瘦客户端
  /// 架构」（跨端持续同步最脆），这里是「原生自足 + 偶尔向 Dart 要一次数据」。
  Future<dynamic> _onNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'requestPlaylist':
        final args = call.arguments as Map?;
        if (args?['force'] == true) _catalog.invalidate();
        await pushQueues();
        // 面板打开时把「正在播的那一条」翻进池里（同 2D 抽屉 `_ensureLoaded`），
        // 否则深列表中段进来，卡片流里找不到自己、也没有下一条。
        final active = _activeQueue;
        if (active != null) unawaited(_ensureCurrentLoaded(active));
        return true;
      case 'browseQueue':
        final args = call.arguments as Map?;
        return await browseQueueForImmersive(
          (args?['queueId'] as String?) ?? '',
        );
      case 'expandCatalog':
        final args = call.arguments as Map?;
        final nodeId = (args?['nodeId'] as String?) ?? '';
        if (nodeId.isNotEmpty) await _catalog.expand(nodeId);
        await pushQueues();
        return true;
      case 'sourcePicked':
        // 面板上换了清晰度：与 2D 播放器底栏同一个落点（DEFAULT_QUALITY_KEY），
        // 下一条视频按它匹配、向下降级（见 [pickPreferredSource]）。
        final args = call.arguments as Map?;
        final label = (args?['label'] as String?)?.trim() ?? '';
        if (label.isNotEmpty && Get.isRegistered<ConfigService>()) {
          Get.find<ConfigService>().setSetting(
            ConfigKey.DEFAULT_QUALITY_KEY,
            label,
          );
        }
        return true;
      case 'formatPicked':
        final args = call.arguments as Map?;
        await _handleFormatPicked(
          key: (args?['key'] as String?)?.trim() ?? '',
          xrFormat: (args?['format'] as String?)?.trim() ?? '',
          shape: (args?['shape'] as String?) ?? '',
          stereo: (args?['stereo'] as String?) ?? '',
        );
        return true;
      case 'loadMore':
        final args = call.arguments as Map?;
        return await loadMoreInQueue((args?['queueId'] as String?) ?? '');
      case 'playItem':
        final args = call.arguments as Map?;
        final videoId = (args?['id'] as String?) ?? '';
        var ok = false;
        try {
          ok = await playQueueItem(
            queueId: (args?['queueId'] as String?) ?? '',
            videoId: videoId,
          );
        } catch (e) {
          LogUtils.w('沉浸态换片抛异常 videoId=$videoId: $e', 'XrImmersive');
        }
        // ⛔ 原生发 playItem 不等回值、已进换片转圈态：这里不喊停，它要干等 45 秒超时。
        if (!ok) unawaited(abortSwitch(mediaId: videoId));
        return ok;
      case 'panelSuspended':
        final args = call.arguments as Map?;
        panelSuspended = (args?['suspended'] as bool?) ?? false;
        return true;
      case 'sceneLifecycle':
        final args = call.arguments as Map?;
        _onSceneLifecycle((args?['foreground'] as bool?) ?? true);
        return true;
      case 'immersiveEnded':
        final args = call.arguments as Map?;
        final id = (args?['mediaId'] as String?)?.trim() ?? '';
        final requestId = (args?['requestId'] as num?)?.toInt() ?? 0;
        final positionMs = (args?['positionMs'] as num?)?.toInt() ?? 0;
        final durationMs = (args?['durationMs'] as num?)?.toInt() ?? 0;
        await _handleImmersiveEnded(
          requestId,
          id,
          positionMs,
          durationMs,
          replaced: args?['replaced'] == true,
        );
        return true;
      case 'sourceExpired':
        final args = call.arguments as Map?;
        return _refreshExpiredSource(
          (args?['videoId'] as String?)?.trim() ?? '',
          (args?['requestId'] as num?)?.toInt() ?? 0,
        );
      case 'galleryFile':
        final args = call.arguments as Map?;
        return await _resolveGalleryFile(
          id: (args?['id'] as String?) ?? '',
          quality: normalizeGalleryImageQuality(args?['quality']),
        );
      case 'galleryIndexChanged':
        final args = call.arguments as Map?;
        final galleryId = (args?['galleryId'] as String?) ?? '';
        final index = (args?['index'] as num?)?.toInt() ?? 0;
        onGalleryIndexChanged?.call(galleryId, index);
        return true;
      case 'galleryQualityPicked':
        final args = call.arguments as Map?;
        final quality = normalizeGalleryImageQuality(args?['quality']);
        // 本机文件那本没有画质之分：面板上点了也别改在线图库的默认画质偏好。
        final allLocal =
            _galleryItems.isNotEmpty &&
            _galleryItems.every((e) => e.isLocalFile);
        if (!allLocal && Get.isRegistered<ConfigService>()) {
          Get.find<ConfigService>().setSetting(
            ConfigKey.GALLERY_VIEWER_DEFAULT_IMAGE_QUALITY,
            quality,
          );
        }
        return true;
      case 'galleryEnded':
        final args = call.arguments as Map?;
        final galleryId = (args?['galleryId'] as String?) ?? '';
        final index = (args?['index'] as num?)?.toInt() ?? 0;
        if (nowShowingGalleryId == galleryId) {
          nowShowingGalleryId = null;
          _galleryItems = const <XrGalleryItem>[];
        }
        onGalleryEnded?.call(galleryId, index);
        return true;
      default:
        return null;
    }
  }

  /// 用请求身份去重；正常换片只保存旧进度，主动退出才交回或恢复对应页面。
  Future<void> _handleImmersiveEnded(
    int requestId,
    String mediaId,
    int positionMs,
    int durationMs, {
    required bool replaced,
  }) async {
    final presentation = _presentations[requestId];
    if (presentation == null || presentation.mediaId != mediaId) return;
    _presentations.remove(requestId);
    // ended 也可能先于同一次 present 的平台回值到达；它本身证明这一请求已播过。
    final wasOnScreen =
        identical(_playing, presentation) ||
        (!replaced && requestId > _lastCommittedRequestId);
    if (wasOnScreen) {
      if (requestId > _lastCommittedRequestId) {
        _lastCommittedRequestId = requestId;
      }
      _setPlaying(null);
    }
    final epoch = _presentationEpoch;
    final latestRequest = _latestRequestId;
    // 本机与线上存储身份来自发起请求时的元数据，不信任回调把两者混作一个 id。
    await _savePresentationProgress(presentation, positionMs, durationMs);
    if (replaced ||
        !wasOnScreen ||
        _closed ||
        _playing != null ||
        nowShowingGalleryId != null ||
        _presentationEpoch != epoch ||
        _latestRequestId != latestRequest) {
      return;
    }
    final handler = onImmersiveEnded;
    if (handler != null && onImmersiveEndedMediaId == mediaId) {
      handler(mediaId, positionMs, durationMs);
      return;
    }
    _restorePage((
      mediaId: mediaId,
      videoId: presentation.videoId,
      localPath: presentation.localPath,
      localLibraryItemId: presentation.localLibraryItemId,
      localTask: presentation.localTask,
      localAllQualityTasks: presentation.localAllQualityTasks,
      queueRef: presentation.queueRef,
    ));
  }

  static void _navigateToPlayback(XrPlaybackReturn playback) {
    if (playback.localPath != null) {
      NaviService.navigateToLocalVideoPlayerPage(
        localPath: playback.localPath!,
        localLibraryItemId: playback.localLibraryItemId,
        task: playback.localTask,
        allQualityTasks: playback.localAllQualityTasks,
        playbackQueueRef: playback.queueRef,
      );
    } else if (playback.videoId != null) {
      unawaited(
        NaviService.navigateToVideoDetailPage(
          playback.videoId!,
          playbackQueueRef: playback.queueRef,
        ),
      );
    }
  }

  Future<void> _savePresentationProgress(
    _XrVideoPresentation presentation,
    int positionMs,
    int durationMs,
  ) async {
    final localId = presentation.localLibraryItemId;
    if (localId != null) {
      if (durationMs <= 0 ||
          !Get.isRegistered<ConfigService>() ||
          Get.find<ConfigService>()[ConfigKey
                  .RECORD_AND_RESTORE_VIDEO_PROGRESS] !=
              true) {
        return;
      }
      final position = positionMs.clamp(0, durationMs);
      final completed =
          position >= durationMs * 0.9 ||
          (durationMs > 60000 && durationMs - position < 10000);
      try {
        _localRepository.saveProgress(
          itemId: localId,
          positionMs: completed ? 0 : position,
          durationMs: durationMs,
          completed: completed,
        );
      } catch (e) {
        LogUtils.w('回写沉浸态本机进度失败 $localId: $e', 'XrImmersive');
      }
    }
    final onlineId = presentation.videoId;
    if (onlineId != null) await _saveHistory(onlineId, positionMs, durationMs);
  }

  Future<bool> _refreshExpiredSource(String videoId, int requestId) async {
    final presentation = _playing;
    if (presentation == null ||
        presentation.videoId != videoId ||
        presentation.requestId != requestId) {
      return false;
    }
    final handler = onSourceRefreshRequested;
    if (handler != null &&
        onSourceRefreshRequestedMediaId == presentation.mediaId) {
      handler(videoId);
      return true;
    }
    // 预加载 B 失败后，页面可能已是 B；A 的刷新不能再依赖那张页面。
    final resolved = await _resolveVideo(videoId);
    if (resolved == null || !identical(_playing, presentation)) return false;
    final sources = [
      for (final source in resolved.sources)
        XrMediaSource(label: source.label, url: source.url),
      // 本机档不会过期，保留它们，避免刷新清单把离线档位删掉。
      for (final source in _lastSources)
        if (source.local) source,
    ];
    final byLabel = {for (final source in sources) source.label: source};
    return updateSources(
      mediaId: presentation.mediaId,
      sources: byLabel.values.toList(),
      requestId: presentation.requestId,
    );
  }

  PlaybackQueue? _snapshotActive(XrQueueSnapshot? snapshot) {
    if (snapshot == null) return null;
    return snapshot.active ??
        snapshot.queues.firstWhereOrNull(
          (q) => q.mediaType == snapshot.mediaType && !q.isDisposed,
        );
  }

  PlaybackQueue? get _activeQueue {
    final playing = _playing;
    if (playing != null) return playing.queue;
    return _snapshotActive(queueProvider?.call());
  }

  List<PlaybackQueue> _playbackQueues(XrQueueSnapshot? snapshot) {
    final playing = _playing;
    if (playing == null) return snapshot?.queues ?? const [];
    return [
      ...playing.queues.where((q) => !q.isDisposed),
      for (final queue in snapshot?.queues ?? <PlaybackQueue>[])
        if (queue.mediaType == PlaybackMediaType.video &&
            !queue.isDisposed &&
            !playing.queues.any((q) => q.queueId == queue.queueId))
          queue,
    ];
  }

  /// 空间面板上给一条片子定了视频类型：永久记住，并让还活着的那张详情页当场改口。
  ///
  /// ⛔ 以前原生侧选完就算了，Dart 一个字都不知道：面板里选的档只活在这一次沉浸会话里，
  /// 下次再进同一条片子又回到推断档，本机文件（没有任何格式元数据）每次都得重选。
  ///
  /// 页面那边必须同步：详情页的 `vrFormatVerdict` 是进页时读的库，不改口的话 2D 播放器
  /// 显示的还是旧档。落库则不经过页面——页面可能已经被换片顶掉了，而换片正是最常见的时刻。
  Future<void> _handleFormatPicked({
    required String key,
    required String xrFormat,
    required String shape,
    required String stereo,
  }) async {
    if (key.isEmpty) return;
    final format = _formatFromChannel(shape, stereo);
    if (Get.isRegistered<VrFormatOverrideService>()) {
      await Get.find<VrFormatOverrideService>().put(
        key,
        format,
        xrFormat: xrFormat.isEmpty ? null : xrFormat,
      );
    }
    LogUtils.i('空间面板定了视频类型 key=$key format=$xrFormat', 'XrImmersive');
    onVrFormatPicked?.call(key, format);
  }

  /// [_shapeOf] / [_stereoOf] 的反方向。
  ///
  /// `eac` 在 2D 这一侧没有对应的投影，退回平面单目：2D 播放器按平面放一条 EAC 片
  /// 顶多是一幅展开图，按错的球面放则是完全没法看——与 [VrSourceFormat] 的兜底方向一致。
  /// 空间里靠 `xr_format` 那一列原样还原，不受影响。
  static VrSourceFormat _formatFromChannel(String shape, String stereo) {
    final projection = switch (shape) {
      '180' => VrProjection.equirect180,
      '360' => VrProjection.equirect360,
      'fisheye' => VrProjection.fisheye,
      _ => VrProjection.flat,
    };
    if (shape == 'eac') return VrSourceFormat.flatMono;
    final layout = switch (stereo) {
      'lr' => VrStereoLayout.sideBySide,
      'tb' => VrStereoLayout.topBottom,
      _ => VrStereoLayout.mono,
    };
    return VrSourceFormat(projection: projection, stereoLayout: layout);
  }

  /// 被换掉的旧片：沉浸端的进度从不经过页面控制器，只能在这一刻回写一次。
  /// 口径与 `MyVideoStateController._disposeAsyncResources` 一致（头尾 5s 内当作没看 / 看完）。
  Future<void> _saveHistory(
    String videoId,
    int positionMs,
    int durationMs,
  ) async {
    if (!Get.isRegistered<PlaybackHistoryService>() ||
        !Get.isRegistered<ConfigService>() ||
        Get.find<ConfigService>()[ConfigKey
                .RECORD_AND_RESTORE_VIDEO_PROGRESS] !=
            true) {
      return;
    }
    if (durationMs <= 0) return;
    final history = Get.find<PlaybackHistoryService>();
    try {
      if (positionMs <= 5000 || positionMs >= durationMs - 5000) {
        await history.deletePlaybackHistory(videoId);
      } else {
        await history.savePlaybackHistory(videoId, durationMs, positionMs);
      }
    } catch (e) {
      LogUtils.d('回写沉浸态播放历史失败 $videoId: $e', 'XrImmersive');
    }
  }

  // ────────────────────────────────────────────── 播放列表

  /// 把「接着看」推给沉浸面板。
  ///
  /// 一次推三样：**正在浏览的池**（卡片流画它）、**播放器在用的池**（上一个 / 下一个 /
  /// 播完接着放、「正在播」标记看它；两者是同一个时只推一份）、整棵池选择器。
  /// 没有页面挂着时退回稍后再看。
  Future<void> pushQueues() async {
    if (_closed) return;
    try {
      final snapshot = queueProvider?.call();
      final sections = <XrPlaylistSection>[];
      XrCatalogNode? catalog;
      String? activeQueueId;
      String? browseQueueId;
      final active = _activeQueue;
      final mediaType = _playing != null
          ? PlaybackMediaType.video
          : snapshot?.mediaType ?? PlaybackMediaType.video;
      if (active != null && !active.isDisposed) {
        var browsing = _browse ?? _snapshotActive(snapshot);
        if (browsing != null &&
            (browsing.isDisposed ||
                browsing.mediaType != mediaType ||
                browsing.queueId == active.queueId)) {
          _setBrowse(null);
          browsing = null;
        }
        final current = browsing ?? active;
        activeQueueId = active.queueId;
        browseQueueId = current.queueId;
        sections.add(XrPlaylistSource.sectionFromQueue(active));
        if (!identical(current, active)) {
          sections.add(XrPlaylistSource.sectionFromQueue(current));
        }
        catalog = _catalog.build(
          queues: _mergeBrowse(_playbackQueues(snapshot), browsing),
          browsing: current,
          currentItemId: nowPlayingId ?? snapshot?.currentItemId ?? '',
          author: _playing?.author ?? snapshot?.author,
          playingLocalFile: active.kind == PlaybackQueueKind.localLibrary,
          mediaType: mediaType,
        );
      } else {
        final fallback = XrPlaylistSource.fallbackSection();
        sections.add(fallback);
        activeQueueId = fallback.queueId;
        browseQueueId = fallback.queueId;
      }
      LogUtils.i(
        '推送接着看 provider=${queueProvider != null} active=$activeQueueId '
            'browse=$browseQueueId catalog=${catalog != null}',
        'XrImmersive',
      );
      await _channel.invokeMethod<void>('setPlaylist', {
        'sections': sections.map((e) => e.toChannelMap()).toList(),
        'catalog': catalog?.toChannelMap(),
        'activeQueueId': activeQueueId,
        'browseQueueId': browseQueueId,
        // 空间画廊里「正在看的那条」是图库 id：卡片高亮同一个字段。
        'nowPlayingId': nowPlayingId ?? nowShowingGalleryId,
        // 刚拒掉的浏览请求：面板据此收掉那枚转圈，不必干等看门狗。
        'browseRejectedQueueId': _takeRejectedBrowse(),
        // 与 2D 抽屉同一句话：直接用应用内的文案，免得面板资源里另译一份再对不上。
        'texts': {
          'upNext': slang.t.playbackQueue.upNext,
          'loadFailed': slang.t.watchLater.queueLoadFailed,
          'emptyVideo': slang.t.playbackQueue.emptyQueue,
          'emptyGallery': slang.t.playbackQueue.emptyGalleryQueue,
        },
      });
    } on MissingPluginException {
      // standard 变体没这条通道，正常。
    } catch (e) {
      LogUtils.d('推送沉浸播放列表失败: $e', 'XrImmersive');
    }
  }

  /// 抽屉 `_useQueue` 的占槽规则：queueId 命中就顶掉实例、同 kind 就顶掉、都不是追加。
  /// 结果只给目录算高亮 / 副标题用，不回写页面。
  static List<PlaybackQueue> _mergeBrowse(
    List<PlaybackQueue> queues,
    PlaybackQueue? browsing,
  ) {
    if (browsing == null) return queues;
    final merged = [...queues];
    var slot = merged.indexWhere((q) => q.queueId == browsing.queueId);
    if (slot < 0) slot = merged.indexWhere((q) => q.kind == browsing.kind);
    if (slot >= 0) {
      merged[slot] = browsing;
    } else {
      merged.add(browsing);
    }
    return merged;
  }

  /// 面板上一次没开成的浏览请求（池不在目录里 / 页面不在了），随下一次推送带走一次。
  String? _rejectedBrowse;

  String? _takeRejectedBrowse() {
    final id = _rejectedBrowse;
    _rejectedBrowse = null;
    return id;
  }

  /// [queue] 装第一页，并翻到装得下正在播的那一条为止（同 2D 抽屉 `_ensureLoaded`）。
  ///
  /// ⛔ 打开面板时只对**在用的池**做：浏览的池多半压根不含正在播的那条，每开一次面板
  /// 就白翻 8 页。浏览池只在切过去那一下做一次（[browseQueueForImmersive]）。
  Future<void> _ensureCurrentLoaded(PlaybackQueue queue) async {
    final snapshot = queueProvider?.call();
    final currentItemId = nowPlayingId ?? snapshot?.currentItemId;
    if (currentItemId == null || queue.isDisposed) return;
    try {
      if (queue.loaded.isEmpty && queue.hasMore && !queue.isLoading) {
        await queue.loadMore();
      }
      final knownQueueItem = _playing == null || !_playing!.anonymous;
      if (knownQueueItem &&
          !queue.isDisposed &&
          !queue.contains(currentItemId)) {
        await queue.ensureContains(currentItemId);
      }
    } catch (e) {
      LogUtils.w('沉浸态装池失败 queue=${queue.queueId}: $e', 'XrImmersive');
    }
    await pushQueues();
  }

  /// 沉浸面板在池选择器里点了一池：**只浏览，不换池**（见 [_browse]）。
  Future<bool> browseQueueForImmersive(String queueId) async {
    if (queueId.isEmpty) return false;
    final snapshot = queueProvider?.call();
    if (snapshot == null && _playing == null) {
      _rejectedBrowse = queueId;
      await pushQueues();
      return false;
    }
    final queue =
        PlaybackQueueService.to.byId(queueId) ?? _catalog.open(queueId);
    final mediaType = _playing != null
        ? PlaybackMediaType.video
        : snapshot!.mediaType;
    if (queue == null || queue.mediaType != mediaType) {
      LogUtils.w('沉浸态要浏览的池不在目录里 queueId=$queueId', 'XrImmersive');
      _rejectedBrowse = queueId;
      await pushQueues();
      return false;
    }
    final active = _activeQueue;
    _setBrowse(
      active != null && active.queueId == queue.queueId ? null : queue,
    );
    // 先发请求再推：池此刻已经在 loading，面板画转圈而不是「加载失败」。
    final loading = queue.loaded.isEmpty && queue.hasMore && !queue.isLoading
        ? queue.loadMore()
        : null;
    await pushQueues();
    if (loading != null) {
      try {
        await loading;
      } catch (e) {
        LogUtils.w('沉浸态浏览池装第一页失败 queue=$queueId: $e', 'XrImmersive');
      }
    }
    await _ensureCurrentLoaded(queue);
    return true;
  }

  /// 沉浸面板里的「接着看」滚到了某个分区的末尾：让那个池翻一页，再整套推回去。
  ///
  /// 这就是应用里列表的无限滚动，只是触发点在原生面板。翻完**整套重推**而不是只推
  /// 增量：面板那边按 id 做 key，整套替换不会丢滚动位置。池不在了 / 已到底就原样推
  /// 一次，好让面板把加载态收掉。
  Future<bool> loadMoreInQueue(String queueId) async {
    final browse = _browse;
    final queue = queueId.isEmpty
        ? null
        : (browse != null && browse.queueId == queueId
              ? browse
              : PlaybackQueueService.to.byId(queueId));
    if (queue == null || !queue.hasMore) {
      await pushQueues();
      return false;
    }
    final before = queue.loaded.length;
    final future = queue.loadMore();
    // 先推一次 loading，面板把「加载失败」换回转圈（重试那条路靠这个）。
    await pushQueues();
    try {
      await future;
    } catch (e) {
      LogUtils.w('沉浸态翻页失败 queue=$queueId: $e', 'XrImmersive');
    }
    await pushQueues();
    return queue.loaded.length > before;
  }

  /// 沉浸面板里点了某个池的某一条。
  ///
  /// 与 2D 抽屉关掉之后详情页做的事一模一样：**先收养这个池**（点播才换池），再走
  /// [PlaybackQueueNavigator] 把详情页换成那条，新页带 `forceAutoPlay` 进来，片源一开就
  /// 自己 present 回沉浸空间。原生侧在发这条请求前已经把面板的出帧恢复了，所以换页能
  /// 正常 build。池认不出来（兜底列表、或池已被淘汰）时退回「直接解析地址」那条老路。
  Future<bool> playQueueItem({
    required String queueId,
    required String videoId,
  }) async {
    if (videoId.isEmpty) return false;
    final browse = _browse;
    final queue = queueId.isEmpty
        ? null
        : (browse != null && browse.queueId == queueId
              ? browse
              : PlaybackQueueService.to.byId(queueId));
    final item = queue?.loaded.firstWhereOrNull((e) => e.id == videoId);
    final snapshot = queueProvider?.call();
    LogUtils.i(
      '沉浸态换片 queue=$queueId found=${queue != null} item=${item != null} '
          'companions=${snapshot?.queues.map((q) => q.queueId).toList()}',
      'XrImmersive',
    );
    if (queue != null && item != null) {
      if (snapshot != null && !identical(snapshot.active, queue)) {
        snapshot.adopt(queue);
      }
      _setBrowse(null);
      await PlaybackQueueNavigator.playItem(
        queue: queue,
        item: item,
        // 「稍后再看 · 未看完」里点的：续播跳过已看完（同 2D 抽屉 `PlaybackQueueSelection`）。
        skipWatched: queue is WatchLaterPlaybackQueue && queue.unwatchedOnly,
        companionQueues: _playbackQueues(queueProvider?.call()),
        // 图库池里点的：新的图库详情页落地就整本交给空间画廊（视频那条路靠 forceAutoPlay）。
        presentInSpace: queue.mediaType.isGallery,
      );
      return true;
    }
    LogUtils.d('沉浸态换片：池 $queueId 里找不到 $videoId，退回直接解析', 'XrImmersive');
    return playFromPlaylist(videoId);
  }

  /// 沉浸面板里点了列表中的某一条。
  ///
  /// ⛔ **不走导航**：看视频时 Flutter 面板被显式暂停出帧，`pushReplacement`
  /// 建不出页面来。见 [XrPlaylistSource] 的类注释。
  Future<bool> playFromPlaylist(String videoId) async {
    final request = _latestRequestId = ++_nextRequestId;
    final epoch = _presentationEpoch;
    final playable = await _resolveVideo(videoId);
    if (_closed || request != _latestRequestId || epoch != _presentationEpoch) {
      return false;
    }
    if (playable == null) {
      LogUtils.w('沉浸态换片失败：解析不出可播地址 videoId=$videoId', 'XrImmersive');
      return false;
    }
    return present(
      url: playable.url,
      format: playable.format,
      title: playable.title,
      author: playable.author,
      videoId: playable.localLibraryItemId == null ? playable.id : null,
      mediaId: playable.id,
      localLibraryItemId: playable.localLibraryItemId,
      localPath: playable.localPath,
      sources: [
        for (final source in playable.sources)
          XrMediaSource(label: source.label, url: source.url),
      ],
      sourceLabel: playable.sourceLabel,
      width: playable.width,
      height: playable.height,
    );
  }

  /// 沉浸空间当前是否活着。
  ///
  /// ⚠️ 这不是「设备是不是 Quest」——沉浸场景可能还没就绪（例如面板里的 Flutter
  /// 比场景先跑起来）。入口按钮应当用它来决定露不露，并在状态变化时重查。
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.d('XR 沉浸空间不可用: $e', 'XrImmersive');
      return false;
    }
  }

  /// 唤出 / 收起浏览态的**空间控制面板**（面板远近 + 背景不透明度）。
  ///
  /// Quest 上整个 Flutter UI 就是悬在空间里的那一块面板，它离人多远、背后透出多少
  /// 真实房间，是每个人身高、坐姿、房间大小各不相同的一件事，所以它们是**用户可调 +
  /// 跨会话记住**的（原生落 `PlayerPrefs`，下次进来还在上次那一档上）。
  ///
  /// ⛔ 调节界面本身不在 Flutter 里：它是与空间视频同一块的**原生空间面板**
  /// （`questui` 的 `BrowsePanelPage`）。这边只负责把它唤出来 —— 一块悬在空间里的
  /// 2D 面板没法把自己推远，那三枚钮必须活在空间里、看得见结果。
  ///
  /// @return 是否受理；false = 幕布正占着场地，或场景没活着。
  Future<bool> togglePanelControls() async {
    try {
      return await _channel.invokeMethod<bool>('panelControls') ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.d('XR 打开面板设置失败: $e', 'XrImmersive');
      return false;
    }
  }

  /// 把这个视频交给沉浸空间呈现。
  ///
  /// [format] 直接用播放器已有的 L1 判定结果（`MyVideoStateController.vrFormat`）——
  /// ⛔ 那是「默认档」不是判决，用户在播放器里选过就以用户的为准，这里原样透传即可。
  ///
  /// 返回 true 表示原生已提交播放；等待、预加载期间保留上一条的身份和队列。
  ///
  /// [sources] 是这条片子所有可选的清晰度（在线直链 / 本机已下载的文件），[sourceLabel]
  /// 是 [url] 对应的那一档；面板上的「清晰度」钮据此换源，换源在原生侧完成、不回 Dart。
  ///
  /// [formatKey] 是「这条片子的视频类型记在哪把钥匙下」，缺省同 [videoId]。本机文件页的
  /// [videoId] 刻意是 null（它还管着回写 Iwara 历史），要另传本地库条目 id。
  ///
  /// ⛔ 库里有这把钥匙的手动覆盖时，**它压过调用方传来的 [format]**：调用方手里的格式是
  /// 进页那一刻读的，用户随后在空间面板上改过的档只在库里（面板改档不经过任何调用方）。
  /// 收口在这里，而不是指望每个调用方都记得先查一次库。
  Future<bool> present({
    required String url,
    required VrSourceFormat format,
    String title = '',
    String author = '',
    String? videoId,
    String? mediaId,
    String? localLibraryItemId,
    String? localPath,
    DownloadTask? localTask,
    List<DownloadTask> localAllQualityTasks = const [],
    String? formatKey,
    int width = 0,
    int height = 0,
    int positionMs = 0,
    bool fullFrame = false,
    List<XrMediaSource> sources = const <XrMediaSource>[],
    String sourceLabel = '',
  }) async {
    if (_closed) return false;
    final requestId = _latestRequestId = ++_nextRequestId;
    final epoch = _presentationEpoch;
    final onlineId = videoId?.trim().isNotEmpty == true
        ? videoId!.trim()
        : null;
    final localId = localLibraryItemId?.trim().isNotEmpty == true
        ? localLibraryItemId!.trim()
        : null;
    final id = mediaId?.trim().isNotEmpty == true
        ? mediaId!.trim()
        : localId ?? onlineId ?? 'local:$requestId';
    final snapshot = queueProvider?.call();
    // 任意文件入口可能没有池游标，但页面仍提供本机目录兜底池。
    final ownsSnapshot =
        snapshot != null &&
        snapshot.mediaType == PlaybackMediaType.video &&
        (snapshot.currentItemId == id ||
            (snapshot.currentItemId.isEmpty && localPath != null));
    final queue = ownsSnapshot
        ? _snapshotActive(snapshot)
        : _browse?.contains(id) == true
        ? _browse
        : _playing?.queue?.contains(id) == true
        ? _playing?.queue
        : null;
    final presentation = _XrVideoPresentation(
      requestId: requestId,
      mediaId: id,
      videoId: onlineId,
      localLibraryItemId: localId,
      localPath: localPath,
      localTask: localTask,
      localAllQualityTasks: List.unmodifiable(localAllQualityTasks),
      sources: List.unmodifiable(sources),
      queue: queue,
      queues:
          {
                ?queue,
                ...(ownsSnapshot ? snapshot.queues : _playbackQueues(snapshot)),
              }
              .where(
                (q) => !q.isDisposed && q.mediaType == PlaybackMediaType.video,
              )
              .toList(),
      author: snapshot?.currentItemId == id ? snapshot?.author : null,
    );
    try {
      final key = (formatKey ?? localId ?? onlineId)?.trim() ?? '';
      String xrFormat = '';
      if (key.isNotEmpty && Get.isRegistered<VrFormatOverrideService>()) {
        final stored = await Get.find<VrFormatOverrideService>().getEntry(key);
        if (stored != null) {
          format = stored.format;
          xrFormat = stored.xrFormat ?? '';
        }
      }
      if (_closed ||
          requestId != _latestRequestId ||
          epoch != _presentationEpoch) {
        return false;
      }
      _presentations[requestId] = presentation;
      final localeTag = slang.LocaleSettings.currentLocale.languageTag;
      _pushedLocaleTag = localeTag;
      final ok = await _channel.invokeMethod<bool>('present', {
        // 面板的语言随包带一份：面板可能在这次 present 之后才第一次被唤出。
        'locale': localeTag,
        'url': url,
        'title': title,
        // 面板标题下面那行小字。图集页早就有作者了，播放页也得有（用户 2026-09-06）。
        'author': author,
        'videoId': onlineId ?? '',
        'mediaId': id,
        'requestId': requestId,
        'sources': sources.map((e) => e.toChannelMap()).toList(),
        'sourceLabel': sourceLabel,
        'shape': _shapeOf(format.projection),
        'stereo': _stereoOf(format.stereoLayout),
        'fullFrame': fullFrame,
        'formatKey': key,
        'xrFormat': xrFormat,
        'w': width,
        'h': height,
        'positionMs': positionMs,
        // ⛔ 鱼眼片源在沉浸态**放不出正确画面**（SDK 没有这个投影），原生侧要靠
        // 这面旗子在控制面板上如实提示并给出「用其他应用打开」，而不是默默按平面播。
        'unsupportedProjection': format.projection == VrProjection.fisheye,
      });
      if (ok != true || _closed) {
        _presentations.remove(requestId);
        return false;
      }
      // 旧请求确实播过：不能接管新会话，但仍需保留元数据供迟到的 ended 回写进度。
      if (epoch != _presentationEpoch ||
          requestId <= _lastCommittedRequestId ||
          !identical(_presentations[requestId], presentation)) {
        return false;
      }
      _lastCommittedRequestId = requestId;
      _setPlaying(presentation);
      // 幕布一亮就把「接着看」推过去：面板里的播放列表页要能立刻用，
      // 而不是等用户点开那一页时才现拉（那时 Flutter 已经停止出帧了）。
      unawaited(pushQueues());
      return true;
    } on MissingPluginException {
      _presentations.remove(requestId);
      return false;
    } catch (e) {
      _presentations.remove(requestId);
      LogUtils.e('交给沉浸空间失败', tag: 'XrImmersive', error: e);
      return false;
    }
  }

  /// 把整本图库交给沉浸空间（空间画廊）。
  ///
  /// 原生只拿到清单（id / 类型 / 尺寸 / 缩略图），**文件本体按需回来要**（`galleryFile`）：
  /// 由 [_resolveGalleryFile] 走 `cached_network_image` 同一只缓存下载 —— 那条 HTTP 带应用内代理、
  /// 与 2D 大图页共用磁盘缓存；原生 Coil 两样都没有，只负责解码。
  ///
  /// [thumbPath] 在这里就先查一遍缓存：详情页横向清单刚刚画过这些图，多半已在盘上，
  /// 面板里的胶片就不必再走网络。
  Future<bool> presentGallery({
    required String galleryId,
    required String title,
    String author = '',
    required List<XrGalleryItem> items,
    int index = 0,
    String quality = galleryImageQualityStandard,
  }) async {
    if (items.isEmpty) return false;
    final requestId = _latestRequestId = ++_nextRequestId;
    try {
      // ⛔ 幕布上若正放着视频：它的 ended 会随 presentGallery 补发回来，nowPlayingId 由那条路清。
      final localeTag = slang.LocaleSettings.currentLocale.languageTag;
      _pushedLocaleTag = localeTag;
      final cache = DefaultCacheManager();
      final rows = <Map<String, dynamic>>[];
      for (final item in items) {
        String thumbPath = item.isLocalFile ? item.largeUrl : '';
        if (!item.isVideo && !item.isLocalFile) {
          try {
            final cached = await cache.getFileFromCache(item.thumbUrl);
            thumbPath = cached?.file.path ?? '';
          } catch (_) {}
        }
        rows.add({
          'id': item.id,
          'video': item.isVideo,
          'url': item.isVideo ? item.originalUrl : item.urlFor(quality),
          'thumbUrl': item.thumbUrl,
          'thumbPath': thumbPath,
          'w': item.width,
          'h': item.height,
        });
      }
      if (_closed || requestId != _latestRequestId) return false;
      _presentationEpoch++;
      nowShowingGalleryId = galleryId;
      _galleryItems = items;
      final ok = await _channel.invokeMethod<bool>('presentGallery', {
        'locale': localeTag,
        'galleryId': galleryId,
        'title': title,
        'author': author,
        'index': index,
        'quality': quality,
        'items': rows,
      });
      LogUtils.i(
        '图库已交给空间画廊 id=$galleryId n=${items.length} index=$index delivered=$ok',
        'XrImmersive',
      );
      // 「接着看」立刻推过去：图库详情页的池（来源 / 稍后再看的图库）就是面板里的列表。
      unawaited(pushQueues());
      return ok ?? false;
    } on MissingPluginException {
      nowShowingGalleryId = null;
      return false;
    } catch (e) {
      nowShowingGalleryId = null;
      LogUtils.e('交给空间画廊失败', tag: 'XrImmersive', error: e);
      return false;
    }
  }

  /// 原生要图库里 [id] 这个文件在 [quality] 档下的本地路径：没缓存就下载（带应用内代理）。
  /// 返回空串 = 失败 / 找不到这一项。
  Future<String> _resolveGalleryFile({
    required String id,
    required String quality,
  }) async {
    final item = _galleryItems.firstWhereOrNull((e) => e.id == id);
    if (item == null || id.isEmpty) {
      LogUtils.w('空间画廊要的文件不在清单里 id=$id', 'XrImmersive');
      return '';
    }
    final url = item.urlFor(quality);
    // 本机文件（本地媒体目录）：路径本身就是答案，不进缓存管理器。文件被外部删了就如实报失败。
    if (item.isLocalFile) {
      if (await File(url).exists()) return url;
      LogUtils.w('空间画廊要的本机文件不存在 id=$id', 'XrImmersive');
      return '';
    }
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      return file.path;
    } catch (e) {
      LogUtils.w('空间画廊下载文件失败 id=$id url=$url: $e', 'XrImmersive');
      return '';
    }
  }

  /// 同一条片子的清晰度清单换了新地址：推给原生，正在放的那一档地址变了就接着当前位置换源。
  ///
  /// 两条来路都汇到这里：详情页到期前 5 分钟的定时刷新（与 2D 播放器同一只定时器），
  /// 以及原生播放被服务端拒了之后的 `sourceExpired` 反向请求。不是幕布上正放的那条就不发。
  Future<bool> updateSources({
    required String mediaId,
    required List<XrMediaSource> sources,
    int? requestId,
  }) async {
    final presentation = _playing;
    if (mediaId.isEmpty ||
        sources.isEmpty ||
        presentation?.mediaId != mediaId ||
        (requestId != null && presentation?.requestId != requestId)) {
      return false;
    }
    try {
      final ok = await _channel.invokeMethod<bool>('updateSources', {
        'mediaId': mediaId,
        'requestId': presentation!.requestId,
        'sources': sources.map((e) => e.toChannelMap()).toList(),
      });
      if (ok == true && identical(_playing, presentation)) {
        _lastSources = List.unmodifiable(sources);
        presentation.sources = _lastSources;
      }
      LogUtils.i(
        '刷新后的片源已推给空间播放器 mediaId=$mediaId n=${sources.length} ok=$ok',
        'XrImmersive',
      );
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.e('推送刷新片源失败', tag: 'XrImmersive', error: e);
      return false;
    }
  }

  /// 面板点了下一条、Dart 却打不开那张详情页（跨站切换失败 / 私密 / 已删除 / 网络）：
  /// 让原生收掉换片在途态，把老片放回去并提示，不必等 45s 看门狗。
  Future<bool> abortSwitch({
    required String mediaId,
    String reason = '',
  }) async {
    try {
      return await _channel.invokeMethod<bool>('abortSwitch', {
            'mediaId': mediaId,
            'reason': reason,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.d('通知沉浸空间放弃换片失败: $e', 'XrImmersive');
      return false;
    }
  }

  /// 收起幕布与控制条，把 UI 面板还回来（视频与空间画廊都归它）。
  Future<bool> dismiss() async {
    try {
      _presentationEpoch++;
      _latestRequestId = ++_nextRequestId;
      return await _channel.invokeMethod<bool>('dismiss') ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.d('收起沉浸幕布失败: $e', 'XrImmersive');
      return false;
    }
  }

  /// ⛔ 鱼眼映射到 `flat`：Spatial SDK 的面板形状只有
  /// Quad / Equirect180 / Equirect360 / Cylinder，**没有鱼眼**（官方 API reference
  /// 逐字确认过）。强行按球面放会得到一幅变形画面，不如按平面放还能看，
  /// 并在 UI 上如实提示不支持。
  static String _shapeOf(VrProjection projection) => switch (projection) {
    VrProjection.equirect180 => '180',
    VrProjection.equirect360 => '360',
    VrProjection.flat => 'flat',
    VrProjection.fisheye => 'fisheye',
  };

  static String _stereoOf(VrStereoLayout layout) => switch (layout) {
    VrStereoLayout.sideBySide => 'lr',
    VrStereoLayout.topBottom => 'tb',
    VrStereoLayout.mono => 'none',
  };
}

/// 沉浸播放退出后的页面落点，媒体类型由独立字段决定。
typedef XrPlaybackReturn = ({
  String mediaId,
  String? videoId,
  String? localPath,
  String? localLibraryItemId,
  DownloadTask? localTask,
  List<DownloadTask> localAllQualityTasks,
  PlaybackQueueRef? queueRef,
});

class _XrVideoPresentation {
  _XrVideoPresentation({
    required this.requestId,
    required this.mediaId,
    required this.videoId,
    required this.localLibraryItemId,
    required this.localPath,
    required this.localTask,
    required this.localAllQualityTasks,
    required this.sources,
    required this.queue,
    required this.queues,
    required this.author,
  });

  final int requestId;
  final String mediaId;
  final String? videoId;
  final String? localLibraryItemId;
  final String? localPath;
  final DownloadTask? localTask;
  final List<DownloadTask> localAllQualityTasks;
  List<XrMediaSource> sources;
  final PlaybackQueue? queue;
  final List<PlaybackQueue> queues;
  final User? author;
  bool get anonymous => videoId == null && localLibraryItemId == null;

  PlaybackQueueRef? get queueRef => queue == null
      ? null
      : PlaybackQueueRef(
          queueId: queue!.queueId,
          currentItemId: anonymous ? '' : mediaId,
          companionQueueIds: [
            for (final companion in queues)
              if (companion.queueId != queue!.queueId) companion.queueId,
          ],
        );
}

/// 详情页交给沉浸面板的「接着看」快照。
///
/// [adopt]：沉浸面板从目录里开了一个新池，交给页面按 kind 占槽、挂监听、设为当前池
/// （与抽屉里点播换池同一条路）。
typedef XrQueueSnapshot = ({
  List<PlaybackQueue> queues,
  PlaybackQueue? active,
  String currentItemId,
  User? author,
  void Function(PlaybackQueue queue) adopt,

  /// 这张页面的池是视频池还是图库池：分区与来源目录都只列同类的（一个池不许混装两种）。
  PlaybackMediaType mediaType,
});

/// 按用户偏好挑一档：**精确命中 → 向下最接近的一档 → 都没有就取最低的那档**。
///
/// 例：偏好 540，片子只有原画与 360 → 360；只有原画 → 原画。[sources] 必须按清晰度
/// 从高到低排好（[CommonUtils.sortVideoResolutionsByQuality] 的顺序），这里只按位置找。
XrMediaSource? pickPreferredSource(
  List<XrMediaSource> sources,
  String? preferred,
) {
  if (sources.isEmpty) return null;
  final tag = preferred?.trim().toLowerCase() ?? '';
  if (tag.isEmpty) return sources.first;
  final exact = sources.firstWhereOrNull((s) => s.label.toLowerCase() == tag);
  if (exact != null) return exact;
  final preferredRank = CommonUtils.qualityRank(tag);
  // 列表从高到低：第一个比偏好更低的就是「向下最接近」。
  final lower = sources.firstWhereOrNull(
    (s) => CommonUtils.qualityRank(s.label) > preferredRank,
  );
  return lower ?? sources.last;
}

/// 一档可播的源：清晰度标签 + 地址；[local] 表示是本机下载完成的文件。
class XrMediaSource {
  const XrMediaSource({
    required this.label,
    required this.url,
    this.local = false,
  });

  /// 档位的**身份**：`Source` / `1080` / `540`…… 原样回传 Dart 存
  /// [ConfigKey.DEFAULT_QUALITY_KEY]，原生也靠它在清单里匹配当前档。⛔ 不能本地化。
  final String label;
  final String url;
  final bool local;

  /// 面板上显示的名字。与 2D 播放器底栏同一套映射（[CommonUtils.getQualityDisplayLabel]：
  /// `Source` → 原画 / Source / 原畫 / オリジナル画質，`Preview` → 预览……），
  /// 所以两边看到的是同一个词。
  ///
  /// ⛔ 在这里算而不是让调用点各算一遍：漏一处就是「面板上还写着 Source」
  /// （用户 2026-09-05 报的就是这个）。
  Map<String, dynamic> toChannelMap() => {
    'label': label,
    'displayLabel': CommonUtils.getQualityDisplayLabel(slang.t, label),
    'url': url,
    'local': local,
  };
}

/// 空间画廊里的一项：图库的一个文件。
///
/// [largeUrl] 是服务端缩放过的「标准」档、[originalUrl] 是原文件；视频与 gif 没有缩放版，
/// 两个地址相同（见 `MediaFile.getLargeImageUrl` 的回落规则）。[thumbUrl] 给面板里的胶片用，
/// 就取标准档 —— 详情页横向清单画的正是它，多半已在缓存里。
class XrGalleryItem {
  const XrGalleryItem({
    required this.id,
    required this.isVideo,
    required this.largeUrl,
    required this.originalUrl,
    this.width = 0,
    this.height = 0,
  });

  final String id;
  final bool isVideo;
  final String largeUrl;
  final String originalUrl;
  final int width;
  final int height;

  String get thumbUrl => largeUrl;

  /// 本机文件：[largeUrl] / [originalUrl] 是绝对路径而不是网址（本地媒体目录进空间画廊）。
  bool get isLocalFile =>
      !largeUrl.startsWith('http://') && !largeUrl.startsWith('https://');

  /// [quality] 是 `galleryImageQualityStandard` / `galleryImageQualityOriginal`。
  String urlFor(String quality) =>
      quality == galleryImageQualityOriginal ? originalUrl : largeUrl;
}
