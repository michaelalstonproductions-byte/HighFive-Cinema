#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UPGRADE="UI-01B"
EVIDENCE_DIR="/private/tmp/highfive-ui-01b-spatial-cinema-evidence"
SHOT_DIR="$EVIDENCE_DIR/screenshots"
JSON_OUT="$EVIDENCE_DIR/spatial_cinema_screenshot_manifest.json"
MD_OUT="$EVIDENCE_DIR/spatial_cinema_screenshot_manifest.md"
BUILD_LOG="$EVIDENCE_DIR/spatial_cinema_build.log"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-01b-spatial-cinema-evidence"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"

build_status="failed"
install_status="failed"
overall_status="failed"
declare -a FAILURES=()
declare -a OMISSIONS=()

if TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build >"$BUILD_LOG" 2>&1; then
  build_status="passed"
else
  FAILURES+=("build failed; see $BUILD_LOG")
fi

if [[ "$build_status" == "passed" ]]; then
  if ! xcrun simctl list devices booted | rg 'iPhone' >/dev/null; then
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  fi

  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl uninstall booted "$APP_ID" || true
  if xcrun simctl install booted "$APP_PATH"; then
    install_status="passed"
  else
    FAILURES+=("install failed for $APP_PATH")
  fi
fi

capture_route() {
  local name="$1"
  local arg="$2"
  local path="$SHOT_DIR/$name.png"
  if [[ "$install_status" != "passed" ]]; then
    OMISSIONS+=("$name omitted because install did not pass")
    return
  fi
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$arg"
  sleep 4
  xcrun simctl io booted screenshot "$path"
  if [[ ! -s "$path" ]]; then
    FAILURES+=("$name screenshot missing or empty: $path")
  fi
}

capture_route "home" "--hf-start-home"
capture_route "movie_detail" "--hf-start-movie-detail"
capture_route "player" "--hf-start-player"
capture_route "profile_tabs" "--hf-start-profile"

if (( ${#FAILURES[@]} == 0 )) && [[ "$build_status" == "passed" && "$install_status" == "passed" ]]; then
  overall_status="passed"
fi

python3 - "$JSON_OUT" "$UPGRADE" "$overall_status" "$build_status" "$install_status" "$SHOT_DIR" <<'PY'
import json
import os
import sys

out, upgrade, status, build, install, shot_dir = sys.argv[1:7]
required = {
    "home": os.path.join(shot_dir, "home.png"),
    "movie_detail": os.path.join(shot_dir, "movie_detail.png"),
    "player": os.path.join(shot_dir, "player.png"),
    "profile_tabs": os.path.join(shot_dir, "profile_tabs.png"),
}
routes = {
    "home": "--hf-skip-onboarding --hf-start-home",
    "movie_detail": "--hf-skip-onboarding --hf-start-movie-detail",
    "player": "--hf-skip-onboarding --hf-start-player",
    "profile_tabs": "--hf-skip-onboarding --hf-start-profile",
}
byte_counts = {name: (os.path.getsize(path) if os.path.exists(path) else 0) for name, path in required.items()}
failures = [name for name, size in byte_counts.items() if size <= 0]
data = {
    "upgrade": upgrade,
    "status": status if not failures else "failed",
    "build": build,
    "install": install,
    "routes": routes,
    "screenshot_paths": required,
    "screenshot_byte_counts": byte_counts,
    "coordinate_tapping": False,
    "fake_screenshots": False,
    "automated_visual_truth": "non-empty screenshot proof only",
    "omissions": [],
    "failures": failures,
}
with open(out, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

python3 - "$JSON_OUT" "$MD_OUT" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
with open(sys.argv[2], "w", encoding="utf-8") as f:
    f.write("# Spatial Cinema Screenshot Manifest\n\n")
    f.write(f"- Upgrade: {data['upgrade']}\n")
    f.write(f"- Status: {data['status']}\n")
    f.write(f"- Build: {data['build']}\n")
    f.write(f"- Install: {data['install']}\n")
    f.write(f"- Coordinate tapping: {str(data['coordinate_tapping']).lower()}\n")
    f.write(f"- Fake screenshots: {str(data['fake_screenshots']).lower()}\n")
    f.write(f"- Automated visual truth: {data['automated_visual_truth']}\n\n")
    f.write("## Screenshots\n")
    for name, path in data["screenshot_paths"].items():
        f.write(f"- {name}: {path} ({data['screenshot_byte_counts'][name]} bytes)\n")
    f.write("\n## Failures\n")
    if data["failures"]:
        for failure in data["failures"]:
            f.write(f"- {failure}\n")
    else:
        f.write("- None\n")
PY

if [[ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["status"])' "$JSON_OUT")" != "passed" ]]; then
  echo "Screenshot harness failed. See $JSON_OUT" >&2
  exit 1
fi

echo "Screenshot harness passed: $JSON_OUT"
