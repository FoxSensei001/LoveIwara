import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
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
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_overflow_menu_button.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_content_brightness.dart';
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

  /// 浮在滚动视图之上的顶栏 chrome：左「返回」圆钮 + 右「更多」菜单位。
  ///
  /// 原先这两枚键挂在 [SliverAppBar] 的 `leading` / `actions` 上。位置没变
  /// （AppBar 是 pinned 的），但那样它们就长在滚动容器里 —— 液态档的折射镜头
  /// 进不了滚动容器（Android 的拉伸回弹会把它渲染成纯黑），于是整页只有这两枚
  /// 键、外加中间那条主 Tab 胶囊停在传统档，而各 tab 自己的排序行
  /// （`GlassHeaderOverlay(liquid: true)`）早就是液态的了——同一屏两种材质。
  ///
  /// 布局按详情页的标准配方来：横向 16、行高 [GlassTokens.headerRowHeight]，
  /// 两侧之间隔着 `Spacer`，整行收进一个融合层（同 `GlassHeaderOverlay`）。
  Widget _buildHeaderChrome(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top,
      left: 0,
      right: 0,
      height: GlassTokens.headerRowHeight,
      // 这一行浮在作者横幅之上，**身后没有蒙层兜底**——深色封面的作者页正是
      // 「底是黑的、返回箭头也是黑的」的重灾区。整行一起翻（不是每枚钮各投
      // 各的）：GlassChromeLayer 把它们收进同一层玻璃，同一层只有一份材质。
      //
      // ⛔ Builder 不能省：下面的颜色是就地从 ColorScheme 取的 Color 值。
      child: GlassAdaptiveChrome(
        debugLabel: '作者页顶栏',
        child: Builder(builder: _buildHeaderChromeRow),
      ),
    );
  }

  Widget _buildHeaderChromeRow(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassChromeLayer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.arrow_back),
              tooltip: t.common.back,
              onPressed: AppService.tryPop,
            ),
            const Spacer(),
            // 有可选项时显示胶囊，没有时收成 0 宽——用 GlassShapeSwitcher
            // 让整块 action group 淡入淡出+宽度过渡（未登录访客切换到已登录、
            // 或作者信息延迟加载时都会命中这次形变）。
            Obx(
              () => GlassShapeSwitcher(child: _buildHeaderActionGroup(context)),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶栏右侧的动作位。条目为 0 时收成 0 宽，只剩一条时直接显示那条动作
  /// （见 [GlassOverflowMenuButton]），≥2 条才是 `⋮` + 玻璃菜单。
  Widget _buildHeaderActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    final author = profileController.author.value;
    final currentUserId = userService.currentUser.value?.id;
    final actions = <GlassMenuAction>[
      if (currentUserId != null && currentUserId == author?.id)
        GlassMenuAction(
          icon: Icons.article,
          label: t.common.createPost,
          onSelected: _showCreatePostDialog,
        )
      else if (currentUserId != null)
        GlassMenuAction(
          icon: Icons.message,
          label: t.conversation.startConversation,
          onSelected: () => showAppDialog(
            NewConversationDialog(
              initUserId: profileController.author.value?.id,
              onSubmit: NaviService.navigateToConversationPage,
            ),
            barrierDismissible: true,
          ),
        ),
      if (author != null)
        GlassMenuAction(
          icon: Icons.share,
          label: t.common.share,
          onSelected: () => _shareAuthor(context),
        ),
    ];

    if (actions.isEmpty) {
      return const KeyedSubtree(
        key: ValueKey('actions-empty'),
        child: SizedBox.shrink(),
      );
    }
    return KeyedSubtree(
      key: const ValueKey('actions-menu'),
      child: GlassButtonGroup(
        children: [GlassGroupOverflowMenuButton(actions: actions)],
      ),
    );
  }

  /// 分享用户主页。
  void _shareAuthor(BuildContext context) {
    final username = profileController.author.value?.username;
    if (username == null) return;
    showGlassBottomSheet(
      builder: (context) => ShareUserBottomSheet(
        username: username,
        authorName: profileController.author.value?.name ?? '',
        previewUrl:
            profileController.headerBackgroundUrl.value ??
            CommonConstants.defaultProfileHeaderUrl,
        avatarUrl: profileController.author.value?.avatar?.avatarUrl,
        followerCount: profileController.followerCounts.value,
        followingCount: profileController.followingCounts.value,
        commentCount: profileController.commentController.comments.value.length,
      ),
      context: context,
    );
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
        // group: false —— 浮钮走 GlassReveal 的 materialize 淡入。
        child: GlassChromeLayer(
          group: false,
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
    showAppToast(
      slang.t.logViewer.copiedToClipboard,
      type: AppToastType.success,
      position: AppToastPosition.bottom,
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
    showAppToast(
      slang.t.personalProfile.usernameCopied,
      type: AppToastType.success,
      position: AppToastPosition.bottom,
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
                                      showAppToast(
                                        t.errors.commentCanNotBeEmpty,
                                        type: AppToastType.error,
                                        position: AppToastPosition.bottom,
                                      );
                                      return;
                                    }
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
      return GlassContentAwareHost(
        child: Stack(
          children: [
            GlassSampledContent(
              child: Scaffold(
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
            ),
            _buildHeaderChrome(context),
            _buildScrollToTopFab(context),
          ],
        ),
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
                // chrome 浮在左栏之上而不是整页之上：它原本就画在这 400 宽里，
                // 挪到页面级会让「更多」键跳到屏幕最右边。
                child: GlassContentAwareHost(
                  child: Stack(
                    children: [
                      GlassSampledContent(
                        child: CustomScrollView(
                          slivers: _buildHeaderSliver(context, false),
                        ),
                      ),
                      _buildHeaderChrome(context),
                    ],
                  ),
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
        // 返回键与「更多」菜单不再挂在 AppBar 上：它们要走液态玻璃，而 lens
        // 不能待在滚动容器里（Android 拉伸回弹会把它渲染成纯黑，见
        // `liquid_glass_material.dart`）。改成浮在整棵滚动视图之上的一行 chrome，
        // 见 [_buildHeaderChrome]——反正 SliverAppBar 是 pinned 的，位置一样。
        automaticallyImplyLeading: false,
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
                          );
                        },
                        // ⛔ 这里曾经包着 Hero，与大图页那张对飞。整套 Hero
                        // 已于 2026-09-05 移除，进大图页只走路由自己的淡入。
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
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
                            );
                          }

                          // Hero 同上：整套已移除。
                          return AvatarWidget(
                            user: profileController.author.value,
                            size: 70,
                            onTap: openAvatar,
                          );
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
            // 主 Tab 胶囊与各 tab 自己的排序行（那些走的是
            // `GlassHeaderOverlay(liquid: true)`）在同一屏上，材质必须一致：
            // 这里就地供一层 chrome 档。它浮在 TabBarView 之上、不在任何滚动
            // 容器里，可以放 lens。
            // group: false —— 这一簇只有一块玻璃（主 Tab 胶囊），收进层里
            // 省不出 backdrop 采样，反倒会把两样东西关掉：胶囊自己的按下底色，
            // 以及分段控件那条果冻指示器的**玻璃透镜**那一趟（嵌套镜头在融合层
            // 底下会被「照亮」，所以 GlassSegmentedControl 处在层里时会主动跳过
            // 它，见 GlassBlendGroup.isInside）。
            child: GlassChromeLayer(
              group: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                // 空间够就平铺分段胶囊，不够（露不出 2.5 个完整段）退化成
                // 下拉钮——这条判定与它的下拉入口都在
                // GlassAdaptiveSegmentedControl 里，全站共用一份。
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
                      : (primaryTC.index == 1 ? _imageBatchController : null);
                  final bool selecting = primaryTC.index == 0
                      ? videoSelecting
                      : (primaryTC.index == 1 ? imageSelecting : false);
                  return GlassAdaptiveSegmentedControl(
                    selectedIndex: primaryTC.index,
                    progress: primaryTC.animation,
                    onChanged: primaryTC.animateTo,
                    items: [
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
                    ],
                    replacement: batch != null && selecting
                        ? SizedBox(
                            key: const ValueKey('selection'),
                            width: 168,
                            child: GlassSelectionSummary(
                              selectedCount: batch.selectedCount,
                              allSelected: false,
                              // 懒加载列表够不到未加载的部分，不给全选
                              onToggleAll: null,
                            ),
                          )
                        : null,
                  );
                }),
              ),
            ),
          ),
          // 批量动作：瀑布流模式下的底部玻璃坞；分页模式下动作行由分页栏
          // 自己承载（见 BatchSelectionScope），底部不会出现第二条玻璃。
          // group: false —— 坞是单块玻璃且走 materialize 淡入，材质淡入在
          // 融合层里无效（见 GlassChromeLayer 最后一段）。
          GlassChromeLayer(
            group: false,
            child: Obx(() => GlassSelectionDock(paginated: _isPaginated.value)),
          ),
        ],
      ),
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

    showAppDialog(
      PostInputDialog(
        onSubmit: (title, body) async {
          if (!mounted) return;

          final result = await postService.postPost(title, body);
          if (!mounted) return;

          if (result.isSuccess) {
            showAppToast(t.common.success, type: AppToastType.success);
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

                showAppToast(timeStr.trim(), type: AppToastType.error);
              }
            }
          } else {
            showAppToast(result.message, type: AppToastType.error);
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
    MediaListQuery? query,
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
      query: query,
    );

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      innerPlaylistContext: playlistContext,
      initialVideoInfo: initialVideoInfo,
    );
  }
}
