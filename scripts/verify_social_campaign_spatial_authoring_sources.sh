#!/usr/bin/env bash
set -o pipefail

OUT_DIR="/private/tmp/highfive-ui-04b-social-campaign-spatial-authoring-evidence"
JSON_OUT="$OUT_DIR/social_campaign_source_verification.json"
MD_OUT="$OUT_DIR/social_campaign_source_verification.md"
ROOT_FILE="HighFive/App/HFStreamingRootView.swift"
CREATOR_FILE="HighFive/Views/Creator/CreatorStudioView.swift"
BASELINE_PARENT="8830634"
BASELINE="aa0a469"

mkdir -p "$OUT_DIR"

failures=()
passes=()

pass() {
  passes+=("$1")
}

fail() {
  failures+=("$1")
}

require_rg() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_absent_rg() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

require_diff_absent() {
  local pattern="$1"
  local label="$2"
  if git diff --name-only "$BASELINE_PARENT..$BASELINE" | rg -q "$pattern"; then
    fail "$label"
  else
    pass "$label"
  fi
}

case_count="$(awk '
  /enum HFSocialCampaignFocus/ { in_enum = 1; next }
  in_enum && /^[[:space:]]*var id:/ { in_enum = 0 }
  in_enum && /^[[:space:]]*case / { count++ }
  END { print count + 0 }
' "$CREATOR_FILE")"

if [ "$case_count" = "5" ]; then
  pass "HFSocialCampaignFocus has exactly five cases"
else
  fail "HFSocialCampaignFocus case count is $case_count, expected 5"
fi

require_rg "enum HFSocialCampaignFocus" "$CREATOR_FILE" "HFSocialCampaignFocus exists"
for focus in poster reel caption story platforms; do
  require_rg "case $focus" "$CREATOR_FILE" "focus case $focus exists"
done
require_rg "var displayName" "$CREATOR_FILE" "focus display names exist"
require_rg "var systemImage" "$CREATOR_FILE" "focus system images exist"
require_rg "var purpose" "$CREATOR_FILE" "focus purposes exist"
require_rg "var accessibilityIdentifier" "$CREATOR_FILE" "focus accessibility identifiers exist"

for identifier in \
  "hf.spatial.social.poster" \
  "hf.spatial.social.reel" \
  "hf.spatial.social.caption" \
  "hf.spatial.social.story" \
  "hf.spatial.social.platforms" \
  "hf.spatial.social" \
  "hf.spatial.social.world" \
  "hf.spatial.social.preview" \
  "hf.spatial.social.projectTitle" \
  "hf.spatial.social.selectedFormat" \
  "hf.spatial.social.reviewCampaign" \
  "hf.spatial.social.saveDraft" \
  "hf.spatial.social.inspector" \
  "hf.spatial.social.backToStudio" \
  "hf.route.socialToCreatorStudio" \
  "hf.social.posterPreview" \
  "hf.social.reelPreview" \
  "hf.social.captionPreview" \
  "hf.social.captionDrafts" \
  "hf.social.storyPreview" \
  "hf.social.platformPreview" \
  "hf.social.inspector" \
  "hf.social.localDraft" \
  "hf.social.providerReady" \
  "hf.social.notConnected" \
  "hf.social.instagramReadiness" \
  "hf.social.tiktokReadiness" \
  "hf.social.youtubeShortsReadiness" \
  "hf.social.threadsReadiness" \
  "hf.social.noLivePublishing" \
  "hf.social.noProviderConnection" \
  "hf.social.campaignLocalOnly" \
  "hf.spatial.creatorStudio.social" \
  "hf.creatorStudio.prepareSocialKit" \
  "hf.route.creatorStudioToSocial"; do
  require_rg "$identifier" "$CREATOR_FILE" "identifier $identifier exists"
done

require_rg "HFOpticalGlassSurface" "$CREATOR_FILE" "optical glass surface used"
require_rg "socialOpticalBlackSurface" "$CREATOR_FILE" "optical-black social surface exists"
require_rg "HFDepthContourOverlay" "$CREATOR_FILE" "depth contour treatment used"
require_rg "projectArtwork\\(for: streamingStore.featuredMovie\\)" "$CREATOR_FILE" "campaign preview uses local project artwork"
require_rg "frame\\(width: 214, height: 316\\)" "$CREATOR_FILE" "dominant vertical preview dimensions exist"
require_rg "scaleEffect\\(isSelected \\? 1\\.08 : 0\\.88\\)" "$CREATOR_FILE" "selected focus moves visually forward"
require_rg "opacity\\(isSelected \\? 1 : 0\\.70\\)" "$CREATOR_FILE" "non-selected focuses recede"
require_rg "HFColors.violet" "$CREATOR_FILE" "violet creative-selection treatment exists"
require_rg "HFEnergyAction\\(title: \"Review Campaign\"" "$CREATOR_FILE" "gold Review Campaign primary action exists"
require_rg "Save Local Campaign" "$CREATOR_FILE" "Save Local Campaign action exists"
require_rg "Back to Creator Studio" "$CREATOR_FILE" "Social return to Creator Studio exists"
require_rg "accessibilityReduceMotion" "$CREATOR_FILE" "Reduce Motion environment used"
require_rg "reduceMotion \\? nil" "$CREATOR_FILE" "reduced-motion animation fallback exists"
require_rg "accessibilityLabel\\(\"Dominant vertical campaign preview" "$CREATOR_FILE" "campaign preview accessibility label exists"
require_rg "accessibilityLabel.*focus\\.displayName" "$CREATOR_FILE" "focus accessibility label exists"
require_rg "isSelected \\? \"selected\" : \"not selected\"" "$CREATOR_FILE" "focus selected state is announced"
require_rg "minimumScaleFactor" "$CREATOR_FILE" "Dynamic Type scale protections exist"
require_rg "safeAreaInset" "$CREATOR_FILE" "safe-area handling exists"
require_absent_rg "repeatForever|TimelineView|Canvas|particle" "$CREATOR_FILE" "no continuous orbit, particle, or canvas effect in CreatorStudioView"

for route in \
  "--hf-start-social-media-kit" \
  "--hf-start-social-media-kit-poster" \
  "--hf-start-social-media-kit-reel" \
  "--hf-start-social-media-kit-caption" \
  "--hf-start-social-media-kit-story" \
  "--hf-start-social-media-kit-platforms"; do
  require_rg "$route" "$ROOT_FILE" "launch route $route exists"
done
require_rg "socialCampaignInitialFocus" "$ROOT_FILE" "social route focus mapper exists"
require_rg "return \\.reel" "$ROOT_FILE" "reel route selects reel"
require_rg "return \\.caption" "$ROOT_FILE" "caption route selects caption"
require_rg "return \\.story" "$ROOT_FILE" "story route selects story"
require_rg "return \\.platforms" "$ROOT_FILE" "platforms route selects platforms"
require_rg "return \\.poster" "$ROOT_FILE" "default social route selects poster"

tab_count="$(rg -c "HFTabItem\\(value:" "$ROOT_FILE")"
if [ "$tab_count" = "5" ]; then
  pass "bottom tab item count is exactly five"
else
  fail "bottom tab item count is $tab_count, expected 5"
fi
for tab in home search library downloads profile; do
  require_rg "HFTabItem\\(value: \\.$tab" "$ROOT_FILE" "bottom tab $tab exists"
done
require_absent_rg "case social|HFTabItem\\(value: \\.social|selectedTab = \\.social" "$ROOT_FILE" "no Social bottom tab"

actual_scope="$(git diff --name-only "$BASELINE_PARENT..$BASELINE" | sort | tr '\n' ' ')"
expected_scope="HighFive/App/HFStreamingRootView.swift HighFive/Views/Creator/CreatorStudioView.swift "
if [ "$actual_scope" = "$expected_scope" ]; then
  pass "UI-04A production scope is exactly the two expected files"
else
  fail "UI-04A production scope mismatch: $actual_scope"
fi

require_diff_absent 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' "no protected/project/asset/plist/privacy/entitlement path changed"

provider_terms=(
  Firebase Supabase CloudKit CKContainer RevenueCat Stripe MetaSDK FacebookCore
  TikTokSDK YouTubeSDK URLSession WebSocket NWConnection Network.framework
  "http://" "https://" "Bearer " "api"_"key" "client"_"secret"
  "access"_"token" "refresh"_"token" "private"_"key" "service"_"role"
)
provider_hit=0
for term in "${provider_terms[@]}"; do
  if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -q "^\+.*${term}"; then
    provider_hit=1
  fi
done
if [ "$provider_hit" = "0" ]; then
  pass "no provider, network, remote URL, or credential term added"
else
  fail "provider, network, remote URL, or credential term added"
fi

upload_terms=(
  AVAssetExportSession PhotosPicker PHPicker UIDocumentPicker FileManager writeTo
  uploadTask multipart "Publish Now" "Schedule Post" "Submit Campaign"
  "Connect Instagram" "Connect TikTok" "Connect YouTube" "Share to Instagram"
  Boost Promote
)
upload_hit=0
for term in "${upload_terms[@]}"; do
  if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.md' | rg -q "^\+.*${term}"; then
    upload_hit=1
  fi
done
if [ "$upload_hit" = "0" ]; then
  pass "no upload, export, file-write, publishing, scheduling, or sharing action added"
else
  fail "upload, export, file-write, publishing, scheduling, or sharing term added"
fi

status="passed"
if [ "${#failures[@]}" -ne 0 ]; then
  status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "UI-04B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "baseline": "%s",\n' "$BASELINE"
  printf -- '  "baseline_parent": "%s",\n' "$BASELINE_PARENT"
  printf -- '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [ "$i" = "$((${#passes[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${passes[$i]//\"/\\\"}" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [ "$i" = "$((${#failures[@]} - 1))" ] && comma=""
    printf -- '    "%s"%s\n' "${failures[$i]//\"/\\\"}" "$comma"
  done
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Social Campaign Source Verification\n\n'
  printf -- '- Upgrade: UI-04B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: %s\n' "$BASELINE"
  printf -- '- Baseline parent: %s\n' "$BASELINE_PARENT"
  printf -- '- Production scope: %s\n\n' "$actual_scope"
  printf -- '## Passed Evidence\n'
  for item in "${passes[@]}"; do
    printf -- '- %s\n' "$item"
  done
  printf -- '\n## Failures\n'
  if [ "${#failures[@]}" -eq 0 ]; then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MD_OUT"

if [ "$status" != "passed" ]; then
  printf -- 'Source verification failed. See %s\n' "$MD_OUT" >&2
  exit 1
fi

printf -- 'Source verification passed. Evidence written to %s and %s\n' "$JSON_OUT" "$MD_OUT"
