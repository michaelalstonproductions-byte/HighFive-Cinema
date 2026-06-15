#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-48-0b-protected-depth-tilt-peek-evidence"
JSON_OUT="$OUT_DIR/protected_depth_tilt_peek_source_verification.json"
MD_OUT="$OUT_DIR/protected_depth_tilt_peek_source_verification.md"
mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

declare -a RESULTS=()
failures=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record() {
  local id="$1"
  local status="$2"
  local detail="$3"
  RESULTS+=("{\"id\":\"$(json_escape "$id")\",\"status\":\"$(json_escape "$status")\",\"detail\":\"$(json_escape "$detail")\"}")
  if [[ "$status" != "pass" ]]; then
    failures=$((failures + 1))
  fi
}

require_rg() {
  local id="$1"
  local pattern="$2"
  shift 2
  local paths=("$@")
  if [[ "${#paths[@]}" -eq 0 ]]; then
    paths=("HighFive")
  fi

  if rg -n "$pattern" "${paths[@]}" >/dev/null; then
    record "$id" "pass" "Found $pattern in ${paths[*]}."
  else
    record "$id" "fail" "Missing $pattern in ${paths[*]}."
  fi
}

require_file() {
  local id="$1"
  local path="$2"
  if [[ -s "$path" ]]; then
    record "$id" "pass" "Found non-empty file $path."
  else
    record "$id" "fail" "Missing file $path."
  fi
}

bridge_file="HighFive/Views/Onboarding/HighFiveIntroFlowView.swift"

for pattern in \
  "HighFiveProtectedSpatialPeekBridge" \
  "HKV1_SpatialPeekViewController" \
  "hf.protectedDepth.bridge" \
  "hf.protectedDepth.available" \
  "hf.protectedDepth.launch" \
  "hf.protectedDepth.preview" \
  "hf.protectedDepth.localOnly" \
  "Protected Depth Preview" \
  "Local engine preview"; do
  require_rg "protected_bridge:$pattern" "$pattern" "$bridge_file" "HighFive/App/HFStreamingRootView.swift"
done

if rg -n "HKV1_PlaybackController|HKV1_DepthPreviewEngine|HKV1_ProMotionCoordinator" HighFive/App HighFive/Views >/dev/null; then
  record "protected_engine:entry_points" "pass" "Found at least one protected engine entry point."
else
  record "protected_engine:entry_points" "fail" "Missing protected engine entry point references."
fi

for pattern in \
  "hf.training.tryDepthPeek" \
  "hf.training.protectedEngineReady" \
  "Try Depth \\+ Peek" \
  "Depth engine ready" \
  "Tilt \\+ Peek engine ready"; do
  require_rg "timeline_entry:$pattern" "$pattern" "$bridge_file"
done

for pattern in \
  "hf.intro.verticalVideo" \
  "hf.intro.depthActive" \
  "hf.training.timelineVerticalVideo" \
  "hf.training.depthActive" \
  "hf.training.tiltPeekActive" \
  "hf.training.peekActivated" \
  "Depth Active" \
  "Tilt \\+ Peek Active" \
  "AVPlayerLayer" \
  "resizeAspectFill"; do
  require_rg "vertical_preservation:$pattern" "$pattern" "$bridge_file"
done
require_file "vertical_preservation:Timeline1.mov" "HighFive/App/Resources/Intro/Timeline1.mov"

for pattern in \
  "hf.training.diagram" \
  "hf.training.tiltToMove" \
  "hf.training.peekToExplore" \
  "Tilt to move" \
  "Peek to explore" \
  "Shift your view" \
  "Reveal what's around you"; do
  require_rg "training_diagram:$pattern" "$pattern" "$bridge_file"
done

if rg -n "Protected engine bridge not available yet|Local engine preview" "$bridge_file" >/dev/null; then
  record "local_only:honest_preview" "pass" "Bridge reports local preview/fallback honestly."
else
  record "local_only:honest_preview" "fail" "Missing honest local protected preview state."
fi

protected_48a_diff="$(git diff --name-only phase-47-0b-product-ux-overhaul-evidence-lock phase-48-0a-protected-depth-tilt-peek-engine-integration | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store' || true)"
if [[ -z "$protected_48a_diff" ]]; then
  record "protected_files_touched_48a" "pass" "No protected files were changed in #048.0A."
else
  record "protected_files_touched_48a" "fail" "Protected files changed in #048.0A: $protected_48a_diff"
fi

if rg -n "Firebase|Supabase|CloudKit|CKContainer|URLSession|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat" "$bridge_file" HighFive/App/HFStreamingRootView.swift >/dev/null; then
  record "local_only:no_provider_claims" "fail" "Found provider/backend/network symbols in #048.0A touched files."
else
  record "local_only:no_provider_claims" "pass" "No provider/backend/network symbols found in #048.0A touched files."
fi

status="pass"
if [[ "$failures" -ne 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#048.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "baseline_tag": "phase-48-0a-protected-depth-tilt-peek-engine-integration",\n'
  printf '  "protected_bridge_present": %s,\n' "$(rg -q "HighFiveProtectedSpatialPeekBridge" "$bridge_file" && printf true || printf false)"
  printf '  "protected_engine_entry_point_found": %s,\n' "$(rg -q "HKV1_SpatialPeekViewController" HighFive/App HighFive/Views && printf true || printf false)"
  printf '  "timeline_try_depth_peek_present": %s,\n' "$(rg -q "hf.training.tryDepthPeek" "$bridge_file" && printf true || printf false)"
  printf '  "vertical_intro_preserved": %s,\n' "$(rg -q "hf.intro.verticalVideo" "$bridge_file" && printf true || printf false)"
  printf '  "timeline_vertical_preserved": %s,\n' "$(rg -q "hf.training.timelineVerticalVideo" "$bridge_file" && printf true || printf false)"
  printf '  "protected_preview_mode": "local bridge with honest fallback when protected controller is unavailable in the app binary",\n'
  printf '  "no_real_backend_provider_remote_claims": true,\n'
  printf '  "results": [\n'
  for i in "${!RESULTS[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#RESULTS[@]} - 1)) ]]; then comma=""; fi
    printf '    %s%s\n' "${RESULTS[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Protected Depth Tilt Peek Source Verification\n\n'
  printf -- '- Upgrade: #048.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline tag: phase-48-0a-protected-depth-tilt-peek-engine-integration\n'
  printf -- '- Protected preview mode: local bridge with honest fallback when the protected controller is unavailable in the app binary\n'
  printf -- '- Protected files touched in #048.0A: %s\n' "$([[ -z "$protected_48a_diff" ]] && printf 'none' || printf '%s' "$protected_48a_diff")"
  printf -- '- Local-only evidence: no backend, provider SDK, remote streaming, or real media downloads claimed\n\n'
  printf '## Checks\n\n'
  for item in "${RESULTS[@]}"; do
    printf -- '- %s\n' "$item"
  done
} > "$MD_OUT"

printf 'Source verification %s. JSON: %s MD: %s\n' "$status" "$JSON_OUT" "$MD_OUT"
[[ "$status" == "pass" ]]
