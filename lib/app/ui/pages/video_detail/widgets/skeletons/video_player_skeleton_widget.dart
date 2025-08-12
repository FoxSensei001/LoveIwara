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

  @override
  Widget build(BuildContext context) {
    // 获取安全区域顶部padding，与my_video_screen.dart保持一致
    final double paddingTop = MediaQuery.paddingOf(context).top;
    
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // 为中心内容添加顶部padding以适配安全区域
          Positioned.fill(
            top: paddingTop,
            child: Center(
              child: Obx(() {
                if (controller.videoSourceErrorMessage.value != null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        controller.videoSourceErrorMessage.value!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchVideoSource(),
                        icon: const Icon(Icons.refresh),
                        label: Text(slang.t.common.retry),
                      ),
                    ],
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