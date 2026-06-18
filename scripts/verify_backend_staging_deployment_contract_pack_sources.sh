#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-64-0b-backend-staging-contract-pack-evidence"
mkdir -p "$OUT_DIR"

PACK_DIR="backend/staging_contract_pack"
DOC_FILE="docs/production_services/HIGHFIVE_BACKEND_STAGING_DEPLOYMENT_CONTRACT_PACK.md"
PRIMARY_VERIFIER="scripts/verify_backend_staging_deployment_contract_pack.sh"

required_files=(
  "$PACK_DIR/README.md"
  "$PACK_DIR/openapi/highfive-entitlement-playback.openapi.yaml"
  "$PACK_DIR/schemas/entitlements.validate.request.schema.json"
  "$PACK_DIR/schemas/entitlements.validate.response.schema.json"
  "$PACK_DIR/schemas/playback.descriptor.request.schema.json"
  "$PACK_DIR/schemas/playback.descriptor.response.schema.json"
  "$PACK_DIR/examples/entitlements.validate.request.example.json"
  "$PACK_DIR/examples/entitlements.validate.response.approved.example.json"
  "$PACK_DIR/examples/entitlements.validate.response.denied.example.json"
  "$PACK_DIR/examples/playback.descriptor.request.example.json"
  "$PACK_DIR/examples/playback.descriptor.response.ready.example.json"
  "$PACK_DIR/examples/playback.descriptor.response.unavailable.example.json"
  "$PACK_DIR/handlers/entitlements.validate.handler.example.ts"
  "$PACK_DIR/handlers/playback.descriptor.handler.example.ts"
  "$PACK_DIR/env/highfive_backend_staging.env.example"
  "$PACK_DIR/DEPLOYMENT_CHECKLIST.md"
  "$PACK_DIR/SECURITY_REQUIREMENTS.md"
  "$PACK_DIR/ROLLBACK_PLAN.md"
  "$DOC_FILE"
  "$PRIMARY_VERIFIER"
)

required_terms=(
  "/entitlements/validate"
  "/playback/descriptor"
  "user_id"
  "anonymous_session_id"
  "movie_id"
  "storekit_product_id"
  "entitlement_context"
  "playback_provider"
  "device_context"
  "entitlement_status"
  "access_decision"
  "denial_reason"
  "audit_id"
  "expires_at"
  "refresh_after"
  "playback_descriptor_status"
  "playback_url_or_token_reference"
  "entitlement_approved"
  "entitlement_denied"
  "entitlement_pending"
  "descriptor_ready"
  "descriptor_unavailable"
  "descriptor_expired"
  "descriptor_refresh_required"
  "local_preview_fallback"
  "Validate StoreKit or RevenueCat entitlement server-side"
  "Verify the StoreKit product ID against the movie ID mapping"
  "Never trust app-provided entitlement state alone"
  "Generate Cloudflare signed playback material server-side"
  "Return short-lived descriptor reference only"
  'Return `expires_at` and `refresh_after`'
  "Write audit record server-side"
  "Handle refund, revocation, cancellation, expiration, restore purchase, and entitlement expiry"
  "Never return Cloudflare API credential material to the app"
  'Never log `playback_url_or_token_reference`'
  "Support rollback by removing runtime config"
  "HIGHFIVE_BACKEND_ENV"
  "HIGHFIVE_BACKEND_PUBLIC_BASE_URL"
  "HIGHFIVE_CLOUDFLARE_ACCOUNT_ID"
  "HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN"
  "HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET"
  "HIGHFIVE_APP_STORE_BUNDLE_ID"
  "HIGHFIVE_APP_STORE_ISSUER_ID"
  "HIGHFIVE_APP_STORE_KEY_ID"
  "HIGHFIVE_APP_STORE_PRIVATE_KEY"
  "HIGHFIVE_REVENUECAT_SECRET_KEY"
  "HIGHFIVE_DATABASE_URL"
  "HIGHFIVE_AUDIT_LOG_SINK"
  "HIGHFIVE_ALLOWED_PLAYBACK_TTL_SECONDS"
  "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
  "HIGHFIVE_BACKEND_MODE"
  "HIGHFIVE_BACKEND_BASE_URL"
  "HIGHFIVE_ENTITLEMENT_BASE_URL"
  "HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL"
  "HIGHFIVE_STREAMING_PROVIDER"
  "HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID"
  "HIGHFIVE_REVENUECAT_PROJECT_ID"
)

json_files=(
  "$PACK_DIR/schemas/entitlements.validate.request.schema.json"
  "$PACK_DIR/schemas/entitlements.validate.response.schema.json"
  "$PACK_DIR/schemas/playback.descriptor.request.schema.json"
  "$PACK_DIR/schemas/playback.descriptor.response.schema.json"
  "$PACK_DIR/examples/entitlements.validate.request.example.json"
  "$PACK_DIR/examples/entitlements.validate.response.approved.example.json"
  "$PACK_DIR/examples/entitlements.validate.response.denied.example.json"
  "$PACK_DIR/examples/playback.descriptor.request.example.json"
  "$PACK_DIR/examples/playback.descriptor.response.ready.example.json"
  "$PACK_DIR/examples/playback.descriptor.response.unavailable.example.json"
)

failures=()

for file in "${required_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty file: $file")
done

for file in "${json_files[@]}"; do
  if [[ -f "$file" ]]; then
    node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$file" || failures+=("invalid json: $file")
  fi
done

for term in "${required_terms[@]}"; do
  if ! rg -q --fixed-strings "$term" "$PACK_DIR" "$DOC_FILE" "$PRIMARY_VERIFIER"; then
    failures+=("missing required evidence term: $term")
  fi
done

if ! rg -q --fixed-strings "/entitlements/validate" "$PACK_DIR/openapi/highfive-entitlement-playback.openapi.yaml"; then
  failures+=("OpenAPI missing entitlement endpoint")
fi
if ! rg -q --fixed-strings "/playback/descriptor" "$PACK_DIR/openapi/highfive-entitlement-playback.openapi.yaml"; then
  failures+=("OpenAPI missing playback descriptor endpoint")
fi
if ! rg -q --fixed-strings "validateServerEntitlement" "$PACK_DIR/handlers/entitlements.validate.handler.example.ts"; then
  failures+=("entitlement handler missing placeholder validation location")
fi
if ! rg -q --fixed-strings "createServerSideDescriptorReference" "$PACK_DIR/handlers/playback.descriptor.handler.example.ts"; then
  failures+=("descriptor handler missing placeholder signing location")
fi

url_pattern='https?''://'
if rg -n "$url_pattern" "$PACK_DIR" "$DOC_FILE"; then
  failures+=("concrete URL found")
fi

key_block_pattern='-----BEGIN PRIVATE ''KEY-----'
if rg -n --fixed-strings -- "$key_block_pattern" "$PACK_DIR" "$DOC_FILE"; then
  failures+=("private key block found")
fi

role_pattern='service_''role'
if rg -ni "$role_pattern" "$PACK_DIR" "$DOC_FILE"; then
  failures+=("service-role key reference found")
fi

live_sk_pattern='sk_''live'
live_pk_pattern='pk_''live'
client_secret_pattern='client_''secret\s*[:=]'
access_token_pattern='access_''token\s*[:=]'
refresh_token_pattern='refresh_''token\s*[:=]'
password_pattern='pass''word\s*[:=]'
bearer_pattern='Bear''er [A-Za-z0-9]'
auth_bearer_pattern='Authori''zation:\s*Bear''er'
api_key_pattern='api[_-]?''key\s*[:=]'
secret_word_pattern='sec''ret\s*[:=][^<]'
token_word_pattern='tok''en\s*[:=][^<]'
sensitive_pattern="($live_sk_pattern|$live_pk_pattern|$client_secret_pattern|$access_token_pattern|$refresh_token_pattern|$password_pattern|$bearer_pattern|$auth_bearer_pattern|$api_key_pattern|$secret_word_pattern|$token_word_pattern)"
if rg -n "$sensitive_pattern" "$PACK_DIR" "$DOC_FILE"; then
  failures+=("secret-like value found")
fi

if find "$PACK_DIR" -name 'node_modules' -o -name 'package-lock.json' -o -name 'yarn.lock' -o -name 'pnpm-lock.yaml' -o -name '.env' | rg -q .; then
  failures+=("live dependency or env artifact found")
fi

deployment_pattern='(fly deploy|vercel --prod|supabase functions deploy|wrangler deploy|gcloud run deploy|aws .* deploy)'
if rg -n "$deployment_pattern" "$PACK_DIR" "$DOC_FILE"; then
  failures+=("live deployment command found")
fi

if git diff --name-only aff3c17^ aff3c17 | rg -q '^HighFive/.*\.swift$'; then
  failures+=("#064.0A changed iOS Swift app code")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#064.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "checked_files": %d,\n' "${#required_files[@]}"
  printf '  "json_files_checked": %d,\n' "${#json_files[@]}"
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    escaped="${failures[$i]//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    comma=","
    [[ "$i" == "$((${#failures[@]} - 1))" ]] && comma=""
    printf '    "%s"%s\n' "$escaped" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$OUT_DIR/backend_staging_contract_pack_source_verification.json"

{
  printf '# Backend Staging Contract Pack Source Verification\n\n'
  printf -- '- Upgrade: #064.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required files checked: %d\n' "${#required_files[@]}"
  printf -- '- JSON files checked: %d\n' "${#json_files[@]}"
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nSource verification passed.\n'
  fi
} > "$OUT_DIR/backend_staging_contract_pack_source_verification.md"

cat "$OUT_DIR/backend_staging_contract_pack_source_verification.md"
[[ "$status" == "pass" ]]
