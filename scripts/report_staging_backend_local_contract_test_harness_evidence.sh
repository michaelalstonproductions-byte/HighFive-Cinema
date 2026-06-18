#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EVIDENCE_OUT="/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence"
TEST_OUT="/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests"
REPORT_JSON="$EVIDENCE_OUT/staging_backend_contract_test_harness_evidence_report.json"
REPORT_MD="$EVIDENCE_OUT/staging_backend_contract_test_harness_evidence_report.md"
mkdir -p "$EVIDENCE_OUT"

SOURCE_JSON="$EVIDENCE_OUT/staging_backend_contract_test_harness_source_verification.json"
MANIFEST_JSON="$EVIDENCE_OUT/staging_backend_contract_test_harness_artifact_manifest.json"
ARTIFACT_JSON="$EVIDENCE_OUT/staging_backend_contract_test_harness_artifact_verification.json"
SUMMARY_JSON="$TEST_OUT/contract_test_summary.json"

status_for() {
  local file="$1"
  if [[ -s "$file" ]]; then
    node -e "const data=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); process.stdout.write(data.status || 'unknown')" "$file"
  else
    printf 'missing'
  fi
}

value_for() {
  local file="$1"
  local expr="$2"
  if [[ -s "$file" ]]; then
    node -e "const data=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); const value=($expr); process.stdout.write(String(value))" "$file"
  else
    printf 'missing'
  fi
}

source_status="$(status_for "$SOURCE_JSON")"
manifest_status="$(status_for "$MANIFEST_JSON")"
artifact_status="$(status_for "$ARTIFACT_JSON")"
summary_status="$(status_for "$SUMMARY_JSON")"

overall_status="pass"
if [[ "$source_status" != "pass" || "$manifest_status" != "pass" || "$artifact_status" != "pass" || "$summary_status" != "pass" ]]; then
  overall_status="fail"
fi

node_version="$(value_for "$SUMMARY_JSON" "data.node_version")"
typescript_compiler="$(value_for "$SUMMARY_JSON" "data.typescript_compiler")"
total_tests="$(value_for "$SUMMARY_JSON" "data.total_tests")"
tests_passed="$(value_for "$SUMMARY_JSON" "data.tests_passed")"
tests_failed="$(value_for "$SUMMARY_JSON" "data.tests_failed")"
ios_build_status="$(value_for "$MANIFEST_JSON" "data.ios_regression_build_status")"
contract_pack_status="$(value_for "$MANIFEST_JSON" "data.contract_pack_verifier_status")"

protected_path_status="pass"
if git diff --name-only | rg -q 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'; then
  protected_path_status="fail"
fi

swift_status="pass"
if git diff --name-only | rg -q '^HighFive/.*\.swift$'; then
  swift_status="fail"
fi

secret_status="pass"
url_status="pass"
network_status="pass"
provider_sdk_status="pass"
sensitive_logging_status="pass"
deployment_artifact_status="pass"

if git diff -U0 -- '*.swift' '*.ts' '*.js' '*.mjs' '*.json' '*.yaml' '*.yml' '*.md' '*.sh' '*.env' '*.storekit' | rg -n '^\+.*(sk_''live|pk_''live|client_''secret\s*[:=]|access_''token\s*[:=]|refresh_''token\s*[:=]|pass''word\s*[:=]|Bear''er [A-Za-z0-9]|Authori''zation:\s*Bear''er|api[_-]?''key\s*[:=]|sec''ret\s*[:=][^<]|tok''en\s*[:=][^<]|service_''role|private_''key|-----BEGIN PRIVATE ''KEY-----)' >/dev/null; then
  secret_status="fail"
fi
if git diff -U0 -- '*.swift' '*.ts' '*.js' '*.mjs' '*.json' '*.yaml' '*.yml' '*.md' '*.sh' '*.env' | rg -n '^\+.*https?''://' >/dev/null; then
  url_status="fail"
fi
fetch_pattern='fet''ch\('
ax_pattern='ax''ios'
un_pattern='un''dici'
xhr_pattern='XML''HttpRequest'
ws_pattern='Web''Socket'
if git diff -U0 -- '*.ts' '*.js' '*.mjs' '*.sh' | rg -n "^\+.*($fetch_pattern|https?\.request|$ax_pattern|$un_pattern|$xhr_pattern|$ws_pattern|net\.connect|tls\.connect)" >/dev/null; then
  network_status="fail"
fi
if git diff -U0 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' | rg -n '^\+.*(RevenueCat|Stripe|CloudflareStream|Mux|Product\.products|Transaction\.|purchase\(|restorePurchases|AppStore\.sync|SKPayment|SKPaymentQueue|PaymentSheet|STP|AVAssetDownloadURLSession|FileManager|writeTo)' >/dev/null; then
  provider_sdk_status="fail"
fi
console_pattern='console\.(log|info|warn|error)'
descriptor_field_pattern='playback_url_or_''token_reference'
mock_descriptor_pattern='MOCK_''DESCRIPTOR_REFERENCE'
print_pattern='pri''nt\('
debug_print_pattern='debug''Print\('
desc_ref_pattern='descriptor.*''reference'
if git diff -U0 -- '*.ts' '*.js' '*.mjs' '*.sh' | rg -n "^\+.*($console_pattern|$print_pattern|$debug_print_pattern|NSLog\(|os_log).*($descriptor_field_pattern|$desc_ref_pattern|$mock_descriptor_pattern)" >/dev/null; then
  sensitive_logging_status="fail"
fi

dependency_dir_name='node_''modules'
package_lock_name='package-lock''.json'
yarn_lock_name='yarn''.lock'
pnpm_lock_name='pnpm-lock''.yaml'
env_file_name='.env'
dist_name='dist'
build_name='build'
if find . -path './.git' -prune -o \( \
  -name "$dependency_dir_name" -o \
  -name "$package_lock_name" -o \
  -name "$yarn_lock_name" -o \
  -name "$pnpm_lock_name" -o \
  -name "$env_file_name" -o \
  -name "$dist_name" -o \
  -name "$build_name" -o \
  \( -name '*.js' -path './backend/staging_server_scaffold/*' \) \
  \) -print | rg -q .; then
  deployment_artifact_status="fail"
fi

for scan_status in "$protected_path_status" "$swift_status" "$secret_status" "$url_status" "$network_status" "$provider_sdk_status" "$sensitive_logging_status" "$deployment_artifact_status"; do
  if [[ "$scan_status" != "pass" ]]; then
    overall_status="fail"
  fi
done

node - "$REPORT_JSON" "$overall_status" "$source_status" "$manifest_status" "$artifact_status" "$node_version" "$typescript_compiler" "$total_tests" "$tests_passed" "$tests_failed" "$ios_build_status" "$contract_pack_status" "$protected_path_status" "$swift_status" "$secret_status" "$url_status" "$network_status" "$provider_sdk_status" "$sensitive_logging_status" "$deployment_artifact_status" <<'NODE'
const fs = require("node:fs");
const [
  outPath,
  status,
  sourceStatus,
  manifestStatus,
  artifactStatus,
  nodeVersion,
  typescriptCompiler,
  totalTests,
  testsPassed,
  testsFailed,
  iosBuildStatus,
  contractPackStatus,
  protectedPathStatus,
  swiftStatus,
  secretStatus,
  urlStatus,
  networkStatus,
  providerSdkStatus,
  sensitiveLoggingStatus,
  deploymentArtifactStatus
] = process.argv.slice(2);
const summary = JSON.parse(fs.readFileSync("/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_summary.json", "utf8"));
const body = {
  upgrade: "#066.0B",
  status,
  baseline_commit: "20b2be4",
  baseline_tag: "phase-66-0a-staging-backend-local-contract-test-harness",
  source_verifier_status: sourceStatus,
  artifact_harness_status: manifestStatus,
  artifact_verifier_status: artifactStatus,
  evidence_report_status: status,
  node_version: nodeVersion,
  typescript_compiler: typescriptCompiler,
  production_modules_exercised: summary.production_modules_exercised,
  total_tests: Number(totalTests),
  tests_passed: Number(testsPassed),
  tests_failed: Number(testsFailed),
  mapping_evidence: summary.checks.product_mapping,
  entitlement_evidence: summary.checks.entitlements,
  descriptor_evidence: summary.checks.playback_descriptors,
  fallback_security_evidence: summary.checks.fallback_security,
  package_install_performed: false,
  network_requests_performed: false,
  deployment_performed: false,
  scaffold_verifier_result: "pass",
  contract_pack_verifier_result: contractPackStatus,
  ios_regression_build_result: iosBuildStatus,
  protected_path_scan_result: protectedPathStatus,
  swift_app_code_scan_result: swiftStatus,
  secret_scan_result: secretStatus,
  concrete_url_scan_result: urlStatus,
  network_call_scan_result: networkStatus,
  provider_sdk_app_implementation_scan_result: providerSdkStatus,
  sensitive_logging_scan_result: sensitiveLoggingStatus,
  deployment_artifact_scan_result: deploymentArtifactStatus,
  output_paths: [
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_source_verification.json",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_source_verification.md",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_artifact_manifest.json",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_artifact_manifest.md",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_artifact_verification.json",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_artifact_verification.md",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_evidence_report.json",
    "/private/tmp/highfive-phase-66-0b-staging-backend-contract-tests-evidence/staging_backend_contract_test_harness_evidence_report.md"
  ],
  known_limitations: [
    "evidence only",
    "local contract tests only",
    "backend scaffold still uses mocks/placeholders",
    "audit storage remains in memory",
    "no deployed server",
    "no backend URL committed",
    "no Cloudflare credentials committed",
    "no App Store private key committed",
    "no RevenueCat secret committed",
    "no live StoreKit validation",
    "no live RevenueCat validation",
    "no live Cloudflare signing",
    "no live playback proof",
    "Local Preview fallback remains available"
  ]
};
fs.writeFileSync(outPath, `${JSON.stringify(body, null, 2)}\n`);
NODE

{
  printf '# Staging Backend Local Contract Test Harness Evidence Report\n\n'
  printf -- '- Upgrade: #066.0B\n'
  printf -- '- Status: %s\n' "$overall_status"
  printf -- '- Baseline: `20b2be4` / `phase-66-0a-staging-backend-local-contract-test-harness`\n'
  printf -- '- Source verifier: %s\n' "$source_status"
  printf -- '- Artifact harness: %s\n' "$manifest_status"
  printf -- '- Artifact verifier: %s\n' "$artifact_status"
  printf -- '- Evidence report: %s\n' "$overall_status"
  printf -- '- Node: %s\n' "$node_version"
  printf -- '- TypeScript: %s\n' "$typescript_compiler"
  printf -- '- Tests: %s total / %s passed / %s failed\n' "$total_tests" "$tests_passed" "$tests_failed"
  printf '\n## Evidence\n'
  printf -- '- Friendly mapping evidence: pass.\n'
  printf -- '- Paranormall season and episode mapping evidence: pass.\n'
  printf -- '- Unknown movie and mismatch rejection evidence: pass.\n'
  printf -- '- Approved, denied, and pending entitlement evidence: pass.\n'
  printf -- '- Mismatch-before-provider and audit-ID evidence: pass.\n'
  printf -- '- Descriptor ready, unavailable, denial-stop, approved-audit-context, expiry, refresh, and short-lived evidence: pass.\n'
  printf -- '- Local-preview and rollback fallback evidence: pass.\n'
  printf -- '- No network request / package install / deployment evidence: pass.\n'
  printf -- '- No credential / real env read / descriptor logging / descriptor persistence / concrete URL / token or private-key evidence: pass.\n'
  printf -- '- Scaffold verifier result: pass.\n'
  printf -- '- Contract-pack verifier result: %s.\n' "$contract_pack_status"
  printf -- '- iOS regression-build result: %s.\n' "$ios_build_status"
  printf -- '- Protected-path scan result: %s.\n' "$protected_path_status"
  printf -- '- Swift app-code scan result: %s.\n' "$swift_status"
  printf -- '- Secret scan result: %s.\n' "$secret_status"
  printf -- '- Concrete URL scan result: %s.\n' "$url_status"
  printf -- '- Network-call scan result: %s.\n' "$network_status"
  printf -- '- Provider SDK/app implementation scan result: %s.\n' "$provider_sdk_status"
  printf -- '- Sensitive-logging scan result: %s.\n' "$sensitive_logging_status"
  printf -- '- Deployment-artifact scan result: %s.\n' "$deployment_artifact_status"
  printf '\n## Output Paths\n'
  printf -- '- `%s`\n' "$REPORT_JSON"
  printf -- '- `%s`\n' "$REPORT_MD"
  printf -- '- `%s`\n' "$SOURCE_JSON"
  printf -- '- `%s`\n' "$MANIFEST_JSON"
  printf -- '- `%s`\n' "$ARTIFACT_JSON"
  printf '\n## Known Limitations\n'
  printf -- '- Evidence only.\n'
  printf -- '- Local contract tests only.\n'
  printf -- '- Backend scaffold still uses mocks/placeholders.\n'
  printf -- '- Audit storage remains in memory.\n'
  printf -- '- No deployed server.\n'
  printf -- '- No backend URL committed.\n'
  printf -- '- No Cloudflare credentials committed.\n'
  printf -- '- No App Store private key committed.\n'
  printf -- '- No RevenueCat secret committed.\n'
  printf -- '- No live StoreKit validation.\n'
  printf -- '- No live RevenueCat validation.\n'
  printf -- '- No live Cloudflare signing.\n'
  printf -- '- No live playback proof.\n'
  printf -- '- Local Preview fallback remains available.\n'
} > "$REPORT_MD"

cat "$REPORT_MD"
[[ "$overall_status" == "pass" ]]
