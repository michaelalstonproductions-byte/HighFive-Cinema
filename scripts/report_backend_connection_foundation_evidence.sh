#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-53-0b-backend-foundation-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
SOURCE_JSON="$OUT_DIR/backend_connection_foundation_source_verification.json"
SCREENSHOT_MANIFEST="$OUT_DIR/backend_connection_foundation_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/backend_connection_foundation_screenshot_verification.json"
JSON_OUT="$OUT_DIR/backend_connection_foundation_evidence_report.json"
MD_OUT="$OUT_DIR/backend_connection_foundation_evidence_report.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_STATUS="missing"
SCREENSHOT_STATUS="missing"
SCREENSHOT_VERIFY_STATUS="missing"

if [[ -s "$SOURCE_JSON" ]] && rg -q '"status": "pass"' "$SOURCE_JSON"; then
  SOURCE_STATUS="pass"
fi
if [[ -s "$SCREENSHOT_MANIFEST" ]] && rg -q '"status": "pass"' "$SCREENSHOT_MANIFEST"; then
  SCREENSHOT_STATUS="pass"
fi
if [[ -s "$SCREENSHOT_VERIFY_JSON" ]] && rg -q '"status": "pass"' "$SCREENSHOT_VERIFY_JSON"; then
  SCREENSHOT_VERIFY_STATUS="pass"
fi

PROTECTED_PATTERN='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'
SECRET_PATTERN="(sk_""live|pk_""live|client_""secret[[:space:]]*[:=]|access_""token[[:space:]]*[:=]|refresh_""token[[:space:]]*[:=]|password[[:space:]]*[:=]|Bearer [A-Za-z0-9])"
PROVIDER_PATTERN="(Fire""base|Cloud""Kit|CK""Container|Revenue""Cat|Str""ipe|Cl""erk|Auth""0|Meta""SDK|Facebook""Core|Tik""Tok|You""Tube|One""Signal|Post""Hog|Mix""panel|Send""bird|Stream""Chat)"
URL_PATTERN="http""s?://"

PROTECTED_SCAN="clean"
SECRET_SCAN="clean"
PROVIDER_SCAN="clean"
URL_SCAN="clean"

if git diff --name-only | rg -q "$PROTECTED_PATTERN"; then
  PROTECTED_SCAN="hits"
fi
if git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' | rg -q "^\+.*$SECRET_PATTERN"; then
  SECRET_SCAN="hits"
fi
if git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q "^\+.*$PROVIDER_PATTERN"; then
  PROVIDER_SCAN="hits"
fi
if git diff -U0 -- '*.swift' '*.md' '*.json' '*.sh' | rg -q "^\+.*$URL_PATTERN"; then
  URL_SCAN="hits"
fi

OVERALL_STATUS="pass"
if [[ "$SOURCE_STATUS" != "pass" || "$SCREENSHOT_STATUS" != "pass" || "$SCREENSHOT_VERIFY_STATUS" != "pass" || "$PROTECTED_SCAN" != "clean" || "$SECRET_SCAN" != "clean" || "$PROVIDER_SCAN" != "clean" || "$URL_SCAN" != "clean" ]]; then
  OVERALL_STATUS="fail"
fi

HOME_SHOT="$SCREENSHOT_DIR/home_backend.png"
PROFILE_SHOT="$SCREENSHOT_DIR/profile_backend.png"
CREATOR_SHOT="$SCREENSHOT_DIR/creator_backend.png"

cat > "$JSON_OUT" <<JSON
{
  "upgrade": "#053.0B",
  "status": "$OVERALL_STATUS",
  "baseline_commit": "9f23185",
  "baseline_tag": "phase-53-0a-backend-connection-foundation-import",
  "source_verifier_status": "$SOURCE_STATUS",
  "screenshot_harness_status": "$SCREENSHOT_STATUS",
  "screenshot_verifier_status": "$SCREENSHOT_VERIFY_STATUS",
  "backend_config_evidence": "Runtime config names are source-verified and placeholder-only.",
  "local_gateway_evidence": "Local gateway and Local Mode fallback are source-verified.",
  "remote_gateway_config_gated_evidence": "Remote gateway creation is gated by complete runtime config.",
  "backend_health_evidence": "HFBackendHealth and gateway health methods are source-verified.",
  "service_boundary_evidence": "Auth, catalog, library, downloads, entitlements, creator, Instagram readiness, communication, notifications, and analytics allowlist boundaries are source-verified.",
  "runtime_config_evidence": "HIGHFIVE runtime variable names are present without committed credential values.",
  "ui_evidence": "Home, Profile, and Creator backend UI routes were screenshot-captured.",
  "local_mode_fallback_evidence": "Missing config remains Local Mode.",
  "missing_credentials_evidence": "Missing Credentials copy and state are source-verified.",
  "protected_path_scan": "$PROTECTED_SCAN",
  "secret_scan": "$SECRET_SCAN",
  "provider_sdk_scan": "$PROVIDER_SCAN",
  "url_scan": "$URL_SCAN",
  "screenshots": [
    "$HOME_SHOT",
    "$PROFILE_SHOT",
    "$CREATOR_SHOT"
  ],
  "known_limitations": [
    "Evidence only.",
    "Backend foundation only.",
    "App stays Local Mode unless runtime config is provided.",
    "No committed secrets.",
    "No hardcoded production URLs.",
    "No live auth.",
    "No live cloud sync.",
    "No live remote streaming.",
    "No live media downloads.",
    "No live payments.",
    "No live Instagram or Meta posting.",
    "No live VOD publishing.",
    "No App Store production configuration."
  ]
}
JSON

{
  echo "# Backend Connection Foundation Evidence Report"
  echo
  echo "- Upgrade: #053.0B"
  echo "- Status: $OVERALL_STATUS"
  echo "- Baseline: 9f23185 / phase-53-0a-backend-connection-foundation-import"
  echo "- Source verifier: $SOURCE_STATUS"
  echo "- Screenshot harness: $SCREENSHOT_STATUS"
  echo "- Screenshot verifier: $SCREENSHOT_VERIFY_STATUS"
  echo
  echo "## Evidence"
  echo "- Backend config: runtime config names are source-verified and placeholder-only."
  echo "- Local gateway: Local Mode fallback is source-verified."
  echo "- Remote gateway: config-gated by complete runtime config."
  echo "- Backend health: HFBackendHealth and gateway health methods are source-verified."
  echo "- Service boundaries: auth, catalog, library, downloads, entitlements, creator, Instagram readiness, communication, notifications, and analytics allowlist are source-verified."
  echo "- UI: Home, Profile, and Creator backend status surfaces were captured."
  echo "- Missing Credentials: state and copy are source-verified."
  echo
  echo "## Scans"
  echo "- Protected path scan: $PROTECTED_SCAN"
  echo "- Secret scan: $SECRET_SCAN"
  echo "- Provider SDK scan: $PROVIDER_SCAN"
  echo "- URL scan: $URL_SCAN"
  echo
  echo "## Screenshots"
  echo "- $HOME_SHOT"
  echo "- $PROFILE_SHOT"
  echo "- $CREATOR_SHOT"
  echo
  echo "## Known Limitations"
  echo "- Evidence only."
  echo "- Backend foundation only."
  echo "- App stays Local Mode unless runtime config is provided."
  echo "- No committed secrets."
  echo "- No hardcoded production URLs."
  echo "- No live auth, cloud sync, remote streaming, media downloads, payments, Instagram/Meta posting, VOD publishing, or App Store production configuration."
} > "$MD_OUT"

if [[ "$OVERALL_STATUS" != "pass" ]]; then
  cat "$MD_OUT"
  exit 1
fi

cat "$MD_OUT"
