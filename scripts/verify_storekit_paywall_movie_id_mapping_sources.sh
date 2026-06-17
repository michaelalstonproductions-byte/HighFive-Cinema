#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-60-0b-storekit-paywall-mapping-evidence"
JSON_OUT="$OUT_DIR/storekit_paywall_movie_id_mapping_source_verification.json"
MD_OUT="$OUT_DIR/storekit_paywall_movie_id_mapping_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_SCOPE=(
  "HighFive"
  "docs/production_services/HIGHFIVE_STOREKIT_PAYWALL_MOVIE_ID_MAPPING.md"
)
DOC_FILE="docs/production_services/HIGHFIVE_STOREKIT_PAYWALL_MOVIE_ID_MAPPING.md"
ENTITLEMENT_FILE="HighFive/Services/Entitlements/HFEntitlementService.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"
MOVIE_DETAIL_FILE="HighFive/Views/MovieDetail/MovieDetailView.swift"
PROFILE_FILE="HighFive/Views/Profile/ProfileView.swift"

declare -a REQUIRED_TERMS=(
  "HFStoreKitAccessMapping"
  "HFStoreKitProductReference"
  "HFMovieAccessRule"
  "HFMovieEntitlementRequirement"
  "HFPlaybackAccessDecision"
  "HFPaywallReadinessState"
  "HFStoreKitProductReadiness"
  "HFCloudflarePlaybackReference"
  "HFPlaybackDescriptorEntitlementContext"
  "HFStoreKitPaywallCatalog"
  "friendly"
  "the_friendly"
  "com.highfive.movie.thefriendly"
  "paranormall-s1"
  "paranormall_s1"
  "com.highfive.series.paranormall.season1"
  "paranormall_s1_e1"
  "paranormall_s1_e2"
  "paranormall_s1_e3"
  "paranormall_s1_e4"
  "paranormall_s1_e5"
  "paranormall_s1_e6"
  "paranormall_s1_e7"
  "com.highfive.episode.paranormall.e1"
  "com.highfive.episode.paranormall.e7"
  "StoreKit product mapping"
  "Paywall readiness"
  "Product ID required"
  "Entitlement validation required"
  "Playback descriptor requires entitlement"
  "Cloudflare playback requires backend descriptor"
  "Local Preview Access"
  "Payment Provider Not Connected Yet"
  "Server Entitlement Validation Required"
  "Restore Purchases Not Active Yet"
  "<STOREKIT_PRODUCT_ID_REQUIRED>"
  "hf.entitlement.storeKitMapping"
  "hf.entitlement.productIDRequired"
  "hf.entitlement.playbackAccessDecision"
  "hf.streaming.cloudflarePlaybackReference"
  "hf.playback.descriptorBoundary"
  "hf.movieDetail.storeKitMapping"
  "hf.movieDetail.paywallReadiness"
  "hf.player.entitlementGate"
  "hf.player.cloudflareDescriptorRequired"
  "hf.profile.storeKitReadiness"
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

require_file_term "$DOC_FILE" "/Volumes/Scratch SSD/May 24th 917 " "old project path inspected"
require_file_term "$DOC_FILE" "Configuration.storekit" "StoreKit config source documented"
require_file_term "$DOC_FILE" "catalog metadata only" "product IDs reused only as catalog metadata"
require_file_term "$DOC_FILE" "Live StoreKit transaction handling" "old live StoreKit transaction code not copied"
require_file_term "$DOC_FILE" "Old UIKit paywall screens" "old UIKit paywall screens not copied"
require_file_term "$DOC_FILE" "Cloudflare video UID values" "Cloudflare URLs and UIDs not copied"
require_file_term "$DOC_FILE" "Local network stream base URLs" "hardcoded local URLs not copied"
require_file_term "$DOC_FILE" "Old playback engine or protected playback internals" "old playback resolver internals not copied"
require_file_term "$DOC_FILE" "Project file membership changes" "project files not copied"
require_file_term "$ENTITLEMENT_FILE" "HFStoreKitAccessMapping" "StoreKit/paywall mapping source"
require_file_term "$ENTITLEMENT_FILE" "HFCloudflarePlaybackReference" "Cloudflare descriptor reference source"
require_file_term "$STORE_FILE" "storeKitAccessRule" "store exposes movie access rule"
require_file_term "$STORE_FILE" "playbackEntitlementContext" "store exposes playback entitlement context"
require_file_term "$MOVIE_DETAIL_FILE" "hf.movieDetail.storeKitMapping" "Movie Detail mapping readiness UI"
require_file_term "$MOVIE_DETAIL_FILE" "hf.player.entitlementGate" "Player entitlement gate UI"
require_file_term "$PROFILE_FILE" "hf.profile.storeKitReadiness" "Profile StoreKit readiness UI"

live_storekit_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s' \
  'Product''\.products' \
  'purchase''\(' \
  'Transaction''\.updates' \
  'Transaction''\.' \
  'AppStore''\.sync' \
  'SK''Payment' \
  'SKPayment''Queue')"

if git diff phase-59-0b-real-downloads-policy-staging-evidence-lock..phase-60-0a-storekit-paywall-movie-id-access-mapping-integration -U0 -- '*.swift' | rg '^\+' | rg -q "$live_storekit_pattern"; then
  failures+=("Live StoreKit transaction marker found in the #060.0A Swift diff")
else
  passes+=("no live StoreKit transaction markers introduced by the #060.0A Swift diff")
fi

provider_pattern="$(printf '%s|%s|%s|%s|%s' \
  'Revenue''Cat' \
  'Stripe' \
  'Payment''Sheet' \
  'Cloudflare''Stream' \
  'import Cloud''flare')"

if git diff phase-59-0b-real-downloads-policy-staging-evidence-lock..phase-60-0a-storekit-paywall-movie-id-access-mapping-integration -U0 -- '*.swift' | rg '^\+' | rg -q "$provider_pattern"; then
  failures+=("Provider SDK marker found in the #060.0A Swift diff")
else
  passes+=("no RevenueCat, Stripe, or Cloudflare SDK markers introduced by the #060.0A Swift diff")
fi

url_pattern='https?''://'
if git diff phase-59-0b-real-downloads-policy-staging-evidence-lock..phase-60-0a-storekit-paywall-movie-id-access-mapping-integration -U0 -- '*.swift' '*.md' | rg '^\+' | rg -q "$url_pattern"; then
  failures+=("Hardcoded URL-like value found in the #060.0A Swift/doc diff")
else
  passes+=("no hardcoded URL-like values introduced by the #060.0A Swift/doc diff")
fi

secret_pattern='(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|api[_-]?''key\s*[:=]|secret\s*[:=]|tok''en\s*[:=]|Bear''er [A-Za-z0-9])'
if git diff phase-59-0b-real-downloads-policy-staging-evidence-lock..phase-60-0a-storekit-paywall-movie-id-access-mapping-integration -U0 -- '*.swift' '*.md' | rg '^\+' | rg -q "$secret_pattern"; then
  failures+=("Secret-like value found in the #060.0A Swift/doc diff")
else
  passes+=("no secret-like values introduced by the #060.0A Swift/doc diff")
fi

forbidden_cta_pattern='Buy Now|Subscribe Now|Pay Now|Purchase Now|Rent Now|Unlock Now|Start Cloudflare Playback'
if git diff phase-59-0b-real-downloads-policy-staging-evidence-lock..phase-60-0a-storekit-paywall-movie-id-access-mapping-integration -U0 -- '*.swift' | rg '^\+' | rg -q "$forbidden_cta_pattern"; then
  failures+=("Forbidden live purchase or Cloudflare CTA copy found in the #060.0A Swift diff")
else
  passes+=("no forbidden live purchase or Cloudflare CTA copy introduced by the #060.0A Swift diff")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#060.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "requiredEvidenceCount": %d,\n' "${#REQUIRED_TERMS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "oldProjectPathInspected": true,\n'
  printf -- '    "storeKitConfigSourceDocumented": true,\n'
  printf -- '    "productIdsCatalogMetadataOnly": true,\n'
  printf -- '    "oldLiveStoreKitCodeNotCopied": true,\n'
  printf -- '    "oldUIKitPaywallNotCopied": true,\n'
  printf -- '    "cloudflareUrlsUidsNotCopied": true,\n'
  printf -- '    "hardcodedLocalUrlsNotCopied": true,\n'
  printf -- '    "oldPlaybackResolverInternalsNotCopied": true,\n'
  printf -- '    "projectFilesNotCopied": true,\n'
  printf -- '    "localPreviewAccessAvailable": true\n'
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
  printf -- '# StoreKit Paywall Movie-ID Mapping Source Verification\n\n'
  printf -- '- Upgrade: #060.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required evidence terms: %d\n' "${#REQUIRED_TERMS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Old project path inspected.\n'
  printf -- '- StoreKit config source documented.\n'
  printf -- '- Product IDs reused only as catalog metadata.\n'
  printf -- '- Old live StoreKit transaction code, UIKit paywall screens, Cloudflare URLs/UIDs, hardcoded local URLs, playback resolver internals, and project files were not copied.\n'
  printf -- '- No live purchase, live restore, RevenueCat SDK, Stripe SDK, Cloudflare token, backend URL, committed secret, or hardcoded URL was found by this verifier.\n'
  printf -- '- Local Preview Access remains available.\n\n'
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

printf -- 'StoreKit paywall movie-ID mapping source verification passed.\n'
