#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-50-0b-one-of-a-kind-ui-evidence"
SOURCE_JSON="$OUT_DIR/one_of_a_kind_cinematic_ui_source_verification.json"
MANIFEST_JSON="$OUT_DIR/screenshots/one_of_a_kind_cinematic_ui_screenshot_manifest.json"
SCREENSHOT_JSON="$OUT_DIR/one_of_a_kind_cinematic_ui_screenshot_verification.json"
JSON_OUT="$OUT_DIR/one_of_a_kind_cinematic_ui_evidence_report.json"
MD_OUT="$OUT_DIR/one_of_a_kind_cinematic_ui_evidence_report.md"
BASELINE_COMMIT="8a4cabc"
BASELINE_TAG="phase-50-0a-one-of-a-kind-cinematic-ui-experience"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_status() {
  local file="$1"
  if [[ -s "$file" ]] && rg -q '"status": "pass"|"status":"pass"' "$file"; then
    printf 'pass'
  else
    printf 'fail'
  fi
}

check_status() {
  local id="$1"
  local file="$2"
  if [[ -s "$file" ]] && rg -q "\"id\": \"$id\", \"status\": \"pass\"" "$file"; then
    printf 'pass'
  else
    printf 'fail'
  fi
}

source_status="$(json_status "$SOURCE_JSON")"
manifest_status="$(json_status "$MANIFEST_JSON")"
screenshot_status="$(json_status "$SCREENSHOT_JSON")"
report_status="pass"
if [[ "$source_status" != "pass" || "$manifest_status" != "pass" || "$screenshot_status" != "pass" ]]; then
  report_status="fail"
fi

protected_scan_status="pass"
if git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' >/dev/null; then
  protected_scan_status="fail"
fi

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|URLSession|h''ttps?:\/\/|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|APNs|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|AVAssetDownloadURLSession|downloadTask|Bearer'
provider_scan_status="pass"
if git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "$provider_pattern" >/dev/null; then
  provider_scan_status="fail"
fi

screenshot_paths=()
while IFS= read -r path; do
  screenshot_paths+=("$path")
done < <(rg -o '/private/tmp/highfive-phase-50-0b-one-of-a-kind-ui-evidence/screenshots/[^"]+\.png' "$MANIFEST_JSON" 2>/dev/null || true)

home_status="$(check_status home_signature "$SOURCE_JSON")"
movie_detail_status="$(check_status movie_detail_cinematic "$SOURCE_JSON")"
depth_status="$(check_status depth_tilt_peek_signature "$SOURCE_JSON")"
search_status="$(check_status search_curated_discovery "$SOURCE_JSON")"
library_status="$(check_status library_watch_shelf "$SOURCE_JSON")"
downloads_status="$(check_status downloads_local_offline "$SOURCE_JSON")"
profile_status="$(check_status profile_hub "$SOURCE_JSON")"
creator_status="$(check_status creator_studio_workspace "$SOURCE_JSON")"
social_status="$(check_status social_media_kit "$SOURCE_JSON")"
vod_status="$(check_status vod_package "$SOURCE_JSON")"
timeline_status="$(check_status timeline_protected_depth "$SOURCE_JSON")"
bottom_tabs_status="$(check_status bottom_tabs "$SOURCE_JSON")"
local_only_status="$(check_status local_only_limitation "$SOURCE_JSON")"

{
  printf -- '{\n'
  printf -- '  "upgrade": "#050.0B",\n'
  printf -- '  "baseline_commit": "%s",\n' "$BASELINE_COMMIT"
  printf -- '  "baseline_tag": "%s",\n' "$BASELINE_TAG"
  printf -- '  "status": "%s",\n' "$report_status"
  printf -- '  "source_verifier_status": "%s",\n' "$source_status"
  printf -- '  "screenshot_harness_status": "%s",\n' "$manifest_status"
  printf -- '  "screenshot_verifier_status": "%s",\n' "$screenshot_status"
  printf -- '  "home_signature_evidence_status": "%s",\n' "$home_status"
  printf -- '  "movie_detail_cinematic_evidence_status": "%s",\n' "$movie_detail_status"
  printf -- '  "depth_tilt_peek_signature_entry_evidence_status": "%s",\n' "$depth_status"
  printf -- '  "search_curated_discovery_evidence_status": "%s",\n' "$search_status"
  printf -- '  "library_watch_shelf_evidence_status": "%s",\n' "$library_status"
  printf -- '  "downloads_local_offline_evidence_status": "%s",\n' "$downloads_status"
  printf -- '  "profile_hub_evidence_status": "%s",\n' "$profile_status"
  printf -- '  "creator_studio_workspace_evidence_status": "%s",\n' "$creator_status"
  printf -- '  "social_media_kit_evidence_status": "%s",\n' "$social_status"
  printf -- '  "vod_package_evidence_status": "%s",\n' "$vod_status"
  printf -- '  "timeline_protected_depth_preservation_status": "%s",\n' "$timeline_status"
  printf -- '  "bottom_tabs_status": "%s",\n' "$bottom_tabs_status"
  printf -- '  "local_only_limitation_status": "%s",\n' "$local_only_status"
  printf -- '  "protected_path_scan_status": "%s",\n' "$protected_scan_status"
  printf -- '  "provider_network_secret_scan_status": "%s",\n' "$provider_scan_status"
  printf -- '  "screenshots": [\n'
  for i in "${!screenshot_paths[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#screenshot_paths[@]} - 1)) ]]; then
      comma=""
    fi
    printf -- '    "%s"%s\n' "$(json_escape "${screenshot_paths[$i]}")" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "known_limitations": [\n'
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
  printf -- '# One-of-a-Kind Cinematic UI Evidence Report\n\n'
  printf -- '- Upgrade: #050.0B\n'
  printf -- '- Baseline commit: `%s`\n' "$BASELINE_COMMIT"
  printf -- '- Baseline tag: `%s`\n' "$BASELINE_TAG"
  printf -- '- Status: `%s`\n\n' "$report_status"
  printf -- '## Evidence Status\n\n'
  printf -- '- Source verifier: `%s`\n' "$source_status"
  printf -- '- Screenshot harness: `%s`\n' "$manifest_status"
  printf -- '- Screenshot verifier: `%s`\n' "$screenshot_status"
  printf -- '- Home signature: `%s`\n' "$home_status"
  printf -- '- Movie Detail cinematic: `%s`\n' "$movie_detail_status"
  printf -- '- Depth/Tilt/Peek signature entry: `%s`\n' "$depth_status"
  printf -- '- Search curated discovery: `%s`\n' "$search_status"
  printf -- '- Library watch shelf: `%s`\n' "$library_status"
  printf -- '- Downloads local offline: `%s`\n' "$downloads_status"
  printf -- '- Profile hub: `%s`\n' "$profile_status"
  printf -- '- Creator Studio workspace: `%s`\n' "$creator_status"
  printf -- '- Social Media Kit: `%s`\n' "$social_status"
  printf -- '- VOD Package: `%s`\n' "$vod_status"
  printf -- '- Timeline / Protected Depth preservation: `%s`\n' "$timeline_status"
  printf -- '- Bottom tabs: `%s`\n' "$bottom_tabs_status"
  printf -- '- Local-only limitation: `%s`\n' "$local_only_status"
  printf -- '- Protected path scan: `%s`\n' "$protected_scan_status"
  printf -- '- Provider/network/secret scan: `%s`\n\n' "$provider_scan_status"
  printf -- '## Screenshot Paths\n\n'
  for path in "${screenshot_paths[@]}"; do
    printf -- '- `%s`\n' "$path"
  done
  printf -- '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- Local product UX only.\n'
  printf -- '- No real backend calls, auth, cloud sync, media downloads, payment provider, social posting, VOD publishing, provider SDKs, remote URLs, or App Store production configuration.\n'
} > "$MD_OUT"

printf -- 'Evidence report: %s\nJSON: %s\nMarkdown: %s\n' "$report_status" "$JSON_OUT" "$MD_OUT"

if [[ "$report_status" != "pass" || "$protected_scan_status" != "pass" || "$provider_scan_status" != "pass" ]]; then
  exit 1
fi
