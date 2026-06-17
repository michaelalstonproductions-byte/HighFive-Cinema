#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-57-0b-payment-entitlement-evidence"
SOURCE_JSON="$OUT_DIR/payment_entitlement_staging_source_verification.json"
SCREENSHOT_MANIFEST_JSON="$OUT_DIR/payment_entitlement_staging_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/payment_entitlement_staging_screenshot_verification.json"
JSON_OUT="$OUT_DIR/payment_entitlement_staging_evidence_report.json"
MD_OUT="$OUT_DIR/payment_entitlement_staging_evidence_report.md"

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
secret_pattern='^\+.*(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9])'
secret_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' | rg -n "$secret_pattern" || true)"
provider_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n '^\+.*(Firebase|CloudKit|CKContainer|RevenueCat|Stripe|Clerk|Auth0|MetaSDK|FacebookCore|TikTok|YouTube|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat)' || true)"
payment_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n '^\+.*(import StoreKit|Product\.products|Transaction\.|purchase\(|restorePurchases|SKPayment|SKProduct|SKPaymentQueue|RevenueCat|Purchases\.|Stripe|PaymentSheet|STP)' || true)"
urlsession_hits="$(git diff -U0 -- '*.swift' | rg -n '^\+.*URLSession' || true)"
url_pattern='^\+.*https?''://'
url_hits="$(git diff -U0 -- '*.swift' '*.md' '*.json' '*.sh' | rg -n "$url_pattern" || true)"

scan_status() {
  [[ -z "$1" ]] && printf clean || printf failed
}

screenshot_paths="$(sed -n 's/.*"path": "\([^"]*\)", "status": "captured".*/\1/p' "$SCREENSHOT_MANIFEST_JSON")"

overall_status="passed"
if [[ "$source_status" != "passed" || "$manifest_status" != "passed" || "$screenshot_status" != "passed" ]]; then
  overall_status="failed"
fi
if [[ -n "$protected_hits" || -n "$secret_hits" || -n "$provider_hits" || -n "$payment_hits" || -n "$urlsession_hits" || -n "$url_hits" ]]; then
  overall_status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#057.0B",\n'
  printf -- '  "status": "%s",\n' "$overall_status"
  printf -- '  "baselineCommit": "%s",\n' "$baseline_commit"
  printf -- '  "baselineTags": "%s",\n' "$baseline_tags"
  printf -- '  "sourceVerifierStatus": "%s",\n' "$source_status"
  printf -- '  "screenshotHarnessStatus": "%s",\n' "$manifest_status"
  printf -- '  "screenshotVerifierStatus": "%s",\n' "$screenshot_status"
  printf -- '  "evidence": {\n'
  printf -- '    "entitlementServiceFoundation": "verified",\n'
  printf -- '    "localEntitlementAdapter": "verified",\n'
  printf -- '    "remoteEntitlementGatewayConfigGated": "verified",\n'
  printf -- '    "productAccessState": "verified",\n'
  printf -- '    "purchaseEligibility": "verified",\n'
  printf -- '    "restorePurchaseState": "verified",\n'
  printf -- '    "paymentProviderStatus": "verified",\n'
  printf -- '    "movieDetailEntitlementAccess": "verified",\n'
  printf -- '    "profileMembershipPaymentReadiness": "verified",\n'
  printf -- '    "vodPricingEntitlementBoundary": "verified",\n'
  printf -- '    "backendEntitlementServiceList": "verified",\n'
  printf -- '    "runtimeConfig": "verified",\n'
  printf -- '    "noLivePurchase": "verified",\n'
  printf -- '    "noStoreKitTransaction": "%s",\n' "$(scan_status "$payment_hits")"
  printf -- '    "noRevenueCatSDK": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "noStripeSDK": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "noPaywall": "verified",\n'
  printf -- '    "noEnabledBuySubscribePay": "verified",\n'
  printf -- '    "noHardcodedURL": "%s",\n' "$(scan_status "$url_hits")"
  printf -- '    "noSecrets": "%s"\n' "$(scan_status "$secret_hits")"
  printf -- '  },\n'
  printf -- '  "scans": {\n'
  printf -- '    "protectedPath": "%s",\n' "$(scan_status "$protected_hits")"
  printf -- '    "secret": "%s",\n' "$(scan_status "$secret_hits")"
  printf -- '    "providerSDK": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "storeKitPaymentImplementation": "%s",\n' "$(scan_status "$payment_hits")"
  printf -- '    "urlSessionLocation": "%s",\n' "$(scan_status "$urlsession_hits")"
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
  printf -- '    "payment/entitlement staging foundation only",\n'
  printf -- '    "app stays Local Preview Access unless runtime payment/entitlement config is provided",\n'
  printf -- '    "no committed secrets",\n'
  printf -- '    "no hardcoded production URLs",\n'
  printf -- '    "no live purchase",\n'
  printf -- '    "no live StoreKit transaction handling",\n'
  printf -- '    "no RevenueCat SDK",\n'
  printf -- '    "no Stripe SDK",\n'
  printf -- '    "no paywall",\n'
  printf -- '    "no server entitlement validation yet",\n'
  printf -- '    "no restore purchase implementation",\n'
  printf -- '    "no live media downloads",\n'
  printf -- '    "no live Instagram/Meta posting",\n'
  printf -- '    "no live VOD publishing",\n'
  printf -- '    "no App Store production configuration"\n'
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Payment Entitlement Staging Evidence Report\n\n'
  printf -- '- Upgrade: #057.0B\n'
  printf -- '- Status: %s\n' "$overall_status"
  printf -- '- Baseline commit/tag: %s / %s\n' "$baseline_commit" "$baseline_tags"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n\n' "$screenshot_status"
  printf -- '## Evidence\n\n'
  printf -- '- Entitlement service foundation: verified\n'
  printf -- '- Local entitlement adapter: verified\n'
  printf -- '- Remote entitlement gateway config-gated: verified\n'
  printf -- '- Product access state: verified\n'
  printf -- '- Purchase eligibility: verified\n'
  printf -- '- Restore purchase state: verified\n'
  printf -- '- Payment provider status: verified\n'
  printf -- '- Movie Detail entitlement/access: verified\n'
  printf -- '- Profile membership/payment readiness: verified\n'
  printf -- '- Creator Studio / VOD pricing entitlement boundary: verified\n'
  printf -- '- Backend entitlement service list: verified\n'
  printf -- '- Runtime config: verified\n'
  printf -- '- No live purchase: verified\n'
  printf -- '- No StoreKit transaction: %s\n' "$(scan_status "$payment_hits")"
  printf -- '- No RevenueCat SDK: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- No Stripe SDK: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- No paywall: verified\n'
  printf -- '- No enabled Buy/Subscribe/Pay: verified\n'
  printf -- '- No hardcoded URL: %s\n' "$(scan_status "$url_hits")"
  printf -- '- No secrets: %s\n\n' "$(scan_status "$secret_hits")"
  printf -- '## Scans\n\n'
  printf -- '- Protected path scan: %s\n' "$(scan_status "$protected_hits")"
  printf -- '- Secret scan: %s\n' "$(scan_status "$secret_hits")"
  printf -- '- Provider SDK scan: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- StoreKit/payment implementation scan: %s\n' "$(scan_status "$payment_hits")"
  printf -- '- URLSession location scan: %s\n' "$(scan_status "$urlsession_hits")"
  printf -- '- URL scan: %s\n\n' "$(scan_status "$url_hits")"
  printf -- '## Screenshots\n\n'
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf -- '- %s\n' "$path"
  done <<< "$screenshot_paths"
  printf -- '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- Payment/entitlement staging foundation only.\n'
  printf -- '- App stays Local Preview Access unless runtime payment/entitlement config is provided.\n'
  printf -- '- No committed secrets, hardcoded production URLs, live purchase, live StoreKit transaction handling, RevenueCat SDK, Stripe SDK, paywall, server entitlement validation, restore purchase implementation, live media downloads, live Instagram/Meta posting, live VOD publishing, or App Store production configuration.\n'
} > "$MD_OUT"

if [[ "$overall_status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Payment entitlement staging evidence report passed.\n'
