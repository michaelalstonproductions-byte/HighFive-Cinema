#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke"
COMPILED_DIR="$OUT_DIR/compiled"
LOG_FILE="$OUT_DIR/server.log"
PID_FILE="$OUT_DIR/server.pid"
READY_FILE="$OUT_DIR/server.ready"
TAP_FILE="$OUT_DIR/http_smoke_test_output.tap"
SUMMARY_JSON="$OUT_DIR/http_smoke_test_summary.json"
SUMMARY_MD="$OUT_DIR/http_smoke_test_summary.md"
SCAFFOLD_DIR="backend/staging_server_scaffold"

rm -rf "$OUT_DIR"
mkdir -p "$COMPILED_DIR"

if ! command -v node >/dev/null 2>&1; then
  printf 'Node is required for local HTTP smoke tests.\n' >&2
  exit 1
fi
if ! command -v tsc >/dev/null 2>&1; then
  printf 'TypeScript compiler must be installed globally outside this repository.\n' >&2
  exit 1
fi

NODE_VERSION="$(node --version)"
TSC_PATH="$(command -v tsc)"
TSC_VERSION="$(tsc --version)"

tsc -p "$SCAFFOLD_DIR/tsconfig.http-target.json" --outDir "$COMPILED_DIR" --pretty false

HIGHFIVE_SERVER_HOST="127.0.0.1" \
HIGHFIVE_SERVER_PORT="0" \
HIGHFIVE_PROVIDER_MODE="mock" \
HIGHFIVE_MOCK_ENTITLEMENT_MODE="approved" \
HIGHFIVE_MOCK_DESCRIPTOR_MODE="ready" \
HIGHFIVE_BACKEND_ENV="local_smoke" \
HIGHFIVE_READY_FILE="$READY_FILE" \
node "$COMPILED_DIR/runtime/start.js" > "$LOG_FILE" 2>&1 &
SERVER_PID="$!"
printf '%s\n' "$SERVER_PID" > "$PID_FILE"

cleanup() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE")"
    if [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid" >/dev/null 2>&1 || true
      for _ in {1..50}; do
        if ! kill -0 "$pid" >/dev/null 2>&1; then
          break
        fi
        sleep 0.1
      done
      if kill -0 "$pid" >/dev/null 2>&1; then
        kill -9 "$pid" >/dev/null 2>&1 || true
      fi
    fi
  fi
}
trap cleanup EXIT

for _ in {1..100}; do
  if [[ -s "$READY_FILE" ]]; then
    break
  fi
  if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    printf 'HTTP smoke server exited before readiness.\n' >&2
    cat "$LOG_FILE" >&2 || true
    exit 1
  fi
  sleep 0.1
done

if [[ ! -s "$READY_FILE" ]]; then
  printf 'HTTP smoke server did not become ready before timeout.\n' >&2
  cat "$LOG_FILE" >&2 || true
  exit 1
fi

PORT="$(node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); process.stdout.write(String(data.port));" "$READY_FILE")"
BASE_URL="http://127.0.0.1:$PORT"

set +e
HIGHFIVE_HTTP_SMOKE_BASE_URL="$BASE_URL" \
HIGHFIVE_HTTP_SMOKE_OUT_DIR="$OUT_DIR" \
HIGHFIVE_HTTP_SMOKE_EXTERNAL_NETWORK_REQUESTS="false" \
HIGHFIVE_HTTP_SMOKE_PACKAGE_INSTALL="false" \
HIGHFIVE_HTTP_SMOKE_DEPLOYMENT="false" \
HIGHFIVE_HTTP_SMOKE_ENV_FILE_READ="false" \
node --test --test-reporter=tap "$SCAFFOLD_DIR"/smoke_runtime/*.test.mjs > "$TAP_FILE" 2>&1
TEST_EXIT_CODE=$?
set -e

cleanup
trap - EXIT

SERVER_STOPPED="false"
if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
  SERVER_STOPPED="true"
fi

SENSITIVE_LOG_FAILURES=()
if rg -n 'playback_url_or_token_reference|MOCK_DESCRIPTOR_REFERENCE|Cloudflare|RevenueCat|APP_STORE|PRIVATE_KEY' "$LOG_FILE" "$TAP_FILE"; then
  SENSITIVE_LOG_FAILURES+=("sensitive descriptor or provider material found in logs")
fi

node - "$TAP_FILE" "$SUMMARY_JSON" "$SUMMARY_MD" "$NODE_VERSION" "$TSC_PATH" "$TSC_VERSION" "$PORT" "$TEST_EXIT_CODE" "$SERVER_STOPPED" "${SENSITIVE_LOG_FAILURES[@]+"${SENSITIVE_LOG_FAILURES[@]}"}" <<'NODE'
const fs = require("node:fs");
const [
  tapPath,
  summaryJsonPath,
  summaryMdPath,
  nodeVersion,
  tscPath,
  tscVersion,
  portText,
  exitCodeText,
  serverStoppedText,
  ...extraFailures
] = process.argv.slice(2);
const tap = fs.readFileSync(tapPath, "utf8");
const exitCode = Number(exitCodeText);
const port = Number(portText);

function numericFooter(label) {
  const match = tap.match(new RegExp(`^# ${label} (\\d+)$`, "m"));
  return match ? Number(match[1]) : 0;
}

function resultFor(name) {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  if (new RegExp(`^ok \\d+ - ${escaped}$`, "m").test(tap)) return "pass";
  if (new RegExp(`^not ok \\d+ - ${escaped}$`, "m").test(tap)) return "fail";
  return "not_found";
}

function groupStatus(names) {
  return names.every((name) => resultFor(name) === "pass") ? "pass" : "fail";
}

const total = numericFooter("tests");
const passed = numericFooter("pass");
const failed = numericFooter("fail");
const healthNames = [
  "health: GET /health returns 200",
  "health: body reports local smoke runtime",
  "health: response contains no credential or URL value",
  "health: POST /health returns 405"
];
const entitlementNames = [
  "entitlement http: Friendly approved request returns entitlement_approved",
  "entitlement http: Paranormall season approved request returns entitlement_approved",
  "entitlement http: Paranormall episode request uses correct product mapping",
  "entitlement http: denied mode returns entitlement_denied",
  "entitlement http: pending mode returns entitlement_pending",
  "entitlement http: unknown movie is rejected",
  "entitlement http: movie/product mismatch is rejected before provider approval",
  "entitlement http: missing required fields return a client error",
  "entitlement http: GET /entitlements/validate returns 405"
];
const descriptorNames = [
  "playback descriptor http: approved entitlement audit can request descriptor",
  "playback descriptor http: ready signer returns descriptor_ready with expiry and refresh",
  "playback descriptor http: unavailable signer returns descriptor_unavailable",
  "playback descriptor http: denied entitlement audit does not issue descriptor",
  "playback descriptor http: unknown audit ID does not issue descriptor",
  "playback descriptor http: mismatched movie/product pair does not issue descriptor",
  "playback descriptor http: GET /playback/descriptor returns 405",
  "playback descriptor http: descriptor response contains no provider credential"
];
const errorNames = [
  "error handling http: unknown path returns 404 JSON",
  "error handling http: malformed JSON returns client error for entitlement",
  "error handling http: malformed JSON returns client error for playback descriptor",
  "error handling http: unsupported content type returns client error"
];
const securityNames = [
  "security http: server binds only to loopback",
  "security http: no external request is attempted",
  "security http: no package install is attempted",
  "security http: no deployment is attempted",
  "security http: no real .env file is read",
  "security http: no credentials are required",
  "security http: server log contains no request body or response body",
  "security http: descriptor reference is not logged",
  "security http: Local Preview fallback policy remains documented"
];

const failures = [...extraFailures];
if (exitCode !== 0) failures.push("node_test_failure");
if (failed !== 0) failures.push("http_smoke_test_failure");
if (serverStoppedText !== "true") failures.push("server_not_stopped");

const summary = {
  upgrade: "#067.0A",
  status: failures.length === 0 ? "pass" : "fail",
  node_version: nodeVersion,
  typescript_compiler: tscPath,
  typescript_compiler_version: tscVersion,
  target_name: "highfive-staging-node-http",
  bind_host: "127.0.0.1",
  port,
  deployment_status: "not_deployed",
  provider_mode: "mock",
  total_tests: total,
  tests_passed: passed,
  tests_failed: failed,
  health_status: groupStatus(healthNames),
  entitlement_http_status: groupStatus(entitlementNames),
  descriptor_http_status: groupStatus(descriptorNames),
  error_handling_status: groupStatus(errorNames),
  security_status: groupStatus(securityNames),
  server_started: true,
  server_stopped: serverStoppedText === "true",
  loopback_requests_performed: true,
  external_network_requests_performed: false,
  package_install_performed: false,
  deployment_performed: false,
  credential_required: false,
  descriptor_reference_logged: false,
  descriptor_reference_persisted: false,
  failures,
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
  ]
};

fs.writeFileSync(summaryJsonPath, `${JSON.stringify(summary, null, 2)}\n`);
fs.writeFileSync(
  summaryMdPath,
  [
    "# HighFive Staging Backend HTTP Smoke Test Summary",
    "",
    `- Upgrade: #067.0A`,
    `- Status: ${summary.status}`,
    `- Target: ${summary.target_name}`,
    `- Bind host: ${summary.bind_host}`,
    `- Port: ${summary.port}`,
    `- Deployment status: ${summary.deployment_status}`,
    `- Provider mode: ${summary.provider_mode}`,
    `- Tests: ${total} total / ${passed} passed / ${failed} failed`,
    `- Health status: ${summary.health_status}`,
    `- Entitlement HTTP status: ${summary.entitlement_http_status}`,
    `- Descriptor HTTP status: ${summary.descriptor_http_status}`,
    `- Error handling status: ${summary.error_handling_status}`,
    `- Security status: ${summary.security_status}`,
    `- Server started: ${summary.server_started}`,
    `- Server stopped: ${summary.server_stopped}`,
    `- External network requests performed: false`,
    `- Package install performed: false`,
    `- Deployment performed: false`,
    ""
  ].join("\n")
);
NODE

cat "$SUMMARY_MD"

if [[ "$TEST_EXIT_CODE" -ne 0 ]]; then
  exit "$TEST_EXIT_CODE"
fi
if [[ "$SERVER_STOPPED" != "true" ]]; then
  exit 1
fi
if [[ "${#SENSITIVE_LOG_FAILURES[@]}" -gt 0 ]]; then
  exit 1
fi

failed_tests="$(node -e "const s=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); process.stdout.write(String(s.tests_failed));" "$SUMMARY_JSON")"
[[ "$failed_tests" == "0" ]]
