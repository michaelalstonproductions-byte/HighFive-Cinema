# HighFive Staging Backend Local Contract Test Harness

Upgrade: #066.0A

This harness adds deterministic local contract tests for `backend/staging_server_scaffold/`.
It compiles the scaffold TypeScript modules into `/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/compiled/` and runs Node's built-in test runner against those compiled production exports.

## Scope

Production modules exercised:

- `src/contracts.ts`
- `src/productMapping.ts`
- `src/audit.ts`
- `src/errors.ts`
- `src/entitlements/validateEntitlement.ts`
- `src/playback/requestPlaybackDescriptor.ts`
- `src/providers/providerInterfaces.ts`
- `src/providers/revenueCatValidator.ts`
- `src/mocks/mockEntitlementProvider.ts`
- `src/mocks/mockCloudflareSigner.ts`

The tests do not duplicate entitlement, product mapping, audit, or playback descriptor production logic. They invoke the compiled scaffold exports.

## Test Coverage

- Product mapping for Friendly, Paranormall season, and Paranormall episodes 1 through 7.
- Unknown movie and movie/product mismatch rejection.
- Entitlement approved, denied, pending, mismatch-before-provider, audit ID, and app-claimed entitlement distrust behavior.
- Playback descriptor denial blocking, approved audit requirement, unavailable signer, ready signer, expiry, refresh, placeholder reference, and credential-free response behavior.
- Local preview fallback preservation when provider approval, valid mapping, or rollback availability is unavailable.
- Security behavior for no network calls, no real `.env` reads, no credentials required, no descriptor logging, no descriptor persistence, no concrete URL, and no token/private key material.

## Runner Outputs

`scripts/run_staging_backend_local_contract_tests.sh` writes:

- `/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_output.tap`
- `/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_summary.json`
- `/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/contract_test_summary.md`

`scripts/verify_staging_backend_local_contract_tests.sh` writes:

- `/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/verification.json`
- `/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests/verification.md`

## Safety Boundaries

- No package installation.
- No lockfile creation.
- No repository-local Node dependency directory.
- No compiled JavaScript emitted inside the repository.
- No `.env` file reads.
- No network calls.
- No backend deployment.
- No iOS Swift or Xcode project edits.
- No provider SDKs.
- No sensitive descriptor logging or persistence.
