#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-20-0e-creator-suite-evidence"
JSON_REPORT="$OUT_DIR/creator_studio_suite_source_verification.json"
MD_REPORT="$OUT_DIR/creator_studio_suite_source_verification.md"
PROFILE_SOURCE="$ROOT_DIR/HighFive/Views/Profile/ProfileView.swift"
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
  if rg -q "$pattern" "$file"; then
    record "$name" "pass" "$pattern"
  else
    record "$name" "fail" "Missing: $pattern"
  fi
}

reject_rg() {
  local name="$1"
  local pattern="$2"
  local file="$3"
  if rg -q "$pattern" "$file"; then
    record "$name" "fail" "Unexpected match: $pattern"
  else
    record "$name" "pass" "No match: $pattern"
  fi
}

if [[ -f "$PROFILE_SOURCE" ]]; then
  record "Creator source exists" "pass" "$PROFILE_SOURCE"
else
  record "Creator source exists" "fail" "$PROFILE_SOURCE missing"
fi

if [[ -f "$ROOT_SOURCE" ]]; then
  record "App root source exists" "pass" "$ROOT_SOURCE"
else
  record "App root source exists" "fail" "$ROOT_SOURCE missing"
fi

for marker in \
  "Creator Studio" \
  "Studio Slate" \
  "Project Package Builder" \
  "Pitch Package" \
  "Media Kit" \
  "Launch Prep"; do
  require_rg "Suite marker $marker" "$marker" "$PROFILE_SOURCE"
done

for boundary in \
  "Studio Safety Boundary" \
  "Pitch Safety Boundary" \
  "Media Kit Safety Boundary" \
  "Launch Prep Safety Boundary"; do
  require_rg "Boundary $boundary" "$boundary" "$PROFILE_SOURCE"
done

for identifier in \
  "hf.room.create.root" \
  "hf.room.create.studioSlate" \
  "hf.room.create.projectCards" \
  "hf.room.create.selectedProject" \
  "hf.room.create.packageProgress" \
  "hf.room.create.creativeMaterials" \
  "hf.room.create.launchConnection" \
  "hf.room.create.studioBoundary" \
  "hf.room.create.packageBuilder" \
  "hf.room.create.packageHero" \
  "hf.room.create.packageSections" \
  "hf.room.create.packageDetail" \
  "hf.room.create.packageReadiness" \
  "hf.room.create.packageBoundary" \
  "hf.room.create.pitchPackage" \
  "hf.room.create.pitchHero" \
  "hf.room.create.pitchSections" \
  "hf.room.create.pitchDetail" \
  "hf.room.create.pitchReadiness" \
  "hf.room.create.pitchConnection" \
  "hf.room.create.pitchBoundary" \
  "hf.room.create.mediaKit" \
  "hf.room.create.mediaKitHero" \
  "hf.room.create.mediaKitSections" \
  "hf.room.create.mediaKitDetail" \
  "hf.room.create.mediaKitReadiness" \
  "hf.room.create.mediaKitConnection" \
  "hf.room.create.mediaKitBoundary" \
  "hf.room.create.launchPrep" \
  "hf.room.create.launchPrepHero" \
  "hf.room.create.launchPrepSections" \
  "hf.room.create.launchPrepDetail" \
  "hf.room.create.launchPrepReadiness" \
  "hf.room.create.launchRoomConnection" \
  "hf.room.create.launchPrepBoundary"; do
  require_rg "Identifier $identifier" "$identifier" "$PROFILE_SOURCE"
done

TAB_TITLES="$(rg -o 'HFTabItem\([^)]*title: "[^"]+"' "$ROOT_SOURCE" | sed -E 's/.*title: ("[^"]+").*/\1/' | tr '\n' ' ')"
for title in '"Home"' '"Search"' '"Library"' '"Downloads"' '"Profile"'; do
  if [[ "$TAB_TITLES" == *"$title"* ]]; then
    record "Bottom tab $title" "pass" "$TAB_TITLES"
  else
    record "Bottom tab $title" "fail" "$TAB_TITLES"
  fi
done

for forbidden in '"Creator"' '"Create"' '"Studio"' '"Pitch"' '"Media Kit"' '"Launch"' '"Projects"' '"Connect"' '"Export"' '"Rooms"' '"Developer"' '"QA"' '"Demo"' '"Tour"' '"Command Center"'; do
  if [[ "$TAB_TITLES" == *"$forbidden"* ]]; then
    record "No suite/internal tab $forbidden" "fail" "$TAB_TITLES"
  else
    record "No suite/internal tab $forbidden" "pass" "$TAB_TITLES"
  fi
done

require_rg "Rooms remain product-facing" "HighFive Rooms" "$PROFILE_SOURCE"
require_rg "Internal area remains under Profile" "hf.profile.internalSection|Developer / QA|DeveloperQAHubView" "$PROFILE_SOURCE"
require_rg "Tour remains internal source" "Demo Tour|FinalDemoTourView" "$PROFILE_SOURCE"

for consumer_file in \
  "$ROOT_DIR/HighFive/Views/Home/HomeView.swift" \
  "$ROOT_DIR/HighFive/Views/Search/SearchView.swift" \
  "$ROOT_DIR/HighFive/Views/MovieDetail/MovieDetailView.swift" \
  "$ROOT_DIR/HighFive/Views/MyListView.swift" \
  "$ROOT_DIR/HighFive/Views/DownloadsView.swift"; do
  if [[ -f "$consumer_file" ]]; then
    reject_rg "Tour absent from $(basename "$consumer_file")" "Demo Tour|FinalDemoTourView" "$consumer_file"
  fi
done

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
LIVE_PATTERN="${media_prefix}Kit|${media_prefix}${player_word}|${media_prefix}${foundation_word}|${core_word}${motion_word}|${ar_word}${kit_word}|${photo_word}s|${replay_word}${kit_word}|${file_word}${manager_word}|${share_word}${link_word}|${pay_word}${ment_word}|${up_word}${load_word}|${ana_word}${lytics_word}|${track_word}${ing_word}|backend|database|render engine|export engine|writeTo|fileExporter|fileImporter"
LIVE_MATCHES="$(git diff -U0 -- '*.swift' | rg -n "^\+.*(${LIVE_PATTERN})" || true)"
if [[ -n "$LIVE_MATCHES" ]]; then
  record "Changed Swift live-system scan" "fail" "$LIVE_MATCHES"
else
  record "Changed Swift live-system scan" "pass" "No executable live-system additions in changed Swift lines"
fi

{
  printf '{\n'
  printf '  "upgrade": "#020.0E",\n'
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
  printf '# Creator Studio Suite Source Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  for row in "${RESULTS[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    status="$(printf '%s' "$row" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    detail="$(printf '%s' "$row" | sed -E 's/.*"detail":"([^"]*)"\}$/\1/')"
    printf -- '- %s: %s — %s\n' "$status" "$name" "$detail"
  done
  printf '\nReports:\n- %s\n- %s\n' "$JSON_REPORT" "$MD_REPORT"
} > "$MD_REPORT"

printf 'Source verification report: %s\n' "$MD_REPORT"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
