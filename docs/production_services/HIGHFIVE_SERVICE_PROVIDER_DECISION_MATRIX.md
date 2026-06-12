# HighFive Service Provider Decision Matrix

This matrix lists the current provider shortlist and decision criteria. It does not select a final provider. HighFive should not add production SDKs until product, privacy, budget, and operations decisions are confirmed.

## 0. Recommended Stack

| Domain | Preferred | Fallback / later option |
| --- | --- | --- |
| Streaming | Cloudflare Stream | Mux |
| Auth | Clerk | Auth0 or Custom |
| Backend | Supabase hybrid | Custom API |
| Payments | RevenueCat + StoreKit | Stripe web only where Apple rules allow |
| Notifications | APNs first | OneSignal later |
| Analytics | PostHog | Mixpanel or Custom |
| Communication | Custom curated updates first | Stream or Sendbird only if real chat is approved |

## 1. Video Streaming

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| Cloudflare Stream | Preferred for managed streaming and CDN-aligned delivery | Cost model, DRM/offline constraints, admin workflow | PlaybackService and StreamingProviderAdapter |
| Mux | Fallback if video workflow, asset analytics, or operations are stronger fit | Cost model, DRM/offline constraints, catalog ingestion | PlaybackService and StreamingProviderAdapter |

Decision questions:

- Are movies hosted by HighFive or embedded from existing services?
- Is DRM required at launch?
- Are source URLs short-lived?
- Is offline playback in scope for beta?

## 2. Authentication

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| Clerk | Preferred managed auth and account UI support | Product fit, pricing, Apple sign-in support, data ownership | AuthService and AccountProviderAdapter |
| Auth0 | Fallback for enterprise-grade auth and portability | Complexity, cost, Apple sign-in support, support process | AuthService and AccountProviderAdapter |
| Custom | Fallback for maximum control | Build/support cost, security ownership, account deletion operations | AuthService and owned backend API |

Decision questions:

- Is account login required at beta?
- Is Apple sign-in required for iOS launch?
- Are creator accounts different from viewer accounts?
- Who owns account support and account deletion?

## 3. Payments

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| RevenueCat + StoreKit | Preferred for iOS subscriptions and entitlement sync | Product tiers, restore behavior, server validation policy | PaymentEntitlementService |
| Stripe (web) | Fallback for web/admin billing only where Apple rules allow | Apple rules, cross-platform entitlement sync, backend validation | Web billing plus entitlement bridge |

Decision questions:

- Are subscriptions, rentals, purchases, or memberships required at launch?
- Is paid access Apple-only or cross-platform?
- How are Stripe web purchases mapped back into app entitlements?
- Who owns refunds, revocation, and support?

## 4. Communication

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| Custom | Preferred for curated updates and exact moderation rules | Build cost, moderation tooling, notification path | ConnectService and CommunicationProviderAdapter |
| Stream | Later option for real chat and moderation tooling | Cost, product fit, user safety policy | ConnectService and CommunicationProviderAdapter |
| Sendbird | Later option for chat/community messaging | Cost, product fit, user safety policy | ConnectService and CommunicationProviderAdapter |

Decision questions:

- Is v1 real chat, comments, or curated updates?
- Who moderates user-generated content?
- Are public rooms, private rooms, or one-way updates in scope?
- Do communications trigger notifications?

## 5. Notifications

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| APNs | Preferred native iOS notification delivery | Backend device registration and preference sync | NotificationService |
| OneSignal | Later option for managed notification tooling | SDK footprint, privacy review, cost, data sharing | NotificationService |

Decision questions:

- What categories justify push notifications?
- What opt-in copy is required?
- Is managed dashboard tooling worth the SDK/privacy tradeoff?

## 6. Analytics

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| PostHog | Preferred product analytics and event exploration | Privacy event list, hosting mode, opt-out | AnalyticsService |
| Mixpanel | Fallback product analytics | Privacy event list, cost, opt-out | AnalyticsService |
| Custom | Fallback for maximum privacy/control | Build cost, dashboard needs, event pipeline ownership | AnalyticsService and owned backend |

Decision questions:

- Which events are allowed before privacy approval?
- Should viewing behavior be excluded or aggregated?
- Is opt-out required before beta?

## 7. Backend

| Candidate | Fit | Key decision | Integration boundary |
| --- | --- | --- | --- |
| Supabase hybrid | Preferred managed data layer with custom domain APIs where needed | Security policies, migrations, admin model | BackendServiceLayer |
| Custom API | Fallback for strongest control and portability | Build cost, operations, admin tooling | BackendServiceLayer |
| Hybrid | Pattern for mixing managed data and owned service boundaries | Complexity, ownership split, integration testing | BackendServiceLayer |

Decision questions:

- Who owns schema migrations and admin tools?
- Which domains require realtime behavior?
- Which service owns entitlement validation?
- What data must never leave owned infrastructure?

## 8. Recommended Decision Gates

Before adding any production SDK, answer:

- Is this Apple-only at launch?
- Is there user account login at v1?
- Are movies hosted by HighFive or embedded from existing services?
- Are creators uploading video?
- Is there real community messaging or curated updates only?
- Are subscriptions required at launch?
- What privacy level is required?
- What budget/services are already owned?
- Who owns moderation and support operations?
- Which candidates are primary vs fallback?
- Which providers are beta-blocking vs post-beta?

No production SDK should be added until these provider decisions are confirmed.
