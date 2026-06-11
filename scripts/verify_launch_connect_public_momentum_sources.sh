#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-23-0b-launch-connect-evidence"
JSON_REPORT="$OUT_DIR/launch_connect_public_momentum_source_verification.json"
MD_REPORT="$OUT_DIR/launch_connect_public_momentum_source_verification.md"
PROFILE_SOURCE="$ROOT_DIR/HighFive/Views/Profile/ProfileView.swift"
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

require_rg "Connect root identifier" "hf.room.connect.root" "$PROFILE_SOURCE"
require_rg "Connect Public Momentum Board" "Public Momentum Board" "$PROFILE_SOURCE"
require_rg "Connect public momentum identifier" "hf.room.connect.publicMomentum" "$PROFILE_SOURCE"
require_rg "Connect momentum board identifier" "hf.room.connect.momentumBoard" "$PROFILE_SOURCE"
require_rg "Connect creator updates identifier" "hf.room.connect.creatorUpdates" "$PROFILE_SOURCE"
require_rg "Connect Creator Update Planner" "Creator Update Planner" "$PROFILE_SOURCE"
require_rg "Connect creator planner identifier" "hf.room.connect.creatorUpdatePlanner" "$PROFILE_SOURCE"
require_rg "Connect premiere conversation identifier" "hf.room.connect.premiereConversation" "$PROFILE_SOURCE"
require_rg "Connect Premiere Conversation Pack" "Premiere Conversation Pack" "$PROFILE_SOURCE"
require_rg "Connect conversation pack identifier" "hf.room.connect.conversationPack" "$PROFILE_SOURCE"
require_rg "Connect community readiness board" "hf.room.connect.communityReadinessBoard" "$PROFILE_SOURCE"
require_rg "Connect audience planner remains" "hf.room.connect.audiencePlanner" "$PROFILE_SOURCE"
require_rg "Connect audience readiness remains" "hf.room.connect.audienceReadiness" "$PROFILE_SOURCE"
require_rg "Connect boundary remains" "hf.room.connect.audienceBoundary" "$PROFILE_SOURCE"

require_rg "Launch root identifier" "hf.room.launch.root" "$PROFILE_SOURCE"
require_rg "Launch Public Release Calendar" "Public Release Calendar" "$PROFILE_SOURCE"
require_rg "Launch public calendar identifier" "hf.room.launch.publicReleaseCalendar" "$PROFILE_SOURCE"
require_rg "Launch milestone stack identifier" "hf.room.launch.releaseMilestoneStack" "$PROFILE_SOURCE"
require_rg "Launch Campaign Momentum Board" "Campaign Momentum Board" "$PROFILE_SOURCE"
require_rg "Launch campaign board identifier" "hf.room.launch.campaignMomentumBoard" "$PROFILE_SOURCE"
require_rg "Launch release readiness board" "hf.room.launch.releaseReadinessBoard" "$PROFILE_SOURCE"
require_rg "Launch Premiere Readiness Pack" "Premiere Readiness Pack" "$PROFILE_SOURCE"
require_rg "Launch premiere pack identifier" "hf.room.launch.premiereReadinessPack" "$PROFILE_SOURCE"
require_rg "Launch campaign planner remains" "hf.room.launch.campaignPlanner" "$PROFILE_SOURCE"
require_rg "Launch campaign readiness remains" "hf.room.launch.campaignReadiness" "$PROFILE_SOURCE"
require_rg "Launch boundary remains" "hf.room.launch.campaignBoundary" "$PROFILE_SOURCE"

require_rg "Profile root identifier" "hf.profile.root" "$PROFILE_SOURCE"
require_rg "Profile rooms section" "hf.profile.roomsSection" "$PROFILE_SOURCE"
require_rg "Profile product suite progress" "hf.profile.productSuiteProgress" "$PROFILE_SOURCE"
require_rg "Profile public momentum summary" "hf.profile.publicMomentumSummary" "$PROFILE_SOURCE"
require_rg "Profile internal section" "hf.profile.internalSection" "$PROFILE_SOURCE"
require_rg "Profile summary copy" "Launch \\+ Connect Momentum" "$PROFILE_SOURCE"

require_rg "Home root identifier" "hf.consumer.home.root" "$HOME_SOURCE"
require_rg "Home premiere momentum copy" "Premieres Building Momentum" "$HOME_SOURCE"
require_rg "Home premiere momentum identifier" "hf.consumer.home.premiereMomentum" "$HOME_SOURCE"
require_rg "Home tonight remains" "hf.consumer.home.tonight" "$HOME_SOURCE"
require_rg "Home momentum remains" "hf.consumer.home.momentum" "$HOME_SOURCE"

require_rg "Movie Detail root identifier" "hf.consumer.movieDetail.root" "$DETAIL_SOURCE"
require_rg "Movie Detail public momentum copy" "Public Momentum" "$DETAIL_SOURCE"
require_rg "Movie Detail public momentum identifier" "hf.consumer.movieDetail.publicMomentum" "$DETAIL_SOURCE"
require_rg "Movie Detail decision panel remains" "hf.consumer.movieDetail.decisionPanel" "$DETAIL_SOURCE"
require_rg "Movie Detail context remains" "hf.consumer.movieDetail.viewingContext" "$DETAIL_SOURCE"
require_rg "Movie Detail related remains" "hf.consumer.movieDetail.moreLikeThis" "$DETAIL_SOURCE"

TAB_TITLES="$(rg -o 'HFTabItem\([^)]*title: "[^"]+"' "$ROOT_SOURCE" | sed -E 's/.*title: ("[^"]+").*/\1/' | tr '\n' ' ')"
for title in '"Home"' '"Search"' '"Library"' '"Downloads"' '"Profile"'; do
  if [[ "$TAB_TITLES" == *"$title"* ]]; then
    record "Bottom tab $title" "pass" "$TAB_TITLES"
  else
    record "Bottom tab $title" "fail" "$TAB_TITLES"
  fi
done

for forbidden in '"Connect"' '"Launch"' '"Community"' '"Campaign"' '"Calendar"' '"Messages"' '"Chat"' '"Notifications"' '"Tickets"' '"Waitlist"' '"Creator"' '"Studio"' '"Export"' '"Rooms"' '"Developer"' '"QA"' '"Demo"' '"Tour"' '"Command Center"'; do
  if [[ "$TAB_TITLES" == *"$forbidden"* ]]; then
    record "No room/internal tab $forbidden" "fail" "$TAB_TITLES"
  else
    record "No room/internal tab $forbidden" "pass" "$TAB_TITLES"
  fi
done

require_rg "Developer QA remains profile-internal" "hf.profile.internalSection|Developer / QA|DeveloperQAHubView" "$PROFILE_SOURCE"
require_rg "Tour remains internal source" "FinalDemoTourView" "$PROFILE_SOURCE"
reject_rg "Consumer Home has no internal route language" "Developer / QA|FinalDemoTourView|Command Center" "$HOME_SOURCE"
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
  printf '  "upgrade": "#023.0B",\n'
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
  printf '# Launch Connect Public Momentum Source Verification\n\n'
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
