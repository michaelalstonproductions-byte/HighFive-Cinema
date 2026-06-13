# HighFive Payment Provider Integration Architecture

## #042.0A Payment Provider Integration Architecture

This document defines the payment provider integration architecture before implementation. It is planning only. It does not add live payment provider behavior, StoreKit implementation, RevenueCat SDK/config, Stripe SDK/config, purchase UI, purchase flows, subscriptions, restore purchase behavior, product IDs, SDKs, URLs, tokens, secrets, API keys, provider config, project settings, Info.plist changes, PrivacyInfo changes, entitlements, asset changes, or app code.

## 1. Purpose

#042.0A locks the payment architecture for HighFive Cinema without connecting a provider. The goal is to define how paid access will eventually flow through HighFive-owned service boundaries while preserving the current local streaming foundation.

The architecture must support:

- RevenueCat + StoreKit preferred for iOS paid access.
- Stripe web fallback only where Apple rules allow.
- A `PaymentEntitlementService` boundary for app access decisions.
- A `StoreProviderAdapter` boundary for provider-specific purchase state.
- BackendServiceLayer dependency for entitlement records and validation state.
- AuthService dependency for account-scoped access.
- HighFive-owned user ID dependency for all entitlement records.
- PlaybackService and DownloadService gates for paid access.
- LibraryService account state for user-facing entitlement context.
- Local preview fallback until live payments are explicitly approved.

## 2. Provider Decision

| Decision | Preferred | Fallback | Current status |
| --- | --- | --- | --- |
| iOS paid access provider | RevenueCat + StoreKit | None for native purchase flows | Architecture only |
| Web billing fallback | Not primary for iOS digital content | Stripe web where Apple rules allow | Architecture only |
| App access boundary | `PaymentEntitlementService` | Same boundary | Not implemented |
| Provider adapter | `StoreProviderAdapter` | Same adapter contract | Not implemented |
| Runtime default | `localPreview` | `providerNotConnected` | No live payment provider |

RevenueCat + StoreKit is preferred because HighFive is an iOS-first streaming experience and paid digital content must respect App Store payment rules. RevenueCat can later simplify entitlement synchronization and restore behavior while StoreKit remains the platform purchase mechanism.

Stripe is only a fallback for web billing or scenarios that Apple rules allow. Stripe must not be used to bypass required in-app purchase rules for iOS digital content. Any Stripe web fallback needs App Store review, backend entitlement bridging, privacy review, and explicit product approval before implementation.

## 3. Architecture Boundary

```text
SwiftUI screens
  -> account, playback, download, and library intent
  -> PaymentEntitlementService
  -> StoreProviderAdapter
  -> RevenueCat + StoreKit later

PaymentEntitlementService
  -> AuthService for session and HighFive-owned user ID
  -> BackendServiceLayer for entitlement records
  -> PlaybackService gates
  -> DownloadService gates
  -> LibraryService account state
```

Rules:

- SwiftUI screens must not call RevenueCat, StoreKit, Stripe, provider clients, provider dashboards, or purchase APIs directly.
- `PaymentEntitlementService` owns app-safe entitlement state, access decisions, restore architecture, validation policy, rollback behavior, and local preview fallback.
- `StoreProviderAdapter` owns provider readiness, product configuration readiness, purchase state mapping, provider availability, and validation-required states.
- BackendServiceLayer owns entitlement records, server entitlement validation, audit state, refund/revocation state, and HighFive-owned user ID mapping.
- AuthService provides the HighFive-owned user ID required for any account-scoped entitlement.
- PlaybackService and DownloadService ask `PaymentEntitlementService` for access decisions before premium playback or offline access.
- LibraryService may display account and entitlement context, but it does not grant access by itself.

## 4. StoreProviderAdapter Contract

`StoreProviderAdapter` is the provider-specific boundary. It maps RevenueCat + StoreKit or allowed Stripe web state into HighFive-safe provider states without exposing SDK types to UI screens.

```text
currentProviderState(userId) -> StoreProviderState
fetchAvailableProducts(userId) -> StoreProductReadiness
startPurchase(productReference, userId) -> StorePurchaseResult
refreshCustomerState(userId) -> StoreCustomerState
restoreCustomerPurchases(userId) -> StoreRestoreResult
validateTransactionState(userId, transactionReference) -> StoreValidationResult
providerHealth() -> StoreProviderHealth
```

Required `StoreProviderAdapter` states:

- `localPreview`
- `providerNotConnected`
- `providerSelected`
- `stagingReady`
- `productsConfigured`
- `purchaseAvailable`
- `entitlementActive`
- `entitlementExpired`
- `restoreRequired`
- `providerUnavailable`
- `validationRequired`
- `purchaseDenied`

Contract rules:

- No StoreKit implementation is added in #042.0A.
- No RevenueCat SDK/config is added in #042.0A.
- No Stripe SDK/config is added in #042.0A.
- No purchase UI is added in #042.0A.
- No product IDs are added in #042.0A.
- Provider state must be environment-gated and default to local preview or provider not connected.
- Provider errors must map into HighFive states such as provider unavailable, validation required, restore required, purchase denied, and entitlement expired.

## 5. PaymentEntitlementService Contract

`PaymentEntitlementService` is the app-facing boundary that other HighFive services use for paid access.

```text
currentEntitlements(userId) -> [SubscriptionEntitlement]
currentAccessState(userId, movieId, accessKind) -> PaymentAccessState
refreshEntitlements(userId) -> EntitlementRefreshResult
recordProviderUpdate(userId, providerState) -> EntitlementUpdateResult
requestRestoreArchitectureState(userId) -> RestoreArchitectureState
validateServerEntitlements(userId) -> ServerEntitlementValidationResult
handleRefundOrRevocation(userId, eventReference) -> EntitlementUpdateResult
handleExpiredEntitlements(userId, now) -> EntitlementUpdateResult
paymentHealth() -> PaymentEntitlementHealth
```

Required behavior:

- Depend on AuthService for current account state and HighFive-owned user ID.
- Depend on BackendServiceLayer for entitlement records and server validation.
- Provide PlaybackService with allow, deny, expired, validation required, provider unavailable, and local preview states.
- Provide DownloadService with offline eligibility, expiry, and revocation states.
- Provide LibraryService with account-level entitlement summary, not raw payment data.
- Keep local preview fallback available until live payments are approved.
- Store payment details only with the provider. HighFive stores entitlement and validation state only.

## 6. Entitlement Record Model

Entitlement records are HighFive-owned backend records that represent access state after provider validation.

| Field | Purpose |
| --- | --- |
| `id` | HighFive entitlement record identifier. |
| `userId` | HighFive-owned user ID from AuthService and BackendServiceLayer. |
| `entitlementKey` | HighFive access tier or capability identifier, not a concrete product ID in this phase. |
| `source` | Local preview, RevenueCat + StoreKit later, or allowed Stripe web bridge later. |
| `state` | Active, expired, revoked, refunded, validation required, provider unavailable, or local preview. |
| `startsAt` | Entitlement start timestamp when validated. |
| `expiresAt` | Entitlement expiry timestamp when applicable. |
| `lastValidatedAt` | Last server entitlement validation timestamp. |
| `validationStatus` | Server authoritative validation result. |
| `revokedAt` | Revocation timestamp when provider or support removes access. |
| `refundReference` | App-safe reference to refund handling status, not payment details. |
| `environment` | Local, staging, or production payment model. |

Entitlement records are not payment receipts, card data, invoice records, or provider secrets. They are access-control records used by HighFive services.

## 7. Subscription Entitlement Model

`Subscription Entitlement` is the app model consumed by feature services.

| State | Meaning | Access result |
| --- | --- | --- |
| `localPreview` | Simulator or demo mode with no live payment provider. | Allow only explicitly free/local preview behavior. |
| `providerNotConnected` | Payment provider is not configured. | Deny paid-only access without showing purchase UI. |
| `entitlementActive` | Server validation confirms active access. | Allow scoped playback, downloads, or library features. |
| `entitlementExpired` | Access end date has passed. | Deny premium access and request refresh when allowed. |
| `validationRequired` | Local state exists but server validation is stale or missing. | Deny sensitive access until validated. |
| `restoreRequired` | Account needs restore flow before entitlement state is trusted. | Deny paid access until restore architecture is implemented. |
| `revoked` | Provider or backend revoked entitlement. | Deny access and clear download eligibility. |
| `refunded` | Purchase was refunded. | Deny access and mark previous access invalid. |
| `providerUnavailable` | Provider cannot be reached. | Use cached entitlement only if policy allows and expiry is valid. |

Subscription entitlement records are scoped to the HighFive-owned user ID and validated through BackendServiceLayer before production paid access is enforced.

## 8. Purchase State Model

The purchase state model is defined for future implementation only. It does not add purchases.

| State | Meaning |
| --- | --- |
| `notOffered` | No purchase UI is available in the current environment. |
| `providerNotConnected` | StoreProviderAdapter has no live provider. |
| `providerSelected` | RevenueCat + StoreKit is selected for future implementation. |
| `stagingReady` | Staging credentials and test products are approved later. |
| `productsConfigured` | App Store product configuration has been approved later. |
| `purchaseAvailable` | StoreProviderAdapter can present purchase capability later. |
| `purchasePending` | Future purchase is waiting for provider completion. |
| `purchaseDenied` | Purchase is blocked by policy, provider, account, validation, or App Store state. |
| `validationRequired` | Transaction or entitlement must be server validated. |
| `entitlementActive` | Validated access exists. |
| `entitlementExpired` | Validated access has expired. |
| `providerUnavailable` | Provider is unavailable or disabled. |

No purchase flows, subscriptions, product IDs, or purchase UI are included in #042.0A.

## 9. Restore Purchase Architecture

Restore purchase architecture is required before paid access ships, but no restore purchase behavior is implemented in this phase.

Future restore flow:

1. User must have an AuthService session or a defined account linking policy.
2. AuthService resolves a HighFive-owned user ID.
3. PaymentEntitlementService requests restore state from StoreProviderAdapter.
4. StoreProviderAdapter asks the selected provider to refresh customer ownership later.
5. BackendServiceLayer stores restored entitlement records after server validation.
6. PaymentEntitlementService returns restored, validation required, provider unavailable, or restore failed state.
7. PlaybackService, DownloadService, and LibraryService update access from the refreshed entitlement model.

Restore architecture requirements:

- Restore must not grant access from local device state alone.
- Restored access must map to the HighFive-owned user ID.
- Restored transactions must pass receipt / transaction validation and server entitlement validation.
- Restore failures must not break free local preview behavior.
- App Store review notes must describe restore behavior before paid access ships.

## 10. Receipt / Transaction Validation Policy

Receipt / transaction validation is server-mediated in production. The app must not trust device-only payment state for premium playback or downloads.

Policy:

- StoreProviderAdapter may read provider-safe transaction or customer state later.
- PaymentEntitlementService must treat local transaction state as validation required until BackendServiceLayer confirms it.
- BackendServiceLayer owns server-side validation with the selected payment provider.
- Validated results create or update entitlement records.
- Stale, missing, revoked, refunded, or expired transaction state must not grant production access.
- Receipt / transaction validation failures map to validation required, entitlement expired, purchase denied, or provider unavailable.

Current #042.0A status: no StoreKit implementation, no RevenueCat SDK/config, no Stripe SDK/config, no receipt validation code, no transaction validation code.

## 11. Server Entitlement Validation Policy

Server entitlement validation is the production source of truth.

BackendServiceLayer must later provide:

- HighFive-owned user ID lookup.
- Provider customer mapping.
- Entitlement records keyed to HighFive-owned user ID.
- Validation timestamps and expiry.
- Refund / revocation handling.
- Expired entitlement handling.
- Audit trail for access grants and denials.
- Rollback path to local preview or free mode when provider integration is disabled.

PaymentEntitlementService must deny sensitive access when server entitlement validation is missing, stale, revoked, expired, or unavailable beyond the allowed cached window.

## 12. Refund / Revocation Handling

Refund and revocation events remove or reduce access. They must be handled by BackendServiceLayer and surfaced through PaymentEntitlementService.

Required behavior:

- Mark entitlement records refunded or revoked.
- Stop new premium playback access through PlaybackService.
- Stop new download access through DownloadService.
- Mark existing offline eligibility invalid when policy requires removal or expiry.
- Reflect account state in LibraryService without exposing payment details.
- Preserve audit evidence for support and App Store review.
- Avoid local-only overrides for refunded or revoked access in production.

## 13. Expired Entitlement Handling

Expired entitlement handling must be explicit and testable.

Required behavior:

- Entitlements with past `expiresAt` become `entitlementExpired`.
- PlaybackService denies premium streaming unless a refreshed entitlement becomes active.
- DownloadService denies new offline access and validates existing offline assets against expiry policy.
- LibraryService can still show saved titles and account state, but not grant paid playback.
- PaymentEntitlementService can request refresh through StoreProviderAdapter later, then BackendServiceLayer must validate the result.
- Local preview fallback remains separate from production entitlement expiry.

## 14. Playback / Download Dependency Map

| Service | Payment dependency | Required result |
| --- | --- | --- |
| PlaybackService | Calls PaymentEntitlementService before premium playback source requests. | Allow only active, server-validated access or approved local preview. |
| DownloadService | Calls PaymentEntitlementService before offline availability or license refresh. | Allow only active entitlement with offline policy approval. |
| BackendServiceLayer | Stores entitlement records and validates access. | Server authoritative entitlement state. |
| AuthService | Provides HighFive-owned user ID. | Account-scoped access and restore mapping. |

Playback access dependency:

- Free or local preview playback can continue only under explicit local preview policy.
- Premium playback waits for active subscription entitlement.
- Validation required, refund, revocation, expired entitlement, or provider unavailable states deny production paid access unless cached policy explicitly allows a short grace period.

Download access dependency:

- Real downloads wait for entitlement validation, offline rights, storage policy, expiry handling, and revocation handling.
- DownloadService must not rely on LibraryService saved state as proof of paid access.

## 15. Library / Account Dependency Map

| Service | Payment relationship |
| --- | --- |
| AuthService | Required for HighFive-owned user ID and account-scoped restore architecture. |
| LibraryService | Displays saved, progress, and account context; does not validate payment alone. |
| UserProfileService | May display account-level entitlement summary later. |
| BackendServiceLayer | Owns entitlement records and account mapping. |

Library/account dependency:

- Paid access requires AuthService once production entitlements are enforced.
- Local unauthenticated preview remains available for simulator demos until live payments are explicitly approved.
- LibraryService may read entitlement summary for user messaging, but PaymentEntitlementService remains the access authority.

## 16. Local / Staging / Production Environment Model

| Environment | Payment behavior |
| --- | --- |
| Local | Local preview fallback only; no live payment provider; no product IDs; no SDKs; no credentials. |
| Staging | Staging payment model after approval; RevenueCat + StoreKit sandbox readiness; test products; BackendServiceLayer validation; rollback flag. |
| Production | Production payment model after approval; App Store product configuration; secure credentials; server validation; refund/revocation handling; monitoring; rollback plan. |

Local preview:

- Does not connect to payment providers.
- Does not simulate real purchases as production truth.
- Keeps Home, Search, Movie Detail, My List, Downloads, and Profile usable without live payments.

Staging payment model:

- Requires selected provider project and sandbox configuration later.
- Requires test account policy and server validation.
- Requires restore, expired entitlement, refund/revocation, and provider unavailable tests.

Production payment model:

- Requires App Store product configuration, App Store review readiness, privacy review, secure credentials, backend validation, monitoring, and rollback.

## 17. Credential Requirements

Credentials are required later, not in #042.0A:

- RevenueCat project configuration if selected for implementation.
- StoreKit product setup in App Store Connect.
- StoreKit sandbox tester process.
- Provider webhook credentials if provider server events are approved later.
- BackendServiceLayer credentials for entitlement validation and records.
- Stripe web credentials only if a web fallback is approved where Apple rules allow.
- Separate staging and production payment credentials.
- Support/admin credentials for refund/revocation review with audit logging.

Current status: not collected, not configured, not committed.

## 18. Backend Requirements

BackendServiceLayer must exist before production paid access is enforced.

Required backend capabilities:

- HighFive-owned user ID records.
- Provider customer mapping records.
- Entitlement records.
- Subscription Entitlement read model.
- Purchase state read model.
- Receipt / transaction validation integration later.
- Server entitlement validation policy.
- Refund / revocation event handling.
- Expired entitlement handling.
- Restore purchase architecture support.
- Playback access decision support.
- Download access decision support.
- Library/account entitlement summary.
- Audit trail for entitlement mutations.
- Rollback flag and provider health state.

## 19. App Store Requirements

App Store requirements before implementation:

- App Store product configuration requirements must be finalized before purchase UI or purchase flows.
- App Store review requirements must be reviewed for digital content, subscriptions, restore behavior, account requirements, and any Stripe web fallback.
- Restore purchase behavior must be designed and tested before paid access ships.
- Privacy labels must be reviewed before collecting payment entitlement state or linking it to account data.
- App Review notes must explain any account requirement, entitlement gates, restore flow, and allowed external billing behavior if applicable.
- No product IDs are added in #042.0A.

## 20. Privacy Requirements

Privacy requirements:

- Payment details remain with the payment provider.
- HighFive stores entitlement state, validation state, expiry, refund/revocation state, and audit references only.
- Entitlement records are high privacy because they reveal paid access and viewing eligibility.
- Library, playback, download, and account data must be scoped to the HighFive-owned user ID.
- Account deletion must address entitlement records and support obligations.
- Analytics must not record purchase or entitlement details until event allowlist and consent policy are approved.
- No URLs/tokens/secrets/API keys are added in this phase.

## 21. Rollback Strategy

Rollback strategy:

- Local preview fallback remains available.
- Payment provider integration can be disabled by environment flag later.
- PaymentEntitlementService returns provider not connected, provider unavailable, validation required, or local preview state instead of crashing access flows.
- PlaybackService and DownloadService treat disabled payment provider as free/local preview only when explicitly allowed by environment policy.
- BackendServiceLayer preserves entitlement records for audit, but stops granting new paid access when rollback disables provider trust.
- UI screens stay decoupled from RevenueCat, StoreKit, and Stripe SDK types.

## 22. What Connects First

What Connects First:

1. Payment architecture review and provider decision.
2. BackendServiceLayer entitlement records and HighFive-owned user ID mapping.
3. AuthService stable session and account identity.
4. PaymentEntitlementService protocol and local preview adapter.
5. StoreProviderAdapter protocol with provider not connected states.
6. Staging payment model and sandbox readiness after explicit approval.
7. RevenueCat + StoreKit implementation only after App Store product configuration and backend validation are ready.

## 23. What Waits

What Waits:

- Live RevenueCat SDK/config waits for explicit implementation scope.
- StoreKit implementation waits for explicit implementation scope.
- Stripe SDK/config waits unless web fallback is approved where Apple rules allow.
- Purchase UI waits for product, App Store, privacy, and rollback review.
- Product IDs wait for App Store product configuration approval.
- Subscriptions wait for entitlement model and validation approval.
- Restore purchase behavior waits for restore architecture implementation scope.
- Paywall waits for later product scope.
- Real downloads wait for entitlement validation and offline rights policy.
- Production payment model waits for staging evidence and App Store review readiness.

## 24. Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| App Store payment rule violation | App rejection or forced redesign | Prefer RevenueCat + StoreKit; use Stripe web only where Apple rules allow. |
| Provider lock-in | Migration cost | Keep `PaymentEntitlementService` and `StoreProviderAdapter` HighFive-owned. |
| Entitlement mismatch | Incorrect access grants or denials | Server entitlement validation and audit records. |
| Device-only trust | Unauthorized access | Treat local transaction state as validation required. |
| Restore gaps | Paid users lose access | Restore purchase architecture before paid launch. |
| Refund/revocation delay | Invalid access remains active | Backend event handling and refresh policy. |
| Expired entitlement drift | Premium access after expiry | Explicit expiry checks in PaymentEntitlementService. |
| Account mapping drift | Entitlements assigned to wrong account | HighFive-owned user ID dependency and contract tests. |
| Privacy overcollection | Compliance and trust risk | Store entitlement state only; payment details stay with provider. |
| Credentials in repo | Security incident | Secure configuration only; no SDKs/URLs/tokens/secrets/app code changes in this phase. |
| UI tied to SDK | Rewrite cost | SwiftUI screens call service boundaries only. |
| Download entitlement gap | Offline access after revocation | DownloadService depends on PaymentEntitlementService and expiry policy. |

## 25. Evidence For #042

- RevenueCat + StoreKit preferred.
- Stripe web fallback only where Apple rules allow.
- `PaymentEntitlementService` boundary defined.
- `StoreProviderAdapter` boundary defined.
- BackendServiceLayer dependency defined.
- AuthService dependency defined.
- HighFive-owned user ID dependency defined.
- entitlement records defined.
- Subscription Entitlement model defined.
- purchase state model defined.
- restore purchase architecture defined.
- receipt / transaction validation policy defined.
- server entitlement validation policy defined.
- refund, revocation, and expired entitlement handling defined.
- PlaybackService and DownloadService dependencies defined.
- LibraryService account dependency defined.
- local preview, staging payment, and production payment models defined.
- Credential Requirements documented.
- App Store product configuration requirements documented.
- App Store review requirements documented.
- Backend Requirements documented.
- Privacy Requirements documented.
- Rollback Strategy documented.
- Risk Register documented.
- What Connects First documented.
- What Waits documented.
- No live payment provider.
- No StoreKit implementation.
- No RevenueCat SDK.
- No Stripe SDK.
- No purchase UI.
- No SDKs/URLs/tokens/secrets/app code changes.

## 26. Known Limitations

- Architecture only.
- No live payment provider.
- No RevenueCat SDK/config.
- No StoreKit implementation.
- No Stripe SDK/config.
- No purchases.
- No subscriptions.
- No product IDs.
- No restore purchase behavior.
- No paywall.
- No URLs/tokens/secrets/API keys.
- No app code changes.
