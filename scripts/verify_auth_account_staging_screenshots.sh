#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-55-0b-auth-account-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST="$OUT_DIR/auth_account_staging_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/auth_account_staging_screenshot_verification.json"
MD_OUT="$OUT_DIR/auth_account_staging_screenshot_verification.md"

mkdir -p "$OUT_DIR"

STATUS="pass"
FAILURES=()
VERIFIED=()

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  printf '%s' "$s"
}

json_array() {
  if [ "$#" -eq 0 ]; then
    printf '[]'
    return
  fi
  local first=1
  printf '['
  for item in "$@"; do
    if [ "$first" -eq 0 ]; then
      printf ', '
    fi
    first=0
    printf '"%s"' "$(json_escape "$item")"
  done
  printf ']'
}

record_fail() {
  STATUS="fail"
  FAILURES+=("$1")
}

verify_file() {
  local path="$1"
  if [ -s "$path" ]; then
    VERIFIED+=("$path")
  else
    record_fail "missing or empty screenshot: $path"
  fi
}

if [ ! -d "$SCREENSHOT_DIR" ]; then
  record_fail "screenshot folder missing: $SCREENSHOT_DIR"
fi

if [ ! -s "$MANIFEST" ]; then
  record_fail "screenshot manifest missing: $MANIFEST"
fi

EXPECTED=(
  "$SCREENSHOT_DIR/profile_account_local.png"
  "$SCREENSHOT_DIR/backend_status_auth_readiness.png"
  "$SCREENSHOT_DIR/home_account_backend_boundary.png"
  "$SCREENSHOT_DIR/creator_account_boundary.png"
)

for path in "${EXPECTED[@]}"; do
  verify_file "$path"
  if [ -s "$MANIFEST" ] && ! rg -q --fixed-strings -- "$path" "$MANIFEST"; then
    record_fail "manifest does not include screenshot: $path"
  fi
done

if [ -s "$MANIFEST" ] && ! rg -q --fixed-strings -- "non-empty screenshots only; no automated visual truth claimed" "$MANIFEST"; then
  record_fail "manifest is missing visual truth limitation"
fi

if [ "${#VERIFIED[@]}" -eq 0 ]; then
  VERIFIED_JSON="[]"
else
  VERIFIED_JSON="$(json_array "${VERIFIED[@]}")"
fi

if [ "${#FAILURES[@]}" -eq 0 ]; then
  FAILURES_JSON="[]"
else
  FAILURES_JSON="$(json_array "${FAILURES[@]}")"
fi

cat > "$JSON_OUT" <<JSON
{
  "upgrade": "#055.0B",
  "status": "$STATUS",
  "manifest": "$(json_escape "$MANIFEST")",
  "verified_screenshots": $VERIFIED_JSON,
  "failures": $FAILURES_JSON,
  "visual_truth": "non-empty screenshots only; no automated visual truth claimed"
}
JSON

{
  echo "# Auth Account Staging Screenshot Verification"
  echo
  echo "- Upgrade: #055.0B"
  echo "- Status: $STATUS"
  echo "- Manifest: $MANIFEST"
  echo "- Visual truth: non-empty screenshots only; no automated visual truth claimed"
  echo
  echo "## Verified Screenshots"
  for item in "${VERIFIED[@]}"; do
    echo "- $item"
  done
  echo
  echo "## Failures"
  if [ "${#FAILURES[@]}" -eq 0 ]; then
    echo "- None"
  else
    for item in "${FAILURES[@]}"; do
      echo "- $item"
    done
  fi
} > "$MD_OUT"

echo "screenshot verification: $STATUS"
echo "$JSON_OUT"
echo "$MD_OUT"

[ "$STATUS" = "pass" ]
