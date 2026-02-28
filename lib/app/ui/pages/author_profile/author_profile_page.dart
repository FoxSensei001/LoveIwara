import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/post.model.dart';

import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/author_profile_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_image_model_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_post_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_video_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_playlist_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../common/constants.dart';
import '../../../services/user_service.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import '../popular_media_list/widgets/media_description_widget.dart';
import 'controllers/authro_profile_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/post_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/new_conversation_dialog.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/share_user_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/friend_button_widget.dart';
import '../popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/widgets/batch_action_fab_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class AuthorProfilePage extends StatefulWidget {
  final String username;
  final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();

  AuthorProfilePage({super.key, required this.username});

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage>
    with TickerProviderStateMixin {
  late final AuthorProfileController profileController;
  final UserService userService = Get.find<UserService>();
  final UserPreferenceService userPreferenceService =
      Get.find<UserPreferenceService>();
  late TabController primaryTC;
  late TabController videoSecondaryTC;
  late TabController imageSecondaryTC;
  late TabController playlistSecondaryTC;
  late final BatchSelectController<Video> _videoBatchController;
  late final BatchSelectController<ImageModel> _imageBatchController;
  late String username;

  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();
  late String uniqueTag;
  late ScrollController _tabBarScrollController;
  final GlobalKey<State<StatefulWidget>> _postListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    uniqueTag = widget.uniqueTag;
    username = widget.username;
    profileController = Get.put(
      AuthorProfileController(username: username),
      tag: uniqueTag,
    );
    primaryTC = TabController(length: 4, vsync: this);
    videoSecondaryTC = TabController(length: 5, vsync: this);
    imageSecondaryTC = TabController(length: 5, vsync: this);
    playlistSecondaryTC = TabController(length: 5, vsync: this);

    primaryTC.addListener(_onTabChange);

    _videoBatchController = Get.put(
      BatchSelectController<Video>(),
      tag: 'author_profile_video_batch_$uniqueTag',
    );
    _imageBatchController = Get.put(
      BatchSelectController<ImageModel>(),
      tag: 'author_profile_image_batch_$uniqueTag',
    );

    _tabBarScrollController = ScrollController();
  }

  @override
  void dispose() {
    profileController.dispose();
    primaryTC.dispose();
    videoSecondaryTC.dispose();
    imageSecondaryTC.dispose();
    playlistSecondaryTC.dispose();
    _tabBarScrollController.dispose();
    Get.delete<AuthorProfileController>(tag: uniqueTag);
    Get.delete<BatchSelectController<Video>>(
      tag: 'author_profile_video_batch_$uniqueTag',
    );
    Get.delete<BatchSelectController<ImageModel>>(
      tag: 'author_profile_image_batch_$uniqueTag',
    );
    super.dispose();
  }

  void _onTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleScroll(double delta) {
    if (_tabBarScrollController.hasClients) {
      final double newOffset = _tabBarScrollController.offset + delta;
      if (newOffset < 0) {
        _tabBarScrollController.jumpTo(0);
      } else if (newOffset > _tabBarScrollController.position.maxScrollExtent) {
        _tabBarScrollController.jumpTo(
          _tabBarScrollController.position.maxScrollExtent,
        );
      } else {
        _tabBarScrollController.jumpTo(newOffset);
      }
    }
  }

  void showCommentModal(BuildContext context) {
    final t = slang.Translations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        t.common.commentList,
                        style: TextStyle(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleLarge?.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 添加评论按钮
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CommentInputBottomSheet(
                              title: t.common.sendComment,
                              submitText: t.common.send,
                              onSubmit: (text) async {
                                if (text.trim().isEmpty) {
                                  showToastWidget(
                                    MDToastWidget(
                                      message: t.errors.commentCanNotBeEmpty,
                                      type: MDToastType.error,
                                    ),
                                    position: ToastPosition.bottom,
                                  );
                                  return;
                                }
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
                                await profileController.commentController
                                    .postComment(text);
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_comment),
                      ),
                      // 关闭按钮
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // 评论列表
                Expanded(
                  child: Obx(
                    () => CommentSection(
                      controller: profileController.commentController,
                      authorUserId: profileController.author.value?.id,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    if (username.isEmpty) {
      return Center(child: Text(t.errors.errorWhileFetching));
    }

    return Obx(() {
      if (profileController.errorWidget.value != null) {
        return _buildErrorWidget(context);
      } else if (profileController.isProfileLoading.value &&
          profileController.author.value == null) {
        return const AuthorProfileSkeleton();
      } else if (!profileController.isProfileLoading.value &&
          profileController.author.value == null) {
        return Center(child: Text(t.errors.errorWhileFetching));
      }

      return _buildMainContent();
    });
  }

  Widget _buildMainContent() {
    // 判断是否为宽屏 (>= 800px)
    bool isWideScreen = MediaQuery.of(context).size.width >= 800;

    if (!isWideScreen) {
      return Stack(
        children: [
          Scaffold(
            body: ExtendedNestedScrollView(
              key: _key,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) =>
                      _buildHeaderSliver(context, innerBoxIsScrolled),
              onlyOneScrollInBody: true,
              pinnedHeaderSliverHeightBuilder: () =>
                  _calculatePinnedHeaderHeight(),
              body: _buildTabBarView(context, isWideScreen: false),
            ),
          ),
        ],
      );
    }

    // 宽屏布局 - 移除了 floatingActionButton
    return Stack(
      children: [
        Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧区域 - 基本信息
              SizedBox(
                width: 400, // 固定宽度
                child: CustomScrollView(
                  slivers: _buildHeaderSliver(context, false),
                ),
              ),
              // 分隔线
              const VerticalDivider(width: 1),
              // 右侧区域 - Tab内容
              Expanded(child: _buildTabBarView(context, isWideScreen: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.authorProfile.userProfile)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          profileController.errorWidget.value!,
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AppService.tryPop();
            },
            child: Text(t.common.back),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderSliver(
    BuildContext context,
    bool innerBoxIsScrolled,
  ) {
    final t = slang.Translations.of(context);
    return <Widget>[
      // header背景图
      SliverAppBar(
        expandedHeight: context.width * 43 / 150 > 300
            ? 300
            : context.width * 43 / 150,
        pinned: true,
        actions: [
          // 添加more按钮
          Obx(() {
            final popupMenuItems = <PopupMenuEntry<String>>[];
            if (userService.currentUser.value?.id ==
                profileController.author.value?.id) {
              popupMenuItems.add(
                PopupMenuItem(
                  value: 'create',
                  child: Row(
                    children: [
                      const Icon(Icons.article),
                      const SizedBox(width: 8),
                      Text(t.common.createPost),
                    ],
                  ),
                ),
              );
            } else if (userService.currentUser.value?.id != null) {
              // 如果不是本人且已登录，显示发起对话选项
              popupMenuItems.add(
                PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      const Icon(Icons.message),
                      const SizedBox(width: 8),
                      Text(t.conversation.startConversation),
                    ],
                  ),
                ),
              );
            }

            // 添加分享选项
            if (profileController.author.value != null) {
              popupMenuItems.add(
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(Icons.share),
                      const SizedBox(width: 8),
                      Text(t.common.share),
                    ],
                  ),
                ),
              );
            }

            // 如果没有可选项，则不显示
            if (popupMenuItems.isEmpty) {
              return const SizedBox.shrink();
            }

            return PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'create') {
                  _showCreatePostDialog();
                } else if (value == 'message') {
                  showAppDialog(
                    NewConversationDialog(
                      initUserId: profileController.author.value?.id,
                      onSubmit: () {
                        NaviService.navigateToConversationPage();
                      },
                    ),
                    barrierDismissible: true,
                  );
                } else if (value == 'share') {
                  // 分享用户主页
                  final username = profileController.author.value?.username;
                  if (username != null) {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => ShareUserBottomSheet(
                        username: username,
                        authorName: profileController.author.value?.name ?? '',
                        previewUrl:
                            profileController.headerBackgroundUrl.value ??
                            CommonConstants.defaultProfileHeaderUrl,
                        avatarUrl:
                            profileController.author.value?.avatar?.avatarUrl,
                        followerCount: profileController.followerCounts.value,
                        followingCount: profileController.followingCounts.value,
                        videoCount: profileController.videoCounts.value,
                        commentCount: profileController
                            .commentController
                            .comments
                            .value
                            .length,
                      ),
                      context: context,
                    );
                  }
                }
              },
              itemBuilder: (context) => popupMenuItems,
            );
          }),
          // 多选按钮
          // Removed the Obx multi-select button from actions as per instruction.
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // 进入图片详情页
                  final headerUrl =
                      profileController.headerBackgroundUrl.value ??
                      CommonConstants.defaultProfileHeaderUrl;
                  final headerHeroTag =
                      'author_header:${profileController.author.value?.id ?? headerUrl}';
                  ImageItem item = ImageItem(
                    url: headerUrl,
                    data: ImageItemData(
                      id: profileController.author.value?.id ?? '',
                      url: headerUrl,
                      originalUrl: headerUrl,
                    ),
                  );
                  final t = slang.Translations.of(context);
                  final menuItems = [
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
                    if (GetPlatform.isDesktop)
                      MenuItem(
                        title: t.galleryDetail.saveAs,
                        icon: Icons.download,
                        onTap: () => ImageUtils.downloadImageForDesktop(item),
                      ),
                    MenuItem(
                      title: t.download.saveToAppDirectory,
                      icon: Icons.save,
                      onTap: () => ImageUtils.downloadImageToAppDirectory(item),
                    ),
                  ];
                  pushPhotoViewWrapperOverlay(
                    context: context,
                    imageItems: [item],
                    initialIndex: 0,
                    menuItemsBuilder: (context, item) => menuItems,
                    heroTagBuilder: (_) => headerHeroTag,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Hero(
                    tag:
                        'author_header:${profileController.author.value?.id ?? (profileController.headerBackgroundUrl.value ?? CommonConstants.defaultProfileHeaderUrl)}',
                    child: CachedNetworkImage(
                      imageUrl:
                          profileController.headerBackgroundUrl.value ??
                          CommonConstants.defaultProfileHeaderUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              // 上次在线时间标签
              Positioned(
                right: 8,
                bottom: 40,
                child: Obx(() {
                  final user = profileController.author.value;
                  if (user == null || user.seenAt == null) {
                    return const SizedBox.shrink();
                  }
                  final t = slang.Translations.of(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.common.lastSeenAt(
                            str: CommonUtils.formatFriendlyTimestamp(
                              user.seenAt,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // 加入时间标签
              Positioned(
                right: 8,
                bottom: 8,
                child: Obx(() {
                  if (profileController.author.value?.createdAt == null) {
                    return const SizedBox.shrink();
                  }
                  final joinDate = profileController.author.value!.createdAt;
                  final t = slang.Translations.of(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.common.joined(
                            str: CommonUtils.formatFriendlyTimestamp(joinDate),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      // 用户信息
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrowScreen = constraints.maxWidth < 400;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: (() {
                          final avatarUrl =
                              profileController.author.value?.avatar?.avatarUrl;
                          final avatarHeroTag = avatarUrl == null
                              ? null
                              : 'author_avatar:${profileController.author.value?.id ?? avatarUrl}';

                          void openAvatar() {
                            if (avatarUrl == null) return;
                            ImageItem item = ImageItem(
                              url: avatarUrl,
                              data: ImageItemData(
                                id: profileController.author.value?.id ?? '',
                                url: avatarUrl,
                                originalUrl: avatarUrl,
                              ),
                              headers: const {
                                'referer': CommonConstants.iwaraBaseUrl,
                              },
                            );
                            final t = slang.Translations.of(context);
                            final menuItems = [
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
                              if (GetPlatform.isDesktop)
                                MenuItem(
                                  title: t.galleryDetail.saveAs,
                                  icon: Icons.download,
                                  onTap: () =>
                                      ImageUtils.downloadImageForDesktop(item),
                                ),
                              MenuItem(
                                title: t.download.saveToAppDirectory,
                                icon: Icons.save,
                                onTap: () =>
                                    ImageUtils.downloadImageToAppDirectory(
                                      item,
                                    ),
                              ),
                            ];
                            pushPhotoViewWrapperOverlay(
                              context: context,
                              imageItems: [item],
                              initialIndex: 0,
                              menuItemsBuilder: (context, item) => menuItems,
                              heroTagBuilder: avatarHeroTag == null
                                  ? null
                                  : (_) => avatarHeroTag,
                            );
                          }

                          final avatar = AvatarWidget(
                            user: profileController.author.value,
                            size: 70,
                            onTap: openAvatar,
                          );

                          return avatarHeroTag == null
                              ? avatar
                              : Hero(tag: avatarHeroTag, child: avatar);
                        })(),
                      ),
                      const SizedBox(width: 16),
                      // 用户名、粉丝数、关注数
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 用户名
                            Obx(() {
                              final user = profileController.author.value;
                              if (user == null) {
                                return const SizedBox.shrink();
                              }
                              return buildUserName(
                                context,
                                user,
                                fontSize: isNarrowScreen ? 20 : 24,
                                bold: true,
                              );
                            }),
                            const SizedBox(height: 8),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                // 用户名
                                Obx(() {
                                  final username =
                                      profileController.author.value?.username;
                                  if (username != null && username.isNotEmpty) {
                                    return SelectableText(
                                      '@$username',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: isNarrowScreen
                                            ? Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.fontSize
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.fontSize,
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                                MouseRegion(
                                  cursor:
                                      SystemMouseCursors.click, // 设置鼠标光标为点击效果
                                  child: Obx(() {
                                    final followerCount =
                                        CommonUtils.formatFriendlyNumber(
                                          profileController.followerCounts.value
                                              .toInt(),
                                        );
                                    return GestureDetector(
                                      onTap: () {
                                        NaviService.navigateToFollowersListPage(
                                          profileController.author.value?.id ??
                                              '',
                                          profileController
                                                  .author
                                                  .value
                                                  ?.name ??
                                              '',
                                          profileController
                                                  .author
                                                  .value
                                                  ?.username ??
                                              '',
                                        );
                                      },
                                      child: Text(
                                        '$followerCount ${t.common.follower}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: isNarrowScreen
                                              ? Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.fontSize
                                              : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.fontSize,
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                MouseRegion(
                                  cursor:
                                      SystemMouseCursors.click, // 设置鼠标光标为点击效果
                                  child: Obx(() {
                                    final followingCount =
                                        CommonUtils.formatFriendlyNumber(
                                          profileController
                                              .followingCounts
                                              .value
                                              .toInt(),
                                        );
                                    return GestureDetector(
                                      onTap: () {
                                        NaviService.navigateToFollowingListPage(
                                          profileController.author.value?.id ??
                                              '',
                                          profileController
                                                  .author
                                                  .value
                                                  ?.name ??
                                              '',
                                          profileController
                                                  .author
                                                  .value
                                                  ?.username ??
                                              '',
                                        );
                                      },
                                      child: Text(
                                        '$followingCount ${t.common.following}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: isNarrowScreen
                                              ? Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.fontSize
                                              : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.fontSize,
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                // 视频数
                                Obx(() {
                                  final videoCount =
                                      CommonUtils.formatFriendlyNumber(
                                        profileController.videoCounts.value
                                                ?.toInt() ??
                                            0,
                                      );
                                  return Text(
                                    '$videoCount ${t.common.video}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: isNarrowScreen
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.fontSize
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.fontSize,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            SizedBox(height: isNarrowScreen ? 4 : 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: isNarrowScreen ? 8.0 : 16.0,
                                runSpacing: isNarrowScreen ? 4.0 : 8.0,
                                alignment: WrapAlignment.start,
                                children: [
                                  // 朋友按钮
                                  Obx(() {
                                    // 如果是本人，则不显示按钮
                                    if (userService.currentUser.value?.id ==
                                        profileController.author.value?.id) {
                                      return const SizedBox.shrink();
                                    }

                                    return SizedBox(
                                      height: isNarrowScreen ? 32 : 36,
                                      child: FriendButtonWidget(
                                        user: profileController.author.value!,
                                        // isPending: profileController.isFriendRequestPending.value,
                                        onUserUpdated: (updatedUser) {
                                          profileController.author.value =
                                              updatedUser;
                                          profileController
                                              .isFriendRequestPending
                                              .value = !profileController
                                              .isFriendRequestPending
                                              .value;
                                        },
                                      ),
                                    );
                                  }),
                                  // 关注按钮
                                  Obx(() {
                                    // 如果是本人，则不显示按钮
                                    if (userService.currentUser.value?.id ==
                                        profileController.author.value?.id) {
                                      return const SizedBox.shrink();
                                    }

                                    if (profileController.author.value ==
                                        null) {
                                      return const SizedBox.shrink();
                                    }

                                    return SizedBox(
                                      height: isNarrowScreen ? 32 : 36,
                                      child: FollowButtonWidget(
                                        user: profileController.author.value!,
                                        onUserUpdated: (updatedUser) {
                                          profileController.author.value =
                                              updatedUser;
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isNarrowScreen ? 4 : 8),
                  // 用户标签
                  Obx(() {
                    final user = profileController.author.value;
                    if (user == null) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        // 高级会员标签
                        if (user.premium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade300,
                                  Colors.blue.shade300,
                                  Colors.pink.shade300,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t.common.premium,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        // 角色标签（非普通用户）
                        if (user.role != 'user')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        // 朋友标签
                        if (user.friend)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t.common.friend,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        // 粉丝标签
                        if (user.followedBy)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t.common.follower,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: isNarrowScreen ? 4.0 : 8.0,
                    runSpacing: isNarrowScreen ? 2.0 : 4.0,
                    children: [
                      // 个人简介
                      Obx(() {
                        return MediaDescriptionWidget(
                          defaultMaxLines: 1,
                          description:
                              profileController.authorDescription.value,
                          isDescriptionExpanded:
                              profileController.isDescriptionExpanded,
                        );
                      }),
                      SizedBox(
                        height: isNarrowScreen ? 4 : 8,
                        child: const SizedBox.shrink(),
                      ),
                      CommentEntryAreaButtonWidget(
                        commentController: profileController.commentController,
                        onClickButton: () {
                          showCommentModal(context);
                        },
                      ),
                      SizedBox(
                        height: isNarrowScreen ? 4 : 8,
                        child: const SizedBox.shrink(),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).width >= 800
                            ? computeBottomSafeInset(MediaQuery.of(context))
                            : 0,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // TabBar
    ];
  }

  Widget _buildTabBarView(BuildContext context, {bool isWideScreen = true}) {
    final t = slang.Translations.of(context);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isWideScreen ? TopPaddingHeightWidget() : const SizedBox.shrink(),
            MouseRegion(
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    _handleScroll(pointerSignal.scrollDelta.dy);
                  }
                },
                child: SingleChildScrollView(
                  controller: _tabBarScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      TabBar(
                        isScrollable: true,
                        physics: const NeverScrollableScrollPhysics(),
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        controller: primaryTC,
                        tabs: [
                          Tab(
                            child: Row(
                              children: [
                                const Icon(Icons.video_collection),
                                const SizedBox(width: 8),
                                Text(t.common.video),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                const Icon(Icons.image),
                                const SizedBox(width: 8),
                                Text(t.common.gallery),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                const Icon(Icons.playlist_play),
                                const SizedBox(width: 8),
                                Text(t.common.playlist),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                const Icon(Icons.article),
                                const SizedBox(width: 8),
                                Text(t.common.post),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: primaryTC,
                children: <Widget>[
                  Obx(
                    () => profileController.author.value?.id != null
                        ? ProfileVideoTabListWidget(
                            key: const Key('video'),
                            userId: profileController.author.value!.id,
                            tabKey: t.common.video,
                            tc: videoSecondaryTC,
                            onFetchFinished: ({int? count}) {
                              profileController.videoCounts.value = count;
                            },
                            isMultiSelectMode:
                                _videoBatchController.isMultiSelect.value,
                            selectedItemIds:
                                _videoBatchController.selectedMediaIds,
                            onItemSelect: (video) =>
                                _videoBatchController.toggleSelection(video),
                            onPageChanged: () =>
                                _videoBatchController.onPageChanged(),
                            onMultiSelectToggle: () =>
                                _videoBatchController.toggleMultiSelect(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => profileController.author.value?.id != null
                        ? ProfileImageModelTabListWidget(
                            key: const Key('image'),
                            userId: profileController.author.value!.id,
                            tabKey: t.common.gallery,
                            tc: imageSecondaryTC,
                            onFetchFinished: ({int? count}) {},
                            isMultiSelectMode:
                                _imageBatchController.isMultiSelect.value,
                            selectedItemIds:
                                _imageBatchController.selectedMediaIds,
                            onItemSelect: (image) =>
                                _imageBatchController.toggleSelection(image),
                            onPageChanged: () =>
                                _imageBatchController.onPageChanged(),
                            onMultiSelectToggle: () =>
                                _imageBatchController.toggleMultiSelect(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => profileController.author.value?.id != null
                        ? ProfilePlaylistTabListWidget(
                            key: const Key('playlist'),
                            userId: profileController.author.value!.id,
                            tabKey: t.common.playlist,
                            tc: playlistSecondaryTC,
                            onFetchFinished: ({int? count}) {},
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => profileController.author.value?.id != null
                        ? ProfilePostTabListWidget(
                            key: _postListKey,
                            widgetKey: _postListKey,
                            userId: profileController.author.value!.id,
                            tabKey: t.common.post,
                            tc: TabController(length: 1, vsync: this),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 批量下载悬浮按钮
        BatchActionFabColumn<Video>(
          controller: _videoBatchController,
          heroTagPrefix: 'author_profile_video_$uniqueTag',
          visible: () => primaryTC.index == 0,
        ),
        BatchActionFabColumn<ImageModel>(
          controller: _imageBatchController,
          heroTagPrefix: 'author_profile_image_$uniqueTag',
          visible: () => primaryTC.index == 1,
        ),
      ],
    );
  }

  double _calculatePinnedHeaderHeight() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
        //pinned SliverAppBar height in header
        kToolbarHeight;
    return pinnedHeaderHeight;
  }

  // 添加创建帖子的方法
  void _showCreatePostDialog() async {
    final t = slang.Translations.of(context);
    final PostService postService = Get.find<PostService>();
    final profilePostTabListWidget = context
        .findAncestorWidgetOfExactType<ProfilePostTabListWidget>();

    showAppDialog(
      PostInputDialog(
        onSubmit: (title, body) async {
          if (!mounted) return;

          final result = await postService.postPost(title, body);
          if (!mounted) return;

          if (result.isSuccess) {
            showToastWidget(
              MDToastWidget(
                message: t.common.success,
                type: MDToastType.success,
              ),
            );
            AppService.tryPop();
            profilePostTabListWidget?.refresh();
          } else if (result.message == t.errors.tooManyRequests) {
            // 如果是请求过于频繁，则获取冷却时间
            ApiResult<PostCooldownModel> cooldownResult = await postService
                .fetchPostCollingInfo();
            if (cooldownResult.isSuccess && cooldownResult.data != null) {
              final cooldown = cooldownResult.data!;
              if (cooldown.limited) {
                // 计算剩余时间,小数点后二位
                final remaining = cooldown.remaining; // 秒
                final hours = remaining ~/ 3600;
                final minutes = (remaining % 3600) ~/ 60;
                final seconds = remaining % 60;

                String timeStr =
                    '${t.errors.tooManyRequestsPleaseTryAgainLaterText} ';
                if (hours > 0) {
                  timeStr += '${t.errors.remainingHours(num: hours)} ';
                }
                if (minutes > 0) {
                  timeStr += '${t.errors.remainingMinutes(num: minutes)} ';
                }
                if (seconds > 0) {
                  timeStr += t.errors.remainingSeconds(num: seconds);
                }

                showToastWidget(
                  MDToastWidget(
                    message: timeStr.trim(),
                    type: MDToastType.error,
                  ),
                );
              }
            }
          } else {
            showToastWidget(
              MDToastWidget(message: result.message, type: MDToastType.error),
            );
          }
        },
      ),
      barrierDismissible: true,
    );
  }
}
