#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-47-0b-product-ux-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
BUILD_LOG="$OUT_DIR/product_ux_overhaul_xcodebuild.log"
MANIFEST_JSON="$SCREENSHOT_DIR/product_ux_overhaul_screenshot_manifest.json"
MANIFEST_MD="$SCREENSHOT_DIR/product_ux_overhaul_screenshot_manifest.md"
APP_PATH="/Volumes/Scratch SSD/XcodeDerivedData/highfive-47-0b-product-ux-evidence/Build/Products/Debug-iphonesimulator/HighFive.app"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"

mkdir -p "$SCREENSHOT_DIR"
cd "$ROOT_DIR"

set +e
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-47-0b-product-ux-evidence" \
  CODE_SIGNING_ALLOWED=NO \
  build > "$BUILD_LOG" 2>&1
BUILD_STATUS=$?
set -e

if [[ "$BUILD_STATUS" -ne 0 ]]; then
  printf 'Build failed. Log: %s\n' "$BUILD_LOG" >&2
  rg -n "error:|fatal error:|BUILD FAILED|The following build commands failed|SwiftCompile|CompileSwift|Ld |CodeSign|HighFive/" "$BUILD_LOG" >&2 || true
  exit "$BUILD_STATUS"
fi

xcrun simctl list devices booted | rg 'iPhone' || {
  DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
  xcrun simctl boot "$DEVICE_ID" || true
  open -a Simulator || true
  xcrun simctl bootstatus booted -b
}

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"
open -a Simulator || true

capture() {
  local name="$1"
  shift
  local path="$SCREENSHOT_DIR/$name.png"
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "$@"
  sleep 3
  xcrun simctl io booted screenshot "$path"
  test -s "$path"
}

capture onboarding_intro --hf-start-onboarding --hf-reset-onboarding
capture training_controls --hf-start-training-controls
capture timeline_practice --hf-start-timeline-practice
capture home --hf-skip-onboarding --hf-start-home
capture search --hf-skip-onboarding --hf-start-search
capture library --hf-skip-onboarding --hf-start-library
capture downloads --hf-skip-onboarding --hf-start-downloads
capture profile --hf-skip-onboarding --hf-start-profile
capture creator_studio --hf-skip-onboarding --hf-start-creator-studio
capture social_media_kit --hf-skip-onboarding --hf-start-social-media-kit
capture vod_package --hf-skip-onboarding --hf-start-vod-package
capture movie_detail --hf-skip-onboarding --hf-start-movie-detail

screens=(
  onboarding_intro
  training_controls
  timeline_practice
  home
  search
  library
  downloads
  profile
  creator_studio
  social_media_kit
  vod_package
  movie_detail
)

{
  printf '{\n'
  printf '  "upgrade": "#047.0B",\n'
  printf '  "status": "pass",\n'
  printf '  "build_log": "%s",\n' "$BUILD_LOG"
  printf '  "app_path": "%s",\n' "$APP_PATH"
  printf '  "screenshots": [\n'
  for i in "${!screens[@]}"; do
    name="${screens[$i]}"
    path="$SCREENSHOT_DIR/$name.png"
    size="$(wc -c < "$path" | tr -d ' ')"
    comma=","
    if [[ "$i" -eq $((${#screens[@]} - 1)) ]]; then comma=""; fi
    printf '    {"name": "%s", "path": "%s", "bytes": %s}%s\n' "$name" "$path" "$size" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Product UX Overhaul Screenshot Manifest\n\n'
  printf -- '- Upgrade: #047.0B\n'
  printf -- '- Status: pass\n'
  printf -- '- Build log: %s\n' "$BUILD_LOG"
  printf -- '- App path: %s\n\n' "$APP_PATH"
  printf '## Screenshots\n\n'
  for name in "${screens[@]}"; do
    path="$SCREENSHOT_DIR/$name.png"
    size="$(wc -c < "$path" | tr -d ' ')"
    printf -- '- `%s`: %s bytes\n' "$path" "$size"
  done
} > "$MANIFEST_MD"

printf 'Screenshot QA passed. Manifest: %s\n' "$MANIFEST_JSON"
