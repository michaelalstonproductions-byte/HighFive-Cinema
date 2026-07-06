#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/simulator"
LOG="$OUT/simulator-doctor.txt"
mkdir -p "$OUT"

exec > "$LOG" 2>&1

echo "HighFive Simulator Doctor"
echo "repo: $ROOT"
echo "cwd: $(pwd)"
echo "date: $(date)"
echo

echo "Toolchain"
echo "xcode-select: $(xcode-select -p 2>/dev/null || echo unavailable)"
echo "DEVELOPER_DIR: ${DEVELOPER_DIR:-<unset>}"
echo "xcodebuild: $(xcrun --find xcodebuild 2>/dev/null || echo unavailable)"
echo "simctl: $(xcrun --find simctl 2>/dev/null || echo unavailable)"
echo

echo "xcodebuild -version"
xcodebuild -version 2>/dev/null || true
echo

echo "Simulator runtimes"
xcrun simctl list runtimes 2>&1 || true
echo

echo "Available devices"
xcrun simctl list devices available 2>&1 || true
echo

echo "Blocker scan"
FOUND=0
RECENT_LOGS=(
  "$OUT/run-highfive-simulator.log"
  "$OUT/simulator-doctor.txt"
  "$ROOT/out/highfive-1-2-depth-pass/debug-build-pass3.log"
  "$ROOT/out/highfive-1-2-depth-pass/release-build-pass3.log"
)
if grep -h "CoreSimulatorService connection became invalid" "${RECENT_LOGS[@]}" >/dev/null 2>&1; then
  echo "- CoreSimulatorService connection became invalid has appeared in recent logs."
  FOUND=1
fi
if grep -h "permissionDenied" "${RECENT_LOGS[@]}" >/dev/null 2>&1; then
  echo "- permissionDenied has appeared in recent build/typecheck logs, commonly while discovering swiftc."
  FOUND=1
fi
if ! xcrun simctl list devices available 2>/dev/null | grep -q "iPhone"; then
  echo "- No available iPhone simulator was found."
  FOUND=1
fi
if ! xcrun simctl list runtimes 2>/dev/null | grep -q "iOS"; then
  echo "- No iOS Simulator runtime was found."
  FOUND=1
fi
if [[ "$FOUND" == "0" ]]; then
  echo "- No known local simulator blocker was detected by this script."
fi
echo

cat <<'EOF'
Non-destructive next steps if blocked:
- Open Xcode once and let it finish installing components.
- Open Simulator once from Xcode > Open Developer Tool > Simulator.
- Confirm Xcode > Settings > Platforms has an installed iOS Simulator runtime.
- If xcode-select points at the wrong Xcode, run:
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
- If CoreSimulator is wedged, quit Simulator and run:
  killall Simulator 2>/dev/null || true
  killall CoreSimulatorService 2>/dev/null || true
- Use /private/tmp for DerivedData when local volume permissions are suspect.

This script does not erase simulators or user data.
EOF
