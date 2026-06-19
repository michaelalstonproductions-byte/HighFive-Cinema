#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UPGRADE="UI-01B"
EVIDENCE_DIR="/private/tmp/highfive-ui-01b-spatial-cinema-evidence"
SHOT_DIR="$EVIDENCE_DIR/screenshots"
MANIFEST="$EVIDENCE_DIR/spatial_cinema_screenshot_manifest.json"
JSON_OUT="$EVIDENCE_DIR/spatial_cinema_screenshot_verification.json"
MD_OUT="$EVIDENCE_DIR/spatial_cinema_screenshot_verification.md"

mkdir -p "$EVIDENCE_DIR"

python3 - "$UPGRADE" "$SHOT_DIR" "$MANIFEST" "$JSON_OUT" "$MD_OUT" <<'PY'
import json
import os
import sys

upgrade, shot_dir, manifest_path, json_out, md_out = sys.argv[1:6]
required = ["home", "movie_detail", "player", "profile_tabs"]
checks = []
failures = []

def check(condition, label):
    if condition:
        checks.append(label)
    else:
        failures.append(label)

check(os.path.isdir(shot_dir), f"screenshot folder exists: {shot_dir}")
check(os.path.isfile(manifest_path), f"manifest exists: {manifest_path}")

manifest = {}
if os.path.isfile(manifest_path):
    try:
        with open(manifest_path, encoding="utf-8") as f:
            manifest = json.load(f)
        checks.append("manifest JSON parses")
    except Exception as exc:
        failures.append(f"manifest JSON parse failed: {exc}")

if manifest:
    check(manifest.get("status") == "passed", "manifest status passed")
    check(manifest.get("build") == "passed", "build passed")
    check(manifest.get("install") == "passed", "install passed")
    check(manifest.get("coordinate_tapping") is False, "no coordinate tapping used")
    check(manifest.get("fake_screenshots") is False, "no screenshot fabricated")
    check(manifest.get("automated_visual_truth") == "non-empty screenshot proof only", "no automated visual-quality claim beyond non-empty proof")
    check("omissions" in manifest, "route omissions field reported")

paths = manifest.get("screenshot_paths", {}) if manifest else {}
byte_counts = manifest.get("screenshot_byte_counts", {}) if manifest else {}
for name in required:
    path = paths.get(name, os.path.join(shot_dir, f"{name}.png"))
    check(os.path.isfile(path), f"{name} screenshot exists")
    check(os.path.getsize(path) > 0 if os.path.isfile(path) else False, f"{name} screenshot is non-empty")
    if name in byte_counts:
        check(byte_counts[name] > 0, f"{name} manifest byte count is non-empty")

status = "passed" if not failures else "failed"
data = {
    "upgrade": upgrade,
    "status": status,
    "manifest": manifest_path,
    "screenshot_folder": shot_dir,
    "checks": checks,
    "failures": failures,
}
with open(json_out, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

with open(md_out, "w", encoding="utf-8") as f:
    f.write("# Spatial Cinema Screenshot Verification\n\n")
    f.write(f"- Upgrade: {upgrade}\n")
    f.write(f"- Status: {status}\n")
    f.write(f"- Manifest: {manifest_path}\n")
    f.write(f"- Screenshot folder: {shot_dir}\n\n")
    f.write("## Checks\n")
    for item in checks:
        f.write(f"- PASS: {item}\n")
    f.write("\n## Failures\n")
    if failures:
        for item in failures:
            f.write(f"- FAIL: {item}\n")
    else:
        f.write("- None\n")

if failures:
    sys.exit(1)
PY

echo "Screenshot verification passed: $JSON_OUT"
