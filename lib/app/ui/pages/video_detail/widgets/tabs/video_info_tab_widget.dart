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
import '../../../../../../common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class VideoInfoTabWidget extends StatelessWidget {
  final MyVideoStateController controller;
  final double paddingTop;

  const VideoInfoTabWidget({
    super.key,
    required this.controller,
    required this.paddingTop,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isVideoInfoLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (controller.mainErrorWidget.value != null) {
        return controller.mainErrorWidget.value!;
      }

      if (controller.isDesktopAppFullScreen.value) {
        return const SizedBox.shrink();
      }

      // 复用VideoDetailContent的详情部分逻辑，排除播放器
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频标题
            _buildVideoTitle(context),
            const SizedBox(height: 12),
            
            // 作者信息区域
            _buildAuthorInfo(context),
            const SizedBox(height: 12),
            
            // 视频发布时间和观看次数
            _buildVideoStats(context),
            const SizedBox(height: 12),
            
            // 视频描述内容
            _buildVideoDescription(context),
            const SizedBox(height: 12),
            
            // 视频标签区域
            _buildVideoTags(context),
            const SizedBox(height: 12),
            
            // 点赞用户头像展示
            _buildLikeAvatars(context),
            const SizedBox(height: 12),
            
            // 操作按钮行
            _buildActionButtons(context),
          ],
        ),
      );
    });
  }

  Widget _buildVideoTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题文本
          Expanded(
            child: SelectableText(
              controller.videoInfo.value?.title ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          // 翻译按钮
          if (controller.videoInfo.value?.title?.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.translate, size: 20),
              padding: EdgeInsets.zero,
              onPressed: () {
                Get.dialog(
                  TranslationDialog(
                    text: controller.videoInfo.value?.title ?? '',
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          _buildAuthorAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAuthorNameButton(context),
          ),
          if (controller.videoInfo.value?.user != null)
            SizedBox(
              height: 32,
              child: FollowButtonWidget(
                user: controller.videoInfo.value!.user!,
                onUserUpdated: (updatedUser) {
                  controller.videoInfo.value = controller.videoInfo.value?.copyWith(
                    user: updatedUser,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final user = controller.videoInfo.value?.user;
          if (user != null) {
            NaviService.navigateToAuthorProfilePage(user.username);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AvatarWidget(
          user: controller.videoInfo.value?.user,
          size: 40
        ),
      ),
    );
  }

  Widget _buildAuthorNameButton(BuildContext context) {
    final user = controller.videoInfo.value?.user;
    if (user?.premium == true) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            NaviService.navigateToAuthorProfilePage(user?.username ?? '');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUserName(context, user, fontSize: 16, bold: true),
              Text(
                '@${user?.username ?? ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          NaviService.navigateToAuthorProfilePage(user?.username ?? '');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '@${user?.username ?? ''}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoStats(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Obx(() => Text(
        '${t.galleryDetail.publishedAt}：${CommonUtils.formatFriendlyTimestamp(controller.videoInfo.value?.createdAt)}    ${t.galleryDetail.viewsCount}：${CommonUtils.formatFriendlyNumber(controller.videoInfo.value?.numViews)}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      )),
    );
  }

  Widget _buildVideoDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Obx(() => VideoDescriptionWidget(
        description: controller.videoInfo.value?.body,
        isDescriptionExpanded: controller.isDescriptionExpanded,
        onToggleDescription: () => controller.isDescriptionExpanded.toggle(),
      )),
    );
  }

  Widget _buildVideoTags(BuildContext context) {
    return Obx(() {
      final tags = controller.videoInfo.value?.tags;
      if (tags != null && tags.isNotEmpty) {
        return ExpandableTagsWidget(tags: tags);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildLikeAvatars(BuildContext context) {
    return Obx(() {
      final videoId = controller.videoInfo.value?.id;
      if (videoId != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SizedBox(
            height: 40,
            child: LikeAvatarsWidget(
              mediaId: videoId,
              mediaType: MediaType.VIDEO,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final videoInfo = controller.videoInfo.value;
      if (videoInfo != null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                LikeButtonWidget(
                  mediaId: videoInfo.id,
                  liked: videoInfo.liked ?? false,
                  likeCount: videoInfo.numLikes ?? 0,
                  onLike: (id) async {
                    final result = await Get.find<VideoService>().likeVideo(id);
                    return result.isSuccess;
                  },
                  onUnlike: (id) async {
                    final result = await Get.find<VideoService>().unlikeVideo(id);
                    return result.isSuccess;
                  },
                  onLikeChanged: (liked) {
                    controller.videoInfo.value = controller.videoInfo.value?.copyWith(
                      liked: liked,
                      numLikes: (controller.videoInfo.value?.numLikes ?? 0) + (liked ? 1 : -1),
                    );
                  },
                ),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      final UserService userService = Get.find();
                      if (!userService.isLogin) {
                        showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error), position: ToastPosition.bottom);
                        Get.toNamed(Routes.LOGIN);
                        return;
                      }
                      // TODO: 实现添加到播放列表功能
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.playlist_add,
                            size: 20,
                            color: Theme.of(context).iconTheme.color
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.common.playList,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _addToFavorite(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_border,
                            size: 20,
                            color: Theme.of(context).iconTheme.color
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.favorite.localizeFavorite,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // TODO: 实现下载功能
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download,
                            size: 20,
                            color: Theme.of(context).iconTheme.color
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.common.download,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // TODO: 实现分享功能
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share,
                            size: 20,
                            color: Theme.of(context).iconTheme.color
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.common.share,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  // 添加到收藏夹
  void _addToFavorite(BuildContext context) {
    final videoInfo = controller.videoInfo.value;
    if (videoInfo == null) {
      showToastWidget(MDToastWidget(message: slang.t.errors.failedToFetchData, type: MDToastType.error));
      return;
    }

    Get.dialog(
      AddToFavoriteDialog(
        itemId: videoInfo.id,
        onAdd: (folderId) async {
          return await FavoriteService.to.addVideoToFolder(videoInfo, folderId);
        },
      ),
    );
  }
} 