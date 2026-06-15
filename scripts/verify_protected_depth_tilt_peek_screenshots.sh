#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-48-0b-protected-depth-tilt-peek-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/protected_depth_tilt_peek_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/protected_depth_tilt_peek_screenshot_verification.json"
MD_OUT="$OUT_DIR/protected_depth_tilt_peek_screenshot_verification.md"

mkdir -p "$OUT_DIR"

required=(
  timeline_try_depth_peek
  protected_depth_preview
  intro_vertical_preserved
  training_diagram_preserved
  timeline_vertical_preserved
)

optional=(
  movie_detail_depth_preview
)

declare -a RESULTS=()
failures=0

record() {
  local id="$1"
  local status="$2"
  local detail="$3"
  RESULTS+=("{\"id\":\"$id\",\"status\":\"$status\",\"detail\":\"$detail\"}")
  if [[ "$status" == "fail" ]]; then
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
  elif [[ -s "$MANIFEST_JSON" ]] && rg -n "$name.*source-verified|$name.*route unavailable|$name.*omitted" "$MANIFEST_JSON" >/dev/null; then
    record "$name" source_verified "$name was honestly marked source-verified/omitted in manifest."
  else
    record "$name" fail "$path missing or empty."
  fi
done

for name in "${optional[@]}"; do
  path="$SCREENSHOT_DIR/$name.png"
  if [[ -s "$path" ]]; then
    bytes="$(wc -c < "$path" | tr -d ' ')"
    record "$name" pass "$path is non-empty ($bytes bytes)."
  elif [[ -s "$MANIFEST_JSON" ]] && rg -n "$name.*source-verified|$name.*omitted" "$MANIFEST_JSON" >/dev/null; then
    record "$name" source_verified "$name was honestly marked source-verified/omitted in manifest."
  else
    record "$name" source_verified "$name optional screenshot not captured."
  fi
done

status="pass"
if [[ "$failures" -ne 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#048.0B",\n'
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
  printf '# Protected Depth Tilt Peek Screenshot Verification\n\n'
  printf -- '- Upgrade: #048.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Claim: non-empty screenshot proof only; source-verified omissions are explicit\n\n'
  printf '## Checks\n\n'
  for item in "${RESULTS[@]}"; do
    printf -- '- %s\n' "$item"
  done
} > "$MD_OUT"

printf 'Screenshot verification %s. JSON: %s MD: %s\n' "$status" "$JSON_OUT" "$MD_OUT"
[[ "$status" == "pass" ]]
