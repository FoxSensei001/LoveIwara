#include "splash_window.h"

#include <dwmapi.h>

#include "resource.h"

namespace {

constexpr wchar_t kClassName[] = L"IIwaraSplashWindow";

// The launcher icon's background colour (flutter_launcher_icons'
// adaptive_icon_background in pubspec.yaml). The icon itself is drawn on the
// same orange, so this reads as one piece rather than a logo on a plate.
constexpr COLORREF kBackground = RGB(0xF8, 0x90, 0x32);

// Logical (96 dpi) metrics, scaled by the monitor dpi at creation time.
constexpr int kWindowSize = 280;
constexpr int kIconSize = 112;
constexpr int kDotRadius = 5;
constexpr int kDotSpacing = 22;
constexpr int kDotsBelowIcon = 34;

constexpr UINT_PTR kAnimationTimer = 1;
constexpr UINT_PTR kSafetyTimer = 2;
constexpr UINT kAnimationIntervalMs = 140;

// If the first frame never arrives, give up rather than leave a topmost window
// on top of everything forever.
constexpr UINT kSafetyTimeoutMs = 30000;

// Only ever one splash per process, so the animation phase can live here
// instead of being threaded through the window's user data.
int g_phase = 0;
int g_scale_dpi = 96;

int Scaled(int logical) { return ::MulDiv(logical, g_scale_dpi, 96); }

// A lighter and a dimmer tint of the background for the pulsing dots. Mixing
// towards white rather than using a second brand colour keeps this readable if
// kBackground is ever retuned.
COLORREF Mix(COLORREF color, double towards_white) {
  auto channel = [towards_white](int value) {
    return static_cast<int>(value + (255 - value) * towards_white);
  };
  return RGB(channel(GetRValue(color)), channel(GetGValue(color)),
             channel(GetBValue(color)));
}

void PaintSplash(HWND window) {
  PAINTSTRUCT ps;
  HDC hdc = ::BeginPaint(window, &ps);

  RECT client;
  ::GetClientRect(window, &client);
  const int width = client.right - client.left;
  const int height = client.bottom - client.top;

  // Double buffered: only the dots change, and repainting the icon straight
  // onto the window every 140ms flickers.
  HDC memory_dc = ::CreateCompatibleDC(hdc);
  HBITMAP bitmap = ::CreateCompatibleBitmap(hdc, width, height);
  HGDIOBJ old_bitmap = ::SelectObject(memory_dc, bitmap);

  HBRUSH background = ::CreateSolidBrush(kBackground);
  ::FillRect(memory_dc, &client, background);
  ::DeleteObject(background);

  const int icon_size = Scaled(kIconSize);
  HICON icon = static_cast<HICON>(
      ::LoadImage(::GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON),
                  IMAGE_ICON, icon_size, icon_size, LR_DEFAULTCOLOR));
  if (icon) {
    const int icon_top = (height - icon_size) / 2 - Scaled(kDotsBelowIcon) / 2;
    ::DrawIconEx(memory_dc, (width - icon_size) / 2, icon_top, icon, icon_size,
                 icon_size, 0, nullptr, DI_NORMAL);
    ::DestroyIcon(icon);

    const int radius = Scaled(kDotRadius);
    const int spacing = Scaled(kDotSpacing);
    const int dots_y = icon_top + icon_size + Scaled(kDotsBelowIcon);
    const int dots_x = width / 2 - spacing;
    for (int i = 0; i < 3; ++i) {
      const bool active = (i == g_phase % 3);
      HBRUSH dot = ::CreateSolidBrush(Mix(kBackground, active ? 0.95 : 0.35));
      HGDIOBJ old_brush = ::SelectObject(memory_dc, dot);
      HGDIOBJ old_pen = ::SelectObject(memory_dc, ::GetStockObject(NULL_PEN));
      const int center_x = dots_x + i * spacing;
      ::Ellipse(memory_dc, center_x - radius, dots_y - radius,
                center_x + radius, dots_y + radius);
      ::SelectObject(memory_dc, old_pen);
      ::SelectObject(memory_dc, old_brush);
      ::DeleteObject(dot);
    }
  }

  ::BitBlt(hdc, 0, 0, width, height, memory_dc, 0, 0, SRCCOPY);

  ::SelectObject(memory_dc, old_bitmap);
  ::DeleteObject(bitmap);
  ::DeleteDC(memory_dc);

  ::EndPaint(window, &ps);
}

LRESULT CALLBACK SplashWndProc(HWND window, UINT message, WPARAM wparam,
                               LPARAM lparam) noexcept {
  switch (message) {
  case WM_ERASEBKGND:
    // Handled by WM_PAINT; saying so here avoids a white flash on the first
    // paint.
    return 1;
  case WM_PAINT:
    PaintSplash(window);
    return 0;
  case WM_TIMER:
    if (wparam == kAnimationTimer) {
      ++g_phase;
      ::InvalidateRect(window, nullptr, FALSE);
      return 0;
    }
    if (wparam == kSafetyTimer) {
      ::DestroyWindow(window);
      return 0;
    }
    break;
  case WM_CLOSE:
    ::DestroyWindow(window);
    return 0;
  case WM_DESTROY:
    ::KillTimer(window, kAnimationTimer);
    ::KillTimer(window, kSafetyTimer);
    ::PostQuitMessage(0);
    return 0;
  default:
    break;
  }
  return ::DefWindowProc(window, message, wparam, lparam);
}

} // namespace

SplashWindow::SplashWindow() = default;

SplashWindow::~SplashWindow() { Close(); }

void SplashWindow::Show() {
  if (started_.exchange(true)) {
    return;
  }
  thread_ = std::thread(&SplashWindow::ThreadMain, this);
}

void SplashWindow::Close() {
  HWND window = window_.exchange(nullptr);
  if (window) {
    // PostMessage, not SendMessage: the caller is the platform thread and must
    // not block on another thread's message loop.
    ::PostMessage(window, WM_CLOSE, 0, 0);
  }
  if (thread_.joinable()) {
    thread_.join();
  }
}

void SplashWindow::ThreadMain() {
  WNDCLASSEX window_class = {};
  window_class.cbSize = sizeof(WNDCLASSEX);
  window_class.lpfnWndProc = SplashWndProc;
  window_class.hInstance = ::GetModuleHandle(nullptr);
  window_class.lpszClassName = kClassName;
  window_class.hCursor = ::LoadCursor(nullptr, IDC_ARROW);
  // No background brush: WM_ERASEBKGND is handled, and letting Windows paint
  // COLOR_WINDOW first is exactly the white flash this class exists to remove.
  window_class.hbrBackground = nullptr;
  ::RegisterClassEx(&window_class);

  HDC screen = ::GetDC(nullptr);
  if (screen) {
    g_scale_dpi = ::GetDeviceCaps(screen, LOGPIXELSX);
    ::ReleaseDC(nullptr, screen);
  }

  // Centre on the primary monitor's work area. The main window's own geometry
  // is restored from the app's config much later (and by Dart), so there is
  // nothing better to align to at this point.
  RECT work_area = {};
  if (!::SystemParametersInfo(SPI_GETWORKAREA, 0, &work_area, 0)) {
    work_area = {0, 0, ::GetSystemMetrics(SM_CXSCREEN),
                 ::GetSystemMetrics(SM_CYSCREEN)};
  }
  const int size = Scaled(kWindowSize);
  const int x = work_area.left + (work_area.right - work_area.left - size) / 2;
  const int y = work_area.top + (work_area.bottom - work_area.top - size) / 2;

  HWND window = ::CreateWindowEx(
      // TOOLWINDOW keeps it out of the taskbar and Alt-Tab: the app's own
      // button is already there, two entries for one launch looks broken.
      WS_EX_TOOLWINDOW | WS_EX_TOPMOST, kClassName, L"i_iwara", WS_POPUP, x, y,
      size, size, nullptr, nullptr, ::GetModuleHandle(nullptr), nullptr);
  if (!window) {
    return;
  }

  // Windows 11 rounded corners; older systems return an error we ignore.
  // DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2. Spelled as literals
  // because the value is not in every SDK this project builds against.
  const DWORD corner_preference = 2;
  ::DwmSetWindowAttribute(window, 33, &corner_preference,
                          sizeof(corner_preference));

  ::SetTimer(window, kAnimationTimer, kAnimationIntervalMs, nullptr);
  ::SetTimer(window, kSafetyTimer, kSafetyTimeoutMs, nullptr);

  window_.store(window);
  ::ShowWindow(window, SW_SHOWNOACTIVATE);
  ::UpdateWindow(window);

  MSG message;
  while (::GetMessage(&message, nullptr, 0, 0)) {
    ::TranslateMessage(&message);
    ::DispatchMessage(&message);
  }

  window_.store(nullptr);
  ::UnregisterClass(kClassName, ::GetModuleHandle(nullptr));
}
