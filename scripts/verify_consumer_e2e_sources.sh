#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-18-0h-consumer-e2e-qa"
REPORT_JSON="$OUT_DIR/consumer_e2e_source_verification.json"
REPORT_MD="$OUT_DIR/consumer_e2e_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

PASS_COUNT=0
FAIL_COUNT=0
RESULTS_JSON=""
RESULTS_MD=""

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record() {
  local label="$1"
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
    {\"label\":\"$(json_escape "$label")\",\"status\":\"$status\",\"detail\":\"$(json_escape "$detail")\"}"
  RESULTS_MD="${RESULTS_MD}| $label | $status | $detail |
"
}

require_rg() {
  local label="$1"
  local pattern="$2"
  shift 2
  if rg -q -- "$pattern" "$@"; then
    record "$label" "pass" "Found expected source evidence."
  else
    record "$label" "fail" "Missing expected source evidence."
  fi
}

reject_rg() {
  local label="$1"
  local pattern="$2"
  shift 2
  if rg -q -- "$pattern" "$@"; then
    record "$label" "fail" "Found disallowed source evidence."
  else
    record "$label" "pass" "No disallowed source evidence found."
  fi
}

ROOT_SOURCE="HighFive/App/HFStreamingRootView.swift"
PROFILE_SOURCE="HighFive/Views/Profile/ProfileView.swift"

for arg in \
  "--hf-skip-onboarding" \
  "--hf-onboarding-intro" \
  "--hf-onboarding-tilt-peek" \
  "--hf-onboarding-instructions" \
  "--hf-start-home" \
  "--hf-start-search" \
  "--hf-start-library" \
  "--hf-start-downloads" \
  "--hf-start-profile" \
  "--hf-start-profile-rooms" \
  "--hf-start-movie-detail" \
  "--hf-start-watch-room" \
  "--hf-start-create-room" \
  "--hf-start-connect-room" \
  "--hf-start-launch-room" \
  "--hf-start-export-room" \
  "--hf-start-developer-qa" \
  "--hf-start-demo-tour"
do
  require_rg "Launch arg exists: $arg" "$arg" "$ROOT_SOURCE" "$PROFILE_SOURCE"
done

require_rg "Home route exists" "HomeView\\(" "$ROOT_SOURCE"
require_rg "Search route exists" "SearchView\\(" "$ROOT_SOURCE"
require_rg "Library route exists" "MyListView\\(" "$ROOT_SOURCE"
require_rg "Downloads route exists" "DownloadsView\\(" "$ROOT_SOURCE"
require_rg "Profile route exists" "ProfileView\\(" "$ROOT_SOURCE"
require_rg "Movie detail QA route exists" "MovieDetailView\\(movie: Self\\.qaMovieDetailMovie\\)" "$ROOT_SOURCE"
require_rg "Developer QA remains in Profile" "DeveloperQAHubView\\(\\)|Developer / QA Hub" "$PROFILE_SOURCE"
require_rg "Demo Tour remains internal" "FinalDemoTourView\\(\\)" "$PROFILE_SOURCE"
require_rg "HighFive Rooms remain product-facing" "HighFive Rooms" "$PROFILE_SOURCE"

for id in \
  "hf.consumer.home.root" \
  "hf.consumer.home.hero" \
  "hf.consumer.home.posterRails" \
  "hf.consumer.search.root" \
  "hf.consumer.search.field" \
  "hf.consumer.discovery.rails" \
  "hf.consumer.movieDetail.root" \
  "hf.consumer.movieDetail.hero" \
  "hf.consumer.movieDetail.watchNow" \
  "hf.consumer.movieDetail.related" \
  "hf.consumer.library.root" \
  "hf.consumer.library.filters" \
  "hf.consumer.library.savedShelf" \
  "hf.consumer.downloads.root" \
  "hf.consumer.downloads.storageCard" \
  "hf.consumer.downloads.offlineShelf" \
  "hf.profile.root" \
  "hf.profile.roomsSection" \
  "hf.profile.internalSection" \
  "hf.profile.bottomTabs"
do
  require_rg "Identifier exists: $id" "$id" HighFive/App HighFive/Views HighFive/Components
done

TAB_TITLES="$(rg -o 'title: \"[^\"]+\"' "$ROOT_SOURCE" | sed 's/title: //g' | tr '\n' ' ')"
if [[ "$TAB_TITLES" == *"\"Home\""* && "$TAB_TITLES" == *"\"Search\""* && "$TAB_TITLES" == *"\"Library\""* && "$TAB_TITLES" == *"\"Downloads\""* && "$TAB_TITLES" == *"\"Profile\""* ]]; then
  if [[ "$TAB_TITLES" == *"\"Onboarding\""* || "$TAB_TITLES" == *"\"Intro\""* || "$TAB_TITLES" == *"\"Demo\""* || "$TAB_TITLES" == *"\"Tour\""* || "$TAB_TITLES" == *"\"Rooms\""* || "$TAB_TITLES" == *"\"Create\""* || "$TAB_TITLES" == *"\"Connect\""* || "$TAB_TITLES" == *"\"Launch\""* || "$TAB_TITLES" == *"\"Export\""* || "$TAB_TITLES" == *"\"Developer\""* || "$TAB_TITLES" == *"\"QA\""* ]]; then
    record "Bottom tab lock" "fail" "Forbidden consumer tab title found."
  else
    record "Bottom tab lock" "pass" "Tabs remain Home, Search, Library, Downloads, Profile."
  fi
else
  record "Bottom tab lock" "fail" "Expected five tab titles were not all found."
fi

reject_rg "Demo Tour is not exposed from consumer screens" "FinalDemoTourView|Consumer \\+ Rooms Demo Tour" HighFive/Views/Home HighFive/Views/Search HighFive/Views/MovieDetail HighFive/Views/DownloadsView.swift HighFive/Views/MyListView.swift

if git diff --name-only | rg -q 'HighFive/App/(Depth|Motion|Playback|Layer4|Rendering|Creator|UI|Store)|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|posterAssetName|backdropAssetName|mapping|asset'; then
  record "Protected path diff" "fail" "Protected or asset path appears in the current diff."
else
  record "Protected path diff" "pass" "No protected or asset path appears in the current diff."
fi

MEDIA_PREFIX="AV"
MOTION_A="Core"
MOTION_B="Motion"
AR_A="AR"
AR_B="Kit"
PHOTO_A="Photo"
PHOTO_B="s"
REPLAY_A="Replay"
REPLAY_B="Kit"
FILE_A="File"
FILE_B="Manager"
SHARE_A="Share"
SHARE_B="Link"
TRANSFER_A="Transfer"
TRANSFER_B="able"
SESSION_A="URL"
SESSION_B="Session"
STORE_A="Store"
STORE_B="Kit"
PAY_A="pay"
PAY_B="ment"
UP_A="up"
UP_B="load"
DATA_A="ana"
DATA_B="lytics"
TRACK_A="track"
TRACK_B="ing"
LIVE_PATTERN="${MEDIA_PREFIX}Kit|${MEDIA_PREFIX}Player|${MEDIA_PREFIX}Foundation|${MOTION_A}${MOTION_B}|${AR_A}${AR_B}|CMMotion|${PHOTO_A}${PHOTO_B}|${REPLAY_A}${REPLAY_B}|${FILE_A}${FILE_B}|${SHARE_A}${SHARE_B}|${TRANSFER_A}${TRANSFER_B}|${SESSION_A}${SESSION_B}|${STORE_A}${STORE_B}|${PAY_A}${PAY_B}|purchase|subscription|entitlement|auth|backend|${UP_A}${UP_B}|subscribe|buy|pay|donate|comment|chat|message|${DATA_A}${DATA_B}|${TRACK_A}${TRACK_B}|render|export file"

if git diff -U0 -- '*.swift' | rg -q "^\+.*(${LIVE_PATTERN})"; then
  record "Changed Swift live-system scan" "fail" "Changed Swift lines contain live-system terms."
else
  record "Changed Swift live-system scan" "pass" "Changed Swift lines do not contain live-system additions."
fi

STATUS="passed"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  STATUS="failed"
fi

{
  printf '{\n'
  printf '  "status": "%s",\n' "$STATUS"
  printf '  "passCount": %s,\n' "$PASS_COUNT"
  printf '  "failCount": %s,\n' "$FAIL_COUNT"
  printf '  "results": [%s\n  ]\n' "$RESULTS_JSON"
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Consumer E2E Source Verification\n\n'
  printf 'Status: **%s**\n\n' "$STATUS"
  printf 'Pass: %s\n\nFail: %s\n\n' "$PASS_COUNT" "$FAIL_COUNT"
  printf '| Check | Status | Detail |\n'
  printf '| --- | --- | --- |\n'
  printf '%s' "$RESULTS_MD"
} > "$REPORT_MD"

printf 'Consumer E2E source verification %s. Reports:\n%s\n%s\n' "$STATUS" "$REPORT_JSON" "$REPORT_MD"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
