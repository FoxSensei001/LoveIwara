import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static IwaraSite get _currentSite => Get.isRegistered<AppService>()
      ? Get.find<AppService>().currentSiteMode
      : IwaraSite.main;

  static String buildUrl(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '${_currentSite.baseUrl}$normalizedPath';
  }

  /// 把 [boundaryKey]（须挂在 [RepaintBoundary] 上）圈住的内容截图，
  /// 存成临时 PNG 后返回文件；失败时记日志并返回 null。
  ///
  /// 分享卡片（标题/作者/二维码）就是靠这个从 widget 树截成图片的。
  static Future<File?> captureWidgetAsPngFile(
    GlobalKey boundaryKey, {
    required String fileNamePrefix,
    double pixelRatio = 3.0,
  }) async {
    try {
      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        LogUtils.e('截图失败：目标不是 RepaintBoundary', tag: 'ShareService');
        return null;
      }
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      return await file.writeAsBytes(byteData.buffer.asUint8List());
    } catch (e) {
      LogUtils.e('生成分享图片失败', error: e, tag: 'ShareService');
      return null;
    }
  }

  /// 分享一张本地图片文件（可附文案 / 标题）。失败时抛出，由调用方提示。
  static Future<void> shareImageFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: text, subject: subject),
    );
  }

  /// 复制链接到剪贴板，并弹成功 / 失败 toast。
  static Future<void> copyLinkWithFeedback(
    String url, {
    String? successMessage,
  }) async {
    try {
      await copyToClipboard(url);
      showAppToast(
        successMessage ?? t.galleryDetail.copyLink,
        type: AppToastType.success,
        position: AppToastPosition.bottom,
      );
    } catch (e) {
      LogUtils.e('复制链接失败', error: e, tag: 'ShareService');
      showAppToast(
        t.errors.failedToOperate,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
    }
  }

  /// 复制链接到剪贴板。失败时记日志并 rethrow，由调用方提示。
  static Future<void> copyToClipboard(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      LogUtils.d('链接已复制到剪贴板: $url', 'ShareService');
    } catch (e) {
      LogUtils.e('复制链接失败', tag: 'ShareService', error: e);
      rethrow;
    }
  }

  /// 各 shareXxxDetail 共用的「分享链接 + 标题」出口。
  static Future<void> _shareUrl(
    String url,
    String subject, {
    required String logMessage,
    required String failureToast,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: subject),
      );
    } catch (e) {
      LogUtils.e(logMessage, error: e, tag: 'ShareService');
      showAppToast(
        failureToast,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
    }
  }

  /// 分享播放列表详情
  static Future<void> sharePlayListDetail(
    String playlistId,
    String? playListTitle,
  ) async {
    final String url = buildUrl('/playlist/$playlistId');
    final String title = playListTitle != null
        ? '$playListTitle - ${t.share.sharePlayList}'
        : t.share.sharePlayList;
    await _shareUrl(
      url,
      title,
      logMessage: '分享播放列表详情失败',
      failureToast: t.errors.failedToOperate,
    );
  }

  /// 分享视频详情
  static Future<void> shareVideoDetail(
    String videoId,
    String? videoTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/video/$videoId');
    final String title = videoTitle != null
        ? '$videoTitle - ${t.share.shareVideo}'
        : t.share.shareVideo;
    await _shareUrl(
      url,
      title,
      logMessage: '分享视频详情失败',
      failureToast: t.share.shareFailed,
    );
  }

  /// 分享图库详情
  static Future<void> shareGalleryDetail(
    String galleryId,
    String? galleryTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/image/$galleryId');
    final String title = galleryTitle != null
        ? '$galleryTitle - ${t.share.shareGallery}'
        : t.share.shareGallery;
    await _shareUrl(
      url,
      title,
      logMessage: '分享图库详情失败',
      failureToast: t.share.shareFailed,
    );
  }

  /// 分享用户详情
  static Future<void> shareUserDetail(
    String username,
    String? authorName,
  ) async {
    final String url = buildUrl('/profile/$username');
    final String title = authorName != null
        ? '$authorName - ${t.share.shareUser}'
        : t.share.shareUser;
    await _shareUrl(
      url,
      title,
      logMessage: '分享失败',
      failureToast: t.share.shareFailed,
    );
  }

  static void sharePlayList(String userId) {
    showAppToast(
      t.common.comingSoon,
      type: AppToastType.error,
      position: AppToastPosition.bottom,
    );
  }

  /// 分享帖子详情
  static Future<void> shareThreadDetail(
    String section,
    String threadId,
    String? threadTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/forum/$section/$threadId');
    final String title = threadTitle != null
        ? '$threadTitle - ${t.share.shareThread}'
        : t.share.shareThread;
    await _shareUrl(
      url,
      title,
      logMessage: '分享失败',
      failureToast: t.share.shareFailed,
    );
  }

  /// 分享帖子详情
  static Future<void> sharePostDetail(
    String postId,
    String? postTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/post/$postId');
    final String title = postTitle != null
        ? '$postTitle - ${t.share.sharePost}'
        : t.share.sharePost;
    await _shareUrl(
      url,
      title,
      logMessage: '分享失败',
      failureToast: t.share.shareFailed,
    );
  }
}
