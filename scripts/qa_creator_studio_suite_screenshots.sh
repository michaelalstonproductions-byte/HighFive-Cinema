#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-20-0e-creator-suite-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SHOT_DIR/creator_studio_suite_screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/creator_studio_suite_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-20-0e-creator-suite-evidence"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
ROOT_SHOT="$SHOT_DIR/creator_studio_root.png"

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

xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding --hf-start-create-room
sleep 3
xcrun simctl io booted screenshot "$ROOT_SHOT"

ROOT_SIZE="$(stat -f%z "$ROOT_SHOT")"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

{
  printf '{\n'
  printf '  "upgrade": "#020.0E",\n'
  printf '  "screenshot_dir": "%s",\n' "$(json_escape "$SHOT_DIR")"
  printf '  "captures": [\n'
  printf '    {"name":"Creator Studio root","path":"%s","bytes":%s,"evidence":"screenshot"}\n' "$(json_escape "$ROOT_SHOT")" "$ROOT_SIZE"
  printf '  ],\n'
  printf '  "source_verified_lower_sections": [\n'
  printf '    "Studio Slate",\n'
  printf '    "Project Package Builder",\n'
  printf '    "Pitch Package",\n'
  printf '    "Media Kit",\n'
  printf '    "Launch Prep"\n'
  printf '  ],\n'
  printf '  "note": "Only the Creator Studio root screenshot is captured automatically; lower sections are verified by source identifiers."\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Creator Studio Suite Screenshot Manifest\n\n'
  printf 'Screenshot directory: `%s`\n\n' "$SHOT_DIR"
  printf -- '- Creator Studio root: `%s` (%s bytes)\n\n' "$ROOT_SHOT" "$ROOT_SIZE"
  printf 'Lower Creator Studio suite sections are source-verified rather than coordinate-scrolled.\n'
} > "$MANIFEST_MD"

printf 'Screenshot manifest: %s\n' "$MANIFEST_MD"
