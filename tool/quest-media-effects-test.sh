#!/usr/bin/env bash
set -euo pipefail

# Run the real Quest GPU/player tests without wearing the headset.
# Usage: tool/quest-media-effects-test.sh 192.168.1.20:5555
# QUEST_SKIP_BUILD=1 reuses APKs from the last successful build.
quest_device="${1:?Pass the Quest ADB serial or address}"
quest_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
quest_adb="${QUEST_ADB:-adb}"
if ! command -v "$quest_adb" >/dev/null 2>&1; then
    quest_adb="$HOME/Library/Android/sdk/platform-tools/adb"
fi
command -v metavr >/dev/null
if [[ "$quest_device" == *:* ]]; then
    "$quest_adb" connect "$quest_device"
fi
quest_model="$("$quest_adb" -s "$quest_device" shell getprop ro.product.model)"
[[ "$quest_model" == *Quest* ]] || { printf 'Refusing to run Quest tests on %s\n' "$quest_model"; exit 1; }

quest_log_dir="$(mktemp -d "${TMPDIR:-/tmp}/loveiwara-media-test.XXXXXX")"
quest_proximity="$(metavr -d "$quest_device" device proximity --status --json)"
quest_restore="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["enabled"])' <<< "$quest_proximity")"
quest_boundary="$(metavr -d "$quest_device" device boundary --status --json)"
quest_restore_boundary="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["enabled"])' <<< "$quest_boundary")"
quest_test_started=false
quest_preferences_present=false
quest_cleanup() {
    if [[ "$quest_test_started" == true ]]; then
        # Instrumentation drives the real controls. Restore personal preferences
        # after stopping the process, so its in-memory cache cannot overwrite us.
        "$quest_adb" -s "$quest_device" shell am force-stop m.c.g.a.i_iwara.debug || true
        if [[ "$quest_preferences_present" == true ]]; then
            "$quest_adb" -s "$quest_device" shell "run-as m.c.g.a.i_iwara.debug sh -c 'cat > shared_prefs/xr_player_v2.xml'" < "$quest_log_dir/player-prefs.xml" || true
        else
            "$quest_adb" -s "$quest_device" shell run-as m.c.g.a.i_iwara.debug rm -f shared_prefs/xr_player_v2.xml || true
        fi
        "$quest_adb" -s "$quest_device" shell run-as m.c.g.a.i_iwara.debug rm -f \
            shared_prefs/xr_player_v2.xml.bak cache/media-effects-probe.mp4 \
            cache/media-effects-probe.png cache/media-effects-probe.gif cache/media-effects-probe.gray.png || true
    fi
    if [[ "$quest_restore_boundary" == True ]]; then
        metavr -d "$quest_device" device boundary --enable --json || true
    fi
    if [[ "$quest_restore" == True ]]; then
        metavr -d "$quest_device" device proximity --enable --json || true
    fi
    printf 'Test evidence: %s\n' "$quest_log_dir"
}
trap quest_cleanup EXIT
trap 'exit 130' INT TERM
# A stationary, unattended headset can lose room tracking. Pause the development
# boundary BEFORE waking it, otherwise Guardian can hold the activity launch.
metavr -d "$quest_device" device boundary --disable --json
metavr -d "$quest_device" device proximity --disable --duration-ms 3600000 --json
metavr -d "$quest_device" device wake
metavr -d "$quest_device" device proximity --status --json > "$quest_log_dir/proximity.json"

if [[ "${QUEST_SKIP_BUILD:-0}" != 1 ]]; then
    (cd "$quest_root/android" && ./gradlew :app:assembleQuestDebug :app:assembleQuestDebugAndroidTest :app:testQuestDebugUnitTest --console=plain) > "$quest_log_dir/build.log" 2>&1
fi
quest_apks="$quest_root/android/app/build/outputs/apk"
"$quest_adb" -s "$quest_device" install -r "$quest_apks/quest/debug/app-quest-arm64-v8a-debug.apk"
"$quest_adb" -s "$quest_device" install -r "$quest_apks/androidTest/quest/debug/app-quest-debug-androidTest.apk"
if "$quest_adb" -s "$quest_device" shell run-as m.c.g.a.i_iwara.debug cat shared_prefs/xr_player_v2.xml > "$quest_log_dir/player-prefs.xml" 2>/dev/null; then
    quest_preferences_present=true
fi
quest_test_started=true
python3 - "$quest_adb" "$quest_device" <<'PY' | tee "$quest_log_dir/device.txt"
import subprocess, sys
try:
    result = subprocess.run([sys.argv[1], "-s", sys.argv[2], "shell", "am", "instrument", "-w",
        "m.c.g.a.i_iwara.debug.test/m.c.g.a.i_iwara.vr.MediaEffectsProbe"], timeout=180)
    raise SystemExit(result.returncode)
except subprocess.TimeoutExpired:
    raise SystemExit("Quest instrumentation did not finish within 180 seconds")
PY
python3 - "$quest_log_dir/device.txt" <<'PY'
import pathlib, sys
result = pathlib.Path(sys.argv[1]).read_text()
required = ["PASS reference GPU comparison", "PASS live video colour pipeline", "PASS media resize follows frame"]
if "FAIL " in result or any(marker not in result for marker in required):
    raise SystemExit("The device regression did not complete successfully")
PY
