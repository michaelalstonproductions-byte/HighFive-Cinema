#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-24-0b-watch-export-evidence"
JSON_REPORT="$OUT_DIR/watch_export_professional_delivery_source_verification.json"
MD_REPORT="$OUT_DIR/watch_export_professional_delivery_source_verification.md"
PROFILE_SOURCE="$ROOT_DIR/HighFive/Views/Profile/ProfileView.swift"
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
  if [[ "$status" != "pass" ]]; then
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

require_rg "Watch root identifier" "hf.room.watch.root" "$PROFILE_SOURCE"
require_rg "Watch Premium Program Board" "Premium Program Board" "$PROFILE_SOURCE"
require_rg "Watch program board identifier" "hf.room.watch.programBoard" "$PROFILE_SOURCE"
require_rg "Watch Featured Programming" "Featured Programming" "$PROFILE_SOURCE"
require_rg "Watch featured identifier" "hf.room.watch.featuredProgramming" "$PROFILE_SOURCE"
require_rg "Watch HighFive Originals lane" "HighFive Originals" "$PROFILE_SOURCE"
require_rg "Watch originals identifier" "hf.room.watch.originalsLane" "$PROFILE_SOURCE"
require_rg "Watch Collections lane" "Collections" "$PROFILE_SOURCE"
require_rg "Watch collections identifier" "hf.room.watch.collectionLane" "$PROFILE_SOURCE"
require_rg "Watch Continue Path" "Continue Path" "$PROFILE_SOURCE"
require_rg "Watch continue identifier" "hf.room.watch.continuePath" "$PROFILE_SOURCE"
require_rg "Watch Discovery Bridge" "Discovery Bridge" "$PROFILE_SOURCE"
require_rg "Watch discovery identifier" "hf.room.watch.discoveryBridge" "$PROFILE_SOURCE"
require_rg "Watch Viewing Journey Planner" "Viewing Journey Planner" "$PROFILE_SOURCE"
require_rg "Watch journey identifier" "hf.room.watch.viewingJourneyPlanner" "$PROFILE_SOURCE"
require_rg "Watch Featured Slate Pack" "Featured Slate Pack" "$PROFILE_SOURCE"
require_rg "Watch slate identifier" "hf.room.watch.featuredSlatePack" "$PROFILE_SOURCE"
require_rg "Watch Viewing Hub remains" "hf.room.watch.viewingHub" "$PROFILE_SOURCE"
require_rg "Watch Readiness remains" "hf.room.watch.viewingReadiness" "$PROFILE_SOURCE"
require_rg "Watch Boundary remains" "hf.room.watch.viewingBoundary" "$PROFILE_SOURCE"
require_rg "Watch Board remains" "hf.room.watch.watchBoard" "$PROFILE_SOURCE"
require_rg "Watch Momentum remains" "hf.room.watch.viewingMomentum" "$PROFILE_SOURCE"
require_rg "Watch Plan remains" "hf.room.watch.watchPlan" "$PROFILE_SOURCE"

require_rg "Export root identifier" "hf.room.export.root" "$PROFILE_SOURCE"
require_rg "Export Professional Delivery Board" "Professional Delivery Board" "$PROFILE_SOURCE"
require_rg "Export professional identifier" "hf.room.export.professionalDelivery" "$PROFILE_SOURCE"
require_rg "Export Delivery Board remains" "hf.room.export.deliveryBoard" "$PROFILE_SOURCE"
require_rg "Export Festival Materials" "Festival Materials" "$PROFILE_SOURCE"
require_rg "Export festival identifier" "hf.room.export.festivalMaterials" "$PROFILE_SOURCE"
require_rg "Export Platform Checklist" "Platform Checklist" "$PROFILE_SOURCE"
require_rg "Export platform identifier" "hf.room.export.platformChecklist" "$PROFILE_SOURCE"
require_rg "Export Press Delivery" "Press Delivery" "$PROFILE_SOURCE"
require_rg "Export press identifier" "hf.room.export.pressDelivery" "$PROFILE_SOURCE"
require_rg "Export Protected Delivery Systems" "Protected Delivery Systems" "$PROFILE_SOURCE"
require_rg "Export protected identifier" "hf.room.export.protectedDeliverySystems" "$PROFILE_SOURCE"
require_rg "Export Festival Platform Readiness Pack" "Festival \\+ Platform Readiness Pack" "$PROFILE_SOURCE"
require_rg "Export festival platform identifier" "hf.room.export.festivalPlatformReadiness" "$PROFILE_SOURCE"
require_rg "Export Distribution Handoff Planner" "Distribution Handoff Planner" "$PROFILE_SOURCE"
require_rg "Export handoff planner identifier" "hf.room.export.handoffPlanner" "$PROFILE_SOURCE"
require_rg "Export Distribution Package remains" "hf.room.export.distributionPackage" "$PROFILE_SOURCE"
require_rg "Export Readiness remains" "hf.room.export.distributionReadiness" "$PROFILE_SOURCE"
require_rg "Export Boundary remains" "hf.room.export.distributionBoundary" "$PROFILE_SOURCE"
require_rg "Export Delivery Readiness Board remains" "hf.room.export.deliveryReadinessBoard" "$PROFILE_SOURCE"
require_rg "Export Handoff Plan remains" "hf.room.export.handoffPlan" "$PROFILE_SOURCE"

require_rg "Profile root identifier" "hf.profile.root" "$PROFILE_SOURCE"
require_rg "Profile rooms section" "hf.profile.roomsSection" "$PROFILE_SOURCE"
require_rg "Profile product suite progress" "hf.profile.productSuiteProgress" "$PROFILE_SOURCE"
require_rg "Profile Watch Export summary" "hf.profile.watchExportSummary" "$PROFILE_SOURCE"
require_rg "Profile internal section" "hf.profile.internalSection" "$PROFILE_SOURCE"
require_rg "Profile summary copy" "Watch \\+ Export Professional Path" "$PROFILE_SOURCE"

require_rg "Movie Detail root identifier" "hf.consumer.movieDetail.root" "$DETAIL_SOURCE"
require_rg "Movie Detail Title Path" "Title Path" "$DETAIL_SOURCE"
require_rg "Movie Detail title path identifier" "hf.consumer.movieDetail.titlePath" "$DETAIL_SOURCE"
require_rg "Movie Detail Watch path" "Watch path" "$DETAIL_SOURCE"
require_rg "Movie Detail Collection fit" "Collection fit" "$DETAIL_SOURCE"
require_rg "Movie Detail Public momentum" "Public momentum" "$DETAIL_SOURCE"
require_rg "Movie Detail Delivery readiness" "Delivery readiness" "$DETAIL_SOURCE"
require_rg "Movie Detail decision panel remains" "hf.consumer.movieDetail.decisionPanel" "$DETAIL_SOURCE"
require_rg "Movie Detail viewing context remains" "hf.consumer.movieDetail.viewingContext" "$DETAIL_SOURCE"
require_rg "Movie Detail More Like This remains" "hf.consumer.movieDetail.moreLikeThis" "$DETAIL_SOURCE"
require_rg "Movie Detail Watch Now remains" "hf.consumer.movieDetail.watchNow" "$DETAIL_SOURCE"

TAB_TITLES="$(rg -o 'HFTabItem\([^)]*title: "[^"]+"' "$ROOT_SOURCE" | sed -E 's/.*title: ("[^"]+").*/\1/' | tr '\n' ' ')"
for title in '"Home"' '"Search"' '"Library"' '"Downloads"' '"Profile"'; do
  if [[ "$TAB_TITLES" == *"$title"* ]]; then
    record "Bottom tab $title" "pass" "$TAB_TITLES"
  else
    record "Bottom tab $title" "fail" "$TAB_TITLES"
  fi
done

for forbidden in '"Watch"' '"Export"' '"Delivery"' '"Platform"' '"Festival"' '"Files"' '"Render"' '"Share"' '"Creator"' '"Studio"' '"Connect"' '"Launch"' '"Rooms"' '"Developer"' '"QA"' '"Demo"' '"Tour"' '"Command Center"'; do
  if [[ "$TAB_TITLES" == *"$forbidden"* ]]; then
    record "No room/internal tab $forbidden" "fail" "$TAB_TITLES"
  else
    record "No room/internal tab $forbidden" "pass" "$TAB_TITLES"
  fi
done

require_rg "Developer QA remains profile-internal" "hf.profile.internalSection|Developer / QA|DeveloperQAHubView" "$PROFILE_SOURCE"
require_rg "Tour remains internal source" "FinalDemoTourView" "$PROFILE_SOURCE"
reject_rg "Movie Detail has no internal route language" "Developer / QA|FinalDemoTourView|Command Center" "$DETAIL_SOURCE"

PROTECTED_PATTERN='HighFive/App/(Depth|Motion|Playback|Layer4|Rendering|Creator|UI|Store)|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|posterAssetName|backdropAssetName|mapping|asset'
if git diff --name-only | rg -q "$PROTECTED_PATTERN"; then
  record "Protected path diff" "fail" "$(git diff --name-only | rg "$PROTECTED_PATTERN" | tr '\n' ' ')"
else
  record "Protected path diff" "pass" "No protected paths changed"
fi

media_prefix="AV"
player_word="Player"
foundation_word="Foundation"
core_word="Core"
motion_word="Motion"
ar_word="AR"
kit_word="Kit"
photo_word="Photo"
replay_word="Replay"
file_word="File"
manager_word="Manager"
share_word="Share"
link_word="Link"
pay_word="pay"
ment_word="ment"
up_word="up"
load_word="load"
ana_word="ana"
lytics_word="lytics"
track_word="track"
ing_word="ing"
comm_word="comm"
ent_word="ent"
LIVE_PATTERN="${media_prefix}Kit|${media_prefix}${player_word}|${media_prefix}${foundation_word}|${core_word}${motion_word}|${ar_word}${kit_word}|${photo_word}s|${replay_word}${kit_word}|${file_word}${manager_word}|${share_word}${link_word}|${pay_word}${ment_word}|${up_word}${load_word}|${ana_word}${lytics_word}|${track_word}${ing_word}|backend|database|render engine|export engine|writeTo|fileExporter|fileImporter|${comm_word}${ent_word}"
LIVE_MATCHES="$(git diff -U0 -- '*.swift' | rg -n "^\+.*(${LIVE_PATTERN})" || true)"
if [[ -n "$LIVE_MATCHES" ]]; then
  record "Changed Swift live-system scan" "fail" "$LIVE_MATCHES"
else
  record "Changed Swift live-system scan" "pass" "No executable live-system additions in changed Swift lines"
fi

{
  printf '{\n'
  printf '  "upgrade": "#024.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "checks": [\n'
  for i in "${!RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${RESULTS[$i]}"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Watch Export Professional Delivery Source Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
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
