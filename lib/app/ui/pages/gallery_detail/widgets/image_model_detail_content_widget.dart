import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/translatable_title.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/share_gallery_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/download/media_download_launcher.dart';

import '../../../../../common/enums/media_enums.dart';
import '../../../../services/app_service.dart';
import '../../popular_media_list/widgets/media_description_widget.dart';
import '../../video_detail/widgets/detail/iwara_tags_section.dart';
import '../../video_detail/widgets/detail/like_avatars_widget.dart';
import '../controllers/gallery_detail_controller.dart';
import '../../../widgets/follow_button_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/split_button_widget.dart'
    show FilledActionButton, FilledLikeButton;
import 'package:i_iwara/app/ui/widgets/watch_later_action_button.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/add_to_favorite_dialog.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';

class ImageModelDetailContent extends StatelessWidget {
  final GalleryDetailController controller;
  final bool showHeader;

  const ImageModelDetailContent({
    super.key,
    required this.controller,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [_buildGalleryDetails(context)],
    );
  }

  // 构建图库详情区域
  Widget _buildGalleryDetails(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildGalleryTitle(),
            if (showHeader) _buildAuthorInfo(context),
            if (showHeader) const SizedBox(height: UIConstants.sectionSpacing),
            _buildGalleryDetailsSection(context),
          ],
        ),
      );
    });
  }

  // 构建图库详情区域（对齐视频详情页结构）
  Widget _buildGalleryDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图库统计信息卡片
        _buildGalleryStatsCard(context),

        // 图库描述
        _buildGalleryDescriptionSection(context),
        const SizedBox(height: UIConstants.sectionSpacing),

        // 操作按钮区域（紧跟个人简介）
        _buildActionButtonsSection(context),
        const SizedBox(height: UIConstants.sectionSpacing),

        // 图库标签
        _buildTagsSection(context),
        const SizedBox(height: UIConstants.sectionSpacing),

        // 点赞头像区域
        _buildLikeAvatarsSection(context),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(UIConstants.cardPadding),
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }

  // 构建图库标题（对齐视频详情页）
  Widget _buildGalleryTitle() {
    return Builder(
      builder: (context) {
        final title = controller.imageModelInfo.value?.title ?? '';
        if (title.isEmpty) {
          return const SizedBox.shrink();
        }

        final textStyle = TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        );

        // 复用视频详情页的标题组件：内联翻译按钮改用裸 Icon + GestureDetector
        // 实现的可点击区域，而不是这里原先的 IconButton（padding/constraints
        // 即便置零也仍带内部留白，跟文字内联时按钮明显偏大，两页大小对不齐）。
        return TranslatableTitle(text: title, style: textStyle);
      },
    );
  }

  // 构建作者信息区域（对齐视频详情页）
  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => NaviService.navigateToAuthorProfilePage(
              controller.imageModelInfo.value!.user!.username,
              initialUser: controller.imageModelInfo.value!.user!,
            ),
            child: AvatarWidget(
              user: controller.imageModelInfo.value?.user,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: UIConstants.pagePadding),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(
                controller.imageModelInfo.value!.user!.username,
                initialUser: controller.imageModelInfo.value!.user!,
              ),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildUserName(
                    context,
                    controller.imageModelInfo.value?.user,
                    fontSize: 16,
                    bold: true,
                  ),
                  Text(
                    '@${controller.imageModelInfo.value?.user?.username ?? ''}',
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
        if (controller.imageModelInfo.value?.user != null)
          SizedBox(
            height: 32,
            child: FollowButtonWidget(
              user: controller.imageModelInfo.value!.user!,
              onUserUpdated: (updatedUser) {
                controller.imageModelInfo.value = controller
                    .imageModelInfo
                    .value
                    ?.copyWith(user: updatedUser);
              },
            ),
          ),
      ],
    );
  }

  // 构建图库统计信息卡片（对齐视频详情页）
  Widget _buildGalleryStatsCard(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final imageModelInfo = controller.imageModelInfo.value;
      if (imageModelInfo == null) return const SizedBox.shrink();

      return _buildSectionCard(
        context,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: UIConstants.iconTextSpacing),
                      Text(
                        '${t.galleryDetail.publishedAt}：${CommonUtils.formatFriendlyTimestamp(imageModelInfo.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.smallSpacing),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: UIConstants.iconTextSpacing),
                      Text(
                        '${CommonUtils.formatFriendlyNumber(imageModelInfo.numViews.toInt())} ${t.galleryDetail.viewsCount}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // 构建图库描述（对齐视频详情页）
  Widget _buildGalleryDescriptionSection(BuildContext context) {
    return Obx(() {
      final description = controller.imageModelInfo.value?.body;
      if (description == null || description.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UIConstants.listSpacing),
          _buildSectionCard(
            context,
            child: MediaDescriptionWidget(
              description: description,
              isDescriptionExpanded: controller.isDescriptionExpanded,
            ),
          ),
        ],
      );
    });
  }

  // 构建标签区域（对齐视频详情页）
  Widget _buildTagsSection(BuildContext context) {
    return Obx(() {
      final tags = controller.imageModelInfo.value?.tags;
      if (tags == null || tags.isEmpty) return const SizedBox.shrink();

      return IwaraTagsSection(
        tags: tags,
        onTagTap: (tag) {
          // 点击标签跳转到标签图库列表页
          NaviService.navigateToTagGalleryListPage(tag);
        },
      );
    });
  }

  // 构建点赞用户头像区域（对齐视频详情页）
  Widget _buildLikeAvatarsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final imageModelId = controller.imageModelInfo.value?.id;
      if (imageModelId == null) return const SizedBox.shrink();

      return _buildSectionCard(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                const SizedBox(width: UIConstants.iconTextSpacing),
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
            const SizedBox(height: UIConstants.listSpacing),
            SizedBox(
              height: 40,
              child: LikeAvatarsWidget(
                mediaId: imageModelId,
                mediaType: MediaType.IMAGE,
              ),
            ),
          ],
        ),
      );
    });
  }

  // 构建操作按钮区域（对齐视频详情页）
  Widget _buildActionButtonsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final imageModelInfo = controller.imageModelInfo.value;
    if (imageModelInfo == null) return const SizedBox.shrink();

    return _buildSectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build, size: 16, color: Colors.grey[600]),
              const SizedBox(width: UIConstants.iconTextSpacing),
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
          const SizedBox(height: UIConstants.interElementSpacing),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // 构建操作按钮（对齐视频详情页）
  Widget _buildActionButtons(BuildContext context) {
    final t = slang.Translations.of(context);
    final imageModelInfo = controller.imageModelInfo.value;
    if (imageModelInfo == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => FilledActionButton(
            icon: Icons.download,
            label: t.download.download,
            onTap: () => launchGalleryDownload(
              context,
              gallery: imageModelInfo,
              onTaskCreated: controller.markGalleryHasDownloadTask,
            ),
            // 用 colorScheme.primary，不用 Theme.of(context).primaryColor——
            // primaryColor 是 M2 遗留字段，M3 深色主题下它不跟随 colorScheme
            // 翻转，选中态的图标/文字会退化成近黑色，糊在深色卡片上看不清。
            accentColor: controller.hasAnyDownloadTask.value
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        const SizedBox(height: UIConstants.listSpacing),
        Wrap(
          spacing: UIConstants.listSpacing, // Horizontal space between buttons
          runSpacing: UIConstants.listSpacing, // Vertical space between rows
          children: [
            FilledLikeButton(
              mediaId: imageModelInfo.id,
              liked: imageModelInfo.liked,
              likeCount: imageModelInfo.numLikes,
              onLike: (id) async {
                final result = await Get.find<GalleryService>().likeImage(id);
                return result.isSuccess;
              },
              onUnlike: (id) async {
                final result = await Get.find<GalleryService>().unlikeImage(id);
                return result.isSuccess;
              },
              onLikeChanged: (liked) {
                final updatedLikeCount =
                    (controller.imageModelInfo.value?.numLikes ?? 0) +
                    (liked ? 1 : -1);
                final normalizedLikeCount = updatedLikeCount < 0
                    ? 0
                    : updatedLikeCount;
                controller.imageModelInfo.value = controller
                    .imageModelInfo
                    .value
                    ?.copyWith(liked: liked, numLikes: normalizedLikeCount);
                try {
                  controller.extData?[NaviService.mediaLikePatchLikedKey] =
                      liked;
                  controller.extData?[NaviService.mediaLikePatchCountKey] =
                      normalizedLikeCount;
                } catch (_) {}
              },
            ),
            // 「稍后再看」摆在本地收藏前面：两者都是"先存起来"，但稍后再看是
            // 临时队列、收藏是长期归档，前者用得更频（与视频详情页同序）。
            WatchLaterActionButton(gallery: imageModelInfo),
            Obx(
              () => FilledActionButton(
                icon: controller.isInAnyFavorite.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: t.favorite.localizeFavorite,
                onTap: () => _addToFavorite(context),
                // 同上：M3 深色主题下必须走 colorScheme.primary。
                accentColor: controller.isInAnyFavorite.value
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            FilledActionButton(
              icon: Icons.share,
              label: slang.t.common.share,
              onTap: () {
                showGlassBottomSheet(
                  builder: (context) {
                    // Ensure imageModelInfo is not null before accessing its properties
                    final info = controller.imageModelInfo.value;
                    if (info == null) {
                      return const SizedBox.shrink(); // Or return an error/placeholder
                    }
                    return ShareGalleryBottomSheet(
                      galleryId: info.id,
                      galleryTitle: info.title,
                      authorName: info.user?.name ?? '',
                      previewUrl: info.thumbnailUrl,
                    );
                  },
                  context: context,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // 添加到收藏夹
  void _addToFavorite(BuildContext context) {
    final imageModelInfo = controller.imageModelInfo.value;
    if (imageModelInfo == null) return;

    showAppDialog(
      AddToFavoriteDialog(
        itemId: imageModelInfo.id,
        onAdd: (folderId) async {
          return await FavoriteService.to.addImageToFolder(
            imageModelInfo,
            folderId,
          );
        },
      ),
    ).then((_) {
      // 对话框关闭后刷新收藏状态
      controller.checkFavoriteStatus();
    });
  }
}
