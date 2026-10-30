#ifndef RUNNER_SPLASH_WINDOW_H_
#define RUNNER_SPLASH_WINDOW_H_

#include <windows.h>

#include <atomic>
#include <thread>

// A small native splash shown while the Flutter engine comes up.
//
// # Why this exists
//
// Measured on this app's release build: nothing is on screen for ~2.4s after
// the user double-clicks the icon. The window is only shown once Flutter has
// a frame (see FlutterWindow::OnCreate and the Dart side's
// windowManager.show()), and ~1.5s of that wait is Impeller's GLES backend
// compiling its 93 default pipelines through ANGLE -> HLSL -> D3D. That cost
// is inside the engine and there is no switch for it (see the note in
// main.cpp), so the only thing left is to stop the wait from looking like a
// hang.
//
// # Why it needs its own thread
//
// The platform thread is blocked inside the FlutterViewController constructor
// for that entire ~1.5s: FlutterEngineRun waits on Shell::Create, which waits
// on the raster thread. A splash created on the platform thread would never
// pump a message, so it could not paint - and after a few seconds Windows
// would mark it unresponsive and ghost it. So this owns a thread with its own
// window and message loop, which keeps painting (and animating, which is what
// proves to the user that the app is not dead) while the engine starts.
//
// # Lifetime
//
// Show() returns as soon as the thread is running; it does not wait for the
// window. Close() is idempotent and is safe to call from another thread - it
// posts WM_CLOSE and joins. The thread also closes itself after a safety
// timeout so a hung startup can never leave a topmost window stuck on screen.
class SplashWindow {
public:
  SplashWindow();
  ~SplashWindow();

  SplashWindow(const SplashWindow &) = delete;
  SplashWindow &operator=(const SplashWindow &) = delete;

  // Starts the splash thread. Does nothing if already started.
  void Show();

  // Tears the splash down and waits for its thread. Idempotent.
  void Close();

private:
  void ThreadMain();

  std::thread thread_;
  // Written by the splash thread, read by whoever calls Close().
  std::atomic<HWND> window_{nullptr};
  std::atomic<bool> started_{false};
};

#endif // RUNNER_SPLASH_WINDOW_H_
