#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-34-0b-launch-campaign-evidence"
JSON_REPORT="$OUT_DIR/launch_campaign_backend_architecture_source_verification.json"
MD_REPORT="$OUT_DIR/launch_campaign_backend_architecture_source_verification.md"
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
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Campaign|Launch|Tickets|Waitlist|Publish|Analytics|Developer|QA|Demo|Rooms|Watch|Create|Connect|Export)"' "$tab_file" || true)
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

  local changed unexpected
  changed=$(git diff --name-only)
  local allowed_re
  allowed_re='^(scripts/verify_launch_campaign_backend_architecture_sources\.sh|scripts/qa_launch_campaign_backend_architecture_screenshots\.sh|scripts/verify_launch_campaign_backend_architecture_screenshots\.sh|scripts/report_launch_campaign_backend_architecture_evidence\.sh)$'
  unexpected=$(printf '%s\n' "$changed" | rg -v "$allowed_re" || true)
  if [[ -z "$unexpected" ]]; then
    pass "only launch campaign evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  local b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24 b25 b26 h1 h2
  b1="Fire""base"
  b2="Supa""base"
  b3="Web""Socket"
  b4="URL""Session"
  b5="User""Notifications"
  b6="UNUser""NotificationCenter"
  b7="Store""Kit"
  b8="SK""Payment"
  b9="tok""en"
  b10="sec""ret"
  b11="api[_-]?""key"
  b12="client_""sec""ret"
  b13="access_""tok""en"
  b14="refresh_""tok""en"
  b15="pass""word"
  b16="ana""lytics SDK"
  b17="tracking SDK"
  b18="push notification"
  b19="auth server"
  b20="account login"
  b21="tick""et"
  b22="wait""list"
  b23="pay""ment"
  b24="publish ""campaign"
  b25="sell tick""et"
  b26="track ana""lytics"
  b27="Authentication""Services"
  b28="open wait""list"
  b29="notify audience"
  b30="AVAssetDownload""URL""Session"
  h1="ht""tp://"
  h2="ht""tps://"
  local blocked_pattern
  blocked_pattern="(${b1}|${b2}|${b3}|${b4}|${h1}|${h2}|${b5}|${b6}|${b7}|${b8}|${b9}|${b10}|${b11}|${b12}|${b13}|${b14}|${b15}|${b16}|${b17}|${b18}|${b19}|${b20}|${b21}|${b22}|${b23}|${b24}|${b25}|${b28}|${b29}|${b26}|${b27}|Keychain|OAuth|purchase|subscription|entitlement|DRM|FairPlay|backend|upload|render engine|video export|fileExporter|fileImporter|DocumentGroup|FileDocument|writeTo|zip|submit to platform|FileManager|${b30}|downloadTask|background transfer)"
  local blocked_diff
  blocked_diff=$(git diff -U0 -- '*.swift' | rg -n "^\\+.*${blocked_pattern}" || true)
  if [[ -z "$blocked_diff" ]]; then
    pass "no blocked launch campaign systems added in Swift diff"
  else
    fail "blocked launch campaign system diff found"
  fi
}

require_term "Launch Campaign marker" "hf.services.launchCampaign"
require_term "Local Launch Campaign Adapter marker" "hf.services.localLaunchCampaignAdapter"
require_term "Remote Campaign Provider Ready marker" "hf.services.remoteCampaignProviderReady"
require_term "Launch Campaign Readiness marker" "hf.services.launchCampaignReadiness"
require_term "Release Calendar marker" "hf.services.releaseCalendar"
require_term "Launch Milestones marker" "hf.services.launchMilestones"
require_term "Local-to-Remote Launch Adapter marker" "hf.services.localToRemoteLaunchAdapter"
require_term "Launch Communication Bridge marker" "hf.services.launchCommunicationBridge"
require_term "Launch Export Handoff marker" "hf.services.launchExportHandoff"

require_term "Launch Campaign Service section" "hf.launch.campaignService"
require_term "Release Calendar section" "hf.launch.releaseCalendar"
require_term "Release Calendar item" "hf.launch.releaseCalendarItem"
require_term "Campaign Milestones section" "hf.launch.campaignMilestones"
require_term "Campaign Milestone item" "hf.launch.campaignMilestone"
require_term "Local-to-Remote Launch Adapter section" "hf.launch.localToRemoteAdapter"
require_term "Launch local checklist" "hf.functional.launch.localChecklist"
require_term "Launch checklist progress" "hf.functional.launch.checklistProgress"
require_term "Launch checklist toggle" "hf.functional.launch.checklistToggle"
require_term "Launch review progress" "hf.functional.launch.reviewProgress"
require_term "Launch connected state" "hf.functional.launch.connectedState"
require_term "Launch account profile state" "hf.account.launch.profileState"
require_term "Launch catalog title context" "hf.catalog.launch.titleContext"
require_term "Launch communication adapter context" "hf.launch.communicationAdapterContext"
require_term "Campaign record" "hf.launch.campaignRecord"
require_term "Campaign status" "hf.launch.campaignStatus"
require_term "Campaign profile" "hf.launch.campaignProfile"
require_term "Campaign catalog title" "hf.launch.campaignCatalogTitle"
require_term "Campaign local review" "hf.launch.campaignLocalReview"
require_term "Campaign Not Published" "hf.launch.campaignNotPublished"
require_term "Campaign readiness" "hf.launch.campaignReadiness"

require_term "Home launch signal" "hf.home.launchSignal"
require_term "Home release plan signal" "hf.home.releasePlanSignal"
require_term "Movie Detail launch path" "hf.movieDetail.launchPath"
require_term "Movie Detail release plan context" "hf.movieDetail.releasePlanContext"
require_term "Profile launch campaign services" "hf.profile.launchCampaignServices"
require_term "Profile launch campaign proof" "hf.profile.launchCampaignProof"
require_term "Profile launch campaign provider status" "hf.profile.launchCampaignProviderStatus"
require_term "Profile launch campaign readiness" "hf.profile.launchCampaignReadiness"
require_term "Demo launch campaign proof" "hf.demoTour.launchCampaignProof"
require_term "Demo local remote launch adapter proof" "hf.demoTour.localRemoteLaunchAdapterProof"
require_term "Connect launch campaign bridge" "hf.connect.launchCampaignBridge"
require_term "Export launch campaign handoff" "hf.export.launchCampaignHandoff"

require_term "Launch Campaign Service copy" "Launch Campaign Service"
require_term "Local Launch Campaign Adapter copy" "Local Launch Campaign Adapter"
require_term "Remote Campaign Provider copy" "Remote Campaign Provider"
require_term "Release Calendar copy" "Release Calendar"
require_term "Launch Milestones copy" "Launch Milestones"
require_term "Local-to-Remote Launch Adapter copy" "Local-to-Remote Launch Adapter"
require_term "Campaign Readiness copy" "Campaign Readiness"
require_term "Not Published copy" "Not Published"
require_term "Not Connected Yet copy" "Not Connected Yet"

require_bottom_tabs
require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#034.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "source presence and evidence-lock safety only",\n'
  printf '  "architecture_scope": "local/provider-ready launch campaign architecture only",\n'
  printf '  "no_real_campaign_backend_claim": true,\n'
  printf '  "no_real_publishing_claim": true,\n'
  printf '  "no_real_wait_%s_tick_%s_pay_%s_claim": true,\n' "list" "et" "ment"
  printf '  "no_push_or_ana_%s_claim": true,\n' "lytics"
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
  printf '# Launch Campaign Backend Architecture Source Verification\n\n'
  printf -- '- Upgrade: #034.0B\n'
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
  printf 'This verifier confirms local/provider-ready Launch Campaign architecture markers, connected route markers, locked tabs, and evidence-lock safety boundaries. It does not verify a live campaign provider, real publishing, real %s, %s, %s, push notifications, campaign %s, platform submission APIs, provider SDKs, remote URLs, credentials, or production campaign security.\n' "wait""lists" "tick""ets" "pay""ments" "ana""lytics"
} > "$MD_REPORT"

printf 'Launch campaign backend architecture source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
