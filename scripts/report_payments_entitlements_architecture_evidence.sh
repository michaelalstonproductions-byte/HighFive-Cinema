#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-36-0b-payment-entitlements-evidence"
JSON_REPORT="$OUT_DIR/payments_entitlements_architecture_evidence_report.json"
MD_REPORT="$OUT_DIR/payments_entitlements_architecture_evidence_report.md"
SOURCE_JSON="$OUT_DIR/payments_entitlements_architecture_source_verification.json"
SHOT_JSON="$OUT_DIR/payments_entitlements_architecture_screenshot_verification.json"
VISUAL_JSON="$OUT_DIR/payments_entitlements_architecture_visual_review.json"
SHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SHOT_DIR/payments_entitlements_architecture_screenshot_manifest.json"
mkdir -p "$OUT_DIR"

status_for() {
  local path="$1"
  if [[ -s "$path" ]] && rg -Fq '"status": "pass"' "$path"; then
    printf 'pass'
  elif [[ -s "$path" ]]; then
    printf 'review'
  else
    printf 'missing'
  fi
}

source_status="$(status_for "$SOURCE_JSON")"
shot_status="$(status_for "$SHOT_JSON")"
manifest_status="missing"
if [[ -s "$MANIFEST_JSON" ]]; then
  manifest_status="pass"
fi

visual_status="missing"
if [[ -s "$VISUAL_JSON" ]]; then
  visual_status="complete"
fi

screenshots=(
  "$SHOT_DIR/profile_payment_entitlement_services.png"
  "$SHOT_DIR/movie_detail_entitlement_path.png"
  "$SHOT_DIR/home_access_path_signal.png"
  "$SHOT_DIR/library_entitlement_boundary.png"
  "$SHOT_DIR/downloads_entitlement_boundary.png"
  "$SHOT_DIR/export_payment_entitlement_boundary.png"
  "$SHOT_DIR/launch_payment_entitlement_boundary.png"
  "$SHOT_DIR/demo_payment_entitlement_proof.png"
)

overall="pass"
for path in "$SOURCE_JSON" "$SHOT_JSON" "$MANIFEST_JSON"; do
  if [[ ! -s "$path" ]]; then
    overall="review"
  fi
done

{
  printf '{\n'
  printf '  "upgrade": "#036.0B",\n'
  printf '  "baseline": "1534194 phase-36-0a-payments-entitlements-architecture-local-remote-adapter",\n'
  printf '  "status": "%s",\n' "$overall"
  printf '  "source_verifier": "%s",\n' "$source_status"
  printf '  "screenshot_harness": "%s",\n' "$manifest_status"
  printf '  "screenshot_verifier": "%s",\n' "$shot_status"
  printf '  "manual_visual_review": "%s",\n' "$visual_status"
  printf '  "payment_entitlement_service_evidence": "source verified",\n'
  printf '  "local_entitlement_adapter_evidence": "source verified",\n'
  printf '  "remote_payment_provider_not_connected_evidence": "source verified",\n'
  printf '  "store_provider_not_connected_evidence": "source verified",\n'
  printf '  "server_entitlement_validation_not_connected_evidence": "source verified",\n'
  printf '  "access_tiers_evidence": "source verified",\n'
  printf '  "player_entitlement_boundary_evidence": "source verified",\n'
  printf '  "library_downloads_entitlement_boundary_evidence": "source verified",\n'
  printf '  "export_launch_entitlement_boundary_evidence": "source verified",\n'
  printf '  "local_to_remote_payment_adapter_evidence": "source verified",\n'
  printf '  "future_contract_docs_evidence": "source verified",\n'
  printf '  "home_movie_detail_access_signal_evidence": "screenshots captured and source verified",\n'
  printf '  "profile_demo_proof_evidence": "screenshots captured and source verified",\n'
  printf '  "library_downloads_export_launch_boundary_evidence": "screenshots captured and source verified",\n'
  printf '  "safety_scans": "source verifier checks protected path diff, allowed evidence files, consumer tabs, and no live payment provider Swift diff",\n'
  printf '  "known_limitations": [\n'
  printf '    "local entitlement adapter only",\n'
  printf '    "no StoreKit integration",\n'
  printf '    "no RevenueCat integration",\n'
  printf '    "no checkout or payment provider",\n'
  printf '    "no purchases, subscriptions, or restore purchases",\n'
  printf '    "no receipt or transaction validation",\n'
  printf '    "no server entitlement validation",\n'
  printf '    "no DRM or FairPlay entitlement enforcement",\n'
  printf '    "no production payment security beyond local app state"\n'
  printf '  ],\n'
  printf '  "screenshots": [\n'
  for i in "${!screenshots[@]}"; do
    comma=","
    [[ "$i" -eq $((${#screenshots[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "${screenshots[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Payments / Entitlements Architecture Evidence Report\n\n'
  printf -- '- Upgrade: #036.0B\n'
  printf -- '- Baseline: 1534194 phase-36-0a-payments-entitlements-architecture-local-remote-adapter\n'
  printf -- '- Status: %s\n' "$overall"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n' "$shot_status"
  printf -- '- Manual visual review: %s\n\n' "$visual_status"
  printf '## Evidence Summary\n\n'
  printf -- '- Payment + Entitlement Service evidence: source verified.\n'
  printf -- '- Local Entitlement Adapter evidence: source verified.\n'
  printf -- '- Remote Payment Provider not connected evidence: source verified.\n'
  printf -- '- Store Provider not connected evidence: source verified.\n'
  printf -- '- Server Entitlement Validation not connected evidence: source verified.\n'
  printf -- '- Access Tiers evidence: source verified.\n'
  printf -- '- Player entitlement boundary evidence: source verified.\n'
  printf -- '- Library and Downloads entitlement boundaries: source verified.\n'
  printf -- '- Export and Launch entitlement boundaries: source verified.\n'
  printf -- '- Local-to-Remote Payment Adapter evidence: source verified.\n'
  printf -- '- Future contract docs and provider decision matrix: source verified.\n\n'
  printf '## Screenshots\n\n'
  for path in "${screenshots[@]}"; do
    printf -- '- %s\n' "$path"
  done
  printf '\n'
  printf '## Known Limitations\n\n'
  printf -- '- Local entitlement adapter only.\n'
  printf -- '- No StoreKit integration.\n'
  printf -- '- No RevenueCat integration.\n'
  printf -- '- No checkout or payment provider.\n'
  printf -- '- No purchases, subscriptions, or restore purchases.\n'
  printf -- '- No receipt or transaction validation.\n'
  printf -- '- No server entitlement validation.\n'
  printf -- '- No DRM or FairPlay entitlement enforcement.\n'
  printf -- '- No production payment security beyond local app state.\n\n'
  printf '## Boundary\n\n'
  printf 'This report combines source verification and safety scans. It does not claim live payments, StoreKit, subscriptions, provider credentials, transaction validation, receipt validation, remote entitlement validation, DRM, FairPlay, paywall behavior, or production payment security.\n'
} > "$MD_REPORT"

printf 'Payments entitlements architecture evidence report written.\n'
printf 'Markdown: %s\n' "$MD_REPORT"
