#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-28-0b-unified-services-evidence"
JSON_REPORT="$OUT_DIR/unified_app_services_source_verification.json"
MD_REPORT="$OUT_DIR/unified_app_services_source_verification.md"
mkdir -p "$OUT_DIR"

passes=()
failures=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }

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
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Watch|Create|Connect|Launch|Export|Demo|Developer|QA)"' "$tab_file" || true)
  if [[ -z "$blocked" ]]; then
    pass "bottom tabs contain no room/internal tabs"
  else
    fail "blocked bottom tab found"
  fi
}

require_clean_safety() {
  if git diff --name-only | egrep -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset'; then
    fail "protected path changed"
  else
    pass "no protected paths changed"
  fi

  local media_picker_pattern="Pho""tosPicker"
  local telemetry_pattern="track""ing SDK"
  local blocked_pattern="^\\+.*(Firebase|Supabase|URLSession|AuthenticationServices|${media_picker_pattern}|UIImagePickerController|PHPicker|UIDocumentPicker|AVCapture|UNUserNotificationCenter|SKPayment|purchase|subscription|entitlement|account login|push notification|${telemetry_pattern}|fileExporter|fileImporter|DocumentGroup|FileDocument|writeTo|zip|submit to platform|ticket|waitlist)"
  local blocked
  blocked=$(git diff -U0 -- '*.swift' | rg -n "$blocked_pattern" || true)
  if [[ -z "$blocked" ]]; then
    pass "no blocked live-system Swift additions"
  else
    fail "blocked live-system Swift addition found"
  fi
}

require_term "unified store marker" "hf.services.unifiedStore"
require_term "movie catalog marker" "hf.services.movieCatalog"
require_term "library state marker" "hf.services.libraryState"
require_term "download state marker" "hf.services.downloadState"
require_term "connect updates marker" "hf.services.connectUpdates"
require_term "launch checklist marker" "hf.services.launchChecklist"
require_term "export summary marker" "hf.services.exportSummary"

require_term "home root" "hf.consumer.home.root"
require_term "home featured route" "hf.functional.home.featuredMovieRoute"
require_term "home continue route" "hf.functional.home.continueWatchingRoute"
require_term "home ecosystem route" "hf.functional.home.ecosystemRoute"

require_term "movie detail root" "hf.consumer.movieDetail.root"
require_term "movie detail watch now" "hf.consumer.movieDetail.watchNow"
require_term "player sheet" "hf.functional.player.sheet"
require_term "player close" "hf.functional.player.close"
require_term "save toggle" "hf.functional.movie.saveToggle"
require_term "download toggle" "hf.functional.movie.downloadToggle"

require_term "library saved state" "hf.functional.library.savedState"
require_term "library connected state" "hf.functional.library.connectedState"
require_term "library saved shelf" "hf.consumer.library.savedShelf"
require_term "library watch shelf" "hf.consumer.library.watchShelf"

require_term "downloads state" "hf.functional.downloads.downloadedState"
require_term "downloads connected state" "hf.functional.downloads.connectedState"
require_term "downloads shelf" "hf.consumer.downloads.offlineShelf"
require_term "downloads watch hub" "hf.consumer.downloads.offlineWatchHub"

require_term "connect local updates" "hf.functional.connect.localUpdates"
require_term "connect input" "hf.functional.connect.updateInput"
require_term "connect add action" "hf.functional.connect.addLocalUpdate"
require_term "connect update list" "hf.functional.connect.updateList"
require_term "connect connected state" "hf.functional.connect.connectedState"
require_term "connect copy" "Local Audience Updates"

require_term "launch checklist" "hf.functional.launch.localChecklist"
require_term "launch progress" "hf.functional.launch.checklistProgress"
require_term "launch toggle" "hf.functional.launch.checklistToggle"
require_term "launch review" "hf.functional.launch.reviewProgress"
require_term "launch connected state" "hf.functional.launch.connectedState"
require_term "launch copy" "Local Release Checklist"

require_term "export delivery summary" "hf.functional.export.deliverySummary"
require_term "export generate summary" "hf.functional.export.generateSummary"
require_term "export summary text" "hf.functional.export.summaryText"
require_term "export connected state" "hf.functional.export.connectedState"
require_term "export copy" "Generate Delivery Summary"
if rg -Fq "hf.functional.export.shareSummary" HighFive; then
  pass "export share summary optional present"
else
  pass "export share summary optional skipped"
fi

require_term "onboarding brand intro" "hf.onboarding.brandIntro"
require_term "onboarding motion" "hf.onboarding.motionTraining"
require_term "onboarding controls" "hf.onboarding.controlsTraining"
require_term "onboarding home reveal" "hf.onboarding.homeReveal"
require_term "onboarding enters home" "hf.functional.onboarding.entersHome"

require_term "profile functional core" "hf.profile.functionalCoreSummary"
require_term "profile connected summary" "hf.profile.connectedAppSummary"
require_term "demo functional core" "hf.demoTour.functionalCoreProof"
require_term "demo connected proof" "hf.demoTour.connectedAppProof"
require_term "presentation mode remains present" "Ecosystem Presentation Mode"

require_term "copy connected state" "Connected State"
require_term "copy connected offline state" "Connected Offline State"
require_term "copy connected local updates" "Connected Local Updates"
require_term "copy connected launch progress" "Connected Launch Progress"
require_term "copy connected delivery summary" "Connected Delivery Summary"
require_term "copy connected app proof" "Connected App Proof"

require_absent_tabs
require_clean_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#028.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(printf '%s' "${passes[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(printf '%s' "${failures[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Unified App Services Source Verification\n\n'
  printf -- '- Upgrade: #028.0B\n'
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
  printf 'This verifies source presence and safety markers. Interactive behavior is covered by screenshots and manual review.\n'
} > "$MD_REPORT"

printf 'Unified app services source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
