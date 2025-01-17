import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/share_gallery_bottom_sheet.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;

import '../../../../../common/constants.dart';
import '../../../../../common/enums/media_enums.dart';
import '../../../../models/image.model.dart';
import '../../../../services/app_service.dart';
import '../../../widgets/error_widget.dart';
import '../../popular_media_list/widgets/media_description_widget.dart';
import '../../video_detail/widgets/detail/expandable_tags_widget.dart';
import '../../video_detail/widgets/detail/like_avatars_widget.dart';
import '../controllers/gallery_detail_controller.dart';
import 'horizontial_image_list.dart';
import '../../../widgets/follow_button_widget.dart';
import '../../../widgets/like_button_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ImageModelDetailContent extends StatelessWidget {
  final GalleryDetailController controller;
  final double paddingTop;
  final double? imageModelHeight;
  final double? imageModelWidth;

  const ImageModelDetailContent({
    super.key,
    required this.controller,
    required this.paddingTop,
    this.imageModelHeight,
    this.imageModelWidth,
  });

  // 构建图像库内容的布局
  Widget _contentLayout(BuildContext context, Widget child) {
    return Column(
      children: [
        _buildPaddingTop(),
        _buildHeader(context),
        _buildImageContent(context, child),
      ],
    );
  }

  // 构建顶部的透明间距
  Widget _buildPaddingTop() {
    return Container(
      height: paddingTop,
      color: Colors.transparent,
    );
  }

  // 构建标题栏，包括返回按钮和标题
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // 主页
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            AppService appService = Get.find();
            int currentIndex = appService.currentIndex;
            final routes = [
              Routes.POPULAR_VIDEOS,
              Routes.GALLERY,
              Routes.SUBSCRIPTIONS,
            ];
            AppService.homeNavigatorKey.currentState!.pushNamedAndRemoveUntil(
                routes[currentIndex], (route) => false);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            controller.imageModelInfo.value?.title ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 构建图片内容部分，主要是显示图库图片
  Widget _buildImageContent(BuildContext context, Widget child) {
    return SizedBox(
      width: imageModelWidth,
      height: (imageModelHeight ?? MediaQuery.sizeOf(context).width / 1.7),
      child: child.paddingHorizontal(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGalleryArea(context),
        _buildGalleryDetails(context),
      ],
    );
  }

  // 构建图库区域，显示图片和加载错误信息
  Widget _buildGalleryArea(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Obx(() {
            if (controller.errorMessage.value != null) {
              return _buildErrorContent(context);
            }
            return _buildImageListContent(context);
          }),
        ],
      ),
    );
  }

  // 构建错误信息区域
  Widget _buildErrorContent(BuildContext context) {
    final t = slang.Translations.of(context);
    return CommonErrorWidget(
      text: controller.errorMessage.value ?? t.errors.errorWhileLoadingGallery,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.back),
        ),
        ElevatedButton(
          onPressed: () => controller.fetchGalleryDetail(),
          child: Text(t.common.retry),
        ),
      ],
    );
  }

  // 构建图片列表内容
  Widget _buildImageListContent(BuildContext context) {
    ImageModel? im = controller.imageModelInfo.value;
    final t = slang.Translations.of(context);
    if (im == null) {
      return _contentLayout(
          context, MyEmptyWidget(message: t.errors.howCouldThereBeNoDataItCantBePossible));
    }

    List<ImageItem> imageItems = im.files
        .map((e) => ImageItem(
              url: e.getLargeImageUrl(),
              data: ImageItemData(
                id: e.id,
                url: e.getLargeImageUrl(),
                originalUrl: e.getOriginalImageUrl(),
              ),
            ))
        .toList();

    return _contentLayout(
      context,
      MouseRegion(
        onEnter: (_) => controller.isHoveringHorizontalList.value = true,
        onExit: (_) => controller.isHoveringHorizontalList.value = false,
        child: HorizontalImageList(
          images: imageItems,
          onItemTap: (item) => _onImageTap(context, item, imageItems),
          menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item),
        ),
      ),
    );
  }

  // 处理图片点击事件
  void _onImageTap(
      BuildContext context, ImageItem item, List<ImageItem> imageItems) {
    ImageItemData iid = item.data;
    LogUtils.d('点击了图片：${iid.id}', 'ImageModelDetailContent');
    int index = imageItems.indexWhere((element) => element.url == item.url);
    if (index == -1) {
      index = imageItems.indexWhere((element) => element.data.id == iid.id);
    }
    NaviService.navigateToPhotoViewWrapper(imageItems: imageItems, initialIndex: index, menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item));
  }

  // 构建图片的菜单项
  List<MenuItem> _buildImageMenuItems(BuildContext context, ImageItem item) {
    final t = slang.Translations.of(context);
    return [
      MenuItem(
        title: t.galleryDetail.copyLink,
        icon: Icons.copy,
        onTap: () => ImageUtils.copyLink(item),
      ),
      MenuItem(
        title: t.galleryDetail.copyImage,
        icon: Icons.copy,
        onTap: () => ImageUtils.copyImage(item),
      ),
      if (GetPlatform.isDesktop && !GetPlatform.isWeb)
        MenuItem(
          title: t.galleryDetail.saveAs,
          icon: Icons.download,
          onTap: () => ImageUtils.downloadImageForDesktop(item),
        ),
      if (GetPlatform.isIOS || GetPlatform.isAndroid)
        MenuItem(
          title: t.galleryDetail.saveToAlbum,
          icon: Icons.save,
          onTap: () => ImageUtils.downloadImageForMobile(item),
        ),
    ];
  }

  // 构建图库详情区域
  Widget _buildGalleryDetails(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildGalleryTitle(),
          const SizedBox(height: 8),
          _buildAuthorInfo(context),
          const SizedBox(height: 8),
          _buildPublishInfo(),
          const SizedBox(height: 16),
          _buildGalleryDescription(),
          const SizedBox(height: 16),
          _buildTags(),
          const SizedBox(height: 16),
          _buildLikeAvatars(),
          const SizedBox(height: 16),
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
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
    Widget avatar = MouseRegion(
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
          defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
          radius: 20,
        ),
      ),
    );

    if (controller.imageModelInfo.value?.user?.premium == true) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade200,
                Colors.blue.shade200,
                Colors.pink.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: avatar,
          ),
        ),
      );
    }

    return avatar;
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
      return ExpandableTagsWidget(tags: tags);
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
          child: Row(
            children: [
              // 左侧按钮组(点赞和分享)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LikeButtonWidget(
                    mediaId: imageModelInfo.id,
                    liked: imageModelInfo.liked ?? false,
                    likeCount: imageModelInfo.numLikes ?? 0,
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
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _downloadGallery(context),
                      borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => ShareGalleryBottomSheet(
                            galleryId: imageModelInfo.id,
                            galleryTitle: imageModelInfo.title,
                            authorName: imageModelInfo.user?.name ?? '',
                            previewUrl: imageModelInfo.thumbnailUrl,
                          ),
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
              const Spacer(),
              // 评论按钮
              Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.comment, 
                        size: 20,
                        color: Theme.of(context).iconTheme.color
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${imageModelInfo.numComments}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 下载图库
  void _downloadGallery(BuildContext context) async {

    showToastWidget(MDToastWidget(
        message: slang.t.download.stillInDevelopment,
        type: MDToastType.success));
    return;
    // final t = slang.Translations.of(context);
    // try {
    //   final imageModel = controller.imageModelInfo.value;
    //   if (imageModel == null) {
    //     showToastWidget(MDToastWidget(
    //         message: t.download.errors.imageModelNotFound,
    //         type: MDToastType.error));
    //     return;
    //   }

    //   // 创建下载任务的扩展数据
    //   final extData = GalleryDownloadExtData(
    //     id: imageModel.id,
    //     title: imageModel.title,
    //     previewUrls: imageModel.files.take(3).map((e) => e.getLargeImageUrl()).toList(),
    //     authorName: imageModel.user?.name,
    //     authorUsername: imageModel.user?.username,
    //     authorAvatar: imageModel.user?.avatar?.avatarUrl,
    //     totalImages: imageModel.files.length,
    //     imageList: imageModel.files.map((e) => {
    //       'id': e.id,
    //       'url': e.getOriginalImageUrl(),
    //     }).toList(),
    //   );

    //   // 创建下载任务
    //   final task = DownloadTask(
    //     id: GalleryDownloadExtData.genExtDataIdByGalleryInfo(imageModel.id),
    //     url: imageModel.files.first.getOriginalImageUrl(), // 使用第一张图片的URL
    //     savePath: await _getSavePath(imageModel.title, imageModel.id),
    //     fileName: '${imageModel.title}_${imageModel.id}',
    //     supportsRange: true,
    //     extData: DownloadTaskExtData(
    //       type: DownloadTaskExtDataType.gallery,
    //       data: extData.toJson(),
    //     ),
    //   );

    //   await DownloadService.to.addTask(task);

    //   showToastWidget(MDToastWidget(
    //       message: t.download.startDownloading,
    //       type: MDToastType.success));

    //   // 打开下载管理页面
    //   NaviService.navigateToDownloadTaskListPage();
    // } catch (e) {
    //   LogUtils.e('添加下载任务失败', tag: 'ImageModelDetailContent', error: e);
    //   showToastWidget(MDToastWidget(
    //       message: t.download.errors.downloadFailed,
    //       type: MDToastType.error));
    // }
  }

  // 获取保存路径
  Future<String> _getSavePath(String title, String id) async {
    final dir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', 'galleries'));
    final sanitizedTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return '${dir.path}/${sanitizedTitle}_$id';
  }
}
