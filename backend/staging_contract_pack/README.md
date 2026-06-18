# HighFive Backend Staging Contract Pack

This pack defines the staging server contract required by the HighFive iOS app for entitlement validation and backend-mediated playback descriptors.

It is a contract and deployment checklist only. It does not deploy a server, does not contain secrets, does not contain concrete backend URLs, and does not include Cloudflare credentials.

## Endpoints

- `POST /entitlements/validate`
- `POST /playback/descriptor`

The iOS app resolves these paths from runtime configuration only. Removing runtime configuration keeps `Local Preview fallback active`.

## Contract Flow

1. The app sends the current `movie_id`, `storekit_product_id`, identity context, entitlement context, playback provider, and device context to `/entitlements/validate`.
2. The backend validates StoreKit or RevenueCat entitlement server-side.
3. The backend verifies the StoreKit product ID against the movie ID mapping.
4. If the entitlement is denied, the backend returns `entitlement_denied` and the app does not request a descriptor.
5. If the entitlement is approved, the app requests `/playback/descriptor` with the entitlement `audit_id`.
6. The backend generates short-lived Cloudflare playback material server-side and returns only a descriptor reference.
7. The app keeps the descriptor reference in memory only and falls back to Local Preview when unavailable.

## Files

- `openapi/highfive-entitlement-playback.openapi.yaml`
- `schemas/*.schema.json`
- `examples/*.example.json`
- `handlers/*.handler.example.ts`
- `env/highfive_backend_staging.env.example`
- `DEPLOYMENT_CHECKLIST.md`
- `SECURITY_REQUIREMENTS.md`
- `ROLLBACK_PLAN.md`

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
- Never persist `playback_url_or_token_reference` in the app.
- Support rollback by removing runtime config and returning Local Preview fallback.
