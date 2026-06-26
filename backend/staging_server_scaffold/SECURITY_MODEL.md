# Security Model

- Cloudflare signing happens server-side only.
- App Store and RevenueCat validation happen server-side only.
- StoreKit product mapping is validated server-side.
- App entitlement claims are not trusted.
- Descriptor reference is short-lived.
- Descriptor reference is not logged.
- Descriptor reference is not persisted by the app.
- Server credentials never return to the app.
- Rollback is done by removing runtime config or returning `local_preview_fallback`.
- P43A adds response security headers to every local staging HTTP response.
- P43A adds route-scoped rate limiting with readiness reporting.
- P43A adds authenticated privacy export without reusable session tokens.
- P43A account deletion request revokes local sessions immediately.
- Backup/restore, object-storage recovery, and secret rotation runbooks live in
  `docs/production_services/HIGHFIVE_SECURITY_PRIVACY_RELIABILITY_HARDENING.md`.

## Server-Only Names

- `HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN`
- `HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET`
- `HIGHFIVE_APP_STORE_PRIVATE_KEY`
- `HIGHFIVE_APP_STORE_ISSUER_ID`
- `HIGHFIVE_APP_STORE_KEY_ID`
- `HIGHFIVE_REVENUECAT_SECRET_KEY`
- `HIGHFIVE_DATABASE_URL`
- `HIGHFIVE_AUDIT_LOG_SINK`
