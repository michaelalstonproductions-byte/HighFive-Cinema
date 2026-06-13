#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-43-0b-cloud-library-sync-evidence"
SOURCE_JSON="$OUT_DIR/cloud_library_sync_architecture_source_verification.json"
SOURCE_MD="$OUT_DIR/cloud_library_sync_architecture_source_verification.md"
REPORT_JSON="$OUT_DIR/cloud_library_sync_architecture_evidence_report.json"
REPORT_MD="$OUT_DIR/cloud_library_sync_architecture_evidence_report.md"
DOC_PATH="$ROOT_DIR/docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_ARCHITECTURE.md"

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
if git -C "$ROOT_DIR" diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -q '^\+.*(api[_-]?key|secret|token|client_secret|access_token|refresh_token|password|https?://|URLSession|Supabase|Firebase|CloudKit|CKContainer|CKDatabase|Postgres|SQL|Bearer|Authorization|FileManager|writeTo|downloadTask|AVAssetDownloadURLSession)'; then
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
if git -C "$ROOT_DIR" diff --name-only | rg -v '^scripts/verify_cloud_library_sync_architecture_sources\.sh$|^scripts/report_cloud_library_sync_architecture_evidence\.sh$|^docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_ARCHITECTURE\.md$' | rg -q '.'; then
  script_scope="fail"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$protected_scan" != "pass" || "$blocked_scan" != "pass" || "$docs_credential_assignment_scan" != "pass" || "$script_scope" != "pass" ]]; then
  overall_status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#043.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline": "13db38c phase-43-0a-cloud-library-sync-architecture",\n'
  printf '  "doc": "%s",\n' "$DOC_PATH"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "protected_scan": "%s",\n' "$protected_scan"
  printf '  "blocked_implementation_scan": "%s",\n' "$blocked_scan"
  printf '  "docs_credential_assignment_scan": "%s",\n' "$docs_credential_assignment_scan"
  printf '  "script_scope": "%s",\n' "$script_scope"
  printf '  "evidence": {\n'
  printf '    "cloud_library_sync": "source verified when verifier passes",\n'
  printf '    "supabase_hybrid_custom_api": "source verified when verifier passes",\n'
  printf '    "library_service": "source verified when verifier passes",\n'
  printf '    "cloud_library_provider_adapter": "source verified when verifier passes",\n'
  printf '    "backend_service_layer_dependency": "source verified when verifier passes",\n'
  printf '    "auth_highfive_user_dependency": "source verified when verifier passes",\n'
  printf '    "movie_catalog_service": "source verified when verifier passes",\n'
  printf '    "payment_entitlement_service": "source verified when verifier passes",\n'
  printf '    "playback_service": "source verified when verifier passes",\n'
  printf '    "download_service": "source verified when verifier passes",\n'
  printf '    "saved_titles": "source verified when verifier passes",\n'
  printf '    "watch_progress": "source verified when verifier passes",\n'
  printf '    "continue_watching": "source verified when verifier passes",\n'
  printf '    "my_list_favorites": "source verified when verifier passes",\n'
  printf '    "download_offline_boundary": "source verified when verifier passes",\n'
  printf '    "conflict_resolution": "source verified when verifier passes",\n'
  printf '    "optimistic_local_update": "source verified when verifier passes",\n'
  printf '    "retry_stale_data": "source verified when verifier passes",\n'
  printf '    "deletion_unsave_account_deletion": "source verified when verifier passes",\n'
  printf '    "privacy_credential_backend_app_store": "source verified when verifier passes",\n'
  printf '    "rollback_risk": "source verified when verifier passes"\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "no live cloud library sync",\n'
  printf '    "no Supabase SDK/config",\n'
  printf '    "no CloudKit implementation",\n'
  printf '    "no Custom API client",\n'
  printf '    "no backend URLs",\n'
  printf '    "no tokens/secrets/API keys",\n'
  printf '    "no file storage provider",\n'
  printf '    "no real media downloads",\n'
  printf '    "no real cross-device sync",\n'
  printf '    "no app code changes"\n'
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Cloud Library Sync Architecture Evidence Report\n\n'
  printf 'Status: %s\n\n' "$overall_status"
  printf 'Baseline: `13db38c phase-43-0a-cloud-library-sync-architecture`\n\n'
  printf 'Document: `%s`\n\n' "$DOC_PATH"
  printf '## Results\n\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Protected scan: %s\n' "$protected_scan"
  printf -- '- Blocked implementation scan: %s\n' "$blocked_scan"
  printf -- '- Docs credential assignment scan: %s\n' "$docs_credential_assignment_scan"
  printf -- '- Evidence script scope: %s\n' "$script_scope"
  printf '\n## Evidence Status\n\n'
  printf -- '- Cloud Library Sync: source verified when verifier passes\n'
  printf -- '- Supabase hybrid / Custom API: source verified when verifier passes\n'
  printf -- '- LibraryService: source verified when verifier passes\n'
  printf -- '- CloudLibraryProviderAdapter: source verified when verifier passes\n'
  printf -- '- BackendServiceLayer dependency: source verified when verifier passes\n'
  printf -- '- AuthService / HighFive-owned user ID: source verified when verifier passes\n'
  printf -- '- MovieCatalogService: source verified when verifier passes\n'
  printf -- '- PaymentEntitlementService: source verified when verifier passes\n'
  printf -- '- PlaybackService: source verified when verifier passes\n'
  printf -- '- DownloadService: source verified when verifier passes\n'
  printf -- '- Saved titles, watch progress, continue watching, My List / favorites: source verified when verifier passes\n'
  printf -- '- Download/offline boundary, conflict resolution, optimistic local update, retry/stale data: source verified when verifier passes\n'
  printf -- '- Deletion, unsave, account deletion, privacy, credential, backend, App Store, rollback, and risk evidence: source verified when verifier passes\n'
  printf '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- No live cloud library sync.\n'
  printf -- '- No Supabase SDK/config.\n'
  printf -- '- No CloudKit implementation.\n'
  printf -- '- No Custom API client.\n'
  printf -- '- No backend URLs.\n'
  printf -- '- No tokens/secrets/API keys.\n'
  printf -- '- No file storage provider.\n'
  printf -- '- No real media downloads.\n'
  printf -- '- No real cross-device sync.\n'
  printf -- '- No app code changes.\n'
  if [[ -f "$SOURCE_MD" ]]; then
    printf '\nSource verifier report: `%s`\n' "$SOURCE_MD"
  fi
} > "$REPORT_MD"

printf 'Cloud library sync architecture evidence report: %s\n' "$overall_status"
printf 'JSON: %s\n' "$REPORT_JSON"
printf 'Markdown: %s\n' "$REPORT_MD"

if [[ "$overall_status" != "pass" ]]; then
  exit 1
fi
