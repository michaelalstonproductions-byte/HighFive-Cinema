# HighFive Backend Entitlement Playback Descriptor Contract

Upgrade: #062.0A

This document stages the backend contract for the flow:

Movie ID -> StoreKit product mapping -> account/session identity -> server entitlement validation request -> backend playback descriptor request -> Cloudflare signed playback descriptor returned by backend -> local preview fallback if unavailable.

This is a contract and staging phase only. No backend URL is committed, no Cloudflare token is stored in the app, and no live purchase or production playback claim is made.

## Runtime Config Names

- `HIGHFIVE_BACKEND_BASE_URL`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`

Values are runtime-only. Do not commit real values, tokens, Cloudflare credentials, backend URLs, or StoreKit secrets.

## Entitlement Validation Endpoint

Endpoint contract:

- Method: `POST`
- Relative path: `/entitlements/validate`
- Full URL: runtime config only; no hardcoded backend URL.
- Status copy: Backend entitlement validation required.

Request fields:

- `user_id` or `anonymous_session_id`
- `movie_id`
- `storekit_product_id`
- `entitlement_context`
- `playback_provider`
- `device_context`

Response fields:

- `entitlement_status`
- `access_decision`
- `denial_reason`
- `audit_id`

Expected staging states:

- Server entitlement validation pending
- Entitlement approved
- Entitlement denied
- Local Preview fallback active

Production must validate purchase history, restore state, refunds, revocations, expiration, family sharing rules if supported, account scope, and product-to-title mapping on the server.

## Playback Descriptor Endpoint

Endpoint contract:

- Method: `POST`
- Relative path: `/playback/descriptor`
- Full URL: runtime config only; no hardcoded backend URL.
- Status copy: Backend playback descriptor endpoint required.

Request fields:

- `user_id` or `anonymous_session_id`
- `movie_id`
- `storekit_product_id`
- `entitlement_context`
- `playback_provider`
- `device_context`

Response fields:

- `entitlement_status`
- `access_decision`
- `playback_descriptor_status`
- `playback_url_or_token_reference`
- `expires_at`
- `refresh_after`
- `denial_reason`
- `audit_id`

Expected staging states:

- Playback descriptor unavailable
- Playback descriptor contract ready
- Descriptor expired
- Descriptor refresh required
- Local Preview fallback active

The backend owns descriptor issuance. Cloudflare signed token generated server-side. No Cloudflare token in app. The app only receives a descriptor or reference after server entitlement validation approves access.

## App Boundary

The app-side boundary is represented by:

- `HFBackendEntitlementValidationRequest`
- `HFBackendEntitlementValidationResponse`
- `HFBackendPlaybackDescriptorRequest`
- `HFBackendPlaybackDescriptorResponse`
- `HFBackendPlaybackDescriptorContract`
- `HFBackendPlaybackDescriptorEndpoint`
- `HFServerEntitlementValidationState`
- `HFCloudflareSignedPlaybackPolicy`
- `HFPlaybackDescriptorExpiryPolicy`
- `HFPlaybackDescriptorAuditRecord`

The current app keeps Watch Now on local preview fallback when backend, entitlement, or playback descriptor config is missing. Contract models must build without a live server.

## What Waits For Production

- Live StoreKit purchase and restore flow.
- Server-side receipt and entitlement validation.
- Server-side Cloudflare signed token generation.
- Playback descriptor endpoint deployment.
- Descriptor refresh and expiration handling.
- Refund, revocation, and expired entitlement enforcement.
- Production backend URL and credentials via runtime config only.
