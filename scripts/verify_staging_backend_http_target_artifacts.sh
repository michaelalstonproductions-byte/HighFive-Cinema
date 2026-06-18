#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-67-0b-staging-backend-http-target-evidence"
JSON_OUT="$OUT_DIR/staging_backend_http_target_artifact_verification.json"
MD_OUT="$OUT_DIR/staging_backend_http_target_artifact_verification.md"
mkdir -p "$OUT_DIR"

SERVER_PROCESS_REMAINING="false"
if ps aux | rg 'highfive.*staging.*http|staging_server_scaffold' | rg -v 'rg ' >/dev/null 2>&1; then
  SERVER_PROCESS_REMAINING="true"
fi

node - "$JSON_OUT" "$MD_OUT" "$SERVER_PROCESS_REMAINING" <<'NODE'
const fs = require("node:fs");

const [jsonOut, mdOut, serverProcessRemaining] = process.argv.slice(2);
const evidenceOut = "/private/tmp/highfive-phase-67-0b-staging-backend-http-target-evidence";
const contractOut = "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests";
const httpOut = "/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke";
const failures = [];

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

function existsNonEmpty(path) {
  return fs.existsSync(path) && fs.statSync(path).size > 0;
}

function check(name, condition) {
  if (!condition) failures.push(name);
}

const sourceJsonPath = `${evidenceOut}/staging_backend_http_target_source_verification.json`;
const sourceMdPath = `${evidenceOut}/staging_backend_http_target_source_verification.md`;
const manifestJsonPath = `${evidenceOut}/staging_backend_http_target_artifact_manifest.json`;
const manifestMdPath = `${evidenceOut}/staging_backend_http_target_artifact_manifest.md`;

check("source_json_exists", existsNonEmpty(sourceJsonPath));
check("source_md_exists", existsNonEmpty(sourceMdPath));
check("manifest_json_exists", existsNonEmpty(manifestJsonPath));
check("manifest_md_exists", existsNonEmpty(manifestMdPath));

const source = readJson(sourceJsonPath);
const manifest = readJson(manifestJsonPath);
const contractSummary = readJson(`${contractOut}/contract_test_summary.json`);
const contractVerification = readJson(`${contractOut}/verification.json`);
const httpSummary = readJson(`${httpOut}/http_smoke_test_summary.json`);
const httpVerification = readJson(`${httpOut}/verification.json`);

check("source_passed", source.status === "pass");
check("manifest_passed", manifest.status === "pass");
check("contract_summary_passed", contractSummary.status === "pass");
check("contract_verification_passed", contractVerification.status === "pass");
check("contract_tests_37", contractSummary.total_tests === 37);
check("contract_tests_passed_37", contractSummary.tests_passed === 37 || contractSummary.passed_tests === 37);
check("contract_tests_failed_0", contractSummary.tests_failed === 0 || contractSummary.failed_tests === 0);

check("http_tap_exists", existsNonEmpty(`${httpOut}/http_smoke_test_output.tap`));
check("http_summary_passed", httpSummary.status === "pass");
check("http_verification_passed", httpVerification.status === "pass");
check("http_failed_0", httpSummary.tests_failed === 0);
check("http_all_passed", httpSummary.tests_passed === httpSummary.total_tests && httpSummary.total_tests > 0);
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
check("loopback_bind", ["127.0.0.1", "localhost", "::1"].includes(httpSummary.bind_host));
check("server_process_remaining_false", serverProcessRemaining === "false");
check("loopback_requests_only", httpSummary.loopback_requests_performed === true && httpSummary.external_network_requests_performed === false);
check("no_package_install", httpSummary.package_install_performed === false);
check("no_deployment", httpSummary.deployment_performed === false);
check("no_credential_required", httpSummary.credential_required === false);
check("no_descriptor_logging", httpSummary.descriptor_reference_logged === false);
check("no_descriptor_persistence", httpSummary.descriptor_reference_persisted === false);
check("compiled_tmp_exists", existsNonEmpty(`${httpOut}/compiled/runtime/httpTarget.js`));
check("manifest_ios_build_passed", manifest.ios_build_status === "pass");

function findCompiledRepoJs(dir) {
  if (!fs.existsSync(dir)) return [];
  const found = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const path = `${dir}/${entry.name}`;
    if (entry.isDirectory()) found.push(...findCompiledRepoJs(path));
    if (entry.isFile() && entry.name.endsWith(".js")) found.push(path);
  }
  return found;
}
const repoJs = findCompiledRepoJs("backend/staging_server_scaffold");
check("no_repo_compiled_js", repoJs.length === 0);

const result = {
  upgrade: "#067.0B",
  status: failures.length === 0 ? "pass" : "fail",
  source_verification_status: source.status,
  artifact_manifest_status: manifest.status,
  contract_tests: {
    total: contractSummary.total_tests,
    passed: contractSummary.tests_passed,
    failed: contractSummary.tests_failed
  },
  http_smoke_tests: {
    total: httpSummary.total_tests,
    passed: httpSummary.tests_passed,
    failed: httpSummary.tests_failed
  },
  server_started: httpSummary.server_started,
  server_stopped: httpSummary.server_stopped,
  bind_host: httpSummary.bind_host,
  server_process_remaining: serverProcessRemaining === "true",
  loopback_requests_performed: httpSummary.loopback_requests_performed,
  external_network_requests_performed: httpSummary.external_network_requests_performed,
  package_install_performed: httpSummary.package_install_performed,
  deployment_performed: httpSummary.deployment_performed,
  credential_required: httpSummary.credential_required,
  descriptor_reference_logged: httpSummary.descriptor_reference_logged,
  descriptor_reference_persisted: httpSummary.descriptor_reference_persisted,
  no_repo_compiled_js: repoJs.length === 0,
  ios_build_status: manifest.ios_build_status,
  failures
};

fs.writeFileSync(jsonOut, `${JSON.stringify(result, null, 2)}\n`);
fs.writeFileSync(mdOut, [
  "# HighFive Staging Backend HTTP Target Artifact Verification",
  "",
  `- Upgrade: ${result.upgrade}`,
  `- Status: ${result.status}`,
  `- Source verifier: ${result.source_verification_status}`,
  `- Artifact manifest: ${result.artifact_manifest_status}`,
  `- Contract tests: ${result.contract_tests.total} total / ${result.contract_tests.passed} passed / ${result.contract_tests.failed} failed`,
  `- HTTP smoke tests: ${result.http_smoke_tests.total} total / ${result.http_smoke_tests.passed} passed / ${result.http_smoke_tests.failed} failed`,
  `- Server started: ${result.server_started}`,
  `- Server stopped: ${result.server_stopped}`,
  `- Bind host: ${result.bind_host}`,
  `- Server process remaining: ${result.server_process_remaining}`,
  `- iOS build: ${result.ios_build_status}`,
  `- Failures: ${failures.length}`,
  "",
  failures.length ? failures.map((failure) => `- ${failure}`).join("\n") : "Artifact verification passed."
].join("\n") + "\n");
if (failures.length > 0) process.exit(1);
NODE

cat "$MD_OUT"
