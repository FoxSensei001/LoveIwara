#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <algorithm>
#include <cmath>
#include <optional>
#include <sstream>
#include <string>
#include <thread>

#include "flutter_window.h"
#include "splash_window.h"
#include "utils.h"
#include "window_geometry.h"

// Helper function to check if a file is a video file
bool IsVideoFile(const std::wstring &file_path) {
  const std::wstring video_extensions[] = {L".mp4", L".mkv", L".avi",  L".mov",
                                           L".wmv", L".flv", L".webm", L".m4v",
                                           L".3gp", L".ts"};

  std::wstring lower_path = file_path;
  std::transform(lower_path.begin(), lower_path.end(), lower_path.begin(),
                 ::towlower);

  for (const auto &ext : video_extensions) {
    if (lower_path.size() >= ext.size() &&
        lower_path.compare(lower_path.size() - ext.size(), ext.size(), ext) ==
            0) {
      return true;
    }
  }
  return false;
}

// Helper function to convert wstring to UTF-8 string
std::string WStringToUtf8(const std::wstring &wstr) {
  if (wstr.empty())
    return std::string();
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(),
                                        NULL, 0, NULL, NULL);
  std::string str(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &str[0],
                      size_needed, NULL, NULL);
  return str;
}

// Milliseconds elapsed since this process was created, or -1 if unavailable.
//
// Used to split the startup cost that Dart cannot see. By the time wWinMain
// runs, the loader has already mapped every statically imported DLL - and this
// app imports a plugin DLL per plugin, which in turn pulls in libmpv-2.dll
// (~30 MB). That work happens before a single line of Dart runs, so without a
// reading from here the Dart-side timeline just reports a large opaque
// "pre-main" and we cannot tell DLL loading apart from engine startup.
static double MsSinceProcessStart() {
  FILETIME creation, exit, kernel, user;
  if (!::GetProcessTimes(::GetCurrentProcess(), &creation, &exit, &kernel,
                         &user)) {
    return -1;
  }
  ULARGE_INTEGER started;
  started.LowPart = creation.dwLowDateTime;
  started.HighPart = creation.dwHighDateTime;

  FILETIME now_ft;
  ::GetSystemTimeAsFileTime(&now_ft);
  ULARGE_INTEGER now;
  now.LowPart = now_ft.dwLowDateTime;
  now.HighPart = now_ft.dwHighDateTime;

  if (now.QuadPart < started.QuadPart) {
    return -1;
  }
  // FILETIME counts 100-nanosecond intervals.
  return static_cast<double>(now.QuadPart - started.QuadPart) / 10000.0;
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // First statement on purpose: everything before this point is loader work
  // (mapping the exe and every statically imported DLL) plus CRT startup.
  const double entry_ms = MsSinceProcessStart();

  // Up first, before anything that can block: the engine takes ~2s to reach a
  // visible window on this app (see the Impeller note below) and until now
  // that was ~2s of no feedback at all. The splash owns its own thread
  // precisely because the platform thread is about to be blocked.
  SplashWindow splash;
  splash.Show();

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  // WARNING - startup cost note, measured here. Do NOT "fix" this by disabling
  // Impeller. Impeller stays on: the VR equirectangular shader needs it
  // (ui.ImageFilter.isShaderFilterSupported, see VrPanoramaShader).
  //
  // On Windows, Impeller's GLES backend costs ~1.2s before Dart main() even
  // starts. It is engine-side and there is no app-level switch for it:
  // ContentContext's constructor eagerly creates 93 default pipelines, each
  // one a GLES program link, which on Windows means ANGLE translating GLSL to
  // HLSL and D3D compiling it (~13ms each). That runs on the raster thread
  // inside Shell::Create, which blocks FlutterEngineRun, which blocks Dart
  // main(), which blocks the first frame - and the window is only shown once
  // the first frame rasterizes. Measured with Impeller off: ~320ms instead of
  // ~1550ms, on a bare `flutter create` app as well as on this one.
  //
  // Things that were tried and did NOT help: --impeller-lazy-shader-mode (not
  // wired up for the GLES backend), --impeller-use-sdfs=false, and all three
  // GpuPreference values (low power saves ~250ms, no more). The Windows
  // embedder has no Vulkan backend at all, so --impeller-backend is a no-op.
  //
  // What is left to us is making the dead time visible (a native splash before
  // the first frame) and not adding to it - see the window geometry notes in
  // lib/main.dart's _initializeDesktop.

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();

  // Hand the loader cost to Dart through the entrypoint arguments. These are
  // NOT the process command line (app_links and the video-file handling below
  // read that separately via GetCommandLineW), so this extra entry cannot be
  // mistaken for something the user passed.
  if (entry_ms >= 0) {
    command_line_arguments.push_back(
        "--startup-entry-ms=" + std::to_string(static_cast<long long>(
                                    entry_ms * 1000.0)) /* microseconds */);
  }

  // Create the window at the size and position the app was last left at, so
  // the Dart side does not have to resize it afterwards. Doing it there costs
  // ~220ms of white screen, because by then the Flutter view exists and a
  // resize rebuilds its render surface; here there is no surface yet.
  //
  // These defaults are the ones the Dart side would otherwise apply itself on
  // a first run (see _initializeDesktop), NOT the 1280x720 the Flutter
  // template ships - matching them is what lets Dart skip the call entirely.
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(800, 600);
  const std::optional<StoredWindowGeometry> stored = ReadStoredWindowGeometry();
  if (stored.has_value()) {
    // Round rather than truncate: these are logical pixels that get scaled by
    // the monitor dpi and read back next launch, and under a fractional
    // display scale truncating made the value drift by a fraction of a pixel
    // per round trip - enough to keep missing the Dart side's "already
    // applied" check and pay for the resize on every launch.
    auto to_pixels = [](double value) {
      return static_cast<unsigned int>(value < 0 ? 0 : std::lround(value));
    };
    origin = Win32Window::Point(to_pixels(stored->x), to_pixels(stored->y));
    size = Win32Window::Size(to_pixels(stored->width),
                             to_pixels(stored->height));
  }

  // Tell Dart exactly what was applied, so it can compare against the
  // rectangle its own screen-fitting pass arrives at and only call
  // setSize/setPosition when they would actually change something.
  {
    std::ostringstream applied;
    applied << "--startup-window-geometry=" << origin.x << "," << origin.y
            << "," << size.width << "," << size.height;
    command_line_arguments.push_back(applied.str());
  }

  // Second reading, taken as late as the entrypoint arguments can still be
  // set: everything after this line is FlutterViewController construction,
  // which is what actually boots the Dart VM and runs main(). Splitting here
  // separates "the engine is slow to come up" from "something before the
  // engine is slow" (console attach, COM init, command line parsing).
  const double pre_engine_ms = MsSinceProcessStart();
  if (pre_engine_ms >= 0) {
    command_line_arguments.push_back(
        "--startup-preengine-ms=" +
        std::to_string(static_cast<long long>(pre_engine_ms * 1000.0)));
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  // Hand the splash over before Create(): Create() is what blocks on engine
  // startup, and the callback it installs can fire inside that call.
  window.set_on_window_shown([&splash]() { splash.Close(); });
  if (!window.Create(L"i_iwara", origin, size)) {
    // The splash is RAII-closed on the way out, but be explicit: a failed
    // launch must not leave a topmost window behind.
    splash.Close();
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  // Check if a file was passed as a command-line argument
  int argc;
  LPWSTR *argv = CommandLineToArgvW(GetCommandLineW(), &argc);
  std::wstring file_path_to_open;

  if (argv != nullptr) {
    // Skip the first argument (executable path)
    for (int i = 1; i < argc; i++) {
      std::wstring arg(argv[i]);
      // Check if this argument is a file path (not a flag)
      if (!arg.empty() && arg[0] != L'-' && arg[0] != L'/') {
        // Check if it's a video file
        if (IsVideoFile(arg)) {
          file_path_to_open = arg;
          OutputDebugStringW(
              (L"Found video file in command line: " + arg + L"\n").c_str());
          break;
        }
      }
    }
    LocalFree(argv);
  }

  // If a video file was found, send it to Flutter after a short delay
  if (!file_path_to_open.empty()) {
    // Convert to file:// URI format
    std::wstring file_uri = L"file:///" + file_path_to_open;
    // Replace backslashes with forward slashes
    std::replace(file_uri.begin(), file_uri.end(), L'\\', L'/');

    std::string file_uri_utf8 = WStringToUtf8(file_uri);
    OutputDebugStringA(
        ("Sending file URI to Flutter: " + file_uri_utf8 + "\n").c_str());

    // Create a thread to send the file path after a delay
    // This ensures Flutter is fully initialized before we send the file
    std::thread([&window, file_uri_utf8]() {
      Sleep(1500); // Wait 1.5 seconds for Flutter to initialize
      window.SendFileToFlutter(file_uri_utf8);
    }).detach();
  }

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Message loop has ended (Dart side already ran its cleanup and called
  // windowManager.destroy(), i.e. PostQuitMessage). What follows - engine and
  // plugin teardown when |window| goes out of scope - has no time limit:
  // media_kit_video waits for the raster thread and its render thread pool, and
  // can even block forever. Put an upper bound on it. TerminateProcess skips
  // DLL_PROCESS_DETACH, so it does not bring back the "Unknown Hard Error" that
  // exit(0) caused (issue #107).
  std::thread([]() {
    ::Sleep(3000);
    OutputDebugStringW(L"Native teardown exceeded 3s, terminating process\n");
    ::TerminateProcess(::GetCurrentProcess(), EXIT_SUCCESS);
  }).detach();

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
