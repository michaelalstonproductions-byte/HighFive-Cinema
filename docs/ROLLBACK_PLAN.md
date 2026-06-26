# HighFive Cinema Rollback Plan

## Immediate App Rollback

1. Remove or disable remote runtime configuration.
2. Confirm the app falls back to Local Preview where supported.
3. Stop promotion of the affected TestFlight or production build.
4. Preserve diagnostics, logs, and audit records.

## Backend Rollback

1. Disable external ingress to the failing backend revision.
2. Restore the previous backend deployment artifact.
3. Restore the previous database migration state only if the migration rollback is verified.
4. Keep audit records immutable.
5. Re-run health, readiness, identity, catalog, playback, publishing, and security smoke tests.

## Media Rollback

1. Stop processing workers.
2. Preserve uploaded source assets and processing logs.
3. Disable newly generated playback manifests if they are invalid.
4. Re-point catalog visibility to the previous approved asset lineage.

## Monetization Rollback

1. Disable entitlement-gated release flags.
2. Preserve transaction records.
3. Keep restore-purchase and account-support paths available.
4. Verify expired/revoked entitlement handling before re-enabling.

## Notification Rollback

1. Disable push send jobs.
2. Keep in-app notification inbox available.
3. Preserve delivery audit logs.
4. Re-enable only after deep-link routing is verified.

## Communication

- Record the affected commit, tag, build number, backend revision, migration version, and rollback owner.
- Document user impact and recovery steps in the incident record.
- Do not delete logs or secrets-history evidence during rollback.

