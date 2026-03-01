import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/image_model_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:oktoast/oktoast.dart';
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

String _galleryCoverHeroTag(String imageModelId) =>
    'gallery_cover:$imageModelId';

const int _galleryDetailSideListCrossAxisCount = 2;

class GalleryDetailPage extends StatefulWidget {
  final String imageModelId;
  final String? initialCoverUrl;
  final String? initialTitle;
  final int? initialImageCount;
  final String? initialAuthorName;
  final String? initialAuthorUsername;
  final String? initialAuthorAvatarUrl;

  const GalleryDetailPage({
    super.key,
    required this.imageModelId,
    this.initialCoverUrl,
    this.initialTitle,
    this.initialImageCount,
    this.initialAuthorName,
    this.initialAuthorUsername,
    this.initialAuthorAvatarUrl,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // dispose
  @override
  void dispose() {
    _relatedTabController.dispose();
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

    if (imageModelId.isEmpty) {
      return;
    }
    LogUtils.d('图库ID: $imageModelId 初始化状态, $uniqueTag', 'GalleryDetailPage');

    // 初始化控制器
    detailController = Get.put(
      GalleryDetailController(imageModelId),
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
  }

  // 构建AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                detailController.imageModelInfo.value?.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => appRouter.go('/'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.2,
          maxChildSize: 0.92,
          expand: false,
          snap: true,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 拖拽条
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
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
                        // 排序切换按钮
                        Obx(
                          () => IconButton(
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
                                      position: ToastPosition.bottom,
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
                                      position: ToastPosition.bottom,
                                    );
                                    LoginService.showLogin();
                                    return;
                                  }
                                  await commentController.postComment(text);
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
                        controller: commentController,
                        authorUserId:
                            detailController.imageModelInfo.value?.user?.id,
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
    );
  }

  Widget _buildHeroScrollerSection(
    BuildContext context, {
    required String coverHeroTag,
    required int? imageCount,
    required double height,
  }) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(14));
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
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
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
    final displayName = authorName.isNotEmpty
        ? authorName
        : (username.isNotEmpty ? username : t.common.unknownUser);
    final avatarUrl = user?.avatar?.avatarUrl ?? widget.initialAuthorAvatarUrl;

    final User effectiveUser =
        user ?? User(id: 'unknown', name: displayName, username: username);

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
          Text(
            displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.pagePadding,
            ),
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

  Widget _buildRelatedTabBar(BuildContext context) {
    final t = slang.Translations.of(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: _relatedTabController,
        tabs: [
          Tab(text: t.galleryDetail.authorOtherGalleries),
          Tab(text: t.galleryDetail.relatedGalleries),
        ],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerHeight: 0,
      ),
    );
  }

  Widget _buildRelatedTabBarView(BuildContext context) {
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

  Widget _buildWideSideColumn(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: UIConstants.pagePadding),
        _buildRelatedTabBar(context),
        Expanded(child: _buildRelatedTabBarView(context)),
      ],
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
        appBar: isWide ? null : _buildAppBar(context),
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

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (Scrollable Content with AppBar)
                Expanded(
                  child: Column(
                    children: [
                      // AppBar for wide screen layout
                      _buildAppBar(context),
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          // 左侧内容整体可滚动
                          physics:
                              detailController.isHoveringHorizontalList.value
                              ? const NeverScrollableScrollPhysics()
                              : null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              overviewCard,
                              // 4. Safe Area Bottom Padding
                              const SafeArea(child: SizedBox.shrink()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Column (Fixed Width, Scrollable List)
                SizedBox(
                  // 右侧固定宽度
                  width: sideColumnMinWidth,
                  child: _buildWideSideColumn(context),
                ),
              ],
            );
          } else {
            // Narrow Screen Layout — NestedScrollView so overview scrolls
            // away while TabBar pins at the top.
            return NestedScrollView(
              physics: detailController.isHoveringHorizontalList.value
                  ? const NeverScrollableScrollPhysics()
                  : null,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(child: overviewCard),
              ],
              body: Column(
                children: [
                  _buildRelatedTabBar(context),
                  Expanded(child: _buildRelatedTabBarView(context)),
                ],
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
