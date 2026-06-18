#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-65-0b-staging-backend-scaffold-evidence"
PRIMARY_OUT="/private/tmp/highfive-phase-65-0a-staging-backend-scaffold"
SCAFFOLD_DIR="backend/staging_server_scaffold"
mkdir -p "$OUT_DIR"

required_files=(
  "$SCAFFOLD_DIR/README.md"
  "$SCAFFOLD_DIR/package.json"
  "$SCAFFOLD_DIR/tsconfig.json"
  "$SCAFFOLD_DIR/src/contracts.ts"
  "$SCAFFOLD_DIR/src/env.ts"
  "$SCAFFOLD_DIR/src/audit.ts"
  "$SCAFFOLD_DIR/src/errors.ts"
  "$SCAFFOLD_DIR/src/productMapping.ts"
  "$SCAFFOLD_DIR/src/entitlements/validateEntitlement.ts"
  "$SCAFFOLD_DIR/src/playback/requestPlaybackDescriptor.ts"
  "$SCAFFOLD_DIR/src/server.ts"
  "$SCAFFOLD_DIR/src/routes/entitlements.ts"
  "$SCAFFOLD_DIR/src/routes/playback.ts"
  "$SCAFFOLD_DIR/src/providers/storekitValidator.ts"
  "$SCAFFOLD_DIR/src/providers/revenueCatValidator.ts"
  "$SCAFFOLD_DIR/src/providers/cloudflareSigner.ts"
  "$SCAFFOLD_DIR/src/providers/providerInterfaces.ts"
  "$SCAFFOLD_DIR/src/mocks/mockEntitlementProvider.ts"
  "$SCAFFOLD_DIR/src/mocks/mockCloudflareSigner.ts"
  "$SCAFFOLD_DIR/test_contracts/validate_contract_examples.ts"
  "$SCAFFOLD_DIR/env/highfive_staging_server.env.example"
  "$SCAFFOLD_DIR/DEPLOYMENT_GUIDE.md"
  "$SCAFFOLD_DIR/SECURITY_MODEL.md"
  "$SCAFFOLD_DIR/ROLLBACK_GUIDE.md"
  "docs/production_services/HIGHFIVE_STAGING_BACKEND_DEPLOYMENT_SCAFFOLD.md"
)

failures=()

bash scripts/verify_staging_backend_deployment_scaffold.sh || failures+=("#065.0A verifier failed")

[[ -s "$PRIMARY_OUT/verification.json" ]] || failures+=("#065.0A verifier JSON missing")
[[ -s "$PRIMARY_OUT/verification.md" ]] || failures+=("#065.0A verifier Markdown missing")
if [[ -s "$PRIMARY_OUT/verification.json" ]] && ! rg -q '"status": "pass"' "$PRIMARY_OUT/verification.json"; then
  failures+=("#065.0A verifier did not pass")
fi

for file in "$SCAFFOLD_DIR/package.json" "$SCAFFOLD_DIR/tsconfig.json"; do
  node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$file" || failures+=("invalid JSON: $file")
done

for file in "${required_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty scaffold file: $file")
done

while IFS= read -r file; do
  [[ -s "$file" ]] || failures+=("empty TypeScript file: $file")
done < <(find "$SCAFFOLD_DIR/src" "$SCAFFOLD_DIR/test_contracts" -type f -name '*.ts' | sort)

if ! rg -q --fixed-strings "<SET_IN_STAGING_SECRET_STORE>" "$SCAFFOLD_DIR/env/highfive_staging_server.env.example"; then
  failures+=("env example missing placeholder values")
fi
if find "$SCAFFOLD_DIR" -name 'node_modules' -o -name 'package-lock.json' -o -name 'yarn.lock' -o -name 'pnpm-lock.yaml' -o -name '.env' -o -name 'dist' -o -name 'build' | rg -q .; then
  failures+=("lockfile or deployment artifact found")
fi

build_status="pending"
if TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-65-0b-staging-backend-scaffold-evidence" \
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
  printf '  "upgrade": "#065.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "primary_verifier_status": "checked",\n'
  printf '  "xcodebuild_status": "%s",\n' "$build_status"
  printf '  "package_install_performed": false,\n'
  printf '  "deployment_performed": false,\n'
  printf '  "required_files_checked": %d,\n' "${#required_files[@]}"
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
} > "$OUT_DIR/staging_backend_scaffold_artifact_manifest.json"

{
  printf '# Staging Backend Scaffold Artifact Manifest\n\n'
  printf -- '- Upgrade: #065.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- #065.0A verifier output: `%s`\n' "$PRIMARY_OUT"
  printf -- '- xcodebuild status: %s\n' "$build_status"
  printf -- '- Package install performed: false\n'
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nArtifact QA passed.\n'
  fi
} > "$OUT_DIR/staging_backend_scaffold_artifact_manifest.md"

cat "$OUT_DIR/staging_backend_scaffold_artifact_manifest.md"
[[ "$status" == "pass" ]]
