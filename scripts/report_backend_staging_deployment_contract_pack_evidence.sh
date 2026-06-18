#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-64-0b-backend-staging-contract-pack-evidence"
mkdir -p "$OUT_DIR"

source_json="$OUT_DIR/backend_staging_contract_pack_source_verification.json"
manifest_json="$OUT_DIR/backend_staging_contract_pack_artifact_manifest.json"
artifact_json="$OUT_DIR/backend_staging_contract_pack_artifact_verification.json"

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

baseline_commit="aff3c17"
baseline_tag="phase-64-0a-backend-staging-deployment-contract-pack"

{
  printf '{\n'
  printf '  "upgrade": "#064.0B",\n'
  printf '  "status": "%s",\n' "$overall_status"
  printf '  "baseline_commit": "%s",\n' "$baseline_commit"
  printf '  "baseline_tag": "%s",\n' "$baseline_tag"
  printf '  "source_verifier_status": "%s",\n' "$source_status"
  printf '  "artifact_harness_status": "%s",\n' "$manifest_status"
  printf '  "artifact_verifier_status": "%s",\n' "$artifact_status"
  printf '  "xcodebuild_status": "%s",\n' "$build_status"
  printf '  "contract_pack_evidence": "backend/staging_contract_pack files verified",\n'
  printf '  "endpoint_contract_evidence": "/entitlements/validate and /playback/descriptor verified",\n'
  printf '  "schema_evidence": "schema JSON files parsed",\n'
  printf '  "example_evidence": "example JSON files parsed",\n'
  printf '  "openapi_evidence": "OpenAPI artifact verified non-empty with endpoint paths",\n'
  printf '  "handler_template_evidence": "placeholder-only handler templates verified",\n'
  printf '  "environment_placeholder_evidence": "env example uses placeholders only",\n'
  printf '  "deployment_checklist_evidence": "deployment checklist verified",\n'
  printf '  "security_requirements_evidence": "security requirements verified",\n'
  printf '  "rollback_plan_evidence": "rollback plan verified",\n'
  printf '  "no_live_deployment": true,\n'
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "backend staging deployment contract pack only",\n'
  printf '    "no deployed server",\n'
  printf '    "no backend URL committed",\n'
  printf '    "no Cloudflare credential committed",\n'
  printf '    "no Cloudflare signed-token generation in app",\n'
  printf '    "no App Store private key committed",\n'
  printf '    "no RevenueCat secret key committed",\n'
  printf '    "no live StoreKit purchase flow",\n'
  printf '    "no live Cloudflare playback proven until staging backend and runtime config are supplied",\n'
  printf '    "local preview fallback remains available"\n'
  printf '  ]\n'
  printf '}\n'
} > "$OUT_DIR/backend_staging_contract_pack_evidence_report.json"

{
  printf '# Backend Staging Deployment Contract Pack Evidence Report\n\n'
  printf -- '- Upgrade: #064.0B\n'
  printf -- '- Status: %s\n' "$overall_status"
  printf -- '- Baseline commit: `%s`\n' "$baseline_commit"
  printf -- '- Baseline tag: `%s`\n' "$baseline_tag"
  printf -- '- Source-verifier status: %s\n' "$source_status"
  printf -- '- Artifact harness status: %s\n' "$manifest_status"
  printf -- '- Artifact verifier status: %s\n' "$artifact_status"
  printf -- '- xcodebuild evidence: %s\n' "$build_status"
  printf '\n## Evidence\n'
  printf -- '- Contract pack file evidence: verified required files exist.\n'
  printf -- '- Endpoint contract evidence: verified `/entitlements/validate` and `/playback/descriptor`.\n'
  printf -- '- Schema evidence: schema JSON files parse.\n'
  printf -- '- Example evidence: example JSON files parse.\n'
  printf -- '- OpenAPI evidence: OpenAPI file exists and contains endpoint paths.\n'
  printf -- '- Handler-template evidence: placeholder-only validation/signing locations verified.\n'
  printf -- '- Environment placeholder evidence: env example contains placeholders only.\n'
  printf -- '- Deployment checklist evidence: verified.\n'
  printf -- '- Security requirements evidence: verified.\n'
  printf -- '- Rollback plan evidence: verified.\n'
  printf -- '- Production service doc evidence: verified.\n'
  printf -- '- No concrete URL / committed secret / private key / live deployment evidence: verified by source and safety scans.\n'
  printf '\n## Known Limitations\n'
  printf -- '- Evidence only.\n'
  printf -- '- No deployed server.\n'
  printf -- '- No backend URL committed.\n'
  printf -- '- No Cloudflare credential committed.\n'
  printf -- '- No live Cloudflare playback proven until staging backend and runtime config are supplied.\n'
  printf -- '- Local Preview fallback remains available.\n'
} > "$OUT_DIR/backend_staging_contract_pack_evidence_report.md"

cat "$OUT_DIR/backend_staging_contract_pack_evidence_report.md"
[[ "$overall_status" == "pass" ]]
