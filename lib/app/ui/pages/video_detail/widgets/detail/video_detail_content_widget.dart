import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/share_video_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/video_description_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/add_to_favorite_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/error_widget.dart';
import '../../controllers/my_video_state_controller.dart';
import 'expandable_tags_widget.dart';
import 'like_avatars_widget.dart';
import '../player/my_video_screen.dart';
import '../../../../widgets/follow_button_widget.dart';
import '../../../../widgets/like_button_widget.dart';
import '../../../../../../i18n/strings.g.dart' as slang;
import 'add_video_to_playlist_dialog.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// 添加最小高度常量
const double MIN_VIDEO_HEIGHT = 240.0;

class VideoDetailContent extends StatelessWidget {
  final MyVideoStateController controller;
  final double paddingTop;
  final double? videoHeight;

  const VideoDetailContent({
    super.key,
    required this.controller,
    required this.paddingTop,
    this.videoHeight,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 用 RepaintBoundary 包裹整个内容区域，减少内部局部更新对整体绘制的影响
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 视频播放器区域
          ClipRect(
            child: Stack(
              children: [
                Obx(() {
                  // 如果视频加载出错，显示错误组件
                  if (controller.videoErrorMessage.value != null) {
                    return SizedBox(
                      height: (videoHeight ?? (MediaQuery.sizeOf(context).width / 1.7)) + paddingTop,
                      child: Stack(
                        children: [
                          // 添加背景图片
                          if (controller.videoInfo.value?.previewUrl != null)
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: controller.videoInfo.value!.previewUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.black,
                                  child: const Icon(Icons.error_outline, size: 48, color: Colors.white54),
                                ),
                              ),
                            ),
                          // 添加半透明遮罩
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          // 错误提示内容
                          Center(
                            child: controller.videoErrorMessage.value == 'resource_404'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.not_interested, size: 48, color: Colors.white),
                                    const SizedBox(height: 12),
                                    Text(
                                      t.videoDetail.resourceDeleted,
                                      style: const TextStyle(fontSize: 18, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => AppService.tryPop(),
                                      icon: const Icon(Icons.arrow_back),
                                      label: Text(t.common.back),
                                    ),
                                  ],
                                )
                              : CommonErrorWidget(
                                  text: controller.videoErrorMessage.value ?? t.videoDetail.errorLoadingVideo,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => AppService.tryPop(),
                                      icon: const Icon(Icons.arrow_back),
                                      label: Text(t.common.back),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => controller.fetchVideoDetail(controller.videoId ?? ''),
                                      icon: const Icon(Icons.refresh),
                                      label: Text(t.common.retry),
                                    ),
                                  ],
                                ),
                          ),
                        ],
                      ),
                    );
                  }
                  // 如果是站外视频，显示站外视频提示
                  else if (controller.videoInfo.value?.isExternalVideo == true) {
                    return SizedBox(
                      height: (videoHeight ?? (MediaQuery.sizeOf(context).width / 1.7)) + paddingTop,
                      child: Stack(
                        children: [
                          // 添加背景图片
                          if (controller.videoInfo.value?.previewUrl != null)
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: controller.videoInfo.value!.previewUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          // 添加半透明遮罩
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          // 原有的提示内容
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.link, size: 48, color: Colors.white),
                                const SizedBox(height: 12),
                                Text(
                                  '${t.videoDetail.externalVideo}: ${controller.videoInfo.value?.externalVideoDomain}',
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  spacing: 16,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => AppService.tryPop(),
                                      icon: const Icon(Icons.arrow_back),
                                      label: Text(t.common.back),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (controller.videoInfo.value?.embedUrl != null) {
                                          launchUrl(Uri.parse(controller.videoInfo.value!.embedUrl!));
                                        }
                                      },
                                      icon: const Icon(Icons.open_in_new),
                                      label: Text(t.videoDetail.openInBrowser),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // 如果不是全屏模式，显示视频播放器
                  else if (!controller.isFullscreen.value) {
                    var isDesktopAppFullScreen =
                        controller.isDesktopAppFullScreen.value;
                    return SizedBox(
                      height: !isDesktopAppFullScreen
                          ? ((videoHeight ??
                                  (
                                      // 使用有效的视频比例，如果比例小于1，则使用1.7
                                      (controller.aspectRatio.value < 1
                                          ? MediaQuery.sizeOf(context).width / 1.7
                                          : MediaQuery.sizeOf(context).width /
                                              controller.aspectRatio.value))) +
                              paddingTop)
                              .clamp(MIN_VIDEO_HEIGHT, double.infinity)
                          : MediaQuery.sizeOf(context).height,
                      child: MyVideoScreen(
                          isFullScreen: false,
                          myVideoStateController: controller),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
          // 视频详情内容区域
          Obx(() {
            if (!controller.isDesktopAppFullScreen.value) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // 视频标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  ),
                  const SizedBox(height: 12),
                  // 作者信息区域，包括头像和用户名
                  _buildAuthorInfo(context),
                  const SizedBox(height: 12),
                  // 视频发布时间和观看次数
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() => Text(
                          '${t.galleryDetail.publishedAt}：${CommonUtils.formatFriendlyTimestamp(controller.videoInfo.value?.createdAt)}    ${t.galleryDetail.viewsCount}：${CommonUtils.formatFriendlyNumber(controller.videoInfo.value?.numViews)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        )),
                  ),
                  const SizedBox(height: 12),
                  // 视频描述内容，支持展开/收起
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() => VideoDescriptionWidget(
                          description: controller.videoInfo.value?.body,
                          isDescriptionExpanded: controller.isDescriptionExpanded,
                          onToggleDescription: () =>
                              controller.isDescriptionExpanded.toggle(),
                        )),
                  ),
                  const SizedBox(height: 12),
                  // 视频标签区域，支持展开
                  Obx(() {
                    final tags = controller.videoInfo.value?.tags;
                    if (tags != null && tags.isNotEmpty) {
                      return ExpandableTagsWidget(tags: tags);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  const SizedBox(height: 12),
                  // 点赞用户头像展示
                  Obx(() {
                    final videoId = controller.videoInfo.value?.id;
                    if (videoId != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  }),
                  const SizedBox(height: 12),
                  Obx(() {
                    final videoInfo = controller.videoInfo.value;
                    if (videoInfo != null) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (context) => AddVideoToPlayListDialog(
                                        videoId: controller.videoInfo.value?.id ?? '',
                                      ), context: context,
                                    );
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
                                          slang.Translations.of(context).common.playList,
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
                                          slang.Translations.of(context).favorite.localizeFavorite,
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
                                    _showDownloadDialog(context);
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
                                          slang.Translations.of(context).common.share,
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
                  }),
                ],
              );
            } else {
              // 如果是全屏模式，则不显示详情内容
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar() {
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

  Widget _buildAuthorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildAuthorAvatar(),
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
  // 获取视频的下载地址
  Future<String?> _getSavePath(String title, String quality, String downloadUrl) async {
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
    LogUtils.d('尝试显示下载对话框', 'VideoDetailContent');
    final t = slang.Translations.of(context);
    final sources = controller.currentVideoSourceList;

    if (sources.isEmpty) {
      LogUtils.w('没有可用的下载源', 'VideoDetailContent');
      showToastWidget(MDToastWidget(message: t.download.errors.noDownloadSourceNowPleaseWaitInfoLoaded, type: MDToastType.error));
      return;
    }
    final UserService userService = Get.find();
    if (!userService.isLogin) {
      LogUtils.w('用户未登录，无法下载', 'VideoDetailContent');
      showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
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
                  LogUtils.d('选择下载质量: ${source.name}', 'VideoDetailContent');
                  AppService.tryPop();

                  if (source.download == null) {
                    LogUtils.w('所选质量没有下载链接', 'VideoDetailContent');
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
                      LogUtils.e('下载失败：视频信息为空', tag: 'VideoDetailContent');
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
                    LogUtils.d('创建下载任务元数据', 'VideoDetailContent');

                    // 在创建下载任务之前获取保存路径
                    final savePath = await _getSavePath(
                      videoInfo.title ?? 'video',
                      source.name ?? 'unknown',
                      source.download ?? 'unknown'
                    );

                    if (savePath == null) {
                      LogUtils.d('用户取消了下载操作', 'VideoDetailContent');
                      showToastWidget(MDToastWidget(
                        message: t.common.operationCancelled,
                        type: MDToastType.info
                      ));
                      return;
                    }

                    final task = DownloadTask(
                      id: VideoDownloadExtData.genExtDataIdByVideoInfo(videoInfo, source.name ?? 'unknown'),
                      url: source.download!,
                      savePath: savePath,
                      fileName: '${videoInfo.title ?? 'video'}_${source.name}.mp4',
                      supportsRange: true,
                      extData: DownloadTaskExtData(
                        type: DownloadTaskExtDataType.video,
                        data: videoExtData.toJson(),
                      ),
                    );
                    LogUtils.d('添加下载任务: ${task.id}', 'VideoDetailContent');

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
                    LogUtils.e('添加下载任务失败: $e',
                        tag: 'VideoDetailContent', error: e);
                    String message;
                    if (e.toString().contains(t.download.errors.downloadTaskAlreadyExists)) {
                      message = t.download.errors.downloadTaskAlreadyExists;
                    } else if (e.toString().contains(t.download.errors.videoAlreadyDownloaded)) {
                      message = t.download.errors.videoAlreadyDownloaded;
                    } else {
                      message = t.download.errors.downloadFailed;
                    }

                    showToastWidget(
                      MDToastWidget(
                        message: message,
                        type: MDToastType.error,
                      ),
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
      LogUtils.e('显示下载对话框失败', error: e, tag: 'VideoDetailContent');
    }
  }

  // 添加到收藏夹
  void _addToFavorite(BuildContext context) {
    LogUtils.d('尝试添加视频到收藏夹', 'VideoDetailContent');
    
    final videoInfo = controller.videoInfo.value;
    if (videoInfo == null) {
      LogUtils.e('添加到收藏夹失败：视频信息为空', tag: 'VideoDetailContent');
      showToastWidget(MDToastWidget(message: slang.t.errors.failedToFetchData, type: MDToastType.error));
      return;
    }

    try {
      Get.dialog(
        AddToFavoriteDialog(
          itemId: videoInfo.id,
          onAdd: (folderId) async {
            LogUtils.d('将视频添加到收藏夹ID: $folderId', 'VideoDetailContent');
            return await FavoriteService.to.addVideoToFolder(videoInfo, folderId);
          },
        ),
      );
    } catch (e) {
      LogUtils.e('打开收藏夹对话框失败', error: e, tag: 'VideoDetailContent');
    }
  }
}
