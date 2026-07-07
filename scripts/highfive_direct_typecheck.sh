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

# Clean-worktree fallback note:
# The raw find-based fallback intentionally excludes
# HighFive/App/Depth/Onboarding/LaunchOnboardingViewController.swift because
# there is another LaunchOnboardingViewController.swift in the same module path.
# Swift uses filenames to disambiguate private declarations, so raw-find
# fallback validation can fail on duplicate basenames even when the Xcode target
# source set is valid.

# Clean-worktree fallback note:
# The raw find-based fallback intentionally excludes fallback-only duplicate
# LaunchOnboardingViewController.swift paths. The Xcode target source set is
# the source of truth; raw find validation can over-include similarly named
# onboarding helpers and fail because Swift uses filenames to distinguish
# private declarations.

prepare_list() {
  local source_list="$1"
  local output_list="$2"

  if [[ -f "$source_list" ]]; then
    cp "$source_list" "$output_list"
  else
    find HighFive -name "*.swift" \
      ! -path "*Checkpoint March 23*" \
      ! -path "*/out/*" \
      ! -path "HighFive/App/Depth/Onboarding/LaunchOnboardingViewController.swift" \
      ! -path "HighFive/App/Motion/LaunchOnboardingViewController.swift" \
      | sort > "$output_list"
  fi
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
    tail -80 "$log" || true
    return "$code"
  fi
}

DEBUG_LIST="$OUT/debug-typecheck.SwiftFileList"
RELEASE_LIST="$OUT/release-typecheck.SwiftFileList"
prepare_list "$SOURCE_OUT/debug-typecheck-pass3-relative.SwiftFileList" "$DEBUG_LIST"
prepare_list "$SOURCE_OUT/release-typecheck-pass3-relative.SwiftFileList" "$RELEASE_LIST"

run_typecheck "debug" "$SIM_SDK" "arm64-apple-ios18.0-simulator" "$DEBUG_LIST" "$MODULE_CACHE/debug"
run_typecheck "release" "$DEVICE_SDK" "arm64-apple-ios18.0" "$RELEASE_LIST" "$MODULE_CACHE/release"
