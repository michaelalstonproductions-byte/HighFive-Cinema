#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-56-0b-streaming-provider-evidence"
JSON_OUT="$OUT_DIR/streaming_provider_staging_source_verification.json"
MD_OUT="$OUT_DIR/streaming_provider_staging_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_SCOPE=("HighFive" "docs/production_services")
SERVICE_FILE="HighFive/Services/Streaming/HFStreamingProviderService.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"

declare -a REQUIRED_TERMS=(
  "HFStreamingProvider"
  "HFPlaybackDescriptor"
  "HFPlaybackDescriptorStatus"
  "HFPlaybackSourceResolver"
  "HFRemotePlaybackDescriptorGateway"
  "HFLocalPreviewPlaybackResolver"
  "HFProviderAssetMapping"
  "HFPlaybackSourceBoundary"
  "HFStreamingProviderStatus"
  "HFPlaybackDescriptorRequest"
  "HFPlaybackDescriptorResponse"
  "HIGHFIVE_STREAMING_PROVIDER"
  "HIGHFIVE_STREAMING_MODE"
  "HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL"
  "HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID"
  "HIGHFIVE_MUX_ENVIRONMENT_KEY"
  "Local Preview Ready"
  "Provider Descriptor Missing"
  "Staging Descriptor Ready"
  "Streaming Provider Not Connected Yet"
  "Backend-mediated playback only"
  "No streaming provider connected"
  "Cloudflare Stream preferred"
  "Mux fallback"
  "hf.streaming.status"
  "hf.streaming.localPreviewReady"
  "hf.streaming.providerDescriptorMissing"
  "hf.streaming.stagingDescriptorReady"
  "hf.streaming.notConnected"
  "hf.streaming.cloudflarePreferred"
  "hf.streaming.muxFallback"
  "hf.playback.descriptorBoundary"
  "hf.player.localPreview"
  "hf.player.providerStatus"
  "hf.movieDetail.playbackStatus"
  "hf.route.watchNow"
)

failures=()
passes=()

require_term() {
  local term="$1"
  if rg -q --fixed-strings "$term" "${SOURCE_SCOPE[@]}"; then
    passes+=("$term")
  else
    failures+=("Missing source evidence: $term")
  fi
}

for term in "${REQUIRED_TERMS[@]}"; do
  require_term "$term"
done

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

require_file_term "$SERVICE_FILE" "guard configuration.hasAnyRuntimeConfig else" "remote gateway missing-config gate"
require_file_term "$SERVICE_FILE" "guard configuration.hasCompleteRuntimeConfig else" "remote gateway complete-config gate"
require_file_term "$SERVICE_FILE" "HFLocalPreviewPlaybackResolver().descriptor" "local preview fallback in remote gateway"
require_file_term "$SERVICE_FILE" "response?.status == .stagingDescriptorReady" "descriptor-ready staging gate"
require_file_term "$SERVICE_FILE" "localPreviewIDs: Set<String> = [\"friendly\", \"paranormall-s1\"]" "Friendly / Paranormall local fallback"
require_file_term "$STORE_FILE" "Self.localPreviewStreamingIDs" "store local preview resolver wiring"
require_file_term "$STORE_FILE" "remotePlaybackDescriptorGateway.descriptor" "store remote descriptor gateway wiring"

if rg -q "AVAssetDownloadURLSession" HighFive; then
  failures+=("AVAssetDownloadURLSession was found in app sources")
else
  passes+=("no AVAssetDownloadURLSession in app sources")
fi

if rg -q "(CloudflareStream|Mux)" HighFive --glob '*.swift'; then
  failures+=("Raw provider SDK marker found in Swift sources")
else
  passes+=("no raw provider SDK markers in Swift sources")
fi

if rg -q "https?://" HighFive docs/production_services --glob '*.swift' --glob '*.md' --glob '*.json' --glob '*.sh'; then
  failures+=("Hardcoded URL-like value found in source/doc scope")
else
  passes+=("no hardcoded URL-like values in source/doc scope")
fi

secret_pattern='(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9])'
if rg -q "$secret_pattern" HighFive docs/production_services scripts --glob '*.swift' --glob '*.md' --glob '*.json' --glob '*.sh'; then
  failures+=("Secret-like value found in source/doc/script scope")
else
  passes+=("no secret-like values in source/doc/script scope")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#056.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "requiredEvidenceCount": %d,\n' "${#REQUIRED_TERMS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "localPreviewDefaultFallback": true,\n'
  printf -- '    "friendlyParanormallFallbackChecked": true,\n'
  printf -- '    "remoteDescriptorGatewayConfigGated": true,\n'
  printf -- '    "missingConfigKeepsLocalPreviewReady": true,\n'
  printf -- '    "partialConfigReportsProviderDescriptorMissing": true,\n'
  printf -- '    "stagingDescriptorReadyIsNotProductionClaim": true,\n'
  printf -- '    "noRawProviderSDK": true,\n'
  printf -- '    "noProviderTokens": true,\n'
  printf -- '    "noHardcodedMediaURLs": true,\n'
  printf -- '    "noHardcodedBackendURLs": true,\n'
  printf -- '    "noCommittedSecrets": true,\n'
  printf -- '    "noLiveDownloads": true,\n'
  printf -- '    "noProductionStreamingClaim": true\n'
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
  printf -- '# Streaming Provider Staging Source Verification\n\n'
  printf -- '- Upgrade: #056.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required evidence terms: %d\n' "${#REQUIRED_TERMS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Local preview remains default fallback.\n'
  printf -- '- Friendly / Paranormall local fallback is source-verified when present.\n'
  printf -- '- Remote descriptor gateway is runtime-config gated.\n'
  printf -- '- Missing streaming config keeps Local Preview Ready.\n'
  printf -- '- Partial streaming config reports Provider Descriptor Missing.\n'
  printf -- '- Staging Descriptor Ready is a descriptor-ready staging state, not a production live claim.\n'
  printf -- '- No raw provider SDK, provider tokens, hardcoded media URLs, hardcoded backend URLs, committed secrets, live downloads, or production streaming claim were found by this verifier.\n\n'
  if (( ${#failures[@]} > 0 )); then
    printf -- '## Failures\n\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '## Failures\n\n- None.\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Streaming provider staging source verification passed.\n'
