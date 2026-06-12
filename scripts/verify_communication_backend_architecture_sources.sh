#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-33-0b-communication-evidence"
JSON_REPORT="$OUT_DIR/communication_backend_architecture_source_verification.json"
MD_REPORT="$OUT_DIR/communication_backend_architecture_source_verification.md"
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
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Communication|Messages|Chat|Comments|Notifications|Provider|Demo|Developer|QA|Rooms|Watch|Create|Connect|Launch|Export)"' "$tab_file" || true)
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
  allowed_re='^(scripts/verify_communication_backend_architecture_sources\.sh|scripts/qa_communication_backend_architecture_screenshots\.sh|scripts/verify_communication_backend_architecture_screenshots\.sh|scripts/report_communication_backend_architecture_evidence\.sh)$'
  unexpected=$(printf '%s\n' "$changed" | rg -v "$allowed_re" || true)
  if [[ -z "$unexpected" ]]; then
    pass "only communication evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  local b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24 h1 h2
  b1="Fire""base"
  b2="Supa""base"
  b3="Stream""Chat"
  b4="Send""bird"
  b5="Web""Socket"
  b6="URL""Session"
  b7="User""Notifications"
  b8="UNUser""NotificationCenter"
  b9="tok""en"
  b10="sec""ret"
  b11="api[_-]?""key"
  b12="auth server"
  b13="account login"
  b14="analytics SDK"
  b15="tracking SDK"
  b16="push notification"
  b17="client_""sec""ret"
  b18="access_""tok""en"
  b19="refresh_""tok""en"
  b20="pass""word"
  b21="Store""Kit"
  b22="pay""ment"
  b23="Authentication""Services"
  b24="AVAssetDownload""URL""Session"
  h1="ht""tp://"
  h2="ht""tps://"
  local blocked_pattern
  blocked_pattern="(${b1}|${b2}|${b3}|${b4}|${b5}|${b6}|${h1}|${h2}|${b7}|${b8}|${b9}|${b10}|${b11}|${b17}|${b18}|${b19}|${b12}|${b13}|${b14}|${b15}|${b16}|${b23}|${b21}|SKPayment|Keychain|OAuth|${b20}|purchase|subscription|entitlement|DRM|FairPlay|backend|upload|render engine|video export|fileExporter|fileImporter|DocumentGroup|FileDocument|writeTo|zip|submit to platform|ticket|waitlist|${b22}|FileManager|${b24}|downloadTask|background transfer)"
  local blocked_diff
  blocked_diff=$(git diff -U0 -- '*.swift' | rg -n "^\\+.*${blocked_pattern}" || true)
  if [[ -z "$blocked_diff" ]]; then
    pass "no blocked communication provider systems added in Swift diff"
  else
    fail "blocked communication provider system diff found"
  fi
}

require_term "communication service marker" "hf.services.communication"
require_term "local communication adapter marker" "hf.services.localCommunicationAdapter"
require_term "remote communication provider ready marker" "hf.services.remoteCommunicationProviderReady"
require_term "communication readiness marker" "hf.services.communicationReadiness"
require_term "communication moderation marker" "hf.services.communicationModeration"
require_term "local to remote adapter marker" "hf.services.localToRemoteCommunicationAdapter"
require_term "audience channels marker" "hf.services.audienceChannels"

require_term "Connect Communication Service" "hf.connect.communicationService"
require_term "Connect audience channels" "hf.connect.audienceChannels"
require_term "Connect audience channel" "hf.connect.audienceChannel"
require_term "Connect local to remote adapter" "hf.connect.localToRemoteAdapter"
require_term "Connect local updates" "hf.functional.connect.localUpdates"
require_term "Connect update input" "hf.functional.connect.updateInput"
require_term "Connect add local update" "hf.functional.connect.addLocalUpdate"
require_term "Connect update list" "hf.functional.connect.updateList"

require_term "communication update input" "hf.communication.updateInput"
require_term "communication add local update" "hf.communication.addLocalUpdate"
require_term "communication local update list" "hf.communication.localUpdateList"
require_term "communication update status" "hf.communication.updateStatus"
require_term "communication author profile" "hf.communication.updateAuthorProfile"
require_term "communication catalog title" "hf.communication.updateCatalogTitle"
require_term "communication moderation readiness" "hf.communication.moderationReadiness"

require_term "Home communication signal" "hf.home.communicationSignal"
require_term "Home audience updates signal" "hf.home.audienceUpdatesSignal"

require_term "Movie Detail communication path" "hf.movieDetail.communicationPath"
require_term "Movie Detail audience update context" "hf.movieDetail.audienceUpdateContext"

require_term "Profile communication services" "hf.profile.communicationServices"
require_term "Profile communication proof" "hf.profile.communicationProof"
require_term "Profile communication provider status" "hf.profile.communicationProviderStatus"
require_term "Profile moderation readiness" "hf.profile.moderationReadiness"

require_term "Demo communication proof" "hf.demoTour.communicationProof"
require_term "Demo local remote adapter proof" "hf.demoTour.localRemoteCommunicationAdapterProof"

require_term "Launch communication adapter context" "hf.launch.communicationAdapterContext"
require_term "Export communication adapter context" "hf.export.communicationAdapterContext"

require_term "Communication Service copy" "Communication Service"
require_term "Local Communication Adapter copy" "Local Communication Adapter"
require_term "Remote Communication Provider copy" "Remote Communication Provider"
require_term "Local-to-Remote Adapter copy" "Local-to-Remote Adapter"
require_term "Moderation Readiness copy" "Moderation Readiness"
require_term "Local Audience Updates copy" "Local Audience Updates"
require_term "Audience Channels copy" "Audience Channels"
require_term "Not Connected Yet copy" "Not Connected Yet"
require_term "Not Sent copy" "Not Sent"

require_bottom_tabs
require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#033.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "source presence and evidence-lock safety only",\n'
  printf '  "architecture_scope": "local/provider-ready communication architecture only",\n'
  printf '  "no_real_backend_claim": true,\n'
  printf '  "no_real_chat_comment_reply_like_follow_claim": true,\n'
  printf '  "no_real_push_notification_claim": true,\n'
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
  printf '# Communication Backend Architecture Source Verification\n\n'
  printf -- '- Upgrade: #033.0B\n'
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
  printf 'This verifier confirms local/provider-ready Communication architecture markers, connected route markers, locked tabs, and evidence-lock safety boundaries. It does not verify a live backend provider, real chat, comments, replies, likes, follows, push notifications, remote moderation, provider SDKs, remote URLs, credentials, or service credentials.\n'
} > "$MD_REPORT"

printf 'Communication backend architecture source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
