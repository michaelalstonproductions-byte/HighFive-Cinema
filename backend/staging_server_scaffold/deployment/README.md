# HighFive Staging Node HTTP Target

This target exposes the existing staging backend scaffold through a provider-neutral Node HTTP listener for local smoke testing only.

## Scope

- Runtime: Node HTTP.
- Deployment status: not deployed.
- Bind policy: loopback only, `127.0.0.1` by default.
- Provider mode: mock.
- Health path: `/health`.
- Entitlement path: `/entitlements/validate`.
- Playback descriptor path: `/playback/descriptor`.

No remote deployment occurred in #067.0A. No provider credentials are present. A later remote deployment phase must select a host and supply runtime configuration outside this repository.

## Provider Boundaries

StoreKit and RevenueCat validation remain server-side responsibilities for a later provider integration phase. Cloudflare descriptor signing also remains server-side. This local target uses only mock providers and the existing production scaffold functions.

## Local Preview

Local Preview fallback remains available. The local smoke harness verifies that the HTTP target preserves fallback behavior and does not require provider credentials.
