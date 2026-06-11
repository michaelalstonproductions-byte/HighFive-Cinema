#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-25-0b"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SHOT_DIR/screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-25-0b-presentation-evidence"
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
  local arg="$2"
  local path="$3"
  xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
  set +e
  xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$arg"
  local launch_code="$?"
  set -e
  if [[ "$launch_code" -ne 0 ]]; then
    LAUNCH_RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"failed\",\"arg\":\"$(json_escape "$arg")\"}")
    MISSING+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"reason\":\"launch_failed\"}")
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
    CAPTURES+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"bytes\":$size,\"arg\":\"$(json_escape "$arg")\"}")
    LAUNCH_RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"passed\",\"arg\":\"$(json_escape "$arg")\"}")
  else
    LAUNCH_RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"screenshot_failed\",\"arg\":\"$(json_escape "$arg")\"}")
    MISSING+=("{\"name\":\"$(json_escape "$name")\",\"path\":\"$(json_escape "$path")\",\"reason\":\"screenshot_failed\"}")
  fi
}

capture_route "Home Launch" "--hf-start-home" "$SHOT_DIR/00_home_launch.png"
capture_route "Profile Presentation Mode" "--hf-start-profile" "$SHOT_DIR/01_profile_presentation_mode.png"
capture_route "Demo Tour Presentation" "--hf-start-demo-tour" "$SHOT_DIR/02_demo_tour_presentation.png"
capture_route "Developer QA Presentation Proof" "--hf-start-developer-qa" "$SHOT_DIR/03_developer_qa_presentation_proof.png"
capture_route "Home Watch First Story" "--hf-start-home" "$SHOT_DIR/04_home_watch_first_story.png"
capture_route "Movie Detail Watch To Release" "--hf-start-movie-detail" "$SHOT_DIR/05_movie_detail_watch_to_release.png"

{
  printf '{\n'
  printf '  "upgrade": "#025.0B",\n'
  printf '  "screenshot_dir": "%s",\n' "$(json_escape "$SHOT_DIR")"
  printf '  "screenshots_requested": ["00_home_launch.png","01_profile_presentation_mode.png","02_demo_tour_presentation.png","03_developer_qa_presentation_proof.png","04_home_watch_first_story.png","05_movie_detail_watch_to_release.png"],\n'
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
  printf '  "known_limitations": "Screenshots capture launch roots. Lower sections may require source proof when below first viewport."\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Mega Ecosystem Presentation Screenshot Manifest\n\n'
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
      printf -- '- %s: `%s` (%s)\n' "$name" "$path" "$reason"
    done
  fi
  printf '\nKnown limitations: Screenshots capture launch roots. Lower sections may require source proof when below first viewport.\n'
} > "$MANIFEST_MD"

printf 'Screenshot manifest: %s\n' "$MANIFEST_MD"
