#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-65-0b-staging-backend-scaffold-evidence"
PRIMARY_OUT="/private/tmp/highfive-phase-65-0a-staging-backend-scaffold"
SCAFFOLD_DIR="backend/staging_server_scaffold"

failures=()

required_outputs=(
  "$OUT_DIR/staging_backend_scaffold_source_verification.json"
  "$OUT_DIR/staging_backend_scaffold_source_verification.md"
  "$OUT_DIR/staging_backend_scaffold_artifact_manifest.json"
  "$OUT_DIR/staging_backend_scaffold_artifact_manifest.md"
  "$PRIMARY_OUT/verification.json"
  "$PRIMARY_OUT/verification.md"
)

for file in "${required_outputs[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty output: $file")
done

for file in "$OUT_DIR/staging_backend_scaffold_source_verification.json" "$OUT_DIR/staging_backend_scaffold_artifact_manifest.json" "$PRIMARY_OUT/verification.json"; do
  if [[ -s "$file" ]]; then
    node -e "const data = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); if (data.status !== 'pass') process.exit(1)" "$file" || failures+=("status not pass: $file")
  fi
done

for file in "$SCAFFOLD_DIR/package.json" "$SCAFFOLD_DIR/tsconfig.json"; do
  [[ -s "$file" ]] || failures+=("missing JSON file: $file")
  if [[ -s "$file" ]]; then
    node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$file" || failures+=("invalid JSON file: $file")
  fi
done

if ! rg -q --fixed-strings "<SET_IN_STAGING_SECRET_STORE>" "$SCAFFOLD_DIR/env/highfive_staging_server.env.example"; then
  failures+=("env example missing placeholder values")
fi

while IFS= read -r file; do
  [[ -s "$file" ]] || failures+=("empty TypeScript source: $file")
done < <(find "$SCAFFOLD_DIR/src" "$SCAFFOLD_DIR/test_contracts" -type f -name '*.ts' | sort)

if ! rg -q '"xcodebuild_status": "pass"' "$OUT_DIR/staging_backend_scaffold_artifact_manifest.json"; then
  failures+=("xcodebuild did not pass in artifact manifest")
fi
if ! rg -q '"package_install_performed": false' "$OUT_DIR/staging_backend_scaffold_artifact_manifest.json"; then
  failures+=("artifact manifest does not confirm no package installation")
fi
if ! rg -q '"deployment_performed": false' "$OUT_DIR/staging_backend_scaffold_artifact_manifest.json"; then
  failures+=("artifact manifest does not confirm no deployment")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#065.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "source_verification_checked": true,\n'
  printf '  "artifact_manifest_checked": true,\n'
  printf '  "primary_verifier_checked": true,\n'
  printf '  "deployment_performed": false,\n'
  printf '  "package_install_performed": false,\n'
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
} > "$OUT_DIR/staging_backend_scaffold_artifact_verification.json"

{
  printf '# Staging Backend Scaffold Artifact Verification\n\n'
  printf -- '- Upgrade: #065.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Source verification checked: true\n'
  printf -- '- Artifact manifest checked: true\n'
  printf -- '- #065.0A verifier checked: true\n'
  printf -- '- Package install performed: false\n'
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nArtifact verification passed.\n'
  fi
} > "$OUT_DIR/staging_backend_scaffold_artifact_verification.md"

cat "$OUT_DIR/staging_backend_scaffold_artifact_verification.md"
[[ "$status" == "pass" ]]
