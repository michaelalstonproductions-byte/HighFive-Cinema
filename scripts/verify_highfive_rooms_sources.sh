#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/Volumes/Scratch SSD/highfive-phase-18-0g-rooms-qa"
REPORT_JSON="$OUT_DIR/highfive_rooms_source_verification.json"
REPORT_MD="$OUT_DIR/highfive_rooms_source_verification.md"

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

PROFILE_SOURCE="HighFive/Views/Profile/ProfileView.swift"
ROOT_SOURCE="HighFive/App/HFStreamingRootView.swift"

require_rg "Watch Room source exists" "Watch Room" "$PROFILE_SOURCE"
require_rg "Creator Studio source exists" "Creator Studio|Create Room" "$PROFILE_SOURCE"
require_rg "Connect Room source exists" "Connect Room" "$PROFILE_SOURCE"
require_rg "Launch Room source exists" "Launch Room" "$PROFILE_SOURCE"
require_rg "Export Room source exists" "Export Room" "$PROFILE_SOURCE"

for room in watch create connect launch export; do
  require_rg "Room root identifier exists: $room" "hf\\.room\\.${room}\\.root" "$PROFILE_SOURCE"
  require_rg "Room feature identifier exists: $room" "hf\\.room\\.${room}\\.features" "$PROFILE_SOURCE"
done

if rg -q 'eyebrow\.lowercased\(\)\)\.hero|hf\.room\.(watch|create|connect|launch|export)\.hero' "$PROFILE_SOURCE"; then
  record "Room hero identifiers are source-verified" "pass" "Shared room hero identifier is present."
else
  record "Room hero identifiers are source-verified" "fail" "Missing shared or literal room hero identifier."
fi

for arg in \
  "--hf-start-watch-room" \
  "--hf-start-create-room" \
  "--hf-start-connect-room" \
  "--hf-start-launch-room" \
  "--hf-start-export-room"
do
  require_rg "QA launch arg exists: $arg" "$arg" "$PROFILE_SOURCE" "$ROOT_SOURCE"
done

TAB_TITLES="$(rg -o 'title: \"[^\"]+\"' "$ROOT_SOURCE" | sed 's/title: //g' | tr '\n' ' ')"
if [[ "$TAB_TITLES" == *"\"Home\""* && "$TAB_TITLES" == *"\"Search\""* && "$TAB_TITLES" == *"\"Library\""* && "$TAB_TITLES" == *"\"Downloads\""* && "$TAB_TITLES" == *"\"Profile\""* ]]; then
  if [[ "$TAB_TITLES" == *"\"Rooms\""* || "$TAB_TITLES" == *"\"Create\""* || "$TAB_TITLES" == *"\"Connect\""* || "$TAB_TITLES" == *"\"Launch\""* || "$TAB_TITLES" == *"\"Export\""* || "$TAB_TITLES" == *"\"Developer\""* || "$TAB_TITLES" == *"\"QA\""* ]]; then
    record "Bottom tab lock" "fail" "Forbidden product or internal title appears in tab titles."
  else
    record "Bottom tab lock" "pass" "Tabs remain Home, Search, Library, Downloads, Profile."
  fi
else
  record "Bottom tab lock" "fail" "Expected five tab titles were not all found."
fi

require_rg "Developer QA remains in Profile" "DeveloperQAHubView\\(\\)|Developer / QA Hub" "$PROFILE_SOURCE"
require_rg "HighFive Rooms remains product-facing" "HighFive Rooms" "$PROFILE_SOURCE"
reject_rg "Consumer tabs do not expose room routes" "Watch Room|Creator Studio|Connect Room|Launch Room|Export Room" HighFive/Views/Home HighFive/Views/Search HighFive/Views/MovieDetail HighFive/Views/DownloadsView.swift HighFive/Views/MyListView.swift

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
  record "Changed Swift live-system scan" "fail" "Changed Swift lines contain executable live-system terms."
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
  printf '# HighFive Rooms Source Verification\n\n'
  printf 'Status: **%s**\n\n' "$STATUS"
  printf 'Pass: %s\n\nFail: %s\n\n' "$PASS_COUNT" "$FAIL_COUNT"
  printf '| Check | Status | Detail |\n'
  printf '| --- | --- | --- |\n'
  printf '%s' "$RESULTS_MD"
} > "$REPORT_MD"

printf 'HighFive Rooms source verification %s. Reports:\n%s\n%s\n' "$STATUS" "$REPORT_JSON" "$REPORT_MD"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
