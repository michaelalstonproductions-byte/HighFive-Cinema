#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/private/tmp/highfive-phase-50-0b-one-of-a-kind-ui-evidence"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/one_of_a_kind_cinematic_ui_screenshot_manifest.json"
JSON_OUT="$OUT_DIR/one_of_a_kind_cinematic_ui_screenshot_verification.json"
MD_OUT="$OUT_DIR/one_of_a_kind_cinematic_ui_screenshot_verification.md"

mkdir -p "$OUT_DIR"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if [[ ! -d "$SCREENSHOT_DIR" ]]; then
  printf 'Missing screenshot folder: %s\n' "$SCREENSHOT_DIR" >&2
  exit 1
fi

if [[ ! -s "$MANIFEST_JSON" ]]; then
  printf 'Missing screenshot manifest: %s\n' "$MANIFEST_JSON" >&2
  exit 1
fi

paths=()
while IFS= read -r path; do
  paths+=("$path")
done < <(rg -o '"/private/tmp/highfive-phase-50-0b-one-of-a-kind-ui-evidence/screenshots/[^"]+\.png"' "$MANIFEST_JSON" | tr -d '"')

omissions=()
while IFS= read -r omission; do
  omissions+=("$omission")
done < <(rg -o '"reason": "[^"]+"' "$MANIFEST_JSON" | sed 's/"reason": "//; s/"$//')

if [[ "${#paths[@]}" -eq 0 ]]; then
  printf 'No screenshot paths found in manifest: %s\n' "$MANIFEST_JSON" >&2
  exit 1
fi

screenshots=()
failures=0
for path in "${paths[@]}"; do
  if [[ -s "$path" ]]; then
    screenshots+=("$path|$(wc -c < "$path" | tr -d ' ')|pass")
  else
    screenshots+=("$path|0|fail")
    failures=$((failures + 1))
  fi
done

status="pass"
if [[ "$failures" -ne 0 ]]; then
  status="fail"
fi

{
  printf -- '{\n'
  printf -- '  "upgrade": "#050.0B",\n'
  printf -- '  "status": "%s",\n' "$status"
  printf -- '  "manifest": "%s",\n' "$(json_escape "$MANIFEST_JSON")"
  printf -- '  "screenshots": [\n'
  for i in "${!screenshots[@]}"; do
    IFS='|' read -r path bytes state <<< "${screenshots[$i]}"
    comma=","
    if [[ "$i" -eq $((${#screenshots[@]} - 1)) ]]; then
      comma=""
    fi
    printf -- '    {"path": "%s", "bytes": %s, "status": "%s"}%s\n' "$(json_escape "$path")" "$bytes" "$(json_escape "$state")" "$comma"
  done
  printf -- '  ],\n'
  printf -- '  "source_verified_omissions": [\n'
  for i in "${!omissions[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#omissions[@]} - 1)) ]]; then
      comma=""
    fi
    printf -- '    "%s"%s\n' "$(json_escape "${omissions[$i]}")" "$comma"
  done
  printf -- '  ]\n'
  printf -- '}\n'
} > "$JSON_OUT"

{
  printf -- '# One-of-a-Kind Cinematic UI Screenshot Verification\n\n'
  printf -- '- Upgrade: #050.0B\n'
  printf -- '- Status: `%s`\n' "$status"
  printf -- '- Manifest: `%s`\n\n' "$MANIFEST_JSON"
  printf -- '## Verified Screenshots\n\n'
  for entry in "${screenshots[@]}"; do
    IFS='|' read -r path bytes state <<< "$entry"
    printf -- '- `%s`: `%s` (%s bytes)\n' "$path" "$state" "$bytes"
  done
  if [[ "${#omissions[@]}" -gt 0 ]]; then
    printf -- '\n## Source-Verified Omissions\n\n'
    for omission in "${omissions[@]}"; do
      printf -- '- %s\n' "$omission"
    done
  fi
  printf -- '\nThis verifier proves screenshots are present and non-empty. It does not claim automated visual truth beyond file evidence.\n'
} > "$MD_OUT"

printf -- 'Screenshot verification: %s\nJSON: %s\nMarkdown: %s\n' "$status" "$JSON_OUT" "$MD_OUT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
