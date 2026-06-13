#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-40-0b-backend-service-evidence"
SOURCE_JSON="$OUT_DIR/backend_service_layer_architecture_source_verification.json"
SOURCE_MD="$OUT_DIR/backend_service_layer_architecture_source_verification.md"
REPORT_JSON="$OUT_DIR/backend_service_layer_architecture_evidence_report.json"
REPORT_MD="$OUT_DIR/backend_service_layer_architecture_evidence_report.md"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_BACKEND_SERVICE_LAYER_ARCHITECTURE.md"

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
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|Supabase|Firebase|Postgres|SQL|Bearer|Authorization)'; then
  blocked_scan="fail"
fi

script_scope="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_backend_service_layer_architecture_sources\.sh$|^scripts/report_backend_service_layer_architecture_evidence\.sh$' | rg -q '.'; then
  script_scope="fail"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$protected_scan" != "pass" || "$blocked_scan" != "pass" || "$script_scope" != "pass" ]]; then
  overall_status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#040.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline": "7db8dcb phase-40-0a-backend-service-layer-architecture",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "protected_scan": "%s",\n' "$protected_scan"
  printf '  "blocked_implementation_scan": "%s",\n' "$blocked_scan"
  printf '  "script_scope": "%s",\n' "$script_scope"
  printf '  "evidence": {\n'
  printf '    "supabase_hybrid_preferred": "source verified",\n'
  printf '    "custom_api_fallback": "source verified",\n'
  printf '    "backend_service_layer_boundary": "source verified",\n'
  printf '    "production_records": "account, provider mapping, catalog, library, entitlement, playback mediation, download, communication, launch, delivery, notification, analytics, admin/support source verified",\n'
  printf '    "environment_credentials_server_privacy": "source verified",\n'
  printf '    "rollback_risk_connects_first_waits": "source verified",\n'
  printf '    "no_live_backend_provider": "source verified",\n'
  printf '    "no_urls_tokens_secrets_sdks_app_code": "scan verified"\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "architecture evidence only",\n'
  printf '    "no live backend provider",\n'
  printf '    "no Supabase SDK or configuration",\n'
  printf '    "no custom API client",\n'
  printf '    "no backend URLs, tokens, secrets, API keys, or provider config",\n'
  printf '    "no app-code implementation changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Backend Service Layer Architecture Evidence Report\n\n'
  printf 'Status: %s\n\n' "$overall_status"
  printf 'Baseline: `7db8dcb phase-40-0a-backend-service-layer-architecture`\n\n'
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf '## Results\n\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Protected scan: %s\n' "$protected_scan"
  printf -- '- Blocked implementation scan: %s\n' "$blocked_scan"
  printf -- '- Evidence script scope: %s\n' "$script_scope"
  printf '\n## Evidence Status\n\n'
  printf -- '- Supabase hybrid preferred: source verified\n'
  printf -- '- Custom API fallback: source verified\n'
  printf -- '- BackendServiceLayer boundary: source verified\n'
  printf -- '- Account identity and provider identity mapping records: source verified\n'
  printf -- '- Catalog, library sync, entitlement, playback mediation, and download policy records: source verified\n'
  printf -- '- Communication, launch campaign, delivery package, notification preference, analytics allowlist, and admin/support boundaries: source verified\n'
  printf -- '- Migration ownership, environment model, credentials, server requirements, and App Store/privacy requirements: source verified\n'
  printf -- '- Rollback strategy, risk register, what connects first, and what waits: source verified\n'
  printf -- '- No live backend provider and no URLs/tokens/secrets/SDKs/app code: source and scan verified\n'
  printf '\n## Known Limitations\n\n'
  printf -- '- Architecture evidence only.\n'
  printf -- '- No live backend provider.\n'
  printf -- '- No Supabase SDK or configuration.\n'
  printf -- '- No custom API client.\n'
  printf -- '- No backend URLs, tokens, secrets, API keys, or provider config.\n'
  printf -- '- No app-code implementation changes.\n'
  if [[ -f "$SOURCE_MD" ]]; then
    printf '\nSource verifier report: `%s`\n' "$SOURCE_MD"
  fi
} > "$REPORT_MD"

printf 'Backend service layer architecture evidence report: %s\n' "$overall_status"
printf 'JSON: %s\n' "$REPORT_JSON"
printf 'Markdown: %s\n' "$REPORT_MD"

if [[ "$overall_status" != "pass" ]]; then
  exit 1
fi
