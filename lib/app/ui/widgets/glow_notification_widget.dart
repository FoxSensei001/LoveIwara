import 'package:flutter/material.dart';

class GlowNotificationWidget extends StatelessWidget {
  final Widget child;
  final bool showGlowLeading;

  const GlowNotificationWidget({
    super.key,
    required this.child,
    this.showGlowLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: child,
    );
  }
} 