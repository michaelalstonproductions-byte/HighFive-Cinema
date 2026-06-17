#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-59-0b-real-downloads-policy-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/real_downloads_policy_staging_screenshot_manifest.json"
MD_OUT="$OUT_DIR/real_downloads_policy_staging_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-59-0b-real-downloads-policy-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SCREENSHOT_DIR"
cd "$ROOT_DIR"

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

xcrun simctl list devices booted | rg 'iPhone' || {
  DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
  xcrun simctl boot "$DEVICE_ID" || true
  open -a Simulator || true
  xcrun simctl bootstatus booted -b
}

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"

captures=()
omissions=()

capture_route() {
  local name="$1"
  local path="$2"
  shift 2

  xcrun simctl terminate booted "$APP_ID" || true
  if xcrun simctl launch booted "$APP_ID" "$@"; then
    sleep 3
    if xcrun simctl io booted screenshot "$path" && [[ -s "$path" ]]; then
      captures+=("$name|$path|captured")
    else
      captures+=("$name|$path|failed")
      return 1
    fi
  else
    captures+=("$name|$path|route unavailable")
    omissions+=("$name route unavailable")
    return 1
  fi
}

capture_route "downloads_policy" "$SCREENSHOT_DIR/downloads_policy.png" --hf-skip-onboarding --hf-start-downloads
capture_route "movie_detail_download_boundary" "$SCREENSHOT_DIR/movie_detail_download_boundary.png" --hf-skip-onboarding --hf-start-movie-detail
capture_route "profile_download_readiness" "$SCREENSHOT_DIR/profile_download_readiness.png" --hf-skip-onboarding --hf-start-profile
capture_route "backend_download_status" "$SCREENSHOT_DIR/backend_download_status.png" --hf-start-backend-status || true

required_failures=()
for entry in "${captures[@]}"; do
  IFS='|' read -r name path state <<< "$entry"
  if [[ "$name" != "backend_download_status" && "$state" != "captured" ]]; then
    required_failures+=("$name was not captured")
  fi
done

status="passed"
if (( ${#required_failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#059.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "build": "passed",\n'
  printf -- '  "install": "passed",\n'
  printf -- '  "screenshots": [\n'
  for i in "${!captures[@]}"; do
    IFS='|' read -r name path state <<< "${captures[$i]}"
    [[ "$i" == "0" ]] || printf -- ',\n'
    printf -- '    {"name": "%s", "path": "%s", "status": "%s", "nonEmpty": %s}' "$name" "$path" "$state" "$([[ "$state" == "captured" ]] && printf true || printf false)"
  done
  printf -- '\n  ],\n'
  printf -- '  "omissions": ['
  for i in "${!omissions[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "${omissions[$i]//\"/\\\"}"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Real Downloads Policy Staging Screenshot Manifest\n\n'
  printf -- '- Upgrade: #059.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: passed\n'
  printf -- '- Install: passed\n\n'
  printf -- '## Screenshots\n\n'
  for entry in "${captures[@]}"; do
    IFS='|' read -r name path state <<< "$entry"
    printf -- '- %s: %s (%s)\n' "$name" "$path" "$state"
  done
  printf -- '\n## Route Omissions\n\n'
  if (( ${#omissions[@]} > 0 )); then
    for omission in "${omissions[@]}"; do
      printf -- '- %s\n' "$omission"
    done
  else
    printf -- '- None.\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Real downloads policy staging screenshot harness passed.\n'
