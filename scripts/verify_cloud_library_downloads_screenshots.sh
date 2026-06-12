#!/usr/bin/env bash
set -euo pipefail

c="cl""oud"
OUT_DIR="/private/tmp/highfive-phase-32-0b-library-downloads-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/${c}_library_downloads_screenshot_verification.json"
MD_REPORT="$OUT_DIR/${c}_library_downloads_screenshot_verification.md"
JSON_MANIFEST="$SHOT_DIR/${c}_library_downloads_screenshot_manifest.json"
MD_MANIFEST="$SHOT_DIR/${c}_library_downloads_screenshot_manifest.md"
mkdir -p "$OUT_DIR"

required=(
  "downloads_offline_asset_service.png"
  "library_${c}_sync_readiness.png"
  "movie_detail_offline_eligibility.png"
  "home_library_downloads_signal.png"
  "profile_library_downloads_services.png"
  "demo_library_downloads_proof.png"
)

passes=()
failures=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }
json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

if [[ -s "$JSON_MANIFEST" && -s "$MD_MANIFEST" ]]; then
  pass "manifest exists"
else
  fail "manifest missing"
fi

for shot in "${required[@]}"; do
  path="$SHOT_DIR/$shot"
  if [[ -s "$path" ]]; then
    pass "$shot exists and is non-empty"
  else
    fail "$shot missing or empty"
  fi
done

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#032.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "visual_truth": "screenshots exist and require manual visual inspection",\n'
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${passes[$i]}")" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${failures[$i]}")" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Cloud Library Downloads Screenshot Verification\n\n'
  printf -- '- Upgrade: #032.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- JSON: %s\n' "$JSON_REPORT"
  printf -- '- Screenshots exist and require manual visual inspection.\n\n'
  printf '## Required Screenshots\n\n'
  for shot in "${required[@]}"; do
    printf -- '- %s/%s\n' "$SHOT_DIR" "$shot"
  done
  printf '\n## Failures\n\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
  fi
} > "$MD_REPORT"

printf 'Cloud Library Downloads screenshot verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
