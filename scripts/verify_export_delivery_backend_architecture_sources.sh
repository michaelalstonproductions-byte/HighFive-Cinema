#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-35-0b-export-delivery-evidence"
JSON_REPORT="$OUT_DIR/export_delivery_backend_architecture_source_verification.json"
MD_REPORT="$OUT_DIR/export_delivery_backend_architecture_source_verification.md"
mkdir -p "$OUT_DIR"

passes=()
failures=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }
json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

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
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Export|Delivery|Files|Render|Platform|Provider|Developer|QA|Demo|Rooms|Watch|Create|Connect|Launch)"' "$tab_file" || true)
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
  allowed_re='^(scripts/verify_export_delivery_backend_architecture_sources\.sh|scripts/qa_export_delivery_backend_architecture_screenshots\.sh|scripts/verify_export_delivery_backend_architecture_screenshots\.sh|scripts/report_export_delivery_backend_architecture_evidence\.sh)$'
  unexpected=$(printf '%s\n' "$changed" | rg -v "$allowed_re" || true)
  if [[ -z "$unexpected" ]]; then
    pass "only export delivery evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  local b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24 b25 b26 b27 b28 b29 h1 h2
  b1="Fire""base"
  b2="Supa""base"
  b3="Web""Socket"
  b4="URL""Session"
  b5="File""Manager"
  b6="file""Exporter"
  b7="file""Importer"
  b8="AVAsset""Export""Session"
  b9="tok""en"
  b10="sec""ret"
  b11="api[_-]?""key"
  b12="client_""sec""ret"
  b13="access_""tok""en"
  b14="refresh_""tok""en"
  b15="pass""word"
  b16="Store""Kit"
  b17="SK""Payment"
  b18="ana""lytics SDK"
  b19="tracking SDK"
  b20="render engine"
  b21="video export"
  b22="submit to ""platform"
  b23="send to ""distributor"
  b24="zi""p"
  b25="pay""ment"
  b26="AVAssetDownload""URL""Session"
  b27="downloadTask"
  b28="background transfer"
  b29="Authentication""Services"
  h1="ht""tp://"
  h2="ht""tps://"
  local blocked_pattern
  blocked_pattern="(${b1}|${b2}|StreamChat|Sendbird|${b3}|${b4}|${h1}|${h2}|${b29}|${b16}|${b17}|Keychain|OAuth|${b15}|${b9}|${b10}|${b11}|${b12}|${b13}|${b14}|purchase|subscription|entitlement|DRM|FairPlay|backend|auth server|account login|upload|push notification|UNUserNotificationCenter|UserNotifications|${b18}|${b19}|${b20}|${b21}|${b8}|${b6}|${b7}|DocumentGroup|FileDocument|writeTo|${b24}|${b22}|${b23}|ticket|waitlist|${b25}|${b5}|${b26}|${b27}|${b28}|publish campaign|sell ticket|open waitlist|notify audience|track analytics)"
  local blocked_diff
  blocked_diff=$(git diff -U0 -- '*.swift' | rg -n "^\\+.*${blocked_pattern}" || true)
  if [[ -z "$blocked_diff" ]]; then
    pass "no blocked export delivery systems added in Swift diff"
  else
    fail "blocked export delivery system diff found"
  fi
}

require_term "Export Delivery marker" "hf.services.exportDelivery"
require_term "Local Export Delivery Adapter marker" "hf.services.localExportDeliveryAdapter"
require_term "Remote Delivery Provider Ready marker" "hf.services.remoteDeliveryProviderReady"
require_term "Export Delivery Readiness marker" "hf.services.exportDeliveryReadiness"
require_term "Delivery Package marker" "hf.services.deliveryPackage"
require_term "Delivery Requirements marker" "hf.services.deliveryRequirements"
require_term "Distribution Handoff marker" "hf.services.distributionHandoff"
require_term "Local-to-Remote Export Adapter marker" "hf.services.localToRemoteExportAdapter"
require_term "Export Launch Handoff marker" "hf.services.exportLaunchHandoff"
require_term "Export Communication Package marker" "hf.services.exportCommunicationPackage"

require_term "Export Delivery Service section" "hf.export.deliveryService"
require_term "Delivery Package section" "hf.export.deliveryPackage"
require_term "Delivery Package status" "hf.export.deliveryPackageStatus"
require_term "Delivery Package profile" "hf.export.deliveryPackageProfile"
require_term "Delivery Package catalog title" "hf.export.deliveryPackageCatalogTitle"
require_term "Delivery Requirements section" "hf.export.deliveryRequirements"
require_term "Delivery Requirement rows" "hf.export.deliveryRequirement"
require_term "Distribution Handoff section" "hf.export.distributionHandoff"
require_term "Distribution Handoff item" "hf.export.distributionHandoffItem"
require_term "Local-to-Remote Export Adapter section" "hf.export.localToRemoteAdapter"
require_term "Generate Delivery Summary" "hf.export.generateDeliverySummary"
require_term "Delivery Summary Text" "hf.export.deliverySummaryText"
require_term "Delivery Summary Status" "hf.export.deliverySummaryStatus"
require_term "Delivery Summary Local Only" "hf.export.deliverySummaryLocalOnly"
require_term "Delivery Not Submitted" "hf.export.deliveryNotSubmitted"
require_term "Export Readiness" "hf.export.deliveryReadiness"

require_term "Export functional delivery summary" "hf.functional.export.deliverySummary"
require_term "Export functional generate summary" "hf.functional.export.generateSummary"
require_term "Export functional summary text" "hf.functional.export.summaryText"
require_term "Export functional connected state" "hf.functional.export.connectedState"
require_term "Export account profile state" "hf.account.export.profileState"
require_term "Export catalog title context" "hf.catalog.export.titleContext"
require_term "Export communication adapter context" "hf.export.communicationAdapterContext"
require_term "Export launch campaign handoff" "hf.export.launchCampaignHandoff"

require_term "Home export delivery signal" "hf.home.exportDeliverySignal"
require_term "Home delivery path signal" "hf.home.deliveryPathSignal"
require_term "Movie Detail delivery path" "hf.movieDetail.deliveryPath"
require_term "Movie Detail delivery package context" "hf.movieDetail.deliveryPackageContext"
require_term "Profile export delivery services" "hf.profile.exportDeliveryServices"
require_term "Profile export delivery proof" "hf.profile.exportDeliveryProof"
require_term "Profile export delivery provider status" "hf.profile.exportDeliveryProviderStatus"
require_term "Profile export delivery readiness" "hf.profile.exportDeliveryReadiness"
require_term "Demo export delivery proof" "hf.demoTour.exportDeliveryProof"
require_term "Demo local remote export adapter proof" "hf.demoTour.localRemoteExportAdapterProof"
require_term "Launch export delivery handoff" "hf.launch.exportDeliveryHandoff"
require_term "Connect export delivery package context" "hf.connect.exportDeliveryPackageContext"
require_term "Library export delivery boundary" "hf.library.exportDeliveryBoundary"
require_term "Downloads export delivery boundary" "hf.downloads.exportDeliveryBoundary"

require_term "Export Delivery Service copy" "Export Delivery Service"
require_term "Local Export Delivery Adapter copy" "Local Export Delivery Adapter"
require_term "Remote Delivery Provider copy" "Remote Delivery Provider"
require_term "Delivery Package copy" "Delivery Package"
require_term "Delivery Requirements copy" "Delivery Requirements"
require_term "Distribution Handoff copy" "Distribution Handoff"
require_term "Local-to-Remote Export Adapter copy" "Local-to-Remote Export Adapter"
require_term "Export Readiness copy" "Export Readiness"
require_term "Not Submitted copy" "Not Submitted"
require_term "Not Connected Yet copy" "Not Connected Yet"

require_bottom_tabs
require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#035.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "source presence and evidence-lock safety only",\n'
  printf '  "architecture_scope": "local/provider-ready export delivery architecture only",\n'
  printf '  "no_real_export_backend_claim": true,\n'
  printf '  "no_real_file_export_claim": true,\n'
  printf '  "no_real_render_engine_claim": true,\n'
  printf '  "no_platform_submission_claim": true,\n'
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
  printf '# Export Delivery Backend Architecture Source Verification\n\n'
  printf -- '- Upgrade: #035.0B\n'
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
  printf 'This verifier confirms local/provider-ready Export Delivery architecture markers, connected route markers, locked tabs, and evidence-lock safety boundaries. It does not verify a live delivery provider, real file export, media render/export, platform submission, file package creation, file storage, provider credentials, or production delivery security.\n'
} > "$MD_REPORT"

printf 'Export delivery backend architecture source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
