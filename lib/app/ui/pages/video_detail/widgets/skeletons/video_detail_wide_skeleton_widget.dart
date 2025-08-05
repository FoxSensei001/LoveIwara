import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/skeletons/media_tile_list_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/skeletons/video_player_skeleton_widget.dart';

class VideoDetailWideSkeletonWidget extends StatelessWidget {
  final MyVideoStateController controller;
  const VideoDetailWideSkeletonWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const double tabsAreaWidth = 350.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧视频播放器骨架
        Expanded(
          child: VideoPlayerSkeletonWidget(controller: controller),
        ),
        // 右侧Tab内容骨架
        const SizedBox(
          width: tabsAreaWidth,
          child: MediaTileListSkeletonWidget(),
        ),
      ],
    );
  }
}