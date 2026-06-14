#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-47-0b-product-ux-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/product_ux_overhaul_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/product_ux_overhaul_screenshot_verification.json"
MD_OUT="$OUT_DIR/product_ux_overhaul_screenshot_verification.md"

required=(
  onboarding_intro
  training_controls
  timeline_practice
  home
  search
  library
  downloads
  profile
  creator_studio
  social_media_kit
  vod_package
  movie_detail
)

mkdir -p "$OUT_DIR"

failures=0
declare -a RESULTS=()

record() {
  local id="$1"
  local status="$2"
  local detail="$3"
  RESULTS+=("{\"id\":\"$id\",\"status\":\"$status\",\"detail\":\"$detail\"}")
  if [[ "$status" != "pass" ]]; then
    failures=$((failures + 1))
  fi
}

if [[ -d "$SCREENSHOT_DIR" ]]; then
  record screenshot_folder pass "$SCREENSHOT_DIR exists."
else
  record screenshot_folder fail "$SCREENSHOT_DIR missing."
fi

if [[ -s "$MANIFEST_JSON" ]]; then
  record manifest pass "$MANIFEST_JSON exists."
else
  record manifest fail "$MANIFEST_JSON missing."
fi

for name in "${required[@]}"; do
  path="$SCREENSHOT_DIR/$name.png"
  if [[ -s "$path" ]]; then
    bytes="$(wc -c < "$path" | tr -d ' ')"
    record "$name" pass "$path is non-empty ($bytes bytes)."
  else
    record "$name" fail "$path missing or empty."
  fi
done

status="pass"
if [[ "$failures" -ne 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#047.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "visual_truth_claim": "non-empty screenshot proof only",\n'
  printf '  "results": [\n'
  for i in "${!RESULTS[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#RESULTS[@]} - 1)) ]]; then comma=""; fi
    printf '    %s%s\n' "${RESULTS[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Product UX Screenshot Verification\n\n'
  printf -- '- Upgrade: #047.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Claim: non-empty screenshot proof only\n\n'
  printf '## Checks\n\n'
  for item in "${RESULTS[@]}"; do
    printf -- '- %s\n' "$item"
  done
} > "$MD_OUT"

printf 'Screenshot verification %s. JSON: %s MD: %s\n' "$status" "$JSON_OUT" "$MD_OUT"
[[ "$status" == "pass" ]]
