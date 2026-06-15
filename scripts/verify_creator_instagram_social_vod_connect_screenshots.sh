#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-52-0b-creator-instagram-social-vod-connect-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/creator_instagram_social_vod_connect_screenshot_manifest.json"
JSON_REPORT="$OUT_DIR/creator_instagram_social_vod_connect_screenshot_verification.json"
MD_REPORT="$OUT_DIR/creator_instagram_social_vod_connect_screenshot_verification.md"

REQUIRED=(
  "intro_video.png"
  "training_video.png"
  "connect.png"
  "creator_studio.png"
  "instagram_connect.png"
  "social_media_kit.png"
  "vod_package.png"
  "profile.png"
  "movie_detail.png"
)

mkdir -p "$OUT_DIR"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

RESULTS=()
FAILURES=0

record() {
  local file="$1"
  local path="$2"
  local bytes="$3"
  local status="$4"
  RESULTS+=("$file|$path|$bytes|$status")
  if [[ "$status" != "pass" ]]; then
    FAILURES=$((FAILURES + 1))
  fi
}

if [[ ! -d "$SCREENSHOT_DIR" ]]; then
  printf 'Missing screenshot folder: %s\n' "$SCREENSHOT_DIR" >&2
  exit 1
fi

if [[ ! -s "$MANIFEST_JSON" ]]; then
  printf 'Missing screenshot manifest: %s\n' "$MANIFEST_JSON" >&2
  exit 1
fi

for file in "${REQUIRED[@]}"; do
  path="$SCREENSHOT_DIR/$file"
  if [[ -s "$path" ]]; then
    bytes="$(wc -c < "$path" | tr -d ' ')"
    record "$file" "$path" "$bytes" "pass"
  else
    record "$file" "$path" "0" "fail"
  fi
done

{
  printf '{\n'
  printf '  "upgrade": "#052.0B",\n'
  printf '  "status": "%s",\n' "$([[ "$FAILURES" -eq 0 ]] && printf pass || printf fail)"
  printf '  "manifest": "%s",\n' "$(json_escape "$MANIFEST_JSON")"
  printf '  "visualTruthClaim": "file evidence only",\n'
  printf '  "screenshots": [\n'
  for i in "${!RESULTS[@]}"; do
    IFS='|' read -r file path bytes status <<< "${RESULTS[$i]}"
    if [[ "$i" -gt 0 ]]; then printf ',\n'; fi
    printf '    {"file": "%s", "path": "%s", "bytes": %s, "status": "%s"}' \
      "$(json_escape "$file")" \
      "$(json_escape "$path")" \
      "$bytes" \
      "$(json_escape "$status")"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Creator Instagram Social VOD Connect Screenshot Verification\n\n'
  printf 'Upgrade: #052.0B\n\n'
  printf 'Status: %s\n\n' "$([[ "$FAILURES" -eq 0 ]] && printf PASS || printf FAIL)"
  printf 'Manifest: `%s`\n\n' "$MANIFEST_JSON"
  printf '| File | Status | Bytes | Path |\n'
  printf '| --- | --- | ---: | --- |\n'
  for entry in "${RESULTS[@]}"; do
    IFS='|' read -r file path bytes status <<< "$entry"
    printf '| `%s` | `%s` | %s | `%s` |\n' "$file" "$status" "$bytes" "$path"
  done
  printf '\nThis verifier confirms screenshots exist and are non-empty. It does not claim automated visual truth beyond file proof.\n'
} > "$MD_REPORT"

printf 'Screenshot verification report: %s\n' "$MD_REPORT"

if [[ "$FAILURES" -ne 0 ]]; then
  exit 1
fi
