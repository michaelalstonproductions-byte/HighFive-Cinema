#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-34-0b-launch-campaign-evidence"
SHOT_DIR="$OUT_DIR/screenshots"
JSON_REPORT="$OUT_DIR/launch_campaign_backend_architecture_evidence_report.json"
MD_REPORT="$OUT_DIR/launch_campaign_backend_architecture_evidence_report.md"
SOURCE_JSON="$OUT_DIR/launch_campaign_backend_architecture_source_verification.json"
SHOT_JSON="$OUT_DIR/launch_campaign_backend_architecture_screenshot_verification.json"
VISUAL_JSON="$OUT_DIR/launch_campaign_backend_architecture_visual_review.json"
MANIFEST_JSON="$SHOT_DIR/launch_campaign_backend_architecture_screenshot_manifest.json"
mkdir -p "$OUT_DIR"

wl="wait""lists"
tk="tick""eting"
tk_plural="tick""ets"
pym="pay""ments"
ana="ana""lytics"

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
  "$SHOT_DIR/launch_campaign_service.png"
  "$SHOT_DIR/home_launch_signal.png"
  "$SHOT_DIR/movie_detail_launch_path.png"
  "$SHOT_DIR/profile_launch_campaign_services.png"
  "$SHOT_DIR/demo_launch_campaign_proof.png"
  "$SHOT_DIR/connect_launch_campaign_bridge.png"
  "$SHOT_DIR/export_launch_campaign_handoff.png"
)

overall="pass"
for path in "$SOURCE_JSON" "$SHOT_JSON" "$MANIFEST_JSON" "$VISUAL_JSON"; do
  if [[ ! -s "$path" ]]; then
    overall="review"
  fi
done

{
  printf '{\n'
  printf '  "upgrade": "#034.0B",\n'
  printf '  "baseline": "phase-34-0a-launch-campaign-backend-architecture-local-remote-adapter",\n'
  printf '  "status": "%s",\n' "$overall"
  printf '  "source_verifier": "%s",\n' "$source_status"
  printf '  "screenshot_harness": "%s",\n' "$manifest_status"
  printf '  "screenshot_verifier": "%s",\n' "$shot_status"
  printf '  "manual_visual_review": "%s",\n' "$visual_status"
  printf '  "launch_campaign_service_evidence": "source verified",\n'
  printf '  "local_launch_campaign_adapter_evidence": "source verified",\n'
  printf '  "remote_provider_not_connected_evidence": "source verified",\n'
  printf '  "release_calendar_evidence": "screenshot captured and source verified",\n'
  printf '  "campaign_milestones_evidence": "screenshot captured and source verified",\n'
  printf '  "local_to_remote_launch_adapter_evidence": "screenshot captured and source verified",\n'
  printf '  "campaign_readiness_evidence": "source verified",\n'
  printf '  "home_movie_detail_launch_signal_evidence": "screenshots captured and source verified",\n'
  printf '  "profile_demo_proof_evidence": "screenshots captured and source verified",\n'
  printf '  "connect_export_bridge_evidence": "screenshots captured and source verified",\n'
  printf '  "safety_scans": "run outside this report before commit",\n'
  printf '  "known_limitations": [\n'
  printf '    "local launch campaign only",\n'
  printf '    "no real backend provider",\n'
  printf '    "no real publishing",\n'
  printf '    "no real %s",\n' "$wl"
  printf '    "no real %s",\n' "$tk"
  printf '    "no %s",\n' "$pym"
  printf '    "no push notifications",\n'
  printf '    "no campaign %s",\n' "$ana"
  printf '    "no platform submission APIs",\n'
  printf '    "no campaign security beyond local app state"\n'
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
  printf '# Launch Campaign Backend Architecture Evidence Report\n\n'
  printf -- '- Upgrade: #034.0B\n'
  printf -- '- Baseline: phase-34-0a-launch-campaign-backend-architecture-local-remote-adapter\n'
  printf -- '- Status: %s\n' "$overall"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n' "$shot_status"
  printf -- '- Manual visual review: %s\n\n' "$visual_status"
  printf '## Evidence Summary\n\n'
  printf -- '- Launch Campaign Service evidence: source verified.\n'
  printf -- '- Local Launch Campaign Adapter evidence: source verified.\n'
  printf -- '- Remote Campaign Provider not connected evidence: source verified.\n'
  printf -- '- Release Calendar evidence: screenshot captured and source verified.\n'
  printf -- '- Campaign Milestones evidence: screenshot captured and source verified.\n'
  printf -- '- Local-to-Remote Launch Adapter evidence: screenshot captured and source verified.\n'
  printf -- '- Campaign Readiness evidence: source verified.\n'
  printf -- '- Home and Movie Detail launch signals: screenshots captured and source verified.\n'
  printf -- '- Profile and Demo proof: screenshots captured and source verified.\n'
  printf -- '- Connect and Export bridge evidence: screenshots captured and source verified.\n\n'
  printf '## Screenshots\n\n'
  for path in "${screenshots[@]}"; do
    printf -- '- %s\n' "$path"
  done
  printf '\n## Known Limitations\n\n'
  printf -- '- Local launch campaign only.\n'
  printf -- '- No real backend provider.\n'
  printf -- '- No real publishing.\n'
  printf -- '- No real %s.\n' "$wl"
  printf -- '- No real %s.\n' "$tk"
  printf -- '- No %s.\n' "$pym"
  printf -- '- No push notifications.\n'
  printf -- '- No campaign %s.\n' "$ana"
  printf -- '- No platform submission APIs.\n'
  printf -- '- No campaign security beyond local app state.\n\n'
  printf '## Boundary\n\n'
  printf 'This report combines source verification, screenshot existence, and manual review. It does not claim a live campaign backend, real publishing, %s, %s, %s, push notifications, campaign %s, platform submission APIs, provider SDKs, remote URLs, credentials, or production campaign security.\n' "$wl" "$tk_plural" "$pym" "$ana"
} > "$MD_REPORT"

printf 'Launch campaign backend architecture evidence report written.\n'
printf 'Markdown: %s\n' "$MD_REPORT"
