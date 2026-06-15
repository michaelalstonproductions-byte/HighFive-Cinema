#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-52-0b-creator-instagram-social-vod-connect-evidence"
JSON_REPORT="$OUT_DIR/creator_instagram_social_vod_connect_source_verification.json"
MD_REPORT="$OUT_DIR/creator_instagram_social_vod_connect_source_verification.md"

CREATOR_SOURCE="$ROOT_DIR/HighFive/Views/Creator/CreatorStudioView.swift"
CONNECT_SOURCE="$ROOT_DIR/HighFive/Views/Connect/ConnectHubView.swift"
ROOT_SOURCE="$ROOT_DIR/HighFive/App/HFStreamingRootView.swift"
INTRO_SOURCE="$ROOT_DIR/HighFive/Views/Onboarding/HighFiveIntroFlowView.swift"
MOVIE_DETAIL_SOURCE="$ROOT_DIR/HighFive/Views/MovieDetail/MovieDetailView.swift"
PLAYER_SOURCE="$ROOT_DIR/HighFive/Components/HFMockPlayerSheet.swift"
MOCK_DATA_SOURCE="$ROOT_DIR/HighFive/Data/HFMockData.swift"
STORE_SOURCE="$ROOT_DIR/HighFive/Data/HFStreamingStore.swift"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

RESULTS=()
FAILURES=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

record() {
  local name="$1"
  local status="$2"
  local detail="$3"
  RESULTS+=("{\"name\":\"$(json_escape "$name")\",\"status\":\"$(json_escape "$status")\",\"detail\":\"$(json_escape "$detail")\"}")
  if [[ "$status" != "pass" ]]; then
    FAILURES=$((FAILURES + 1))
  fi
}

require_file() {
  local name="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    record "$name" "pass" "$file"
  else
    record "$name" "fail" "Missing file: $file"
  fi
}

require_fixed() {
  local name="$1"
  local needle="$2"
  shift 2
  if rg -F -q -- "$needle" "$@"; then
    record "$name" "pass" "$needle"
  else
    record "$name" "fail" "Missing: $needle"
  fi
}

require_regex() {
  local name="$1"
  local pattern="$2"
  shift 2
  if rg -q -- "$pattern" "$@"; then
    record "$name" "pass" "$pattern"
  else
    record "$name" "fail" "Missing pattern: $pattern"
  fi
}

for source in \
  "$CREATOR_SOURCE" \
  "$CONNECT_SOURCE" \
  "$ROOT_SOURCE" \
  "$INTRO_SOURCE" \
  "$MOVIE_DETAIL_SOURCE" \
  "$PLAYER_SOURCE" \
  "$MOCK_DATA_SOURCE" \
  "$STORE_SOURCE"; do
  require_file "Source exists $(basename "$source")" "$source"
done

for marker in \
  "hf.creatorStudio.screen" \
  "hf.creatorStudio.dashboard" \
  "hf.creatorStudio.currentProject" \
  "hf.creatorStudio.toolControlStrip" \
  "hf.creatorStudio.projectSlate" \
  "hf.creatorStudio.assetBoard" \
  "hf.creatorStudio.captionLab" \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.instagramConnect" \
  "hf.creatorStudio.vodPackage" \
  "hf.creatorStudio.releaseChecklist" \
  "hf.creatorStudio.providerReadiness" \
  "hf.creatorStudio.primaryAction" \
  "hf.creatorStudio.buildTheRelease" \
  "hf.creatorStudio.prepareSocialKit" \
  "hf.creatorStudio.packageVOD" \
  "Creator Studio" \
  "Current Project" \
  "Tool Control Strip" \
  "Build the Release" \
  "Prepare the Social Kit" \
  "Package the VOD" \
  "Local Draft" \
  "Provider-ready" \
  "Not Connected Yet"; do
  require_fixed "Creator Studio marker $marker" "$marker" "$CREATOR_SOURCE"
done

for marker in \
  "hf.creatorStudio.instagramConnect" \
  "Instagram Connect" \
  "Instagram" \
  "Not Connected Yet" \
  "Provider-ready" \
  "Local Draft" \
  "No live provider" \
  "No live posting"; do
  require_fixed "Instagram Connect marker $marker" "$marker" "$CREATOR_SOURCE" "$CONNECT_SOURCE"
done

for marker in \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.socialCaptionDrafts" \
  "hf.creatorStudio.socialPlatformReadiness" \
  "Social Media Kit" \
  "Caption Drafts" \
  "Instagram" \
  "TikTok" \
  "YouTube Shorts" \
  "X / Threads" \
  "Poster" \
  "Clip" \
  "Trailer" \
  "Local Draft" \
  "Provider-ready" \
  "Not Connected Yet" \
  "No live publishing"; do
  require_fixed "Social Media Kit marker $marker" "$marker" "$CREATOR_SOURCE"
done

for marker in \
  "hf.creatorStudio.vodPackage" \
  "hf.creatorStudio.vodChecklist" \
  "hf.creatorStudio.vodProviderStatus" \
  "hf.creatorStudio.noLiveVODProvider" \
  "VOD Package" \
  "Trailer readiness" \
  "Poster readiness" \
  "Synopsis readiness" \
  "Pricing / entitlement boundary" \
  "Distribution provider" \
  "Storefront provider" \
  "No live VOD provider" \
  "Local Draft" \
  "Provider-ready" \
  "Not Connected Yet"; do
  require_fixed "VOD Package marker $marker" "$marker" "$CREATOR_SOURCE"
done

for marker in \
  "hf.connect.system" \
  "hf.connect.hero" \
  "hf.connect.watchRooms" \
  "hf.connect.creatorCircles" \
  "hf.connect.activityFeed" \
  "hf.connect.socialGraph" \
  "hf.connect.providerBoundary" \
  "hf.connect.notConnectedYet" \
  "Connect System" \
  "Watch Rooms" \
  "Creator Circles" \
  "Activity Feed" \
  "Social Graph" \
  "Provider-ready" \
  "Not Connected Yet" \
  "No live provider"; do
  require_fixed "Connect System marker $marker" "$marker" "$CONNECT_SOURCE"
done

for marker in \
  "--hf-start-intro-video" \
  "hf.intro.verticalVideo" \
  "hf.training.timelineVerticalVideo" \
  "resizeAspectFill" \
  "fillsContainer" \
  "Depth Active" \
  "Tilt + Peek Active"; do
  require_fixed "Fullscreen video marker $marker" "$marker" "$INTRO_SOURCE" "$ROOT_SOURCE"
done

for marker in \
  "--hf-start-creator-studio" \
  "--hf-start-instagram-connect" \
  "--hf-start-social-media-kit" \
  "--hf-start-vod-package" \
  "--hf-start-connect" \
  "--hf-start-intro-video" \
  "--hf-start-timeline-practice"; do
  require_fixed "Route marker $marker" "$marker" "$ROOT_SOURCE" "$INTRO_SOURCE"
done

for marker in \
  "The Friendly" \
  "Paranormall"; do
  require_fixed "Local title present $marker" "$marker" "$MOCK_DATA_SOURCE" "$STORE_SOURCE" "$CONNECT_SOURCE"
done

for marker in \
  "hf.player.surface" \
  "hf.player.cinematicFrame" \
  "hf.player.localPreview" \
  "Local Preview" \
  "No streaming provider connected"; do
  require_fixed "Local preview playback marker $marker" "$marker" "$MOVIE_DETAIL_SOURCE" "$PLAYER_SOURCE" "$STORE_SOURCE"
done

if [[ -n "$(git diff --name-only -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json')" ]]; then
  record "Evidence-only app source diff" "fail" "App or config source files are dirty"
else
  record "Evidence-only app source diff" "pass" "No app or config source diff"
fi

if git diff --name-only | rg -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements'; then
  record "Protected path scan" "fail" "$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements' | tr '\n' ' ')"
else
  record "Protected path scan" "pass" "No protected path diff"
fi

require_regex "Bottom tabs include Home Search Library Downloads Profile" 'Home|Search|Library|Downloads|Profile' "$ROOT_SOURCE"

{
  printf '{\n'
  printf '  "upgrade": "#052.0B",\n'
  printf '  "baselineTag": "phase-52-0a1-connect-system-fullscreen-video-finish",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "checks": [\n'
  for i in "${!RESULTS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    %s' "${RESULTS[$i]}"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Creator Instagram Social VOD Connect Source Verification\n\n'
  printf 'Upgrade: #052.0B\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  for row in "${RESULTS[@]}"; do
    name="$(printf '%s' "$row" | sed -E 's/^\{"name":"([^"]+)".*/\1/')"
    status="$(printf '%s' "$row" | sed -E 's/.*"status":"([^"]+)".*/\1/')"
    detail="$(printf '%s' "$row" | sed -E 's/.*"detail":"([^"]*)"\}$/\1/')"
    printf -- '- %s: %s - %s\n' "$status" "$name" "$detail"
  done
  printf '\nReports:\n- %s\n- %s\n' "$JSON_REPORT" "$MD_REPORT"
} > "$MD_REPORT"

printf 'Source verification report: %s\n' "$MD_REPORT"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
