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

## Server-Only Names

- `HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN`
- `HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET`
- `HIGHFIVE_APP_STORE_PRIVATE_KEY`
- `HIGHFIVE_APP_STORE_ISSUER_ID`
- `HIGHFIVE_APP_STORE_KEY_ID`
- `HIGHFIVE_REVENUECAT_SECRET_KEY`
- `HIGHFIVE_DATABASE_URL`
- `HIGHFIVE_AUDIT_LOG_SINK`
