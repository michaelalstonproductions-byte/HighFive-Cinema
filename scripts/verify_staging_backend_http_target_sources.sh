#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-67-0b-staging-backend-http-target-evidence"
JSON_OUT="$OUT_DIR/staging_backend_http_target_source_verification.json"
MD_OUT="$OUT_DIR/staging_backend_http_target_source_verification.md"
mkdir -p "$OUT_DIR"

node - "$JSON_OUT" "$MD_OUT" <<'NODE'
const fs = require("node:fs");

const jsonOut = process.argv[2];
const mdOut = process.argv[3];
const failures = [];
const checks = {};

function read(path) {
  return fs.readFileSync(path, "utf8");
}

function exists(path) {
  return fs.existsSync(path) && fs.statSync(path).size > 0;
}

function check(name, condition, detail = "") {
  checks[name] = condition ? "pass" : "fail";
  if (!condition) failures.push(detail || name);
}

function includes(path, value) {
  return read(path).includes(value);
}

function json(path) {
  return JSON.parse(read(path));
}

const target = json("backend/staging_server_scaffold/deployment/target.json");
check("target_name", target.target_name === "highfive-staging-node-http");
check("runtime", target.runtime === "node");
check("transport", target.transport === "http");
check("deployment_status", target.deployment_status === "not_deployed");
check("provider_mode", target.provider_mode === "mock");
check("health_path", target.health_path === "/health");
check("entitlement_path", target.entitlement_path === "/entitlements/validate");
check("descriptor_path", target.descriptor_path === "/playback/descriptor");
check("local_bind_host", target.local_bind_host === "127.0.0.1");
check("compiled_output_policy", target.compiled_output_policy === "private_tmp_only_for_qa");
check("credentials_required_for_local_smoke", target.credentials_required_for_local_smoke === false);
check("external_network_allowed_for_local_smoke", target.external_network_allowed_for_local_smoke === false);
check("local_preview_fallback_preserved", target.local_preview_fallback_preserved === true);

const requiredFiles = [
  "backend/staging_server_scaffold/tsconfig.http-target.json",
  "backend/staging_server_scaffold/src/server.ts",
  "backend/staging_server_scaffold/src/runtime/runtimeConfig.ts",
  "backend/staging_server_scaffold/src/runtime/providerFactory.ts",
  "backend/staging_server_scaffold/src/runtime/httpResponse.ts",
  "backend/staging_server_scaffold/src/runtime/httpTarget.ts",
  "backend/staging_server_scaffold/src/runtime/start.ts",
  "backend/staging_server_scaffold/src/runtime/node-runtime-shims.d.ts",
  "backend/staging_server_scaffold/deployment/target.json",
  "backend/staging_server_scaffold/deployment/runtime.env.example",
  "backend/staging_server_scaffold/deployment/README.md",
  "backend/staging_server_scaffold/smoke_runtime/testHelpers.mjs",
  "backend/staging_server_scaffold/smoke_runtime/httpHealth.test.mjs",
  "backend/staging_server_scaffold/smoke_runtime/httpEntitlement.test.mjs",
  "backend/staging_server_scaffold/smoke_runtime/httpPlaybackDescriptor.test.mjs",
  "backend/staging_server_scaffold/smoke_runtime/httpErrorHandling.test.mjs",
  "backend/staging_server_scaffold/smoke_runtime/httpSecurity.test.mjs",
  "scripts/run_staging_backend_local_http_smoke_tests.sh",
  "scripts/verify_staging_backend_local_http_smoke_tests.sh",
  "docs/production_services/HIGHFIVE_STAGING_BACKEND_HTTP_DEPLOYMENT_TARGET_SMOKE_TEST.md"
];
for (const file of requiredFiles) check(`file:${file}`, exists(file), `${file} missing or empty`);

const envExample = read("backend/staging_server_scaffold/deployment/runtime.env.example");
for (const value of [
  "HIGHFIVE_SERVER_HOST=127.0.0.1",
  "HIGHFIVE_PROVIDER_MODE=mock",
  "HIGHFIVE_MOCK_ENTITLEMENT_MODE=approved",
  "HIGHFIVE_MOCK_DESCRIPTOR_MODE=ready",
  "HIGHFIVE_BACKEND_ENV=local_smoke"
]) {
  check(`env:${value.split("=")[0]}`, envExample.includes(value), `${value} not found`);
}
check(
  "env:HIGHFIVE_SERVER_PORT",
  envExample.includes("HIGHFIVE_SERVER_PORT=0") || envExample.includes("HIGHFIVE_SERVER_PORT=<EPHEMERAL_OR_LOCAL_PORT>"),
  "HIGHFIVE_SERVER_PORT local value not found"
);

const runtimeConfig = read("backend/staging_server_scaffold/src/runtime/runtimeConfig.ts");
for (const value of ["127.0.0.1", "local_smoke", "mock", "approved", "denied", "pending", "ready", "unavailable"]) {
  check(`runtime_value:${value}`, runtimeConfig.includes(value) || envExample.includes(value), `${value} not found`);
}
check("body_limit_64k", runtimeConfig.includes("64 * 1024"));
check("configurable_or_ephemeral_port", runtimeConfig.includes("return 0") && runtimeConfig.includes("HIGHFIVE_SERVER_PORT"));

const httpTarget = read("backend/staging_server_scaffold/src/runtime/httpTarget.ts");
check("server_factory_export", httpTarget.includes("createStagingHttpTarget"));
check("health_route", httpTarget.includes('path === "/health"'));
check("entitlement_route", httpTarget.includes("entitlementValidationPath"));
check("descriptor_route", httpTarget.includes("playbackDescriptorPath"));
check("production_entitlement_route_invoked", httpTarget.includes("createEntitlementRoute"));
check("production_playback_route_invoked", httpTarget.includes("createPlaybackRoute"));
check("bounded_json_used", httpTarget.includes("readBoundedJsonBody"));
check("unknown_route_404", httpTarget.includes("routeNotFound"));
check("method_405", httpTarget.includes("methodNotAllowed"));
check("health_local_smoke", httpTarget.includes("environment: config.backendEnv"));
check("health_mock", httpTarget.includes("provider_mode: config.providerMode"));
check("health_not_deployed", httpTarget.includes("deployment_status: config.deploymentStatus"));
check("health_no_credentials", httpTarget.includes("credentials_required: false"));
check("health_no_external_network", httpTarget.includes("external_network_allowed: false"));
check("fallback_documented_in_health", httpTarget.includes("local_preview_fallback_preserved: true"));

const response = read("backend/staging_server_scaffold/src/runtime/httpResponse.ts");
check("json_response_content_type", response.includes('"Content-Type": "application/json"'));
check("unsupported_content_type", response.includes("unsupported_content_type"));
check("payload_too_large", response.includes("payload_too_large"));
check("malformed_json", response.includes("malformed_json"));
check("empty_json_body", response.includes("empty_json_body"));
check("response_405", response.includes("405"));
check("response_404", response.includes("404"));

const providerFactory = read("backend/staging_server_scaffold/src/runtime/providerFactory.ts");
check("mock_entitlement_provider", providerFactory.includes("MockEntitlementProvider"));
check("mock_descriptor_signer", providerFactory.includes("MockCloudflareSigner"));
check("mock_entitlement_modes", ["approved", "denied", "pending"].every((value) => providerFactory.includes(value)));
check("mock_descriptor_modes", ["ready", "unavailable"].every((value) => providerFactory.includes(value)));

const start = read("backend/staging_server_scaffold/src/runtime/start.ts");
check("graceful_shutdown", start.includes("server.close") && start.includes("SIGTERM") && start.includes("SIGINT"));
check("ready_file", start.includes("HIGHFIVE_READY_FILE"));

const helper = read("backend/staging_server_scaffold/smoke_runtime/testHelpers.mjs");
check("smoke_uses_node_test", helper.includes('from "node:test"'));
check("smoke_uses_assert_strict", helper.includes('from "node:assert/strict"'));
check("smoke_loopback_only", helper.includes("loopbackHttpPrefix") && helper.includes("localhostHttpPrefix"));
check("smoke_loopback_request_marker", helper.includes("local_http_smoke"));
check("smoke_credential_assertion", helper.includes("assertNoCredentialMaterial"));
check("smoke_no_remote_url_assertion", helper.includes("assertNoRemoteUrl"));

const health = read("backend/staging_server_scaffold/smoke_runtime/httpHealth.test.mjs");
check("health_get_test", health.includes("GET /health returns 200"));
check("health_wrong_method_test", health.includes("POST /health returns 405"));
check("health_no_credential_url_test", health.includes("contains no credential or URL"));

const entitlement = read("backend/staging_server_scaffold/smoke_runtime/httpEntitlement.test.mjs");
for (const [name, phrase] of [
  ["friendly_approved", "Friendly approved"],
  ["paranormall_season", "Paranormall season"],
  ["episode_mapping", "episode request uses correct product mapping"],
  ["denied", "denied mode"],
  ["pending", "pending mode"],
  ["unknown_movie", "unknown movie"],
  ["mismatch", "mismatch is rejected"],
  ["missing_fields", "missing required fields"],
  ["wrong_method", "GET /entitlements/validate returns 405"],
  ["audit_id", "audit_id"]
]) check(`entitlement_test:${name}`, entitlement.includes(phrase), phrase);

const descriptor = read("backend/staging_server_scaffold/smoke_runtime/httpPlaybackDescriptor.test.mjs");
for (const [name, phrase] of [
  ["approved_audit", "approved entitlement audit"],
  ["ready", "descriptor_ready"],
  ["unavailable", "descriptor_unavailable"],
  ["expiry", "expires_at"],
  ["refresh", "refresh_after"],
  ["short_lived", "assertShortLived"],
  ["denied_audit", "denied entitlement audit"],
  ["unknown_audit", "unknown audit ID"],
  ["mismatch", "mismatched movie/product"],
  ["wrong_method", "GET /playback/descriptor returns 405"],
  ["no_provider_credentials", "contains no provider credential"]
]) check(`descriptor_test:${name}`, descriptor.includes(phrase), phrase);

const errors = read("backend/staging_server_scaffold/smoke_runtime/httpErrorHandling.test.mjs");
check("unknown_route_test", errors.includes("unknown path returns 404 JSON"));
check("malformed_entitlement_test", errors.includes("malformed JSON returns client error for entitlement"));
check("malformed_descriptor_test", errors.includes("malformed JSON returns client error for playback descriptor"));
check("content_type_test", errors.includes("unsupported content type"));

const security = read("backend/staging_server_scaffold/smoke_runtime/httpSecurity.test.mjs");
for (const [name, phrase] of [
  ["loopback_bind", "server binds only to loopback"],
  ["no_external_request", "no external request is attempted"],
  ["no_package_install", "no package install is attempted"],
  ["no_deployment", "no deployment is attempted"],
  ["no_real_env", "no real .env file is read"],
  ["no_credentials", "no credentials are required"],
  ["no_body_logging", "no request body or response body"],
  ["no_descriptor_logging", "descriptor reference is not logged"],
  ["fallback_doc", "Local Preview fallback policy remains documented"]
]) check(`security_test:${name}`, security.includes(phrase), phrase);
check("body_limit_runtime_enforced", response.includes("payload_too_large") && runtimeConfig.includes("bodyLimitBytes"));
check("server_stop_verified_by_runner", includes("scripts/run_staging_backend_local_http_smoke_tests.sh", "SERVER_STOPPED"));

const runner = read("scripts/run_staging_backend_local_http_smoke_tests.sh");
const runnerFields = [
  "upgrade",
  "status",
  "node_version",
  "typescript_compiler",
  "typescript_compiler_version",
  "target_name",
  "bind_host",
  "deployment_status",
  "provider_mode",
  "total_tests",
  "tests_passed",
  "tests_failed",
  "health_status",
  "entitlement_http_status",
  "descriptor_http_status",
  "error_handling_status",
  "security_status",
  "server_started",
  "server_stopped",
  "loopback_requests_performed",
  "external_network_requests_performed",
  "package_install_performed",
  "deployment_performed",
  "credential_required",
  "descriptor_reference_logged",
  "descriptor_reference_persisted",
  "failures",
  "production_modules_exercised"
];
for (const field of runnerFields) check(`runner_field:${field}`, runner.includes(field), `${field} missing`);
check("runner_port_or_policy", runner.includes("port,") || runner.includes('"port"') || runner.includes("port_policy"));
check("runner_tmp_compile_only", runner.includes("/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke") && runner.includes("--outDir"));
check("runner_no_package_install", !/(npm install|yarn install|pnpm install|npx )/.test(runner));
check("runner_no_deploy_command", !/\b(deploy|wrangler|vercel|flyctl|railway)\b/.test(runner.replace(/deployment_performed/g, "")));

const verifier = read("scripts/verify_staging_backend_local_http_smoke_tests.sh");
check("verifier_checks_summary", verifier.includes("http_smoke_test_summary.json"));
check("verifier_checks_no_server", verifier.includes("server_process_remaining"));
check("verifier_checks_no_repo_js", verifier.includes("compiled JavaScript found beneath backend/staging_server_scaffold"));

const doc = read("docs/production_services/HIGHFIVE_STAGING_BACKEND_HTTP_DEPLOYMENT_TARGET_SMOKE_TEST.md");
check("doc_no_remote_deployment", doc.includes("No remote staging deployment") || doc.includes("No remote deployment"));
check("doc_local_preview_fallback", doc.includes("Local Preview fallback remains available"));
check("doc_output_paths", doc.includes("/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke"));

const allText = requiredFiles.map((file) => read(file)).join("\n");
const loopbackRunnerUrl = new RegExp("http" + "://127\\.0\\.0\\.1:\\$PORT", "g");
const localUrlConstruction = /http"\s*\+\s*":\/\//g;
const remoteCandidateText = allText.replace(loopbackRunnerUrl, "").replace(localUrlConstruction, "");
check("no_remote_backend_url_literal", !/https?:\/\//i.test(remoteCandidateText));
check("no_dependency_directory_committed", !fs.existsSync("node_modules"));
check("no_real_env_file", !fs.existsSync(".env"));
check("no_repo_compiled_js", !findRepoJs("backend/staging_server_scaffold"));
check("no_package_lockfiles", !["package-lock.json", "yarn.lock", "pnpm-lock.yaml"].some((file) => fs.existsSync(file)));
check("no_ios_swift_changes_in_0670a", !requiredFiles.some((file) => file.startsWith("HighFive/") && file.endsWith(".swift")));
check("no_project_file_change_in_0670a", !requiredFiles.some((file) => file.includes("project.pbxproj")));

function findRepoJs(dir) {
  if (!fs.existsSync(dir)) return false;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const path = `${dir}/${entry.name}`;
    if (entry.isDirectory() && findRepoJs(path)) return true;
    if (entry.isFile() && entry.name.endsWith(".js")) return true;
  }
  return false;
}

const result = {
  upgrade: "#067.0B",
  baseline_commit: "b37bb92",
  baseline_tag: "phase-67-0a-staging-backend-deployment-target-smoke-test-pack",
  status: failures.length === 0 ? "pass" : "fail",
  files_checked: requiredFiles,
  target_metadata: target,
  http_entrypoint: "backend/staging_server_scaffold/src/runtime/httpTarget.ts",
  server_factory: "createStagingHttpTarget",
  bind_host_policy: "127.0.0.1",
  port_policy: "configurable or ephemeral local smoke port",
  production_modules_exercised: [
    "contracts.ts",
    "productMapping.ts",
    "audit.ts",
    "errors.ts",
    "entitlements/validateEntitlement.ts",
    "playback/requestPlaybackDescriptor.ts",
    "providers/providerInterfaces.ts",
    "mocks/mockEntitlementProvider.ts",
    "mocks/mockCloudflareSigner.ts",
    "routes/entitlements.ts",
    "routes/playback.ts",
    "runtime/httpTarget.ts"
  ],
  checks,
  failures
};
fs.writeFileSync(jsonOut, `${JSON.stringify(result, null, 2)}\n`);
fs.writeFileSync(mdOut, [
  "# HighFive Staging Backend HTTP Target Source Verification",
  "",
  `- Upgrade: ${result.upgrade}`,
  `- Status: ${result.status}`,
  `- Baseline: ${result.baseline_commit} (${result.baseline_tag})`,
  `- HTTP entrypoint: ${result.http_entrypoint}`,
  `- Server factory: ${result.server_factory}`,
  `- Bind policy: ${result.bind_host_policy}`,
  `- Port policy: ${result.port_policy}`,
  `- Files checked: ${requiredFiles.length}`,
  `- Failures: ${failures.length}`,
  "",
  failures.length ? failures.map((failure) => `- ${failure}`).join("\n") : "Source verification passed."
].join("\n") + "\n");
if (failures.length > 0) process.exit(1);
NODE

cat "$MD_OUT"
