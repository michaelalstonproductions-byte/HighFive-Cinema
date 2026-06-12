#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-36-0b-payment-entitlements-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_MANIFEST="$SHOT_DIR/payments_entitlements_architecture_screenshot_manifest.json"
MD_MANIFEST="$SHOT_DIR/payments_entitlements_architecture_screenshot_manifest.md"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
DERIVED="$OUT_DIR/DerivedData"
APP_PATH="$DERIVED/Build/Products/Debug-iphonesimulator/HighFive.app"
BUILD_LOG="$OUT_DIR/payments_entitlements_architecture_xcodebuild.log"
mkdir -p "$SHOT_DIR"

set +e
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build > "$BUILD_LOG" 2>&1
BUILD_STATUS=$?
set -e

if [[ "$BUILD_STATUS" -ne 0 ]]; then
  printf 'Build failed. Log: %s\n' "$BUILD_LOG" >&2
  rg -n "error:|fatal error:|BUILD FAILED|The following build commands failed|SwiftCompile|CompileSwift|Ld |CodeSign|HighFive/" "$BUILD_LOG" >&2 || true
  exit "$BUILD_STATUS"
fi

open -a Simulator >/dev/null 2>&1 || true

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"

captures=()

capture_route() {
  local name="$1"
  shift
  local path="$SHOT_DIR/$name"
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "$@"
  sleep 3
  xcrun simctl io booted screenshot "$path"
  if [[ ! -s "$path" ]]; then
    printf 'Screenshot missing or empty: %s\n' "$path" >&2
    exit 1
  fi
  captures+=("$name")
}

capture_route "profile_payment_entitlement_services.png" --hf-skip-onboarding --hf-start-profile
capture_route "movie_detail_entitlement_path.png" --hf-skip-onboarding --hf-start-movie-detail
capture_route "home_access_path_signal.png" --hf-skip-onboarding --hf-start-home
capture_route "library_entitlement_boundary.png" --hf-skip-onboarding --hf-start-library
capture_route "downloads_entitlement_boundary.png" --hf-skip-onboarding --hf-start-downloads
capture_route "export_payment_entitlement_boundary.png" --hf-skip-onboarding --hf-start-export-room
capture_route "launch_payment_entitlement_boundary.png" --hf-skip-onboarding --hf-start-launch-room
capture_route "demo_payment_entitlement_proof.png" --hf-skip-onboarding --hf-start-demo-tour

{
  printf '{\n'
  printf '  "upgrade": "#036.0B",\n'
  printf '  "baseline": "1534194 phase-36-0a-payments-entitlements-architecture-local-remote-adapter",\n'
  printf '  "status": "pass",\n'
  printf '  "build": "passed",\n'
  printf '  "install": "passed",\n'
  printf '  "launches": "passed",\n'
  printf '  "screenshots": [\n'
  for i in "${!captures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#captures[@]} - 1)) ]] && comma=""
    printf '    "%s/%s"%s\n' "$SHOT_DIR" "${captures[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_MANIFEST"

{
  printf '# Payments / Entitlements Architecture Screenshot Manifest\n\n'
  printf -- '- Upgrade: #036.0B\n'
  printf -- '- Baseline: 1534194 phase-36-0a-payments-entitlements-architecture-local-remote-adapter\n'
  printf -- '- Build: passed\n'
  printf -- '- Install: passed\n'
  printf -- '- Launches: passed\n'
  printf -- '- Screenshots require manual visual inspection.\n\n'
  for item in "${captures[@]}"; do
    printf -- '- %s/%s\n' "$SHOT_DIR" "$item"
  done
} > "$MD_MANIFEST"

printf 'Payments entitlements architecture screenshots captured.\n'
printf 'Manifest: %s\n' "$MD_MANIFEST"
