#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_REAL_DOWNLOADS_ARCHITECTURE.md"
OUT_DIR="/private/tmp/highfive-phase-44-0b-real-downloads-evidence"
JSON_OUT="$OUT_DIR/real_downloads_architecture_source_verification.json"
MD_OUT="$OUT_DIR/real_downloads_architecture_source_verification.md"

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
  printf '{"upgrade":"#044.0B","status":"fail","reason":"missing real downloads architecture doc","doc":"%s"}\n' "$DOC_PATH" > "$JSON_OUT"
  {
    printf '# Real Downloads Architecture Source Verification\n\n'
    printf 'Status: fail\n\n'
    printf 'Missing document: `%s`\n' "$DOC_PATH"
  } > "$MD_OUT"
  exit 1
fi

add_check "real-downloads-architecture" "Real Downloads architecture" "Real Downloads architecture"
add_check "download-service-boundary" "DownloadService boundary" "DownloadService"
add_check "offline-asset-provider-adapter-boundary" "OfflineAssetProviderAdapter boundary" "OfflineAssetProviderAdapter"
add_check "backend-service-layer-dependency" "BackendServiceLayer dependency" "BackendServiceLayer"
add_check "auth-service-dependency" "AuthService dependency" "AuthService"
add_check "highfive-user-id-dependency" "HighFive-owned user ID dependency" "HighFive-owned user ID"
add_check "cloud-library-provider-adapter-dependency" "CloudLibraryProviderAdapter dependency" "CloudLibraryProviderAdapter"
add_check "library-service-dependency" "LibraryService dependency" "LibraryService"
add_check "movie-catalog-service-dependency" "MovieCatalogService dependency" "MovieCatalogService"
add_check "playback-service-dependency" "PlaybackService dependency" "PlaybackService"
add_check "payment-entitlement-service-dependency" "PaymentEntitlementService dependency" "PaymentEntitlementService"
add_check "streaming-provider-adapter-dependency" "StreamingProviderAdapter dependency" "StreamingProviderAdapter"
add_check "download-eligibility-model" "download eligibility model" "Download Eligibility Model|download eligibility model"
add_check "offline-license-policy" "offline license policy" "Offline License Policy|offline license policy"
add_check "media-asset-availability-model" "media asset availability model" "Media Asset Availability Model|media asset availability model"
add_check "storage-policy" "storage policy" "Storage Policy|storage policy"
add_check "device-storage-pressure" "device storage pressure handling" "Device Storage Pressure Handling|storage pressure"
add_check "download-queue-model" "download queue model" "Download Queue Model|download queue model"
add_check "download-progress-model" "download progress model" "Download Progress Model|download progress model"
add_check "download-retry-model" "download retry model" "download retry|Download retry|Retry limits"
add_check "pause-resume-architecture" "pause / resume architecture" "Pause / Resume / Retry Architecture|pause / resume architecture"
add_check "expiry-policy" "expiry policy" "Expiry Policy|expiry policy"
add_check "revocation-policy" "revocation policy" "Revocation Policy|revocation policy"
add_check "refund-entitlement-loss-policy" "refund / entitlement loss policy" "Refund / Entitlement Loss Policy|refund / entitlement loss"
add_check "account-deletion-impact" "account deletion impact" "Account Deletion Impact|account deletion impact"
add_check "offline-playback-boundary" "offline playback boundary" "Offline Playback Boundary|offline playback boundary"
add_check "drm-fairplay-decision-framework" "DRM / FairPlay decision framework" "DRM / FairPlay Decision Framework|DRM and FairPlay decision framework"
add_check "airplane-mode-behavior" "airplane-mode behavior" "Airplane-Mode Behavior|airplane-mode behavior"
add_check "stale-license-behavior" "stale license behavior" "Stale License Behavior|stale license behavior"
add_check "delete-downloaded-title-behavior" "delete downloaded title behavior" "Delete Downloaded Title Behavior|delete downloaded title behavior"
add_check "local-preview-fallback" "local preview fallback" "Local preview|local preview fallback"
add_check "staging-download-model" "staging download model" "Staging download model|staging download"
add_check "production-download-model" "production download model" "Production download model|production download"
add_check "credential-requirements" "credential requirements" "Credential Requirements"
add_check "backend-requirements" "backend requirements" "Backend Requirements"
add_check "app-store-privacy-requirements" "App Store/privacy requirements" "App Store requirements|Privacy Requirements"
add_check "rollback-strategy" "rollback strategy" "Rollback Strategy"
add_check "risk-register" "risk register" "Risk Register"
add_check "what-connects-first" "what connects first" "What Connects First"
add_check "what-waits" "what waits" "What Waits"
add_check "no-live-media-downloads" "no live media downloads" "No live media downloads"
add_check "no-avassetdownloadurlsession" "no AVAssetDownloadURLSession implementation" "No AVAssetDownloadURLSession implementation"
add_check "no-filemanager-writes" "no FileManager writes" "No FileManager writes"
add_check "no-urlsession" "no URLSession" "No URLSession"
add_check "no-file-storage-provider" "no file storage provider" "No file storage provider"
add_check "no-backend-urls" "no backend URLs" "No backend URLs"
add_check "no-supabase-sdk-config" "no Supabase SDK/config" "No Supabase SDK/config"
add_check "no-cloudkit-implementation" "no CloudKit implementation" "No CloudKit implementation"
add_check "no-drm-fairplay-implementation" "no DRM/FairPlay implementation" "No DRM/FairPlay implementation"
add_check "no-real-offline-playback-media-files" "no real offline playback media files" "No real offline playback media files"
add_combo_check "no-sdks-urls-tokens-secrets-app-code" "no SDKs/URLs/tokens/secrets/app code changes" "No SDKs" "No app code" "tokens/secrets/API keys|tokens, secrets, API keys"

script_scope="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_real_downloads_architecture_sources\.sh$|^scripts/report_real_downloads_architecture_evidence\.sh$' | rg -q '.'; then
  script_scope="fail"
fi
add_named_status "script-scope" "only #044.0B real downloads evidence scripts changed" "$script_scope"

protected_scan="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -q '^HighFive/|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements|HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|posterAssetName|backdropAssetName|mapping|asset'; then
  protected_scan="fail"
fi
add_named_status "protected-scan" "protected path scan clean" "$protected_scan"

blocked_scan="pass"
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|Supabase|Firebase|CloudKit|CKContainer|CKDatabase|Postgres|SQL|Bearer|Authorization|FileManager|writeTo|downloadTask|AVAssetDownloadURLSession|AVAssetDownloadTask|AVAggregateAssetDownloadTask|background transfer|FairPlay|DRM|AVContentKeySession|AVAssetResourceLoader)'; then
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
add_named_status "docs-credential-assignment-scan" "docs/script credential assignment scan clean" "$docs_credential_assignment_scan"

status="pass"
if [[ "${#failures[@]}" -gt 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#044.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "baseline": "5d60828 phase-44-0a-real-downloads-architecture",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "claim": "source/document evidence only; no live media downloads or app-code implementation exists or is claimed",\n'
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
  printf '# Real Downloads Architecture Source Verification\n\n'
  printf 'Status: %s\n\n' "$status"
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf 'Scope: source/document evidence only. This verifier does not claim live media downloads, AVAssetDownloadURLSession, URLSession, FileManager writes, file storage, backend URLs, Supabase, CloudKit, SDKs, credentials, DRM/FairPlay, provider config, or app-code integration exists.\n\n'
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

printf 'Real downloads architecture source verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_OUT"
printf 'Markdown: %s\n' "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
