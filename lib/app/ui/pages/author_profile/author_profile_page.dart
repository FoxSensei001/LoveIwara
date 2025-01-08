import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/author_profile_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_image_model_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_post_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_video_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/profile_playlist_tab_list_widget.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/top_padding_height_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common/constants.dart';
import '../../../services/user_service.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import '../popular_media_list/widgets/media_description_widget.dart';
import 'controllers/authro_profile_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';

class AuthorProfilePage extends StatefulWidget {
  final String username;
  final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();

  AuthorProfilePage({super.key, required this.username});

  @override
  _AuthorProfilePageState createState() => _AuthorProfilePageState();
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
  late String username;

  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();
  late String uniqueTag;
  late ScrollController _tabBarScrollController;

  @override
  void initState() {
    super.initState();
    uniqueTag = widget.uniqueTag;
    username = widget.username;
    profileController =
        Get.put(AuthorProfileController(username: username), tag: uniqueTag);
    primaryTC = TabController(length: 4, vsync: this);
    videoSecondaryTC = TabController(length: 5, vsync: this);
    imageSecondaryTC = TabController(length: 5, vsync: this);
    playlistSecondaryTC = TabController(length: 5, vsync: this);
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
    super.dispose();
  }

  void _handleScroll(double delta) {
    if (_tabBarScrollController.hasClients) {
      final double newOffset = _tabBarScrollController.offset + delta;
      if (newOffset < 0) {
        _tabBarScrollController.jumpTo(0);
      } else if (newOffset > _tabBarScrollController.position.maxScrollExtent) {
        _tabBarScrollController
            .jumpTo(_tabBarScrollController.position.maxScrollExtent);
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
                          fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 添加评论按钮
                      TextButton.icon(
                        onPressed: () {
                          Get.dialog(
                            CommentInputDialog(
                              title: t.common.sendComment,
                              submitText: t.common.send,
                              onSubmit: (text) async {
                                if (text.trim().isEmpty) {
                                  showToastWidget(MDToastWidget(
                                      message: t.errors.commentCanNotBeEmpty,
                                      type: MDToastType.error));
                                  return;
                                }
                                final UserService userService = Get.find();
                                if (!userService.isLogin) {
                                  showToastWidget(MDToastWidget(
                                      message: t.errors.pleaseLoginFirst,
                                      type: MDToastType.error));
                                  Get.toNamed(Routes.LOGIN);
                                  return;
                                }
                                await profileController.commentController
                                    .postComment(text);
                              },
                            ),
                            barrierDismissible: true,
                          );
                        },
                        icon: const Icon(Icons.add_comment),
                        label: Text(t.common.sendComment),
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
                  child: Obx(() => CommentSection(
                      controller: profileController.commentController,
                      authorUserId: profileController.author.value?.id)),
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
      } else if (profileController.isProfileLoading.value) {
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
            floatingActionButton: _buildScrollToTopButton(),
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
              Expanded(
                child: _buildTabBarView(context, isWideScreen: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.authorProfile.userProfile),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          profileController.errorWidget.value!,
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              profileController.fetchAuthorDescription();
            },
            child: Text(t.common.retry),
          )
        ],
      ),
    );
  }

  Widget _buildScrollToTopButton() {
    return FloatingActionButton(
      child: const Icon(Icons.file_upload),
      onPressed: () {
        _key.currentState?.outerController.animateTo(
          0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
        );
      },
    );
  }

  List<Widget> _buildHeaderSliver(
      BuildContext context, bool innerBoxIsScrolled) {
    final t = slang.Translations.of(context);
    return <Widget>[
      // header背景图
      SliverAppBar(
        expandedHeight:
            context.width * 43 / 150 > 300 ? 300 : context.width * 43 / 150,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: GestureDetector(
            onTap: () {
              // 进入图片详情页
              ImageItem item = ImageItem(
                  url: profileController.headerBackgroundUrl.value ??
                      CommonConstants.defaultProfileHeaderUrl,
                  data: ImageItemData(
                      id: profileController.author.value?.id ?? '',
                      url: profileController.headerBackgroundUrl.value ??
                          CommonConstants.defaultProfileHeaderUrl,
                      originalUrl:
                          profileController.headerBackgroundUrl.value ??
                              CommonConstants.defaultProfileHeaderUrl));
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
              NaviService.navigateToPhotoViewWrapper(
                  imageItems: [item],
                  initialIndex: 0,
                  menuItemsBuilder: (context, item) => menuItems);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click, // 添加鼠标悬浮效果
              child: CachedNetworkImage(
                imageUrl: profileController.headerBackgroundUrl.value ??
                    CommonConstants.defaultProfileHeaderUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      // 用户信息
      SliverToBoxAdapter(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                AvatarWidget(
                  avatarUrl: profileController.author.value?.avatar?.avatarUrl,
                  defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                  headers: const {'referer': CommonConstants.iwaraBaseUrl},
                  radius: 40,
                  isPremium: profileController.author.value?.premium ?? false,
                  isAdmin: profileController.author.value?.isAdmin ?? false,
                ),
                const SizedBox(width: 16),
                // 用户名、粉丝数、关注数
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // 修改名称样式，使用主题色并加粗
                          Obx(() {
                            bool isPremium =
                                profileController.author.value?.premium == true;
                            if (!isPremium) {
                              return SelectableText(
                                profileController.author.value?.name ?? '',
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }

                            return ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.purple.shade300,
                                  Colors.blue.shade300,
                                  Colors.pink.shade300,
                                ],
                              ).createShader(bounds),
                              child: SelectableText(
                                profileController.author.value?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          Obx(() {
                            bool isPremium =
                                profileController.author.value?.premium == true;
                            return isPremium
                                ? Tooltip(
                                    triggerMode: TooltipTriggerMode.tap,
                                    message: t.common.premium,
                                    preferBelow: false,
                                    child: Icon(
                                      Icons.stars,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }),
                          Obx(() {
                            // 是粉丝
                            bool isFollower =
                                profileController.author.value?.followedBy ??
                                    false;
                            return isFollower
                                ? Tooltip(
                                    triggerMode: TooltipTriggerMode.tap,
                                    message: t.common.follower,
                                    preferBelow: false,
                                    child: Icon(
                                      Icons.person_add,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }),
                          Obx(() {
                            // 是朋友
                            bool isFriend =
                                profileController.author.value?.friend ?? false;
                            return isFriend
                                ? Tooltip(
                                    triggerMode: TooltipTriggerMode.tap,
                                    message: t.common.friend,
                                    preferBelow: false,
                                    child: Icon(
                                      Icons.favorite,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          })
                        ],
                      ),
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
                                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          MouseRegion(
                            cursor: SystemMouseCursors.click, // 设置鼠标光标为点击效果
                            child: Obx(() {
                              final followerCount =
                                  CommonUtils.formatFriendlyNumber(
                                      profileController.followerCounts.value
                                          .toInt());
                              return GestureDetector(
                                onTap: () {
                                  NaviService.navigateToFollowersListPage(
                                    profileController.author.value?.id ?? '',
                                    profileController.author.value?.name ?? '',
                                    profileController.author.value?.username ??
                                        '',
                                  );
                                },
                                child: Text(
                                  '$followerCount ${t.common.follower}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                  ),
                                ),
                              );
                            }),
                          ),

                          MouseRegion(
                            cursor: SystemMouseCursors.click, // 设置鼠标光标为点击效果
                            child: Obx(() {
                              final followingCount =
                                  CommonUtils.formatFriendlyNumber(
                                      profileController.followingCounts.value
                                          .toInt());
                              return GestureDetector(
                                onTap: () {
                                  NaviService.navigateToFollowingListPage(
                                      profileController.author.value?.id ?? '',
                                      profileController.author.value?.name ??
                                          '',
                                      profileController
                                              .author.value?.username ??
                                          '');
                                },
                                child: Text(
                                  '$followingCount ${t.common.following}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                  ),
                                ),
                              );
                            }),
                          ),

                          // 视频数
                          Obx(() {
                            final videoCount = CommonUtils.formatFriendlyNumber(
                                profileController.videoCounts.value?.toInt() ??
                                    0);
                            return Text(
                              '$videoCount ${t.common.video}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 8.0,
                        children: [
                          // 朋友
                          Obx(() {
                            // 如果是本人，则不显示按钮
                            if (userService.currentUser.value?.id ==
                                profileController.author.value?.id) {
                              return const SizedBox.shrink();
                            }

                            // 加载中状态
                            if (profileController.isFriendLoading.value) {
                              return ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.person_add, size: 18),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(t.common.loading),
                                  ],
                                ),
                              );
                            }

                            // 处于代办状态
                            if (profileController.isFriendRequestPending.value) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  // 取消朋友申请
                                  profileController.cancelFriendRequest();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                icon: const Icon(Icons.person_remove, size: 18),
                                label: Text(t.common.cancelFriendRequest),
                              );
                            // 是朋友
                            } else if (profileController.author.value?.friend == true) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  // 取消朋友
                                  profileController.cancelFriendRequest();
                                },
                                icon: const Icon(Icons.person_remove, size: 18),
                                label: Text(t.common.removeFriend),
                              );
                            } else {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  // 发送朋友申请
                                  profileController.sendFriendRequest();
                                },
                                icon: const Icon(Icons.person_add, size: 18),
                                label: Text(t.common.addFriend),
                              );
                            }
                          }),
                          // 关注
                          Obx(() {
                            // 如果是本人，则不显示按钮
                            if (userService.currentUser.value?.id ==
                                profileController.author.value?.id) {
                              return const SizedBox.shrink();
                            }

                            if (profileController.author.value == null) {
                              return const SizedBox.shrink();
                            }

                            return FollowButtonWidget(
                              user: profileController.author.value!,
                              onUserUpdated: (updatedUser) {
                                profileController.author.value = updatedUser;
                              },
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
      // 个人简介
      SliverToBoxAdapter(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MediaDescriptionWidget(
              defaultMaxLines: 1,
              description: profileController.authorDescription.value,
              isDescriptionExpanded: profileController.isDescriptionExpanded,
            )),
      ),
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: CommentEntryAreaButtonWidget(
            commentController: profileController.commentController,
            onClickButton: () {
              showCommentModal(context);
            },
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
            height: Get.context != null
                ? MediaQuery.of(Get.context!).padding.bottom
                : 0),
      ),
      // TabBar
    ];
  }

  Widget _buildTabBarView(BuildContext context, {bool isWideScreen = true}) {
    final t = slang.Translations.of(context);
    return Column(
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
              child: TabBar(
                isScrollable: true,
                physics: const NeverScrollableScrollPhysics(),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
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
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: primaryTC,
            children: <Widget>[
              Obx(() => profileController.author.value?.id != null
                  ? ProfileVideoTabListWidget(
                      key: const Key('video'),
                      userId: profileController.author.value!.id,
                      tabKey: t.common.video,
                      tc: videoSecondaryTC,
                      onFetchFinished: ({int? count}) {
                        profileController.videoCounts.value = count;
                      })
                  : const SizedBox.shrink()),
              Obx(() => profileController.author.value?.id != null
                  ? ProfileImageModelTabListWidget(
                      key: const Key('image'),
                      userId: profileController.author.value!.id,
                      tabKey: t.common.gallery,
                      tc: imageSecondaryTC,
                      onFetchFinished: ({int? count}) {})
                  : const SizedBox.shrink()),
              Obx(() => profileController.author.value?.id != null
                  ? ProfilePlaylistTabListWidget(
                      key: const Key('playlist'),
                      userId: profileController.author.value!.id,
                      tabKey: t.common.playlist,
                      tc: playlistSecondaryTC,
                      onFetchFinished: ({int? count}) {})
                  : const SizedBox.shrink()),
              Obx(() => profileController.author.value?.id != null
                  ? ProfilePostTabListWidget(
                      key: const Key('post'),
                      userId: profileController.author.value!.id,
                      tabKey: t.common.post,
                      tc: TabController(length: 1, vsync: this),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
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
}
