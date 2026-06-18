#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence"
mkdir -p "$OUT_DIR"

SOURCE_JSON="$OUT_DIR/staging_backend_contract_test_harness_source_verification.json"
SOURCE_MD="$OUT_DIR/staging_backend_contract_test_harness_source_verification.md"
SCAFFOLD_DIR="backend/staging_server_scaffold"
DOC_FILE="docs/production_services/HIGHFIVE_STAGING_BACKEND_LOCAL_CONTRACT_TEST_HARNESS.md"
RUNNER="scripts/run_staging_backend_local_contract_tests.sh"
VERIFIER="scripts/verify_staging_backend_local_contract_tests.sh"

failures=()

required_harness_files=(
  "$SCAFFOLD_DIR/tsconfig.contract-tests.json"
  "$SCAFFOLD_DIR/test_runtime/testHelpers.mjs"
  "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/entitlementFlow.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/playbackDescriptorFlow.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/localFallback.test.mjs"
  "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
  "$RUNNER"
  "$VERIFIER"
  "$DOC_FILE"
)

production_modules=(
  "$SCAFFOLD_DIR/src/contracts.ts"
  "$SCAFFOLD_DIR/src/productMapping.ts"
  "$SCAFFOLD_DIR/src/audit.ts"
  "$SCAFFOLD_DIR/src/errors.ts"
  "$SCAFFOLD_DIR/src/entitlements/validateEntitlement.ts"
  "$SCAFFOLD_DIR/src/playback/requestPlaybackDescriptor.ts"
  "$SCAFFOLD_DIR/src/providers/providerInterfaces.ts"
  "$SCAFFOLD_DIR/src/providers/revenueCatValidator.ts"
  "$SCAFFOLD_DIR/src/mocks/mockEntitlementProvider.ts"
  "$SCAFFOLD_DIR/src/mocks/mockCloudflareSigner.ts"
)

for file in "${required_harness_files[@]}" "${production_modules[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty file: $file")
done

for json_file in "$SCAFFOLD_DIR/tsconfig.contract-tests.json" "$SCAFFOLD_DIR/package.json" "$SCAFFOLD_DIR/tsconfig.json"; do
  if [[ -s "$json_file" ]]; then
    node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$json_file" || failures+=("invalid JSON: $json_file")
  else
    failures+=("missing JSON file: $json_file")
  fi
done

require_term() {
  local term="$1"
  shift
  if ! rg -q --fixed-strings -- "$term" "$@"; then
    failures+=("missing required term: $term")
  fi
}

require_regex() {
  local pattern="$1"
  shift
  if ! rg -q "$pattern" "$@"; then
    failures+=("missing required pattern: $pattern")
  fi
}

require_term "command -v tsc" "$RUNNER"
require_term "tsc -p" "$RUNNER"
require_term "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/compiled" "$RUNNER" "$SCAFFOLD_DIR/tsconfig.contract-tests.json"
require_term "--test-reporter=tap" "$RUNNER"
require_term "node:test" "$SCAFFOLD_DIR/test_runtime"
require_term "node:assert/strict" "$SCAFFOLD_DIR/test_runtime"
require_term "compiledModule(" "$SCAFFOLD_DIR/test_runtime"
require_term "repository-local Node dependency directory" "$DOC_FILE"

if find "$SCAFFOLD_DIR" -name '*.js' -type f | rg -q .; then
  failures+=("compiled JavaScript found beneath backend/staging_server_scaffold")
fi

dependency_dir_name='node_''modules'
package_lock_name='package-lock''.json'
yarn_lock_name='yarn''.lock'
pnpm_lock_name='pnpm-lock''.yaml'
env_file_name='.env'
dist_name='dist'
build_name='build'
if find "$SCAFFOLD_DIR" \
  \( -name "$dependency_dir_name" -o -name "$package_lock_name" -o -name "$yarn_lock_name" -o -name "$pnpm_lock_name" -o -name "$env_file_name" -o -name "$dist_name" -o -name "$build_name" \) \
  | rg -q .; then
  failures+=("dependency, env, dist, or build artifact found in scaffold")
fi

install_pattern='(npm install|yarn install|pnpm install|npx )'
if rg -n "$install_pattern" "$SCAFFOLD_DIR/test_runtime" "$RUNNER" "$VERIFIER" "$DOC_FILE"; then
  failures+=("package install command found")
fi

fly_pattern='fly ''deploy'
vercel_pattern='vercel --''prod'
supabase_pattern='supabase functions ''deploy'
wrangler_pattern='wrangler ''deploy'
gcloud_pattern='gcloud run ''deploy'
aws_pattern='aws .* ''deploy'
deploy_pattern="($fly_pattern|$vercel_pattern|$supabase_pattern|$wrangler_pattern|$gcloud_pattern|$aws_pattern)"
if rg -n "$deploy_pattern" "$SCAFFOLD_DIR/test_runtime" "$RUNNER" "$VERIFIER" "$DOC_FILE"; then
  failures+=("deployment command found")
fi

fetch_pattern='fet''ch\('
http_request_pattern='http\.request'
https_request_pattern='https\.request'
ax_pattern='ax''ios'
un_pattern='un''dici'
xhr_pattern='XML''HttpRequest'
ws_pattern='Web''Socket\('
net_pattern='net\.connect'
tls_pattern='tls\.connect'
network_pattern="($fetch_pattern|$http_request_pattern|$https_request_pattern|$ax_pattern|$un_pattern|$xhr_pattern|$ws_pattern|$net_pattern|$tls_pattern)"
if rg -n "$network_pattern" "$SCAFFOLD_DIR/test_runtime" "$RUNNER" "$VERIFIER"; then
  failures+=("network-call syntax found in harness files")
fi

url_pattern='https?''://'
if rg -n "$url_pattern" "$SCAFFOLD_DIR/test_runtime" "$RUNNER" "$VERIFIER" "$DOC_FILE"; then
  failures+=("concrete URL found")
fi

key_pattern='-----BEGIN PRIVATE ''KEY-----'
if rg -n --fixed-strings -- "$key_pattern" "$SCAFFOLD_DIR/test_runtime" "$RUNNER" "$VERIFIER" "$DOC_FILE"; then
  failures+=("private key marker found")
fi

secret_pattern='(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9]|Authori''zation:\s*Bear''er|api[_-]?''key\s*[:=]|sec''ret\s*[:=][^<]|tok''en\s*[:=][^<]|service_''role)'
if rg -n "$secret_pattern" "$SCAFFOLD_DIR/test_runtime" "$RUNNER" "$VERIFIER" "$DOC_FILE"; then
  failures+=("secret-like value found")
fi

require_term "friendly" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs" "$SCAFFOLD_DIR/src/productMapping.ts"
require_term "com.highfive.movie.thefriendly" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs" "$SCAFFOLD_DIR/src/productMapping.ts"
require_term "paranormall-s1" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs" "$SCAFFOLD_DIR/src/productMapping.ts"
require_term "com.highfive.series.paranormall.season1" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs" "$SCAFFOLD_DIR/src/productMapping.ts"
for episode in 1 2 3 4 5 6 7; do
  require_term "paranormall_s1_e$episode" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs" "$SCAFFOLD_DIR/src/productMapping.ts"
  require_term "com.highfive.episode.paranormall.e$episode" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs" "$SCAFFOLD_DIR/src/productMapping.ts"
done
require_term "unknown movie rejection" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs"
require_term "movie/product mismatch rejection" "$SCAFFOLD_DIR/test_runtime/productMapping.test.mjs"

require_term "entitlement_approved" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "entitlement_denied" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "entitlement_pending" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "mismatch denied before provider approval" "$SCAFFOLD_DIR/test_runtime/entitlementFlow.test.mjs"
require_term "audit ID produced" "$SCAFFOLD_DIR/test_runtime/entitlementFlow.test.mjs"
require_term "app-provided entitlement state is not trusted" "$SCAFFOLD_DIR/test_runtime/entitlementFlow.test.mjs"

require_term "denial prevents descriptor issuance" "$SCAFFOLD_DIR/test_runtime/playbackDescriptorFlow.test.mjs"
require_term "approved audit context required" "$SCAFFOLD_DIR/test_runtime/playbackDescriptorFlow.test.mjs"
require_term "descriptor_ready" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "descriptor_unavailable" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "expires_at" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "refresh_after" "$SCAFFOLD_DIR/test_runtime" "$SCAFFOLD_DIR/src"
require_term "short-lived" "$SCAFFOLD_DIR/test_runtime/playbackDescriptorFlow.test.mjs"
require_term "contains no provider credentials" "$SCAFFOLD_DIR/test_runtime/playbackDescriptorFlow.test.mjs"

require_term "provider unavailable preserves local_preview_fallback" "$SCAFFOLD_DIR/test_runtime/localFallback.test.mjs"
require_term "missing approval preserves local_preview_fallback" "$SCAFFOLD_DIR/test_runtime/localFallback.test.mjs"
require_term "invalid mapping preserves local_preview_fallback" "$SCAFFOLD_DIR/test_runtime/localFallback.test.mjs"
require_term "rollback state preserves local_preview_fallback" "$SCAFFOLD_DIR/test_runtime/localFallback.test.mjs"
ws_word='Web''Socket'
require_term "no fetch/HTTP/HTTPS/$ws_word/network calls" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
require_term "no credentials required" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
require_term "no real .env reads" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
require_term "descriptor references are not logged" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
require_term "descriptor references are not persisted" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
require_term "descriptor contains no concrete URL" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"
require_term "descriptor contains no token or private key" "$SCAFFOLD_DIR/test_runtime/securityBehavior.test.mjs"

for field in \
  upgrade status node_version typescript_compiler typescript_compiler_version total_tests tests_passed tests_failed \
  passed_tests failed_tests product_mapping_status entitlement_flow_status playback_descriptor_status \
  local_fallback_status security_behavior_status network_requests_performed package_install_performed \
  deployment_performed failures production_modules_exercised; do
  require_term "$field" "$RUNNER"
done

require_regex 'production_modules_exercised' "$RUNNER"
for module in \
  "contracts.ts" \
  "productMapping.ts" \
  "audit.ts" \
  "errors.ts" \
  "entitlements/validateEntitlement.ts" \
  "playback/requestPlaybackDescriptor.ts" \
  "providers/providerInterfaces.ts" \
  "providers/revenueCatValidator.ts" \
  "mocks/mockEntitlementProvider.ts" \
  "mocks/mockCloudflareSigner.ts"; do
  require_term "$module" "$RUNNER"
done

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

node - "$SOURCE_JSON" "$status" ${failures[@]+"${failures[@]}"} <<'NODE'
const fs = require("node:fs");
const [outPath, status, ...failures] = process.argv.slice(2);
const body = {
  upgrade: "#066.0B",
  status,
  baseline_commit: "20b2be4",
  baseline_tag: "phase-66-0a-staging-backend-local-contract-test-harness",
  required_harness_files_checked: 10,
  production_modules_checked: 10,
  tooling_behavior_verified: status === "pass",
  tests_import_compiled_production_modules: status === "pass",
  compiled_output_private_tmp_only: status === "pass",
  package_install_performed: false,
  network_requests_performed: false,
  deployment_performed: false,
  failures
};
fs.writeFileSync(outPath, `${JSON.stringify(body, null, 2)}\n`);
NODE

{
  printf '# Staging Backend Local Contract Test Harness Source Verification\n\n'
  printf -- '- Upgrade: #066.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: `20b2be4` / `phase-66-0a-staging-backend-local-contract-test-harness`\n'
  printf -- '- Required harness files checked: 10\n'
  printf -- '- Production modules checked: 10\n'
  printf -- '- Package install performed: false\n'
  printf -- '- Network requests performed: false\n'
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nSource verification passed.\n'
  fi
} > "$SOURCE_MD"

cat "$SOURCE_MD"
[[ "$status" == "pass" ]]
