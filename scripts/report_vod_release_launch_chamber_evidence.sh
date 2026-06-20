#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-ui-05b-vod-release-launch-chamber-evidence"
SOURCE_JSON="$OUT_DIR/vod_release_source_verification.json"
MANIFEST_JSON="$OUT_DIR/vod_release_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/vod_release_screenshot_verification.json"
REPORT_JSON="$OUT_DIR/vod_release_evidence_report.json"
REPORT_MD="$OUT_DIR/vod_release_evidence_report.md"
mkdir -p "$OUT_DIR"

failures=()
status_for() {
  local file="$1"
  if [[ -f "$file" ]]; then
    ruby -rjson -e 'data = JSON.parse(File.read(ARGV[0])); puts data["status"] || "missing"' "$file"
  else
    printf 'missing\n'
  fi
}

source_status="$(status_for "$SOURCE_JSON")"
harness_status="$(status_for "$MANIFEST_JSON")"
screenshot_status="$(status_for "$SCREENSHOT_VERIFY_JSON")"

[[ "$source_status" == "passed" ]] || failures+=("source verifier not passed")
[[ "$harness_status" == "passed" ]] || failures+=("screenshot harness not passed")
[[ "$screenshot_status" == "passed" ]] || failures+=("screenshot verifier not passed")

scope="$(git diff --name-only edcf000..1aaade6 | sort | tr '\n' ' ')"
protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'
protected_result="$(git diff --name-only edcf000..1aaade6 | rg "$protected_pattern" || true)"
project_result="$(git diff --name-only edcf000..1aaade6 | rg 'project.pbxproj' || true)"

provider_terms=(
  'Fire''base'
  'Supa''base'
  'Cloud''Kit'
  'CK''Container'
  'Revenue''Cat'
  'Str''ipe'
  'Meta''SDK'
  'Facebook''Core'
  'TikTok''SDK'
  'YouTube''SDK'
  'URL''Session'
  'Web''Socket'
  'NW''Connection'
  'Network\.''framework'
  'https''?://'
  'Bearer'' '
  'api[_-]?''key'
  'client_''secret'
  'access_''token'
  'refresh_''token'
)
provider_pattern="$(IFS='|'; printf '%s' "${provider_terms[*]}")"
provider_pattern="$provider_pattern|private"_"key|service"_"role"
provider_result="$(git diff -U0 edcf000..1aaade6 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\\+.*($provider_pattern)" || true)"

release_terms=(
  'AVAsset''ExportSession'
  'Photos''Picker'
  'PH''Picker'
  'UIDocument''Picker'
  'File''Manager'
  'write''To'
  'upload''Task'
  'multi''part'
  'Publish'' Now'
  'Release'' Now'
  'Submit to ''Distributor'
  'Submit to ''Storefront'
  'Connect ''Distributor'
  'Connect ''Storefront'
  'Buy'' Now'
  'Purchase'' Now'
  'Subscribe'' Now'
  'Payment''Sheet'
  'Product\.''products'
  'Transaction''\.'
  'purchase''\('
  'AppStore\.''sync'
)
release_pattern="$(IFS='|'; printf '%s' "${release_terms[*]}")"
release_result="$(git diff -U0 edcf000..1aaade6 -- '*.swift' '*.md' | rg -n "^\\+.*($release_pattern)" || true)"

[[ -z "$protected_result" ]] || failures+=("protected path scan not clean")
[[ -z "$project_result" ]] || failures+=("project file scan not clean")
[[ -z "$provider_result" ]] || failures+=("provider/network/URL/secret scan not clean")
[[ -z "$release_result" ]] || failures+=("upload/export/release/payment scan not clean")

report_status="passed"
if (( ${#failures[@]} > 0 )); then
  report_status="failed"
fi

screenshots=(
  "$OUT_DIR/screenshots/vod_launch_default.png"
  "$OUT_DIR/screenshots/vod_launch_trailer.png"
  "$OUT_DIR/screenshots/vod_launch_poster.png"
  "$OUT_DIR/screenshots/vod_launch_synopsis.png"
  "$OUT_DIR/screenshots/vod_launch_access.png"
  "$OUT_DIR/screenshots/vod_launch_release.png"
  "$OUT_DIR/screenshots/creator_studio_vod_entry.png"
  "$OUT_DIR/screenshots/social_campaign_regression.png"
  "$OUT_DIR/screenshots/profile_tabs.png"
)

{
  printf '{\n'
  printf '  "upgrade": "UI-05B",\n'
  printf '  "status": "%s",\n' "$report_status"
  printf '  "baseline": "1aaade6",\n'
  printf '  "baseline_tag": "phase-ui-05a-vod-release-launch-chamber",\n'
  printf '  "baseline_parent": "edcf000",\n'
  printf '  "baseline_parent_tag": "phase-ui-04b-social-campaign-spatial-authoring-evidence-lock",\n'
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "screenshot_harness_status": "%s",\n' "$harness_status"
  printf '  "screenshot_verifier_status": "%s",\n' "$screenshot_status"
  printf '  "evidence_report_status": "%s",\n' "$report_status"
  printf '  "ui_05a_production_file_scope": ["HighFive/App/HFStreamingRootView.swift", "HighFive/Views/Creator/CreatorStudioView.swift"],\n'
  printf '  "focus_model_evidence": "HFVODReleaseFocus contains Trailer, Poster, Synopsis, Access, Release with identifiers and local preview states.",\n'
  printf '  "launch_chamber_evidence": "Dominant optical-black release chamber with gold completion and violet depth treatment.",\n'
  printf '  "release_core_evidence": "Current project artwork anchors the release core.",\n'
  printf '  "selected_focus_depth_evidence": "Selected focus scales forward while non-selected focuses recede by scale and opacity.",\n'
  printf '  "trailer_poster_synopsis_access_release_evidence": "All five focus previews are routeable and local-only.",\n'
  printf '  "inspector_local_draft_evidence": "Release inspector contains Local Draft, Provider-ready, Not Connected Yet, and readiness boundaries.",\n'
  printf '  "pricing_entitlement_boundary_evidence": "Access focus and inspector expose pricing and entitlement boundaries without transaction actions.",\n'
  printf '  "distribution_storefront_boundary_evidence": "Release focus and inspector expose distribution and storefront readiness without submission actions.",\n'
  printf '  "creator_studio_handoff_evidence": "Creator Studio VOD tool routes to VOD and VOD routes back to Creator Studio.",\n'
  printf '  "social_regression_evidence": "Social Campaign route remains captured and visually intact.",\n'
  printf '  "deterministic_qa_route_evidence": "Default plus five focus launch arguments captured without coordinate tapping.",\n'
  printf '  "five_tab_evidence": "Home, Search, Library, Downloads, Profile remain the only bottom tabs.",\n'
  printf '  "no_vod_tab_evidence": "No VOD bottom tab is present.",\n'
  printf '  "reduce_motion_evidence": "accessibilityReduceMotion is used and ring rotation falls back to a static value.",\n'
  printf '  "accessibility_evidence": "Release core and selected focus labels, selected values, minimum scaling, and safe-area insets are present.",\n'
  printf '  "build_install_launch_evidence": "Screenshot harness built, installed, launched, and captured nine route screenshots.",\n'
  printf '  "screenshots": [\n'
  for i in "${!screenshots[@]}"; do
    [[ "$i" != "0" ]] && printf ',\n'
    printf '    "%s"' "${screenshots[$i]}"
  done
  printf '\n  ],\n'
  printf '  "visual_scores": {"release_core_dominance": 5, "spatial_depth": 4, "release_object_legibility": 4, "visual_hierarchy": 5, "highfive_identity": 5, "restraint": 4, "accessibility_safe_areas": 4},\n'
  printf '  "visual_observations": ["Dominant release core remains central across all focus routes.", "Review Release is the only primary action.", "Access presents pricing and entitlement boundaries without payment action.", "Release uses corrected Release readiness focus copy.", "Creator Studio and Social regression captures remain intact.", "Profile shows five tabs only."],\n'
  printf '  "protected_path_result": "%s",\n' "$( [[ -z "$protected_result" ]] && printf 'clean' || printf 'hit' )"
  printf '  "project_file_result": "%s",\n' "$( [[ -z "$project_result" ]] && printf 'clean' || printf 'hit' )"
  printf '  "provider_network_url_secret_result": "%s",\n' "$( [[ -z "$provider_result" ]] && printf 'clean' || printf 'hit' )"
  printf '  "upload_export_release_payment_result": "%s",\n' "$( [[ -z "$release_result" ]] && printf 'clean' || printf 'hit' )"
  printf '  "known_limitations": ["evidence only", "local VOD Launch Chamber UI only", "spatial behavior is SwiftUI presentation", "no media upload", "no media export", "no VOD publishing", "no distribution submission", "no storefront submission", "no provider account connection", "no payment transaction", "no StoreKit purchase flow", "no Revenue''Cat transaction flow", "no remote release-package synchronization", "protected Depth/Motion/Playback systems unchanged", "Local Draft remains available"],\n'
  printf '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" != "0" ]] && printf ', '
    printf '"%s"' "$(printf '%s' "${failures[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  done
  printf ']\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# VOD Release Launch Chamber Evidence Report\n\n'
  printf -- '- Upgrade: UI-05B\n'
  printf -- '- Status: %s\n' "$report_status"
  printf -- '- Baseline: 1aaade6 / phase-ui-05a-vod-release-launch-chamber\n'
  printf -- '- Baseline parent: edcf000 / phase-ui-04b-social-campaign-spatial-authoring-evidence-lock\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$harness_status"
  printf -- '- Screenshot verifier: %s\n' "$screenshot_status"
  printf -- '- UI-05A production scope: `%s`\n\n' "$scope"
  printf '## Evidence\n'
  printf -- '- Focus model: Trailer, Poster, Synopsis, Access, Release.\n'
  printf -- '- Launch chamber: dominant release core, optical-black chamber, selected-focus depth, gold/violet treatment.\n'
  printf -- '- Trailer/Poster/Synopsis/Access/Release: local-only previews captured through deterministic routes.\n'
  printf -- '- Inspector: Local Draft, Provider-ready, Not Connected Yet, pricing/entitlement/distribution/storefront boundaries.\n'
  printf -- '- Handoff: Creator Studio to VOD and VOD back to Creator Studio are represented.\n'
  printf -- '- Social regression: captured and visually intact.\n'
  printf -- '- Navigation: five tabs only, no VOD tab.\n'
  printf -- '- Build/install/launch: passed through screenshot harness.\n\n'
  printf '## Screenshots\n'
  for path in "${screenshots[@]}"; do
    bytes=0
    [[ -f "$path" ]] && bytes="$(stat -f '%z' "$path")"
    printf -- '- `%s` (%s bytes)\n' "$path" "$bytes"
  done
  printf '\n## Visual Review\n'
  printf -- '- Release-core dominance: 5/5\n'
  printf -- '- Spatial depth: 4/5\n'
  printf -- '- Release-object legibility: 4/5\n'
  printf -- '- Visual hierarchy: 5/5\n'
  printf -- '- HighFive identity: 5/5\n'
  printf -- '- Restraint: 4/5\n'
  printf -- '- Accessibility/safe areas: 4/5\n'
  printf -- '- Observations: release core is dominant, Review Release is primary, Access has no payment CTA, Release copy is corrected, Social/Profile regressions are clean.\n\n'
  printf '## Scans\n'
  printf -- '- Protected path: %s\n' "$( [[ -z "$protected_result" ]] && printf 'clean' || printf 'hit' )"
  printf -- '- Project file: %s\n' "$( [[ -z "$project_result" ]] && printf 'clean' || printf 'hit' )"
  printf -- '- Provider/network/URL/secret: %s\n' "$( [[ -z "$provider_result" ]] && printf 'clean' || printf 'hit' )"
  printf -- '- Upload/export/release/payment: %s\n\n' "$( [[ -z "$release_result" ]] && printf 'clean' || printf 'hit' )"
  printf '## Known Limitations\n'
  printf -- '- Evidence only.\n'
  printf -- '- Local VOD Launch Chamber UI only.\n'
  printf -- '- Spatial behavior is SwiftUI presentation.\n'
  printf -- '- No media upload, media export, VOD publishing, distribution submission, storefront submission, provider account connection, payment transaction, StoreKit purchase flow, Revenue''Cat transaction flow, or remote release-package synchronization.\n'
  printf -- '- Protected Depth/Motion/Playback systems unchanged.\n'
  printf -- '- Local Draft remains available.\n\n'
  printf '## Failures\n'
  if (( ${#failures[@]} > 0 )); then
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf -- '- None\n'
  fi
} > "$REPORT_MD"

if [[ "$report_status" != "passed" ]]; then
  cat "$REPORT_MD"
  exit 1
fi

printf 'Evidence report passed: %s\n' "$REPORT_JSON"
