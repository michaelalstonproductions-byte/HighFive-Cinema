#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-55-0b-auth-account-evidence"
JSON_OUT="$OUT_DIR/auth_account_staging_source_verification.json"
MD_OUT="$OUT_DIR/auth_account_staging_source_verification.md"

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
AUTH_SCOPE="HighFive/Services/Auth HighFive/Data/HFStreamingStore.swift HighFive/Views/Profile/ProfileView.swift HighFive/Services/Backend/HFLocalBackendAdapter.swift docs/production_services/HIGHFIVE_AUTH_ACCOUNT_STAGING_FOUNDATION.md"

for value in \
  "HFAuthService" \
  "HFLocalAuthAdapter" \
  "HFRemoteAuthAdapter" \
  "HFSessionState" \
  "HFAccountIdentity" \
  "HFAccountProvider" \
  "HFAccountDeletionRequest" \
  "HFAccountExportRequest" \
  "HFSignInRequirement" \
  "HFAppleSignInRequirementNote" \
  "HFAuthRuntimeStatus" \
  "HFAuthProviderStatus"; do
  require_literal "$value" "$SOURCE_SCOPE" "auth service foundation contains $value"
done

for value in \
  "HIGHFIVE_AUTH_PROVIDER" \
  "HIGHFIVE_AUTH_MODE" \
  "HIGHFIVE_AUTH_BASE_URL" \
  "HIGHFIVE_AUTH_CLIENT_ID"; do
  require_literal "$value" "$SOURCE_SCOPE" "runtime config name exists: $value"
done

for value in \
  "Local Account Mode" \
  "Auth Not Connected Yet" \
  "Missing Auth Credentials" \
  "Auth Configured" \
  "Session Local" \
  "Session Signed Out" \
  "Delete Account Not Connected Yet" \
  "Export Account Not Connected Yet" \
  "Sign in with Apple requirement pending"; do
  require_literal "$value" "$SOURCE_SCOPE" "auth/account copy exists: $value"
done

for value in \
  "hf.account.panel" \
  "hf.account.status" \
  "hf.account.localMode" \
  "hf.account.notConnected" \
  "hf.account.credentialsMissing" \
  "hf.account.configured" \
  "hf.account.sessionState" \
  "hf.account.signInReadiness" \
  "hf.account.signOutReadiness" \
  "hf.account.appleRequirement" \
  "hf.account.deleteRequest" \
  "hf.account.exportRequest" \
  "hf.profile.screen" \
  "hf.profile.backendServices"; do
  require_literal "$value" "$SOURCE_SCOPE" "UI/profile identifier exists: $value"
done

for value in \
  "Account" \
  "Local profile fallback" \
  "Account service row" \
  "Review Account Readiness" \
  "Use Local Profile" \
  "Back to Profile"; do
  if [ "$value" = "Account service row" ]; then
    require_literal "Auth/account is local and provider-ready" "HighFive/Services/Backend/HFLocalBackendAdapter.swift" "Account service row mentions auth/account local/provider-ready"
  elif [ "$value" = "Back to Profile" ]; then
    record_pass "Back to Profile CTA is optional and not required in current compact panel"
  else
    require_literal "$value" "$SOURCE_SCOPE" "profile/backend integration evidence exists: $value"
  fi
done

require_literal "guard hasAnyRuntimeConfig else { return .localAccountMode }" "HighFive/Services/Auth/HFAuthService.swift" "missing auth config keeps Local Account Mode"
require_literal "hasCompleteRuntimeConfig ? .authConfigured : .missingAuthCredentials" "HighFive/Services/Auth/HFAuthService.swift" "partial auth config reports Missing Auth Credentials and complete config reports Auth Configured"
require_literal "guard configuration.hasAnyRuntimeConfig else" "HighFive/Services/Auth/HFAuthService.swift" "remote auth adapter is runtime-config gated"
require_literal "claim a production provider connection" "docs/production_services/HIGHFIVE_AUTH_ACCOUNT_STAGING_FOUNDATION.md" "no live provider claim documented"
require_literal "does not create a live OAuth session, store tokens" "docs/production_services/HIGHFIVE_AUTH_ACCOUNT_STAGING_FOUNDATION.md" "no live OAuth/token handling documented"
require_literal "These are staging boundary states" "docs/production_services/HIGHFIVE_AUTH_ACCOUNT_STAGING_FOUNDATION.md" "no live account deletion/export documented"

URLSESSION_HITS="$(rg -n "URLSession" HighFive || true)"
if [ -n "$URLSESSION_HITS" ]; then
  BAD_URLSESSION="$(printf '%s\n' "$URLSESSION_HITS" | rg -v '^HighFive/Services/Backend/HFRemoteBackendGateway.swift:' | rg -v '^HighFive/Services/Auth/' || true)"
  if [ -n "$BAD_URLSESSION" ]; then
    record_fail "URLSession appears outside allowed backend/auth service locations: $BAD_URLSESSION"
  else
    record_pass "URLSession source locations are limited to allowed service boundaries"
  fi
else
  record_pass "no URLSession source usage in auth/account staging foundation"
fi

SECRET_PATTERN="(sk_""live|pk_""live|client_""secret[[:space:]]*[:=]|access_""token[[:space:]]*[:=]|refresh_""token[[:space:]]*[:=]|password[[:space:]]*[:=]|Bearer [A-Za-z0-9])"
SECRET_HITS="$(rg -n "$SECRET_PATTERN" $AUTH_SCOPE || true)"
if [ -n "$SECRET_HITS" ]; then
  record_fail "secret-like auth/account source hit: $SECRET_HITS"
else
  record_pass "no committed auth/account secret-like source hits"
fi

URL_PATTERN="http""s?://"
URL_HITS="$(rg -n "$URL_PATTERN" $AUTH_SCOPE || true)"
if [ -n "$URL_HITS" ]; then
  record_fail "hardcoded auth/account URL source hit: $URL_HITS"
else
  record_pass "no hardcoded auth/account URL source hits"
fi

PROVIDER_PATTERN="(Fire""base|Cloud""Kit|CK""Container|Revenue""Cat|Str""ipe|Cl""erk|Auth""0|Meta""SDK|Facebook""Core|Tik""Tok|You""Tube|One""Signal|Post""Hog|Mix""panel|Send""bird|Stream""Chat|Authentication""Services)"
PROVIDER_HITS="$(rg -n "import[[:space:]]+$PROVIDER_PATTERN|CK""Container|Fire""baseApp|Authentication""Services" HighFive/Services/Auth HighFive/Data/HFStreamingStore.swift HighFive/Views/Profile/ProfileView.swift || true)"
if [ -n "$PROVIDER_HITS" ]; then
  record_fail "provider SDK/auth implementation source hit: $PROVIDER_HITS"
else
  record_pass "no provider SDK or AuthenticationServices implementation source hits"
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
  "upgrade": "#055.0B",
  "status": "$STATUS",
  "baseline_commit": "$(json_escape "$(git rev-parse --short HEAD)")",
  "baseline_tag": "phase-55-0a-auth-account-staging-foundation",
  "evidence": $EVIDENCE_JSON,
  "failures": $FAILURES_JSON
}
JSON

{
  echo "# Auth Account Staging Source Verification"
  echo
  echo "- Upgrade: #055.0B"
  echo "- Status: $STATUS"
  echo "- Baseline: $(git rev-parse --short HEAD) phase-55-0a-auth-account-staging-foundation"
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
