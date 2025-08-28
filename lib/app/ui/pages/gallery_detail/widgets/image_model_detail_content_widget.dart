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
import '../../video_detail/widgets/detail/expandable_tags_widget.dart';
import '../../video_detail/widgets/detail/like_avatars_widget.dart';
import '../controllers/gallery_detail_controller.dart';
import '../../../widgets/follow_button_widget.dart';
import '../../../widgets/like_button_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/add_to_favorite_dialog.dart';

class ImageModelDetailContent extends StatelessWidget {
  final GalleryDetailController controller;

  const ImageModelDetailContent({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGalleryDetails(context),
      ],
    );
  }

  // 构建图库详情区域
  Widget _buildGalleryDetails(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildGalleryTitle(),
          const SizedBox(height: 8),
          _buildAuthorInfo(context),
          const SizedBox(height: 8),
          _buildPublishInfo(),
          const SizedBox(height: 12),
          _buildGalleryDescription(),
          const SizedBox(height: 12),
          _buildTags(),
          const SizedBox(height: 12),
          _buildLikeAvatars(),
          const SizedBox(height: 12),
          _buildLikeAndCommentButtons(context),
        ],
      );
    });
  }

  // 构建图库标题
  Widget _buildGalleryTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题文本
          Expanded(
            child: SelectableText(
              controller.imageModelInfo.value?.title ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          // 翻译按钮
          if (controller.imageModelInfo.value?.title.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.translate, size: 20),
              onPressed: () {
                Get.dialog(
                  TranslationDialog(
                    text: controller.imageModelInfo.value!.title,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 构建作者信息区域
  Widget _buildAuthorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildAuthorAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAuthorNameButton(context),
          ),
          if (controller.imageModelInfo.value?.user != null)
            SizedBox(
              height: 32,
              child: FollowButtonWidget(
                user: controller.imageModelInfo.value!.user!,
                onUserUpdated: (updatedUser) {
                  controller.imageModelInfo.value = controller.imageModelInfo.value?.copyWith(
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
          final user = controller.imageModelInfo.value?.user;
          if (user != null) {
            NaviService.navigateToAuthorProfilePage(user.username);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AvatarWidget(
          user: controller.imageModelInfo.value?.user,
          size: 40
        ),
      ),
    );

  }

  // 构建作者名字按钮
  Widget _buildAuthorNameButton(BuildContext context) {
    final user = controller.imageModelInfo.value?.user;
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

  // 构建发布时间和观看次数
  Widget _buildPublishInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        '${slang.t.galleryDetail.publishedAt}: ${CommonUtils.formatFriendlyTimestamp(controller.imageModelInfo.value?.createdAt)}    ${slang.t.galleryDetail.viewsCount}: ${CommonUtils.formatFriendlyNumber(controller.imageModelInfo.value?.numViews.toInt() ?? 0)}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
    );
  }

  // 构建图库描述
  Widget _buildGalleryDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MediaDescriptionWidget(
        description: controller.imageModelInfo.value?.body,
        isDescriptionExpanded: controller.isDescriptionExpanded,
      ),
    );
  }

  // 构建标签区域
  Widget _buildTags() {
    final tags = controller.imageModelInfo.value?.tags;
    if (tags != null && tags.isNotEmpty) {
      return ExpandableTagsWidget(
        tags: tags,
        onTagTap: (tag) {
          // 点击标签跳转到标签图库列表页
          NaviService.navigateToTagGalleryListPage(tag);
        },
      );
    }
    return const SizedBox.shrink();
  }

  // 构建点赞用户头像区域
  Widget _buildLikeAvatars() {
    final imageModelId = controller.imageModelInfo.value?.id;
    if (imageModelId != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 40,
          child: LikeAvatarsWidget(
              mediaId: imageModelId, mediaType: MediaType.IMAGE),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 构建点赞和评论按钮区域
  Widget _buildLikeAndCommentButtons(BuildContext context) {
    final t = slang.Translations.of(context);
    final imageModelInfo = controller.imageModelInfo.value;
    if (imageModelInfo != null) {
      return Builder(
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                LikeButtonWidget(
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
                    controller.imageModelInfo.value = controller.imageModelInfo.value?.copyWith(
                      liked: liked,
                      numLikes: (controller.imageModelInfo.value?.numLikes ?? 0) + (liked ? 1 : -1),
                    );
                  },
                ),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _addToFavorite(context),
                    borderRadius: BorderRadius.circular(20),
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
                    onTap: () => _downloadGallery(context),
                    borderRadius: BorderRadius.circular(20),
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
                            t.download.download,
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
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) {
                          // Ensure imageModelInfo is not null before accessing its properties
                          final info = controller.imageModelInfo.value;
                          if (info == null) return const SizedBox.shrink(); // Or return an error/placeholder
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
                            slang.t.common.share,
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
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 下载图库
  void _downloadGallery(BuildContext context) async {

    final t = slang.Translations.of(context);
    try {
      final imageModel = controller.imageModelInfo.value;
      if (imageModel == null) {
        showToastWidget(MDToastWidget(
            message: t.download.errors.imageModelNotFound,
            type: MDToastType.error));
        return;
      }

      // 创建下载任务的扩展数据
      final extData = GalleryDownloadExtData(
        id: imageModel.id,
        title: imageModel.title,
        previewUrls: imageModel.files.take(3).map((e) => e.getLargeImageUrl()).toList(),
        authorName: imageModel.user?.name,
        authorUsername: imageModel.user?.username,
        authorAvatar: imageModel.user?.avatar?.avatarUrl,
        totalImages: imageModel.files.length,
        imageList: {
          for (var e in imageModel.files) 
            e.id: e.getOriginalImageUrl(),
        },
        localPaths: {},
      );

      // 创建下载任务
      final savePath = await _getSavePath(imageModel.title, imageModel.id);
      if (savePath == null) {
        showToastWidget(MDToastWidget(
            message: t.common.operationCancelled,
            type: MDToastType.info));
        return;
      }
      final task = DownloadTask(
        url: imageModel.files.first.getOriginalImageUrl(), // 使用第一张图片的URL
        downloadedBytes: 0, // 已下载图片数量
        totalBytes: imageModel.files.length, // 总图片数量
        savePath: savePath,  // 保存路径 [下载文件夹/galleries/图库标题_图库id]
        fileName: '${imageModel.title}_${imageModel.id}', // 文件名
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: extData.toJson(),
        ),
      );

      await DownloadService.to.addTask(task);

      showToastWidget(MDToastWidget(
          message: t.download.startDownloading,
          type: MDToastType.success));

      // 打开下载管理页面
      NaviService.navigateToDownloadTaskListPage();
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'ImageModelDetailContent', error: e);
      showToastWidget(MDToastWidget(
          message: t.download.errors.downloadFailed,
          type: MDToastType.error));
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

    Get.dialog(
      AddToFavoriteDialog(
        itemId: imageModelInfo.id,
        onAdd: (folderId) async {
          return await FavoriteService.to.addImageToFolder(imageModelInfo, folderId);
        },
      ),
    );
  }
}
