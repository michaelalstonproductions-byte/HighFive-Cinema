#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-38-0b-account-provider-evidence"
JSON_REPORT="$OUT_DIR/account_provider_architecture_source_verification.json"
MD_REPORT="$OUT_DIR/account_provider_architecture_source_verification.md"
mkdir -p "$OUT_DIR"

passes=()
failures=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

require_file() {
  local path="$1"
  if [[ -s "$path" ]]; then
    pass "$path exists"
  else
    fail "$path missing or empty"
  fi
}

require_term() {
  local label="$1"
  local term="$2"
  local path="${3:-docs/production_services}"
  if rg -Fq "$term" "$path"; then
    pass "$label"
  else
    fail "$label missing: $term"
  fi
}

require_regex() {
  local label="$1"
  local pattern="$2"
  local path="${3:-docs/production_services}"
  if rg -q "$pattern" "$path"; then
    pass "$label"
  else
    fail "$label missing pattern: $pattern"
  fi
}

require_evidence_lock_safety() {
  local protected
  protected=$(git diff --name-only | rg '^HighFive/|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements' || true)
  if [[ -z "$protected" ]]; then
    pass "protected path scan clean"
  else
    fail "protected paths changed: $protected"
  fi

  local blocked
  blocked=$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' | rg -n '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|import AuthenticationServices|import StoreKit|import Firebase|import Supabase|import RevenueCat|import Stripe|Clerk|Auth0|URLSession)' || true)
  if [[ -z "$blocked" ]]; then
    pass "blocked implementation scan clean"
  else
    fail "blocked implementation diff found: $blocked"
  fi

  local unexpected
  unexpected=$(git status --short | rg -v '^(\?\? scripts/|A  scripts/| M scripts/|M  scripts/)(verify_account_provider_architecture_sources|report_account_provider_architecture_evidence)\.sh$' || true)
  if [[ -z "$unexpected" ]]; then
    pass "only account provider evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi
}

docs=(
  "docs/production_services/HIGHFIVE_ACCOUNT_PROVIDER_ARCHITECTURE.md"
  "docs/production_services/HIGHFIVE_API_CONTRACTS_AND_ADAPTER_PLAN.md"
  "docs/production_services/HIGHFIVE_PRODUCTION_DATA_MODEL_MAP.md"
  "docs/production_services/HIGHFIVE_REAL_SERVICES_ARCHITECTURE.md"
  "docs/production_services/HIGHFIVE_REAL_SERVICES_IMPLEMENTATION_ROADMAP.md"
  "docs/production_services/HIGHFIVE_SECURITY_PRIVACY_ENTITLEMENTS_CHECKLIST.md"
)

for doc in "${docs[@]}"; do
  require_file "$doc"
done

require_term "baseline commit documented in repo state" "phase-38-0a-account-provider-architecture" <(git tag --points-at d5ca114 2>/dev/null || true)

require_term "Clerk preferred" "Clerk is preferred"
require_term "Clerk preferred provider summary" "Preferred provider | Clerk"
require_regex "Auth0 custom fallback" "Auth0( or |/)custom|Auth0 and custom auth|Auth0/custom"
require_term "AuthService boundary" "AuthService"
require_term "UserProfileService boundary" "UserProfileService"
require_term "AccountProviderAdapter boundary" "AccountProviderAdapter"
require_term "HighFive-owned user ID" "HighFive-owned user ID"
require_term "provider identity mapping" "provider identity mapping"
require_term "AccountProviderIdentity model" "AccountProviderIdentity"
require_term "local profile fallback" "Local profile mode remains"
require_regex "account deletion workflow" "account deletion|AccountDeletionRequest|requestAccountDeletion"
require_regex "account data export workflow" "account data export|AccountExportRequest|exportAccountData"
require_regex "Apple sign-in review requirement" "Apple sign-in review|Sign in with Apple"
require_term "no live provider SDKs" "does not add SDKs"
require_term "no auth provider configuration" "auth provider configuration"
require_term "no URLs" "URLs"
require_term "no secrets" "secrets"
require_term "no tokens" "tokens"
require_term "no app code" "app code"
require_term "#041 first live authentication phase" "#041 remains the first phase allowed to implement selected authentication"
require_term "#041 roadmap authentication" "#041.0A — Authentication"

require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#038.0B",\n'
  printf '  "baseline": "d5ca114 phase-38-0a-account-provider-architecture",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "docs-only account provider architecture proof; no live authentication integration",\n'
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${passes[$i]}")" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${failures[$i]}")" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Account Provider Architecture Source Verification\n\n'
  printf -- '- Upgrade: #038.0B\n'
  printf -- '- Baseline: d5ca114 phase-38-0a-account-provider-architecture\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- JSON: %s\n\n' "$JSON_REPORT"
  printf '## Passes\n\n'
  for item in "${passes[@]}"; do printf -- '- %s\n' "$item"; done
  printf '\n## Failures\n\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
  fi
  printf '\n## Evidence Boundary\n\n'
  printf 'This verifier confirms the account provider architecture docs, Clerk primary/Auth0-custom fallback plan, AuthService/UserProfileService/AccountProviderAdapter boundaries, HighFive-owned user identity mapping, local profile fallback, deletion/export workflows, Apple sign-in review requirement, and #041 live-authentication boundary. It does not verify or add live authentication.\n'
} > "$MD_REPORT"

printf 'Account provider architecture source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
