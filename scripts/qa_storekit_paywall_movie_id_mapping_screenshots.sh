#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-60-0b-storekit-paywall-mapping-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/storekit_paywall_movie_id_mapping_screenshot_manifest.json"
MD_OUT="$OUT_DIR/storekit_paywall_movie_id_mapping_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-60-0b-storekit-paywall-mapping-evidence"
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

if ! xcrun simctl list devices booted | rg 'iPhone' >/dev/null; then
  DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
  xcrun simctl boot "$DEVICE_ID" || true
  open -a Simulator || true
  xcrun simctl bootstatus booted -b
fi

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"

declare -a SHOTS=(
  "movie_detail_storekit_mapping.png|--hf-skip-onboarding --hf-start-movie-detail|required"
  "player_entitlement_gate.png|--hf-skip-onboarding --hf-start-player|required"
  "profile_storekit_readiness.png|--hf-skip-onboarding --hf-start-profile|required"
  "backend_entitlement_mapping.png|--hf-start-backend-status|optional"
)

status="passed"
manifest_entries=()
failures=()

capture_shot() {
  local filename="$1"
  local args="$2"
  local requirement="$3"
  local path="$SCREENSHOT_DIR/$filename"

  xcrun simctl terminate booted "$APP_ID" || true
  if xcrun simctl launch booted "$APP_ID" $args >/tmp/highfive-60-0b-launch.log 2>&1; then
    sleep 3
    if xcrun simctl io booted screenshot "$path" >/tmp/highfive-60-0b-screenshot.log 2>&1 && [[ -s "$path" ]]; then
      manifest_entries+=("{\"name\":\"$filename\",\"path\":\"$path\",\"route\":\"$args\",\"status\":\"captured\",\"required\":\"$requirement\"}")
    else
      if [[ "$requirement" == "optional" ]]; then
        manifest_entries+=("{\"name\":\"$filename\",\"path\":\"$path\",\"route\":\"$args\",\"status\":\"omitted\",\"required\":\"$requirement\",\"reason\":\"screenshot capture failed\"}")
      else
        status="failed"
        failures+=("$filename capture failed or empty")
        manifest_entries+=("{\"name\":\"$filename\",\"path\":\"$path\",\"route\":\"$args\",\"status\":\"failed\",\"required\":\"$requirement\"}")
      fi
    fi
  else
    if [[ "$requirement" == "optional" ]]; then
      manifest_entries+=("{\"name\":\"$filename\",\"path\":\"$path\",\"route\":\"$args\",\"status\":\"omitted\",\"required\":\"$requirement\",\"reason\":\"route launch failed\"}")
    else
      status="failed"
      failures+=("$filename route launch failed")
      manifest_entries+=("{\"name\":\"$filename\",\"path\":\"$path\",\"route\":\"$args\",\"status\":\"failed\",\"required\":\"$requirement\"}")
    fi
  fi
}

for shot in "${SHOTS[@]}"; do
  IFS='|' read -r filename route_args requirement <<< "$shot"
  capture_shot "$filename" "$route_args" "$requirement"
done

{
  printf -- '{\n'
  printf -- '  "upgrade": "#060.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "build": "passed",\n'
  printf -- '  "install": "passed",\n'
  printf -- '  "screenshots": [\n'
  for i in "${!manifest_entries[@]}"; do
    printf -- '    %s' "${manifest_entries[$i]}"
    if [[ "$i" != "$((${#manifest_entries[@]} - 1))" ]]; then
      printf -- ','
    fi
    printf -- '\n'
  done
  printf -- '  ],\n'
  printf -- '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "${failures[$i]//\"/\\\"}"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# StoreKit Paywall Movie-ID Mapping Screenshot Manifest\n\n'
  printf -- '- Upgrade: #060.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: passed\n'
  printf -- '- Install: passed\n\n'
  printf -- '## Screenshots\n\n'
  for entry in "${manifest_entries[@]}"; do
    name="$(printf '%s\n' "$entry" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')"
    path="$(printf '%s\n' "$entry" | sed -n 's/.*"path":"\([^"]*\)".*/\1/p')"
    entry_status="$(printf '%s\n' "$entry" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    printf -- '- %s: %s (%s)\n' "$name" "$entry_status" "$path"
  done
  printf -- '\n## Notes\n\n'
  printf -- '- No coordinate tapping was used.\n'
  printf -- '- No screenshots were faked.\n'
  printf -- '- Optional backend route omissions are reported honestly if they occur.\n'
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'StoreKit paywall movie-ID mapping screenshot harness passed.\n'
