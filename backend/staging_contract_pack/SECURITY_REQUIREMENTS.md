# Security Requirements

## Server-Only Credentials

The following names are placeholders only and must be set outside the repository:

- `HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN`
- `HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET`
- `HIGHFIVE_APP_STORE_PRIVATE_KEY`
- `HIGHFIVE_APP_STORE_ISSUER_ID`
- `HIGHFIVE_APP_STORE_KEY_ID`
- `HIGHFIVE_REVENUECAT_SECRET_KEY`
- `HIGHFIVE_DATABASE_URL`
- `HIGHFIVE_AUDIT_LOG_SINK`

## Required Controls

- Do not commit backend URLs.
- Do not commit Cloudflare credentials.
- Do not commit App Store private key material.
- Do not commit RevenueCat secret key material.
- Do not return Cloudflare provider credentials to the app.
- Do not generate Cloudflare signed playback material in the app.
- Do not log `playback_url_or_token_reference`.
- Do not persist `playback_url_or_token_reference` in the app.
- Keep descriptor references short-lived.
- Write entitlement and descriptor audit records server-side.
- Use Local Preview fallback when backend config is absent or descriptor validation fails.

## App Boundary

The iOS app receives runtime endpoint config and short-lived descriptor references only. It must not receive provider credentials or server signing material.
