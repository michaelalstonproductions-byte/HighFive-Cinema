#!/usr/bin/env bash
set -u -o pipefail

OUT_DIR="/private/tmp/highfive-ui-03b-connect-constellation-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST="$OUT_DIR/connect_constellation_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/connect_constellation_screenshot_verification.json"
MD_OUT="$OUT_DIR/connect_constellation_screenshot_verification.md"

mkdir -p "$OUT_DIR"

declare -a PASSES=()
declare -a FAILURES=()

pass() {
  PASSES+=("$1")
}

fail() {
  FAILURES+=("$1")
}

if [[ -d "$SHOT_DIR" ]]; then
  pass "screenshot folder exists"
else
  fail "screenshot folder exists"
fi

if [[ -f "$MANIFEST" ]]; then
  pass "manifest exists"
else
  fail "manifest exists"
fi

if [[ -f "$MANIFEST" ]] && jq -e . "$MANIFEST" >/dev/null; then
  pass "manifest JSON parses"
else
  fail "manifest JSON parses"
fi

if [[ -f "$MANIFEST" ]] && rg -q '"status": "passed"' "$MANIFEST"; then
  pass "manifest status passed"
else
  fail "manifest status passed"
fi

if [[ -f "$MANIFEST" ]] && rg -q '"build": "passed"' "$MANIFEST"; then
  pass "build passed"
else
  fail "build passed"
fi

if [[ -f "$MANIFEST" ]] && rg -q '"install": "passed"' "$MANIFEST"; then
  pass "install passed"
else
  fail "install passed"
fi

if [[ -f "$MANIFEST" ]] && rg -q '"coordinate_tapping": false' "$MANIFEST"; then
  pass "no coordinate tapping"
else
  fail "no coordinate tapping"
fi

if [[ -f "$MANIFEST" ]] && rg -q '"fake_screenshots": false' "$MANIFEST"; then
  pass "no fabricated screenshots"
else
  fail "no fabricated screenshots"
fi

if [[ -f "$MANIFEST" ]] && rg -q '"automated_visual_truth": "non-empty screenshot proof only"' "$MANIFEST"; then
  pass "automated visual claim is limited to non-empty proof"
else
  fail "automated visual claim is limited to non-empty proof"
fi

for shot in \
  connect_constellation.png \
  local_watch_room.png \
  premiere_lobby.png \
  profile_connect_entry.png \
  movie_detail_watch_together.png
do
  if [[ -s "$SHOT_DIR/$shot" ]]; then
    pass "$shot exists and is non-empty"
  else
    fail "$shot exists and is non-empty"
  fi
done

if [[ -f "$MANIFEST" ]] && jq -e '.omissions == []' "$MANIFEST" >/dev/null; then
  pass "route omissions are reported honestly"
else
  fail "route omissions are reported honestly"
fi

status="passed"
if (( ${#FAILURES[@]} > 0 )); then
  status="failed"
fi

{
  printf '{\n'
  printf '  "upgrade": "UI-03B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "checks_passed": %d,\n' "${#PASSES[@]}"
  printf '  "checks_failed": %d,\n' "${#FAILURES[@]}"
  printf '  "screenshot_folder": "%s",\n' "$SHOT_DIR"
  printf '  "manifest": "%s",\n' "$MANIFEST"
  printf '  "failures": ['
  if (( ${#FAILURES[@]} > 0 )); then
    printf '"see markdown report"'
  fi
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Connect Constellation Screenshot Verification\n\n'
  printf -- '- Upgrade: UI-03B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Checks passed: %d\n' "${#PASSES[@]}"
  printf -- '- Checks failed: %d\n\n' "${#FAILURES[@]}"
  printf '## Passed Checks\n'
  for item in "${PASSES[@]}"; do
    printf -- '- %s\n' "$item"
  done
  if (( ${#FAILURES[@]} > 0 )); then
    printf '\n## Failed Checks\n'
    for item in "${FAILURES[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  exit 1
fi
