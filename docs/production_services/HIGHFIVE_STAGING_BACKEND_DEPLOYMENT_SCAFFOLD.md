# HighFive Staging Backend Deployment Scaffold

Phase #065.0A adds a deployable backend scaffold under `backend/staging_server_scaffold/`. It mirrors the #064.0A contract pack and keeps the #064.0B evidence-lock boundaries intact.

## Endpoint Paths

- `POST /entitlements/validate`
- `POST /playback/descriptor`

## Route Files

- `src/routes/entitlements.ts`
- `src/routes/playback.ts`
- `src/server.ts`

## Provider Boundaries

- `src/providers/providerInterfaces.ts`
- `src/providers/storekitValidator.ts`
- `src/providers/revenueCatValidator.ts`
- `src/providers/cloudflareSigner.ts`
- `src/mocks/mockEntitlementProvider.ts`
- `src/mocks/mockCloudflareSigner.ts`

The StoreKit and RevenueCat validators are placeholders for server-side validation. The Cloudflare signer is a placeholder for server-side descriptor signing. No provider credentials are present.

## Product Mapping

- `friendly -> com.highfive.movie.thefriendly`
- `paranormall-s1 -> com.highfive.series.paranormall.season1`
- `paranormall_s1_e1 -> com.highfive.episode.paranormall.e1`
- `paranormall_s1_e2 -> com.highfive.episode.paranormall.e2`
- `paranormall_s1_e3 -> com.highfive.episode.paranormall.e3`
- `paranormall_s1_e4 -> com.highfive.episode.paranormall.e4`
- `paranormall_s1_e5 -> com.highfive.episode.paranormall.e5`
- `paranormall_s1_e6 -> com.highfive.episode.paranormall.e6`
- `paranormall_s1_e7 -> com.highfive.episode.paranormall.e7`

## Audit Model

`src/audit.ts` creates placeholder server-side audit records for entitlement validation and descriptor issuance. Descriptor references are not logged.

## Environment Placeholders

- `HIGHFIVE_BACKEND_ENV`
- `HIGHFIVE_BACKEND_PUBLIC_BASE_URL`
- `HIGHFIVE_CLOUDFLARE_ACCOUNT_ID`
- `HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN`
- `HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET`
- `HIGHFIVE_APP_STORE_BUNDLE_ID`
- `HIGHFIVE_APP_STORE_ISSUER_ID`
- `HIGHFIVE_APP_STORE_KEY_ID`
- `HIGHFIVE_APP_STORE_PRIVATE_KEY`
- `HIGHFIVE_REVENUECAT_SECRET_KEY`
- `HIGHFIVE_DATABASE_URL`
- `HIGHFIVE_AUDIT_LOG_SINK`
- `HIGHFIVE_ALLOWED_PLAYBACK_TTL_SECONDS`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`

## iOS Runtime Config Needed Later

- `HIGHFIVE_BACKEND_MODE`
- `HIGHFIVE_BACKEND_BASE_URL`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`

## Intentionally Not Run

- No package installation.
- No lockfile creation.
- No backend deployment.
- No provider SDK added to the iOS app.
- No live StoreKit purchase flow.
- No live Cloudflare playback proof.

## Rollback

Rollback is performed by removing iOS runtime backend config or returning `local_preview_fallback` / `descriptor_unavailable` from the staging server.

## What Waits For Production

- Real deployed staging backend.
- Server-side StoreKit or RevenueCat validation.
- Server-side Cloudflare signing.
- Durable audit sink.
- Runtime config supplied outside the repo.
