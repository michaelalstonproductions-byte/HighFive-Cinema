#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-53-0b-backend-foundation-evidence"
JSON_OUT="$OUT_DIR/backend_connection_foundation_source_verification.json"
MD_OUT="$OUT_DIR/backend_connection_foundation_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

STATUS="pass"
FAILURES=()
PASSES=()

record_pass() {
  PASSES+=("$1")
}

record_fail() {
  STATUS="fail"
  FAILURES+=("$1")
}

require_pattern() {
  local label="$1"
  local pattern="$2"
  shift 2
  if rg -q "$pattern" "$@"; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

require_absent() {
  local label="$1"
  local pattern="$2"
  shift 2
  if rg -q "$pattern" "$@"; then
    record_fail "$label"
  else
    record_pass "$label"
  fi
}

json_array() {
  local first=1
  printf '['
  for item in "$@"; do
    if [[ "$first" -eq 0 ]]; then
      printf ','
    fi
    first=0
    printf '"%s"' "$(printf '%s' "$item" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  done
  printf ']'
}

SOURCE_PATHS=(HighFive docs/production_services)

require_pattern "HFBackendConfiguration" "HFBackendConfiguration" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendConnectionState" "HFBackendConnectionState" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendRuntimeStatus" "HFBackendRuntimeStatus" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendServiceStatus" "HFBackendServiceStatus" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendGateway" "HFBackendGateway" "${SOURCE_PATHS[@]}"
require_pattern "HFLocalBackendGateway" "HFLocalBackendGateway" "${SOURCE_PATHS[@]}"
require_pattern "HFRemoteBackendGateway" "HFRemoteBackendGateway" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendGatewayFactory" "HFBackendGatewayFactory" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendHealth" "HFBackendHealth" "${SOURCE_PATHS[@]}"
require_pattern "HFBackendStatusPanel" "HFBackendStatusPanel" "${SOURCE_PATHS[@]}"

require_pattern "HFAuthService" "HFAuthService" "${SOURCE_PATHS[@]}"
require_pattern "HFCatalogService" "HFCatalogService" "${SOURCE_PATHS[@]}"
require_pattern "HFLibrarySyncService" "HFLibrarySyncService" "${SOURCE_PATHS[@]}"
require_pattern "HFDownloadEligibilityService" "HFDownloadEligibilityService" "${SOURCE_PATHS[@]}"
require_pattern "HFEntitlementService" "HFEntitlementService" "${SOURCE_PATHS[@]}"
require_pattern "HFCreatorStudioBackendFacade" "HFCreatorStudioBackendFacade" "${SOURCE_PATHS[@]}"
if [[ -s HighFive/Services/CreatorProviders/HFInstagramConnectModels.swift ]] &&
  rg -q "HFInstagramReadiness|HFInstagramConnectionState" HighFive/Services/CreatorProviders/HFInstagramConnectModels.swift; then
  record_pass "HFInstagramConnectModels"
else
  record_fail "HFInstagramConnectModels"
fi
require_pattern "HFCommunicationService" "HFCommunicationService" "${SOURCE_PATHS[@]}"
require_pattern "HFNotificationPreferenceService" "HFNotificationPreferenceService" "${SOURCE_PATHS[@]}"
require_pattern "HFAnalyticsAllowlist" "HFAnalyticsAllowlist" "${SOURCE_PATHS[@]}"

require_pattern "HIGHFIVE_BACKEND_MODE" "HIGHFIVE_BACKEND_MODE" "${SOURCE_PATHS[@]}"
require_pattern "HIGHFIVE_BACKEND_BASE_URL" "HIGHFIVE_BACKEND_BASE_URL" "${SOURCE_PATHS[@]}"
require_pattern "HIGHFIVE_SUPABASE_PROJECT_URL" "HIGHFIVE_SUPABASE_PROJECT_URL" "${SOURCE_PATHS[@]}"
require_pattern "HIGHFIVE_SUPABASE_ANON_KEY" "HIGHFIVE_SUPABASE_ANON_KEY" "${SOURCE_PATHS[@]}"

require_pattern "Local Mode copy" "Local Mode" "${SOURCE_PATHS[@]}"
require_pattern "Backend Not Connected Yet copy" "Backend Not Connected Yet" "${SOURCE_PATHS[@]}"
require_pattern "Missing Credentials copy" "Missing Credentials" "${SOURCE_PATHS[@]}"
require_pattern "Provider-ready copy" "Provider-ready" "${SOURCE_PATHS[@]}"
require_pattern "Backend Configured copy" "Backend Configured" "${SOURCE_PATHS[@]}"

require_pattern "hf.backend.status identifier" "hf\\.backend\\.status" "${SOURCE_PATHS[@]}"
require_pattern "hf.backend.localMode identifier" "hf\\.backend\\.localMode" "${SOURCE_PATHS[@]}"
require_pattern "hf.backend.notConnected identifier" "hf\\.backend\\.notConnected" "${SOURCE_PATHS[@]}"
require_pattern "hf.backend.configured identifier" "hf\\.backend\\.configured" "${SOURCE_PATHS[@]}"
require_pattern "hf.backend.credentialsMissing identifier" "hf\\.backend\\.credentialsMissing" "${SOURCE_PATHS[@]}"
require_pattern "hf.backend.providerReady identifier" "hf\\.backend\\.providerReady" "${SOURCE_PATHS[@]}"
require_pattern "hf.home.backendStatus identifier" "hf\\.home\\.backendStatus" "${SOURCE_PATHS[@]}"
require_pattern "hf.profile.backendServices identifier" "hf\\.profile\\.backendServices" "${SOURCE_PATHS[@]}"
require_pattern "hf.creatorStudio.backendStatus identifier" "hf\\.creatorStudio\\.backendStatus" "${SOURCE_PATHS[@]}"
require_pattern "hf.creatorStudio.socialBackendStatus identifier" "hf\\.creatorStudio\\.socialBackendStatus" "${SOURCE_PATHS[@]}"
require_pattern "hf.creatorStudio.vodBackendStatus identifier" "hf\\.creatorStudio\\.vodBackendStatus" "${SOURCE_PATHS[@]}"

require_pattern "Remote gateway config-gated by complete runtime config" "hasCompleteRuntimeConfig \\? HFRemoteBackendGateway\\(configuration: configuration\\) : HFLocalBackendGateway\\(\\)" HighFive/Services/Backend/HFBackendGatewayFactory.swift
require_pattern "Missing config falls back to local mode" "return \\.local" HighFive/Services/Backend/HFBackendConfiguration.swift
require_pattern "Local mode creates local backend adapter" "return HFLocalBackendAdapter\\(configuration: configuration\\)" HighFive/Services/Backend/HFBackendService.swift
require_pattern "Backend health method exists" "func health\\(\\) async throws -> HFBackendHealth" HighFive/Services/Backend

require_absent "No committed runtime backend URL values" "HIGHFIVE_BACKEND_BASE_URL=.*[[:alnum:]]+\\.[[:alnum:]]+" docs/production_services/highfive_backend.env.example
require_absent "No committed Supabase project URL values" "HIGHFIVE_SUPABASE_PROJECT_URL=.*[[:alnum:]]+\\.[[:alnum:]]+" docs/production_services/highfive_backend.env.example
require_absent "No committed anon key values" "HIGHFIVE_SUPABASE_ANON_KEY=.+[[:alnum:]]" docs/production_services/highfive_backend.env.example

SECRET_PATTERN="(sk_""live|pk_""live|client_""secret[[:space:]]*[:=]|access_""token[[:space:]]*[:=]|refresh_""token[[:space:]]*[:=]|password[[:space:]]*[:=]|Bearer [A-Za-z0-9])"
PROVIDER_PATTERN="(Fire""base|Cloud""Kit|CK""Container|Revenue""Cat|Str""ipe|Cl""erk|Auth""0|Meta""SDK|Facebook""Core|Tik""Tok|You""Tube|One""Signal|Post""Hog|Mix""panel|Send""bird|Stream""Chat)"
URL_PATTERN="http""s?://"

require_absent "No committed secrets" "$SECRET_PATTERN" HighFive docs/production_services
require_absent "No provider SDK references" "$PROVIDER_PATTERN" HighFive/Services HighFive.xcodeproj/project.pbxproj
require_absent "No hardcoded production URLs" "$URL_PATTERN" HighFive docs/production_services

PASSES_JSON="$(json_array "${PASSES[@]}")"
if [[ "${#FAILURES[@]}" -eq 0 ]]; then
  FAILURES_JSON="[]"
else
  FAILURES_JSON="$(json_array "${FAILURES[@]}")"
fi

cat > "$JSON_OUT" <<JSON
{
  "upgrade": "#053.0B",
  "status": "$STATUS",
  "baseline_commit": "9f23185",
  "baseline_tag": "phase-53-0a-backend-connection-foundation-import",
  "evidence_type": "source",
  "passes": $PASSES_JSON,
  "failures": $FAILURES_JSON,
  "notes": [
    "Evidence only.",
    "Remote gateway is config-gated.",
    "Missing config remains Local Mode.",
    "No live backend claim is made by this verifier."
  ]
}
JSON

{
  echo "# Backend Connection Foundation Source Verification"
  echo
  echo "- Upgrade: #053.0B"
  echo "- Status: $STATUS"
  echo "- Baseline: 9f23185 / phase-53-0a-backend-connection-foundation-import"
  echo "- Output JSON: $JSON_OUT"
  echo
  echo "## Passes"
  for item in "${PASSES[@]}"; do
    echo "- $item"
  done
  echo
  echo "## Failures"
  if [[ "${#FAILURES[@]}" -eq 0 ]]; then
    echo "- None"
  else
    for item in "${FAILURES[@]}"; do
      echo "- $item"
    done
  fi
  echo
  echo "## Evidence Rules"
  echo "- Remote gateway is config-gated."
  echo "- Missing config keeps app in Local Mode."
  echo "- Runtime config names exist without committed real values."
  echo "- No committed secrets, provider SDKs, or hardcoded production URLs were found."
} > "$MD_OUT"

if [[ "$STATUS" != "pass" ]]; then
  cat "$MD_OUT"
  exit 1
fi

cat "$MD_OUT"
