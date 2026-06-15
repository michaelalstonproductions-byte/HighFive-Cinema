#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-49-0b-watch-first-ux-evidence"
JSON_OUT="$OUT_DIR/watch_first_product_ux_source_verification.json"
MD_OUT="$OUT_DIR/watch_first_product_ux_source_verification.md"
BASELINE_TAG="phase-49-0a-watch-first-product-ux-upgrade"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

checks=()
failures=0

json_escape() {
  printf -- '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
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

has_pattern() {
  local pattern="$1"
  shift
  rg -q --fixed-strings "$pattern" "$@"
}

has_regex() {
  local pattern="$1"
  shift
  rg -q "$pattern" "$@"
}

require_fixed() {
  local id="$1"
  local pattern="$2"
  shift 2
  if has_pattern "$pattern" "$@"; then
    add_check "$id" "pass" "Found $pattern"
  else
    add_check "$id" "fail" "Missing $pattern"
  fi
}

require_any_fixed() {
  local id="$1"
  local label="$2"
  shift 2
  local paths=("${@: -1}")
  local patterns=("${@:1:$#-1}")
  local found=""
  for pattern in "${patterns[@]}"; do
    if has_pattern "$pattern" "${paths[@]}"; then
      found="$pattern"
      break
    fi
  done
  if [[ -n "$found" ]]; then
    add_check "$id" "pass" "Found $found for $label"
  else
    add_check "$id" "fail" "Missing one of: ${patterns[*]}"
  fi
}

require_all_for_status() {
  local id="$1"
  shift
  local missing=()
  for pattern in "$@"; do
    if ! has_pattern "$pattern" HighFive; then
      missing+=("$pattern")
    fi
  done
  if [[ "${#missing[@]}" -eq 0 ]]; then
    add_check "$id" "pass" "All required source proof found"
  else
    add_check "$id" "fail" "Missing: ${missing[*]}"
  fi
}

require_all_for_status "home" \
  "hf.home.screen" \
  "hf.home.backendStatus" \
  "hf.route.watchNow" \
  "hf.route.homeToMovieDetail" \
  "hf.protectedDepth.launch" \
  "Watch Now" \
  "Local Mode" \
  "Not Connected Yet" \
  "Provider-ready"

require_fixed "movie_detail_depth_entry" "hf.movieDetail.depthPreview" HighFive/Views/MovieDetail HighFive/Views/Onboarding
require_all_for_status "movie_detail" \
  "hf.route.watchNow" \
  "Local preview" \
  "Local offline" \
  "Provider-ready"
if has_pattern "Try Depth + Peek" HighFive || has_pattern "Depth Preview" HighFive; then
  add_check "movie_detail_depth_copy" "pass" "Depth entry copy found"
else
  add_check "movie_detail_depth_copy" "fail" "Missing Try Depth + Peek or Depth Preview"
fi

require_all_for_status "search" \
  "hf.search.screen" \
  "hf.route.searchToMovieDetail"

require_all_for_status "library" \
  "hf.library.screen" \
  "hf.library.backendStatus" \
  "hf.route.libraryToMovieDetail"
if has_pattern "Local saved state" HighFive || has_pattern "Your Watch Shelf" HighFive || has_pattern "Watch Shelf" HighFive; then
  add_check "library_watch_shelf_language" "pass" "Library local saved/watch shelf language found"
else
  add_check "library_watch_shelf_language" "fail" "Missing local saved state or watch shelf language"
fi

require_all_for_status "downloads" \
  "hf.downloads.screen" \
  "hf.downloads.backendStatus" \
  "hf.route.downloadsToMovieDetail"
if has_pattern "Local Offline Shelf" HighFive || has_pattern "Offline Preview" HighFive; then
  add_check "downloads_offline_language" "pass" "Downloads local offline language found"
else
  add_check "downloads_offline_language" "fail" "Missing Local Offline Shelf or Offline Preview"
fi
if has_regex "Download Now|Saved to device|File ready|Real offline playback|Media file stored" HighFive/Views/DownloadsView.swift; then
  add_check "downloads_no_real_download_language" "fail" "Downloads screen contains real-download wording"
else
  add_check "downloads_no_real_download_language" "pass" "Downloads screen avoids real-download wording"
fi

require_all_for_status "profile" \
  "hf.profile.screen" \
  "hf.profile.backendServices" \
  "hf.route.profileToCreatorStudio" \
  "hf.route.profileToConnect" \
  "hf.route.profileToLaunch" \
  "hf.route.profileToExport" \
  "Creator Studio"

require_all_for_status "creator_studio" \
  "hf.creatorStudio.screen" \
  "hf.creatorStudio.dashboard" \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.socialCaptionDrafts" \
  "hf.creatorStudio.socialPlatformReadiness" \
  "hf.creatorStudio.vodPackage" \
  "hf.creatorStudio.vodChecklist" \
  "hf.creatorStudio.vodProviderStatus" \
  "hf.creatorStudio.localDraft" \
  "hf.creatorStudio.noLivePublishing" \
  "hf.creatorStudio.noLiveVODProvider" \
  "Local Draft" \
  "Provider-ready" \
  "Not Connected Yet" \
  "Social Media Kit" \
  "VOD Package"

require_all_for_status "social_media_kit" \
  "hf.creatorStudio.socialMediaKit" \
  "hf.creatorStudio.socialCaptionDrafts" \
  "hf.creatorStudio.socialPlatformReadiness" \
  "Social Media Kit"

require_all_for_status "vod_package" \
  "hf.creatorStudio.vodPackage" \
  "hf.creatorStudio.vodChecklist" \
  "hf.creatorStudio.vodProviderStatus" \
  "hf.creatorStudio.noLiveVODProvider" \
  "VOD Package"

require_all_for_status "timeline_depth_entry" \
  "hf.training.timelinePractice" \
  "hf.training.tryDepthPeek" \
  "hf.training.timelineVerticalVideo" \
  "hf.training.depthActive" \
  "hf.training.tiltPeekActive" \
  "hf.training.peekActivated" \
  "hf.protectedDepth.launch" \
  "Depth Active" \
  "Tilt + Peek Active" \
  "Try Depth + Peek"

require_all_for_status "bottom_tabs" \
  "Home" \
  "Search" \
  "Library" \
  "Downloads" \
  "Profile"

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|URLSession|h''ttps?:\/\/|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|APNs|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|AVAssetDownloadURLSession|downloadTask|Bearer'
if git diff -U0 "${BASELINE_TAG}^..${BASELINE_TAG}" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "$provider_pattern" >/dev/null; then
  add_check "local_only_limitation" "fail" "Baseline UX diff contains provider/network implementation terms"
else
  add_check "local_only_limitation" "pass" "No backend/provider/remote systems added by the watch-first UX diff"
fi

overall="pass"
if [[ "$failures" -ne 0 ]]; then
  overall="fail"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#049.0B",\n'
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
  printf -- '    "no remote URLs"\n'
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Watch-First Product UX Source Verification\n\n'
  printf -- '- Upgrade: #049.0B\n'
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
  printf -- '- No real backend calls, auth, cloud sync, media downloads, payment provider, social posting, VOD publishing, provider SDKs, or remote URLs.\n'
} > "$MD_OUT"

printf -- 'Source verification: %s\nJSON: %s\nMarkdown: %s\n' "$overall" "$JSON_OUT" "$MD_OUT"

if [[ "$overall" != "pass" ]]; then
  exit 1
fi
