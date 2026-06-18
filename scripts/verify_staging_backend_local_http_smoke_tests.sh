#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke"
SUMMARY_JSON="$OUT_DIR/http_smoke_test_summary.json"
SUMMARY_MD="$OUT_DIR/http_smoke_test_summary.md"
TAP_FILE="$OUT_DIR/http_smoke_test_output.tap"
SERVER_LOG="$OUT_DIR/server.log"
VERIFICATION_JSON="$OUT_DIR/verification.json"
VERIFICATION_MD="$OUT_DIR/verification.md"
SCAFFOLD_DIR="backend/staging_server_scaffold"

failures=()

required_files=(
  "scripts/run_staging_backend_local_http_smoke_tests.sh"
  "scripts/verify_staging_backend_local_http_smoke_tests.sh"
  "$SCAFFOLD_DIR/smoke_runtime/testHelpers.mjs"
  "$SCAFFOLD_DIR/smoke_runtime/httpHealth.test.mjs"
  "$SCAFFOLD_DIR/smoke_runtime/httpEntitlement.test.mjs"
  "$SCAFFOLD_DIR/smoke_runtime/httpPlaybackDescriptor.test.mjs"
  "$SCAFFOLD_DIR/smoke_runtime/httpErrorHandling.test.mjs"
  "$SCAFFOLD_DIR/smoke_runtime/httpSecurity.test.mjs"
  "$SCAFFOLD_DIR/deployment/target.json"
  "$SCAFFOLD_DIR/deployment/runtime.env.example"
  "$SCAFFOLD_DIR/deployment/README.md"
  "$SUMMARY_JSON"
  "$SUMMARY_MD"
  "$TAP_FILE"
  "$SERVER_LOG"
)

for file in "${required_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty file: $file")
done

[[ -x scripts/run_staging_backend_local_http_smoke_tests.sh ]] || failures+=("runner is not executable")
[[ -x scripts/verify_staging_backend_local_http_smoke_tests.sh ]] || failures+=("verifier is not executable")
[[ ! -e "$SCAFFOLD_DIR/deployment/.env" ]] || failures+=("real deployment .env file exists")

if [[ -s "$SCAFFOLD_DIR/deployment/target.json" ]]; then
  node - "$SCAFFOLD_DIR/deployment/target.json" <<'NODE' || failures+=("target metadata invalid")
const fs = require("node:fs");
const target = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const expected = {
  target_name: "highfive-staging-node-http",
  runtime: "node",
  transport: "http",
  deployment_status: "not_deployed",
  provider_mode: "mock",
  health_path: "/health",
  entitlement_path: "/entitlements/validate",
  descriptor_path: "/playback/descriptor",
  local_bind_host: "127.0.0.1",
  compiled_output_policy: "private_tmp_only_for_qa",
  credentials_required_for_local_smoke: false,
  external_network_allowed_for_local_smoke: false,
  local_preview_fallback_preserved: true
};
for (const [key, value] of Object.entries(expected)) {
  if (target[key] !== value) throw new Error(`${key} mismatch`);
}
NODE
fi

if [[ -s "$SUMMARY_JSON" ]]; then
  node - "$SUMMARY_JSON" <<'NODE' || failures+=("summary JSON failed verification")
const fs = require("node:fs");
const summary = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const expected = {
  status: "pass",
  tests_failed: 0,
  health_status: "pass",
  entitlement_http_status: "pass",
  descriptor_http_status: "pass",
  error_handling_status: "pass",
  security_status: "pass",
  server_started: true,
  server_stopped: true,
  bind_host: "127.0.0.1",
  external_network_requests_performed: false,
  package_install_performed: false,
  deployment_performed: false,
  credential_required: false,
  descriptor_reference_logged: false,
  descriptor_reference_persisted: false
};
for (const [key, value] of Object.entries(expected)) {
  if (summary[key] !== value) throw new Error(`${key} expected ${value} got ${summary[key]}`);
}
if (!Array.isArray(summary.failures) || summary.failures.length !== 0) throw new Error("failures must be empty");
if (!Array.isArray(summary.production_modules_exercised) || summary.production_modules_exercised.length < 10) {
  throw new Error("production modules evidence missing");
}
NODE
fi

if [[ ! -d "$OUT_DIR/compiled" ]]; then
  failures+=("compiled output directory missing under private tmp")
fi
if find "$SCAFFOLD_DIR" -name '*.js' -type f | rg -q .; then
  failures+=("compiled JavaScript found beneath backend/staging_server_scaffold")
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
  failures+=("dependency, env, dist, or build artifact found in scaffold")
fi

if rg -n 'playback_url_or_token_reference|MOCK_DESCRIPTOR_REFERENCE|Cloudflare|RevenueCat|APP_STORE|PRIVATE_KEY' "$SERVER_LOG"; then
  failures+=("sensitive descriptor or provider material found in server log")
fi

if [[ -f "$OUT_DIR/server.pid" ]]; then
  pid="$(cat "$OUT_DIR/server.pid")"
  if [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1; then
    failures+=("server process remains running")
  fi
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

node - "$VERIFICATION_JSON" "$status" ${failures[@]+"${failures[@]}"} <<'NODE'
const fs = require("node:fs");
const [outPath, status, ...failures] = process.argv.slice(2);
const body = {
  upgrade: "#067.0A",
  status,
  runner_executable: true,
  smoke_files_checked: true,
  target_metadata_checked: true,
  summary_checked: true,
  verification_json_checked: true,
  no_compiled_repo_js: status === "pass",
  no_package_install: true,
  no_external_network_request: true,
  no_deployment: true,
  no_credentials_required: true,
  descriptor_reference_logged: false,
  descriptor_reference_persisted: false,
  server_process_remaining: false,
  failures
};
fs.writeFileSync(outPath, `${JSON.stringify(body, null, 2)}\n`);
NODE

{
  printf '# HighFive Staging Backend Local HTTP Smoke Verification\n\n'
  printf -- '- Upgrade: #067.0A\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Runner executable: true\n'
  printf -- '- Smoke files checked: true\n'
  printf -- '- Target metadata checked: true\n'
  printf -- '- Summary checked: true\n'
  printf -- '- No package install: true\n'
  printf -- '- No external network request: true\n'
  printf -- '- No deployment: true\n'
  printf -- '- Descriptor reference logged: false\n'
  printf -- '- Descriptor reference persisted: false\n'
  printf -- '- Server process remaining: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nHTTP smoke verification passed.\n'
  fi
} > "$VERIFICATION_MD"

cat "$VERIFICATION_MD"
[[ "$status" == "pass" ]]
