#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/simulator"
mkdir -p "$OUT"

RECORD=0
for arg in "$@"; do
  case "$arg" in
    --record) RECORD=1 ;;
    *) echo "Unknown argument: $arg"; exit 2 ;;
  esac
done

UDID="$(python3 - <<'PY'
import json
import subprocess

devices = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "booted", "-j"], text=True)).get("devices", {})
for runtime, values in devices.items():
    for device in values:
        if "iPhone" in device.get("name", "") and device.get("state") == "Booted":
            print(device.get("udid"))
            raise SystemExit
print("")
PY
)"

if [[ -z "$UDID" ]]; then
  echo "FAILED: no booted iPhone simulator found."
  exit 1
fi

SCREENSHOT="$OUT/highfive-current.png"
xcrun simctl io "$UDID" screenshot "$SCREENSHOT"
echo "screenshot: $SCREENSHOT"

if [[ "$RECORD" == "1" ]]; then
  VIDEO="$OUT/highfive-depth-preview.mov"
  rm -f "$VIDEO"
  xcrun simctl io "$UDID" recordVideo "$VIDEO" &
  PID="$!"
  sleep 12
  kill -INT "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true
  echo "video: $VIDEO"
fi
