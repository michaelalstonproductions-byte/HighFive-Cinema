#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-31-0b-player-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/streaming_player_service_screenshot_verification.json"
MD_REPORT="$OUT_DIR/streaming_player_service_screenshot_verification.md"
JSON_MANIFEST="$SHOT_DIR/streaming_player_service_screenshot_manifest.json"
MD_MANIFEST="$SHOT_DIR/streaming_player_service_screenshot_manifest.md"
mkdir -p "$OUT_DIR"

required=(
  "movie_detail_player_service.png"
  "home_player_ready.png"
  "library_player_context.png"
  "downloads_player_context.png"
  "watch_room_player_readiness.png"
  "profile_player_service.png"
  "demo_player_proof.png"
)

optional=(
  "player_surface.png"
)

passes=()
failures=()
skipped=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }
skip() { skipped+=("$1"); }
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

for shot in "${optional[@]}"; do
  path="$SHOT_DIR/$shot"
  if [[ -s "$path" ]]; then
    pass "$shot optional screenshot exists and is non-empty"
  else
    skip "$shot optional screenshot skipped; source verification required"
  fi
done

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#031.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "visual_truth": "screenshots exist and require manual visual inspection",\n'
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${passes[$i]}")" "$comma"
  done
  printf '  ],\n'
  printf '  "skipped": [\n'
  for i in "${!skipped[@]}"; do
    comma=","
    [[ "$i" -eq $((${#skipped[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${skipped[$i]}")" "$comma"
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
  printf '# Streaming Player Service Screenshot Verification\n\n'
  printf -- '- Upgrade: #031.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- JSON: %s\n' "$JSON_REPORT"
  printf -- '- Screenshots exist and require manual visual inspection.\n\n'
  printf '## Required Screenshots\n\n'
  for shot in "${required[@]}"; do
    printf -- '- %s/%s\n' "$SHOT_DIR" "$shot"
  done
  printf '\n## Optional Screenshots\n\n'
  for item in "${skipped[@]}"; do printf -- '- %s\n' "$item"; done
  printf '\n## Failures\n\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
  fi
} > "$MD_REPORT"

printf 'Streaming player service screenshot verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
