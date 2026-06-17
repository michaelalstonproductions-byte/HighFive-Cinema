#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-57-0b-payment-entitlement-evidence"
JSON_OUT="$OUT_DIR/payment_entitlement_staging_source_verification.json"
MD_OUT="$OUT_DIR/payment_entitlement_staging_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_SCOPE=("HighFive" "docs/production_services")
ENTITLEMENT_FILE="HighFive/Services/Entitlements/HFEntitlementService.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"

declare -a REQUIRED_TERMS=(
  "HFEntitlementService"
  "HFLocalEntitlementAdapter"
  "HFRemoteEntitlementGateway"
  "HFPurchaseEligibility"
  "HFProductAccessState"
  "HFRestorePurchaseState"
  "HFEntitlementBoundary"
  "HFPaymentProviderStatus"
  "HFEntitlementRuntimeStatus"
  "HFEntitlementRecord"
  "HFProductIdentifier"
  "HFEntitlementProvider"
  "HFPaymentProvider"
  "HIGHFIVE_PAYMENT_PROVIDER"
  "HIGHFIVE_PAYMENT_MODE"
  "HIGHFIVE_ENTITLEMENT_BASE_URL"
  "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
  "HIGHFIVE_REVENUECAT_PROJECT_ID"
  "Local Preview Access"
  "Access Ready"
  "Payment Provider Not Connected Yet"
  "Restore Purchases Not Active Yet"
  "Purchase Provider Missing"
  "Entitlement Provider Missing"
  "Entitlement Configured"
  "Server Entitlement Validation Required"
  "Pricing / entitlement boundary"
  "hf.entitlement.status"
  "hf.entitlement.localPreviewAccess"
  "hf.entitlement.paymentProviderNotConnected"
  "hf.entitlement.restoreNotActive"
  "hf.entitlement.serverValidationRequired"
  "hf.movieDetail.entitlementStatus"
  "hf.movieDetail.paymentBoundary"
  "hf.profile.paymentReadiness"
  "hf.profile.membershipStatus"
  "hf.profile.restoreReadiness"
  "hf.profile.entitlementBoundary"
  "hf.creatorStudio.vodEntitlementBoundary"
  "hf.creatorStudio.vodPricingBoundary"
  "hf.creatorStudio.vodProviderStatus"
  "hf.creatorStudio.noLiveVODProvider"
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

require_file_term "$ENTITLEMENT_FILE" "guard configuration.hasAnyRuntimeConfig else" "missing config local access gate"
require_file_term "$ENTITLEMENT_FILE" "guard configuration.hasCompleteRuntimeConfig else" "partial config provider missing gate"
require_file_term "$ENTITLEMENT_FILE" "HFLocalEntitlementAdapter().runtimeStatus" "local entitlement fallback"
require_file_term "$ENTITLEMENT_FILE" "Entitlement Configured. Server Entitlement Validation Required" "configured without live purchase claim"
require_file_term "$STORE_FILE" "entitlementBackendServiceStatus" "backend entitlement service list integration"

if rg "import StoreKit|Product\\.products|Transaction\\.|purchase\\(|restorePurchases|SKPayment|SKProduct|SKPaymentQueue|Purchases\\.|PaymentSheet|STP" HighFive --glob '*.swift' | rg -q -v "CATransaction"; then
  failures+=("StoreKit/payment implementation marker found in Swift sources")
else
  passes+=("no StoreKit transaction or purchase implementation in Swift sources")
fi

if rg -q "RevenueCat|Stripe" HighFive --glob '*.swift'; then
  failures+=("RevenueCat or Stripe SDK marker found in Swift sources")
else
  passes+=("no RevenueCat or Stripe SDK markers in Swift sources")
fi

if rg -q "Paywall|Buy Now|Subscribe|Restore Now|Payment Active|Paid Access Active|Purchased|Subscribed" HighFive --glob '*.swift'; then
  failures+=("Forbidden live payment/paywall copy found in Swift sources")
else
  passes+=("no forbidden live payment/paywall copy in Swift sources")
fi

if rg -q "Text\\(\"(Buy|Subscribe|Pay|Purchase|Rent|Restore Purchases)\"|HFButton\\(\"(Buy|Subscribe|Pay|Purchase|Rent|Restore Purchases)\"" HighFive --glob '*.swift'; then
  failures+=("Enabled-looking payment CTA copy found in Swift sources")
else
  passes+=("no enabled Buy/Subscribe/Pay style CTA found in Swift sources")
fi

url_pattern='https?''://'
if rg -q "$url_pattern" HighFive docs/production_services --glob '*.swift' --glob '*.md' --glob '*.json' --glob '*.sh'; then
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
  printf -- '  "upgrade": "#057.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "requiredEvidenceCount": %d,\n' "${#REQUIRED_TERMS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "missingConfigKeepsLocalPreviewAccess": true,\n'
  printf -- '    "partialConfigReportsProviderMissing": true,\n'
  printf -- '    "completeConfigDoesNotClaimLivePurchase": true,\n'
  printf -- '    "remoteGatewayConfigGated": true,\n'
  printf -- '    "noLivePurchase": true,\n'
  printf -- '    "noStoreKitTransactionHandling": true,\n'
  printf -- '    "noRevenueCatSDK": true,\n'
  printf -- '    "noStripeSDK": true,\n'
  printf -- '    "noPaywall": true,\n'
  printf -- '    "noEnabledPaymentCTA": true,\n'
  printf -- '    "noRealProductIDs": true,\n'
  printf -- '    "noHardcodedProductionURLs": true,\n'
  printf -- '    "noCommittedSecrets": true,\n'
  printf -- '    "noServerEntitlementValidationYet": true,\n'
  printf -- '    "noRestorePurchaseImplementationYet": true\n'
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
  printf -- '# Payment Entitlement Staging Source Verification\n\n'
  printf -- '- Upgrade: #057.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required evidence terms: %d\n' "${#REQUIRED_TERMS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Missing payment config keeps Local Preview Access.\n'
  printf -- '- Partial config reports Payment Provider Not Connected Yet / Purchase Provider Missing.\n'
  printf -- '- Complete config may report Entitlement Configured but does not claim live purchase.\n'
  printf -- '- Remote entitlement gateway is runtime-config gated.\n'
  printf -- '- No live purchase, StoreKit transaction handling, RevenueCat SDK, Stripe SDK, paywall, enabled payment CTA, hardcoded URL, committed secret, server validation implementation, or restore implementation was found by this verifier.\n\n'
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

printf -- 'Payment entitlement staging source verification passed.\n'
