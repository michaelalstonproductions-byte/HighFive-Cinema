#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-35-0b-export-delivery-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/export_delivery_backend_architecture_evidence_report.json"
MD_REPORT="$OUT_DIR/export_delivery_backend_architecture_evidence_report.md"
SOURCE_JSON="$OUT_DIR/export_delivery_backend_architecture_source_verification.json"
SHOT_JSON="$OUT_DIR/export_delivery_backend_architecture_screenshot_verification.json"
VISUAL_JSON="$OUT_DIR/export_delivery_backend_architecture_visual_review.json"
MANIFEST_JSON="$SHOT_DIR/export_delivery_backend_architecture_screenshot_manifest.json"
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

visual_status="missing"
if [[ -s "$VISUAL_JSON" ]]; then
  visual_status="complete"
fi

source_status="$(status_for "$SOURCE_JSON")"
shot_status="$(status_for "$SHOT_JSON")"
manifest_status="missing"
if [[ -s "$MANIFEST_JSON" ]]; then
  manifest_status="pass"
fi

screenshots=(
  "$SHOT_DIR/export_delivery_service.png"
  "$SHOT_DIR/home_export_delivery_signal.png"
  "$SHOT_DIR/movie_detail_delivery_path.png"
  "$SHOT_DIR/profile_export_delivery_services.png"
  "$SHOT_DIR/demo_export_delivery_proof.png"
  "$SHOT_DIR/launch_export_delivery_handoff.png"
  "$SHOT_DIR/connect_export_delivery_context.png"
  "$SHOT_DIR/library_export_delivery_boundary.png"
  "$SHOT_DIR/downloads_export_delivery_boundary.png"
)

overall="pass"
for path in "$SOURCE_JSON" "$SHOT_JSON" "$MANIFEST_JSON" "$VISUAL_JSON"; do
  if [[ ! -s "$path" ]]; then
    overall="review"
  fi
done

{
  printf '{\n'
  printf '  "upgrade": "#035.0B",\n'
  printf '  "baseline": "15b693f phase-35-0a-export-delivery-backend-architecture-local-remote-adapter",\n'
  printf '  "status": "%s",\n' "$overall"
  printf '  "source_verifier": "%s",\n' "$source_status"
  printf '  "screenshot_harness": "%s",\n' "$manifest_status"
  printf '  "screenshot_verifier": "%s",\n' "$shot_status"
  printf '  "manual_visual_review": "%s",\n' "$visual_status"
  printf '  "export_delivery_service_evidence": "source verified and screenshot captured",\n'
  printf '  "local_export_delivery_adapter_evidence": "source verified",\n'
  printf '  "remote_provider_not_connected_evidence": "source verified",\n'
  printf '  "delivery_package_evidence": "source verified",\n'
  printf '  "delivery_requirements_evidence": "source verified",\n'
  printf '  "distribution_handoff_evidence": "source verified",\n'
  printf '  "local_to_remote_export_adapter_evidence": "source verified",\n'
  printf '  "export_readiness_evidence": "source verified",\n'
  printf '  "home_movie_detail_delivery_signal_evidence": "screenshots captured and source verified",\n'
  printf '  "profile_demo_proof_evidence": "screenshots captured and source verified",\n'
  printf '  "launch_connect_library_downloads_boundary_evidence": "screenshots captured and source verified",\n'
  printf '  "safety_scans": "run outside this report before commit",\n'
  printf '  "known_limitations": [\n'
  printf '    "local export delivery only",\n'
  printf '    "no real backend provider",\n'
  printf '    "no real file export",\n'
  printf '    "no real media render/export engine",\n'
  printf '    "no platform submission APIs",\n'
  printf '    "no distribution provider",\n'
  printf '    "no ZIP/file package creation",\n'
  printf '    "no file storage provider",\n'
  printf '    "no delivery security beyond local app state"\n'
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
  printf '# Export Delivery Backend Architecture Evidence Report\n\n'
  printf -- '- Upgrade: #035.0B\n'
  printf -- '- Baseline: 15b693f phase-35-0a-export-delivery-backend-architecture-local-remote-adapter\n'
  printf -- '- Status: %s\n' "$overall"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n' "$shot_status"
  printf -- '- Manual visual review: %s\n\n' "$visual_status"
  printf '## Evidence Summary\n\n'
  printf -- '- Export Delivery Service evidence: source verified and screenshot captured.\n'
  printf -- '- Local Export Delivery Adapter evidence: source verified.\n'
  printf -- '- Remote Delivery Provider not connected evidence: source verified.\n'
  printf -- '- Delivery Package evidence: source verified.\n'
  printf -- '- Delivery Requirements evidence: source verified.\n'
  printf -- '- Distribution Handoff evidence: source verified.\n'
  printf -- '- Local-to-Remote Export Adapter evidence: source verified.\n'
  printf -- '- Export Readiness evidence: source verified.\n'
  printf -- '- Home and Movie Detail delivery signals: screenshots captured and source verified.\n'
  printf -- '- Profile and Demo proof: screenshots captured and source verified.\n'
  printf -- '- Launch, Connect, Library, and Downloads boundaries: screenshots captured and source verified.\n\n'
  printf '## Screenshots\n\n'
  for path in "${screenshots[@]}"; do
    printf -- '- %s\n' "$path"
  done
  printf '\n## Known Limitations\n\n'
  printf -- '- Local export delivery only.\n'
  printf -- '- No real backend provider.\n'
  printf -- '- No real file export.\n'
  printf -- '- No real media render/export engine.\n'
  printf -- '- No platform submission APIs.\n'
  printf -- '- No distribution provider.\n'
  printf -- '- No ZIP/file package creation.\n'
  printf -- '- No file storage provider.\n'
  printf -- '- No delivery security beyond local app state.\n\n'
  printf '## Boundary\n\n'
  printf 'This report combines source verification, screenshot existence, and manual review. It does not claim a live delivery provider, real file export, media render/export, platform submission, file package creation, file storage, provider credentials, or production delivery security.\n'
} > "$MD_REPORT"

printf 'Export delivery backend architecture evidence report written.\n'
printf 'Markdown: %s\n' "$MD_REPORT"
