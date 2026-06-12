# HighFive Account Provider Architecture

## #038.0A Account Provider Architecture

This document defines the account provider architecture before implementation. It is planning only. It does not add SDKs, auth provider configuration, URLs, secrets, tokens, keys, project settings, Info.plist changes, entitlements, backend calls, or app code.

## Provider Recommendation

| Decision | Preferred | Fallback |
| --- | --- | --- |
| Account provider | Clerk | Auth0 or custom auth |
| Backend identity record | Supabase hybrid account table | Custom API account table |
| App account surface | Local profile remains default until #041 | Remote account state after provider approval |
| Apple sign-in | Required review before third-party auth ships | Custom account strategy must still satisfy App Store rules |

Clerk is preferred for speed, managed account flows, and clear account lifecycle support. Auth0 is the fallback if enterprise identity requirements become more important than speed. Custom auth is the fallback only if HighFive needs full control and accepts the security/support burden.

## Architecture Boundary

```text
SwiftUI screens
  -> Profile / onboarding store
  -> AuthService
  -> AccountProviderAdapter
  -> Clerk, Auth0, or custom provider later
  -> BackendServiceLayer account record

UserProfileService
  -> AuthService session identity
  -> BackendServiceLayer profile record

PaymentEntitlementService
  -> AuthService user identity
  -> BackendServiceLayer entitlement record

LibraryService
  -> AuthService user identity
  -> BackendServiceLayer library record
```

Rules:

- SwiftUI screens must not call Clerk, Auth0, custom auth clients, provider URLs, or raw backend clients directly.
- `AuthService` owns session state, sign-in intent, sign-out, account deletion requests, and provider availability.
- `UserProfileService` owns display profile data and preferences.
- Backend records map provider identity into HighFive-owned user IDs.
- Local profile mode remains available for simulator demos and rollback.

## AuthService Contract Shape

```text
currentSession() -> Session?
beginSignIn(provider) -> AuthResult
finishSignIn(callbackPayload) -> AuthResult
refreshSession() -> Session?
signOut() -> Void
requestAccountDeletion() -> DeletionRequest
exportAccountData() -> AccountExportRequest
```

Required state:

- `signedOut`
- `localPreview`
- `signingIn`
- `signedIn`
- `sessionExpired`
- `providerUnavailable`
- `deletionRequested`

Required failure handling:

- User cancelled.
- Provider unavailable.
- Session expired.
- Account disabled.
- Network unavailable.
- Backend identity record missing.
- Account deletion pending.

## Account Data Model

| Model | Owner | Purpose |
| --- | --- | --- |
| `User` | AuthService / backend layer | HighFive-owned account identity. |
| `AccountProviderIdentity` | AuthService adapter | Maps provider subject to HighFive user ID. |
| `AuthSession` | AuthService | App-safe session state, expiry, and user ID. |
| `Profile` | UserProfileService | Display name, avatar reference, profile type, and preferences. |
| `AccountDeletionRequest` | AuthService / backend layer | Tracks deletion request, status, and completion. |
| `AccountExportRequest` | AuthService / backend layer | Tracks user data export request if required. |

Sensitive values:

- Provider subject identifiers.
- Email if collected.
- Session state and expiry.
- Account status.
- Deletion/export request state.

The app must not store raw provider credentials, passwords, refresh tokens, private keys, or service-role credentials.

## Environment Requirements

| Environment | Account behavior |
| --- | --- |
| Local | Local profile only; no provider credentials; no remote account required. |
| Staging | Provider project, test accounts, secure config, rollback flag, deletion test path. |
| Production | Production provider project, privacy approval, support owner, deletion/export process, monitoring. |

## Credential Requirements

Credentials are required later, not in #038:

- Provider project identifiers.
- Provider client configuration.
- Apple sign-in configuration if required.
- Backend service credentials for account record mediation.
- Account deletion/admin access credentials.
- Webhook secret only if provider webhooks are approved later.

Current status: not collected, not configured, not committed.

## Backend Requirements

- HighFive-owned user ID table.
- Provider identity mapping table.
- Profile table keyed by HighFive user ID.
- Session audit or account event table if required by policy.
- Account deletion request path.
- Account export request path if required.
- Authorization checks for every user-scoped resource.
- Admin/support process that is separate from consumer UI.

## App Store Requirements

- Sign in with Apple review before third-party account sign-in ships.
- Privacy labels updated before collecting account identifiers or email.
- Account deletion path available if account creation is enabled.
- Clear support policy for disabled/deleted accounts.
- No account requirement for local simulator demos.

## What Connects First

1. Account provider architecture docs and contract review.
2. Backend identity record design.
3. Staging provider project decision.
4. AuthService implementation behind local fallback in #041.
5. Profile sync, library sync, payments, and personalization after auth stabilizes.

## What Waits

- Live provider SDK or custom auth client waits until #041.
- Account-gated playback waits until #042 entitlement integration.
- Cloud library sync waits until #043.
- Real downloads wait until #044.
- Notifications and analytics account linkage wait until #048 privacy approval.

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Account provider lock-in | Migration cost | Keep HighFive-owned user IDs and provider mapping. |
| Missing account deletion path | App Store and privacy blocker | Design deletion request flow before #041 implementation. |
| Provider credentials in repo | Security incident | Secure config only; no credentials in docs or source. |
| UI tied to provider SDK | Rewrite cost | Screens use stores and `AuthService`, never raw provider clients. |
| Email overcollection | Privacy burden | Collect minimum account data required for beta. |
| Creator/viewer identity confusion | Permission bugs | Decide account roles before creator features go live. |
| Session expiry gaps | Broken sync and access gates | Explicit expired-session state and local fallback. |
| Backend identity mismatch | Entitlement/library corruption | Server-side user ID mapping and contract tests. |

## Evidence For #038

- Account architecture is documented.
- Clerk is preferred; Auth0/custom are fallbacks.
- Local profile mode remains default.
- No provider SDKs or app code are added.
- No URLs, tokens, secrets, project settings, Info.plist, PrivacyInfo, entitlements, assets, or backend calls are added.
- #041 remains the first phase allowed to implement selected authentication.
