#!/usr/bin/env bash
set -o pipefail

OUT_DIR="/private/tmp/highfive-ui-04b-social-campaign-spatial-authoring-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST="$OUT_DIR/social_campaign_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/social_campaign_screenshot_verification.json"
MD_OUT="$OUT_DIR/social_campaign_screenshot_verification.md"

failures=()
passes=()
required=(
  social_campaign_default.png
  social_campaign_poster.png
  social_campaign_reel.png
  social_campaign_caption.png
  social_campaign_story.png
  social_campaign_platforms.png
  creator_studio_social_entry.png
  profile_tabs.png
)

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }

if [ -d "$SHOT_DIR" ]; then pass "screenshot folder exists"; else fail "screenshot folder missing"; fi
if [ -f "$MANIFEST" ]; then pass "manifest exists"; else fail "manifest missing"; fi

if [ -f "$MANIFEST" ] && ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' "$MANIFEST" >/dev/null; then
  pass "manifest JSON parses"
else
  fail "manifest JSON does not parse"
fi

if [ -f "$MANIFEST" ] && rg -q '"status": "passed"' "$MANIFEST"; then pass "manifest status passed"; else fail "manifest status not passed"; fi
if [ -f "$MANIFEST" ] && rg -q '"build": "passed"' "$MANIFEST"; then pass "build passed"; else fail "build did not pass"; fi
if [ -f "$MANIFEST" ] && rg -q '"install": "passed"' "$MANIFEST"; then pass "install passed"; else fail "install did not pass"; fi
if [ -f "$MANIFEST" ] && rg -q '"coordinate_tapping": false' "$MANIFEST"; then pass "no coordinate tapping"; else fail "coordinate tapping not false"; fi
if [ -f "$MANIFEST" ] && rg -q '"fake_screenshots": false' "$MANIFEST"; then pass "no fabricated screenshots"; else fail "fake screenshots not false"; fi
if [ -f "$MANIFEST" ] && rg -q '"automated_visual_truth": "non-empty screenshot proof only"' "$MANIFEST"; then
  pass "no automated visual-quality claim beyond non-empty proof"
else
  fail "automated visual truth claim is missing or too broad"
fi
if [ -f "$MANIFEST" ] && rg -F -q '"omissions": [' "$MANIFEST"; then pass "route omissions are reported honestly"; else fail "omissions field missing"; fi

for file in "${required[@]}"; do
  if [ -s "$SHOT_DIR/$file" ]; then
    pass "$file exists and is non-empty"
  else
    fail "$file missing or empty"
  fi
done

status="passed"
[ "${#failures[@]}" -eq 0 ] || status="failed"

{
  printf -- '{\n'
  printf -- '  "upgrade": "UI-04B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [ "$i" = "$((${#passes[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${passes[$i]//\"/\\\"}" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [ "$i" = "$((${#failures[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${failures[$i]//\"/\\\"}" "$comma"
  done
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Social Campaign Screenshot Verification\n\n'
  printf -- '- Upgrade: UI-04B\n'
  printf -- '- Status: %s\n\n' "$status"
  printf -- '## Passed Evidence\n'
  for item in "${passes[@]}"; do printf -- '- %s\n' "$item"; done
  printf -- '\n## Failures\n'
  [ "${#failures[@]}" -eq 0 ] && printf -- '- None\n'
  for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
} > "$MD_OUT"

if [ "$status" != "passed" ]; then
  printf -- 'Screenshot verification failed. See %s\n' "$MD_OUT" >&2
  exit 1
fi

printf -- 'Screenshot verification passed. Evidence written to %s and %s\n' "$JSON_OUT" "$MD_OUT"
