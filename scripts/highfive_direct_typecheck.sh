#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/simulator"
SOURCE_OUT="$ROOT/out/highfive-1-2-depth-pass"
mkdir -p "$OUT" "$SOURCE_OUT"

SWIFTC="$(xcrun --find swiftc)"
SIM_SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
DEVICE_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
MODULE_CACHE="/private/tmp/highfive-direct-typecheck-module-cache"
mkdir -p "$MODULE_CACHE/debug" "$MODULE_CACHE/release"

sanitize_source_list() {
  local raw_list="$1"
  local output_list="$2"
  local report="$3"

  python3 - "$raw_list" "$output_list" "$report" <<'PY'
from pathlib import Path
import sys

raw_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
report_path = Path(sys.argv[3])
root = Path.cwd()

raw_lines = raw_path.read_text().splitlines() if raw_path.exists() else []
seen = set()
paths = []

for line in raw_lines:
    item = line.strip()
    if not item:
        continue

    # Normalize old escaped absolute paths from earlier generated file lists.
    item = item.replace("\\ ", " ")

    root_text = str(root)
    if item.startswith(root_text + "/"):
        item = str(Path(item).relative_to(root))

    if not item.endswith(".swift"):
        continue
    if "Checkpoint March 23" in item:
        continue
    if "/DerivedSources/" in item or item.endswith("GeneratedAssetSymbols.swift"):
        continue
    if "/out/" in item:
        continue

    p = Path(item)
    if not p.exists():
        continue

    normalized = str(p)
    if normalized not in seen:
        seen.add(normalized)
        paths.append(normalized)

groups = {}
for path in paths:
    groups.setdefault(Path(path).name, []).append(path)

# Direct swiftc fallback is not the Xcode target source-of-truth. It is a
# source-health fallback. Raw find can over-include similarly named helper files
# and fail with "filename used twice", even when xcodebuild's target source set
# is valid. Prefer the active/canonical UI path when known, otherwise keep the
# first stable sorted path and record the fallback-only exclusions.
priority = {
    "LaunchOnboardingViewController.swift": [
        "HighFive/App/Creator/Onboarding/LaunchOnboardingViewController.swift",
        "HighFive/App/Onboarding/LaunchOnboardingViewController.swift",
        "HighFive/App/Depth/Onboarding/LaunchOnboardingViewController.swift",
        "HighFive/App/Motion/LaunchOnboardingViewController.swift",
        "HighFive/App/Motion/Onboarding/LaunchOnboardingViewController.swift",
    ],
    "HKV1_ControlBar.swift": [
        "HighFive/App/UI/HKV1_ControlBar.swift",
        "HighFive/App/UI/Rendering/HKV1_ControlBar.swift",
    ],
}

kept = []
dropped = []

for basename in sorted(groups):
    candidates = sorted(groups[basename])

    if len(candidates) == 1:
        kept.append(candidates[0])
        continue

    preferred = None
    for candidate in priority.get(basename, []):
        if candidate in candidates:
            preferred = candidate
            break

    if preferred is None:
        preferred = candidates[0]

    kept.append(preferred)
    for candidate in candidates:
        if candidate != preferred:
            dropped.append((basename, preferred, candidate))

kept = sorted(dict.fromkeys(kept))
output_path.write_text("\n".join(kept) + "\n")

lines = [
    "# HighFive direct typecheck fallback duplicate exclusions",
    "",
    f"Input source count: {len(paths)}",
    f"Output source count: {len(kept)}",
    f"Dropped duplicate count: {len(dropped)}",
    "",
]

for basename, preferred, candidate in dropped:
    lines.append(f"- {basename}")
    lines.append(f"  kept: {preferred}")
    lines.append(f"  dropped: {candidate}")

report_path.write_text("\n".join(lines) + "\n")
PY
}

prepare_list() {
  local source_list="$1"
  local output_list="$2"
  local raw_list="$output_list.raw"
  local report="$OUT/direct-typecheck-fallback-exclusions.txt"

  if [[ -f "$source_list" ]]; then
    cp "$source_list" "$raw_list"
  else
    find HighFive -name "*.swift" \
      ! -path "*Checkpoint March 23*" \
      ! -path "*/out/*" \
      | sort > "$raw_list"
  fi

  sanitize_source_list "$raw_list" "$output_list" "$report"
}

run_typecheck() {
  local name="$1"
  local sdk="$2"
  local target="$3"
  local list="$4"
  local cache="$5"
  local log="$OUT/${name}-typecheck.log"
  local status="$OUT/${name}-typecheck.status"

  echo "Running $name direct Swift typecheck..."
  set +e
  "$SWIFTC" \
    -typecheck \
    -parse-as-library \
    -default-isolation=MainActor \
    -sdk "$sdk" \
    -target "$target" \
    -module-cache-path "$cache" \
    @"$list" > "$log" 2>&1
  local code="$?"
  set -e

  if [[ "$code" == "0" ]]; then
    echo "PASS" > "$status"
    echo "$name typecheck: PASS"
  else
    echo "FAIL ($code)" > "$status"
    echo "$name typecheck: FAIL ($code)"
    tail -120 "$log" || true
    return "$code"
  fi
}

DEBUG_LIST="$OUT/debug-typecheck.SwiftFileList"
RELEASE_LIST="$OUT/release-typecheck.SwiftFileList"

prepare_list "$SOURCE_OUT/debug-typecheck-pass3-relative.SwiftFileList" "$DEBUG_LIST"
prepare_list "$SOURCE_OUT/release-typecheck-pass3-relative.SwiftFileList" "$RELEASE_LIST"

run_typecheck "debug" "$SIM_SDK" "arm64-apple-ios18.0-simulator" "$DEBUG_LIST" "$MODULE_CACHE/debug"
run_typecheck "release" "$DEVICE_SDK" "arm64-apple-ios18.0" "$RELEASE_LIST" "$MODULE_CACHE/release"
