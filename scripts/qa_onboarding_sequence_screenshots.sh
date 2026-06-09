#!/usr/bin/env bash
set -euo pipefail

BUNDLE_ID="com.higherkey.HighFiveCinemaClean.HighFive"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-18-0b-onboarding-qa"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-18-0b-onboarding-qa"
MANIFEST_JSON="$OUT_DIR/onboarding_screenshot_manifest.json"
MANIFEST_MD="$OUT_DIR/onboarding_screenshot_manifest.md"

mkdir -p "$OUT_DIR"

CAPTURE_NAMES=()
CAPTURE_STATUSES=()
CAPTURE_NOTES=()

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record_capture() {
  CAPTURE_NAMES+=("$1")
  CAPTURE_STATUSES+=("$2")
  CAPTURE_NOTES+=("$3")
}

write_manifest() {
  {
    printf '{\n'
    printf '  "outputDirectory": "%s",\n' "$(json_escape "$OUT_DIR")"
    printf '  "bundleIdentifier": "%s",\n' "$BUNDLE_ID"
    printf '  "captures": [\n'
    for index in "${!CAPTURE_NAMES[@]}"; do
      [[ "$index" -gt 0 ]] && printf ',\n'
      printf '    {"file": "%s", "status": "%s", "note": "%s"}' \
        "$(json_escape "${CAPTURE_NAMES[$index]}")" \
        "$(json_escape "${CAPTURE_STATUSES[$index]}")" \
        "$(json_escape "${CAPTURE_NOTES[$index]}")"
    done
    printf '\n  ]\n'
    printf '}\n'
  } > "$MANIFEST_JSON"

  {
    printf '# Onboarding Screenshot Manifest\n\n'
    printf 'Output: `%s`\n\n' "$OUT_DIR"
    printf '| File | Status | Note |\n'
    printf '| --- | --- | --- |\n'
    for index in "${!CAPTURE_NAMES[@]}"; do
      printf '| `%s` | %s | %s |\n' "${CAPTURE_NAMES[$index]}" "${CAPTURE_STATUSES[$index]}" "${CAPTURE_NOTES[$index]}"
    done
  } > "$MANIFEST_MD"
}

capture_png() {
  local filename="$1"
  local note="$2"
  local path="$OUT_DIR/$filename"

  if xcrun simctl io booted screenshot "$path" >/dev/null; then
    if [[ -s "$path" ]]; then
      record_capture "$filename" "captured" "$note"
      return 0
    fi
  fi

  record_capture "$filename" "missing" "$note"
  return 1
}

launch_and_capture() {
  local filename="$1"
  local note="$2"
  shift 2

  xcrun simctl terminate booted "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch booted "$BUNDLE_ID" "$@" >/dev/null
  sleep 3
  capture_png "$filename" "$note"
}

if ! xcrun simctl list devices booted | rg -q '\(Booted\)'; then
  printf 'No booted simulator found.\n' >&2
  exit 1
fi

TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO

xcrun simctl terminate booted "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl uninstall booted "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install booted "$APP_PATH"

launch_and_capture "highfive-onboarding-intro.png" "Normal launch should show onboarding intro before Home."
launch_and_capture "highfive-onboarding-tilt-peek.png" "QA launch argument should show Tilt / Peek instruction screen." "--hf-onboarding-tilt-peek"
launch_and_capture "highfive-onboarding-instructions.png" "QA launch argument should show final instruction-format screen." "--hf-onboarding-instructions"
launch_and_capture "highfive-onboarding-skip-home.png" "QA bypass should show Home with five locked tabs." "--hf-skip-onboarding"

write_manifest

for required in \
  highfive-onboarding-intro.png \
  highfive-onboarding-tilt-peek.png \
  highfive-onboarding-instructions.png \
  highfive-onboarding-skip-home.png
do
  if [[ ! -s "$OUT_DIR/$required" ]]; then
    printf 'Missing required onboarding screenshot: %s\n' "$OUT_DIR/$required" >&2
    exit 1
  fi
done

printf 'Onboarding screenshot harness complete. Manifest:\n%s\n%s\n' "$MANIFEST_JSON" "$MANIFEST_MD"
