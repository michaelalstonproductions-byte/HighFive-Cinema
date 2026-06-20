#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-ui-05b-vod-release-launch-chamber-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST="$OUT_DIR/vod_release_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/vod_release_screenshot_verification.json"
MD_OUT="$OUT_DIR/vod_release_screenshot_verification.md"

mkdir -p "$OUT_DIR"

failures=()
checks=()

pass() { checks+=("$1"); }
fail() { failures+=("$1"); }

required=(
  "vod_launch_default.png"
  "vod_launch_trailer.png"
  "vod_launch_poster.png"
  "vod_launch_synopsis.png"
  "vod_launch_access.png"
  "vod_launch_release.png"
  "creator_studio_vod_entry.png"
  "social_campaign_regression.png"
  "profile_tabs.png"
)

if [[ -d "$SHOT_DIR" ]]; then pass "screenshot folder exists"; else fail "screenshot folder missing"; fi
if [[ -f "$MANIFEST" ]]; then pass "manifest exists"; else fail "manifest missing"; fi

if [[ -f "$MANIFEST" ]] && ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' "$MANIFEST"; then
  pass "manifest JSON parses"
else
  fail "manifest JSON does not parse"
fi

json_value() {
  ruby -rjson -e 'data = JSON.parse(File.read(ARGV[0])); value = data.dig(*ARGV[1].split(".")); puts value.nil? ? "" : value' "$MANIFEST" "$1"
}

if [[ -f "$MANIFEST" ]]; then
  [[ "$(json_value status)" == "passed" ]] && pass "manifest status passed" || fail "manifest status is not passed"
  [[ "$(json_value build)" == "passed" ]] && pass "build passed" || fail "build did not pass"
  [[ "$(json_value install)" == "passed" ]] && pass "install passed" || fail "install did not pass"
  [[ "$(json_value coordinate_tapping)" == "false" ]] && pass "no coordinate tapping" || fail "coordinate tapping was not false"
  [[ "$(json_value fake_screenshots)" == "false" ]] && pass "no fabricated screenshots" || fail "fake screenshots was not false"
  [[ "$(json_value automated_visual_truth)" == "non-empty screenshot proof only" ]] && pass "automated visual truth is limited" || fail "automated visual truth claim is too broad"
fi

for file in "${required[@]}"; do
  path="$SHOT_DIR/$file"
  if [[ -s "$path" ]]; then
    pass "$file exists and is non-empty"
  else
    fail "$file missing or empty"
  fi
done

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf '{\n'
  printf '  "upgrade": "UI-05B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "manifest": "%s",\n' "$MANIFEST"
  printf '  "screenshot_folder": "%s",\n' "$SHOT_DIR"
  printf '  "checks_passed": %s,\n' "${#checks[@]}"
  printf '  "required_screenshot_count": 9,\n'
  printf '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" != "0" ]] && printf ', '
    printf '"%s"' "$(printf '%s' "${failures[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  done
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# VOD Release Launch Chamber Screenshot Verification\n\n'
  printf -- '- Upgrade: UI-05B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Manifest: `%s`\n' "$MANIFEST"
  printf -- '- Screenshot folder: `%s`\n' "$SHOT_DIR"
  printf -- '- Checks passed: %s\n\n' "${#checks[@]}"
  printf '## Required Screenshots\n'
  for file in "${required[@]}"; do
    path="$SHOT_DIR/$file"
    bytes=0
    [[ -f "$path" ]] && bytes="$(stat -f '%z' "$path")"
    printf -- '- `%s` (%s bytes)\n' "$path" "$bytes"
  done
  printf '\n## Verification\n'
  printf -- '- Manifest parses and reports passed status.\n'
  printf -- '- Build and install report passed.\n'
  printf -- '- Coordinate tapping is false.\n'
  printf -- '- Fabricated screenshots is false.\n'
  printf -- '- Automated visual claim is limited to non-empty proof.\n\n'
  printf '## Failures\n'
  if (( ${#failures[@]} > 0 )); then
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '- None\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf 'Screenshot verification passed: %s\n' "$JSON_OUT"
