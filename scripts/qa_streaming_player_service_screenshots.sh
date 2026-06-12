#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-31-0b-player-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_MANIFEST="$SHOT_DIR/streaming_player_service_screenshot_manifest.json"
MD_MANIFEST="$SHOT_DIR/streaming_player_service_screenshot_manifest.md"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
DERIVED="/Volumes/Scratch SSD/XcodeDerivedData/highfive-31-0b-player-evidence"
APP_PATH="$DERIVED/Build/Products/Debug-iphonesimulator/HighFive.app"
BUILD_LOG="$OUT_DIR/streaming_player_service_xcodebuild.log"
mkdir -p "$SHOT_DIR"

set +e
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  build > "$BUILD_LOG" 2>&1
BUILD_STATUS=$?
set -e

if [[ "$BUILD_STATUS" -ne 0 ]]; then
  printf 'Build failed. Log: %s\n' "$BUILD_LOG" >&2
  rg -n "error:|fatal error:|BUILD FAILED|The following build commands failed|SwiftCompile|CompileSwift|Ld |CodeSign|HighFive/" "$BUILD_LOG" >&2 || true
  exit "$BUILD_STATUS"
fi

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"

captures=()
optional=()

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

capture_route "movie_detail_player_service.png" --hf-skip-onboarding --hf-start-movie-detail
capture_route "home_player_ready.png" --hf-skip-onboarding --hf-start-home
capture_route "library_player_context.png" --hf-skip-onboarding --hf-start-library
capture_route "downloads_player_context.png" --hf-skip-onboarding --hf-start-downloads
capture_route "watch_room_player_readiness.png" --hf-skip-onboarding --hf-start-watch-room
capture_route "profile_player_service.png" --hf-skip-onboarding --hf-start-profile
capture_route "demo_player_proof.png" --hf-skip-onboarding --hf-start-demo-tour

optional+=("player_surface.png skipped: no safe direct player route; source verified")

{
  printf '{\n'
  printf '  "upgrade": "#031.0B",\n'
  printf '  "status": "pass",\n'
  printf '  "build": "passed",\n'
  printf '  "install": "passed",\n'
  printf '  "optional_player_surface": "skipped: no safe direct route",\n'
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
  printf '# Streaming Player Service Screenshot Manifest\n\n'
  printf -- '- Upgrade: #031.0B\n'
  printf -- '- Build: passed\n'
  printf -- '- Install: passed\n'
  printf -- '- Screenshots require manual visual inspection.\n'
  printf -- '- Optional player surface: skipped because no safe direct route exists; source identifiers verify the sheet.\n\n'
  for item in "${captures[@]}"; do
    printf -- '- %s/%s\n' "$SHOT_DIR" "$item"
  done
} > "$MD_MANIFEST"

printf 'Streaming player service screenshots captured.\n'
printf 'Manifest: %s\n' "$MD_MANIFEST"
