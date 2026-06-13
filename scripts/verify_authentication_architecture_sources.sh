#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_AUTHENTICATION_ARCHITECTURE.md"
OUT_DIR="/private/tmp/highfive-phase-41-0b-authentication-evidence"
JSON_OUT="$OUT_DIR/authentication_architecture_source_verification.json"
MD_OUT="$OUT_DIR/authentication_architecture_source_verification.md"

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
  printf '{"status":"fail","reason":"missing authentication architecture doc","doc":"%s"}\n' "$DOC_PATH" > "$JSON_OUT"
  {
    printf '# Authentication Architecture Source Verification\n\n'
    printf 'Status: fail\n\n'
    printf 'Missing document: `%s`\n' "$DOC_PATH"
  } > "$MD_OUT"
  exit 1
fi

add_check "clerk-preferred" "Clerk preferred" "Clerk is preferred|Authentication provider \\| Clerk"
add_check "auth0-fallback" "Auth0 fallback" "Auth0 is the fallback|Auth0 is fallback|\\| Auth0 \\|"
add_check "custom-auth-fallback" "Custom auth fallback" "Custom auth is the last-resort fallback|Custom auth is last-resort fallback|Custom auth"
add_check "auth-service" "AuthService boundary" "AuthService"
add_check "provider-adapter" "AuthenticationProviderAdapter boundary" "AuthenticationProviderAdapter"
add_check "backend-dependency" "BackendServiceLayer dependency" "BackendServiceLayer"
add_check "highfive-user-id" "HighFive-owned user ID" "HighFive-owned user ID|HighFiveUserID"
add_check "provider-mapping" "provider identity mapping" "provider identity mapping|ProviderIdentityMapping"
add_check "session-lifecycle" "session lifecycle" "Session Lifecycle|session lifecycle"
add_check "sign-in-flow" "sign-in flow" "Sign-in flow|beginSignIn"
add_check "sign-out-flow" "sign-out flow" "Sign-out flow|signOut"
add_check "refresh-flow" "session refresh flow" "Session refresh flow|refreshSession"
add_check "deletion-flow" "account deletion flow" "Account deletion flow|requestAccountDeletion"
add_check "export-flow" "account export flow" "Account export flow|requestAccountExport"
add_check "apple-requirement" "Sign in with Apple requirement" "Sign in with Apple"
add_check "local-preview" "local preview fallback" "local preview fallback|Local preview fallback"
add_check "staging-model" "staging model" "Staging"
add_check "production-model" "production model" "Production"
add_check "credential-requirements" "credential requirements" "Credential Requirements"
add_check "backend-requirements" "backend requirements" "Backend Requirements"
add_check "app-store-privacy" "App Store/privacy requirements" "App Store And Privacy Requirements|Privacy labels"
add_check "rollback" "rollback strategy" "Rollback Strategy|rollback"
add_check "risk-register" "risk register" "Risk Register"
add_check "connects-first" "what connects first" "What Connects First"
add_check "what-waits" "what waits" "What Waits"
add_check "no-live-auth" "no live auth provider" "No live auth provider is connected|No live sign-in"
add_combo_check "no-sdk-url-secret-code" "no SDKs/URLs/tokens/secrets/app code changes" "No SDKs|does not add Clerk SDKs" "URLs" "tokens" "secrets" "app code"

status="pass"
if [[ "${#failures[@]}" -gt 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#041.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "claim": "source presence only; architecture evidence only; no live authentication provider integration",\n'
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
  printf '# Authentication Architecture Source Verification\n\n'
  printf 'Status: %s\n\n' "$status"
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf 'Scope: source presence only. This evidence does not claim live Clerk, Auth0, custom auth, AuthenticationServices, credentials, provider config, SDKs, or app-code integration exists.\n\n'
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

printf 'Authentication architecture source verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_OUT"
printf 'Markdown: %s\n' "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
