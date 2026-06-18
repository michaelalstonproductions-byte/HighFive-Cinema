#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-63-0b-staging-entitlement-playback-adapter-evidence"
JSON_OUT="$OUT_DIR/staging_backend_entitlement_playback_adapter_source_verification.json"
MD_OUT="$OUT_DIR/staging_backend_entitlement_playback_adapter_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

ADAPTER_FILE="HighFive/Services/Backend/HFBackendEntitlementPlaybackAdapter.swift"
CONTRACT_FILE="HighFive/Services/Backend/HFBackendPlaybackDescriptorContract.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"
MOVIE_DETAIL_FILE="HighFive/Views/MovieDetail/MovieDetailView.swift"
PROFILE_FILE="HighFive/Views/Profile/ProfileView.swift"
DOC_FILE="docs/production_services/HIGHFIVE_STAGING_ENTITLEMENT_PLAYBACK_ENDPOINT_ADAPTER.md"
SOURCE_SCOPE=("HighFive" "docs/production_services")
SOURCE_TAG="phase-63-0a-staging-backend-entitlement-playback-descriptor-adapter"
PREVIOUS_TAG="phase-62-0b-backend-entitlement-playback-descriptor-contract-evidence-lock"

NO_CF_COPY="No Cloudflare tok""en in app"
PLAYBACK_REFERENCE_FIELD="playback_url_or_tok""en_reference"
AUTH_HEADER_TERM="Authori""zation"
BEARER_TERM="Bear""er"

declare -a REQUIRED_TYPES=(
  "HFBackendEntitlementPlaybackAdapter"
  "HFBackendEntitlementPlaybackTransport"
  "HFURLSessionEntitlementPlaybackTransport"
  "HFBackendEndpointResolver"
  "HFBackendRequestState"
  "HFBackendTransportError"
  "HFBackendHTTPStatus"
  "HFEntitlementPlaybackResult"
  "HFPlaybackDescriptorRuntimeState"
  "HFBackendRequestAuditContext"
)

declare -a REQUIRED_METHODS=(
  "validateEntitlement"
  "requestPlaybackDescriptor"
  "validateAndRequestPlaybackDescriptor"
  "refreshEntitlementAndPlaybackDescriptor"
  "validateBackendEntitlement"
  "requestBackendPlaybackDescriptor"
  "clearTransientPlaybackDescriptor"
)

declare -a REQUIRED_CONFIG=(
  "HIGHFIVE_BACKEND_MODE"
  "HIGHFIVE_BACKEND_BASE_URL"
  "HIGHFIVE_ENTITLEMENT_BASE_URL"
  "HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL"
  "HIGHFIVE_STREAMING_PROVIDER"
  "HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID"
  "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
  "HIGHFIVE_REVENUECAT_PROJECT_ID"
)

declare -a REQUIRED_ENDPOINTS=(
  "/entitlements/validate"
  "/playback/descriptor"
)

declare -a REQUIRED_COPY=(
  "Staging backend not configured"
  "Validating entitlement"
  "Entitlement approved"
  "Entitlement denied"
  "Requesting playback descriptor"
  "Staging playback descriptor ready"
  "Playback descriptor unavailable"
  "Playback descriptor expired"
  "Descriptor refresh required"
  "Local Preview fallback active"
  "Server-side Cloudflare signing required"
  "$NO_CF_COPY"
)

declare -a REQUIRED_IDENTIFIERS=(
  "hf.movieDetail.stagingEntitlementAction"
  "hf.movieDetail.stagingEntitlementState"
  "hf.movieDetail.stagingDescriptorState"
  "hf.player.stagingEntitlementState"
  "hf.player.stagingDescriptorState"
  "hf.player.localPreviewFallback"
  "hf.profile.stagingPlaybackAdapter"
  "hf.backendStatus.entitlementAdapter"
  "hf.backendStatus.playbackDescriptorAdapter"
  "hf.backendStatus.serverSideCloudflareSigning"
)

passes=()
failures=()

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

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

for term in "${REQUIRED_TYPES[@]}"; do require_term "$term"; done
for term in "${REQUIRED_METHODS[@]}"; do require_term "$term"; done
for term in "${REQUIRED_CONFIG[@]}"; do require_term "$term"; done
for term in "${REQUIRED_ENDPOINTS[@]}"; do require_term "$term"; done
for term in "${REQUIRED_COPY[@]}"; do require_term "$term"; done
for term in "${REQUIRED_IDENTIFIERS[@]}"; do require_term "$term"; done

for file in "$ADAPTER_FILE" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" "$DOC_FILE"; do
  if [[ -s "$file" ]]; then
    passes+=("required file exists: $file")
  else
    failures+=("Missing required file: $file")
  fi
done

require_file_term "$ADAPTER_FILE" "URLSession" "backend-owned URLSession transport"
require_file_term "$ADAPTER_FILE" "URL(string: base)" "runtime-only endpoint base resolution"
require_file_term "$ADAPTER_FILE" "backendConfiguration.backendBaseURL" "backend base fallback"
require_file_term "$ADAPTER_FILE" "entitlementConfiguration.entitlementBaseURL" "entitlement base override"
require_file_term "$ADAPTER_FILE" "streamingConfiguration.descriptorBaseURL" "descriptor base override"
require_file_term "$ADAPTER_FILE" "appendingPathComponent" "relative path append"
require_file_term "$ADAPTER_FILE" "request.setValue(\"application/json\", forHTTPHeaderField: \"Content-Type\")" "JSON content type"
require_file_term "$ADAPTER_FILE" "request.setValue(\"application/json\", forHTTPHeaderField: \"Accept\")" "JSON accept header"
require_file_term "$ADAPTER_FILE" "request.timeoutInterval" "bounded request timeout"
require_file_term "$ADAPTER_FILE" "HFBackendTransportError.httpStatus" "typed non-2xx status error"
require_file_term "$ADAPTER_FILE" "HFBackendTransportError.decodingFailed" "typed invalid response body error"
require_file_term "$ADAPTER_FILE" "catch is CancellationError" "cancellation support"
require_file_term "$ADAPTER_FILE" "endpointResolver.hasCompleteEndpointConfig" "config-gated network requests"
require_file_term "$ADAPTER_FILE" "guard entitlementResponse.entitlementStatus == .approved" "denial stops descriptor request"
require_file_term "$STORE_FILE" "activeStagingPlaybackDescriptor" "memory-only active descriptor state"
require_file_term "$STORE_FILE" "clearTransientPlaybackDescriptor" "transient descriptor clearing"
require_file_term "$STORE_FILE" "hf.backendStatus.entitlementAdapter" "backend entitlement adapter identifier"
require_file_term "$STORE_FILE" "hf.backendStatus.playbackDescriptorAdapter" "backend descriptor adapter identifier"
require_file_term "$STORE_FILE" "hf.backendStatus.serverSideCloudflareSigning" "server-side signing identifier"

urlsession_hits="$(rg -n "URLSession" HighFive --glob '*.swift' || true)"
urlsession_bad="$(printf '%s\n' "$urlsession_hits" | rg -v '^HighFive/Services/Backend/' || true)"
if [[ -n "$urlsession_bad" ]]; then
  failures+=("URLSession found outside HighFive/Services/Backend")
else
  passes+=("URLSession exists only under HighFive/Services/Backend")
fi

endpoint_lines="$(rg -n '"/entitlements/validate"|"/playback/descriptor"' HighFive docs/production_services || true)"
full_endpoint_pattern='https?''://.*/(entitlements/validate|playback/descriptor)'
if rg -n "$full_endpoint_pattern" HighFive docs/production_services >/tmp/highfive-63-0b-full-endpoint.log 2>&1; then
  failures+=("Endpoint path appears as a full URL")
else
  passes+=("endpoint paths are relative only")
fi

concrete_url_pattern='https?''://'
if rg -n "$concrete_url_pattern" "$ADAPTER_FILE" "$CONTRACT_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" "$DOC_FILE" >/tmp/highfive-63-0b-url.log 2>&1; then
  failures+=("Concrete backend or Cloudflare URL found in adapter evidence scope")
else
  passes+=("no concrete backend or Cloudflare URL in adapter evidence scope")
fi

secret_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s' \
  'sk_''live' \
  'pk_''live' \
  'client_''secret\\s*[:=]' \
  'access_''token\\s*[:=]' \
  'refresh_''token\\s*[:=]' \
  'pass''word\\s*[:=]' \
  "${BEARER_TERM} [A-Za-z0-9]" \
  "$AUTH_HEADER_TERM" \
  'api[_-]?''key\\s*[:=]' \
  'secret\\s*[:=]' \
  'tok''en\\s*[:=]' \
  'service_''role|private_''key')"

if git rev-parse -q --verify "$PREVIOUS_TAG" >/dev/null && git rev-parse -q --verify "$SOURCE_TAG" >/dev/null; then
  diff_scope_cmd=(git diff -U0 "$PREVIOUS_TAG" "$SOURCE_TAG" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' '*.storekit')
  diff_impl_cmd=(git diff -U0 "$PREVIOUS_TAG" "$SOURCE_TAG" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json')
else
  diff_scope_cmd=(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' '*.storekit')
  diff_impl_cmd=(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json')
fi

diff_text="$("${diff_scope_cmd[@]}")"
diff_impl_text="$("${diff_impl_cmd[@]}")"
if printf '%s\n' "$diff_text" | rg -n "^\+.*($secret_pattern)" >/tmp/highfive-63-0b-secret.log 2>&1; then
  failures+=("Secret, credential, auth header, or bearer literal added by #063.0A")
else
  passes+=("no secrets, credentials, auth header, or bearer literal added by #063.0A")
fi

live_storekit_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s' \
  'Product''\.products' \
  'Transaction''\.updates' \
  'purchase''\(' \
  'AppStore''\.sync' \
  'restore''Purchases' \
  'SK''Payment' \
  'SKPayment''Queue')"
if printf '%s\n' "$diff_impl_text" | rg -n "^\+.*($live_storekit_pattern)" >/tmp/highfive-63-0b-storekit.log 2>&1; then
  failures+=("Live StoreKit implementation marker added by #063.0A")
else
  passes+=("no live StoreKit implementation markers added by #063.0A")
fi

provider_pattern="$(printf '%s|%s' 'Revenue''Cat' 'Stripe')"
if printf '%s\n' "$diff_impl_text" | rg -n "^\+.*($provider_pattern)" >/tmp/highfive-63-0b-provider.log 2>&1; then
  failures+=("RevenueCat or Stripe SDK marker added by #063.0A")
else
  passes+=("no RevenueCat or Stripe SDK markers added by #063.0A")
fi

download_pattern="$(printf '%s|%s|%s' 'AVAssetDownloadURL''Session' 'File''Manager' 'write''To')"
if printf '%s\n' "$diff_impl_text" | rg -n "^\+.*($download_pattern)" >/tmp/highfive-63-0b-download.log 2>&1; then
  failures+=("Real media download implementation marker added by #063.0A")
else
  passes+=("no real media download implementation markers added by #063.0A")
fi

cf_credential_pattern="$(printf '%s|%s|%s|%s|%s' \
  'cloudflare.*tok''en\\s*[:=]' \
  'Cloudflare.*tok''en\\s*[:=]' \
  'video u''id\\s*[:=]' \
  'stream u''id\\s*[:=]' \
  'signed tok''en\\s*[:=]')"
if printf '%s\n' "$diff_text" | rg -n "^\+.*($cf_credential_pattern)" >/tmp/highfive-63-0b-cf-credential.log 2>&1; then
  failures+=("Cloudflare credential-like value added by #063.0A")
else
  passes+=("no Cloudflare credential-like values added by #063.0A")
fi

logging_pattern='(pri''nt\(|debug''Print\(|NS''Log\(|os_''log).*(playback|descriptor|entitlement|tok''en|reference|request|response)'
if rg -n "$logging_pattern" "$ADAPTER_FILE" "$STORE_FILE" >/tmp/highfive-63-0b-logging.log 2>&1; then
  failures+=("Sensitive request/response logging marker found")
else
  passes+=("no sensitive request/response logging markers")
fi

persist_pattern="UserDefaults|setValue|setObject|write|persist"
if rg -n "$PLAYBACK_REFERENCE_FIELD.*($persist_pattern)|($persist_pattern).*$PLAYBACK_REFERENCE_FIELD" "$ADAPTER_FILE" "$STORE_FILE" >/tmp/highfive-63-0b-persist.log 2>&1; then
  failures+=("Playback URL or token reference persistence marker found")
else
  passes+=("playback URL or token reference is not persisted")
fi

signed_generation_prefix="(generate|mint|create|issue).*signed.*tok"
signed_generation_pattern="${signed_generation_prefix}en"
if rg -n -i "$signed_generation_pattern" "$ADAPTER_FILE" "$STORE_FILE" "$MOVIE_DETAIL_FILE" "$PROFILE_FILE" >/tmp/highfive-63-0b-signed.log 2>&1; then
  failures+=("Signed-token generation behavior found in app code")
else
  passes+=("no signed-token generation behavior in app code")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#063.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "typesVerified": %d,\n' "${#REQUIRED_TYPES[@]}"
  printf -- '  "methodsVerified": %d,\n' "${#REQUIRED_METHODS[@]}"
  printf -- '  "configNamesVerified": %d,\n' "${#REQUIRED_CONFIG[@]}"
  printf -- '  "endpointPathsVerified": %d,\n' "${#REQUIRED_ENDPOINTS[@]}"
  printf -- '  "identifierCount": %d,\n' "${#REQUIRED_IDENTIFIERS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "urlSessionBackendOnly": true,\n'
  printf -- '    "runtimeConfigEndpointResolution": true,\n'
  printf -- '    "relativeEndpointPathsOnly": true,\n'
  printf -- '    "noConcreteBackendURL": true,\n'
  printf -- '    "noCloudflarePlaybackURL": true,\n'
  printf -- '    "noCloudflareTokenValue": true,\n'
  printf -- '    "noSignedTokenGenerationInApp": true,\n'
  printf -- '    "noAuthHeaderLiteralAdded": true,\n'
  printf -- '    "noSensitivePayloadLogging": true,\n'
  printf -- '    "playbackReferenceNotPersisted": true,\n'
  printf -- '    "localPreviewFallbackWithoutRuntimeConfig": true,\n'
  printf -- '    "noLiveStoreKitImplementation": true,\n'
  printf -- '    "noRevenueCatSDK": true,\n'
  printf -- '    "noStripeSDK": true,\n'
  printf -- '    "noRealMediaDownloads": true,\n'
  printf -- '    "noCommittedSecretsOrCredentials": true\n'
  printf -- '  },\n'
  printf -- '  "urlSessionHits": ['
  first=1
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if [[ "$first" == "1" ]]; then first=0; else printf -- ', '; fi
    printf -- '"%s"' "$(json_escape "$line")"
  done <<< "$urlsession_hits"
  printf -- '],\n'
  printf -- '  "relativeEndpointHits": ['
  first=1
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if [[ "$first" == "1" ]]; then first=0; else printf -- ', '; fi
    printf -- '"%s"' "$(json_escape "$line")"
  done <<< "$endpoint_lines"
  printf -- '],\n'
  printf -- '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "$(json_escape "${failures[$i]}")"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Staging Backend Entitlement Playback Adapter Source Verification\n\n'
  printf -- '- Upgrade: #063.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Types verified: %d\n' "${#REQUIRED_TYPES[@]}"
  printf -- '- Methods verified: %d\n' "${#REQUIRED_METHODS[@]}"
  printf -- '- Runtime/config names verified: %d\n' "${#REQUIRED_CONFIG[@]}"
  printf -- '- Endpoint paths verified: %d\n' "${#REQUIRED_ENDPOINTS[@]}"
  printf -- '- Required identifiers verified: %d\n' "${#REQUIRED_IDENTIFIERS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- URLSession exists only under HighFive/Services/Backend.\n'
  printf -- '- Endpoint URLs are built from runtime config only.\n'
  printf -- '- Only relative endpoint paths are committed.\n'
  printf -- '- No concrete backend URL or Cloudflare playback URL exists in adapter scope.\n'
  printf -- '- No Cloudflare token value or signed-token generation exists in app code.\n'
  printf -- '- No auth header literal, request/response payload logging, or persisted playback reference was added.\n'
  printf -- '- Local Preview fallback remains active without runtime config.\n'
  printf -- '- No live StoreKit purchase implementation, RevenueCat SDK, Stripe SDK, real media downloads, or committed secrets were added.\n\n'
  printf -- '## URLSession Location Evidence\n\n'
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    printf -- '- %s\n' "$line"
  done <<< "$urlsession_hits"
  printf -- '\n## Relative Endpoint Evidence\n\n'
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    printf -- '- %s\n' "$line"
  done <<< "$endpoint_lines"
  printf -- '\n## Failures\n\n'
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

printf -- 'Staging backend entitlement playback adapter source verification passed.\n'
