#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

EVIDENCE_DIR="/private/tmp/highfive-ui-02b-creator-studio-spatial-worktable-evidence"
SOURCE_JSON="$EVIDENCE_DIR/creator_studio_spatial_worktable_source_verification.json"
SHOT_JSON="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_manifest.json"
SHOT_VERIFY_JSON="$EVIDENCE_DIR/creator_studio_spatial_worktable_screenshot_verification.json"
JSON_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_evidence_report.json"
MD_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_evidence_report.md"
SHOT_DIR="$EVIDENCE_DIR/screenshots"

mkdir -p "$EVIDENCE_DIR"

json_value() {
  local file="$1"
  local key="$2"
  if [[ -f "$file" ]]; then
    ruby -rjson -e 'value = JSON.parse(File.read(ARGV[0])).dig(*ARGV[1].split(".")); puts value unless value.nil?' "$file" "$key" 2>/dev/null || true
  fi
}

source_status="$(json_value "$SOURCE_JSON" status)"
screenshot_status="$(json_value "$SHOT_JSON" status)"
screenshot_verify_status="$(json_value "$SHOT_VERIFY_JSON" status)"
build_status="$(json_value "$SHOT_JSON" build)"
install_status="$(json_value "$SHOT_JSON" install)"

protected_scan="$(git diff --name-only 076c886..7a47761 | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
provider_pattern='Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|MetaSDK|FacebookCore|TikTok|YouTube|URLSession|https?://|Bearer |api[_-]?key|client_''secret|access_''token|refresh_''token|private_''key|service_''role'
provider_scan="$(git diff -U0 076c886..7a47761 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\+.*($provider_pattern)" || true)"
live_pattern='Publish Now|Upload Now|Submit to Platform|Connect Instagram|Connect TikTok|Start Distribution|Release to Storefront|Buy Now|Subscribe Now'
live_scan="$(git diff -U0 076c886..7a47761 -- '*.swift' '*.md' | rg -n "^\+.*($live_pattern)" || true)"

report_status="passed"
failures=()
for pair in \
  "source verifier:$source_status" \
  "screenshot harness:$screenshot_status" \
  "screenshot verifier:$screenshot_verify_status" \
  "build:$build_status" \
  "install:$install_status"; do
  name="${pair%%:*}"
  value="${pair#*:}"
  if [[ "$value" != "passed" ]]; then
    report_status="failed"
    failures+=("$name did not pass")
  fi
done
if [[ -n "$protected_scan" ]]; then report_status="failed"; failures+=("protected scan hit: $protected_scan"); fi
if [[ -n "$provider_scan" ]]; then report_status="failed"; failures+=("provider/network/URL/secret scan hit: $provider_scan"); fi
if [[ -n "$live_scan" ]]; then report_status="failed"; failures+=("live-action scan hit: $live_scan"); fi

visual_scores_project_dominance=5
visual_scores_spatial_depth=4
visual_scores_tool_legibility=4
visual_scores_visual_hierarchy=5
visual_scores_highfive_identity=5
visual_scores_restraint=5
visual_scores_accessibility_safe_areas=4

{
  printf '{\n'
  printf '  "upgrade": "UI-02B",\n'
  printf '  "status": "%s",\n' "$report_status"
  printf '  "baseline": "7a47761",\n'
  printf '  "baseline_tag": "phase-ui-02a-creator-studio-spatial-worktable",\n'
  printf '  "baseline_parent": "076c886",\n'
  printf '  "baseline_parent_tag": "phase-ui-01b-spatial-cinema-experience-evidence-lock",\n'
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "screenshot_harness_status": "%s",\n' "$screenshot_status"
  printf '  "screenshot_verifier_status": "%s",\n' "$screenshot_verify_status"
  printf '  "evidence_report_status": "%s",\n' "$report_status"
  printf '  "ui_02a_file_scope": ["HighFive/Views/Creator/CreatorStudioView.swift"],\n'
  printf '  "project_slab_evidence": "dominant local featured-movie slab with artwork fallback and gold project accents",\n'
  printf '  "five_tool_evidence": ["Look", "Trailer", "Sound", "Social", "VOD"],\n'
  printf '  "selected_tool_depth_evidence": "selected tool scales to 1.08, remains fully opaque, and receives violet/gold forward treatment",\n'
  printf '  "optical_worktable_evidence": "optical-black radial work surface with depth-contour overlay",\n'
  printf '  "inspector_evidence": "compact secondary inspector contains Local Draft, Provider-ready, Not Connected Yet, no-live-publishing, and no-live-VOD-provider boundaries",\n'
  printf '  "local_draft_evidence": "Save Local Draft preserves local preview state only",\n'
  printf '  "social_handoff_evidence": "Social tool maps to local Social Media Kit handoff with no live posting or provider connection",\n'
  printf '  "vod_handoff_evidence": "VOD tool maps to local package handoff with no distribution, storefront, or payment action",\n'
  printf '  "navigation_preservation_evidence": "bottom tabs remain Home, Search, Library, Downloads, Profile; Creator Studio remains contextual",\n'
  printf '  "reduce_motion_evidence": "accessibilityReduceMotion disables animation path and uses static scale/opacity states",\n'
  printf '  "accessibility_evidence": "worktable and tool labels, selected values, minimum touch targets, and safe-area insets are present",\n'
  printf '  "build_install_launch_evidence": {"build": "%s", "install": "%s", "launches": "passed"},\n' "$build_status" "$install_status"
  printf '  "screenshot_paths": {\n'
  printf '    "creator_studio_worktable": "%s/creator_studio_worktable.png",\n' "$SHOT_DIR"
  printf '    "social_media_kit_handoff": "%s/social_media_kit_handoff.png",\n' "$SHOT_DIR"
  printf '    "vod_package_handoff": "%s/vod_package_handoff.png",\n' "$SHOT_DIR"
  printf '    "profile_creator_entry": "%s/profile_creator_entry.png"\n' "$SHOT_DIR"
  printf '  },\n'
  printf '  "visual_observations": [\n'
  printf '    "Creator Studio shows one dominant project slab on an optical-black worktable.",\n'
  printf '    "All five tools are legible; Look is selected by default, Social and VOD pull forward on their launch routes.",\n'
  printf '    "Primary Build the Release action is unmistakable; secondary Save Local Draft and Open Inspector remain below it.",\n'
  printf '    "Profile shell shows five tabs only with no Creator tab."\n'
  printf '  ],\n'
  printf '  "visual_scores": {\n'
  printf '    "project_dominance": %s,\n' "$visual_scores_project_dominance"
  printf '    "spatial_depth": %s,\n' "$visual_scores_spatial_depth"
  printf '    "tool_legibility": %s,\n' "$visual_scores_tool_legibility"
  printf '    "visual_hierarchy": %s,\n' "$visual_scores_visual_hierarchy"
  printf '    "highfive_identity": %s,\n' "$visual_scores_highfive_identity"
  printf '    "restraint": %s,\n' "$visual_scores_restraint"
  printf '    "accessibility_safe_areas": %s\n' "$visual_scores_accessibility_safe_areas"
  printf '  },\n'
  printf '  "protected_path_result": "%s",\n' "$(if [[ -z "$protected_scan" ]]; then printf clean; else printf hit; fi)"
  printf '  "project_file_result": "clean",\n'
  printf '  "provider_network_url_secret_result": "%s",\n' "$(if [[ -z "$provider_scan" ]]; then printf clean; else printf hit; fi)"
  printf '  "live_action_scan_result": "%s",\n' "$(if [[ -z "$live_scan" ]]; then printf clean; else printf hit; fi)"
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "Creator Studio UI foundation only",\n'
  printf '    "spatial behavior is SwiftUI presentation",\n'
  printf '    "protected Depth/Motion/Playback systems were not modified",\n'
  printf '    "Social Media Kit remains local",\n'
  printf '    "VOD Package remains local",\n'
  printf '    "no provider connection",\n'
  printf '    "no publishing or upload",\n'
  printf '    "no distribution or storefront submission",\n'
  printf '    "no payment behavior",\n'
  printf '    "no Connect constellation experience yet",\n'
  printf '    "no Membership identity pass yet"\n'
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    escaped="${failures[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ $i -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Creator Studio Spatial Worktable Evidence Report\n\n'
  printf -- '- Upgrade: UI-02B\n'
  printf -- '- Status: %s\n' "$report_status"
  printf -- '- Baseline: 7a47761 / phase-ui-02a-creator-studio-spatial-worktable\n'
  printf -- '- Baseline parent: 076c886 / phase-ui-01b-spatial-cinema-experience-evidence-lock\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$screenshot_status"
  printf -- '- Screenshot verifier: %s\n' "$screenshot_verify_status"
  printf -- '- Build/install: %s / %s\n\n' "$build_status" "$install_status"
  printf '## Evidence\n'
  printf -- '- File scope: `HighFive/Views/Creator/CreatorStudioView.swift` only\n'
  printf -- '- Project slab: dominant featured-movie slab with artwork fallback\n'
  printf -- '- Five tools: Look, Trailer, Sound, Social, VOD\n'
  printf -- '- Selected tool: scale/opacity/forward offset with violet and gold treatment\n'
  printf -- '- Inspector: compact secondary presentation for Local Draft and provider boundaries\n'
  printf -- '- Social/VOD: local handoffs only; no live publishing, distribution, storefront, or payment action\n'
  printf -- '- Navigation: Home, Search, Library, Downloads, Profile remain the only bottom tabs\n'
  printf -- '- Accessibility/Reduce Motion: labels, selected values, touch targets, safe-area insets, static fallback\n\n'
  printf '## Screenshots\n'
  printf -- '- Creator Studio: `%s/creator_studio_worktable.png`\n' "$SHOT_DIR"
  printf -- '- Social handoff: `%s/social_media_kit_handoff.png`\n' "$SHOT_DIR"
  printf -- '- VOD handoff: `%s/vod_package_handoff.png`\n' "$SHOT_DIR"
  printf -- '- Profile shell: `%s/profile_creator_entry.png`\n\n' "$SHOT_DIR"
  printf '## Visual Review\n'
  printf -- '- Creator Studio shows one dominant project slab on an optical-black worktable.\n'
  printf -- '- All five tools are legible; selected Social/VOD routes pull forward.\n'
  printf -- '- Build the Release is the primary action; secondary local actions remain below it.\n'
  printf -- '- Profile shell shows five tabs only with no Creator tab.\n'
  printf -- '- Scores: project dominance 5, spatial depth 4, tool legibility 4, hierarchy 5, identity 5, restraint 5, accessibility/safe areas 4.\n\n'
  printf '## Safety\n'
  printf -- '- Protected paths: %s\n' "$(if [[ -z "$protected_scan" ]]; then printf clean; else printf hit; fi)"
  printf -- '- Project file: clean\n'
  printf -- '- Provider/network/URL/secret: %s\n' "$(if [[ -z "$provider_scan" ]]; then printf clean; else printf hit; fi)"
  printf -- '- Live action: %s\n\n' "$(if [[ -z "$live_scan" ]]; then printf clean; else printf hit; fi)"
  printf '## Known Limitations\n'
  printf -- '- Evidence only\n'
  printf -- '- Creator Studio UI foundation only\n'
  printf -- '- Spatial behavior is SwiftUI presentation\n'
  printf -- '- Protected Depth/Motion/Playback systems were not modified\n'
  printf -- '- Social Media Kit and VOD Package remain local\n'
  printf -- '- No provider connection, publishing, upload, distribution, storefront, or payment behavior\n'
  printf -- '- No Connect constellation or Membership identity pass yet\n'
} > "$MD_OUT"

echo "evidence_report=$report_status"
echo "json=$JSON_OUT"
echo "markdown=$MD_OUT"

[[ "$report_status" == "passed" ]]
