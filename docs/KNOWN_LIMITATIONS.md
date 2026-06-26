# HighFive Cinema Known Limitations

## Local/Staging Limits

- The backend smoke harness uses loopback local runtime unless a hosted environment is explicitly configured.
- Identity can run in development mode; production Sign in with Apple requires external Apple configuration.
- APNs delivery requires Apple credentials and device provisioning.
- StoreKit/App Store Server API validation requires App Store Connect setup and server secrets.
- Object storage and CDN playback signing require external provider credentials.
- Media processing depends on production worker deployment and storage configuration.
- The local audit can create an unsigned Release archive, but TestFlight export/submission requires signing and provisioning configuration.

## Product Limits

- Some workflows remain local-preview capable for development fallback.
- Offline media behavior depends on entitlement and media availability configuration.
- Revenue, analytics, and notification dashboards depend on backend event ingestion quality.
- Rights, moderation, and operations are only as complete as the configured backend enforcement.

## Operational Limits

- Production backup/restore must be tested in the selected hosting environment.
- Rate limiting in the local scaffold is in-memory; production should use a shared store or ingress-level control.
- Audit retention policies must be finalized before production launch.
- Account deletion must be validated with all connected providers before public release.
