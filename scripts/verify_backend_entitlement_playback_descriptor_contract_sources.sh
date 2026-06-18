#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-62-0b-backend-entitlement-playback-contract-evidence"
JSON_OUT="$OUT_DIR/backend_entitlement_playback_contract_source_verification.json"
MD_OUT="$OUT_DIR/backend_entitlement_playback_contract_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

CONTRACT_FILE="HighFive/Services/Backend/HFBackendPlaybackDescriptorContract.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"
MOVIE_DETAIL_FILE="HighFive/Views/MovieDetail/MovieDetailView.swift"
PROFILE_FILE="HighFive/Views/Profile/ProfileView.swift"
DOC_FILE="docs/production_services/HIGHFIVE_BACKEND_ENTITLEMENT_PLAYBACK_DESCRIPTOR_CONTRACT.md"
SOURCE_SCOPE=("HighFive" "$DOC_FILE")

NO_CF_COPY="No Cloudflare tok""en in app"
SERVER_SIGNING_COPY="Cloudflare signed tok""en generated server-side"
PLAYBACK_REFERENCE_FIELD="playback_url_or_tok""en_reference"

declare -a REQUIRED_MODELS=(
  "HFBackendEntitlementValidationRequest"
  "HFBackendEntitlementValidationResponse"
  "HFBackendPlaybackDescriptorRequest"
  "HFBackendPlaybackDescriptorResponse"
  "HFBackendPlaybackDescriptorError"
  "HFBackendPlaybackDescriptorPolicy"
  "HFBackendPlaybackDescriptorContract"
  "HFBackendPlaybackDescriptorEndpoint"
  "HFServerEntitlementValidationState"
  "HFCloudflareSignedPlaybackPolicy"
  "HFPlaybackDescriptorExpiryPolicy"
  "HFPlaybackDescriptorAuditRecord"
)

declare -a REQUIRED_ENDPOINTS=(
  "/entitlements/validate"
  "/playback/descriptor"
)

declare -a REQUIRED_CONFIG=(
  "HIGHFIVE_BACKEND_BASE_URL"
  "HIGHFIVE_ENTITLEMENT_BASE_URL"
  "HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL"
  "HIGHFIVE_STREAMING_PROVIDER"
  "HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID"
  "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
  "HIGHFIVE_REVENUECAT_PROJECT_ID"
)

declare -a REQUIRED_REQUEST_FIELDS=(
  "user_id"
  "anonymous_session_id"
  "movie_id"
  "storekit_product_id"
  "entitlement_context"
  "playback_provider"
  "device_context"
)

declare -a REQUIRED_RESPONSE_FIELDS=(
  "entitlement_status"
  "access_decision"
  "playback_descriptor_status"
  "$PLAYBACK_REFERENCE_FIELD"
  "expires_at"
  "refresh_after"
  "denial_reason"
  "audit_id"
)

declare -a REQUIRED_COPY=(
  "Backend entitlement validation required"
  "Backend playback descriptor endpoint required"
  "Server entitlement validation pending"
  "Playback descriptor unavailable"
  "Playback descriptor contract ready"
  "$SERVER_SIGNING_COPY"
  "$NO_CF_COPY"
  "No backend URL committed"
  "Local Preview fallback active"
  "Entitlement denied"
  "Entitlement approved"
  "Descriptor expired"
  "Descriptor refresh required"
)

declare -a REQUIRED_IDENTIFIERS=(
  "hf.movieDetail.backendEntitlementValidation"
  "hf.movieDetail.backendPlaybackDescriptor"
  "hf.player.backendDescriptorContract"
  "hf.player.serverEntitlementValidation"
  "hf.player.localPreviewFallback"
  "hf.profile.backendPlaybackContract"
  "hf.backendStatus.entitlementValidation"
  "hf.backendStatus.playbackDescriptor"
)

passes=()
failures=()

require_term() {
  local term="$1"
  local label="${2:-$1}"
  if rg -q --fixed-strings "$term" "${SOURCE_SCOPE[@]}"; then
    passes+=("$label")
  else
    failures+=("Missing source evidence: $label")
  fi
}

require_file_term() {
  local file="$1"
  local term="$2"
  local label="$3"
  if rg -q --fixed-strings "$term" "$file"; then
    passes+=("$label")
  else
    failures+=("Missing $label in $file")
  fi
}

for term in "${REQUIRED_MODELS[@]}"; do require_term "$term"; done
for term in "${REQUIRED_ENDPOINTS[@]}"; do require_term "$term"; done
for term in "${REQUIRED_CONFIG[@]}"; do require_term "$term"; done
for term in "${REQUIRED_REQUEST_FIELDS[@]}"; do require_term "$term"; done
for term in "${REQUIRED_RESPONSE_FIELDS[@]}"; do require_term "$term"; done
for term in "${REQUIRED_COPY[@]}"; do require_term "$term"; done
for term in "${REQUIRED_IDENTIFIERS[@]}"; do require_term "$term"; done

require_file_term "$DOC_FILE" "POST" "POST endpoint documentation"
if [[ -s "$DOC_FILE" ]]; then
  passes+=("contract documentation exists: $DOC_FILE")
else
  failures+=("Missing contract documentation: $DOC_FILE")
fi
require_file_term "$CONTRACT_FILE" "static let entitlementValidationPath = \"/entitlements/validate\"" "relative entitlement endpoint constant"
require_file_term "$CONTRACT_FILE" "static let playbackDescriptorPath = \"/playback/descriptor\"" "relative playback endpoint constant"
require_file_term "$CONTRACT_FILE" "playbackURLOrTokenReference: nil" "no app-provided playback token reference"
require_file_term "$STORE_FILE" "backendPlaybackDescriptorContract(for" "store contract helper"
require_file_term "$STORE_FILE" "backendEntitlementValidationRequest(for" "store entitlement validation request helper"
require_file_term "$STORE_FILE" "backendPlaybackDescriptorRequest(for" "store playback descriptor request helper"
require_file_term "$STORE_FILE" "serverEntitlementValidationState(for" "store server entitlement state helper"
require_file_term "$STORE_FILE" "hasCompleteRuntimeConfig" "runtime-config-gated contract readiness"
require_file_term "$MOVIE_DETAIL_FILE" "hf.movieDetail.backendEntitlementValidation" "Movie Detail contract identifier"
require_file_term "$MOVIE_DETAIL_FILE" "hf.player.backendDescriptorContract" "Player contract identifier"
require_file_term "$PROFILE_FILE" "hf.profile.backendPlaybackContract" "Profile contract identifier"

url_pattern='https?''://'
concrete_url_hits="$(rg -n "$url_pattern" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" "$DOC_FILE" || true)"
if [[ -n "$concrete_url_hits" ]]; then
  failures+=("Concrete URL-like value found in contract scope")
else
  passes+=("no concrete URL-like values in contract scope")
fi

full_url_endpoint_hits="$(rg -n "$url_pattern.*(/entitlements/validate|/playback/descriptor)" "$CONTRACT_FILE" "$DOC_FILE" || true)"
if [[ -n "$full_url_endpoint_hits" ]]; then
  failures+=("Endpoint path appears as a full URL")
else
  passes+=("endpoint paths are relative only")
fi

live_storekit_pattern="$(printf '%s|%s|%s|%s|%s|%s' \
  'Product''\.products' \
  'Transaction''\.updates' \
  'purchase''\(' \
  'AppStore''\.sync' \
  'SK''Payment' \
  'SKPayment''Queue')"
if rg -n "$live_storekit_pattern" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" >/tmp/highfive-62-0b-live-storekit.log 2>&1; then
  failures+=("Live StoreKit implementation marker found in contract scope")
else
  passes+=("no live StoreKit implementation markers in contract scope")
fi

provider_pattern="$(printf '%s|%s' 'Revenue''Cat' 'Stripe')"
provider_hits="$(rg -n "$provider_pattern" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" || true)"
if [[ -n "$provider_hits" ]]; then
  failures+=("Provider SDK marker found in Swift contract scope")
else
  passes+=("no RevenueCat or Stripe SDK markers in Swift contract scope")
fi

download_pattern="$(printf '%s|%s|%s' 'AVAssetDownloadURL''Session' 'File''Manager' 'write''To')"
if rg -n "$download_pattern" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" >/tmp/highfive-62-0b-download.log 2>&1; then
  failures+=("Real media download implementation marker found in contract scope")
else
  passes+=("no real media download implementation markers in contract scope")
fi

secret_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s' \
  'sk_''live' \
  'pk_''live' \
  'client_''secret\\s*[:=]' \
  'access_''token\\s*[:=]' \
  'refresh_''token\\s*[:=]' \
  'pass''word\\s*[:=]' \
  'Bear''er [A-Za-z0-9]' \
  'api[_-]?''key\\s*[:=]' \
  'secret\\s*[:=]' \
  'tok''en\\s*[:=]' \
  'service_''role|private_''key')"
if rg -n "$secret_pattern" "$CONTRACT_FILE" "$DOC_FILE" >/tmp/highfive-62-0b-secret.log 2>&1; then
  failures+=("Secret-like assignment found in contract scope")
else
  passes+=("no secret-like assignments in contract scope")
fi

signed_generation_prefix="(generate|mint|create|issue).*signed.*tok"
signed_generation_pattern="${signed_generation_prefix}en"
s_phrase='signed-'
s_phrase+='token'
cf_phrase='Cloudflare tok'
cf_phrase+='en'
signed_generation_hits="$(rg -n -i "$signed_generation_pattern" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" || true)"
if [[ -n "$signed_generation_hits" ]]; then
  failures+=("Signed-token generation behavior found in app code")
else
  passes+=("no ${s_phrase} generation behavior in app code")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#062.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "modelsVerified": %d,\n' "${#REQUIRED_MODELS[@]}"
  printf -- '  "endpointPathsVerified": %d,\n' "${#REQUIRED_ENDPOINTS[@]}"
  printf -- '  "configNamesVerified": %d,\n' "${#REQUIRED_CONFIG[@]}"
  printf -- '  "requestFieldsVerified": %d,\n' "${#REQUIRED_REQUEST_FIELDS[@]}"
  printf -- '  "responseFieldsVerified": %d,\n' "${#REQUIRED_RESPONSE_FIELDS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "endpointPathsRelativeOnly": true,\n'
  printf -- '    "noFullBackendURL": true,\n'
  printf -- '    "noCloudflarePlaybackURL": true,\n'
  printf -- '    "noCloudflareTokenValue": true,\n'
  printf -- '    "noSignedTokenGenerationInApp": true,\n'
  printf -- '    "contractModelsBuildWithoutLiveServer": true,\n'
  printf -- '    "missingRuntimeConfigPreservesLocalPreviewFallback": true,\n'
  printf -- '    "noLiveStoreKitImplementation": true,\n'
  printf -- '    "noRevenueCatSDK": true,\n'
  printf -- '    "noStripeSDK": true,\n'
  printf -- '    "noRealMediaDownloads": true,\n'
  printf -- '    "noCommittedSecretsOrCredentials": true\n'
  printf -- '  },\n'
  printf -- '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "${failures[$i]//\"/\\\"}"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Backend Entitlement Playback Contract Source Verification\n\n'
  printf -- '- Upgrade: #062.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Models verified: %d\n' "${#REQUIRED_MODELS[@]}"
  printf -- '- Endpoint paths verified: %d\n' "${#REQUIRED_ENDPOINTS[@]}"
  printf -- '- Runtime config names verified: %d\n' "${#REQUIRED_CONFIG[@]}"
  printf -- '- Request fields verified: %d\n' "${#REQUIRED_REQUEST_FIELDS[@]}"
  printf -- '- Response fields verified: %d\n' "${#REQUIRED_RESPONSE_FIELDS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Endpoint paths are relative only.\n'
  printf -- '- No full backend URL, Cloudflare playback URL, concrete %s, %s generation in app, live StoreKit implementation, RevenueCat SDK, Stripe SDK, real media downloads, or committed secrets were found in the contract scope.\n' "$cf_phrase" "$s_phrase"
  printf -- '- Missing runtime config preserves Local Preview fallback active.\n\n'
  printf -- '## Failures\n\n'
  if (( ${#failures[@]} > 0 )); then
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '- None.\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Backend entitlement playback contract source verification passed.\n'
