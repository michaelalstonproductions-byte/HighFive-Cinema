#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-44-0b-real-downloads-evidence"
SOURCE_JSON="$OUT_DIR/real_downloads_architecture_source_verification.json"
SOURCE_MD="$OUT_DIR/real_downloads_architecture_source_verification.md"
REPORT_JSON="$OUT_DIR/real_downloads_architecture_evidence_report.json"
REPORT_MD="$OUT_DIR/real_downloads_architecture_evidence_report.md"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_REAL_DOWNLOADS_ARCHITECTURE.md"

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
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|Supabase|Firebase|CloudKit|CKContainer|CKDatabase|Postgres|SQL|Bearer|Authorization|FileManager|writeTo|downloadTask|AVAssetDownloadURLSession|AVAssetDownloadTask|AVAggregateAssetDownloadTask|background transfer|FairPlay|DRM|AVContentKeySession|AVAssetResourceLoader)'; then
  blocked_scan="fail"
fi

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

script_scope="pass"
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_real_downloads_architecture_sources\.sh$|^scripts/report_real_downloads_architecture_evidence\.sh$' | rg -q '.'; then
  script_scope="fail"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$protected_scan" != "pass" || "$blocked_scan" != "pass" || "$docs_credential_assignment_scan" != "pass" || "$script_scope" != "pass" ]]; then
  overall_status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#044.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline": "5d60828 phase-44-0a-real-downloads-architecture",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "protected_scan": "%s",\n' "$protected_scan"
  printf '  "blocked_implementation_scan": "%s",\n' "$blocked_scan"
  printf '  "docs_credential_assignment_scan": "%s",\n' "$docs_credential_assignment_scan"
  printf '  "script_scope": "%s",\n' "$script_scope"
  printf '  "evidence": {\n'
  printf '    "real_downloads": "source verified when verifier passes",\n'
  printf '    "download_service": "source verified when verifier passes",\n'
  printf '    "offline_asset_provider_adapter": "source verified when verifier passes",\n'
  printf '    "backend_auth_user_dependency": "source verified when verifier passes",\n'
  printf '    "cloud_library_library_catalog_playback_payment_streaming_dependency": "source verified when verifier passes",\n'
  printf '    "eligibility_license_storage_queue_progress_retry": "source verified when verifier passes",\n'
  printf '    "expiry_revocation_refund_account_deletion": "source verified when verifier passes",\n'
  printf '    "offline_playback_drm_fairplay": "source verified when verifier passes",\n'
  printf '    "airplane_mode_stale_license_delete": "source verified when verifier passes",\n'
  printf '    "local_staging_production": "source verified when verifier passes",\n'
  printf '    "credential_backend_app_store_privacy": "source verified when verifier passes",\n'
  printf '    "rollback_risk_connects_first_waits": "source verified when verifier passes",\n'
  printf '    "no_live_media_downloads_or_blocked_implementation": "source and scan verified when all checks pass"\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "no live media downloads",\n'
  printf '    "no AVAssetDownloadURLSession implementation",\n'
  printf '    "no URLSession",\n'
  printf '    "no FileManager writes",\n'
  printf '    "no file storage provider",\n'
  printf '    "no Supabase SDK/config",\n'
  printf '    "no CloudKit implementation",\n'
  printf '    "no Custom API client",\n'
  printf '    "no backend URLs",\n'
  printf '    "no tokens/secrets/API keys",\n'
  printf '    "no DRM/FairPlay implementation",\n'
  printf '    "no real offline playback media files",\n'
  printf '    "no app code changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Real Downloads Architecture Evidence Report\n\n'
  printf 'Status: %s\n\n' "$overall_status"
  printf 'Baseline: `5d60828 phase-44-0a-real-downloads-architecture`\n\n'
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf '## Results\n\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Protected scan: %s\n' "$protected_scan"
  printf -- '- Blocked implementation scan: %s\n' "$blocked_scan"
  printf -- '- Docs/script credential assignment scan: %s\n' "$docs_credential_assignment_scan"
  printf -- '- Evidence script scope: %s\n' "$script_scope"
  printf '\n## Evidence Status\n\n'
  printf -- '- Real Downloads architecture: source verified when verifier passes\n'
  printf -- '- DownloadService boundary: source verified when verifier passes\n'
  printf -- '- OfflineAssetProviderAdapter boundary: source verified when verifier passes\n'
  printf -- '- BackendServiceLayer, AuthService, and HighFive-owned user ID dependencies: source verified when verifier passes\n'
  printf -- '- CloudLibraryProviderAdapter, LibraryService, MovieCatalogService, PlaybackService, PaymentEntitlementService, and StreamingProviderAdapter dependencies: source verified when verifier passes\n'
  printf -- '- Eligibility, license, storage, queue, progress, retry, pause, and resume models: source verified when verifier passes\n'
  printf -- '- Expiry, revocation, refund, entitlement loss, and account deletion policies: source verified when verifier passes\n'
  printf -- '- Offline playback boundary and DRM / FairPlay decision framework: source verified when verifier passes\n'
  printf -- '- Airplane-mode, stale license, and delete downloaded title behavior: source verified when verifier passes\n'
  printf -- '- Local preview, staging download, and production download models: source verified when verifier passes\n'
  printf -- '- Credential, backend, App Store, privacy, rollback, risk, connects-first, and waits evidence: source verified when verifier passes\n'
  printf -- '- No live downloads, no blocked implementation, and no credential assignment: source and scan verified when all checks pass\n'
  printf '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- No live media downloads.\n'
  printf -- '- No AVAssetDownloadURLSession implementation.\n'
  printf -- '- No URLSession.\n'
  printf -- '- No FileManager writes.\n'
  printf -- '- No file storage provider.\n'
  printf -- '- No Supabase SDK/config.\n'
  printf -- '- No CloudKit implementation.\n'
  printf -- '- No Custom API client.\n'
  printf -- '- No backend URLs.\n'
  printf -- '- No tokens/secrets/API keys.\n'
  printf -- '- No DRM/FairPlay implementation.\n'
  printf -- '- No real offline playback media files.\n'
  printf -- '- No app code changes.\n'
  if [[ -f "$SOURCE_MD" ]]; then
    printf '\nSource verifier report: `%s`\n' "$SOURCE_MD"
  fi
} > "$REPORT_MD"

printf 'Real downloads architecture evidence report: %s\n' "$overall_status"
printf 'JSON: %s\n' "$REPORT_JSON"
printf 'Markdown: %s\n' "$REPORT_MD"

if [[ "$overall_status" != "pass" ]]; then
  exit 1
fi
