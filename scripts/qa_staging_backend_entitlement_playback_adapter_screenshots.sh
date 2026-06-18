#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-63-0b-staging-entitlement-playback-adapter-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/staging_backend_entitlement_playback_adapter_screenshot_manifest.json"
MD_OUT="$OUT_DIR/staging_backend_entitlement_playback_adapter_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-63-0b-staging-entitlement-playback-adapter-evidence"
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
  "movie_detail_adapter_local_fallback.png|--hf-skip-onboarding --hf-start-movie-detail|required"
  "player_adapter_local_fallback.png|--hf-skip-onboarding --hf-start-player|required"
  "backend_adapter_status.png|--hf-start-backend-status|required"
  "profile_staging_playback_adapter.png|--hf-skip-onboarding --hf-start-profile|required"
)

status="passed"
manifest_entries=()
failures=()

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

capture_shot() {
  local filename="$1"
  local args="$2"
  local requirement="$3"
  local path="$SCREENSHOT_DIR/$filename"

  xcrun simctl terminate booted "$APP_ID" || true
  if xcrun simctl launch booted "$APP_ID" $args >/tmp/highfive-63-0b-launch.log 2>&1; then
    sleep 3
    if xcrun simctl io booted screenshot "$path" >/tmp/highfive-63-0b-screenshot.log 2>&1 && [[ -s "$path" ]]; then
      manifest_entries+=("{\"name\":\"$(json_escape "$filename")\",\"path\":\"$(json_escape "$path")\",\"route\":\"$(json_escape "$args")\",\"status\":\"captured\",\"required\":\"$requirement\"}")
    else
      status="failed"
      failures+=("$filename capture failed or empty")
      manifest_entries+=("{\"name\":\"$(json_escape "$filename")\",\"path\":\"$(json_escape "$path")\",\"route\":\"$(json_escape "$args")\",\"status\":\"failed\",\"required\":\"$requirement\"}")
    fi
  else
    status="failed"
    failures+=("$filename route launch failed")
    manifest_entries+=("{\"name\":\"$(json_escape "$filename")\",\"path\":\"$(json_escape "$path")\",\"route\":\"$(json_escape "$args")\",\"status\":\"failed\",\"required\":\"$requirement\"}")
  fi
}

for shot in "${SHOTS[@]}"; do
  IFS='|' read -r filename route_args requirement <<< "$shot"
  capture_shot "$filename" "$route_args" "$requirement"
done

fixture_note="QA fixture transport not added in #063.0A"
if rg -q -- '--hf-backend-fixture-entitlement-approved|--hf-backend-fixture-entitlement-denied|--hf-backend-fixture-descriptor-unavailable' HighFive docs/production_services; then
  fixture_note="QA fixture launch arguments found; fixture screenshots should be captured by a future evidence script"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#063.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "build": "passed",\n'
  printf -- '  "install": "passed",\n'
  printf -- '  "coordinateTapping": false,\n'
  printf -- '  "fakeScreenshots": false,\n'
  printf -- '  "fixtureSummary": "%s",\n' "$(json_escape "$fixture_note")"
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
    printf -- '"%s"' "$(json_escape "${failures[$i]}")"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Staging Backend Entitlement Playback Adapter Screenshot Manifest\n\n'
  printf -- '- Upgrade: #063.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: passed\n'
  printf -- '- Install: passed\n'
  printf -- '- Coordinate tapping: false\n'
  printf -- '- Fake screenshots: false\n'
  printf -- '- Fixture summary: %s\n\n' "$fixture_note"
  printf -- '## Screenshots\n\n'
  for entry in "${manifest_entries[@]}"; do
    name="$(printf '%s\n' "$entry" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')"
    path="$(printf '%s\n' "$entry" | sed -n 's/.*"path":"\([^"]*\)".*/\1/p')"
    entry_status="$(printf '%s\n' "$entry" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    required="$(printf '%s\n' "$entry" | sed -n 's/.*"required":"\([^"]*\)".*/\1/p')"
    printf -- '- %s: %s, %s (%s)\n' "$name" "$entry_status" "$required" "$path"
  done
  printf -- '\n## Notes\n\n'
  printf -- '- No coordinate tapping was used.\n'
  printf -- '- No screenshots were faked.\n'
  printf -- '- Optional fixture omissions are reported honestly.\n'
  printf -- '- Non-empty screenshots are proof of capture only.\n'
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Staging backend entitlement playback adapter screenshot harness passed.\n'
