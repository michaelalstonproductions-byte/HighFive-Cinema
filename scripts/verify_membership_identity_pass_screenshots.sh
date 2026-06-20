#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EVIDENCE_DIR="/private/tmp/highfive-ui-06b-membership-identity-pass-evidence"
SHOT_DIR="$EVIDENCE_DIR/screenshots"
MANIFEST="$EVIDENCE_DIR/membership_identity_pass_screenshot_manifest.json"
JSON_OUT="$EVIDENCE_DIR/membership_identity_pass_screenshot_verification.json"
MD_OUT="$EVIDENCE_DIR/membership_identity_pass_screenshot_verification.md"

required=(
  membership_pass_default.png
  membership_identity.png
  membership_premieres.png
  membership_creator_rooms.png
  membership_protected_playback.png
  membership_depth_peek.png
  profile_membership_entry.png
  movie_detail_access_regression.png
  vod_regression.png
)

failures=()
passes=()

[[ -d "$SHOT_DIR" ]] && passes+=("screenshot folder exists") || failures+=("screenshot folder missing")
[[ -f "$MANIFEST" ]] && passes+=("manifest exists") || failures+=("manifest missing")

if [[ -f "$MANIFEST" ]]; then
  if python3 -m json.tool "$MANIFEST" >/dev/null; then
    passes+=("manifest JSON parses")
  else
    failures+=("manifest JSON does not parse")
  fi

  manifest_status="$(python3 - <<PY
import json
print(json.load(open("$MANIFEST")).get("status", "missing"))
PY
)"
  [[ "$manifest_status" == "passed" ]] && passes+=("manifest status passed") || failures+=("manifest status not passed:$manifest_status")

  build_status="$(python3 - <<PY
import json
print(json.load(open("$MANIFEST")).get("build", "missing"))
PY
)"
  [[ "$build_status" == "passed" ]] && passes+=("build passed") || failures+=("build not passed:$build_status")

  install_status="$(python3 - <<PY
import json
print(json.load(open("$MANIFEST")).get("install", "missing"))
PY
)"
  [[ "$install_status" == "passed" ]] && passes+=("install passed") || failures+=("install not passed:$install_status")

  coordinate_tapping="$(python3 - <<PY
import json
print(json.load(open("$MANIFEST")).get("coordinate_tapping"))
PY
)"
  [[ "$coordinate_tapping" == "False" ]] && passes+=("no coordinate tapping") || failures+=("coordinate tapping flag not false")

  fake_screenshots="$(python3 - <<PY
import json
print(json.load(open("$MANIFEST")).get("fake_screenshots"))
PY
)"
  [[ "$fake_screenshots" == "False" ]] && passes+=("no fabricated screenshots") || failures+=("fake screenshots flag not false")

  visual_truth="$(python3 - <<PY
import json
print(json.load(open("$MANIFEST")).get("automated_visual_truth", ""))
PY
)"
  [[ "$visual_truth" == "non-empty screenshot proof only" ]] && passes+=("automated visual truth limited to non-empty proof") || failures+=("automated visual truth overclaimed")
fi

for file in "${required[@]}"; do
  path="$SHOT_DIR/$file"
  if [[ -s "$path" ]]; then
    passes+=("non-empty screenshot:$path")
  else
    failures+=("missing or empty screenshot:$path")
  fi
done

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

REQUIRED_JSON="$(mktemp)"
PASSES_JSON="$(mktemp)"
FAILURES_JSON="$(mktemp)"
printf '%s\n' "${required[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip() for l in sys.stdin if l.rstrip()]))' > "$REQUIRED_JSON"
printf '%s\n' "${passes[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip() for l in sys.stdin if l.rstrip()]))' > "$PASSES_JSON"
if (( ${#failures[@]} > 0 )); then
  printf '%s\n' "${failures[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip() for l in sys.stdin if l.rstrip()]))' > "$FAILURES_JSON"
else
  printf '[]\n' > "$FAILURES_JSON"
fi

python3 - <<PY
import json
from pathlib import Path
data = {
  "upgrade": "UI-06B",
  "status": "$status",
  "screenshot_folder": "$SHOT_DIR",
  "manifest": "$MANIFEST",
  "required_screenshots": [],
  "passes": [],
  "failures": []
}
data["required_screenshots"] = json.loads(Path("$REQUIRED_JSON").read_text())
data["passes"] = json.loads(Path("$PASSES_JSON").read_text())
data["failures"] = json.loads(Path("$FAILURES_JSON").read_text())
Path("$JSON_OUT").write_text(json.dumps(data, indent=2) + "\n")
PY
rm -f "$REQUIRED_JSON" "$PASSES_JSON" "$FAILURES_JSON"

{
  echo "# Membership Identity Pass Screenshot Verification"
  echo
  echo "- upgrade: UI-06B"
  echo "- status: $status"
  echo "- screenshot folder: $SHOT_DIR"
  echo "- manifest: $MANIFEST"
  echo
  echo "## Passes"
  printf -- "- %s\n" "${passes[@]}"
  if (( ${#failures[@]} > 0 )); then
    echo
    echo "## Failures"
    printf -- "- %s\n" "${failures[@]}"
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

echo "membership identity pass screenshot verification passed"
