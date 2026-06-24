# HighFive Staging Backend Server Scaffold

This scaffold mirrors the #064.0A backend staging contract pack for the app-required staging endpoints and the P29A read-only production catalog foundation.

- `POST /entitlements/validate`
- `POST /playback/descriptor`
- `GET /health`
- `GET /ready`
- `GET /v1/catalog`
- `GET /v1/content/:id`
- `GET /v1/creators/:id`
- `GET /v1/collections/:id`
- `GET /openapi.json`

It is local development source structure only. It is not deployed in this phase, contains no production backend URL, contains no provider credentials, and does not include dependency install output.

## P29A Local Catalog Startup

Compile and run the local catalog target:

```bash
cd backend/staging_server_scaffold
npx tsc -p tsconfig.http-target.json --outDir /private/tmp/highfive-p29a-production-backend-service-foundation/compiled
npm run catalog:migrate:local
HIGHFIVE_BACKEND_ENV=local_smoke \
HIGHFIVE_PROVIDER_MODE=mock \
HIGHFIVE_SERVER_HOST=127.0.0.1 \
HIGHFIVE_SERVER_PORT=8787 \
npm run catalog:start
```

In another terminal:

```bash
HIGHFIVE_HTTP_SMOKE_BASE_URL=http://127.0.0.1:8787 npm run catalog:smoke
```

Docker Compose local development is also available:

```bash
cd backend/staging_server_scaffold
docker compose up --build
```

## Layout

- `src/contracts.ts` defines the request and response types.
- `src/productMapping.ts` validates movie ID to StoreKit product ID mapping.
- `src/entitlements/validateEntitlement.ts` stages server-side entitlement validation.
- `src/playback/requestPlaybackDescriptor.ts` stages backend-mediated descriptor issuance.
- `src/providers/` defines StoreKit, RevenueCat, and Cloudflare boundary interfaces and placeholder providers.
- `src/mocks/` contains deterministic mock providers.
- `src/routes/` contains route adapters for the two endpoint paths.
- `src/catalog/` contains the local read-only catalog seed and OpenAPI document.
- `migrations/001_content_catalog.sql` contains the PostgreSQL-compatible catalog schema.
- `seed/catalog.json` contains the P29A seed fixture for migration validation.
- `test_contracts/validate_contract_examples.ts` statically references the contract examples and expected fields.

## Boundaries

- StoreKit and RevenueCat validation happen server-side only.
- Cloudflare signing happens server-side only.
- App-provided entitlement claims are never trusted alone.
- Product mapping is validated server-side before descriptor issuance.
- Descriptor references are short-lived and not logged.
- Server credentials never return to the app.
- P29A catalog endpoints are read-only.
- P29A does not add authentication, uploads, media processing, payments, or subscriptions.

## Rollback

Rollback is done by removing iOS runtime config or returning `local_preview_fallback` / `descriptor_unavailable`.
