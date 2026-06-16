#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-54-0b-live-backend-staging-evidence"
JSON_OUT="$OUT_DIR/live_backend_staging_source_verification.json"
MD_OUT="$OUT_DIR/live_backend_staging_source_verification.md"

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

require_pattern() {
  local pattern="$1"
  local scope="$2"
  local label="$3"
  if rg -q -- "$pattern" $scope; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

require_literal() {
  local value="$1"
  local scope="$2"
  local label="$3"
  if rg -q --fixed-strings -- "$value" $scope; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

SOURCE_SCOPE="HighFive docs/production_services"

for value in \
  "HFRemoteBackendGateway" \
  "health()" \
  "HFBackendHealth" \
  "HFBackendConnectionState" \
  "localMode" \
  "missingCredentials" \
  "backendConfigured" \
  "stagingReachable" \
  "stagingUnavailable" \
  "HFBackendRuntimeStatus" \
  "refreshBackendRuntimeStatus" \
  "backendRuntimeStatus" \
  "backendHealthSummary" \
  "backendRuntimeConfigRows" \
  "backendLocalFallbackNote"; do
  require_literal "$value" "$SOURCE_SCOPE" "source contains $value"
done

for value in \
  "HIGHFIVE_BACKEND_MODE" \
  "HIGHFIVE_BACKEND_BASE_URL" \
  "HIGHFIVE_SUPABASE_PROJECT_URL" \
  "HIGHFIVE_SUPABASE_ANON_KEY"; do
  require_literal "$value" "$SOURCE_SCOPE" "runtime config name exists: $value"
done

for value in \
  "--hf-start-backend-status" \
  "Backend Status" \
  "Runtime Config" \
  "Health Check" \
  "Local fallback active" \
  "No secrets stored in app"; do
  require_literal "$value" "$SOURCE_SCOPE" "backend status route/copy exists: $value"
done

for value in \
  "hf.backendStatus.screen" \
  "hf.backendStatus.health" \
  "hf.backendStatus.runtimeConfig" \
  "hf.backendStatus.serviceList" \
  "hf.backendStatus.localFallback" \
  "hf.backendStatus.noSecrets" \
  "hf.backend.status" \
  "hf.backend.localMode" \
  "hf.backend.notConnected" \
  "hf.backend.configured" \
  "hf.backend.credentialsMissing" \
  "hf.backend.stagingReachable" \
  "hf.backend.stagingUnavailable" \
  "hf.backend.providerReady" \
  "hf.home.backendStatus" \
  "hf.profile.backendServices" \
  "hf.creatorStudio.backendStatus" \
  "hf.creatorStudio.socialBackendStatus" \
  "hf.creatorStudio.vodBackendStatus"; do
  require_literal "$value" "$SOURCE_SCOPE" "UI identifier exists: $value"
done

require_literal "hasAnyRuntimeConfig ? .missingCredentials : .localMode" "HighFive/Services/Backend/HFBackendConfiguration.swift" "missing config falls back to Local Mode while partial config is Missing Credentials"
require_literal "if hasCompleteRuntimeConfig" "HighFive/Services/Backend/HFBackendConfiguration.swift" "complete runtime config reaches Backend Configured state"
require_literal "return .backendConfigured" "HighFive/Services/Backend/HFBackendConfiguration.swift" "Backend Configured state is returned from runtime config"
require_literal "guard configuration.hasCompleteRuntimeConfig" "HighFive/Services/Backend/HFRemoteBackendGateway.swift" "remote health call is gated by complete runtime config"
require_literal "URLSession.shared.data" "HighFive/Services/Backend/HFRemoteBackendGateway.swift" "staging health check uses URLSession in remote gateway"
require_literal "guard backendConfiguration.hasAnyRuntimeConfig" "HighFive/Data/HFStreamingStore.swift" "missing runtime config skips network and stays Local Mode"
require_literal "guard backendConfiguration.hasCompleteRuntimeConfig" "HighFive/Data/HFStreamingStore.swift" "partial runtime config skips network and reports Missing Credentials"
require_literal "backendGateway.health()" "HighFive/Data/HFStreamingStore.swift" "complete runtime config enables health check"
require_literal "backendRuntimeStatus = backendService.currentStatus(for: .stagingReachable)" "HighFive/Data/HFStreamingStore.swift" "successful health updates Staging Reachable"
require_literal "backendRuntimeStatus = backendService.currentStatus(for: .stagingUnavailable)" "HighFive/Data/HFStreamingStore.swift" "failed health updates Staging Unavailable"
require_literal "No production service claim is made" "HighFive/Services/Backend/HFRemoteBackendGateway.swift" "remote gateway avoids production backend claim"

URLSESSION_HITS="$(rg -n "URLSession" HighFive || true)"
if [ -n "$URLSESSION_HITS" ]; then
  BAD_URLSESSION="$(printf '%s\n' "$URLSESSION_HITS" | rg -v '^HighFive/Services/Backend/HFRemoteBackendGateway.swift:' || true)"
  if [ -n "$BAD_URLSESSION" ]; then
    record_fail "URLSession appears outside HighFive/Services/Backend/HFRemoteBackendGateway.swift: $BAD_URLSESSION"
  else
    record_pass "URLSession appears only in HighFive/Services/Backend/HFRemoteBackendGateway.swift"
  fi
else
  record_fail "URLSession evidence missing"
fi

SECRET_PATTERN="(sk_""live|pk_""live|client_""secret[[:space:]]*[:=]|access_""token[[:space:]]*[:=]|refresh_""token[[:space:]]*[:=]|password[[:space:]]*[:=]|Bearer [A-Za-z0-9])"
SECRET_HITS="$(rg -n "$SECRET_PATTERN" HighFive docs/production_services scripts || true)"
if [ -n "$SECRET_HITS" ]; then
  record_fail "secret-like source hit: $SECRET_HITS"
else
  record_pass "no committed secret-like source hits"
fi

LIVE_STAGING_SCOPE=(
  "HighFive/Services/Backend"
  "HighFive/Data/HFStreamingStore.swift"
  "HighFive/App/HFStreamingRootView.swift"
  "HighFive/Views/Home/HomeView.swift"
  "HighFive/Views/Profile/ProfileView.swift"
  "HighFive/Views/Profile/HFBackendStatusPanel.swift"
  "HighFive/Views/Creator/CreatorStudioView.swift"
)

URL_PATTERN="http""s?://"
URL_HITS="$(rg -n "$URL_PATTERN" "${LIVE_STAGING_SCOPE[@]}" || true)"
if [ -n "$URL_HITS" ]; then
  record_fail "hardcoded URL source hit: $URL_HITS"
else
  record_pass "no hardcoded URL source hits"
fi

PROVIDER_PATTERN="(Fire""base|Cloud""Kit|CK""Container|Revenue""Cat|Str""ipe|Cl""erk|Auth""0|Meta""SDK|Facebook""Core|Tik""Tok|You""Tube|One""Signal|Post""Hog|Mix""panel|Send""bird|Stream""Chat)"
PROVIDER_HITS="$(rg -n "import[[:space:]]+$PROVIDER_PATTERN|CK""Container|Fire""baseApp|Supabase""Client|Stream""Chat" "${LIVE_STAGING_SCOPE[@]}" || true)"
if [ -n "$PROVIDER_HITS" ]; then
  record_fail "provider SDK source hit: $PROVIDER_HITS"
else
  record_pass "no provider SDK source hits"
fi

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

cat > "$JSON_OUT" <<JSON
{
  "upgrade": "#054.0B",
  "status": "$STATUS",
  "baseline_commit": "$(json_escape "$(git rev-parse --short HEAD)")",
  "baseline_tag": "phase-54-0a-live-backend-staging-connection",
  "evidence": $EVIDENCE_JSON,
  "failures": $FAILURES_JSON
}
JSON

{
  echo "# Live Backend Staging Source Verification"
  echo
  echo "- Upgrade: #054.0B"
  echo "- Status: $STATUS"
  echo "- Baseline: $(git rev-parse --short HEAD) phase-54-0a-live-backend-staging-connection"
  echo
  echo "## Evidence"
  for item in "${EVIDENCE[@]}"; do
    echo "- PASS: $item"
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

echo "source verification: $STATUS"
echo "$JSON_OUT"
echo "$MD_OUT"

[ "$STATUS" = "pass" ]
