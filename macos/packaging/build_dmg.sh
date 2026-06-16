#!/usr/bin/env bash
#
# Build a branded, laid-out macOS DMG for i_iwara using appdmg.
#
# appdmg writes the window layout (background, icon positions, Applications
# link) deterministically into the DMG's .DS_Store — no Finder/AppleScript
# automation, so it runs reliably headless (CI) and locally.
#
# Prerequisites:
#   - `flutter build macos --release` already run (produces the .app)
#   - appdmg installed:  npm install -g appdmg
#
# Without code-signing env vars this produces an ad-hoc-signed, un-notarized
# DMG (ships fine; users bypass Gatekeeper per INSTALL_NOTE.md). With the
# Developer ID env vars set, it additionally signs + notarizes + staples.
#
# Optional env (notarization needs ALL four):
#   MACOS_SIGN_IDENTITY   e.g. "Developer ID Application: Name (TEAMID)"
#   APPLE_ID              Apple ID email for notarytool
#   APPLE_TEAM_ID         10-char team id
#   APPLE_APP_PASSWORD    app-specific password for notarytool
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

APP_NAME="i_iwara"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
PKG_DIR="macos/packaging"
DMG_ASSETS="${PKG_DIR}/dmg"
OUT_DIR="build/macos"

# --- version ----------------------------------------------------------------
VERSION="$(grep '^version:' pubspec.yaml | head -1 | sed 's/version:[[:space:]]*//' | cut -d'+' -f1 | tr -d '[:space:]')"
DMG_PATH="${OUT_DIR}/${APP_NAME}-${VERSION}-macos.dmg"

if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: app bundle not found at $APP_PATH" >&2
  echo "Run 'flutter build macos --release' first." >&2
  exit 1
fi
if ! command -v appdmg >/dev/null 2>&1; then
  echo "ERROR: appdmg not found. Install with: npm install -g appdmg" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
rm -f "$DMG_PATH"

# --- guard against partial signing/notarization config ----------------------
# If any signing-related variable is set, require the full set so a typo'd or
# missing secret in a release pipeline fails loudly instead of silently
# shipping a low-trust (ad-hoc / un-notarized) build. To intentionally ship an
# unsigned build, set ALLOW_UNSIGNED_RELEASE=1.
NOTARIZE_COMPLETE=0
if [[ -n "${MACOS_SIGN_IDENTITY:-}" && -n "${APPLE_ID:-}" \
      && -n "${APPLE_TEAM_ID:-}" && -n "${APPLE_APP_PASSWORD:-}" ]]; then
  NOTARIZE_COMPLETE=1
fi
SIGN_VARS_PRESENT=0
for v in "${MACOS_SIGN_IDENTITY:-}" "${MACOS_CERT_BASE64:-}" "${APPLE_ID:-}" \
         "${APPLE_TEAM_ID:-}" "${APPLE_APP_PASSWORD:-}"; do
  [[ -n "$v" ]] && SIGN_VARS_PRESENT=1
done
if [[ "$SIGN_VARS_PRESENT" == "1" && "$NOTARIZE_COMPLETE" == "0" \
      && "${ALLOW_UNSIGNED_RELEASE:-}" != "1" ]]; then
  echo "ERROR: signing/notarization is partially configured." >&2
  echo "Need ALL of: MACOS_SIGN_IDENTITY, APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD" >&2
  echo "(plus MACOS_CERT_BASE64 imported into the keychain in CI)." >&2
  echo "To intentionally ship an unsigned build, set ALLOW_UNSIGNED_RELEASE=1." >&2
  exit 1
fi

# --- sign the .app ----------------------------------------------------------
if [[ -n "${MACOS_SIGN_IDENTITY:-}" ]]; then
  echo "Signing app with Developer ID: $MACOS_SIGN_IDENTITY"
  codesign --deep --force --options runtime --timestamp \
    --sign "$MACOS_SIGN_IDENTITY" "$APP_PATH"
else
  echo "No MACOS_SIGN_IDENTITY set; applying ad-hoc signature."
  codesign --deep --force --sign - "$APP_PATH"
fi

# --- stage the install note with a friendly name ----------------------------
WORK_DIR="$(mktemp -d -t iwara_dmg)"
trap 'rm -rf "$WORK_DIR"' EXIT
NOTE_PATH="${WORK_DIR}/安装说明 Read Me.txt"
cp "${PKG_DIR}/INSTALL_NOTE.md" "$NOTE_PATH"

# --- materialize appdmg spec with absolute paths ----------------------------
# appdmg resolves relative paths against the spec's dir; we substitute absolute
# paths for the app bundle and staged note so the spec stays location-agnostic.
SPEC="${WORK_DIR}/appdmg.json"
APP_ABS="${REPO_ROOT}/${APP_PATH}"
python3 - "$DMG_ASSETS/appdmg.json" "$SPEC" "$APP_ABS" "$NOTE_PATH" <<'PY'
import json, sys
src, dst, app_path, note_path = sys.argv[1:5]
spec = json.load(open(src, encoding="utf-8"))
# Resolve asset paths (icon/background) to absolute against the source dir.
import os
base = os.path.dirname(os.path.abspath(src))
spec["icon"] = os.path.join(base, spec["icon"])
spec["background"] = os.path.join(base, spec["background"])
for item in spec["contents"]:
    if item.get("path") == "__APP_PATH__":
        item["path"] = app_path
    elif item.get("path") == "__NOTE_PATH__":
        item["path"] = note_path
json.dump(spec, open(dst, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
PY

# --- build the DMG (appdmg auto-uses background@2x.png for retina) -----------
echo "Building DMG with appdmg..."
appdmg "$SPEC" "$DMG_PATH"
echo "Built: $DMG_PATH"

# --- notarize (only if full Developer ID env present) -----------------------
if [[ "$NOTARIZE_COMPLETE" == "1" ]]; then
  echo "Notarizing DMG..."
  xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --wait
  xcrun stapler staple "$DMG_PATH"
  echo "Notarized and stapled: $DMG_PATH"
else
  echo "Skipping notarization (Developer ID / Apple ID env not fully set)."
  echo "DMG is ad-hoc signed; see ${PKG_DIR}/INSTALL_NOTE.md for first-launch steps."
fi
