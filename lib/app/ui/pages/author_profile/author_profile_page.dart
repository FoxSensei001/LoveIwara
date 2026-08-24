import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';

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
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/routes/app_router.dart' show routeObserver;
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/utils/image_utils.dart';

import '../../../../common/constants.dart';
import '../../../services/user_service.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import '../popular_media_list/widgets/media_description_widget.dart';
import 'controllers/authro_profile_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/block_user_button_widget.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/post_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/new_conversation_dialog.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/share_user_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/friend_button_widget.dart';
import '../popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class AuthorProfilePage extends StatefulWidget {
  final String username;
  final User? initialUser;
  final int initialTabIndex;
  final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();

  AuthorProfilePage({
    super.key,
    required this.username,
    this.initialUser,
    this.initialTabIndex = 0,
  });

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage>
    with TickerProviderStateMixin, RouteAware {
  late final AuthorProfileController profileController;
  final UserService userService = Get.find<UserService>();
  final UserPreferenceService userPreferenceService =
      Get.find<UserPreferenceService>();
  late TabController primaryTC;
  late TabController videoSecondaryTC;
  late TabController imageSecondaryTC;
  late TabController playlistSecondaryTC;
  late TabController postSecondaryTC;
  late final BatchSelectController<Video> _videoBatchController;
  late final BatchSelectController<ImageModel> _imageBatchController;
  final RxBool _isPaginated = false.obs;
  late String username;

  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();
  late String uniqueTag;

  /// 窄屏：外层 / 内层滚动位置（控制右下角「回到顶部」浮钮）。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);
  double _outerScrollPixels = 0;
  double _innerScrollPixels = 0;
  final GlobalKey<State<StatefulWidget>> _postListKey = GlobalKey();

  // 各 tab 列表用 GlobalKey：宽窄布局切换时子树是被搬走而不是销毁重建，
  // 列表 State 与其数据仓库得以保留（局部 Key 会导致整棵子树重建 + 重新拉数据）。
  final GlobalKey _videoTabKey = GlobalKey();
  final GlobalKey _imageTabKey = GlobalKey();
  final GlobalKey _playlistTabKey = GlobalKey();

  /// 本页是否被上层「页面级」路由（视频详情页等）盖住。弹层不计入，见 [didPushNext]。
  bool _isCovered = false;

  /// 最后一次「可见时」判定的宽窄布局。被盖住期间不跟随尺寸变化，
  /// 避免在不可见时因转屏跨过 800dp 而重建整棵 tab 子树。
  bool? _lastVisibleIsWide;

  @override
  void initState() {
    super.initState();
    uniqueTag = widget.uniqueTag;
    username = widget.username;
    profileController = Get.put(
      AuthorProfileController(
        username: username,
        initialUser: widget.initialUser,
      ),
      tag: uniqueTag,
    );
    primaryTC = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    videoSecondaryTC = TabController(length: 5, vsync: this);
    imageSecondaryTC = TabController(length: 5, vsync: this);
    playlistSecondaryTC = TabController(length: 5, vsync: this);
    postSecondaryTC = TabController(length: 1, vsync: this);

    primaryTC.addListener(_onTabChange);

    _videoBatchController = Get.put(
      BatchSelectController<Video>(),
      tag: 'author_profile_video_batch_$uniqueTag',
    );
    _imageBatchController = Get.put(
      BatchSelectController<ImageModel>(),
      tag: 'author_profile_image_batch_$uniqueTag',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  // ===== RouteAware：被盖住 / 重新露出 =====

  @override
  void didPushNext() {
    // 只有「页面级」路由压上来才算被盖住。对话框 / bottom sheet 同样会触发
    // didPushNext，但本页大半仍然露着，必须继续跟随尺寸——否则横屏开着弹层再转
    // 竖屏，会把宽屏布局(固定 400 宽的左栏)塞进 360dp，Tab 区宽度归零并溢出。
    // observers 顺序是 [OverlayTracker.shell, routeObserver, ...]，进到这里时
    // 弹层计数已经加过了。
    if (OverlayTracker.instance.hasOverlay) return;
    _isCovered = true;
  }

  @override
  void didPopNext() {
    // 重新露出：解冻，按当前尺寸重新判定布局。
    // 不需要 setState：_buildMainContent 里对 ModalRoute 的 isCurrent 建立了依赖，
    // 本页重新变成栈顶时框架会自动重建（也避开了声明式移除路由时
    // didPopNext 落在 build 阶段、setState 抛异常的问题）。
    _isCovered = false;
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    profileController.dispose();
    primaryTC.dispose();
    videoSecondaryTC.dispose();
    imageSecondaryTC.dispose();
    playlistSecondaryTC.dispose();
    postSecondaryTC.dispose();
    _showBackToTop.dispose();
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

  void _togglePaginationMode() {
    final isPaginated = !_isPaginated.value;
    _isPaginated.value = isPaginated;
    _videoBatchController.setPaginatedMode(isPaginated);
    _imageBatchController.setPaginatedMode(isPaginated);
  }

  bool _handleNestedScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification &&
        notification is! OverscrollNotification) {
      return false;
    }
    // depth 0 = ExtendedNestedScrollView 外层（头图 + 资料区），depth 1 = 内层列表
    if (notification.depth == 0) {
      _outerScrollPixels = notification.metrics.pixels;
    } else if (notification.depth == 1) {
      _innerScrollPixels = notification.metrics.pixels;
    }
    final show = _outerScrollPixels > 240 || _innerScrollPixels > 600;
    if (_showBackToTop.value != show) _showBackToTop.value = show;
    return false;
  }

  void _scrollToTop() {
    final state = _key.currentState;
    if (state == null) return;
    final inner = state.innerController;
    if (inner.hasClients) {
      inner.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    final outer = state.outerController;
    if (outer.hasClients) {
      outer.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮（窄屏）。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(
      () => Positioned(
        right: 16,
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (_isPaginated.value ? PaginationBar.barHeight : 0),
        child: ValueListenableBuilder<bool>(
          valueListenable: _showBackToTop,
          builder: (context, visible, _) => GlassReveal(
            visible: visible,
            builder: (context, m) => GlassIconButton(
              materialize: m,
              standalone: true,
              icon: const Icon(Icons.vertical_align_top),
              tooltip: t.common.scrollToTop,
              onPressed: _scrollToTop,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyAuthorName(String authorName) async {
    final normalizedName = authorName.trim();
    if (normalizedName.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: normalizedName));
    if (!mounted) {
      return;
    }
    showGlassToast(
      slang.t.logViewer.copiedToClipboard,
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  Future<void> _copyUsername(String username) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: normalizedUsername));
    if (!mounted) {
      return;
    }
    showGlassToast(
      slang.t.personalProfile.usernameCopied,
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  void showCommentModal(BuildContext context) {
    final t = slang.Translations.of(context);
    showGlassDraggableBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GlassDraggableBottomSheet(
          initialChildSize: 0.75,
          minChildSize: 0.2,
          maxChildSize: 0.92,
          snap: true,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        t.common.commentList,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 排序 / 发评论合成一只玻璃胶囊
                      GlassButtonGroup(
                        children: [
                          Obx(
                            () => GlassIconButton(
                              icon: Icon(
                                profileController
                                        .commentController
                                        .sortOrder
                                        .value
                                    ? Icons
                                          .arrow_downward_rounded // 倒序图标
                                    : Icons.arrow_upward_rounded, // 正序图标
                              ),
                              tooltip:
                                  profileController
                                      .commentController
                                      .sortOrder
                                      .value
                                  ? t.common.createTimeDesc
                                  : t.common.createTimeAsc,
                              onPressed: profileController
                                  .commentController
                                  .toggleSortOrder,
                            ),
                          ),
                          // 添加评论按钮
                          GlassIconButton(
                            icon: const Icon(Icons.add_comment),
                            tooltip: t.common.sendComment,
                            onPressed: () {
                              showGlassBottomSheet(
                                context: context,
                                builder: (context) => CommentInputBottomSheet(
                                  title: t.common.sendComment,
                                  submitText: t.common.send,
                                  onSubmit: (text) async {
                                    if (text.trim().isEmpty) {
                                      showGlassToast(
                                        t.errors.commentCanNotBeEmpty,
                                        type: GlassToastType.error,
                                        position: GlassToastPosition.bottom,
                                      );
                                      return;
                                    }
                                    final UserService userService = Get.find();
                                    if (!userService.isAuthenticated) {
                                      showGlassToast(
                                        t.errors.pleaseLoginFirst,
                                        type: GlassToastType.error,
                                        position: GlassToastPosition.bottom,
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
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // 关闭按钮：弹层关闭键一律玻璃圆钮
                      GlassIconButton(
                        standalone: true,
                        icon: const Icon(Icons.close),
                        tooltip: t.common.close,
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
                      scrollController: scrollController,
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
    // 判断是否为宽屏 (>= 800px)。
    // 被上层页面盖住时沿用最后一次可见时的判定：视频详情页转横屏会把本页尺寸
    // 带过 800dp，若跟着切布局，整棵 tab 子树会在不可见时被销毁重建（数据重拉、
    // 滚动归零），返回后用户就看到列表被刷掉且回到顶部。
    // `!isCurrent` 只作兜底：RouteObserver 不会把 removeRoute / pushReplacement
    // 转成 didPopNext，只认 _isCovered 有可能永久冻结。本页确实回到栈顶时，
    // 无论 _isCovered 是什么都按实时尺寸走。
    final bool isCurrent = ModalRoute.isCurrentOf(context) ?? true;
    final bool covered = _isCovered && !isCurrent;

    final bool liveIsWide = MediaQuery.sizeOf(context).width >= 800;
    final bool isWideScreen = covered
        ? (_lastVisibleIsWide ?? liveIsWide)
        : liveIsWide;
    if (!covered) {
      _lastVisibleIsWide = liveIsWide;
    }

    if (!isWideScreen) {
      return Stack(
        children: [
          Scaffold(
            body: NotificationListener<ScrollNotification>(
              onNotification: _handleNestedScrollNotification,
              child: ExtendedNestedScrollView(
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
          ),
          _buildScrollToTopFab(context),
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
        // 顶栏本身透明：展开时按钮悬浮在头图上，收起后由 flexibleSpace 里的
        // 渐变蒙层托底，内容从按钮背后经过（与首页玻璃 header 一致）
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        // 透明底色会被 AppBar 估成「深色背景」而把状态栏图标设成白色，
        // 这里按主题明暗显式指定
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 16 + GlassTokens.pillHeight + 8,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.arrow_back),
              tooltip: t.common.back,
              onPressed: AppService.tryPop,
            ),
          ),
        ),
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

            // 有可选项时显示胶囊，没有时收成 0 宽——用 GlassShapeSwitcher
            // 让整块 action group 淡入淡出+宽度过渡（未登录访客切换到已登录、
            // 或作者信息延迟加载时都会命中这次形变）。
            final Widget content = popupMenuItems.isEmpty
                ? const KeyedSubtree(
                    key: ValueKey('actions-empty'),
                    child: SizedBox.shrink(),
                  )
                : Center(
                    key: const ValueKey('actions-menu'),
                    child: GlassButtonGroup(
                      children: [
                        SizedBox(
                          width: GlassTokens.groupIconButtonSize,
                          height: GlassTokens.groupIconButtonSize,
                          child: PopupMenuButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert,
                              size: GlassTokens.iconSize,
                            ),
                            position: PopupMenuPosition.under,
                            // 往下挪一点，别压住玻璃胶囊本身
                            offset: const Offset(0, 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              if (value == 'create') {
                                _showCreatePostDialog();
                              } else if (value == 'message') {
                                showAppDialog(
                                  NewConversationDialog(
                                    initUserId:
                                        profileController.author.value?.id,
                                    onSubmit: () {
                                      NaviService.navigateToConversationPage();
                                    },
                                  ),
                                  barrierDismissible: true,
                                );
                              } else if (value == 'share') {
                                // 分享用户主页
                                final username =
                                    profileController.author.value?.username;
                                if (username != null) {
                                  showGlassBottomSheet(
                                    builder: (context) => ShareUserBottomSheet(
                                      username: username,
                                      authorName:
                                          profileController
                                              .author
                                              .value
                                              ?.name ??
                                          '',
                                      previewUrl:
                                          profileController
                                              .headerBackgroundUrl
                                              .value ??
                                          CommonConstants
                                              .defaultProfileHeaderUrl,
                                      avatarUrl: profileController
                                          .author
                                          .value
                                          ?.avatar
                                          ?.avatarUrl,
                                      followerCount: profileController
                                          .followerCounts
                                          .value,
                                      followingCount: profileController
                                          .followingCounts
                                          .value,
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
                          ),
                        ),
                      ],
                    ),
                  );
            return GlassShapeSwitcher(child: content);
          }),
          const SizedBox(width: 16),
          // 多选按钮
          // Removed the Obx multi-select button from actions as per instruction.
        ],
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            final double statusBar = MediaQuery.of(context).padding.top;
            final double minExtent = statusBar + kToolbarHeight;
            // 只在最后 ~48px 的收起过程中把蒙层淡入，展开时头图上不压蒙层
            final double scrimOpacity =
                ((minExtent + 48 - constraints.maxHeight) / 48).clamp(0.0, 1.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                FlexibleSpaceBar(
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
                                onTap: () =>
                                    ImageUtils.downloadImageForDesktop(item),
                              ),
                            MenuItem(
                              title: t.download.saveToAppDirectory,
                              icon: Icons.save,
                              onTap: () =>
                                  ImageUtils.downloadImageToAppDirectory(item),
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
                          if (profileController.author.value?.createdAt ==
                              null) {
                            return const SizedBox.shrink();
                          }
                          final joinDate =
                              profileController.author.value!.createdAt;
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
                                    str: CommonUtils.formatFriendlyTimestamp(
                                      joinDate,
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
                    ],
                  ),
                ),
                if (scrimOpacity > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: scrimOpacity,
                      child: EdgeFadeScrim.top(
                        // smoothstep 在 height 处刚好衰减到 0，不会出现硬边
                        height: minExtent,
                        solidExtent: statusBar,
                      ),
                    ),
                  ),
              ],
            );
          },
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
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _copyAuthorName(user.name),
                                  child: buildUserName(
                                    context,
                                    user,
                                    fontSize: isNarrowScreen ? 20 : 24,
                                    bold: true,
                                  ),
                                ),
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
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _copyUsername(username),
                                        child: Text(
                                          '@$username',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: isNarrowScreen
                                                ? Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.fontSize
                                                : Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.fontSize,
                                          ),
                                        ),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 操作按钮：占满整行宽度，空间不足时自动换行
                  SizedBox(height: isNarrowScreen ? 8 : 12),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // 朋友按钮
                      Obx(() {
                        // 如果是本人，则不显示按钮
                        if (userService.currentUser.value?.id ==
                            profileController.author.value?.id) {
                          return const SizedBox.shrink();
                        }

                        return FriendButtonWidget(
                          iconOnly: true,
                          user: profileController.author.value!,
                          onUserUpdated: (updatedUser) {
                            profileController.author.value = updatedUser;
                            profileController.isFriendRequestPending.value =
                                !profileController.isFriendRequestPending.value;
                          },
                        );
                      }),
                      // 关注按钮
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
                          iconOnly: true,
                          user: profileController.author.value!,
                          onUserUpdated: (updatedUser) {
                            profileController.author.value = updatedUser;
                          },
                        );
                      }),
                      // 屏蔽按钮（本地内容屏蔽）
                      Obx(() {
                        if (userService.currentUser.value?.id ==
                            profileController.author.value?.id) {
                          return const SizedBox.shrink();
                        }
                        if (profileController.author.value == null) {
                          return const SizedBox.shrink();
                        }
                        return BlockUserButtonWidget(
                          iconOnly: true,
                          user: profileController.author.value!,
                        );
                      }),
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
    // 主 Tab 行悬浮在各 tab 列表之上（宽屏时它上方还有状态栏）；
    // 各 tab 自己再把排序行叠在它下面，并用 paddingTop 让出这两行。
    final double headerTop = isWideScreen
        ? MediaQuery.of(context).padding.top
        : 0.0;
    const double primaryRowHeight = GlassTokens.pillHeight + 16;
    final double overlayTopInset = headerTop + primaryRowHeight;
    final double scrimSolidExtent = headerTop;
    // 宽屏时本 Stack 在 Row/Expanded 下拿到的是「高度松约束」，需要
    // StackFit.expand 才能撑满可用空间。
    return BatchDownloadSelectionScope(
      // 视频 / 图库两个控制器只广播当前 tab 那一个
      controllers: [_videoBatchController, _imageBatchController],
      activeIndex: () => primaryTC.index,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: TabBarView(
              controller: primaryTC,
              children: <Widget>[
                Obx(
                  () => profileController.author.value?.id != null
                      ? ProfileVideoTabListWidget(
                          key: _videoTabKey,
                          userId: profileController.author.value!.id,
                          tabKey: t.common.video,
                          tc: videoSecondaryTC,
                          overlayTopInset: overlayTopInset,
                          scrimSolidExtent: scrimSolidExtent,
                          onFetchFinished: ({int? count}) {},
                          isMultiSelectMode:
                              _videoBatchController.isMultiSelect.value,
                          selectedItemIds:
                              _videoBatchController.selectedMediaIds,
                          onItemSelect: (video) =>
                              _videoBatchController.toggleSelection(video),
                          onPageChanged: () {
                            _videoBatchController.onPageChanged();
                            _scrollToTop();
                          },
                          isPaginated: _isPaginated.value,
                          onPaginationToggle: _togglePaginationMode,
                          onMultiSelectToggle: () =>
                              _videoBatchController.toggleMultiSelect(),
                          onOpenVideo: _openVideoFromAuthorProfile,
                        )
                      : const SizedBox.shrink(),
                ),
                Obx(
                  () => profileController.author.value?.id != null
                      ? ProfileImageModelTabListWidget(
                          key: _imageTabKey,
                          userId: profileController.author.value!.id,
                          tabKey: t.common.gallery,
                          tc: imageSecondaryTC,
                          overlayTopInset: overlayTopInset,
                          scrimSolidExtent: scrimSolidExtent,
                          onFetchFinished: ({int? count}) {},
                          isMultiSelectMode:
                              _imageBatchController.isMultiSelect.value,
                          selectedItemIds:
                              _imageBatchController.selectedMediaIds,
                          onItemSelect: (image) =>
                              _imageBatchController.toggleSelection(image),
                          onPageChanged: () {
                            _imageBatchController.onPageChanged();
                            _scrollToTop();
                          },
                          isPaginated: _isPaginated.value,
                          onPaginationToggle: _togglePaginationMode,
                          onMultiSelectToggle: () =>
                              _imageBatchController.toggleMultiSelect(),
                        )
                      : const SizedBox.shrink(),
                ),
                Obx(
                  () => profileController.author.value?.id != null
                      ? ProfilePlaylistTabListWidget(
                          overlayTopInset: overlayTopInset,
                          scrimSolidExtent: scrimSolidExtent,
                          key: _playlistTabKey,
                          userId: profileController.author.value!.id,
                          tabKey: t.common.playlist,
                          tc: playlistSecondaryTC,
                          onFetchFinished: ({int? count}) {},
                          isPaginated: _isPaginated.value,
                          onPaginationToggle: _togglePaginationMode,
                          onPageChanged: _scrollToTop,
                        )
                      : const SizedBox.shrink(),
                ),
                Obx(
                  () => profileController.author.value?.id != null
                      ? ProfilePostTabListWidget(
                          overlayTopInset: overlayTopInset,
                          scrimSolidExtent: scrimSolidExtent,
                          key: _postListKey,
                          widgetKey: _postListKey,
                          userId: profileController.author.value!.id,
                          tabKey: t.common.post,
                          tc: postSecondaryTC,
                          isPaginated: _isPaginated.value,
                          onPaginationToggle: _togglePaginationMode,
                          onPageChanged: _scrollToTop,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Positioned(
            top: headerTop,
            left: 0,
            right: 0,
            height: primaryRowHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              // 空间够就平铺分段胶囊，不够（露不出 2.5 个完整段）退化成
              // 下拉钮——阈值与订阅页/热门列表页的子栏目胶囊共用同一约定
              // （见 GlassSegmentedControl.minWidthFor）。
              child: LayoutBuilder(
                builder: (context, rowConstraints) {
                  final primaryTabItems = [
                    GlassSegmentItem(
                      label: t.common.video,
                      icon: const Icon(Icons.video_collection),
                    ),
                    GlassSegmentItem(
                      label: t.common.gallery,
                      icon: const Icon(Icons.image),
                    ),
                    GlassSegmentItem(
                      label: t.common.playlist,
                      icon: const Icon(Icons.playlist_play),
                    ),
                    GlassSegmentItem(
                      label: t.common.post,
                      icon: const Icon(Icons.article),
                    ),
                  ];
                  final bool useSegmented =
                      rowConstraints.maxWidth >=
                      GlassSegmentedControl.minWidthFor(
                        context,
                        primaryTabItems,
                      );
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Obx(() {
                      // 选择态下这只胶囊改报「已选 N 项」：进选择态是一次页面级
                      // 的模式切换，header 不该毫无反应。
                      // 两个控制器的 Rx 都要在分支之外读一次：播放列表 / 帖子 tab
                      // 上 batch 为 null，那一支不碰可观察量会让 Obx 抛 ObxError。
                      final bool videoSelecting =
                          _videoBatchController.isMultiSelect.value;
                      final bool imageSelecting =
                          _imageBatchController.isMultiSelect.value;
                      final batch = primaryTC.index == 0
                          ? _videoBatchController
                          : (primaryTC.index == 1
                                ? _imageBatchController
                                : null);
                      final bool selecting = primaryTC.index == 0
                          ? videoSelecting
                          : (primaryTC.index == 1 ? imageSelecting : false);
                      if (batch != null && selecting) {
                        return GlassCapsuleMorph(
                          child: SizedBox(
                            key: const ValueKey('selection'),
                            width: 168,
                            child: GlassSelectionSummary(
                              selectedCount: batch.selectedCount,
                              allSelected: false,
                              // 懒加载列表够不到未加载的部分，不给全选
                              onToggleAll: null,
                            ),
                          ),
                        );
                      }
                      return GlassCapsuleMorph(
                        child: useSegmented
                            ? GlassSegmentedControl(
                                key: const ValueKey('segmented'),
                                flat: true,
                                selectedIndex: primaryTC.index,
                                progress: primaryTC.animation,
                                onChanged: primaryTC.animateTo,
                                items: primaryTabItems,
                              )
                            : KeyedSubtree(
                                key: const ValueKey('dropdown'),
                                child: _buildPrimaryTabDropdown(
                                  context,
                                  primaryTabItems,
                                ),
                              ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          // 批量动作：瀑布流模式下的底部玻璃坞；分页模式下动作行由分页栏
          // 自己承载（见 BatchSelectionScope），底部不会出现第二条玻璃。
          Obx(() => GlassSelectionDock(paginated: _isPaginated.value)),
        ],
      ),
    );
  }

  /// 过窄时的主 Tab 入口：下拉菜单（代替分段胶囊）。
  /// 只渲染「文字 + 箭头」的无壳内容，玻璃壳由外层 GlassCapsuleMorph 提供。
  ///
  /// 文案接 `primaryTC.animation`：横滑 TabBarView 时跟着手指一格一格
  /// 翻页（见 [GlassFlipLabel]），不是等滑完才换字。
  Widget _buildPrimaryTabDropdown(
    BuildContext context,
    List<GlassSegmentItem> items,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // Builder：落点与材质档位从触发位自身的 context 量出。
    return Builder(
      builder: (anchorContext) => GlassPressable(
        // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
        // 松手选中（见 GlassTapArea.opensOverlay）。
        opensOverlay: true,
        onTap: () => _openPrimaryTabMenu(anchorContext, items),
        // 内容套在常驻的 GlassCapsuleMorph 里，按下不再自缩，免得和胶囊的
        // 宽度形变打架；反馈交给菜单弹出本身。
        scale: 1.0,
        builder: (context, pressed) => SizedBox(
          height: GlassTokens.pillHeight,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassFlipLabel(
                  progress: primaryTC.animation!,
                  labels: [for (final item in items) item.label],
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 22,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPrimaryTabMenu(
    BuildContext anchorContext,
    List<GlassSegmentItem> items,
  ) async {
    final int index = primaryTC.index;
    final int? picked = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        for (var i = 0; i < items.length; i++)
          GlassMenuOption<int>(
            value: i,
            label: items[i].label,
            selected: i == index,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    primaryTC.animateTo(picked);
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

    showAppDialog(
      PostInputDialog(
        onSubmit: (title, body) async {
          if (!mounted) return;

          final result = await postService.postPost(title, body);
          if (!mounted) return;

          if (result.isSuccess) {
            showGlassToast(t.common.success, type: GlassToastType.success);
            AppService.tryPop();
            // 帖子列表是本页的「后代」而非「祖先」，原先用
            // context.findAncestorWidgetOfExactType() 取它恒为 null，
            // 发帖成功后的刷新一直是空操作。本页已持有它的 GlobalKey，
            // 这里在真正要用时再取（提前取会拿到过期或未挂载的实例）。
            final postTab = _postListKey.currentWidget;
            if (postTab is ProfilePostTabListWidget) {
              postTab.refresh();
            }
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

                showGlassToast(timeStr.trim(), type: GlassToastType.error);
              }
            }
          } else {
            showGlassToast(result.message, type: GlassToastType.error);
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _openVideoFromAuthorProfile({
    required String videoId,
    required List<Video> loadedVideos,
    Map<String, dynamic>? extData,
  }) async {
    Video? initialVideoInfo;
    for (final video in loadedVideos) {
      if (video.id == videoId) {
        initialVideoInfo = video;
        break;
      }
    }

    final playlistContext = InnerPlaylistContext.fromVideos(
      source: InnerPlaylistSource.authorProfile,
      videos: loadedVideos,
      currentVideoId: videoId,
    );

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      innerPlaylistContext: playlistContext,
      initialVideoInfo: initialVideoInfo,
    );
  }
}
