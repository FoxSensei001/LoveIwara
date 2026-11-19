#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {

// The Flutter view's own window procedure, saved when it is subclassed.
WNDPROC g_flutter_view_proc = nullptr;

// Whether an assistive technology that actually needs the semantics tree is
// running. SPI_GETSCREENREADER covers NVDA, JAWS and most others; Narrator
// does not set it and is recognised by the mutex it holds while running.
bool IsScreenReaderRunning() {
  BOOL enabled = FALSE;
  if (::SystemParametersInfoW(SPI_GETSCREENREADER, 0, &enabled, 0) &&
      enabled) {
    return true;
  }
  HANDLE narrator = ::OpenMutexW(SYNCHRONIZE, FALSE, L"NarratorRunning");
  if (narrator) {
    ::CloseHandle(narrator);
    return true;
  }
  return false;
}

// Keeps accessibility queries away from the engine unless a screen reader is
// running.
//
// The engine answers every WM_GETOBJECT by switching semantics on and handing
// out its MSAA tree, and any process may ask - input methods, overlays,
// automation tools - not only screen readers. Once a client holds that tree it
// re-enumerates it whenever the window changes, and the engine can then crash
// the whole process: AXPlatformNodeWin::get_accChild trusts a cached child
// count, and FlutterPlatformNodeDelegate::ChildAtIndex dereferences the null it
// gets for an index that is no longer there. Entering fullscreen (a style
// change plus a resize while the page rebuilds) is where that was hit.
//
// Declining the query leaves such clients with the plain window object, which
// is all they need, and keeps the semantics tree from being built at all.
LRESULT CALLBACK FlutterViewProc(HWND hwnd, UINT message, WPARAM wparam,
                                 LPARAM lparam) {
  WNDPROC original = g_flutter_view_proc;
  if (message == WM_GETOBJECT && !IsScreenReaderRunning()) {
    return ::DefWindowProcW(hwnd, message, wparam, lparam);
  }
  if (message == WM_NCDESTROY) {
    ::SetWindowLongPtrW(hwnd, GWLP_WNDPROC,
                        reinterpret_cast<LONG_PTR>(original));
    g_flutter_view_proc = nullptr;
  }
  return ::CallWindowProcW(original, hwnd, message, wparam, lparam);
}

} // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  HWND flutter_view = flutter_controller_->view()->GetNativeWindow();
  g_flutter_view_proc = reinterpret_cast<WNDPROC>(::SetWindowLongPtrW(
      flutter_view, GWLP_WNDPROC,
      reinterpret_cast<LONG_PTR>(FlutterViewProc)));
  SetChildContent(flutter_view);

  // Setup file handler method channel
  SetupFileHandlerChannel();

  flutter_controller_->engine()->SetNextFrameCallback([&]() { this->Show(); });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  case WM_SHOWWINDOW:
    // Only the first time, and only for "becoming visible": the window is
    // shown and hidden again over its life (tray, minimise), and the splash is
    // long gone by then.
    if (wparam == TRUE && !window_shown_) {
      window_shown_ = true;
      if (on_window_shown_) {
        on_window_shown_();
      }
    }
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetupFileHandlerChannel() {
  const flutter::StandardMethodCodec &codec =
      flutter::StandardMethodCodec::GetInstance();

  file_handler_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "com.example.i_iwara/file_handler", &codec);
}

void FlutterWindow::SendFileToFlutter(const std::string &file_uri) {
  if (file_handler_channel_) {
    flutter::EncodableValue args(file_uri);
    file_handler_channel_->InvokeMethod(
        "onFileOpened", std::make_unique<flutter::EncodableValue>(args));
  }
}
