#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-17-0d-fit-qa"
JSON_REPORT="$OUT_DIR/screen_fit_source_verification.json"
MD_REPORT="$OUT_DIR/screen_fit_source_verification.md"

mkdir -p "$OUT_DIR" || exit 1
cd "$ROOT_DIR" || exit 1

PASS_COUNT=0
FAIL_COUNT=0
RESULTS=()

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  RESULTS+=("- PASS: $1")
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  RESULTS+=("- FAIL: $1")
}

require() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg -q "$pattern" "$path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

reject() {
  local label="$1"
  local pattern="$2"
  shift 2
  if rg -q "$pattern" "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

require "Responsive fit helper exists" "enum HFResponsiveFit" "HighFive/DesignSystem/HFResponsiveFit.swift"
require "Home uses responsive fit helper" "HFResponsiveFit" "HighFive/Views/Home/HomeView.swift"
require "Bottom tab uses responsive fit helper" "HFResponsiveFit" "HighFive/Components/HFTabBar.swift"
require "Coming Soon badge is intentional two-line text" "Coming\\\\nSoon" "HighFive/Components/HFPosterCard.swift"
require "Developer / QA remains in Profile" "DeveloperQAHubView\\(\\)" "HighFive/Views/Profile/ProfileView.swift"
require "HighFive Rooms remains in Profile" "HighFive Rooms" "HighFive/Views/Profile/ProfileView.swift"

TAB_TITLES="$(rg -o 'title: \"[^\"]+\"' HighFive/App/HFStreamingRootView.swift | sed 's/title: //g' | tr '\n' ' ')"
if [[ "$TAB_TITLES" == *"\"Home\""* && "$TAB_TITLES" == *"\"Search\""* && "$TAB_TITLES" == *"\"Library\""* && "$TAB_TITLES" == *"\"Downloads\""* && "$TAB_TITLES" == *"\"Profile\""* ]]; then
  if [[ "$TAB_TITLES" == *"\"Demo\""* || "$TAB_TITLES" == *"\"Tour\""* || "$TAB_TITLES" == *"\"Rooms\""* || "$TAB_TITLES" == *"\"Create\""* || "$TAB_TITLES" == *"\"Connect\""* || "$TAB_TITLES" == *"\"Launch\""* || "$TAB_TITLES" == *"\"Export\""* || "$TAB_TITLES" == *"\"Developer\""* || "$TAB_TITLES" == *"\"QA\""* ]]; then
    fail "Bottom tabs contain forbidden product/internal titles"
  else
    pass "Bottom tabs remain Home Search Library Downloads Profile"
  fi
else
  fail "Bottom tabs do not expose the expected five titles"
fi

reject "Demo Tour is not exposed from consumer screens" "FinalDemoTourView|Consumer \\+ Rooms Demo Tour" HighFive/Views/Home HighFive/Views/Search HighFive/Views/MovieDetail HighFive/Views/DownloadsView.swift HighFive/Views/MyListView.swift
reject "No forbidden imports in changed fit sources" "^import (AVKit|StoreKit|Photos|ReplayKit|AuthenticationServices|MessageUI|UniformTypeIdentifiers)$" HighFive/Views/Home/HomeView.swift HighFive/Components/HFTabBar.swift HighFive/Components/HFPosterCard.swift HighFive/DesignSystem/HFResponsiveFit.swift
reject "No new hard clipped Home/bottom-tab fit source" "clipped\\(" HighFive/Views/Home/HomeView.swift HighFive/Components/HFTabBar.swift
reject "No active live-system CTA in fit source" "Upload Video|Import From Photos|Subscribe|Purchase|Buy Ticket|Donate|Start Chat|Send Message|Post Comment|Notify Followers|Enable Notifications|Track Audience|View Live Analytics|Publish Campaign|Join Waitlist|Export File|Render Package|Download Package|Share Package|Generate ZIP|Create Folder|Open Files|Submit To Platform|Save To Photos|Copy Public Link" HighFive/Views/Home/HomeView.swift HighFive/Components/HFTabBar.swift HighFive/Components/HFPosterCard.swift

STATUS="passed"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  STATUS="failed"
fi

{
  printf '{\n'
  printf '  "status": "%s",\n' "$STATUS"
  printf '  "passed": %s,\n' "$PASS_COUNT"
  printf '  "failed": %s\n' "$FAIL_COUNT"
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Screen Fit Source Verification\n\n'
  printf 'Status: **%s**\n\n' "$STATUS"
  printf 'Passed: %s\n\n' "$PASS_COUNT"
  printf 'Failed: %s\n\n' "$FAIL_COUNT"
  printf '## Checks\n\n'
  printf '%s\n' "${RESULTS[@]}"
} > "$MD_REPORT"

printf 'Screen fit source verification %s. Reports:\n%s\n%s\n' "$STATUS" "$JSON_REPORT" "$MD_REPORT"

if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
