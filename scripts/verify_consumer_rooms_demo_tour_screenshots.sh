#!/usr/bin/env bash
set -u

OUT_DIR="/Volumes/Scratch SSD/highfive-phase-17-0c-screenshots"
MANIFEST_JSON="$OUT_DIR/screenshot_manifest.json"
SOURCE_JSON="$OUT_DIR/source_verification_report.json"
JSON_REPORT="$OUT_DIR/screenshot_verification_report.json"
MD_REPORT="$OUT_DIR/screenshot_verification_report.md"

mkdir -p "$OUT_DIR" || exit 1

REQUIRED_MINIMUM=(
  "01-profile-rooms-and-tabs.png"
  "03-developer-qa-hub.png"
  "04-consumer-rooms-demo-tour-hero.png"
  "05-consumer-rooms-demo-tour-act1.png"
)

PREFERRED_FULL=(
  "00-home-launch.png"
  "01-profile-rooms-and-tabs.png"
  "02-profile-internal-developer-qa.png"
  "03-developer-qa-hub.png"
  "04-consumer-rooms-demo-tour-hero.png"
  "05-consumer-rooms-demo-tour-act1.png"
  "06-consumer-rooms-demo-tour-act2-rooms.png"
  "07-consumer-rooms-demo-tour-act3-internal-validation.png"
  "08-consumer-rooms-demo-tour-screenshot-plan.png"
  "09-consumer-rooms-demo-tour-highfive-story.png"
  "10-consumer-rooms-demo-tour-figma-source.png"
  "11-consumer-rooms-demo-tour-protected-systems.png"
)

MISSING=()
PRESENT=()

check_png() {
  local name="$1"
  local path="$OUT_DIR/$name"
  if [[ -f "$path" && -s "$path" && "$name" == *.png ]]; then
    PRESENT+=("$name")
    return 0
  fi
  MISSING+=("$name")
  return 1
}

if [[ ! -f "$MANIFEST_JSON" ]]; then
  MISSING+=("screenshot_manifest.json")
fi

FAIL_COUNT=0
for item in "${REQUIRED_MINIMUM[@]}"; do
  if ! check_png "$item"; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

SCREENSHOT_PLAN_OK=false
if [[ -f "$OUT_DIR/08-consumer-rooms-demo-tour-screenshot-plan.png" && -s "$OUT_DIR/08-consumer-rooms-demo-tour-screenshot-plan.png" ]]; then
  SCREENSHOT_PLAN_OK=true
elif [[ -f "$SOURCE_JSON" ]] && rg -q '"screenshotPlanExists": true' "$SOURCE_JSON"; then
  SCREENSHOT_PLAN_OK=true
fi

if [[ "$SCREENSHOT_PLAN_OK" != true ]]; then
  FAIL_COUNT=$((FAIL_COUNT + 1))
  MISSING+=("08-consumer-rooms-demo-tour-screenshot-plan.png or source screenshotPlanExists")
fi

for item in "${PREFERRED_FULL[@]}"; do
  if [[ ! -f "$OUT_DIR/$item" || ! -s "$OUT_DIR/$item" ]]; then
    case " ${MISSING[*]} " in
      *" $item "*) ;;
      *) MISSING+=("$item") ;;
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
  printf '  "minimumFailures": %s,\n' "$FAIL_COUNT"
  printf '  "screenshotPlanSatisfied": %s,\n' "$SCREENSHOT_PLAN_OK"
  printf '  "presentCount": %s,\n' "${#PRESENT[@]}"
  printf '  "missing": ['
  for index in "${!MISSING[@]}"; do
    [[ "$index" -gt 0 ]] && printf ', '
    printf '"%s"' "${MISSING[$index]}"
  done
  printf ']\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Consumer + Rooms Demo Tour Screenshot Verification\n\n'
  printf 'Status: **%s**\n\n' "$STATUS"
  printf 'Screenshot plan satisfied: **%s**\n\n' "$SCREENSHOT_PLAN_OK"
  printf 'Present minimum screenshots: %s\n\n' "${#PRESENT[@]}"
  printf '## Missing / Limitations\n\n'
  if [[ "${#MISSING[@]}" -eq 0 ]]; then
    printf -- '- None\n'
  else
    for item in "${MISSING[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MD_REPORT"

printf 'Screenshot verification %s. Reports:\n%s\n%s\n' "$STATUS" "$JSON_REPORT" "$MD_REPORT"

if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
