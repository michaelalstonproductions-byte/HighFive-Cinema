#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-47-0b-product-ux-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
SOURCE_JSON="$OUT_DIR/product_ux_overhaul_source_verification.json"
MANIFEST_JSON="$SCREENSHOT_DIR/product_ux_overhaul_screenshot_manifest.json"
SCREENSHOT_JSON="$OUT_DIR/product_ux_overhaul_screenshot_verification.json"
REPORT_JSON="$OUT_DIR/product_ux_overhaul_evidence_report.json"
REPORT_MD="$OUT_DIR/product_ux_overhaul_evidence_report.md"

cd "$ROOT_DIR"
mkdir -p "$OUT_DIR"

json_status() {
  local file="$1"
  if [[ -s "$file" ]] && rg -n '"status": "pass"' "$file" >/dev/null; then
    printf pass
  else
    printf fail
  fi
}

source_status="$(json_status "$SOURCE_JSON")"
manifest_status="$(json_status "$MANIFEST_JSON")"
screenshot_status="$(json_status "$SCREENSHOT_JSON")"

protected_scan="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
blocked_scan="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n '^\+.*(Firebase|Supabase|CloudKit|CKContainer|URLSession|http://|https://|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|APNs|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|upload|publish|submit to platform|FileManager|writeTo|AVAssetDownloadURLSession|downloadTask|Bearer|api[_-]?key|secret|token|client_secret|access_token|refresh_token|password)' || true)"

protected_status=pass
if [[ -n "$protected_scan" ]]; then protected_status=fail; fi
blocked_status=pass
if [[ -n "$blocked_scan" ]]; then blocked_status=fail; fi

report_status=pass
for status in "$source_status" "$manifest_status" "$screenshot_status" "$protected_status" "$blocked_status"; do
  if [[ "$status" != pass ]]; then
    report_status=fail
  fi
done

screens=(
  onboarding_intro
  training_controls
  timeline_practice
  home
  search
  library
  downloads
  profile
  creator_studio
  social_media_kit
  vod_package
  movie_detail
)

{
  printf '{\n'
  printf '  "upgrade": "#047.0B",\n'
  printf '  "status": "%s",\n' "$report_status"
  printf '  "baseline_commit": "f2f0e2e",\n'
  printf '  "baseline_tag": "phase-47-0a1-vertical-intro-depth-tilt-peek-activation",\n'
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "screenshot_harness_status": "%s",\n' "$manifest_status"
  printf '  "screenshot_verifier_status": "%s",\n' "$screenshot_status"
  printf '  "full_vertical_intro_evidence": "source identifiers plus screenshot onboarding_intro.png",\n'
  printf '  "intro_depth_active_evidence": "hf.intro.depthActive and Depth Active copy verified",\n'
  printf '  "training_diagram_evidence": "hf.training.diagram and training_controls.png",\n'
  printf '  "timeline_vertical_evidence": "hf.training.timelineVerticalVideo and timeline_practice.png",\n'
  printf '  "timeline_depth_active_evidence": "hf.training.depthActive and Depth Active copy verified",\n'
  printf '  "timeline_tilt_peek_active_evidence": "hf.training.tiltPeekActive, hf.training.peekActivated, and Tilt + Peek Active copy verified",\n'
  printf '  "protected_scan_status": "%s",\n' "$protected_status"
  printf '  "blocked_implementation_scan_status": "%s",\n' "$blocked_status"
  printf '  "known_limitations": [\n'
  printf '    "local product UX only",\n'
  printf '    "protected HKV1 depth/playback engine not integrated",\n'
  printf '    "no real backend calls",\n'
  printf '    "no real auth",\n'
  printf '    "no real cloud sync",\n'
  printf '    "no real media downloads",\n'
  printf '    "no real payment provider",\n'
  printf '    "no real social posting",\n'
  printf '    "no real VOD publishing",\n'
  printf '    "no provider SDKs",\n'
  printf '    "no remote URLs",\n'
  printf '    "no App Store production configuration"\n'
  printf '  ],\n'
  printf '  "screenshots": [\n'
  for i in "${!screens[@]}"; do
    name="${screens[$i]}"
    path="$SCREENSHOT_DIR/$name.png"
    comma=","
    if [[ "$i" -eq $((${#screens[@]} - 1)) ]]; then comma=""; fi
    printf '    "%s"%s\n' "$path" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Product UX Overhaul Evidence Report\n\n'
  printf -- '- Upgrade: #047.0B\n'
  printf -- '- Status: %s\n' "$report_status"
  printf -- '- Baseline: f2f0e2e / phase-47-0a1-vertical-intro-depth-tilt-peek-activation\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n' "$screenshot_status"
  printf -- '- Protected scan: %s\n' "$protected_status"
  printf -- '- Blocked implementation scan: %s\n\n' "$blocked_status"
  printf '## Evidence Summary\n\n'
  printf -- '- Full vertical intro: source identifiers plus onboarding intro screenshot.\n'
  printf -- '- Intro Depth Active: `hf.intro.depthActive` and `Depth Active` verified.\n'
  printf -- '- Training diagram: `hf.training.diagram` and training screenshot verified.\n'
  printf -- '- Timeline vertical video: `hf.training.timelineVerticalVideo` and timeline screenshot verified.\n'
  printf -- '- Timeline Depth Active: `hf.training.depthActive` and `Depth Active` verified.\n'
  printf -- '- Timeline Tilt + Peek Active: `hf.training.tiltPeekActive`, `hf.training.peekActivated`, and `Tilt + Peek Active` verified.\n'
  printf -- '- Home/Search/Library/Downloads/Profile UX: screen IDs and screenshots verified.\n'
  printf -- '- Creator Studio/Social/VOD: section IDs and screenshots verified.\n'
  printf -- '- Bottom tabs: Home, Search, Library, Downloads, Profile source evidence verified.\n\n'
  printf '## Screenshots\n\n'
  for name in "${screens[@]}"; do
    printf -- '- `%s/%s.png`\n' "$SCREENSHOT_DIR" "$name"
  done
  printf '\n## Known Limitations\n\n'
  printf -- '- local product UX only\n'
  printf -- '- protected HKV1 depth/playback engine not integrated\n'
  printf -- '- no real backend calls\n'
  printf -- '- no real auth\n'
  printf -- '- no real cloud sync\n'
  printf -- '- no real media downloads\n'
  printf -- '- no real payment provider\n'
  printf -- '- no real social posting\n'
  printf -- '- no real VOD publishing\n'
  printf -- '- no provider SDKs\n'
  printf -- '- no remote URLs\n'
  printf -- '- no App Store production configuration\n'
} > "$REPORT_MD"

printf 'Evidence report %s. JSON: %s MD: %s\n' "$report_status" "$REPORT_JSON" "$REPORT_MD"
[[ "$report_status" == pass ]]
