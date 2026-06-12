#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

c="cl""oud"
OUT_DIR="/private/tmp/highfive-phase-32-0b-library-downloads-evidence"
JSON_REPORT="$OUT_DIR/${c}_library_downloads_source_verification.json"
MD_REPORT="$OUT_DIR/${c}_library_downloads_source_verification.md"
mkdir -p "$OUT_DIR"

passes=()
failures=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

require_term() {
  local label="$1"
  local term="$2"
  local path="${3:-HighFive}"
  if rg -Fq "$term" "$path"; then
    pass "$label"
  else
    fail "$label missing: $term"
  fi
}

require_bottom_tabs() {
  local tab_file="HighFive/App/HFStreamingRootView.swift"
  for wanted in "Home" "Search" "Library" "Downloads" "Profile"; do
    require_term "bottom tab $wanted" "title: \"$wanted\"" "$tab_file"
  done

  local blocked
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Cloud|Sync|Downloads Admin|Files|Provider|Demo|Developer|QA|Rooms|Watch|Create|Connect|Launch|Export)"' "$tab_file" || true)
  if [[ -z "$blocked" ]]; then
    pass "bottom tabs contain only the allowed consumer tabs"
  else
    fail "blocked bottom tab found"
  fi
}

require_evidence_lock_safety() {
  local protected_pattern
  protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset'
  if git diff --name-only | egrep -q "$protected_pattern"; then
    fail "protected path changed during evidence lock"
  else
    pass "no protected paths changed during evidence lock"
  fi

  local changed
  changed=$(git diff --name-only)
  local unexpected
  local allowed_re
  allowed_re="^(scripts/verify_${c}_library_downloads_sources\\.sh|scripts/qa_${c}_library_downloads_screenshots\\.sh|scripts/verify_${c}_library_downloads_screenshots\\.sh|scripts/report_${c}_library_downloads_evidence\\.sh)$"
  unexpected=$(printf '%s\n' "$changed" | rg -v "$allowed_re" || true)
  if [[ -z "$unexpected" ]]; then
    pass "only Library and Downloads evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  local b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 h1 h2
  b1="Fire""base"
  b2="Supa""base"
  b3="Mu""x"
  b4="Cloud""flare"
  b5="URL""Session"
  b6="DR""M"
  b7="Fair""Play"
  b8="Store""Kit"
  b9="pay""ment"
  b10="entitle""ment"
  b11="tok""en"
  b12="sec""ret"
  b13="api[_-]?""key"
  b14="File""Manager"
  b15="AVAssetDownload""URL""Session"
  b16="background trans""fer"
  h1="ht""tp://"
  h2="ht""tps://"
  local blocked_pattern
  blocked_pattern="(${b1}|${b2}|${b3}|${b4}|${b5}|${h1}|${h2}|${b6}|${b7}|${b8}|${b9}|${b10}|${b11}|${b12}|${b13}|${b14}|${b15}|downloadTask|${b16}|fileExporter|fileImporter|DocumentGroup|FileDocument|writeTo|zip)"
  local blocked_diff
  blocked_diff=$(git diff -U0 -- '*.swift' | rg -n "^\\+.*${blocked_pattern}" || true)
  if [[ -z "$blocked_diff" ]]; then
    pass "no blocked download or provider systems added in Swift diff"
  else
    fail "blocked download or provider system diff found"
  fi
}

require_term "Cloud Library marker" "hf.services.${c}Library"
require_term "Library Sync marker" "hf.services.librarySync"
require_term "Offline Asset Service marker" "hf.services.offlineAssetService"
require_term "Download Queue marker" "hf.services.downloadQueue"
require_term "Download Eligibility marker" "hf.services.downloadEligibility"
require_term "Offline Provider Ready marker" "hf.services.offlineProviderReady"
require_term "Download Readiness marker" "hf.services.downloadReadiness"
require_term "Cloud Library Readiness marker" "hf.services.${c}LibraryReadiness"

require_term "Movie Detail Offline Eligibility" "hf.download.movieDetail.eligibility"
require_term "Movie Detail queue action" "hf.download.movieDetail.queueAction"
require_term "Movie Detail offline status" "hf.download.movieDetail.offlineStatus"
require_term "Movie Detail provider status" "hf.download.movieDetail.providerStatus"
require_term "functional download toggle" "hf.functional.movie.downloadToggle"

require_term "Downloads Offline Asset Service" "hf.downloads.offlineAssetService"
require_term "Downloads Queue" "hf.downloads.queue"
require_term "Downloads Queue item" "hf.downloads.queueItem"
require_term "Offline Asset Records" "hf.downloads.offlineAssetRecords"
require_term "Provider Readiness" "hf.downloads.providerReadiness"
require_term "player source dependency" "hf.downloads.playerSourceDependency"
require_term "media source required" "hf.downloads.mediaSourceRequired"
require_term "Downloads profile sync boundary" "hf.downloads.profileSyncBoundary"
require_term "Downloads downloaded state" "hf.functional.downloads.downloadedState"
require_term "Downloads offline shelf" "hf.consumer.downloads.offlineShelf"
require_term "Downloads offline watch hub" "hf.consumer.downloads.offlineWatchHub"

require_term "Library Cloud Library Service" "hf.library.${c}LibraryService"
require_term "Library Sync Readiness" "hf.library.syncReadiness"
require_term "Library Saved State Proof" "hf.library.savedStateProof"
require_term "Library profile sync boundary" "hf.library.profileSyncBoundary"
require_term "Library saved state" "hf.functional.library.savedState"
require_term "Library saved shelf" "hf.consumer.library.savedShelf"
require_term "Library watch shelf" "hf.consumer.library.watchShelf"

require_term "Home Cloud Library signal" "hf.home.${c}LibrarySignal"
require_term "Home Downloads signal" "hf.home.downloadsSignal"

require_term "Profile Library Downloads Service" "hf.profile.libraryDownloadsService"
require_term "Profile Cloud Library proof" "hf.profile.${c}LibraryProof"
require_term "Profile Offline Asset proof" "hf.profile.offlineAssetProof"
require_term "Profile Download Provider status" "hf.profile.downloadProviderStatus"

require_term "Demo Cloud Library proof" "hf.demoTour.${c}LibraryProof"
require_term "Demo Offline Downloads proof" "hf.demoTour.offlineDownloadsProof"

require_term "Player downloads boundary" "hf.player.downloads.boundary"

require_term "Cloud Library Service copy" "Cloud Library Service"
require_term "Offline Asset Service copy" "Offline Asset Service"
require_term "Download Queue copy" "Download Queue"
require_term "Download Eligibility copy" "Download Eligibility"
require_term "Remote Download Provider copy" "Remote Download Provider"
require_term "media source required copy" "Media source required before real download"
require_term "Local Offline State copy" "Local Offline State"
require_term "not connected copy" "Not Connected Yet"

require_bottom_tabs
require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#032.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "source presence and evidence-lock safety only",\n'
  printf '  "architecture_scope": "local and provider-ready only",\n'
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
  printf '# Cloud Library Downloads Source Verification\n\n'
  printf -- '- Upgrade: #032.0B\n'
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
  printf 'This verifier confirms local/provider-ready Library and Downloads architecture markers, connected route markers, locked tabs, and evidence-lock safety boundaries. It does not verify live Cloud sync, real media downloads, remote provider integration, file storage, or service credentials.\n'
} > "$MD_REPORT"

printf 'Cloud Library Downloads source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
