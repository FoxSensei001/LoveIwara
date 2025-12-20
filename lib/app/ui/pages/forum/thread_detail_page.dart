import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/share_thread_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'widgets/thread_comment_card_widget.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_title_dialog.dart';
import 'package:i_iwara/app/services/forum_service.dart';

class ThreadDetailPage extends StatefulWidget {
  final String threadId;
  final String categoryId;

  const ThreadDetailPage({
    super.key,
    required this.threadId,
    required this.categoryId,
  });

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage>
    with SingleTickerProviderStateMixin {
  late ThreadDetailRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final Rx<ForumThreadModel?> _thread = Rx<ForumThreadModel?>(null);
  final UserService _userService = Get.find<UserService>();

  // 分页模式状态
  final RxBool isPaginated = CommonConstants.isPaginated.obs;

  // 分页模式下的状态
  int currentPage = 0;
  int itemsPerPage = 20;
  bool isLoading = false;
  List<ThreadCommentModel> paginatedItems = [];
  IndicatorStatus _indicatorStatus = IndicatorStatus.fullScreenBusying;
  String? _errorMessage;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    listSourceRepository = ThreadDetailRepository(
      categoryId: widget.categoryId,
      threadId: widget.threadId,
      updateThread: (thread) {
        _thread.value = thread;
      },
    );

    // 如果是分页模式，加载首页数据
    if (isPaginated.value) {
      _loadPaginatedData(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    super.dispose();
  }

  /// 切换分页模式
  void _togglePaginationMode() {
    final newValue = !isPaginated.value;
    isPaginated.value = newValue;
    CommonConstants.isPaginated = newValue;
    Get.find<ConfigService>()[ConfigKey.DEFAULT_PAGINATION_MODE] = newValue;

    // 滚动到顶部
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    if (newValue) {
      // 切换到分页模式
      currentPage = 0;
      _loadPaginatedData(0);
    } else {
      // 切换到瀑布流模式，刷新数据
      listSourceRepository.refresh(true);
    }
  }

  /// 加载分页数据
  Future<void> _loadPaginatedData(int page) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (_isFirstLoad || page == 0) {
        _indicatorStatus = IndicatorStatus.fullScreenBusying;
      } else {
        _indicatorStatus = IndicatorStatus.loadingMoreBusying;
      }
    });

    final bool pageChanged = page != currentPage && !_isFirstLoad;

    try {
      final items = await listSourceRepository.loadPageData(page, itemsPerPage);

      if (!mounted) return;

      setState(() {
        paginatedItems = items;
        currentPage = page;
        isLoading = false;
        _isFirstLoad = false;

        if (items.isEmpty && page == 0) {
          _indicatorStatus = IndicatorStatus.empty;
        } else if (items.isEmpty) {
          _indicatorStatus = IndicatorStatus.noMoreLoad;
        } else {
          _indicatorStatus = IndicatorStatus.none;
        }
      });

      if (pageChanged && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        _isFirstLoad = false;
        _errorMessage = CommonUtils.parseExceptionMessage(e);
        _indicatorStatus = page == 0
            ? IndicatorStatus.fullScreenError
            : IndicatorStatus.error;
      });
    }
  }

  /// 刷新数据
  Future<void> _refresh() async {
    if (isPaginated.value) {
      await _loadPaginatedData(0);
    } else {
      await listSourceRepository.refresh(true);
    }
  }

  int get totalItems => listSourceRepository.requestTotalCount;
  int get totalPages => totalItems > 0 ? (totalItems / itemsPerPage).ceil() : 1;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => _thread.value == null
              ? Shimmer.fromColors(
                  baseColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 200, height: 16, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 120, height: 12, color: Colors.white),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _thread.value?.title ?? '',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_thread.value != null)
                      Text(
                        '${t.common.publishedAt}: ${CommonUtils.formatFriendlyTimestamp(_thread.value?.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
        ),
        actions: [
          // 分页模式切换按钮
          Obx(
            () => IconButton(
              icon: Icon(
                isPaginated.value ? Icons.view_stream : Icons.view_module,
              ),
              tooltip: isPaginated.value
                  ? slang.t.common.pagination.waterfall
                  : slang.t.common.pagination.pagination,
              onPressed: _togglePaginationMode,
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          Obx(() {
            if (_thread.value == null) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(_thread.value!.locked ? Icons.lock : Icons.reply),
              tooltip: t.forum.reply,
              onPressed: () {
                if (_thread.value!.locked) {
                  showToastWidget(
                    MDToastWidget(
                      message: slang.t.forum.errors.threadLocked,
                      type: MDToastType.warning,
                    ),
                  );
                  return;
                }
                if (!_userService.isLogin) {
                  showToastWidget(
                    MDToastWidget(
                      message: slang.t.errors.pleaseLoginFirst,
                      type: MDToastType.warning,
                    ),
                  );
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ForumReplyBottomSheet(
                    threadId: _thread.value!.id,
                    onSubmit: () {
                      _refresh();
                    },
                  ),
                );
              },
            );
          }),
          Obx(() {
            if (_thread.value == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) =>
                      ShareThreadBottomSheet(thread: _thread.value!),
                  context: context,
                );
              },
            );
          }),
        ],
      ),
      body: Obx(
        () => isPaginated.value
            ? _buildPaginatedBody(context)
            : _buildWaterfallBody(context),
      ),
    );
  }

  /// 构建瀑布流模式的 body
  Widget _buildWaterfallBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 600;

        return LoadingMoreCustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // 添加面包屑导航
            SliverToBoxAdapter(
              child: Obx(() {
                if (_thread.value == null) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 16.0 : 8.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${slang.t.forum.forum} / ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        idNames[replaceUnderline(_thread.value!.section)] ??
                            'Unknown',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // 帖子内容区域
            SliverToBoxAdapter(
              child: Obx(() {
                if (_thread.value == null) {
                  return _buildShimmerLoading(isWideScreen);
                }

                return _buildThreadCard(context, isWideScreen);
              }),
            ),

            // 评论列表
            LoadingMoreSliverList<ThreadCommentModel>(
              SliverListConfig<ThreadCommentModel>(
                itemBuilder: (context, comment, index) =>
                    buildCommentItem(context, comment, isWideScreen),
                sourceList: listSourceRepository,
                padding: EdgeInsets.only(
                  left: isWideScreen ? 16.0 : 8.0,
                  right: isWideScreen ? 16.0 : 8.0,
                  bottom: Get.context != null
                      ? MediaQuery.of(Get.context!).padding.bottom
                      : 0,
                ),
                indicatorBuilder: (context, status) => buildIndicator(
                  context,
                  status,
                  () => listSourceRepository.errorRefresh(),
                  emptyIcon: Icons.forum_outlined,
                  paddingTop: 0,
                  errorMessage: listSourceRepository.lastErrorMessage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建分页模式的 body
  Widget _buildPaginatedBody(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const paginationBarHeight = 46;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 600;

        return Stack(
          children: [
            // 主内容区域
            RefreshIndicator(
              onRefresh: _refresh,
              child: _buildPaginatedContent(
                context,
                isWideScreen,
                paginationBarHeight,
              ),
            ),

            // 分页控制栏
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PaginationBar(
                currentPage: currentPage,
                totalPages: totalPages,
                totalItems: totalItems,
                isLoading: isLoading,
                onPageChanged: _loadPaginatedData,
                useBlurEffect: true,
                paddingBottom: bottomPadding,
                showBottomPadding: true,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建分页模式的内容
  Widget _buildPaginatedContent(
    BuildContext context,
    bool isWideScreen,
    int paginationBarHeight,
  ) {
    // 全屏状态显示指示器
    if (_indicatorStatus == IndicatorStatus.fullScreenBusying ||
        _indicatorStatus == IndicatorStatus.fullScreenError ||
        (_indicatorStatus == IndicatorStatus.empty && paginatedItems.isEmpty)) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          // 帖子头部
          SliverToBoxAdapter(
            child: Obx(() {
              if (_thread.value == null) return const SizedBox.shrink();

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 16.0 : 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      '${slang.t.forum.forum} / ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      idNames[replaceUnderline(_thread.value!.section)] ??
                          'Unknown',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (_thread.value == null) {
                return _buildShimmerLoading(isWideScreen);
              }
              return _buildThreadCard(context, isWideScreen);
            }),
          ),
          // buildIndicator already returns a Sliver for fullscreen states
          if (_indicatorStatus == IndicatorStatus.fullScreenBusying ||
              _indicatorStatus == IndicatorStatus.fullScreenError ||
              _indicatorStatus == IndicatorStatus.empty)
            buildIndicator(
                  context,
                  _indicatorStatus,
                  () => _loadPaginatedData(currentPage),
                  emptyIcon: Icons.forum_outlined,
                  paddingTop: 0,
                  errorMessage: _errorMessage,
                ) ??
                const SliverToBoxAdapter(child: SizedBox.shrink()),
        ],
      );
    }

    // 数据已加载，显示内容
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // 面包屑导航
        SliverToBoxAdapter(
          child: Obx(() {
            if (_thread.value == null) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 16.0 : 8.0,
              ),
              child: Row(
                children: [
                  Text(
                    '${slang.t.forum.forum} / ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    idNames[replaceUnderline(_thread.value!.section)] ??
                        'Unknown',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),

        // 帖子内容区域
        SliverToBoxAdapter(
          child: Obx(() {
            if (_thread.value == null) {
              return _buildShimmerLoading(isWideScreen);
            }
            return _buildThreadCard(context, isWideScreen);
          }),
        ),

        // 评论列表
        SliverPadding(
          padding: EdgeInsets.only(
            left: isWideScreen ? 16.0 : 8.0,
            right: isWideScreen ? 16.0 : 8.0,
            bottom: paginationBarHeight + 4.0,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => buildCommentItem(
                context,
                paginatedItems[index],
                isWideScreen,
              ),
              childCount: paginatedItems.length,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建帖子卡片
  Widget _buildThreadCard(BuildContext context, bool isWideScreen) {
    final t = slang.Translations.of(context);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 16.0 : 8.0,
        vertical: 4.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header：作者信息区域
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      NaviService.navigateToAuthorProfilePage(
                        _thread.value!.user.username,
                      );
                    },
                    child: AvatarWidget(user: _thread.value!.user, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  NaviService.navigateToAuthorProfilePage(
                                    _thread.value!.user.username,
                                  );
                                },
                                child: buildUserName(
                                  context,
                                  _thread.value!.user,
                                  fontSize: 15,
                                  bold: true,
                                ),
                              ),
                            ),
                          ),
                          // 锁和图钉图标
                          if (_thread.value!.sticky)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.push_pin,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          if (_thread.value!.locked)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.lock,
                                size: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: _thread.value!.user.username,
                                    ),
                                  );
                                  showToastWidget(
                                    MDToastWidget(
                                      message: slang.t.forum
                                          .copySuccessForMessage(
                                            str: _thread.value!.user.username,
                                          ),
                                      type: MDToastType.success,
                                    ),
                                  );
                                },
                                child: Text(
                                  '@${_thread.value!.user.username}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.schedule, size: 14),
                          Text(
                            CommonUtils.formatFriendlyTimestamp(
                              _thread.value!.createdAt,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
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
          // 内容部分：标题、状态、统计信息及更新时间
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                // 标题
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _thread.value!.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.translate),
                      onPressed: () {
                        Get.dialog(
                          TranslationDialog(text: _thread.value!.title),
                        );
                      },
                      tooltip: t.common.translate,
                    ),
                    if (_userService.currentUser.value?.id ==
                        _thread.value!.user.id)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Get.dialog(
                            ForumEditTitleDialog(
                              postId: _thread.value!.id,
                              initialTitle: _thread.value!.title,
                              repository: listSourceRepository,
                              onSubmit: () {
                                _refresh();
                              },
                            ),
                          );
                        },
                        tooltip: t.forum.editTitle,
                      ),
                  ],
                ),
                // 统计信息和更新时间
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                              Text(
                                CommonUtils.formatFriendlyNumber(
                                  _thread.value!.numViews,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.comment,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                              Text(
                                CommonUtils.formatFriendlyNumber(
                                  _thread.value!.numPosts,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${t.common.updatedAt}: ${CommonUtils.formatFriendlyTimestamp(_thread.value!.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentItem(
    BuildContext context,
    ThreadCommentModel comment,
    bool isWideScreen,
  ) {
    return ThreadCommentCardWidget(
      comment: comment,
      threadAuthorId: _thread.value?.user.id ?? '',
      threadId: widget.threadId,
      lockedThread: _thread.value?.locked ?? false,
      listSourceRepository: listSourceRepository,
    );
  }

  Widget _buildShimmerLoading(bool isWideScreen) {
    return Card(
      margin: EdgeInsets.all(isWideScreen ? 16.0 : 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          highlightColor: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // 作者信息
              Row(
                spacing: 12,
                children: [
                  // 头像
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        // 用户名
                        Container(width: 100, height: 14, color: Colors.white),
                        // 时间
                        Container(width: 80, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              // 标题
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              // 统计信息
              Row(
                spacing: 16,
                children: [
                  Container(width: 60, height: 14, color: Colors.white),
                  Container(width: 60, height: 14, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
