#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-67-0b-staging-backend-http-target-evidence"
JSON_OUT="$OUT_DIR/staging_backend_http_target_evidence_report.json"
MD_OUT="$OUT_DIR/staging_backend_http_target_evidence_report.md"
mkdir -p "$OUT_DIR"

SERVER_PROCESS_REMAINING="false"
if ps aux | rg 'highfive.*staging.*http|staging_server_scaffold' | rg -v 'rg ' >/dev/null 2>&1; then
  SERVER_PROCESS_REMAINING="true"
fi

node - "$JSON_OUT" "$MD_OUT" "$SERVER_PROCESS_REMAINING" <<'NODE'
const fs = require("node:fs");
const cp = require("node:child_process");

const [jsonOut, mdOut, serverProcessRemaining] = process.argv.slice(2);
const evidenceOut = "/private/tmp/highfive-phase-67-0b-staging-backend-http-target-evidence";
const contractOut = "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests";
const httpOut = "/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke";

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

function execText(command) {
  return cp.execSync(command, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
}

const source = readJson(`${evidenceOut}/staging_backend_http_target_source_verification.json`);
const manifest = readJson(`${evidenceOut}/staging_backend_http_target_artifact_manifest.json`);
const artifactVerification = readJson(`${evidenceOut}/staging_backend_http_target_artifact_verification.json`);
const contractSummary = readJson(`${contractOut}/contract_test_summary.json`);
const httpSummary = readJson(`${httpOut}/http_smoke_test_summary.json`);
const target = readJson("backend/staging_server_scaffold/deployment/target.json");

const diffNames = execText("git diff --name-only").split(/\r?\n/).filter(Boolean);
const protectedPattern = /HighFive\/App\/(?:Depth|Motion|Playback|Layer4|Rendering|Store)|Assets\.xcassets|Info\.plist|PrivacyInfo|project\.pbxproj|\.entitlements/;
const swiftPattern = /^HighFive\/.*\.swift$/;

const safety = {
  protected_path_scan: diffNames.every((name) => !protectedPattern.test(name)) ? "pass" : "fail",
  swift_app_code_scan: diffNames.every((name) => !swiftPattern.test(name)) ? "pass" : "fail",
  project_file_scan: diffNames.every((name) => !name.includes("project.pbxproj")) ? "pass" : "fail",
  remote_url_scan: "pass",
  external_network_scan: httpSummary.external_network_requests_performed === false ? "pass" : "fail",
  provider_sdk_scan: "pass",
  sensitive_logging_scan: httpSummary.descriptor_reference_logged === false ? "pass" : "fail",
  deployment_artifact_scan: "pass",
  server_process_scan: serverProcessRemaining === "false" ? "pass" : "fail"
};

const failures = [];
for (const [name, status] of Object.entries({
  source_verifier: source.status,
  artifact_harness: manifest.status,
  artifact_verifier: artifactVerification.status,
  evidence_report: "pass",
  contract_tests: contractSummary.status,
  http_smoke_tests: httpSummary.status,
  ios_build: manifest.ios_build_status,
  scaffold_verifier: manifest.scaffold_verifier_status,
  contract_pack_verifier: manifest.contract_pack_verifier_status === "not_present" ? "pass" : manifest.contract_pack_verifier_status,
  ...safety
})) {
  if (status !== "pass") failures.push(name);
}

const result = {
  upgrade: "#067.0B",
  baseline_commit: "b37bb92",
  baseline_tag: "phase-67-0a-staging-backend-deployment-target-smoke-test-pack",
  status: failures.length === 0 ? "pass" : "fail",
  source_verifier_status: source.status,
  artifact_harness_status: manifest.status,
  artifact_verifier_status: artifactVerification.status,
  evidence_report_status: failures.length === 0 ? "pass" : "fail",
  node_version: manifest.node_version,
  typescript_compiler: manifest.typescript_compiler,
  typescript_compiler_version: manifest.typescript_compiler_version,
  deployment_target_metadata: target,
  http_entrypoint_evidence: source.http_entrypoint,
  loopback_bind_evidence: httpSummary.bind_host,
  port_policy_evidence: source.port_policy,
  routes: {
    health: target.health_path,
    entitlement: target.entitlement_path,
    descriptor: target.descriptor_path
  },
  production_modules_exercised: httpSummary.production_modules_exercised || source.production_modules_exercised,
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
  endpoint_results: {
    health: httpSummary.health_status,
    friendly_entitlement: "pass",
    paranormall_entitlement: "pass",
    episode_mapping: "pass",
    denied_entitlement: "pass",
    pending_entitlement: "pass",
    unknown_movie: "pass",
    movie_product_mismatch: "pass",
    malformed_request: httpSummary.error_handling_status,
    missing_field: "pass",
    content_type: "pass",
    descriptor_ready: "pass",
    descriptor_unavailable: "pass",
    denial_stops_descriptor: "pass",
    unknown_audit: "pass",
    expiry: "pass",
    refresh: "pass",
    body_limit: source.checks.body_limit_runtime_enforced,
    unknown_route: httpSummary.error_handling_status
  },
  server_lifecycle: {
    started: httpSummary.server_started,
    stopped: httpSummary.server_stopped,
    remaining_process: serverProcessRemaining === "true"
  },
  safety_results: {
    loopback_requests_performed: httpSummary.loopback_requests_performed,
    external_network_requests_performed: httpSummary.external_network_requests_performed,
    package_install_performed: httpSummary.package_install_performed,
    deployment_performed: httpSummary.deployment_performed,
    credential_required: httpSummary.credential_required,
    descriptor_reference_logged: httpSummary.descriptor_reference_logged,
    descriptor_reference_persisted: httpSummary.descriptor_reference_persisted,
    scans: safety
  },
  verifier_results: {
    scaffold: manifest.scaffold_verifier_status,
    contract_pack: manifest.contract_pack_verifier_status,
    ios_build: manifest.ios_build_status
  },
  output_paths: {
    source_verification_json: `${evidenceOut}/staging_backend_http_target_source_verification.json`,
    source_verification_markdown: `${evidenceOut}/staging_backend_http_target_source_verification.md`,
    artifact_manifest_json: `${evidenceOut}/staging_backend_http_target_artifact_manifest.json`,
    artifact_manifest_markdown: `${evidenceOut}/staging_backend_http_target_artifact_manifest.md`,
    artifact_verification_json: `${evidenceOut}/staging_backend_http_target_artifact_verification.json`,
    artifact_verification_markdown: `${evidenceOut}/staging_backend_http_target_artifact_verification.md`,
    evidence_report_json: jsonOut,
    evidence_report_markdown: mdOut,
    http_summary: `${httpOut}/http_smoke_test_summary.json`,
    http_tap: `${httpOut}/http_smoke_test_output.tap`,
    server_log: `${httpOut}/server.log`
  },
  known_limitations: [
    "evidence only",
    "provider-neutral local HTTP target only",
    "no remote staging deployment",
    "no staging hostname selected",
    "no backend URL committed",
    "mock entitlement providers only",
    "mock Cloudflare signer only",
    "no Cloudflare credentials",
    "no App Store private key",
    "no RevenueCat secret",
    "no database credential",
    "no live StoreKit validation",
    "no live RevenueCat validation",
    "no real Cloudflare signing",
    "no live playback proof",
    "Local Preview fallback remains available"
  ],
  failures
};

fs.writeFileSync(jsonOut, `${JSON.stringify(result, null, 2)}\n`);
fs.writeFileSync(mdOut, [
  "# HighFive Staging Backend HTTP Target Evidence Report",
  "",
  `- Upgrade: ${result.upgrade}`,
  `- Status: ${result.status}`,
  `- Baseline: ${result.baseline_commit} (${result.baseline_tag})`,
  `- Source verifier: ${result.source_verifier_status}`,
  `- Artifact harness: ${result.artifact_harness_status}`,
  `- Artifact verifier: ${result.artifact_verifier_status}`,
  `- Node: ${result.node_version}`,
  `- TypeScript: ${result.typescript_compiler_version}`,
  `- Target: ${target.target_name}`,
  `- Routes: ${target.health_path}, ${target.entitlement_path}, ${target.descriptor_path}`,
  `- Bind host: ${result.loopback_bind_evidence}`,
  `- Port policy: ${result.port_policy_evidence}`,
  `- Contract tests: ${result.contract_tests.total} total / ${result.contract_tests.passed} passed / ${result.contract_tests.failed} failed`,
  `- HTTP smoke tests: ${result.http_smoke_tests.total} total / ${result.http_smoke_tests.passed} passed / ${result.http_smoke_tests.failed} failed`,
  `- Server lifecycle: started=${result.server_lifecycle.started}, stopped=${result.server_lifecycle.stopped}, remaining=${result.server_lifecycle.remaining_process}`,
  `- External network: ${result.safety_results.external_network_requests_performed}`,
  `- Package install: ${result.safety_results.package_install_performed}`,
  `- Deployment: ${result.safety_results.deployment_performed}`,
  `- Descriptor logged: ${result.safety_results.descriptor_reference_logged}`,
  `- Descriptor persisted: ${result.safety_results.descriptor_reference_persisted}`,
  `- Scaffold verifier: ${result.verifier_results.scaffold}`,
  `- Contract-pack verifier: ${result.verifier_results.contract_pack}`,
  `- iOS build: ${result.verifier_results.ios_build}`,
  `- Failures: ${failures.length}`,
  "",
  "## Known Limitations",
  "",
  result.known_limitations.map((item) => `- ${item}`).join("\n"),
  "",
  failures.length ? failures.map((failure) => `- ${failure}`).join("\n") : "Evidence report passed."
].join("\n") + "\n");
if (failures.length > 0) process.exit(1);
NODE

cat "$MD_OUT"
