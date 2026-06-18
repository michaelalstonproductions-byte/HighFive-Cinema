#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests"
SUMMARY_JSON="$OUT_DIR/contract_test_summary.json"
SUMMARY_MD="$OUT_DIR/contract_test_summary.md"
TAP_FILE="$OUT_DIR/contract_test_output.tap"
VERIFICATION_JSON="$OUT_DIR/verification.json"
VERIFICATION_MD="$OUT_DIR/verification.md"
SCAFFOLD_DIR="backend/staging_server_scaffold"
DOC_FILE="docs/production_services/HIGHFIVE_STAGING_BACKEND_LOCAL_CONTRACT_TEST_HARNESS.md"

failures=()

required_files=(
  "$SCAFFOLD_DIR/tsconfig.contract-tests.json"
  "$SCAFFOLD_DIR/test_runtime/testHelpers.mjs"
  "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/entitlementFlow.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/playbackDescriptorFlow.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/localFallback.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
  "scripts/run_staging_backend_local_contract_tests.sh"
  "scripts/verify_staging_backend_local_contract_tests.sh"
  "$DOC_FILE"
  "$TAP_FILE"
  "$SUMMARY_JSON"
  "$SUMMARY_MD"
)

for file in "${required_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty file: $file")
done

if [[ -f "$SUMMARY_JSON" ]]; then
  node - "$SUMMARY_JSON" <<'NODE' || failures+=("contract test summary did not pass required checks")
const fs = require("node:fs");
const summary = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
if (summary.status !== "pass") throw new Error("summary status is not pass");
if (summary.failed_tests !== 0) throw new Error("failed_tests is not 0");
if (summary.network_requests_performed !== false) throw new Error("network flag is not false");
if (summary.package_install_performed !== false) throw new Error("package install flag is not false");
if (summary.deployment_performed !== false) throw new Error("deployment flag is not false");
if (summary.total_tests < 37) throw new Error("expected at least 37 contract tests");
if (summary.passed_tests !== summary.total_tests) throw new Error("passed_tests must equal total_tests");
if (summary.tests_passed !== summary.total_tests) throw new Error("tests_passed must equal total_tests");
if (summary.tests_failed !== 0) throw new Error("tests_failed must be 0");
for (const field of [
  "product_mapping_status",
  "entitlement_flow_status",
  "playback_descriptor_status",
  "local_fallback_status",
  "security_behavior_status"
]) {
  if (summary[field] !== "pass") throw new Error(`${field} is not pass`);
}
NODE
fi

dependency_dir_name='node_''modules'
package_lock_name='package-lock''.json'
yarn_lock_name='yarn''.lock'
pnpm_lock_name='pnpm-lock''.yaml'
env_name='.env'
dist_name='dist'
build_name='build'

if find "$SCAFFOLD_DIR" \
  \( -name "$dependency_dir_name" -o -name "$package_lock_name" -o -name "$yarn_lock_name" -o -name "$pnpm_lock_name" -o -name "$env_name" -o -name "$dist_name" -o -name "$build_name" \) \
  | rg -q .; then
  failures+=("disallowed dependency, env, dist, or build artifact found in scaffold")
fi

if find "$SCAFFOLD_DIR" -name '*.js' -type f | rg -q .; then
  failures+=("compiled JavaScript found inside backend/staging_server_scaffold")
fi

if git diff --name-only | rg -q '^HighFive/.*\.swift$'; then
  failures+=("HighFive Swift files changed")
fi
if git diff --name-only | rg -q 'project.pbxproj'; then
  failures+=("project.pbxproj changed")
fi
if git diff --name-only | rg -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|Assets.xcassets|Info.plist|PrivacyInfo|\.entitlements'; then
  failures+=("protected app path changed")
fi

url_pattern='https?''://'
if rg -n "$url_pattern" "$SCAFFOLD_DIR/test_runtime" "$DOC_FILE" scripts/run_staging_backend_local_contract_tests.sh scripts/verify_staging_backend_local_contract_tests.sh; then
  failures+=("concrete URL found in local contract harness")
fi

key_block_pattern='-----BEGIN PRIVATE ''KEY-----'
if rg -n --fixed-strings -- "$key_block_pattern" "$SCAFFOLD_DIR/test_runtime" "$DOC_FILE"; then
  failures+=("private key block found in local contract harness")
fi

fly_pattern='fly ''deploy'
vercel_pattern='vercel --''prod'
supabase_pattern='supabase functions ''deploy'
wrangler_pattern='wrangler ''deploy'
gcloud_pattern='gcloud run ''deploy'
aws_pattern='aws .* ''deploy'
deployment_pattern="($fly_pattern|$vercel_pattern|$supabase_pattern|$wrangler_pattern|$gcloud_pattern|$aws_pattern)"
if rg -n "$deployment_pattern" "$SCAFFOLD_DIR/test_runtime" "$DOC_FILE" scripts/run_staging_backend_local_contract_tests.sh scripts/verify_staging_backend_local_contract_tests.sh; then
  failures+=("deployment command found in local contract harness")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#066.0A",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "summary_json": "%s",\n' "$SUMMARY_JSON"
  printf '  "tap_output": "%s",\n' "$TAP_FILE"
  printf '  "network_requests_performed": false,\n'
  printf '  "package_install_performed": false,\n'
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
} > "$VERIFICATION_JSON"

{
  printf '# HighFive Staging Backend Local Contract Test Verification\n\n'
  printf -- '- Upgrade: #066.0A\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Summary: `%s`\n' "$SUMMARY_JSON"
  printf -- '- TAP output: `%s`\n' "$TAP_FILE"
  printf -- '- Network requests performed: false\n'
  printf -- '- Package install performed: false\n'
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nLocal contract test harness verification passed.\n'
  fi
} > "$VERIFICATION_MD"

cat "$VERIFICATION_MD"
[[ "$status" == "pass" ]]
