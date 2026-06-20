#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EVIDENCE_DIR="/private/tmp/highfive-ui-06b-membership-identity-pass-evidence"
SHOT_DIR="$EVIDENCE_DIR/screenshots"
JSON_OUT="$EVIDENCE_DIR/membership_identity_pass_screenshot_manifest.json"
MD_OUT="$EVIDENCE_DIR/membership_identity_pass_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-06b-membership-identity-pass-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"
rm -f "$SHOT_DIR"/*.png

failures=()
routes=()
screenshots=()

build_status="failed"
install_status="failed"

if TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build; then
  build_status="passed"
else
  failures+=("build failed")
fi

if [[ "$build_status" == "passed" ]]; then
  xcrun simctl list devices booted | rg 'iPhone' || {
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  }

  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl uninstall booted "$APP_ID" || true
  if xcrun simctl install booted "$APP_PATH"; then
    install_status="passed"
  else
    failures+=("install failed")
  fi
fi

capture() {
  local route="$1"
  local file="$2"
  local path="$SHOT_DIR/$file"
  routes+=("$route")
  screenshots+=("$path")
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$route"
  sleep 4
  xcrun simctl io booted screenshot "$path"
  if [[ ! -s "$path" ]]; then
    failures+=("missing or empty screenshot:$path")
  fi
}

if [[ "$install_status" == "passed" ]]; then
  capture --hf-start-membership membership_pass_default.png
  capture --hf-start-membership-identity membership_identity.png
  capture --hf-start-membership-premieres membership_premieres.png
  capture --hf-start-membership-creator-rooms membership_creator_rooms.png
  capture --hf-start-membership-protected-playback membership_protected_playback.png
  capture --hf-start-membership-depth-peek membership_depth_peek.png
  capture --hf-start-profile profile_membership_entry.png
  capture --hf-start-movie-detail movie_detail_access_regression.png
  capture --hf-start-vod-package vod_regression.png
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

ROUTES_JSON="$(mktemp)"
FAILURES_JSON="$(mktemp)"
printf '%s\n' "${routes[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip() for l in sys.stdin if l.rstrip()]))' > "$ROUTES_JSON"
if (( ${#failures[@]} > 0 )); then
  printf '%s\n' "${failures[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip() for l in sys.stdin if l.rstrip()]))' > "$FAILURES_JSON"
else
  printf '[]\n' > "$FAILURES_JSON"
fi

python3 - <<PY
import json
from pathlib import Path
paths = [Path(p) for p in """$(printf '%s\n' "${screenshots[@]}")""".splitlines() if p]
data = {
  "upgrade": "UI-06B",
  "status": "$status",
  "build": "$build_status",
  "install": "$install_status",
  "routes": [],
  "screenshot_paths": [str(p) for p in paths],
  "screenshot_byte_counts": {str(p): (p.stat().st_size if p.exists() else 0) for p in paths},
  "coordinate_tapping": False,
  "fake_screenshots": False,
  "automated_visual_truth": "non-empty screenshot proof only",
  "omissions": [],
  "failures": []
}
data["routes"] = json.loads(Path("$ROUTES_JSON").read_text())
data["failures"] = json.loads(Path("$FAILURES_JSON").read_text())
Path("$JSON_OUT").write_text(json.dumps(data, indent=2) + "\n")
PY
rm -f "$ROUTES_JSON" "$FAILURES_JSON"

{
  echo "# Membership Identity Pass Screenshot Manifest"
  echo
  echo "- upgrade: UI-06B"
  echo "- status: $status"
  echo "- build: $build_status"
  echo "- install: $install_status"
  echo "- coordinate_tapping: false"
  echo "- fake_screenshots: false"
  echo "- automated_visual_truth: non-empty screenshot proof only"
  echo
  echo "## Screenshots"
  for path in "${screenshots[@]}"; do
    if [[ -f "$path" ]]; then
      echo "- $path ($(stat -f%z "$path") bytes)"
    else
      echo "- $path (missing)"
    fi
  done
  if (( ${#failures[@]} > 0 )); then
    echo
    echo "## Failures"
    printf -- "- %s\n" "${failures[@]}"
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

echo "membership identity pass screenshot harness passed"
