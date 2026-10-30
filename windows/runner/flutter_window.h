#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <functional>
#include <memory>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject &project);
  virtual ~FlutterWindow();

  // Send a file path to Flutter via MethodChannel
  void SendFileToFlutter(const std::string &file_uri);

  // Called once, the first time this window actually becomes visible on
  // screen. Used to take the native splash down at the exact moment there is
  // something real to replace it - see SplashWindow.
  //
  // Hooked to WM_SHOWWINDOW rather than to the engine's next-frame callback on
  // purpose: having a frame is not the same as being on screen here. The Dart
  // side restores the stored window geometry and only then calls
  // windowManager.show(), which lands ~400ms after the first frame. Closing
  // the splash on the frame instead would uncover the desktop for that gap.
  void set_on_window_shown(std::function<void()> callback) {
    on_window_shown_ = std::move(callback);
  }

protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // Method channel for file handler communication.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      file_handler_channel_;

  // Setup the file handler method channel.
  void SetupFileHandlerChannel();

  // Fired once from MessageHandler; see set_on_window_shown.
  std::function<void()> on_window_shown_;
  bool window_shown_ = false;
};

#endif // RUNNER_FLUTTER_WINDOW_H_
