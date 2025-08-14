import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class VideoPlayerSkeletonWidget extends StatelessWidget {
  final MyVideoStateController controller;

  const VideoPlayerSkeletonWidget({super.key, required this.controller});

  String _getLoadingMessage(BuildContext context) {
    switch (controller.pageLoadingState.value) {
      case VideoDetailPageLoadingState.loadingVideoInfo:
      // return "正在获取视频信息...";
        return slang.t.videoDetail.skeleton.fetchingVideoInfo;
      case VideoDetailPageLoadingState.loadingVideoSource:
      // return "正在获取播放地址...";
        return slang.t.videoDetail.skeleton.fetchingVideoSources;
      case VideoDetailPageLoadingState.applyingSolution:
      // return "正在应用此分辨率...";
        return slang.t.videoDetail.skeleton.applyingSolution;
      case VideoDetailPageLoadingState.addingListeners:
      // return "正在添加监听器...";
        return slang.t.videoDetail.skeleton.addingListeners;
      case VideoDetailPageLoadingState.successFecthVideoDurationInfo:
      // return "成功获取视频资源，开始加载视频...";
        return slang.t.videoDetail.skeleton.successFecthVideoDurationInfo;
      case VideoDetailPageLoadingState.successFecthVideoHeightInfo:
      // return "加载完成";
        return slang.t.videoDetail.skeleton.successFecthVideoHeightInfo;
      case VideoDetailPageLoadingState.playerError:
        return controller.videoErrorMessage.value ?? slang.t.videoDetail.skeleton.loadingVideo;
      case VideoDetailPageLoadingState.idle:
      // 如果是站外视频，不显示加载消息
        if (controller.videoInfo.value?.isExternalVideo == true) {
          return "";
        }
        if (!controller.videoPlayerReady.value) {
          return slang.t.videoDetail.skeleton.loadingVideo;
        }
        return "";
      default:
        return "";
    }
  }

  // 截取错误信息的前50个字符
  String _getTruncatedErrorMessage(String message) {
    if (message.length <= 50) {
      return message;
    }
    return '${message.substring(0, 50)}...';
  }

  // 显示错误详情底部弹窗
  void _showErrorDetailSheet(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: bottomPadding + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  slang.t.common.detail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.videoSourceErrorMessage.value!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.fetchVideoSource();
                },
                icon: const Icon(Icons.refresh),
                label: Text(slang.t.common.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取安全区域顶部padding，与my_video_screen.dart保持一致
    final double paddingTop = MediaQuery.paddingOf(context).top;
    final double paddingBottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // 为中心内容添加顶部padding以适配安全区域
          Positioned.fill(
            top: paddingTop,
            bottom: paddingBottom,
            child: Center(
              child: Obx(() {
                if (controller.videoSourceErrorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTruncatedErrorMessage(controller.videoSourceErrorMessage.value!),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showErrorDetailSheet(context),
                                      icon: const Icon(Icons.info_outline, size: 16),
                                      label: Text(slang.t.common.detail),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => controller.fetchVideoSource(),
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: Text(slang.t.common.retry),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getLoadingMessage(context),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  );
                }
              }),
            ),
          ),
          // 返回按钮保持在安全区域内
          Positioned(
            top: paddingTop,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}