import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class FullscreenInnerPlaylistDrawer extends StatelessWidget {
  final List<InnerPlaylistItemSnapshot> items;
  final bool isExpanded;
  final bool showHint;
  final bool isBusy;
  final String? loadingItemId;
  final ValueChanged<InnerPlaylistItemSnapshot> onSelectItem;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final VoidCallback onDismiss;

  const FullscreenInnerPlaylistDrawer({
    super.key,
    required this.items,
    required this.isExpanded,
    required this.showHint,
    required this.isBusy,
    required this.loadingItemId,
    required this.onSelectItem,
    required this.onExpand,
    required this.onCollapse,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isBusy) {
      return const SizedBox.shrink();
    }

    const hintDuration = Duration(milliseconds: 220);
    const hintCurve = Curves.easeOutCubic;
    const drawerDuration = Duration(milliseconds: 320);
    const drawerCurve = Curves.easeOutCubic;

    final mediaPadding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final drawerWidth = (size.width * 0.72).clamp(280.0, 460.0);
    const drawerHeight = 176.0;
    final horizontalPadding = mediaPadding.right + 12.0;
    final defaultHintTop = (size.height * 0.62).clamp(
      mediaPadding.top + 48.0,
      size.height - mediaPadding.bottom - 136.0 - 24.0,
    );
    final hintTop = defaultHintTop;
    final drawerTop = (hintTop - (drawerHeight - 136.0) / 2).clamp(
      mediaPadding.top + 20.0,
      size.height - mediaPadding.bottom - drawerHeight - 20.0,
    );
    final hintVisible = showHint && !isExpanded && items.isNotEmpty;
    final hiddenDrawerRight = -drawerWidth - mediaPadding.right - 24.0;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isExpanded,
            child: AnimatedOpacity(
              duration: drawerDuration,
              curve: drawerCurve,
              opacity: isExpanded ? 1 : 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                onHorizontalDragUpdate: (details) {
                  if ((details.primaryDelta ?? 0) > 8) {
                    onDismiss();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (items.isNotEmpty)
          Positioned(
            right: 0,
            top: hintTop,
            child: IgnorePointer(
              ignoring: !hintVisible,
              child: AnimatedSlide(
                duration: hintDuration,
                curve: hintCurve,
                offset: hintVisible ? Offset.zero : const Offset(0.18, 0),
                child: AnimatedOpacity(
                  duration: hintDuration,
                  curve: hintCurve,
                  opacity: hintVisible ? 1 : 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onExpand,
                    onHorizontalDragUpdate: (details) {
                      if ((details.primaryDelta ?? 0) < -6) {
                        onExpand();
                      }
                    },
                    child: _DrawerHint(item: items.first),
                  ),
                ),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: drawerDuration,
          curve: drawerCurve,
          top: drawerTop,
          right: isExpanded ? horizontalPadding : hiddenDrawerRight,
          child: IgnorePointer(
            ignoring: !isExpanded,
            child: AnimatedOpacity(
              duration: drawerDuration,
              curve: drawerCurve,
              opacity: isExpanded ? 1 : 0,
              child: AnimatedScale(
                duration: drawerDuration,
                curve: drawerCurve,
                alignment: Alignment.centerRight,
                scale: isExpanded ? 1 : 0.96,
                child: _DrawerSurface(
                  items: items,
                  width: drawerWidth,
                  height: drawerHeight,
                  onSelectItem: isBusy ? null : onSelectItem,
                  onCollapse: onCollapse,
                  loadingItemId: loadingItemId,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerHint extends StatelessWidget {
  final InnerPlaylistItemSnapshot item;

  const _DrawerHint({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 136,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF232323)),
            ),
            errorWidget: (context, url, error) => const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF232323)),
              child: Center(
                child: Icon(
                  Icons.video_library_outlined,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.68),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 30,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSurface extends StatefulWidget {
  final List<InnerPlaylistItemSnapshot> items;
  final double width;
  final double height;
  final ValueChanged<InnerPlaylistItemSnapshot>? onSelectItem;
  final VoidCallback onCollapse;
  final String? loadingItemId;

  const _DrawerSurface({
    required this.items,
    required this.width,
    required this.height,
    required this.onSelectItem,
    required this.onCollapse,
    required this.loadingItemId,
  });

  @override
  State<_DrawerSurface> createState() => _DrawerSurfaceState();
}

class _DrawerSurfaceState extends State<_DrawerSurface> {
  final ScrollController _scrollController = ScrollController();

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) {
      return;
    }

    final scrollDelta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    if (scrollDelta.abs() < 1) {
      return;
    }

    final targetOffset = (_scrollController.offset + scrollDelta)
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();
    _scrollController.jumpTo(targetOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(26));

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerSignal: _handlePointerSignal,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 8, 74, 8),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: _DrawerCard(
                        item: widget.items[index],
                        isLoading:
                            widget.loadingItemId == widget.items[index].id,
                        onTap: widget.onSelectItem == null
                            ? null
                            : () => widget.onSelectItem!(widget.items[index]),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemCount: widget.items.length,
                ),
              ),
              Positioned(
                right: 10,
                top: 22,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onCollapse,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.56),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: const Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerCard extends StatelessWidget {
  final InnerPlaylistItemSnapshot item;
  final bool isLoading;
  final VoidCallback? onTap;

  const _DrawerCard({
    required this.item,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 160,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFF262626)),
                    ),
                    errorWidget: (context, url, error) => const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFF262626)),
                      child: Center(
                        child: Icon(
                          Icons.video_library_outlined,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.56),
                            Colors.black.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 72,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.14),
                            Colors.black.withValues(alpha: 0.62),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    right: 12,
                    child: Text(
                      item.title.isEmpty ? slang.t.common.noTitle : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _StatPill(
                              icon: Icons.visibility_outlined,
                              text: CommonUtils.formatFriendlyNumber(
                                item.numViews,
                              ),
                            ),
                            _StatPill(
                              icon: item.liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              text: CommonUtils.formatFriendlyNumber(
                                item.numLikes,
                              ),
                              iconColor: item.liked
                                  ? const Color(0xFFFF6B81)
                                  : Colors.white70,
                            ),
                          ],
                        ),
                        if (item.isPrivate || item.isExternalVideo)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (item.isPrivate)
                                  const _Badge(
                                    icon: Icons.lock_outline_rounded,
                                    label: 'Private',
                                  ),
                                if (item.isExternalVideo)
                                  _Badge(
                                    icon: Icons.link_rounded,
                                    label: item.externalVideoDomain.isEmpty
                                        ? slang.t.common.externalVideo
                                        : item.externalVideoDomain,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.46),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _StatPill({required this.icon, required this.text, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor ?? Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
