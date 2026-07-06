#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/simulator"
DERIVED_DATA="/private/tmp/highfive-simulator-derived-diagnose"
LOG="$OUT/xcodebuild-diagnose.log"
ERRORS="$OUT/xcodebuild-errors.txt"
RESULT_BUNDLE="$OUT/highfive-diagnose.xcresult"

mkdir -p "$OUT"
rm -rf "$DERIVED_DATA" "$RESULT_BUNDLE"

echo "HighFive xcodebuild diagnose"
echo "repo: $ROOT"
echo "derivedData: $DERIVED_DATA"
echo "log: $LOG"
echo

set +e
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_BUNDLE" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build > "$LOG" 2>&1
STATUS="$?"
set -e

{
  echo "HighFive xcodebuild diagnose status: $STATUS"
  echo "log: $LOG"
  echo "resultBundle: $RESULT_BUNDLE"
  echo
  echo "Extracted error context"
  echo "======================="
  rg -n -C 4 \
    "error:|fatal error:|SwiftEmitModule|EmitSwiftModule|cannot find|no such module|unresolved identifier|has no member|ambiguous|type .* has no member|value of type|cannot infer|result builder|duplicate filename|command SwiftCompile failed|Command SwiftEmitModule failed|The following build commands failed|CoreSimulatorService|simdiskimaged|permissionDenied|Unable to discover swiftc" \
    "$LOG" || true
} > "$ERRORS"

echo "xcodebuild status: $STATUS"
echo "errors: $ERRORS"
echo
tail -120 "$ERRORS" || true

exit "$STATUS"
