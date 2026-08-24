import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/post_detail/widgets/post_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/post_detail/widgets/share_post_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../widgets/error_widget.dart';
import '../comment/controllers/comment_controller.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import 'controllers/post_detail_controller.dart';
import 'widgets/post_detail_shimmer.dart';
import '../../widgets/iwara_site_badge.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final PostModel? initialPost;

  const PostDetailPage({super.key, required this.postId, this.initialPost});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late String postId;
  late PostDetailController detailController;
  late CommentController commentController;
  late String uniqueTag;
  String _postHeroTag(String id) => 'post-card-$id';

  final ScrollController _scrollController = ScrollController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    uniqueTag = UniqueKey().toString();

    if (postId.isEmpty) return;

    // 初始化控制器
    detailController = Get.put(PostDetailController(postId), tag: uniqueTag);

    commentController = Get.put(
      CommentController(id: postId, type: CommentType.post),
      tag: uniqueTag,
    );

    if (widget.initialPost != null) {
      detailController.postInfo.value = widget.initialPost;
      detailController.errorMessage.value = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    Get.delete<PostDetailController>(tag: uniqueTag);
    Get.delete<CommentController>(tag: uniqueTag);
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void showCommentModal(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    detailController.isCommentSheetVisible.value = true;
    showGlassDraggableBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GlassDraggableBottomSheet(
          initialChildSize: isSmallScreen ? 0.88 : 0.8,
          minChildSize: 0.25,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            final theme = Theme.of(context);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 12 : 16,
                    4,
                    isSmallScreen ? 12 : 16,
                    8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          slang.t.common.commentList,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 排序 / 发评论 / 关闭进同一只玻璃动作胶囊
                      GlassButtonGroup(
                        children: [
                          Obx(
                            () => GlassIconButton(
                              icon: Icon(
                                commentController.sortOrder.value
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                              ),
                              tooltip: commentController.sortOrder.value
                                  ? slang.t.common.createTimeDesc
                                  : slang.t.common.createTimeAsc,
                              onPressed: commentController.toggleSortOrder,
                            ),
                          ),
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
                                      );
                                      return;
                                    }
                                    final UserService userService = Get.find();
                                    if (!userService.isAuthenticated) {
                                      showGlassToast(
                                        slang.t.errors.pleaseLoginFirst,
                                        type: GlassToastType.error,
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
                          GlassIconButton(
                            icon: const Icon(Icons.close),
                            tooltip: slang.t.common.close,
                            onPressed: () {
                              detailController.isCommentSheetVisible.value =
                                  false;
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => CommentSection(
                      controller: commentController,
                      authorUserId: detailController.postInfo.value?.user.id,
                      scrollController: scrollController,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      detailController.isCommentSheetVisible.value = false;
    });
  }

  void _showShareSheet() {
    final post = detailController.postInfo.value;
    if (post == null) return;
    showGlassBottomSheet(
      builder: (context) => SharePostBottomSheet(post: post),
      context: context,
    );
  }

  /// 钉在顶部的玻璃 header 行：返回圆钮 / 标题胶囊（AI 站点加徽标）/ 分享胶囊。
  Widget _buildHeader(BuildContext context) {
    final t = slang.Translations.of(context);
    final currentSite = Get.find<AppService>().currentSiteMode;
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
          Expanded(
            child: Obx(() {
              final post = detailController.postInfo.value;
              // null = 仍在加载，标题胶囊显示 shimmer 占位
              final String? title = post == null
                  ? null
                  : (post.title.isNotEmpty ? post.title : t.common.post);
              return Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题胶囊：点按/长按弹出完整标题弹窗（长标题被截断时的出口）
                    Flexible(child: GlassTitlePill(title: title)),
                    if (currentSite.isAi) ...[
                      const SizedBox(width: 8),
                      IwaraSiteBadge(site: currentSite),
                    ],
                  ],
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          // 分享要等投稿数据就绪才可用，用 GlassGroupSlot 随加载完成「挤进」胶囊
          Obx(
            () => GlassButtonGroup(
              children: [
                GlassGroupSlot(
                  visible: detailController.postInfo.value != null,
                  child: GlassIconButton(
                    icon: const Icon(Icons.share),
                    tooltip: t.common.share,
                    onPressed: _showShareSheet,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮（窄屏；宽屏双列各自滚动不提供）。
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

  Widget _buildCommentEntrySection(
    BuildContext context, {
    required CommentController commentController,
    double horizontalPadding = 12,
    double bottomPadding = 12,
  }) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        2,
        horizontalPadding,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                t.common.commentList,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CommentEntryAreaButtonWidget(
            commentController: commentController,
            onClickButton: () {
              showCommentModal(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isWideLayout = screenWidth >= 1080;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final double effectiveTopPadding = headerExtent;

    if (postId.isEmpty) {
      return CommonErrorWidget(
        text: t.errors.invalidPostId,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.back),
          ),
        ],
      );
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (detailController.isCommentSheetVisible.value) {
            detailController.isCommentSheetVisible.value = false;
            Navigator.of(context).maybePop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: GlassHeaderOverlay(
          liquid: true,
          headerExtent: headerExtent,
          headerTop: statusBarHeight,
          solidExtent: statusBarHeight,
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical &&
                  notification.depth == 0) {
                _showBackToTop.value = notification.metrics.pixels >= 300;
              }
              return false;
            },
            child: Obx(() {
              final theme = Theme.of(context);
              final availableWideHeight =
                  (MediaQuery.sizeOf(context).height - effectiveTopPadding - 6)
                      .clamp(200.0, double.infinity);

              if (detailController.errorMessage.value != null) {
                return Padding(
                  padding: EdgeInsets.only(top: headerExtent),
                  child: CommonErrorWidget(
                    text:
                        detailController.errorMessage.value ??
                        t.errors.errorWhileLoadingPost,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.common.back),
                      ),
                    ],
                  ),
                );
              }

              if (detailController.isPostInfoLoading.value &&
                  detailController.postInfo.value == null) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.2,
                        ),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideLayout ? 1220 : 940,
                      ),
                      child: PostDetailShimmer(
                        topPadding: effectiveTopPadding,
                        isWideLayout: isWideLayout,
                        availableWideHeight: availableWideHeight,
                        heroTag: _postHeroTag(postId),
                      ),
                    ),
                  ),
                );
              }

              if (detailController.postInfo.value == null) {
                return Padding(
                  padding: EdgeInsets.only(top: headerExtent),
                  child: MyEmptyWidget(),
                );
              }

              final commentCount = commentController.totalComments.value;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.2,
                      ),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideLayout ? 1220 : 940,
                    ),
                    child: isWideLayout
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(
                              12,
                              effectiveTopPadding + 6,
                              12,
                              0,
                            ),
                            child: SizedBox(
                              height: availableWideHeight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 360,
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            12 +
                                            MediaQuery.paddingOf(
                                              context,
                                            ).bottom,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PostDetailContent(
                                            controller: detailController,
                                            commentCount: commentCount,
                                            showContentCard: false,
                                            includeTopSpacing: false,
                                            horizontalPadding: 0,
                                            overviewHeroTag: _postHeroTag(
                                              postId,
                                            ),
                                          ),
                                          _buildCommentEntrySection(
                                            context,
                                            commentController:
                                                commentController,
                                            horizontalPadding: 0,
                                            bottomPadding: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      padding: EdgeInsets.only(
                                        bottom:
                                            12 +
                                            MediaQuery.paddingOf(
                                              context,
                                            ).bottom,
                                      ),
                                      child: PostDetailContent(
                                        controller: detailController,
                                        commentCount: commentCount,
                                        showOverviewCard: false,
                                        includeTopSpacing: false,
                                        horizontalPadding: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: effectiveTopPadding + 4),
                                PostDetailContent(
                                  controller: detailController,
                                  commentCount: commentCount,
                                  includeTopSpacing: false,
                                  overviewHeroTag: _postHeroTag(postId),
                                ),
                                _buildCommentEntrySection(
                                  context,
                                  commentController: commentController,
                                  horizontalPadding: isSmallScreen ? 10 : 12,
                                  bottomPadding: isSmallScreen ? 8 : 12,
                                ),
                                const SafeArea(
                                  top: false,
                                  child: SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
          // header 行：左 返回圆钮 / 中 标题胶囊（AI 站点加徽标）/ 右 分享胶囊
          header: _buildHeader(context),
          extra: [
            // 回到顶部浮钮（窄屏；宽屏双列各自滚动不提供）
            if (!isWideLayout) _buildScrollToTopFab(context),
          ],
        ),
      ),
    );
  }
}
