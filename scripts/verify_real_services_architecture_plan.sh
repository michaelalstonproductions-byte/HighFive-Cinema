#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-27-0a-real-services-plan"
JSON_REPORT="$OUT_DIR/real_services_architecture_plan_verification.json"
MD_REPORT="$OUT_DIR/real_services_architecture_plan_verification.md"
mkdir -p "$OUT_DIR"

DOC_DIR="docs/production_services"
REQUIRED_DOCS=(
  "$DOC_DIR/HIGHFIVE_REAL_SERVICES_ARCHITECTURE.md"
  "$DOC_DIR/HIGHFIVE_SERVICE_PROVIDER_DECISION_MATRIX.md"
  "$DOC_DIR/HIGHFIVE_PRODUCTION_DATA_MODEL_MAP.md"
  "$DOC_DIR/HIGHFIVE_API_CONTRACTS_AND_ADAPTER_PLAN.md"
  "$DOC_DIR/HIGHFIVE_SECURITY_PRIVACY_ENTITLEMENTS_CHECKLIST.md"
  "$DOC_DIR/HIGHFIVE_REAL_SERVICES_IMPLEMENTATION_ROADMAP.md"
  "$DOC_DIR/HIGHFIVE_PHASE_27A_READINESS_REPORT.md"
)

REQUIRED_TERMS=(
  "Identity / Accounts"
  "Movie Catalog"
  "Video Streaming"
  "Offline Downloads"
  "Connect Updates"
  "Launch Campaigns"
  "Export / Delivery"
  "Payments"
  "Analytics"
  "Notifications"
  "Security"
  "Privacy"
  "Service Protocol"
  "Provider Adapter"
  "No secrets"
  "No production SDKs"
  "phase-27-0b"
  "phase-28-0a"
)

failures=()
passes=()

record_pass() {
  passes+=("$1")
}

record_fail() {
  failures+=("$1")
}

for doc in "${REQUIRED_DOCS[@]}"; do
  if [[ -s "$doc" ]]; then
    record_pass "exists: $doc"
  else
    record_fail "missing or empty: $doc"
  fi
done

for term in "${REQUIRED_TERMS[@]}"; do
  if rg -Fq "$term" "$DOC_DIR" scripts/verify_real_services_architecture_plan.sh; then
    record_pass "term: $term"
  else
    record_fail "missing term: $term"
  fi
done

if git diff --name-only | rg -q '^HighFive/.*\.swift$'; then
  record_fail "app Swift source changed"
else
  record_pass "no app Swift source changed"
fi

if git diff --name-only | egrep -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset'; then
  record_fail "protected path changed"
else
  record_pass "no protected paths changed"
fi

if git diff --name-only | egrep -q 'Assets.xcassets|HighFive.xcodeproj/project.pbxproj|Info.plist|PrivacyInfo|Entitlements'; then
  record_fail "project, asset, privacy, info, or entitlement file changed"
else
  record_pass "no project/assets/settings files changed"
fi

sensitive_terms=(
  "to""ken"
  "sec""ret"
  "api""_key"
  "bear""er"
  "pass""word"
  "private"" key"
)

scan_failed=0
while IFS= read -r line; do
  lower="$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')"
  for term in "${sensitive_terms[@]}"; do
    if [[ "$lower" == *"$term"* ]]; then
      if [[ "$lower" == *"no secrets"* || "$lower" == *"no keys"* || "$lower" == *"secrets policy"* || "$lower" == *"never commit"* || "$lower" == *"do not"* || "$lower" == *"does not add"* || "$lower" == *"not approved"* || "$lower" == *"never owns"* || "$lower" == *"must not"* || "$lower" == *"reject"* || "$lower" == *"scanner"* || "$lower" == *"rotate"* || "$lower" == *"policy"* ]]; then
        continue
      fi
      scan_failed=1
      record_fail "sensitive literal in added line: ${line:0:120}"
    fi
  done
done < <(git diff -U0 -- "$DOC_DIR" scripts/verify_real_services_architecture_plan.sh | rg '^\+' || true)

if [[ "$scan_failed" -eq 0 ]]; then
  record_pass "no unapproved sensitive literals in new docs/scripts"
fi

if git diff -U0 -- "$DOC_DIR" scripts/verify_real_services_architecture_plan.sh | rg -q '^\+.*https?://'; then
  record_fail "external URL found in added docs/scripts"
else
  record_pass "no external URLs in added docs/scripts"
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#027.0A",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(printf '%s' "${passes[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(printf '%s' "${failures[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# HighFive Real Services Architecture Plan Verification\n\n'
  printf -- '- Upgrade: #027.0A\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- JSON report: %s\n\n' "$JSON_REPORT"
  printf '## Passes\n\n'
  for item in "${passes[@]}"; do
    printf -- '- %s\n' "$item"
  done
  printf '\n## Failures\n\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
  printf '\n## Scope Note\n\n'
  printf 'This verifier checks source documentation presence and safety constraints. It does not implement or verify live production services.\n'
} > "$MD_REPORT"

printf 'Real services architecture plan verification: %s\n' "$status"
printf 'JSON: %s\n' "$JSON_REPORT"
printf 'Markdown: %s\n' "$MD_REPORT"

if [[ "$status" != "pass" ]]; then
  exit 1
fi
