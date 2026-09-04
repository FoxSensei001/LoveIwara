import 'dart:async';

import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video.model.dart' as video_model;
import 'package:i_iwara/app/models/video_fullscreen_handoff.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/ui/pages/local_video_detail/widgets/local_video_info_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/blurred_thumbnail_background.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/video_info_tab_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/comments_tab_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/related_videos_tab_widget.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart'
    show CommonErrorWidget;
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/enums/media_enums.dart';
import '../comment/controllers/comment_controller.dart';
import 'controllers/related_media_controller.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/playback_queue_navigator.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/playback_queue_drawer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class MyVideoDetailPage extends StatefulWidget {
  final String videoId;
  final Map<String, dynamic>? extData;

  // 本地视频模式参数
  final String? localPath;
  final DownloadTask? localTask;
  final List<DownloadTask>? localAllQualityTasks;
  final InnerPlaylistContext? innerPlaylistContext;
  final bool forceAutoPlay;
  final bool forceEnterFullscreen;
  final video_model.Video? initialVideoInfo;
  final VideoFullscreenHandoff? fullscreenHandoff;

  /// 从上一条续播/抽屉点播过来时带的池引用（只有两个字符串）。
  final PlaybackQueueRef? playbackQueueRef;

  /// 续播时跳不跳过已看完的（由点播时所在的筛选 tab 决定）。
  final bool skipWatchedInQueue;

  const MyVideoDetailPage({
    super.key,
    required this.videoId,
    this.extData = const {},
    this.localPath,
    this.localTask,
    this.localAllQualityTasks,
    this.innerPlaylistContext,
    this.forceAutoPlay = false,
    this.forceEnterFullscreen = false,
    this.initialVideoInfo,
    this.fullscreenHandoff,
    this.playbackQueueRef,
    this.skipWatchedInQueue = false,
  });

  @override
  MyVideoDetailPageState createState() => MyVideoDetailPageState();
}

class MyVideoDetailPageState extends State<MyVideoDetailPage>
    with TickerProviderStateMixin, RouteAware {
  final String uniqueTag = UniqueKey().toString();
  late String videoId;
  final AppService appService = Get.find();

  // 本地视频模式标识
  late bool isLocalMode;

  late MyVideoStateController controller;
  CommentController? commentController;
  RelatedMediasController? relatedVideoController;
  Worker? _forceEnterFullscreenWorker;
  bool _hasTriggeredForcedFullscreen = false;
  bool _initializationFailed = false;
  bool get _hasUsableController =>
      !_initializationFailed && (isLocalMode || videoId.isNotEmpty);

  // Tab控制器
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    videoId = widget.videoId;
    isLocalMode = widget.localPath != null;

    // 初始化Tab控制器（本地模式只有1个tab，在线模式有3个tab）
    tabController = TabController(length: isLocalMode ? 1 : 3, vsync: this);

    if (videoId.isEmpty && !isLocalMode) {
      return;
    }

    // 初始化控制器
    try {
      if (isLocalMode) {
        // 本地视频模式：使用 forLocalVideo 构造函数
        controller = Get.put(
          MyVideoStateController.forLocalVideo(
            localPath: widget.localPath!,
            task: widget.localTask,
            allQualityTasks: widget.localAllQualityTasks,
            // 从「接着看」的下载池换过来的那一条要直接开播、并接手全屏。
            forceAutoPlay: widget.forceAutoPlay,
            fullscreenHandoff: widget.fullscreenHandoff,
          ),
          tag: uniqueTag,
        );
      } else {
        // 在线视频模式：使用普通构造函数
        controller = Get.put(
          MyVideoStateController(
            videoId,
            extData: widget.extData,
            forceAutoPlay: widget.forceAutoPlay,
            initialVideoInfo: widget.initialVideoInfo,
            fullscreenHandoff: widget.fullscreenHandoff,
          ),
          tag: uniqueTag,
        );

        // 只在在线模式下初始化评论和相关视频控制器
        commentController = Get.put(
          CommentController(id: videoId, type: CommentType.video),
          tag: uniqueTag,
        );

        relatedVideoController = Get.put(
          RelatedMediasController(mediaId: videoId, mediaType: MediaType.VIDEO),
          tag: uniqueTag,
        );

      }

      // ⛔ 强制进全屏**两种模式都要**：从「接着看」的下载池连播过来时落的是
      // 本地播放页，只在在线分支里排这一枪的话，全屏连播换到已下载的那一条
      // 就会掉出全屏。
      if (widget.forceEnterFullscreen) {
        _scheduleForcedFullscreenEntry();
      }

      // 视频池：来源 / （续播带过来的）播放列表 / 稍后再看
      _setupPlaybackQueues();

      // RouteAware 订阅在 didChangeDependencies 中完成
    } catch (e) {
      _initializationFailed = true;
      LogUtils.e('初始化控制器失败', tag: 'video_detail_page_v2', error: e);
    }
  }

  void _scheduleForcedFullscreenEntry() {
    void tryEnterFullscreen() {
      if (!mounted || _hasTriggeredForcedFullscreen) {
        return;
      }
      if (controller.isFullscreen.value) {
        _hasTriggeredForcedFullscreen = true;
        return;
      }

      // ⛔ 已经知道这条片子播不了（私密/被删/站外短链/源错误）就别再强推全屏。
      //
      // 推进去只能看到一张错误页，桌面端还会把窗口留在满屏、标题栏和侧边导航
      // 全藏着（2026-08-31 用户报障）。交接过来的那个全屏会话由控制器的
      // `_reconcileAutoFullscreen` 负责交还，这里只管别再把人推回去——不然它前脚
      // 退出、这里后脚又进，两边打架。
      if (controller.isPlaybackBlocked) {
        LogUtils.d(
          'forced fullscreen declined: playback blocked',
          'MyVideoDetailPage',
        );
        _hasTriggeredForcedFullscreen = true;
        return;
      }

      final reusingNativeFullscreen =
          widget.fullscreenHandoff?.nativeFullscreenActive == true;
      if (!reusingNativeFullscreen && !controller.videoPlayerReady.value) {
        return;
      }

      _hasTriggeredForcedFullscreen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(controller.enterFullscreen());
      });
    }

    _forceEnterFullscreenWorker = ever<bool>(
      controller.videoPlayerReady,
      (_) => tryEnterFullscreen(),
    );
    tryEnterFullscreen();
  }

  // ------------------------------------------------------------ 视频池

  /// 本页可用的池。**每层详情页各持一份**——`详情页1 → 作者页 → 详情页2` 时，
  /// 详情页2 的来源池是作者页那份列表，而返回详情页1 时它的池必须还是原来那份。
  /// 用"全局唯一的当前池"会让下游页面把上游的上下文静默篡改掉。
  List<PlaybackQueue> _queues = const <PlaybackQueue>[];
  PlaybackQueue? _activeQueue;

  /// 池里用来定位「当前这一条」的 id。
  ///
  /// ⛔ 在线模式它就是 [videoId]，但**本地模式不是**：本地播放页的路由 id 是
  /// `local_xxx` 那种占位，拿它去池里找自己永远找不到（找不到当前条 =
  /// [PlaybackQueue.itemAfter] 一律返回 null = 推进彻底失效）。真正的媒体 id
  /// 由路由 extra 里的 [PlaybackQueueRef.currentItemId] 带过来。
  String _queueItemId = '';

  /// 「接着看」入口钮要不要在场。
  ///
  /// ⛔ 判据是**手上有没有池**，不是"池里这会儿有没有东西"（与图库详情页对齐）。
  /// 从论坛帖子、通知、深链、搜索单条进来时没有来源池，稍后再看又常常是空的，
  /// 按"有货才显示"来判，入口就整只不出现——而抽屉里的「最爱 / 作者的视频 /
  /// 本地收藏 / 已下载 / 订阅」那几支全都是**进了抽屉才现开**的，用户因此永远
  /// 够不着它们。空池的抽屉本来就说得清楚（"这个池里没有可播的视频"），胶囊还
  /// 能当场换到别的池去。
  ///
  /// 在线模式下稍后再看池一定在场（见 [_setupPlaybackQueues]），所以这条等价于
  /// 「非本地模式」；本地播放页认不出交接过来的池时仍旧整只不出现。
  bool get _hasPlaybackQueue => _queues.isNotEmpty;

  /// 组装本页的池清单。
  ///
  /// ⛔ 「来源」只在**真的有来源**时出现（深链 / 通知 / 搜索单条进来时整只不出现），
  /// 而不是出现一个点了什么都没有的空 tab。
  void _setupPlaybackQueues() {
    final service = PlaybackQueueService.to;
    final queues = <PlaybackQueue>[];

    // 1. 上一条续播/抽屉点播带过来的池（路由 extra 里只有两个字符串）
    final ref = widget.playbackQueueRef;
    PlaybackQueue? handedOver;
    if (ref != null) {
      handedOver = service.byId(ref.queueId);
      if (handedOver != null) queues.add(handedOver);
    }

    // 本地模式下 videoId 是 `local_xxx` 占位，游标只能用 ref 带来的那个。
    _queueItemId = isLocalMode ? (ref?.currentItemId.trim() ?? '') : videoId;

    // ⛔ 本地播放页只认**交接过来的那个池**（从下载列表进来的下载池）。
    // 来源快照与稍后再看都是在线的东西，摆进一个离线播放页里既没上下文
    // 也点不动。池认不出来（App 重启后 ref 失效）就整只不出现。
    if (isLocalMode) {
      if (handedOver == null || _queueItemId.isEmpty) {
        _queues = const <PlaybackQueue>[];
        _activeQueue = null;
        return;
      }
      _queues = queues;
      _activeQueue = handedOver;
      handedOver.addListener(_onActiveQueueChanged);
      controller.onPlaybackCompleted = _advanceInQueue;
      return;
    }

    // 2. 来源池：进详情页之前那个列表。
    //
    // ⭐ 列表页交得出**它自己那份查询**时（热门 / 图库 / 订阅这些接口列表），
    // 来源池是一条能一直翻下去的分页池（[RemoteListPlaybackQueue]），已加载的
    // 条目只当种子；交不出来的（相关推荐、深链）仍旧是那份到底就没了的快照。
    //
    // ⛔ 判重按 **kind**：交接过来的那个可能就是同一条来源线（连播 / 抽屉点播），
    // 只是 id 未必对得上（快照池带 ownerKey、接口池带查询签名）。按 id 比会让
    // 抽屉里排出两条「来源」。
    final sourceContext = widget.innerPlaylistContext;
    if (sourceContext != null &&
        !queues.any((queue) => queue.kind == PlaybackQueueKind.source)) {
      final query = sourceContext.query;
      if (query != null) {
        queues.add(
          service.openRemoteList(query, seed: sourceContext.items),
        );
      } else if (sourceContext.items.isNotEmpty) {
        queues.add(service.openSource(sourceContext, ownerKey: uniqueTag));
      }
    }

    // 3. 稍后再看：只装视频、排除站外，默认「全部」。
    //
    // ⛔ 判重要按 **kind** 而不是 queueId：筛选是池身份的一部分
    // （`watchLater:all` / `watchLater:unwatched` 是两个 id），从稍后再看页的
    // 「未看完」进来时按 id 比会两个都塞进去，抽屉里就排出两条同名 tab
    // ——和 2026-08-29 那次报障一模一样。一种池永远只占一个槽。
    if (!queues.any((queue) => queue.kind == PlaybackQueueKind.watchLater)) {
      queues.add(service.openWatchLater(unwatchedOnly: false));
    }

    _queues = queues;
    _activeQueue = handedOver ?? queues.firstOrNull;
    // ⛔ **本页持有的每个池都要挂上监听**，不能只挂 active 那一个。
    //
    // LRU 只保护"还有人在听"的池（`PlaybackQueueService._evictIfNeeded`）。
    // 只听 active 的话，`_queues` 里另外那两个在别处注册新池时会被淘汰并
    // `dispose()`，而本页仍拿着它们的引用——用户在抽屉里点到那条 tab，
    // `addListener` 就撞上一个已 dispose 的 ChangeNotifier 直接崩。
    //
    // 顺带：池里内容变了（翻页 / 稍后再看被改）也要重算把手要不要在场。
    for (final queue in _queues) {
      queue.addListener(_onActiveQueueChanged);
    }

    // 播完之后接着播池里的下一条。只有「池内续播」开着时才会被调到（判定在
    // controller 里），池到底了就什么都不做——停在最后一条，恢复暂停/重播语义。
    controller.onPlaybackCompleted = _advanceInQueue;
  }

  void _onActiveQueueChanged() {
    if (mounted) setState(() {});
  }

  /// 播放器底栏那枚「下一个」要不要在场。判据见 [PlaybackQueue.canAdvance]。
  bool get _canPlayNextInQueue =>
      _activeQueue?.canAdvance(
        _queueItemId,
        skipWatched: widget.skipWatchedInQueue,
      ) ??
      false;

  /// 手动点「下一个」。
  ///
  /// ⛔ 与自动续播共用 [_advanceInQueue] 那条路，但**不看「池内续播」那个开关**
  /// ——开关管的是"播完要不要自动接上"，用户手动点是一次明确的指令。
  Future<void> _playNextInQueue() async {
    final queue = _activeQueue;
    if (queue == null || !mounted) return;
    final advanced = await _advanceInQueue();
    if (!advanced && mounted) {
      // 到底了就说一声。默默不动会被当成"按钮坏了"。
      showAppToast(
        slang.Translations.of(context).playbackQueue.queueEnded,
        type: AppToastType.info,
      );
    }
  }

  /// 推进到池里的下一条。返回 false = 池到底了（调用方决定要不要提示）。
  Future<bool> _advanceInQueue() async {
    final queue = _activeQueue;
    if (queue == null || !mounted) return false;
    final inFullscreen = controller.isFullscreen.value;
    return PlaybackQueueNavigator.advance(
      queue: queue,
      currentItemId: _queueItemId,
      skipWatched: widget.skipWatchedInQueue,
      forceEnterFullscreen: inFullscreen,
      fullscreenHandoff: inFullscreen
          ? controller.buildFullscreenHandoff()
          : null,
      onRelinquishFullscreen: controller.relinquishFullscreenForRouteHandoff,
      // 补页/翻页要联网，这中间用户按了返回就别再往栈上顶新的详情页了。
      stillWanted: () => mounted,
    );
  }

  Future<void> _openQueueDrawer() async {
    final queues = _queues;
    if (queues.isEmpty || !mounted) return;
    final selection = await showPlaybackQueueDrawer(
      context: context,
      queues: queues,
      initialQueue: _activeQueue ?? queues.first,
      currentItemId: _queueItemId,
      author: controller.videoInfo.value?.user,
    );
    if (selection == null || !mounted) return;
    // ⛔ 只有**真的点播了一条**才换池。光切 tab 逛一圈不算——用户常常只是想
    // 瞄一眼别的池里有什么，静默换池会让下一条突然从别处冒出来。
    // 抽屉里可能换出了新的池实例（切了播放列表 / 切了稍后再看的筛选）——
    // 那些实例本页还没听过，得补上，否则它们同样会被 LRU 淘汰掉。
    //
    // ⛔ **按 kind 顶掉同类的那一个，不能直接 append**：稍后再看的筛选换一档
    // 就是另一个池实例（`watchLater:all` / `watchLater:unwatched`），一路
    // append 下去，抽屉里就会排出两条一模一样的「稍后再看」——同一个池、同一
    // 个名字（2026-08-29 用户报障）。一种池永远只占一个槽。
    if (!_queues.any((queue) => identical(queue, selection.queue))) {
      final merged = [..._queues];
      final slot = merged.indexWhere(
        (queue) => queue.kind == selection.queue.kind,
      );
      if (slot >= 0) {
        // 换下来的那个不再由本页持有：摘掉监听，让 LRU 该淘汰就淘汰。
        merged[slot].removeListener(_onActiveQueueChanged);
        merged[slot] = selection.queue;
      } else {
        merged.add(selection.queue);
      }
      _queues = merged;
      selection.queue.addListener(_onActiveQueueChanged);
    }
    _activeQueue = selection.queue;
    final inFullscreen = controller.isFullscreen.value;
    await PlaybackQueueNavigator.playItem(
      queue: selection.queue,
      item: selection.item,
      skipWatched: selection.skipWatched,
      forceEnterFullscreen: inFullscreen,
      fullscreenHandoff: inFullscreen
          ? controller.buildFullscreenHandoff()
          : null,
      onRelinquishFullscreen: controller.relinquishFullscreenForRouteHandoff,
    );
  }

  InnerPlaylistContext? _resolveInnerPlaylistContext() {
    final context = widget.innerPlaylistContext;
    if (isLocalMode || context == null) {
      return context;
    }

    if (context.source != InnerPlaylistSource.relatedVideosTab) {
      return context;
    }

    // Respect an explicit handoff order from the previous detail page so the
    // "up next" chain can keep consumed items at the tail.
    if (context.items.isNotEmpty) {
      return context.currentVideoId == videoId
          ? context
          : context.copyWith(currentVideoId: videoId);
    }

    final relatedVideos = relatedVideoController?.videos;
    if (relatedVideos == null || relatedVideos.isEmpty) {
      return null;
    }

    return InnerPlaylistContext.fromVideos(
      source: InnerPlaylistSource.relatedVideosTab,
      videos: relatedVideos,
      currentVideoId: videoId,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 订阅路由观察者
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  /// 另一个页面被推入覆盖当前页面时调用（等同于原来的"离开"）
  @override
  void didPushNext() {
    if (!_hasUsableController) return;
    LogUtils.d('didPushNext', 'MyVideoDetailPage');
    // 弹窗/菜单（PopupRoute）覆盖时不自动暂停，避免工具栏弹层打断播放。
    //
    // ⛔ 这道闸门数的是**全局**弹层数，分不清「浮在我上面的抽屉」和「盖住我的
    // 新页面」：「接着看」抽屉开着时，从预览弹窗里跳去别的页面会被它一并挡掉。
    // 那一份收尾由 [PageDepartureGuard] 补（它知道刚 push 的是不是真页面，也正是
    // 它把那些临时层收掉的），两边落到同一个 [onCoveredByAnotherPage]。
    if (OverlayTracker.instance.hasOverlay) {
      LogUtils.d(
        'didPushNext ignored because popup overlay is active',
        'MyVideoDetailPage',
      );
      return;
    }
    controller.onCoveredByAnotherPage();
  }

  /// 从上层页面返回到当前页面时调用（等同于原来的"进入"）
  @override
  void didPopNext() {
    if (!_hasUsableController) return;
    LogUtils.d(
      'didPopNext: keep current playback state on route return',
      'MyVideoDetailPage',
    );
    // 返回到视频详情页，重置屏幕亮度
    ScreenBrightness().resetApplicationScreenBrightness();
    controller.resumeFromCoveredRoute();
    if (controller.isFullscreen.value) {
      appService.hideSystemUI();
    }
  }

  @override
  void dispose() {
    LogUtils.w('dispose start: uniqueTag=$uniqueTag', 'MyVideoDetailPage');
    // _activeQueue 一定在 _queues 里，不用再单独摘一次。
    for (final queue in _queues) {
      queue.removeListener(_onActiveQueueChanged);
    }

    // 应用内全屏（isDesktopAppFullScreen）不会被页面 PopScope 拦截，
    // 因此可能在未退出该模式时直接关闭视频页，残留 showTitleBar/showRailNavi
    // 为隐藏态，导致窗口无法拖动、被锁死在视频分区。这里兜底恢复系统 UI。
    // showSystemUI() 正是进入应用内全屏所用 hideSystemUI(hideTitleBar:false) 的逆操作，
    // 是完整的清理。
    //
    // 系统全屏（isFullscreen）不在此处理：其 PopScope 会拦截返回并先走
    // controller.exitFullscreen()（含 native 退出与窗口几何恢复），且全屏 overlay
    // (MyVideoScreen) 自身 dispose 也会恢复系统 UI；在此只做半截恢复反而会掩盖问题。
    try {
      if (controller.isDesktopAppFullScreen.value) {
        appService.showSystemUI();
      }
    } catch (_) {
      // controller 可能因初始化失败而未赋值（late），忽略即可
    }

    // 销毁Tab控制器
    tabController.dispose();
    _forceEnterFullscreenWorker?.dispose();

    // 取消订阅路由观察者
    routeObserver.unsubscribe(this);

    // 尝试删除controller
    try {
      Get.delete<MyVideoStateController>(tag: uniqueTag);
      Get.delete<CommentController>(tag: uniqueTag);
      Get.delete<RelatedMediasController>(tag: uniqueTag);
    } catch (e) {
      LogUtils.e('销毁视频详情页失败', error: e, tag: 'video_detail_page_v2');
    }

    super.dispose();
  }

  // 计算是否需要分两列
  bool _shouldUseWideScreenLayout(
    double screenHeight,
    double screenWidth,
    double videoRatio,
  ) {
    // 使用有效的视频比例，如果比例小于1，则使用1.7
    final effectiveVideoRatio = videoRatio < 1 ? 1.7 : videoRatio;
    // 视频的高度
    final videoHeight = screenWidth / effectiveVideoRatio;
    // 如果视频高度超过屏幕高度的70%，并且屏幕宽度足够
    return videoHeight > screenHeight * 0.7;
  }

  Widget _buildVideoArea({required Widget player}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        player,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    if (!_hasUsableController) {
      return CommonErrorWidget(
        text: _initializationFailed
            ? t.videoDetail.videoLoadError
            : t.videoDetail.videoIdIsEmpty,
        children: [
          ElevatedButton(
            onPressed: AppService.tryPop,
            child: Text(t.common.back),
          ),
        ],
      );
    }

    // 将 MediaQuery 的值缓存下来，避免重复计算
    final Size screenSize = MediaQuery.sizeOf(context);
    final double paddingTop = MediaQuery.paddingOf(context).top;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Obx(() {
      final fullscreenActive = controller.isFullscreen.value;
      final overlayActive = OverlayTracker.instance.hasOverlay;
      final effectiveInnerPlaylistContext = _resolveInnerPlaylistContext();

      return PopScope(
        // Fullscreen is now handled inside the same page route.
        // When fullscreen is active, back should first exit fullscreen.
        // On Android predictive back, when a dialog (PopupRoute) is visible,
        // allowing the page route to pop can leave the dialog behind.
        // Block page pop while an overlay is present, and delegate to
        // PopCoordinator via AppService.tryPop to close the overlay first.
        canPop: !fullscreenActive && !overlayActive,
        onPopInvokedWithResult: (didPop, result) {
          final overlayActiveNow = OverlayTracker.instance.hasOverlay;
          LogUtils.d(
            'video detail PopScope: didPop=$didPop, '
                'controllerFullscreen=${controller.isFullscreen.value}, '
                'overlayActive=$overlayActiveNow, '
                'routeCurrent=${ModalRoute.of(context)?.isCurrent}',
            'MyVideoDetailPage',
          );

          if (didPop) return;

          if (overlayActiveNow) {
            LogUtils.d(
              'video detail PopScope -> close overlay via AppService.tryPop',
              'MyVideoDetailPage',
            );
            AppService.tryPop(context: context);
            return;
          }

          if (controller.isFullscreen.value) {
            LogUtils.d(
              'video detail PopScope -> exit fullscreen',
              'MyVideoDetailPage',
            );
            unawaited(controller.exitFullscreen());
            return;
          }

          LogUtils.d(
            'video detail PopScope fallback -> AppService.tryPop',
            'MyVideoDetailPage',
          );
          AppService.tryPop(context: context);
        },
        child: Stack(
          children: [
            Scaffold(
              body: RepaintBoundary(
                child: Obx(() {
                  // 添加画中画模式判断
                  if (controller.isPiPMode.value) {
                    // PiP 全程不参与共享 GlobalKey：其生命周期独立于内联槽位/
                    // 形变层/全屏宿主，无条件独立实例可彻底排除与全屏会话状态
                    // 组合出的同帧 Key 重复风险（纹理经同一 videoController
                    // 共享，重建无黑帧）。
                    return _buildPlayerScreen(
                      isFullScreen: false,
                      innerPlaylistContext: effectiveInnerPlaylistContext,
                    );
                  }

                  if (controller.mainErrorWidget.value != null) {
                    return controller.mainErrorWidget.value!;
                  }

                  // 优先处理应用内全屏
                  if (controller.isDesktopAppFullScreen.value) {
                    return _buildPureVideoPlayer(
                      screenHeight,
                      innerPlaylistContext: effectiveInnerPlaylistContext,
                    );
                  }

                  // 判断是否使用宽屏布局
                  bool isWide = _shouldUseWideScreenLayout(
                    screenHeight,
                    screenWidth,
                    controller.aspectRatio.value,
                  );

                  if (isWide) {
                    return _buildWideScreenLayout(
                      context,
                      screenSize,
                      paddingTop,
                      t,
                      effectiveInnerPlaylistContext,
                    );
                  } else {
                    return _buildNarrowScreenLayout(
                      context,
                      screenSize,
                      paddingTop,
                      t,
                      effectiveInnerPlaylistContext,
                    );
                  }
                }),
              ),
            ),
            if (fullscreenActive)
              Positioned.fill(
                child: RestoreRawMediaQueryInsets(
                  child: _buildPlayerScreen(
                    isFullScreen: true,
                    innerPlaylistContext: effectiveInnerPlaylistContext,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // 宽屏布局：播放器在左侧，Tab内容在右侧
  Widget _buildWideScreenLayout(
    BuildContext context,
    Size screenSize,
    double paddingTop,
    slang.Translations t,
    InnerPlaylistContext? innerPlaylistContext,
  ) {
    const double tabsAreaWidth = 350.0; // 固定Tab区域宽度，适当缩窄以优化播放器显示区域

    // 如果是私有视频但没有fileUrl（无访问权限），则不显示内容
    if (controller.videoInfo.value?.private == true &&
        controller.videoInfo.value?.fileUrl == null) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧纯播放器区域（自适应宽度）
        Expanded(
          child: SizedBox.expand(
            child: _buildVideoArea(
              player: Obx(() {
                // 站外、站内视频都显示播放器
                if (controller.videoInfo.value?.isExternalVideo == true ||
                    controller.videoPlayerReady.value) {
                  return _buildPureVideoPlayer(
                    screenSize.height,
                    applyBottomSafeArea: true,
                    innerPlaylistContext: innerPlaylistContext,
                  );
                }
                // 全屏时播放器渲染在全屏叠加层，这里必须让位——否则在
                // 「尚未 ready + 已进全屏」这个窗口里，内嵌与全屏两只
                // MyVideoScreen 会同时挂载，各带一套 Listener 与 FocusScope。
                // 目前靠 Stack 命中测试（叠加层在最上层、命中即停）兜住没出事，
                // 但那是运气不是设计：任何绕过命中测试的输入方案（如全局指针
                // 路由）都会立刻变成双派发。此守卫与 _buildPureVideoPlayer /
                // _buildVideoPlayerContent 两处保持一致。
                if (controller.isFullscreen.value) {
                  return const SizedBox.shrink();
                }
                // 否则显示播放器（包含加载状态）
                return _buildPlayerScreen(
                  isFullScreen: false,
                  enableBottomSafeArea: true,
                  innerPlaylistContext: innerPlaylistContext,
                );
              }),
            ),
          ),
        ),

        // 右侧Tab内容区域（固定宽度）
        SizedBox(
          width: tabsAreaWidth,
          child: _buildTabSection(context, paddingTop, t),
        ),
      ],
    );
  }

  // 窄屏布局：使用 ExtendedNestedScrollView 实现播放器固定效果
  Widget _buildNarrowScreenLayout(
    BuildContext context,
    Size screenSize,
    double paddingTop,
    slang.Translations t,
    InnerPlaylistContext? innerPlaylistContext,
  ) {
    return Obx(() {
      // 使用 Obx 包装整个 ExtendedNestedScrollView，确保相关状态变化时重建。
      // 读取一次以建立 Obx 依赖：播放/暂停切换、竖屏判定（宽高比）变化、以及初始封面
      // 态切换到真正播放（videoPlayerReady 影响 shouldShowInitialPlaybackCover）时，
      // 都需要重算固定头部高度。
      controller.videoPlaying.value;
      controller.aspectRatio.value;
      controller.videoPlayerReady.value;
      return ExtendedNestedScrollView(
        key: controller.nestedScrollViewKey,
        controller: controller.scrollController,
        physics: const NeverScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          // 核心逻辑：
          // - 暂停态：固定头部收缩到工具栏高度，上滑 tabs 可将播放器收起并浮现顶部工具栏。
          // - 播放态（普通/宽比例视频）：返回完整视频高度，头部完全钉住、不可收缩，
          //   保证开始播放即放到最大高度。
          // - 播放态 + 竖屏比例视频：改为返回 minVideoHeight 作为“钉住下限”，从而允许
          //   上滑 tabs 将播放器从最大高度收缩到最小高度，为 tabs 让出更多空间；由于
          //   下限恰为 minVideoHeight，scrollRatio 全程为 0，收缩过程不会出现顶部工具栏
          //   （仍算作播放态）。此收缩仅在“真正播放中”生效——排除初始播放封面态
          //   （关闭自动播放时 videoPlaying 默认仍为 true，此处需显式排除封面），避免尚未
          //   开始播放的封面被上滑收缩。
          if (controller.videoPlaying.value ||
              controller.shouldShowInitialPlaybackCover) {
            if (controller.videoPlaying.value &&
                !controller.shouldShowInitialPlaybackCover &&
                controller.isVerticalVideo) {
              return controller.getMinimumVideoHeight(
                screenSize.width,
                screenSize.height,
              );
            }
            return controller.getCurrentVideoHeight(
              screenSize.width,
              screenSize.height,
              paddingTop,
            );
          } else {
            return kToolbarHeight + paddingTop;
          }
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            Obx(
              () => SliverAppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                primary: false,
                automaticallyImplyLeading: false,
                pinned: true,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
                // 动态 pinned
                expandedHeight: controller.getCurrentVideoHeight(
                  screenSize.width,
                  screenSize.height,
                  paddingTop,
                ),
                flexibleSpace: Stack(
                  children: [
                    // 视频播放器
                    Obx(() {
                      final videoHeight = controller.getCurrentVideoHeight(
                        screenSize.width,
                        screenSize.height,
                        paddingTop,
                      );

                      // 站外、站内视频都显示播放器
                      if (controller.videoInfo.value?.isExternalVideo == true ||
                          controller.videoPlayerReady.value ||
                          controller.shouldShowInitialPlaybackCover) {
                        return SizedBox(
                          width: screenSize.width,
                          height: videoHeight,
                          child: _buildVideoArea(
                            player: _buildVideoPlayerContent(
                              innerPlaylistContext,
                            ),
                          ),
                        );
                      }
                      // 否则显示骨架屏（全屏时同样让位给全屏叠加层，
                      // 理由见 _buildWideScreenLayout 里同款守卫的说明）
                      else if (controller.isFullscreen.value) {
                        return SizedBox(
                          width: screenSize.width,
                          height: videoHeight,
                        );
                      } else {
                        return SizedBox(
                          width: screenSize.width,
                          height: videoHeight,
                          child: _buildVideoArea(
                            player: _buildPlayerScreen(
                              isFullScreen: false,
                              innerPlaylistContext: innerPlaylistContext,
                            ),
                          ),
                        );
                      }
                    }),
                    // 顶部工具栏（根据滚动状态显示）
                    Obx(() => _buildTopToolbarOverlay(context, t)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _buildTabSection(context, 0, t),
      );
    });
  }

  /// 本页**唯一**的播放器构造点（内嵌、宽屏、全屏叠加层、PiP 都走这里）。
  ///
  /// ⛔ 「接着看」把手一度只在全屏出现，根因就是这几处各写各的：全屏与 PiP 那
  /// 两处传了视频池参数，内嵌的四处漏了。池是**页面**的属性，跟播放器是内嵌
  /// 还是全屏毫无关系，所以下发口收成一个——新增播放器时不可能再漏。
  /// 闸门见 `test/playback_queue_entry_guard_test.dart`。
  Widget _buildPlayerScreen({
    required bool isFullScreen,
    bool enableBottomSafeArea = false,
    InnerPlaylistContext? innerPlaylistContext,
  }) {
    return MyVideoScreen(
      myVideoStateController: controller,
      isFullScreen: isFullScreen,
      enableBottomSafeArea: enableBottomSafeArea,
      innerPlaylistContext: innerPlaylistContext,
      hasPlaybackQueue: _hasPlaybackQueue,
      onOpenQueueDrawer: _openQueueDrawer,
      canPlayNextInQueue: _canPlayNextInQueue,
      onPlayNextInQueue: _playNextInQueue,
    );
  }

  // 构建纯播放器（宽屏时使用，占满整个容器）
  Widget _buildPureVideoPlayer(
    double screenHeight, {
    bool applyBottomSafeArea = false,
    InnerPlaylistContext? innerPlaylistContext,
  }) {
    return Container(
      height: screenHeight,
      color: Colors.black,
      child: Obx(() {
        // 如果视频加载出错，显示错误组件
        if (controller.videoErrorMessage.value != null) {
          return _buildVideoErrorWidget(context);
        }
        // 如果是站外视频，显示站外视频提示
        else if (controller.videoInfo.value?.isExternalVideo == true) {
          return _buildExternalVideoWidget(context);
        }
        // 正常显示播放器（全屏时播放器渲染在全屏叠加层，这里渲染黑色占位）
        else if (!controller.isFullscreen.value) {
          return _buildPlayerScreen(
            isFullScreen: false,
            enableBottomSafeArea: applyBottomSafeArea,
            innerPlaylistContext: innerPlaylistContext,
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  // 构建播放器内容
  Widget _buildVideoPlayerContent(InnerPlaylistContext? innerPlaylistContext) {
    return Obx(() {
      // 如果视频加载出错，显示错误组件
      if (controller.videoErrorMessage.value != null) {
        return _buildVideoErrorWidget(context);
      }
      // 如果是站外视频，显示站外视频提示
      else if (controller.videoInfo.value?.isExternalVideo == true) {
        return _buildExternalVideoWidget(context);
      }
      // 正常显示播放器（全屏时播放器渲染在全屏叠加层，这里渲染黑色占位）
      else if (!controller.isFullscreen.value) {
        return _buildPlayerScreen(
          isFullScreen: false,
          innerPlaylistContext: innerPlaylistContext,
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  // 构建视频错误提示
  Widget _buildVideoErrorWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: controller.videoErrorMessage.value == 'resource_404'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.not_interested, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  t.videoDetail.resourceNotFound,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => AppService.tryPop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(t.common.back),
                ),
              ],
            )
          : CommonErrorWidget(
              text:
                  controller.videoErrorMessage.value ??
                  t.videoDetail.videoLoadError,
              children: [
                ElevatedButton.icon(
                  onPressed: () => AppService.tryPop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(t.common.back),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.fetchVideoDetail(controller.videoId ?? ''),
                  icon: const Icon(Icons.refresh),
                  label: Text(t.common.retry),
                ),
              ],
            ),
    );
  }

  // 构建外链视频提示
  Widget _buildExternalVideoWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // 获取视频缩略图URL用于模糊背景
    final thumbnailUrl = controller.videoInfo.value?.thumbnailUrl;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // 模糊背景
          Positioned.fill(
            child: BlurredThumbnailBackground(thumbnailUrl: thumbnailUrl),
          ),
          // 前景内容
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '${t.videoDetail.externalVideo}: ${controller.videoInfo.value?.externalVideoDomain}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 使用 Obx 包裹，根据滚动比例隐藏按钮
                  Obx(() {
                    final isWide = _shouldUseWideScreenLayout(
                      screenHeight,
                      screenWidth,
                      controller.aspectRatio.value,
                    );
                    // 当 header 收缩时（scrollRatio > 0.8），隐藏按钮
                    final isCollapsed =
                        !isWide && controller.scrollRatio.value > 0.8;
                    return AnimatedOpacity(
                      opacity: isCollapsed ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: isCollapsed,
                        child: Row(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => AppService.tryPop(),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(t.common.back),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (controller.videoInfo.value?.embedUrl !=
                                    null) {
                                  launchUrl(
                                    Uri.parse(
                                      controller.videoInfo.value!.embedUrl!,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: Text(t.videoDetail.openInBrowser),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建Tab区域
  Widget _buildTabSection(
    BuildContext context,
    double paddingTop,
    slang.Translations t,
  ) {
    return Column(
      children: [
        Container(height: paddingTop, color: Colors.transparent),

        // 本地模式：直接显示 LocalVideoInfoWidget，不显示 Tab
        if (isLocalMode)
          Expanded(
            child: LocalVideoInfoWidget(
              controller: controller,
              task: widget.localTask,
              allQualityTasks: widget.localAllQualityTasks ?? [],
              localPath: widget.localPath!,
            ),
          )
        else ...[
          // 在线模式：显示 Tab 导航栏和内容
          _buildTabBar(context, t),
          Expanded(child: _buildTabBarView()),
        ],
      ],
    );
  }

  // 构建Tab导航栏
  Widget _buildTabBar(BuildContext context, slang.Translations t) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          // 点击Tab时滚动到顶部
          if (!tabController.indexIsChanging) {
            controller.animateToTop();
          }
        },
        tabs: isLocalMode
            ? [
                // 本地模式：只显示详情tab
                Tab(text: t.common.detail),
              ]
            : [
                // 在线模式：显示所有tab
                Tab(text: t.common.detail),
                Tab(text: t.common.commentList),
                Tab(text: t.videoDetail.relatedVideos),
              ],
      ),
    );
  }

  // 构建Tab内容视图
  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: isLocalMode
          ? [
              // 本地模式：只显示本地视频信息
              LocalVideoInfoWidget(
                controller: controller,
                task: widget.localTask,
                allQualityTasks: widget.localAllQualityTasks ?? [],
                localPath: widget.localPath!,
              ),
            ]
          : [
              // 在线模式：显示所有tab
              VideoInfoTabWidget(controller: controller),
              CommentsTabWidget(
                commentController: commentController!,
                videoController: controller,
              ),
              RelatedVideosTabWidget(
                videoController: controller,
                relatedVideoController: relatedVideoController!,
                outerTabController: tabController,
              ),
            ],
    );
  }

  // 构建顶部工具栏覆盖层
  Widget _buildTopToolbarOverlay(BuildContext context, slang.Translations t) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: controller.scrollRatio.value <= 0,
        child: SizedBox(
          height: kToolbarHeight + MediaQuery.paddingOf(context).top,
          child: Opacity(
            opacity: (controller.scrollRatio.value / 0.8).clamp(0.0, 1.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: AppBar(
                  title: Text(
                    controller.videoInfo.value?.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: IconButton(
                    onPressed: () => AppService.tryPop(context: context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    // 播放/暂停按钮
                    IconButton(
                      onPressed: () {
                        unawaited(controller.togglePlayback());
                        controller.animateToTop();
                      },
                      icon: Icon(
                        controller.videoPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ],
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
