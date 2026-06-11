#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-24-0b-watch-export-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SHOT_DIR/watch_export_professional_delivery_screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/watch_export_professional_delivery_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-24-0b-watch-export-evidence"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"

mkdir -p "$SHOT_DIR"
cd "$ROOT_DIR"

TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
xcrun simctl uninstall booted "$APP_ID" >/dev/null 2>&1 || true
xcrun simctl install booted "$APP_PATH"

CAPTURES=()

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

capture_route() {
  local name="$1"
  local arg="$2"
  local path="$3"
  xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
  xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$arg"
  sleep 3
  xcrun simctl io booted screenshot "$path"
  local size
  size="$(stat -f%z "$path")"
  CAPTURES+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"bytes\":$size}")
}

capture_route "Watch Room" "--hf-start-watch-room" "$SHOT_DIR/watch_professional_path.png"
capture_route "Export Room" "--hf-start-export-room" "$SHOT_DIR/export_professional_delivery.png"
capture_route "Profile" "--hf-start-profile" "$SHOT_DIR/profile_watch_export_summary.png"
capture_route "Movie Detail" "--hf-start-movie-detail" "$SHOT_DIR/movie_detail_title_path.png"

{
  printf '{\n'
  printf '  "upgrade": "#024.0B",\n'
  printf '  "screenshot_dir": "%s",\n' "$(json_escape "$SHOT_DIR")"
  printf '  "captures": [\n'
  for i in "${!CAPTURES[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${CAPTURES[$i]}"
  done
  printf '\n  ],\n'
  printf '  "note": "Screenshots capture route roots; lower Watch and Export professional delivery sections are verified by source identifiers when below first viewport."\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Watch Export Professional Delivery Screenshot Manifest\n\n'
  printf 'Screenshot directory: `%s`\n\n' "$SHOT_DIR"
  for row in "${CAPTURES[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    path="$(printf '%s' "$row" | sed -E 's/.*"path":"([^"]+)".*/\1/')"
    bytes="$(printf '%s' "$row" | sed -E 's/.*"bytes":([0-9]+).*/\1/')"
    printf -- '- %s: `%s` (%s bytes)\n' "$name" "$path" "$bytes"
  done
  printf '\nLower Watch and Export professional delivery sections are source-verified when they are below the first viewport.\n'
} > "$MANIFEST_MD"

printf 'Screenshot manifest: %s\n' "$MANIFEST_MD"
