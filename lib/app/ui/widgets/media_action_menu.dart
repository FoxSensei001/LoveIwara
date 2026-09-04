// 卡片上那枚三点钮弹出的**媒体操作菜单**。
//
// # 它和预览弹窗的分工
//
// 2026-08-29 那次收口把长按 / 右键 / 三点钮**全部**指向了本菜单，同时删掉了
// 只能看不能动手的 `VideoPreviewDetailModal`。现在重新分家，但分法变了：
//
//   - **长按 / 右键 → 预览弹窗**（`media_preview_dialog.dart`）："我想凑近
//     看一眼"。
//   - **三点钮 → 本菜单**："我想对它做点什么"。
//
// 两边不是并列的两套能力：菜单第一条就是「预览」（[_MediaAction.preview]），
// 预览弹窗的动作行里也挂着「更多」直接吐出本菜单——任一入口都够得到另一边。
//
// # ⛔ 开菜单之前一次网络请求都不等
//
// 液态档的菜单面板尺寸是开菜单那一刻**钉死**的（`_measureMenuPanelSize` 的
// 结果直接喂给 `GlassSurface`），而且"出入场全程尺寸不变"是那套卷开动画的
// 前提。所以任何状态都**不许改行的尺寸**。
//
// 开菜单前只查本地三项（稍后再看 / 本地收藏 / 已下载，都是本地库查询，毫秒
// 级），点下去立刻就有菜单。"已加入 N 个播放列表"要打一次 `/light/playlists`，
// **为它等是不行的**——那意味着点了三点钮之后先看一两秒转圈，用户明确否掉过。
//
// 所以那一项走「后到」这条路（`GlassMenuOption.live`）：菜单照常立刻开，请求
// 同时发出去，那一行的行尾先转个圈，回来了再原地换成状态色 + 尾注。**转圈
// 期间那一行照常能点**——它只是还不知道自己在几个列表里，不是不能用。尺寸
// 靠 `liveTrailingReserve` 在量宽时按最坏情况顶住，全程不变。
//
// 顺带把拉回来的列表交给对话框（`initialPlaylists`），点进去不用再拉一次
// ——同一份数据，服务端只打一次。
//
// # ⛔ 卡片上不放状态角标
//
// 瀑布流一屏 20 张卡片，每张都要查一遍状态不可接受。状态只在用户主动打开
// 菜单时、只为这一条查。
//
// # 需要加载的动作在**菜单自己那一行**转圈
//
// 「下载」点下去还得先拉一次视频源（列表数据里没有）。菜单不立刻关：那一行的
// 图标换成同尺寸的转圈（`GlassMenuOption.prepare`），拉完再关面板进清晰度选择。
// 尺寸全程不变，所以不违反上面那条。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/light_play_list.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/ui/pages/download/media_download_launcher.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/add_video_to_playlist_dialog.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/share_video_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/share_gallery_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/add_to_favorite_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 打开菜单前解析出来的一份状态快照。
@immutable
class MediaActionStatus {
  const MediaActionStatus({
    this.inWatchLater = false,
    this.favoriteFolderCount = 0,
    this.hasDownloadTask = false,
    this.liked = false,
  });

  final bool inWatchLater;
  final int favoriteFolderCount;
  final bool hasDownloadTask;
  final bool liked;
}

/// 把一条媒体的各项状态查出来。
///
/// ⛔ 全是本地库查询，**不许在这里加网络请求**：菜单要点开就有，见文件头。
Future<MediaActionStatus> resolveMediaActionStatus({
  Video? video,
  ImageModel? gallery,
  bool? likedOverride,
}) async {
  final String id = video?.id ?? gallery?.id ?? '';
  if (id.isEmpty) return const MediaActionStatus();

  final type = video != null
      ? WatchLaterItemType.video
      : WatchLaterItemType.image;

  bool inWatchLater = false;
  try {
    inWatchLater = WatchLaterService.to.contains(id, type);
  } catch (e) {
    LogUtils.w('查询稍后再看状态失败: $e', 'MediaActionMenu');
  }

  int favoriteFolderCount = 0;
  try {
    favoriteFolderCount = (await FavoriteService.to.getItemFolders(id)).length;
  } catch (e) {
    LogUtils.w('查询本地收藏状态失败: $e', 'MediaActionMenu');
  }

  bool hasDownloadTask = false;
  try {
    hasDownloadTask = video != null
        ? await DownloadService.to.hasAnyVideoDownloadTask(id)
        : await DownloadService.to.hasAnyGalleryDownloadTask(id);
  } catch (e) {
    LogUtils.w('查询下载任务状态失败: $e', 'MediaActionMenu');
  }

  return MediaActionStatus(
    inWatchLater: inWatchLater,
    favoriteFolderCount: favoriteFolderCount,
    hasDownloadTask: hasDownloadTask,
    liked: likedOverride ?? video?.liked ?? gallery?.liked ?? false,
  );
}

/// 「已加入几个播放列表」那次请求的生命周期看护。
///
/// 请求活得比菜单久是常态（用户扫一眼就把菜单关了）。所以这只通知器**不由菜单
/// 直接回收**：谁最后走谁关灯——菜单先关就把灯留着等请求回来自己关，请求先回来
/// 就照常推值、由菜单关。少了这一步，请求回来时往已 dispose 的 `ValueNotifier`
/// 上推值会在 debug 下直接炸断言。
class _LiveStatusHandle {
  _LiveStatusHandle(this.notifier);

  final ValueNotifier<GlassMenuLiveState> notifier;
  bool _pending = true;
  bool _closed = false;

  /// 查回来了。
  void settle(GlassMenuLiveState state) {
    _pending = false;
    if (_closed) {
      notifier.dispose();
      return;
    }
    notifier.value = state;
  }

  /// 菜单关了。
  void close() {
    _closed = true;
    if (!_pending) notifier.dispose();
  }
}

enum _MediaAction {
  preview,
  download,
  watchLater,
  playlist,
  favorite,
  share,
  toggleLike,
  viewAuthor,
}

/// 弹出菜单并执行选中的动作。
///
/// [status] 由 [resolveMediaActionStatus] 预先查好；不传就在这里现查（全是本地
/// 库查询，毫秒级，不需要调用方给等待反馈）。
///
/// [onLikeChanged] 让卡片把点赞态同步过去（列表与详情页的点赞是联动的）。
/// [onChanged] 在任何写操作之后回调，供卡片刷新自己。
///
/// [globalPosition]：手指 / 光标的落点（全局坐标）。**触发件是大面积区域时必须
/// 传**——菜单默认贴着 [anchorContext] 那只控件的边缘弹，对一枚 40px 的三点钮
/// 正好，对一整张卡片就成了「在半个屏幕以外弹出来」。传了它菜单就从落点撑开
/// （见 [showGlassMenu] 的 globalAnchor），顺带也让「离手指最近的一条优先」这
/// 条规矩（`priorityNearAnchor`）量的是真手指而不是卡片边缘。
Future<void> showMediaActionMenu({
  required BuildContext anchorContext,
  Video? video,
  ImageModel? gallery,
  MediaActionStatus? status,
  Offset? globalPosition,

  /// 卡片自己维护的点赞态。卡片点过赞之后不一定重建，`video.liked` 会是旧值。
  bool? likedOverride,
  ValueChanged<bool>? onLikeChanged,
  VoidCallback? onChanged,

  /// 打开预览弹窗。给了它菜单里才有「预览」那一条——预览弹窗自己吐出本菜单时
  /// 不传，免得在自己身上打转。
  VoidCallback? onPreview,
}) async {
  assert(
    (video == null) != (gallery == null),
    'showMediaActionMenu 一次只处理一条媒体：video 与 gallery 二选一',
  );

  final t = slang.Translations.of(anchorContext);
  final cs = Theme.of(anchorContext).colorScheme;
  final resolved =
      status ??
      await resolveMediaActionStatus(
        video: video,
        gallery: gallery,
        likedOverride: likedOverride,
      );
  if (!anchorContext.mounted) return;

  final accent = cs.primary;

  // ⛔ 这份顺序是**优先级从高到低**，不是屏幕上从上到下的顺序：菜单朝上弹时
  // 整列会倒过来，让最常用的那条永远贴着三点钮（`priorityNearAnchor`）。
  // 顺序由用户拍板：稍后再看 → 下载 → 播放列表 → 本地收藏 → 点赞 → 作者主页
  // → 分享。也因此这里**不能有分隔线**（倒过来会归属错位，那边有 assert）。
  //
  // 「预览」排在最前：它是这一列里唯一「只是看看、什么都不改」的一条，代价最
  // 低、最常被随手点，贴着手指最合适。
  //
  // 「下载」拉到的源存在这里，菜单关掉之后直接交给 launcher，失败路径上也不会
  // 白打第二次请求（见 [prepareVideoDownloadSources]）。
  List<VideoSource>? preparedSources;
  ImageModel? preparedGallery;

  // 「已加入几个播放列表」是这张菜单里唯一要打网络请求的一项。菜单**不为它等**
  // （见文件头）：请求这就发出去，那一行的行尾先转圈，回来了自己换状态。
  //
  // 未登录不发：那一行点下去只会弹登录提示，为一次注定没有结果的查询打请求没
  // 有意义（与「下载」那一行同一条规矩）。
  _LiveStatusHandle? playlistLive;
  List<LightPlaylistModel>? preparedPlaylists;
  if (video != null && Get.find<UserService>().isAuthenticated) {
    final handle = _LiveStatusHandle(
      ValueNotifier(const GlassMenuLiveState(loading: true)),
    );
    playlistLive = handle;
    unawaited(
      Get.find<PlayListService>().getLightPlaylists(videoId: video.id).then((
        result,
      ) {
        if (!result.isSuccess || result.data == null) {
          // 查不到就当没查过：那一行退回中性态，照常能点开对话框——对话框自己
          // 会重拉一次，也只有它说得清错在哪。
          handle.settle(const GlassMenuLiveState());
          return;
        }
        preparedPlaylists = result.data;
        final int count = result.data!.where((p) => p.added).length;
        handle.settle(
          GlassMenuLiveState(
            icon: count > 0 ? Icons.playlist_add_check : null,
            accentColor: count > 0 ? accent : null,
            trailing: count > 0 ? t.mediaMenu.inPlaylists(count: count) : null,
          ),
        );
      }),
    );
  }

  final entries = <GlassMenuEntry>[
    if (onPreview != null)
      GlassMenuOption<_MediaAction>(
        value: _MediaAction.preview,
        label: t.mediaPreview.preview,
        icon: Icons.zoom_out_map,
      ),
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.watchLater,
      label: resolved.inWatchLater
          ? t.watchLater.removeFromWatchLater
          : t.watchLater.addToWatchLater,
      icon: resolved.inWatchLater
          ? Icons.watch_later
          : Icons.watch_later_outlined,
      accentColor: resolved.inWatchLater ? accent : null,
    ),
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.download,
      label: t.common.download,
      icon: Icons.download_outlined,
      accentColor: resolved.hasDownloadTask ? accent : null,
      trailing: resolved.hasDownloadTask ? t.mediaMenu.downloaded : null,
      // 点下去先在这一行转圈把源/文件清单拉回来，再关面板进选择弹窗。
      // 未登录时不拉：让 launcher 去弹登录提示，别为一次注定失败的下载打请求。
      prepare: () async {
        if (!Get.find<UserService>().isAuthenticated) return true;
        if (video != null) {
          preparedSources = await prepareVideoDownloadSources(video);
        } else {
          preparedGallery = await prepareGalleryDownloadFiles(gallery!);
        }
        return true;
      },
    ),
    // 播放列表接口只吃视频，图库加不进去——这一项对图库**不显示**而不是灰掉：
    // 它不是临时不可用，是对图库永远不存在。
    if (video != null)
      GlassMenuOption<_MediaAction>(
        value: _MediaAction.playlist,
        label: t.common.playList,
        // 中性图标：状态是后到的（见下面的 live），在它到之前我们确实不知道这条
        // 视频加没加过。playlist_add 那个「+」读起来是"这个还没加"，是在表态。
        icon: Icons.playlist_play,
        live: playlistLive?.notifier,
        // 量宽用的最坏情况。两位数够用——「同一条视频加进 100 个播放列表」不是
        // 会发生的事，真发生了也只是这行尾注被截成省略号。
        liveTrailingReserve: playlistLive == null
            ? null
            : t.mediaMenu.inPlaylists(count: 88),
      ),
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.favorite,
      label: t.favorite.localizeFavorite,
      icon: resolved.favoriteFolderCount > 0
          ? Icons.bookmark
          : Icons.bookmark_border,
      accentColor: resolved.favoriteFolderCount > 0 ? accent : null,
      trailing: resolved.favoriteFolderCount > 0
          ? t.mediaMenu.inFolders(count: resolved.favoriteFolderCount)
          : null,
    ),
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.toggleLike,
      label: resolved.liked ? t.mediaMenu.unlike : t.mediaMenu.like,
      icon: resolved.liked ? Icons.favorite : Icons.favorite_border,
      accentColor: resolved.liked ? accent : null,
    ),
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.viewAuthor,
      label: t.mediaMenu.viewAuthor,
      icon: Icons.person_outline,
    ),
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.share,
      label: t.common.share,
      icon: Icons.share_outlined,
    ),
  ];

  final action = await showGlassMenu<_MediaAction>(
    anchorContext: anchorContext,
    entries: entries,
    // 落点没给（三点钮那条路）时退回贴着控件弹。
    globalAnchor: globalPosition == null ? null : globalPosition & Size.zero,
    priorityNearAnchor: true,
  );
  // 菜单没了，那份后到的状态也就没人看了（请求还在飞的话由它自己收尾）。
  playlistLive?.close();
  if (action == null || !anchorContext.mounted) return;

  switch (action) {
    case _MediaAction.preview:
      onPreview!();
    case _MediaAction.download:
      if (video != null) {
        await launchVideoDownload(
          anchorContext,
          video: video,
          // 源在菜单那一行转圈时就拉好了；没拉到也别再拉一次，直接照常提示。
          sources: preparedSources,
          sourcesAlreadyResolved: true,
          onTaskCreated: onChanged,
        );
      } else {
        await launchGalleryDownload(
          anchorContext,
          gallery: preparedGallery ?? gallery!,
          onTaskCreated: onChanged,
        );
      }
    case _MediaAction.watchLater:
      toggleMediaWatchLater(
        t,
        video: video,
        gallery: gallery,
        currentlyIn: resolved.inWatchLater,
      );
      onChanged?.call();
    case _MediaAction.playlist:
      _openPlaylistDialog(
        anchorContext,
        t,
        video!,
        onChanged,
        // 菜单开着的时候已经拉过一次了，别让服务端再吃一遍。
        initialPlaylists: preparedPlaylists,
      );
    case _MediaAction.favorite:
      _openFavoriteDialog(
        anchorContext,
        video: video,
        gallery: gallery,
        onChanged: onChanged,
      );
    case _MediaAction.share:
      _share(anchorContext, video: video, gallery: gallery);
    case _MediaAction.toggleLike:
      await toggleMediaLike(
        t,
        video: video,
        gallery: gallery,
        currentlyLiked: resolved.liked,
        onLikeChanged: onLikeChanged,
      );
    case _MediaAction.viewAuthor:
      final username = (video?.user?.username ?? gallery?.user?.username ?? '')
          .trim();
      if (username.isEmpty) return;
      NaviService.navigateToAuthorProfilePage(
        username,
        initialUser: video?.user ?? gallery?.user,
      );
  }
}

/// 加入 / 移出「稍后再看」（操作菜单与预览弹窗共用同一份提示与容错）。
void toggleMediaWatchLater(
  slang.Translations t, {
  Video? video,
  ImageModel? gallery,
  required bool currentlyIn,
}) {
  final service = WatchLaterService.to;
  final id = video?.id ?? gallery!.id;
  final type = video != null
      ? WatchLaterItemType.video
      : WatchLaterItemType.image;

  if (currentlyIn) {
    service.remove(id, type);
    showAppToast(
      t.watchLater.removedFromWatchLater,
      type: AppToastType.info,
    );
    return;
  }

  final result = video != null
      ? service.addVideo(video)
      : service.addImageModel(gallery!);

  switch (result) {
    case WatchLaterAddResult.added:
      // toast 上挂一枚「查看列表」——加完之后想去看看是最自然的下一步，
      // 不该逼用户自己去抽屉里翻入口。
      showAppToast(
        t.watchLater.addedToWatchLater,
        type: AppToastType.success,
        actionLabel: t.watchLater.viewWatchLaterList,
        onAction: NaviService.navigateToWatchLaterPage,
      );
    case WatchLaterAddResult.alreadyExists:
      showAppToast(
        t.watchLater.alreadyInWatchLater,
        type: AppToastType.info,
      );
    case WatchLaterAddResult.failed:
      showAppToast(t.watchLater.addFailed, type: AppToastType.error);
  }
}

void _openPlaylistDialog(
  BuildContext context,
  slang.Translations t,
  Video video,
  VoidCallback? onChanged, {
  List<LightPlaylistModel>? initialPlaylists,
}) {
  if (!Get.find<UserService>().isAuthenticated) {
    showAppToast(t.errors.pleaseLoginFirst, type: AppToastType.error);
    LoginService.showLogin();
    return;
  }
  showAppDialog(
    AddVideoToPlayListDialog(
      videoId: video.id,
      initialPlaylists: initialPlaylists,
    ),
  ).then((_) => onChanged?.call());
}

void _openFavoriteDialog(
  BuildContext context, {
  Video? video,
  ImageModel? gallery,
  VoidCallback? onChanged,
}) {
  showAppDialog(
    AddToFavoriteDialog(
      itemId: video?.id ?? gallery!.id,
      onAdd: (folderId) => video != null
          ? FavoriteService.to.addVideoToFolder(video, folderId)
          : FavoriteService.to.addImageToFolder(gallery!, folderId),
    ),
  ).then((_) => onChanged?.call());
}

void _share(BuildContext context, {Video? video, ImageModel? gallery}) {
  showGlassBottomSheet(
    context: context,
    builder: (_) => video != null
        ? ShareVideoBottomSheet(
            videoId: video.id,
            videoTitle: video.title ?? '',
            authorName: video.user?.name ?? '',
            previewUrl: video.thumbnailUrl,
          )
        : ShareGalleryBottomSheet(
            galleryId: gallery!.id,
            galleryTitle: gallery.title,
            authorName: gallery.user?.name ?? '',
            previewUrl: gallery.thumbnailUrl,
          ),
  );
}

/// 点赞 / 取消点赞（操作菜单与预览弹窗共用同一份未登录与失败处理）。
Future<void> toggleMediaLike(
  slang.Translations t, {
  Video? video,
  ImageModel? gallery,
  required bool currentlyLiked,
  ValueChanged<bool>? onLikeChanged,
}) async {
  if (!Get.find<UserService>().isAuthenticated) {
    showAppToast(t.errors.pleaseLoginFirst, type: AppToastType.error);
    LoginService.showLogin();
    return;
  }

  final id = video?.id ?? gallery!.id;
  final bool ok;
  if (video != null) {
    final service = Get.find<VideoService>();
    ok = currentlyLiked
        ? (await service.unlikeVideo(id)).isSuccess
        : (await service.likeVideo(id)).isSuccess;
  } else {
    final service = Get.find<GalleryService>();
    ok = currentlyLiked
        ? (await service.unlikeImage(id)).isSuccess
        : (await service.likeImage(id)).isSuccess;
  }

  if (ok) {
    onLikeChanged?.call(!currentlyLiked);
  } else {
    showAppToast(t.errors.errorOccurred, type: AppToastType.error);
  }
}

/// 卡片右下角那枚三点钮：全站唯一的媒体操作菜单触发件。
///
/// # ⛔ 它刻意**不是**玻璃按钮
///
/// 用户明确要的是"卡片上一枚普通的三点钮，点开之后才是液态玻璃弹窗"。所以这里
/// 只借 [GlassTapArea] 的**手势层**（它没有任何视觉），换来的是长按也能开菜单、
/// 以及「按住 → 划到某一条 → 松手选中」那条接力——纯 `IconButton` 拿不到这些。
/// `opensOverlay: true` 是这条接力的声明位（`glass_style_guard_test` 有零容忍闸门）。
///
/// # ⛔ 按下去**不转圈**
///
/// 这枚钮从头到尾就是三个点。开菜单前只查本地状态（毫秒级），所以没有可等的
/// 东西；曾经这里会先转一两秒圈等"已加入播放列表"那次网络请求，用户明确否掉了
/// （见文件头）。真正需要加载的动作（下载要先拉源）在**菜单自己那一行**转圈。
class MediaActionMenuButton extends StatefulWidget {
  const MediaActionMenuButton({
    super.key,
    this.video,
    this.gallery,
    this.likedOverride,
    this.onLikeChanged,
    this.onChanged,
    this.onPreview,
    this.size = 18,
    this.color,
  });

  final Video? video;
  final ImageModel? gallery;

  /// 卡片自己维护的点赞态（卡片点过赞之后不重建也要正确显示）。
  final bool? likedOverride;

  final ValueChanged<bool>? onLikeChanged;
  final VoidCallback? onChanged;

  /// 打开预览弹窗。给了它菜单里才有「预览」那一条，见 [showMediaActionMenu]。
  final VoidCallback? onPreview;

  final double size;
  final Color? color;

  @override
  State<MediaActionMenuButton> createState() => _MediaActionMenuButtonState();
}

class _MediaActionMenuButtonState extends State<MediaActionMenuButton> {
  /// 纯重入闸门（连点两下别开两张菜单）。**不驱动任何视觉**——见类文档。
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    try {
      final status = await resolveMediaActionStatus(
        video: widget.video,
        gallery: widget.gallery,
        likedOverride: widget.likedOverride,
      );
      if (!mounted) return;
      await showMediaActionMenu(
        anchorContext: context,
        video: widget.video,
        gallery: widget.gallery,
        status: status,
        onLikeChanged: widget.onLikeChanged,
        onChanged: widget.onChanged,
        onPreview: widget.onPreview,
      );
    } finally {
      if (mounted) _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return GlassTapArea(
      onTap: _open,
      onLongPress: _open,
      opensOverlay: true,
      longPressOpensOverlay: true,
      child: Padding(
        // 图标本身只有 18，靠内边距把可点面积撑到 40——卡片上这枚钮紧挨着
        // "打开详情"的大热区，太小会经常点岔。
        padding: const EdgeInsets.all(11),
        child: SizedBox.square(
          dimension: widget.size,
          child: Icon(Icons.more_vert, size: widget.size, color: color),
        ),
      ),
    );
  }
}
