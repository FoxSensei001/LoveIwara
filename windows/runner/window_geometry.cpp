#include "window_geometry.h"

// windows.h first on purpose: knownfolders.h and shlobj.h both need its types
// (GUID, EXTERN_C) and do not include it themselves. Sorting these
// alphabetically breaks the build.
#include <windows.h>

#include <knownfolders.h>
#include <shlobj.h>

#include <fstream>
#include <sstream>
#include <string>

namespace {

// Must match CommonConstants.applicationName and the directory
// path_provider's getApplicationDocumentsDirectory() resolves to on Windows,
// which is FOLDERID_Documents (and follows OneDrive redirection, as
// SHGetKnownFolderPath does too).
constexpr wchar_t kAppFolder[] = L"i_iwara";
constexpr wchar_t kFileName[] = L"window_geometry.txt";

// A window smaller than this is not something the user can have left behind;
// it matches the minWidth/minHeight the Dart side enforces.
constexpr double kMinSide = 200.0;
// Generous upper bound: a plausible multi-monitor desktop, not a corrupt file.
constexpr double kMaxSide = 30000.0;

std::optional<std::wstring> GeometryFilePath() {
  PWSTR documents = nullptr;
  if (FAILED(::SHGetKnownFolderPath(FOLDERID_Documents, KF_FLAG_DEFAULT,
                                    nullptr, &documents)) ||
      documents == nullptr) {
    if (documents) {
      ::CoTaskMemFree(documents);
    }
    return std::nullopt;
  }
  std::wstring path(documents);
  ::CoTaskMemFree(documents);

  path += L"\\";
  path += kAppFolder;
  path += L"\\";
  path += kFileName;
  return path;
}

// True when the rectangle overlaps the virtual desktop at all. A window that
// is entirely off-screen would be unreachable, and that is exactly the case
// the Dart side's fitStoredWindowRect exists to repair - better to start from
// the default and let it place the window than to flash something unusable.
bool IntersectsAnyMonitor(const StoredWindowGeometry &geometry) {
  const int virtual_left = ::GetSystemMetrics(SM_XVIRTUALSCREEN);
  const int virtual_top = ::GetSystemMetrics(SM_YVIRTUALSCREEN);
  const int virtual_width = ::GetSystemMetrics(SM_CXVIRTUALSCREEN);
  const int virtual_height = ::GetSystemMetrics(SM_CYVIRTUALSCREEN);
  if (virtual_width <= 0 || virtual_height <= 0) {
    return true; // No idea; do not reject on a failed query.
  }

  // Physical metrics against logical values: this is deliberately a sanity
  // check, not an exact containment test. Mixed-dpi desktops make the two
  // differ by a scale factor, and the Dart side does the precise fitting.
  const double right = geometry.x + geometry.width;
  const double bottom = geometry.y + geometry.height;
  return right > virtual_left && geometry.x < virtual_left + virtual_width &&
         bottom > virtual_top && geometry.y < virtual_top + virtual_height;
}

} // namespace

std::optional<StoredWindowGeometry> ReadStoredWindowGeometry() {
  const std::optional<std::wstring> path = GeometryFilePath();
  if (!path.has_value()) {
    return std::nullopt;
  }

  std::ifstream file(path->c_str());
  if (!file.is_open()) {
    return std::nullopt;
  }

  std::string line;
  if (!std::getline(file, line)) {
    return std::nullopt;
  }

  StoredWindowGeometry geometry;
  std::istringstream stream(line);
  if (!(stream >> geometry.x >> geometry.y >> geometry.width >>
        geometry.height)) {
    return std::nullopt;
  }

  if (geometry.width < kMinSide || geometry.height < kMinSide ||
      geometry.width > kMaxSide || geometry.height > kMaxSide) {
    return std::nullopt;
  }
  if (!IntersectsAnyMonitor(geometry)) {
    return std::nullopt;
  }

  return geometry;
}
