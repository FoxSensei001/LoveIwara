import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';

const String _tag = 'GalleryVideoPoster';

/// 下载回来的图库里，那段视频的封面文件：与视频**同目录、同名**，多一个
/// `.poster.jpg` 后缀。
///
/// 放在视频旁边而不是缓存目录里，图的是三件事：跟着下载目录一起搬走 / 一起删掉、
/// 离线永远在（缓存目录会被系统清）、不需要任何索引就能从视频路径算出来。
String galleryVideoPosterPath(String videoPath) => '$videoPath.poster.jpg';

/// 确保 [videoPath] 旁边有那张封面，返回它的路径；弄不到答 null。
///
/// # ⛔ 为什么不解本地帧
///
/// 2026-09-15 用户实测：这台 Quest 上**无头 libmpv 一帧都抓不出来** —— 连「本机文件 ›
/// 所有视频」里普通 mp4 的卡片封面都是灰占位（那条路走的是
/// `LocalMediaDerivationService` 的派生队列，与这里本是同一套办法）。头显是这个功能
/// 的主战场，抓帧在主战场上不工作，就不能把它当作方案。
///
/// 而服务端**本来就给这段视频生成了静图**（见 `MediaFile.getPosterUrl`，实测 490×490
/// 的 JPEG、32.8KB）。取一次存在文件旁边，之后离线、换设备、清缓存都还在。
///
/// # 取的那一次走哪条路
///
/// [DefaultCacheManager] —— 与 2D 那几处画海报用的是**同一只缓存**：详情页 / 胶片
/// 刚画过的话这里一次网络都不用走；它那条 HTTP 还带着应用内代理，而原生 Coil 没有。
Future<String?> ensureGalleryVideoPoster({
  required String videoPath,
  required String posterUrl,
}) async {
  final target = galleryVideoPosterPath(videoPath);
  try {
    if (await File(target).exists()) return target;
  } catch (_) {
    return null;
  }
  if (!posterUrl.startsWith('http')) return null;
  try {
    final cached = await DefaultCacheManager().getSingleFile(posterUrl);
    if (!await cached.exists()) return null;
    await cached.copy(target);
    LogUtils.d('图库视频封面已落盘：$target', _tag);
    return target;
  } catch (error) {
    // 离线、地址失效、目录只读都会走到这里。答 null 就是「这一格画占位图」，
    // ⛔ 别把它当异常往上抛：封面取不到不该影响浏览。
    LogUtils.w('图库视频封面取不到（$error）', _tag);
    return null;
  }
}

/// 已经落盘的那张；没有就 null。**不走网络**，给「只想同步看一眼有没有」的地方用。
Future<String?> existingGalleryVideoPoster(String videoPath) async {
  final target = galleryVideoPosterPath(videoPath);
  try {
    return await File(target).exists() ? target : null;
  } catch (_) {
    return null;
  }
}
