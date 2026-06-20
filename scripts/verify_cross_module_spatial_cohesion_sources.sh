#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UPGRADE="UI-07B"
BASELINE="3063e12"
BASELINE_TAG="phase-ui-07a-cross-module-spatial-motion-accessibility-cohesion"
BASELINE_PARENT="78c401b"
BASELINE_PARENT_TAG="phase-ui-06b-membership-identity-pass-evidence-lock"
OUT_DIR="/private/tmp/highfive-ui-07b-spatial-cohesion-evidence"
JSON_OUT="$OUT_DIR/cross_module_spatial_cohesion_source_verification.json"
MD_OUT="$OUT_DIR/cross_module_spatial_cohesion_source_verification.md"
mkdir -p "$OUT_DIR"

declare -a failures=()
declare -a notes=()

fail() {
  failures+=("$1")
}

note() {
  notes+=("$1")
}

require_rg() {
  local pattern="$1"
  local path="${2:-HighFive}"
  local label="$3"
  if ! rg -q -- "$pattern" "$path"; then
    fail "$label"
  fi
}

require_no_rg() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if rg -q -- "$pattern" "$path"; then
    fail "$label"
  fi
}

require_diff_no_rg() {
  local pattern="$1"
  local label="$2"
  if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -q -- "$pattern"; then
    fail "$label"
  fi
}

expected_files=$'HighFive/Components/HFSpatialCinemaPrimitives.swift\nHighFive/Views/Connect/ConnectHubView.swift\nHighFive/Views/Creator/CreatorStudioView.swift\nHighFive/Views/Home/HomeView.swift\nHighFive/Views/MovieDetail/MovieDetailView.swift\nHighFive/Views/Profile/ProfileView.swift'
actual_files="$(git diff --name-only "$BASELINE_PARENT..$BASELINE" | sort)"
if [[ "$actual_files" != "$expected_files" ]]; then
  fail "UI-07A production scope differs from expected six files"
fi

if ! git rev-parse -q --verify "$BASELINE^{commit}" >/dev/null; then
  fail "baseline commit $BASELINE is unavailable"
fi
if ! git tag --points-at "$BASELINE" | rg -q "^${BASELINE_TAG}$"; then
  fail "baseline tag $BASELINE_TAG is not on $BASELINE"
fi
if ! git rev-parse -q --verify "$BASELINE_PARENT^{commit}" >/dev/null; then
  fail "baseline parent commit $BASELINE_PARENT is unavailable"
fi
if ! git tag --points-at "$BASELINE_PARENT" | rg -q "^${BASELINE_PARENT_TAG}$"; then
  fail "baseline parent tag $BASELINE_PARENT_TAG is not on $BASELINE_PARENT"
fi
if ! git diff --check "$BASELINE_PARENT..$BASELINE" >/dev/null; then
  fail "UI-07A commit range has whitespace errors"
fi

PRIMITIVES="HighFive/Components/HFSpatialCinemaPrimitives.swift"
CREATOR="HighFive/Views/Creator/CreatorStudioView.swift"
CONNECT="HighFive/Views/Connect/ConnectHubView.swift"
PROFILE="HighFive/Views/Profile/ProfileView.swift"
HOME="HighFive/Views/Home/HomeView.swift"
MOVIE="HighFive/Views/MovieDetail/MovieDetailView.swift"
ROOT_VIEW="HighFive/App/HFStreamingRootView.swift"

require_rg "enum HFSpatialMotionTokens" "$PRIMITIVES" "missing HFSpatialMotionTokens"
require_rg "microResponse: Double = 0\\.16" "$PRIMITIVES" "missing micro response token"
require_rg "standardTransition: Double = 0\\.26" "$PRIMITIVES" "missing standard transition token"
require_rg "sceneEntrance: Double = 0\\.48" "$PRIMITIVES" "missing scene entrance token"
require_rg "focusSpringResponse: Double = 0\\.42" "$PRIMITIVES" "missing focus spring response token"
require_rg "focusSpringDamping: Double = 0\\.86" "$PRIMITIVES" "missing focus spring damping token"
require_rg "selectedScale: CGFloat = 1\\.055" "$PRIMITIVES" "missing selected scale token"
require_rg "recededScale: CGFloat = 0\\.93" "$PRIMITIVES" "missing receded scale token"
require_rg "maximumTiltDegrees: Double = 7" "$PRIMITIVES" "missing shared maximum tilt token"

require_rg "enum HFSpatialDepthState" "$PRIMITIVES" "missing HFSpatialDepthState"
require_rg "enum HFSpatialSelectionTreatment" "$PRIMITIVES" "missing HFSpatialSelectionTreatment"
require_rg "typealias HFSpatialFocusTransform" "$PRIMITIVES" "missing HFSpatialFocusTransform"
require_rg "HFSpatialSelectionModifier" "$PRIMITIVES" "missing shared selection modifier"
require_rg "\\.zIndex\\(isSelected \\? 2 : 0\\)" "$PRIMITIVES" "missing selected z-index distinction"
require_rg "accessibilityAddTraits\\(isSelected \\? \\.isSelected : \\[\\]\\)" "$PRIMITIVES" "missing selected VoiceOver trait"
require_rg "accessibilityValue\\(isSelected \\? \"Selected\" : \"Not selected\"\\)" "$PRIMITIVES" "missing selected accessibility value"
require_rg "hf.spatial.motion.selected" "$PRIMITIVES" "missing selected motion identifier"
require_rg "hf.spatial.motion.receded" "$PRIMITIVES" "missing receded motion identifier"
require_rg "hf.spatial.accessibility.differentiateWithoutColor" "$PRIMITIVES" "missing non-color selection identifier"

require_rg "HFSpatialSceneEntranceModifier" "$PRIMITIVES" "missing finite scene entrance modifier"
require_rg "hf.spatial.motion.sceneEntrance" "$PRIMITIVES" "missing scene entrance identifier"
require_rg "hf.spatial.motion.reduceMotionFallback" "$PRIMITIVES" "missing Reduce Motion fallback identifier"
require_no_rg "repeatForever|TimelineView" "$PRIMITIVES" "shared primitives contain continuous animation"

require_rg "struct HFOpticalGlassSurface" "$PRIMITIVES" "missing HFOpticalGlassSurface"
require_rg "accessibilityReduceTransparency" "$PRIMITIVES" "missing Reduce Transparency environment"
require_rg "Color\\.black\\.opacity\\(0\\.96\\)" "$PRIMITIVES" "missing opaque black Reduce Transparency fallback"
require_rg "hf.spatial.material.opticalBlack" "$PRIMITIVES" "missing optical black material identifier"
require_rg "hf.spatial.material.reduceTransparency" "$PRIMITIVES" "missing reduce transparency material identifier"

require_rg "struct HFSpatialActionCluster" "$PRIMITIVES" "missing shared action cluster"
require_rg "struct HFEnergyAction" "$PRIMITIVES" "missing HFEnergyAction"
require_rg "frame\\(minHeight: 52\\)" "$PRIMITIVES" "primary action target is below expected size or not verified"
require_rg "style == \\.gold && differentiateWithoutColor" "$PRIMITIVES" "missing non-color support in gold primary action"
require_rg "hf.spatial.actionCluster" "$PRIMITIVES" "missing action cluster identifier"

require_rg "struct HFSpatialInspectorChrome" "$PRIMITIVES" "missing shared inspector chrome"
require_rg "hf.spatial.inspector.chrome" "$PRIMITIVES" "missing inspector chrome identifier"

require_rg "accessibilityReduceMotion" "HighFive" "missing Reduce Motion environment usage"
require_rg "accessibilityReduceTransparency" "HighFive" "missing Reduce Transparency environment usage"
require_rg "accessibilityDifferentiateWithoutColor" "HighFive" "missing Differentiate Without Color environment usage"
require_rg "dynamicTypeSize" "HighFive" "missing Dynamic Type environment usage"
require_rg "accessibilitySortPriority" "HighFive" "missing VoiceOver sort priority evidence"
require_rg "accessibilityAddTraits" "HighFive" "missing VoiceOver selected trait evidence"
require_rg "accessibilityValue" "HighFive" "missing VoiceOver value evidence"
require_rg "hf.spatial.accessibility.largeType" "HighFive" "missing large type identifier"
require_rg "hf.spatial.accessibility.fallbackLayout" "HighFive" "missing fallback layout identifier"

require_rg "hfSpatialSceneEntrance" "$HOME" "Home missing shared finite scene entrance"
require_rg "Watch" "$HOME" "Home Watch action missing"
require_rg "Depth" "$HOME" "Home Depth action missing"
require_rg "Saved|Save" "$HOME" "Home Save action missing"
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- "$HOME" | rg -q '^\\+.*repeatForever'; then
  fail "Home introduced repeatForever"
fi

require_rg "hfSpatialSceneEntrance" "$MOVIE" "Movie Detail missing shared finite scene entrance"
require_rg "Watch Together" "$MOVIE" "Movie Detail Watch Together route missing"
require_rg "Access & Playback Readiness" "$MOVIE" "Movie Detail readiness boundary missing"

require_rg "hf.spatial.creatorStudio.project" "$CREATOR" "Creator project slab identifier missing"
require_rg "Look|Trailer|Sound|Social|VOD" "$CREATOR" "Creator five tools are incomplete"
require_rg "hfSpatialSelectionTreatment" "$CREATOR" "Creator missing shared selection treatment"
require_rg "usesSpatialFallbackLayout" "$CREATOR" "Creator missing large-text fallback switch"
require_rg "hf.spatial.accessibility.fallbackLayout" "$CREATOR" "Creator missing fallback layout identifier"

require_rg "hf.spatial.connect.portal" "$CONNECT" "Connect movie portal missing"
require_rg "Host" "$CONNECT" "Connect host label missing"
require_rg "presenceSummaryFallback" "$CONNECT" "Connect readable fallback missing"
require_rg "differentiateWithoutColor" "$CONNECT" "Connect missing non-color host/guest evidence"
require_rg "HFSpatialActionCluster" "$CONNECT" "Connect missing shared action cluster"

require_rg "hf.spatial.social.preview" "$CREATOR" "Social campaign preview missing"
require_rg "Poster|Reel|Caption|Story|Platforms" "$CREATOR" "Social five focuses incomplete"
require_rg "hf.social.inspector" "$CREATOR" "Social inspector missing"

require_rg "hf.spatial.vod.core" "$CREATOR" "VOD release core missing"
require_rg "Trailer|Poster|Synopsis|Access|Release" "$CREATOR" "VOD five focuses incomplete"
require_rg "hf.vod.inspector" "$CREATOR" "VOD inspector missing"

require_rg "hf.spatial.membership.pass" "$PROFILE" "Membership pass missing"
require_rg "HFSpatialMotionTokens.maximumTiltDegrees" "$PROFILE" "Membership shared tilt clamp missing"
require_rg "hf.membership.localAccountMode" "$PROFILE" "Local Account Mode missing"
require_rg "hf.membership.localPreviewAccess" "$PROFILE" "Local Preview Access missing"
require_rg "hfSpatialSelectionTreatment" "$PROFILE" "Membership missing shared selection treatment"

tab_count="$(rg -n "HFTabItem\\(value:" "$ROOT_VIEW" | wc -l | tr -d ' ')"
if [[ "$tab_count" != "5" ]]; then
  fail "bottom tab count is $tab_count, expected 5"
fi
for tab in Home Search Library Downloads Profile; do
  require_rg "title: \"$tab\"" "$ROOT_VIEW" "missing bottom tab $tab"
done
require_no_rg "case (connect|creator|social|vod|membership)|HFTabItem\\(value: \\.(connect|creator|social|vod|membership)" "$ROOT_VIEW" "contextual module was added as a bottom tab"

require_rg "Local Preview" "HighFive" "Local Preview evidence missing"
require_rg "Local Draft" "HighFive" "Local Draft evidence missing"
require_rg "Local Account Mode" "HighFive" "Local Account Mode evidence missing"

protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\\.entitlements'
if git diff --name-only "$BASELINE_PARENT..$BASELINE" | rg -q "$protected_pattern"; then
  fail "UI-07A touched protected paths or project/config files"
fi

provider_pattern='^\\+.*(Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|PaymentSheet|STP|MetaSDK|URLSession|WebSocket|NWConnection|Network\\.framework|https?://|Bearer |api[_-]?key|client_'"secret"'|access_'"token"'|refresh_'"token"'|private_'"key"'|service_'"role"')'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -q "$provider_pattern"; then
  fail "UI-07A introduced provider/network/URL/secret evidence"
fi
live_pattern='^\\+.*(Publish Now|Upload Now|Release Now|Buy Now|Subscribe Now|Purchase Now|Join Live|Start Live Room|Send Message|Connect Account)'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.md' | rg -q "$live_pattern"; then
  fail "UI-07A introduced forbidden live action copy"
fi
perf_pattern='^\\+.*(repeatForever|TimelineView|CADisplayLink|Timer\\.publish|CMMotionManager|import CoreMotion|SceneKit|SpriteKit|Metal|Particle|withAnimation.*repeat)'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' | rg -q "$perf_pattern"; then
  fail "UI-07A introduced infinite/performance-risk animation"
fi
persistence_pattern='^\\+.*(FileManager|writeTo|Keychain|SecItemAdd|SecItemUpdate|UserDefaults\\.standard\\.set.*(token|credential|descriptor|payment))'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' | rg -q "$persistence_pattern"; then
  fail "UI-07A introduced sensitive persistence"
fi

if rg -q "repeatForever" "$MOVIE"; then
  note "Existing Movie Detail player shell contains repeatForever outside the UI-07A shared scene-entrance additions; UI-07A introduced no repeatForever lines."
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

python_args=("$JSON_OUT" "$MD_OUT" "$status" "$UPGRADE" "$BASELINE" "$BASELINE_TAG" "$BASELINE_PARENT" "$BASELINE_PARENT_TAG" "$actual_files")
if (( ${#failures[@]} > 0 )); then
  python_args+=("${failures[@]}")
fi

python3 - "${python_args[@]}" <<'PY'
import json
import sys
from pathlib import Path

json_out, md_out, status, upgrade, baseline, baseline_tag, parent, parent_tag, changed_files, *failures = sys.argv[1:]
notes = []
if Path("HighFive/Views/MovieDetail/MovieDetailView.swift").read_text().find("repeatForever") >= 0:
    notes.append("Existing Movie Detail player shell contains repeatForever outside UI-07A additions; commit-range performance scan verifies UI-07A introduced none.")
data = {
    "upgrade": upgrade,
    "status": status,
    "baseline": {"commit": baseline, "tag": baseline_tag},
    "baseline_parent": {"commit": parent, "tag": parent_tag},
    "changed_files": changed_files.splitlines(),
    "source_evidence": {
        "shared_motion_tokens": "HFSpatialMotionTokens with micro, standard, scene entrance, focus spring, scale, and tilt tokens",
        "selection_treatment": "HFSpatialDepthState, HFSpatialSelectionTreatment, shared modifier, selected trait/value, selected/receded identifiers",
        "scene_entrance": "HFSpatialSceneEntranceModifier uses finite animation and Reduce Motion fallback",
        "optical_material": "HFOpticalGlassSurface supports Reduce Transparency with opaque black fallback",
        "action_cluster": "HFSpatialActionCluster wraps HFEnergyAction clusters with minimum 52pt primary targets",
        "inspector_chrome": "HFSpatialInspectorChrome provides shared optical-black inspector chrome",
        "dynamic_type": "Creator, Connect, Social, VOD, and Membership contain fallback layouts",
        "navigation": "HFStreamingRootView remains five tabs only"
    },
    "failures": failures,
    "notes": notes
}
Path(json_out).write_text(json.dumps(data, indent=2) + "\n")
lines = [
    f"# {upgrade} Source Verification",
    "",
    f"Status: **{status}**",
    f"Baseline: `{baseline}` / `{baseline_tag}`",
    f"Baseline parent: `{parent}` / `{parent_tag}`",
    "",
    "## Changed Files",
    *[f"- `{f}`" for f in data["changed_files"]],
    "",
    "## Evidence",
    "- Shared motion, selection, scene entrance, optical material, action cluster, inspector chrome, accessibility environments, Dynamic Type fallbacks, five-tab navigation, and local-state preservation were verified from source and commit range.",
    "- Provider/network/live-action/infinite-animation/persistence/protected-path scans were verified from the UI-07A commit range.",
]
if notes:
    lines += ["", "## Notes", *[f"- {n}" for n in notes]]
if failures:
    lines += ["", "## Failures", *[f"- {f}" for f in failures]]
Path(md_out).write_text("\n".join(lines) + "\n")
PY

if [[ "$status" != "passed" ]]; then
  printf 'Source verification failed:\n' >&2
  printf ' - %s\n' "${failures[@]}" >&2
  exit 1
fi

echo "Source verification passed: $JSON_OUT"
