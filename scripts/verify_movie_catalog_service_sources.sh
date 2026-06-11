#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-30-0b-catalog-evidence"
JSON_REPORT="$OUT_DIR/movie_catalog_service_source_verification.json"
MD_REPORT="$OUT_DIR/movie_catalog_service_source_verification.md"
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

require_absent_tabs() {
  local tab_file="HighFive/App/HFStreamingRootView.swift"
  for wanted in "Home" "Search" "Library" "Downloads" "Profile"; do
    require_term "bottom tab $wanted" "title: \"$wanted\"" "$tab_file"
  done

  local blocked
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Catalog|Search Provider|Admin|Demo|Developer|QA|Rooms|Watch|Create|Connect|Launch|Export)"' "$tab_file" || true)
  if [[ -z "$blocked" ]]; then
    pass "bottom tabs contain only the allowed consumer tabs"
  else
    fail "blocked bottom tab found"
  fi
}

require_safety() {
  local protected_pattern
  protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset'
  if git diff --name-only | egrep -q "$protected_pattern"; then
    fail "protected path changed"
  else
    pass "no protected paths changed"
  fi

  if git diff --name-only | egrep -q '^HighFive/.*\.swift$'; then
    fail "app source changed during evidence lock"
  else
    pass "no app source changed during evidence lock"
  fi

  local changed
  changed=$(git diff --name-only)
  local unexpected
  unexpected=$(printf '%s\n' "$changed" | rg -v '^(scripts/verify_movie_catalog_service_sources\.sh|scripts/qa_movie_catalog_service_screenshots\.sh|scripts/verify_movie_catalog_service_screenshots\.sh|scripts/report_movie_catalog_service_evidence\.sh)$' || true)
  if [[ -z "$unexpected" ]]; then
    pass "only movie catalog evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  pass "provider, credential, and URL scans are run outside this verifier"
}

require_term "movie catalog marker" "hf.services.movieCatalog"
require_term "catalog provider marker" "hf.services.catalogProvider"
require_term "local catalog adapter marker" "hf.services.localCatalogAdapter"
require_term "remote catalog ready marker" "hf.services.remoteCatalogReady"
require_term "catalog readiness marker" "hf.services.catalogReadiness"
require_term "catalog identity marker" "hf.services.catalogIdentity"
require_term "movie lookup marker" "hf.services.movieLookup"

require_term "Home catalog connection" "hf.catalog.home.connected"
require_term "Home featured route" "hf.functional.home.featuredMovieRoute"
require_term "Home continue route" "hf.functional.home.continueWatchingRoute"

require_term "Search catalog connection" "hf.catalog.search.connected"
require_term "Discover catalog connection" "hf.catalog.discover.connected"
require_term "Search discovery studio" "hf.consumer.search.discoveryStudio"
require_term "Discovery rails" "hf.consumer.discovery.rails"

require_term "Movie Detail catalog identity" "hf.catalog.movieDetail.identity"
require_term "Movie Detail Watch Now" "hf.consumer.movieDetail.watchNow"
require_term "Movie Detail save toggle" "hf.functional.movie.saveToggle"
require_term "Movie Detail download toggle" "hf.functional.movie.downloadToggle"

require_term "Library catalog connection" "hf.catalog.library.connected"
require_term "Library saved state" "hf.functional.library.savedState"
require_term "Library saved shelf" "hf.consumer.library.savedShelf"

require_term "Downloads catalog connection" "hf.catalog.downloads.connected"
require_term "Downloads downloaded state" "hf.functional.downloads.downloadedState"
require_term "Downloads offline shelf" "hf.consumer.downloads.offlineShelf"

require_term "Profile catalog summary" "hf.catalog.profile.serviceSummary"
require_term "Profile catalog readiness" "hf.catalog.profile.readiness"
require_term "Profile catalog proof" "hf.profile.catalogServiceProof"

require_term "Demo catalog proof" "hf.demoTour.catalogServiceProof"
require_term "Demo remote-ready catalog proof" "hf.demoTour.remoteCatalogReadyProof"

require_term "Connect title context" "hf.catalog.connect.titleContext"
require_term "Launch title context" "hf.catalog.launch.titleContext"
require_term "Export title context" "hf.catalog.export.titleContext"

require_term "Remote-ready status" "hf.catalog.remoteReady.status"
require_term "Local adapter active" "hf.catalog.localAdapter.active"
require_term "Provider not connected" "hf.catalog.provider.notConnected"

require_term "Movie catalog service copy" "Movie Catalog Service"
require_term "Catalog connected copy" "Catalog Connected"
require_term "Catalog search copy" "Catalog Search"
require_term "Catalog identity copy" "Catalog Identity"
require_term "Catalog library copy" "Catalog Library"
require_term "Catalog downloads copy" "Catalog Downloads"
require_term "Remote catalog provider copy" "Remote Catalog Provider"
require_term "Local catalog adapter copy" "Local Catalog Adapter"
require_term "Not connected copy" "Not Connected Yet"

require_absent_tabs
require_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#030.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "local catalog and provider-ready source presence only",\n'
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
  printf '# Movie Catalog Service Source Verification\n\n'
  printf -- '- Upgrade: #030.0B\n'
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
  printf 'This verifier confirms local movie catalog source markers, connected route markers, locked tabs, and evidence-lock safety boundaries. It does not verify a live remote catalog, endpoint, CMS, sync service, video host, or provider credentials.\n'
} > "$MD_REPORT"

printf 'Movie catalog service source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
