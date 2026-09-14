import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  String? initialPath,
) {
  if (paths.isEmpty) {
    showAppToast(slang.t.localMedia.fileMissing, type: AppToastType.error);
    return;
  }
  final index = initialPath == null ? -1 : paths.indexOf(initialPath);
  final initialIndex = index >= 0 ? index : 0;

  if (_presentLocalImagesInSpace(paths, initialIndex)) return;

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
bool _presentLocalImagesInSpace(List<String> paths, int initialIndex) {
  if (!Get.isRegistered<XrImmersiveService>()) return false;
  final xr = Get.find<XrImmersiveService>();
  if (!xr.available.value || !xr.galleryAutoEnterEnabled) return false;
  final folder = p.dirname(paths[initialIndex]);
  final galleryId = 'local:$folder#${paths.length}';
  final items = <XrGalleryItem>[
    for (final path in paths)
      XrGalleryItem(
        id: path,
        isVideo: false,
        largeUrl: path,
        originalUrl: path,
      ),
  ];
  LogUtils.i(
    '本机图片交给空间画廊 n=${items.length} index=$initialIndex',
    'LocalImageViewer',
  );
  unawaited(
    xr.presentGallery(
      galleryId: galleryId,
      title: p.basename(folder),
      items: items,
      index: initialIndex,
      quality: galleryImageQualityOriginal,
    ),
  );
  return true;
}
