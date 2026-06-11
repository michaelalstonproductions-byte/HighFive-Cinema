#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-28-0b-unified-services-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_MANIFEST="$SHOT_DIR/unified_app_services_screenshot_manifest.json"
MD_MANIFEST="$SHOT_DIR/unified_app_services_screenshot_manifest.md"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
DERIVED="/Volumes/Scratch SSD/XcodeDerivedData/highfive-28-0b-unified-services-evidence"
APP_PATH="$DERIVED/Build/Products/Debug-iphonesimulator/HighFive.app"
mkdir -p "$SHOT_DIR"

TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"

captures=()

capture_route() {
  local name="$1"
  shift
  local path="$SHOT_DIR/$name"
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "$@"
  sleep 3
  xcrun simctl io booted screenshot "$path"
  captures+=("$name")
}

capture_route "home_connected.png" --hf-skip-onboarding --hf-start-home
capture_route "movie_detail_connected.png" --hf-skip-onboarding --hf-start-movie-detail
capture_route "library_connected.png" --hf-skip-onboarding --hf-start-library
capture_route "downloads_connected.png" --hf-skip-onboarding --hf-start-downloads
capture_route "connect_connected.png" --hf-skip-onboarding --hf-start-connect-room
capture_route "launch_connected.png" --hf-skip-onboarding --hf-start-launch-room
capture_route "export_connected.png" --hf-skip-onboarding --hf-start-export-room
capture_route "profile_connected.png" --hf-skip-onboarding --hf-start-profile
capture_route "demo_tour_connected.png" --hf-skip-onboarding --hf-start-demo-tour
capture_route "onboarding_connected.png" --hf-reset-onboarding

{
  printf '{\n'
  printf '  "upgrade": "#028.0B",\n'
  printf '  "status": "pass",\n'
  printf '  "build": "passed",\n'
  printf '  "install": "passed",\n'
  printf '  "screenshots": [\n'
  for i in "${!captures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#captures[@]} - 1)) ]] && comma=""
    printf '    "%s/%s"%s\n' "$SHOT_DIR" "${captures[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_MANIFEST"

{
  printf '# Unified App Services Screenshot Manifest\n\n'
  printf -- '- Upgrade: #028.0B\n'
  printf -- '- Build: passed\n'
  printf -- '- Install: passed\n'
  printf -- '- Screenshots require manual visual inspection.\n\n'
  for item in "${captures[@]}"; do
    printf -- '- %s/%s\n' "$SHOT_DIR" "$item"
  done
} > "$MD_MANIFEST"

printf 'Unified app services screenshots captured.\n'
printf 'Manifest: %s\n' "$MD_MANIFEST"
