#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-65-0b-staging-backend-scaffold-evidence"
mkdir -p "$OUT_DIR"

SCAFFOLD_DIR="backend/staging_server_scaffold"
DOC_FILE="docs/production_services/HIGHFIVE_STAGING_BACKEND_DEPLOYMENT_SCAFFOLD.md"
PRIMARY_VERIFIER="scripts/verify_staging_backend_deployment_scaffold.sh"

required_files=(
  "$SCAFFOLD_DIR/README.md"
  "$SCAFFOLD_DIR/package.json"
  "$SCAFFOLD_DIR/tsconfig.json"
  "$SCAFFOLD_DIR/src/contracts.ts"
  "$SCAFFOLD_DIR/src/env.ts"
  "$SCAFFOLD_DIR/src/audit.ts"
  "$SCAFFOLD_DIR/src/errors.ts"
  "$SCAFFOLD_DIR/src/productMapping.ts"
  "$SCAFFOLD_DIR/src/entitlements/validateEntitlement.ts"
  "$SCAFFOLD_DIR/src/playback/requestPlaybackDescriptor.ts"
  "$SCAFFOLD_DIR/src/server.ts"
  "$SCAFFOLD_DIR/src/routes/entitlements.ts"
  "$SCAFFOLD_DIR/src/routes/playback.ts"
  "$SCAFFOLD_DIR/src/providers/storekitValidator.ts"
  "$SCAFFOLD_DIR/src/providers/revenueCatValidator.ts"
  "$SCAFFOLD_DIR/src/providers/cloudflareSigner.ts"
  "$SCAFFOLD_DIR/src/providers/providerInterfaces.ts"
  "$SCAFFOLD_DIR/src/mocks/mockEntitlementProvider.ts"
  "$SCAFFOLD_DIR/src/mocks/mockCloudflareSigner.ts"
  "$SCAFFOLD_DIR/test_contracts/validate_contract_examples.ts"
  "$SCAFFOLD_DIR/env/highfive_staging_server.env.example"
  "$SCAFFOLD_DIR/DEPLOYMENT_GUIDE.md"
  "$SCAFFOLD_DIR/SECURITY_MODEL.md"
  "$SCAFFOLD_DIR/ROLLBACK_GUIDE.md"
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
  "friendly"
  "com.highfive.movie.thefriendly"
  "paranormall-s1"
  "com.highfive.series.paranormall.season1"
  "paranormall_s1_e1"
  "com.highfive.episode.paranormall.e1"
  "paranormall_s1_e2"
  "com.highfive.episode.paranormall.e2"
  "paranormall_s1_e3"
  "com.highfive.episode.paranormall.e3"
  "paranormall_s1_e4"
  "com.highfive.episode.paranormall.e4"
  "paranormall_s1_e5"
  "com.highfive.episode.paranormall.e5"
  "paranormall_s1_e6"
  "com.highfive.episode.paranormall.e6"
  "paranormall_s1_e7"
  "com.highfive.episode.paranormall.e7"
  "StoreKit"
  "RevenueCat"
  "Cloudflare signing happens server-side only"
  "App entitlement claims are not trusted"
  "StoreKit product mapping is validated server-side"
  "Descriptor reference is short-lived"
  "Descriptor reference is not logged"
  "Server credentials never return to the app"
  'Rollback is done by removing runtime config or returning `local_preview_fallback`'
  "descriptor_unavailable"
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
)

failures=()

for file in "${required_files[@]}"; do
  [[ -s "$file" ]] || failures+=("missing or empty file: $file")
done

for file in "$SCAFFOLD_DIR/package.json" "$SCAFFOLD_DIR/tsconfig.json"; do
  if [[ -f "$file" ]]; then
    node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$file" || failures+=("invalid JSON: $file")
  fi
done

while IFS= read -r file; do
  [[ -s "$file" ]] || failures+=("empty TypeScript file: $file")
done < <(find "$SCAFFOLD_DIR/src" "$SCAFFOLD_DIR/test_contracts" -type f -name '*.ts' | sort)

for term in "${required_terms[@]}"; do
  if ! rg -q --fixed-strings "$term" "$SCAFFOLD_DIR" "$DOC_FILE" "$PRIMARY_VERIFIER"; then
    failures+=("missing required evidence term: $term")
  fi
done

if ! rg -q --fixed-strings "<SET_IN_STAGING_SECRET_STORE>" "$SCAFFOLD_DIR/env/highfive_staging_server.env.example"; then
  failures+=("env example missing placeholder secret-store values")
fi

url_pattern='https?''://'
if rg -n "$url_pattern" "$SCAFFOLD_DIR" "$DOC_FILE"; then
  failures+=("concrete URL found")
fi

key_block_pattern='-----BEGIN PRIVATE ''KEY-----'
if rg -n --fixed-strings -- "$key_block_pattern" "$SCAFFOLD_DIR" "$DOC_FILE"; then
  failures+=("private key block found")
fi

role_pattern='service_''role'
if rg -ni "$role_pattern" "$SCAFFOLD_DIR" "$DOC_FILE"; then
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
if rg -n "$sensitive_pattern" "$SCAFFOLD_DIR" "$DOC_FILE"; then
  failures+=("secret-like value found")
fi

if find "$SCAFFOLD_DIR" -name 'node_modules' -o -name 'package-lock.json' -o -name 'yarn.lock' -o -name 'pnpm-lock.yaml' -o -name '.env' -o -name 'dist' -o -name 'build' | rg -q .; then
  failures+=("live deployment artifact found")
fi

if git diff --name-only 079d633^ 079d633 | rg -q '^HighFive/.*\.swift$'; then
  failures+=("#065.0A changed iOS Swift app code")
fi
if git diff --name-only 079d633^ 079d633 | rg -q 'project.pbxproj'; then
  failures+=("#065.0A changed project.pbxproj")
fi

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#065.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "required_files_checked": %d,\n' "${#required_files[@]}"
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
} > "$OUT_DIR/staging_backend_scaffold_source_verification.json"

{
  printf '# Staging Backend Scaffold Source Verification\n\n'
  printf -- '- Upgrade: #065.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Required files checked: %d\n' "${#required_files[@]}"
  if (( ${#failures[@]} > 0 )); then
    printf '\n## Failures\n'
    for failure in "${failures[@]}"; do
      printf -- '- %s\n' "$failure"
    done
  else
    printf '\nSource verification passed.\n'
  fi
} > "$OUT_DIR/staging_backend_scaffold_source_verification.md"

cat "$OUT_DIR/staging_backend_scaffold_source_verification.md"
[[ "$status" == "pass" ]]
