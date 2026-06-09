#!/usr/bin/env bash
set -u

OUT_DIR="/Volumes/Scratch SSD/highfive-phase-17-0d-fit-qa"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
MANIFEST_JSON="$SCREENSHOT_DIR/screen_fit_screenshot_manifest.json"
JSON_REPORT="$OUT_DIR/screen_fit_screenshot_verification.json"
MD_REPORT="$OUT_DIR/screen_fit_screenshot_verification.md"

mkdir -p "$OUT_DIR" "$SCREENSHOT_DIR" || exit 1

REQUIRED=(
  "home_iphone_17_pro.png"
  "profile_iphone_17_pro.png"
)

PREFERRED=(
  "home_iphone_small.png"
  "home_iphone_standard.png"
  "home_iphone_17_pro.png"
  "home_iphone_large.png"
  "profile_iphone_17_pro.png"
  "developer_qa_iphone_17_pro.png"
)

PRESENT=()
MISSING=()

check_png() {
  local name="$1"
  local path="$SCREENSHOT_DIR/$name"
  if [[ -f "$path" && -s "$path" && "$name" == *.png ]]; then
    PRESENT+=("$name")
    return 0
  fi
  MISSING+=("$name")
  return 1
}

FAIL_COUNT=0
if [[ ! -f "$MANIFEST_JSON" ]]; then
  MISSING+=("screen_fit_screenshot_manifest.json")
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

for name in "${REQUIRED[@]}"; do
  if ! check_png "$name"; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

for name in "${PREFERRED[@]}"; do
  if [[ ! -f "$SCREENSHOT_DIR/$name" || ! -s "$SCREENSHOT_DIR/$name" ]]; then
    case " ${MISSING[*]-} " in
      *" $name "*) ;;
      *) MISSING+=("$name") ;;
    esac
  fi
done

STATUS="passed"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  STATUS="failed"
fi

{
  printf '{\n'
  printf '  "status": "%s",\n' "$STATUS"
  printf '  "requiredFailures": %s,\n' "$FAIL_COUNT"
  printf '  "presentRequiredCount": %s,\n' "${#PRESENT[@]}"
  printf '  "missing": ['
  for index in "${!MISSING[@]}"; do
    [[ "$index" -gt 0 ]] && printf ', '
    printf '"%s"' "${MISSING[$index]}"
  done
  printf ']\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Screen Fit Screenshot Verification\n\n'
  printf 'Status: **%s**\n\n' "$STATUS"
  printf 'Required screenshots present: %s of %s\n\n' "${#PRESENT[@]}" "${#REQUIRED[@]}"
  printf '## Manual Visual Review Checklist\n\n'
  printf -- '- Header fully visible\n'
  printf -- '- Icons and notification badge not clipped\n'
  printf -- '- Hero title and buttons fit\n'
  printf -- '- Coming Soon badges readable\n'
  printf -- '- Right poster rail stays inside hero bounds\n'
  printf -- '- Bottom tab icons and labels fit\n'
  printf -- '- Profile and Developer / QA route still reachable\n\n'
  printf '## Missing / Limitations\n\n'
  if [[ "${#MISSING[@]}" -eq 0 ]]; then
    printf -- '- None\n'
  else
    for item in "${MISSING[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MD_REPORT"

printf 'Screen fit screenshot verification %s. Reports:\n%s\n%s\n' "$STATUS" "$JSON_REPORT" "$MD_REPORT"

if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
