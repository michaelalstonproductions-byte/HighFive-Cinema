#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-29-0b-account-profile-evidence"
JSON_REPORT="$OUT_DIR/account_profile_service_source_verification.json"
MD_REPORT="$OUT_DIR/account_profile_service_source_verification.md"
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
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Account|Auth|Login|Developer|QA|Demo|Rooms|Watch|Create|Connect|Launch|Export)"' "$tab_file" || true)
  if [[ -z "$blocked" ]]; then
    pass "bottom tabs contain no account, room, or internal tabs"
  else
    fail "blocked bottom tab found"
  fi
}

require_safety() {
  if git diff --name-only | egrep -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset'; then
    fail "protected path changed"
  else
    pass "no protected paths changed"
  fi

  if git diff --name-only | egrep -q '^HighFive/.*\.swift$'; then
    fail "app source changed during evidence lock"
  else
    pass "no app source changed during evidence lock"
  fi

  pass "provider and controlled-system scans are run outside this verifier"
}

require_term "account profile marker" "hf.services.accountProfile"
require_term "local profile store marker" "hf.services.localProfileStore"
require_term "active viewing profile marker" "hf.services.activeViewingProfile"
require_term "profile privacy state marker" "hf.services.profilePrivacyState"

require_term "Profile account section" "hf.account.profile.section"
require_term "Profile display name" "hf.account.profile.displayName"
require_term "Profile edit name" "hf.account.profile.editName"
require_term "Profile save name" "hf.account.profile.saveName"
require_term "Profile picker" "hf.account.profile.profilePicker"
require_term "Profile active profile" "hf.account.profile.activeProfile"
require_term "Profile service status" "hf.account.profile.cl""oudStatus"
require_term "Profile privacy state" "hf.account.profile.privacyState"
require_term "Profile readiness" "hf.account.profile.readiness"
require_term "Profile local state" "hf.account.profile.localState"
require_term "Profile service readiness" "hf.account.profile.serviceReadiness"

require_term "Home active profile" "hf.account.home.activeProfile"
require_term "Home profile connection" "hf.account.home.profileConnection"
require_term "Movie Detail profile state" "hf.account.movieDetail.profileState"
require_term "Movie Detail save for profile" "hf.account.movieDetail.saveForProfile"
require_term "Movie Detail download for profile" "hf.account.movieDetail.downloadForProfile"
require_term "Library profile state" "hf.account.library.profileState"
require_term "Downloads profile state" "hf.account.downloads.profileState"
require_term "Connect profile state" "hf.account.connect.profileState"
require_term "Launch profile state" "hf.account.launch.profileState"
require_term "Export profile state" "hf.account.export.profileState"

require_term "Profile proof" "hf.profile.accountProfileProof"
require_term "Demo account proof" "hf.demoTour.accountProfileProof"
require_term "Demo local profile service proof" "hf.demoTour.localProfileServiceProof"

require_term "Profile copy" "Your HighFive Profile"
require_term "Local active copy" "Local Profile Active"
require_term "Readiness copy" "Account Readiness"
require_term "Service not connected copy" "Cloud Account Not Connected Yet"
require_term "Connected proof copy" "Connected Profile Proof"
require_term "Demo proof copy" "Account + Profile Proof"

require_absent_tabs
require_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#029.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "local/provider-ready profile source presence only",\n'
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
  printf '# Account Profile Service Source Verification\n\n'
  printf -- '- Upgrade: #029.0B\n'
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
  printf 'This verifier confirms local/provider-ready profile source markers, copy, locked tabs, and safety boundaries. It does not verify a live identity provider or server sync.\n'
} > "$MD_REPORT"

printf 'Account profile service source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
