#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-63-0b-staging-entitlement-playback-adapter-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$OUT_DIR/staging_backend_entitlement_playback_adapter_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/staging_backend_entitlement_playback_adapter_screenshot_verification.json"
MD_OUT="$OUT_DIR/staging_backend_entitlement_playback_adapter_screenshot_verification.md"

cd "$ROOT_DIR"

status="passed"
failures=()
verified=()
fixture_summary="unknown"

declare -a REQUIRED_NAMES=(
  "movie_detail_adapter_local_fallback.png"
  "player_adapter_local_fallback.png"
  "backend_adapter_status.png"
  "profile_staging_playback_adapter.png"
)

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if [[ ! -d "$SCREENSHOT_DIR" ]]; then
  status="failed"
  failures+=("Screenshot folder missing: $SCREENSHOT_DIR")
fi

if [[ ! -s "$MANIFEST_JSON" ]]; then
  status="failed"
  failures+=("Screenshot manifest missing or empty: $MANIFEST_JSON")
else
  fixture_summary="$(sed -n 's/.*"fixtureSummary": "\([^"]*\)".*/\1/p' "$MANIFEST_JSON" | head -1)"
  while IFS= read -r line; do
    path="$(printf '%s\n' "$line" | sed -n 's/.*"path":"\([^"]*\)".*/\1/p')"
    name="$(printf '%s\n' "$line" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')"
    shot_status="$(printf '%s\n' "$line" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    required="$(printf '%s\n' "$line" | sed -n 's/.*"required":"\([^"]*\)".*/\1/p')"
    [[ -n "$name" ]] || continue
    if [[ "$shot_status" == "captured" && -s "$path" ]]; then
      verified+=("$name|$path|$required")
    else
      status="failed"
      failures+=("Manifest screenshot missing, empty, or not captured: $name")
    fi
  done < <(rg '"name":"' "$MANIFEST_JSON" || true)
fi

for required_name in "${REQUIRED_NAMES[@]}"; do
  found=0
  for item in "${verified[@]}"; do
    IFS='|' read -r name _path requirement <<< "$item"
    if [[ "$name" == "$required_name" && "$requirement" == "required" ]]; then
      found=1
      break
    fi
  done
  if [[ "$found" != "1" ]]; then
    status="failed"
    failures+=("Required screenshot not verified: $required_name")
  fi
done

{
  printf -- '{\n'
  printf -- '  "upgrade": "#063.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "verifiedScreenshots": %d,\n' "${#verified[@]}"
  printf -- '  "requiredScreenshots": %d,\n' "${#REQUIRED_NAMES[@]}"
  printf -- '  "fixtureSummary": "%s",\n' "$(json_escape "$fixture_summary")"
  printf -- '  "automatedVisualTruth": "not claimed; non-empty screenshot proof only",\n'
  printf -- '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "$(json_escape "${failures[$i]}")"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Staging Backend Entitlement Playback Adapter Screenshot Verification\n\n'
  printf -- '- Upgrade: #063.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Verified screenshots: %d\n' "${#verified[@]}"
  printf -- '- Required screenshots: %d\n' "${#REQUIRED_NAMES[@]}"
  printf -- '- Fixture summary: %s\n' "$fixture_summary"
  printf -- '- Automated visual truth: not claimed; non-empty screenshot proof only.\n\n'
  printf -- '## Verified Screenshots\n\n'
  if (( ${#verified[@]} > 0 )); then
    for item in "${verified[@]}"; do
      IFS='|' read -r name path requirement <<< "$item"
      printf -- '- %s: %s (%s)\n' "$name" "$path" "$requirement"
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

printf -- 'Staging backend entitlement playback adapter screenshot verification passed.\n'
