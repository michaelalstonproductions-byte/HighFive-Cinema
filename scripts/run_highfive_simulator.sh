#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/simulator"
LOG="$OUT/run-highfive-simulator.log"
DERIVED_DATA="/private/tmp/highfive-simulator-derived"
mkdir -p "$OUT"

exec > "$LOG" 2>&1

echo "HighFive Simulator Run"
echo "repo: $ROOT"
echo "date: $(date)"

DEVICE_INFO="$(python3 - <<'PY'
import json
import subprocess
import sys

def simctl_json(*args):
    return json.loads(subprocess.check_output(["xcrun", "simctl", *args, "-j"], text=True))

devices = simctl_json("list", "devices", "available").get("devices", {})
all_devices = []
for runtime, values in devices.items():
    if "iOS" not in runtime and "iPhone" not in runtime:
        continue
    for device in values:
        if device.get("isAvailable") and "iPhone" in device.get("name", ""):
            all_devices.append(device)

booted = [d for d in all_devices if d.get("state") == "Booted"]
preferred_names = ["iPhone 16 Pro", "iPhone 15 Pro"]
chosen = booted[0] if booted else None
if chosen is None:
    for name in preferred_names:
        matches = [d for d in all_devices if d.get("name") == name]
        if matches:
            chosen = matches[-1]
            break
if chosen is None and all_devices:
    chosen = all_devices[-1]

if chosen is None:
    print("NO_DEVICE\tNO_DEVICE")
    sys.exit(0)

print(f"{chosen.get('udid')}\t{chosen.get('name')}")
PY
)"

UDID="${DEVICE_INFO%%$'\t'*}"
DEVICE_NAME="${DEVICE_INFO#*$'\t'}"
if [[ "$UDID" == "NO_DEVICE" || -z "$UDID" ]]; then
  echo "FAILED: no available iPhone simulator found."
  "$ROOT/scripts/highfive_simulator_doctor.sh" || true
  exit 1
fi

echo "simulator UDID: $UDID"
echo "device name: $DEVICE_NAME"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b
open -a Simulator || true

rm -rf "$DERIVED_DATA"

echo "Building Debug for simulator..."
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build

APP_PATH="$(find "$DERIVED_DATA/Build/Products/Debug-iphonesimulator" -maxdepth 2 -name "*.app" -type d | head -n 1)"
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "FAILED: could not find built .app under $DERIVED_DATA/Build/Products/Debug-iphonesimulator"
  exit 1
fi

BUNDLE_ID="$(plutil -extract CFBundleIdentifier raw "$APP_PATH/Info.plist")"
echo "app path: $APP_PATH"
echo "bundle ID: $BUNDLE_ID"

xcrun simctl install "$UDID" "$APP_PATH"
xcrun simctl launch --terminate-running-process "$UDID" "$BUNDLE_ID" \
  --hf-simulator-preview \
  --hf-simulate-ui-depth \
  --hf-open-home

sleep 5

SCREENSHOT="$OUT/highfive-home.png"
xcrun simctl io "$UDID" screenshot "$SCREENSHOT"

echo "screenshot: $SCREENSHOT"
echo "HighFive Simulator run complete."
