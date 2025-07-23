import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/video_description_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/expandable_tags_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/like_avatars_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/like_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/add_to_favorite_dialog.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart'; // 导入共享常量和组件

class VideoInfoTabWidget extends StatelessWidget {
  final MyVideoStateController controller;

  const VideoInfoTabWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isVideoInfoLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.mainErrorWidget.value != null) {
        return controller.mainErrorWidget.value!;
      }
      if (controller.isDesktopAppFullScreen.value) {
        return const SizedBox.shrink();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoTitle(context),
            const SizedBox(height: UIConstants.interElementSpacing),
            _buildAuthorInfo(context),
            const SizedBox(height: UIConstants.interElementSpacing),
            _buildVideoStats(context),
            const SizedBox(height: UIConstants.interElementSpacing),
            _buildVideoDescription(context),
            const SizedBox(height: UIConstants.interElementSpacing),
            _buildVideoTags(context),
            const SizedBox(height: UIConstants.interElementSpacing),
            _buildLikeAvatars(context),
            const SizedBox(height: UIConstants.sectionSpacing), // More space before actions
            _buildActionButtons(context),
          ],
        ),
      );
    });
  }

  Widget _buildVideoTitle(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SelectableText(
            controller.videoInfo.value?.title ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
          ),
        ),
        if (controller.videoInfo.value?.title?.isNotEmpty == true)
          IconButton(
            icon: const Icon(Icons.translate, size: 20),
            padding: const EdgeInsets.only(left: 8),
            constraints: const BoxConstraints(),
            onPressed: () => Get.dialog(TranslationDialog(text: controller.videoInfo.value!.title!)),
          ),
      ],
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => NaviService.navigateToAuthorProfilePage(controller.videoInfo.value!.user!.username),
          child: AvatarWidget(user: controller.videoInfo.value?.user, size: 40),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => NaviService.navigateToAuthorProfilePage(controller.videoInfo.value!.user!.username),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildUserName(context, controller.videoInfo.value?.user, fontSize: 16, bold: true),
                Text(
                  '@${controller.videoInfo.value?.user?.username ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        if (controller.videoInfo.value?.user != null)
          SizedBox(
            height: 32,
            child: FollowButtonWidget(
              user: controller.videoInfo.value!.user!,
              onUserUpdated: (updatedUser) {
                controller.videoInfo.value = controller.videoInfo.value?.copyWith(user: updatedUser);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVideoStats(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() => Text(
      '${t.galleryDetail.publishedAt}：${CommonUtils.formatFriendlyTimestamp(controller.videoInfo.value?.createdAt)}  ·  ${CommonUtils.formatFriendlyNumber(controller.videoInfo.value?.numViews)} ${t.galleryDetail.viewsCount}',
      style: TextStyle(color: Colors.grey[600], fontSize: 13),
    ));
  }

  Widget _buildVideoDescription(BuildContext context) {
    return Obx(() => VideoDescriptionWidget(
      description: controller.videoInfo.value?.body,
      isDescriptionExpanded: controller.isDescriptionExpanded,
      onToggleDescription: controller.isDescriptionExpanded.toggle,
    ));
  }

  Widget _buildVideoTags(BuildContext context) {
    return Obx(() {
      final tags = controller.videoInfo.value?.tags;
      return (tags != null && tags.isNotEmpty)
          ? ExpandableTagsWidget(tags: tags)
          : const SizedBox.shrink();
    });
  }

  Widget _buildLikeAvatars(BuildContext context) {
    return Obx(() {
      final videoId = controller.videoInfo.value?.id;
      return videoId != null
          ? SizedBox(height: 40, child: LikeAvatarsWidget(mediaId: videoId, mediaType: MediaType.VIDEO))
          : const SizedBox.shrink();
    });
  }
  
  /// A more responsive action button row using Wrap.
  Widget _buildActionButtons(BuildContext context) {
    final t = slang.Translations.of(context);
    final videoInfo = controller.videoInfo.value;
    if (videoInfo == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.0, // Horizontal space between buttons
      runSpacing: 8.0, // Vertical space between rows
      children: [
        LikeButtonWidget(
          mediaId: videoInfo.id,
          liked: videoInfo.liked ?? false,
          likeCount: videoInfo.numLikes ?? 0,
          onLike: (id) async => (await Get.find<VideoService>().likeVideo(id)).isSuccess,
          onUnlike: (id) async => (await Get.find<VideoService>().unlikeVideo(id)).isSuccess,
          onLikeChanged: (liked) {
            controller.videoInfo.value = controller.videoInfo.value?.copyWith(
              liked: liked,
              numLikes: (controller.videoInfo.value?.numLikes ?? 0) + (liked ? 1 : -1),
            );
          },
        ),
        _ActionButton(
          icon: Icons.playlist_add,
          label: t.common.playList,
          onTap: () {
            // TODO: Add to playlist logic
             final UserService userService = Get.find();
            if (!userService.isLogin) {
              showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error), position: ToastPosition.bottom);
              Get.toNamed(Routes.LOGIN);
            }
          },
        ),
         _ActionButton(
          icon: Icons.bookmark_border,
          label: t.favorite.localizeFavorite,
          onTap: () => _addToFavorite(context, videoInfo),
        ),
         _ActionButton(
          icon: Icons.download,
          label: t.common.download,
          onTap: () {
            // TODO: Download logic
          },
        ),
         _ActionButton(
          icon: Icons.share,
          label: t.common.share,
          onTap: () {
            // TODO: Share logic
          },
        ),
      ],
    );
  }

  /// Reusable widget for creating action buttons to reduce code duplication.
  Widget _ActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Get.theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Get.theme.iconTheme.color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Get.theme.textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToFavorite(BuildContext context, dynamic videoInfo) {
    Get.dialog(
      AddToFavoriteDialog(
        itemId: videoInfo.id,
        onAdd: (folderId) => FavoriteService.to.addVideoToFolder(videoInfo, folderId),
      ),
    );
  }
}
