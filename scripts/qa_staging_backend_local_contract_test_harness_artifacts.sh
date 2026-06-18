#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EVIDENCE_OUT="/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence"
TEST_OUT="/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests"
MANIFEST_JSON="$EVIDENCE_OUT/staging_backend_contract_test_harness_artifact_manifest.json"
MANIFEST_MD="$EVIDENCE_OUT/staging_backend_contract_test_harness_artifact_manifest.md"
mkdir -p "$EVIDENCE_OUT"

failures=()

node_version="missing"
node_path="missing"
tsc_path="missing"
tsc_version="missing"
contract_pack_verifier_status="not_present"
ios_build_status="pending"

if command -v node >/dev/null 2>&1; then
  node_path="$(command -v node)"
  node_version="$(node --version)"
else
  failures+=("node missing")
fi

if command -v tsc >/dev/null 2>&1; then
  tsc_path="$(command -v tsc)"
  tsc_version="$(tsc --version)"
else
  failures+=("tsc missing")
fi

if ! bash scripts/run_staging_backend_local_contract_tests.sh; then
  failures+=("#066.0A contract test runner failed")
fi
if ! bash scripts/verify_staging_backend_local_contract_tests.sh; then
  failures+=("#066.0A contract test verifier failed")
fi
if ! bash scripts/verify_staging_backend_deployment_scaffold.sh; then
  failures+=("staging backend scaffold verifier failed")
fi
if [[ -x scripts/verify_backend_staging_deployment_contract_pack.sh ]]; then
  if bash scripts/verify_backend_staging_deployment_contract_pack.sh; then
    contract_pack_verifier_status="pass"
  else
    contract_pack_verifier_status="fail"
    failures+=("backend staging contract-pack verifier failed")
  fi
fi

expected_outputs=(
  "$TEST_OUT/contract_test_output.tap"
  "$TEST_OUT/contract_test_summary.json"
  "$TEST_OUT/contract_test_summary.md"
  "$TEST_OUT/verification.json"
  "$TEST_OUT/verification.md"
)

for file in "${expected_outputs[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty #066.0A output: $file")
done

if [[ -s "$TEST_OUT/contract_test_summary.json" ]]; then
  node - "$TEST_OUT/contract_test_summary.json" <<'NODE' || failures+=("#066.0A summary did not pass required checks")
const fs = require("node:fs");
const summary = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const required = {
  status: "pass",
  total_tests: 37,
  tests_passed: 37,
  tests_failed: 0,
  passed_tests: 37,
  failed_tests: 0,
  product_mapping_status: "pass",
  entitlement_flow_status: "pass",
  playback_descriptor_status: "pass",
  local_fallback_status: "pass",
  security_behavior_status: "pass",
  network_requests_performed: false,
  package_install_performed: false,
  deployment_performed: false
};
for (const [key, value] of Object.entries(required)) {
  if (summary[key] !== value) throw new Error(`${key} expected ${value} got ${summary[key]}`);
}
if (!Array.isArray(summary.failures) || summary.failures.length !== 0) {
  throw new Error("summary failures must be empty");
}
if (!Array.isArray(summary.production_modules_exercised) || summary.production_modules_exercised.length < 10) {
  throw new Error("production_modules_exercised missing expected modules");
}
NODE
else
  failures+=("#066.0A summary JSON missing")
fi

if [[ -s "$TEST_OUT/verification.json" ]]; then
  node - "$TEST_OUT/verification.json" <<'NODE' || failures+=("#066.0A verification did not pass required checks")
const fs = require("node:fs");
const verification = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
if (verification.status !== "pass") throw new Error("verification status is not pass");
if (verification.network_requests_performed !== false) throw new Error("network flag is not false");
if (verification.package_install_performed !== false) throw new Error("install flag is not false");
if (verification.deployment_performed !== false) throw new Error("deployment flag is not false");
if (!Array.isArray(verification.failures) || verification.failures.length !== 0) {
  throw new Error("verification failures must be empty");
}
NODE
else
  failures+=("#066.0A verification JSON missing")
fi

if TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-66-0b-staging-backend-contract-test-evidence" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build; then
  ios_build_status="pass"
else
  ios_build_status="fail"
  failures+=("iOS regression build failed")
fi

summary_status="missing"
total_tests=0
tests_passed=0
tests_failed=0
if [[ -s "$TEST_OUT/contract_test_summary.json" ]]; then
  summary_status="$(node -e "const s=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); process.stdout.write(s.status)" "$TEST_OUT/contract_test_summary.json")"
  total_tests="$(node -e "const s=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); process.stdout.write(String(s.total_tests))" "$TEST_OUT/contract_test_summary.json")"
  tests_passed="$(node -e "const s=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); process.stdout.write(String(s.tests_passed))" "$TEST_OUT/contract_test_summary.json")"
  tests_failed="$(node -e "const s=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); process.stdout.write(String(s.tests_failed))" "$TEST_OUT/contract_test_summary.json")"
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

node - "$MANIFEST_JSON" "$status" "$node_version" "$node_path" "$tsc_version" "$tsc_path" "$contract_pack_verifier_status" "$ios_build_status" "$summary_status" "$total_tests" "$tests_passed" "$tests_failed" ${failures[@]+"${failures[@]}"} <<'NODE'
const fs = require("node:fs");
const [
  outPath,
  status,
  nodeVersion,
  nodePath,
  tscVersion,
  tscPath,
  contractPackVerifierStatus,
  iosBuildStatus,
  summaryStatus,
  totalTests,
  testsPassed,
  testsFailed,
  ...failures
] = process.argv.slice(2);
const body = {
  upgrade: "#066.0B",
  status,
  node_version: nodeVersion,
  node_path: nodePath,
  typescript_compiler: tscPath,
  typescript_compiler_version: tscVersion,
  contract_test_runner_status: summaryStatus,
  contract_test_verifier_status: status === "pass" ? "pass" : "checked",
  scaffold_verifier_status: status === "pass" ? "pass" : "checked",
  contract_pack_verifier_status: contractPackVerifierStatus,
  ios_regression_build_status: iosBuildStatus,
  total_tests: Number(totalTests),
  tests_passed: Number(testsPassed),
  tests_failed: Number(testsFailed),
  expected_outputs: [
    "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_output.tap",
    "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_summary.json",
    "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_summary.md",
    "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/verification.json",
    "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/verification.md"
  ],
  package_install_performed: false,
  network_requests_performed: false,
  deployment_performed: false,
  failures
};
fs.writeFileSync(outPath, `${JSON.stringify(body, null, 2)}\n`);
NODE

{
  printf '# Staging Backend Local Contract Test Harness Artifact Manifest\n\n'
  printf -- '- Upgrade: #066.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Node: %s (%s)\n' "$node_version" "$node_path"
  printf -- '- TypeScript: %s (%s)\n' "$tsc_version" "$tsc_path"
  printf -- '- Contract tests: %s total / %s passed / %s failed\n' "$total_tests" "$tests_passed" "$tests_failed"
  printf -- '- iOS regression build: %s\n' "$ios_build_status"
  printf -- '- Contract-pack verifier: %s\n' "$contract_pack_verifier_status"
  printf -- '- Package install performed: false\n'
  printf -- '- Network requests performed: false\n'
  printf -- '- Deployment performed: false\n'
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nArtifact QA passed.\n'
  fi
} > "$MANIFEST_MD"

cat "$MANIFEST_MD"
[[ "$status" == "pass" ]]
