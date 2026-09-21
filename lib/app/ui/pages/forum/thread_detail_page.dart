import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/share_thread_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_overflow_menu_button.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/services/quoted_user_cache.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'widgets/thread_comment_card_widget.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_title_dialog.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';

class ThreadDetailPage extends StatefulWidget {
  final String threadId;
  final String categoryId;
  final ForumThreadModel? initialThread;

  const ThreadDetailPage({
    super.key,
    required this.threadId,
    required this.categoryId,
    this.initialThread,
  });

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage>
    with SingleTickerProviderStateMixin {
  // 楼主强调色（琥珀），与楼层卡片中发帖人保持一致
  static const Color _authorAccent = Color(0xFFFFB300);
  late ThreadDetailRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final Rx<ForumThreadModel?> _thread = Rx<ForumThreadModel?>(null);
  final UserService _userService = Get.find<UserService>();

  // 分页模式状态
  final RxBool isPaginated = CommonConstants.isPaginated.obs;

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  // 分页模式下的状态
  int currentPage = 0;
  int itemsPerPage = 20;
  bool isLoading = false;
  List<ThreadCommentModel> paginatedItems = [];
  IndicatorStatus _indicatorStatus = IndicatorStatus.fullScreenBusying;
  String? _errorMessage;
  bool _isFirstLoad = true;

  /// 当前这一屏里，楼层号 → 那条楼层的锚点。跳转靠它 `ensureVisible`。
  ///
  /// ⚠️ 只装**当前构建出来的**那些：翻页 / 刷新之后旧的 key 会失效，所以每次
  /// 换数据都要清一遍（见 [_resetFloorAnchors]），否则 `currentContext` 会拿到
  /// 已经卸载的 element。
  final Map<int, GlobalKey> _floorAnchors = {};

  /// 刚跳到的那一楼，短暂点亮。null＝没有。
  ///
  /// 不点亮的话，跳转在一屏全是相似楼层的列表里等于什么都没发生——用户不知道
  /// 到底是滚到了哪一条。
  int? _highlightedFloor;

  /// 正在为「跳楼层」翻页：抑制 [_loadPaginatedData] 翻页后那记回到顶部。
  ///
  /// ⛔ 不抑制的话两个滚动会打架：它把列表甩回顶部，我们紧接着 ensureVisible
  /// 到目标楼层，用户看到的是列表抽搐一下。
  bool _jumpingToFloor = false;

  @override
  void initState() {
    super.initState();
    _thread.value = widget.initialThread;
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
    _showBackToTop.dispose();
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
        _resetFloorAnchors();
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

      if (pageChanged && !_jumpingToFloor && _scrollController.hasClients) {
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

  String _threadHeroTag(String threadId) => 'forum-thread-card-$threadId';

  Widget _buildThreadMetaChip({
    required IconData icon,
    required String text,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? colorScheme.onSurfaceVariant;
    final bg = backgroundColor ?? fg.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.5, color: fg),
          const SizedBox(width: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadStatusChip({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 19, minWidth: 27),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, size: 13, color: color),
    );
  }

  /// 这个主题能给小尾巴的上下文：标题、版块名、楼主。
  ///
  /// 版块名走 [idNames]（界面语言那份），不是接口给的 `general-zh` 那种 slug——
  /// 小尾巴是写给人看的一句话。
  SignatureContext _signatureContextOf(ForumThreadModel thread) =>
      SignatureContext(
        title: thread.title,
        author: thread.user.name,
        section: idNames[replaceUnderline(thread.section)] ?? thread.section,
      );

  /// 弹出回复底部弹层（锁定 / 未登录时给出提示）。
  void _showReplySheet() {
    final thread = _thread.value;
    if (thread == null) return;
    if (thread.locked) {
      showAppToast(
        slang.t.forum.errors.threadLocked,
        type: AppToastType.warning,
      );
      return;
    }
    if (!_userService.isAuthenticated) {
      showAppToast(slang.t.errors.pleaseLoginFirst, type: AppToastType.warning);
      return;
    }
    showGlassBottomSheet(
      context: context,
      builder: (context) => ForumReplyBottomSheet(
        threadId: thread.id,
        signatureContext: _signatureContextOf(thread),
        onSubmit: () {
          _refresh();
        },
      ),
    );
  }

  void _showShareSheet() {
    final thread = _thread.value;
    if (thread == null) return;
    showGlassBottomSheet(
      builder: (context) => ShareThreadBottomSheet(thread: thread),
      context: context,
    );
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

  /// 右侧动作胶囊：[分享(仅宽屏)] 瀑布/分页切换 · 回复 · 更多。
  ///
  /// 分享 / 回复要等帖子数据就绪才可用，用 [GlassGroupSlot] 让它们
  /// 随加载完成被「挤进」胶囊；锁定态下回复位的图标切成锁
  /// （GlassIconButton 内建图标交叉过渡）。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final thread = _thread.value;
      final bool loaded = thread != null;
      return GlassButtonGroup(
        children: [
          GlassGroupSlot(
            visible: isWide && loaded,
            child: GlassIconButton(
              icon: const Icon(Icons.share),
              tooltip: t.common.share,
              onPressed: _showShareSheet,
            ),
          ),
          GlassIconButton(
            icon: Icon(
              isPaginated.value ? Icons.view_stream : Icons.view_module,
            ),
            tooltip: isPaginated.value
                ? t.common.pagination.waterfall
                : t.common.pagination.pagination,
            onPressed: _togglePaginationMode,
          ),
          GlassGroupSlot(
            visible: loaded,
            child: GlassIconButton(
              icon: Icon(loaded && thread.locked ? Icons.lock : Icons.reply),
              tooltip: t.forum.reply,
              onPressed: _showReplySheet,
            ),
          ),
          // 「更多」只剩一条时（宽屏 / 数据未就绪：分享不在菜单里，只剩刷新）
          // 自动变成那枚动作本身，不为一个选项多弹一次层
          GlassGroupOverflowMenuButton(
            actions: [
              GlassMenuAction(
                icon: Icons.refresh,
                label: t.common.refresh,
                onSelected: _refresh,
                showsLoading: true,
              ),
              if (!isWide && loaded)
                GlassMenuAction(
                  icon: Icons.share,
                  label: t.common.share,
                  onSelected: _showShareSheet,
                ),
            ],
          ),
        ],
      );
    });
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Obx(
      () => Positioned(
        right: 16,
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (isPaginated.value ? PaginationBar.barHeight : 0),
        child: ValueListenableBuilder<bool>(
          valueListenable: _showBackToTop,
          builder: (context, visible, _) =>
              ScrollToTopFab(visible: visible, onPressed: _scrollToTop),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
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
          child: Obx(
            () => isPaginated.value
                ? _buildPaginatedBody(context, headerExtent)
                : _buildWaterfallBody(context, headerExtent),
          ),
        ),
        // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
        header: Padding(
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
                child: Obx(() => GlassTitlePill(title: _thread.value?.title)),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context, isWide: isWide),
            ],
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }

  Widget _buildBreadcrumb(
    BuildContext context,
    bool isWideScreen, {
    required double topPadding,
  }) {
    if (_thread.value == null) {
      return SizedBox(height: topPadding);
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWideScreen ? 16.0 : 8.0,
        topPadding,
        isWideScreen ? 16.0 : 8.0,
        8,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildThreadMetaChip(
            icon: Icons.forum_outlined,
            text: slang.t.forum.forum,
            foregroundColor: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          ),
          _buildThreadMetaChip(
            icon: Icons.label_rounded,
            text:
                idNames[replaceUnderline(_thread.value!.section)] ?? 'Unknown',
            foregroundColor: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  /// 构建瀑布流模式的 body
  Widget _buildWaterfallBody(BuildContext context, double effectivePaddingTop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 600;

        return LoadingMoreCustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // 添加面包屑导航
            SliverToBoxAdapter(
              child: Obx(() {
                return _buildBreadcrumb(
                  context,
                  isWideScreen,
                  topPadding: effectivePaddingTop + 8,
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
                itemBuilder: (context, comment, index) => buildCommentItem(
                  context,
                  comment,
                  isWideScreen,
                  showDivider: index < listSourceRepository.length - 1,
                ),
                sourceList: listSourceRepository,
                padding: EdgeInsets.only(
                  left: isWideScreen ? 16.0 : 8.0,
                  right: isWideScreen ? 16.0 : 8.0,
                  bottom: MediaQuery.of(context).padding.bottom,
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
  Widget _buildPaginatedBody(BuildContext context, double effectivePaddingTop) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 46 = 分页栏内容高度；再加悬浮模式上方的透明渐入区
    final paginationBarHeight = 46 + PaginationBar.fadeAboveExtent.toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 600;

        return Stack(
          children: [
            // 主内容区域
            RefreshIndicator(
              // 下拉指示器从玻璃 header 下方弹出
              displacement: effectivePaddingTop,
              onRefresh: _refresh,
              child: _buildPaginatedContent(
                context,
                isWideScreen,
                paginationBarHeight,
                effectivePaddingTop,
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
    double effectivePaddingTop,
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
              return _buildBreadcrumb(
                context,
                isWideScreen,
                topPadding: effectivePaddingTop + 8,
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
            return _buildBreadcrumb(
              context,
              isWideScreen,
              topPadding: effectivePaddingTop + 8,
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
                showDivider: index < paginatedItems.length - 1,
              ),
              childCount: paginatedItems.length,
            ),
          ),
        ),
      ],
    );
  }

  /// 主楼动作行的幽灵胶囊钮（与楼层卡片的动作行同款）。
  Widget _buildGhostAction({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = color ?? colorScheme.onSurfaceVariant;
    final bg = color != null
        ? color.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHigh;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 身份小徽标（「作者」琥珀 /「我」主色），与楼层卡片同款。
  Widget _buildIdentityChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }

  /// 主楼区块：与楼层流同一套「扁平线程流」语言——无卡片，头像列 + 内容列，
  /// 琥珀「作者」徽标代替旧版整卡染色 + 强调竖条，标题完整展示不截断，
  /// 右下角 翻译 / 编辑标题 幽灵钮，底部细分隔线收束主楼区。
  Widget _buildThreadCard(BuildContext context, bool isWideScreen) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final thread = _thread.value!;
    final bool isMe = _userService.currentUser.value?.id == thread.user.id;

    void openProfile() {
      NaviService.navigateToAuthorProfilePage(
        thread.user.username,
        initialUser: thread.user,
      );
    }

    void copyUsername() {
      Clipboard.setData(ClipboardData(text: thread.user.username));
      showAppToast(
        slang.t.forum.copySuccessForMessage(str: thread.user.username),
        type: AppToastType.success,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWideScreen ? 16.0 : 8.0,
        4,
        isWideScreen ? 16.0 : 8.0,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: _threadHeroTag(thread.id),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者行：头像 + 名字/徽标 + 元信息行
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: openProfile,
                          child: AvatarWidget(user: thread.user, size: 36),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: openProfile,
                                      child: buildUserName(
                                        context,
                                        thread.user,
                                        fontSize: 15,
                                        bold: true,
                                      ),
                                    ),
                                  ),
                                ),
                                _buildIdentityChip(
                                  t.common.author,
                                  _authorAccent,
                                ),
                                if (isMe)
                                  _buildIdentityChip(
                                    t.common.me,
                                    colorScheme.primary,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // 元信息行：@用户名 · 发布时间（点按复制用户名）
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: copyUsername,
                                child: Text(
                                  '@${thread.user.username} · '
                                  '${CommonUtils.formatFriendlyTimestamp(thread.createdAt)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 标题：主楼完整展示不截断（header 胶囊里才做省略）
                            SelectableText(
                              thread.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 状态 / 统计 chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (thread.sticky)
                                  _buildThreadStatusChip(
                                    icon: Icons.push_pin_rounded,
                                    color: colorScheme.primary,
                                  ),
                                if (thread.locked)
                                  _buildThreadStatusChip(
                                    icon: Icons.lock_rounded,
                                    color: colorScheme.error,
                                  ),
                                _buildThreadMetaChip(
                                  icon: Icons.visibility_rounded,
                                  text: CommonUtils.formatFriendlyNumber(
                                    thread.numViews,
                                  ),
                                ),
                                _buildThreadMetaChip(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  text: CommonUtils.formatFriendlyNumber(
                                    thread.numPosts,
                                  ),
                                ),
                                _buildThreadMetaChip(
                                  icon: Icons.update_rounded,
                                  text: CommonUtils.formatFriendlyTimestamp(
                                    thread.updatedAt,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 动作行：翻译 / 编辑标题
                            //（幽灵钮，右对齐与楼层动作行呼应）
                            Row(
                              children: [
                                const Spacer(),
                                _buildGhostAction(
                                  icon: Icons.translate,
                                  label: t.common.translate,
                                  onTap: () {
                                    showTranslationDialog(
                                      context,
                                      text: thread.title,
                                    );
                                  },
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 8),
                                  _buildGhostAction(
                                    icon: Icons.edit,
                                    label: t.forum.editTitle,
                                    onTap: () {
                                      showAppDialog(
                                        ForumEditTitleDialog(
                                          postId: thread.id,
                                          initialTitle: thread.title,
                                          repository: listSourceRepository,
                                          onSubmit: () {
                                            _refresh();
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 主楼与楼层流之间的分隔线
          Divider(
            height: 1,
            thickness: 0.5,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  void _resetFloorAnchors() => _floorAnchors.clear();

  /// 跳到某一楼。引用条点下去走的就是这条路。
  ///
  /// 三种落法，按代价从小到大：
  ///
  /// 1. **已经在当前这份数据里** → 滚过去（两种模式都走这条）。注意「在数据里」
  ///    不等于「在屏幕上」：懒列表只给屏内那几条建 element，所以屏外的目标要先
  ///    由 [_ensureFloorBuilt] 挪出来；
  /// 2. **分页模式且不在本页** → 楼层号 `replyNum` 是服务端下发的**全局**序号，
  ///    第几页算得出来（`(floor-1) ~/ itemsPerPage`），翻过去再滚；
  /// 3. **瀑布流且还没加载到** → ⛔ 不做「自动一直加载到那一页」：目标可能在
  ///    几十页以前，那等于替用户决定打几十次请求。老老实实说一句它在更早的
  ///    位置，把要不要继续翻留给用户。
  ///
  /// 楼层被删（总数比它小）时直接说不存在——引用里的楼层号指向一条不在了的
  /// 回复是完全正常的事，不该表现成「点了没反应」。
  Future<void> _jumpToFloor(int floor) async {
    final total = _thread.value?.numPosts;
    if (floor < 1 || (total != null && floor > total)) {
      showAppToast(slang.t.forum.floorNotFound, type: AppToastType.warning);
      return;
    }

    if (await _revealFloor(floor)) return;

    if (!isPaginated.value) {
      showAppToast(slang.t.forum.floorNotLoadedYet, type: AppToastType.info);
      return;
    }

    final targetPage = (floor - 1) ~/ itemsPerPage;
    if (targetPage == currentPage) {
      // 就在本页却找不到锚点＝这一楼确实不在数据里（被删了）
      showAppToast(slang.t.forum.floorNotFound, type: AppToastType.warning);
      return;
    }

    _jumpingToFloor = true;
    try {
      await _loadPaginatedData(targetPage);
      if (!mounted) return;
      // 等这一帧画完，新一页的锚点才挂得上去
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      if (await _revealFloor(floor)) return;
      showAppToast(slang.t.forum.floorNotFound, type: AppToastType.warning);
    } finally {
      _jumpingToFloor = false;
    }
  }

  /// 当前这份数据里的全部楼层（分页模式是本页，瀑布流是已经加载到的那些）。
  List<ThreadCommentModel> get _currentItems =>
      isPaginated.value ? paginatedItems : listSourceRepository;

  /// 朝目标楼层一屏一屏地挪，最多挪这么多次就放弃。
  ///
  /// 一页 40 条、一屏放得下三四条，来回也就十来次；给到 80 是留给「一页条数
  /// 很多 + 每条都很长」的极端情形，同时保证这个循环一定会停。
  static const int _maxFloorSeekSteps = 80;

  /// 让目标楼层**真的挂到树上**，返回是否落成。
  ///
  /// ⛔ 楼层是 `SliverChildBuilderDelegate` 懒建的：屏外那些根本没有 element，
  /// `GlobalKey.currentContext` 对它们恒为 null。早先直接拿这个 null 当「找不到
  /// 这一楼」，于是在同一页里往回跳（正读第 38 楼，点一条指向第 3 楼的引用）会
  /// 弹出「楼层不存在」——而它明明就在这一页里（2026-09-21 审查查出）。
  ///
  /// 所以先问**数据**里有没有这一楼（那才是「存不存在」的真答案），有就朝它的
  /// 方向挪，边挪边看锚点挂上来没有。楼层按 `replyNum` 升序排，所以目标比已建
  /// 出来的最小楼层还小就往上，否则往下。
  Future<bool> _ensureFloorBuilt(int floor) async {
    if (_floorAnchors[floor]?.currentContext != null) return true;
    if (!_currentItems.any((c) => c.replyNum + 1 == floor)) return false;
    if (!_scrollController.hasClients) return false;

    for (var step = 0; step < _maxFloorSeekSteps; step++) {
      final built = _floorAnchors.entries
          .where((e) => e.value.currentContext != null)
          .map((e) => e.key)
          .toList();
      // 一条都没建出来就没有方向可言（列表还没画）——交给调用方去报。
      if (built.isEmpty) return false;

      final position = _scrollController.position;
      final smallest = built.reduce((a, b) => a < b ? a : b);
      final delta = position.viewportDimension * 0.8;
      final target =
          (floor < smallest ? position.pixels - delta : position.pixels + delta)
              .clamp(position.minScrollExtent, position.maxScrollExtent);
      // 已经顶到头还没见着它：再挪也没用。
      if ((target - position.pixels).abs() < 1) return false;

      // ⛔ 这一段用 jumpTo：它是**找**的过程，不是给人看的过程。真正的落位由
      // [_revealFloor] 的 ensureVisible 平滑做完。
      _scrollController.jumpTo(target);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return false;
      if (_floorAnchors[floor]?.currentContext != null) return true;
    }
    return false;
  }

  /// 目标楼层在当前这份数据里就滚过去并点亮，返回是否落成。
  Future<bool> _revealFloor(int floor) async {
    if (!await _ensureFloorBuilt(floor)) return false;
    if (!mounted) return false;
    // ⭐ 锚点是在 await **之后**现取的，所以它本来就是当下那一个（`currentContext`
    // 对没挂在树上的 key 直接给 null）。`mounted` 这一道是给分析器看的，也顺手
    // 防住「拿到的一刻正好被回收」。
    final anchor = _floorAnchors[floor]?.currentContext;
    if (anchor == null || !anchor.mounted) return false;

    await Scrollable.ensureVisible(
      anchor,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      // 别把目标贴在屏幕最上沿：留一点上文才看得出它是回复流里的一条
      alignment: 0.12,
    );
    if (!mounted) return true;

    setState(() => _highlightedFloor = floor);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted || _highlightedFloor != floor) return;
      setState(() => _highlightedFloor = null);
    });
    return true;
  }

  Widget buildCommentItem(
    BuildContext context,
    ThreadCommentModel comment,
    bool isWideScreen, {
    bool showDivider = false,
  }) {
    final floor = comment.replyNum + 1;
    // 每构建一条就把作者喂进引用缓存：引用条的头像 / 昵称靠它，喂过之后同页
    // （以及之后翻回来的页）的引用都是零网络的。幂等，成本是一次 map 写。
    QuotedUserCache.seed([comment.user]);
    final anchor = _floorAnchors.putIfAbsent(floor, () => GlobalKey());

    final Widget item = ThreadCommentCardWidget(
      key: ValueKey('floor-$floor-${comment.id}'),
      comment: comment,
      threadAuthorId: _thread.value?.user.id ?? '',
      threadId: widget.threadId,
      lockedThread: _thread.value?.locked ?? false,
      listSourceRepository: listSourceRepository,
      onJumpToFloor: _jumpToFloor,
      // 楼层回复的小尾巴上下文＝这个主题的上下文（楼层自己再补上「回给谁」）。
      // 只有帖子详情页手里有主题信息，卡片自己看不见。
      threadSignatureContext: () {
        final thread = _thread.value;
        return thread == null
            ? SignatureContext.empty
            : _signatureContextOf(thread);
      },
    );

    // 跳过去之后点亮一下，否则在一屏相似的楼层里根本看不出落在了哪条。
    final highlighted = _highlightedFloor == floor;
    final Widget anchored = KeyedSubtree(
      key: anchor,
      child: AnimatedContainer(
        duration: Duration(milliseconds: highlighted ? 180 : 700),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: highlighted
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: item,
      ),
    );

    if (!showDivider) return anchored;
    // 扁平楼层流之间用细分隔线（与评论区一致）
    return Column(
      children: [
        anchored,
        Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  /// 主楼区块加载骨架：与正式主楼同一套扁平布局。
  Widget _buildShimmerLoading(bool isWideScreen) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );

    return Hero(
      tag: _threadHeroTag(widget.threadId),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isWideScreen ? 16.0 : 8.0,
            4,
            isWideScreen ? 16.0 : 8.0,
            12,
          ),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surface,
            // 与正式主楼一致：标题 / chips 也缩进到头像右侧那一列
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                // 头像
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户名
                      bar(100, 14),
                      const SizedBox(height: 4),
                      // 元信息行
                      bar(140, 12),
                      const SizedBox(height: 12),
                      // 标题
                      bar(double.infinity, 20),
                      const SizedBox(height: 10),
                      // 状态 / 统计 chips
                      Row(
                        spacing: 8,
                        children: [bar(60, 19), bar(60, 19), bar(60, 19)],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
