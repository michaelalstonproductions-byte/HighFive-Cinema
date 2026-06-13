# HighFive Provider Selection Integration Plan

## #037 Provider Selection + Integration Plan

This plan captures the current provider shortlist and integration sequence. It is architecture-only. It does not add SDKs, URLs, keys, secrets, StoreKit, RevenueCat, Stripe, auth providers, backend calls, push registration, analytics SDKs, or app-code integration.

## Provider Shortlist

| Domain | Preferred | Fallback | First integration phase | Boundary |
| --- | --- | --- | --- | --- |
| Video Streaming | Cloudflare Stream | Mux | #039 Streaming Provider Integration | `PlaybackService` |
| Authentication | Clerk | Auth0 or Custom | #038 Account Provider Architecture, then #041 Authentication | `AuthService` |
| Backend | Supabase hybrid | Custom API | #040 Backend Service Layer | Backend service adapters |
| Payments | RevenueCat + StoreKit | Stripe web where Apple rules allow | #042 Payment Provider Integration | `PaymentEntitlementService` |
| Notifications | APNs | OneSignal later | #048 Production Hardening | `NotificationService` |
| Analytics | PostHog | Mixpanel or Custom | #048 Production Hardening | `AnalyticsService` |
| Communication | Custom curated updates | Stream or Sendbird only if real chat is approved | #045 Communication Backend | `ConnectService` |

## Provider Decision Matrix

| Domain | Primary decision | Why preferred | Fallback trigger | Blocks |
| --- | --- | --- | --- | --- |
| Streaming | Cloudflare Stream primary | Fits managed streaming and CDN-oriented delivery with a narrow playback adapter | Choose Mux if video workflow, asset analytics, or encoding operations are stronger fit | Playback source integration, real downloads |
| Auth | Clerk primary | Fast account architecture and managed user workflows | Choose Auth0 for enterprise identity needs; choose custom if full control outweighs speed | Library sync, payments, personalization |
| Backend | Supabase hybrid primary | Strong managed database layer while preserving custom domain APIs where needed | Choose custom API if security, portability, or operations require full ownership | Auth bridge, library, launch, delivery, entitlements |
| Payments | RevenueCat + StoreKit primary | Strong iOS subscription and entitlement workflow | Use Stripe web only where Apple rules allow and backend entitlement sync is approved | Paid access, restore, entitlement gates |
| Notifications | APNs first | Native delivery with minimal third-party footprint | Add OneSignal later if dashboard tooling and campaign operations justify SDK/privacy cost | Push campaigns, communication alerts |
| Analytics | PostHog primary | Product analytics with flexible event modeling | Use Mixpanel for mature analytics workflow; custom for stricter privacy/control | Beta observability, product learning |
| Communication | Custom curated updates first | Safer moderation and scope control for launch | Use Stream or Sendbird only after real chat is approved | Community, messaging, notification triggers |

## Backend Dependency Graph

```text
AuthService
  -> AccountProviderAdapter
  -> BackendServiceLayer

PaymentEntitlementService
  -> StoreProviderAdapter
  -> BackendServiceLayer entitlement records
  -> PlaybackService access checks
  -> DownloadService access checks

PlaybackService
  -> StreamingProviderAdapter
  -> PaymentEntitlementService
  -> MovieCatalogService

LibraryService
  -> AuthService
  -> BackendServiceLayer
  -> CloudLibraryProviderAdapter for saved titles, watch progress, continue watching, and My List sync later
  -> MovieCatalogService

DownloadService
  -> AuthService
  -> PlaybackService
  -> PaymentEntitlementService
  -> BackendServiceLayer

ConnectService
  -> AuthService
  -> BackendServiceLayer
  -> NotificationService when approved

LaunchService
  -> AuthService
  -> BackendServiceLayer
  -> ConnectService for approved public updates

ExportPackageService
  -> AuthService
  -> BackendServiceLayer
  -> LaunchService handoff context

NotificationService
  -> AuthService
  -> BackendServiceLayer preferences
  -> APNs or later notification provider

AnalyticsService
  -> Consent state
  -> Privacy-approved event allowlist
```

## Integration Rules

- Keep local adapters as the default until each provider phase is explicitly approved.
- Put every provider behind a HighFive-owned service protocol.
- Do not let SwiftUI screens call raw SDKs, URLs, or provider clients directly.
- Do not commit provider keys, tokens, secrets, URLs, signing material, or private environment files.
- Do not modify protected Depth, Motion, Playback, Layer4, Rendering, Store, assets, project, Info.plist, privacy, or entitlement files unless a later phase explicitly scopes the risk.
- Every live provider phase needs a rollback flag or configuration path back to local mode.
- Every live provider phase needs staging smoke tests, denied/error states, and privacy review before production.

## Phase Sequence

| Phase | Name | Outcome |
| --- | --- | --- |
| #037 | Provider Selection + Integration Plan | Lock shortlist, risks, sequence, and decision gates. |
| #038 | Account Provider Architecture | Choose account model and Clerk/Auth0/custom boundary. |
| #039 | Streaming Provider Integration | Connect Cloudflare Stream or Mux behind playback contracts. |
| #040 | Backend Service Layer | Establish Supabase/custom/hybrid backend adapter layer. |
| #041 | Authentication | Implement selected auth provider behind `AuthService`. |
| #042 | Payment Provider Integration | Implement RevenueCat + StoreKit or Stripe web entitlement bridge. |
| #043 | Cloud Library Sync | Sync saved titles and progress through account-scoped library service. |
| #044 | Real Downloads | Add real offline media policy, license, expiry, and storage behavior. |
| #045 | Communication Backend | Connect Custom, Stream, or Sendbird behind `ConnectService`. |
| #046 | Launch Campaign Backend | Store campaign plans and milestones through backend service layer. |
| #047 | Delivery Backend | Store delivery package records and handoff state. |
| #048 | Production Hardening | Lock notification, analytics, privacy, security, and rollback readiness. |
| #049 | Beta Readiness | Validate TestFlight readiness and staging provider evidence. |
| #050 | Production Launch Candidate | Final QA, production configuration, monitoring, and launch evidence lock. |

## Decision Gates

- Primary and fallback provider per domain.
- Beta-blocking domains vs post-beta domains.
- Account requirement for beta.
- Apple sign-in requirement.
- Subscription/rental/purchase model.
- Cross-platform entitlement requirements.
- Streaming DRM/offline policy.
- Backend ownership and migration owner.
- Moderation and support owner.
- Notification categories and consent copy.
- Analytics event allowlist and opt-out policy.

## Credential Requirements

| Domain | Credentials required later | Current #037 status |
| --- | --- | --- |
| Streaming | Provider account, playback signing policy, upload/admin credentials if used | Not collected, not configured |
| Auth | Provider project, client identifiers, sign-in configuration, account deletion/support process | Not collected, not configured |
| Backend | Database/project credentials, service-role credentials, migration credentials, storage credentials if used | Not collected, not configured |
| Payments | Store products, RevenueCat project if selected, StoreKit product identifiers, Stripe web credentials only if allowed | Not collected, not configured |
| Notifications | Apple push capability, APNs key/cert, device registration backend, OneSignal credentials only if selected later | Not collected, not configured |
| Analytics | Project key, event allowlist, consent policy, opt-out behavior | Not collected, not configured |
| Communication | Provider credentials if Stream/Sendbird selected, moderation credentials, webhook secrets if needed | Not collected, not configured |

## Environment Requirements

| Environment | Purpose | Requirements before use |
| --- | --- | --- |
| Local | Simulator demos and fallback behavior | Local adapters remain default; no remote credentials |
| Staging | Provider smoke tests with non-production data | Explicit provider selection, secure config, rollback flag, test accounts |
| Production | Launch candidate and App Store release | Privacy approval, production credentials, monitoring owner, rollback plan |

## Server Requirements

- Backend service layer for account-scoped library sync, entitlement records, launch campaigns, delivery packages, notification preferences, and provider health.
- Server-side entitlement validation before paid access is enforced.
- Device registration endpoint before push notifications are enabled.
- Webhook handling only after provider selection and secret storage policy are approved.
- Migration ownership, backup policy, audit logs, and admin access policy before beta.

## App Store Requirements

- StoreKit product configuration before in-app purchase or subscription flows.
- Apple sign-in review if third-party auth is used and accounts are required.
- Privacy nutrition labels updated before adding analytics, notifications, account, or payment data collection.
- Push notification entitlement and user-facing permission copy before APNs registration.
- Clear restore purchase behavior before paid access ships.
- App Review notes for any web billing or external account behavior, especially Stripe web usage.

## What Connects First

- Backend service layer architecture and staging project decision.
- Account provider architecture, then authentication.
- Streaming provider behind `PlaybackService`.
- Payment entitlement service only after auth/backend decisions are stable.
- Cloud library sync after auth and backend are active.

## What Waits

- Real downloads wait for streaming, auth, backend, and entitlements.
- Communication provider waits for moderation and product-scope approval.
- Launch and delivery backends wait for backend service layer ownership.
- Notifications wait for communication/launch triggers and consent copy.
- Analytics waits for event allowlist and privacy approval.
- OneSignal, Stream, and Sendbird wait until managed third-party scope is justified.

## Infrastructure Requirements By Capability

| Capability | Requires backend/server infrastructure | Requires App Store configuration | Requires credentials |
| --- | --- | --- | --- |
| Cloudflare Stream or Mux playback | Yes, for signed/source mediation if used | No, unless playback policy affects review notes | Yes |
| Clerk/Auth0/custom auth | Yes, for account records and deletion workflow | Apple sign-in may be required | Yes |
| Supabase hybrid/custom API | Yes | No | Yes |
| RevenueCat + StoreKit | Yes, for entitlement records and validation policy | Yes | Yes |
| Stripe web | Yes, for web billing and entitlement bridge | Review-sensitive; Apple rules apply | Yes |
| Cloud library sync | Yes | No | Yes |
| Real downloads | Yes, for license/entitlement state | Possibly, if offline media policy affects review | Yes |
| Custom curated updates | Yes | No | Maybe, depending on backend |
| Stream or Sendbird chat | Yes | No | Yes |
| APNs | Yes, for device registration/preferences | Yes | Yes |
| OneSignal | Yes | Yes, if push capability is used | Yes |
| PostHog/Mixpanel/custom analytics | Maybe, depending on hosting/model | Privacy labels required | Yes |

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Provider lock-in | Expensive migration later | Use HighFive-owned protocols and adapters. |
| Secrets in repo | Security and release blocker | Keep all credentials in secure environment/config only. |
| App Store payment rule violation | App rejection | Prefer RevenueCat + StoreKit for iOS paid access; use Stripe web only where allowed. |
| Entitlement mismatch | Incorrect access grants or denials | Server-side validation and local fallback states before paid gates. |
| Streaming URL leakage | Unauthorized access | Short-lived source mediation and no raw provider calls in UI. |
| Auth support burden | Account deletion/support gaps | Choose ownership model before beta. |
| Notification overreach | User trust and review risk | APNs first, explicit opt-in, category-level preferences. |
| Analytics privacy drift | Privacy policy mismatch | Event allowlist and opt-out before SDK/config. |
| Chat moderation gap | User safety risk | Start with custom curated updates; real chat needs moderation approval. |
| Backend ownership ambiguity | Slow incidents and migrations | Assign schema, admin, and support owners before staging. |

## Evidence Required Before Live Integration

- Source verifier confirming only scoped files changed.
- Protected path scan clean.
- Blocked provider scan clean until live integration is explicitly approved.
- No secrets, URLs, tokens, API keys, or private config committed.
- Local fallback documented and tested.
- Staging smoke test plan documented before production.
