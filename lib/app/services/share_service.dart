import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ShareService {
  static IwaraSite get _currentSite => Get.isRegistered<AppService>()
      ? Get.find<AppService>().currentSiteMode
      : IwaraSite.main;

  static String buildUrl(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '${_currentSite.baseUrl}$normalizedPath';
  }

  /// 分享播放列表详情
  static Future<void> sharePlayListDetail(
    String playlistId,
    String? playListTitle,
  ) async {
    final String url = buildUrl('/playlist/$playlistId');
    String title = playListTitle != null
        ? '$playListTitle - ${t.share.sharePlayList}'
        : t.share.sharePlayList;

    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: title),
      );
    } catch (e) {
      LogUtils.e('分享播放列表详情失败', error: e, tag: 'ShareService');
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToOperate,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    }
  }

  /// 分享视频详情
  static Future<void> shareVideoDetail(
    String videoId,
    String? videoTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/video/$videoId');
    String title = videoTitle != null
        ? '$videoTitle - ${t.share.shareVideo}'
        : t.share.shareVideo;

    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: title),
      );
    } catch (e) {
      LogUtils.e('分享视频详情失败', error: e, tag: 'ShareService');
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToOperate,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    }
  }

  /// 分享图库详情
  static Future<void> shareGalleryDetail(
    String galleryId,
    String? galleryTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/image/$galleryId');
    String title = galleryTitle != null
        ? '$galleryTitle - ${t.share.shareGallery}'
        : t.share.shareGallery;

    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: title),
      );
    } catch (e) {
      LogUtils.e('分享图库详情失败', error: e, tag: 'ShareService');
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToOperate,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    }
  }

  /// 分享用户详情
  static Future<void> shareUserDetail(
    String username,
    String? authorName,
  ) async {
    final String url = buildUrl('/profile/$username');
    String title = authorName != null
        ? '$authorName - ${t.share.shareUser}'
        : t.share.shareUser;

    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: title),
      );
    } catch (e) {
      LogUtils.e('分享失败', tag: 'ShareService', error: e);
      showToastWidget(
        MDToastWidget(message: t.share.shareFailed, type: MDToastType.error),
        position: ToastPosition.bottom,
      );
    }
  }

  static void sharePlayList(String userId) {
    showToastWidget(
      MDToastWidget(message: t.common.comingSoon, type: MDToastType.error),
      position: ToastPosition.bottom,
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
    String title = threadTitle != null
        ? '$threadTitle - ${t.share.shareThread}'
        : t.share.shareThread;

    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: title),
      );
    } catch (e) {
      LogUtils.e('分享失败', tag: 'ShareService', error: e);
      showToastWidget(
        MDToastWidget(message: t.share.shareFailed, type: MDToastType.error),
        position: ToastPosition.bottom,
      );
    }
  }

  /// 分享帖子详情
  static Future<void> sharePostDetail(
    String postId,
    String? postTitle,
    String? authorName,
  ) async {
    final String url = buildUrl('/post/$postId');
    String title = postTitle != null
        ? '$postTitle - ${t.share.sharePost}'
        : t.share.sharePost;

    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(url), subject: title),
      );
    } catch (e) {
      LogUtils.e('分享失败', tag: 'ShareService', error: e);
      showToastWidget(
        MDToastWidget(message: t.share.shareFailed, type: MDToastType.error),
        position: ToastPosition.bottom,
      );
    }
  }

  /// 复制链接到剪贴板
  static Future<void> copyToClipboard(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      LogUtils.d('链接已复制到剪贴板: $url', 'ShareService');
    } catch (e) {
      LogUtils.e('复制链接失败', tag: 'ShareService', error: e);
      rethrow;
    }
  }
}
