#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-26-0b-functional-core-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/functional_app_core_screenshot_verification.json"
MD_REPORT="$OUT_DIR/functional_app_core_screenshot_verification.md"
MANIFEST_JSON="$SHOT_DIR/functional_app_core_screenshot_manifest.json"
MANIFEST_MD="$SHOT_DIR/functional_app_core_screenshot_manifest.md"

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

optional_nonempty() {
  local name="$1"
  local path="$2"
  if [[ -s "$path" ]]; then
    local size
    size="$(stat -f%z "$path")"
    record "$name" "present" "$path ($size bytes)"
  else
    record "$name" "absent_but_optional" "$path not captured"
  fi
}

require_nonempty "Screenshot manifest JSON" "$MANIFEST_JSON"
require_nonempty "Screenshot manifest Markdown" "$MANIFEST_MD"
require_nonempty "Home functional core screenshot" "$SHOT_DIR/home_functional_core.png"
require_nonempty "Movie Detail functional core screenshot" "$SHOT_DIR/movie_detail_functional_core.png"
require_nonempty "Library functional state screenshot" "$SHOT_DIR/library_functional_state.png"
require_nonempty "Downloads functional state screenshot" "$SHOT_DIR/downloads_functional_state.png"
require_nonempty "Connect local updates screenshot" "$SHOT_DIR/connect_local_updates.png"
require_nonempty "Launch local checklist screenshot" "$SHOT_DIR/launch_local_checklist.png"
require_nonempty "Export delivery summary screenshot" "$SHOT_DIR/export_delivery_summary.png"
require_nonempty "Profile functional core screenshot" "$SHOT_DIR/profile_functional_core.png"
optional_nonempty "Onboarding brand intro screenshot" "$SHOT_DIR/onboarding_brand_intro.png"
optional_nonempty "Demo Tour functional core screenshot" "$SHOT_DIR/demo_tour_functional_core.png"

{
  printf '{\n'
  printf '  "upgrade": "#026.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "honesty_note": "Screenshots exist and are non-empty. They require manual visual inspection and do not prove interactive behavior automatically.",\n'
  printf '  "checks": [\n'
  for i in "${!RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${RESULTS[$i]}"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Functional App Core Screenshot Verification\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  printf 'Honesty note: screenshots exist and are non-empty. They require manual visual inspection and do not prove interactive behavior automatically.\n\n'
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
