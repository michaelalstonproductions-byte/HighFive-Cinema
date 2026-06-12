# HighFive Real Services Architecture

## 1. Executive Summary

HighFive currently has a local-first functional foundation: cinematic onboarding, movie routing, a Watch Now player path, saved and downloaded local state, local Connect updates, a local Launch checklist, a delivery summary, and Profile/Demo proof surfaces.

Production service work now needs architecture, provider decisions, API contracts, security rules, privacy review, and staged integration. The screens should not call provider SDKs or raw service clients directly. HighFive should introduce app-owned stores, service protocols, and provider adapters so local simulator behavior remains stable while staging and production services can be added safely.

This phase does not add live services, production SDKs, accounts, payment code, provider keys, or secrets. It locks the service plan before implementation begins.

## 2. Current App Foundation

| Area | Current local behavior | Future production need |
| --- | --- | --- |
| Onboarding | Cinematic intro, motion training, controls training, completion to Home | Account-aware first-run state, privacy consent, optional profile setup |
| Home and Movie Detail | Home routes toward Movie Detail through local movie data | Remote catalog, personalized rails, availability rules |
| Player path | Watch Now opens a controlled player route or honest placeholder | Real playback sources, entitlements, HLS, offline rules |
| My List | Saved state persists locally through `HFStreamingStore` | Account-scoped library sync |
| Downloads | Downloaded/offline state persists locally | Real offline media license and storage policy |
| Connect | Local update draft/list behavior | Curated updates, moderation, delivery status |
| Launch | Local release checklist/progress | Campaign records, calendar state, approvals |
| Export | Local delivery text summary and optional share summary | Delivery package records and external handoff workflow |
| Profile/Demo | Functional Core proof and presentation proof | Internal QA, admin eligibility, environment diagnostics |

## 3. Production Service Domains

| Domain | Purpose | Current local placeholder | Production service needed | Sensitive data | Risk | First phase |
| --- | --- | --- | --- | --- | --- | --- |
| Identity / Accounts | Identify users and sessions | No real login | Clerk, Auth0, or custom account service | Account identifiers, email if collected | High | Phase 38A |
| User Profile | Store profile and preferences | Local profile mock data | Profile service behind account provider | Display name, preferences | Medium | Phase 38A |
| Movie Catalog / CMS | Serve movie metadata and rails | `HFMockData` | Backend service layer | Low unless personalized | Medium | Phase 40A |
| Video Streaming / Hosting | Provide playable media | Player route or placeholder | Cloudflare Stream or Mux adapter | Viewing access, source URLs | High | Phase 39A |
| Playback Entitlements | Decide access | None | Payment/entitlement service | Purchase/subscription state | High | Phase 42A |
| Offline Downloads | Manage offline media rights | Local downloaded flag | Download service and offline policy | Viewing history, license state | High | Phase 44A |
| My List / Library Sync | Sync saved/progress state | Local saved/downloaded IDs | Library sync service | Viewing history, saved titles | High | Phase 43A |
| Connect Updates / Communication | Publish creator/audience updates | Local draft/list | Custom, Stream, or Sendbird adapter | User text, creator content | High | Phase 45A |
| Launch Campaigns | Manage release plans | Local checklist | Campaign service on backend layer | Campaign plans, dates | Medium | Phase 46A |
| Creator Studio Projects | Store creator project data | Static room surfaces | Project service | Project metadata, assets | High | Phase 34A |
| Export / Delivery Packages | Track delivery summaries | Local text summary | Delivery package service on backend layer | Project/package data | High | Phase 47A |
| Payments / Subscriptions | Monetize access | None | RevenueCat + StoreKit or Stripe web bridge | Payment entitlement state | High | Phase 42A |
| Notifications | Notify opted-in users | None | APNs or OneSignal adapter | Device notification preference | High | Phase 48A |
| Analytics / Crash Reporting | Improve stability and product | None | PostHog, Mixpanel, or custom analytics | Usage events, crash context | High | Phase 48A |
| Admin / Moderation | Review catalog, updates, users | None | Admin console and moderation queue | Moderation history | High | Phase 33A |
| Security / Privacy | Protect data and compliance | Safety docs/verifiers | Security review, privacy policy, audit | All user and creator data | High | Phase 27B onward |

## 4. Service Boundaries

Recommended layer order:

```text
UI Screen
Feature ViewModel / Store
Service Protocol
Provider Adapter
Remote API / SDK
```

Rules:

- UI never owns secrets.
- UI never calls raw provider SDKs directly.
- All real services sit behind HighFive-owned protocols and adapters.
- Mock and local adapters remain available for simulator demos and failure-mode tests.
- Production adapters are gated behind configuration and environment selection.
- Stores map provider data into app models before it reaches screens.
- Error states must be explicit, user-safe, and testable.

## 5. Protected System Policy

The following areas remain isolated unless a later phase explicitly scopes them:

- `HighFive/App/Depth/*`
- `HighFive/App/Motion/*`
- `HighFive/App/Playback/*`
- `HighFive/App/Layer4/*`
- `HighFive/App/Rendering/*`
- `HighFive/App/Creator/*`
- `HighFive/App/Store/*`
- `HighFive/App/UI/*`
- `Assets.xcassets`
- `HighFive.xcodeproj/project.pbxproj`
- Info, privacy, entitlement, and signing files

Production services should integrate through new app-facing contracts first. Protected playback, depth, motion, rendering, creator, and store systems should only be touched when a phase explicitly authorizes the work and includes rollback proof.

## 6. Recommended Integration Order

| Phase | Scope | Notes |
| --- | --- | --- |
| Phase 37A | Provider selection + integration plan | Docs only, no live providers |
| Phase 38A | Account provider architecture | Clerk, Auth0, or custom decision |
| Phase 39A | Streaming provider integration | Cloudflare Stream or Mux behind PlaybackService |
| Phase 40A | Backend service layer | Supabase, custom API, or hybrid |
| Phase 41A | Authentication | Implement selected account provider |
| Phase 42A | Payment provider integration | RevenueCat + StoreKit or Stripe web bridge |
| Phase 43A | Cloud library sync | Account-scoped saved/progress data |
| Phase 44A | Real downloads | Do not rush media storage and rights |
| Phase 45A | Communication backend | Custom, Stream, or Sendbird with moderation |
| Phase 46A | Launch campaign backend | Campaign records and approvals |
| Phase 47A | Delivery backend | Text/package records before media engines |
| Phase 48A | Production hardening | Notifications, analytics, privacy, rollback |
| Phase 49A | Beta readiness | TestFlight and staging service evidence |
| Phase 50A | Production launch candidate | Final QA and launch evidence lock |

## 7. Backend Dependency Graph

```text
Account provider
  -> AuthService
  -> BackendServiceLayer

BackendServiceLayer
  -> MovieCatalogService
  -> LibraryService
  -> LaunchService
  -> ExportPackageService
  -> NotificationService preferences
  -> PaymentEntitlementService records

Streaming provider
  -> PlaybackService
  -> PaymentEntitlementService
  -> DownloadService

Payment provider
  -> PaymentEntitlementService
  -> PlaybackService gates
  -> DownloadService gates

Communication provider
  -> ConnectService
  -> NotificationService only after consent and category approval

Analytics provider
  -> AnalyticsService
  -> privacy-approved event allowlist only
```

## 8. Provider Requirements Summary

| Requirement | Applies to | Notes |
| --- | --- | --- |
| Credentials | All live providers | None are collected or committed during #037. |
| Server infrastructure | Auth, backend, payments, library, downloads, communication, launch, delivery, notifications | Required before live provider behavior is enabled. |
| App Store configuration | StoreKit, APNs, account sign-in behavior, privacy labels | Required before payment, push, account, analytics, or data collection ships. |
| Environment selection | Every provider | Local remains default; staging and production must be explicit. |
| Rollback path | Every provider | Each adapter needs a route back to local mode. |

## 9. Known Limitations

- No real backend exists yet.
- No provider has been selected.
- No provider SDKs are added.
- No secrets, provider keys, or credentials are committed.
- No real production streaming is connected unless separately proven in a later phase.
- Downloads are currently local state, not real offline media files.
- Connect updates are local-only, not backend-backed messaging.
- Export is a text/package summary path, not a real media render or delivery engine.
