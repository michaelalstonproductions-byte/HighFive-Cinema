#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-ui-03b-connect-constellation-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/connect_constellation_screenshot_manifest.json"
MD_OUT="$OUT_DIR/connect_constellation_screenshot_manifest.md"
DERIVED_DATA="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-03b-connect-constellation-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"

declare -a FAILURES=()
build_status="failed"
install_status="failed"
status="failed"

record_failure() {
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
  xcrun simctl list devices booted | rg 'iPhone' >/dev/null || {
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  }
}

capture_route() {
  local route="$1"
  local path="$2"
  xcrun simctl terminate booted "$APP_ID" || true
  if ! xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$route" >/dev/null; then
    record_failure "launch failed for $route"
    return 1
  fi
  sleep 4
  if ! xcrun simctl io booted screenshot "$path" >/dev/null; then
    record_failure "screenshot failed for $route"
    return 1
  fi
  if [[ ! -s "$path" ]]; then
    record_failure "screenshot was empty for $route"
    return 1
  fi
}

if build_app; then
  build_status="passed"
else
  record_failure "build failed"
fi

if [[ "$build_status" == "passed" ]]; then
  ensure_booted_iphone
  xcrun simctl terminate booted "$APP_ID" || true
  xcrun simctl uninstall booted "$APP_ID" || true
  if xcrun simctl install booted "$APP_PATH"; then
    install_status="passed"
  else
    record_failure "install failed"
  fi
fi

if [[ "$install_status" == "passed" ]]; then
  capture_route "--hf-start-connect" "$SHOT_DIR/connect_constellation.png"
  capture_route "--hf-start-connect-room" "$SHOT_DIR/local_watch_room.png"
  capture_route "--hf-start-premiere-lobby" "$SHOT_DIR/premiere_lobby.png"
  capture_route "--hf-start-profile" "$SHOT_DIR/profile_connect_entry.png"
  capture_route "--hf-start-movie-detail" "$SHOT_DIR/movie_detail_watch_together.png"
fi

if [[ "$build_status" == "passed" && "$install_status" == "passed" && ${#FAILURES[@]} -eq 0 ]]; then
  status="passed"
fi

byte_count() {
  local path="$1"
  if [[ -f "$path" ]]; then
    stat -f%z "$path"
  else
    printf '0'
  fi
}

{
  printf '{\n'
  printf '  "upgrade": "UI-03B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "build": "%s",\n' "$build_status"
  printf '  "install": "%s",\n' "$install_status"
  printf '  "routes": [\n'
  printf '    "--hf-start-connect",\n'
  printf '    "--hf-start-connect-room",\n'
  printf '    "--hf-start-premiere-lobby",\n'
  printf '    "--hf-start-profile",\n'
  printf '    "--hf-start-movie-detail"\n'
  printf '  ],\n'
  printf '  "screenshot_paths": {\n'
  printf '    "connect_constellation": "%s/connect_constellation.png",\n' "$SHOT_DIR"
  printf '    "local_watch_room": "%s/local_watch_room.png",\n' "$SHOT_DIR"
  printf '    "premiere_lobby": "%s/premiere_lobby.png",\n' "$SHOT_DIR"
  printf '    "profile_connect_entry": "%s/profile_connect_entry.png",\n' "$SHOT_DIR"
  printf '    "movie_detail_watch_together": "%s/movie_detail_watch_together.png"\n' "$SHOT_DIR"
  printf '  },\n'
  printf '  "screenshot_byte_counts": {\n'
  printf '    "connect_constellation": %s,\n' "$(byte_count "$SHOT_DIR/connect_constellation.png")"
  printf '    "local_watch_room": %s,\n' "$(byte_count "$SHOT_DIR/local_watch_room.png")"
  printf '    "premiere_lobby": %s,\n' "$(byte_count "$SHOT_DIR/premiere_lobby.png")"
  printf '    "profile_connect_entry": %s,\n' "$(byte_count "$SHOT_DIR/profile_connect_entry.png")"
  printf '    "movie_detail_watch_together": %s\n' "$(byte_count "$SHOT_DIR/movie_detail_watch_together.png")"
  printf '  },\n'
  printf '  "coordinate_tapping": false,\n'
  printf '  "fake_screenshots": false,\n'
  printf '  "automated_visual_truth": "non-empty screenshot proof only",\n'
  printf '  "omissions": [],\n'
  printf '  "failures": ['
  if (( ${#FAILURES[@]} > 0 )); then
    printf '"see markdown report"'
  fi
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Connect Constellation Screenshot Manifest\n\n'
  printf -- '- Upgrade: UI-03B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Build: %s\n' "$build_status"
  printf -- '- Install: %s\n' "$install_status"
  printf -- '- Coordinate tapping: false\n'
  printf -- '- Fake screenshots: false\n'
  printf -- '- Automated visual truth: non-empty screenshot proof only\n\n'
  printf '## Screenshots\n'
  printf -- '- Connect Hub: %s (%s bytes)\n' "$SHOT_DIR/connect_constellation.png" "$(byte_count "$SHOT_DIR/connect_constellation.png")"
  printf -- '- Local Watch Room: %s (%s bytes)\n' "$SHOT_DIR/local_watch_room.png" "$(byte_count "$SHOT_DIR/local_watch_room.png")"
  printf -- '- Premiere Lobby: %s (%s bytes)\n' "$SHOT_DIR/premiere_lobby.png" "$(byte_count "$SHOT_DIR/premiere_lobby.png")"
  printf -- '- Profile contextual entry: %s (%s bytes)\n' "$SHOT_DIR/profile_connect_entry.png" "$(byte_count "$SHOT_DIR/profile_connect_entry.png")"
  printf -- '- Movie Detail Watch Together: %s (%s bytes)\n' "$SHOT_DIR/movie_detail_watch_together.png" "$(byte_count "$SHOT_DIR/movie_detail_watch_together.png")"
  if (( ${#FAILURES[@]} > 0 )); then
    printf '\n## Failures\n'
    for item in "${FAILURES[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  exit 1
fi
