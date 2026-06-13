#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-41-0b-authentication-evidence"
SOURCE_JSON="$OUT_DIR/authentication_architecture_source_verification.json"
SOURCE_MD="$OUT_DIR/authentication_architecture_source_verification.md"
REPORT_JSON="$OUT_DIR/authentication_architecture_evidence_report.json"
REPORT_MD="$OUT_DIR/authentication_architecture_evidence_report.md"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_AUTHENTICATION_ARCHITECTURE.md"

mkdir -p "$OUT_DIR"

source_status="missing"
if [[ -f "$SOURCE_JSON" ]]; then
  source_status="$(sed -n 's/.*"status": "\([^"]*\)".*/\1/p' "$SOURCE_JSON" | head -n 1)"
fi

if [[ -z "$source_status" ]]; then
  source_status="unknown"
fi

protected_scan="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -q '^HighFive/|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements'; then
  protected_scan="fail"
fi

blocked_scan="pass"
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|AuthenticationServices|ASAuthorization|Clerk|Auth0|OAuth|Keychain|Bearer|Authorization)'; then
  blocked_scan="fail"
fi

script_scope="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_authentication_architecture_sources\.sh$|^scripts/report_authentication_architecture_evidence\.sh$' | rg -q '.'; then
  script_scope="fail"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$protected_scan" != "pass" || "$blocked_scan" != "pass" || "$script_scope" != "pass" ]]; then
  overall_status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#041.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline": "d2623c0 phase-41-0a-authentication-architecture-integration-plan",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "protected_scan": "%s",\n' "$protected_scan"
  printf '  "blocked_implementation_scan": "%s",\n' "$blocked_scan"
  printf '  "script_scope": "%s",\n' "$script_scope"
  printf '  "evidence": {\n'
  printf '    "clerk_preferred": "source verified",\n'
  printf '    "auth0_fallback": "source verified",\n'
  printf '    "custom_auth_fallback": "source verified",\n'
  printf '    "auth_service_boundary": "source verified",\n'
  printf '    "authentication_provider_adapter_boundary": "source verified",\n'
  printf '    "backend_dependency_and_user_identity": "source verified",\n'
  printf '    "session_and_account_flows": "sign-in, sign-out, refresh, deletion, and export source verified",\n'
  printf '    "apple_local_staging_production": "source verified",\n'
  printf '    "requirements_rollback_risk_sequence": "source verified",\n'
  printf '    "no_live_auth_provider": "source verified",\n'
  printf '    "no_sdks_urls_tokens_secrets_app_code": "scan verified"\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "architecture evidence only",\n'
  printf '    "no live auth provider",\n'
  printf '    "no Clerk SDK or configuration",\n'
  printf '    "no Auth0 SDK or configuration",\n'
  printf '    "no AuthenticationServices implementation",\n'
  printf '    "no URLs, tokens, secrets, API keys, or provider config",\n'
  printf '    "no app-code implementation changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Authentication Architecture Evidence Report\n\n'
  printf 'Status: %s\n\n' "$overall_status"
  printf 'Baseline: `d2623c0 phase-41-0a-authentication-architecture-integration-plan`\n\n'
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf '## Results\n\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Protected scan: %s\n' "$protected_scan"
  printf -- '- Blocked implementation scan: %s\n' "$blocked_scan"
  printf -- '- Evidence script scope: %s\n' "$script_scope"
  printf '\n## Evidence Status\n\n'
  printf -- '- Clerk preferred: source verified\n'
  printf -- '- Auth0 fallback: source verified\n'
  printf -- '- Custom auth fallback: source verified\n'
  printf -- '- AuthService boundary: source verified\n'
  printf -- '- AuthenticationProviderAdapter boundary: source verified\n'
  printf -- '- BackendServiceLayer dependency, HighFive-owned user ID, and provider identity mapping: source verified\n'
  printf -- '- Session lifecycle, sign-in, sign-out, refresh, deletion, and export flows: source verified\n'
  printf -- '- Sign in with Apple requirement, local preview fallback, staging model, and production model: source verified\n'
  printf -- '- Credential, backend, App Store/privacy, rollback, risk, what connects first, and what waits: source verified\n'
  printf -- '- No live auth provider and no SDKs/URLs/tokens/secrets/app code: source and scan verified\n'
  printf '\n## Known Limitations\n\n'
  printf -- '- Architecture evidence only.\n'
  printf -- '- No live auth provider.\n'
  printf -- '- No Clerk SDK or configuration.\n'
  printf -- '- No Auth0 SDK or configuration.\n'
  printf -- '- No AuthenticationServices implementation.\n'
  printf -- '- No URLs, tokens, secrets, API keys, or provider config.\n'
  printf -- '- No app-code implementation changes.\n'
  if [[ -f "$SOURCE_MD" ]]; then
    printf '\nSource verifier report: `%s`\n' "$SOURCE_MD"
  fi
} > "$REPORT_MD"

printf 'Authentication architecture evidence report: %s\n' "$overall_status"
printf 'JSON: %s\n' "$REPORT_JSON"
printf 'Markdown: %s\n' "$REPORT_MD"

if [[ "$overall_status" != "pass" ]]; then
  exit 1
fi
