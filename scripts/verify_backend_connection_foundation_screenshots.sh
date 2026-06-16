#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-53-0b-backend-foundation-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST="$OUT_DIR/backend_connection_foundation_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/backend_connection_foundation_screenshot_verification.json"
MD_OUT="$OUT_DIR/backend_connection_foundation_screenshot_verification.md"

STATUS="pass"
FAILURES=()
PASSES=()

record_pass() {
  PASSES+=("$1")
}

record_fail() {
  STATUS="fail"
  FAILURES+=("$1")
}

json_array() {
  local first=1
  printf '['
  for item in "$@"; do
    if [[ "$first" -eq 0 ]]; then
      printf ','
    fi
    first=0
    printf '"%s"' "$(printf '%s' "$item" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  done
  printf ']'
}

if [[ -d "$SCREENSHOT_DIR" ]]; then
  record_pass "Screenshot folder exists"
else
  record_fail "Screenshot folder missing"
fi

if [[ -s "$MANIFEST" ]]; then
  record_pass "Screenshot manifest exists"
else
  record_fail "Screenshot manifest missing"
fi

for path in \
  "$SCREENSHOT_DIR/home_backend.png" \
  "$SCREENSHOT_DIR/profile_backend.png" \
  "$SCREENSHOT_DIR/creator_backend.png"; do
  if [[ -s "$path" ]]; then
    record_pass "$path exists and is non-empty"
  else
    record_fail "$path missing or empty"
  fi
done

if [[ -s "$MANIFEST" ]] && rg -q '"route": "backend_status"' "$MANIFEST"; then
  if rg -q '"status": "route_unavailable_source_verified"' "$MANIFEST"; then
    record_pass "backend_status route omission reported honestly"
  elif [[ -s "$SCREENSHOT_DIR/backend_status.png" ]] && rg -q '"route": "backend_status"' "$MANIFEST" && rg -q '"status": "captured"' "$MANIFEST"; then
    record_pass "backend_status screenshot captured and non-empty"
  else
    record_fail "backend_status manifest says captured but screenshot is missing or empty"
  fi
fi

PASSES_JSON="$(json_array "${PASSES[@]}")"
if [[ "${#FAILURES[@]}" -eq 0 ]]; then
  FAILURES_JSON="[]"
else
  FAILURES_JSON="$(json_array "${FAILURES[@]}")"
fi

cat > "$JSON_OUT" <<JSON
{
  "upgrade": "#053.0B",
  "status": "$STATUS",
  "manifest": "$MANIFEST",
  "screenshot_folder": "$SCREENSHOT_DIR",
  "passes": $PASSES_JSON,
  "failures": $FAILURES_JSON,
  "notes": [
    "No automated visual truth beyond non-empty screenshot proof."
  ]
}
JSON

{
  echo "# Backend Connection Foundation Screenshot Verification"
  echo
  echo "- Upgrade: #053.0B"
  echo "- Status: $STATUS"
  echo "- Manifest: $MANIFEST"
  echo "- Screenshot folder: $SCREENSHOT_DIR"
  echo
  echo "## Passes"
  for item in "${PASSES[@]}"; do
    echo "- $item"
  done
  echo
  echo "## Failures"
  if [[ "${#FAILURES[@]}" -eq 0 ]]; then
    echo "- None"
  else
    for item in "${FAILURES[@]}"; do
      echo "- $item"
    done
  fi
  echo
  echo "No automated visual truth beyond non-empty screenshot proof."
} > "$MD_OUT"

if [[ "$STATUS" != "pass" ]]; then
  cat "$MD_OUT"
  exit 1
fi

cat "$MD_OUT"
