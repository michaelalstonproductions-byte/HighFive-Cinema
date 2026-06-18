# Backend Staging Deployment Checklist

This checklist is for a future staging deployment. It contains no deployment destination and no credentials.

## Preflight

- Confirm the iOS app is on or after #063.0B.
- Confirm the backend implements `POST /entitlements/validate`.
- Confirm the backend implements `POST /playback/descriptor`.
- Confirm JSON request and response bodies match `schemas/`.
- Confirm runtime config is supplied outside the repo.
- Confirm server-only credentials live in the staging secret store.
- Confirm audit logging is configured server-side.

## Entitlement Validation

- Validate StoreKit or RevenueCat entitlement server-side.
- Verify `storekit_product_id` against `movie_id`.
- Reject mismatched products.
- Never trust app-provided entitlement state alone.
- Return `entitlement_approved`, `entitlement_denied`, or `entitlement_pending`.
- Return `expires_at`, `refresh_after`, and `audit_id`.
- Handle refund, revocation, cancellation, expiration, restore purchase, and entitlement expiry.

## Playback Descriptor

- Require a valid entitlement `audit_id`.
- Generate Cloudflare signed playback material server-side.
- Return only a short-lived `playback_url_or_token_reference`.
- Return `descriptor_ready`, `descriptor_unavailable`, `descriptor_expired`, or `descriptor_refresh_required`.
- Never return Cloudflare API credential material to the app.
- Never log `playback_url_or_token_reference`.

## iOS Runtime Config After Deployment

- `HIGHFIVE_BACKEND_MODE`
- `HIGHFIVE_BACKEND_BASE_URL`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`

## Rollback Trigger

- Remove iOS runtime endpoint config.
- Backend may return `local_preview_fallback`.
- Confirm app returns to Local Preview fallback active.
