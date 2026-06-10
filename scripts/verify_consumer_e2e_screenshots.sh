#!/usr/bin/env bash
set -euo pipefail

OUT_ROOT="/Volumes/Scratch SSD/highfive-phase-18-0h-consumer-e2e-qa"
OUT_DIR="$OUT_ROOT/screenshots"
MANIFEST_JSON="$OUT_DIR/consumer_e2e_screenshot_manifest.json"
MANIFEST_MD="$OUT_DIR/consumer_e2e_screenshot_manifest.md"
REPORT_JSON="$OUT_ROOT/consumer_e2e_screenshot_verification.json"
REPORT_MD="$OUT_ROOT/consumer_e2e_screenshot_verification.md"

REQUIRED=(
  "onboarding_intro.png"
  "onboarding_tilt_peek.png"
  "onboarding_instructions.png"
  "home.png"
  "search_discover.png"
  "movie_detail.png"
  "library.png"
  "downloads.png"
  "profile.png"
  "profile_rooms_gateway.png"
  "watch_room.png"
  "creator_studio.png"
  "connect_room.png"
  "launch_room.png"
  "export_room.png"
  "developer_qa.png"
  "demo_tour.png"
)

PASS_COUNT=0
FAIL_COUNT=0
RESULTS_JSON=""
RESULTS_MD=""

mkdir -p "$OUT_ROOT"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record() {
  local file="$1"
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
    {\"file\":\"$(json_escape "$file")\",\"status\":\"$status\",\"detail\":\"$(json_escape "$detail")\"}"
  RESULTS_MD="${RESULTS_MD}| \`$file\` | $status | $detail |
"
}

if [[ -s "$MANIFEST_JSON" && -s "$MANIFEST_MD" ]]; then
  record "manifest" "pass" "Manifest JSON and Markdown exist."
else
  record "manifest" "fail" "Missing or empty screenshot manifest."
fi

for file in "${REQUIRED[@]}"; do
  path="$OUT_DIR/$file"
  if [[ -s "$path" && "${file##*.}" == "png" ]]; then
    size=$(wc -c < "$path" | tr -d ' ')
    record "$file" "pass" "PNG exists and is non-empty: ${size} bytes. Manual visual inspection is still required."
  else
    record "$file" "fail" "Missing, empty, or not a PNG at $path."
  fi
done

{
  printf '{\n'
  printf '  "passCount": %s,\n' "$PASS_COUNT"
  printf '  "failCount": %s,\n' "$FAIL_COUNT"
  printf '  "manualVisualInspectionRequired": true,\n'
  printf '  "results": [%s\n  ]\n' "$RESULTS_JSON"
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Consumer E2E Screenshot Verification\n\n'
  printf 'Pass: %s\n\nFail: %s\n\n' "$PASS_COUNT" "$FAIL_COUNT"
  printf 'Screenshots exist and require manual visual inspection. This script verifies file evidence only.\n\n'
  printf '| File | Status | Detail |\n'
  printf '| --- | --- | --- |\n'
  printf '%s' "$RESULTS_MD"
} > "$REPORT_MD"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  printf 'Consumer E2E screenshot verification failed. See:\n%s\n%s\n' "$REPORT_JSON" "$REPORT_MD" >&2
  exit 1
fi

printf 'Consumer E2E screenshot verification passed. Reports:\n%s\n%s\n' "$REPORT_JSON" "$REPORT_MD"
