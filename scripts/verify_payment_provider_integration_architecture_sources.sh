#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_PAYMENT_PROVIDER_INTEGRATION_ARCHITECTURE.md"
OUT_DIR="/private/tmp/highfive-phase-42-0b-payment-provider-evidence"
JSON_OUT="$OUT_DIR/payment_provider_integration_architecture_source_verification.json"
MD_OUT="$OUT_DIR/payment_provider_integration_architecture_source_verification.md"

mkdir -p "$OUT_DIR"

checks=()
failures=()

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

add_check() {
  local id="$1"
  local label="$2"
  local pattern="$3"
  if rg -q -- "$pattern" "$DOC_PATH"; then
    checks+=("{\"id\":\"$(json_escape "$id")\",\"label\":\"$(json_escape "$label")\",\"status\":\"pass\"}")
  else
    checks+=("{\"id\":\"$(json_escape "$id")\",\"label\":\"$(json_escape "$label")\",\"status\":\"fail\"}")
    failures+=("$label")
  fi
}

add_combo_check() {
  local id="$1"
  local label="$2"
  shift 2
  local ok="true"
  local pattern
  for pattern in "$@"; do
    if ! rg -q -- "$pattern" "$DOC_PATH"; then
      ok="false"
      break
    fi
  done

  if [[ "$ok" == "true" ]]; then
    checks+=("{\"id\":\"$(json_escape "$id")\",\"label\":\"$(json_escape "$label")\",\"status\":\"pass\"}")
  else
    checks+=("{\"id\":\"$(json_escape "$id")\",\"label\":\"$(json_escape "$label")\",\"status\":\"fail\"}")
    failures+=("$label")
  fi
}

if [[ ! -f "$DOC_PATH" ]]; then
  printf '{"status":"fail","reason":"missing payment provider architecture doc","doc":"%s"}\n' "$DOC_PATH" > "$JSON_OUT"
  {
    printf '# Payment Provider Integration Architecture Source Verification\n\n'
    printf 'Status: fail\n\n'
    printf 'Missing document: `%s`\n' "$DOC_PATH"
  } > "$MD_OUT"
  exit 1
fi

add_check "revenuecat-storekit-preferred" "RevenueCat + StoreKit preferred" "RevenueCat \\+ StoreKit preferred|RevenueCat \\+ StoreKit is preferred|iOS paid access provider \\| RevenueCat \\+ StoreKit"
add_check "stripe-web-fallback" "Stripe web fallback only where Apple rules allow" "Stripe web fallback only where Apple rules allow|Stripe web where Apple rules allow|Apple rules allow"
add_check "payment-entitlement-service" "PaymentEntitlementService boundary" "PaymentEntitlementService"
add_check "store-provider-adapter" "StoreProviderAdapter boundary" "StoreProviderAdapter"
add_check "backend-service-layer" "BackendServiceLayer dependency" "BackendServiceLayer"
add_check "auth-service" "AuthService dependency" "AuthService"
add_check "highfive-user-id" "HighFive-owned user ID dependency" "HighFive-owned user ID"
add_check "entitlement-records" "entitlement records" "entitlement records|Entitlement records"
add_check "subscription-entitlement" "Subscription Entitlement model" "Subscription Entitlement Model|Subscription Entitlement"
add_check "purchase-state" "purchase state model" "Purchase State Model|purchase state model"
add_check "restore-architecture" "restore purchase architecture" "Restore Purchase Architecture|restore purchase architecture"
add_check "receipt-transaction-validation" "receipt / transaction validation policy" "Receipt / Transaction Validation Policy|receipt / transaction validation"
add_check "server-entitlement-validation" "server entitlement validation policy" "Server Entitlement Validation Policy|server entitlement validation"
add_check "refund-handling" "refund handling" "Refund / Revocation Handling|refund"
add_check "revocation-handling" "revocation handling" "Refund / Revocation Handling|revocation"
add_check "expired-entitlement" "expired entitlement handling" "Expired Entitlement Handling|expired entitlement"
add_check "playback-service" "PlaybackService dependency" "PlaybackService"
add_check "download-service" "DownloadService dependency" "DownloadService"
add_check "library-service" "LibraryService account dependency" "LibraryService account dependency|LibraryService"
add_check "local-preview" "local preview fallback" "local preview fallback|Local preview"
add_check "staging-payment" "staging payment model" "staging payment model|Staging payment model|Staging \\|"
add_check "production-payment" "production payment model" "production payment model|Production payment model|Production \\|"
add_check "credential-requirements" "Credential Requirements" "Credential Requirements"
add_check "backend-requirements" "Backend Requirements" "Backend Requirements"
add_check "app-store-product" "App Store product configuration requirements" "App Store product configuration requirements|App Store product configuration"
add_check "app-store-review" "App Store review requirements" "App Store review requirements|App Store review"
add_check "privacy-requirements" "Privacy Requirements" "Privacy Requirements"
add_check "rollback-strategy" "Rollback Strategy" "Rollback Strategy"
add_check "risk-register" "Risk Register" "Risk Register"
add_check "what-connects-first" "What Connects First" "What Connects First"
add_check "what-waits" "What Waits" "What Waits"
add_check "no-live-payment-provider" "No live payment provider" "No live payment provider"
add_check "no-storekit-implementation" "No StoreKit implementation" "No StoreKit implementation"
add_check "no-revenuecat-sdk-config" "No RevenueCat SDK/config" "No RevenueCat SDK/config|No RevenueCat SDK"
add_check "no-stripe-sdk-config" "No Stripe SDK/config" "No Stripe SDK/config|No Stripe SDK"
add_check "no-purchase-ui" "No purchase UI" "No purchase UI"
add_combo_check "no-sdk-url-token-secret-code" "No SDKs/URLs/tokens/secrets/app code changes" "No SDKs" "URLs" "tokens" "secrets" "app code changes"

status="pass"
if [[ "${#failures[@]}" -gt 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#042.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "claim": "source presence only; architecture evidence only; no live payment provider integration",\n'
  printf '  "checks": [\n'
  count="${#checks[@]}"
  for i in "${!checks[@]}"; do
    if [[ "$i" -lt $((count - 1)) ]]; then
      printf '    %s,\n' "${checks[$i]}"
    else
      printf '    %s\n' "${checks[$i]}"
    fi
  done
  printf '  ],\n'
  printf '  "failures": ['
  for i in "${!failures[@]}"; do
    escaped="$(json_escape "${failures[$i]}")"
    if [[ "$i" -lt $((${#failures[@]} - 1)) ]]; then
      printf '"%s",' "$escaped"
    else
      printf '"%s"' "$escaped"
    fi
  done
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Payment Provider Integration Architecture Source Verification\n\n'
  printf 'Status: %s\n\n' "$status"
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf 'Scope: source presence only. This evidence does not claim live RevenueCat, StoreKit, Stripe, purchases, subscriptions, paywalls, restore purchase behavior, product IDs, credentials, provider config, SDKs, URLs, or app-code integration exists.\n\n'
  printf '## Checks\n\n'
  for check in "${checks[@]}"; do
    label="$(printf '%s' "$check" | sed -E 's/.*"label":"([^"]+)".*/\1/')"
    check_status="$(printf '%s' "$check" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    printf -- '- %s: %s\n' "$label" "$check_status"
  done
  if [[ "${#failures[@]}" -gt 0 ]]; then
    printf '\n## Missing Evidence\n\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  fi
} > "$MD_OUT"

printf 'Payment provider integration architecture source verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_OUT"
printf 'Markdown: %s\n' "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
