import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/services/playback_queue_navigator.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/xr_playlist_source.dart';
import 'package:i_iwara/app/services/xr_queue_catalog.dart';
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
  static const MethodChannel _channel = MethodChannel('i_iwara/immersive');

  /// 供 UI 直接 Obx 的可用性。⚠️ 它是**缓存值**，进入播放器时刷一次即可 ——
  /// 沉浸场景的生死只会随「进/出沉浸空间」变化，不会在页面停留期间反复抖动。
  final RxBool available = false.obs;

  /// 幕布上正在放的那条视频的 id（沉浸态自己换过片之后也会更新）。
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
  void Function(String videoId, int positionMs)? onImmersiveEnded;

  /// [onImmersiveEnded] 挂着的那张页面的视频 id；ended 只在 id 对得上时才交给它。
  String? onImmersiveEndedVideoId;

  /// 原生播放器被服务端拒了（直链 `expires` 到期，Iwara 回 404）时的落点：当前活着的视频页
  /// 控制器挂在这里，收到后立刻重取一份清晰度清单并 [updateSources] 推回去。
  /// 只在 [videoId] 与页面这条对得上时才调（详情页自己判）。
  void Function(String videoId)? onSourceRefreshRequested;

  /// Quest 上打开视频是否自动交给空间播放器（设置项，默认开）。
  bool get autoEnterEnabled =>
      Get.find<ConfigService>()[ConfigKey.XR_AUTO_ENTER_IMMERSIVE_KEY] == true;

  /// 当前活着的视频详情页把它的「接着看」视频池交在这里；沉浸面板的播放列表就是这份。
  ///
  /// 没有页面挂着时退回「稍后再看」（[XrPlaylistSource.fallbackSections]）。
  XrQueueSnapshot Function()? queueProvider;

  /// 「接着看」的来源目录（与 2D 抽屉同一套两级菜单），见 [XrQueueCatalog]。
  late final XrQueueCatalog _catalog = XrQueueCatalog(
    onChanged: () => unawaited(pushQueues()),
  );

  /// 已下载完成的视频 id；每次推列表前刷一次（一条 SQL），给卡片打「已下载」角标。
  Set<String> _downloadedIds = const <String>{};

  @override
  void onInit() {
    super.onInit();
    // ⛔ 无条件挂：standard 变体没注册这条通道，原生侧永远不会回调过来，
    // 挂一个处理器不会有任何副作用。调用点因此不需要 `if (isQuest)`。
    _channel.setMethodCallHandler(_onNativeCall);
    // 启动时就问一次：第一张详情页在 onInit 里要靠这个缓存值决定「进页面起不起播」。
    unawaited(refreshAvailability());
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
        unawaited(updateSources(videoId: playing, sources: _lastSources));
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
        return true;
      case 'openQueue':
        final args = call.arguments as Map?;
        return await openQueueForImmersive((args?['queueId'] as String?) ?? '');
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
      case 'loadMore':
        final args = call.arguments as Map?;
        return await loadMoreInQueue((args?['queueId'] as String?) ?? '');
      case 'playItem':
        final args = call.arguments as Map?;
        return await playQueueItem(
          queueId: (args?['queueId'] as String?) ?? '',
          videoId: (args?['id'] as String?) ?? '',
        );
      case 'immersiveEnded':
        final args = call.arguments as Map?;
        final id = (args?['videoId'] as String?)?.trim() ?? '';
        final positionMs = (args?['positionMs'] as num?)?.toInt() ?? 0;
        final durationMs = (args?['durationMs'] as num?)?.toInt() ?? 0;
        await _handleImmersiveEnded(id, positionMs, durationMs);
        return true;
      case 'sourceExpired':
        final args = call.arguments as Map?;
        final id = (args?['videoId'] as String?)?.trim() ?? '';
        final handler = onSourceRefreshRequested;
        if (id.isEmpty || handler == null) {
          LogUtils.w('沉浸态报播放地址过期但没人接 videoId=$id', 'XrImmersive');
          return false;
        }
        handler(id);
        return true;
      default:
        return null;
    }
  }

  /// 沉浸播放结束（回应用 / 换片 / 退出场景）：把最后位置交回去。
  ///
  /// 三种情形要分清：
  /// 1. 结束的就是页面上这条 → 交给页面控制器（回写面板播放器 + 观看历史）。
  /// 2. 结束的是**幕布上正放的**那条，而页面已不是它（原生自足换片的兜底路）→ 导航过去，
  ///    让 2D 面板与刚才看的东西对得上。
  /// 3. 结束的是一条**已经被 Dart 换掉的旧片**（`playQueueItem` 走导航换片，新页 present 后
  ///    原生给旧片补发一次 ended）→ **只回写历史，绝不导航**。⛔ 之前这种情形也走了导航：
  ///    在新页之上又 push 了旧片的详情页，那张页没有来源池，「来源」页签随之消失、
  ///    分区跳到稍后再看（用户 2026-09-05 报障）。
  ///
  /// 判据靠 [nowPlayingId]：[present] 在发通道之前就把它写成新片 id，所以旧片的 ended
  /// 到达时它已经不等于旧片。
  Future<void> _handleImmersiveEnded(
    String videoId,
    int positionMs,
    int durationMs,
  ) async {
    if (videoId.isEmpty) return;
    final wasOnScreen = nowPlayingId == videoId;
    if (wasOnScreen) nowPlayingId = null;
    final handler = onImmersiveEnded;
    final pageVideoId = onImmersiveEndedVideoId;
    // 本地播放页没有 iwara id（pageVideoId 为 null）：只在结束的正是幕布上那条时交给它。
    final pageMatches =
        pageVideoId == videoId || (pageVideoId == null && wasOnScreen);
    if (handler != null && pageMatches) {
      handler(videoId, positionMs);
      return;
    }
    await _saveHistory(videoId, positionMs, durationMs);
    if (wasOnScreen) {
      LogUtils.d('沉浸播放结束但页面不是它，导航到 $videoId', 'XrImmersive');
      NaviService.navigateToVideoDetailPage(videoId);
    }
  }

  /// 被换掉的旧片：沉浸端的进度从不经过页面控制器，只能在这一刻回写一次。
  /// 口径与 `MyVideoStateController._disposeAsyncResources` 一致（头尾 5s 内当作没看 / 看完）。
  Future<void> _saveHistory(String videoId, int positionMs, int durationMs) async {
    if (!Get.isRegistered<PlaybackHistoryService>()) return;
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

  /// 把「接着看」推给沉浸面板：详情页交来的视频池按池分区 + 整套来源目录，
  /// 没有页面时退回稍后再看。
  Future<void> pushQueues() async {
    try {
      await _refreshDownloadedIds();
      final snapshot = queueProvider?.call();
      final List<XrPlaylistSection> sections;
      List<XrQueueGroup> groups = const <XrQueueGroup>[];
      String? activeQueueId;
      if (snapshot != null && snapshot.queues.isNotEmpty) {
        sections = XrPlaylistSource.sectionsFromQueues(
          snapshot.queues,
          downloadedIds: _downloadedIds,
        );
        activeQueueId = snapshot.active?.queueId;
        groups = _catalog.build(
          queues: snapshot.queues,
          currentItemId: snapshot.currentItemId,
          author: snapshot.author,
        );
      } else {
        sections = XrPlaylistSource.fallbackSections();
      }
      LogUtils.i(
        '推送接着看 provider=${queueProvider != null} sections=${sections.map((e) => e.queueId).toList()} '
        'active=${activeQueueId ?? sections.firstOrNull?.queueId} groups=${groups.map((g) => g.id).toList()}',
        'XrImmersive',
      );
      await _channel.invokeMethod<void>('setPlaylist', {
        'sections': sections.map((e) => e.toChannelMap()).toList(),
        'groups': groups.map((e) => e.toChannelMap()).toList(),
        'activeQueueId': activeQueueId ?? sections.firstOrNull?.queueId,
        'nowPlayingId': nowPlayingId,
      });
    } on MissingPluginException {
      // standard 变体没这条通道，正常。
    } catch (e) {
      LogUtils.d('推送沉浸播放列表失败: $e', 'XrImmersive');
    }
  }

  Future<void> _refreshDownloadedIds() async {
    if (!Get.isRegistered<DownloadService>()) return;
    try {
      final tasks = await DownloadService.to.repository.getAllTasksByStatus(
        DownloadStatus.completed,
      );
      _downloadedIds = {
        for (final task in tasks)
          if (task.extData?.type == DownloadTaskExtDataType.video)
            VideoDownloadExtData.fromJson(task.extData!.data).id ?? '',
      }..remove('');
    } catch (e) {
      LogUtils.d('读取已下载清单失败: $e', 'XrImmersive');
    }
  }

  /// 沉浸面板点了目录里一个还没开的池：开出来交给详情页收养，装第一页，再整套推回去。
  Future<bool> openQueueForImmersive(String queueId) async {
    if (queueId.isEmpty) return false;
    final snapshot = queueProvider?.call();
    if (snapshot == null) {
      await pushQueues();
      return false;
    }
    final queue = PlaybackQueueService.to.byId(queueId) ?? _catalog.open(queueId);
    if (queue == null) {
      LogUtils.w('沉浸态要开的池不在目录里 queueId=$queueId', 'XrImmersive');
      await pushQueues();
      return false;
    }
    snapshot.adopt(queue);
    if (queue.loaded.isEmpty && queue.hasMore) {
      try {
        await queue.loadMore();
      } catch (e) {
        LogUtils.w('沉浸态开池装第一页失败 queue=$queueId: $e', 'XrImmersive');
      }
    }
    await pushQueues();
    return true;
  }

  /// 沉浸面板里的「接着看」滚到了某个分区的末尾：让那个池翻一页，再整套推回去。
  ///
  /// 这就是应用里列表的无限滚动，只是触发点在原生面板。翻完**整套重推**而不是只推
  /// 增量：面板那边按 id 做 key，整套替换不会丢滚动位置，而且不用再维护一条
  /// 「追加」协议。池不在了 / 已到底就原样推一次，好让面板把加载态收掉。
  Future<bool> loadMoreInQueue(String queueId) async {
    final queue = queueId.isEmpty ? null : PlaybackQueueService.to.byId(queueId);
    if (queue == null || !queue.hasMore) {
      await pushQueues();
      return false;
    }
    final before = queue.loaded.length;
    try {
      await queue.loadMore();
    } catch (e) {
      LogUtils.w('沉浸态翻页失败 queue=$queueId: $e', 'XrImmersive');
    }
    await pushQueues();
    return queue.loaded.length > before;
  }

  /// 沉浸面板里点了某个池的某一条。
  ///
  /// 走 [PlaybackQueueNavigator]：把详情页换成那条视频（用户要求「切换了接着看的视频，
  /// 也要把详情页替换掉」），新页带 `forceAutoPlay` 进来，片源一开就会自己 present 回沉浸空间。
  /// 原生侧在发这条请求前已经把面板的出帧恢复了，所以换页能正常 build。
  /// 池认不出来（稍后再看兜底列表、或池已被淘汰）时退回「直接解析地址」那条老路。
  ///
  /// 详情页手上的其它池随 `companionQueues` 一起带给新页，否则换一次片「来源」就没了
  /// （2026-09-05 报障：换片后重开面板，分区只剩稍后再看）。
  Future<bool> playQueueItem({
    required String queueId,
    required String videoId,
  }) async {
    if (videoId.isEmpty) return false;
    final queue = queueId.isEmpty ? null : PlaybackQueueService.to.byId(queueId);
    final item = queue?.loaded.firstWhereOrNull((e) => e.id == videoId);
    LogUtils.i(
      '沉浸态换片 queue=$queueId found=${queue != null} item=${item != null} '
      'companions=${queueProvider?.call().queues.map((q) => q.queueId).toList()}',
      'XrImmersive',
    );
    if (queue != null && item != null) {
      await PlaybackQueueNavigator.playItem(
        queue: queue,
        item: item,
        skipWatched: false,
        companionQueues: queueProvider?.call().queues ?? const [],
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
    final playable = await XrPlaylistSource.resolve(videoId);
    if (playable == null) {
      LogUtils.w('沉浸态换片失败：解析不出可播地址 videoId=$videoId', 'XrImmersive');
      return false;
    }
    return present(
      url: playable.url,
      format: playable.format,
      title: playable.title,
      videoId: playable.id,
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

  /// 把这个视频交给沉浸空间呈现。
  ///
  /// [format] 直接用播放器已有的 L1 判定结果（`MyVideoStateController.vrFormat`）——
  /// ⛔ 那是「默认档」不是判决，用户在播放器里选过就以用户的为准，这里原样透传即可。
  ///
  /// @return true 表示已投递给场景；false 表示场景没就绪（原生侧会暂存，就绪后补投）。
  ///
  /// [sources] 是这条片子所有可选的清晰度（在线直链 / 本机已下载的文件），[sourceLabel]
  /// 是 [url] 对应的那一档；面板上的「清晰度」钮据此换源，换源在原生侧完成、不回 Dart。
  Future<bool> present({
    required String url,
    required VrSourceFormat format,
    String title = '',
    String? videoId,
    int width = 0,
    int height = 0,
    int positionMs = 0,
    bool fullFrame = false,
    List<XrMediaSource> sources = const <XrMediaSource>[],
    String sourceLabel = '',
  }) async {
    try {
      // ⛔ 先记再发：原生处理新片时会给旧片补发一次 ended，那时这里必须已经是新片 id，
      // 见 [_handleImmersiveEnded] 的判据。
      nowPlayingId = videoId;
      final localeTag = slang.LocaleSettings.currentLocale.languageTag;
      _pushedLocaleTag = localeTag;
      final ok = await _channel.invokeMethod<bool>('present', {
        // 面板的语言随包带一份：面板可能在这次 present 之后才第一次被唤出。
        'locale': localeTag,
        'url': url,
        'title': title,
        'videoId': videoId ?? '',
        'sources': sources.map((e) => e.toChannelMap()).toList(),
        'sourceLabel': sourceLabel,
        'shape': _shapeOf(format.projection),
        'stereo': _stereoOf(format.stereoLayout),
        'fullFrame': fullFrame,
        'w': width,
        'h': height,
        'positionMs': positionMs,
        // ⛔ 鱼眼片源在沉浸态**放不出正确画面**（SDK 没有这个投影），原生侧要靠
        // 这面旗子在控制面板上如实提示并给出「用其他应用打开」，而不是默默按平面播。
        'unsupportedProjection': format.projection == VrProjection.fisheye,
      });
      _lastSources = sources;
      // 幕布一亮就把「接着看」推过去：面板里的播放列表页要能立刻用，
      // 而不是等用户点开那一页时才现拉（那时 Flutter 已经停止出帧了）。
      unawaited(pushQueues());
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.e('交给沉浸空间失败', tag: 'XrImmersive', error: e);
      return false;
    }
  }

  /// 同一条片子的清晰度清单换了新地址：推给原生，正在放的那一档地址变了就接着当前位置换源。
  ///
  /// 两条来路都汇到这里：详情页到期前 5 分钟的定时刷新（与 2D 播放器同一只定时器），
  /// 以及原生播放被服务端拒了之后的 `sourceExpired` 反向请求。不是幕布上正放的那条就不发。
  Future<bool> updateSources({
    required String videoId,
    required List<XrMediaSource> sources,
  }) async {
    if (videoId.isEmpty || sources.isEmpty || nowPlayingId != videoId) {
      return false;
    }
    try {
      final ok = await _channel.invokeMethod<bool>('updateSources', {
        'videoId': videoId,
        'sources': sources.map((e) => e.toChannelMap()).toList(),
      });
      _lastSources = sources;
      LogUtils.i(
        '刷新后的片源已推给空间播放器 videoId=$videoId n=${sources.length} ok=$ok',
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
  Future<bool> abortSwitch({required String videoId, String reason = ''}) async {
    try {
      return await _channel.invokeMethod<bool>('abortSwitch', {
            'videoId': videoId,
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

  /// 收起幕布与控制条，把 UI 面板还回来。
  Future<bool> dismiss() async {
    try {
      nowPlayingId = null;
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
