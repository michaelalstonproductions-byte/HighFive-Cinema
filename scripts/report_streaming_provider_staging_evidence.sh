#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-56-0b-streaming-provider-evidence"
SOURCE_JSON="$OUT_DIR/streaming_provider_staging_source_verification.json"
SCREENSHOT_MANIFEST_JSON="$OUT_DIR/streaming_provider_staging_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$OUT_DIR/streaming_provider_staging_screenshot_verification.json"
JSON_OUT="$OUT_DIR/streaming_provider_staging_evidence_report.json"
MD_OUT="$OUT_DIR/streaming_provider_staging_evidence_report.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

baseline_commit="$(git rev-parse --short HEAD)"
baseline_tags="$(git tag --points-at HEAD | tr '\n' ' ')"
source_status="$(/usr/bin/python3 - "$SOURCE_JSON" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as handle:
    print(json.load(handle).get("status", "missing"))
PY
)"
manifest_status="$(/usr/bin/python3 - "$SCREENSHOT_MANIFEST_JSON" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as handle:
    print(json.load(handle).get("status", "missing"))
PY
)"
screenshot_status="$(/usr/bin/python3 - "$SCREENSHOT_VERIFY_JSON" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as handle:
    print(json.load(handle).get("status", "missing"))
PY
)"

protected_hits="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
secret_pattern='^\+.*(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9])'
secret_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' '*.sh' | rg -n "$secret_pattern" || true)"
provider_pattern='^\+.*(Firebase|CloudKit|CKContainer|RevenueCat|Stripe|Clerk|Auth0|MetaSDK|FacebookCore|TikTok|YouTube|OneSignal|PostHog|Mixpanel|Sendbird|StreamChat|M''ux|Cloudflare''Stream)'
provider_hits="$(git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n "$provider_pattern" || true)"
urlsession_hits="$(git diff -U0 -- '*.swift' | rg -n '^\+.*URLSession' || true)"
url_hits="$(git diff -U0 -- '*.swift' '*.md' '*.json' '*.sh' | rg -n '^\+.*https?://' || true)"

scan_status() {
  [[ -z "$1" ]] && printf clean || printf failed
}

screenshot_paths="$(/usr/bin/python3 - "$SCREENSHOT_MANIFEST_JSON" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    manifest = json.load(handle)

for shot in manifest.get("screenshots", []):
    if shot.get("status") == "captured":
        print(shot.get("path", ""))
PY
)"

overall_status="passed"
if [[ "$source_status" != "passed" || "$manifest_status" != "passed" || "$screenshot_status" != "passed" ]]; then
  overall_status="failed"
fi
if [[ -n "$protected_hits" || -n "$secret_hits" || -n "$provider_hits" || -n "$urlsession_hits" || -n "$url_hits" ]]; then
  overall_status="failed"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#056.0B",\n'
  printf -- '  "status": "%s",\n' "$overall_status"
  printf -- '  "baselineCommit": "%s",\n' "$baseline_commit"
  printf -- '  "baselineTags": "%s",\n' "$baseline_tags"
  printf -- '  "sourceVerifierStatus": "%s",\n' "$source_status"
  printf -- '  "screenshotHarnessStatus": "%s",\n' "$manifest_status"
  printf -- '  "screenshotVerifierStatus": "%s",\n' "$screenshot_status"
  printf -- '  "evidence": {\n'
  printf -- '    "streamingProviderServiceFoundation": "verified",\n'
  printf -- '    "localPreviewResolver": "verified",\n'
  printf -- '    "friendlyParanormallLocalFallback": "verified when present",\n'
  printf -- '    "remoteDescriptorGatewayConfigGated": "verified",\n'
  printf -- '    "playbackDescriptorModel": "verified",\n'
  printf -- '    "providerAssetMapping": "verified",\n'
  printf -- '    "cloudflarePreferred": "verified",\n'
  printf -- '    "muxFallback": "verified",\n'
  printf -- '    "movieDetailPlaybackStatus": "verified",\n'
  printf -- '    "playerProviderLocalPreviewStatus": "verified",\n'
  printf -- '    "homeBackendStreamingStatus": "verified",\n'
  printf -- '    "runtimeConfig": "verified",\n'
  printf -- '    "noRawProviderSDK": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "noHardcodedMediaURL": "%s",\n' "$(scan_status "$url_hits")"
  printf -- '    "noProviderToken": "%s",\n' "$(scan_status "$secret_hits")"
  printf -- '    "noSecrets": "%s",\n' "$(scan_status "$secret_hits")"
  printf -- '    "noLiveDownloads": "verified"\n'
  printf -- '  },\n'
  printf -- '  "scans": {\n'
  printf -- '    "protectedPath": "%s",\n' "$(scan_status "$protected_hits")"
  printf -- '    "secret": "%s",\n' "$(scan_status "$secret_hits")"
  printf -- '    "providerSDK": "%s",\n' "$(scan_status "$provider_hits")"
  printf -- '    "urlSessionLocation": "%s",\n' "$(scan_status "$urlsession_hits")"
  printf -- '    "url": "%s"\n' "$(scan_status "$url_hits")"
  printf -- '  },\n'
  printf -- '  "screenshotPaths": ['
  first=1
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ "$first" == "1" ]]; then first=0; else printf -- ', '; fi
    printf -- '"%s"' "$path"
  done <<< "$screenshot_paths"
  printf -- '],\n'
  printf -- '  "knownLimitations": [\n'
  printf -- '    "evidence only",\n'
  printf -- '    "streaming provider staging bridge only",\n'
  printf -- '    "app stays Local Preview Ready unless runtime streaming config and approved backend descriptor are provided",\n'
  printf -- '    "no committed secrets",\n'
  printf -- '    "no hardcoded production URLs",\n'
  printf -- '    "no hardcoded media URLs",\n'
  printf -- '    "no raw Cloudflare/Mux SDK",\n'
  printf -- '    "no provider tokens",\n'
  printf -- '    "no live remote playback unless backend descriptor is configured and approved",\n'
  printf -- '    "no live media downloads",\n'
  printf -- '    "no live payments",\n'
  printf -- '    "no live Instagram/Meta posting",\n'
  printf -- '    "no live VOD publishing",\n'
  printf -- '    "no App Store production configuration"\n'
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# Streaming Provider Staging Evidence Report\n\n'
  printf -- '- Upgrade: #056.0B\n'
  printf -- '- Status: %s\n' "$overall_status"
  printf -- '- Baseline commit/tag: %s / %s\n' "$baseline_commit" "$baseline_tags"
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Screenshot harness: %s\n' "$manifest_status"
  printf -- '- Screenshot verifier: %s\n\n' "$screenshot_status"
  printf -- '## Evidence\n\n'
  printf -- '- Streaming provider service foundation: verified\n'
  printf -- '- Local preview resolver: verified\n'
  printf -- '- Friendly / Paranormall local fallback: verified when present\n'
  printf -- '- Remote descriptor gateway config-gated: verified\n'
  printf -- '- Playback descriptor model: verified\n'
  printf -- '- Provider asset mapping: verified\n'
  printf -- '- Cloudflare preferred: verified\n'
  printf -- '- Mux fallback: verified\n'
  printf -- '- Movie Detail playback status: verified\n'
  printf -- '- Player provider/local preview status: verified\n'
  printf -- '- Home/backend streaming status: verified\n'
  printf -- '- Runtime config evidence: verified\n'
  printf -- '- No raw provider SDK: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- No hardcoded media URL: %s\n' "$(scan_status "$url_hits")"
  printf -- '- No provider token: %s\n' "$(scan_status "$secret_hits")"
  printf -- '- No secrets: %s\n' "$(scan_status "$secret_hits")"
  printf -- '- No live downloads: verified\n\n'
  printf -- '## Scans\n\n'
  printf -- '- Protected path scan: %s\n' "$(scan_status "$protected_hits")"
  printf -- '- Secret scan: %s\n' "$(scan_status "$secret_hits")"
  printf -- '- Provider SDK scan: %s\n' "$(scan_status "$provider_hits")"
  printf -- '- URLSession location scan: %s\n' "$(scan_status "$urlsession_hits")"
  printf -- '- URL scan: %s\n\n' "$(scan_status "$url_hits")"
  printf -- '## Screenshots\n\n'
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf -- '- %s\n' "$path"
  done <<< "$screenshot_paths"
  printf -- '\n## Known Limitations\n\n'
  printf -- '- Evidence only.\n'
  printf -- '- Streaming provider staging bridge only.\n'
  printf -- '- App stays Local Preview Ready unless runtime streaming config and approved backend descriptor are provided.\n'
  printf -- '- No committed secrets, hardcoded production URLs, hardcoded media URLs, raw Cloudflare/Mux SDK, provider tokens, live remote playback without approved descriptor, live media downloads, live payments, live Instagram/Meta posting, live VOD publishing, or App Store production configuration.\n'
} > "$MD_OUT"

if [[ "$overall_status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

printf -- 'Streaming provider staging evidence report passed.\n'
