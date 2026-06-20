#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-ui-05b-vod-release-launch-chamber-evidence"
JSON_OUT="$OUT_DIR/vod_release_source_verification.json"
MD_OUT="$OUT_DIR/vod_release_source_verification.md"
mkdir -p "$OUT_DIR"

CREATOR="HighFive/Views/Creator/CreatorStudioView.swift"
ROOT="HighFive/App/HFStreamingRootView.swift"
BASE_PARENT="edcf000"
BASELINE="1aaade6"

failures=()
checks=()

record_pass() {
  checks+=("$1")
}

record_fail() {
  failures+=("$1")
}

require_rg() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

expect_empty() {
  local output="$1"
  local label="$2"
  if [[ -z "$output" ]]; then
    record_pass "$label"
  else
    record_fail "$label: $output"
  fi
}

if [[ "$(git rev-parse --short HEAD)" == "$BASELINE" ]]; then
  record_pass "HEAD is $BASELINE"
else
  record_fail "HEAD is $(git rev-parse --short HEAD), expected $BASELINE"
fi

if git tag --points-at HEAD | rg -q '^phase-ui-05a-vod-release-launch-chamber$'; then
  record_pass "baseline tag is present"
else
  record_fail "baseline tag is missing at HEAD"
fi

changed_files="$(git diff --name-only "$BASE_PARENT..$BASELINE" | sort)"
expected_files="$(printf '%s\n%s\n' "$ROOT" "$CREATOR" | sort)"
if [[ "$changed_files" == "$expected_files" ]]; then
  record_pass "UI-05A production scope is exactly the two expected files"
else
  record_fail "UI-05A production scope mismatch: $changed_files"
fi

focus_block="$(sed -n '/enum HFVODReleaseFocus/,/var id:/p' "$CREATOR")"
focus_cases="$(printf '%s\n' "$focus_block" | rg '^[[:space:]]+case ' | sed 's/^[[:space:]]*case //')"
focus_case_count="$(printf '%s\n' "$focus_cases" | sed '/^$/d' | wc -l | tr -d ' ')"
if [[ "$focus_case_count" == "5" ]] \
  && printf '%s\n' "$focus_cases" | rg -q '^trailer$' \
  && printf '%s\n' "$focus_cases" | rg -q '^poster$' \
  && printf '%s\n' "$focus_cases" | rg -q '^synopsis$' \
  && printf '%s\n' "$focus_cases" | rg -q '^access$' \
  && printf '%s\n' "$focus_cases" | rg -q '^release$'; then
  record_pass "HFVODReleaseFocus has exactly trailer, poster, synopsis, access, release"
else
  record_fail "HFVODReleaseFocus cases are not exactly the required five: $focus_cases"
fi

require_rg 'var displayName: String' "$CREATOR" "focus display names exist"
require_rg 'var systemImage: String' "$CREATOR" "focus system images exist"
require_rg 'var purpose: String' "$CREATOR" "focus purpose copy exists"
require_rg 'var accessibilityIdentifier: String' "$CREATOR" "focus accessibility identifiers exist"
require_rg 'vodReleasePreviewContent' "$CREATOR" "local-only preview state exists"

for id in \
  'hf.spatial.vod.trailer' \
  'hf.spatial.vod.poster' \
  'hf.spatial.vod.synopsis' \
  'hf.spatial.vod.access' \
  'hf.spatial.vod.release' \
  'hf.spatial.vod' \
  'hf.spatial.vod.chamber' \
  'hf.spatial.vod.core' \
  'hf.spatial.vod.projectTitle' \
  'hf.spatial.vod.selectedFocus' \
  'hf.vod.reviewRelease' \
  'hf.vod.saveDraft' \
  'hf.vod.inspector' \
  'hf.vod.backToStudio' \
  'hf.route.vodToCreatorStudio' \
  'hf.vod.trailerPreview' \
  'hf.vod.posterPreview' \
  'hf.vod.synopsisPreview' \
  'hf.vod.shortSynopsis' \
  'hf.vod.longSynopsis' \
  'hf.vod.accessPreview' \
  'hf.vod.pricingBoundary' \
  'hf.vod.entitlementBoundary' \
  'hf.vod.storeKitMapping' \
  'hf.vod.localPreviewFallback' \
  'hf.vod.releasePreview' \
  'hf.vod.distributionReadiness' \
  'hf.vod.storefrontReadiness' \
  'hf.vod.releaseLocalOnly' \
  'hf.vod.localDraft' \
  'hf.vod.providerReady' \
  'hf.vod.notConnected' \
  'hf.vod.trailerReadiness' \
  'hf.vod.posterReadiness' \
  'hf.vod.synopsisReadiness' \
  'hf.vod.noLiveProvider' \
  'hf.vod.noDistributionProvider' \
  'hf.vod.noStorefrontProvider' \
  'hf.vod.packageLocalOnly' \
  'hf.spatial.creatorStudio.vod' \
  'hf.creatorStudio.packageVOD' \
  'hf.route.creatorStudioToVOD'; do
  require_rg "$id" "$CREATOR" "identifier $id"
done

for route in \
  '--hf-start-vod-package' \
  '--hf-start-vod-package-trailer' \
  '--hf-start-vod-package-poster' \
  '--hf-start-vod-package-synopsis' \
  '--hf-start-vod-package-access' \
  '--hf-start-vod-package-release'; do
  require_rg "$route" "$ROOT" "launch route $route"
done

require_rg 'vodReleaseInitialFocus' "$ROOT" "VOD initial focus route mapping exists"
require_rg 'if arguments.contains\("--hf-start-vod-package-poster"\) \{ return \.poster \}' "$ROOT" "poster route maps to poster"
require_rg 'if arguments.contains\("--hf-start-vod-package-synopsis"\) \{ return \.synopsis \}' "$ROOT" "synopsis route maps to synopsis"
require_rg 'if arguments.contains\("--hf-start-vod-package-access"\) \{ return \.access \}' "$ROOT" "access route maps to access"
require_rg 'if arguments.contains\("--hf-start-vod-package-release"\) \{ return \.release \}' "$ROOT" "release route maps to release"

require_rg 'projectArtwork\(for: streamingStore.featuredMovie\)' "$CREATOR" "dominant release core uses current project artwork"
require_rg 'scaleEffect\(isSelected \? 1\.08 : 0\.88\)' "$CREATOR" "selected focus moves forward and non-selected recede"
require_rg 'opacity\(isSelected \? 1 : 0\.70\)' "$CREATOR" "non-selected focus recession opacity exists"
require_rg 'HFColors.gold' "$CREATOR" "gold readiness/completion treatment exists"
require_rg 'HFColors.violet' "$CREATOR" "violet creative-depth treatment exists"
require_rg 'RadialGradient' "$CREATOR" "optical-black spatial surface exists"
require_rg 'rotationEffect\(\.degrees\(reduceMotion \? 0 : -12\)\)' "$CREATOR" "static reduced-motion ring fallback exists"
require_rg 'accessibilityReduceMotion' "$CREATOR" "Reduce Motion environment is used"
require_rg 'accessibilityLabel\("Release core first' "$CREATOR" "release core is announced before focus objects"
require_rg 'accessibilityValue\(isSelected \? "Selected" : "Available"\)' "$CREATOR" "selected state is announced without color alone"
require_rg 'minimumScaleFactor' "$CREATOR" "Dynamic Type protections exist"
require_rg 'safeAreaInset' "$CREATOR" "safe-area handling exists"

tab_count="$(rg -c 'HFTabItem\(value:' "$ROOT")"
if [[ "$tab_count" == "5" ]]; then
  record_pass "exactly five HFTabItem entries"
else
  record_fail "expected five HFTabItem entries, found $tab_count"
fi
require_rg 'HFTabItem\(value: \.home, title: "Home"' "$ROOT" "Home tab present"
require_rg 'HFTabItem\(value: \.search, title: "Search"' "$ROOT" "Search tab present"
require_rg 'HFTabItem\(value: \.library, title: "Library"' "$ROOT" "Library tab present"
require_rg 'HFTabItem\(value: \.downloads, title: "Downloads"' "$ROOT" "Downloads tab present"
require_rg 'HFTabItem\(value: \.profile, title: "Profile"' "$ROOT" "Profile tab present"
expect_empty "$(rg -n 'case vod|HFTabItem\(value: \.vod|selectedTab = \.vod' "$ROOT" || true)" "no VOD bottom tab"

protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'
expect_empty "$(git diff --name-only "$BASE_PARENT..$BASELINE" | rg "$protected_pattern" || true)" "no protected/project/assets/plist/privacy/entitlement changes"

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
expect_empty "$(git diff -U0 "$BASE_PARENT..$BASELINE" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\\+.*($provider_pattern)" || true)" "no provider/network/URL/secret additions"

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
expect_empty "$(git diff -U0 "$BASE_PARENT..$BASELINE" -- '*.swift' '*.md' | rg -n "^\\+.*($release_pattern)" || true)" "no upload/export/release/payment additions"

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

{
  printf '{\n'
  printf '  "upgrade": "UI-05B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "baseline": "1aaade6",\n'
  printf '  "baseline_tag": "phase-ui-05a-vod-release-launch-chamber",\n'
  printf '  "baseline_parent": "edcf000",\n'
  printf '  "production_scope": ["%s", "%s"],\n' "$ROOT" "$CREATOR"
  printf '  "checks_passed": %s,\n' "${#checks[@]}"
  printf '  "failures": ['
  for i in "${!failures[@]}"; do
    [[ "$i" != "0" ]] && printf ', '
    printf '"%s"' "$(printf '%s' "${failures[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  done
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# VOD Release Launch Chamber Source Verification\n\n'
  printf -- '- Upgrade: UI-05B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: 1aaade6 / phase-ui-05a-vod-release-launch-chamber\n'
  printf -- '- Baseline parent: edcf000 / phase-ui-04b-social-campaign-spatial-authoring-evidence-lock\n'
  printf -- '- Production scope: `%s`, `%s`\n' "$ROOT" "$CREATOR"
  printf -- '- Checks passed: %s\n\n' "${#checks[@]}"
  printf '## Evidence\n'
  printf -- '- Focus model: HFVODReleaseFocus with Trailer, Poster, Synopsis, Access, Release.\n'
  printf -- '- Launch chamber: dominant release core, selected-focus depth, non-selected recession, gold/violet optical-black treatment.\n'
  printf -- '- Local actions: Review Release, Save Local Package, Open Inspector, Back to Creator Studio.\n'
  printf -- '- Inspector: Local Draft, Provider-ready, Not Connected Yet, readiness and provider boundaries.\n'
  printf -- '- Navigation: five streaming tabs only, no VOD tab.\n'
  printf -- '- Safety: no protected paths, project file, provider/network/secret, upload/export/release/payment additions.\n\n'
  if (( ${#failures[@]} > 0 )); then
    printf '## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '## Failures\n- None\n'
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf 'Source verification passed: %s\n' "$JSON_OUT"
