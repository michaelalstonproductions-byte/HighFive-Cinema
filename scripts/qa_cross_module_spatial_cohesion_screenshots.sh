#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UPGRADE="UI-07B"
OUT_DIR="/private/tmp/highfive-ui-07b-spatial-cohesion-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_OUT="$OUT_DIR/cross_module_spatial_cohesion_screenshot_manifest.json"
MD_OUT="$OUT_DIR/cross_module_spatial_cohesion_screenshot_manifest.md"
DERIVED="/Volumes/Scratch SSD/XcodeDerivedData/highfive-ui-07b-spatial-cohesion-evidence"
APP_ID="com.higherkey.HighFiveCinemaClean.HighFive"
APP_PATH="$DERIVED/Build/Products/Debug-iphonesimulator/HighFive.app"

mkdir -p "$SHOT_DIR"

declare -a failures=()
declare -a omissions=()
declare -a normal_paths=()
declare -a large_paths=()
large_text_supported=false
content_size_restored=false
build_status="not_run"
install_status="not_run"

fail() {
  failures+=("$1")
}

capture_route() {
  local route="$1"
  local file="$2"
  xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
  xcrun simctl launch booted "$APP_ID" --hf-skip-onboarding "$route" >/dev/null
  sleep 4
  xcrun simctl io booted screenshot "$SHOT_DIR/$file" >/dev/null
  test -s "$SHOT_DIR/$file"
}

if TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild -quiet \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build; then
  build_status="passed"
else
  build_status="failed"
  fail "build failed"
fi

if [[ "$build_status" == "passed" ]]; then
  if ! xcrun simctl list devices booted | rg 'iPhone' >/dev/null; then
    DEVICE_ID="$(xcrun simctl list devices available | rg 'iPhone' | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
    xcrun simctl boot "$DEVICE_ID" || true
    open -a Simulator || true
    xcrun simctl bootstatus booted -b
  fi

  xcrun simctl terminate booted "$APP_ID" >/dev/null 2>&1 || true
  xcrun simctl uninstall booted "$APP_ID" >/dev/null 2>&1 || true
  if xcrun simctl install booted "$APP_PATH"; then
    install_status="passed"
  else
    install_status="failed"
    fail "install failed"
  fi
fi

normal_routes=(
  "--hf-start-home:home.png"
  "--hf-start-movie-detail:movie_detail.png"
  "--hf-start-player:player.png"
  "--hf-start-creator-studio:creator_studio.png"
  "--hf-start-connect:connect.png"
  "--hf-start-connect-room:local_watch_room.png"
  "--hf-start-social-media-kit:social_campaign.png"
  "--hf-start-vod-package:vod_launch_chamber.png"
  "--hf-start-membership:membership_pass.png"
  "--hf-start-profile:profile_tabs.png"
)

if [[ "$install_status" == "passed" ]]; then
  for item in "${normal_routes[@]}"; do
    route="${item%%:*}"
    file="${item#*:}"
    if capture_route "$route" "$file"; then
      normal_paths+=("$SHOT_DIR/$file")
    else
      fail "normal screenshot failed for $route"
    fi
  done
fi

simctl_ui_help="$(xcrun simctl help ui 2>&1 || true)"
if printf '%s' "$simctl_ui_help" | rg -q "content_size"; then
  large_text_supported=true
else
  omissions+=("simctl content_size control unsupported by this runtime")
fi

large_routes=(
  "--hf-start-creator-studio:creator_studio_large_text.png"
  "--hf-start-social-media-kit:social_campaign_large_text.png"
  "--hf-start-vod-package:vod_launch_large_text.png"
  "--hf-start-membership:membership_large_text.png"
)

if [[ "$large_text_supported" == "true" && "$install_status" == "passed" ]]; then
  if xcrun simctl ui booted content_size accessibility-extra-extra-large; then
    for item in "${large_routes[@]}"; do
      route="${item%%:*}"
      file="${item#*:}"
      if capture_route "$route" "$file"; then
        large_paths+=("$SHOT_DIR/$file")
      else
        fail "large-text screenshot failed for $route"
      fi
    done
  else
    large_text_supported=false
    omissions+=("simctl content_size command was advertised but failed")
  fi

  if xcrun simctl ui booted content_size large >/dev/null 2>&1; then
    content_size_restored=true
  else
    fail "simulator content size restore failed"
  fi
else
  content_size_restored=true
fi

if [[ ${#normal_paths[@]} -ne 10 ]]; then
  fail "expected 10 normal screenshots, got ${#normal_paths[@]}"
fi
if [[ "$large_text_supported" == "true" && ${#large_paths[@]} -ne 4 ]]; then
  fail "expected 4 large-text screenshots, got ${#large_paths[@]}"
fi

contact_normal=""
contact_large=""
if python3 - <<'PY' "$SHOT_DIR" >/tmp/highfive_ui07b_contact_paths.txt 2>/tmp/highfive_ui07b_contact_errors.txt
import sys
from pathlib import Path
from PIL import Image, ImageDraw

shot_dir = Path(sys.argv[1])
sets = {
    "contact_sheet_normal.png": [
        "home.png", "movie_detail.png", "player.png", "creator_studio.png", "connect.png",
        "local_watch_room.png", "social_campaign.png", "vod_launch_chamber.png", "membership_pass.png", "profile_tabs.png",
    ],
    "contact_sheet_large_text.png": [
        "creator_studio_large_text.png", "social_campaign_large_text.png",
        "vod_launch_large_text.png", "membership_large_text.png",
    ],
}
for out_name, names in sets.items():
    existing = [n for n in names if (shot_dir / n).exists()]
    if not existing:
        continue
    thumbs = []
    for name in existing:
        img = Image.open(shot_dir / name).convert("RGB")
        img.thumbnail((260, 560))
        thumbs.append((name, img.copy()))
    cols = 5 if len(thumbs) > 4 else max(1, len(thumbs))
    pad, label_h, cell_w, cell_h = 16, 34, 280, 610
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell_w + pad, rows * cell_h + pad), (16, 16, 18))
    draw = ImageDraw.Draw(sheet)
    for idx, (name, img) in enumerate(thumbs):
        col, row = idx % cols, idx // cols
        draw.text((pad + col * cell_w + 8, pad + row * cell_h + 8), name, fill=(235, 222, 185))
        x = pad + col * cell_w + (cell_w - img.width) // 2
        y = pad + row * cell_h + label_h
        sheet.paste(img, (x, y))
    out = shot_dir / out_name
    sheet.save(out)
    print(out)
PY
then
  contact_normal="$(rg -n "contact_sheet_normal" /tmp/highfive_ui07b_contact_paths.txt | cut -d: -f2- || true)"
  contact_large="$(rg -n "contact_sheet_large_text" /tmp/highfive_ui07b_contact_paths.txt | cut -d: -f2- || true)"
else
  omissions+=("contact sheet generation unavailable")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

python_args=("$JSON_OUT" "$MD_OUT" "$status" "$UPGRADE" "$build_status" "$install_status" "$large_text_supported" "$content_size_restored" "$contact_normal" "$contact_large")
if (( ${#normal_paths[@]} > 0 )); then
  python_args+=("${normal_paths[@]}")
fi
python_args+=("--")
if (( ${#large_paths[@]} > 0 )); then
  python_args+=("${large_paths[@]}")
fi
python_args+=("--")
if (( ${#failures[@]} > 0 )); then
  python_args+=("${failures[@]}")
fi
python_args+=("--")
if (( ${#omissions[@]} > 0 )); then
  python_args+=("${omissions[@]}")
fi

python3 - "${python_args[@]}" <<'PY'
import json
import os
import sys
from pathlib import Path

args = sys.argv[1:]
json_out, md_out, status, upgrade, build, install, large_supported, restored, contact_normal, contact_large = args[:10]
rest = args[10:]
groups = [[]]
for item in rest:
    if item == "--":
        groups.append([])
    else:
        groups[-1].append(item)
normal_paths, large_paths, failures, omissions = (groups + [[] for _ in range(4)])[:4]
paths = normal_paths + large_paths
byte_counts = {p: os.path.getsize(p) for p in paths if os.path.exists(p)}
data = {
    "upgrade": upgrade,
    "status": status,
    "build": build,
    "install": install,
    "normal_routes": [
        "--hf-start-home", "--hf-start-movie-detail", "--hf-start-player", "--hf-start-creator-studio",
        "--hf-start-connect", "--hf-start-connect-room", "--hf-start-social-media-kit",
        "--hf-start-vod-package", "--hf-start-membership", "--hf-start-profile",
    ],
    "normal_screenshot_paths": normal_paths,
    "large_text_supported": large_supported == "true",
    "large_text_routes": [
        "--hf-start-creator-studio", "--hf-start-social-media-kit", "--hf-start-vod-package", "--hf-start-membership"
    ] if large_supported == "true" else [],
    "large_text_screenshot_paths": large_paths,
    "contact_sheet_paths": [p for p in [contact_normal, contact_large] if p],
    "screenshot_byte_counts": byte_counts,
    "content_size_restored": restored == "true",
    "coordinate_tapping": False,
    "fake_screenshots": False,
    "automated_visual_truth": "non-empty screenshot proof only",
    "omissions": omissions,
    "failures": failures,
}
Path(json_out).write_text(json.dumps(data, indent=2) + "\n")
lines = [
    f"# {upgrade} Screenshot Manifest",
    "",
    f"Status: **{status}**",
    f"Build: `{build}`",
    f"Install: `{install}`",
    f"Large text supported: `{data['large_text_supported']}`",
    f"Content size restored: `{data['content_size_restored']}`",
    "Coordinate tapping: `false`",
    "Fake screenshots: `false`",
    "Automated visual truth: non-empty screenshot proof only",
    "",
    "## Normal Screenshots",
    *[f"- `{p}` ({byte_counts.get(p, 0)} bytes)" for p in normal_paths],
    "",
    "## Large Text Screenshots",
    *[f"- `{p}` ({byte_counts.get(p, 0)} bytes)" for p in large_paths],
]
if data["contact_sheet_paths"]:
    lines += ["", "## Contact Sheets", *[f"- `{p}`" for p in data["contact_sheet_paths"]]]
if omissions:
    lines += ["", "## Omissions", *[f"- {o}" for o in omissions]]
if failures:
    lines += ["", "## Failures", *[f"- {f}" for f in failures]]
Path(md_out).write_text("\n".join(lines) + "\n")
PY

if [[ "$status" != "passed" ]]; then
  printf 'Screenshot harness failed:\n' >&2
  printf ' - %s\n' "${failures[@]}" >&2
  exit 1
fi

echo "Screenshot harness passed: $JSON_OUT"
