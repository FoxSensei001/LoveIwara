import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/pages/play_list/widgets/playlist_item_widget.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ProfilePlaylistTabListWidget extends StatefulWidget {
  final String userId;
  final String tabKey;
  final TabController tc;

  /// 上方被页面级 header 占掉的高度（列表用它让出首屏，滚动时从背后经过）。
  final double overlayTopInset;

  /// 顶部蒙层平台段（状态栏）高度。
  final double scrimSolidExtent;
  final Function({int? count})? onFetchFinished;
  final bool isPaginated;
  final VoidCallback? onPaginationToggle;
  final VoidCallback? onPageChanged;

  const ProfilePlaylistTabListWidget({
    super.key,
    required this.userId,
    required this.tabKey,
    required this.tc,
    this.onFetchFinished,
    this.isPaginated = false,
    this.onPaginationToggle,
    this.onPageChanged,
    this.overlayTopInset = 0,
    this.scrimSolidExtent = 0,
  });

  @override
  State<ProfilePlaylistTabListWidget> createState() =>
      _ProfilePlaylistTabListWidgetState();
}

class _ProfilePlaylistTabListWidgetState
    extends State<ProfilePlaylistTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late PlayListRepository listSourceRepository;
  final ScrollController _fallbackController = ScrollController();
  final ValueNotifier<bool> _showBackToTop = ValueNotifier(false);
  final ValueNotifier<int> _refreshSignal = ValueNotifier(0);

  // 四个 tab 里原本只有播放列表这一个没有保活：TabBarView 未开
  // allowImplicitScrolling，非当前页在切换动画结束后即被 unmount，
  // 导致每次切回来都从第 0 页重新拉数据、滚动位置也回到顶部。
  // 其余三个 tab（video / image / post）都已 wantKeepAlive => true。
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    listSourceRepository = PlayListRepository(userId: widget.userId);
  }

  @override
  void dispose() {
    _fallbackController.dispose();
    _showBackToTop.dispose();
    _refreshSignal.dispose();
    listSourceRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 要求
    final t = slang.Translations.of(context);
    final inheritPrimary = PrimaryScrollController.shouldInherit(
      context,
      Axis.vertical,
    );
    final primaryController = inheritPrimary
        ? PrimaryScrollController.maybeOf(context)
        : null;
    final scrollTarget = primaryController ?? _fallbackController;
    const headerHeight = GlassTokens.pillHeight + 12;
    final headerExtent = widget.overlayTopInset + headerHeight;

    return GlassHeaderOverlay(
      headerExtent: headerExtent,
      headerTop: widget.overlayTopInset,
      headerHeight: headerHeight,
      solidExtent: widget.scrimSolidExtent,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            _showBackToTop.value = notification.metrics.pixels >= 300;
          }
          return false;
        },
        child: MediaListView(
          sourceList: listSourceRepository,
          isPaginated: widget.isPaginated,
          refreshSignal: _refreshSignal,
          onPageChanged: widget.onPageChanged,
          scrollController: primaryController == null
              ? _fallbackController
              : null,
          paddingTop: headerExtent,
          emptyIcon: Icons.playlist_play,
          itemBuilder: (context, item, index) =>
              PlaylistItemWidget(playlist: item),
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
              GlassIconButton(
                icon: const Icon(Icons.refresh),
                tooltip: t.common.refresh,
                onPressed: () => _refreshSignal.value++,
              ),
            ],
          ),
        ),
      ),
      extra: [
        Positioned(
          right: 16,
          bottom:
              16 +
              computeBottomSafeInset(MediaQuery.of(context)) +
              (widget.isPaginated ? 46 : 0),
          child: ValueListenableBuilder<bool>(
            valueListenable: _showBackToTop,
            builder: (context, visible, _) => IgnorePointer(
              ignoring: !visible,
              child: AnimatedOpacity(
                duration: GlassTokens.motionDuration,
                opacity: visible ? 1 : 0,
                child: GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.vertical_align_top),
                  tooltip: t.common.scrollToTop,
                  onPressed: () {
                    if (!scrollTarget.hasClients) return;
                    scrollTarget.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
