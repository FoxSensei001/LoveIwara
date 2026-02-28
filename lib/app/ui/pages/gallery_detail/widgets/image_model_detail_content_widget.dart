import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/share_gallery_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../common/enums/media_enums.dart';
import '../../../../services/app_service.dart';
import '../../popular_media_list/widgets/media_description_widget.dart';
import '../../video_detail/widgets/detail/expandable_section_widget.dart';
import '../../video_detail/widgets/detail/tags_display_widget.dart';
import '../../video_detail/widgets/detail/like_avatars_widget.dart';
import '../controllers/gallery_detail_controller.dart';
import '../../../widgets/follow_button_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/split_button_widget.dart'
    show FilledActionButton, FilledLikeButton;
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildGalleryTitle(),
            if (showHeader) _buildAuthorInfo(context),
            if (showHeader)
              const SizedBox(height: UIConstants.sectionSpacing),
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

        return RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: title),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    onPressed: () {
                      showTranslationDialog(context, text: title);
                    },
                    icon: Icon(
                      Icons.translate,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
        );
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
    final t = slang.Translations.of(context);
    return Obx(() {
      final tags = controller.imageModelInfo.value?.tags;
      if (tags == null || tags.isEmpty) return const SizedBox.shrink();

      return ExpandableSectionWidget(
        title: t.common.iwaraTags,
        icon: Icons.label,
        child: TagsDisplayWidget(
          tags: tags,
          onTagTap: (tag) {
            // 点击标签跳转到标签图库列表页
            NaviService.navigateToTagGalleryListPage(tag);
          },
        ),
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
        FilledActionButton(
          icon: Icons.download,
          label: t.download.download,
          onTap: () => _downloadGallery(context),
          // 下载作为主操作，默认高亮；已有下载任务时保持高亮状态。
          accentColor: Theme.of(context).primaryColor,
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
                controller.imageModelInfo.value = controller
                    .imageModelInfo
                    .value
                    ?.copyWith(
                      liked: liked,
                      numLikes:
                          (controller.imageModelInfo.value?.numLikes ?? 0) +
                          (liked ? 1 : -1),
                    );
              },
            ),
            Obx(
              () => FilledActionButton(
                icon: controller.isInAnyFavorite.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: t.favorite.localizeFavorite,
                onTap: () => _addToFavorite(context),
                accentColor: controller.isInAnyFavorite.value
                    ? Theme.of(context).primaryColor
                    : null,
              ),
            ),
            FilledActionButton(
              icon: Icons.share,
              label: slang.t.common.share,
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
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

  // 下载图库
  void _downloadGallery(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final imageModel = controller.imageModelInfo.value;
      if (imageModel == null) {
        showToastWidget(
          MDToastWidget(
            message: t.download.errors.imageModelNotFound,
            type: MDToastType.error,
          ),
        );
        return;
      }

      // 创建下载任务的扩展数据
      final extData = GalleryDownloadExtData(
        id: imageModel.id,
        title: imageModel.title,
        previewUrls: imageModel.files
            .take(3)
            .map((e) => e.getLargeImageUrl())
            .toList(),
        authorName: imageModel.user?.name,
        authorUsername: imageModel.user?.username,
        authorAvatar: imageModel.user?.avatar?.avatarUrl,
        totalImages: imageModel.files.length,
        imageList: {
          for (var e in imageModel.files) e.id: e.getOriginalImageUrl(),
        },
        localPaths: {},
      );

      // 创建下载任务
      final savePath = await _getSavePath(imageModel.title, imageModel.id);
      if (savePath == null) {
        showToastWidget(
          MDToastWidget(
            message: t.common.operationCancelled,
            type: MDToastType.info,
          ),
        );
        return;
      }
      final task = DownloadTask(
        url: imageModel.files.first.getOriginalImageUrl(), // 使用第一张图片的URL
        downloadedBytes: 0, // 已下载图片数量
        totalBytes: imageModel.files.length, // 总图片数量
        savePath: savePath, // 保存路径 [下载文件夹/galleries/图库标题_图库id]
        fileName: '${imageModel.title}_${imageModel.id}', // 文件名
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: extData.toJson(),
        ),
        mediaType: 'gallery',
        mediaId: imageModel.id,
      );

      await DownloadService.to.addTask(task);

      // 标记图库有下载任务
      controller.markGalleryHasDownloadTask();

      showToastWidget(
        MDToastWidget(
          message: t.download.startDownloading,
          type: MDToastType.success,
        ),
      );

      // 打开下载管理页面
      NaviService.navigateToDownloadTaskListPage();
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'ImageModelDetailContent', error: e);
      showToastWidget(
        MDToastWidget(
          message: t.download.errors.downloadFailed,
          type: MDToastType.error,
        ),
      );
    }
  }

  // 获取保存路径
  Future<String?> _getSavePath(String title, String id) async {
    // 使用下载路径服务
    final downloadPathService = Get.find<DownloadPathService>();

    // 创建临时图库对象用于路径生成
    final imageModel = controller.imageModelInfo.value;
    final gallery = ImageModel(
      id: id,
      title: title,
      user: imageModel?.user,
      files: imageModel?.files ?? [],
    );

    return await downloadPathService.getGalleryDownloadPath(gallery: gallery);
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
