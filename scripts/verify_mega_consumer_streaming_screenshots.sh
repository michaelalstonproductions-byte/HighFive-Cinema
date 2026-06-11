#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-22-0b-consumer-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/mega_consumer_streaming_screenshot_verification.json"
MD_REPORT="$OUT_DIR/mega_consumer_streaming_screenshot_verification.md"
MANIFEST_JSON="$SHOT_DIR/mega_consumer_streaming_screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/mega_consumer_streaming_screenshot_manifest.md"

mkdir -p "$OUT_DIR"

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

require_nonempty "Home screenshot" "$SHOT_DIR/home.png"
require_nonempty "Search screenshot" "$SHOT_DIR/search.png"
require_nonempty "Movie Detail screenshot" "$SHOT_DIR/movie_detail.png"
require_nonempty "Library screenshot" "$SHOT_DIR/library.png"
require_nonempty "Downloads screenshot" "$SHOT_DIR/downloads.png"
require_nonempty "Profile screenshot" "$SHOT_DIR/profile.png"
require_nonempty "Screenshot manifest JSON" "$MANIFEST_JSON"
require_nonempty "Screenshot manifest Markdown" "$MANIFEST_MD"

{
  printf '{\n'
  printf '  "upgrade": "#022.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "note": "Screenshots exist and require manual visual inspection.",\n'
  printf '  "checks": [\n'
  for i in "${!RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${RESULTS[$i]}"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Mega Consumer Streaming Screenshot Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  printf 'Screenshots exist and require manual visual inspection.\n\n'
  for row in "${RESULTS[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    status="$(printf '%s' "$row" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    detail="$(printf '%s' "$row" | sed -E 's/.*"detail":"([^"]*)"\}$/\1/')"
    printf -- '- %s: %s — %s\n' "$status" "$name" "$detail"
  done
} > "$MD_REPORT"

printf 'Screenshot verification report: %s\n' "$MD_REPORT"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
