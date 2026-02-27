import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/video_description_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/expandable_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/tags_display_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/oreno3d_tags_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/like_avatars_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/app_service.dart';

import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
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
import 'package:i_iwara/app/utils/show_app_dialog.dart';

import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/add_video_to_playlist_dialog.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/share_video_bottom_sheet.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/ui/widgets/split_button_widget.dart'
    show SplitFilledButton, FilledActionButton, FilledLikeButton;

class VideoInfoTabWidget extends StatefulWidget {
  final MyVideoStateController controller;
  final TabController tabController;

  const VideoInfoTabWidget({
    super.key,
    required this.controller,
    required this.tabController,
  });

  @override
  State<VideoInfoTabWidget> createState() => _VideoInfoTabWidgetState();
}

class _VideoInfoTabWidgetState extends State<VideoInfoTabWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用 super.build

    return Obx(() {
      if (widget.controller.pageLoadingState.value ==
          VideoDetailPageLoadingState.loadingVideoInfo) {
        return _buildVideoInfoLoadingSkeleton(context);
      }
      if (widget.controller.mainErrorWidget.value != null) {
        return widget.controller.mainErrorWidget.value!;
      }
      if (widget.controller.isDesktopAppFullScreen.value) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoTitle(context),
              _buildAuthorInfo(context),
              const SizedBox(height: UIConstants.sectionSpacing),
              _buildVideoDetailsSection(context),
              const SafeArea(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    });
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

  Widget _buildVideoInfoLoadingSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 26,
              width: MediaQuery.of(context).size.width * 0.68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: UIConstants.sectionSpacing),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: UIConstants.pagePadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: UIConstants.smallSpacing),
                      Container(
                        height: 12,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.sectionSpacing),
            _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == 2 ? 0 : UIConstants.listSpacing,
                    ),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.sectionSpacing),
            _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: UIConstants.interElementSpacing),
                  Wrap(
                    spacing: UIConstants.listSpacing,
                    runSpacing: UIConstants.listSpacing,
                    children: List.generate(
                      4,
                      (_) => Container(
                        width: 90,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.sectionSpacing),
            _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == 3 ? 0 : UIConstants.smallSpacing,
                    ),
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SafeArea(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTitle(BuildContext context) {
    return Builder(
      builder: (context) {
        final title = widget.controller.videoInfo.value?.title ?? '';
        if (title.isEmpty) {
          return const SizedBox.shrink();
        }

        final textStyle = TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        );

        return SelectableText.rich(
          TextSpan(
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

  Widget _buildAuthorInfo(BuildContext context) {
    // 本地播放模式下不显示作者信息区域
    if (widget.controller.isLocalVideoMode) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => NaviService.navigateToAuthorProfilePage(
              widget.controller.videoInfo.value!.user!.username,
            ),
            child: AvatarWidget(
              user: widget.controller.videoInfo.value?.user,
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
                widget.controller.videoInfo.value!.user!.username,
              ),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildUserName(
                    context,
                    widget.controller.videoInfo.value?.user,
                    fontSize: 16,
                    bold: true,
                  ),
                  Text(
                    '@${widget.controller.videoInfo.value?.user?.username ?? ''}',
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
        if (widget.controller.videoInfo.value?.user != null)
          SizedBox(
            height: 32,
            child: FollowButtonWidget(
              user: widget.controller.videoInfo.value!.user!,
              onUserUpdated: widget.controller.handleAuthorUpdated,
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

        // 视频描述
        _buildVideoDescriptionSection(context),

        // 操作按钮区域（紧跟个人简介）
        const SizedBox(height: UIConstants.sectionSpacing),
        _buildActionButtonsSection(context),

        // 视频标签
        _buildVideoTagsSection(context),

        // Oreno3D信息区域
        _buildOreno3dSection(context),

        const SizedBox(height: UIConstants.sectionSpacing),
        // 点赞头像区域
        _buildLikeAvatarsSection(context),
        const SafeArea(child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildVideoStatsCard(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final videoInfo = widget.controller.videoInfo.value;
      if (videoInfo == null) return const SizedBox.shrink();

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
                        '${t.galleryDetail.publishedAt}：${CommonUtils.formatFriendlyTimestamp(videoInfo.createdAt)}',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.tagPaddingHorizontal,
                  vertical: UIConstants.tagPaddingVertical,
                ),
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
                    const SizedBox(width: UIConstants.tinySpacing),
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
      final description = widget.controller.videoInfo.value?.body;
      if (description == null || description.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UIConstants.listSpacing),
          _buildSectionCard(
            context,
            child: VideoDescriptionWidget(
              description: description,
              isDescriptionExpanded: widget.controller.isDescriptionExpanded,
              onToggleDescription:
                  widget.controller.isDescriptionExpanded.toggle,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildVideoTagsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final tags = widget.controller.videoInfo.value?.tags;
      if (tags == null || tags.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UIConstants.sectionSpacing),
          ExpandableSectionWidget(
            title: t.common.iwaraTags,
            icon: Icons.label,
            child: TagsDisplayWidget(
              tags: tags,
              onTagTap: (tag) {
                // 点击标签跳转到标签视频列表页面
                NaviService.navigateToTagVideoListPage(tag);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOreno3dSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final oreno3dDetail = widget.controller.oreno3dVideoDetail.value;
      final isMatching = widget.controller.isOreno3dMatching.value;

      // 判断是否应该显示
      final shouldShow =
          isMatching ||
          (oreno3dDetail != null &&
              (oreno3dDetail.origin != null ||
                  oreno3dDetail.tags.isNotEmpty ||
                  oreno3dDetail.characters.isNotEmpty));

      // 使用 AnimatedSize 实现高度收缩动画
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: shouldShow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: UIConstants.sectionSpacing),
                  // 如果正在匹配，显示 loading
                  if (isMatching)
                    ExpandableSectionWidget(
                      title: t.oreno3d.name,
                      icon: Icons.view_in_ar,
                      onHelpTap: () => _showOreno3dInfoDialog(context),
                      showHelpButton: true,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(UIConstants.cardPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
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
                            const SizedBox(
                              height: UIConstants.interElementSpacing,
                            ),

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
                              spacing: UIConstants.iconTextSpacing,
                              runSpacing: UIConstants.smallSpacing,
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
                            const SizedBox(
                              height: UIConstants.interElementSpacing,
                            ),

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
                              spacing: UIConstants.iconTextSpacing,
                              runSpacing: UIConstants.smallSpacing,
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
                    )
                  // 有数据时显示内容
                  else if (oreno3dDetail != null)
                    ExpandableSectionWidget(
                      title: t.oreno3d.name,
                      icon: Icons.view_in_ar,
                      onHelpTap: () => _showOreno3dInfoDialog(context),
                      showHelpButton: true,
                      child: Oreno3dTagsWidget(
                        oreno3dDetail: oreno3dDetail,
                        onSearchTap: _handleOreno3dSearch,
                      ),
                    ),
                ],
              )
            : Column(mainAxisSize: MainAxisSize.min, children: const []),
      );
    });
  }

  Widget _buildLikeAvatarsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final videoId = widget.controller.videoInfo.value?.id;
      if (videoId == null) return const SizedBox.shrink();

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
                mediaId: videoId,
                mediaType: MediaType.VIDEO,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtonsSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final videoInfo = widget.controller.videoInfo.value;
    if (videoInfo == null) return const SizedBox.shrink();

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

  /// A more responsive action button row using Wrap.
  Widget _buildActionButtons(BuildContext context) {
    final t = slang.Translations.of(context);
    final videoInfo = widget.controller.videoInfo.value;
    if (videoInfo == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDownloadSplitButton(context, isPrimary: true),
        const SizedBox(height: UIConstants.listSpacing),
        Wrap(
          spacing: UIConstants.listSpacing, // Horizontal space between buttons
          runSpacing: UIConstants.listSpacing, // Vertical space between rows
          children: [
            FilledLikeButton(
              mediaId: videoInfo.id,
              liked: videoInfo.liked,
              likeCount: videoInfo.numLikes ?? 0,
              onLike: (id) async =>
                  (await Get.find<VideoService>().likeVideo(id)).isSuccess,
              onUnlike: (id) async =>
                  (await Get.find<VideoService>().unlikeVideo(id)).isSuccess,
              onLikeChanged: (liked) {
                widget.controller.videoInfo.value = widget
                    .controller
                    .videoInfo
                    .value
                    ?.copyWith(
                      liked: liked,
                      numLikes:
                          (widget.controller.videoInfo.value?.numLikes ?? 0) +
                          (liked ? 1 : -1),
                    );
                // 更新缓存中的点赞信息
                widget.controller.updateCachedVideoLikeInfo(
                  videoInfo.id,
                  liked,
                  widget.controller.videoInfo.value?.numLikes ?? 0,
                );
              },
            ),
            Obx(
              () => FilledActionButton(
                icon: widget.controller.isInAnyPlaylist.value
                    ? Icons.playlist_add_check
                    : Icons.playlist_add,
                label: t.common.playList,
                onTap: () => _handlePlaylistAction(context),
                accentColor: widget.controller.isInAnyPlaylist.value
                    ? Theme.of(context).primaryColor
                    : null,
              ),
            ),
            Obx(
              () => FilledActionButton(
                icon: widget.controller.isInAnyFavorite.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: t.favorite.localizeFavorite,
                onTap: () => _handleFavoriteAction(context, videoInfo),
                accentColor: widget.controller.isInAnyFavorite.value
                    ? Theme.of(context).primaryColor
                    : null,
              ),
            ),
            FilledActionButton(
              icon: Icons.share,
              label: t.common.share,
              onTap: () => _handleShareAction(context),
            ),
          ],
        ),
      ],
    );
  }

  /// 处理播放列表操作
  void _handlePlaylistAction(BuildContext context) {
    final t = slang.Translations.of(context);
    final UserService userService = Get.find();

    if (!userService.isLogin) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.pleaseLoginFirst,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      LoginService.showLogin();
      return;
    }

    showAppDialog(
      AddVideoToPlayListDialog(
        videoId: widget.controller.videoInfo.value?.id ?? '',
      ),
    ).then((_) {
      // 对话框关闭后刷新播放列表状态
      widget.controller.checkFavoriteAndPlaylistStatus();
    });
  }

  /// 处理收藏操作
  void _handleFavoriteAction(BuildContext context, dynamic videoInfo) {
    showAppDialog(
      AddToFavoriteDialog(
        itemId: videoInfo.id,
        onAdd: (folderId) =>
            FavoriteService.to.addVideoToFolder(videoInfo, folderId),
      ),
    ).then((_) {
      // 对话框关闭后刷新收藏状态
      widget.controller.checkFavoriteAndPlaylistStatus();
    });
  }

  /// 处理下载操作
  void _handleDownloadAction(BuildContext context) {
    _showDownloadDialog(context);
  }

  /// 获取当前应该显示的清晰度
  /// 优先使用配置的清晰度，如果视频源中没有该清晰度，则按优先级选择
  String? _getCurrentQuality(List<VideoSource> sources) {
    if (sources.isEmpty) return null;

    final configService = Get.find<ConfigService>();
    final lastQuality =
        (configService[ConfigKey.LAST_DOWNLOAD_QUALITY] as String)
            .toLowerCase();

    // 优先级列表（小写）
    final priorityList = ['source', '1080', '720', '540', '360', 'preview'];

    // 首先检查配置的清晰度是否存在（不区分大小写）
    final matchingSource = sources.firstWhereOrNull(
      (source) => (source.name?.toLowerCase() ?? '') == lastQuality,
    );
    if (matchingSource != null) {
      // 返回原始大小写的清晰度名称
      return matchingSource.name;
    }

    // 如果配置的清晰度不存在，按优先级选择第一个存在的（不区分大小写）
    for (final quality in priorityList) {
      final matchingSource = sources.firstWhereOrNull(
        (source) => (source.name?.toLowerCase() ?? '') == quality.toLowerCase(),
      );
      if (matchingSource != null) {
        // 返回原始大小写的清晰度名称
        return matchingSource.name;
      }
    }

    // 如果都不存在，返回第一个可用的清晰度
    return sources.firstOrNull?.name;
  }

  /// 构建下载 Split Button
  Widget _buildDownloadSplitButton(
    BuildContext context, {
    bool isPrimary = false,
  }) {
    final t = slang.Translations.of(context);
    final configService = Get.find<ConfigService>();

    // 声明下载图标
    const downloadIcon = Icons.download;

    return Obx(() {
      final sources = widget.controller.currentVideoSourceList;
      final videoInfo = widget.controller.videoInfo.value;
      final isLoading =
          widget.controller.pageLoadingState.value ==
              VideoDetailPageLoadingState.loadingVideoInfo ||
          widget.controller.pageLoadingState.value ==
              VideoDetailPageLoadingState.loadingVideoSource;

      // 如果视频信息未加载或没有可用源，禁用按钮
      final isDisabled = videoInfo == null || sources.isEmpty || isLoading;

      final currentQuality = _getCurrentQuality(sources);
      final qualityLabel = currentQuality ?? t.download.errors.unknown;

      // 检查是否已有下载任务
      final hasDownloadTask = widget.controller.hasAnyDownloadTask.value;
      final accentColor = hasDownloadTask
          ? Theme.of(context).primaryColor
          : null;

      return SplitFilledButton(
        label: '${t.common.download} $qualityLabel',
        icon: downloadIcon,
        isPrimary: isPrimary,
        onPressed: isDisabled
            ? null
            : () => _handleDownloadWithQuality(context, currentQuality),
        menuItems: [
          // 置顶菜单项：查看下载列表
          PopupMenuItem<String>(
            value: '__download_list__',
            child: Row(
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: UIConstants.iconTextSpacing),
                Text(
                  t.download.viewDownloadList,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // 分割线
          const PopupMenuDivider(),
          // 清晰度选项
          ...sources.map((source) {
            return PopupMenuItem<String>(
              value: source.name ?? t.download.errors.unknown,
              child: Text(source.name ?? t.download.errors.unknown),
            );
          }),
        ],
        onMenuItemSelected: (quality) {
          // 如果是跳转到下载列表
          if (quality == '__download_list__') {
            NaviService.navigateToDownloadTaskListPage();
            return;
          }
          // 保存选择的清晰度到配置
          configService.setSetting(ConfigKey.LAST_DOWNLOAD_QUALITY, quality);
          // 使用选择的清晰度下载
          _handleDownloadWithQuality(context, quality);
        },
        isDisabled: isDisabled,
        accentColor: accentColor,
      );
    });
  }

  /// 使用指定清晰度下载
  void _handleDownloadWithQuality(BuildContext context, String? quality) {
    if (quality == null) {
      _handleDownloadAction(context);
      return;
    }

    final sources = widget.controller.currentVideoSourceList;
    // 使用 toLowerCase() 进行不区分大小写的比较
    final source = sources.firstWhereOrNull(
      (s) => (s.name?.toLowerCase() ?? '') == quality.toLowerCase(),
    );

    if (source == null) {
      _handleDownloadAction(context);
      return;
    }

    // 直接使用该清晰度下载，跳过选择对话框
    _downloadWithSource(context, source);
  }

  /// 使用指定的视频源下载
  Future<void> _downloadWithSource(
    BuildContext context,
    VideoSource source,
  ) async {
    final t = slang.Translations.of(context);

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
      final videoInfo = widget.controller.videoInfo.value;
      if (videoInfo == null) {
        LogUtils.e('下载失败：视频信息为空', tag: 'VideoInfoTabWidget');
        showToastWidget(
          MDToastWidget(
            message: t.download.errors.videoInfoNotFound,
            type: MDToastType.error,
          ),
        );
        return;
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

      // 检查是否存在重复任务
      final duplicateCheck = await DownloadService.to.checkVideoTaskDuplicate(
        videoInfo.id,
        source.name ?? 'unknown',
      );

      // 如果存在重复任务，显示确认对话框
      if (duplicateCheck.hasSameVideoSameQuality ||
          duplicateCheck.hasSameVideoDifferentQuality) {
        // 检查 context 是否仍然有效
        if (!context.mounted) {
          LogUtils.d('Context 已失效，取消下载操作', 'VideoInfoTabWidget');
          return;
        }

        final shouldContinue = await _showDuplicateTaskDialog(
          context,
          duplicateCheck.hasSameVideoSameQuality,
          duplicateCheck.existingQualities,
        );

        if (!shouldContinue) {
          LogUtils.d('用户取消了重复任务下载', 'VideoInfoTabWidget');
          return;
        }
      }

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
        fileName: '${videoInfo.title ?? 'video'}_${source.name}.mp4',
        supportsRange: true,
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.video,
          data: videoExtData.toJson(),
        ),
        mediaType: 'video',
        mediaId: videoInfo.id,
        quality: source.name,
      );
      LogUtils.d('添加下载任务: ${task.id}', 'VideoInfoTabWidget');

      await DownloadService.to.addTask(task);

      // 标记视频有下载任务
      widget.controller.markVideoHasDownloadTask();

      _showDownloadStartedSnackBar(context);
    } catch (e) {
      LogUtils.e('添加下载任务失败: $e', tag: 'VideoInfoTabWidget', error: e);
      String message;
      if (e.toString().contains(t.download.errors.downloadTaskAlreadyExists)) {
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
  }

  /// 统一展示“开始下载”的 SnackBar，确保旧提示被清理并按时消失
  void _showDownloadStartedSnackBar(BuildContext context) {
    final t = slang.Translations.of(context);

    // 使用 showToastWidget 自定义一个类似 SnackBar 的 UI
    showToastWidget(
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.inverseSurface, // 通常 SnackBar 是深色的
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                t.videoDetail.startDownloading,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                // 关闭 Toast (如果你没有引用 dismissAllToast，可以让它自然消失，或者手动调用)
                dismissAllToast();
                NaviService.navigateToDownloadTaskListPage();
              },
              child: Text(
                t.download.viewDownloadList,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 4),
      handleTouch: true, // 关键：允许点击 Toast 内部的按钮
      dismissOtherToast: true, // 可选：显示新的时关闭旧的
    );
  }

  /// 处理分享操作
  void _handleShareAction(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareVideoBottomSheet(
        videoId: widget.controller.videoInfo.value?.id ?? '',
        videoTitle: widget.controller.videoInfo.value?.title ?? '',
        authorName: widget.controller.videoInfo.value?.user?.name ?? '',
        previewUrl: widget.controller.videoInfo.value?.previewUrl ?? '',
      ),
      context: context,
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
      id: widget.controller.videoInfo.value?.id ?? 'unknown',
      title: title,
      user: widget.controller.videoInfo.value?.user,
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
    final sources = widget.controller.currentVideoSourceList;

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
      LoginService.showLogin();
      return;
    }

    try {
      showAppDialog(
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

                  // 重新从 controller 获取最新的视频源列表，避免使用过期的源
                  final latestSources =
                      widget.controller.currentVideoSourceList;
                  final latestSource = latestSources.firstWhereOrNull(
                    (s) =>
                        (s.name?.toLowerCase() ?? '') ==
                        (source.name?.toLowerCase() ?? ''),
                  );

                  if (latestSource == null || latestSource.download == null) {
                    LogUtils.w('所选质量没有下载链接或源已失效', 'VideoInfoTabWidget');
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
                    final videoInfo = widget.controller.videoInfo.value;
                    if (videoInfo == null) {
                      LogUtils.e('下载失败：视频信息为空', tag: 'VideoInfoTabWidget');
                      throw Exception(t.download.errors.videoInfoNotFound);
                    }

                    // 创建视频下载的额外信息，使用最新获取的视频源
                    final videoExtData = VideoDownloadExtData(
                      id: videoInfo.id,
                      title: videoInfo.title,
                      thumbnail: videoInfo.thumbnailUrl,
                      authorName: videoInfo.user?.name,
                      authorUsername: videoInfo.user?.username,
                      authorAvatar: videoInfo.user?.avatar?.avatarUrl,
                      duration: videoInfo.file?.duration,
                      quality: latestSource.name,
                    );
                    LogUtils.d('创建下载任务元数据，使用最新视频源', 'VideoInfoTabWidget');

                    // 检查是否存在重复任务
                    final duplicateCheck = await DownloadService.to
                        .checkVideoTaskDuplicate(
                          videoInfo.id,
                          latestSource.name ?? 'unknown',
                        );

                    // 如果存在重复任务，显示确认对话框
                    if (duplicateCheck.hasSameVideoSameQuality ||
                        duplicateCheck.hasSameVideoDifferentQuality) {
                      // 检查 context 是否仍然有效
                      if (!context.mounted) {
                        LogUtils.d('Context 已失效，取消下载操作', 'VideoInfoTabWidget');
                        return;
                      }

                      final shouldContinue = await _showDuplicateTaskDialog(
                        context,
                        duplicateCheck.hasSameVideoSameQuality,
                        duplicateCheck.existingQualities,
                      );

                      if (!shouldContinue) {
                        LogUtils.d('用户取消了重复任务下载', 'VideoInfoTabWidget');
                        return;
                      }
                    }

                    // 在创建下载任务之前获取保存路径
                    final savePath = await _getSavePath(
                      videoInfo.title ?? 'video',
                      latestSource.name ?? 'unknown',
                      latestSource.download ?? 'unknown',
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
                      url: latestSource.download!,
                      savePath: savePath,
                      fileName:
                          '${videoInfo.title ?? 'video'}_${latestSource.name}.mp4',
                      supportsRange: true,
                      extData: DownloadTaskExtData(
                        type: DownloadTaskExtDataType.video,
                        data: videoExtData.toJson(),
                      ),
                      mediaType: 'video',
                      mediaId: videoInfo.id,
                      quality: latestSource.name,
                    );
                    LogUtils.d('添加下载任务: ${task.id}', 'VideoInfoTabWidget');

                    await DownloadService.to.addTask(task);

                    // 标记视频有下载任务
                    widget.controller.markVideoHasDownloadTask();

                    // 保存选择的清晰度到配置
                    final configService = Get.find<ConfigService>();
                    configService.setSetting(
                      ConfigKey.LAST_DOWNLOAD_QUALITY,
                      latestSource.name ?? 'unknown',
                    );

                    _showDownloadStartedSnackBar(context);
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

  /// 显示重复任务确认对话框
  /// 返回 true 表示用户确认继续下载，false 表示取消
  Future<bool> _showDuplicateTaskDialog(
    BuildContext context,
    bool hasSameQuality,
    List<String> existingQualities,
  ) async {
    // 检查 context 是否仍然有效
    if (!context.mounted) {
      return false;
    }

    final t = slang.Translations.of(context);
    final String message;
    if (hasSameQuality) {
      message = t.download.alreadyDownloadedWithQuality;
    } else {
      final qualitiesText = existingQualities.isNotEmpty
          ? existingQualities.join('、')
          : t.download.otherQualities;
      message = t.download.alreadyDownloadedWithQualities(
        qualities: qualitiesText,
      );
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.common.tips),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.confirm),
          ),
        ],
      ),
    );

    return result ?? false;
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
                const PConfig(textStyle: TextStyle(fontSize: 14, height: 1.5)),
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
    LogUtils.d(
      'Oreno3D 搜索: id=$id, type=$type, name=$name',
      'VideoInfoTabWidget',
    );

    // 跳转到搜索页面，自动选择 oreno3d 模式
    // 传递空的搜索关键词，通过 extData 传递 ID 和类型信息
    NaviService.toSearchPage(
      searchInfo: '',
      segment: SearchSegment.oreno3d,
      extData: {
        'searchType': type,
        'id': id,
        'name': name, // 传递标签名
      },
    );
  }

  /// 处理水平滑动结束事件，用于切换tab
  void _handleHorizontalDragEnd(DragEndDetails details) {
    // 获取水平速度（正数表示向右滑动，负数表示向左滑动）
    final velocity = details.velocity.pixelsPerSecond.dx;

    // 设置阈值：速度大于300px/s时才触发切换
    const double velocityThreshold = 300.0;

    // 检查是否达到切换阈值
    if (velocity.abs() > velocityThreshold) {
      // 速度足够，基于速度方向切换
      if (velocity > 0 && widget.tabController.index > 0) {
        // 向右滑动，切换到上一个tab
        widget.tabController.animateTo(widget.tabController.index - 1);
      } else if (velocity < 0 &&
          widget.tabController.index < widget.tabController.length - 1) {
        // 向左滑动，切换到下一个tab
        widget.tabController.animateTo(widget.tabController.index + 1);
      }
    }
  }
}
