#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-ui-05b-vod-release-launch-chamber-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/vod_release_screenshot_manifest.json"
MD_OUT="$OUT_DIR/vod_release_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-05b-vod-release-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"

failures=()
build_status="failed"
install_status="failed"

add_failure() {
  failures+=("$1")
}

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
  add_failure "build failed"
fi

if [[ "$build_status" == "passed" ]]; then
  if ! xcrun simctl list devices booted | rg 'iPhone' >/dev/null; then
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  fi

  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl uninstall booted "$APP_ID" || true
  if xcrun simctl install booted "$APP_PATH"; then
    install_status="passed"
  else
    add_failure "install failed"
  fi
fi

routes=(
  "default|--hf-start-vod-package|vod_launch_default.png"
  "trailer|--hf-start-vod-package-trailer|vod_launch_trailer.png"
  "poster|--hf-start-vod-package-poster|vod_launch_poster.png"
  "synopsis|--hf-start-vod-package-synopsis|vod_launch_synopsis.png"
  "access|--hf-start-vod-package-access|vod_launch_access.png"
  "release|--hf-start-vod-package-release|vod_launch_release.png"
  "creator_studio|--hf-start-creator-studio|creator_studio_vod_entry.png"
  "social_regression|--hf-start-social-media-kit|social_campaign_regression.png"
  "profile_tabs|--hf-start-profile|profile_tabs.png"
)

capture_route() {
  local route="$1"
  local file="$2"
  local path="$SHOT_DIR/$file"
  xcrun simctl terminate booted "$APP_ID" || true
  if ! xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$route" >/dev/null; then
    add_failure "launch failed for $route"
    return
  fi
  sleep 4
  if ! xcrun simctl io booted screenshot "$path" >/dev/null; then
    add_failure "screenshot failed for $route"
    return
  fi
  if [[ ! -s "$path" ]]; then
    add_failure "empty screenshot for $route"
  fi
}

if [[ "$install_status" == "passed" ]]; then
  for entry in "${routes[@]}"; do
    IFS='|' read -r _ route file <<< "$entry"
    capture_route "$route" "$file"
  done
fi

for entry in "${routes[@]}"; do
  IFS='|' read -r label _ file <<< "$entry"
  if [[ ! -s "$SHOT_DIR/$file" ]]; then
    add_failure "required screenshot missing or empty: $label"
  fi
done

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf '{\n'
  printf '  "upgrade": "UI-05B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "build": "%s",\n' "$build_status"
  printf '  "install": "%s",\n' "$install_status"
  printf '  "coordinate_tapping": false,\n'
  printf '  "fake_screenshots": false,\n'
  printf '  "automated_visual_truth": "non-empty screenshot proof only",\n'
  printf '  "routes": [\n'
  for i in "${!routes[@]}"; do
    IFS='|' read -r label route file <<< "${routes[$i]}"
    [[ "$i" != "0" ]] && printf ',\n'
    printf '    {"name": "%s", "argument": "%s", "screenshot": "%s"}' "$label" "$route" "$SHOT_DIR/$file"
  done
  printf '\n  ],\n'
  printf '  "screenshot_paths": [\n'
  for i in "${!routes[@]}"; do
    IFS='|' read -r _ _ file <<< "${routes[$i]}"
    [[ "$i" != "0" ]] && printf ',\n'
    printf '    "%s"' "$SHOT_DIR/$file"
  done
  printf '\n  ],\n'
  printf '  "screenshot_byte_counts": {\n'
  for i in "${!routes[@]}"; do
    IFS='|' read -r _ _ file <<< "${routes[$i]}"
    path="$SHOT_DIR/$file"
    bytes=0
    [[ -f "$path" ]] && bytes="$(stat -f '%z' "$path")"
    [[ "$i" != "0" ]] && printf ',\n'
    printf '    "%s": %s' "$path" "$bytes"
  done
  printf '\n  },\n'
  printf '  "omissions": [],\n'
  printf '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" != "0" ]] && printf ', '
    printf '"%s"' "$(printf '%s' "${failures[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  done
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# VOD Release Launch Chamber Screenshot Manifest\n\n'
  printf -- '- Upgrade: UI-05B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: %s\n' "$build_status"
  printf -- '- Install: %s\n' "$install_status"
  printf -- '- Coordinate tapping: false\n'
  printf -- '- Fake screenshots: false\n'
  printf -- '- Automated visual truth: non-empty screenshot proof only\n\n'
  printf '## Screenshots\n'
  for entry in "${routes[@]}"; do
    IFS='|' read -r label route file <<< "$entry"
    path="$SHOT_DIR/$file"
    bytes=0
    [[ -f "$path" ]] && bytes="$(stat -f '%z' "$path")"
    printf -- '- %s `%s`: `%s` (%s bytes)\n' "$label" "$route" "$path" "$bytes"
  done
  printf '\n## Omissions\n- None\n\n'
  printf '## Failures\n'
  if (( ${#failures[@]} > 0 )); then
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '- None\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf 'Screenshot harness passed: %s\n' "$JSON_OUT"
