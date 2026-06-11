#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-26-0b-functional-core-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SHOT_DIR/functional_app_core_screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/functional_app_core_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-26-0b-functional-core-evidence"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"

mkdir -p "$SHOT_DIR"
cd "$ROOT_DIR"

CAPTURES=()
MISSING=()
LAUNCH_RESULTS=()
BUILD_STATUS="not_run"
INSTALL_STATUS="not_run"
BOOTED_SIMULATOR="$(xcrun simctl list devices booted | sed -n 's/^[[:space:]]*\([^()]*\) (.*/\1/p' | head -1 | sed 's/[[:space:]]*$//')"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if [[ -z "$BOOTED_SIMULATOR" ]]; then
  printf 'No booted simulator found. Boot a simulator before running screenshot QA.\n' >&2
  exit 1
fi

TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build
BUILD_STATUS="passed"

xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
xcrun simctl uninstall booted "$APP_ID" >/dev/null 2>&1 || true
xcrun simctl install booted "$APP_PATH"
INSTALL_STATUS="passed"

capture_route() {
  local name="$1"
  local args="$2"
  local path="$3"
  local required="$4"
  xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
  set +e
  # shellcheck disable=SC2086
  xcrun simctl launch booted "$APP_ID" $args
  local launch_code="$?"
  set -e
  if [[ "$launch_code" -ne 0 ]]; then
    LAUNCH_RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"failed\",\"args\":\"$(json_escape "$args")\",\"required\":$required}")
    MISSING+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"reason\":\"launch_failed\",\"required\":$required}")
    return
  fi
  sleep 3
  set +e
  xcrun simctl io booted screenshot "$path"
  local screenshot_code="$?"
  set -e
  if [[ "$screenshot_code" -eq 0 && -s "$path" ]]; then
    local size
    size="$(stat -f%z "$path")"
    CAPTURES+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"bytes\":$size,\"args\":\"$(json_escape "$args")\",\"required\":$required}")
    LAUNCH_RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"passed\",\"args\":\"$(json_escape "$args")\",\"required\":$required}")
  else
    LAUNCH_RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"screenshot_failed\",\"args\":\"$(json_escape "$args")\",\"required\":$required}")
    MISSING+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"reason\":\"screenshot_failed\",\"required\":$required}")
  fi
}

capture_route "Home Functional Core" "--hf-skip-onboarding --hf-start-home" "$SHOT_DIR/home_functional_core.png" true
capture_route "Movie Detail Functional Core" "--hf-skip-onboarding --hf-start-movie-detail" "$SHOT_DIR/movie_detail_functional_core.png" true
capture_route "Library Functional State" "--hf-skip-onboarding --hf-start-library" "$SHOT_DIR/library_functional_state.png" true
capture_route "Downloads Functional State" "--hf-skip-onboarding --hf-start-downloads" "$SHOT_DIR/downloads_functional_state.png" true
capture_route "Connect Local Updates" "--hf-skip-onboarding --hf-start-connect-room" "$SHOT_DIR/connect_local_updates.png" true
capture_route "Launch Local Checklist" "--hf-skip-onboarding --hf-start-launch-room" "$SHOT_DIR/launch_local_checklist.png" true
capture_route "Export Delivery Summary" "--hf-skip-onboarding --hf-start-export-room" "$SHOT_DIR/export_delivery_summary.png" true
capture_route "Profile Functional Core" "--hf-skip-onboarding --hf-start-profile" "$SHOT_DIR/profile_functional_core.png" true
capture_route "Demo Tour Functional Core" "--hf-skip-onboarding --hf-start-demo-tour" "$SHOT_DIR/demo_tour_functional_core.png" false
capture_route "Onboarding Brand Intro" "--hf-reset-onboarding" "$SHOT_DIR/onboarding_brand_intro.png" false

xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true

{
  printf '{\n'
  printf '  "upgrade": "#026.0B",\n'
  printf '  "screenshot_dir": "%s",\n' "$(json_escape "$SHOT_DIR")"
  printf '  "screenshots_required": ["home_functional_core.png","movie_detail_functional_core.png","library_functional_state.png","downloads_functional_state.png","connect_local_updates.png","launch_local_checklist.png","export_delivery_summary.png","profile_functional_core.png"],\n'
  printf '  "screenshots_optional": ["demo_tour_functional_core.png","onboarding_brand_intro.png"],\n'
  printf '  "screenshots_captured": [\n'
  for i in "${!CAPTURES[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${CAPTURES[$i]}"
  done
  printf '\n  ],\n'
  printf '  "missing_screenshots": [\n'
  for i in "${!MISSING[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${MISSING[$i]}"
  done
  printf '\n  ],\n'
  printf '  "booted_simulator": "%s",\n' "$(json_escape "$BOOTED_SIMULATOR")"
  printf '  "build_status": "%s",\n' "$BUILD_STATUS"
  printf '  "install_status": "%s",\n' "$INSTALL_STATUS"
  printf '  "launch_status": [\n'
  for i in "${!LAUNCH_RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${LAUNCH_RESULTS[$i]}"
  done
  printf '\n  ],\n'
  printf '  "known_limitations": "Screenshots capture route roots. Controls below the first viewport require source proof and manual review."\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Functional App Core Screenshot Manifest\n\n'
  printf 'Booted simulator: `%s`\n' "$BOOTED_SIMULATOR"
  printf 'Build status: %s\n' "$BUILD_STATUS"
  printf 'Install status: %s\n\n' "$INSTALL_STATUS"
  printf 'Captured screenshots:\n'
  for row in "${CAPTURES[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    path="$(printf '%s' "$row" | sed -E 's/.*"path":"([^"]+)".*/\1/')"
    bytes="$(printf '%s' "$row" | sed -E 's/.*"bytes":([0-9]+).*/\1/')"
    printf -- '- %s: `%s` (%s bytes)\n' "$name" "$path" "$bytes"
  done
  printf '\nMissing screenshots:\n'
  if [[ "${#MISSING[@]}" -eq 0 ]]; then
    printf -- '- none\n'
  else
    for row in "${MISSING[@]}"; do
      name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
      path="$(printf '%s' "$row" | sed -E 's/.*"path":"([^"]+)".*/\1/')"
      reason="$(printf '%s' "$row" | sed -E 's/.*"reason":"([^"]+)".*/\1/')"
      required="$(printf '%s' "$row" | sed -E 's/.*"required":([^,}]+).*/\1/')"
      printf -- '- %s: `%s` (%s, required=%s)\n' "$name" "$path" "$reason" "$required"
    done
  fi
  printf '\nKnown limitations: Screenshots capture route roots. Controls below the first viewport require source proof and manual review.\n'
} > "$MANIFEST_MD"

printf 'Screenshot manifest: %s\n' "$MANIFEST_MD"
