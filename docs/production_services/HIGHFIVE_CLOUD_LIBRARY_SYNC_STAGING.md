# HighFive Cloud Library Sync Staging

## Purpose

#058.0A adds an account-scoped cloud library sync staging foundation. It keeps the existing local saved list, Continue Watching progress, and offline preview state as the default behavior while defining the service boundary for future backend-mediated sync.

This is not production cloud sync.

## Service Boundary

- `HFLibrarySyncService`
- `HFLocalLibrarySyncAdapter`
- `HFRemoteLibrarySyncGateway`
- `HFLibrarySyncSnapshot`
- `HFLibrarySyncBoundary`
- `HFLibraryConflictPolicy`

The app uses local state unless account, backend, and library sync runtime config are complete.

## Runtime Config Names

- `HIGHFIVE_LIBRARY_SYNC_MODE`
- `HIGHFIVE_LIBRARY_SYNC_BASE_URL`
- `HIGHFIVE_LIBRARY_SYNC_PROVIDER`
- `HIGHFIVE_LIBRARY_SYNC_USER_SCOPE`

The app checks presence only. No real values, URLs, tokens, secrets, provider credentials, or direct database settings are committed.

## Local Fallback Records

Saved title records use `HFSavedTitleRecord` and report `Saved Locally`.

Progress records use `HFProgressRecord` and report `Progress Saved Locally`.

Offline state records use `HFOfflineStateRecord` and report `Offline Preview State`.

These records are local staging models and do not activate cross-device sync.

## Account And Backend Dependency

Cloud sync requires account.

Library sync is backend-mediated only. The app must not connect directly to a cloud provider, direct database client, or production backend from UI code.

Missing library sync config keeps `Local Library Mode`.

Missing account/auth keeps `Cloud Library Not Connected Yet`.

Partial config reports `Library Sync Missing Credentials`.

Complete config may report `Library Sync Configured`, but that is staging-only and does not claim live cross-device sync.

## Conflict Policy

The staging conflict policy is local-first:

- Local saved titles remain available.
- Local progress remains available.
- Offline preview state remains available.
- Server conflict resolution waits for production validation.

## What Waits For Production

- Live cross-device sync.
- Server conflict resolution.
- Account retention and deletion policy integration.
- Viewing history retention review.
- Backend schema and migration approval.
- Provider credentials.
- Production monitoring and rollback policy.
- App Store production configuration.
