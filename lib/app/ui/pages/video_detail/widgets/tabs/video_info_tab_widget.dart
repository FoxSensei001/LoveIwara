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
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart'; // 导入共享常量和组件
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shimmer/shimmer.dart';

import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/add_video_to_playlist_dialog.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/share_video_bottom_sheet.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/video.model.dart';

class VideoInfoTabWidget extends StatelessWidget {
  final MyVideoStateController controller;

  const VideoInfoTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.pageLoadingState.value == VideoDetailPageLoadingState.loadingVideoInfo || controller.pageLoadingState.value == VideoDetailPageLoadingState.loadingAll) {
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
            const SizedBox(height: UIConstants.sectionSpacing),
            _buildVideoDetailsSection(context),
            const SafeArea(child: SizedBox.shrink()),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        if (controller.videoInfo.value?.title?.isNotEmpty == true)
          IconButton(
            icon: const Icon(Icons.translate, size: 20),
            padding: const EdgeInsets.only(left: 8),
            constraints: const BoxConstraints(),
            onPressed: () => Get.dialog(
              TranslationDialog(text: controller.videoInfo.value!.title!),
            ),
          ),
      ],
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => NaviService.navigateToAuthorProfilePage(
              controller.videoInfo.value!.user!.username,
            ),
            child: AvatarWidget(user: controller.videoInfo.value?.user, size: 40),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(
                controller.videoInfo.value!.user!.username,
              ),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildUserName(
                    context,
                    controller.videoInfo.value?.user,
                    fontSize: 16,
                    bold: true,
                  ),
                  Text(
                    '@${controller.videoInfo.value?.user?.username ?? ''}',
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
          ),
        ),
        if (controller.videoInfo.value?.user != null)
          SizedBox(
            height: 32,
            child: FollowButtonWidget(
              user: controller.videoInfo.value!.user!,
              onUserUpdated: (updatedUser) {
                controller.videoInfo.value = controller.videoInfo.value
                    ?.copyWith(user: updatedUser);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVideoDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 视频统计信息卡片
        _buildVideoStatsCard(context),
        const SizedBox(height: UIConstants.interElementSpacing),

        // 视频描述
        _buildVideoDescriptionSection(context),
        const SizedBox(height: UIConstants.interElementSpacing),

        // 视频标签
        _buildVideoTagsSection(context),
        const SizedBox(height: UIConstants.interElementSpacing),

        // Oreno3D信息区域
        _buildOreno3dSection(context),
        const SizedBox(height: UIConstants.interElementSpacing),

        // 点赞头像区域
        _buildLikeAvatarsSection(context),
        const SizedBox(height: UIConstants.sectionSpacing),

        // 操作按钮区域
        _buildActionButtonsSection(context),
      ],
    );
  }

  Widget _buildVideoStatsCard(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final videoInfo = controller.videoInfo.value;
      if (videoInfo == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${t.galleryDetail.publishedAt}：${CommonUtils.formatFriendlyTimestamp(videoInfo.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${CommonUtils.formatFriendlyNumber(videoInfo.numViews)} ${t.galleryDetail.viewsCount}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (videoInfo.file?.duration != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      CommonUtils.formatDuration(
                        Duration(seconds: videoInfo.file!.duration!),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildVideoDescriptionSection(BuildContext context) {
    return Obx(() {
      final description = controller.videoInfo.value?.body;
      if (description == null || description.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          VideoDescriptionWidget(
            description: description,
            isDescriptionExpanded: controller.isDescriptionExpanded,
            onToggleDescription: controller.isDescriptionExpanded.toggle,
          ),
        ],
      );
    });
  }

  Widget _buildVideoTagsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final tags = controller.videoInfo.value?.tags;
      if (tags == null || tags.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                t.common.iwaraTags,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExpandableTagsWidget(
            tags: tags,
            onTagTap: (tag) {
              // 点击标签跳转到标签视频列表页面
              NaviService.navigateToTagVideoListPage(tag);
            },
          ),
        ],
      );
    });
  }

  Widget _buildOreno3dSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final oreno3dDetail = controller.oreno3dVideoDetail.value;
      final isMatching = controller.isOreno3dMatching.value;


      // 如果正在匹配，显示 loading
      if (isMatching) {
        return _buildOreno3dLoadingSection(context);
      }

      // 如果没有匹配到且不在匹配中，不显示
      if (oreno3dDetail == null && !isMatching) {
        return const SizedBox.shrink();
      }

      // 检查是否有实际内容可显示（原作、标签、角色）
      if (oreno3dDetail != null) {
        final hasOrigin = oreno3dDetail.origin != null;
        final hasTags = oreno3dDetail.tags.isNotEmpty;
        final hasCharacters = oreno3dDetail.characters.isNotEmpty;
        
        // 如果三者都为空，也不显示
        if (!hasOrigin && !hasTags && !hasCharacters) {
          return const SizedBox.shrink();
        }
      }

      // 有数据时显示内容
      return oreno3dDetail != null ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.view_in_ar, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                t.oreno3d.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showOreno3dInfoDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.help_outline,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 原作信息
                  if (oreno3dDetail.origin != null) ...[
                    Text(
                      t.oreno3d.origin,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleOreno3dSearch(
                          oreno3dDetail.origin!.id ?? oreno3dDetail.origin!.name,
                          'origin',
                          oreno3dDetail.origin!.name,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              oreno3dDetail.origin!.name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Oreno3D标签
                  if (oreno3dDetail.tags.isNotEmpty) ...[
                    if (oreno3dDetail.origin != null)
                      const SizedBox(height: 12),
                    Text(
                      t.oreno3d.tags,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: oreno3dDetail.tags.map((tag) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleOreno3dSearch(
                              tag.id ?? tag.name,
                              'tag',
                              tag.name,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.purple.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  tag.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // 角色信息
                  if (oreno3dDetail.characters.isNotEmpty) ...[
                    if (oreno3dDetail.tags.isNotEmpty || oreno3dDetail.origin != null)
                      const SizedBox(height: 12),
                    Text(
                      // 'キャラ：',
                      t.oreno3d.characters,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: oreno3dDetail.characters.map((character) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleOreno3dSearch(
                              character.id ?? character.name,
                              'character',
                              character.name,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  character.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ) : const SizedBox.shrink();
    });
  }

  /// 构建 Oreno3D 加载状态的 Widget
  Widget _buildOreno3dLoadingSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.view_in_ar, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              t.oreno3d.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showOreno3dInfoDialog(context),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.help_outline,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Shimmer loading 效果
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 模拟原作信息
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 30,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 70,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 模拟标签信息
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 25,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 65,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 45,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 模拟角色信息
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 25,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 55,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLikeAvatarsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final videoId = controller.videoInfo.value?.id;
      if (videoId == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                t.common.likeThisVideo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: LikeAvatarsWidget(
              mediaId: videoId,
              mediaType: MediaType.VIDEO,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButtonsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final videoInfo = controller.videoInfo.value;
    if (videoInfo == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.build, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              t.common.operation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButtons(context),
      ],
    );
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
          onLike: (id) async =>
              (await Get.find<VideoService>().likeVideo(id)).isSuccess,
          onUnlike: (id) async =>
              (await Get.find<VideoService>().unlikeVideo(id)).isSuccess,
          onLikeChanged: (liked) {
            controller.videoInfo.value = controller.videoInfo.value?.copyWith(
              liked: liked,
              numLikes:
                  (controller.videoInfo.value?.numLikes ?? 0) +
                  (liked ? 1 : -1),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.playlist_add,
          label: t.common.playList,
          onTap: () {
            final UserService userService = Get.find();
            if (!userService.isLogin) {
              showToastWidget(
                MDToastWidget(
                  message: t.errors.pleaseLoginFirst,
                  type: MDToastType.error,
                ),
                position: ToastPosition.bottom,
              );
              Get.toNamed(Routes.LOGIN);
            } else {
              Get.dialog(
                AddVideoToPlayListDialog(
                  videoId: controller.videoInfo.value?.id ?? '',
                ),
              );
            }
          },
        ),
        _buildActionButton(
          icon: Icons.bookmark_border,
          label: t.favorite.localizeFavorite,
          onTap: () => _addToFavorite(context, videoInfo),
        ),
        _buildActionButton(
          icon: Icons.download,
          label: t.common.download,
          onTap: () => _showDownloadDialog(context), // Call the new method
        ),
        _buildActionButton(
          icon: Icons.share,
          label: t.common.share,
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => ShareVideoBottomSheet(
                videoId: controller.videoInfo.value?.id ?? '',
                videoTitle: controller.videoInfo.value?.title ?? '',
                authorName: controller.videoInfo.value?.user?.name ?? '',
                previewUrl: controller.videoInfo.value?.previewUrl ?? '',
              ),
              context: context,
            );
          },
        ),
      ],
    );
  }

  /// Reusable widget for creating action buttons to reduce code duplication.
  Widget _buildActionButton({
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
                style: TextStyle(
                  fontSize: 14,
                  color: Get.theme.textTheme.bodyMedium?.color,
                ),
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
        onAdd: (folderId) =>
            FavoriteService.to.addVideoToFolder(videoInfo, folderId),
      ),
    );
  }

  // 获取视频的下载地址
  Future<String?> _getSavePath(
    String title,
    String quality,
    String downloadUrl,
  ) async {
    // 使用下载路径服务
    final downloadPathService = Get.find<DownloadPathService>();

    // 创建临时视频对象用于路径生成
    final video = Video(
      id: controller.videoInfo.value?.id ?? 'unknown',
      title: title,
      user: controller.videoInfo.value?.user,
    );

    return await downloadPathService.getVideoDownloadPath(
      video: video,
      quality: quality,
      downloadUrl: downloadUrl,
    );
  }

  void _showDownloadDialog(BuildContext context) {
    LogUtils.d('尝试显示下载对话框', 'VideoInfoTabWidget'); // Changed tag for clarity
    final t = slang.Translations.of(context);
    final sources = controller.currentVideoSourceList;

    if (sources.isEmpty) {
      LogUtils.w('没有可用的下载源', 'VideoInfoTabWidget');
      showToastWidget(
        MDToastWidget(
          message: t.download.errors.noDownloadSourceNowPleaseWaitInfoLoaded,
          type: MDToastType.error,
        ),
      );
      return;
    }
    final UserService userService = Get.find();
    if (!userService.isLogin) {
      LogUtils.w('用户未登录，无法下载', 'VideoInfoTabWidget');
      showToastWidget(
        MDToastWidget(
          message: t.errors.pleaseLoginFirst,
          type: MDToastType.error,
        ),
      );
      Get.toNamed(Routes.LOGIN);
      return;
    }

    try {
      Get.dialog(
        AlertDialog(
          title: Text(t.common.selectQuality),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: sources.map((source) {
              return ListTile(
                title: Text(source.name ?? t.download.errors.unknown),
                onTap: () async {
                  LogUtils.d('选择下载质量: ${source.name}', 'VideoInfoTabWidget');
                  AppService.tryPop();

                  if (source.download == null) {
                    LogUtils.w('所选质量没有下载链接', 'VideoInfoTabWidget');
                    showToastWidget(
                      MDToastWidget(
                        message: t.videoDetail.noDownloadUrl,
                        type: MDToastType.error,
                      ),
                      position: ToastPosition.top,
                    );
                    return;
                  }

                  try {
                    final videoInfo = controller.videoInfo.value;
                    if (videoInfo == null) {
                      LogUtils.e('下载失败：视频信息为空', tag: 'VideoInfoTabWidget');
                      throw Exception(t.download.errors.videoInfoNotFound);
                    }

                    // 创建视频下载的额外信息
                    final videoExtData = VideoDownloadExtData(
                      id: videoInfo.id,
                      title: videoInfo.title,
                      thumbnail: videoInfo.thumbnailUrl,
                      authorName: videoInfo.user?.name,
                      authorUsername: videoInfo.user?.username,
                      authorAvatar: videoInfo.user?.avatar?.avatarUrl,
                      duration: videoInfo.file?.duration,
                      quality: source.name,
                    );
                    LogUtils.d('创建下载任务元数据', 'VideoInfoTabWidget');

                    // 在创建下载任务之前获取保存路径
                    final savePath = await _getSavePath(
                      videoInfo.title ?? 'video',
                      source.name ?? 'unknown',
                      source.download ?? 'unknown',
                    );

                    if (savePath == null) {
                      LogUtils.d('用户取消了下载操作', 'VideoInfoTabWidget');
                      showToastWidget(
                        MDToastWidget(
                          message: t.common.operationCancelled,
                          type: MDToastType.info,
                        ),
                      );
                      return;
                    }

                    final task = DownloadTask(
                      url: source.download!,
                      savePath: savePath,
                      fileName:
                          '${videoInfo.title ?? 'video'}_${source.name}.mp4',
                      supportsRange: true,
                      extData: DownloadTaskExtData(
                        type: DownloadTaskExtDataType.video,
                        data: videoExtData.toJson(),
                      ),
                    );
                    LogUtils.d('添加下载任务: ${task.id}', 'VideoInfoTabWidget');

                    await DownloadService.to.addTask(task);

                    showToastWidget(
                      MDToastWidget(
                        message: t.videoDetail.startDownloading,
                        type: MDToastType.success,
                      ),
                      position: ToastPosition.top,
                    );

                    // 打开下载管理页面
                    NaviService.navigateToDownloadTaskListPage();
                  } catch (e) {
                    LogUtils.e(
                      '添加下载任务失败: $e',
                      tag: 'VideoInfoTabWidget',
                      error: e,
                    );
                    String message;
                    if (e.toString().contains(
                      t.download.errors.downloadTaskAlreadyExists,
                    )) {
                      message = t.download.errors.downloadTaskAlreadyExists;
                    } else if (e.toString().contains(
                      t.download.errors.videoAlreadyDownloaded,
                    )) {
                      message = t.download.errors.videoAlreadyDownloaded;
                    } else {
                      message = t.download.errors.downloadFailed;
                    }

                    showToastWidget(
                      MDToastWidget(message: message, type: MDToastType.error),
                      position: ToastPosition.top,
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      LogUtils.e('显示下载对话框失败', error: e, tag: 'VideoInfoTabWidget');
    }
  }

  void _showOreno3dInfoDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.oreno3d.name),
        content: SizedBox(
          width: double.maxFinite,
          child: MarkdownWidget(
            data: t.oreno3d.thirdPartyTagsExplanation,
            shrinkWrap: true,
            selectable: true,
            config: MarkdownConfig(
              configs: [
                const PConfig(
                  textStyle: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton.icon(
            onPressed: () async {
              const url = 'https://github.com/FoxSensei001/oreno3d_i18n';
              try {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                }
              } catch (e) {
                LogUtils.e('打开链接失败', error: e, tag: 'VideoInfoTabWidget');
              }
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(t.common.visit),
          ),
        ],
      ),
    );
  }

  /// 处理 Oreno3D 搜索点击事件
  /// 处理 Oreno3D 搜索点击事件
  void _handleOreno3dSearch(String id, String type, String name) {
    LogUtils.d('Oreno3D 搜索: id=$id, type=$type, name=$name', 'VideoInfoTabWidget');

    // 跳转到搜索页面，自动选择 oreno3d 模式
    // 传递空的搜索关键词，通过 extData 传递 ID 和类型信息
    NaviService.toSearchPage(
      searchInfo: '',
      segment: 'oreno3d',
      extData: {
        'searchType': type,
        'id': id,
        'name': name, // 传递标签名
      },
    );
  }
}
