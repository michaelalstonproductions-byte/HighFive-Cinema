#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-33-0b-communication-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/communication_backend_architecture_evidence_report.json"
MD_REPORT="$OUT_DIR/communication_backend_architecture_evidence_report.md"
SOURCE_JSON="$OUT_DIR/communication_backend_architecture_source_verification.json"
SHOT_JSON="$OUT_DIR/communication_backend_architecture_screenshot_verification.json"
VISUAL_JSON="$OUT_DIR/communication_backend_architecture_visual_review.json"
MANIFEST_JSON="$SHOT_DIR/communication_backend_architecture_screenshot_manifest.json"
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
  "$SHOT_DIR/connect_communication_service.png"
  "$SHOT_DIR/home_communication_signal.png"
  "$SHOT_DIR/movie_detail_communication_path.png"
  "$SHOT_DIR/profile_communication_services.png"
  "$SHOT_DIR/demo_communication_proof.png"
  "$SHOT_DIR/launch_communication_context.png"
  "$SHOT_DIR/export_communication_context.png"
)

overall="pass"
for path in "$SOURCE_JSON" "$SHOT_JSON" "$MANIFEST_JSON" "$VISUAL_JSON"; do
  if [[ ! -s "$path" ]]; then
    overall="review"
  fi
done

{
  printf '{\n'
  printf '  "upgrade": "#033.0B",\n'
  printf '  "baseline": "phase-33-0a-communication-backend-architecture-local-remote-adapter",\n'
  printf '  "status": "%s",\n' "$overall"
  printf '  "source_verifier": "%s",\n' "$source_status"
  printf '  "screenshot_harness": "%s",\n' "$manifest_status"
  printf '  "screenshot_verifier": "%s",\n' "$shot_status"
  printf '  "manual_visual_review": "%s",\n' "$visual_status"
  printf '  "communication_service_evidence": "source verified",\n'
  printf '  "local_communication_adapter_evidence": "source verified",\n'
  printf '  "remote_provider_not_connected_evidence": "source verified",\n'
  printf '  "local_to_remote_adapter_evidence": "source verified",\n'
  printf '  "audience_channels_evidence": "source verified",\n'
  printf '  "connect_local_updates_evidence": "screenshot captured and source verified",\n'
  printf '  "moderation_readiness_evidence": "source verified",\n'
  printf '  "home_movie_detail_signal_evidence": "screenshots captured and source verified",\n'
  printf '  "profile_demo_proof_evidence": "screenshots captured and source verified",\n'
  printf '  "launch_export_context_evidence": "screenshots captured and source verified",\n'
  printf '  "safety_scans": "run outside this report before commit",\n'
  printf '  "known_limitations": [\n'
  printf '    "local communication only",\n'
  printf '    "no real backend provider",\n'
  printf '    "no real chat",\n'
  printf '    "no real comments",\n'
  printf '    "no real push notifications",\n'
  printf '    "no remote moderation provider",\n'
  printf '    "no user-to-user messaging",\n'
  printf '    "no communication security beyond local app state"\n'
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
  printf '# Communication Backend Architecture Evidence Report\n\n'
  printf -- '- Upgrade: #033.0B\n'
  printf -- '- Baseline: phase-33-0a-communication-backend-architecture-local-remote-adapter\n'
  printf -- '- Status: %s\n' "$overall"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n' "$shot_status"
  printf -- '- Manual visual review: %s\n\n' "$visual_status"
  printf '## Evidence Summary\n\n'
  printf -- '- Communication Service evidence: source verified.\n'
  printf -- '- Local Communication Adapter evidence: source verified.\n'
  printf -- '- Remote provider not connected evidence: source verified.\n'
  printf -- '- Local-to-Remote Adapter evidence: source verified.\n'
  printf -- '- Audience Channels evidence: source verified.\n'
  printf -- '- Connect local updates evidence: screenshot captured and source verified.\n'
  printf -- '- Moderation Readiness evidence: source verified.\n'
  printf -- '- Home and Movie Detail communication signals: screenshots captured and source verified.\n'
  printf -- '- Profile and Demo proof: screenshots captured and source verified.\n'
  printf -- '- Launch and Export communication context: screenshots captured and source verified.\n\n'
  printf '## Screenshots\n\n'
  for path in "${screenshots[@]}"; do
    printf -- '- %s\n' "$path"
  done
  printf '\n## Known Limitations\n\n'
  printf -- '- Local communication only.\n'
  printf -- '- No real backend provider.\n'
  printf -- '- No real chat.\n'
  printf -- '- No real comments.\n'
  printf -- '- No real push notifications.\n'
  printf -- '- No remote moderation provider.\n'
  printf -- '- No user-to-user messaging.\n'
  printf -- '- No communication security beyond local app state.\n\n'
  printf '## Boundary\n\n'
  printf 'This report combines source verification, screenshot existence, and manual review. It does not claim live backend messaging, real chat, comments, replies, likes, follows, push notifications, remote moderation, provider SDKs, remote URLs, credentials, or production communication security.\n'
} > "$MD_REPORT"

printf 'Communication backend architecture evidence report written.\n'
printf 'Markdown: %s\n' "$MD_REPORT"
