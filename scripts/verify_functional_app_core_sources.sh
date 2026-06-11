#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-26-0b-functional-core-evidence"
JSON_REPORT="$OUT_DIR/functional_app_core_source_verification.json"
MD_REPORT="$OUT_DIR/functional_app_core_source_verification.md"
ROOT_SOURCE="$ROOT_DIR/HighFive/App/HFStreamingRootView.swift"
HOME_SOURCE="$ROOT_DIR/HighFive/Views/Home/HomeView.swift"
DETAIL_SOURCE="$ROOT_DIR/HighFive/Views/MovieDetail/MovieDetailView.swift"
PLAYER_SOURCE="$ROOT_DIR/HighFive/Components/HFMockPlayerSheet.swift"
LIBRARY_SOURCE="$ROOT_DIR/HighFive/Views/MyListView.swift"
DOWNLOADS_SOURCE="$ROOT_DIR/HighFive/Views/DownloadsView.swift"
PROFILE_SOURCE="$ROOT_DIR/HighFive/Views/Profile/ProfileView.swift"
DEMO_SOURCE="$ROOT_DIR/HighFive/Views/Demo/FinalDemoTourView.swift"

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

require_any_rg() {
  local name="$1"
  local first_pattern="$2"
  local first_file="$3"
  local second_pattern="$4"
  local second_file="$5"
  if [[ -f "$first_file" ]] && rg -q "$first_pattern" "$first_file"; then
    record "$name" "pass" "$first_pattern"
  elif [[ -f "$second_file" ]] && rg -q "$second_pattern" "$second_file"; then
    record "$name" "pass" "$second_pattern"
  else
    record "$name" "fail" "Missing either $first_pattern or $second_pattern"
  fi
}

reject_tabs() {
  local tab_titles="$1"
  local forbidden="$2"
  if [[ " $tab_titles " == *" $forbidden "* ]]; then
    record "No forbidden bottom tab $forbidden" "fail" "$tab_titles"
  else
    record "No forbidden bottom tab $forbidden" "pass" "$tab_titles"
  fi
}

require_rg "Onboarding brand intro" "hf\\.onboarding\\.brandIntro" "$ROOT_SOURCE"
require_rg "Onboarding motion training" "hf\\.onboarding\\.motionTraining" "$ROOT_SOURCE"
require_rg "Onboarding tilt to move" "hf\\.onboarding\\.tiltToMove" "$ROOT_SOURCE"
require_rg "Onboarding peek to explore" "hf\\.onboarding\\.peekToExplore" "$ROOT_SOURCE"
require_rg "Onboarding controls training" "hf\\.onboarding\\.controlsTraining" "$ROOT_SOURCE"
require_rg "Onboarding depth control" "hf\\.onboarding\\.depthControl" "$ROOT_SOURCE"
require_rg "Onboarding focus control" "hf\\.onboarding\\.focusControl" "$ROOT_SOURCE"
require_rg "Onboarding import export training" "hf\\.onboarding\\.importExportTraining" "$ROOT_SOURCE"
require_any_rg "Onboarding home reveal or completion path" "hf\\.onboarding\\.homeReveal" "$ROOT_SOURCE" "completeLaunchIntro" "$ROOT_SOURCE"

require_rg "Home root" "hf\\.consumer\\.home\\.root" "$HOME_SOURCE"
require_rg "Home featured route" "hf\\.functional\\.home\\.featuredMovieRoute" "$HOME_SOURCE"
require_rg "Home continue watching route" "hf\\.functional\\.home\\.continueWatchingRoute" "$HOME_SOURCE"
require_rg "Home ecosystem route" "hf\\.functional\\.home\\.ecosystemRoute" "$HOME_SOURCE"

require_rg "Movie Detail root" "hf\\.consumer\\.movieDetail\\.root" "$DETAIL_SOURCE"
require_rg "Movie Detail Watch Now" "hf\\.consumer\\.movieDetail\\.watchNow" "$DETAIL_SOURCE"
require_rg "Player sheet" "hf\\.functional\\.player\\.sheet" "$DETAIL_SOURCE"
require_any_rg "Player Watch Now path" "hf\\.functional\\.player\\.watchNow" "$DETAIL_SOURCE" "hf\\.functional\\.player\\.watchNow" "$PLAYER_SOURCE"
require_rg "Player close" "hf\\.functional\\.player\\.close" "$PLAYER_SOURCE"
require_rg "Movie save toggle" "hf\\.functional\\.movie\\.saveToggle" "$DETAIL_SOURCE"
require_rg "Movie download toggle" "hf\\.functional\\.movie\\.downloadToggle" "$DETAIL_SOURCE"

require_rg "Library saved state" "hf\\.functional\\.library\\.savedState" "$LIBRARY_SOURCE"
require_rg "Library saved shelf" "hf\\.consumer\\.library\\.savedShelf" "$LIBRARY_SOURCE"
require_rg "Library watch shelf" "hf\\.consumer\\.library\\.watchShelf" "$LIBRARY_SOURCE"

require_rg "Downloads downloaded state" "hf\\.functional\\.downloads\\.downloadedState" "$DOWNLOADS_SOURCE"
require_rg "Downloads offline shelf" "hf\\.consumer\\.downloads\\.offlineShelf" "$DOWNLOADS_SOURCE"
require_rg "Downloads offline watch hub" "hf\\.consumer\\.downloads\\.offlineWatchHub" "$DOWNLOADS_SOURCE"

require_rg "Connect local updates section" "hf\\.functional\\.connect\\.localUpdates" "$PROFILE_SOURCE"
require_rg "Connect update input" "hf\\.functional\\.connect\\.updateInput" "$PROFILE_SOURCE"
require_rg "Connect add local update action" "hf\\.functional\\.connect\\.addLocalUpdate" "$PROFILE_SOURCE"
require_rg "Connect update list" "hf\\.functional\\.connect\\.updateList" "$PROFILE_SOURCE"
require_rg "Connect local update copy" "Local Audience Updates" "$PROFILE_SOURCE"

require_rg "Launch local checklist" "hf\\.functional\\.launch\\.localChecklist" "$PROFILE_SOURCE"
require_rg "Launch checklist progress" "hf\\.functional\\.launch\\.checklistProgress" "$PROFILE_SOURCE"
require_rg "Launch checklist toggle" "hf\\.functional\\.launch\\.checklistToggle" "$PROFILE_SOURCE"
require_rg "Launch review progress action" "hf\\.functional\\.launch\\.reviewProgress" "$PROFILE_SOURCE"
require_rg "Launch checklist copy" "Local Release Checklist" "$PROFILE_SOURCE"

require_rg "Export delivery summary section" "hf\\.functional\\.export\\.deliverySummary" "$PROFILE_SOURCE"
require_rg "Export generate summary action" "hf\\.functional\\.export\\.generateSummary" "$PROFILE_SOURCE"
require_rg "Export summary text" "hf\\.functional\\.export\\.summaryText" "$PROFILE_SOURCE"
if rg -q "ShareLink" "$PROFILE_SOURCE"; then
  require_rg "Export share summary" "hf\\.functional\\.export\\.shareSummary" "$PROFILE_SOURCE"
else
  record "Export share summary" "skipped_optional" "Share summary not implemented"
fi
require_rg "Export delivery summary copy" "Generate Delivery Summary" "$PROFILE_SOURCE"

require_rg "Profile Functional Core summary" "hf\\.profile\\.functionalCoreSummary" "$PROFILE_SOURCE"
require_rg "Demo Functional Core proof" "hf\\.demoTour\\.functionalCoreProof" "$DEMO_SOURCE"
require_rg "Functional Core copy" "Functional Core" "$PROFILE_SOURCE"
require_rg "Presentation mode remains present" "hf\\.profile\\.ecosystemPresentationMode" "$PROFILE_SOURCE"
require_rg "Demo presentation mode remains present" "hf\\.demoTour\\.presentationHero" "$DEMO_SOURCE"

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

for forbidden in Watch Create Connect Launch Export Demo Developer QA Presentation Rooms Player Messages Notifications; do
  reject_tabs "$TAB_TITLES" "$forbidden"
done

PROTECTED_PATTERN='HighFive/App/(Depth|Motion|Playback|Layer4|Rendering|Creator|UI|Store)|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|posterAssetName|backdropAssetName|mapping|asset'
PROTECTED_DIFF="$(git diff --name-only | rg "$PROTECTED_PATTERN" || true)"
if [[ -n "$PROTECTED_DIFF" ]]; then
  record "Protected path diff" "fail" "$(printf '%s' "$PROTECTED_DIFF" | tr '\n' ' ')"
else
  record "Protected path diff" "pass" "No protected paths changed"
fi

BLOCKED_TERMS=(
  "Firebase" "Supabase" "URLSession" "AuthenticationServices" "Store""Kit"
  "Pho""tosPicker" "UIImagePickerController" "PHPicker" "UIDocumentPicker"
  "AVCapture" "UNUserNotificationCenter" "SKPayment" "purchase" "subscription"
  "entitlement" "account login" "up""load" "push notification" "ana""lytics SDK"
  "track""ing SDK" "render engine" "video export" "fileExporter" "fileImporter"
  "DocumentGroup" "FileDocument" "writeTo" "zip" "submit to platform" "ticket"
  "waitlist" "pay""ment"
)
CHANGED_SWIFT_LINES="$(git diff -U0 -- '*.swift' | rg -n '^\+' || true)"
BLOCKED_MATCHES=""
if [[ -n "$CHANGED_SWIFT_LINES" ]]; then
  for term in "${BLOCKED_TERMS[@]}"; do
    term_matches="$(printf '%s\n' "$CHANGED_SWIFT_LINES" | grep -F "$term" || true)"
    if [[ -n "$term_matches" ]]; then
      BLOCKED_MATCHES="${BLOCKED_MATCHES}${term_matches}"$'\n'
    fi
  done
fi
if [[ -n "$BLOCKED_MATCHES" ]]; then
  record "Changed Swift controlled-system scan" "fail" "$BLOCKED_MATCHES"
else
  record "Changed Swift controlled-system scan" "pass" "No blocked changed Swift additions"
fi

{
  printf '{\n'
  printf '  "upgrade": "#026.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "bottom_tabs": "%s",\n' "$(json_escape "$TAB_TITLES")"
  printf '  "honesty_note": "Source verification proves identifiers and copy exist. It does not prove interactive behavior by itself.",\n'
  printf '  "checks": [\n'
  for i in "${!RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${RESULTS[$i]}"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Functional App Core Source Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  printf 'Bottom tabs: `%s`\n\n' "$TAB_TITLES"
  printf 'Honesty note: source verification proves identifiers and copy exist. It does not prove interactive behavior by itself.\n\n'
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
