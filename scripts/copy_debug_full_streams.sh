#!/usr/bin/env bash
set -euo pipefail

echo "HighFive Debug Full Streams copy step"

CONFIGURATION="${CONFIGURATION:-}"
TARGET_RESOURCES="${TARGET_BUILD_DIR:-}/${UNLOCALIZED_RESOURCES_FOLDER_PATH:-}"

if [[ "$CONFIGURATION" != "Debug" ]]; then
  echo "Release/non-Debug build: removing any accidental *_ref.mp4 files from app resources."
  if [[ -d "$TARGET_RESOURCES" ]]; then
    find "$TARGET_RESOURCES" -maxdepth 2 -name '*_ref.mp4' -delete || true
  fi
  exit 0
fi

if [[ -z "$TARGET_RESOURCES" || ! -d "$TARGET_RESOURCES" ]]; then
  echo "No target resources folder yet; skipping debug stream copy."
  exit 0
fi

STREAM_DIR="${HF_LOCAL_FULL_STREAM_DIR:-}"

# Local convenience fallback for this development machine only.
# DEBUG build script only. These files must never be copied in Release.
if [[ -z "$STREAM_DIR" && -d "/Volumes/Scratch SSD/New project may 29th" ]]; then
  STREAM_DIR="/Volumes/Scratch SSD/New project may 29th"
fi

if [[ -z "$STREAM_DIR" || ! -d "$STREAM_DIR" ]]; then
  echo "No debug stream directory found."
  echo "Set HF_LOCAL_FULL_STREAM_DIR to the folder containing TheFriendly_ref.mp4 and Paranormall_E*_ref.mp4."
  exit 0
fi

DEST_DIR="$TARGET_RESOURCES/DebugFullStreams"
mkdir -p "$DEST_DIR"

FILES=(
  "TheFriendly_ref.mp4"
  "Paranormall_E1_ref.mp4"
  "Paranormall_E2_ref.mp4"
  "Paranormall_E3_ref.mp4"
  "Paranormall_E4_ref.mp4"
  "Paranormall_E5_ref.mp4"
  "Paranormall_E6_ref.mp4"
  "Paranormall_E7_ref.mp4"
)

for file in "${FILES[@]}"; do
  SRC="$STREAM_DIR/$file"
  if [[ -f "$SRC" ]]; then
    echo "Copying DEBUG stream: $file"
    rm -f "$DEST_DIR/.$file".* 2>/dev/null || true
    /bin/cp -f "$SRC" "$DEST_DIR/$file"
    /usr/bin/touch "$DEST_DIR/$file"
  else
    echo "Missing DEBUG stream: $SRC"
  fi
done

echo "Debug full stream copy step complete."
