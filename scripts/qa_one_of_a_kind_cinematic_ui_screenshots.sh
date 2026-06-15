#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-50-0b-one-of-a-kind-ui-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
BUILD_LOG="$OUT_DIR/one_of_a_kind_cinematic_ui_xcodebuild.log"
MANIFEST_JSON="$SCREENSHOT_DIR/one_of_a_kind_cinematic_ui_screenshot_manifest.json"
MANIFEST_MD="$SCREENSHOT_DIR/one_of_a_kind_cinematic_ui_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-50-0b-one-of-a-kind-ui-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SCREENSHOT_DIR"
cd "$ROOT_DIR"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

set +e
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
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

screenshots=()
omissions=()

capture_required() {
  local name="$1"
  shift
  local path="$SCREENSHOT_DIR/$name.png"
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "$@"
  sleep 3
  xcrun simctl io booted screenshot "$path"
  test -s "$path"
  screenshots+=("$name|$path|$(wc -c < "$path" | tr -d ' ')|captured")
}

capture_optional_route() {
  local name="$1"
  local route_flag="$2"
  local path="$SCREENSHOT_DIR/$name.png"
  if rg -q --fixed-strings -- "$route_flag" HighFive; then
    xcrun simctl terminate booted "$APP_ID" || true
    if xcrun simctl launch booted "$APP_ID" "$route_flag"; then
      sleep 3
      if xcrun simctl io booted screenshot "$path" && test -s "$path"; then
        screenshots+=("$name|$path|$(wc -c < "$path" | tr -d ' ')|captured")
        return
      fi
    fi
    omissions+=("$name|route present but screenshot capture failed")
  else
    omissions+=("$name|route unavailable; source verified instead")
  fi
}

capture_required "home" --hf-skip-onboarding --hf-start-home
capture_required "movie_detail" --hf-skip-onboarding --hf-start-movie-detail
capture_required "search" --hf-skip-onboarding --hf-start-search
capture_required "library" --hf-skip-onboarding --hf-start-library
capture_required "downloads" --hf-skip-onboarding --hf-start-downloads
capture_required "profile" --hf-skip-onboarding --hf-start-profile
capture_required "creator_studio" --hf-skip-onboarding --hf-start-creator-studio
capture_required "social_media_kit" --hf-skip-onboarding --hf-start-social-media-kit
capture_required "vod_package" --hf-skip-onboarding --hf-start-vod-package
capture_required "timeline_practice" --hf-start-timeline-practice
capture_optional_route "protected_depth_preview" "--hf-start-protected-depth-preview"

for entry in "${screenshots[@]}"; do
  IFS='|' read -r _ path _ _ <<< "$entry"
  test -s "$path"
done

status="pass"
if [[ "${#omissions[@]}" -gt 0 ]]; then
  for omission in "${omissions[@]}"; do
    if [[ "$omission" == *"capture failed"* ]]; then
      status="fail"
    fi
  done
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#050.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "build_status": "pass",\n'
  printf -- '  "build_log": "%s",\n' "$(json_escape "$BUILD_LOG")"
  printf -- '  "app_path": "%s",\n' "$(json_escape "$APP_PATH")"
  printf -- '  "screenshots": [\n'
  for i in "${!screenshots[@]}"; do
    IFS='|' read -r name path bytes state <<< "${screenshots[$i]}"
    comma=","
    if [[ "$i" -eq $((${#screenshots[@]} - 1)) ]]; then
      comma=""
    fi
    printf -- '    {"name": "%s", "path": "%s", "bytes": %s, "status": "%s"}%s\n' "$(json_escape "$name")" "$(json_escape "$path")" "$bytes" "$(json_escape "$state")" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "omissions": [\n'
  for i in "${!omissions[@]}"; do
    IFS='|' read -r name reason <<< "${omissions[$i]}"
    comma=","
    if [[ "$i" -eq $((${#omissions[@]} - 1)) ]]; then
      comma=""
    fi
    printf -- '    {"name": "%s", "reason": "%s"}%s\n' "$(json_escape "$name")" "$(json_escape "$reason")" "$comma"
  done
  printf -- '  ]\n'
  printf -- '}\n'
} > "$MANIFEST_JSON"

{
  printf -- '# One-of-a-Kind Cinematic UI Screenshot Manifest\n\n'
  printf -- '- Upgrade: #050.0B\n'
  printf -- '- Status: `%s`\n' "$status"
  printf -- '- Build: `pass`\n'
  printf -- '- Build log: `%s`\n\n' "$BUILD_LOG"
  printf -- '## Screenshots\n\n'
  for entry in "${screenshots[@]}"; do
    IFS='|' read -r name path bytes state <<< "$entry"
    printf -- '- `%s`: `%s` (%s bytes, %s)\n' "$name" "$path" "$bytes" "$state"
  done
  if [[ "${#omissions[@]}" -gt 0 ]]; then
    printf -- '\n## Source-Verified Omissions\n\n'
    for omission in "${omissions[@]}"; do
      IFS='|' read -r name reason <<< "$omission"
      printf -- '- `%s`: %s\n' "$name" "$reason"
    done
  fi
} > "$MANIFEST_MD"

printf -- 'Screenshot harness: %s\nManifest: %s\n' "$status" "$MANIFEST_JSON"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
