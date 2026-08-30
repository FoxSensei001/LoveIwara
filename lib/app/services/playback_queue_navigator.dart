import 'package:flutter/foundation.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video_fullscreen_handoff.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 「换到池里的下一条」这件事的**唯一出口**。
///
/// 抽屉里点播、播完自动续播，都从这里走。收成一处不是为了省几行——是为了让
/// 换片机制**只有一个地方要改**。
///
/// # ⚠️ 现在用的是 `pushReplacement`，而不是最终要的「原地换片」
///
/// 设计上定的终局是 **④原地换片**：不开新路由，在当前详情页里把视频换掉，
/// 路由栈恒定 1 层、只有一个 libmpv 实例、全程不 dispose 播放器。
///
/// 但那需要给 `MyVideoStateController` 加一条 `switchToVideo(videoId)`：
/// 它的 `videoId` 现在是构造时固定的 `final`（全文件 60 处引用），评论、相关
/// 视频这两个兄弟 controller 又是页面按 `uniqueTag` 各自 `Get.put` 的。这是一次
/// 需要**真机验证**才敢下结论的改动，而这块代码的历史故障恰恰集中在
/// libmpv 的拆建时序上（use-after-free / 光栅线程 Vulkan 崩溃）。所以先在这里
/// 留一个可替换的接缝：
///
/// - **现在**：`pushReplacement` 顶替栈顶。路由栈同样恒定，返回键回到入口列表，
///   连播 15 条也不会叠 15 层路由 / 15 个活着的播放器——自动连播最危险的那条
///   （无声地把内存堆爆）已经堵住了。
/// - **将来**：把 [playItem] 的实现换成 `controller.switchToVideo(...)` 即可，
///   调用点一处都不用动。
///
/// `pushReplacement` 唯一的残余代价是：被顶掉那页的 `dispose` 里那条**异步**的
/// `player.dispose`，会和新页的播放器初始化落在同一个时间窗里。这个窗口今天
/// 就存在（用户返回后立刻点开下一个视频是同一条时序），不是这次新引入的。
class PlaybackQueueNavigator {
  const PlaybackQueueNavigator._();

  /// 播放池里的某一条。
  ///
  /// [queue] 是这一条**所在的池**——它同时成为新的当前池（"你点播哪一条，池就是
  /// 那一条所在的 tab"）。
  static Future<void> playItem({
    required PlaybackQueue queue,
    required InnerPlaylistItemSnapshot item,
    required bool skipWatched,
    bool forceEnterFullscreen = false,
    VideoFullscreenHandoff? fullscreenHandoff,
    VoidCallback? onRelinquishFullscreen,
  }) async {
    final id = item.id.trim();
    if (id.isEmpty) return;

    // ⛔ 站外视频（youtube 一类的 embed）**内置播放器放不了**。自动推进本来就
    // 会跳过它们（见 PlaybackQueue.itemAfter），但抽屉里用户可以手动点到一条。
    // 这时既不能强制自动播、也不能强制进全屏——老实退出全屏，让详情页用它自己
    // 的方式呈现（这是被删掉的 _handleInnerPlaylistSelection 原本做的事）。
    final isExternal = item.isExternalVideo;

    final ref = PlaybackQueueRef(queueId: queue.queueId, currentItemId: id);

    // ⛔ 图库池落在**图库详情页**，不是播放器。池的类型（不是条目的）说了算：
    // 一个池里不许混装两种（见 [PlaybackMediaType]），所以这一问就够了。
    // 全屏 / 自动播 / 本地文件那一整套都与图库无关，整条路各走各的。
    if (queue.mediaType.isGallery) {
      _pushGallery(item: item, ref: ref);
      return;
    }

    // ⛔ 下载池里的条目**用磁盘上的文件播**，不回头去联网拉流（见
    // [PlaybackQueue.localTargetFor]）。文件在池建好之后被删掉是可能的，池会
    // 当场 stat 一遍，答 null 就老实退回在线详情页。
    final local = isExternal ? null : await queue.localTargetFor(id);
    if (local != null) {
      _pushLocal(
        local: local,
        ref: ref,
        skipWatched: skipWatched,
        forceEnterFullscreen: forceEnterFullscreen,
        fullscreenHandoff: fullscreenHandoff,
        onRelinquishFullscreen: onRelinquishFullscreen,
      );
      return;
    }

    // ⛔ 已下载池里的一条**没能用本地文件打开**，只可能是磁盘上那个文件已经不在
    // 了（池只按数据库列条目，从不 stat）。下面照常退回在线详情页——这比开一个
    // 黑屏播放器好——但**不能一声不吭**：用户明明是在「已下载」里点的，页面却以
    // 在线方式打开并联网拉流，不给个说法就只会被当成"离线播放坏了"。
    if (!isExternal && queue.kind == PlaybackQueueKind.downloads) {
      LogUtils.w(
        '已下载池里的 $id 落不到本地文件，退回在线播放',
        'PlaybackQueueNavigator',
      );
      showGlassToast(
        slang.t.download.errors.fileNotFound,
        type: GlassToastType.error,
      );
    }

    final extra = VideoDetailExtra(
      initialVideoInfo: item.sourceVideo,
      forceAutoPlay: !isExternal,
      forceEnterFullscreen: forceEnterFullscreen && !isExternal,
      playbackQueueRef: ref,
      skipWatchedInQueue: skipWatched,
      // ⛔ 全屏交接：没有它，换一条就得等新页 videoPlayerReady 之后才进全屏，
      // 中间会先以非全屏渲染一帧（移动端看着闪一下竖屏）。桌面端更糟——
      // enterFullscreen 会把**当前这个已经是全屏的窗口几何**当成"进全屏前的
      // 尺寸"缓存下来，之后退出全屏再也还原不回原始窗口大小。
      fullscreenHandoff: isExternal ? null : fullscreenHandoff,
    );

    try {
      // 交出全屏所有权要在 push 之前：新页会接手，旧页此时不该再去复原方向。
      if (!isExternal && fullscreenHandoff != null) {
        onRelinquishFullscreen?.call();
      }
      appRouter.pushReplacement('/video_detail/$id', extra: extra);
    } catch (e) {
      LogUtils.e('切换到池内下一条失败', tag: 'PlaybackQueueNavigator', error: e);
      // 兜底：至少别把用户卡在原地
      NaviService.navigateToVideoDetailPage(id);
    }
  }

  /// 图库那条路。
  ///
  /// 同样用 `pushReplacement`：从抽屉里连着看十个图库不该在栈里叠十层——返回键
  /// 要回到最初那个列表，而不是一层层倒着退（与视频那条同一个理由）。
  ///
  /// 快照里有的先带过去（封面 / 标题 / 张数 / 作者），新页开局就能渲染出骨架，
  /// 不必空着等详情请求回来。
  static void _pushGallery({
    required InnerPlaylistItemSnapshot item,
    required PlaybackQueueRef ref,
  }) {
    final extra = GalleryDetailExtra(
      coverUrl: item.thumbnailUrl.isEmpty ? null : item.thumbnailUrl,
      title: item.title.isEmpty ? null : item.title,
      imageCount: item.numImages,
      authorName: item.authorName,
      authorUsername: item.authorUsername,
      playbackQueueRef: ref,
    );
    try {
      appRouter.pushReplacement(
        '/gallery_detail/${ref.currentItemId}',
        extra: extra,
      );
    } catch (e) {
      LogUtils.e('切换到池内下一个图库失败', tag: 'PlaybackQueueNavigator', error: e);
      // 兜底：至少别把用户卡在原地
      NaviService.navigateToGalleryDetailPage(ref.currentItemId);
    }
  }

  /// 本地文件那条路：路由 id 只是个占位（本地模式没有 iwara videoId），池的
  /// 游标靠 [PlaybackQueueRef.currentItemId] 带过去——详情页在本地模式下会用它
  /// 而不是 `videoId` 去池里定位自己。
  static void _pushLocal({
    required LocalPlaybackTarget local,
    required PlaybackQueueRef ref,
    required bool skipWatched,
    required bool forceEnterFullscreen,
    VideoFullscreenHandoff? fullscreenHandoff,
    VoidCallback? onRelinquishFullscreen,
  }) {
    final extra = VideoDetailExtra(
      localPath: local.localPath,
      localTask: local.task,
      localAllQualityTasks: local.allQualityTasks,
      playbackQueueRef: ref,
      skipWatchedInQueue: skipWatched,
      forceAutoPlay: true,
      forceEnterFullscreen: forceEnterFullscreen,
      fullscreenHandoff: fullscreenHandoff,
    );
    try {
      if (fullscreenHandoff != null) onRelinquishFullscreen?.call();
      appRouter.pushReplacement(
        '/video_detail/${localVideoRouteId(ref.currentItemId)}',
        extra: extra,
      );
    } catch (e) {
      LogUtils.e('切换到本地下载的下一条失败', tag: 'PlaybackQueueNavigator', error: e);
    }
  }

  /// 播完之后推进到下一条。返回 false 表示池到底了——调用方应当停在最后一条，
  /// 恢复「暂停 / 重播」的老语义（**不**自动追加相关视频：无限刷和"临时队列"
  /// 的定位相反）。
  /// [stillWanted] 在**所有等待都结束、真要跳转之前**再问一次「这次推进还算数吗」。
  ///
  /// ⛔ 自动续播下面这两步都是要联网的（补页找到当前条、翻到下一页），加起来能
  /// 有好几百毫秒。用户在这个窗口里按了返回，页面已经不在栈顶了，而 [playItem]
  /// 里的 `pushReplacement` 不认这个——它会把详情页顶到用户刚回到的列表页上面。
  /// 调用方传 `() => mounted` 即可。
  static Future<bool> advance({
    required PlaybackQueue queue,
    required String currentItemId,
    required bool skipWatched,
    bool forceEnterFullscreen = false,
    VideoFullscreenHandoff? fullscreenHandoff,
    VoidCallback? onRelinquishFullscreen,
    bool Function()? stillWanted,
  }) async {
    // ⛔ 先把池翻到**装得下当前这条**为止。从「最爱」这类深列表的中段进来时，
    // 池刚建好只有第 0 页，而当前这条可能在第 5 页——找不到自己 itemAfter 就
    // 恒为 null，推进从第一下起就失效。
    if (!queue.contains(currentItemId)) {
      await queue.ensureContains(currentItemId);
    }

    // ⛔ 分页池到了已加载部分的末尾时，itemAfter 返回 null **不代表池到底了**。
    // 不先翻一页的话，一个 40 条的播放列表连播到第 32 条就会停（后 8 条还没拉
    // 进来），而 hasMore 恰恰是区分"到分页边界"和"真到底"的那个信号。
    var attempts = 0;
    while (queue.needsMoreToAdvance(currentItemId, skipWatched: skipWatched) &&
        attempts < 3) {
      attempts++;
      final before = queue.loaded.length;
      await queue.loadMore();
      // 一页都没多出来（到底了 / 请求失败）就别再空转
      if (queue.loaded.length == before) break;
    }

    // 上面两处 await 期间用户可能已经离开这一页了，跳转前再确认一次。
    // 返回 true（当作"推进成功"）而不是 false：不然调用方会弹一句"已经是最后
    // 一条了"的提示，可用户明明只是按了返回。
    if (stillWanted != null && !stillWanted()) {
      LogUtils.d('续播目标页已离开，放弃本次推进', 'PlaybackQueueNavigator');
      return true;
    }

    final next = queue.itemAfter(currentItemId, skipWatched: skipWatched);
    if (next == null) {
      LogUtils.d('视频池已到底，停在最后一条', 'PlaybackQueueNavigator');
      return false;
    }
    await playItem(
      queue: queue,
      item: next,
      skipWatched: skipWatched,
      forceEnterFullscreen: forceEnterFullscreen,
      fullscreenHandoff: fullscreenHandoff,
      onRelinquishFullscreen: onRelinquishFullscreen,
    );
    return true;
  }
}
