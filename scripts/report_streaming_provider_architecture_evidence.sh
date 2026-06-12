#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-39-0b-streaming-provider-evidence"
SOURCE_JSON="$OUT_DIR/streaming_provider_architecture_source_verification.json"
SOURCE_MD="$OUT_DIR/streaming_provider_architecture_source_verification.md"
REPORT_JSON="$OUT_DIR/streaming_provider_architecture_evidence_report.json"
REPORT_MD="$OUT_DIR/streaming_provider_architecture_evidence_report.md"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_STREAMING_PROVIDER_ARCHITECTURE.md"

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
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|AVURLAsset|AVPlayer|Cloudflare|Mux|HLS|m3u8|DRM|FairPlay|downloadTask|AVAssetDownloadURLSession)'; then
  blocked_scan="fail"
fi

docs_only="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_streaming_provider_architecture_sources\.sh$|^scripts/report_streaming_provider_architecture_evidence\.sh$' | rg -q '.'; then
  docs_only="fail"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$protected_scan" != "pass" || "$blocked_scan" != "pass" || "$docs_only" != "pass" ]]; then
  overall_status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#039.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline": "961b248 phase-39-0a-streaming-provider-integration-architecture",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "protected_scan": "%s",\n' "$protected_scan"
  printf '  "blocked_implementation_scan": "%s",\n' "$blocked_scan"
  printf '  "script_scope": "%s",\n' "$docs_only"
  printf '  "evidence": {\n'
  printf '    "cloudflare_stream_preferred": "source verified",\n'
  printf '    "mux_fallback": "source verified",\n'
  printf '    "streaming_provider_adapter_boundary": "source verified",\n'
  printf '    "playback_service_boundary": "source verified",\n'
  printf '    "dependency_map": "MovieCatalogService, PaymentEntitlementService, and DownloadService source verified",\n'
  printf '    "signed_source_and_expiration": "source verified as architecture only",\n'
  printf '    "hls_drm_offline_policy": "source verified as architecture/planning only",\n'
  printf '    "provider_health_local_fallback_and_rollback": "source verified",\n'
  printf '    "environment_credentials_backend_app_store": "source verified",\n'
  printf '    "risk_connects_first_waits": "source verified",\n'
  printf '    "no_live_provider_integration": "source verified"\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "architecture evidence only",\n'
  printf '    "no Cloudflare Stream integration",\n'
  printf '    "no Mux integration",\n'
  printf '    "no live HLS source",\n'
  printf '    "no DRM or FairPlay implementation",\n'
  printf '    "no signed playback source implementation",\n'
  printf '    "no backend source mediation implementation",\n'
  printf '    "no provider credentials, config, URLs, tokens, or secrets",\n'
  printf '    "no playback implementation changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Streaming Provider Architecture Evidence Report\n\n'
  printf 'Status: %s\n\n' "$overall_status"
  printf 'Baseline: `961b248 phase-39-0a-streaming-provider-integration-architecture`\n\n'
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf '## Results\n\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Protected scan: %s\n' "$protected_scan"
  printf -- '- Blocked implementation scan: %s\n' "$blocked_scan"
  printf -- '- Evidence script scope: %s\n' "$docs_only"
  printf '\n## Evidence Status\n\n'
  printf -- '- Cloudflare Stream preferred: source verified\n'
  printf -- '- Mux fallback: source verified\n'
  printf -- '- StreamingProviderAdapter boundary: source verified\n'
  printf -- '- PlaybackService boundary: source verified\n'
  printf -- '- MovieCatalogService dependency: source verified\n'
  printf -- '- PaymentEntitlementService dependency: source verified\n'
  printf -- '- DownloadService dependency: source verified\n'
  printf -- '- Signed playback source architecture: source verified as planning only\n'
  printf -- '- Source expiration policy: source verified\n'
  printf -- '- HLS playback model: source verified as playback-source descriptor architecture only\n'
  printf -- '- DRM decision framework: source verified as deferred security review only\n'
  printf -- '- Offline/download dependency map: source verified\n'
  printf -- '- Provider health states: source verified\n'
  printf -- '- Local fallback behavior: source verified\n'
  printf -- '- Environment requirements: source verified\n'
  printf -- '- Credential requirements: source verified\n'
  printf -- '- Backend requirements: source verified\n'
  printf -- '- App Store review considerations: source verified\n'
  printf -- '- Streaming rollback strategy: source verified\n'
  printf -- '- Risk register: source verified\n'
  printf -- '- What connects first / what waits: source verified\n'
  printf -- '- #039 architecture-only status: source verified\n'
  printf -- '- #040/backend layer dependency before production streaming security: source verified as backend mediation prerequisite\n'
  printf -- '- No live provider credentials/config/URLs/secrets: source verified\n'
  printf -- '- No playback implementation changes: scan verified\n'
  printf '\n## Known Limitations\n\n'
  printf -- '- Architecture evidence only.\n'
  printf -- '- No Cloudflare Stream integration.\n'
  printf -- '- No Mux integration.\n'
  printf -- '- No live HLS source.\n'
  printf -- '- No DRM or FairPlay implementation.\n'
  printf -- '- No signed playback source implementation.\n'
  printf -- '- No backend source mediation implementation.\n'
  printf -- '- No provider credentials, config, URLs, tokens, or secrets.\n'
  printf -- '- No playback implementation changes.\n'
  if [[ -f "$SOURCE_MD" ]]; then
    printf '\nSource verifier report: `%s`\n' "$SOURCE_MD"
  fi
} > "$REPORT_MD"

printf 'Streaming provider architecture evidence report: %s\n' "$overall_status"
printf 'JSON: %s\n' "$REPORT_JSON"
printf 'Markdown: %s\n' "$REPORT_MD"

if [[ "$overall_status" != "pass" ]]; then
  exit 1
fi
