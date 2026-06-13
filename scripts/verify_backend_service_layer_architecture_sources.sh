#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_BACKEND_SERVICE_LAYER_ARCHITECTURE.md"
OUT_DIR="/private/tmp/highfive-phase-40-0b-backend-service-evidence"
JSON_OUT="$OUT_DIR/backend_service_layer_architecture_source_verification.json"
MD_OUT="$OUT_DIR/backend_service_layer_architecture_source_verification.md"

mkdir -p "$OUT_DIR"

checks=()
failures=()

add_check() {
  local id="$1"
  local label="$2"
  local pattern="$3"
  if rg -q -- "$pattern" "$DOC_PATH"; then
    checks+=("{\"id\":\"$id\",\"label\":\"$label\",\"status\":\"pass\"}")
  else
    checks+=("{\"id\":\"$id\",\"label\":\"$label\",\"status\":\"fail\"}")
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
    checks+=("{\"id\":\"$id\",\"label\":\"$label\",\"status\":\"pass\"}")
  else
    checks+=("{\"id\":\"$id\",\"label\":\"$label\",\"status\":\"fail\"}")
    failures+=("$label")
  fi
}

if [[ ! -f "$DOC_PATH" ]]; then
  printf '{"status":"fail","reason":"missing backend architecture doc","doc":"%s"}\n' "$DOC_PATH" > "$JSON_OUT"
  {
    printf '# Backend Service Layer Architecture Source Verification\n\n'
    printf 'Status: fail\n\n'
    printf 'Missing document: `%s`\n' "$DOC_PATH"
  } > "$MD_OUT"
  exit 1
fi

add_check "supabase-hybrid" "Supabase hybrid preferred" "Supabase hybrid is preferred|Backend model \\| Supabase hybrid"
add_check "custom-api" "Custom API fallback" "Custom API remains the fallback|Custom API is fallback|Custom API \\|"
add_check "backend-boundary" "BackendServiceLayer boundary" "BackendServiceLayer"
add_check "account-records" "account identity records" "AccountIdentityRecord|account identity"
add_check "provider-mapping" "provider identity mapping" "ProviderIdentityMapping|provider identity mapping"
add_check "catalog-records" "catalog records" "CatalogRecord|Catalog records"
add_check "library-sync" "library sync records" "LibrarySyncRecord|Library sync"
add_check "entitlements" "entitlement records" "EntitlementRecord|Entitlement records"
add_check "playback-mediation" "playback source mediation records" "PlaybackSourceMediationRecord|Playback source mediation|source mediation"
add_check "download-policy" "download policy records" "DownloadPolicyRecord|Download policy"
add_check "communication-records" "communication records" "CommunicationRecord|Communication table"
add_check "launch-records" "launch campaign records" "LaunchCampaignRecord|Launch campaign"
add_check "delivery-records" "delivery package records" "DeliveryPackageRecord|Delivery package"
add_check "notification-preferences" "notification preference records" "NotificationPreferenceRecord|Notification preference"
add_check "analytics-allowlist" "analytics event allowlist boundary" "AnalyticsEventAllowlistRecord|event allowlist"
add_check "admin-support" "admin/support boundary" "AdminSupportRecord|admin/support boundary|Admin/support"
add_check "migration-ownership" "migration ownership" "migration owner|migration ownership|Schema migration"
add_combo_check "environment-model" "local/staging/production environment model" "Environment Model" "Local" "Staging" "Production"
add_check "credential-requirements" "credential requirements" "Credential Requirements"
add_check "server-requirements" "server requirements" "Server Requirements"
add_check "app-store-privacy" "App Store/privacy requirements" "App Store And Privacy Requirements|Privacy labels"
add_check "rollback" "rollback strategy" "Rollback Strategy|rollback"
add_check "risk-register" "risk register" "Risk Register"
add_check "connects-first" "what connects first" "What Connects First"
add_check "what-waits" "what waits" "What Waits"
add_check "no-live-backend" "no live backend provider" "No live backend provider is connected|Local adapters only"
add_combo_check "no-live-secrets-sdk-app-code" "no URLs/tokens/secrets/SDKs/app code changes" "No URLs|backend URLs" "tokens" "secrets" "SDKs" "app code"

status="pass"
if [[ "${#failures[@]}" -gt 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#040.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "claim": "source presence only; architecture evidence only; no live backend provider integration",\n'
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
    escaped="${failures[$i]//\"/\\\"}"
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
  printf '# Backend Service Layer Architecture Source Verification\n\n'
  printf 'Status: %s\n\n' "$status"
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf 'Scope: source presence only. This evidence does not claim live Supabase, custom API, backend URLs, credentials, provider config, SDKs, or app-code integration exists.\n\n'
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

printf 'Backend service layer architecture source verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_OUT"
printf 'Markdown: %s\n' "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
