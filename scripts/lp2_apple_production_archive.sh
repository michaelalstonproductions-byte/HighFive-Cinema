#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="${HIGHFIVE_DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-lp2-apple-production-configuration}"
ARCHIVE_PATH="${HIGHFIVE_ARCHIVE_PATH:-/private/tmp/highfive-lp2-apple-production-configuration/HighFive.xcarchive}"
EXPORT_PATH="${HIGHFIVE_EXPORT_PATH:-/private/tmp/highfive-lp2-apple-production-configuration/export}"
EXPORT_OPTIONS="${HIGHFIVE_EXPORT_OPTIONS:-$ROOT_DIR/HighFive/Config/ExportOptions.AppStore.example.plist}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/lp2_apple_production_archive.sh verify
  scripts/lp2_apple_production_archive.sh unsigned-archive
  scripts/lp2_apple_production_archive.sh export-signed

Modes:
  verify           Validate checked-in Apple production configuration.
  unsigned-archive Build a Release archive without signing for CI compile verification.
  export-signed    Export a signed App Store Connect archive. Requires Apple signing assets.
USAGE
}

mode="${1:-verify}"

case "$mode" in
  verify)
    "$ROOT_DIR/scripts/verify_lp2_apple_production_configuration.sh"
    ;;
  unsigned-archive)
    mkdir -p "$(dirname "$ARCHIVE_PATH")"
    TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
      -project "$ROOT_DIR/HighFive.xcodeproj" \
      -scheme HighFive \
      -configuration Release \
      -destination 'generic/platform=iOS' \
      -archivePath "$ARCHIVE_PATH" \
      -derivedDataPath "$DERIVED_DATA" \
      CODE_SIGNING_ALLOWED=NO \
      SDK_STAT_CACHE_ENABLE=NO \
      COMPILER_INDEX_STORE_ENABLE=NO \
      archive
    ;;
  export-signed)
    test -d "$ARCHIVE_PATH" || {
      echo "Signed archive not found at $ARCHIVE_PATH" >&2
      exit 1
    }
    mkdir -p "$EXPORT_PATH"
    xcodebuild -exportArchive \
      -archivePath "$ARCHIVE_PATH" \
      -exportPath "$EXPORT_PATH" \
      -exportOptionsPlist "$EXPORT_OPTIONS"
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
