# HighFive Backend Connection Master Plan

## Product principle

HighFive remains consumer-first:

```text
Watch → Depth Peek → Creator Studio → Social Kit → VOD Package
```

Backend connection should make the product real without making the UI feel like an admin dashboard.

## Connection order

### Stage 1 — Runtime configuration

Add a runtime configuration reader that supports:

```text
HIGHFIVE_BACKEND_MODE=local|staging|production
HIGHFIVE_BACKEND_BASE_URL=<runtime only>
HIGHFIVE_SUPABASE_PROJECT_URL=<runtime only>
HIGHFIVE_SUPABASE_ANON_KEY=<runtime only>
HIGHFIVE_AUTH_PROVIDER=local|clerk|auth0|custom
HIGHFIVE_PAYMENTS_PROVIDER=local|revenuecat|storekit|stripe
HIGHFIVE_VIDEO_PROVIDER=local|cloudflare-stream|mux
HIGHFIVE_SOCIAL_PROVIDER=local|instagram|custom
HIGHFIVE_VOD_PROVIDER=local|custom
```

No real values are committed.

### Stage 2 — Backend status service

The app should expose backend status for:

- Account
- Catalog
- Library
- Downloads
- Payments/entitlements
- Creator Studio
- Social Media Kit
- VOD Package
- Communications
- Notifications
- Analytics

UI labels:

- Local Mode
- Backend Not Connected Yet
- Backend Configured
- Missing Credentials
- Provider-ready
- Not Connected Yet

### Stage 3 — Real backend health endpoint

First live call should be a safe health check:

```http
GET /health
```

Expected response:

```json
{
  "status": "ok",
  "environment": "staging",
  "services": {
    "catalog": "ready",
    "library": "ready",
    "creatorStudio": "ready",
    "socialKit": "ready",
    "vodPackage": "ready"
  }
}
```

### Stage 4 — Account identity

Use HighFive-owned user IDs. Provider IDs map to HighFive IDs.

Required tables:

- highfive_users
- provider_identities
- user_profiles

### Stage 5 — Catalog and library sync

Required tables:

- catalog_titles
- catalog_assets
- library_items
- continue_watching

### Stage 6 — Creator Studio, Social Kit, VOD Package

Required tables:

- creator_projects
- creator_assets
- social_kits
- social_posts
- social_platform_status
- vod_packages
- vod_checklist_items

### Stage 7 — Payments, downloads, playback mediation

Connect only after account identity and backend mediation exist.

Do not expose raw provider URLs or provider tokens to SwiftUI views.

## Provider order

Preferred:

- Backend: Supabase hybrid or custom API
- Auth: Clerk/Auth0/custom behind AuthService
- Video: Cloudflare Stream or Mux behind PlaybackService
- Payments: RevenueCat + StoreKit, Stripe web for non-iOS flows
- Analytics: PostHog/Mixpanel/custom allowlist
- Social: Instagram provider adapter later, not direct UI SDK
- VOD: custom release package provider later

## App safety boundaries

SwiftUI views should never directly call provider SDKs. Views should use services:

```text
View → Store/ViewModel → HighFiveBackendGateway → service adapters → backend/provider
```

## Forbidden in committed code

- hardcoded production URLs
- API keys
- secrets
- OAuth tokens
- refresh tokens
- Stripe secrets
- RevenueCat API keys
- Supabase service role key
- raw media provider URLs
- real Instagram token exchange secrets
