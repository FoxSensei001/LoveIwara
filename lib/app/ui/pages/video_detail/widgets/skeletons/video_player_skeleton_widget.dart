import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
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
      case VideoDetailPageLoadingState.idle:
        if (!controller.videoPlayerReady.value) {
          // return "正在加载视频...";
          return slang.t.videoDetail.skeleton.loadingVideo;
        }
        return "";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
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
          Positioned(
            top: MediaQuery.paddingOf(context).top,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => AppService.tryPop(),
            ),
          ),
        ],
      ),
    );
  }
}