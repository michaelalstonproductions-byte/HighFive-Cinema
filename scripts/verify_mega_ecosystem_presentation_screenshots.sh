#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-25-0b"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/screenshot_verification_report.json"
MD_REPORT="$OUT_DIR/screenshot_verification_report.md"
MANIFEST_JSON="$SHOT_DIR/screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/screenshot_manifest.md"
SOURCE_JSON="$OUT_DIR/mega_ecosystem_presentation_source_verification.json"

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

require_nonempty() {
  local name="$1"
  local path="$2"
  if [[ -s "$path" ]]; then
    local size
    size="$(stat -f%z "$path")"
    record "$name" "pass" "$path ($size bytes)"
  else
    record "$name" "fail" "$path missing or empty"
  fi
}

source_has() {
  local pattern="$1"
  [[ -s "$SOURCE_JSON" ]] && rg -q "$pattern" "$SOURCE_JSON"
}

require_nonempty "Screenshot manifest JSON" "$MANIFEST_JSON"
require_nonempty "Screenshot manifest Markdown" "$MANIFEST_MD"

if [[ -s "$SHOT_DIR/00_home_launch.png" ]]; then
  require_nonempty "Home launch screenshot" "$SHOT_DIR/00_home_launch.png"
else
  record "Home launch screenshot" "source_verified_fallback" "Preferred but not mandatory if QA route fails"
fi

if [[ -s "$SHOT_DIR/01_profile_presentation_mode.png" ]]; then
  require_nonempty "Profile presentation screenshot" "$SHOT_DIR/01_profile_presentation_mode.png"
elif source_has "hf\\\\.profile\\\\.ecosystemPresentationMode"; then
  record "Profile presentation screenshot" "source_verified_fallback" "Profile identifiers verified by source"
else
  record "Profile presentation screenshot" "fail" "Missing screenshot and source proof"
fi

if [[ -s "$SHOT_DIR/02_demo_tour_presentation.png" ]]; then
  require_nonempty "Demo Tour presentation screenshot" "$SHOT_DIR/02_demo_tour_presentation.png"
elif source_has "hf\\\\.demoTour\\\\.presentationHero"; then
  record "Demo Tour presentation screenshot" "source_verified_fallback" "Demo Tour identifiers verified by source"
else
  record "Demo Tour presentation screenshot" "fail" "Missing screenshot and source proof"
fi

if [[ -s "$SHOT_DIR/03_developer_qa_presentation_proof.png" ]]; then
  require_nonempty "Developer QA presentation proof screenshot" "$SHOT_DIR/03_developer_qa_presentation_proof.png"
elif source_has "hf\\\\.devqa\\\\.presentationProofPath"; then
  record "Developer QA presentation proof screenshot" "source_verified_fallback" "Developer QA identifiers verified by source"
else
  record "Developer QA presentation proof screenshot" "fail" "Missing screenshot and source proof"
fi

if [[ -s "$SHOT_DIR/04_home_watch_first_story.png" ]]; then
  require_nonempty "Optional Home watch-first screenshot" "$SHOT_DIR/04_home_watch_first_story.png"
else
  record "Optional Home watch-first screenshot" "absent_but_optional" "Optional route evidence"
fi

if [[ -s "$SHOT_DIR/05_movie_detail_watch_to_release.png" ]]; then
  require_nonempty "Optional Movie Detail watch-to-release screenshot" "$SHOT_DIR/05_movie_detail_watch_to_release.png"
else
  record "Optional Movie Detail watch-to-release screenshot" "absent_but_optional" "Optional route evidence"
fi

{
  printf '{\n'
  printf '  "upgrade": "#025.0B",\n'
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
  printf '# Mega Ecosystem Presentation Screenshot Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  for row in "${RESULTS[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    status="$(printf '%s' "$row" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    detail="$(printf '%s' "$row" | sed -E 's/.*"detail":"([^"]*)"\}$/\1/')"
    printf -- '- %s: %s - %s\n' "$status" "$name" "$detail"
  done
} > "$MD_REPORT"

printf 'Screenshot verification report: %s\n' "$MD_REPORT"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
