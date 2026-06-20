#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-ui-07b-spatial-cohesion-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$OUT_DIR/cross_module_spatial_cohesion_screenshot_manifest.json"
MANIFEST_MD="$OUT_DIR/cross_module_spatial_cohesion_screenshot_manifest.md"
JSON_OUT="$OUT_DIR/cross_module_spatial_cohesion_screenshot_verification.json"
MD_OUT="$OUT_DIR/cross_module_spatial_cohesion_screenshot_verification.md"

mkdir -p "$OUT_DIR"

python3 - "$SHOT_DIR" "$MANIFEST_JSON" "$MANIFEST_MD" "$JSON_OUT" "$MD_OUT" <<'PY'
import json
import os
import sys
from pathlib import Path

shot_dir, manifest_json, manifest_md, json_out, md_out = map(Path, sys.argv[1:])
failures = []

if not shot_dir.exists():
    failures.append("screenshot folder does not exist")
if not manifest_json.exists():
    failures.append("manifest JSON does not exist")
if not manifest_md.exists():
    failures.append("manifest Markdown does not exist")

manifest = {}
if manifest_json.exists():
    try:
        manifest = json.loads(manifest_json.read_text())
    except Exception as exc:
        failures.append(f"manifest JSON parse failed: {exc}")

if manifest:
    if manifest.get("status") != "passed":
        failures.append("manifest status is not passed")
    if manifest.get("build") != "passed":
        failures.append("build did not pass")
    if manifest.get("install") != "passed":
        failures.append("install did not pass")
    if manifest.get("coordinate_tapping") is not False:
        failures.append("coordinate tapping was not false")
    if manifest.get("fake_screenshots") is not False:
        failures.append("fake screenshots was not false")
    if manifest.get("automated_visual_truth") != "non-empty screenshot proof only":
        failures.append("manifest claims visual truth beyond non-empty proof")
    if manifest.get("content_size_restored") is not True:
        failures.append("simulator content size was not restored")

    normal = manifest.get("normal_screenshot_paths", [])
    if len(normal) != 10:
        failures.append(f"expected 10 normal screenshots, got {len(normal)}")
    for path in normal:
        p = Path(path)
        if not p.exists() or p.stat().st_size <= 0:
            failures.append(f"normal screenshot missing or empty: {path}")

    large_supported = manifest.get("large_text_supported") is True
    large = manifest.get("large_text_screenshot_paths", [])
    if large_supported and len(large) != 4:
        failures.append(f"expected 4 large-text screenshots, got {len(large)}")
    if large_supported:
        for path in large:
            p = Path(path)
            if not p.exists() or p.stat().st_size <= 0:
                failures.append(f"large-text screenshot missing or empty: {path}")

status = "passed" if not failures else "failed"
data = {
    "upgrade": "UI-07B",
    "status": status,
    "manifest": str(manifest_json),
    "screenshot_folder": str(shot_dir),
    "normal_screenshot_count": len(manifest.get("normal_screenshot_paths", [])) if manifest else 0,
    "large_text_supported": manifest.get("large_text_supported") if manifest else None,
    "large_text_screenshot_count": len(manifest.get("large_text_screenshot_paths", [])) if manifest else 0,
    "build": manifest.get("build") if manifest else None,
    "install": manifest.get("install") if manifest else None,
    "coordinate_tapping": manifest.get("coordinate_tapping") if manifest else None,
    "fake_screenshots": manifest.get("fake_screenshots") if manifest else None,
    "automated_visual_truth": manifest.get("automated_visual_truth") if manifest else None,
    "omissions": manifest.get("omissions", []) if manifest else [],
    "failures": failures,
}
json_out.write_text(json.dumps(data, indent=2) + "\n")
lines = [
    "# UI-07B Screenshot Verification",
    "",
    f"Status: **{status}**",
    f"Manifest: `{manifest_json}`",
    f"Normal screenshot count: `{data['normal_screenshot_count']}`",
    f"Large text supported: `{data['large_text_supported']}`",
    f"Large text screenshot count: `{data['large_text_screenshot_count']}`",
    "Automated visual truth: non-empty screenshot proof only",
]
if data["omissions"]:
    lines += ["", "## Omissions", *[f"- {o}" for o in data["omissions"]]]
if failures:
    lines += ["", "## Failures", *[f"- {f}" for f in failures]]
md_out.write_text("\n".join(lines) + "\n")
if failures:
    sys.exit(1)
PY

echo "Screenshot verification passed: $JSON_OUT"
