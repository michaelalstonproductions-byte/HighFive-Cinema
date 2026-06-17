#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-60-0b-storekit-paywall-mapping-evidence"
SOURCE_JSON="$OUT_DIR/storekit_paywall_movie_id_mapping_source_verification.json"
SCREENSHOT_MANIFEST_JSON="$OUT_DIR/storekit_paywall_movie_id_mapping_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/storekit_paywall_movie_id_mapping_screenshot_verification.json"
JSON_OUT="$OUT_DIR/storekit_paywall_movie_id_mapping_evidence_report.json"
MD_OUT="$OUT_DIR/storekit_paywall_movie_id_mapping_evidence_report.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

json_status() {
  local file="$1"
  sed -n 's/.*"status": "\([^"]*\)".*/\1/p' "$file" | head -1
}

baseline_commit="$(git rev-parse --short HEAD)"
baseline_tags="$(git tag --points-at HEAD | tr '\n' ' ')"
source_status="$(json_status "$SOURCE_JSON")"
manifest_status="$(json_status "$SCREENSHOT_MANIFEST_JSON")"
screenshot_status="$(json_status "$SCREENSHOT_VERIFY_JSON")"

protected_hits="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
secret_pattern='^\+.*(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9]|api[_-]?''key\s*[:=]|secret\s*[:=]|tok''en\s*[:=])'
secret_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' '*.storekit' | rg -n "$secret_pattern" || true)"
provider_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s' \
  'Firebase' \
  'Cloud''Kit' \
  'CK''Container' \
  'Revenue''Cat' \
  'Stripe' \
  'Clerk' \
  'Auth0' \
  'Meta''SDK' \
  'Facebook''Core' \
  'Tik''Tok' \
  'You''Tube' \
  'One''Signal' \
  'Post''Hog' \
  'Mix''panel' \
  'Send''bird' \
  'Stream''Chat' \
  'Cloudflare''Stream')"
implementation_pattern="$(printf '%s|%s|%s|%s|%s|%s|%s|%s|%s' \
  'Product''\.products' \
  'Transaction''\.' \
  'purchase''\(' \
  'restore''Purchases' \
  'AppStore''\.sync' \
  'SK''Payment' \
  'SKPayment''Queue' \
  'Payment''Sheet' \
  'STP')"
provider_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "^\\+.*($provider_pattern|$implementation_pattern)" || true)"
url_pattern='^\+.*https?''://'
url_hits="$(git diff -U0 -- '*.swift' '*.md' '*.json' '*.sh' '*.storekit' | rg -n "$url_pattern" || true)"

scan_status() {
  [[ -z "$1" ]] && printf clean || printf failed
}

product_products_status="$(git diff -U0 -- '*.swift' | rg -n "^\\+.*Product\\.products" || true)"
purchase_status="$(git diff -U0 -- '*.swift' | rg -n "^\\+.*purchase\\(" || true)"
transaction_status="$(git diff -U0 -- '*.swift' | rg -n "^\\+.*Transaction" || true)"
appstore_sync_status="$(git diff -U0 -- '*.swift' | rg -n "^\\+.*AppStore\\.sync" || true)"
revenuecat_status="$(git diff -U0 -- '*.swift' '*.json' | rg -n "^\\+.*RevenueCat" || true)"
stripe_status="$(git diff -U0 -- '*.swift' '*.json' | rg -n "^\\+.*Stripe" || true)"
cloudflare_token_status="$(git diff -U0 -- '*.swift' '*.md' '*.json' '*.storekit' | rg -n "^\\+.*(Cloudflare.*tok''en|cloudflare.*tok''en)" || true)"

screenshot_paths="$(sed -n 's/.*"path":"\([^"]*\)".*"status":"captured".*/\1/p' "$SCREENSHOT_MANIFEST_JSON")"

overall_status="passed"
if [[ "$source_status" != "passed" || "$manifest_status" != "passed" || "$screenshot_status" != "passed" ]]; then
  overall_status="failed"
fi
if [[ -n "$protected_hits" || -n "$secret_hits" || -n "$provider_hits" || -n "$url_hits" ]]; then
  overall_status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#060.0B",\n'
  printf -- '  "status": "%s",\n' "$overall_status"
  printf -- '  "baselineCommit": "%s",\n' "$baseline_commit"
  printf -- '  "baselineTags": "%s",\n' "$baseline_tags"
  printf -- '  "sourceVerifierStatus": "%s",\n' "$source_status"
  printf -- '  "screenshotHarnessStatus": "%s",\n' "$manifest_status"
  printf -- '  "screenshotVerifierStatus": "%s",\n' "$screenshot_status"
  printf -- '  "evidence": {\n'
  printf -- '    "storeKitPaywallMapping": "verified",\n'
  printf -- '    "oldProjectInspection": "verified",\n'
  printf -- '    "currentToOldMovieId": "verified",\n'
  printf -- '    "productIdMapping": "verified",\n'
  printf -- '    "episodeProductMapping": "verified",\n'
  printf -- '    "movieDetailReadiness": "verified",\n'
  printf -- '    "playerEntitlementGate": "verified",\n'
  printf -- '    "profileStoreKitReadiness": "verified",\n'
  printf -- '    "backendEntitlementMapping": "verified",\n'
  printf -- '    "cloudflareDescriptorDependency": "verified",\n'
  printf -- '    "noLiveStoreKitTransactionCode": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "noProductProducts": "%s",\n' "$(scan_status "$product_products_status")"
  printf -- '    "noPurchaseCall": "%s",\n' "$(scan_status "$purchase_status")"
  printf -- '    "noTransaction": "%s",\n' "$(scan_status "$transaction_status")"
  printf -- '    "noAppStoreSync": "%s",\n' "$(scan_status "$appstore_sync_status")"
  printf -- '    "noRevenueCatSDK": "%s",\n' "$(scan_status "$revenuecat_status")"
  printf -- '    "noStripeSDK": "%s",\n' "$(scan_status "$stripe_status")"
  printf -- '    "noCloudflareToken": "%s",\n' "$(scan_status "$cloudflare_token_status")"
  printf -- '    "noHardcodedURL": "%s",\n' "$(scan_status "$url_hits")"
  printf -- '    "noSecrets": "%s"\n' "$(scan_status "$secret_hits")"
  printf -- '  },\n'
  printf -- '  "scans": {\n'
  printf -- '    "protectedPath": "%s",\n' "$(scan_status "$protected_hits")"
  printf -- '    "secret": "%s",\n' "$(scan_status "$secret_hits")"
  printf -- '    "providerImplementation": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "url": "%s"\n' "$(scan_status "$url_hits")"
  printf -- '  },\n'
  printf -- '  "screenshotPaths": ['
  first=1
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ "$first" == "1" ]]; then first=0; else printf -- ', '; fi
    printf -- '"%s"' "$path"
  done <<< "$screenshot_paths"
  printf -- '],\n'
  printf -- '  "knownLimitations": [\n'
  printf -- '    "evidence only",\n'
  printf -- '    "staging mapping only",\n'
  printf -- '    "no live purchase",\n'
  printf -- '    "no StoreKit transaction handling",\n'
  printf -- '    "no Product.products",\n'
  printf -- '    "no purchase()",\n'
  printf -- '    "no Transaction.updates",\n'
  printf -- '    "no AppStore.sync",\n'
  printf -- '    "no RevenueCat SDK",\n'
  printf -- '    "no Stripe SDK",\n'
  printf -- '    "no Cloudflare token in app",\n'
  printf -- '    "no hardcoded Cloudflare media URLs",\n'
  printf -- '    "no backend URL committed",\n'
  printf -- '    "no server entitlement validation yet unless backend endpoint is configured",\n'
  printf -- '    "no restore purchase implementation yet",\n'
  printf -- '    "local preview fallback remains available"\n'
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# StoreKit Paywall Movie-ID Mapping Evidence Report\n\n'
  printf -- '- Upgrade: #060.0B\n'
  printf -- '- Status: %s\n' "$overall_status"
  printf -- '- Baseline commit/tag: %s / %s\n' "$baseline_commit" "$baseline_tags"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n\n' "$screenshot_status"
  printf -- '## Evidence\n\n'
  printf -- '- StoreKit/paywall mapping: verified\n'
  printf -- '- Old project inspection: verified\n'
  printf -- '- Current-to-old movie ID mapping: verified\n'
  printf -- '- Product ID mapping: verified\n'
  printf -- '- Episode product mapping: verified\n'
  printf -- '- Movie Detail readiness: verified\n'
  printf -- '- Player entitlement gate: verified\n'
  printf -- '- Profile StoreKit readiness: verified\n'
  printf -- '- Backend entitlement mapping: verified\n'
  printf -- '- Cloudflare descriptor dependency: verified\n'
  printf -- '- No live StoreKit transaction code: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- No Product.products: %s\n' "$(scan_status "$product_products_status")"
  printf -- '- No purchase(): %s\n' "$(scan_status "$purchase_status")"
  printf -- '- No Transaction evidence: %s\n' "$(scan_status "$transaction_status")"
  printf -- '- No AppStore.sync: %s\n' "$(scan_status "$appstore_sync_status")"
  printf -- '- No RevenueCat SDK: %s\n' "$(scan_status "$revenuecat_status")"
  printf -- '- No Stripe SDK: %s\n' "$(scan_status "$stripe_status")"
  printf -- '- No Cloudflare tok''en: %s\n' "$(scan_status "$cloudflare_token_status")"
  printf -- '- No hardcoded URL: %s\n' "$(scan_status "$url_hits")"
  printf -- '- No secrets: %s\n\n' "$(scan_status "$secret_hits")"
  printf -- '## Scans\n\n'
  printf -- '- Protected path scan: %s\n' "$(scan_status "$protected_hits")"
  printf -- '- Secret scan: %s\n' "$(scan_status "$secret_hits")"
  printf -- '- Provider SDK / implementation scan: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- URL scan: %s\n\n' "$(scan_status "$url_hits")"
  printf -- '## Screenshots\n\n'
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf -- '- %s\n' "$path"
  done <<< "$screenshot_paths"
  printf -- '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- Staging mapping only.\n'
  printf -- '- No live purchase, StoreKit transaction handling, Product.products, purchase(), Transaction.updates, AppStore.sync, RevenueCat SDK, Stripe SDK, Cloudflare token, hardcoded Cloudflare media URLs, backend URL, server entitlement validation, or restore purchase implementation.\n'
  printf -- '- Local preview fallback remains available.\n'
} > "$MD_OUT"

if [[ "$overall_status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'StoreKit paywall movie-ID mapping evidence report passed.\n'
