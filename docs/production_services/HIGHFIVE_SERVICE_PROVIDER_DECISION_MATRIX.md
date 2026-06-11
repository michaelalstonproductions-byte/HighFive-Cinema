# HighFive Service Provider Decision Matrix

This matrix lists provider categories and decision criteria. It does not select a final provider. HighFive should not add production SDKs until product, privacy, budget, and operations decisions are confirmed.

## 1. Identity / Auth

| Candidate category | iOS integration | Account portability | Privacy | Cost complexity | Speed | Lock-in | Admin needs |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Apple Sign In + custom backend | Strong | Medium | Strong | Medium | Medium | Low | Custom admin required |
| Supabase Auth | Good | Good | Depends on configuration | Medium | Fast | Medium | Useful built-in admin |
| Firebase Auth | Good | Good | Depends on configuration | Medium | Fast | Medium | Strong ecosystem |
| Auth0 / Clerk | Good | Strong | Depends on plan/configuration | Medium to high | Fast | Medium | Strong account tooling |
| Custom OAuth | Variable | Strong | Custom responsibility | High | Slow | Low | Fully custom |

Decision questions:

- Is account login required at v1?
- Is Apple-only launch acceptable?
- Are creator accounts different from viewer accounts?
- Who owns account support and account deletion operations?

## 2. Database / Backend

| Candidate category | Realtime needs | Media metadata | Creator workflows | Admin tooling | Security policies | Migrations | Offline sync |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Supabase | Strong | Good | Good | Good | Strong if configured | SQL-based | Moderate |
| Firebase | Strong | Good | Moderate | Good | Rule-based | NoSQL migration planning | Strong client patterns |
| Custom Node/Express + Postgres | Custom | Strong | Strong | Custom | Custom | Strong | Custom |
| Cloudflare Workers + D1/R2 | Good edge fit | Good | Moderate | Custom | Custom | Evolving | Custom |
| AWS stack | Strong | Strong | Strong | Strong but complex | Strong | Complex | Custom |

Decision questions:

- Does Connect need realtime messaging or curated update feeds?
- Do creators upload and manage projects in v1?
- Who operates migrations, admin tools, and support workflows?

## 3. Video Hosting / Streaming

| Candidate category | HLS support | DRM potential | Thumbnails | Encoding | iOS playback | Cost | Analytics |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mux | Strong | Available by plan | Strong | Managed | Strong | Usage-based | Strong |
| Cloudflare Stream | Strong | Varies by plan | Good | Managed | Strong | Usage-based | Good |
| Vimeo OTT/private API | Strong | Platform-dependent | Good | Managed | Strong | Platform-dependent | Good |
| AWS MediaConvert + CloudFront | Strong | Strong | Custom | Powerful | Strong | Complex | Custom |
| Custom HLS pipeline | Custom | Custom | Custom | Custom | Strong if done well | High engineering cost | Custom |

Decision questions:

- Are movies hosted by HighFive or embedded from existing services?
- Is DRM required at launch?
- Are creator uploads required, or is catalog ingestion handled by staff?

## 4. Storage

| Candidate category | Media files | Posters/backdrops | Creator assets | Delivery packages | Signed access | Privacy |
| --- | --- | --- | --- | --- | --- | --- |
| Supabase Storage | Good | Good | Good | Good | Good | Config-dependent |
| Firebase Storage | Good | Good | Good | Good | Good | Config-dependent |
| S3/R2 | Strong | Strong | Strong | Strong | Strong | Custom responsibility |
| Custom CDN storage | Strong | Strong | Strong | Strong | Custom | Custom responsibility |

Decision questions:

- Are posters/backdrops managed through CMS or storage buckets?
- Will delivery packages include media or text/package records first?
- What retention policy applies to creator assets?

## 5. Messaging / Communication

| Candidate category | Moderation | User safety | Cost | Auditability | Notifications | Community fit |
| --- | --- | --- | --- | --- | --- | --- |
| Supabase realtime | Custom | Custom | Medium | Good with database records | Custom | Good for update feeds |
| Firebase realtime/firestore | Custom | Custom | Medium | Good with records | Good | Good for realtime patterns |
| Stream Chat | Strong | Strong | Higher | Strong | Strong | Good for real chat |
| Custom backend | Custom | Custom | High | Custom | Custom | Exact product fit |
| No-chat update feed | Stronger control | Strong | Low to medium | Strong | Optional | Best for curated launch |

Decision questions:

- Is HighFive launching with real community messaging or curated updates only?
- Who moderates user-generated text?
- Are notifications required for updates?

## 6. Payments / Subscriptions

| Candidate category | Apple rules | Subscription sync | Entitlement state | Restore purchases | Server validation |
| --- | --- | --- | --- | --- | --- |
| StoreKit direct | Native | Custom | Custom | Native | Custom |
| RevenueCat | Strong | Strong | Strong | Strong | Managed |
| Stripe for web/admin only | Must respect Apple rules | Custom | Backend-driven | Web-only | Backend-driven |
| Hybrid StoreKit + backend entitlements | Strong if designed carefully | Strong | Strong | Native + backend | Strong |

Decision questions:

- Are subscriptions required at launch?
- Are rentals, purchases, or membership tiers planned?
- Is access Apple-only or cross-platform?

## 7. Analytics / Crash

| Candidate category | Privacy | Crash debugging | Event volume | PII risk | Opt-out |
| --- | --- | --- | --- | --- | --- |
| Sentry | Good if configured | Strong | Moderate | Config-dependent | Configurable |
| Firebase Crashlytics | Good if configured | Strong | Moderate | Config-dependent | Configurable |
| PostHog | Strong product analytics | Optional crash tooling | High | Config-dependent | Configurable |
| Privacy-first internal logs | Strong control | Custom | Custom | Custom responsibility | Custom |
| No analytics until privacy policy ready | Strongest short-term privacy | None | None | Low | Not needed |

Decision questions:

- What privacy level is required before TestFlight?
- Are product analytics needed before crash diagnostics?
- What event data should never be collected?

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

No production SDK should be added until these provider decisions are confirmed.
