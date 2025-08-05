import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

class VideoPlayerSkeletonWidget extends StatelessWidget {
  final MyVideoStateController controller;

  const VideoPlayerSkeletonWidget({super.key, required this.controller});

  String _getLoadingMessage(BuildContext context) {
    switch (controller.pageLoadingState.value) {
      case VideoDetailPageLoadingState.loadingVideoInfo:
        return "正在获取视频信息...";
      case VideoDetailPageLoadingState.loadingVideoSource:
        return "正在获取播放地址...";
      case VideoDetailPageLoadingState.idle:
        if (!controller.videoPlayerReady.value) {
          return "正在加载播放器...";
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      label: const Text("重试"),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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