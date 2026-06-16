# HighFive Auth Account Staging Foundation

## Scope

#055.0A adds an auth/account staging foundation only. It defines local account fallback, runtime config gating, session status, account identity, and deletion/export request boundaries without enabling live authentication.

## Runtime Config Names

Runtime auth config is read from environment names only:

- `HIGHFIVE_AUTH_PROVIDER`
- `HIGHFIVE_AUTH_MODE`
- `HIGHFIVE_AUTH_BASE_URL`
- `HIGHFIVE_AUTH_CLIENT_ID`

No real values, real URLs, tokens, secrets, passwords, client secrets, or provider credentials are committed.

## Local Fallback Behavior

Missing auth config keeps the app in `Local Account Mode`.

Partial auth config returns `Missing Auth Credentials`.

Complete auth config returns `Auth Configured`, but the remote auth adapter remains a staging stub. It does not create a live OAuth session, store tokens, persist credentials, or claim a production provider connection.

## Session Boundary

The app can show:

- `Session Local`
- `Session Signed Out`

These states describe staging readiness only. They do not prove a live user session.

## Sign In With Apple Requirement

`Sign in with Apple requirement pending` remains visible until the App Store and provider requirements are reviewed. A live Sign in with Apple implementation waits for a separately scoped phase.

## Account Deletion And Export

The foundation defines request models for:

- `Delete Account Not Connected Yet`
- `Export Account Not Connected Yet`

These are staging boundary states. Production deletion/export requires live account records, backend audit policy, retention policy, support ownership, and privacy review before activation.

## What Waits For Production

- Live OAuth
- Live Sign in with Apple
- Provider SDKs
- Token storage
- Keychain/token persistence
- Password handling
- Live account deletion
- Live account export
- Live cloud sync
- Live remote streaming playback
- Live payments
- Live Instagram or Meta posting
- Live VOD publishing
- App Store production configuration
