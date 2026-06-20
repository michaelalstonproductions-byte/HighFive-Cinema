#!/usr/bin/env bash
set -o pipefail

OUT_DIR="/private/tmp/highfive-ui-04b-social-campaign-spatial-authoring-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/social_campaign_screenshot_manifest.json"
MD_OUT="$OUT_DIR/social_campaign_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-04b-social-campaign-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"

failures=()
omissions=()
routes=(
  "default|--hf-start-social-media-kit|social_campaign_default.png"
  "poster|--hf-start-social-media-kit-poster|social_campaign_poster.png"
  "reel|--hf-start-social-media-kit-reel|social_campaign_reel.png"
  "caption|--hf-start-social-media-kit-caption|social_campaign_caption.png"
  "story|--hf-start-social-media-kit-story|social_campaign_story.png"
  "platforms|--hf-start-social-media-kit-platforms|social_campaign_platforms.png"
  "creator_studio|--hf-start-creator-studio|creator_studio_social_entry.png"
  "profile_tabs|--hf-start-profile|profile_tabs.png"
)

build_status="failed"
install_status="failed"

TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
build_exit=$?
if [ "$build_exit" -eq 0 ]; then
  build_status="passed"
else
  failures+=("build failed with exit code $build_exit")
fi

if [ "$build_status" = "passed" ]; then
  xcrun simctl list devices booted | rg 'iPhone' || {
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  }

  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl uninstall booted "$APP_ID" || true
  if xcrun simctl install booted "$APP_PATH"; then
    install_status="passed"
  else
    failures+=("install failed")
  fi
fi

capture_route() {
  local name="$1"
  local route="$2"
  local file="$3"
  local path="$SHOT_DIR/$file"

  if [ "$install_status" != "passed" ]; then
    omissions+=("$name skipped because install did not pass")
    return
  fi

  xcrun simctl terminate booted "$APP_ID" || true
  if ! xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$route"; then
    failures+=("$name launch failed for $route")
    return
  fi
  sleep 4
  if ! xcrun simctl io booted screenshot "$path"; then
    failures+=("$name screenshot failed")
    return
  fi
  if [ ! -s "$path" ]; then
    failures+=("$name screenshot is empty")
  fi
}

for entry in "${routes[@]}"; do
  IFS='|' read -r name route file <<< "$entry"
  capture_route "$name" "$route" "$file"
done

required_missing=0
for entry in "${routes[@]}"; do
  IFS='|' read -r _name _route file <<< "$entry"
  if [ ! -s "$SHOT_DIR/$file" ]; then
    required_missing=1
  fi
done
[ "$required_missing" = "0" ] || failures+=("one or more required screenshots missing or empty")

status="passed"
[ "${#failures[@]}" -eq 0 ] || status="failed"

{
  printf -- '{\n'
  printf -- '  "upgrade": "UI-04B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "build": "%s",\n' "$build_status"
  printf -- '  "install": "%s",\n' "$install_status"
  printf -- '  "coordinate_tapping": false,\n'
  printf -- '  "fake_screenshots": false,\n'
  printf -- '  "automated_visual_truth": "non-empty screenshot proof only",\n'
  printf -- '  "routes": [\n'
  for i in "${!routes[@]}"; do
    IFS='|' read -r name route file <<< "${routes[$i]}"
    comma=","
    [ "$i" = "$((${#routes[@]} - 1))" ] && comma=""
    printf -- '    {"name": "%s", "route": "%s", "screenshot": "%s"}%s\n' "$name" "$route" "$SHOT_DIR/$file" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "screenshot_paths": {\n'
  for i in "${!routes[@]}"; do
    IFS='|' read -r name _route file <<< "${routes[$i]}"
    comma=","
    [ "$i" = "$((${#routes[@]} - 1))" ] && comma=""
    printf -- '    "%s": "%s"%s\n' "$name" "$SHOT_DIR/$file" "$comma"
  done
  printf -- '  },\n'
  printf -- '  "screenshot_byte_counts": {\n'
  for i in "${!routes[@]}"; do
    IFS='|' read -r name _route file <<< "${routes[$i]}"
    bytes=0
    [ -f "$SHOT_DIR/$file" ] && bytes="$(stat -f%z "$SHOT_DIR/$file")"
    comma=","
    [ "$i" = "$((${#routes[@]} - 1))" ] && comma=""
    printf -- '    "%s": %s%s\n' "$name" "$bytes" "$comma"
  done
  printf -- '  },\n'
  printf -- '  "omissions": [\n'
  for i in "${!omissions[@]}"; do
    comma=","
    [ "$i" = "$((${#omissions[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${omissions[$i]//\"/\\\"}" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [ "$i" = "$((${#failures[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${failures[$i]//\"/\\\"}" "$comma"
  done
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Social Campaign Screenshot Manifest\n\n'
  printf -- '- Upgrade: UI-04B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: %s\n' "$build_status"
  printf -- '- Install: %s\n' "$install_status"
  printf -- '- Coordinate tapping: false\n'
  printf -- '- Fake screenshots: false\n'
  printf -- '- Automated visual truth: non-empty screenshot proof only\n\n'
  printf -- '## Screenshots\n'
  for entry in "${routes[@]}"; do
    IFS='|' read -r name route file <<< "$entry"
    bytes=0
    [ -f "$SHOT_DIR/$file" ] && bytes="$(stat -f%z "$SHOT_DIR/$file")"
    printf -- '- %s: `%s` via `%s` (%s bytes)\n' "$name" "$SHOT_DIR/$file" "$route" "$bytes"
  done
  printf -- '\n## Omissions\n'
  [ "${#omissions[@]}" -eq 0 ] && printf -- '- None\n'
  for item in "${omissions[@]}"; do printf -- '- %s\n' "$item"; done
  printf -- '\n## Failures\n'
  [ "${#failures[@]}" -eq 0 ] && printf -- '- None\n'
  for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
} > "$MD_OUT"

if [ "$status" != "passed" ]; then
  printf -- 'Screenshot harness failed. See %s\n' "$MD_OUT" >&2
  exit 1
fi

printf -- 'Screenshot harness passed. Evidence written to %s and %s\n' "$JSON_OUT" "$MD_OUT"
