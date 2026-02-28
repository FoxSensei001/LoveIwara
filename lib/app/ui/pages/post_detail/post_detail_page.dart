import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/post_detail/widgets/post_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/post_detail/widgets/share_post_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../widgets/error_widget.dart';
import '../comment/controllers/comment_controller.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import 'controllers/post_detail_controller.dart';
import 'widgets/post_detail_shimmer.dart';

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
    Get.delete<PostDetailController>(tag: uniqueTag);
    Get.delete<CommentController>(tag: uniqueTag);
    super.dispose();
  }

  void showCommentModal(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    detailController.isCommentSheetVisible.value = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: isSmallScreen ? 0.88 : 0.8,
          minChildSize: 0.25,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 12 : 16,
                      4,
                      isSmallScreen ? 6 : 10,
                      8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          slang.t.common.commentList,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Obx(
                          () => IconButton(
                            onPressed: commentController.toggleSortOrder,
                            icon: Icon(
                              commentController.sortOrder.value
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            tooltip: commentController.sortOrder.value
                                ? slang.t.common.createTimeDesc
                                : slang.t.common.createTimeAsc,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => CommentInputBottomSheet(
                                title: slang.t.common.sendComment,
                                submitText: slang.t.common.send,
                                onSubmit: (text) async {
                                  if (text.trim().isEmpty) {
                                    showToastWidget(
                                      MDToastWidget(
                                        message:
                                            slang.t.errors.commentCanNotBeEmpty,
                                        type: MDToastType.error,
                                      ),
                                    );
                                    return;
                                  }
                                  final UserService userService = Get.find();
                                  if (!userService.isLogin) {
                                    showToastWidget(
                                      MDToastWidget(
                                        message:
                                            slang.t.errors.pleaseLoginFirst,
                                        type: MDToastType.error,
                                      ),
                                    );
                                    LoginService.showLogin();
                                    return;
                                  }
                                  await commentController.postComment(text);
                                },
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.add_comment,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          onPressed: () {
                            detailController.isCommentSheetVisible.value =
                                false;
                            Navigator.pop(context);
                          },
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
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      detailController.isCommentSheetVisible.value = false;
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.7),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Obx(
        () => Text(
          detailController.postInfo.value?.title.isNotEmpty == true
              ? detailController.postInfo.value!.title
              : t.common.post,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: const Icon(Icons.share),
            onPressed: detailController.postInfo.value == null
                ? null
                : () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => SharePostBottomSheet(
                        post: detailController.postInfo.value!,
                      ),
                      context: context,
                    );
                  },
          ),
        ),
      ],
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
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Obx(() {
          final theme = Theme.of(context);
          final effectiveTopPadding =
              MediaQuery.paddingOf(context).top + kToolbarHeight;
          final isWideLayout = screenWidth >= 1080;
          final availableWideHeight =
              (MediaQuery.sizeOf(context).height - effectiveTopPadding - 6)
                  .clamp(200.0, double.infinity);

          if (detailController.errorMessage.value != null) {
            return CommonErrorWidget(
              text:
                  detailController.errorMessage.value ??
                  t.errors.errorWhileLoadingPost,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.common.back),
                ),
              ],
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
            return const MyEmptyWidget();
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
                                        MediaQuery.paddingOf(context).bottom,
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
                                        overviewHeroTag: _postHeroTag(postId),
                                      ),
                                      _buildCommentEntrySection(
                                        context,
                                        commentController: commentController,
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
                                  padding: EdgeInsets.only(
                                    bottom:
                                        12 +
                                        MediaQuery.paddingOf(context).bottom,
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
                            const SafeArea(child: SizedBox.shrink()),
                          ],
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
