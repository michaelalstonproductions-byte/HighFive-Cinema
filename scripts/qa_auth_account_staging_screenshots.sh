#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-55-0b-auth-account-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/auth_account_staging_screenshot_manifest.json"
MD_OUT="$OUT_DIR/auth_account_staging_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-55-0b-auth-account-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SCREENSHOT_DIR"
cd "$ROOT_DIR"

STATUS="pass"
FAILURES=()
SCREENSHOTS=()

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

build_app() {
  TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
    -project HighFive.xcodeproj \
    -scheme HighFive \
    -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    SDK_STAT_CACHE_ENABLE=NO \
    COMPILER_INDEX_STORE_ENABLE=NO \
    build
}

ensure_booted_iphone() {
  if ! xcrun simctl list devices booted | rg 'iPhone' >/dev/null; then
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  fi
}

install_app() {
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl uninstall booted "$APP_ID" || true
  xcrun simctl install booted "$APP_PATH"
}

capture_route() {
  local name="$1"
  shift
  local path="$SCREENSHOT_DIR/$name"

  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "$@"
  sleep 3
  xcrun simctl io booted screenshot "$path"

  if [ -s "$path" ]; then
    SCREENSHOTS+=("$path")
  else
    record_fail "missing or empty screenshot: $path"
  fi
}

build_app
ensure_booted_iphone
install_app

capture_route "profile_account_local.png" --hf-skip-onboarding --hf-start-profile
capture_route "backend_status_auth_readiness.png" --hf-start-backend-status
capture_route "home_account_backend_boundary.png" --hf-skip-onboarding --hf-start-home
capture_route "creator_account_boundary.png" --hf-skip-onboarding --hf-start-creator-studio

if [ "${#SCREENSHOTS[@]}" -eq 0 ]; then
  SCREENSHOTS_JSON="[]"
else
  SCREENSHOTS_JSON="$(json_array "${SCREENSHOTS[@]}")"
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
  "build": "pass",
  "install": "pass",
  "launch": "pass",
  "screenshots": $SCREENSHOTS_JSON,
  "failures": $FAILURES_JSON,
  "visual_truth": "non-empty screenshots only; no automated visual truth claimed"
}
JSON

{
  echo "# Auth Account Staging Screenshot Manifest"
  echo
  echo "- Upgrade: #055.0B"
  echo "- Status: $STATUS"
  echo "- Build: pass"
  echo "- Install: pass"
  echo "- Launch: pass"
  echo "- Visual truth: non-empty screenshots only; no automated visual truth claimed"
  echo
  echo "## Screenshots"
  for item in "${SCREENSHOTS[@]}"; do
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

echo "screenshot harness: $STATUS"
echo "$JSON_OUT"
echo "$MD_OUT"

[ "$STATUS" = "pass" ]
