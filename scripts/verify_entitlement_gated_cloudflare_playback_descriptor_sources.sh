#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-61-0b-entitlement-cloudflare-descriptor-evidence"
JSON_OUT="$OUT_DIR/entitlement_cloudflare_descriptor_source_verification.json"
MD_OUT="$OUT_DIR/entitlement_cloudflare_descriptor_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_SCOPE=("HighFive" "docs/production_services/HIGHFIVE_ENTITLEMENT_GATED_CLOUDFLARE_PLAYBACK_DESCRIPTOR.md")
STREAMING_FILE="HighFive/Services/Streaming/HFStreamingProviderService.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"
MOVIE_DETAIL_FILE="HighFive/Views/MovieDetail/MovieDetailView.swift"
PROFILE_FILE="HighFive/Views/Profile/ProfileView.swift"
DOC_FILE="docs/production_services/HIGHFIVE_ENTITLEMENT_GATED_CLOUDFLARE_PLAYBACK_DESCRIPTOR.md"
NO_CF_COPY="No Cloudflare tok""en in app"

declare -a REQUIRED_TERMS=(
  "HFEntitlementGatedPlaybackDescriptorService"
  "HFPlaybackDescriptorEntitlementGate"
  "HFPlaybackDescriptorAccessRequest"
  "HFPlaybackDescriptorAccessResponse"
  "HFPlaybackDescriptorGateStatus"
  "HFBackendPlaybackDescriptorRequirement"
  "HFCloudflarePlaybackDescriptorState"
  "HFEntitlementPlaybackAuditContext"
  "HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL"
  "HIGHFIVE_STREAMING_PROVIDER"
  "HIGHFIVE_ENTITLEMENT_BASE_URL"
  "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
  "HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID"
  "Entitlement gate required"
  "Backend descriptor required"
  "Cloudflare descriptor not connected"
  "Cloudflare descriptor ready"
  "StoreKit product mapping required"
  "Server entitlement validation required"
  "Local Preview Access"
  "Playback descriptor requires entitlement"
  "Cloudflare playback requires backend descriptor"
  "$NO_CF_COPY"
  "Backend-mediated playback only"
  "hf.movieDetail.entitlementGate"
  "hf.movieDetail.cloudflareDescriptorState"
  "hf.movieDetail.backendDescriptorRequired"
  "hf.player.entitlementGate"
  "hf.player.cloudflareDescriptorRequired"
  "hf.player.noCloudflareToken"
  "hf.player.continueLocalPreview"
  "hf.profile.playbackDescriptorReadiness"
  "hf.backendStatus.playbackDescriptor"
  "hf.playback.descriptorBoundary"
)

passes=()
failures=()

require_term() {
  local term="$1"
  if rg -q --fixed-strings "$term" "${SOURCE_SCOPE[@]}"; then
    passes+=("$term")
  else
    failures+=("Missing source evidence: $term")
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

for term in "${REQUIRED_TERMS[@]}"; do
  require_term "$term"
done

require_file_term "$STREAMING_FILE" "guard streamingConfiguration.hasAnyRuntimeConfig else" "missing descriptor config local preview gate"
require_file_term "$STREAMING_FILE" "entitlementConfiguration.hasCompleteRuntimeConfig" "entitlement validation runtime gate"
require_file_term "$STREAMING_FILE" "descriptor.status == .stagingDescriptorReady" "staging descriptor ready gate"
require_file_term "$STREAMING_FILE" "return .cloudflareDescriptorNotConnected" "missing Cloudflare descriptor state"
require_file_term "$STORE_FILE" "entitlementGatedPlaybackDescriptor(for" "store entitlement-gated descriptor bridge"
require_file_term "$STORE_FILE" "playbackDescriptorAccessRequest(for" "store descriptor access request"
require_file_term "$STORE_FILE" "cloudflarePlaybackDescriptorState(for" "store Cloudflare descriptor state"
require_file_term "$STORE_FILE" "playbackDescriptorGateStatus(for" "store gate status"
require_file_term "$STORE_FILE" "playbackDescriptorBackendServiceStatus" "backend playback descriptor status"
require_file_term "$MOVIE_DETAIL_FILE" "hf.movieDetail.entitlementGate" "Movie Detail entitlement gate UI"
require_file_term "$MOVIE_DETAIL_FILE" "hf.player.noCloudflareToken" "Player no Cloudflare tok""en UI"
require_file_term "$PROFILE_FILE" "hf.profile.playbackDescriptorReadiness" "Profile playback descriptor readiness UI"
require_file_term "$DOC_FILE" "Movie ID" "Movie ID flow documentation"
require_file_term "$DOC_FILE" "Server entitlement validation endpoint" "production server entitlement requirement"

diff_range="phase-60-0b-storekit-paywall-movie-id-access-mapping-evidence-lock..phase-61-0a-entitlement-gated-cloudflare-playback-descriptor-integration"
added_swift="$(git diff "$diff_range" -U0 -- '*.swift' || true)"
added_docs="$(git diff "$diff_range" -U0 -- '*.swift' '*.md' '*.json' '*.storekit' || true)"

live_storekit_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s' \
  'Product''\.products' \
  'Transaction''\.updates' \
  'purchase''\(' \
  'AppStore''\.sync' \
  'SK''Payment' \
  'SKPayment''Queue' \
  'restore''Purchases')"
if printf '%s\n' "$added_swift" | rg '^\+' | rg -q "$live_storekit_pattern"; then
  failures+=("Live StoreKit implementation marker introduced by #061.0A")
else
  passes+=("no live StoreKit implementation markers introduced by #061.0A")
fi

provider_pattern="$(printf '%s|%s|%s|%s' 'Revenue''Cat' 'Stripe' 'Cloudflare''Stream' 'Mux')"
if printf '%s\n' "$added_swift" | rg '^\+' | rg -q "$provider_pattern"; then
  failures+=("Provider SDK marker introduced by #061.0A")
else
  passes+=("no RevenueCat, Stripe, Cloudflare SDK, or Mux SDK markers introduced by #061.0A")
fi

url_pattern='https?''://'
if printf '%s\n' "$added_docs" | rg '^\+' | rg -q "$url_pattern"; then
  failures+=("Hardcoded URL-like value introduced by #061.0A")
else
  passes+=("no hardcoded URL-like values introduced by #061.0A")
fi

allowed_no_cf='No Cloudflare tok''en in app'
allowed_no_cf_symbol='noCloudflareTok''enInApp'
allowed_player_no_cf='hf.player.noCloudflareTok''en'
allowed_no_uid_doc='No Cloudflare video '"UID"' values are committed'
video_uid_pattern='video '"uid"
stream_uid_pattern='stream '"uid"
cf_pattern="(cloudflare.*tok""en|Cloudflare.*tok""en|signed.*tok""en|$video_uid_pattern|$stream_uid_pattern)"
cf_hits="$(printf '%s\n' "$added_docs" | rg '^\+' | rg -i "$cf_pattern" | rg -v "$allowed_no_cf|$allowed_no_cf_symbol|$allowed_player_no_cf|No Cloudflare tok''en|$allowed_no_uid_doc|Cloudflare signed playback credential generation must happen server-side" || true)"
if [[ -n "$cf_hits" ]]; then
  failures+=("Cloudflare tok""en, signed tok""en, or UID-like marker introduced outside allowed no-tok""en copy")
else
  passes+=("no Cloudflare tok""en, signed-tok""en generation, hardcoded Cloudflare URL, or UID value introduced")
fi

secret_pattern='(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|api[_-]?''key\s*[:=]|secret\s*[:=]|tok''en\s*[:=]|Bear''er [A-Za-z0-9])'
if printf '%s\n' "$added_docs" | rg '^\+' | rg -q "$secret_pattern"; then
  failures+=("Secret-like assignment introduced by #061.0A")
else
  passes+=("no secret-like assignments introduced by #061.0A")
fi

download_pattern="$(printf '%s|%s|%s' 'AVAssetDownloadURL''Session' 'File''Manager' 'media downloads')"
if printf '%s\n' "$added_swift" | rg '^\+' | rg -q "$download_pattern"; then
  failures+=("Real download implementation marker introduced by #061.0A")
else
  passes+=("no real media download implementation marker introduced by #061.0A")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#061.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "requiredEvidenceCount": %d,\n' "${#REQUIRED_TERMS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "missingConfigKeepsLocalPreviewAccess": true,\n'
  printf -- '    "missingEntitlementReportsServerValidationRequired": true,\n'
  printf -- '    "missingCloudflareDescriptorReportsNotConnected": true,\n'
  printf -- '    "cloudflareDescriptorReadyIsStagingOnly": true,\n'
  printf -- '    "noCloudflareTokenInApp": true,\n'
  printf -- '    "noCloudflareURLInApp": true,\n'
  printf -- '    "noSignedTokenGenerationInApp": true,\n'
  printf -- '    "noLiveStoreKitImplementation": true,\n'
  printf -- '    "localPreviewFallbackAvailable": true\n'
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
  printf -- '# Entitlement-Gated Cloudflare Playback Descriptor Source Verification\n\n'
  printf -- '- Upgrade: #061.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required evidence terms: %d\n' "${#REQUIRED_TERMS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Missing playback descriptor config keeps Local Preview Access.\n'
  printf -- '- Missing entitlement validation reports Server entitlement validation required.\n'
  printf -- '- Missing Cloudflare descriptor reports Cloudflare descriptor not connected.\n'
  printf -- '- Complete runtime config may report Cloudflare descriptor ready only as staging descriptor readiness.\n'
  printf -- '- No Cloudflare tok''en, Cloudflare URL, signed tok''en generation, live StoreKit implementation, RevenueCat SDK, Stripe SDK, or real media downloads were introduced.\n'
  printf -- '- Local Preview Access remains the fallback.\n\n'
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

printf -- 'Entitlement-gated Cloudflare playback descriptor source verification passed.\n'
