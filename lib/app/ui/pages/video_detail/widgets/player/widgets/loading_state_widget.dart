import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class LoadingStateWidget extends StatelessWidget {
  final MyVideoStateController controller;
  final double size;

  const LoadingStateWidget({
    super.key,
    required this.controller,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.2),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: size * 0.08,
            ).animate(onPlay: (controller) => controller.repeat()).rotate(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getLoadingMessage(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  String _getLoadingMessage() {
    switch (controller.pageLoadingState.value) {
      case VideoDetailPageLoadingState.loadingVideoInfo:
        return slang.t.videoDetail.skeleton.fetchingVideoInfo;
      case VideoDetailPageLoadingState.loadingVideoSource:
        return slang.t.videoDetail.skeleton.fetchingVideoSources;
      case VideoDetailPageLoadingState.applyingSolution:
        return slang.t.videoDetail.skeleton.applyingSolution;
      case VideoDetailPageLoadingState.addingListeners:
        return slang.t.videoDetail.skeleton.addingListeners;
      case VideoDetailPageLoadingState.successFecthVideoDurationInfo:
        return slang.t.videoDetail.skeleton.successFecthVideoDurationInfo;
      case VideoDetailPageLoadingState.successFecthVideoHeightInfo:
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
}
