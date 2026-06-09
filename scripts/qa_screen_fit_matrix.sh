#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-17-0d-fit-qa"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/screen_fit_screenshot_manifest.json"
MANIFEST_MD="$SCREENSHOT_DIR/screen_fit_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-screen-fit-qa"
BUNDLE_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SCREENSHOT_DIR" || exit 1
cd "$ROOT_DIR" || exit 1

CAPTURE_NAMES=()
CAPTURE_STATUSES=()
CAPTURE_NOTES=()

record_capture() {
  CAPTURE_NAMES+=("$1")
  CAPTURE_STATUSES+=("$2")
  CAPTURE_NOTES+=("$3")
}

capture_png() {
  local name="$1"
  local note="$2"
  local path="$SCREENSHOT_DIR/$name"

  if xcrun simctl io booted screenshot "$path" >/dev/null 2>&1 && [[ -s "$path" ]]; then
    record_capture "$name" "captured" "$note"
    return 0
  fi

  record_capture "$name" "missing" "$note"
  return 1
}

record_missing() {
  record_capture "$1" "missing" "$2"
}

run_with_timeout() {
  local timeout_seconds="$1"
  shift
  "$@" &
  local pid=$!
  local elapsed=0

  while kill -0 "$pid" >/dev/null 2>&1; do
    if [[ "$elapsed" -ge "$timeout_seconds" ]]; then
      kill "$pid" >/dev/null 2>&1 || true
      wait "$pid" >/dev/null 2>&1 || true
      return 124
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  wait "$pid"
}

click_accessibility_button() {
  local label="$1"
  run_with_timeout 18 osascript \
    -e 'tell application "Simulator" to activate' \
    -e 'tell application "System Events" to tell process "Simulator"' \
    -e 'set elementsList to get entire contents of window 1' \
    -e 'repeat with e in elementsList' \
    -e 'set eRef to contents of e' \
    -e 'try' \
    -e "if class of eRef is button and ((name of eRef as text) is \"$label\" or (description of eRef as text) is \"$label\") then click eRef" \
    -e "if class of eRef is button and ((name of eRef as text) is \"$label\" or (description of eRef as text) is \"$label\") then return true" \
    -e 'end try' \
    -e 'end repeat' \
    -e 'return false' \
    -e 'end tell' >/dev/null 2>&1
}

page_down() {
  run_with_timeout 5 osascript \
    -e 'tell application "Simulator" to activate' \
    -e 'tell application "System Events" to key code 121' >/dev/null 2>&1 || true
  sleep 1
}

write_manifest() {
  {
    printf '{\n'
    printf '  "outputDirectory": "%s",\n' "$SCREENSHOT_DIR"
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
    printf '# Screen Fit Screenshot Manifest\n\n'
    printf 'Output: `%s`\n\n' "$SCREENSHOT_DIR"
    printf '| File | Status | Note |\n'
    printf '| --- | --- | --- |\n'
    for index in "${!CAPTURE_NAMES[@]}"; do
      printf '| `%s` | %s | %s |\n' "${CAPTURE_NAMES[$index]}" "${CAPTURE_STATUSES[$index]}" "${CAPTURE_NOTES[$index]}"
    done
  } > "$MANIFEST_MD"
}

launch_app() {
  xcrun simctl terminate booted "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch booted "$BUNDLE_ID" "$@" || return 1
  sleep 3
}

BOOTED_LINE="$(xcrun simctl list devices booted | rg '\(Booted\)' | head -n 1 || true)"
if [[ -z "$BOOTED_LINE" ]]; then
  printf 'No booted simulator found.\n' >&2
  exit 1
fi

BOOTED_NAME="$(printf '%s' "$BOOTED_LINE" | sed 's/^[[:space:]]*//; s/ (.*//')"

TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO || exit 1

xcrun simctl uninstall booted "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install booted "$APP_PATH" || exit 1
launch_app "--hf-skip-onboarding" || exit 1

capture_png "current_booted_home.png" "Immediate Home capture after launch on $BOOTED_NAME."

case "$BOOTED_NAME" in
  *"17 Pro"*) capture_png "home_iphone_17_pro.png" "Home capture on $BOOTED_NAME." ;;
  *"Pro Max"*|*"Plus"*) capture_png "home_iphone_large.png" "Home capture on $BOOTED_NAME." ;;
  *"SE"*|*"mini"*) capture_png "home_iphone_small.png" "Home capture on $BOOTED_NAME." ;;
  *) capture_png "home_iphone_standard.png" "Home capture on $BOOTED_NAME." ;;
esac

[[ -f "$SCREENSHOT_DIR/home_iphone_small.png" ]] || record_missing "home_iphone_small.png" "No small iPhone simulator was booted for this run."
[[ -f "$SCREENSHOT_DIR/home_iphone_standard.png" ]] || record_missing "home_iphone_standard.png" "No standard iPhone simulator was booted for this run."
[[ -f "$SCREENSHOT_DIR/home_iphone_17_pro.png" ]] || record_missing "home_iphone_17_pro.png" "No iPhone 17 Pro simulator was booted for this run."
[[ -f "$SCREENSHOT_DIR/home_iphone_large.png" ]] || record_missing "home_iphone_large.png" "No large iPhone simulator was booted for this run."

if click_accessibility_button "Profile"; then
  sleep 2
  capture_png "profile_iphone_17_pro.png" "Profile capture after bounded tab navigation on $BOOTED_NAME."
else
  if launch_app "--hf-start-profile"; then
    capture_png "profile_iphone_17_pro.png" "Profile capture after QA-only launch fallback on $BOOTED_NAME."
  else
    record_missing "profile_iphone_17_pro.png" "Profile launch fallback failed."
  fi
fi

if [[ -f "$SCREENSHOT_DIR/profile_iphone_17_pro.png" ]]; then
  page_down
  if click_accessibility_button "Developer QA Hub, internal validation and release readiness"; then
    sleep 2
    capture_png "developer_qa_iphone_17_pro.png" "Developer / QA capture after bounded internal navigation on $BOOTED_NAME."
  else
    record_missing "developer_qa_iphone_17_pro.png" "Developer / QA navigation was unavailable or timed out."
  fi
else
  record_missing "developer_qa_iphone_17_pro.png" "Developer / QA skipped because Profile capture was unavailable."
fi

write_manifest
printf 'Screen fit screenshot matrix complete for %s. Manifest:\n%s\n%s\n' "$BOOTED_NAME" "$MANIFEST_JSON" "$MANIFEST_MD"
