#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-17-0c-screenshots"
MANIFEST_JSON="$OUT_DIR/screenshot_manifest.json"
MANIFEST_MD="$OUT_DIR/screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-demo-tour-qa"
BUNDLE_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$OUT_DIR" || exit 1
cd "$ROOT_DIR" || exit 1

CAPTURE_NAMES=()
CAPTURE_STATUSES=()
CAPTURE_NOTES=()

manifest_record() {
  CAPTURE_NAMES+=("$1")
  CAPTURE_STATUSES+=("$2")
  CAPTURE_NOTES+=("$3")
}

capture_png() {
  local name="$1"
  local note="$2"
  local path="$OUT_DIR/$name"

  if xcrun simctl io booted screenshot "$path" >/dev/null 2>&1 && [[ -s "$path" ]]; then
    manifest_record "$name" "captured" "$note"
    return 0
  fi

  manifest_record "$name" "missing" "$note"
  return 1
}

open_simulator_ui() {
  open -a Simulator >/dev/null 2>&1 || true
  sleep 2
  osascript -e 'tell application "Simulator" to activate' >/dev/null 2>&1 || true
}

click_button_description() {
  local description="$1"
  osascript \
    -e 'with timeout of 12 seconds' \
    -e 'tell application "System Events" to tell process "Simulator"' \
    -e 'set elementsList to get entire contents of window 1' \
    -e 'repeat with e in elementsList' \
    -e 'set eRef to contents of e' \
    -e 'try' \
    -e "if class of eRef is button and description of eRef is \"$description\" then click eRef" \
    -e "if class of eRef is button and description of eRef is \"$description\" then return true" \
    -e 'end try' \
    -e 'end repeat' \
    -e 'end tell' \
    -e 'end timeout' >/dev/null 2>&1
}

click_button_name() {
  local name="$1"
  osascript \
    -e 'with timeout of 12 seconds' \
    -e 'tell application "System Events" to tell process "Simulator"' \
    -e 'set elementsList to get entire contents of window 1' \
    -e 'repeat with e in elementsList' \
    -e 'set eRef to contents of e' \
    -e 'try' \
    -e "if class of eRef is button and ((name of eRef as text) is \"$name\" or (description of eRef as text) is \"$name\") then click eRef" \
    -e "if class of eRef is button and ((name of eRef as text) is \"$name\" or (description of eRef as text) is \"$name\") then return true" \
    -e 'end try' \
    -e 'end repeat' \
    -e 'end tell' \
    -e 'end timeout' >/dev/null 2>&1
}

click_back() {
  osascript \
    -e 'with timeout of 12 seconds' \
    -e 'tell application "System Events" to tell process "Simulator"' \
    -e 'set elementsList to get entire contents of window 1' \
    -e 'repeat with e in elementsList' \
    -e 'set eRef to contents of e' \
    -e 'try' \
    -e 'if class of eRef is button and description of eRef is "Back" then click eRef' \
    -e 'if class of eRef is button and description of eRef is "Back" then return true' \
    -e 'end try' \
    -e 'end repeat' \
    -e 'end tell' \
    -e 'end timeout' >/dev/null 2>&1
}

normalize_to_profile() {
  open_simulator_ui
  click_back
  sleep 1
  click_back
  sleep 1
  click_button_name "Profile"
  sleep 2
}

page_down() {
  osascript -e 'tell application "Simulator" to activate' -e 'tell application "System Events" to key code 121' >/dev/null 2>&1 || true
  sleep 1
}

build_app() {
  TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
    -project HighFive.xcodeproj \
    -scheme HighFive \
    -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO
}

write_manifest() {
  {
    printf '{\n'
    printf '  "outputDirectory": "%s",\n' "$OUT_DIR"
    printf '  "bundleIdentifier": "%s",\n' "$BUNDLE_ID"
    printf '  "captures": [\n'
    for index in "${!CAPTURE_NAMES[@]}"; do
      [[ "$index" -gt 0 ]] && printf ',\n'
      printf '    {"file": "%s", "status": "%s", "note": "%s"}' "${CAPTURE_NAMES[$index]}" "${CAPTURE_STATUSES[$index]}" "${CAPTURE_NOTES[$index]}"
    done
    printf '\n  ]\n'
    printf '}\n'
  } > "$MANIFEST_JSON"

  {
    printf '# Consumer + Rooms Demo Tour Screenshot Manifest\n\n'
    printf 'Output: `%s`\n\n' "$OUT_DIR"
    printf '| File | Status | Note |\n'
    printf '| --- | --- | --- |\n'
    for index in "${!CAPTURE_NAMES[@]}"; do
      printf '| `%s` | %s | %s |\n' "${CAPTURE_NAMES[$index]}" "${CAPTURE_STATUSES[$index]}" "${CAPTURE_NOTES[$index]}"
    done
  } > "$MANIFEST_MD"
}

if ! xcrun simctl list devices booted | rg -q '\(Booted\)'; then
  printf 'No booted simulator found.\n' >&2
  exit 1
fi

build_app || exit 1

xcrun simctl terminate booted "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl uninstall booted "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install booted "$APP_PATH" || exit 1
xcrun simctl launch booted "$BUNDLE_ID" --hf-skip-onboarding || exit 1
sleep 3

capture_png "00-home-launch.png" "Captured immediately after clean install and launch."

normalize_to_profile
capture_png "01-profile-rooms-and-tabs.png" "Profile tab after accessibility navigation; should show HighFive Rooms and bottom tabs."

page_down
capture_png "02-profile-internal-developer-qa.png" "Profile after one page-down attempt toward Internal / Developer QA."

normalize_to_profile
click_button_description "Developer QA Hub, internal validation and release readiness"
sleep 2
capture_png "03-developer-qa-hub.png" "Developer / QA Hub opened from Profile Internal section."

click_button_description "Consumer + Rooms Demo Tour, Guided proof path for Watch, HighFive Rooms, Product Spine, and internal safety."
sleep 2
capture_png "04-consumer-rooms-demo-tour-hero.png" "Demo Tour opened from Developer / QA; hero proof."
capture_png "05-consumer-rooms-demo-tour-act1.png" "Demo Tour top view includes Act 1 Watch First."

page_down
capture_png "06-consumer-rooms-demo-tour-act2-rooms.png" "Best-effort page-down capture for Act 2 HighFive Rooms."
page_down
capture_png "07-consumer-rooms-demo-tour-act3-internal-validation.png" "Best-effort page-down capture for Act 3 Internal Validation."
page_down
capture_png "08-consumer-rooms-demo-tour-screenshot-plan.png" "Best-effort page-down capture for Screenshot Plan."
page_down
capture_png "09-consumer-rooms-demo-tour-highfive-story.png" "Best-effort page-down capture for The HighFive Story."
page_down
capture_png "10-consumer-rooms-demo-tour-figma-source.png" "Best-effort page-down capture for Figma Source."
page_down
capture_png "11-consumer-rooms-demo-tour-protected-systems.png" "Best-effort page-down capture for Protected Systems Summary."

write_manifest
printf 'Screenshot harness complete. Manifest:\n%s\n%s\n' "$MANIFEST_JSON" "$MANIFEST_MD"
