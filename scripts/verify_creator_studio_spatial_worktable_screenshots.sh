#!/usr/bin/env bash
set -euo pipefail

EVIDENCE_DIR="/private/tmp/highfive-ui-02b-creator-studio-spatial-worktable-evidence"
SHOT_DIR="$EVIDENCE_DIR/screenshots"
MANIFEST="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_manifest.json"
JSON_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_verification.json"
MD_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_verification.md"

mkdir -p "$EVIDENCE_DIR"

failures=()
passes=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }

if [[ -d "$SHOT_DIR" ]]; then pass "screenshot folder exists"; else fail "screenshot folder missing"; fi
if [[ -f "$MANIFEST" ]]; then pass "manifest exists"; else fail "manifest missing"; fi

if [[ -f "$MANIFEST" ]] && ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' "$MANIFEST" >/dev/null 2>&1; then
  pass "manifest JSON parses"
else
  fail "manifest JSON does not parse"
fi

manifest_value() {
  local key="$1"
  if [[ -f "$MANIFEST" ]]; then
    ruby -rjson -e 'value = JSON.parse(File.read(ARGV[0])).dig(*ARGV[1].split(".")); puts value unless value.nil?' "$MANIFEST" "$key" 2>/dev/null || true
  fi
}

[[ "$(manifest_value status)" == "passed" ]] && pass "manifest status passed" || fail "manifest status is not passed"
[[ "$(manifest_value build)" == "passed" ]] && pass "build passed" || fail "build did not pass"
[[ "$(manifest_value install)" == "passed" ]] && pass "install passed" || fail "install did not pass"
[[ "$(manifest_value coordinate_tapping)" == "false" ]] && pass "no coordinate tapping" || fail "coordinate tapping was not false"
[[ "$(manifest_value fake_screenshots)" == "false" ]] && pass "no fabricated screenshots" || fail "fake screenshots was not false"
[[ "$(manifest_value automated_visual_truth)" == "non-empty screenshot proof only" ]] && pass "no visual-quality claim beyond non-empty proof" || fail "automated visual truth claim is too broad"

required=(
  "$SHOT_DIR/creator_studio_worktable.png"
  "$SHOT_DIR/social_media_kit_handoff.png"
  "$SHOT_DIR/vod_package_handoff.png"
  "$SHOT_DIR/profile_creator_entry.png"
)

for file in "${required[@]}"; do
  if [[ -s "$file" ]]; then
    pass "non-empty screenshot: $file"
  else
    fail "missing or empty screenshot: $file"
  fi
done

omission_count="$(grep -c 'omitted because' "$MANIFEST" 2>/dev/null || true)"
if [[ "$omission_count" == "0" ]]; then
  pass "route omissions reported honestly: none"
else
  pass "route omissions reported honestly: $omission_count"
fi

status="passed"
if (( ${#failures[@]} > 0 )); then status="failed"; fi

{
  printf '{\n'
  printf '  "upgrade": "UI-02B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "manifest": "%s",\n' "$MANIFEST"
  printf '  "screenshot_folder": "%s",\n' "$SHOT_DIR"
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    escaped="${passes[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ $i -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    escaped="${failures[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ $i -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Creator Studio Spatial Worktable Screenshot Verification\n\n'
  printf -- '- Upgrade: UI-02B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Manifest: `%s`\n' "$MANIFEST"
  printf -- '- Screenshot folder: `%s`\n\n' "$SHOT_DIR"
  printf '## Passes\n'
  for item in "${passes[@]}"; do printf -- '- %s\n' "$item"; done
  printf '\n## Failures\n'
  if (( ${#failures[@]} == 0 )); then printf -- '- None\n'; else for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done; fi
} > "$MD_OUT"

echo "screenshot_verification=$status"
echo "json=$JSON_OUT"
echo "markdown=$MD_OUT"

[[ "$status" == "passed" ]]
