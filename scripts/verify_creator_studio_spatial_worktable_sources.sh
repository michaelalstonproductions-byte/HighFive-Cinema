#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

EVIDENCE_DIR="/private/tmp/highfive-ui-02b-creator-studio-spatial-worktable-evidence"
JSON_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_source_verification.json"
MD_OUT="$EVIDENCE_DIR/creator_studio_spatial_worktable_source_verification.md"
SOURCE="HighFive/Views/Creator/CreatorStudioView.swift"
ROOT_VIEW="HighFive/App/HFStreamingRootView.swift"

mkdir -p "$EVIDENCE_DIR"

failures=()
passes=()

pass() {
  passes+=("$1")
}

fail() {
  failures+=("$1")
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "file exists: $file"
  else
    fail "missing file: $file"
  fi
}

require_contains() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if rg -q -- "$pattern" "$file"; then
    pass "$description"
  else
    fail "$description"
  fi
}

require_absent() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if rg -q -- "$pattern" "$file"; then
    fail "$description"
  else
    pass "$description"
  fi
}

require_empty_command() {
  local description="$1"
  shift
  local output
  set +e
  output="$("$@" 2>/dev/null)"
  local status=$?
  set -e
  if [[ $status -eq 0 && -n "$output" ]]; then
    fail "$description: $output"
  else
    pass "$description"
  fi
}

require_file "$SOURCE"
require_file "$ROOT_VIEW"

tool_case_count="$(awk '/private enum HFSpatialCreatorTool/,/struct CreatorStudioView/' "$SOURCE" | rg 'case (look|trailer|sound|social|vod) =' | wc -l | tr -d ' ')"
if [[ "$tool_case_count" == "5" ]]; then
  pass "HFSpatialCreatorTool has exactly five tool cases"
else
  fail "HFSpatialCreatorTool expected 5 tool cases, found $tool_case_count"
fi

for token in 'HFSpatialCreatorTool' 'case look = "Look"' 'case trailer = "Trailer"' 'case sound = "Sound"' 'case social = "Social"' 'case vod = "VOD"'; do
  require_contains "$SOURCE" "$token" "spatial tool model includes $token"
done

for token in \
  'selectedTool' \
  'private static func tool\(for focus: HFCreatorStudioFocus\)' \
  'private var spatialWorktable' \
  'private var opticalBlackWorkSurface' \
  'HFDepthContourOverlay' \
  'private var spatialProjectSlab' \
  'projectArtwork\(for: movie\)' \
  'HFPosterFallback' \
  'HFColors.gold' \
  'HFColors.violet' \
  'scaleEffect\(isSelected \? 1.08 : 0.94\)' \
  'opacity\(isSelected \? 1 : 0.78\)' \
  'selectedOffset\(for: tool\)' \
  'private var creatorInspector' \
  'presentationDetents' \
  'HFEnergyAction\(title: "Build the Release"' \
  'didSaveLocalDraft' \
  'compactHandoffPanel' \
  'No live publishing' \
  'No live VOD provider'; do
  require_contains "$SOURCE" "$token" "source contains $token"
done

for identifier in \
  'hf.spatial.creatorStudio' \
  'hf.spatial.creatorStudio.worktable' \
  'hf.spatial.creatorStudio.project' \
  'hf.spatial.creatorStudio.projectTitle' \
  'hf.spatial.creatorStudio.buildRelease' \
  'hf.spatial.creatorStudio.saveDraft' \
  'hf.spatial.creatorStudio.inspector' \
  'hf.spatial.creatorStudio.backToStreaming' \
  'hf.spatial.creatorStudio.look' \
  'hf.spatial.creatorStudio.trailer' \
  'hf.spatial.creatorStudio.sound' \
  'hf.spatial.creatorStudio.social' \
  'hf.spatial.creatorStudio.vod' \
  'hf.creatorStudio.inspector' \
  'hf.creatorStudio.localDraft' \
  'hf.creatorStudio.providerReady' \
  'hf.creatorStudio.notConnected' \
  'hf.creatorStudio.noLivePublishing' \
  'hf.creatorStudio.noLiveVODProvider' \
  'hf.route.creatorStudioToSocial' \
  'hf.creatorStudio.prepareSocialKit' \
  'hf.route.creatorStudioToVOD' \
  'hf.creatorStudio.packageVOD'; do
  require_contains "$SOURCE" "$identifier" "required identifier present: $identifier"
done

require_contains "$SOURCE" 'accessibilityLabel\("Creator Studio spatial worktable with project slab and five tools"\)' "VoiceOver label for worktable"
require_contains "$SOURCE" 'accessibilityLabel\("\\\(tool.rawValue\) tool"\)' "VoiceOver labels for tools"
require_contains "$SOURCE" 'accessibilityValue\(isSelected \? "Selected" : "Available"\)' "selected state announced"
require_contains "$SOURCE" '@Environment\(\\.accessibilityReduceMotion\)' "Reduce Motion environment used"
require_contains "$SOURCE" 'withAnimation\(reduceMotion \? nil' "Reduce Motion disables selection animation"
require_contains "$SOURCE" 'frame\(minWidth: 72, minHeight: 72\)' "minimum touch target treatment"
require_absent "$SOURCE" 'repeatForever|rotationEffect|TimelineView|Canvas' "no unbounded particle or continuous orbit animation"

tab_count="$(rg -c 'HFTabItem\(value:' "$ROOT_VIEW" | tr -d ' ')"
if [[ "$tab_count" == "5" ]]; then
  pass "bottom navigation has exactly five HFTabItem entries"
else
  fail "bottom navigation expected 5 HFTabItem entries, found $tab_count"
fi

for tab in 'Home' 'Search' 'Library' 'Downloads' 'Profile'; do
  require_contains "$ROOT_VIEW" "title: \"$tab\"" "bottom tab present: $tab"
done
require_absent "$ROOT_VIEW" 'HFTabItem\(value: \\.creator|title: "Creator"|case creator' "no Creator bottom tab"

for route in '--hf-start-creator-studio' '--hf-start-social-media-kit' '--hf-start-vod-package'; do
  require_contains "$ROOT_VIEW" "$route" "launch route remains: $route"
done

scope_files="$(git diff --name-only 076c886..7a47761)"
if [[ "$scope_files" == "$SOURCE" ]]; then
  pass "UI-02A changed only $SOURCE"
else
  fail "UI-02A changed unexpected files: $scope_files"
fi

require_empty_command "UI-02A protected path scan clean" bash -c "git diff --name-only 076c886..7a47761 | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\\.entitlements'"

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|MetaSDK|FacebookCore|TikTok|YouTube|URLSession|https?://|Bearer |api[_-]?key|client_''secret|access_''token|refresh_''token|private_''key|service_''role'
require_empty_command "UI-02A provider/network/URL/secret scan clean" bash -c "git diff -U0 076c886..7a47761 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n '^\\+.*($provider_pattern)'"

live_pattern='Publish Now|Upload Now|Submit to Platform|Connect Instagram|Connect TikTok|Start Distribution|Release to Storefront|Buy Now|Subscribe Now'
require_empty_command "UI-02A forbidden live-action scan clean" bash -c "git diff -U0 076c886..7a47761 -- '*.swift' '*.md' | rg -n '^\\+.*($live_pattern)'"

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf '{\n'
  printf '  "upgrade": "UI-02B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "baseline": "7a47761",\n'
  printf '  "baseline_tag": "phase-ui-02a-creator-studio-spatial-worktable",\n'
  printf '  "baseline_parent": "076c886",\n'
  printf '  "baseline_parent_tag": "phase-ui-01b-spatial-cinema-experience-evidence-lock",\n'
  printf '  "source_file": "%s",\n' "$SOURCE"
  printf '  "tool_count": %s,\n' "$tool_case_count"
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    escaped="${passes[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ $i -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
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
  printf '# Creator Studio Spatial Worktable Source Verification\n\n'
  printf -- '- Upgrade: UI-02B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: 7a47761 / phase-ui-02a-creator-studio-spatial-worktable\n'
  printf -- '- Baseline parent: 076c886 / phase-ui-01b-spatial-cinema-experience-evidence-lock\n'
  printf -- '- Source file: `%s`\n' "$SOURCE"
  printf -- '- Tool count: %s\n\n' "$tool_case_count"
  printf '## Passes\n'
  for item in "${passes[@]}"; do printf -- '- %s\n' "$item"; done
  printf '\n## Failures\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
  fi
} > "$MD_OUT"

echo "source_verification=$status"
echo "json=$JSON_OUT"
echo "markdown=$MD_OUT"

[[ "$status" == "passed" ]]
