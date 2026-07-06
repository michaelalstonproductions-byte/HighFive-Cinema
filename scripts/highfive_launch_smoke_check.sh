#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/launch-polish"
DERIVED_DATA="${DERIVED_DATA:-/private/tmp/highfive-launch-smoke}"
APP_BUNDLE_ID="${APP_BUNDLE_ID:-com.higherkey.HigherKeySpatialPeek-Rebuild}"
SCREENSHOT="$OUT/latest-launch.png"
RESULT="$OUT/launch-smoke-result.txt"

mkdir -p "$OUT"

status() {
  printf '%s\n' "$1" | tee "$RESULT"
}

echo "Building HighFive Debug for launch smoke check..."
if ! TMPDIR="${TMPDIR:-/private/tmp}" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build > "$OUT/launch-smoke-build.log" 2>&1; then
  status "BUILD_FAILED"
  exit 0
fi

if ! command -v xcrun >/dev/null 2>&1; then
  status "SIMULATOR_UNAVAILABLE"
  exit 0
fi

DEVICE_ID="${DEVICE_ID:-}"
if [[ -z "$DEVICE_ID" ]]; then
  DEVICE_ID="$(xcrun simctl list devices available 2>/dev/null | awk -F '[()]' '/iPhone/ && /Booted/ {print $2; exit}')"
fi
if [[ -z "$DEVICE_ID" ]]; then
  DEVICE_ID="$(xcrun simctl list devices available 2>/dev/null | awk -F '[()]' '/iPhone/ {print $2; exit}')"
fi
if [[ -z "$DEVICE_ID" ]]; then
  status "SIMULATOR_UNAVAILABLE"
  exit 0
fi

if ! xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1; then
  if ! xcrun simctl list devices 2>/dev/null | grep -q "$DEVICE_ID.*Booted"; then
    status "SIMULATOR_UNAVAILABLE"
    exit 0
  fi
fi

APP_PATH="$(find "$DERIVED_DATA/Build/Products" -path '*Debug-iphonesimulator/HighFive Cinema.app' -print -quit 2>/dev/null || true)"
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  status "BUILD_FAILED"
  exit 0
fi

if ! xcrun simctl install "$DEVICE_ID" "$APP_PATH" >/dev/null 2>&1; then
  status "SIMULATOR_UNAVAILABLE"
  exit 0
fi

if ! xcrun simctl launch "$DEVICE_ID" "$APP_BUNDLE_ID" >/dev/null 2>&1; then
  status "LAUNCH_FAILED"
  exit 0
fi

sleep 1

if ! xcrun simctl io "$DEVICE_ID" screenshot "$SCREENSHOT" >/dev/null 2>&1; then
  status "SIMULATOR_UNAVAILABLE"
  exit 0
fi

brightness_status="$(python3 - "$SCREENSHOT" <<'PY'
import struct
import sys
import zlib
from pathlib import Path

path = Path(sys.argv[1])
data = path.read_bytes()
if not data.startswith(b"\x89PNG\r\n\x1a\n"):
    print("SCREENSHOT_BLACK")
    sys.exit(0)

pos = 8
width = height = bit_depth = color_type = None
compressed = bytearray()

while pos + 8 <= len(data):
    length = struct.unpack(">I", data[pos:pos + 4])[0]
    chunk_type = data[pos + 4:pos + 8]
    chunk = data[pos + 8:pos + 8 + length]
    pos += 12 + length
    if chunk_type == b"IHDR":
        width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", chunk)
        if bit_depth != 8 or interlace != 0:
            print("PASS")
            sys.exit(0)
    elif chunk_type == b"IDAT":
        compressed.extend(chunk)
    elif chunk_type == b"IEND":
        break

if not width or not height:
    print("SCREENSHOT_BLACK")
    sys.exit(0)

channels_by_type = {0: 1, 2: 3, 4: 2, 6: 4}
channels = channels_by_type.get(color_type)
if channels is None:
    print("PASS")
    sys.exit(0)

raw = zlib.decompress(bytes(compressed))
stride = width * channels
prev = [0] * stride
offset = 0
total = 0.0
count = 0

for _ in range(height):
    filter_type = raw[offset]
    offset += 1
    scan = list(raw[offset:offset + stride])
    offset += stride
    recon = [0] * stride
    for i, value in enumerate(scan):
        left = recon[i - channels] if i >= channels else 0
        up = prev[i]
        up_left = prev[i - channels] if i >= channels else 0
        if filter_type == 0:
            out = value
        elif filter_type == 1:
            out = (value + left) & 0xFF
        elif filter_type == 2:
            out = (value + up) & 0xFF
        elif filter_type == 3:
            out = (value + ((left + up) // 2)) & 0xFF
        elif filter_type == 4:
            p = left + up - up_left
            pa = abs(p - left)
            pb = abs(p - up)
            pc = abs(p - up_left)
            predictor = left if pa <= pb and pa <= pc else up if pb <= pc else up_left
            out = (value + predictor) & 0xFF
        else:
            out = value
        recon[i] = out

    for x in range(width):
        base = x * channels
        if color_type == 0:
            r = g = b = recon[base]
        else:
            r, g, b = recon[base], recon[base + 1], recon[base + 2]
        total += (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0
        count += 1
    prev = recon

average = total / max(1, count)
print("SCREENSHOT_BLACK" if average < 0.015 else "PASS")
PY
)"

if [[ "$brightness_status" == "SCREENSHOT_BLACK" ]]; then
  status "SCREENSHOT_BLACK"
else
  status "PASS"
fi
