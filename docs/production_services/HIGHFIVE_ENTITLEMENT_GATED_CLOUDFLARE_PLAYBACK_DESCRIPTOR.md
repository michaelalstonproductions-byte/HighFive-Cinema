# HighFive Entitlement-Gated Cloudflare Playback Descriptor

## Upgrade

#061.0A - Entitlement-gated Cloudflare playback descriptor integration.

## Staging Flow

This phase connects the current staging boundaries without launching production streaming:

1. Movie ID
2. StoreKit product mapping
3. Entitlement access decision
4. Backend playback descriptor request
5. Cloudflare playback descriptor readiness
6. Player local preview fallback unless the descriptor is configured and approved

The current mapped title path is:

| Current movie ID | Source movie ID | StoreKit product ID | Descriptor dependency |
| --- | --- | --- | --- |
| `friendly` | `the_friendly` | `com.highfive.movie.thefriendly` | Backend descriptor required |
| `paranormall-s1` | `paranormall_s1` | `com.highfive.series.paranormall.season1` | Backend descriptor required |

Paranormall episode products remain catalog metadata:

- `paranormall_s1_e1` through `paranormall_s1_e7`
- `com.highfive.episode.paranormall.e1` through `com.highfive.episode.paranormall.e7`

## StoreKit / Paywall Dependency

- StoreKit product mapping is reused from the inspected older project as metadata only.
- Paywall readiness stays disabled.
- No live purchase flow is active.
- Product loading waits for production StoreKit sandbox configuration.
- Restore purchase behavior waits for server validation.

## Entitlement Gate

- Entitlement gate required.
- StoreKit product mapping required for unmapped catalog titles.
- Server entitlement validation required before backend playback descriptors can be approved.
- Missing playback descriptor config keeps `Local Preview Access`.
- Missing entitlement validation reports `Server entitlement validation required`.

## Backend Descriptor Requirement

- Backend descriptor required.
- Backend-mediated playback only.
- The app sends only staging access context: movie ID, profile scope, product identifier, entitlement requirement, and provider boundary.
- The app does not contain a backend URL.
- Runtime config stores only presence in the app.

## Cloudflare Descriptor Boundary

- Cloudflare descriptor not connected by default.
- Cloudflare descriptor ready is a staging descriptor readiness state only, not a production playback claim.
- Cloudflare playback requires backend descriptor.
- Cloudflare signed playback credential generation must happen server-side, not in app code.
- No Cloudflare token in app.
- No hardcoded Cloudflare URLs.
- No Cloudflare video UID values are committed.

## Runtime Config Names

- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`

These names are documented only. No real values, URLs, tokens, or credentials are committed.

## Local Preview Fallback

Local Preview Access remains available for Watch Now and Player routes. Provider playback is never required for the local preview path.

## What Waits For Production

- Server entitlement validation endpoint.
- Backend playback descriptor endpoint.
- Server-side Cloudflare signed playback credential generation.
- StoreKit sandbox products and App Store product review.
- Restore purchase implementation.
- Refund, revocation, and expiration handling.
- Approved Cloudflare descriptor response.
- Production observability and rollback.
