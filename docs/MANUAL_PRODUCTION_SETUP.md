# HighFive Cinema Manual Production Setup

This repository intentionally does not contain production credentials, certificates, private keys, provisioning profiles, API tokens, or hosted service URLs.

## Apple Platform Setup

1. Create or confirm the production App ID and bundle identifier.
2. Configure Sign in with Apple for the app and backend identity exchange.
3. Configure Push Notifications and APNs key material.
4. Configure StoreKit products, subscriptions, and sandbox testers.
5. Configure App Store Server API issuer ID, key ID, and private key in the backend secret store.
6. Configure provisioning profiles and signing certificates in Xcode or CI.

## Backend Setup

1. Deploy the backend scaffold to the selected hosting environment.
2. Create the production database.
3. Run database migrations from an empty database.
4. Load approved seed/bootstrap data only.
5. Configure object storage buckets for source media and processed media.
6. Configure media processing workers and ffmpeg/ffprobe runtime images.
7. Configure CDN or signed playback URL provider.
8. Configure audit logging, structured logs, monitoring, and alerts.

## Secret Setup

Store these values outside the repository:

- `HIGHFIVE_DATABASE_URL`
- `HIGHFIVE_AUDIT_LOG_SINK`
- `HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN`
- `HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET`
- `HIGHFIVE_APP_STORE_PRIVATE_KEY`
- `HIGHFIVE_APP_STORE_ISSUER_ID`
- `HIGHFIVE_APP_STORE_KEY_ID`
- `HIGHFIVE_REVENUECAT_SECRET_KEY`
- APNs signing key material
- Object-storage access keys

## Local Verification Setup

Use loopback for local smoke tests:

```bash
cd backend/staging_server_scaffold
npm run typecheck
HIGHFIVE_BACKEND_ENV=local_smoke \
HIGHFIVE_PROVIDER_MODE=mock \
HIGHFIVE_SERVER_HOST=127.0.0.1 \
HIGHFIVE_SERVER_PORT=8787 \
node /private/tmp/highfive-p44a-release-candidate-final-audit/compiled/src/runtime/start.js
```

Then run smoke tests with:

```bash
HIGHFIVE_HTTP_SMOKE_BASE_URL=http://127.0.0.1:8787 npm run catalog:smoke
```

Use the same base URL for the other smoke scripts.

