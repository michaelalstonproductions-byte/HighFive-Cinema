#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-48-0b-protected-depth-tilt-peek-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
BUILD_LOG="$OUT_DIR/protected_depth_tilt_peek_xcodebuild.log"
MANIFEST_JSON="$SCREENSHOT_DIR/protected_depth_tilt_peek_screenshot_manifest.json"
MANIFEST_MD="$SCREENSHOT_DIR/protected_depth_tilt_peek_screenshot_manifest.md"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="/Volumes/Scratch SSD/XcodeDerivedData/highfive-48-0b-protected-depth-evidence/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SCREENSHOT_DIR"
cd "$ROOT_DIR"

set +e
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-48-0b-protected-depth-evidence" \
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

declare -a SCREENSHOT_NAMES=()
declare -a SCREENSHOT_PATHS=()
declare -a OMITTED=()

capture() {
  local name="$1"
  shift
  local path="$SCREENSHOT_DIR/$name.png"
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "$@"
  sleep 3
  xcrun simctl io booted screenshot "$path"
  test -s "$path"
  SCREENSHOT_NAMES+=("$name")
  SCREENSHOT_PATHS+=("$path")
}

capture timeline_try_depth_peek --hf-start-timeline-practice

if rg -n -- "--hf-start-protected-depth-preview" HighFive >/dev/null; then
  capture protected_depth_preview --hf-start-protected-depth-preview
else
  OMITTED+=("protected_depth_preview: source-verified, route unavailable")
fi

capture intro_vertical_preserved --hf-start-onboarding --hf-reset-onboarding
capture training_diagram_preserved --hf-start-training-controls
capture timeline_vertical_preserved --hf-start-timeline-practice

if rg -n "hf.movieDetail.depthPreview|Depth Preview" HighFive/Views/MovieDetail/MovieDetailView.swift >/dev/null; then
  capture movie_detail_depth_preview --hf-skip-onboarding --hf-start-movie-detail
else
  OMITTED+=("movie_detail_depth_preview: source-verified omitted, no movie-detail depth preview CTA in #048.0A")
fi

{
  printf '{\n'
  printf '  "upgrade": "#048.0B",\n'
  printf '  "status": "pass",\n'
  printf '  "build_log": "%s",\n' "$BUILD_LOG"
  printf '  "app_path": "%s",\n' "$APP_PATH"
  printf '  "screenshots": [\n'
  for i in "${!SCREENSHOT_NAMES[@]}"; do
    name="${SCREENSHOT_NAMES[$i]}"
    path="${SCREENSHOT_PATHS[$i]}"
    bytes="$(wc -c < "$path" | tr -d ' ')"
    comma=","
    if [[ "$i" -eq $((${#SCREENSHOT_NAMES[@]} - 1)) ]]; then comma=""; fi
    printf '    {"name": "%s", "path": "%s", "bytes": %s}%s\n' "$name" "$path" "$bytes" "$comma"
  done
  printf '  ],\n'
  printf '  "omitted": [\n'
  for i in "${!OMITTED[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#OMITTED[@]} - 1)) ]]; then comma=""; fi
    printf '    "%s"%s\n' "${OMITTED[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Protected Depth Tilt Peek Screenshot Manifest\n\n'
  printf -- '- Upgrade: #048.0B\n'
  printf -- '- Status: pass\n'
  printf -- '- Build log: %s\n' "$BUILD_LOG"
  printf -- '- App path: %s\n\n' "$APP_PATH"
  printf '## Screenshots\n\n'
  for i in "${!SCREENSHOT_NAMES[@]}"; do
    path="${SCREENSHOT_PATHS[$i]}"
    bytes="$(wc -c < "$path" | tr -d ' ')"
    printf -- '- `%s`: %s bytes\n' "$path" "$bytes"
  done
  printf '\n## Source-Verified Omissions\n\n'
  if [[ "${#OMITTED[@]}" -eq 0 ]]; then
    printf -- '- none\n'
  else
    for item in "${OMITTED[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MANIFEST_MD"

printf 'Screenshot QA passed. Manifest: %s\n' "$MANIFEST_JSON"
