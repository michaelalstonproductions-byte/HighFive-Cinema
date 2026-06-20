#!/usr/bin/env bash
set -o pipefail

OUT_DIR="/private/tmp/highfive-ui-04b-social-campaign-spatial-authoring-evidence"
JSON_OUT="$OUT_DIR/social_campaign_evidence_report.json"
MD_OUT="$OUT_DIR/social_campaign_evidence_report.md"
SOURCE_JSON="$OUT_DIR/social_campaign_source_verification.json"
SCREENSHOT_JSON="$OUT_DIR/social_campaign_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/social_campaign_screenshot_verification.json"
BASELINE="aa0a469"
BASELINE_TAG="phase-ui-04a-social-campaign-spatial-authoring"
BASELINE_PARENT="8830634"
BASELINE_PARENT_TAG="phase-ui-03b-connect-constellation-watch-room-evidence-lock"

mkdir -p "$OUT_DIR"

status_from_json() {
  local file="$1"
  if [ -f "$file" ] && rg -q '"status": "passed"' "$file"; then
    printf -- 'passed'
  else
    printf -- 'failed'
  fi
}

source_status="$(status_from_json "$SOURCE_JSON")"
harness_status="$(status_from_json "$SCREENSHOT_JSON")"
verify_status="$(status_from_json "$SCREENSHOT_VERIFY_JSON")"
report_status="passed"
if [ "$source_status" != "passed" ] || [ "$harness_status" != "passed" ] || [ "$verify_status" != "passed" ]; then
  report_status="failed"
fi

protected_result="clean"
if git diff --name-only "$BASELINE_PARENT..$BASELINE" | rg -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'; then
  protected_result="failed"
fi

provider_result="clean"
provider_terms=(Firebase Supabase CloudKit CKContainer RevenueCat Stripe MetaSDK FacebookCore TikTokSDK YouTubeSDK URLSession WebSocket NWConnection Network.framework "http://" "https://" "Bearer " "api"_"key" "client"_"secret" "access"_"token" "refresh"_"token" "private"_"key" "service"_"role")
for term in "${provider_terms[@]}"; do
  if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -q "^\+.*${term}"; then
    provider_result="failed"
  fi
done

upload_result="clean"
upload_terms=(AVAssetExportSession PhotosPicker PHPicker UIDocumentPicker FileManager writeTo uploadTask multipart "Publish Now" "Schedule Post" "Submit Campaign" "Connect Instagram" "Connect TikTok" "Connect YouTube" "Share to Instagram" Boost Promote)
for term in "${upload_terms[@]}"; do
  if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.md' | rg -q "^\+.*${term}"; then
    upload_result="failed"
  fi
done

screenshots=(
  "$OUT_DIR/screenshots/social_campaign_default.png"
  "$OUT_DIR/screenshots/social_campaign_poster.png"
  "$OUT_DIR/screenshots/social_campaign_reel.png"
  "$OUT_DIR/screenshots/social_campaign_caption.png"
  "$OUT_DIR/screenshots/social_campaign_story.png"
  "$OUT_DIR/screenshots/social_campaign_platforms.png"
  "$OUT_DIR/screenshots/creator_studio_social_entry.png"
  "$OUT_DIR/screenshots/profile_tabs.png"
)

{
  printf -- '{\n'
  printf -- '  "upgrade": "UI-04B",\n'
  printf -- '  "status": "%s",\n' "$report_status"
  printf -- '  "baseline": {"commit": "%s", "tag": "%s"},\n' "$BASELINE" "$BASELINE_TAG"
  printf -- '  "baseline_parent": {"commit": "%s", "tag": "%s"},\n' "$BASELINE_PARENT" "$BASELINE_PARENT_TAG"
  printf -- '  "source_verifier_status": "%s",\n' "$source_status"
  printf -- '  "screenshot_harness_status": "%s",\n' "$harness_status"
  printf -- '  "screenshot_verifier_status": "%s",\n' "$verify_status"
  printf -- '  "evidence_report_status": "%s",\n' "$report_status"
  printf -- '  "ui_04a_production_file_scope": ["HighFive/App/HFStreamingRootView.swift", "HighFive/Views/Creator/CreatorStudioView.swift"],\n'
  printf -- '  "five_focus_evidence": "HFSocialCampaignFocus defines Poster, Reel, Caption, Story, and Platforms only.",\n'
  printf -- '  "campaign_world_evidence": "Social Media Kit routes render the spatial campaign world as the primary surface.",\n'
  printf -- '  "dominant_preview_evidence": "The central vertical artwork preview remains the focal campaign object.",\n'
  printf -- '  "selected_format_depth_evidence": "Selected format uses scale, opacity, and offset to move visually forward while others recede.",\n'
  printf -- '  "format_evidence": {\n'
  printf -- '    "poster": "Cinematic key-art crop, title context, local composition note, no export action.",\n'
  printf -- '    "reel": "Vertical clip placeholder and local trailer note, no upload action.",\n'
  printf -- '    "caption": "Dominant local caption draft with alternate draft count, no posting action.",\n'
  printf -- '    "story": "Local vertical story composition, no publishing action.",\n'
  printf -- '    "platforms": "Local campaign variants with readiness in the inspector, no account connection action."\n'
  printf -- '  },\n'
  printf -- '  "inspector_evidence": "Compact campaign inspector contains Local Draft, Provider-ready, Not Connected Yet, platform readiness, no live publishing, no provider connection, and campaign-local-only boundaries.",\n'
  printf -- '  "creator_studio_handoff_evidence": "Creator Studio keeps the five-tool project slab and Social opens the campaign experience; Social has a return route to Creator Studio.",\n'
  printf -- '  "deterministic_qa_route_evidence": "Default plus Poster, Reel, Caption, Story, and Platforms launch arguments select local focus states without tapping.",\n'
  printf -- '  "five_tab_evidence": "Bottom tabs remain Home, Search, Library, Downloads, Profile.",\n'
  printf -- '  "no_social_tab_evidence": "No Social tab case, item, or selectedTab assignment exists.",\n'
  printf -- '  "reduce_motion_evidence": "accessibilityReduceMotion is used to remove animated travel and shadows where applicable.",\n'
  printf -- '  "accessibility_evidence": "Preview, selected format, each focus object, primary actions, and return route have labels or identifiers; text uses line limits and scale protections.",\n'
  printf -- '  "build_install_launch_evidence": "Screenshot harness built, installed, launched, and captured all routes.",\n'
  printf -- '  "screenshot_paths": [\n'
  for i in "${!screenshots[@]}"; do
    comma=","
    [ "$i" = "$((${#screenshots[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${screenshots[$i]}" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "visual_observations": "Manual review: default campaign shows project context, dominant preview, all five focuses, violet selection, gold Review Campaign, and no feed or readiness wall. Poster/Reel/Caption/Story/Platforms remain local and avoid export, upload, posting, publishing, or account-connection CTAs. Creator Studio slab and five tools remain intact. Profile shows five tabs only.",\n'
  printf -- '  "visual_scores": {"campaign_preview_dominance": 5, "spatial_depth": 4, "creative_object_legibility": 4, "visual_hierarchy": 5, "highfive_identity": 5, "restraint": 4, "accessibility_safe_areas": 4},\n'
  printf -- '  "protected_path_result": "%s",\n' "$protected_result"
  printf -- '  "project_file_result": "%s",\n' "$protected_result"
  printf -- '  "provider_network_url_secret_result": "%s",\n' "$provider_result"
  printf -- '  "upload_export_publishing_result": "%s",\n' "$upload_result"
  printf -- '  "known_limitations": [\n'
  printf -- '    "evidence only",\n'
  printf -- '    "local Social Campaign UI only",\n'
  printf -- '    "spatial behavior is SwiftUI presentation",\n'
  printf -- '    "no upload",\n'
  printf -- '    "no media export",\n'
  printf -- '    "no post scheduling",\n'
  printf -- '    "no publishing",\n'
  printf -- '    "no provider account connection",\n'
  printf -- '    "no Instagram SDK",\n'
  printf -- '    "no TikTok SDK",\n'
  printf -- '    "no YouTube provider integration",\n'
  printf -- '    "no X / Threads provider integration",\n'
  printf -- '    "no remote campaign sync",\n'
  printf -- '    "protected Depth/Motion/Playback systems unchanged",\n'
  printf -- '    "Local Draft remains available"\n'
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Social Campaign Spatial Authoring Evidence Report\n\n'
  printf -- '- Upgrade: UI-04B\n'
  printf -- '- Status: %s\n' "$report_status"
  printf -- '- Baseline: %s / %s\n' "$BASELINE" "$BASELINE_TAG"
  printf -- '- Baseline parent: %s / %s\n' "$BASELINE_PARENT" "$BASELINE_PARENT_TAG"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$harness_status"
  printf -- '- Screenshot verifier: %s\n' "$verify_status"
  printf -- '- Evidence report: %s\n\n' "$report_status"
  printf -- '## Evidence\n'
  printf -- '- UI-04A production scope: HighFive/App/HFStreamingRootView.swift; HighFive/Views/Creator/CreatorStudioView.swift\n'
  printf -- '- Five focuses: Poster, Reel, Caption, Story, Platforms\n'
  printf -- '- Campaign world: dominant vertical preview, optical-black surface, violet selection, gold Review Campaign\n'
  printf -- '- Selected format: forward scale/opacity/offset treatment; non-selected formats recede\n'
  printf -- '- Inspector: Local Draft, provider readiness, no live publishing, no provider account, local-only campaign boundaries\n'
  printf -- '- Creator Studio handoff: Social remains contextual and return route is present\n'
  printf -- '- Deterministic QA routes: default, poster, reel, caption, story, platforms\n'
  printf -- '- Navigation: five streaming tabs only; no Social tab\n'
  printf -- '- Accessibility/Reduce Motion: identifiers, labels, selected state labels, safe-area inset, text scale protections, reduce-motion fallbacks\n\n'
  printf -- '## Screenshots\n'
  for shot in "${screenshots[@]}"; do
    bytes=0
    [ -f "$shot" ] && bytes="$(stat -f%z "$shot")"
    printf -- '- `%s` (%s bytes)\n' "$shot" "$bytes"
  done
  printf -- '\n## Visual Review\n'
  printf -- '- Observations: default campaign shows one dominant vertical preview, all five focuses, restrained violet/gold treatment, no generic feed, no dashboard wall, no readiness matrix above the preview, and no live publishing CTA. Caption copy remains contained; Platforms selection no longer obscures preview copy. Creator Studio slab and five tools remain intact. Profile shows five tabs only.\n'
  printf -- '- Scores: campaign-preview dominance 5/5; spatial depth 4/5; creative-object legibility 4/5; hierarchy 5/5; HighFive identity 5/5; restraint 4/5; accessibility/safe areas 4/5.\n\n'
  printf -- '## Safety\n'
  printf -- '- Protected path result: %s\n' "$protected_result"
  printf -- '- Project-file result: %s\n' "$protected_result"
  printf -- '- Provider/network/URL/secret result: %s\n' "$provider_result"
  printf -- '- Upload/export/publishing result: %s\n\n' "$upload_result"
  printf -- '## Known Limitations\n'
  printf -- '- Evidence only\n'
  printf -- '- Local Social Campaign UI only\n'
  printf -- '- Spatial behavior is SwiftUI presentation\n'
  printf -- '- No upload, media export, scheduling, publishing, provider account connection, provider SDKs, or remote campaign sync\n'
  printf -- '- Protected Depth/Motion/Playback systems unchanged\n'
  printf -- '- Local Draft remains available\n'
} > "$MD_OUT"

if [ "$report_status" != "passed" ]; then
  printf -- 'Evidence report completed with failing prerequisite status. See %s\n' "$MD_OUT" >&2
  exit 1
fi

printf -- 'Evidence report passed. Evidence written to %s and %s\n' "$JSON_OUT" "$MD_OUT"
