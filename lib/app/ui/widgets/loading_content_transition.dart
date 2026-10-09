import 'package:flutter/material.dart';

/// Dissolves a finished placeholder without keeping two live content trees.
/// Cached content, refreshes with visible data and load-more do not animate.
class LoadingContentTransition extends StatefulWidget {
  const LoadingContentTransition({
    super.key,
    required this.isLoading,
    required this.child,
    this.retainLoading = true,
  });

  final bool isLoading;
  final Widget child;

  /// Disable for placeholders sharing a ScrollController or GlobalKey with
  /// content. These use a short content fade instead of retaining the loader.
  final bool retainLoading;

  static const duration = Duration(milliseconds: 180);

  @override
  State<LoadingContentTransition> createState() =>
      _LoadingContentTransitionState();
}

class _LoadingContentTransitionState extends State<LoadingContentTransition>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: LoadingContentTransition.duration,
    value: 1,
  );
  late final _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Widget? _placeholder;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _placeholder != null) {
        setState(() => _placeholder = null);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.maybeOf(context);
    _reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);
    if (_reduceMotion) {
      _placeholder = null;
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(LoadingContentTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _placeholder = null;
      _controller.value = 1;
    } else if (oldWidget.isLoading && !_reduceMotion) {
      _placeholder = widget.retainLoading ? oldWidget.child : null;
      _controller.forward(from: 0);
    }
    if (!widget.retainLoading) _placeholder = null;
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The active slot never moves or changes wrapper type. Removing the
    // overlay must not remount content or reset its scroll/tab/player state.
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        FadeTransition(
          opacity: widget.retainLoading ? kAlwaysCompleteAnimation : _progress,
          child: widget.child,
        ),
        if (_placeholder != null)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeFocus(
                child: ExcludeSemantics(
                  child: HeroMode(
                    enabled: false,
                    child: TickerMode(
                      enabled: false,
                      child: PrimaryScrollController.none(
                        child: FadeTransition(
                          opacity: ReverseAnimation(_progress),
                          child: _placeholder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
