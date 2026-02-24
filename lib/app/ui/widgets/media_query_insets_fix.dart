import 'dart:math' as math;

import 'package:flutter/widgets.dart';

double computeBottomSafeInset(MediaQueryData mq) {
  return math.max(
    mq.padding.bottom,
    math.max(mq.viewPadding.bottom, mq.systemGestureInsets.bottom),
  );
}

class RawMediaQueryDataScope extends InheritedWidget {
  final MediaQueryData rawData;

  const RawMediaQueryDataScope({
    super.key,
    required this.rawData,
    required super.child,
  });

  static RawMediaQueryDataScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RawMediaQueryDataScope>();
  }

  @override
  bool updateShouldNotify(RawMediaQueryDataScope oldWidget) {
    return rawData != oldWidget.rawData;
  }
}

/// Fixes `MediaQuery.padding.bottom` in edge-to-edge environments where it may be
/// `0`, while `systemGestureInsets.bottom` is non-zero.
///
/// This helps `SafeArea(bottom: true)` and existing `MediaQuery.padding.bottom`
/// call sites behave as expected without rewriting every usage site.
class ApplyFixedMediaQueryInsets extends StatelessWidget {
  final Widget child;

  const ApplyFixedMediaQueryInsets({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final rawMq = MediaQuery.of(context);
    final fixedBottom = computeBottomSafeInset(rawMq);
    final fixedMq = rawMq.copyWith(
      padding: rawMq.padding.copyWith(bottom: fixedBottom),
    );

    return RawMediaQueryDataScope(
      rawData: rawMq,
      child: MediaQuery(data: fixedMq, child: child),
    );
  }
}

/// Restores the raw (unfixed) `MediaQueryData` captured by
/// [ApplyFixedMediaQueryInsets].
///
/// Intended for immersive/fullscreen pages that want to keep the previous
/// behavior (e.g. allow bottom overlays to reach the very bottom).
class RestoreRawMediaQueryInsets extends StatelessWidget {
  final Widget child;

  const RestoreRawMediaQueryInsets({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final rawScope = RawMediaQueryDataScope.maybeOf(context);
    if (rawScope == null) return child;
    return MediaQuery(data: rawScope.rawData, child: child);
  }
}
