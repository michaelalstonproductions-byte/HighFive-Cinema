#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-58-0b-cloud-library-sync-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$OUT_DIR/cloud_library_sync_staging_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/cloud_library_sync_staging_screenshot_verification.json"
MD_OUT="$OUT_DIR/cloud_library_sync_staging_screenshot_verification.md"

mkdir -p "$OUT_DIR"

failures=()
verified=()

[[ -d "$SCREENSHOT_DIR" ]] || failures+=("Screenshot folder is missing: $SCREENSHOT_DIR")
[[ -s "$MANIFEST_JSON" ]] || failures+=("Screenshot manifest is missing: $MANIFEST_JSON")

if [[ -s "$MANIFEST_JSON" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    IFS='|' read -r name path state <<< "$line"
    if [[ "$state" == "captured" ]]; then
      if [[ -s "$path" ]]; then
        verified+=("$path")
      else
        failures+=("Manifest screenshot is missing or empty: $path")
      fi
    elif [[ "$name" != "backend_library_sync_status" ]]; then
      failures+=("Required screenshot route was not captured: $name")
    fi
  done < <(sed -n 's/.*"name": "\([^"]*\)", "path": "\([^"]*\)", "status": "\([^"]*\)".*/\1|\2|\3/p' "$MANIFEST_JSON")

  if rg -q '"omissions": \[\]' "$MANIFEST_JSON"; then
    omissions_count="0"
  else
    omissions_count="1"
  fi
else
  omissions_count="0"
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#058.0B",\n'
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
  printf -- '# Cloud Library Sync Staging Screenshot Verification\n\n'
  printf -- '- Upgrade: #058.0B\n'
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

printf -- 'Cloud library sync staging screenshot verification passed.\n'
