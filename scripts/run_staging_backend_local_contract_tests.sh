#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests"
COMPILED_DIR="$OUT_DIR/compiled"
TAP_FILE="$OUT_DIR/contract_test_output.tap"
SUMMARY_JSON="$OUT_DIR/contract_test_summary.json"
SUMMARY_MD="$OUT_DIR/contract_test_summary.md"
SCAFFOLD_DIR="backend/staging_server_scaffold"

rm -rf "$OUT_DIR"
mkdir -p "$COMPILED_DIR"

if ! command -v tsc >/dev/null 2>&1; then
  printf 'TypeScript compiler must be installed globally outside this repository.\n' >&2
  exit 1
fi

NODE_VERSION="$(node --version)"
TSC_VERSION="$(tsc --version)"

tsc -p "$SCAFFOLD_DIR/tsconfig.contract-tests.json" --pretty false

set +e
HIGHFIVE_CONTRACT_TEST_COMPILED_ROOT="$COMPILED_DIR" node --test --test-reporter=tap "$SCAFFOLD_DIR"/test_runtime/*.test.mjs > "$TAP_FILE" 2>&1
TEST_EXIT_CODE=$?
set -e

node - "$TAP_FILE" "$SUMMARY_JSON" "$SUMMARY_MD" "$NODE_VERSION" "$TSC_VERSION" "$TEST_EXIT_CODE" <<'NODE'
const fs = require("node:fs");
const [tapPath, summaryJsonPath, summaryMdPath, nodeVersion, tscVersion, exitCodeText] = process.argv.slice(2);
const tap = fs.readFileSync(tapPath, "utf8");
const exitCode = Number(exitCodeText);

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

const checks = {
  product_mapping: {
    friendly: resultFor("product mapping: Friendly mapping"),
    paranormall_season: resultFor("product mapping: Paranormall season mapping"),
    paranormall_episodes_1_through_7: Array.from({ length: 7 }, (_, index) =>
      resultFor(`product mapping: Paranormall episode ${index + 1}`)
    ),
    unknown_movie_rejection: resultFor("product mapping: unknown movie rejection"),
    movie_product_mismatch_rejection: resultFor("product mapping: movie/product mismatch rejection")
  },
  entitlements: {
    approved: resultFor("entitlement flow: approved result"),
    denied: resultFor("entitlement flow: denied result"),
    pending: resultFor("entitlement flow: pending result"),
    mismatch_denied_before_provider_approval: resultFor("entitlement flow: mismatch denied before provider approval"),
    audit_id_produced: resultFor("entitlement flow: audit ID produced"),
    app_provided_entitlement_state_not_trusted: resultFor(
      "entitlement flow: app-provided entitlement state is not trusted"
    )
  },
  playback_descriptors: {
    denial_stops_descriptor: resultFor("playback descriptor flow: denial prevents descriptor issuance"),
    approved_audit_context_required: resultFor("playback descriptor flow: approved audit context required"),
    unavailable_signer: resultFor("playback descriptor flow: unavailable signer returns descriptor_unavailable"),
    ready_signer: resultFor("playback descriptor flow: ready signer returns descriptor_ready"),
    ready_includes_expires_at: resultFor("playback descriptor flow: ready result includes expires_at"),
    ready_includes_refresh_after: resultFor("playback descriptor flow: ready result includes refresh_after"),
    placeholder_reference_only: resultFor("playback descriptor flow: descriptor reference is placeholder/mock only"),
    no_provider_credentials: resultFor("playback descriptor flow: descriptor response contains no provider credentials"),
    short_lived: resultFor("playback descriptor flow: descriptor is short-lived")
  },
  fallback_security: {
    provider_unavailable_preserves_local_preview_fallback: resultFor(
      "local fallback: provider unavailable preserves local_preview_fallback"
    ),
    missing_approval_preserves_local_preview_fallback: resultFor(
      "local fallback: missing approval preserves local_preview_fallback"
    ),
    invalid_mapping_preserves_local_preview_fallback: resultFor(
      "local fallback: invalid mapping preserves local_preview_fallback"
    ),
    rollback_state_preserves_local_preview_fallback: resultFor(
      "local fallback: rollback state preserves local_preview_fallback"
    ),
    no_network_calls: resultFor("security behavior: no fetch/HTTP/HTTPS/WebSocket/network calls"),
    no_real_env_reads: resultFor("security behavior: no real .env reads"),
    no_credentials_required: resultFor("security behavior: no credentials required"),
    descriptor_references_not_logged: resultFor("security behavior: descriptor references are not logged"),
    descriptor_references_not_persisted: resultFor("security behavior: descriptor references are not persisted"),
    no_concrete_url: resultFor("security behavior: descriptor contains no concrete URL"),
    no_token_or_private_key: resultFor("security behavior: descriptor contains no token or private key")
  }
};

const total = numericFooter("tests");
const passed = numericFooter("pass");
const failed = numericFooter("fail");
const status = exitCode === 0 && failed === 0 ? "pass" : "fail";

function groupStatus(group) {
  const values = Object.values(group).flat();
  return values.every((value) => value === "pass") ? "pass" : "fail";
}

const summary = {
  upgrade: "#066.0A",
  status,
  node_version: nodeVersion,
  typescript_compiler: tscVersion,
  typescript_compiler_version: tscVersion,
  compiled_output_dir: "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/compiled",
  tap_output: tapPath,
  total_tests: total,
  tests_passed: passed,
  tests_failed: failed,
  passed_tests: passed,
  failed_tests: failed,
  product_mapping_status: groupStatus(checks.product_mapping),
  entitlement_flow_status: groupStatus(checks.entitlements),
  playback_descriptor_status: groupStatus(checks.playback_descriptors),
  local_fallback_status: groupStatus({
    provider_unavailable_preserves_local_preview_fallback:
      checks.fallback_security.provider_unavailable_preserves_local_preview_fallback,
    missing_approval_preserves_local_preview_fallback:
      checks.fallback_security.missing_approval_preserves_local_preview_fallback,
    invalid_mapping_preserves_local_preview_fallback:
      checks.fallback_security.invalid_mapping_preserves_local_preview_fallback,
    rollback_state_preserves_local_preview_fallback:
      checks.fallback_security.rollback_state_preserves_local_preview_fallback
  }),
  security_behavior_status: groupStatus({
    no_network_calls: checks.fallback_security.no_network_calls,
    no_real_env_reads: checks.fallback_security.no_real_env_reads,
    no_credentials_required: checks.fallback_security.no_credentials_required,
    descriptor_references_not_logged: checks.fallback_security.descriptor_references_not_logged,
    descriptor_references_not_persisted: checks.fallback_security.descriptor_references_not_persisted,
    no_concrete_url: checks.fallback_security.no_concrete_url,
    no_token_or_private_key: checks.fallback_security.no_token_or_private_key
  }),
  network_requests_performed: false,
  package_install_performed: false,
  deployment_performed: false,
  failures: failed === 0 ? [] : ["node_test_failure"],
  production_modules_exercised: [
    "contracts.ts",
    "productMapping.ts",
    "audit.ts",
    "errors.ts",
    "entitlements/validateEntitlement.ts",
    "playback/requestPlaybackDescriptor.ts",
    "providers/providerInterfaces.ts",
    "providers/revenueCatValidator.ts",
    "mocks/mockEntitlementProvider.ts",
    "mocks/mockCloudflareSigner.ts"
  ],
  checks
};

fs.writeFileSync(summaryJsonPath, `${JSON.stringify(summary, null, 2)}\n`);
fs.writeFileSync(
  summaryMdPath,
  [
    "# HighFive Staging Backend Local Contract Test Summary",
    "",
    `- Upgrade: #066.0A`,
    `- Status: ${status}`,
    `- Node: ${nodeVersion}`,
    `- TypeScript: ${tscVersion}`,
    `- Total tests: ${total}`,
    `- Passed: ${passed}`,
    `- Failed: ${failed}`,
    `- Network requests performed: false`,
    `- Package install performed: false`,
    `- Deployment performed: false`,
    `- TAP output: ${tapPath}`,
    `- Compiled output: /private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/compiled`,
    ""
  ].join("\n")
);
NODE

cat "$SUMMARY_MD"

if [[ "$TEST_EXIT_CODE" -ne 0 ]]; then
  exit "$TEST_EXIT_CODE"
fi

failed_tests="$(node -e "process.stdout.write(String(JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')).failed_tests))" "$SUMMARY_JSON")"
[[ "$failed_tests" == "0" ]]
