# HighFive Staging Backend Server Scaffold

This scaffold mirrors the #064.0A backend staging contract pack for the two app-required endpoints:

- `POST /entitlements/validate`
- `POST /playback/descriptor`

It is deployable source structure only. It is not deployed in this phase, contains no concrete backend URL, contains no provider credentials, and does not include dependency install output.

## Layout

- `src/contracts.ts` defines the request and response types.
- `src/productMapping.ts` validates movie ID to StoreKit product ID mapping.
- `src/entitlements/validateEntitlement.ts` stages server-side entitlement validation.
- `src/playback/requestPlaybackDescriptor.ts` stages backend-mediated descriptor issuance.
- `src/providers/` defines StoreKit, RevenueCat, and Cloudflare boundary interfaces and placeholder providers.
- `src/mocks/` contains deterministic mock providers.
- `src/routes/` contains route adapters for the two endpoint paths.
- `test_contracts/validate_contract_examples.ts` statically references the contract examples and expected fields.

## Boundaries

- StoreKit and RevenueCat validation happen server-side only.
- Cloudflare signing happens server-side only.
- App-provided entitlement claims are never trusted alone.
- Product mapping is validated server-side before descriptor issuance.
- Descriptor references are short-lived and not logged.
- Server credentials never return to the app.

## Rollback

Rollback is done by removing iOS runtime config or returning `local_preview_fallback` / `descriptor_unavailable`.
