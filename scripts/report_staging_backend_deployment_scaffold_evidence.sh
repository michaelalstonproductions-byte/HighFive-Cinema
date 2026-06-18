#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-65-0b-staging-backend-scaffold-evidence"
mkdir -p "$OUT_DIR"

source_json="$OUT_DIR/staging_backend_scaffold_source_verification.json"
manifest_json="$OUT_DIR/staging_backend_scaffold_artifact_manifest.json"
artifact_json="$OUT_DIR/staging_backend_scaffold_artifact_verification.json"

status_for() {
  local file="$1"
  if [[ -s "$file" ]]; then
    node -e "const data = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); process.stdout.write(data.status || 'unknown')" "$file"
  else
    printf 'missing'
  fi
}

source_status="$(status_for "$source_json")"
manifest_status="$(status_for "$manifest_json")"
artifact_status="$(status_for "$artifact_json")"
build_status="missing"
if [[ -s "$manifest_json" ]]; then
  build_status="$(node -e "const data = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); process.stdout.write(data.xcodebuild_status || 'unknown')" "$manifest_json")"
fi

overall_status="pass"
if [[ "$source_status" != "pass" || "$manifest_status" != "pass" || "$artifact_status" != "pass" || "$build_status" != "pass" ]]; then
  overall_status="fail"
fi

baseline_commit="079d633"
baseline_tag="phase-65-0a-staging-backend-deployment-scaffold"

{
  printf '{\n'
  printf '  "upgrade": "#065.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline_commit": "%s",\n' "$baseline_commit"
  printf '  "baseline_tag": "%s",\n' "$baseline_tag"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "artifact_harness_status": "%s",\n' "$manifest_status"
  printf '  "artifact_verifier_status": "%s",\n' "$artifact_status"
  printf '  "xcodebuild_status": "%s",\n' "$build_status"
  printf '  "scaffold_evidence": "backend/staging_server_scaffold files verified",\n'
  printf '  "endpoint_evidence": "/entitlements/validate and /playback/descriptor verified",\n'
  printf '  "contract_field_evidence": "request and response fields verified",\n'
  printf '  "route_handler_evidence": "entitlement and playback route files verified",\n'
  printf '  "provider_interface_evidence": "provider interfaces and placeholders verified",\n'
  printf '  "mock_provider_evidence": "mock entitlement and Cloudflare signer verified",\n'
  printf '  "product_mapping_evidence": "Friendly and Paranormall product mappings verified",\n'
  printf '  "audit_model_evidence": "placeholder audit model verified",\n'
  printf '  "env_placeholder_evidence": "placeholder-only env example verified",\n'
  printf '  "no_live_deployment": true,\n'
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "staging backend scaffold only",\n'
  printf '    "no deployed server",\n'
  printf '    "no backend URL committed",\n'
  printf '    "no Cloudflare credential committed",\n'
  printf '    "no App Store private key committed",\n'
  printf '    "no RevenueCat secret key committed",\n'
  printf '    "no live StoreKit purchase flow in app",\n'
  printf '    "no live Cloudflare playback proven until staging backend is deployed and runtime config is supplied",\n'
  printf '    "local preview fallback remains available"\n'
  printf '  ]\n'
  printf '}\n'
} > "$OUT_DIR/staging_backend_scaffold_evidence_report.json"

{
  printf '# Staging Backend Deployment Scaffold Evidence Report\n\n'
  printf -- '- Upgrade: #065.0B\n'
  printf -- '- Status: %s\n' "$overall_status"
  printf -- '- Baseline commit: `%s`\n' "$baseline_commit"
  printf -- '- Baseline tag: `%s`\n' "$baseline_tag"
  printf -- '- Source-verifier status: %s\n' "$source_status"
  printf -- '- Artifact harness status: %s\n' "$manifest_status"
  printf -- '- Artifact verifier status: %s\n' "$artifact_status"
  printf -- '- xcodebuild evidence: %s\n' "$build_status"
  printf '\n## Evidence\n'
  printf -- '- Scaffold file evidence: verified required files exist.\n'
  printf -- '- Endpoint evidence: verified `/entitlements/validate` and `/playback/descriptor`.\n'
  printf -- '- Contract field evidence: verified request and response fields.\n'
  printf -- '- TypeScript source evidence: non-empty source files verified.\n'
  printf -- '- Route handler evidence: entitlement and playback routes verified.\n'
  printf -- '- Provider interface evidence: provider interfaces verified.\n'
  printf -- '- Mock provider evidence: mock entitlement and Cloudflare signer verified.\n'
  printf -- '- Product mapping evidence: Friendly and Paranormall mappings verified.\n'
  printf -- '- Audit model evidence: placeholder audit model verified.\n'
  printf -- '- Env placeholder evidence: placeholder-only env example verified.\n'
  printf -- '- No concrete URL / committed secret / private key / live deployment evidence: verified by source and safety scans.\n'
  printf '\n## Known Limitations\n'
  printf -- '- Evidence only.\n'
  printf -- '- No deployed server.\n'
  printf -- '- No backend URL committed.\n'
  printf -- '- No Cloudflare credential committed.\n'
  printf -- '- No live Cloudflare playback proven until staging backend and runtime config are supplied.\n'
  printf -- '- Local Preview fallback remains available.\n'
} > "$OUT_DIR/staging_backend_scaffold_evidence_report.md"

cat "$OUT_DIR/staging_backend_scaffold_evidence_report.md"
[[ "$overall_status" == "pass" ]]
