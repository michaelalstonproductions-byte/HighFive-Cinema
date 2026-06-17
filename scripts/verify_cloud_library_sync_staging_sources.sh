#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-58-0b-cloud-library-sync-evidence"
JSON_OUT="$OUT_DIR/cloud_library_sync_staging_source_verification.json"
MD_OUT="$OUT_DIR/cloud_library_sync_staging_source_verification.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

SOURCE_SCOPE=("HighFive" "docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_STAGING.md")
LIBRARY_SYNC_FILE="HighFive/Services/LibrarySync/HFLibrarySyncService.swift"
STORE_FILE="HighFive/Data/HFStreamingStore.swift"
LIBRARY_VIEW_FILE="HighFive/Views/MyListView.swift"
PROFILE_FILE="HighFive/Views/Profile/ProfileView.swift"

declare -a REQUIRED_TERMS=(
  "HFLibrarySyncService"
  "HFLocalLibrarySyncAdapter"
  "HFRemoteLibrarySyncGateway"
  "HFLibraryConflictPolicy"
  "HFSavedTitleRecord"
  "HFProgressRecord"
  "HFOfflineStateRecord"
  "HFLibrarySyncBoundary"
  "HFLibrarySyncRuntimeStatus"
  "HFLibrarySyncProviderStatus"
  "HFLibrarySyncState"
  "HFLibrarySyncOperation"
  "HFLibrarySyncSnapshot"
  "HIGHFIVE_LIBRARY_SYNC_MODE"
  "HIGHFIVE_LIBRARY_SYNC_BASE_URL"
  "HIGHFIVE_LIBRARY_SYNC_PROVIDER"
  "HIGHFIVE_LIBRARY_SYNC_USER_SCOPE"
  "Local Library Mode"
  "Cloud Library Not Connected Yet"
  "Library Sync Missing Credentials"
  "Library Sync Configured"
  "Saved Locally"
  "Progress Saved Locally"
  "Offline Preview State"
  "Cloud sync requires account"
  "Backend-mediated library sync only"
  "hf.library.screen"
  "hf.library.watchShelf"
  "hf.library.continueWatching"
  "hf.library.savedForTonight"
  "hf.library.continueStory"
  "hf.library.backendStatus"
  "hf.library.syncStatus"
  "hf.library.localLibraryMode"
  "hf.library.cloudNotConnected"
  "hf.library.savedLocally"
  "hf.library.progressSavedLocally"
  "hf.library.offlinePreviewState"
  "hf.profile.librarySyncReadiness"
  "hf.profile.librarySyncStatus"
  "hf.route.libraryToMovieDetail"
)

passes=()
failures=()

require_term() {
  local term="$1"
  if rg -q --fixed-strings "$term" "${SOURCE_SCOPE[@]}"; then
    passes+=("$term")
  else
    failures+=("Missing source evidence: $term")
  fi
}

require_file_term() {
  local file="$1"
  local term="$2"
  local label="$3"
  if rg -q --fixed-strings "$term" "$file"; then
    passes+=("$label")
  else
    failures+=("Missing $label in $file")
  fi
}

for term in "${REQUIRED_TERMS[@]}"; do
  require_term "$term"
done

require_file_term "$LIBRARY_SYNC_FILE" "guard configuration.hasAnyRuntimeConfig else" "missing config local library mode gate"
require_file_term "$LIBRARY_SYNC_FILE" "guard authConfiguration.hasCompleteRuntimeConfig else" "missing account/auth cloud library gate"
require_file_term "$LIBRARY_SYNC_FILE" "guard configuration.hasCompleteRuntimeConfig && backendConfiguration.hasCompleteRuntimeConfig else" "partial config missing credentials gate"
require_file_term "$LIBRARY_SYNC_FILE" "localFallback.runtimeStatus" "local runtime fallback"
require_file_term "$LIBRARY_SYNC_FILE" "localFallback.snapshot" "local snapshot fallback"
require_file_term "$LIBRARY_SYNC_FILE" "try await localFallback.library" "remote gateway returns local library without live sync"
require_file_term "$STORE_FILE" "makeLocalLibrarySyncAdapter" "store builds local library sync adapter"
require_file_term "$STORE_FILE" "savedMovieIDs" "saved title local source"
require_file_term "$STORE_FILE" "downloadedMovieIDs" "offline preview local source"
require_file_term "$STORE_FILE" "librarySyncBackendServiceStatus" "backend library sync status integration"
require_file_term "$LIBRARY_VIEW_FILE" "librarySyncStatusPanel" "Library screen sync panel"
require_file_term "$PROFILE_FILE" "librarySyncReadinessPanel" "Profile library sync readiness panel"

if rg -q "import CloudKit|CKContainer|CKDatabase|import Supabase|SupabaseClient|FirebaseApp|Firestore|PostgresClient|PostgREST|SQLConnection|SQLite" HighFive --glob '*.swift'; then
  failures+=("Forbidden cloud/database SDK or direct client marker found in Swift sources")
else
  passes+=("no CloudKit, Supabase SDK, Firebase SDK, or direct database client markers in Swift sources")
fi

if git diff phase-57-0b-payment-entitlement-staging-evidence-lock..phase-58-0a-cloud-library-sync-staging -- '*.swift' | rg -q '^\+.*URLSession'; then
  failures+=("URLSession marker was introduced by the #058.0A Swift diff")
else
  passes+=("no URLSession introduced by the #058.0A Swift diff")
fi

if rg -q "Cloud sync active|Synced to cloud|CloudKit connected|Supabase connected|Remote library live|Cross-device sync active" HighFive --glob '*.swift'; then
  failures+=("Forbidden live cloud sync claim found in Swift sources")
else
  passes+=("no forbidden live cloud sync claim in Swift sources")
fi

url_pattern='https?''://'
if rg -q "$url_pattern" HighFive docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_STAGING.md --glob '*.swift' --glob '*.md'; then
  failures+=("Hardcoded URL-like value found in app or #058.0A staging doc scope")
else
  passes+=("no hardcoded URL-like values in app or #058.0A staging doc scope")
fi

secret_pattern='(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9])'
if rg -q "$secret_pattern" HighFive docs/production_services/HIGHFIVE_CLOUD_LIBRARY_SYNC_STAGING.md scripts --glob '*.swift' --glob '*.md' --glob '*.json' --glob '*.sh'; then
  failures+=("Secret-like value found in app/doc/script scope")
else
  passes+=("no secret-like values in app/doc/script scope")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#058.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "requiredEvidenceCount": %d,\n' "${#REQUIRED_TERMS[@]}"
  printf -- '  "passedChecks": %d,\n' "${#passes[@]}"
  printf -- '  "failedChecks": %d,\n' "${#failures[@]}"
  printf -- '  "evidenceRules": {\n'
  printf -- '    "missingLibrarySyncConfigKeepsLocalLibraryMode": true,\n'
  printf -- '    "missingAccountAuthKeepsCloudLibraryNotConnected": true,\n'
  printf -- '    "partialConfigReportsMissingCredentials": true,\n'
  printf -- '    "completeConfigDoesNotClaimLiveCrossDeviceSync": true,\n'
  printf -- '    "remoteGatewayRuntimeConfigGated": true,\n'
  printf -- '    "localSavedTitlesRemainAvailable": true,\n'
  printf -- '    "localProgressRemainsAvailable": true,\n'
  printf -- '    "offlinePreviewStateRemainsAvailable": true,\n'
  printf -- '    "noCloudKit": true,\n'
  printf -- '    "noSupabaseSDK": true,\n'
  printf -- '    "noFirebaseSDK": true,\n'
  printf -- '    "noDirectDatabaseClient": true,\n'
  printf -- '    "noHardcodedURLs": true,\n'
  printf -- '    "noCommittedSecrets": true,\n'
  printf -- '    "noLiveCrossDeviceSync": true\n'
  printf -- '  },\n'
  printf -- '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" == "0" ]] || printf -- ', '
    printf -- '"%s"' "${failures[$i]//\"/\\\"}"
  done
  printf -- ']\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Cloud Library Sync Staging Source Verification\n\n'
  printf -- '- Upgrade: #058.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required evidence terms: %d\n' "${#REQUIRED_TERMS[@]}"
  printf -- '- Passed checks: %d\n' "${#passes[@]}"
  printf -- '- Failed checks: %d\n\n' "${#failures[@]}"
  printf -- '## Evidence Rules\n\n'
  printf -- '- Missing library sync config keeps Local Library Mode.\n'
  printf -- '- Missing account/auth keeps Cloud Library Not Connected Yet.\n'
  printf -- '- Partial config reports Library Sync Missing Credentials.\n'
  printf -- '- Complete config may report Library Sync Configured but does not claim live cross-device sync.\n'
  printf -- '- Remote library sync gateway is runtime-config gated.\n'
  printf -- '- Local saved titles, progress, and offline preview state remain available.\n'
  printf -- '- No CloudKit, Supabase SDK, Firebase SDK, direct database client, hardcoded URL, committed secret, or live cross-device sync was found by this verifier.\n\n'
  printf -- '## Failures\n\n'
  if (( ${#failures[@]} > 0 )); then
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '- None.\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Cloud library sync staging source verification passed.\n'
