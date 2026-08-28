// 卡片上那枚三点钮（以及右键、长按）弹出的**媒体操作菜单**。
//
// # 为什么三个入口共用一只菜单
//
// 在这之前，卡片的长按与右键指向的是 `VideoPreviewDetailModal`（一张只能看、
// 不能动手的预览弹窗）。现在长按 / 右键 / 三点钮**都指向这里**——"我想对这个
// 东西做点什么"只该有一个答案。预览弹窗已整只移除，它唯一被真正用到的动作
// （跳作者主页）作为一项进了本菜单。
//
// # ⛔ 为什么状态要在开菜单**之前**查完
//
// 液态档的菜单面板尺寸是开菜单那一刻**钉死**的（`_measureMenuPanelSize` 的
// 结果直接喂给 `GlassSurface`），而且"出入场全程尺寸不变"是那套卷开动画的
// 前提。所以**菜单开着的时候没法更新任何一行**，"先转圈再出色"做不到。
//
// 于是改成：先把状态查完再开菜单，调用方在这期间自己显示 loading（三点钮转
// 圈）。本地三项（稍后再看 / 本地收藏 / 已下载）是本地库查询，很快；只有
// "已加入播放列表"要打一次 `/light/playlists`，所以它单独设了
// [_playlistStatusTimeout]——网络慢的时候宁可不带这一项的状态色，也不能让
// 用户点了三点钮之后干等。
//
// # ⛔ 卡片上不放状态角标
//
// 瀑布流一屏 20 张卡片，"已加入播放列表"每张都要打一次请求，不可接受。状态
// 只在用户主动打开菜单时、只为这一条查。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
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
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';


/// 查询「已加入播放列表」的耐心。超过就不带这一项的状态色开菜单。
const Duration _playlistStatusTimeout = Duration(milliseconds: 2000);

/// 打开菜单前解析出来的一份状态快照。
@immutable
class MediaActionStatus {
  const MediaActionStatus({
    this.inWatchLater = false,
    this.favoriteFolderCount = 0,
    this.playlistCount = 0,
    this.playlistUnknown = false,
    this.hasDownloadTask = false,
    this.liked = false,
  });

  final bool inWatchLater;
  final int favoriteFolderCount;

  /// 该视频已被加入的播放列表数。
  final int playlistCount;

  /// 没查出来（未登录 / 超时 / 请求失败）。此时这一项不上状态色，
  /// 而不是谎报"没加入过"。
  final bool playlistUnknown;

  final bool hasDownloadTask;
  final bool liked;
}

/// 把一条媒体的各项状态查出来。调用方应在等待期间显示 loading。
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

  // 只有视频有播放列表，且只有登录后查得到。
  int playlistCount = 0;
  bool playlistUnknown = true;
  if (video != null && Get.find<UserService>().isAuthenticated) {
    try {
      final result = await Get.find<PlayListService>()
          .getLightPlaylists(videoId: id)
          .timeout(_playlistStatusTimeout);
      if (result.isSuccess && result.data != null) {
        playlistCount = result.data!.where((p) => p.added == true).length;
        playlistUnknown = false;
      }
    } catch (e) {
      // 超时/失败都走这里：不上状态色，但菜单照开。
      LogUtils.w('查询播放列表状态失败或超时: $e', 'MediaActionMenu');
    }
  }

  return MediaActionStatus(
    inWatchLater: inWatchLater,
    favoriteFolderCount: favoriteFolderCount,
    playlistCount: playlistCount,
    playlistUnknown: playlistUnknown,
    hasDownloadTask: hasDownloadTask,
    liked: likedOverride ?? video?.liked ?? gallery?.liked ?? false,
  );
}

enum _MediaAction {
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
/// [status] 由 [resolveMediaActionStatus] 预先查好。
///
/// ⚠️ 不传的话这里会现查，而"已加入播放列表"要打一次网络请求（带 2 秒超时）——
/// **调用方必须自己给出等待反馈**，否则长按/右键之后画面会静静地冻上一两秒。
/// 卡片上的三点钮走 [MediaActionMenuButton]，那套已经带转圈了；长按/右键请复用
/// 同一条路（见各卡片的 `_openActionMenu`）。
/// [onLikeChanged] 让卡片把点赞态同步过去（列表与详情页的点赞是联动的）。
/// [onChanged] 在任何写操作之后回调，供卡片刷新自己。
Future<void> showMediaActionMenu({
  required BuildContext anchorContext,
  Video? video,
  ImageModel? gallery,
  MediaActionStatus? status,
  /// 卡片自己维护的点赞态。卡片点过赞之后不一定重建，`video.liked` 会是旧值。
  bool? likedOverride,
  ValueChanged<bool>? onLikeChanged,
  VoidCallback? onChanged,
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

  final entries = <GlassMenuEntry>[
    GlassMenuOption<_MediaAction>(
      value: _MediaAction.download,
      label: t.common.download,
      icon: Icons.download_outlined,
      accentColor: resolved.hasDownloadTask ? accent : null,
      trailing: resolved.hasDownloadTask ? t.mediaMenu.downloaded : null,
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
    // 播放列表接口只吃视频，图库加不进去——这一项对图库**不显示**而不是灰掉：
    // 它不是临时不可用，是对图库永远不存在。
    if (video != null)
      GlassMenuOption<_MediaAction>(
        value: _MediaAction.playlist,
        label: t.common.playList,
        // 查不出来（未登录 / 超时 / 请求失败）时用中性图标，**不谎报"没加入过"**：
        // playlist_add 那个"+"读起来就是"这个还没加"，而我们其实不知道。
        icon: resolved.playlistUnknown
            ? Icons.playlist_play
            : (resolved.playlistCount > 0
                  ? Icons.playlist_add_check
                  : Icons.playlist_add),
        accentColor: resolved.playlistCount > 0 ? accent : null,
        trailing: resolved.playlistCount > 0
            ? t.mediaMenu.inPlaylists(count: resolved.playlistCount)
            : null,
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
      value: _MediaAction.share,
      label: t.common.share,
      icon: Icons.share_outlined,
    ),
    const GlassMenuSeparator(),
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
  ];

  final action = await showGlassMenu<_MediaAction>(
    anchorContext: anchorContext,
    entries: entries,
  );
  if (action == null || !anchorContext.mounted) return;

  switch (action) {
    case _MediaAction.download:
      if (video != null) {
        await launchVideoDownload(
          anchorContext,
          video: video,
          onTaskCreated: onChanged,
        );
      } else {
        await launchGalleryDownload(
          anchorContext,
          gallery: gallery!,
          onTaskCreated: onChanged,
        );
      }
    case _MediaAction.watchLater:
      _toggleWatchLater(
        t,
        video: video,
        gallery: gallery,
        currentlyIn: resolved.inWatchLater,
      );
      onChanged?.call();
    case _MediaAction.playlist:
      _openPlaylistDialog(anchorContext, t, video!, onChanged);
    case _MediaAction.favorite:
      _openFavoriteDialog(anchorContext, video: video, gallery: gallery,
          onChanged: onChanged);
    case _MediaAction.share:
      _share(anchorContext, video: video, gallery: gallery);
    case _MediaAction.toggleLike:
      await _toggleLike(
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

void _toggleWatchLater(
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
    showGlassToast(
      t.watchLater.removedFromWatchLater,
      type: GlassToastType.info,
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
      showGlassToast(
        t.watchLater.addedToWatchLater,
        type: GlassToastType.success,
        actionLabel: t.watchLater.viewWatchLaterList,
        onAction: NaviService.navigateToWatchLaterPage,
      );
    case WatchLaterAddResult.alreadyExists:
      showGlassToast(
        t.watchLater.alreadyInWatchLater,
        type: GlassToastType.info,
      );
    case WatchLaterAddResult.failed:
      showGlassToast(t.watchLater.addFailed, type: GlassToastType.error);
  }
}

void _openPlaylistDialog(
  BuildContext context,
  slang.Translations t,
  Video video,
  VoidCallback? onChanged,
) {
  if (!Get.find<UserService>().isAuthenticated) {
    showGlassToast(t.errors.pleaseLoginFirst, type: GlassToastType.error);
    LoginService.showLogin();
    return;
  }
  showAppDialog(
    AddVideoToPlayListDialog(videoId: video.id),
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

Future<void> _toggleLike(
  slang.Translations t, {
  Video? video,
  ImageModel? gallery,
  required bool currentlyLiked,
  ValueChanged<bool>? onLikeChanged,
}) async {
  if (!Get.find<UserService>().isAuthenticated) {
    showGlassToast(t.errors.pleaseLoginFirst, type: GlassToastType.error);
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
    showGlassToast(t.errors.errorOccurred, type: GlassToastType.error);
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
/// # 为什么按下去会先转一圈
///
/// 菜单的行在开出来之后就没法再改了（见文件头），所以状态必须先查完再开。
/// 本地三项很快，只有"已加入播放列表"要打一次网络请求——转圈就是在等它，
/// 超时也会照常开菜单，只是那一项不带状态色。
class MediaActionMenuButton extends StatefulWidget {
  const MediaActionMenuButton({
    super.key,
    this.video,
    this.gallery,
    this.likedOverride,
    this.onLikeChanged,
    this.onChanged,
    this.size = 18,
    this.color,
    this.busy = false,
  });

  final Video? video;
  final ImageModel? gallery;

  /// 卡片自己维护的点赞态（卡片点过赞之后不重建也要正确显示）。
  final bool? likedOverride;

  final ValueChanged<bool>? onLikeChanged;
  final VoidCallback? onChanged;
  final double size;
  final Color? color;

  /// 由卡片外部驱动的忙碌态。
  ///
  /// 长按 / 右键走的是卡片自己的 `_openActionMenu`，不经过这枚钮，但状态解析
  /// 同样要等一次网络请求。把忙碌态引到这里，用户至少能在卡片上看见"它在转"，
  /// 而不是长按之后画面静静地冻一两秒。
  final bool busy;

  @override
  State<MediaActionMenuButton> createState() => _MediaActionMenuButtonState();
}

class _MediaActionMenuButtonState extends State<MediaActionMenuButton> {
  bool _resolving = false;

  Future<void> _open() async {
    if (_resolving) return;
    setState(() => _resolving = true);
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
      );
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final busy = _resolving || widget.busy;
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
          child: busy
              ? Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(Icons.more_vert, size: widget.size, color: color),
        ),
      ),
    );
  }
}
