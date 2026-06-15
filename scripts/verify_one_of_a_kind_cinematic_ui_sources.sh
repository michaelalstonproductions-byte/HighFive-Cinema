#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-50-0b-one-of-a-kind-ui-evidence"
JSON_OUT="$OUT_DIR/one_of_a_kind_cinematic_ui_source_verification.json"
MD_OUT="$OUT_DIR/one_of_a_kind_cinematic_ui_source_verification.md"
BASELINE_TAG="phase-50-0a-one-of-a-kind-cinematic-ui-experience"
PREVIOUS_TAG="phase-49-0b-watch-first-product-ux-evidence-lock"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

checks=()
failures=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

add_check() {
  local id="$1"
  local status="$2"
  local detail="$3"
  checks+=("$id|$status|$detail")
  if [[ "$status" != "pass" ]]; then
    failures=$((failures + 1))
  fi
}

has_fixed() {
  local pattern="$1"
  shift
  rg -q --fixed-strings "$pattern" "$@"
}

require_group() {
  local id="$1"
  shift
  local missing=()
  for pattern in "$@"; do
    if ! has_fixed "$pattern" HighFive; then
      missing+=("$pattern")
    fi
  done
  if [[ "${#missing[@]}" -eq 0 ]]; then
    add_check "$id" "pass" "All required source proof found"
  else
    add_check "$id" "fail" "Missing: ${missing[*]}"
  fi
}

require_any() {
  local id="$1"
  shift
  local found=""
  for pattern in "$@"; do
    if has_fixed "$pattern" HighFive; then
      found="$pattern"
      break
    fi
  done
  if [[ -n "$found" ]]; then
    add_check "$id" "pass" "Found $found"
  else
    add_check "$id" "fail" "Missing one of: $*"
  fi
}

require_group "home_signature" \
  "hf.home.screen" \
  "hf.home.signatureHero" \
  "hf.home.tonightOnHighFive" \
  "hf.home.depthPeekCTA" \
  "hf.home.curatedRails" \
  "hf.home.startWatching" \
  "hf.home.savedForTonight" \
  "hf.route.watchNow" \
  "hf.route.homeToMovieDetail" \
  "Tonight on HighFive" \
  "Start the Watch" \
  "Watch Now" \
  "Try Depth" \
  "Provider-ready" \
  "Not Connected Yet" \
  "Local Mode"

require_group "movie_detail_cinematic" \
  "hf.movieDetail.signatureHero" \
  "hf.movieDetail.primaryActions" \
  "hf.movieDetail.tonightMood" \
  "hf.movieDetail.localDepthPreview" \
  "hf.route.watchNow" \
  "Local Depth Preview" \
  "Move the frame" \
  "Peek into the shot"
require_any "movie_detail_depth_entry" "hf.movieDetail.depthPreview" "hf.protectedDepth.launch"
require_any "movie_detail_tonight_mood_copy" "Tonight's mood" "Tonight’s mood"

require_group "depth_tilt_peek_signature" \
  "hf.protectedDepth.launch" \
  "hf.protectedDepth.preview" \
  "hf.protectedDepth.localOnly" \
  "Depth Active" \
  "Tilt + Peek Active" \
  "Try Depth + Peek"
require_any "depth_signature_entry" "hf.depthExperience.signatureEntry" "hf.depthExperience.localPreview"

require_group "timeline_protected_depth" \
  "hf.training.timelinePractice" \
  "hf.training.tryDepthPeek" \
  "hf.training.timelineVerticalVideo" \
  "hf.training.depthActive" \
  "hf.training.tiltPeekActive" \
  "hf.training.peekActivated" \
  "hf.protectedDepth.launch"

require_group "search_curated_discovery" \
  "hf.search.screen" \
  "hf.search.curatedDiscovery" \
  "hf.search.moodChips" \
  "hf.search.resultCards" \
  "hf.search.highfivePicks" \
  "hf.search.forTonight" \
  "hf.route.searchToMovieDetail" \
  "HighFive Picks" \
  "For Tonight"

require_group "library_watch_shelf" \
  "hf.library.screen" \
  "hf.library.watchShelf" \
  "hf.library.continueWatching" \
  "hf.library.savedForTonight" \
  "hf.library.continueStory" \
  "hf.library.backendStatus" \
  "hf.route.libraryToMovieDetail" \
  "Saved for Tonight" \
  "Continue the Story"

require_group "downloads_local_offline" \
  "hf.downloads.screen" \
  "hf.downloads.localOfflineShelf" \
  "hf.downloads.offlinePreview" \
  "hf.downloads.localOnlyBoundary" \
  "hf.downloads.backendStatus" \
  "hf.route.downloadsToMovieDetail"
require_any "downloads_offline_copy" "Local Offline Shelf" "Offline Preview"
if rg -qi "real offline playback|Download Now|Saved to device|File ready|Media file stored" HighFive/Views/DownloadsView.swift; then
  add_check "downloads_no_real_offline_playback_language" "fail" "Downloads screen contains forbidden offline/file wording"
else
  add_check "downloads_no_real_offline_playback_language" "pass" "Downloads screen avoids forbidden offline/file wording"
fi

require_group "profile_hub" \
  "hf.profile.screen" \
  "hf.profile.highfiveHub" \
  "hf.profile.creatorStudioHero" \
  "hf.profile.productMap" \
  "hf.profile.nextSteps" \
  "hf.profile.backendServices" \
  "hf.route.profileToCreatorStudio" \
  "hf.route.profileToConnect" \
  "hf.route.profileToLaunch" \
  "hf.route.profileToExport" \
  "HighFive Hub" \
  "Creator Studio"

require_group "creator_studio_workspace" \
  "hf.creatorStudio.screen" \
  "hf.creatorStudio.dashboard" \
  "hf.creatorStudio.currentProject" \
  "hf.creatorStudio.primaryAction" \
  "hf.creatorStudio.workspaceModules" \
  "hf.creatorStudio.releasePrep" \
  "hf.creatorStudio.buildTheRelease" \
  "hf.creatorStudio.prepareSocialKit" \
  "hf.creatorStudio.packageVOD" \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.vodPackage" \
  "hf.creatorStudio.localDraft" \
  "hf.creatorStudio.noLivePublishing" \
  "hf.creatorStudio.noLiveVODProvider" \
  "Build the Release" \
  "Prepare the Social Kit" \
  "Package the VOD" \
  "Local Draft" \
  "Provider-ready" \
  "Not Connected Yet"

require_group "social_media_kit" \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.prepareSocialKit" \
  "Social Media Kit" \
  "Prepare the Social Kit"

require_group "vod_package" \
  "hf.creatorStudio.vodPackage" \
  "hf.creatorStudio.packageVOD" \
  "VOD Package" \
  "Package the VOD"

require_group "bottom_tabs" \
  "Home" \
  "Search" \
  "Library" \
  "Downloads" \
  "Profile"

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|URLSession|h''ttps?:\/\/|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|APNs|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|AVAssetDownloadURLSession|downloadTask|Bearer'
if git diff -U0 "${PREVIOUS_TAG}..${BASELINE_TAG}" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "$provider_pattern" >/dev/null; then
  add_check "local_only_limitation" "fail" "Phase 50.0A diff contains provider/network implementation terms"
else
  add_check "local_only_limitation" "pass" "No backend/provider/remote systems added by the cinematic UI diff"
fi

overall="pass"
if [[ "$failures" -ne 0 ]]; then
  overall="fail"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#050.0B",\n'
  printf -- '  "baseline_tag": "%s",\n' "$BASELINE_TAG"
  printf -- '  "status": "%s",\n' "$overall"
  printf -- '  "failures": %s,\n' "$failures"
  printf -- '  "checks": [\n'
  for i in "${!checks[@]}"; do
    IFS='|' read -r id status detail <<< "${checks[$i]}"
    comma=","
    if [[ "$i" -eq $((${#checks[@]} - 1)) ]]; then
      comma=""
    fi
    printf -- '    {"id": "%s", "status": "%s", "detail": "%s"}%s\n' "$(json_escape "$id")" "$(json_escape "$status")" "$(json_escape "$detail")" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "limitations": [\n'
  printf -- '    "evidence only",\n'
  printf -- '    "local product UX only",\n'
  printf -- '    "no real backend calls",\n'
  printf -- '    "no real auth",\n'
  printf -- '    "no real cloud sync",\n'
  printf -- '    "no real media downloads",\n'
  printf -- '    "no real payment provider",\n'
  printf -- '    "no real social posting",\n'
  printf -- '    "no real VOD publishing",\n'
  printf -- '    "no provider SDKs",\n'
  printf -- '    "no remote URLs",\n'
  printf -- '    "no App Store production configuration"\n'
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# One-of-a-Kind Cinematic UI Source Verification\n\n'
  printf -- '- Upgrade: #050.0B\n'
  printf -- '- Baseline tag: `%s`\n' "$BASELINE_TAG"
  printf -- '- Status: `%s`\n' "$overall"
  printf -- '- Failures: `%s`\n\n' "$failures"
  printf -- '## Checks\n\n'
  for check in "${checks[@]}"; do
    IFS='|' read -r id status detail <<< "$check"
    printf -- '- `%s`: `%s` - %s\n' "$id" "$status" "$detail"
  done
  printf -- '\n## Local-Only Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- Local product UX only.\n'
  printf -- '- No real backend calls, auth, cloud sync, media downloads, payment provider, social posting, VOD publishing, provider SDKs, remote URLs, or App Store production configuration.\n'
} > "$MD_OUT"

printf -- 'Source verification: %s\nJSON: %s\nMarkdown: %s\n' "$overall" "$JSON_OUT" "$MD_OUT"

if [[ "$overall" != "pass" ]]; then
  exit 1
fi
