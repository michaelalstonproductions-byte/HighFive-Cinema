#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-52-0b-creator-instagram-social-vod-connect-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/creator_instagram_social_vod_connect_screenshot_manifest.json"
MANIFEST_MD="$SCREENSHOT_DIR/creator_instagram_social_vod_connect_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-52-0b-creator-instagram-social-vod-connect-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SCREENSHOT_DIR"
cd "$ROOT_DIR"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

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

if ! xcrun simctl list devices booted | rg -q 'iPhone'; then
  DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
  xcrun simctl boot "$DEVICE_ID" || true
  open -a Simulator || true
  xcrun simctl bootstatus booted -b
fi

xcrun simctl terminate booted "$APP_ID" || true
xcrun simctl uninstall booted "$APP_ID" || true
xcrun simctl install booted "$APP_PATH"

CAPTURES=(
  "intro_video.png|--hf-start-intro-video"
  "training_video.png|--hf-start-timeline-practice"
  "connect.png|--hf-skip-onboarding --hf-start-connect"
  "creator_studio.png|--hf-skip-onboarding --hf-start-creator-studio"
  "instagram_connect.png|--hf-skip-onboarding --hf-start-instagram-connect"
  "social_media_kit.png|--hf-skip-onboarding --hf-start-social-media-kit"
  "vod_package.png|--hf-skip-onboarding --hf-start-vod-package"
  "profile.png|--hf-skip-onboarding --hf-start-profile"
  "movie_detail.png|--hf-skip-onboarding --hf-start-movie-detail"
)

RESULTS=()
FAILURES=0

capture_screen() {
  local file="$1"
  local args_string="$2"
  local path="$SCREENSHOT_DIR/$file"
  read -r -a args <<< "$args_string"

  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl launch booted "$APP_ID" "${args[@]}" >/dev/null
  sleep 3
  xcrun simctl io booted screenshot "$path" >/dev/null

  if [[ -s "$path" ]]; then
    local bytes
    bytes="$(wc -c < "$path" | tr -d ' ')"
    RESULTS+=("$file|$path|$bytes|pass|$args_string")
  else
    RESULTS+=("$file|$path|0|fail|$args_string")
    FAILURES=$((FAILURES + 1))
  fi
}

for capture in "${CAPTURES[@]}"; do
  IFS='|' read -r file args_string <<< "$capture"
  capture_screen "$file" "$args_string"
done

{
  printf '{\n'
  printf '  "upgrade": "#052.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "appId": "%s",\n' "$(json_escape "$APP_ID")"
  printf '  "appPath": "%s",\n' "$(json_escape "$APP_PATH")"
  printf '  "screenshots": [\n'
  for i in "${!RESULTS[@]}"; do
    IFS='|' read -r file path bytes status args_string <<< "${RESULTS[$i]}"
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    {"file": "%s", "path": "%s", "bytes": %s, "status": "%s", "launchArgs": "%s"}' \
      "$(json_escape "$file")" \
      "$(json_escape "$path")" \
      "$bytes" \
      "$(json_escape "$status")" \
      "$(json_escape "$args_string")"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$MANIFEST_JSON"

{
  printf '# Creator Instagram Social VOD Connect Screenshot Manifest\n\n'
  printf 'Upgrade: #052.0B\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  printf '| File | Status | Bytes | Launch Args | Path |\n'
  printf '| --- | --- | ---: | --- | --- |\n'
  for entry in "${RESULTS[@]}"; do
    IFS='|' read -r file path bytes status args_string <<< "$entry"
    printf '| `%s` | `%s` | %s | `%s` | `%s` |\n' "$file" "$status" "$bytes" "$args_string" "$path"
  done
  printf '\nThis manifest proves screenshot files were captured and are non-empty. Manual visual review is still required.\n'
} > "$MANIFEST_MD"

printf 'Screenshot manifest: %s\nMarkdown: %s\n' "$MANIFEST_JSON" "$MANIFEST_MD"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
