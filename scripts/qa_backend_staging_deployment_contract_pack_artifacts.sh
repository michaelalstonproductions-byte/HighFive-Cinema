#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-64-0b-backend-staging-contract-pack-evidence"
PRIMARY_OUT="/private/tmp/highfive-phase-64-0a-backend-staging-contract-pack"
mkdir -p "$OUT_DIR"

PACK_DIR="backend/staging_contract_pack"

schema_files=(
  "$PACK_DIR/schemas/entitlements.validate.request.schema.json"
  "$PACK_DIR/schemas/entitlements.validate.response.schema.json"
  "$PACK_DIR/schemas/playback.descriptor.request.schema.json"
  "$PACK_DIR/schemas/playback.descriptor.response.schema.json"
)

example_files=(
  "$PACK_DIR/examples/entitlements.validate.request.example.json"
  "$PACK_DIR/examples/entitlements.validate.response.approved.example.json"
  "$PACK_DIR/examples/entitlements.validate.response.denied.example.json"
  "$PACK_DIR/examples/playback.descriptor.request.example.json"
  "$PACK_DIR/examples/playback.descriptor.response.ready.example.json"
  "$PACK_DIR/examples/playback.descriptor.response.unavailable.example.json"
)

doc_files=(
  "$PACK_DIR/README.md"
  "$PACK_DIR/openapi/highfive-entitlement-playback.openapi.yaml"
  "$PACK_DIR/handlers/entitlements.validate.handler.example.ts"
  "$PACK_DIR/handlers/playback.descriptor.handler.example.ts"
  "$PACK_DIR/env/highfive_backend_staging.env.example"
  "$PACK_DIR/DEPLOYMENT_CHECKLIST.md"
  "$PACK_DIR/SECURITY_REQUIREMENTS.md"
  "$PACK_DIR/ROLLBACK_PLAN.md"
  "docs/production_services/HIGHFIVE_BACKEND_STAGING_DEPLOYMENT_CONTRACT_PACK.md"
)

failures=()

bash scripts/verify_backend_staging_deployment_contract_pack.sh || failures+=("#064.0A verifier failed")

[[ -s "$PRIMARY_OUT/verification.json" ]] || failures+=("#064.0A verifier JSON missing")
[[ -s "$PRIMARY_OUT/verification.md" ]] || failures+=("#064.0A verifier Markdown missing")
if [[ -s "$PRIMARY_OUT/verification.json" ]] && ! rg -q '"status": "pass"' "$PRIMARY_OUT/verification.json"; then
  failures+=("#064.0A verifier did not pass")
fi

for file in "${schema_files[@]}" "${example_files[@]}"; do
  if [[ -f "$file" ]]; then
    node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$file" || failures+=("invalid json: $file")
  else
    failures+=("missing json file: $file")
  fi
done

for file in "${doc_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty artifact: $file")
done

build_status="pending"
if TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-64-0b-backend-staging-contract-pack-evidence" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build; then
  build_status="pass"
else
  build_status="fail"
  failures+=("xcodebuild failed")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#064.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "primary_verifier_status": "checked",\n'
  printf '  "xcodebuild_status": "%s",\n' "$build_status"
  printf '  "schemas_checked": %d,\n' "${#schema_files[@]}"
  printf '  "examples_checked": %d,\n' "${#example_files[@]}"
  printf '  "docs_checked": %d,\n' "${#doc_files[@]}"
  printf '  "deployment_performed": false,\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    escaped="${failures[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ "$i" == "$((${#failures[@]} - 1))" ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.json"

{
  printf '# Backend Staging Contract Pack Artifact Manifest\n\n'
  printf -- '- Upgrade: #064.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- #064.0A verifier output: `%s`\n' "$PRIMARY_OUT"
  printf -- '- xcodebuild status: %s\n' "$build_status"
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nArtifact QA passed.\n'
  fi
} > "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.md"

cat "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.md"
[[ "$status" == "pass" ]]
