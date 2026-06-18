# HighFive Backend Staging Deployment Contract Pack

Phase #064.0A adds a server-side contract pack for the app adapter evidence-locked in #063.0B. It does not deploy a backend and does not commit runtime endpoint values.

## Location

`backend/staging_contract_pack/`

## Relationship To App Adapter

The #063.0A app adapter resolves endpoint URLs from runtime config and appends only:

- `/entitlements/validate`
- `/playback/descriptor`

This pack describes the staging server that must answer those endpoints. Without runtime config, the iOS app remains in `Local Preview fallback active`.

## Schemas Created

- `schemas/entitlements.validate.request.schema.json`
- `schemas/entitlements.validate.response.schema.json`
- `schemas/playback.descriptor.request.schema.json`
- `schemas/playback.descriptor.response.schema.json`

## Handler Templates Created

- `handlers/entitlements.validate.handler.example.ts`
- `handlers/playback.descriptor.handler.example.ts`

The templates show where server-side StoreKit or RevenueCat validation belongs, where server-side Cloudflare signing belongs, and where audit records are written. They contain no live provider calls and no deployment target.

## Required Endpoint Fields

Entitlement validation request:

- `user_id`
- `anonymous_session_id`
- `movie_id`
- `storekit_product_id`
- `entitlement_context`
- `playback_provider`
- `device_context`

Entitlement validation response:

- `entitlement_status`
- `access_decision`
- `denial_reason`
- `audit_id`
- `expires_at`
- `refresh_after`

Playback descriptor request:

- `user_id`
- `anonymous_session_id`
- `movie_id`
- `storekit_product_id`
- `entitlement_context`
- `playback_provider`
- `device_context`
- `audit_id`

Playback descriptor response:

- `playback_descriptor_status`
- `playback_url_or_token_reference`
- `expires_at`
- `refresh_after`
- `denial_reason`
- `audit_id`

## Server-Only Credentials

These are placeholders only and must remain outside the repo:

- `HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN`
- `HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET`
- `HIGHFIVE_APP_STORE_PRIVATE_KEY`
- `HIGHFIVE_APP_STORE_ISSUER_ID`
- `HIGHFIVE_APP_STORE_KEY_ID`
- `HIGHFIVE_REVENUECAT_SECRET_KEY`
- `HIGHFIVE_DATABASE_URL`
- `HIGHFIVE_AUDIT_LOG_SINK`

## iOS Runtime Config Needed After Deployment

- `HIGHFIVE_BACKEND_MODE`
- `HIGHFIVE_BACKEND_BASE_URL`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`

## Server Responsibilities

- Validate StoreKit or RevenueCat entitlement server-side.
- Verify the StoreKit product ID against the movie ID mapping.
- Never trust app-provided entitlement state alone.
- Generate Cloudflare signed playback material server-side.
- Return short-lived descriptor reference only.
- Return `expires_at` and `refresh_after`.
- Write audit record server-side.
- Handle refund, revocation, cancellation, expiration, restore purchase, and entitlement expiry.
- Never return Cloudflare API credential material to the app.
- Never log `playback_url_or_token_reference`.
- Support rollback by removing runtime config and returning Local Preview fallback.

## What Waits For Production

- Deployed staging backend.
- Server-owned StoreKit or RevenueCat validation.
- Server-owned Cloudflare signing.
- Audit log persistence.
- Runtime config supplied outside the repo.
- End-to-end staging verification with real non-repo credentials.
