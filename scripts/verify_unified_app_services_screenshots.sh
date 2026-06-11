#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-28-0b-unified-services-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/unified_app_services_screenshot_verification.json"
MD_REPORT="$OUT_DIR/unified_app_services_screenshot_verification.md"
MANIFEST="$SHOT_DIR/unified_app_services_screenshot_manifest.json"
mkdir -p "$OUT_DIR"

required=(
  "home_connected.png"
  "movie_detail_connected.png"
  "library_connected.png"
  "downloads_connected.png"
  "connect_connected.png"
  "launch_connected.png"
  "export_connected.png"
  "profile_connected.png"
)

optional=(
  "onboarding_connected.png"
  "demo_tour_connected.png"
)

passes=()
failures=()

for name in "${required[@]}"; do
  if [[ -s "$SHOT_DIR/$name" ]]; then
    passes+=("required screenshot exists: $name")
  else
    failures+=("missing or empty required screenshot: $name")
  fi
done

for name in "${optional[@]}"; do
  if [[ -s "$SHOT_DIR/$name" ]]; then
    passes+=("optional screenshot exists: $name")
  else
    passes+=("optional screenshot not captured: $name")
  fi
done

if [[ -s "$MANIFEST" ]]; then
  passes+=("manifest exists")
else
  failures+=("manifest missing")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#028.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "note": "Screenshots exist and require manual visual inspection.",\n'
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "${passes[$i]}" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "${failures[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Unified App Services Screenshot Verification\n\n'
  printf -- '- Upgrade: #028.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Note: Screenshots exist and require manual visual inspection.\n\n'
  printf '## Passes\n\n'
  for item in "${passes[@]}"; do printf -- '- %s\n' "$item"; done
  printf '\n## Failures\n\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
  fi
} > "$MD_REPORT"

printf 'Unified app services screenshot verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
