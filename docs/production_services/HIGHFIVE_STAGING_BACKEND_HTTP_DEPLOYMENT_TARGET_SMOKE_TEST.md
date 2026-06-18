# HighFive Staging Backend HTTP Deployment Target Smoke Test

Upgrade: #067.0A

Baseline: #066.0B staging backend local contract test harness evidence lock.

This phase adds a provider-neutral Node HTTP target for the existing staging backend scaffold. It is a local smoke-test target only. No remote staging deployment occurred, no staging hostname was selected, and no backend URL was committed.

## Target

- Target name: `highfive-staging-node-http`
- Runtime: Node
- Transport: HTTP
- Bind policy: loopback only, `127.0.0.1` by default
- Provider mode: mock
- Deployment status: not deployed

## Routes

- `GET /health`
- `POST /entitlements/validate`
- `POST /playback/descriptor`

The HTTP target routes requests into the existing production scaffold functions:

- `validateEntitlement`
- `requestPlaybackDescriptor`
- `productMatchesMovie`
- `createAuditRecord`
- `findAuditRecord`
- `MockEntitlementProvider`
- `MockCloudflareSigner`

## Smoke Coverage

The loopback-only smoke harness verifies:

- health response status and metadata
- Friendly mapping
- Paranormall season and episode mapping
- approved, denied, and pending entitlement decisions
- unknown movie rejection
- movie/product mismatch rejection
- malformed JSON errors
- wrong-method errors
- unknown-route errors
- approved audit context before descriptor issuance
- descriptor ready and unavailable states
- descriptor expiry and refresh fields
- short-lived descriptor behavior
- denial stops descriptor issuance
- no provider credentials in responses
- no request body logging
- no response body logging
- no descriptor reference logging
- no descriptor reference persistence

## Runtime And Safety Policy

The target uses local runtime values only:

- `HIGHFIVE_SERVER_HOST=127.0.0.1`
- `HIGHFIVE_SERVER_PORT=0`
- `HIGHFIVE_PROVIDER_MODE=mock`
- `HIGHFIVE_MOCK_ENTITLEMENT_MODE=approved`
- `HIGHFIVE_MOCK_DESCRIPTOR_MODE=ready`
- `HIGHFIVE_BACKEND_ENV=local_smoke`

No package installation, external network request, provider SDK, remote deployment, real environment file, or credential is required. Cloudflare signing remains server-side. StoreKit and RevenueCat validation remain server-side for a later provider integration phase.

## Outputs

The smoke runner writes to:

- `/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke/http_smoke_test_output.tap`
- `/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke/http_smoke_test_summary.json`
- `/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke/http_smoke_test_summary.md`
- `/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke/server.log`
- `/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke/verification.json`
- `/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke/verification.md`

Rerun:

```bash
bash scripts/run_staging_backend_local_http_smoke_tests.sh
bash scripts/verify_staging_backend_local_http_smoke_tests.sh
```

## What Remains Before Remote Staging Deployment

- Select a remote host.
- Supply runtime configuration outside the repository.
- Add real server-side StoreKit or RevenueCat validation.
- Add real server-side Cloudflare signing.
- Configure durable audit storage.
- Keep Local Preview fallback available until remote staging is proven.

Local Preview fallback remains available.
