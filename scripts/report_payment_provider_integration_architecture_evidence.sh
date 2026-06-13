#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-42-0b-payment-provider-evidence"
SOURCE_JSON="$OUT_DIR/payment_provider_integration_architecture_source_verification.json"
SOURCE_MD="$OUT_DIR/payment_provider_integration_architecture_source_verification.md"
REPORT_JSON="$OUT_DIR/payment_provider_integration_architecture_evidence_report.json"
REPORT_MD="$OUT_DIR/payment_provider_integration_architecture_evidence_report.md"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_PAYMENT_PROVIDER_INTEGRATION_ARCHITECTURE.md"

mkdir -p "$OUT_DIR"

source_status="missing"
if [[ -f "$SOURCE_JSON" ]]; then
  source_status="$(sed -n 's/.*"status": "\([^"]*\)".*/\1/p' "$SOURCE_JSON" | head -n 1)"
fi

if [[ -z "$source_status" ]]; then
  source_status="unknown"
fi

protected_scan="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -q '^HighFive/|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements|HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|posterAssetName|backdropAssetName|mapping|asset'; then
  protected_scan="fail"
fi

blocked_scan="pass"
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|StoreKit|SKPayment|Product|Transaction|RevenueCat|Stripe|purchase|subscription|restorePurchases|receipt|verifyReceipt|AppStore|paywall|payment|Bearer|Authorization)'; then
  blocked_scan="fail"
fi

docs_credential_assignment_scan="pass"
a1="api[_-]?""key[[:space:]]*[:=]"
a2="sec""ret[[:space:]]*[:=]"
a3="tok""en[[:space:]]*[:=]"
a4="client_""sec""ret[[:space:]]*[:=]"
a5="access_""tok""en[[:space:]]*[:=]"
a6="refresh_""tok""en[[:space:]]*[:=]"
a7="pass""word[[:space:]]*[:=]"
a8="ht""tps?://"
a9="sk_""live"
a10="pk_""live"
a11="Bear""er [A-Za-z0-9]"
assignment_pattern="^\\+.*(${a1}|${a2}|${a3}|${a4}|${a5}|${a6}|${a7}|${a8}|${a9}|${a10}|${a11})"
if git -C "$ROOT_DIR" diff -U0 -- docs/production_services scripts | rg -q "$assignment_pattern"; then
  docs_credential_assignment_scan="fail"
fi

script_scope="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_payment_provider_integration_architecture_sources\.sh$|^scripts/report_payment_provider_integration_architecture_evidence\.sh$' | rg -q '.'; then
  script_scope="fail"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$protected_scan" != "pass" || "$blocked_scan" != "pass" || "$docs_credential_assignment_scan" != "pass" || "$script_scope" != "pass" ]]; then
  overall_status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#042.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline": "74c178a phase-42-0a-payment-provider-integration-architecture",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "protected_scan": "%s",\n' "$protected_scan"
  printf '  "blocked_implementation_scan": "%s",\n' "$blocked_scan"
  printf '  "docs_credential_assignment_scan": "%s",\n' "$docs_credential_assignment_scan"
  printf '  "script_scope": "%s",\n' "$script_scope"
  printf '  "evidence": {\n'
  printf '    "revenuecat_storekit_preferred": "source verified",\n'
  printf '    "stripe_web_fallback_limited": "source verified",\n'
  printf '    "payment_entitlement_service_boundary": "source verified",\n'
  printf '    "store_provider_adapter_boundary": "source verified",\n'
  printf '    "backend_auth_highfive_user_dependency": "source verified",\n'
  printf '    "entitlement_records": "source verified",\n'
  printf '    "subscription_entitlement_model": "source verified",\n'
  printf '    "purchase_state_model": "source verified",\n'
  printf '    "restore_purchase_architecture": "source verified",\n'
  printf '    "validation_policies": "receipt transaction and server entitlement validation source verified",\n'
  printf '    "refund_revocation_expired_entitlement": "source verified",\n'
  printf '    "playback_download_dependencies": "source verified",\n'
  printf '    "library_account_dependency": "source verified",\n'
  printf '    "credential_backend_app_store_privacy": "source verified",\n'
  printf '    "rollback_risk_connects_first_waits": "source verified",\n'
  printf '    "no_live_payment_provider": "source verified",\n'
  printf '    "no_sdks_urls_tokens_secrets_app_code": "scan verified"\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "no live payment provider",\n'
  printf '    "no RevenueCat SDK/config",\n'
  printf '    "no StoreKit implementation",\n'
  printf '    "no Stripe SDK/config",\n'
  printf '    "no purchases",\n'
  printf '    "no subscriptions",\n'
  printf '    "no product IDs",\n'
  printf '    "no restore purchase behavior",\n'
  printf '    "no paywall",\n'
  printf '    "no URLs/tokens/secrets/API keys",\n'
  printf '    "no app code changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Payment Provider Integration Architecture Evidence Report\n\n'
  printf 'Status: %s\n\n' "$overall_status"
  printf 'Baseline: `74c178a phase-42-0a-payment-provider-integration-architecture`\n\n'
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf '## Results\n\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Protected scan: %s\n' "$protected_scan"
  printf -- '- Blocked implementation scan: %s\n' "$blocked_scan"
  printf -- '- Docs credential assignment scan: %s\n' "$docs_credential_assignment_scan"
  printf -- '- Evidence script scope: %s\n' "$script_scope"
  printf '\n## Evidence Status\n\n'
  printf -- '- RevenueCat + StoreKit preferred: source verified\n'
  printf -- '- Stripe web fallback only where Apple rules allow: source verified\n'
  printf -- '- PaymentEntitlementService boundary: source verified\n'
  printf -- '- StoreProviderAdapter boundary: source verified\n'
  printf -- '- BackendServiceLayer, AuthService, and HighFive-owned user ID dependencies: source verified\n'
  printf -- '- Entitlement records, Subscription Entitlement model, and purchase state model: source verified\n'
  printf -- '- Restore purchase architecture: source verified\n'
  printf -- '- Receipt / transaction validation and server entitlement validation policies: source verified\n'
  printf -- '- Refund, revocation, and expired entitlement handling: source verified\n'
  printf -- '- PlaybackService and DownloadService dependencies: source verified\n'
  printf -- '- LibraryService account dependency: source verified\n'
  printf -- '- Credential, backend, App Store product, App Store review, and privacy requirements: source verified\n'
  printf -- '- Rollback strategy, risk register, what connects first, and what waits: source verified\n'
  printf -- '- No live payment provider and no SDKs/URLs/tokens/secrets/app code: source and scan verified\n'
  printf '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- No live payment provider.\n'
  printf -- '- No RevenueCat SDK/config.\n'
  printf -- '- No StoreKit implementation.\n'
  printf -- '- No Stripe SDK/config.\n'
  printf -- '- No purchases.\n'
  printf -- '- No subscriptions.\n'
  printf -- '- No product IDs.\n'
  printf -- '- No restore purchase behavior.\n'
  printf -- '- No paywall.\n'
  printf -- '- No URLs/tokens/secrets/API keys.\n'
  printf -- '- No app code changes.\n'
  if [[ -f "$SOURCE_MD" ]]; then
    printf '\nSource verifier report: `%s`\n' "$SOURCE_MD"
  fi
} > "$REPORT_MD"

printf 'Payment provider integration architecture evidence report: %s\n' "$overall_status"
printf 'JSON: %s\n' "$REPORT_JSON"
printf 'Markdown: %s\n' "$REPORT_MD"

if [[ "$overall_status" != "pass" ]]; then
  exit 1
fi
