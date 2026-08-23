import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/author_profile/controllers/userz_post_list_repository.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_tile_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/author_profile/widgets/post_input_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class ProfilePostTabListWidget extends StatefulWidget {
  final String userId;
  final String tabKey;
  final TabController tc;

  /// 上方被页面级 header 占掉的高度（列表用它让出首屏，滚动时从背后经过）。
  final double overlayTopInset;

  /// 顶部蒙层平台段（状态栏）高度。
  final double scrimSolidExtent;
  final Function({int? count})? onFetchFinished;
  final GlobalKey<State<StatefulWidget>>? widgetKey;
  final bool isPaginated;
  final VoidCallback? onPaginationToggle;
  final VoidCallback? onPageChanged;

  const ProfilePostTabListWidget({
    super.key,
    required this.userId,
    required this.tabKey,
    required this.tc,
    this.onFetchFinished,
    this.widgetKey,
    this.isPaginated = false,
    this.onPaginationToggle,
    this.onPageChanged,
    this.overlayTopInset = 0,
    this.scrimSolidExtent = 0,
  });

  void refresh() {
    if (widgetKey?.currentState != null) {
      (widgetKey!.currentState as _ProfilePostTabListWidgetState)
          ._requestRefresh();
    }
  }

  @override
  State<ProfilePostTabListWidget> createState() =>
      _ProfilePostTabListWidgetState();
}

class _ProfilePostTabListWidgetState extends State<ProfilePostTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late UserzPostListRepository listSourceRepository;

  /// 仅在「没有 PrimaryScrollController 可用」时才启用的后备 controller。
  ///
  /// 窄屏走 ExtendedNestedScrollView(onlyOneScrollInBody: true)，它会通过
  /// PrimaryScrollController 向 body 下发内层 controller。列表必须挂到那个
  /// controller 上，滚动才会被外层协调器看见、头部才能跟着折叠——包作者在
  /// 文档里明确写了 body 内的可滚动组件「不应该被指定显式 controller」。
  /// 本 tab 原先传了自建 controller，于是脱离协调，滑列表带不动头部折叠
  /// （其余三个 tab 都没传，一直是正常的）。
  ///
  /// 宽屏布局没有 NestedScrollView，也就没有 PrimaryScrollController，
  /// 这时才回退到本 controller，否则「回到顶部」按钮会失效。
  final ScrollController _fallbackController = ScrollController();
  final RxBool _showBackToTop = false.obs;

  /// 带回执的刷新信号：header 上的刷新钮据此在刷完前显示沙漏。
  final ListRefreshSignal _refreshSignal = ListRefreshSignal();
  final UserService _userService = Get.find<UserService>();
  final PostService _postService = Get.find<PostService>();

  @override
  void initState() {
    super.initState();
    listSourceRepository = UserzPostListRepository(userId: widget.userId);
  }

  @override
  void dispose() {
    _fallbackController.dispose();
    _refreshSignal.dispose();
    listSourceRepository.dispose();
    super.dispose();
  }

  void _showCreatePostDialog() {
    final t = slang.Translations.of(context);
    showAppDialog(
      PostInputDialog(
        onSubmit: (title, body) async {
          final result = await _postService.postPost(title, body);
          if (result.isSuccess) {
            showGlassToast(t.common.success, type: GlassToastType.success);
            AppService.tryPop();
            _requestRefresh();
          } else if (result.message == t.errors.tooManyRequests) {
            // 如果是请求过于频繁，则获取冷却时间
            final cooldownResult = await _postService.fetchPostCollingInfo();
            if (cooldownResult.isSuccess && cooldownResult.data != null) {
              final cooldown = cooldownResult.data!;
              if (cooldown.limited) {
                // 计算剩余时间，小数点后二位
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

  Future<void> _requestRefresh() => _refreshSignal.request();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 有 PrimaryScrollController（窄屏的 ExtendedNestedScrollView 下发的）时
    // 一定要让给它，列表才会参与外层头部折叠的协调。
    final bool inheritPrimary = PrimaryScrollController.shouldInherit(
      context,
      Axis.vertical,
    );
    final ScrollController? primaryController = inheritPrimary
        ? PrimaryScrollController.maybeOf(context)
        : null;
    final ScrollController scrollTarget =
        primaryController ?? _fallbackController;

    final t = slang.Translations.of(context);
    const headerHeight = GlassTokens.pillHeight + 12;
    final double headerExtent = widget.overlayTopInset + headerHeight;
    return GlassHeaderOverlay(
      headerExtent: headerExtent,
      headerTop: widget.overlayTopInset,
      headerHeight: headerHeight,
      solidExtent: widget.scrimSolidExtent,
      liquid: true,
      body: NotificationListener<ScrollNotification>(
        // 改用滚动通知驱动「回到顶部」按钮的显隐：不再依赖自建 controller，
        // 无论列表最终挂在 PrimaryScrollController 还是后备 controller 上都成立。
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            _showBackToTop.value = notification.metrics.pixels >= 300;
          }
          return false;
        },
        child: MediaListView<PostModel>(
          sourceList: listSourceRepository,
          isPaginated: widget.isPaginated,
          refreshSignal: _refreshSignal,
          onPageChanged: widget.onPageChanged,
          scrollController: primaryController == null
              ? _fallbackController
              : null,
          paddingTop: headerExtent,
          emptyIcon: Icons.article_outlined,
          itemBuilder: buildItem,
        ),
      ),
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(
          alignment: Alignment.centerRight,
          child: GlassButtonGroup(
            children: [
              GlassIconButton(
                icon: Icon(
                  widget.isPaginated ? Icons.grid_view : Icons.view_stream,
                ),
                tooltip: widget.isPaginated
                    ? t.common.pagination.waterfall
                    : t.common.pagination.pagination,
                onPressed: widget.onPaginationToggle,
              ),
              GlassAsyncIconButton(
                icon: const Icon(Icons.refresh),
                tooltip: t.common.refresh,
                onPressed: _requestRefresh,
              ),
            ],
          ),
        ),
      ),
      extra: [
        Positioned(
          right: 16,
          // 视口不再被整体上移，所以 FAB 要自己避开手势条。
          bottom:
              16 +
              computeBottomSafeInset(MediaQuery.of(context)) +
              (widget.isPaginated ? 46 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 发表帖子按钮
              Obx(() {
                if (_userService.currentUser.value?.id == widget.userId) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: FloatingActionButton(
                      heroTag: 'createPost',
                      onPressed: _showCreatePostDialog,
                      child: const Icon(Icons.add),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              // 返回顶部按钮
              Obx(
                () => _showBackToTop.value
                    ? FloatingActionButton(
                        heroTag: 'backToTop',
                        onPressed: () {
                          if (!scrollTarget.hasClients) return;
                          scrollTarget.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Icon(Icons.arrow_upward),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildItem(BuildContext context, PostModel post, int index) {
    return PostTileListItemWidget(post: post);
  }

  @override
  bool get wantKeepAlive => true;
}
