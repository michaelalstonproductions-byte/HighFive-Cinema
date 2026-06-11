#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-22-0b-consumer-evidence"
JSON_REPORT="$OUT_DIR/mega_consumer_streaming_source_verification.json"
MD_REPORT="$OUT_DIR/mega_consumer_streaming_source_verification.md"
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

HOME_SOURCE="$ROOT_DIR/HighFive/Views/Home/HomeView.swift"
SEARCH_SOURCE="$ROOT_DIR/HighFive/Views/Search/SearchView.swift"
DISCOVER_SOURCE="$ROOT_DIR/HighFive/Views/Discover/UnifiedDiscoveryView.swift"
DETAIL_SOURCE="$ROOT_DIR/HighFive/Views/MovieDetail/MovieDetailView.swift"
LIBRARY_SOURCE="$ROOT_DIR/HighFive/Views/MyListView.swift"
DOWNLOADS_SOURCE="$ROOT_DIR/HighFive/Views/DownloadsView.swift"
PROFILE_SOURCE="$ROOT_DIR/HighFive/Views/Profile/ProfileView.swift"

require_rg "Home Tonight on HighFive" "Tonight on HighFive" "$HOME_SOURCE"
require_rg "Home Streaming Momentum" "Streaming Momentum" "$HOME_SOURCE"
require_rg "Home root identifier" "hf.consumer.home.root" "$HOME_SOURCE"
require_rg "Home hero identifier" "hf.consumer.home.hero" "$HOME_SOURCE"
require_rg "Home tonight identifier" "hf.consumer.home.tonight" "$HOME_SOURCE"
require_rg "Home momentum identifier" "hf.consumer.home.momentum" "$HOME_SOURCE"
require_rg "Home poster rails identifier" "hf.consumer.home.posterRails" "$HOME_SOURCE"

require_rg "Search Discovery Studio" "Discovery Studio" "$SEARCH_SOURCE"
require_rg "Search mood filters" "Browse by mood|Genre and mood filters" "$SEARCH_SOURCE"
require_rg "Search Discovery Momentum" "Discovery Momentum" "$SEARCH_SOURCE"
require_rg "Search root identifier" "hf.consumer.search.root" "$SEARCH_SOURCE"
require_rg "Search field identifier" "hf.consumer.search.field" "$SEARCH_SOURCE"
require_rg "Search discovery studio identifier" "hf.consumer.search.discoveryStudio" "$SEARCH_SOURCE"
require_rg "Search filter identifier" "hf.consumer.search.genreFilters" "$SEARCH_SOURCE"
require_rg "Search momentum identifier" "hf.consumer.search.discoveryMomentum" "$SEARCH_SOURCE"
require_rg "Search rails identifier" "hf.consumer.discovery.rails" "$SEARCH_SOURCE"
require_rg "Discover root identifier" "hf.consumer.discover.root" "$DISCOVER_SOURCE"
require_rg "Discover rails identifier" "hf.consumer.discovery.rails" "$DISCOVER_SOURCE"

require_rg "Movie Detail Why Watch Tonight" "Why Watch Tonight" "$DETAIL_SOURCE"
require_rg "Movie Detail Viewing Context" "Viewing Context" "$DETAIL_SOURCE"
require_rg "Movie Detail More Like This" "More Like This" "$DETAIL_SOURCE"
require_rg "Movie Detail root identifier" "hf.consumer.movieDetail.root" "$DETAIL_SOURCE"
require_rg "Movie Detail hero identifier" "hf.consumer.movieDetail.hero" "$DETAIL_SOURCE"
require_rg "Movie Detail watch action identifier" "hf.consumer.movieDetail.watchNow" "$DETAIL_SOURCE"
require_rg "Movie Detail decision identifier" "hf.consumer.movieDetail.decisionPanel" "$DETAIL_SOURCE"
require_rg "Movie Detail context identifier" "hf.consumer.movieDetail.viewingContext" "$DETAIL_SOURCE"
require_rg "Movie Detail more identifier" "hf.consumer.movieDetail.moreLikeThis" "$DETAIL_SOURCE"
require_rg "Movie Detail related identifier" "hf.consumer.movieDetail.related" "$DETAIL_SOURCE"

require_rg "Library Your Watch Shelf" "Your Watch Shelf" "$LIBRARY_SOURCE"
require_rg "Library Shelf Momentum" "Shelf Momentum" "$LIBRARY_SOURCE"
require_rg "Library root identifier" "hf.consumer.library.root" "$LIBRARY_SOURCE"
require_rg "Library filters identifier" "hf.consumer.library.filters" "$LIBRARY_SOURCE"
require_rg "Library shelf identifier" "hf.consumer.library.watchShelf" "$LIBRARY_SOURCE"
require_rg "Library momentum identifier" "hf.consumer.library.shelfMomentum" "$LIBRARY_SOURCE"
require_rg "Library saved shelf identifier" "hf.consumer.library.savedShelf" "$LIBRARY_SOURCE"

require_rg "Downloads Offline Watch Hub" "Offline Watch Hub" "$DOWNLOADS_SOURCE"
require_rg "Downloads Offline Plan" "Offline Plan" "$DOWNLOADS_SOURCE"
require_rg "Downloads root identifier" "hf.consumer.downloads.root" "$DOWNLOADS_SOURCE"
require_rg "Downloads storage identifier" "hf.consumer.downloads.storageCard" "$DOWNLOADS_SOURCE"
require_rg "Downloads hub identifier" "hf.consumer.downloads.offlineWatchHub" "$DOWNLOADS_SOURCE"
require_rg "Downloads plan identifier" "hf.consumer.downloads.offlinePlan" "$DOWNLOADS_SOURCE"
require_rg "Downloads shelf identifier" "hf.consumer.downloads.offlineShelf" "$DOWNLOADS_SOURCE"

require_rg "Profile Your HighFive" "Your HighFive" "$PROFILE_SOURCE"
require_rg "Profile root identifier" "hf.profile.root" "$PROFILE_SOURCE"
require_rg "Profile consumer summary identifier" "hf.profile.consumerSummary" "$PROFILE_SOURCE"
require_rg "Profile rooms identifier" "hf.profile.roomsSection" "$PROFILE_SOURCE"
require_rg "Profile suite progress identifier" "hf.profile.productSuiteProgress" "$PROFILE_SOURCE"
require_rg "Profile internal identifier" "hf.profile.internalSection" "$PROFILE_SOURCE"
require_rg "Profile Developer QA remains internal" "hf.profile.internalSection|Developer / QA|DeveloperQAHubView" "$PROFILE_SOURCE"
require_rg "Demo tour remains internal source" "FinalDemoTourView" "$PROFILE_SOURCE"

TAB_TITLES="$(rg -o 'HFTabItem\([^)]*title: "[^"]+"' "$ROOT_SOURCE" | sed -E 's/.*title: ("[^"]+").*/\1/' | tr '\n' ' ')"
for title in '"Home"' '"Search"' '"Library"' '"Downloads"' '"Profile"'; do
  if [[ "$TAB_TITLES" == *"$title"* ]]; then
    record "Bottom tab $title" "pass" "$TAB_TITLES"
  else
    record "Bottom tab $title" "fail" "$TAB_TITLES"
  fi
done

for forbidden in '"Watch"' '"Create"' '"Creator"' '"Studio"' '"Connect"' '"Launch"' '"Export"' '"Rooms"' '"Developer"' '"QA"' '"Demo"' '"Tour"' '"Command Center"' '"Calendar"' '"Board"' '"Media Kit"' '"Projects"'; do
  if [[ "$TAB_TITLES" == *"$forbidden"* ]]; then
    record "No room/internal tab $forbidden" "fail" "$TAB_TITLES"
  else
    record "No room/internal tab $forbidden" "pass" "$TAB_TITLES"
  fi
done

for consumer_file in "$HOME_SOURCE" "$SEARCH_SOURCE" "$DISCOVER_SOURCE" "$DETAIL_SOURCE" "$LIBRARY_SOURCE" "$DOWNLOADS_SOURCE"; do
  reject_rg "Internal route language absent from $(basename "$consumer_file")" "Developer / QA|FinalDemoTourView|Command Center" "$consumer_file"
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
  printf '  "upgrade": "#022.0B",\n'
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
  printf '# Mega Consumer Streaming Source Verification\n\n'
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
