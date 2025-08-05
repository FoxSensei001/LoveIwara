import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/related_media_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/skeletons/media_tile_list_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_tile_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart'; // 导入共享常量和组件
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
    final t = slang.Translations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者的其他视频部分
          _buildAuthorOtherVideos(t),
          const SizedBox(height: UIConstants.sectionSpacing), // 统一区块间距
          _buildRelatedVideos(t),
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAuthorOtherVideos(slang.Translations t) {
    return Obx(() {
      final otherVideosController = videoController.otherAuthorzVideosController;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(icon: Icons.person, title: t.videoDetail.authorOtherVideos), // 使用共享的SectionHeader
          if (otherVideosController == null)
            const SizedBox.shrink()
          else if (otherVideosController.isLoading.value)
            const MediaTileListSkeletonWidget()
          else if (otherVideosController.videos.isEmpty)
            _buildEmptyState(t.videoDetail.authorNoOtherVideos)
          else
            ListView.separated(
              itemCount: otherVideosController.videos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: UIConstants.listSpacing),
              itemBuilder: (_, index) => VideoTileListItem(video: otherVideosController.videos[index]),
            ),
        ],
      );
    });
  }

  Widget _buildRelatedVideos(slang.Translations t) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader( // 使用共享的SectionHeader
            icon: Icons.recommend,
            title: t.videoDetail.relatedVideos,
            action: IconButton(
              onPressed: relatedVideoController.fetchRelatedMedias,
              icon: const Icon(Icons.refresh),
              tooltip: t.common.refresh,
            ),
          ),
          if (relatedVideoController.isLoading.value)
            const MediaTileListSkeletonWidget()
          else if (relatedVideoController.videos.isEmpty)
            _buildEmptyState(t.videoDetail.noRelatedVideos)
          else
            ListView.separated(
              itemCount: relatedVideoController.videos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: UIConstants.listSpacing),
              itemBuilder: (_, index) => VideoTileListItem(video: relatedVideoController.videos[index]),
            )
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
          Icon(Icons.video_library_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
