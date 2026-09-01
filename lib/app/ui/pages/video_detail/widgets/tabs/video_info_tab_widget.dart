import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/video_description_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/expandable_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/iwara_tags_section.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/oreno3d_tags_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/like_avatars_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/translatable_title.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/app_service.dart';

import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/add_to_favorite_dialog.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/widgets/watch_later_action_button.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart'; // 导入共享常量和组件
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/add_video_to_playlist_dialog.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/share_video_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart'
    show openDownloadCategoryManagePage;
import 'package:i_iwara/app/ui/pages/download/media_download_launcher.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_picker_sheet.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/ui/widgets/split_button_widget.dart'
    show SplitFilledButton, FilledActionButton, FilledLikeButton;

class VideoInfoTabWidget extends StatefulWidget {
  final MyVideoStateController controller;

  const VideoInfoTabWidget({super.key, required this.controller});

  @override
  State<VideoInfoTabWidget> createState() => _VideoInfoTabWidgetState();
}

class _VideoInfoTabWidgetState extends State<VideoInfoTabWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _getExtDataString(String key) {
    final value = widget.controller.extData?[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  bool _getExtDataBool(String key) {
    final value = widget.controller.extData?[key];
    if (value is bool) return value;
    return false;
  }

  User? _buildInitialAuthorUser() {
    final name = _getExtDataString('authorName') ?? '';
    final username = _getExtDataString('authorUsername') ?? '';
    if (name.isEmpty && username.isEmpty) return null;

    final displayName = name.isNotEmpty ? name : username;
    return User(
      id: _getExtDataString('authorId') ?? '',
      name: displayName,
      username: username,
      role: _getExtDataString('authorRole') ?? '',
      premium: _getExtDataBool('authorPremium'),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用 super.build

    return Obx(() {
      if (widget.controller.pageLoadingState.value ==
              VideoDetailPageLoadingState.loadingVideoInfo ||
          widget.controller.pageLoadingState.value ==
              VideoDetailPageLoadingState.init) {
        return _buildVideoInfoLoadingSkeleton(context);
      }
      if (widget.controller.mainErrorWidget.value != null) {
        return widget.controller.mainErrorWidget.value!;
      }
      if (widget.controller.isDesktopAppFullScreen.value) {
        return const SizedBox.shrink();
      }

      // 不再自行包裹 GestureDetector 处理水平滑动：
      // 之前的 onHorizontalDragEnd 会在手势竞技场中抢占 TabBarView 内置的
      // PageView 拖动，导致详情 tab 只能"一次性甩动"切换、没有实时跟手反馈，
      // 与评论/相关 tab 的体验割裂。交还给 TabBarView 原生处理即可保持一致。
      return SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoTitle(context),
            _buildAuthorInfo(context),
            const SizedBox(height: UIConstants.sectionSpacing),
            _buildVideoDetailsSection(context),
            const SafeArea(top: false, child: SizedBox.shrink()),
          ],
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
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final videoId = widget.controller.videoId;

    final initialTitle = _getExtDataString('title') ?? '';
    final hasInitialTitle = initialTitle.trim().isNotEmpty;
    final displayTitle = hasInitialTitle
        ? initialTitle.trim()
        : t.common.noTitle;

    final authorUser = _buildInitialAuthorUser();
    final authorAvatarUrl = _getExtDataString('authorAvatarUrl');

    Widget titleWidget;
    if (videoId == null || videoId.isEmpty) {
      titleWidget = Container(
        height: 26,
        width: MediaQuery.of(context).size.width * 0.68,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else if (hasInitialTitle) {
      // 有初始标题信息时复用正式标题组件，确保字号/按钮/内边距与正式态一致
      titleWidget = _buildVideoTitle(context);
    } else {
      titleWidget = Text(
        displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      );
    }

    Widget authorWidget = const SizedBox.shrink();
    if (!widget.controller.isLocalVideoMode &&
        videoId != null &&
        videoId.isNotEmpty &&
        authorUser != null) {
      final username = (authorUser.username).trim();
      VoidCallback? onTapAuthor;
      if (username.isNotEmpty) {
        onTapAuthor = () => NaviService.navigateToAuthorProfilePage(
          username,
          initialUser: authorUser,
        );
      }

      authorWidget = Row(
        children: [
          MouseRegion(
            cursor: onTapAuthor != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: onTapAuthor,
              child: AvatarWidget(
                user: authorUser,
                avatarUrl: authorAvatarUrl,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: UIConstants.pagePadding),
          Expanded(
            child: MouseRegion(
              cursor: onTapAuthor != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: onTapAuthor,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildUserName(
                      context,
                      authorUser,
                      fontSize: 16,
                      bold: true,
                    ),
                    if (username.isNotEmpty)
                      Text(
                        '@$username',
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
          Container(
            width: 72,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          authorWidget,
          const SizedBox(height: UIConstants.sectionSpacing),
          Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SafeArea(top: false, child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTitle(BuildContext context) {
    return Builder(
      builder: (context) {
        final t = slang.Translations.of(context);
        final title =
            widget.controller.videoInfo.value?.title ??
            _getExtDataString('title') ??
            '';
        final displayTitle = title.trim().isEmpty
            ? t.common.noTitle
            : title.trim();

        final textStyle = TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        );

        return TranslatableTitle(
          text: displayTitle,
          style: textStyle,
          selectable: true,
        );
      },
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    // 本地播放模式下不显示作者信息区域
    if (widget.controller.isLocalVideoMode) {
      return const SizedBox.shrink();
    }

    final videoId = widget.controller.videoId;
    final user = widget.controller.videoInfo.value?.user;
    if (videoId == null || videoId.isEmpty || user == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => NaviService.navigateToAuthorProfilePage(
              user.username,
              initialUser: user,
            ),
            child: AvatarWidget(user: user, size: 40),
          ),
        ),
        const SizedBox(width: UIConstants.pagePadding),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(
                user.username,
                initialUser: user,
              ),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildUserName(context, user, fontSize: 16, bold: true),
                  Text(
                    '@${user.username}',
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
        const SafeArea(top: false, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildVideoStatsCard(BuildContext context) {
    final t = slang.Translations.of(context);
    // 用 colorScheme.primary，不用 Theme.of(context).primaryColor——
    // primaryColor 是 M2 遗留字段，M3 深色主题下不跟随 colorScheme 变化，
    // 时长标签会显示成偏黑色，糊在深色背景里看不清。
    final primaryColor = Theme.of(context).colorScheme.primary;
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
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: UIConstants.tinySpacing),
                    Text(
                      CommonUtils.formatDuration(
                        Duration(seconds: videoInfo.file!.duration!),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
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
          const SizedBox(height: UIConstants.sectionSpacing),
          _buildSectionCard(
            context,
            child: VideoDescriptionWidget(
              description: description,
              isDescriptionExpanded: widget.controller.isDescriptionExpanded,
              onToggleDescription:
                  widget.controller.isDescriptionExpanded.toggle,
              onTimestampSeek:
                  widget.controller.videoInfo.value?.isExternalVideo == true
                  ? null
                  : widget.controller.seekFromTextReference,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildVideoTagsSection(BuildContext context) {
    return Obx(() {
      final tags = widget.controller.videoInfo.value?.tags;
      if (tags == null || tags.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UIConstants.sectionSpacing),
          IwaraTagsSection(
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
                      // 不加不透明背景色：外层 ExpandableSectionWidget 已是同色
                      // Material，叠一层不透明背景会挡住其长按/点击水波纹。
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(UIConstants.cardPadding),
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
                    Oreno3dTagsSection(
                      oreno3dDetail: oreno3dDetail,
                      onSearchTap: _handleOreno3dSearch,
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
        _buildDownloadSplitButton(context),
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
                widget.controller.applyVideoLikeState(
                  videoId: videoInfo.id,
                  liked: liked,
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
                // 用 colorScheme.primary，不用 Theme.of(context).primaryColor——
                // primaryColor 是 M2 遗留字段，M3 深色主题下它不跟随 colorScheme
                // 翻转，选中态的图标/文字会退化成近黑色，糊在深色卡片上看不清。
                accentColor: widget.controller.isInAnyPlaylist.value
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            // ⛔ 详情页必须有「稍后再看」入口：不然一个正在看片、想存起来以后
            // 接着看的用户，得先退回列表页去卡片上操作——对一个叫"稍后再看"的
            // 功能来说这是最说不过去的发现性缺口。
            WatchLaterActionButton(video: videoInfo),
            Obx(
              () => FilledActionButton(
                icon: widget.controller.isInAnyFavorite.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: t.favorite.localizeFavorite,
                onTap: () => _handleFavoriteAction(context, videoInfo),
                // 同上：M3 深色主题下必须走 colorScheme.primary。
                accentColor: widget.controller.isInAnyFavorite.value
                    ? Theme.of(context).colorScheme.primary
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

    if (!userService.isAuthenticated) {
      showAppToast(
        t.errors.pleaseLoginFirst,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
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

    // 声明下载图标
    const downloadIcon = Icons.download;

    return Obx(() {
      final sources = CommonUtils.sortVideoSourcesByQuality(
        widget.controller.currentVideoSourceList,
      );
      final videoInfo = widget.controller.videoInfo.value;
      final isLoading =
          widget.controller.pageLoadingState.value ==
              VideoDetailPageLoadingState.loadingVideoInfo ||
          widget.controller.pageLoadingState.value ==
              VideoDetailPageLoadingState.loadingVideoSource;

      // 如果视频信息未加载或没有可用源，禁用按钮
      final isDisabled = videoInfo == null || sources.isEmpty || isLoading;

      final currentQuality = _getCurrentQuality(sources);
      final qualityLabel = CommonUtils.getQualityDisplayLabel(
        t,
        currentQuality,
      );

      // 检查是否已有下载任务
      final hasDownloadTask = widget.controller.hasAnyDownloadTask.value;
      // 用 colorScheme.primary，不用 Theme.of(context).primaryColor——
      // primaryColor 是 M2 遗留字段，用 ColorScheme 建的 M3 深色主题下它不跟随
      // colorScheme 变化，会显示成偏黑色，跟深色背景糊在一起看不清。
      final primaryColor = Theme.of(context).colorScheme.primary;
      final accentColor = hasDownloadTask ? primaryColor : null;

      return SplitFilledButton(
        label: '${t.common.download} $qualityLabel',
        icon: downloadIcon,
        isPrimary: isPrimary,
        // 主按钮：打开「选择下载」弹窗，预选“上次下载用的清晰度”（就是按钮上写的那个）。
        // 「更多」菜单里的每个清晰度也打开同一张弹窗，只是预选那个被点的清晰度——
        // 两个入口共用一张弹窗、一条下载流程，不再各走各的。
        onPressed: isDisabled
            ? null
            : () => launchVideoDownload(
                context,
                // isDisabled 里含 videoInfo == null，走到这一支时 Dart 的流分析
                // 已经把它提升成非空，不需要 `!`。
                video: videoInfo,
                sources: sources,
                initialQuality: currentQuality,
                preselectSource: DownloadPickerPreselectSource.lastUsed,
                onTaskCreated: widget.controller.markVideoHasDownloadTask,
                refreshSources: () => widget.controller.currentVideoSourceList,
              ),
        menuItems: [
          // 置顶菜单项：查看下载列表
          GlassMenuOption<String>(
            value: '__download_list__',
            icon: Icons.download_outlined,
            label: t.download.viewDownloadList,
          ),
          // 管理分类快捷入口：不用先弹出选清晰度的弹窗，直达管理页
          GlassMenuOption<String>(
            value: '__manage_categories__',
            icon: Icons.folder_outlined,
            label: t.download.category.manageTitle,
          ),
          const GlassMenuSeparator(),
          // 清晰度选项：配上与播放器一致的分辨率图标，不再是赤裸文字
          //
          // value 用空字符串兜底而不是本地化的"未知"文案——它要传给
          // _openDownloadPicker 做清晰度匹配，得和 sheet 内
          // `s.name?.toLowerCase() ?? ''` 的兜底值对上，否则名字为空的源会被
          // 错误匹配成排序后的第一个（画质最高）源。
          ...sources.map(
            (source) => GlassMenuOption<String>(
              value: source.name ?? '',
              label: CommonUtils.getQualityDisplayLabel(t, source.name),
              leading: SvgPicture.asset(
                CommonUtils.getQualityIconAsset(source.name),
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  // leading 槽位外面套了一层跟着行语义色走的 IconTheme，
                  // SVG 不吃 IconTheme，得自己取一次当前色。
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
        onMenuItemSelected: (value) {
          // 这两条跟当前这条视频没关系，是纯导航——放在 videoInfo 空守卫**之前**。
          // 压在守卫后面的话，视频信息还没加载出来时点「查看下载列表」就没反应。
          if (value == '__download_list__') {
            NaviService.navigateToDownloadTaskListPage();
            return;
          }
          if (value == '__manage_categories__') {
            openDownloadCategoryManagePage(context);
            return;
          }
          // 往下都要拿 videoInfo 才能下载。
          if (videoInfo == null) return;
          // 其余菜单项的 value 就是被点的清晰度名称
          launchVideoDownload(
            context,
            video: videoInfo,
            sources: sources,
            initialQuality: value,
            preselectSource: DownloadPickerPreselectSource.picked,
            onTaskCreated: widget.controller.markVideoHasDownloadTask,
            refreshSources: () => widget.controller.currentVideoSourceList,
          );
        },
        isDisabled: isDisabled,
        accentColor: accentColor,
      );
    });
  }

  /// 处理分享操作
  void _handleShareAction(BuildContext context) {
    showGlassBottomSheet(
      builder: (context) => ShareVideoBottomSheet(
        videoId: widget.controller.videoInfo.value?.id ?? '',
        videoTitle: widget.controller.videoInfo.value?.title ?? '',
        authorName: widget.controller.videoInfo.value?.user?.name ?? '',
        previewUrl: widget.controller.videoInfo.value?.previewUrl ?? '',
      ),
      context: context,
    );
  }

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
}
