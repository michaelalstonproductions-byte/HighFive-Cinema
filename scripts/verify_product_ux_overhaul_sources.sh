#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-47-0b-product-ux-evidence"
JSON_OUT="$OUT_DIR/product_ux_overhaul_source_verification.json"
MD_OUT="$OUT_DIR/product_ux_overhaul_source_verification.md"
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
    record "$id" "pass" "Found non-empty local asset: $path."
  else
    record "$id" "fail" "Missing local asset: $path."
  fi
}

for pattern in \
  "hf.home.screen" \
  "hf.search.screen" \
  "hf.library.screen" \
  "hf.downloads.screen" \
  "hf.profile.screen" \
  "hf.creatorStudio.screen" \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.vodPackage" \
  "hf.home.backendStatus" \
  "hf.profile.backendServices" \
  "hf.creatorStudio.backendStatus" \
  "hf.library.backendStatus" \
  "hf.downloads.backendStatus" \
  "Local Mode" \
  "Backend Not Connected Yet" \
  "Provider-ready" \
  "Not Connected Yet" \
  "Local Draft" \
  "No live publishing"; do
  require_rg "ux:$pattern" "$pattern" "HighFive"
done

for pattern in \
  "hf.intro.cinematic" \
  "hf.intro.higherkey" \
  "hf.intro.highfiveCinema" \
  "hf.intro.verticalVideo" \
  "hf.intro.depthActive" \
  "hf.training.controls" \
  "hf.training.diagram" \
  "hf.training.tiltToMove" \
  "hf.training.peekToExplore" \
  "hf.training.timelinePractice" \
  "hf.training.timelineVerticalVideo" \
  "hf.training.depthActive" \
  "hf.training.tiltPeekActive" \
  "hf.training.peekActivated" \
  "Depth Active" \
  "Tilt \\+ Peek Active" \
  "Practice the Timeline" \
  "Enter HighFive"; do
  require_rg "intro_training:$pattern" "$pattern" "HighFive/Views/Onboarding/HighFiveIntroFlowView.swift"
done

for pattern in \
  "HighFiveVerticalVideoPlayer" \
  "HighFiveVerticalDepthVideoStage" \
  "AVPlayerLayer" \
  "resizeAspectFill"; do
  require_rg "video_implementation:$pattern" "$pattern" "HighFive/Views/Onboarding/HighFiveIntroFlowView.swift"
done

require_file "video_asset:Timeline1.mov" "HighFive/App/Resources/Intro/Timeline1.mov"

for tab in Home Search Library Downloads Profile; do
  require_rg "bottom_tab:$tab" "\"$tab\"" "HighFive/App/HFStreamingRootView.swift" "HighFive/Views"
done

status="pass"
if [[ "$failures" -ne 0 ]]; then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#047.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "baseline_commit": "f2f0e2e",\n'
  printf '  "baseline_tag": "phase-47-0a1-vertical-intro-depth-tilt-peek-activation",\n'
  printf '  "timeline1_asset_found": %s,\n' "$([[ -s HighFive/App/Resources/Intro/Timeline1.mov ]] && printf true || printf false)"
  printf '  "local_only": true,\n'
  printf '  "protected_engine_integrated": false,\n'
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
  printf '# Product UX Overhaul Source Verification\n\n'
  printf -- '- Upgrade: #047.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: f2f0e2e / phase-47-0a1-vertical-intro-depth-tilt-peek-activation\n'
  printf -- '- Timeline1.mov local bundled asset: %s\n' "$([[ -s HighFive/App/Resources/Intro/Timeline1.mov ]] && printf 'found' || printf 'missing')"
  printf -- '- Protected HKV1 depth/playback engine integrated: no\n'
  printf -- '- Local-only evidence: yes\n\n'
  printf '## Checks\n\n'
  for item in "${RESULTS[@]}"; do
    printf -- '- %s\n' "$item"
  done
} > "$MD_OUT"

printf 'Source verification %s. JSON: %s MD: %s\n' "$status" "$JSON_OUT" "$MD_OUT"
[[ "$status" == "pass" ]]
