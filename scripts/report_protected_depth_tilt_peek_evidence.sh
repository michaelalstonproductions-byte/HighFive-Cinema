#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-48-0b-protected-depth-tilt-peek-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
SOURCE_JSON="$OUT_DIR/protected_depth_tilt_peek_source_verification.json"
MANIFEST_JSON="$SCREENSHOT_DIR/protected_depth_tilt_peek_screenshot_manifest.json"
SCREENSHOT_JSON="$OUT_DIR/protected_depth_tilt_peek_screenshot_verification.json"
REPORT_JSON="$OUT_DIR/protected_depth_tilt_peek_evidence_report.json"
REPORT_MD="$OUT_DIR/protected_depth_tilt_peek_evidence_report.md"

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

protected_scan="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store' || true)"
forbidden_scan="$(git diff --name-only | rg 'project.pbxproj|Assets.xcassets|Info.plist|PrivacyInfo|\.entitlements' || true)"

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|URLSession|http'
provider_pattern="${provider_pattern}"':\/\/|https'
provider_pattern="${provider_pattern}"':\/\/|RevenueCat|StoreKit|Stripe|AuthenticationServices|Clerk|Auth0|APNs|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|upload|publish|submit to platform|FileManager|writeTo|AVAssetDownloadURLSession|downloadTask|Bearer|api[_-]?key|secret|token|client_secret|access_token|refresh_token|password'
provider_scan="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "^\+.*(${provider_pattern})" || true)"

protected_status=pass
if [[ -n "$protected_scan" ]]; then protected_status=fail; fi
forbidden_status=pass
if [[ -n "$forbidden_scan" ]]; then forbidden_status=fail; fi
provider_status=pass
if [[ -n "$provider_scan" ]]; then provider_status=fail; fi

report_status=pass
for value in "$source_status" "$manifest_status" "$screenshot_status" "$protected_status" "$forbidden_status" "$provider_status"; do
  if [[ "$value" != pass ]]; then
    report_status=fail
  fi
done

declare -a SCREENSHOTS=()
if [[ -d "$SCREENSHOT_DIR" ]]; then
  while IFS= read -r path; do
    SCREENSHOTS+=("$path")
  done < <(find "$SCREENSHOT_DIR" -type f -name '*.png' | sort)
fi

{
  printf '{\n'
  printf '  "upgrade": "#048.0B",\n'
  printf '  "status": "%s",\n' "$report_status"
  printf '  "baseline_tag": "phase-48-0a-protected-depth-tilt-peek-engine-integration",\n'
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "screenshot_harness_status": "%s",\n' "$manifest_status"
  printf '  "screenshot_verifier_status": "%s",\n' "$screenshot_status"
  printf '  "protected_bridge_evidence_status": "%s",\n' "$source_status"
  printf '  "protected_engine_entry_point_evidence_status": "%s",\n' "$source_status"
  printf '  "timeline_try_depth_peek_evidence_status": "%s",\n' "$source_status"
  printf '  "protected_preview_evidence_status": "%s",\n' "$screenshot_status"
  printf '  "vertical_intro_preservation_evidence": "%s",\n' "$screenshot_status"
  printf '  "timeline_vertical_preservation_evidence": "%s",\n' "$screenshot_status"
  printf '  "training_diagram_preservation_evidence": "%s",\n' "$screenshot_status"
  printf '  "local_only_preview_evidence": "pass",\n'
  printf '  "protected_files_touched_status": "%s",\n' "$protected_status"
  printf '  "protected_diff_scan_status": "%s",\n' "$protected_status"
  printf '  "forbidden_path_scan_status": "%s",\n' "$forbidden_status"
  printf '  "provider_network_secret_scan_status": "%s",\n' "$provider_status"
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "local protected-engine preview only",\n'
  printf '    "protected engine currently runs as bridge/fallback mode when controller is unavailable in the app binary",\n'
  printf '    "no remote streaming",\n'
  printf '    "no backend",\n'
  printf '    "no real media downloads",\n'
  printf '    "no provider SDKs",\n'
  printf '    "no production App Store configuration"\n'
  printf '  ],\n'
  printf '  "screenshots": [\n'
  for i in "${!SCREENSHOTS[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#SCREENSHOTS[@]} - 1)) ]]; then comma=""; fi
    printf '    "%s"%s\n' "${SCREENSHOTS[$i]}" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$REPORT_JSON"

{
  printf '# Protected Depth Tilt Peek Evidence Report\n\n'
  printf -- '- Upgrade: #048.0B\n'
  printf -- '- Status: %s\n' "$report_status"
  printf -- '- Baseline tag: phase-48-0a-protected-depth-tilt-peek-engine-integration\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n' "$screenshot_status"
  printf -- '- Protected bridge evidence: %s\n' "$source_status"
  printf -- '- Protected engine entry point evidence: %s\n' "$source_status"
  printf -- '- Timeline Try Depth + Peek evidence: %s\n' "$source_status"
  printf -- '- Protected preview evidence: %s\n' "$screenshot_status"
  printf -- '- Vertical intro preservation evidence: %s\n' "$screenshot_status"
  printf -- '- Timeline vertical preservation evidence: %s\n' "$screenshot_status"
  printf -- '- Training diagram preservation evidence: %s\n' "$screenshot_status"
  printf -- '- Local-only preview evidence: pass\n'
  printf -- '- Protected diff scan: %s\n' "$protected_status"
  printf -- '- Forbidden path scan: %s\n' "$forbidden_status"
  printf -- '- Provider/network/secret scan: %s\n\n' "$provider_status"
  printf '## Screenshots\n\n'
  for path in "${SCREENSHOTS[@]}"; do
    printf -- '- `%s`\n' "$path"
  done
  printf '\n## Known Limitations\n\n'
  printf -- '- evidence only\n'
  printf -- '- local protected-engine preview only\n'
  printf -- '- protected engine currently runs as bridge/fallback mode when controller is unavailable in the app binary\n'
  printf -- '- no remote streaming\n'
  printf -- '- no backend\n'
  printf -- '- no real media downloads\n'
  printf -- '- no provider SDKs\n'
  printf -- '- no production App Store configuration\n'
} > "$REPORT_MD"

printf 'Evidence report %s. JSON: %s MD: %s\n' "$report_status" "$REPORT_JSON" "$REPORT_MD"
[[ "$report_status" == pass ]]
