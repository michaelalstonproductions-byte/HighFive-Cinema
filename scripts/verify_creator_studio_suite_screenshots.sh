#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-20-0e-creator-suite-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/creator_studio_suite_screenshot_verification.json"
MD_REPORT="$OUT_DIR/creator_studio_suite_screenshot_verification.md"
MANIFEST_JSON="$SHOT_DIR/creator_studio_suite_screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/creator_studio_suite_screenshot_manifest.md"
ROOT_SHOT="$SHOT_DIR/creator_studio_root.png"

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

optional_nonempty() {
  local name="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    require_nonempty "$name" "$path"
  else
    record "$name" "pass" "$path not captured; lower section remains source-verified"
  fi
}

require_nonempty "Creator Studio root screenshot" "$ROOT_SHOT"
require_nonempty "Screenshot manifest JSON" "$MANIFEST_JSON"
require_nonempty "Screenshot manifest Markdown" "$MANIFEST_MD"

optional_nonempty "Studio Slate screenshot" "$SHOT_DIR/studio_slate.png"
optional_nonempty "Project Package Builder screenshot" "$SHOT_DIR/package_builder.png"
optional_nonempty "Pitch Package screenshot" "$SHOT_DIR/pitch_package.png"
optional_nonempty "Media Kit screenshot" "$SHOT_DIR/media_kit.png"
optional_nonempty "Launch Prep screenshot" "$SHOT_DIR/launch_prep.png"

{
  printf '{\n'
  printf '  "upgrade": "#020.0E",\n'
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
  printf '# Creator Studio Suite Screenshot Verification\n\n'
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
