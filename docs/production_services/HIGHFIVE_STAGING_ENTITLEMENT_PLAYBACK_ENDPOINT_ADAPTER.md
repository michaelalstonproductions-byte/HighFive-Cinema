# HighFive Staging Entitlement Playback Endpoint Adapter

## Scope

#063.0A adds the app-side staging adapter that connects the backend entitlement-validation contract to the backend playback-descriptor contract. It is a runtime-config-gated transport boundary only. It does not deploy a backend, commit backend URL values, add production payment flow, or generate Cloudflare signing material in the app.

## Transport Boundary

The app-side boundary is `HFBackendEntitlementPlaybackAdapter`.

It uses:

- `HFBackendEntitlementPlaybackTransport`
- `HFURLSessionEntitlementPlaybackTransport`
- `HFBackendEndpointResolver`
- `HFBackendRequestState`
- `HFBackendTransportError`
- `HFBackendHTTPStatus`
- `HFEntitlementPlaybackResult`
- `HFPlaybackDescriptorRuntimeState`
- `HFBackendRequestAuditContext`

`URLSession` ownership stays under `HighFive/Services/Backend`. SwiftUI views and the player surface do not call endpoints directly.

## Runtime Endpoint Resolution

The resolver builds endpoint URLs from runtime config only.

Runtime config names:

- `HIGHFIVE_BACKEND_MODE`
- `HIGHFIVE_BACKEND_BASE_URL`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`

Resolution order:

- Entitlement validation uses `HIGHFIVE_ENTITLEMENT_BASE_URL` when present.
- Playback descriptor uses `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL` when present.
- Both fall back to `HIGHFIVE_BACKEND_BASE_URL` when the specialized base is not present.

Relative endpoint paths:

- `/entitlements/validate`
- `/playback/descriptor`

No runtime value is committed or displayed in the UI.

## Request Order

The adapter runs entitlement validation first:

1. Build `HFBackendEntitlementValidationRequest`.
2. POST to `/entitlements/validate`.
3. If entitlement is denied, stop and keep `Local Preview fallback active`.
4. If entitlement is approved, build `HFBackendPlaybackDescriptorRequest`.
5. POST to `/playback/descriptor`.
6. Decode `HFBackendPlaybackDescriptorResponse`.
7. Expose `Staging playback descriptor ready` only as staging readiness.

## Denial Behavior

When validation returns `Entitlement denied`, the app does not request a playback descriptor. Movie Detail, Player, Profile, and Backend Status remain on `Local Preview fallback active`.

## Descriptor Behavior

The descriptor response is handled as transient runtime state:

- `Playback descriptor unavailable` keeps local preview.
- `Playback descriptor expired` keeps local preview.
- `Descriptor refresh required` keeps local preview.
- `Staging playback descriptor ready` may expose an in-memory descriptor through the existing streaming boundary.

`playback_url_or_token_reference` is not displayed, printed, logged, or persisted.

## Expiry And Refresh

The backend contract includes:

- `expires_at`
- `refresh_after`
- `Descriptor expired`
- `Descriptor refresh required`

The app records only status and timing metadata needed for staging readiness. Production refresh scheduling waits for a deployed backend policy.

## Logging Policy

The adapter does not log:

- request bodies
- response bodies
- entitlement payloads
- descriptor payloads
- playback references
- account identifiers

## Local Preview Fallback

Missing config, incomplete endpoint config, denial, unavailable descriptor, expired descriptor, malformed response, HTTP error, cancellation, and decode failure all preserve `Local Preview fallback active`.

The Watch Now local preview path remains usable.

## Server-Side Cloudflare Signing

Server-side Cloudflare signing required.

No Cloudflare token in app.

The app never generates signed playback material and never stores Cloudflare provider credentials. Server deployment must own Cloudflare account credentials, signing policy, expiration, revocation, and playback descriptor creation.

## What Must Be Deployed Server-Side

Production requires:

- deployed entitlement validation endpoint
- deployed playback descriptor endpoint
- StoreKit receipt or transaction validation server-side
- account/session validation
- Cloudflare signing server-side
- descriptor expiry and refresh policy
- refund, revocation, and expiration handling
- audit record storage
- rollback path to local preview

## Rollout And Rollback

Rollout requires runtime config supplied outside the repository. Rollback removes runtime config and the app returns to `Staging backend not configured` and `Local Preview fallback active`.

## Not Included

This phase does not include:

- production backend deployment
- committed backend URL values
- Cloudflare token in app
- signed-token generation in app
- live StoreKit purchase flow
- RevenueCat SDK
- Stripe SDK
- persistent playback-reference storage
- real media downloads
