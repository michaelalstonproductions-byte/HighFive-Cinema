# HighFive Payment Entitlement Staging Foundation

## Purpose

#057.0A adds a release-safe payment and entitlement staging foundation. It defines the app boundary for access decisions, restore readiness, provider configuration presence, and server entitlement validation requirements without enabling live purchases.

This is not a production payment launch.

## Preferred Production Direction

- Preferred iOS path: RevenueCat plus StoreKit after product, privacy, refund, restore, and App Store review.
- Web fallback: Stripe only where Apple rules allow and only behind backend-mediated entitlement validation.
- App boundary: `PaymentEntitlementService` / `HFEntitlementService`.
- Provider boundary: StoreProviderAdapter and remote entitlement provider remain provider-ready only.

## Runtime Config Names

- `HIGHFIVE_PAYMENT_PROVIDER`
- `HIGHFIVE_PAYMENT_MODE`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`
- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`

The app checks presence only. No real values, product IDs, tokens, provider credentials, URLs, or secrets are committed.

## Local Fallback Behavior

Missing payment config keeps the app in `Local Preview Access`.

Partial payment config reports provider readiness gaps such as:

- `Payment Provider Not Connected Yet`
- `Purchase Provider Missing`
- `Entitlement Provider Missing`
- `Restore Purchases Not Active Yet`

Complete config may report `Entitlement Configured`, but that state is still staging-only and does not activate live purchase, paid access, restore, receipt validation, or subscription behavior.

## Server Entitlement Validation Requirement

Production paid access requires server entitlement validation before any sensitive access is granted. The server boundary must handle:

- Restore purchase validation.
- Refund and revocation state.
- Expired entitlement state.
- Account-to-entitlement mapping.
- Provider update reconciliation.
- Audit-safe entitlement records.

Local device state must not grant paid access by itself.

## UI Boundary

Movie Detail shows entitlement/access readiness without blocking local preview playback.

Profile shows Membership readiness and restore readiness without purchase CTAs.

Creator Studio VOD Package shows `Pricing / entitlement boundary`, provider-ready rows, and `No live VOD provider`.

Allowed local review CTAs are limited to readiness review. Live purchase, subscribe, buy, rent, restore, and provider connection actions wait for a future production-scoped phase.

## What Waits For Production

- Live purchase flow.
- StoreKit transaction handling.
- RevenueCat SDK integration.
- Stripe checkout or web payment fallback.
- Paywall.
- Enabled buy, subscribe, rent, or restore buttons.
- Receipt or transaction validation.
- Server entitlement validation implementation.
- Refund, revocation, and expired entitlement handling.
- Real product identifiers.
- Provider credentials.
- App Store production configuration.
