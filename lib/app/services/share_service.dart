import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// 分享播放列表详情
  static Future<void> sharePlayListDetail(
      String playlistId, String? playListTitle) async {
    final String url = '${CommonConstants.iwaraBaseUrl}/playlist/$playlistId';
    String title = playListTitle != null ? '$playListTitle - ${t.share.sharePlayList}' : t.share.sharePlayList;

    try {
      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(url),
          subject: title,
        ),
      );
    } catch (e) {
      LogUtils.e('分享播放列表详情失败', error: e, tag: 'ShareService');
      showToastWidget(MDToastWidget(message: t.errors.failedToOperate, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  /// 分享视频详情
  static Future<void> shareVideoDetail(String videoId, String? videoTitle, String? authorName) async {
    final String url = '${CommonConstants.iwaraBaseUrl}/video/$videoId';
    String title = videoTitle != null ? '$videoTitle - ${t.share.shareVideo}' : t.share.shareVideo;

    try {
      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(url),
          subject: title,
        ),
      );
    } catch (e) {
      LogUtils.e('分享视频详情失败', error: e, tag: 'ShareService');
      showToastWidget(MDToastWidget(message: t.errors.failedToOperate, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  /// 分享图库详情
  static Future<void> shareGalleryDetail(String galleryId, String? galleryTitle, String? authorName) async {
    final String url = '${CommonConstants.iwaraBaseUrl}/image/$galleryId';
    String title = galleryTitle != null ? '$galleryTitle - ${t.share.shareGallery}' : t.share.shareGallery;

    try {
      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(url),
          subject: title,
        ),
      );
    } catch (e) {
      LogUtils.e('分享图库详情失败', error: e, tag: 'ShareService');
      showToastWidget(MDToastWidget(message: t.errors.failedToOperate, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  /// 分享用户详情
  static Future<void> shareUserDetail(String username, String? authorName) async {
    final String url = '${CommonConstants.iwaraBaseUrl}/profile/$username';
    String title = authorName != null ? '$authorName - ${t.share.shareUser}' : t.share.shareUser;

    try {
      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(url),
          subject: title,
        ),
      );
    } catch (e) {
      LogUtils.e('分享失败', tag: 'ShareService', error: e);
      showToastWidget(MDToastWidget(message: t.share.shareFailed, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  static void sharePlayList(String userId) {
    showToastWidget(MDToastWidget(message: t.common.comingSoon, type: MDToastType.error), position: ToastPosition.bottom);
  }

  /// 分享帖子详情
  static Future<void> shareThreadDetail(String section, String threadId, String? threadTitle, String? authorName) async {
    final String url = '${CommonConstants.iwaraBaseUrl}/forum/$section/$threadId';
    String title = threadTitle != null ? '$threadTitle - ${t.share.shareThread}' : t.share.shareThread;

    try {
      await SharePlus.instance.share(ShareParams(
        uri: Uri.parse(url),
        subject: title,
      ));
    } catch (e) {
      LogUtils.e('分享失败', tag: 'ShareService', error: e);
      showToastWidget(MDToastWidget(message: t.share.shareFailed, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  /// 分享帖子详情
  static Future<void> sharePostDetail(String postId, String? postTitle, String? authorName) async {
    final String url = '${CommonConstants.iwaraBaseUrl}/post/$postId';
    String title = postTitle != null ? '$postTitle - ${t.share.sharePost}' : t.share.sharePost;

    try {
      await SharePlus.instance.share(ShareParams(
        uri: Uri.parse(url),
        subject: title,
      ));
    } catch (e) {
      LogUtils.e('分享失败', tag: 'ShareService', error: e);
      showToastWidget(MDToastWidget(message: t.share.shareFailed, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }
}
