#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-56-0b-streaming-provider-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$OUT_DIR/streaming_provider_staging_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/streaming_provider_staging_screenshot_verification.json"
MD_OUT="$OUT_DIR/streaming_provider_staging_screenshot_verification.md"

mkdir -p "$OUT_DIR"

failures=()
verified=()

[[ -d "$SCREENSHOT_DIR" ]] || failures+=("Screenshot folder is missing: $SCREENSHOT_DIR")
[[ -s "$MANIFEST_JSON" ]] || failures+=("Screenshot manifest is missing: $MANIFEST_JSON")

if [[ -s "$MANIFEST_JSON" ]]; then
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ -s "$path" ]]; then
      verified+=("$path")
    else
      failures+=("Manifest screenshot is missing or empty: $path")
    fi
  done < <(/usr/bin/python3 - "$MANIFEST_JSON" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    manifest = json.load(handle)

for shot in manifest.get("screenshots", []):
    if shot.get("status") == "captured":
        print(shot.get("path", ""))

for shot in manifest.get("screenshots", []):
    if shot.get("status") != "captured" and shot.get("name") != "backend_streaming_status":
        print(shot.get("path", ""))
PY
  )

  omissions_count="$(/usr/bin/python3 - "$MANIFEST_JSON" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    manifest = json.load(handle)

print(len(manifest.get("omissions", [])))
PY
  )"
else
  omissions_count="0"
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#056.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "screenshotFolderExists": %s,\n' "$([[ -d "$SCREENSHOT_DIR" ]] && printf true || printf false)"
  printf -- '  "manifestExists": %s,\n' "$([[ -s "$MANIFEST_JSON" ]] && printf true || printf false)"
  printf -- '  "verifiedScreenshotCount": %d,\n' "${#verified[@]}"
  printf -- '  "routeOmissionsReported": %s,\n' "$([[ "$omissions_count" != "0" ]] && printf true || printf false)"
  printf -- '  "automatedVisualTruth": "non-empty screenshot proof only",\n'
  printf -- '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "${failures[$i]//\"/\\\"}"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Streaming Provider Staging Screenshot Verification\n\n'
  printf -- '- Upgrade: #056.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Screenshot folder: %s\n' "$SCREENSHOT_DIR"
  printf -- '- Manifest: %s\n' "$MANIFEST_JSON"
  printf -- '- Verified screenshot count: %d\n' "${#verified[@]}"
  printf -- '- Automated visual truth: non-empty screenshot proof only\n\n'
  printf -- '## Verified Screenshots\n\n'
  if (( ${#verified[@]} > 0 )); then
    for path in "${verified[@]}"; do
      printf -- '- %s\n' "$path"
    done
  else
    printf -- '- None.\n'
  fi
  printf -- '\n## Failures\n\n'
  if (( ${#failures[@]} > 0 )); then
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '- None.\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Streaming provider staging screenshot verification passed.\n'
