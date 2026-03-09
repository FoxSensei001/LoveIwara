import 'package:flutter/widgets.dart';

class VideoFullscreenHandoff {
  final bool nativeFullscreenActive;
  final Size? desktopWindowSizeBeforeFullscreen;
  final Offset? desktopWindowPositionBeforeFullscreen;
  final bool desktopWindowWasMaximized;
  final bool hasDesktopWindowGeometrySnapshot;

  const VideoFullscreenHandoff({
    this.nativeFullscreenActive = true,
    this.desktopWindowSizeBeforeFullscreen,
    this.desktopWindowPositionBeforeFullscreen,
    this.desktopWindowWasMaximized = false,
    this.hasDesktopWindowGeometrySnapshot = false,
  });
}
