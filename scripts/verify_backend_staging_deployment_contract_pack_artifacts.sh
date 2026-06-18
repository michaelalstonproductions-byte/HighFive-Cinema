#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-64-0b-backend-staging-contract-pack-evidence"
PRIMARY_OUT="/private/tmp/highfive-phase-64-0a-backend-staging-contract-pack"
PACK_DIR="backend/staging_contract_pack"

failures=()

required_outputs=(
  "$OUT_DIR/backend_staging_contract_pack_source_verification.json"
  "$OUT_DIR/backend_staging_contract_pack_source_verification.md"
  "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.json"
  "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.md"
  "$PRIMARY_OUT/verification.json"
  "$PRIMARY_OUT/verification.md"
)

for file in "${required_outputs[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty output: $file")
done

for file in "$OUT_DIR/backend_staging_contract_pack_source_verification.json" "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.json" "$PRIMARY_OUT/verification.json"; do
  if [[ -s "$file" ]]; then
    node -e "const data = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); if (data.status !== 'pass') process.exit(1)" "$file" || failures+=("status not pass: $file")
  fi
done

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

for file in "${schema_files[@]}" "${example_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty JSON artifact: $file")
  if [[ -s "$file" ]]; then
    node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$file" || failures+=("invalid JSON artifact: $file")
  fi
done

[[ -s "$PACK_DIR/openapi/highfive-entitlement-playback.openapi.yaml" ]] || failures+=("OpenAPI file missing")
[[ -s "$PACK_DIR/handlers/entitlements.validate.handler.example.ts" ]] || failures+=("entitlement handler missing")
[[ -s "$PACK_DIR/handlers/playback.descriptor.handler.example.ts" ]] || failures+=("descriptor handler missing")

if ! rg -q --fixed-strings "<SET_IN_STAGING_SECRET_STORE>" "$PACK_DIR/env/highfive_backend_staging.env.example"; then
  failures+=("env example missing placeholder values")
fi
if ! rg -q '"xcodebuild_status": "pass"' "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.json"; then
  failures+=("xcodebuild did not pass in artifact manifest")
fi
if ! rg -q '"deployment_performed": false' "$OUT_DIR/backend_staging_contract_pack_artifact_manifest.json"; then
  failures+=("artifact manifest does not confirm no deployment")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#064.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "source_verification_checked": true,\n'
  printf '  "artifact_manifest_checked": true,\n'
  printf '  "primary_verifier_checked": true,\n'
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
} > "$OUT_DIR/backend_staging_contract_pack_artifact_verification.json"

{
  printf '# Backend Staging Contract Pack Artifact Verification\n\n'
  printf -- '- Upgrade: #064.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Source verification checked: true\n'
  printf -- '- Artifact manifest checked: true\n'
  printf -- '- #064.0A verifier checked: true\n'
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nArtifact verification passed.\n'
  fi
} > "$OUT_DIR/backend_staging_contract_pack_artifact_verification.md"

cat "$OUT_DIR/backend_staging_contract_pack_artifact_verification.md"
[[ "$status" == "pass" ]]
