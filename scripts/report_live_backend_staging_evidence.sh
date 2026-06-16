#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-54-0b-live-backend-staging-evidence"
SOURCE_JSON="$OUT_DIR/live_backend_staging_source_verification.json"
MANIFEST_JSON="$OUT_DIR/live_backend_staging_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/live_backend_staging_screenshot_verification.json"
JSON_OUT="$OUT_DIR/live_backend_staging_evidence_report.json"
MD_OUT="$OUT_DIR/live_backend_staging_evidence_report.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

STATUS="pass"
FAILURES=()
EVIDENCE=()

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  printf '%s' "$s"
}

json_array() {
  if [ "$#" -eq 0 ]; then
    printf '[]'
    return
  fi
  local first=1
  printf '['
  for item in "$@"; do
    if [ "$first" -eq 0 ]; then
      printf ', '
    fi
    first=0
    printf '"%s"' "$(json_escape "$item")"
  done
  printf ']'
}

record_pass() {
  EVIDENCE+=("$1")
}

record_fail() {
  STATUS="fail"
  FAILURES+=("$1")
}

require_report_status() {
  local file="$1"
  local label="$2"
  if [ -s "$file" ] && rg -q '"status": "pass"' "$file"; then
    record_pass "$label: pass"
  else
    record_fail "$label: missing or failed"
  fi
}

require_source() {
  local value="$1"
  local label="$2"
  if rg -q --fixed-strings -- "$value" HighFive docs/production_services; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

require_report_status "$SOURCE_JSON" "source verifier"
require_report_status "$MANIFEST_JSON" "screenshot harness"
require_report_status "$SCREENSHOT_VERIFY_JSON" "screenshot verifier"

require_source "HFBackendHealth" "backend health evidence exists"
require_source "HIGHFIVE_BACKEND_BASE_URL" "runtime config evidence exists"
require_source "guard configuration.hasCompleteRuntimeConfig" "config-gated remote health evidence exists"
require_source "guard backendConfiguration.hasAnyRuntimeConfig" "Local Mode fallback evidence exists"
require_source "guard backendConfiguration.hasCompleteRuntimeConfig" "Missing Credentials evidence exists"
require_source ".backendConfigured" "Backend Configured evidence exists"
require_source ".stagingReachable" "Staging Reachable evidence exists"
require_source ".stagingUnavailable" "Staging Unavailable evidence exists"
require_source "--hf-start-backend-status" "backend status route evidence exists"
require_source "hf.home.backendStatus" "Home backend UI evidence exists"
require_source "hf.profile.backendServices" "Profile backend UI evidence exists"
require_source "hf.creatorStudio.backendStatus" "Creator backend UI evidence exists"

PROTECTED_HITS="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
if [ -n "$PROTECTED_HITS" ]; then
  record_fail "protected path scan hit: $PROTECTED_HITS"
else
  record_pass "protected path scan clean"
fi

SECRET_PATTERN="(sk_""live|pk_""live|client_""secret[[:space:]]*[:=]|access_""token[[:space:]]*[:=]|refresh_""token[[:space:]]*[:=]|password[[:space:]]*[:=]|Bearer [A-Za-z0-9])"
SECRET_HITS="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' | rg -n "$SECRET_PATTERN" || true)"
if [ -n "$SECRET_HITS" ]; then
  record_fail "secret scan hit: $SECRET_HITS"
else
  record_pass "secret scan clean"
fi

PROVIDER_PATTERN="(Fire""base|Cloud""Kit|CK""Container|Revenue""Cat|Str""ipe|Cl""erk|Auth""0|Meta""SDK|Facebook""Core|Tik""Tok|You""Tube|One""Signal|Post""Hog|Mix""panel|Send""bird|Stream""Chat)"
PROVIDER_HITS="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "$PROVIDER_PATTERN" || true)"
if [ -n "$PROVIDER_HITS" ]; then
  record_fail "provider SDK scan hit: $PROVIDER_HITS"
else
  record_pass "provider SDK scan clean"
fi

URLSESSION_DIFF_HITS="$(git diff -U0 -- '*.swift' | rg -n '^\+.*URLSession' || true)"
if [ -n "$URLSESSION_DIFF_HITS" ]; then
  record_fail "URLSession diff hit in evidence lock: $URLSESSION_DIFF_HITS"
else
  record_pass "URLSession diff scan clean"
fi

URLSESSION_SOURCE_HITS="$(rg -n "URLSession" HighFive || true)"
URLSESSION_BAD_SOURCE="$(printf '%s\n' "$URLSESSION_SOURCE_HITS" | rg -v '^HighFive/Services/Backend/HFRemoteBackendGateway.swift:' || true)"
if [ -n "$URLSESSION_SOURCE_HITS" ] && [ -z "$URLSESSION_BAD_SOURCE" ]; then
  record_pass "URLSession source location limited to HighFive/Services/Backend/HFRemoteBackendGateway.swift"
else
  record_fail "URLSession source location invalid: $URLSESSION_SOURCE_HITS"
fi

URL_PATTERN="http""s?://"
URL_HITS="$(git diff -U0 -- '*.swift' '*.md' '*.json' '*.sh' | rg -n "$URL_PATTERN" || true)"
if [ -n "$URL_HITS" ]; then
  record_fail "URL scan hit: $URL_HITS"
else
  record_pass "URL scan clean"
fi

SCREENSHOT_PATHS=(
  "$OUT_DIR/screenshots/backend_status_local.png"
  "$OUT_DIR/screenshots/profile_backend_services.png"
  "$OUT_DIR/screenshots/creator_backend_readiness.png"
  "$OUT_DIR/screenshots/home_backend_status.png"
)

for path in "${SCREENSHOT_PATHS[@]}"; do
  if [ -s "$path" ]; then
    record_pass "screenshot captured: $path"
  else
    record_fail "screenshot missing or empty: $path"
  fi
done

KNOWN_LIMITATIONS=(
  "evidence only"
  "staging health connection only"
  "app stays Local Mode unless runtime config is provided"
  "no committed secrets"
  "no hardcoded production URLs"
  "no live auth"
  "no live cloud sync"
  "no live remote streaming playback"
  "no live media downloads"
  "no live payments"
  "no live Instagram/Meta posting"
  "no live VOD publishing"
  "no App Store production configuration"
)

if [ "${#EVIDENCE[@]}" -eq 0 ]; then
  EVIDENCE_JSON="[]"
else
  EVIDENCE_JSON="$(json_array "${EVIDENCE[@]}")"
fi

if [ "${#FAILURES[@]}" -eq 0 ]; then
  FAILURES_JSON="[]"
else
  FAILURES_JSON="$(json_array "${FAILURES[@]}")"
fi

SCREENSHOT_PATHS_JSON="$(json_array "${SCREENSHOT_PATHS[@]}")"
KNOWN_LIMITATIONS_JSON="$(json_array "${KNOWN_LIMITATIONS[@]}")"

cat > "$JSON_OUT" <<JSON
{
  "upgrade": "#054.0B",
  "status": "$STATUS",
  "baseline_commit": "$(json_escape "$(git rev-parse --short HEAD)")",
  "baseline_tag": "phase-54-0a-live-backend-staging-connection",
  "source_verifier_status": "$(if [ -s "$SOURCE_JSON" ] && rg -q '"status": "pass"' "$SOURCE_JSON"; then printf pass; else printf fail; fi)",
  "screenshot_harness_status": "$(if [ -s "$MANIFEST_JSON" ] && rg -q '"status": "pass"' "$MANIFEST_JSON"; then printf pass; else printf fail; fi)",
  "screenshot_verifier_status": "$(if [ -s "$SCREENSHOT_VERIFY_JSON" ] && rg -q '"status": "pass"' "$SCREENSHOT_VERIFY_JSON"; then printf pass; else printf fail; fi)",
  "evidence": $EVIDENCE_JSON,
  "failures": $FAILURES_JSON,
  "screenshots": $SCREENSHOT_PATHS_JSON,
  "known_limitations": $KNOWN_LIMITATIONS_JSON
}
JSON

{
  echo "# Live Backend Staging Evidence Report"
  echo
  echo "- Upgrade: #054.0B"
  echo "- Status: $STATUS"
  echo "- Baseline: $(git rev-parse --short HEAD) phase-54-0a-live-backend-staging-connection"
  echo "- Source verifier: $(if [ -s "$SOURCE_JSON" ] && rg -q '"status": "pass"' "$SOURCE_JSON"; then printf pass; else printf fail; fi)"
  echo "- Screenshot harness: $(if [ -s "$MANIFEST_JSON" ] && rg -q '"status": "pass"' "$MANIFEST_JSON"; then printf pass; else printf fail; fi)"
  echo "- Screenshot verifier: $(if [ -s "$SCREENSHOT_VERIFY_JSON" ] && rg -q '"status": "pass"' "$SCREENSHOT_VERIFY_JSON"; then printf pass; else printf fail; fi)"
  echo
  echo "## Evidence"
  for item in "${EVIDENCE[@]}"; do
    echo "- PASS: $item"
  done
  echo
  echo "## Screenshots"
  for item in "${SCREENSHOT_PATHS[@]}"; do
    echo "- $item"
  done
  echo
  echo "## Known Limitations"
  for item in "${KNOWN_LIMITATIONS[@]}"; do
    echo "- $item"
  done
  echo
  echo "## Failures"
  if [ "${#FAILURES[@]}" -eq 0 ]; then
    echo "- None"
  else
    for item in "${FAILURES[@]}"; do
      echo "- FAIL: $item"
    done
  fi
} > "$MD_OUT"

echo "evidence report: $STATUS"
echo "$JSON_OUT"
echo "$MD_OUT"

[ "$STATUS" = "pass" ]
