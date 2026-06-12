#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_STREAMING_PROVIDER_ARCHITECTURE.md"
OUT_DIR="/private/tmp/highfive-phase-39-0b-streaming-provider-evidence"
JSON_OUT="$OUT_DIR/streaming_provider_architecture_source_verification.json"
MD_OUT="$OUT_DIR/streaming_provider_architecture_source_verification.md"

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
  printf '{"status":"fail","reason":"missing architecture doc","doc":"%s"}\n' "$DOC_PATH" > "$JSON_OUT"
  {
    printf '# Streaming Provider Architecture Source Verification\n\n'
    printf 'Status: fail\n\n'
    printf 'Missing document: `%s`\n' "$DOC_PATH"
  } > "$MD_OUT"
  exit 1
fi

add_check "cloudflare-preferred" "Cloudflare Stream preferred" "Cloudflare Stream remains the preferred|Cloudflare Stream is preferred"
add_check "mux-fallback" "Mux fallback" "Mux remains the fallback|Mux is fallback"
add_check "streaming-provider-adapter" "StreamingProviderAdapter boundary" "StreamingProviderAdapter"
add_check "playback-service" "PlaybackService boundary" "PlaybackService"
add_check "movie-catalog-dependency" "MovieCatalogService dependency" "MovieCatalogService"
add_check "payment-entitlement-dependency" "PaymentEntitlementService dependency" "PaymentEntitlementService"
add_check "download-service-dependency" "DownloadService dependency" "DownloadService"
add_combo_check "signed-source-architecture" "signed playback source architecture" "Signed-source helper|Signed playback sources|signed source|Playback signing" "Backend service layer|Backend mediation|source mediation"
add_check "source-expiration-policy" "source expiration policy" "source expiry|Source descriptor expired|Source expiry and refresh policy|expired"
add_combo_check "hls-playback-model" "HLS playback model" "playable stream|PlaybackSource|playback descriptor" "source type|source descriptor|PlaybackSource"
add_combo_check "drm-decision-framework" "DRM decision framework" "DRM|advanced protection" "separate security review|waits"
add_combo_check "offline-download-map" "offline/download dependency map" "Offline media policy|offline policy|Real downloads" "DownloadService|download service policy|download licensing"
add_check "provider-health" "provider health states" "ProviderHealth|provider health|provider availability"
add_check "local-fallback" "local fallback behavior" "Local preview playback remains available|local fallback|Local preview adapter"
add_check "environment-requirements" "environment requirements" "Environment Requirements"
add_check "credential-requirements" "credential requirements" "Credential Requirements"
add_check "backend-requirements" "backend requirements" "Backend Requirements"
add_check "app-store-review" "App Store review considerations" "App Store And Privacy Requirements|App Review"
add_check "rollback-strategy" "streaming rollback strategy" "rollback|Local rollback"
add_check "risk-register" "risk register" "Risk Register"
add_check "what-connects-first" "what connects first" "What Connects First"
add_check "what-waits" "what waits" "What Waits"
add_check "architecture-only" "#039 is architecture only" "#039|architecture.*only|planning only"
add_combo_check "phase-40-backend-required" "#040 backend layer required before production streaming security" "Backend service layer|backend service layer|Backend mediation" "source protection|signed|signing|source mediation"
add_combo_check "no-live-provider-credentials" "no live provider credentials/config/URLs/secrets" "No provider SDKs|does not add SDKs" "URLs|provider URLs" "secrets|tokens|credentials" "not collected, not configured, not committed|not committed"
add_check "no-playback-implementation" "no playback implementation changes" "No app code is added|does not add.*app code|implementation waits"

status="pass"
if [[ "${#failures[@]}" -gt 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#039.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "claim": "source presence only; architecture evidence only; no live streaming provider integration",\n'
  printf '  "checks": [\n'
  local_count="${#checks[@]}"
  for i in "${!checks[@]}"; do
    if [[ "$i" -lt $((local_count - 1)) ]]; then
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
  printf '# Streaming Provider Architecture Source Verification\n\n'
  printf 'Status: %s\n\n' "$status"
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf 'Scope: source presence only. This evidence does not claim live Cloudflare Stream, Mux, HLS, DRM, backend mediation, signed playback sources, or playback implementation exists.\n\n'
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

printf 'Streaming provider architecture source verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_OUT"
printf 'Markdown: %s\n' "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
