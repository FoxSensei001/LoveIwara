import 'package:flutter/widgets.dart';

/// A lightweight scope to tweak UI during a Hero flight.
///
/// Current use-case: hide the in-player overlay UI (toolbars/gestures/panels)
/// when popping a `video_cover:*` hero from the video detail page.
class HeroFlightScope extends InheritedWidget {
  final bool hidePlayerUi;

  const HeroFlightScope({
    super.key,
    required this.hidePlayerUi,
    required super.child,
  });

  static HeroFlightScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HeroFlightScope>();
  }

  static bool hidePlayerUiOf(BuildContext context) {
    return maybeOf(context)?.hidePlayerUi ?? false;
  }

  @override
  bool updateShouldNotify(HeroFlightScope oldWidget) {
    return hidePlayerUi != oldWidget.hidePlayerUi;
  }
}
