import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_navigator.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/image_model_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/playback_queue_drawer.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/translatable_title.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/infinite_scroll_waterfall_tab.dart';

import '../../../../common/enums/media_enums.dart';
import '../../../../utils/logger_utils.dart';
import '../../../../app/utils/layout_calculator.dart';
import '../../widgets/error_widget.dart';
import '../comment/controllers/comment_controller.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import '../popular_media_list/widgets/image_model_card_list_item_widget.dart';
import '../video_detail/controllers/related_media_controller.dart';
import 'controllers/gallery_detail_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'widgets/gallery_image_scroller_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';

String _galleryCoverHeroTag(String imageModelId) =>
    'gallery_cover:$imageModelId';

const int _galleryDetailSideListCrossAxisCount = 2;

class GalleryDetailPage extends StatefulWidget {
  final String imageModelId;
  final String? initialCoverUrl;
  final String? initialTitle;
  final int? initialImageCount;
  final String? initialAuthorId;
  final String? initialAuthorName;
  final String? initialAuthorUsername;
  final String? initialAuthorAvatarUrl;
  final String? initialAuthorRole;
  final bool? initialAuthorPremium;
  final Map<String, dynamic>? extData;

  /// 图库池的引用：从「接着看」抽屉点过来、或者从带池的列表页进来时才有。
  final PlaybackQueueRef? playbackQueueRef;

  const GalleryDetailPage({
    super.key,
    required this.imageModelId,
    this.initialCoverUrl,
    this.initialTitle,
    this.initialImageCount,
    this.initialAuthorId,
    this.initialAuthorName,
    this.initialAuthorUsername,
    this.initialAuthorAvatarUrl,
    this.initialAuthorRole,
    this.initialAuthorPremium,
    this.extData,
    this.playbackQueueRef,
  });

  @override
  GalleryDetailPageState createState() => GalleryDetailPageState();
}

class GalleryDetailPageState extends State<GalleryDetailPage>
    with SingleTickerProviderStateMixin {
  late String imageModelId;
  late GalleryDetailController detailController;
  late CommentController commentController;
  late RelatedMediasController relatedMediasController;
  late String uniqueTag;
  late TabController _relatedTabController;

  // 布局计算器
  final LayoutCalculator _layoutCalculator = LayoutCalculator();

  // 分配图库详情与附列表的宽度
  final double sideColumnMinWidth = 400.0; // 右侧固定宽度
  final double leftColumnMinWidth = 600.0; // 左侧内容的最小期望宽度，用于判断是否宽屏

  // 窄屏：ExtendedNestedScrollView 的状态钥匙（回顶要拿内外两个控制器）
  final GlobalKey<ExtendedNestedScrollViewState> _nestedKey =
      GlobalKey<ExtendedNestedScrollViewState>();

  // 宽屏：左列 CustomScrollView 的控制器
  final ScrollController _wideScrollController = ScrollController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮（仅窄屏）。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);
  double _outerScrollPixels = 0;
  double _innerScrollPixels = 0;

  // dispose
  @override
  void dispose() {
    _relatedTabController.removeListener(_handleRelatedTabChange);
    _relatedTabController.dispose();
    _wideScrollController.dispose();
    _showBackToTop.dispose();
    for (final queue in _queues) {
      queue.removeListener(_onQueueChanged);
    }
    Get.delete<GalleryDetailController>(tag: uniqueTag);
    Get.delete<CommentController>(tag: uniqueTag);
    Get.delete<RelatedMediasController>(tag: uniqueTag);

    LogUtils.d('图库ID: $imageModelId 已销毁', 'GalleryDetailPage');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    imageModelId = widget.imageModelId;
    uniqueTag = UniqueKey().toString();
    _relatedTabController = TabController(length: 2, vsync: this);
    _relatedTabController.addListener(_handleRelatedTabChange);

    if (imageModelId.isEmpty) {
      return;
    }
    LogUtils.d('图库ID: $imageModelId 初始化状态, $uniqueTag', 'GalleryDetailPage');

    // 初始化控制器
    detailController = Get.put(
      GalleryDetailController(imageModelId, extData: widget.extData),
      tag: uniqueTag,
    );

    commentController = Get.put(
      CommentController(id: imageModelId, type: CommentType.image),
      tag: uniqueTag,
    );

    relatedMediasController = Get.put(
      RelatedMediasController(
        mediaId: imageModelId,
        mediaType: MediaType.IMAGE,
      ),
      tag: uniqueTag,
    );

    _setupPlaybackQueues();
  }

  // ------------------------------------------------------------ 图库池

  /// 本页可用的池。与视频详情页同一套（见那边的 `_setupPlaybackQueues`）：
  /// **每层详情页各持一份**，池的真身在 `PlaybackQueueService` 里。
  List<PlaybackQueue> _queues = const <PlaybackQueue>[];
  PlaybackQueue? _activeQueue;

  /// 入口钮要不要在场。
  ///
  /// ⛔ 判据比视频那边**松**：只要手上有池就摆出来，不看池里这会儿有没有东西。
  /// 图库这一路绝大多数入口交接不出池，稍后再看的图库那一支又常常是空的——
  /// 按"池里有货才显示"来判，「最爱 / 本地收藏夹 / 作者的图库」这几支就**永远
  /// 够不着**（它们是进了抽屉才现开的）。空池的抽屉本来就说得清楚（"这个池里
  /// 没有可看的图库"），胶囊还能换到别的池去。
  bool get _hasPlaybackQueue => _queues.isNotEmpty;

  /// 组装本页的池清单。
  ///
  /// 只放两样：交接过来的那个（从抽屉点进来、或者从带池的列表页进来），以及
  /// 稍后再看的图库那一支。**其余几类（最爱 / 本地收藏夹 / 作者的图库）由抽屉
  /// 按需现开**——它们都是"用户主动想换过去"才需要的东西，开页时先建好只会白
  /// 打请求（视频详情页同理）。
  void _setupPlaybackQueues() {
    final service = PlaybackQueueService.to;
    final queues = <PlaybackQueue>[];

    final ref = widget.playbackQueueRef;
    PlaybackQueue? handedOver;
    if (ref != null) {
      final queue = service.byId(ref.queueId);
      // ⛔ 交接过来的必须是**图库池**：App 重启后 ref 会失效，而 queueId 也可能
      // 命中一个同名的视频池——把视频池摆进图库详情页，"下一条"会把用户扔进
      // 播放器。
      if (queue != null && queue.mediaType.isGallery) {
        handedOver = queue;
        queues.add(queue);
      }
    }

    // 稍后再看（图库那一支），默认「全部」。判重按 kind：筛选是池身份的一部分
    // （`watchLater:all:gallery` / `watchLater:unwatched:gallery` 是两个 id），
    // 按 id 比会两个都塞进去，抽屉里就排出两条同名 tab。
    if (!queues.any((queue) => queue.kind == PlaybackQueueKind.watchLater)) {
      queues.add(
        service.openWatchLater(
          unwatchedOnly: false,
          mediaType: PlaybackMediaType.gallery,
        ),
      );
    }

    _queues = queues;
    _activeQueue = handedOver ?? queues.firstOrNull;
    // ⛔ **每个池都要挂监听**，不能只挂 active 那一个：LRU 只保护"还有人在听"的
    // 池，没挂的那些会在别处注册新池时被 dispose 掉，而本页仍拿着引用。
    for (final queue in _queues) {
      queue.addListener(_onQueueChanged);
    }
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  /// 打开「接着看」抽屉。与播放器共用同一只抽屉（[showPlaybackQueueDrawer]）。
  Future<void> _openQueueDrawer() async {
    final queues = _queues;
    if (queues.isEmpty || !mounted) return;
    final selection = await showPlaybackQueueDrawer(
      context: context,
      queues: queues,
      initialQueue: _activeQueue ?? queues.first,
      currentItemId: imageModelId,
      author: detailController.imageModelInfo.value?.user,
      mediaType: PlaybackMediaType.gallery,
    );
    if (selection == null || !mounted) return;
    // ⛔ 只有**真的点了一条**才换池；光切 tab 逛一圈不算。抽屉里可能换出了新的
    // 池实例，那些本页还没听过，得**按 kind 顶掉同类的那一个**补上监听——一路
    // append 下去会排出两条同名 tab（视频那边 2026-08-29 报障过）。
    if (!_queues.any((queue) => identical(queue, selection.queue))) {
      final merged = [..._queues];
      final slot = merged.indexWhere(
        (queue) => queue.kind == selection.queue.kind,
      );
      if (slot >= 0) {
        merged[slot].removeListener(_onQueueChanged);
        merged[slot] = selection.queue;
      } else {
        merged.add(selection.queue);
      }
      _queues = merged;
      selection.queue.addListener(_onQueueChanged);
    }
    _activeQueue = selection.queue;
    await PlaybackQueueNavigator.playItem(
      queue: selection.queue,
      item: selection.item,
      skipWatched: false,
    );
  }

  // 相关图库分段行随 tab 落定重排（横滑过程由 progress 驱动，无需重建）
  void _handleRelatedTabChange() {
    if (_relatedTabController.indexIsChanging) return;
    if (mounted) setState(() {});
  }

  bool _handleNestedScrollNotification(ScrollNotification notification) {
    // depth 0 = ExtendedNestedScrollView 外层（玻璃 header + 概览卡），
    // depth 1 = 内层相关列表
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
    final state = _nestedKey.currentState;
    if (state != null) {
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
    if (_wideScrollController.hasClients) {
      _wideScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮（窄屏）。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
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
    );
  }

  /// 玻璃 header 行：返回圆钮 / 标题胶囊 / 主页胶囊。
  ///
  /// 用 [GlassHeaderOverlay] 悬浮在滚动内容之上（普通 Stack + Positioned，
  /// 不进 sliver 树）——之前塞进 SliverAppBar.flexibleSpace 时，蒙层的渐隐
  /// 距离会被 FlexibleSpaceBar 压扁在 toolbarHeight 以内，渐变没走完就被
  /// 截断，读起来像一条硬边阴影；悬浮实现没有这层限制，与热门列表页等
  /// 页面同一套配方（见 glass_header_overlay.dart）。
  Widget _buildGlassHeaderRow(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.arrow_back),
            tooltip: t.common.back,
            onPressed: () => AppService.tryPop(),
          ),
          const SizedBox(width: 8),
          // 标题胶囊：点按/长按弹出完整标题弹窗（长标题被截断时的出口）
          Expanded(
            child: Obx(
              () => GlassTitlePill(
                title:
                    detailController.imageModelInfo.value?.title ??
                    widget.initialTitle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GlassButtonGroup(
            children: [
              // 「接着看」：图库详情页没有播放器底栏那种常驻位置，chrome 上这枚
              // 圆钮是唯一既随处可达、又不和内容抢地方的落点。池里空无一物时
              // 整只退场（带宽度过渡，不硬切）——摆一枚点了什么都没有的钮比不
              // 摆更糟。
              GlassGroupSlot(
                visible: _hasPlaybackQueue,
                child: GlassIconButton(
                  icon: const Icon(Icons.playlist_play),
                  tooltip: t.playbackQueue.upNext,
                  onPressed: _openQueueDrawer,
                ),
              ),
              // 回到「图库」那一类的首页页签：从订阅进来的落回订阅的图库半边，
              // 其余（社区 / 视频 / 图库栏）落回图库栏。
              GlassIconButton(
                icon: const Icon(Icons.home),
                tooltip: t.videoDetail.home,
                onPressed: () => goHomeForMedia(MediaType.IMAGE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 计算是否需要分两列
  bool _shouldUseWideScreenLayout(double screenHeight, double screenWidth) {
    // 如果屏幕宽度足够容纳左侧最小宽度和右侧固定宽度，则使用宽屏布局
    return screenWidth >= leftColumnMinWidth + sideColumnMinWidth;
  }

  /// 计算图片滚动区域的智能高度
  double _calculateImageScrollerHeight(Size screenSize, double paddingTop) {
    final result = _layoutCalculator.calculateGalleryScrollerHeight(
      screenSize: screenSize,
      paddingTop: paddingTop,
    );

    LogUtils.d(
      '[智能布局] 屏幕: ${screenSize.width.toInt()}x${screenSize.height.toInt()}, '
          '设备类型: ${result.isMobile
              ? "手机"
              : result.isTablet
              ? "平板"
              : "桌面"}, '
          '图片区域高度: ${result.maxHeight.toInt()}px',
      'GalleryDetailPage',
    );

    return result.maxHeight;
  }

  void showCommentModal(BuildContext context) {
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
                        slang.t.common.commentList,
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
                              onPressed: () {
                                commentController.toggleSortOrder();
                              },
                              icon: Icon(
                                commentController.sortOrder.value
                                    ? Icons
                                          .arrow_downward_rounded // 倒序图标
                                    : Icons.arrow_upward_rounded, // 正序图标
                              ),
                              tooltip: commentController.sortOrder.value
                                  ? slang.t.common.createTimeDesc
                                  : slang.t.common.createTimeAsc,
                            ),
                          ),
                          // 添加评论按钮
                          GlassIconButton(
                            icon: const Icon(Icons.add_comment),
                            tooltip: slang.t.common.sendComment,
                            onPressed: () {
                              showGlassBottomSheet(
                                context: context,
                                builder: (context) => CommentInputBottomSheet(
                                  title: slang.t.common.sendComment,
                                  submitText: slang.t.common.send,
                                  onSubmit: (text) async {
                                    if (text.trim().isEmpty) {
                                      showGlassToast(
                                        slang.t.errors.commentCanNotBeEmpty,
                                        type: GlassToastType.error,
                                        position: GlassToastPosition.bottom,
                                      );
                                      return;
                                    }
                                    final UserService userService = Get.find();
                                    if (!userService.isAuthenticated) {
                                      showGlassToast(
                                        slang.t.errors.pleaseLoginFirst,
                                        type: GlassToastType.error,
                                        position: GlassToastPosition.bottom,
                                      );
                                      LoginService.showLogin();
                                      return;
                                    }
                                    await commentController.postComment(text);
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
                        tooltip: slang.t.common.close,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // 评论列表
                Expanded(
                  child: Obx(
                    () => CommentSection(
                      controller: commentController,
                      authorUserId:
                          detailController.imageModelInfo.value?.user?.id,
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

  /// 概览卡顶部要让出的高度。
  ///
  /// 窄屏下概览卡直接跟在玻璃 header sliver 之后，SliverAppBar 已经占了位；
  /// 宽屏同理。这段间距同时要让卡片顶边滚动经过 header 时，与 header 玻璃
  /// 按钮的投影拉开距离——挨太近会让实色卡片的硬边把按钮阴影衬得很重。
  static const double _overviewCardTopGap = 20;

  Widget _buildHeroScrollerSection(
    BuildContext context, {
    required String coverHeroTag,
    required int? imageCount,
    required double height,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(14));
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: GalleryImageScrollerWidget(
          controller: detailController,
          maxHeight: height,
          coverHeroTag: coverHeroTag,
          initialImageCount: imageCount,
        ),
      ),
    );
  }

  Widget _buildHeroOverviewCard(
    BuildContext context, {
    required String coverHeroTag,
    required int? imageCount,
    required double height,
    required ImageModel? imageModelInfo,
    required bool isLoading,
    required String? errorMessage,
  }) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UIConstants.pagePadding,
        _overviewCardTopGap,
        UIConstants.pagePadding,
        0,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: radius,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroScrollerSection(
                context,
                coverHeroTag: coverHeroTag,
                imageCount: imageCount,
                height: height,
              ),
              _buildMainDetailSection(
                context,
                imageModelInfo: imageModelInfo,
                isLoading: isLoading,
                errorMessage: errorMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeaderSection(
    BuildContext context, {
    required ImageModel? imageModelInfo,
  }) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    final title = (imageModelInfo?.title ?? widget.initialTitle ?? '').trim();
    final displayTitle = title.isEmpty ? t.common.noTitle : title;

    final user = imageModelInfo?.user;
    final username = (user?.username ?? widget.initialAuthorUsername ?? '')
        .trim();
    final authorName = (user?.name ?? widget.initialAuthorName ?? '').trim();
    final authorId = (user?.id ?? widget.initialAuthorId ?? '').trim();
    final authorRole = (user?.role ?? widget.initialAuthorRole ?? '').trim();
    final authorPremium =
        user?.premium ?? (widget.initialAuthorPremium ?? false);
    final displayName = authorName.isNotEmpty
        ? authorName
        : (username.isNotEmpty ? username : t.common.unknownUser);
    final avatarUrl = user?.avatar?.avatarUrl ?? widget.initialAuthorAvatarUrl;

    final User effectiveUser =
        user ??
        User(
          id: authorId.isNotEmpty ? authorId : 'unknown',
          name: displayName,
          username: username,
          role: authorRole,
          premium: authorPremium,
        );

    VoidCallback? onTapAuthor;
    if (username.isNotEmpty) {
      onTapAuthor = () => NaviService.navigateToAuthorProfilePage(username);
    }

    final nameWidget = buildUserName(
      context,
      effectiveUser,
      bold: true,
      fontSize: 16,
      defaultNameColor: theme.textTheme.titleMedium?.color,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UIConstants.pagePadding,
        10,
        UIConstants.pagePadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatableTitle(
            text: displayTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onTapAuthor,
                child: AvatarWidget(
                  user: effectiveUser,
                  avatarUrl: avatarUrl,
                  size: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onTapAuthor,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nameWidget,
                      if (username.isNotEmpty)
                        Text(
                          '@$username',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (user != null)
                SizedBox(
                  height: 32,
                  child: FollowButtonWidget(
                    user: user,
                    onUserUpdated: (updatedUser) {
                      detailController.imageModelInfo.value = detailController
                          .imageModelInfo
                          .value
                          ?.copyWith(user: updatedUser);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainDetailSection(
    BuildContext context, {
    required ImageModel? imageModelInfo,
    required bool isLoading,
    required String? errorMessage,
  }) {
    final t = slang.Translations.of(context);

    final header = _buildHeroHeaderSection(
      context,
      imageModelInfo: imageModelInfo,
    );

    if (imageModelInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          ImageModelDetailContent(
            controller: detailController,
            showHeader: false,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CommentEntryAreaButtonWidget(
              commentController: commentController,
              onClickButton: () => showCommentModal(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          CommonErrorWidget(
            text: errorMessage.isEmpty
                ? t.errors.errorWhileLoadingGallery
                : errorMessage,
            children: [
              ElevatedButton(
                onPressed: () => detailController.fetchGalleryDetail(),
                child: Text(t.common.retry),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.common.back),
              ),
            ],
          ).paddingVertical(16),
        ],
      );
    }

    if (!isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, const SizedBox(height: 16), const MyEmptyWidget()],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 16),
        const _GalleryDetailInfoSkeleton(),
      ],
    );
  }

  Widget _buildGalleryCardSkeleton(BuildContext context, double width) {
    return _GalleryCardSkeleton(width: width);
  }

  /// 相关图库分段胶囊：接 TabController.animation，横滑 TabBarView 时
  /// 高亮块跟手插值；空间不够（露不出 2.5 个完整段）时自己退化成下拉钮。
  Widget _buildRelatedSegmentedControl(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassAdaptiveSegmentedControl(
      selectedIndex: _relatedTabController.index,
      progress: _relatedTabController.animation,
      onChanged: _relatedTabController.animateTo,
      items: [
        GlassSegmentItem(label: t.galleryDetail.authorOtherGalleries),
        GlassSegmentItem(label: t.galleryDetail.relatedGalleries),
      ],
    );
  }

  Widget _buildRelatedTabBarView(BuildContext context, {double topInset = 0}) {
    final t = slang.Translations.of(context);
    return TabBarView(
      controller: _relatedTabController,
      children: [
        // Tab 1: Author's Other Galleries
        Obx(() {
          // Always access imageModelInfo so GetX registers a listener
          // even when otherController is still null.
          final _ = detailController.imageModelInfo.value;
          final ctrl = detailController.otherAuthorzImageModelsController;
          return InfiniteScrollWaterfallTab<ImageModel>(
            items: ctrl?.imageModels.toList() ?? const [],
            isLoading: ctrl?.isLoading.value ?? false,
            isLoadingMore: ctrl?.isLoadingMore.value ?? false,
            hasMore: ctrl?.hasMore.value ?? false,
            onLoadMore: () => ctrl?.loadMore(),
            available: ctrl != null,
            crossAxisCount: _galleryDetailSideListCrossAxisCount,
            emptyMessage: t.galleryDetail.authorNoOtherGalleries,
            skeletonBuilder: _buildGalleryCardSkeleton,
            topInset: topInset,
            itemBuilder: (context, imageModel, itemWidth) {
              return ImageModelCardListItemWidget(
                imageModel: imageModel,
                width: itemWidth,
              );
            },
          );
        }),
        // Tab 2: Related Galleries
        Obx(
          () => InfiniteScrollWaterfallTab<ImageModel>(
            items: relatedMediasController.imageModels.toList(),
            isLoading: relatedMediasController.isLoading.value,
            isLoadingMore: relatedMediasController.isLoadingMore.value,
            hasMore: relatedMediasController.hasMore.value,
            onLoadMore: relatedMediasController.loadMore,
            crossAxisCount: _galleryDetailSideListCrossAxisCount,
            emptyMessage: t.galleryDetail.noRelatedGalleries,
            skeletonBuilder: _buildGalleryCardSkeleton,
            topInset: topInset,
            itemBuilder: (context, imageModel, itemWidth) {
              return ImageModelCardListItemWidget(
                imageModel: imageModel,
                width: itemWidth,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 窄屏：分段胶囊行悬浮在相关列表之上（列表用 topInset 让位）。
  static const double _relatedTabsRowHeight = GlassTokens.pillHeight + 16;

  /// 走 [GlassHeaderOverlay] 而不是手绘 `Stack + Positioned.fill`——不是抠好看，
  /// 是接液态档的**必经之路**：这块 Stack 挂在外层 `ExtendedNestedScrollView`
  /// 的 `body:` 上，而外层页面自己的 `GlassHeaderOverlay(liquid: true)`
  /// 会把整个 `body` 强制按回 [GlassBackend.plain]（列表是滚动容器，装不得
  /// lens，见该组件类文档）。分段胶囊虽然悬浮在列表**之上**、是货真价实的
  /// chrome，但它人在 `body` 子树里，跟着一起被摁回了传统档——`GlassSegmentedControl`
  /// 已经是「最新组件」，材质却始终没换过，2026-08-24 用户真机点开就是这个。
  ///
  /// 嵌一层自己的 `GlassHeaderOverlay(liquid: true)` 才能重新供上液态 scope
  /// （子树里最近的 [LiquidGlassScope] 生效，会盖过外层那次强制 plain）——
  /// 与 `profile_post_tab_list_widget.dart` 等各 tab 各自嵌一层的做法同源。
  Widget _buildNarrowRelatedArea(BuildContext context) {
    return GlassHeaderOverlay(
      liquid: true,
      headerExtent: _relatedTabsRowHeight,
      headerHeight: _relatedTabsRowHeight,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: _buildRelatedSegmentedControl(context),
      ),
      body: _buildRelatedTabBarView(context, topInset: _relatedTabsRowHeight),
    );
  }

  /// 宽屏右列：相关图库（分段胶囊 + 瀑布流）。
  ///
  /// 同 [_buildNarrowRelatedArea]：走 [GlassHeaderOverlay] 而不是手绘
  /// `Stack + EdgeFadeScrim`。这一列本身不在左列那只 `GlassHeaderOverlay`
  /// 里头——它是宽屏 `Row` 里的另一个孩子，够不着左列供的液态 scope，分段
  /// 胶囊此前是彻头彻尾的**传统档**（不是被摁回去，是压根没供过）。改用
  /// `GlassHeaderOverlay(liquid: true)` 自建一份 scope，顺带把手写的
  /// `EdgeFadeScrim.top` 换成组件自带的那份（`headerExtent` / `solidExtent`
  /// 语义与原手写代码一致，读起来更少一份要跟着改的重复）。
  /// 分段行按 headerRowHeight 居中，与左列 header 上的胶囊同一水平线。
  Widget _buildWideSideColumn(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return GlassHeaderOverlay(
      liquid: true,
      headerExtent: headerExtent,
      headerTop: statusBarHeight,
      solidExtent: statusBarHeight,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildRelatedSegmentedControl(context),
      ),
      body: _buildRelatedTabBarView(context, topInset: headerExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    if (imageModelId.isEmpty) {
      return CommonErrorWidget(
        text: t.errors.invalidGalleryId,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.back),
          ),
        ],
      );
    }

    // 获取屏幕尺寸和内边距
    Size screenSize = MediaQuery.sizeOf(context);
    double paddingTop = MediaQuery.paddingOf(context).top;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;

    // 判断是否使用宽屏布局 (移出 Obx)
    bool isWide = _shouldUseWideScreenLayout(screenHeight, screenWidth);

    // 使用智能布局计算器计算图片滚动区域的最大高度 (移出 Obx)
    final double imageScrollerMaxHeight = _calculateImageScrollerHeight(
      screenSize,
      paddingTop,
    );

    final String coverHeroTag = _galleryCoverHeroTag(imageModelId);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (detailController.isCommentSheetVisible.value) {
            detailController.isCommentSheetVisible.toggle();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Obx(() {
          final imageModelInfo = detailController.imageModelInfo.value;
          final isLoading = detailController.isImageModelInfoLoading.value;
          final errorMessage = detailController.errorMessage.value;
          final imageCount =
              imageModelInfo?.numImages ?? widget.initialImageCount;

          final overviewCard = _buildHeroOverviewCard(
            context,
            coverHeroTag: coverHeroTag,
            imageCount: imageCount,
            height: imageScrollerMaxHeight,
            imageModelInfo: imageModelInfo,
            isLoading: isLoading,
            errorMessage: errorMessage,
          );

          final double headerExtent = paddingTop + GlassTokens.headerRowHeight;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左列：玻璃 header 悬浮在顶部，概览卡从它背后滚过
                Expanded(
                  child: GlassHeaderOverlay(
                    liquid: true,
                    headerExtent: headerExtent,
                    headerTop: paddingTop,
                    solidExtent: paddingTop,
                    header: _buildGlassHeaderRow(context),
                    body: CustomScrollView(
                      controller: _wideScrollController,
                      physics: detailController.isHoveringHorizontalList.value
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(height: headerExtent),
                        ),
                        SliverToBoxAdapter(child: overviewCard),
                        const SliverToBoxAdapter(
                          child: SafeArea(top: false, child: SizedBox.shrink()),
                        ),
                      ],
                    ),
                  ),
                ),
                // 右列：固定宽度的相关图库（分段胶囊 + 瀑布流）
                SizedBox(
                  // 右侧固定宽度
                  width: sideColumnMinWidth,
                  child: _buildWideSideColumn(context),
                ),
              ],
            );
          } else {
            // 窄屏：ExtendedNestedScrollView——概览卡上滑收走，玻璃 header 与
            // 相关图库分段行分别悬浮在顶部（分段行悬浮在列表之上，列表以
            // topInset 让位）。
            return GlassHeaderOverlay(
              liquid: true,
              headerExtent: headerExtent,
              headerTop: paddingTop,
              solidExtent: paddingTop,
              header: _buildGlassHeaderRow(context),
              extra: [_buildScrollToTopFab(context)],
              body: NotificationListener<ScrollNotification>(
                onNotification: _handleNestedScrollNotification,
                child: ExtendedNestedScrollView(
                  key: _nestedKey,
                  physics: detailController.isHoveringHorizontalList.value
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  onlyOneScrollInBody: true,
                  // header 行已经悬浮在 GlassHeaderOverlay 里，sliver 树里
                  // 不再有真正 pinned 的部分。
                  pinnedHeaderSliverHeightBuilder: () => 0,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(child: SizedBox(height: headerExtent)),
                    SliverToBoxAdapter(child: overviewCard),
                  ],
                  body: _buildNarrowRelatedArea(context),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

class _GalleryDetailInfoSkeleton extends StatelessWidget {
  const _GalleryDetailInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.35,
    );

    Widget box({
      double? width,
      required double height,
      BorderRadiusGeometry borderRadius = const BorderRadius.all(
        Radius.circular(10),
      ),
    }) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.pagePadding,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          box(height: 84),
          const SizedBox(height: 16),
          box(height: 14, width: 280),
          const SizedBox(height: 8),
          box(height: 14),
          const SizedBox(height: 8),
          box(height: 14, width: 240),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: box(height: 40)),
              const SizedBox(width: 12),
              Expanded(child: box(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 单个图库卡片骨架
class _GalleryCardSkeleton extends StatelessWidget {
  final double width;

  const _GalleryCardSkeleton({required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: width,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: radius.topLeft),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: width * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        height: 22,
                        width: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
