#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-17-0c-screenshots"
JSON_REPORT="$OUT_DIR/source_verification_report.json"
MD_REPORT="$OUT_DIR/source_verification_report.md"

mkdir -p "$OUT_DIR" || exit 1
cd "$ROOT_DIR" || exit 1

PASS_COUNT=0
FAIL_COUNT=0
RESULT_LINES=()

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  RESULT_LINES+=("- PASS: $1")
}

record_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  RESULT_LINES+=("- FAIL: $1")
}

require_text() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  if rg -q "$pattern" "$path"; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

reject_text() {
  local label="$1"
  local pattern="$2"
  shift 2

  if rg -q "$pattern" "$@"; then
    record_fail "$label"
  else
    record_pass "$label"
  fi
}

require_text "Consumer + Rooms Demo Tour entry exists in Developer / QA" "Consumer \\+ Rooms Demo Tour" "HighFive/Views/Profile/ProfileView.swift"
require_text "Demo Tour destination is FinalDemoTourView" "FinalDemoTourView\\(\\)" "HighFive/Views/Profile/ProfileView.swift"
require_text "Profile has HighFive Rooms section" "HighFive Rooms" "HighFive/Views/Profile/ProfileView.swift"
require_text "Developer / QA remains internal" "HFSectionHeader\\(title: \"Internal\"" "HighFive/Views/Profile/ProfileView.swift"

require_text "Act 1 exists" "Act 1 - Watch First" "HighFive/Data/HFFinalDemoTourData.swift"
require_text "Act 2 exists" "Act 2 - HighFive Rooms" "HighFive/Data/HFFinalDemoTourData.swift"
require_text "Act 3 exists" "Act 3 - Internal Validation" "HighFive/Data/HFFinalDemoTourData.swift"
require_text "Screenshot Plan exists" "Screenshot Plan" "HighFive/Views/Demo/FinalDemoTourView.swift"
require_text "The HighFive Story exists" "The HighFive Story" "HighFive/Views/Demo/FinalDemoTourView.swift"
require_text "Figma Source exists" "Figma Source" "HighFive/Views/Demo/FinalDemoTourView.swift"
require_text "Protected Systems Summary exists" "Protected Systems Summary" "HighFive/Views/Demo/FinalDemoTourView.swift"

require_text "Profile root identifier exists" "hf\\.profile\\.root" "HighFive/Views/Profile/ProfileView.swift"
require_text "Profile rooms identifier exists" "hf\\.profile\\.roomsSection" "HighFive/Views/Profile/ProfileView.swift"
require_text "Profile internal identifier exists" "hf\\.profile\\.internalSection" "HighFive/Views/Profile/ProfileView.swift"
require_text "Profile Developer QA identifier exists" "hf\\.profile\\.developerQaButton" "HighFive/Views/Profile/ProfileView.swift"
require_text "Bottom tabs identifier exists" "hf\\.profile\\.bottomTabs" "HighFive/App/HFStreamingRootView.swift"
require_text "Developer QA root identifier exists" "hf\\.developerQa\\.root" "HighFive/Views/Profile/ProfileView.swift"
require_text "Demo Tour button identifier exists" "hf\\.developerQa\\.consumerRoomsDemoTourButton" "HighFive/Views/Profile/ProfileView.swift"
require_text "Demo Tour root identifier exists" "hf\\.demoTour\\.root" "HighFive/Views/Demo/FinalDemoTourView.swift"
require_text "Demo Tour hero identifier exists" "hf\\.demoTour\\.hero" "HighFive/Views/Demo/FinalDemoTourView.swift"
require_text "Demo Tour screenshot plan identifier exists" "hf\\.demoTour\\.screenshotPlan" "HighFive/Views/Demo/FinalDemoTourView.swift"
require_text "Demo step card identifier exists" "hf\\.demoStep\\.card" "HighFive/Components/HFFinalDemoStepCard.swift"

TAB_TITLES="$(rg -o 'title: \"[^\"]+\"' HighFive/App/HFStreamingRootView.swift | sed 's/title: //g' | tr '\n' ' ')"
if [[ "$TAB_TITLES" == *"\"Home\""* && "$TAB_TITLES" == *"\"Search\""* && "$TAB_TITLES" == *"\"Library\""* && "$TAB_TITLES" == *"\"Downloads\""* && "$TAB_TITLES" == *"\"Profile\""* ]]; then
  if [[ "$TAB_TITLES" == *"\"Demo\""* || "$TAB_TITLES" == *"\"Tour\""* || "$TAB_TITLES" == *"\"Rooms\""* || "$TAB_TITLES" == *"\"Create\""* || "$TAB_TITLES" == *"\"Connect\""* || "$TAB_TITLES" == *"\"Launch\""* || "$TAB_TITLES" == *"\"Export\""* || "$TAB_TITLES" == *"\"Developer\""* || "$TAB_TITLES" == *"\"QA\""* ]]; then
    record_fail "Bottom tabs contain forbidden product/internal titles"
  else
    record_pass "Bottom tabs remain Home Search Library Downloads Profile"
  fi
else
  record_fail "Bottom tabs do not expose the expected five titles"
fi

reject_text "Demo Tour is not exposed from consumer screens" "FinalDemoTourView|Consumer \\+ Rooms Demo Tour" HighFive/Views/Home HighFive/Views/Search HighFive/Views/MovieDetail HighFive/Views/DownloadsView.swift HighFive/Views/MyListView.swift
reject_text "No forbidden imports in changed UI sources" "^import (AVKit|StoreKit|Photos|ReplayKit|AuthenticationServices|MessageUI|UniformTypeIdentifiers)$" HighFive/Views/Profile/ProfileView.swift HighFive/Views/Demo/FinalDemoTourView.swift HighFive/Components/HFFinalDemoStepCard.swift HighFive/App/HFStreamingRootView.swift
reject_text "No active forbidden CTAs in Demo Tour source" "Upload Video|Import From Photos|Connect Account|Sign In To Follow|Subscribe Now|Purchase|Buy Ticket|Donate|Start Crowdfunding|Start Chat|Send Message|Post Comment|Notify Followers|Enable Notifications|Track Audience|View Live Analytics|Publish Campaign|Join Waitlist|Export File|Render Package|Download Package|Share Package|Generate ZIP|Create Folder|Open Files|Submit To Platform|Save To Photos|Copy Public Link" HighFive/Views/Demo/FinalDemoTourView.swift HighFive/Data/HFFinalDemoTourData.swift HighFive/Components/HFFinalDemoStepCard.swift

STATUS="passed"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  STATUS="failed"
fi

{
  printf '{\n'
  printf '  "status": "%s",\n' "$STATUS"
  printf '  "passed": %s,\n' "$PASS_COUNT"
  printf '  "failed": %s,\n' "$FAIL_COUNT"
  printf '  "screenshotPlanExists": %s\n' "$(if rg -q "Screenshot Plan" HighFive/Views/Demo/FinalDemoTourView.swift; then echo true; else echo false; fi)"
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Consumer + Rooms Demo Tour Source Verification\n\n'
  printf 'Status: **%s**\n\n' "$STATUS"
  printf 'Passed: %s\n\n' "$PASS_COUNT"
  printf 'Failed: %s\n\n' "$FAIL_COUNT"
  printf '## Checks\n\n'
  printf '%s\n' "${RESULT_LINES[@]}"
} > "$MD_REPORT"

printf 'Source verification %s. Reports:\n%s\n%s\n' "$STATUS" "$JSON_REPORT" "$MD_REPORT"

if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
