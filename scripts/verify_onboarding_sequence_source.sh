#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/Volumes/Scratch SSD/highfive-phase-18-0b-onboarding-qa"
REPORT_JSON="$OUT_DIR/onboarding_source_verification.json"
REPORT_MD="$OUT_DIR/onboarding_source_verification.md"
SOURCE_FILE="HighFive/App/HFStreamingRootView.swift"

mkdir -p "$OUT_DIR"

PASS_COUNT=0
FAIL_COUNT=0
RESULTS_JSON=""
RESULTS_MD=""

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record() {
  local name="$1"
  local status="$2"
  local detail="$3"

  if [[ "$status" == "pass" ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi

  local comma=""
  [[ -n "$RESULTS_JSON" ]] && comma=","
  RESULTS_JSON="${RESULTS_JSON}${comma}
    {\"name\":\"$(json_escape "$name")\",\"status\":\"$status\",\"detail\":\"$(json_escape "$detail")\"}"
  RESULTS_MD="${RESULTS_MD}| $name | $status | $detail |
"
}

require_text() {
  local name="$1"
  local pattern="$2"
  local file="$3"
  if rg -q -- "$pattern" "$file"; then
    record "$name" "pass" "Found expected source text."
  else
    record "$name" "fail" "Missing pattern: $pattern"
  fi
}

reject_text() {
  local name="$1"
  local pattern="$2"
  shift 2
  if rg -q -- "$pattern" "$@"; then
    record "$name" "fail" "Forbidden text matched: $pattern"
  else
    record "$name" "pass" "No forbidden text matched."
  fi
}

require_text "Active SwiftUI onboarding source" "HFLaunchIntroSequenceView" "$SOURCE_FILE"
require_text "Intro screen exists" "HFLaunchIntroVideoScreen" "$SOURCE_FILE"
require_text "Tilt Peek screen exists" "HFLaunchMotionInstructionScreen" "$SOURCE_FILE"
require_text "Instruction screen exists" "HFLaunchInstructionFormatScreen" "$SOURCE_FILE"
require_text "Enter Home exists" "Enter Home" "$SOURCE_FILE"
require_text "Skip onboarding arg exists" "--hf-skip-onboarding" "$SOURCE_FILE"
require_text "Start profile arg exists" "--hf-start-profile" "$SOURCE_FILE"
require_text "Intro launch arg exists" "--hf-onboarding-intro" "$SOURCE_FILE"
require_text "Tilt Peek launch arg exists" "--hf-onboarding-tilt-peek" "$SOURCE_FILE"
require_text "Instructions launch arg exists" "--hf-onboarding-instructions" "$SOURCE_FILE"
require_text "Intro accessibility id" "hf\\.onboarding\\.intro" "$SOURCE_FILE"
require_text "Tilt Peek accessibility id" "hf\\.onboarding\\.tiltPeek" "$SOURCE_FILE"
require_text "Instructions accessibility id" "hf\\.onboarding\\.instructions" "$SOURCE_FILE"
require_text "Continue button id" "hf\\.onboarding\\.continueButton" "$SOURCE_FILE"
require_text "Skip button id" "hf\\.onboarding\\.skipButton" "$SOURCE_FILE"
require_text "Enter Home button id" "hf\\.onboarding\\.enterHomeButton" "$SOURCE_FILE"
require_text "Tilt row id" "hf\\.onboarding\\.row\\.tilt" "$SOURCE_FILE"
require_text "Peek row id" "hf\\.onboarding\\.row\\.peek" "$SOURCE_FILE"
require_text "Watch row id" "hf\\.onboarding\\.row\\.watch" "$SOURCE_FILE"

require_text "Screen fit harness skips onboarding" "--hf-skip-onboarding" "scripts/qa_screen_fit_matrix.sh"
require_text "Demo tour harness skips onboarding" "--hf-skip-onboarding" "scripts/qa_consumer_rooms_demo_tour_screenshots.sh"

MEDIA_SENSOR_PATTERN="AV""Kit|AV""Player|AV""Foundation|Core""Motion|AR""Kit|CM""Motion|Store""Kit|Pho""tos|Replay""Kit|URL""Session|File""Manager|Share""Link|Pho""tosPicker|UI""DocumentPicker|UI""ImagePickerController|PH""Picker|AV""Capture"
reject_text "No forbidden media or sensor code in onboarding source" "$MEDIA_SENSOR_PATTERN" "$SOURCE_FILE"

BOTTOM_TABS=$(rg -n -- 'HFTabItem\(value: \.(home|search|library|downloads|profile), title: "(Home|Search|Library|Downloads|Profile)"' "$SOURCE_FILE" | wc -l | tr -d ' ')
if [[ "$BOTTOM_TABS" == "5" ]]; then
  record "Bottom tabs locked" "pass" "Found exactly the five expected tab declarations."
else
  record "Bottom tabs locked" "fail" "Expected 5 locked tab declarations, found $BOTTOM_TABS."
fi

PROTECTED_CHANGED=$(git diff --name-only | egrep 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset' || true)
if [[ -z "$PROTECTED_CHANGED" ]]; then
  record "Protected paths unchanged" "pass" "No protected paths appear in git diff."
else
  record "Protected paths unchanged" "fail" "$PROTECTED_CHANGED"
fi

INACTIVE_CHANGED=$(git diff --name-only | egrep 'HighFive/App/Onboarding/LaunchOnboardingViewController.swift|HighFive/App/App/HKV1_SceneDelegate.swift|HighFive.xcodeproj/project.pbxproj' || true)
if [[ -z "$INACTIVE_CHANGED" ]]; then
  record "Inactive onboarding and project unchanged" "pass" "No inactive UIKit onboarding, SceneDelegate, or project file changes."
else
  record "Inactive onboarding and project unchanged" "fail" "$INACTIVE_CHANGED"
fi

{
  printf '{\n'
  printf '  "passCount": %s,\n' "$PASS_COUNT"
  printf '  "failCount": %s,\n' "$FAIL_COUNT"
  printf '  "results": [%s\n  ]\n' "$RESULTS_JSON"
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Onboarding Source Verification\n\n'
  printf 'Pass: %s\n\nFail: %s\n\n' "$PASS_COUNT" "$FAIL_COUNT"
  printf '| Check | Status | Detail |\n'
  printf '| --- | --- | --- |\n'
  printf '%s' "$RESULTS_MD"
} > "$REPORT_MD"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  printf 'Onboarding source verification failed. See:\n%s\n%s\n' "$REPORT_JSON" "$REPORT_MD" >&2
  exit 1
fi

printf 'Onboarding source verification passed. Reports:\n%s\n%s\n' "$REPORT_JSON" "$REPORT_MD"
