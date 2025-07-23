import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/related_media_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/media_tile_list_loading_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_tile_list_item_widget.dart';

class RelatedVideosTabWidget extends StatelessWidget {
  final MyVideoStateController videoController;
  final RelatedMediasController relatedVideoController;

  const RelatedVideosTabWidget({
    super.key,
    required this.videoController,
    required this.relatedVideoController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者的其他视频部分
          _buildAuthorOtherVideos(),
          
          const SizedBox(height: 24),
          
          // 相关视频部分
          _buildRelatedVideos(),
        ],
      ),
    );
  }

  Widget _buildAuthorOtherVideos() {
    return Obx(() {
      final otherVideosController = videoController.otherAuthorzVideosController;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              const Text(
                '作者的其他视频',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 内容
          if (otherVideosController == null)
            const SizedBox.shrink()
          else if (otherVideosController.isLoading.value)
            const MediaTileListSkeletonWidget()
          else if (otherVideosController.videos.isEmpty)
            _buildEmptyState('作者暂无其他视频')
          else
            Column(
              children: otherVideosController.videos
                  .map((video) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: VideoTileListItem(video: video),
                      ))
                  .toList(),
            ),
        ],
      );
    });
  }

  Widget _buildRelatedVideos() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.recommend,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              const Text(
                '相关视频',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // 刷新按钮
              IconButton(
                onPressed: () => relatedVideoController.fetchRelatedMedias(),
                icon: const Icon(Icons.refresh),
                tooltip: '刷新相关视频',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 内容
          if (relatedVideoController.isLoading.value)
            const MediaTileListSkeletonWidget()
          else if (relatedVideoController.videos.isEmpty)
            _buildEmptyState('暂无相关视频')
          else
            Column(
              children: relatedVideoController.videos
                  .map((video) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: VideoTileListItem(video: video),
                      ))
                  .toList(),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 