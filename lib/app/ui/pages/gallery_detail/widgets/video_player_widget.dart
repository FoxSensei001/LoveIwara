import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/external_player_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_video_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/external_player_sheet.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_filter_wrapper.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 图库大图页里那一页的**画面**。
///
/// ⛔ 控件条不在这里，在大图页的 `Stack` 上：这一层被 `PhotoViewGallery` 的
/// 缩放变换裹着，控件放进来会跟着画面一起放大、跟着拖动一起跑出屏幕。两边共享
/// 同一个 [GalleryVideoController]，见那只类的文档。
///
/// 手势也不在这里：单击切显隐、长按加速（随手指横向位移调档）都由大图页统一收，
/// 理由同上——那些手势与「翻页」「下拉关闭」「长按开菜单」在同一个竞技场里，
/// 必须由同一处安排先后，不能各写一份。
class GalleryVideoPlayer extends StatelessWidget {
  const GalleryVideoPlayer({super.key, required this.controller});

  final GalleryVideoController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final error = controller.error;
        if (error != null) {
          return _GalleryVideoErrorView(
            error: error,
            videoUrl: controller.videoUrl,
            onRetry: controller.retry,
          );
        }
        // 就绪与否都画 [Video]：media_kit 在拿到首帧前给的是黑底，正好是这一页
        // 该有的样子。**加载指示与播放钮都不在这里**——它们是控件，跟着 chrome
        // 层走（见 `GalleryVideoCenterControls` 的类文档：待在页内会被
        // PhotoViewGallery 的缩放变换一起放大）。
        return ColorVisionFilterWrapper(
          // 图库内容跟随「图库色觉辅助」开关，与播放器那个开关独立。
          configKey: ConfigKey.GALLERY_COLOR_VISION_FILTER_ID,
          child: Video(
            controller: controller.videoController,
            controls: NoVideoControls,
            fit: BoxFit.contain,
            // ⛔ [Video] 默认 `fill: Color(0xFF000000)`，会自己在整块视口上铺一层
            // **不透明**黑。大图页的黑底统一由外层 `_ExitFadeBackdrop` 供给，并
            // 且要跟着下拉关闭的手势一起淡出露出下层页面——这一层不置空的话，
            // 图片页拖着拖着背景透出来了，视频页却始终是一块死黑
            // （用户 2026-09-05 报的）。`PhotoViewGallery.backgroundDecoration`
            // 早已因为同一个理由置成了透明。
            fill: Colors.transparent,
          ),
        );
      },
    );
  }
}

/// 播不了时的说明卡。
///
/// ⛔ **文案由 [GalleryVideoErrorKind] 决定，不再由文件后缀决定**。改造前这里
/// 只认 `could not open codec` 一个字符串，而图库 webm 真正报的是
/// `Failed to recognize file format.`——一条也没命中，于是所有人看到的都是兜底
/// 的「不支持的视频格式 · 请尝试使用其他视频播放器」，把一个**地址拿错了**的
/// 问题说成设备解码能力不足。真正的修复在 [MediaFile.getLargeImageUrl]；这里
/// 负责的是万一再出问题时，说的话是对的。
class _GalleryVideoErrorView extends StatelessWidget {
  const _GalleryVideoErrorView({
    required this.error,
    required this.videoUrl,
    required this.onRetry,
  });

  final GalleryVideoError error;
  final String videoUrl;
  final VoidCallback onRetry;

  ({String title, String? suggestion}) _describe(slang.Translations t) {
    switch (error.kind) {
      case GalleryVideoErrorKind.unrecognized:
        return (
          title: t.mediaPlayer.unrecognizedVideoFormat,
          suggestion: t.mediaPlayer.unrecognizedVideoFormatSuggestion,
        );
      case GalleryVideoErrorKind.codec:
        return (
          title: t.mediaPlayer.videoCodecNotSupported,
          suggestion: t.mediaPlayer.currentDeviceCodecNotSupported,
        );
      case GalleryVideoErrorKind.network:
        return (
          title: t.mediaPlayer.networkConnectionIssue,
          suggestion: t.mediaPlayer.checkNetworkConnection,
        );
      // ⛔ 403 **不是**「本机权限不足」。Iwara 的播放地址是带时效的 CDN 链接，
      // 服务端回 403 压倒性地是"这条链接过期/签错了"，跟应用有没有媒体权限毫无
      // 关系——照着「应用可能缺少必要的媒体播放权限」去设置里翻，永远修不好。
      // 这正是这次改造要消灭的那类错标。
      case GalleryVideoErrorKind.forbidden:
        return (
          title: t.mediaPlayer.accessDenied,
          suggestion: t.mediaPlayer.accessDeniedSuggestion,
        );
      case GalleryVideoErrorKind.other:
        return (
          title: t.mediaPlayer.videoLoadFailed,
          suggestion: t.mediaPlayer.tryOtherVideoPlayer,
        );
    }
  }

  Future<void> _openExternally() async {
    await showExternalPlayerSheet(
      ExternalPlayerSource(
        kind: videoUrl.startsWith('file://')
            ? ExternalPlayerSourceKind.localFile
            : ExternalPlayerSourceKind.onlineUrl,
        value: videoUrl.startsWith('file://')
            ? videoUrl.replaceFirst('file://', '')
            : videoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final described = _describe(t);
    final extension = CommonUtils.getFileExtension(videoUrl);

    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                described.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (extension.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${t.mediaPlayer.format}: ${extension.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              if (described.suggestion != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          described.suggestion!,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Theme(
                // ExpansionTile 的分割线在这张深色卡上是两条亮线，去掉。
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    t.mediaPlayer.detailedErrorInfo,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        error.raw,
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(t.mediaPlayer.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // 「用其他应用打开」以前只挂在 webm 编解码错误这一支上，而那
                  // 一支从来没被命中过，等于这枚按钮从来没出现过。现在只要是
                  // 「这台设备/这个地址放不了」的几类，就把出路摆出来——403
                  // 也算：重试是拿同一条链接再试一次，换个应用（它自己会重新
                  // 发起请求、带自己的 UA）反而常常能放。
                  if (error.kind == GalleryVideoErrorKind.unrecognized ||
                      error.kind == GalleryVideoErrorKind.codec ||
                      error.kind == GalleryVideoErrorKind.forbidden)
                    ElevatedButton.icon(
                      onPressed: _openExternally,
                      icon: const Icon(Icons.open_in_new),
                      label: Text(t.mediaPlayer.externalPlayer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
