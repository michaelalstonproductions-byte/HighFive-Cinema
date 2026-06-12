#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-36-0b-payment-entitlements-evidence"
JSON_REPORT="$OUT_DIR/payments_entitlements_architecture_source_verification.json"
MD_REPORT="$OUT_DIR/payments_entitlements_architecture_source_verification.md"
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
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Payments|Entitlements|Subscribe|Subscription|Purchase|Store|Paywall|Provider|Developer|QA|Demo|Rooms|Watch|Create|Connect|Launch|Export)"' "$tab_file" || true)
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
  allowed_re='^(scripts/verify_payments_entitlements_architecture_sources\.sh|scripts/qa_payments_entitlements_architecture_screenshots\.sh|scripts/verify_payments_entitlements_architecture_screenshots\.sh|scripts/report_payments_entitlements_architecture_evidence\.sh)$'
  unexpected=$(printf '%s\n' "$changed" | rg -v "$allowed_re" || true)
  if [[ -z "$unexpected" ]]; then
    pass "only payments entitlements evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  local b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24 b25 b26 h1 h2
  b1="Fire""base"
  b2="Supa""base"
  b3="URL""Session"
  b4="Store""Kit"
  b5="SK""Payment"
  b6="Product""View"
  b7="Transaction"
  b8="App""Store"
  b9="purchase"
  b10="subscription"
  b11="pay""wall"
  b12="Revenue""Cat"
  b13="Stripe"
  b14="tok""en"
  b15="sec""ret"
  b16="api[_-]?""key"
  b17="client_""sec""ret"
  b18="access_""tok""en"
  b19="refresh_""tok""en"
  b20="pass""word"
  b21="Key""chain"
  b22="OAuth"
  b23="DRM"
  b24="Fair""Play"
  b25="backend"
  b26="server validation"
  h1="ht""tp://"
  h2="ht""tps://"
  local blocked_pattern
  blocked_pattern="(${b1}|${b2}|${b3}|${h1}|${h2}|${b4}|${b5}|${b6}|${b7}|${b8}|${b9}|${b10}|${b11}|${b12}|${b13}|${b14}|${b15}|${b16}|${b17}|${b18}|${b19}|${b20}|${b21}|${b22}|${b23}|${b24}|${b25}|${b26}|payment provider|entitlement provider|restore purchases|receipt validation|verifyReceipt|signed transaction|in-app purchase|merchant|checkout)"
  local blocked_diff
  blocked_diff=$(git diff -U0 -- '*.swift' | rg -n "^\\+.*${blocked_pattern}" || true)
  if [[ -z "$blocked_diff" ]]; then
    pass "no live payment or entitlement provider systems added in Swift diff"
  else
    fail "blocked payment entitlement system diff found"
  fi
}

require_term "Payment Entitlement marker" "hf.services.paymentEntitlement"
require_term "Local Entitlement Adapter marker" "hf.services.localEntitlementAdapter"
require_term "Remote Payment Provider marker" "hf.services.remotePaymentProviderReady"
require_term "Store Provider marker" "hf.services.storeProviderReady"
require_term "Entitlement Readiness marker" "hf.services.entitlementReadiness"
require_term "Access Tiers marker" "hf.services.accessTiers"
require_term "Local-to-Remote Payment Adapter marker" "hf.services.localToRemotePaymentAdapter"
require_term "Player Entitlement Boundary marker" "hf.services.playerEntitlementBoundary"
require_term "Library Entitlement Boundary marker" "hf.services.libraryEntitlementBoundary"
require_term "Download Entitlement Boundary marker" "hf.services.downloadEntitlementBoundary"
require_term "Export Entitlement Boundary marker" "hf.services.exportEntitlementBoundary"
require_term "Launch Entitlement Boundary marker" "hf.services.launchEntitlementBoundary"

require_term "Payment provider enum" "enum HFPaymentProviderStatus"
require_term "Entitlement status enum" "enum HFEntitlementStatus"
require_term "Access tier record" "struct HFAccessTierRecord"
require_term "Entitlement record" "struct HFEntitlementRecord"
require_term "Payment readiness row" "struct HFPaymentReadinessRow"
require_term "Payment service mode" "paymentEntitlementServiceMode"
require_term "Local entitlement adapter status" "localEntitlementAdapterStatus"
require_term "Remote provider disconnected state" ".remoteProviderNotConnected"
require_term "Store provider disconnected state" "Store Provider Not Connected Yet"
require_term "Access tier rows" "accessTierRows"
require_term "Entitlement records" "entitlementRecords"
require_term "Payment readiness rows" "paymentReadinessRows"
require_term "Local-to-remote payment rows" "localToRemotePaymentAdapterRows"
require_term "Player entitlement rows" "playerEntitlementBoundaryRows"
require_term "Library entitlement rows" "libraryEntitlementRows"
require_term "Download entitlement rows" "downloadEntitlementRows"
require_term "Export entitlement rows" "exportEntitlementRows"
require_term "Launch entitlement rows" "launchEntitlementRows"
require_term "Payment proof rows" "paymentProofRows"
require_term "Entitlement status resolver" "func entitlementStatus(for movie: Movie)"
require_term "Entitlement copy resolver" "func entitlementCopy(for movie: Movie)"

require_term "Profile payment entitlement services" "hf.profile.paymentEntitlementServices"
require_term "Profile payment proof" "hf.profile.paymentEntitlementProof"
require_term "Profile payment provider status" "hf.profile.paymentProviderStatus"
require_term "Profile store provider status" "hf.profile.storeProviderStatus"
require_term "Profile entitlement readiness" "hf.profile.entitlementReadiness"
require_term "Profile local-to-remote adapter" "hf.payment.localToRemoteAdapter"
require_term "Profile access tier record" "hf.payment.accessTierRecord"
require_term "Profile entitlement record" "hf.payment.entitlementRecord"

require_term "Movie Detail entitlement path" "hf.movieDetail.entitlementPath"
require_term "Movie Detail access readiness" "hf.movieDetail.accessReadiness"
require_term "Movie Detail player boundary" "hf.movieDetail.playerEntitlementBoundary"
require_term "Home access path signal" "hf.home.accessPathSignal"
require_term "Home entitlement signal" "hf.home.entitlementSignal"
require_term "Player entitlement boundary" "hf.player.entitlementBoundary"
require_term "Player payment provider status" "hf.player.paymentProviderStatus"
require_term "Player access status" "hf.player.accessStatus"

require_term "Library entitlement boundary" "hf.library.entitlementBoundary"
require_term "Downloads entitlement boundary" "hf.downloads.entitlementBoundary"
require_term "Launch payment entitlement boundary" "hf.launch.paymentEntitlementBoundary"
require_term "Export payment entitlement boundary" "hf.export.paymentEntitlementBoundary"
require_term "Demo payment proof" "hf.demoTour.paymentEntitlementProof"
require_term "Demo local remote payment adapter proof" "hf.demoTour.localRemotePaymentAdapterProof"

require_term "Payment service copy" "Payment + Entitlement Services"
require_term "Payment proof copy" "Payment + Entitlement Service Proof"
require_term "Local entitlement adapter copy" "Local Entitlement Adapter"
require_term "Local-to-Remote Payment Adapter copy" "Local-to-Remote Payment Adapter"
require_term "Access Tiers copy" "Access Tiers"
require_term "Server Entitlement Validation copy" "Server Entitlement Validation"
require_term "No Purchase Active copy" "No Purchase Active"
require_term "Local Preview Only copy" "Local Preview Only"
require_term "Not Connected Yet copy" "Not Connected Yet"

require_term "Roadmap baseline phase" "#037.0A — Payments / Entitlements" "docs/production_services"
require_term "Payment contract plan" "PaymentEntitlementService" "docs/production_services"
require_term "Subscription entitlement contract" "SubscriptionEntitlement" "docs/production_services"
require_term "Payment details provider boundary" "payment details stay with payment provider" "docs/production_services"
require_term "Provider decision StoreKit" "StoreKit direct" "docs/production_services"
require_term "Provider decision RevenueCat" "RevenueCat" "docs/production_services"
require_term "Provider decision hybrid entitlements" "Hybrid StoreKit + backend entitlements" "docs/production_services"
require_term "Server-side validation requirement" "Payment entitlement state must be validated server-side." "docs/production_services"

require_bottom_tabs
require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#036.0B",\n'
  printf '  "baseline": "1534194 phase-36-0a-payments-entitlements-architecture-local-remote-adapter",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "evidence_boundary": "local payment entitlement adapter source presence, provider-disconnected state, docs contract presence, and evidence-lock safety only",\n'
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
  printf '# Payments / Entitlements Architecture Source Verification\n\n'
  printf -- '- Upgrade: #036.0B\n'
  printf -- '- Baseline: 1534194 phase-36-0a-payments-entitlements-architecture-local-remote-adapter\n'
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
  printf 'This verifier confirms local payment and entitlement adapter markers, access tier and entitlement boundary source, provider-disconnected copy, future contract documentation, locked consumer tabs, and safety boundaries. It does not verify StoreKit, RevenueCat, checkout, purchases, subscriptions, restore purchases, receipt validation, server entitlement validation, DRM, FairPlay, remote URLs, credentials, or production payment security.\n'
} > "$MD_REPORT"

printf 'Payments entitlements architecture source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
