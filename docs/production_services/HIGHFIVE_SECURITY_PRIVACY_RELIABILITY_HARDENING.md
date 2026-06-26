# HighFive Cinema P43A Security, Privacy, and Reliability Hardening

## Scope

P43A hardens the local staging backend and app integration without adding new
production providers. It verifies the production shape for security headers,
rate limits, privacy export, account deletion, audit logging, rollback, backup,
and recovery.

## Implemented Runtime Controls

- Security headers on every HTTP response:
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: no-referrer`
  - `X-Frame-Options: DENY`
  - `Cross-Origin-Resource-Policy: same-origin`
  - restrictive `Permissions-Policy`
  - `X-HighFive-Request-ID`
- Route-scoped in-memory rate limiting for local staging routes.
- Structured JSON error contract for authorization, validation, payload, and
  rate-limit failures.
- Privacy export endpoint:
  - `/v1/identity/data-export`
  - returns sanitized user/session/audit data only.
- Account deletion request endpoint revokes all local sessions for the user:
  - `/v1/identity/delete-request`
- Readiness reports expose the active security/privacy controls.
- Existing smoke helpers continue to reject credential material in responses.

## Threat Model Summary

| Area | Risk | P43A Control |
| --- | --- | --- |
| Credential leakage | Secrets in API responses, logs, screenshots, or docs | response redaction tests, credential scans, server-only secret docs |
| Token/session misuse | Stale local sessions remain usable after deletion | deletion request revokes local sessions |
| Abuse / brute force | Repeated route calls overload local endpoint behavior | route-scoped rate limiter |
| Browser embedding | UI endpoints framed or MIME-sniffed by a host page | frame, content-type, referrer, and permission headers |
| Overlarge payloads | oversized JSON or upload payloads | bounded body readers and upload byte limit |
| Unauthorized mutation | viewer mutates creator/admin resources | existing role checks plus P43 smoke coverage |
| Recovery failure | no backup, restore, or rollback path | documented runbooks below |

## Backup and Restore Runbook

Current staging state is in memory plus local seed fixtures. For production:

1. Take PostgreSQL-compatible backups before schema migrations.
2. Store object-storage manifests separately from media bytes.
3. Verify restore into an isolated staging database before promoting.
4. Re-run catalog, identity, publishing, operations, monetization, and security
   smoke suites after restore.
5. Compare restored catalog counts and audit counts with the pre-backup report.

Local fixture validation:

```bash
cd "/Volumes/Scratch SSD/HighFive-Cinema-clean/backend/staging_server_scaffold"
npm run typecheck
HIGHFIVE_HTTP_SMOKE_BASE_URL=http://127.0.0.1:8787 npm run security:smoke
```

## Object Storage Recovery Plan

1. Treat the asset manifest as the source of relationship truth.
2. Validate each stored object by checksum before making it playable.
3. Rebuild processing jobs from asset records when derived media is missing.
4. Never delete source media until replacement derivatives validate.
5. Keep package manifests readable without requiring media playback.

## Secret Rotation Procedure

1. Rotate provider secrets server-side only.
2. Update deployment environment variables outside the repository.
3. Restart the backend with the new environment.
4. Confirm `/ready` remains healthy.
5. Run entitlement, playback, upload, monetization, and security smoke tests.
6. Revoke the old provider credential after validation.

Never commit:

- API keys
- private keys
- access tokens
- refresh tokens
- signing certificates
- production `.env` files

## Privacy Controls

- Account export is explicit and authenticated.
- Export returns suffixes/metadata, not reusable session tokens.
- Deletion request revokes local sessions immediately.
- Production deletion still requires identity-provider confirmation and retention
  policy enforcement.
- Analytics events must not include private raw identifiers unless required by
  an authenticated product flow.

## Reliability Checks

P43A verification covers:

- TypeScript typecheck.
- Security smoke suite.
- Catalog smoke regression.
- Identity smoke regression.
- Operations smoke regression.
- Monetization smoke regression.
- iOS simulator build.
- Protected-path scan.
- secret/network/file-write scans.
- locked-tab scan.

## Known Limitations

- Rate limiting is in-memory for the staging backend.
- Backup/restore is documented and fixture-tested, not connected to a live
  production database.
- Crash reporting and operational alerts remain provider-selection tasks for the
  production deployment phase.
- Account deletion is local-session revocation plus request/audit recording; it
  is not a production identity-provider deletion.
