#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-25-0b"
JSON_REPORT="$OUT_DIR/mega_ecosystem_presentation_source_verification.json"
MD_REPORT="$OUT_DIR/mega_ecosystem_presentation_source_verification.md"
PROFILE_SOURCE="$ROOT_DIR/HighFive/Views/Profile/ProfileView.swift"
DEMO_SOURCE="$ROOT_DIR/HighFive/Views/Demo/FinalDemoTourView.swift"
HOME_SOURCE="$ROOT_DIR/HighFive/Views/Home/HomeView.swift"
DETAIL_SOURCE="$ROOT_DIR/HighFive/Views/MovieDetail/MovieDetailView.swift"
ROOT_SOURCE="$ROOT_DIR/HighFive/App/HFStreamingRootView.swift"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

RESULTS=()
FAILURES=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record() {
  local name="$1"
  local status="$2"
  local detail="$3"
  RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"$(json_escape "$status")\",\"detail\":\"$(json_escape "$detail")\"}")
  if [[ "$status" == "fail" ]]; then
    FAILURES=$((FAILURES + 1))
  fi
}

require_rg() {
  local name="$1"
  local pattern="$2"
  local file="$3"
  if [[ ! -f "$file" ]]; then
    record "$name" "fail" "Missing file: $file"
  elif rg -q "$pattern" "$file"; then
    record "$name" "pass" "$pattern"
  else
    record "$name" "fail" "Missing: $pattern"
  fi
}

reject_rg() {
  local name="$1"
  local pattern="$2"
  local file="$3"
  if [[ -f "$file" ]] && rg -q "$pattern" "$file"; then
    record "$name" "fail" "Unexpected match: $pattern"
  else
    record "$name" "pass" "No match: $pattern"
  fi
}

optional_signal() {
  local name="$1"
  local identifier="$2"
  local copy="$3"
  local file="$4"
  local diff_name="$5"
  if [[ ! -f "$file" ]]; then
    record "$name" "absent_but_optional" "Missing optional file: $file"
  elif rg -q "$identifier" "$file" && rg -q "$copy" "$file"; then
    record "$name" "present" "$identifier / $copy"
  elif git diff --name-only | rg -q "^${diff_name}$"; then
    record "$name" "fail" "touched_but_missing: $identifier / $copy"
  else
    record "$name" "absent_but_optional" "$identifier / $copy"
  fi
}

require_rg "Profile presentation mode identifier" "hf\\.profile\\.ecosystemPresentationMode" "$PROFILE_SOURCE"
require_rg "Profile presentation story card identifier" "hf\\.profile\\.presentationStoryCard" "$PROFILE_SOURCE"
require_rg "Profile HighFive product story identifier" "hf\\.profile\\.highfiveProductStory" "$PROFILE_SOURCE"
require_rg "Profile Ecosystem Presentation Mode copy" "Ecosystem Presentation Mode" "$PROFILE_SOURCE"
require_rg "Profile HighFive Product Story copy" "HighFive Product Story" "$PROFILE_SOURCE"
require_rg "Profile product story sequence" "Watch, Create, Connect, Launch, and Export" "$PROFILE_SOURCE"
require_rg "HighFive Rooms remains product-facing" "hf\\.profile\\.roomsSection|HighFive Rooms" "$PROFILE_SOURCE"

require_rg "Demo Tour presentation hero identifier" "hf\\.demoTour\\.presentationHero" "$DEMO_SOURCE"
require_rg "Demo Tour Watch act identifier" "hf\\.demoTour\\.actWatch" "$DEMO_SOURCE"
require_rg "Demo Tour Rooms act identifier" "hf\\.demoTour\\.actRooms" "$DEMO_SOURCE"
require_rg "Demo Tour Proof act identifier" "hf\\.demoTour\\.actProof" "$DEMO_SOURCE"
require_rg "Demo Tour ecosystem proof board identifier" "hf\\.demoTour\\.ecosystemProofBoard" "$DEMO_SOURCE"
require_rg "Demo Tour run-of-show identifier" "hf\\.demoTour\\.runOfShow" "$DEMO_SOURCE"
require_rg "Demo Tour screenshot evidence plan identifier" "hf\\.demoTour\\.screenshotEvidencePlan" "$DEMO_SOURCE"
require_rg "Demo Tour product story copy" "HighFive Cinema Product Story" "$DEMO_SOURCE"
require_rg "Demo Tour WATCH first copy" "WATCH first" "$DEMO_SOURCE"
require_rg "Demo Tour CREATE copy" "CREATE" "$DEMO_SOURCE"
require_rg "Demo Tour CONNECT copy" "CONNECT" "$DEMO_SOURCE"
require_rg "Demo Tour LAUNCH copy" "LAUNCH" "$DEMO_SOURCE"
require_rg "Demo Tour EXPORT copy" "EXPORT" "$DEMO_SOURCE"

require_rg "Developer QA presentation proof identifier" "hf\\.devqa\\.presentationProofPath" "$PROFILE_SOURCE"
require_rg "Developer QA presentation proof copy" "Presentation Proof Path" "$PROFILE_SOURCE"
require_rg "Developer QA remains profile routed" "arguments\\.contains\\(\"--hf-start-developer-qa\"\\)" "$ROOT_SOURCE"
require_rg "Demo Tour remains profile routed" "arguments\\.contains\\(\"--hf-start-demo-tour\"\\)" "$ROOT_SOURCE"
require_rg "Developer QA view remains in Profile source" "DeveloperQAHubView" "$PROFILE_SOURCE"
require_rg "Demo Tour view remains in Profile source" "FinalDemoTourView" "$PROFILE_SOURCE"

optional_signal "Optional Home Watch-first story" "hf\\.consumer\\.home\\.watchFirstStory" "Built Around The Watch" "$HOME_SOURCE" "HighFive/Views/Home/HomeView.swift"
optional_signal "Optional Movie Detail Watch-to-release story" "hf\\.consumer\\.movieDetail\\.watchToRelease" "From Watch To Release" "$DETAIL_SOURCE" "HighFive/Views/MovieDetail/MovieDetailView.swift"

TAB_TITLES="$(rg -o 'HFTabItem\([^)]*title: "[^"]+"' "$ROOT_SOURCE" | sed -E 's/.*title: "([^"]+)".*/\1/' | paste -sd ' ' -)"
if [[ "$TAB_TITLES" == "Home Search Library Downloads Profile" ]]; then
  record "Bottom tabs exactly locked" "pass" "$TAB_TITLES"
else
  record "Bottom tabs exactly locked" "fail" "$TAB_TITLES"
fi

TAB_COUNT="$(rg -o 'HFTabItem\([^)]*title: "[^"]+"' "$ROOT_SOURCE" | wc -l | tr -d ' ')"
if [[ "$TAB_COUNT" == "5" ]]; then
  record "Bottom tab count exactly five" "pass" "$TAB_COUNT"
else
  record "Bottom tab count exactly five" "fail" "$TAB_COUNT"
fi

for forbidden in Presentation Demo Tour Rooms Watch Create Creator Studio Connect Launch Export Developer QA "Command Center" Proof Evidence Dashboard; do
  if [[ "$TAB_TITLES" == *"$forbidden"* ]]; then
    record "No forbidden bottom tab $forbidden" "fail" "$TAB_TITLES"
  else
    record "No forbidden bottom tab $forbidden" "pass" "$TAB_TITLES"
  fi
done

reject_rg "Consumer Home has no internal proof route" "Developer / QA|FinalDemoTourView|Command Center|Presentation Proof Path" "$HOME_SOURCE"
reject_rg "Movie Detail has no internal proof route" "Developer / QA|FinalDemoTourView|Command Center|Presentation Proof Path" "$DETAIL_SOURCE"
reject_rg "Root tabs do not expose Demo Tour" 'title: "Demo"|title: "Tour"|title: "Presentation"|title: "Developer"|title: "QA"' "$ROOT_SOURCE"

PROTECTED_PATTERN='HighFive/App/(Depth|Motion|Playback|Layer4|Rendering|Creator|UI|Store)|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|posterAssetName|backdropAssetName|mapping|asset'
PROTECTED_DIFF="$(git diff --name-only | rg "$PROTECTED_PATTERN" || true)"
if [[ -n "$PROTECTED_DIFF" ]]; then
  record "Protected path diff" "fail" "$(printf '%s' "$PROTECTED_DIFF" | tr '\n' ' ')"
else
  record "Protected path diff" "pass" "No protected paths changed"
fi

LIVE_TERMS=(
  "AV""Kit" "AV""Player" "AVFoundation" "Core""Motion" "AR""Kit" "CMMotion"
  "Store""Kit" "Pho""tos" "Replay""Kit" "AVCapture" "UNUserNotificationCenter"
  "URLSession" "FileManager" "ShareLink" "Transferable" "Pho""tosPicker"
  "UIImagePickerController" "PHPicker" "UIDocumentPicker" "pay""ment" "purchase"
  "subscription" "entitlement" "auth" "backend" "up""load" "message" "chat"
  "comment" "notification" "ana""lytics" "track""ing" "social graph" "database"
  "waitlist" "ticket" "donate" "crowdfunding" "render" "export file" "writeTo"
  "Data(" "FileDocument" "DocumentGroup" "fileExporter" "fileImporter"
  "publish campaign" "notify audience" "join waitlist" "sell access" "buy ticket"
  "track audience" "view ana""lytics" "connect account" "push launch" "file picker"
  "image picker" "media picker" "select files" "import from photos" "start stream"
  "launch player" "watch party" "submit to platform" "share package" "save to photos"
  "generate zip" "open files" "send message" "start chat" "post comment"
  "follow creator" "invite users" "export file" "render package" "download package"
  "send to distributor"
)
CHANGED_SWIFT_LINES="$(git diff -U0 -- '*.swift' | rg -n '^\+' || true)"
LIVE_MATCHES=""
if [[ -n "$CHANGED_SWIFT_LINES" ]]; then
  for term in "${LIVE_TERMS[@]}"; do
    term_matches="$(printf '%s\n' "$CHANGED_SWIFT_LINES" | grep -F "$term" || true)"
    if [[ -n "$term_matches" ]]; then
      LIVE_MATCHES="${LIVE_MATCHES}${term_matches}"$'\n'
    fi
  done
fi
if [[ -n "$LIVE_MATCHES" ]]; then
  record "Changed Swift live-system scan" "fail" "$LIVE_MATCHES"
else
  record "Changed Swift live-system scan" "pass" "No changed Swift live-system additions"
fi

{
  printf '{\n'
  printf '  "upgrade": "#025.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "bottom_tabs": "%s",\n' "$(json_escape "$TAB_TITLES")"
  printf '  "checks": [\n'
  for i in "${!RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${RESULTS[$i]}"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Mega Ecosystem Presentation Source Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  printf 'Bottom tabs: `%s`\n\n' "$TAB_TITLES"
  for row in "${RESULTS[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    status="$(printf '%s' "$row" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    detail="$(printf '%s' "$row" | sed -E 's/.*"detail":"([^"]*)"\}$/\1/')"
    printf -- '- %s: %s - %s\n' "$status" "$name" "$detail"
  done
  printf '\nReports:\n- %s\n- %s\n' "$JSON_REPORT" "$MD_REPORT"
} > "$MD_REPORT"

printf 'Source verification report: %s\n' "$MD_REPORT"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
