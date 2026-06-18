#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-67-0b-staging-backend-http-target-evidence"
JSON_OUT="$OUT_DIR/staging_backend_http_target_artifact_manifest.json"
MD_OUT="$OUT_DIR/staging_backend_http_target_artifact_manifest.md"
CONTRACT_OUT="/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests"
HTTP_OUT="/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke"
mkdir -p "$OUT_DIR"

STEP_FAILURES=()
CONTRACT_RUN_STATUS="not_run"
CONTRACT_VERIFY_STATUS="not_run"
HTTP_RUN_STATUS="not_run"
HTTP_VERIFY_STATUS="not_run"
SCAFFOLD_VERIFY_STATUS="not_run"
CONTRACT_PACK_VERIFY_STATUS="not_present"
IOS_BUILD_STATUS="not_run"

run_step() {
  local name="$1"
  shift
  if "$@"; then
    printf '%s: pass\n' "$name"
    return 0
  fi
  printf '%s: fail\n' "$name"
  STEP_FAILURES+=("$name")
  return 1
}

NODE_VERSION="$(node --version)"
NODE_PATH="$(command -v node)"
TSC_PATH="$(command -v tsc)"
TSC_VERSION="$(tsc --version)"

if run_step "contract_runner" bash scripts/run_staging_backend_local_contract_tests.sh; then
  CONTRACT_RUN_STATUS="pass"
else
  CONTRACT_RUN_STATUS="fail"
fi

if run_step "contract_verifier" bash scripts/verify_staging_backend_local_contract_tests.sh; then
  CONTRACT_VERIFY_STATUS="pass"
else
  CONTRACT_VERIFY_STATUS="fail"
fi

if run_step "http_smoke_runner" bash scripts/run_staging_backend_local_http_smoke_tests.sh; then
  HTTP_RUN_STATUS="pass"
else
  HTTP_RUN_STATUS="fail"
fi

if run_step "http_smoke_verifier" bash scripts/verify_staging_backend_local_http_smoke_tests.sh; then
  HTTP_VERIFY_STATUS="pass"
else
  HTTP_VERIFY_STATUS="fail"
fi

if run_step "scaffold_verifier" bash scripts/verify_staging_backend_deployment_scaffold.sh; then
  SCAFFOLD_VERIFY_STATUS="pass"
else
  SCAFFOLD_VERIFY_STATUS="fail"
fi

if [[ -x scripts/verify_backend_staging_deployment_contract_pack.sh ]]; then
  if run_step "contract_pack_verifier" bash scripts/verify_backend_staging_deployment_contract_pack.sh; then
    CONTRACT_PACK_VERIFY_STATUS="pass"
  else
    CONTRACT_PACK_VERIFY_STATUS="fail"
  fi
fi

if run_step "ios_regression_build" env TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-67-0b-staging-backend-http-target-evidence" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build; then
  IOS_BUILD_STATUS="pass"
else
  IOS_BUILD_STATUS="fail"
fi

node - "$JSON_OUT" "$MD_OUT" \
  "$NODE_VERSION" "$NODE_PATH" "$TSC_PATH" "$TSC_VERSION" \
  "$CONTRACT_RUN_STATUS" "$CONTRACT_VERIFY_STATUS" \
  "$HTTP_RUN_STATUS" "$HTTP_VERIFY_STATUS" \
  "$SCAFFOLD_VERIFY_STATUS" "$CONTRACT_PACK_VERIFY_STATUS" "$IOS_BUILD_STATUS" \
  ${STEP_FAILURES[@]+"${STEP_FAILURES[@]}"} <<'NODE'
const fs = require("node:fs");

const [
  jsonOut,
  mdOut,
  nodeVersion,
  nodePath,
  tscPath,
  tscVersion,
  contractRunStatus,
  contractVerifyStatus,
  httpRunStatus,
  httpVerifyStatus,
  scaffoldVerifyStatus,
  contractPackVerifyStatus,
  iosBuildStatus,
  ...stepFailures
] = process.argv.slice(2);

const contractOut = "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests";
const httpOut = "/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke";
const failures = [...stepFailures];

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

function existsNonEmpty(path) {
  return fs.existsSync(path) && fs.statSync(path).size > 0;
}

function check(name, condition) {
  if (!condition) failures.push(name);
}

const contractSummary = readJson(`${contractOut}/contract_test_summary.json`);
const contractVerification = readJson(`${contractOut}/verification.json`);
const httpSummary = readJson(`${httpOut}/http_smoke_test_summary.json`);
const httpVerification = readJson(`${httpOut}/verification.json`);

for (const path of [
  `${contractOut}/contract_test_output.tap`,
  `${contractOut}/contract_test_summary.json`,
  `${contractOut}/contract_test_summary.md`,
  `${contractOut}/verification.json`,
  `${contractOut}/verification.md`,
  `${httpOut}/http_smoke_test_output.tap`,
  `${httpOut}/http_smoke_test_summary.json`,
  `${httpOut}/http_smoke_test_summary.md`,
  `${httpOut}/server.log`,
  `${httpOut}/verification.json`,
  `${httpOut}/verification.md`
]) {
  check(`non_empty:${path}`, existsNonEmpty(path));
}

check("contract_status", contractSummary.status === "pass" && contractVerification.status === "pass");
check("contract_total_37", contractSummary.total_tests === 37);
check("contract_passed_37", contractSummary.tests_passed === 37 || contractSummary.passed_tests === 37);
check("contract_failed_0", contractSummary.tests_failed === 0 || contractSummary.failed_tests === 0);
check("http_status", httpSummary.status === "pass" && httpVerification.status === "pass");
check("http_total_positive", httpSummary.total_tests > 0);
check("http_all_passed", httpSummary.tests_passed === httpSummary.total_tests);
check("http_failed_0", httpSummary.tests_failed === 0);
for (const field of [
  "health_status",
  "entitlement_http_status",
  "descriptor_http_status",
  "error_handling_status",
  "security_status"
]) {
  check(`http_group:${field}`, httpSummary[field] === "pass");
}
check("server_started", httpSummary.server_started === true);
check("server_stopped", httpSummary.server_stopped === true);
check("loopback_bind", httpSummary.bind_host === "127.0.0.1" || httpSummary.bind_host === "localhost" || httpSummary.bind_host === "::1");
check("not_deployed", httpSummary.deployment_status === "not_deployed");
check("mock_provider", httpSummary.provider_mode === "mock");
check("loopback_requests", httpSummary.loopback_requests_performed === true);
check("no_external_network", httpSummary.external_network_requests_performed === false);
check("no_package_install", httpSummary.package_install_performed === false);
check("no_deployment", httpSummary.deployment_performed === false);
check("no_credential_required", httpSummary.credential_required === false);
check("no_descriptor_logging", httpSummary.descriptor_reference_logged === false);
check("no_descriptor_persistence", httpSummary.descriptor_reference_persisted === false);
check("http_failures_empty", Array.isArray(httpSummary.failures) && httpSummary.failures.length === 0);
check("ios_build_passed", iosBuildStatus === "pass");
check("scaffold_verifier_passed", scaffoldVerifyStatus === "pass");
check("contract_pack_verifier_passed_or_absent", contractPackVerifyStatus === "pass" || contractPackVerifyStatus === "not_present");

const result = {
  upgrade: "#067.0B",
  status: failures.length === 0 ? "pass" : "fail",
  node_version: nodeVersion,
  node_path: nodePath,
  typescript_compiler: tscPath,
  typescript_compiler_version: tscVersion,
  contract_runner_status: contractRunStatus,
  contract_verifier_status: contractVerifyStatus,
  contract_test_status: contractSummary.status,
  contract_total_tests: contractSummary.total_tests,
  contract_tests_passed: contractSummary.tests_passed,
  contract_tests_failed: contractSummary.tests_failed,
  http_runner_status: httpRunStatus,
  http_verifier_status: httpVerifyStatus,
  http_smoke_status: httpSummary.status,
  http_total_tests: httpSummary.total_tests,
  http_tests_passed: httpSummary.tests_passed,
  http_tests_failed: httpSummary.tests_failed,
  server_started: httpSummary.server_started,
  server_stopped: httpSummary.server_stopped,
  scaffold_verifier_status: scaffoldVerifyStatus,
  contract_pack_verifier_status: contractPackVerifyStatus,
  ios_build_status: iosBuildStatus,
  deployment_performed: false,
  output_paths: {
    contract_summary: `${contractOut}/contract_test_summary.json`,
    contract_verification: `${contractOut}/verification.json`,
    http_summary: `${httpOut}/http_smoke_test_summary.json`,
    http_verification: `${httpOut}/verification.json`,
    http_tap: `${httpOut}/http_smoke_test_output.tap`,
    server_log: `${httpOut}/server.log`
  },
  failures
};

fs.writeFileSync(jsonOut, `${JSON.stringify(result, null, 2)}\n`);
fs.writeFileSync(mdOut, [
  "# HighFive Staging Backend HTTP Target Artifact Manifest",
  "",
  `- Upgrade: ${result.upgrade}`,
  `- Status: ${result.status}`,
  `- Node: ${result.node_version}`,
  `- TypeScript: ${result.typescript_compiler_version}`,
  `- Contract tests: ${result.contract_total_tests} total / ${result.contract_tests_passed} passed / ${result.contract_tests_failed} failed`,
  `- HTTP smoke tests: ${result.http_total_tests} total / ${result.http_tests_passed} passed / ${result.http_tests_failed} failed`,
  `- Server lifecycle: started=${result.server_started}, stopped=${result.server_stopped}`,
  `- Scaffold verifier: ${result.scaffold_verifier_status}`,
  `- Contract-pack verifier: ${result.contract_pack_verifier_status}`,
  `- iOS build: ${result.ios_build_status}`,
  `- Deployment performed: ${result.deployment_performed}`,
  `- Failures: ${failures.length}`,
  "",
  failures.length ? failures.map((failure) => `- ${failure}`).join("\n") : "Artifact QA passed."
].join("\n") + "\n");
if (failures.length > 0) process.exit(1);
NODE

cat "$MD_OUT"
