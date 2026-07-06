#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "FAIL: $1"
  exit 1
}

echo "Running HighFive release safety check..."

if grep -R "/Volumes/Scratch SSD/New project may 29th" HighFive.xcodeproj/project.pbxproj HighFive 2>/dev/null; then
  fail "Absolute local movie path found."
fi

if grep -R "TheFriendly_ref.mp4 in Resources\|Paranormall_E[1-7]_ref.mp4 in Resources" HighFive.xcodeproj/project.pbxproj 2>/dev/null; then
  fail "Reference full movie still attached to Copy Bundle Resources."
fi

if grep -R "com.highfive.app.unlock\|com.highfive.series.paranormall.season1" HighFive 2>/dev/null; then
  fail "Inactive StoreKit product found."
fi

if grep -R 'com.highfive.episode.paranormall.e7"' HighFive 2>/dev/null; then
  fail "Old Paranormall Episode 7 product found. Use e7.v2."
fi

if grep -R "preview_.*full\|full.*preview_" HighFive/Data HighFive/Views 2>/dev/null; then
  fail "Preview may be wired to full playback. Inspect before shipping."
fi

python3 - <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path("HighFive/App/Resources/Streaming/HFOfficialStreams.json")
if not manifest_path.exists():
    print("FAIL: HFOfficialStreams.json is missing.")
    sys.exit(1)

try:
    manifest = json.loads(manifest_path.read_text())
except Exception as error:
    print(f"FAIL: HFOfficialStreams.json cannot be decoded: {error}")
    sys.exit(1)

errors = []
for entry in manifest.get("titles", []):
    title_id = entry.get("id", "")
    series_id = entry.get("seriesID")
    if title_id != "friendly" and series_id != "paranormall-s1":
        continue

    url = (entry.get("fullStreamURL") or "").strip()
    label = f"{title_id} product={entry.get('storeKitProductID')}"
    if not url:
        errors.append(f"empty fullStreamURL for {label}")
    elif not url.startswith("https://"):
        errors.append(f"non-https fullStreamURL for {label}: {url}")
    elif "preview_" in url or "_ref." in url or "/Volumes/" in url or url.startswith("file:"):
        errors.append(f"forbidden full playback URL for {label}: {url}")

if errors:
    print("FAIL: Official stream manifest is not submission safe.")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)
PY

python3 - <<'PY'
from pathlib import Path
import sys

def strip_debug_blocks(text: str) -> str:
    output = []
    skipping = 0
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("#if DEBUG"):
            skipping += 1
            continue
        if skipping:
            if stripped.startswith("#if "):
                skipping += 1
            elif stripped.startswith("#endif"):
                skipping -= 1
            continue
        output.append(line)
    return "\n".join(output)

needles = [
    "HF_ALLOW_DEBUG_PAYWALL_UNLOCK",
    "debugUnlockedMovieIDs",
]

matches = []
for path in Path("HighFive").rglob("*.swift"):
    release_text = strip_debug_blocks(path.read_text(errors="ignore"))
    for needle in needles:
        if needle in release_text:
            matches.append(f"{path}: release-facing {needle}")

if matches:
    print("FAIL: Release-facing debug unlock code found.")
    for match in matches:
        print(f" - {match}")
    sys.exit(1)
PY

if grep -R --exclude="highfive_release_safety_check.sh" "\[Company Legal Name\]\|\[Support Email\]\|\[Company Mailing Address\]\|\[Phone Number, if available\]\|TODO App Store\|FIXME App Store" HighFive Scripts scripts 2>/dev/null; then
  fail "App Store legal placeholder or TODO/FIXME remains."
fi

RELEASE_PRODUCTS_DIR="${HIGHFIVE_RELEASE_PRODUCTS_DIR:-/private/tmp/highfive-streams-back-release/Build/Products}"
if [[ -d "$RELEASE_PRODUCTS_DIR" ]] && find "$RELEASE_PRODUCTS_DIR" -name '*_ref.mp4' -print -quit | grep -q .; then
  find "$RELEASE_PRODUCTS_DIR" -name '*_ref.mp4' -print
  fail "Release app product contains debug full reference movies."
fi

echo "PASS: HighFive release safety check passed."
