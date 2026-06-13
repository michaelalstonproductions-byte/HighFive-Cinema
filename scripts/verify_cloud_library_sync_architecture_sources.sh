#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_ARCHITECTURE.md"
OUT_DIR="/private/tmp/highfive-phase-43-0b-cloud-library-sync-evidence"
JSON_OUT="$OUT_DIR/cloud_library_sync_architecture_source_verification.json"
MD_OUT="$OUT_DIR/cloud_library_sync_architecture_source_verification.md"

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

add_named_status() {
  local id="$1"
  local label="$2"
  local status="$3"
  checks+=("{\"id\":\"$(json_escape "$id")\",\"label\":\"$(json_escape "$label")\",\"status\":\"$status\"}")
  if [[ "$status" != "pass" ]]; then
    failures+=("$label")
  fi
}

if [[ ! -f "$DOC_PATH" ]]; then
  printf '{"upgrade":"#043.0B","status":"fail","reason":"missing cloud library sync architecture doc","doc":"%s"}\n' "$DOC_PATH" > "$JSON_OUT"
  {
    printf '# Cloud Library Sync Architecture Source Verification\n\n'
    printf 'Status: fail\n\n'
    printf 'Missing document: `%s`\n' "$DOC_PATH"
  } > "$MD_OUT"
  exit 1
fi

add_check "cloud-library-sync" "Cloud Library Sync architecture" "Cloud Library Sync"
add_check "supabase-hybrid" "Supabase hybrid preferred backend path" "Supabase hybrid"
add_check "custom-api" "Custom API fallback" "Custom API"
add_check "library-service" "LibraryService boundary" "LibraryService"
add_check "cloud-library-provider-adapter" "CloudLibraryProviderAdapter boundary" "CloudLibraryProviderAdapter"
add_check "backend-service-layer" "BackendServiceLayer dependency" "BackendServiceLayer"
add_check "auth-service" "AuthService dependency" "AuthService"
add_check "highfive-user-id" "HighFive-owned user ID dependency" "HighFive-owned user ID"
add_check "movie-catalog-service" "MovieCatalogService dependency" "MovieCatalogService"
add_check "payment-entitlement-service" "PaymentEntitlementService boundary dependency" "PaymentEntitlementService"
add_check "playback-service" "PlaybackService dependency" "PlaybackService"
add_check "download-service" "DownloadService boundary dependency" "DownloadService"
add_check "saved-titles" "saved titles sync model" "saved titles"
add_check "watch-progress" "watch progress sync model" "watch progress"
add_check "continue-watching" "continue watching sync model" "continue watching|Continue Watching"
add_check "my-list" "My List sync model" "My List"
add_check "favorites" "favorites sync model" "favorites|Favorites"
add_check "download-state" "download state boundary" "download state"
add_check "offline-queue" "offline queue boundary" "offline queue|Offline queue"
add_check "conflict-resolution" "conflict resolution model" "conflict resolution|Conflict resolution"
add_check "optimistic-local-update" "optimistic local update model" "optimistic local update|Optimistic local update"
add_check "sync-retry" "sync retry model" "sync retry|Sync retry"
add_check "stale-data" "stale data handling" "stale data|Stale data"
add_check "deletion" "deletion handling" "deletion|Deletion"
add_check "unsave" "unsave handling" "unsave|Unsave"
add_check "viewing-history" "privacy model for viewing history" "viewing history"
add_check "account-deletion" "account deletion impact" "account deletion|Account deletion"
add_check "local-preview" "local preview fallback" "local preview|Local preview"
add_check "staging-sync" "staging sync model" "staging sync|Staging sync"
add_check "production-sync" "production sync model" "production sync|Production sync"
add_check "credential-requirements" "Credential Requirements" "Credential Requirements"
add_check "backend-requirements" "Backend Requirements" "Backend Requirements"
add_check "app-store" "App Store requirements" "App Store"
add_check "privacy-requirements" "Privacy Requirements" "Privacy Requirements"
add_check "rollback-strategy" "Rollback Strategy" "Rollback Strategy"
add_check "risk-register" "Risk Register" "Risk Register"
add_check "what-connects-first" "What Connects First" "What Connects First"
add_check "what-waits" "What Waits" "What Waits"
add_check "no-live-cloud-library-sync" "No live cloud library sync" "No live cloud library sync"
add_check "no-supabase-sdk" "No Supabase SDK/config" "No Supabase SDK"
add_check "no-cloudkit-implementation" "No CloudKit implementation" "No CloudKit implementation"
add_check "no-backend-urls" "No backend URLs" "No backend URLs"
add_check "no-file-storage-provider" "No file storage provider" "No file storage provider"
add_check "no-media-downloads" "No media downloads" "No media downloads"
add_check "no-sdks" "No SDKs" "No SDKs"
add_check "no-app-code" "No app code" "No app code"

script_scope="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_cloud_library_sync_architecture_sources\.sh$|^scripts/report_cloud_library_sync_architecture_evidence\.sh$|^docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_ARCHITECTURE\.md$' | rg -q '.'; then
  script_scope="fail"
fi
add_named_status "script-scope" "only #043.0B evidence scripts plus verifier-proven architecture doc proof correction changed" "$script_scope"

protected_scan="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -q '^HighFive/|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements|HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|posterAssetName|backdropAssetName|mapping|asset'; then
  protected_scan="fail"
fi
add_named_status "protected-scan" "protected path scan clean" "$protected_scan"

blocked_scan="pass"
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|Supabase|Firebase|CloudKit|CKContainer|CKDatabase|Postgres|SQL|Bearer|Authorization|FileManager|writeTo|downloadTask|AVAssetDownloadURLSession)'; then
  blocked_scan="fail"
fi
add_named_status "blocked-implementation-scan" "blocked implementation scan clean" "$blocked_scan"

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
add_named_status "docs-credential-assignment-scan" "docs credential assignment scan clean" "$docs_credential_assignment_scan"

status="pass"
if [[ "${#failures[@]}" -gt 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#043.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "claim": "source/document evidence only; no live cloud library sync exists or is claimed",\n'
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
  printf '# Cloud Library Sync Architecture Source Verification\n\n'
  printf 'Status: %s\n\n' "$status"
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf 'Scope: source/document evidence only. This verifier does not claim live cloud sync, Supabase, CloudKit, Custom API, backend URLs, URLSession, file storage, media downloads, credentials, provider config, SDKs, or app-code integration exists.\n\n'
  printf '## Checks\n\n'
  for check in "${checks[@]}"; do
    label="$(printf '%s' "$check" | sed -E 's/.*"label":"([^"]+)".*/\1/')"
    check_status="$(printf '%s' "$check" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    printf -- '- %s: %s\n' "$label" "$check_status"
  done
  if [[ "${#failures[@]}" -gt 0 ]]; then
    printf '\n## Missing Or Failed Evidence\n\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  fi
} > "$MD_OUT"

printf 'Cloud library sync architecture source verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_OUT"
printf 'Markdown: %s\n' "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
