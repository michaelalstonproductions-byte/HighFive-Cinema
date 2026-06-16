# HighFive Backend Provider Matrix

| Area | Preferred | Fallback | App boundary |
| --- | --- | --- | --- |
| Backend | Supabase hybrid | Custom API | `HFBackendGateway` |
| Auth | Clerk/Auth0/custom | Local auth fallback | `HFAuthService` |
| Catalog | Supabase/custom table | local catalog | `HFCatalogService` |
| Library | Supabase/custom table | local saved state | `HFLibrarySyncService` |
| Downloads | backend policy records | local offline preview | `HFDownloadEligibilityService` |
| Payments | RevenueCat + StoreKit | Stripe web | `HFEntitlementService` |
| Video | Cloudflare Stream | Mux | `PlaybackService` / backend mediation |
| Communication | Custom | Stream/Sendbird | `HFCommunicationService` |
| Notifications | APNs | OneSignal | notification preferences |
| Analytics | PostHog/Mixpanel/custom | local logs | event allowlist |
| Instagram | Meta/Instagram through backend | local readiness | Social provider adapter |
| VOD | custom package provider | local package | VOD provider adapter |

All provider specifics remain behind services; SwiftUI views must not call provider SDKs directly.
