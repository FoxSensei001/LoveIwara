#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <algorithm>
#include <string>
#include <thread>

#include "flutter_window.h"
#include "utils.h"

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

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"i_iwara", origin, size)) {
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

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
