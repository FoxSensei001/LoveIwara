import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/services/gallery_video_poster.dart';
import 'package:i_iwara/app/services/xr_immersive_service.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本机文件模块里「点一张图 → 开大图页」的唯一入口。
///
/// **Quest**：沉浸场景活着且「点开图片自动进空间画廊」开着时，这一组图交给空间画廊
/// （与在线图库同一条路，见 `openGalleryImageViewer`），不开 2D 大图页。
///
/// ⛔ 本目录下原先有三份一模一样的拼装（目录页 / 媒体墙 / 已下载图库页），
/// 其中只有一份写了下面那条裸拼约定的理由，另外两份是照抄的——下一个人改其中
/// 一份时很可能「顺手修正」成 `Uri.file`。收口到这里，约定只写一遍。
///
/// [initialPath] 找不到（或为空）时从第一张开。[paths] 为空时提示文件不存在，
/// 不开空相册。
void openLocalImageViewer(
  BuildContext context,
  List<String> paths,
  String? initialPath, {

  /// 路径 → 那段视频的静图海报**网络**地址。只有下载域知道（任务的 `imageList`
  /// 里存着原始地址），本机目录浏览传 null —— 那种视频只有已经落盘的封面才画得出来。
  Map<String, String>? videoPosterUrls,
}) {
  if (paths.isEmpty) {
    showAppToast(slang.t.localMedia.fileMissing, type: AppToastType.error);
    return;
  }
  final index = initialPath == null ? -1 : paths.indexOf(initialPath);
  final initialIndex = index >= 0 ? index : 0;

  if (_presentLocalImagesInSpace(paths, initialIndex, videoPosterUrls)) return;

  // ⛔⭐ 这里必须**裸拼** `'file://$path'`，不许换成 `Uri.file(path)`。
  //
  // 看着像个待修的 bug（文件名里的 `#`/`?` 在真 URI 里会被当分隔符），实际不是：
  // 消费方 `my_gallery_photo_view_wrapper.dart` 拿到的是
  // `imageUrl.replaceFirst('file://', '')` ——**纯字符串剥前缀，从不解析 URI**。
  // 所以裸拼进去什么、剥出来就是什么，`#` 一路安然无恙。
  //
  // 换成 `Uri.file()` 反而当场坏掉：它会把 `#` 正确编码成 `%23`，而剥前缀那头
  // 不做解码，`%23` 就原样进了文件系统调用。真机实证（2026-09-11）：
  //   PathNotFoundException: Cannot retrieve length of file,
  //   path = '.../ClaudeProbe/tag%231_test.png'
  //
  // 要改只能连**下游一起**改（把所有 `replaceFirst('file://','')` 换成
  // `Uri.parse(url).toFilePath()`）——那是全站图库的事，不是这一处能单方面决定的。
  final imageItems = <ImageItem>[
    for (final path in paths)
      ImageItem(
        url: 'file://$path',
        data: ImageItemData(
          id: path,
          url: 'file://$path',
          originalUrl: 'file://$path',
        ),
      ),
  ];

  pushPhotoViewWrapperOverlay(
    context: context,
    imageItems: imageItems,
    initialIndex: initialIndex,
    menuItemsBuilder: (context, item) => const [],
    enableMenu: false,
  );
}

/// Quest：把这组本机图片交给空间画廊。交出去了返回 true。
///
/// 清单项的「地址」就是绝对路径：服务里 [XrGalleryItem.isLocalFile] 据此不走缓存下载、
/// 直接把路径交回原生。宽高不在这里读（一组可能上千张）——原生拿到路径时读文件头。
/// 标题取起始那张所在的文件夹名；id 按文件夹 + 张数拼，同一组再点进来算同一本（不重置摆位）。
///
/// ⛔ [XrGalleryItem.isVideo] 必须如实填：原生按它分叉——图片交给 Coil 解码、视频交给
/// ExoPlayer 起播（`ImmersiveActivity.showGalleryItem`）。这里曾经**写死 false**，
/// 于是图库里混着的短片（Iwara 的 `.webm`，下载下来就躺在同一个文件夹里）被当成图片
/// 送去解码，真机报的正是 `BitmapFactory returned a null bitmap`（用户 2026-09-15）。
/// 本地文件没有服务端的 `type`/`mime`，只能按后缀判，见 [isGalleryVideoFileName]。
bool _presentLocalImagesInSpace(
  List<String> paths,
  int initialIndex,
  Map<String, String>? videoPosterUrls,
) {
  if (!Get.isRegistered<XrImmersiveService>()) return false;
  final xr = Get.find<XrImmersiveService>();
  if (!xr.available.value || !xr.galleryAutoEnterEnabled) return false;
  // 闸门是同步的（调用方要立刻知道还开不开 2D 大图页），交付本身是异步的：
  // 视频项的胶片格要先把封面备齐。
  unawaited(
    _deliverLocalImagesToSpace(xr, paths, initialIndex, videoPosterUrls),
  );
  return true;
}

/// 视频项的封面最多等这么久。
///
/// 本地已有的那张只是一次 `exists`（毫秒级）；没有、要照地址取一次的才会花时间。
/// 没赶上的留空（面板画一枚播放三角），而取回来的是**落盘**的：下次进来当场就有。
const Duration _localPosterBudget = Duration(seconds: 3);

/// 一次最多备多少条视频的封面。防的是「一个文件夹全是视频」。
const int _maxLocalPosterWarmup = 8;

Future<void> _deliverLocalImagesToSpace(
  XrImmersiveService xr,
  List<String> paths,
  int initialIndex,
  Map<String, String>? videoPosterUrls,
) async {
  final folder = p.dirname(paths[initialIndex]);
  final galleryId = 'local:$folder#${paths.length}';
  final posters = await _localVideoPosters(paths, videoPosterUrls);
  final items = <XrGalleryItem>[
    for (final path in paths)
      XrGalleryItem(
        id: path,
        isVideo: isGalleryVideoFileName(path),
        largeUrl: path,
        originalUrl: path,
        // 本地那张优先；面板拿不到它时还能照网络地址自己取（原生那条不走代理，
        // 但海报在 `i.iwara.tv` 上不挂代理也取得到，2026-09-15 实测）。
        posterPath: posters[path],
        posterUrl: videoPosterUrls?[path],
      ),
  ];
  LogUtils.i(
    '本机图片交给空间画廊 n=${items.length} index=$initialIndex '
        'posters=${posters.length}',
    'LocalImageViewer',
  );
  await xr.presentGallery(
    galleryId: galleryId,
    title: p.basename(folder),
    items: items,
    index: initialIndex,
    quality: galleryImageQualityOriginal,
  );
}

/// 把清单里各段视频的封面备齐（路径 → 封面文件路径）。备不出来的不进这张表。
Future<Map<String, String>> _localVideoPosters(
  List<String> paths,
  Map<String, String>? videoPosterUrls,
) async {
  final videos = paths
      .where(isGalleryVideoFileName)
      .take(_maxLocalPosterWarmup)
      .toList();
  if (videos.isEmpty) return const <String, String>{};
  final posters = <String, String>{};
  Future<void> resolve(String path) async {
    final url = videoPosterUrls?[path];
    final poster = url == null || url.isEmpty
        ? await existingGalleryVideoPoster(path)
        : await ensureGalleryVideoPoster(videoPath: path, posterUrl: url);
    if (poster != null) posters[path] = poster;
  }

  try {
    await Future.wait(videos.map(resolve)).timeout(_localPosterBudget);
  } on TimeoutException {
    // 超预算就带着已经拿到的那几张走，剩下的继续跑完、落盘给下一次用。
    LogUtils.d(
      '本机视频封面超预算，已拿到 ${posters.length}/${videos.length}',
      'LocalImageViewer',
    );
  } catch (error) {
    LogUtils.w('本机视频封面备齐失败：$error', 'LocalImageViewer');
  }
  return posters;
}
