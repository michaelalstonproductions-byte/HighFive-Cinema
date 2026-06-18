#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-62-0b-backend-entitlement-playback-contract-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$OUT_DIR/backend_entitlement_playback_contract_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/backend_entitlement_playback_contract_screenshot_verification.json"
MD_OUT="$OUT_DIR/backend_entitlement_playback_contract_screenshot_verification.md"

cd "$ROOT_DIR"

status="passed"
failures=()
verified=()
omitted=()
required_seen=()

declare -a REQUIRED_NAMES=(
  "movie_detail_backend_contract.png"
  "player_backend_contract.png"
  "profile_backend_contract.png"
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
  while IFS= read -r line; do
    path="$(printf '%s\n' "$line" | sed -n 's/.*"path":"\([^"]*\)".*/\1/p')"
    name="$(printf '%s\n' "$line" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')"
    shot_status="$(printf '%s\n' "$line" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    required="$(printf '%s\n' "$line" | sed -n 's/.*"required":"\([^"]*\)".*/\1/p')"
    [[ -n "$name" ]] || continue
    if [[ "$required" == "required" ]]; then
      required_seen+=("$name")
    fi
    if [[ "$shot_status" == "captured" ]]; then
      if [[ -s "$path" ]]; then
        verified+=("$name|$path|$required")
      else
        status="failed"
        failures+=("Manifest screenshot missing or empty: $name at $path")
      fi
    elif [[ "$required" == "optional" && "$shot_status" == "omitted" ]]; then
      omitted+=("$name")
    else
      status="failed"
      failures+=("Manifest reports non-captured required screenshot: $name")
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
  printf -- '  "upgrade": "#062.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "verifiedScreenshots": %d,\n' "${#verified[@]}"
  printf -- '  "requiredScreenshots": %d,\n' "${#REQUIRED_NAMES[@]}"
  printf -- '  "omittedRoutes": %d,\n' "${#omitted[@]}"
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
  printf -- '# Backend Entitlement Playback Contract Screenshot Verification\n\n'
  printf -- '- Upgrade: #062.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Verified screenshots: %d\n' "${#verified[@]}"
  printf -- '- Required screenshots: %d\n' "${#REQUIRED_NAMES[@]}"
  printf -- '- Omitted optional routes: %d\n' "${#omitted[@]}"
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
  printf -- '\n## Omitted Optional Routes\n\n'
  if (( ${#omitted[@]} > 0 )); then
    for name in "${omitted[@]}"; do
      printf -- '- %s\n' "$name"
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

printf -- 'Backend entitlement playback contract screenshot verification passed.\n'
