import 'dart:math' as math;

import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class FullscreenInnerPlaylistDrawer extends StatefulWidget {
  final List<InnerPlaylistItemSnapshot> items;
  final bool isExpanded;
  final bool showHint;
  final bool isBusy;
  final String? loadingItemId;
  final ValueChanged<InnerPlaylistItemSnapshot> onSelectItem;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final VoidCallback onDismiss;
  final double toolbarVisibility;
  final bool showResumePositionTip;

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
    this.toolbarVisibility = 1.0,
    this.showResumePositionTip = false,
  });

  @override
  State<FullscreenInnerPlaylistDrawer> createState() =>
      _FullscreenInnerPlaylistDrawerState();
}

class _FullscreenInnerPlaylistDrawerState
    extends State<FullscreenInnerPlaylistDrawer> {
  static const double _openTriggerDistance = 84.0;
  static const double _expandDecisionThreshold = 0.42;

  double _hintDragProgress = 0.0;
  bool _isHintDragActive = false;

  @override
  void didUpdateWidget(covariant FullscreenInnerPlaylistDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _hintDragProgress = 0.0;
    }
  }

  void _handleHintDragUpdate(DragUpdateDetails details) {
    final primaryDelta = details.primaryDelta ?? 0.0;
    final nextProgress =
        (_hintDragProgress + (-primaryDelta / _openTriggerDistance)).clamp(
          0.0,
          1.0,
        );
    if (nextProgress != _hintDragProgress) {
      setState(() {
        _hintDragProgress = nextProgress;
      });
    }
  }

  void _handleHintDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldExpand =
        _hintDragProgress >= _expandDecisionThreshold || velocity < -700;

    setState(() {
      _isHintDragActive = false;
      _hintDragProgress = shouldExpand ? 1.0 : 0.0;
    });

    if (shouldExpand) {
      widget.onExpand();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isBusy) {
      return const SizedBox.shrink();
    }

    const drawerDuration = Duration(milliseconds: 320);
    const drawerCurve = Curves.easeOutCubic;
    const hintHeight = 136.0;
    const hintWidth = 64.0;
    const topToolbarHeight = 60.0;
    const bottomQuickActionsHeight = 40.0;
    const bottomToolbarHeight = 68.0;
    const resumeTipHeight = 34.0;
    const verticalMargin = 16.0;
    const panelHorizontalMargin = 12.0;

    final mediaQuery = MediaQuery.of(context);
    final mediaPadding = mediaQuery.padding;
    final safeBottomInset = computeBottomSafeInset(mediaQuery);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final baseToolbarVisibility = widget.toolbarVisibility.clamp(0.0, 1.0);
        final safeContentWidth = math.max(
          0.0,
          size.width -
              mediaPadding.left -
              mediaPadding.right -
              panelHorizontalMargin * 2,
        );
        final drawerWidth = math.min(760.0, safeContentWidth);
        final safeContentRight = mediaPadding.right + panelHorizontalMargin;
        final targetPanelProgress = widget.isExpanded ? 1.0 : _hintDragProgress;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: targetPanelProgress),
          duration: _isHintDragActive ? Duration.zero : drawerDuration,
          curve: drawerCurve,
          builder: (context, animatedPanelProgress, _) {
            // As the drawer opens, we should progressively stop reserving space
            // for the player's toolbars so short screens still have room.
            final visibleToolbarFactor =
                baseToolbarVisibility * (1 - animatedPanelProgress);
            final bottomControlsHeight =
                (bottomQuickActionsHeight +
                    bottomToolbarHeight +
                    (widget.showResumePositionTip ? resumeTipHeight : 0.0)) *
                visibleToolbarFactor;
            final topReservedHeight =
                verticalMargin + topToolbarHeight * visibleToolbarFactor;
            final collapsedBottomAnchor =
                safeBottomInset + verticalMargin + bottomControlsHeight;
            final availableHeight = math.max(
              0.0,
              size.height - topReservedHeight - collapsedBottomAnchor,
            );
            final scaledHintHeight = math.min(hintHeight, availableHeight);

            // The popup should end up with the same height as the entry (hint).
            final scaledDrawerHeight = scaledHintHeight;
            final hintScale = hintHeight == 0
                ? 1.0
                : scaledHintHeight / hintHeight;
            final drawerListHeight = math.max(0.0, scaledDrawerHeight);
            final cardHeight = drawerListHeight;
            final cardWidth = (cardHeight * (220 / 160)).clamp(120.0, 228.0);
            final hintTopRange = math.max(
              0.0,
              availableHeight - scaledHintHeight,
            );
            final hintTop = topReservedHeight + hintTopRange * 0.62;
            final hintVisible =
                widget.showHint &&
                !widget.isExpanded &&
                widget.items.isNotEmpty &&
                hintScale > 0.0;
            final hintOpacity =
                ((1 - animatedPanelProgress) * (hintVisible ? 1.0 : 0.0)).clamp(
                  0.0,
                  1.0,
                );

            // Start fully off-screen on the right, then slide in to dock right.
            final hiddenPanelOffsetX = drawerWidth + safeContentRight + 24.0;
            final panelOffsetX =
                hiddenPanelOffsetX * (1 - animatedPanelProgress);
            final panelVisible =
                (widget.isExpanded || animatedPanelProgress > 0.0) &&
                drawerWidth > 0 &&
                scaledDrawerHeight > 0;

            final panelScale = 0.94 + 0.06 * animatedPanelProgress;
            final hintSlideX = hintOpacity > 0
                ? -hintWidth * 0.12 * animatedPanelProgress
                : hintWidth * 0.18;

            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: animatedPanelProgress <= 0,
                    child: Opacity(
                      opacity: animatedPanelProgress,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onDismiss,
                        onHorizontalDragUpdate: (details) {
                          if ((details.primaryDelta ?? 0) > 8) {
                            widget.onDismiss();
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
                if (widget.items.isNotEmpty)
                  Positioned(
                    right: mediaPadding.right,
                    top: hintTop,
                    child: IgnorePointer(
                      ignoring: hintOpacity <= 0,
                      child: Transform.translate(
                        offset: Offset(hintSlideX, 0),
                        child: Opacity(
                          opacity: hintOpacity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onExpand,
                            onHorizontalDragStart: (_) {
                              setState(() {
                                _isHintDragActive = true;
                              });
                            },
                            onHorizontalDragUpdate: _handleHintDragUpdate,
                            onHorizontalDragEnd: _handleHintDragEnd,
                            onHorizontalDragCancel: () {
                              setState(() {
                                _isHintDragActive = false;
                                _hintDragProgress = 0.0;
                              });
                            },
                            child: SizedBox(
                              key: const Key(
                                'fullscreen_inner_playlist_hint_box',
                              ),
                              width: hintWidth * hintScale,
                              height: scaledHintHeight,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: hintWidth,
                                  height: hintHeight,
                                  child: _DrawerHint(item: widget.items.first),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (panelVisible)
                  Positioned(
                    top: hintTop,
                    right: safeContentRight,
                    child: IgnorePointer(
                      ignoring: !widget.isExpanded,
                      child: Transform.translate(
                        offset: Offset(panelOffsetX, 0),
                        child: Opacity(
                          opacity: animatedPanelProgress.clamp(0.0, 1.0),
                          child: Transform.scale(
                            alignment: Alignment.centerRight,
                            scale: panelScale,
                            child: SizedBox(
                              key: const Key(
                                'fullscreen_inner_playlist_drawer_box',
                              ),
                              width: drawerWidth,
                              height: scaledDrawerHeight,
                              child: _DrawerSurface(
                                items: widget.items,
                                width: drawerWidth,
                                height: scaledDrawerHeight,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                onSelectItem: widget.isBusy
                                    ? null
                                    : widget.onSelectItem,
                                onCollapse: widget.onCollapse,
                                loadingItemId: widget.loadingItemId,
                              ),
                            ),
                          ),
                        ),
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
  final double cardWidth;
  final double cardHeight;
  final ValueChanged<InnerPlaylistItemSnapshot>? onSelectItem;
  final VoidCallback onCollapse;
  final String? loadingItemId;

  const _DrawerSurface({
    required this.items,
    required this.width,
    required this.height,
    required this.cardWidth,
    required this.cardHeight,
    required this.onSelectItem,
    required this.onCollapse,
    required this.loadingItemId,
  });

  @override
  State<_DrawerSurface> createState() => _DrawerSurfaceState();
}

class _DrawerSurfaceState extends State<_DrawerSurface> {
  final ScrollController _scrollController = ScrollController();
  static const double _closeTriggerDistance = 96.0;
  static const double _verticalCloseTriggerDistance = 120.0;
  static const double _closeDecisionThreshold = 0.42;

  Offset? _dragStartPosition;
  Offset? _lastPointerPosition;
  bool _edgeCloseActive = false;
  double _edgeCloseProgress = 0.0;
  bool _verticalCloseActive = false;
  double _verticalCloseProgress = 0.0;
  bool _dragStartedAtLeftEdge = false;

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

  bool get _canStartEdgeClose {
    if (!_scrollController.hasClients) {
      return false;
    }
    return _scrollController.position.pixels <= 0.5;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _dragStartPosition = event.position;
    _lastPointerPosition = event.position;
    _dragStartedAtLeftEdge = _canStartEdgeClose;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final dragStart = _dragStartPosition;
    final lastPointer = _lastPointerPosition;
    _lastPointerPosition = event.position;

    if (dragStart == null || lastPointer == null) {
      return;
    }

    final totalDelta = event.position - dragStart;
    if (!_edgeCloseActive && !_verticalCloseActive) {
      final isHorizontalCloseIntent =
          totalDelta.dx > 8 && totalDelta.dx.abs() > totalDelta.dy.abs();
      final isVerticalCloseIntent =
          totalDelta.dy > 8 && totalDelta.dy.abs() > totalDelta.dx.abs();

      if (isVerticalCloseIntent) {
        _verticalCloseActive = true;
      } else if (isHorizontalCloseIntent && _dragStartedAtLeftEdge) {
        _edgeCloseActive = true;
      } else {
        return;
      }
    }

    if (_edgeCloseActive) {
      final deltaX = event.position.dx - lastPointer.dx;
      final nextProgress =
          (_edgeCloseProgress + (deltaX / _closeTriggerDistance)).clamp(
            0.0,
            1.0,
          );
      if (nextProgress != _edgeCloseProgress) {
        setState(() {
          _edgeCloseProgress = nextProgress;
        });
      }
      return;
    }

    if (_verticalCloseActive) {
      final deltaY = event.position.dy - lastPointer.dy;
      final nextProgress =
          (_verticalCloseProgress + (deltaY / _verticalCloseTriggerDistance))
              .clamp(0.0, 1.0);
      if (nextProgress != _verticalCloseProgress) {
        setState(() {
          _verticalCloseProgress = nextProgress;
        });
      }
    }
  }

  void _finishEdgeCloseDrag() {
    if (!_edgeCloseActive &&
        !_verticalCloseActive &&
        _edgeCloseProgress == 0.0 &&
        _verticalCloseProgress == 0.0) {
      _dragStartPosition = null;
      _lastPointerPosition = null;
      _dragStartedAtLeftEdge = false;
      return;
    }

    final shouldClose =
        _edgeCloseProgress >= _closeDecisionThreshold ||
        _verticalCloseProgress >= _closeDecisionThreshold;
    setState(() {
      _edgeCloseActive = false;
      _verticalCloseActive = false;
      _edgeCloseProgress = shouldClose ? 1.0 : 0.0;
      _verticalCloseProgress = shouldClose ? 1.0 : 0.0;
      _dragStartPosition = null;
      _lastPointerPosition = null;
      _dragStartedAtLeftEdge = false;
    });

    if (shouldClose) {
      widget.onCollapse();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const surfaceRadius = BorderRadius.all(Radius.circular(20));
    final animatedCloseOffset = _edgeCloseProgress * widget.width * 0.42;
    final animatedCloseOffsetY = _verticalCloseProgress * widget.height * 0.86;
    final combinedCloseProgress = math.max(
      _edgeCloseProgress,
      _verticalCloseProgress,
    );
    final surfaceOpacity = (1 - combinedCloseProgress * 0.22).clamp(0.0, 1.0);

    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: Offset.zero,
        end: Offset(animatedCloseOffset, animatedCloseOffsetY),
      ),
      duration: _edgeCloseActive || _verticalCloseActive
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, closeOffset, child) {
        return Transform.translate(
          offset: closeOffset,
          child: AnimatedOpacity(
            duration: _edgeCloseActive || _verticalCloseActive
                ? Duration.zero
                : const Duration(milliseconds: 180),
            opacity: surfaceOpacity,
            child: child,
          ),
        );
      },
      // Transparent container with zero padding; only cards are visible.
      child: ClipRRect(
        borderRadius: surfaceRadius,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: _handlePointerSignal,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: (_) => _finishEdgeCloseDrag(),
            onPointerCancel: (_) => _finishEdgeCloseDrag(),
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: _DrawerCard(
                    item: widget.items[index],
                    width: widget.cardWidth,
                    height: widget.cardHeight,
                    isLoading: widget.loadingItemId == widget.items[index].id,
                    onTap: widget.onSelectItem == null
                        ? null
                        : () => widget.onSelectItem!(widget.items[index]),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: widget.items.length,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerCard extends StatelessWidget {
  final InnerPlaylistItemSnapshot item;
  final double width;
  final double height;
  final bool isLoading;
  final VoidCallback? onTap;

  const _DrawerCard({
    required this.item,
    required this.width,
    required this.height,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = height < 144 ? 11.5 : 12.5;
    final topGradientHeight = (height * 0.28).clamp(34.0, 52.0);
    final bottomGradientHeight = (height * 0.38).clamp(44.0, 62.0);

    return SizedBox(
      width: width,
      height: height,
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
                    height: topGradientHeight,
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
                    height: bottomGradientHeight,
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
                    left: 8,
                    top: 8,
                    right: 8,
                    child: Text(
                      item.title.isEmpty ? slang.t.common.noTitle : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
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
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: iconColor ?? Colors.white70),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.8,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 88),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
