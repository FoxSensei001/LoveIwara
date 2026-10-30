#ifndef RUNNER_WINDOW_GEOMETRY_H_
#define RUNNER_WINDOW_GEOMETRY_H_

#include <optional>

// The window rectangle the app was last left at, in logical (96 dpi) pixels -
// the same units window_manager's setSize/setPosition take on the Dart side.
struct StoredWindowGeometry {
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
};

// Reads the geometry mirror the Dart side writes next to the app's data (see
// DesktopWindowListener in lib/main.dart).
//
// # Why a plain file instead of the config database
//
// The geometry already lives in the app's sqlite config, but it is needed
// *before* the Flutter engine exists, and opening sqlite and knowing its
// schema from the runner would couple the two far too tightly for one
// rectangle. The mirror is four numbers of plain text, written whenever the
// window settles.
//
// # Why the runner needs it at all
//
// Applying the geometry from Dart costs ~220ms of white screen: by then the
// Flutter view exists, and resizing the window makes the engine tear down and
// rebuild its render surface. Creating the window at the right size in the
// first place costs nothing, because there is no surface yet.
//
// Returns nullopt when the file is missing, unparseable, or describes a
// rectangle that is not plausible on this machine (too small, absurdly large,
// or entirely off every monitor). The caller then falls back to the default
// size, and the Dart side still runs its own screen-fitting pass, so a stale
// rectangle here can never strand the window off-screen.
std::optional<StoredWindowGeometry> ReadStoredWindowGeometry();

#endif // RUNNER_WINDOW_GEOMETRY_H_
