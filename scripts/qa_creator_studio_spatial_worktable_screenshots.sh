#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UPGRADE="UI-02B"
EVIDENCE_DIR="/private/tmp/highfive-ui-02b-creator-studio-spatial-worktable-evidence"
SHOT_DIR="$EVIDENCE_DIR/screenshots"
JSON_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_manifest.json"
MD_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-02b-creator-spatial-worktable-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"

build_status="not_run"
install_status="not_run"
status="passed"
failures=()
omissions=()

record_failure() {
  failures+=("$1")
  status="failed"
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
  build_status="failed"
  record_failure "build failed"
fi

if [[ "$build_status" == "passed" ]]; then
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
    install_status="failed"
    record_failure "install failed"
  fi
fi

capture_route() {
  local name="$1"
  local route="$2"
  local output="$3"

  if [[ "$install_status" != "passed" ]]; then
    omissions+=("$name omitted because install did not pass")
    return
  fi

  xcrun simctl terminate booted "$APP_ID" || true
  if ! xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$route"; then
    record_failure "$name launch failed"
    return
  fi
  sleep 4
  if ! xcrun simctl io booted screenshot "$output"; then
    record_failure "$name screenshot failed"
    return
  fi
  if [[ ! -s "$output" ]]; then
    record_failure "$name screenshot is empty"
  fi
}

capture_route "Creator Studio default Look state" "--hf-start-creator-studio" "$SHOT_DIR/creator_studio_worktable.png"
capture_route "Social handoff" "--hf-start-social-media-kit" "$SHOT_DIR/social_media_kit_handoff.png"
capture_route "VOD handoff" "--hf-start-vod-package" "$SHOT_DIR/vod_package_handoff.png"
capture_route "Profile shell" "--hf-start-profile" "$SHOT_DIR/profile_creator_entry.png"

if ! find "$SHOT_DIR" -type f -name '*.png' -exec test -s {} \;; then
  record_failure "one or more screenshots are empty"
fi

byte_count() {
  local file="$1"
  if [[ -f "$file" ]]; then
    stat -f '%z' "$file"
  else
    printf '0'
  fi
}

creator_bytes="$(byte_count "$SHOT_DIR/creator_studio_worktable.png")"
social_bytes="$(byte_count "$SHOT_DIR/social_media_kit_handoff.png")"
vod_bytes="$(byte_count "$SHOT_DIR/vod_package_handoff.png")"
profile_bytes="$(byte_count "$SHOT_DIR/profile_creator_entry.png")"

{
  printf '{\n'
  printf '  "upgrade": "%s",\n' "$UPGRADE"
  printf '  "status": "%s",\n' "$status"
  printf '  "build": "%s",\n' "$build_status"
  printf '  "install": "%s",\n' "$install_status"
  printf '  "routes": {\n'
  printf '    "creator_studio_worktable": "--hf-start-creator-studio",\n'
  printf '    "social_media_kit_handoff": "--hf-start-social-media-kit",\n'
  printf '    "vod_package_handoff": "--hf-start-vod-package",\n'
  printf '    "profile_creator_entry": "--hf-start-profile"\n'
  printf '  },\n'
  printf '  "screenshot_paths": {\n'
  printf '    "creator_studio_worktable": "%s/creator_studio_worktable.png",\n' "$SHOT_DIR"
  printf '    "social_media_kit_handoff": "%s/social_media_kit_handoff.png",\n' "$SHOT_DIR"
  printf '    "vod_package_handoff": "%s/vod_package_handoff.png",\n' "$SHOT_DIR"
  printf '    "profile_creator_entry": "%s/profile_creator_entry.png"\n' "$SHOT_DIR"
  printf '  },\n'
  printf '  "screenshot_byte_counts": {\n'
  printf '    "creator_studio_worktable": %s,\n' "$creator_bytes"
  printf '    "social_media_kit_handoff": %s,\n' "$social_bytes"
  printf '    "vod_package_handoff": %s,\n' "$vod_bytes"
  printf '    "profile_creator_entry": %s\n' "$profile_bytes"
  printf '  },\n'
  printf '  "coordinate_tapping": false,\n'
  printf '  "fake_screenshots": false,\n'
  printf '  "automated_visual_truth": "non-empty screenshot proof only",\n'
  printf '  "omissions": [\n'
  for i in "${!omissions[@]}"; do
    escaped="${omissions[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ $i -eq $((${#omissions[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    escaped="${failures[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ $i -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Creator Studio Spatial Worktable Screenshot Manifest\n\n'
  printf -- '- Upgrade: %s\n' "$UPGRADE"
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: %s\n' "$build_status"
  printf -- '- Install: %s\n' "$install_status"
  printf -- '- Coordinate tapping: false\n'
  printf -- '- Fake screenshots: false\n'
  printf -- '- Automated visual truth: non-empty screenshot proof only\n\n'
  printf '## Screenshots\n'
  printf -- '- Creator Studio: `%s/creator_studio_worktable.png` (%s bytes)\n' "$SHOT_DIR" "$creator_bytes"
  printf -- '- Social handoff: `%s/social_media_kit_handoff.png` (%s bytes)\n' "$SHOT_DIR" "$social_bytes"
  printf -- '- VOD handoff: `%s/vod_package_handoff.png` (%s bytes)\n' "$SHOT_DIR" "$vod_bytes"
  printf -- '- Profile shell: `%s/profile_creator_entry.png` (%s bytes)\n\n' "$SHOT_DIR" "$profile_bytes"
  printf '## Omissions\n'
  if (( ${#omissions[@]} == 0 )); then printf -- '- None\n'; else for item in "${omissions[@]}"; do printf -- '- %s\n' "$item"; done; fi
  printf '\n## Failures\n'
  if (( ${#failures[@]} == 0 )); then printf -- '- None\n'; else for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done; fi
} > "$MD_OUT"

echo "screenshot_harness=$status"
echo "json=$JSON_OUT"
echo "markdown=$MD_OUT"

[[ "$status" == "passed" ]]
