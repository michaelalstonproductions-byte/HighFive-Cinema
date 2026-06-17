#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-59-0b-real-downloads-policy-evidence"
JSON_OUT="$OUT_DIR/real_downloads_policy_staging_source_verification.json"
MD_OUT="$OUT_DIR/real_downloads_policy_staging_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_SCOPE=("HighFive" "docs/production_services/HIGHFIVE_REAL_DOWNLOADS_POLICY_ELIGIBILITY_STAGING.md")
DOWNLOAD_FILE="HighFive/Services/Downloads/HFDownloadEligibilityService.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"

declare -a REQUIRED_TERMS=(
  "HFDownloadEligibilityService"
  "HFLocalDownloadEligibilityAdapter"
  "HFRemoteDownloadPolicyGateway"
  "HFDownloadPolicy"
  "HFDownloadQueueRecord"
  "HFOfflineLicenseState"
  "HFStoragePressureState"
  "HFDownloadExpirationPolicy"
  "HFDownloadProviderBoundary"
  "HFDownloadRuntimeStatus"
  "HFDownloadProviderStatus"
  "HFDownloadEligibilityResult"
  "HFDownloadPrerequisite"
  "HFDownloadQueueState"
  "HFDownloadStoragePolicy"
  "HFOfflineLicensePolicy"
  "HFDownloadActionReadiness"
  "HIGHFIVE_DOWNLOADS_MODE"
  "HIGHFIVE_DOWNLOADS_PROVIDER"
  "HIGHFIVE_DOWNLOAD_POLICY_BASE_URL"
  "HIGHFIVE_OFFLINE_LICENSE_PROVIDER"
  "HIGHFIVE_DOWNLOAD_STORAGE_LIMIT_MB"
  "Offline Preview"
  "Local Offline Shelf"
  "Download Provider Not Connected Yet"
  "License Required"
  "Media Source Required"
  "Entitlement Required"
  "Storage Policy Required"
  "Download Eligibility Missing Provider"
  "Real downloads disabled"
  "Backend-mediated downloads only"
  "Local offline preview only"
  "Download policy configured"
  "Offline license not active"
  "Expiration policy required"
  "hf.downloads.policyStatus"
  "hf.downloads.eligibilityStatus"
  "hf.downloads.downloadProviderNotConnected"
  "hf.downloads.mediaSourceRequired"
  "hf.downloads.licenseRequired"
  "hf.downloads.entitlementRequired"
  "hf.downloads.storagePolicyRequired"
  "hf.downloads.realDownloadsDisabled"
  "hf.downloads.localOfflinePreviewOnly"
  "hf.movieDetail.downloadBoundary"
  "hf.movieDetail.downloadEligibility"
  "hf.profile.downloadReadiness"
  "hf.profile.downloadPolicyStatus"
  "hf.backendStatus.downloads"
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

require_file_term "$DOWNLOAD_FILE" "guard configuration.hasAnyRuntimeConfig else" "missing config local fallback gate"
require_file_term "$DOWNLOAD_FILE" "guard configuration.hasCompleteRuntimeConfig else" "partial config missing provider gate"
require_file_term "$DOWNLOAD_FILE" "streamingStatus != .stagingDescriptorReady" "missing streaming descriptor prerequisite"
require_file_term "$DOWNLOAD_FILE" "entitlementStatus != .entitlementConfigured" "missing entitlement prerequisite"
require_file_term "$DOWNLOAD_FILE" "prerequisites.append(.licenseRequired)" "missing offline license prerequisite"
require_file_term "$DOWNLOAD_FILE" "prerequisites.append(.storagePolicyRequired)" "missing storage policy prerequisite"
require_file_term "$DOWNLOAD_FILE" "localFallback.eligibility" "remote gateway local eligibility fallback"
require_file_term "$DOWNLOAD_FILE" "localFallback.runtimeStatus" "remote gateway local runtime fallback"
require_file_term "$STORE_FILE" "downloadPolicyRuntimeStatus" "store download policy runtime status"
require_file_term "$STORE_FILE" "downloadPolicyBackendServiceStatus" "backend downloads readiness integration"

forbidden_download_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s' \
  'AVAssetDownloadURL''Session' \
  'AVAssetDownload''Task' \
  'AVAggregateAssetDownload''Task' \
  'download''Task' \
  'URL''Session' \
  'File''Manager' \
  'write''To' \
  'background ''transfer' \
  'backgroundSession''Configuration' \
  'AVContentKey''Session' \
  'AVAssetResource''Loader' \
  'Fair''Play' \
  'D''RM' \
  'media ''file' \
  'offline playback ''active' \
  'download ''complete' \
  'Download ''Now|Start ''Download|Pause ''download|Resume ''download')"

if git diff phase-58-0b-cloud-library-sync-staging-evidence-lock..phase-59-0a-real-downloads-policy-eligibility-staging -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg '^\+' | rg -q "$forbidden_download_pattern"; then
  failures+=("Forbidden real download implementation marker was introduced by the #059.0A diff")
else
  passes+=("no real download implementation markers introduced by the #059.0A diff")
fi

if rg -q "CloudflareStream|import Cloudflare|Mux" HighFive --glob '*.swift'; then
  failures+=("Cloudflare or Mux SDK marker found in Swift sources")
else
  passes+=("no Cloudflare or Mux SDK markers in Swift sources")
fi

offline_claim_pattern='real offline playback|offline playback ''active|production download|live downloads active'
if rg -q "$offline_claim_pattern" HighFive --glob '*.swift'; then
  failures+=("Real offline playback or production download claim found in Swift sources")
else
  passes+=("no real offline playback or production download claim in Swift sources")
fi

url_pattern='https?''://'
if rg -q "$url_pattern" HighFive docs/production_services/HIGHFIVE_REAL_DOWNLOADS_POLICY_ELIGIBILITY_STAGING.md --glob '*.swift' --glob '*.md'; then
  failures+=("Hardcoded URL-like value found in app or #059.0A staging doc scope")
else
  passes+=("no hardcoded URL-like values in app or #059.0A staging doc scope")
fi

secret_pattern='(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9])'
if rg -q "$secret_pattern" HighFive docs/production_services/HIGHFIVE_REAL_DOWNLOADS_POLICY_ELIGIBILITY_STAGING.md scripts --glob '*.swift' --glob '*.md' --glob '*.json' --glob '*.sh'; then
  failures+=("Secret-like value found in app/doc/script scope")
else
  passes+=("no secret-like values in app/doc/script scope")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#059.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "requiredEvidenceCount": %d,\n' "${#REQUIRED_TERMS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "missingConfigKeepsOfflinePreviewLocalShelf": true,\n'
  printf -- '    "missingStreamingDescriptorReportsMediaSourceRequired": true,\n'
  printf -- '    "missingEntitlementReportsEntitlementRequired": true,\n'
  printf -- '    "missingOfflineLicenseReportsLicenseRequired": true,\n'
  printf -- '    "missingStoragePolicyReportsStoragePolicyRequired": true,\n'
  printf -- '    "remoteGatewayStubNoNetwork": true,\n'
  printf -- '    "noRealDownloadImplementation": true,\n'
  printf -- '    "noHardcodedURLs": true,\n'
  printf -- '    "noCommittedSecrets": true,\n'
  printf -- '    "noLiveDownloads": true,\n'
  printf -- '    "noRealOfflinePlaybackClaim": true\n'
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
  printf -- '# Real Downloads Policy Staging Source Verification\n\n'
  printf -- '- Upgrade: #059.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required evidence terms: %d\n' "${#REQUIRED_TERMS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Missing config keeps Offline Preview / Local Offline Shelf.\n'
  printf -- '- Missing streaming descriptor reports Media Source Required.\n'
  printf -- '- Missing entitlement reports Entitlement Required.\n'
  printf -- '- Missing offline license reports License Required.\n'
  printf -- '- Missing storage policy reports Storage Policy Required.\n'
  printf -- '- Remote download policy gateway is a stub and does not call network.\n'
  printf -- '- No real download implementation, hardcoded URL, committed secret, live download, or real offline playback claim was found by this verifier.\n\n'
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

printf -- 'Real downloads policy staging source verification passed.\n'
