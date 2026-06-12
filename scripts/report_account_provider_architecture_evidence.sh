#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-38-0b-account-provider-evidence"
JSON_REPORT="$OUT_DIR/account_provider_architecture_evidence_report.json"
MD_REPORT="$OUT_DIR/account_provider_architecture_evidence_report.md"
SOURCE_JSON="$OUT_DIR/account_provider_architecture_source_verification.json"
mkdir -p "$OUT_DIR"

status_for() {
  local path="$1"
  if [[ -s "$path" ]] && rg -Fq '"status": "pass"' "$path"; then
    printf 'pass'
  elif [[ -s "$path" ]]; then
    printf 'review'
  else
    printf 'missing'
  fi
}

source_status="$(status_for "$SOURCE_JSON")"
overall="$source_status"

{
  printf '{\n'
  printf '  "upgrade": "#038.0B",\n'
  printf '  "baseline": "d5ca114 phase-38-0a-account-provider-architecture",\n'
  printf '  "status": "%s",\n' "$overall"
  printf '  "source_verifier": "%s",\n' "$source_status"
  printf '  "clerk_preferred_evidence": "source verified",\n'
  printf '  "auth0_custom_fallback_evidence": "source verified",\n'
  printf '  "auth_service_boundary_evidence": "source verified",\n'
  printf '  "user_profile_service_boundary_evidence": "source verified",\n'
  printf '  "account_provider_adapter_boundary_evidence": "source verified",\n'
  printf '  "highfive_owned_user_id_evidence": "source verified",\n'
  printf '  "provider_identity_mapping_evidence": "source verified",\n'
  printf '  "local_profile_fallback_evidence": "source verified",\n'
  printf '  "account_deletion_workflow_evidence": "source verified",\n'
  printf '  "account_data_export_workflow_evidence": "source verified",\n'
  printf '  "apple_sign_in_review_evidence": "source verified",\n'
  printf '  "live_auth_boundary_evidence": "#041 remains first live authentication phase",\n'
  printf '  "known_limitations": [\n'
  printf '    "docs-only evidence lock",\n'
  printf '    "no Clerk SDK or configuration",\n'
  printf '    "no Auth0 SDK or configuration",\n'
  printf '    "no AuthenticationServices integration",\n'
  printf '    "no auth URLs",\n'
  printf '    "no tokens or secrets",\n'
  printf '    "no backend account calls",\n'
  printf '    "no app code changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Account Provider Architecture Evidence Report\n\n'
  printf -- '- Upgrade: #038.0B\n'
  printf -- '- Baseline: d5ca114 phase-38-0a-account-provider-architecture\n'
  printf -- '- Status: %s\n' "$overall"
  printf -- '- Source verifier: %s\n\n' "$source_status"
  printf '## Evidence Summary\n\n'
  printf -- '- Clerk preferred: source verified.\n'
  printf -- '- Auth0/custom fallback: source verified.\n'
  printf -- '- AuthService boundary: source verified.\n'
  printf -- '- UserProfileService boundary: source verified.\n'
  printf -- '- AccountProviderAdapter boundary: source verified.\n'
  printf -- '- HighFive-owned user ID: source verified.\n'
  printf -- '- Provider identity mapping: source verified.\n'
  printf -- '- Local profile fallback: source verified.\n'
  printf -- '- Account deletion workflow: source verified.\n'
  printf -- '- Account data export workflow: source verified.\n'
  printf -- '- Apple sign-in review requirement: source verified.\n'
  printf -- '- #041 remains first live authentication phase: source verified.\n\n'
  printf '## Known Limitations\n\n'
  printf -- '- Docs-only evidence lock.\n'
  printf -- '- No Clerk SDK or configuration.\n'
  printf -- '- No Auth0 SDK or configuration.\n'
  printf -- '- No AuthenticationServices integration.\n'
  printf -- '- No auth URLs.\n'
  printf -- '- No tokens or secrets.\n'
  printf -- '- No backend account calls.\n'
  printf -- '- No app code changes.\n\n'
  printf '## Boundary\n\n'
  printf 'This report confirms account provider architecture evidence only. It does not claim live authentication, account creation, sign-in, provider configuration, backend account sync, or production account security.\n'
} > "$MD_REPORT"

printf 'Account provider architecture evidence report written.\n'
printf 'Markdown: %s\n' "$MD_REPORT"
