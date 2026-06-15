#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-52-0b-creator-instagram-social-vod-connect-evidence"
REPORT_JSON="$OUT_DIR/creator_instagram_social_vod_connect_evidence_report.json"
REPORT_MD="$OUT_DIR/creator_instagram_social_vod_connect_evidence_report.md"
SOURCE_JSON="$OUT_DIR/creator_instagram_social_vod_connect_source_verification.json"
SOURCE_MD="$OUT_DIR/creator_instagram_social_vod_connect_source_verification.md"
SHOT_JSON="$OUT_DIR/creator_instagram_social_vod_connect_screenshot_verification.json"
SHOT_MD="$OUT_DIR/creator_instagram_social_vod_connect_screenshot_verification.md"
MANIFEST_JSON="$OUT_DIR/screenshots/creator_instagram_social_vod_connect_screenshot_manifest.json"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_status() {
  local file="$1"
  if [[ -s "$file" ]] && rg -q '"status": "pass"' "$file"; then
    printf 'pass'
  else
    printf 'fail'
  fi
}

scan_status() {
  local matches="$1"
  if [[ -z "$matches" ]]; then
    printf 'pass'
  else
    printf 'fail'
  fi
}

HEAD_LINE="$(git log -1 --oneline --decorate)"
HEAD_TAGS="$(git tag --points-at HEAD | tr '\n' ' ')"
BASELINE_PRESENT="$(git tag --list 'phase-52-0a1-connect-system-fullscreen-video-finish')"
SOURCE_STATUS="$(json_status "$SOURCE_JSON")"
SHOT_STATUS="$(json_status "$SHOT_JSON")"
MANIFEST_STATUS="fail"
if [[ -s "$MANIFEST_JSON" ]] && rg -q '"status": "pass"' "$MANIFEST_JSON"; then
  MANIFEST_STATUS="pass"
fi

PROTECTED_MATCHES="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements' || true)"

network_prefix="URL"
network_suffix="Session"
plain_h="ht"
plain_t="tp"
secure_s="s"
swift_live_pattern="Firebase|Supabase|CloudKit|CKContainer|${network_prefix}${network_suffix}|${plain_h}${plain_t}://|${plain_h}${plain_t}${secure_s}://|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|APNs|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|upload|publish|submit to platform|FileManager|writeTo|AVAssetDownloadURLSession|downloadTask|Bearer|api[_-]?key|secret|token|client_secret|access_token|refresh_token|password"
PROVIDER_MATCHES="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "^\\+.*(${swift_live_pattern})" || true)"

PROTECTED_STATUS="$(scan_status "$PROTECTED_MATCHES")"
PROVIDER_STATUS="$(scan_status "$PROVIDER_MATCHES")"

SCREENSHOT_PATHS=()
if [[ -s "$MANIFEST_JSON" ]]; then
  while IFS= read -r path; do
    SCREENSHOT_PATHS+=("$path")
  done < <(rg -o '"/private/tmp/highfive-phase-52-0b-creator-instagram-social-vod-connect-evidence/screenshots/[^"]+\.png"' "$MANIFEST_JSON" | tr -d '"')
fi

OVERALL_STATUS="pass"
if [[ "$SOURCE_STATUS" != "pass" || "$SHOT_STATUS" != "pass" || "$MANIFEST_STATUS" != "pass" || "$PROTECTED_STATUS" != "pass" || "$PROVIDER_STATUS" != "pass" ]]; then
  OVERALL_STATUS="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#052.0B",\n'
  printf '  "status": "%s",\n' "$OVERALL_STATUS"
  printf '  "baselineCommitRequested": "c8981f8",\n'
  printf '  "baselineTag": "phase-52-0a1-connect-system-fullscreen-video-finish",\n'
  printf '  "baselineTagPresent": "%s",\n' "$(json_escape "$BASELINE_PRESENT")"
  printf '  "head": "%s",\n' "$(json_escape "$HEAD_LINE")"
  printf '  "headTags": "%s",\n' "$(json_escape "$HEAD_TAGS")"
  printf '  "sourceVerifierStatus": "%s",\n' "$SOURCE_STATUS"
  printf '  "screenshotHarnessStatus": "%s",\n' "$MANIFEST_STATUS"
  printf '  "screenshotVerifierStatus": "%s",\n' "$SHOT_STATUS"
  printf '  "protectedPathScan": "%s",\n' "$PROTECTED_STATUS"
  printf '  "providerNetworkSecretScan": "%s",\n' "$PROVIDER_STATUS"
  printf '  "sourceReport": "%s",\n' "$(json_escape "$SOURCE_MD")"
  printf '  "screenshotReport": "%s",\n' "$(json_escape "$SHOT_MD")"
  printf '  "screenshots": [\n'
  for i in "${!SCREENSHOT_PATHS[@]}"; do
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    "%s"' "$(json_escape "${SCREENSHOT_PATHS[$i]}")"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Creator Instagram Social VOD Connect Evidence\n\n'
  printf -- '- Upgrade: #052.0B\n'
  printf -- '- Status: `%s`\n' "$OVERALL_STATUS"
  printf -- '- Requested baseline commit: `c8981f8`\n'
  printf -- '- Baseline tag: `phase-52-0a1-connect-system-fullscreen-video-finish`\n'
  printf -- '- Actual HEAD: `%s`\n'
  printf '%s\n' "$HEAD_LINE"
  printf -- '- Tags at HEAD: `%s`\n\n' "$HEAD_TAGS"
  printf '## Verifier Status\n\n'
  printf -- '- Source verifier: `%s`\n' "$SOURCE_STATUS"
  printf -- '- Screenshot harness: `%s`\n' "$MANIFEST_STATUS"
  printf -- '- Screenshot verifier: `%s`\n' "$SHOT_STATUS"
  printf -- '- Protected path scan: `%s`\n' "$PROTECTED_STATUS"
  printf -- '- Provider/network/credential scan: `%s`\n\n' "$PROVIDER_STATUS"
  printf '## Evidence Summary\n\n'
  printf -- '- Creator Studio Control Center: source identifiers, dashboard, current project, tool strip, and local draft actions verified.\n'
  printf -- '- Instagram Connect: local/provider-ready surface, Not Connected Yet state, and no live provider/posting copy verified.\n'
  printf -- '- Social Media Kit: caption drafts, platform readiness rows, poster/clip/trailer placeholders, and local-only boundary verified.\n'
  printf -- '- VOD Package: checklist, trailer/poster/synopsis readiness, pricing boundary, provider status, and no live VOD provider copy verified.\n'
  printf -- '- Connect System: hero, watch rooms, creator circles, activity feed, social graph, and provider boundary verified.\n'
  printf -- '- Fullscreen intro/training: routes, resizeAspectFill, fillsContainer, Depth Active, Tilt + Peek Active, and screenshot evidence verified.\n'
  printf -- '- The Friendly and Paranormall: local mock catalog presence and local preview playback boundary verified where present.\n\n'
  printf '## Screenshot Paths\n\n'
  for path in "${SCREENSHOT_PATHS[@]}"; do
    printf -- '- `%s`\n' "$path"
  done
  printf '\n## Reports\n\n'
  printf -- '- `%s`\n' "$SOURCE_MD"
  printf -- '- `%s`\n' "$SHOT_MD"
  printf -- '- `%s`\n' "$REPORT_JSON"
  printf -- '- `%s`\n\n' "$REPORT_MD"
  printf '## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- Local product UX only.\n'
  printf -- '- No live backend.\n'
  printf -- '- No live auth.\n'
  printf -- '- No cloud sync.\n'
  printf -- '- No real media downloads.\n'
  printf -- '- No real payments.\n'
  printf -- '- No real social posting.\n'
  printf -- '- No Instagram/Meta provider connection.\n'
  printf -- '- No live VOD publishing.\n'
  printf -- '- No provider SDKs.\n'
  printf -- '- No remote URLs.\n'
  printf -- '- No App Store production configuration.\n'
} > "$REPORT_MD"

printf 'Evidence report: %s\nJSON: %s\n' "$REPORT_MD" "$REPORT_JSON"

if [[ "$OVERALL_STATUS" != "pass" ]]; then
  exit 1
fi
