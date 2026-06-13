# HighFive Authentication Architecture

## #041.0A Authentication Architecture & Integration Plan

This document defines the authentication architecture before implementation. It is planning only. It does not add Clerk SDKs, Auth0 SDKs, AuthenticationServices implementation, provider configuration, URLs, tokens, secrets, API keys, project settings, Info.plist changes, PrivacyInfo changes, entitlements, asset changes, or app code.

## Provider Recommendation

| Decision | Preferred | Fallback | Last Resort |
| --- | --- | --- | --- |
| Authentication provider | Clerk | Auth0 | Custom auth |
| App boundary | `AuthService` | `AuthService` | `AuthService` |
| Provider adapter | `AuthenticationProviderAdapter` | `AuthenticationProviderAdapter` | Custom provider adapter |
| Identity record owner | BackendServiceLayer | BackendServiceLayer | BackendServiceLayer |
| Default runtime until approved | Local preview fallback | Local preview fallback | Local preview fallback |

Clerk is preferred for managed account lifecycle, fast implementation, and clear support paths. Auth0 is the fallback if enterprise identity requirements, migration tooling, or broader identity-provider compatibility become more important than speed. Custom auth is the last-resort fallback only if HighFive accepts full security, support, account recovery, and compliance ownership.

## Architecture Boundary

```text
SwiftUI screens
  -> Profile / onboarding / account intent
  -> AuthService
  -> AuthenticationProviderAdapter
  -> Clerk or Auth0 later
  -> BackendServiceLayer
  -> HighFive-owned user ID and provider identity mapping

UserProfileService
  -> AuthService session identity
  -> BackendServiceLayer profile records

LibraryService / PaymentEntitlementService / PlaybackService
  -> AuthService user identity
  -> BackendServiceLayer scoped records
```

Rules:

- SwiftUI screens must not call Clerk, Auth0, AuthenticationServices, OAuth clients, provider URLs, or backend clients directly.
- `AuthService` owns session lifecycle, sign-in, sign-out, session refresh, account deletion, account export, local preview fallback, and provider availability.
- `AuthenticationProviderAdapter` maps provider-specific state into HighFive-safe authentication models.
- BackendServiceLayer owns HighFive-owned user IDs and provider identity mapping.
- Local preview mode remains available for simulator demos, rollback, and unauthenticated consumer browsing until live authentication is explicitly approved.

## AuthService Contract Shape

```text
currentSession() -> AuthSession?
currentAuthState() -> AuthState
beginSignIn(provider, intent) -> AuthFlowResult
completeSignIn(callbackPayload) -> AuthFlowResult
refreshSession() -> AuthSessionRefreshResult
signOut() -> AuthSignOutResult
requestAccountDeletion(reason) -> AccountDeletionRequest
requestAccountExport() -> AccountExportRequest
providerHealth() -> AuthenticationProviderHealth
```

Required state:

- `localPreview`
- `signedOut`
- `signingIn`
- `signedIn`
- `refreshing`
- `sessionExpired`
- `providerUnavailable`
- `backendIdentityMissing`
- `deletionRequested`
- `exportRequested`
- `rollbackActive`

Required failure handling:

- User cancelled.
- Provider unavailable.
- Session expired.
- BackendServiceLayer unavailable.
- HighFive-owned user ID missing.
- Provider identity mapping missing.
- Account disabled.
- Deletion pending.
- Export request pending.
- Sign in with Apple requirement not satisfied.

## Authentication Data Model

| Model | Owner | Purpose |
| --- | --- | --- |
| `HighFiveUserID` | BackendServiceLayer | HighFive-owned user ID used across account, profile, library, entitlement, playback, downloads, communication, launch, and delivery records. |
| `ProviderIdentityMapping` | BackendServiceLayer / AuthService | Maps provider subject identity to HighFive-owned user ID. |
| `AuthSession` | AuthService | App-safe session state, expiry, provider availability, and HighFive user ID. |
| `AuthState` | AuthService | Local preview, signed-out, signed-in, expired, unavailable, and rollback states. |
| `AccountDeletionRequest` | AuthService / BackendServiceLayer | Tracks deletion intent, request state, and completion requirements. |
| `AccountExportRequest` | AuthService / BackendServiceLayer | Tracks user data export request status if required by privacy policy. |
| `AuthenticationProviderHealth` | AuthenticationProviderAdapter | Provider availability and operational readiness without exposing credentials. |

Sensitive values:

- Provider subject identifiers.
- Email or phone if collected later.
- Session expiry and account status.
- Provider identity mapping.
- Account deletion and export request state.
- Support/admin account remediation records.

The app must not store raw provider credentials, passwords, refresh credentials, signing keys, service-role credentials, private provider configuration, or backend secrets.

## Session Lifecycle

| Flow | Architecture |
| --- | --- |
| Sign-in flow | UI sends intent to `AuthService`; `AuthService` delegates to `AuthenticationProviderAdapter`; adapter returns provider-safe result; BackendServiceLayer resolves HighFive-owned user ID. |
| Sign-out flow | `AuthService` clears app session state, asks adapter to close provider session when live auth is approved, and leaves local preview fallback available. |
| Session refresh flow | `AuthService` refreshes provider-safe session state through adapter and revalidates HighFive-owned user ID through BackendServiceLayer. |
| Account deletion flow | `AuthService` creates deletion request state; BackendServiceLayer owns deletion workflow, audit trail, and completion evidence. |
| Account export flow | `AuthService` creates export request state; BackendServiceLayer owns export packaging and privacy-compliant delivery process. |

No live sign-in, sign-out, refresh, deletion, or export implementation is added in #041.0A.

## Sign In With Apple Requirement

If third-party authentication is enabled and account creation is offered in the iOS app, Sign in with Apple must be reviewed before release. The architecture must account for:

- Apple sign-in eligibility and App Store rule review.
- Provider support for Apple identity if Clerk or Auth0 is selected.
- Account deletion path if account creation is enabled.
- Privacy labels for identifiers, contact info, account state, and linked records.
- Local preview fallback for simulator demos and unauthenticated consumer browsing.

No AuthenticationServices implementation or entitlements are added in this phase.

## Environment Model

| Environment | Authentication behavior |
| --- | --- |
| Local | Local preview fallback only; no provider credentials; no live account required. |
| Staging | Selected provider test project, test accounts, BackendServiceLayer identity records, rollback flag, deletion/export smoke tests. |
| Production | Production provider project, secure credentials, Sign in with Apple review if required, support owner, deletion/export process, monitoring, rollback plan. |

## Credential Requirements

Credentials are required later, not in #041.0A:

- Selected provider project configuration.
- Provider client configuration.
- Sign in with Apple configuration if required.
- BackendServiceLayer credentials for identity records.
- Account deletion/admin credentials.
- Provider webhook secret only if provider webhooks are approved later.
- Separate staging and production credentials.

Current status: not collected, not configured, not committed.

## Backend Requirements

- HighFive-owned user ID table.
- Provider identity mapping table.
- Account state and session audit table if required by policy.
- Profile table keyed by HighFive-owned user ID.
- Library, entitlement, playback, download, communication, launch, and delivery records scoped to HighFive-owned user ID.
- Account deletion request workflow.
- Account export request workflow.
- Support/admin boundary with audit logging.
- Staging seed accounts and rollback flag.
- Contract tests for provider identity mapping and missing backend identity states.

## App Store And Privacy Requirements

- Sign in with Apple review before third-party account creation ships if required by App Store rules.
- Privacy labels updated before collecting provider identifiers, email, account status, or linked usage records.
- Account deletion path available if account creation is enabled.
- Data export process reviewed if required by privacy policy.
- Clear support policy for disabled, deleted, or merged accounts.
- No account requirement for local simulator demos.

## Rollback Strategy

- Local preview fallback remains available in every environment.
- Authentication provider can be disabled by environment flag.
- Screens depend on `AuthService` states, not provider SDK types.
- BackendServiceLayer preserves HighFive-owned user IDs so provider migration remains possible.
- Sign-in failures fall back to signed-out or local preview states without breaking Home, Search, Library, Downloads, or Profile.
- Account-scoped services defer remote sync when authentication is unavailable.

## What Connects First

1. Authentication architecture and provider decision review.
2. BackendServiceLayer account identity records and provider identity mapping.
3. Staging provider project decision: Clerk preferred, Auth0 fallback, custom auth last resort.
4. `AuthService` protocol and local preview adapter.
5. Provider adapter skeleton disabled by default.
6. Sign in with Apple review before live iOS account creation.
7. Account deletion and export workflow before production account requirement.

## What Waits

- Live Clerk SDK/config waits for explicit implementation scope.
- Live Auth0 SDK/config waits unless fallback is selected.
- Custom auth waits unless both managed providers are rejected.
- AuthenticationServices implementation waits for scoped Sign in with Apple phase.
- URLs, tokens, secrets, API keys, and provider config wait for secure configuration policy.
- Library sync, entitlement validation, cloud downloads, and personalization wait for stable HighFive-owned user IDs.
- Production authentication waits for privacy review, deletion/export process, support owner, monitoring, and rollback proof.

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Provider lock-in | Expensive auth migration | HighFive-owned user IDs and provider identity mapping. |
| Credentials in repo | Security incident | Secure configuration only; no credentials in docs or source. |
| Screens tied to provider SDK | Rewrite cost | Screens use `AuthService`, never raw provider clients. |
| Missing Sign in with Apple path | App Store blocker | Review Apple requirement before third-party account launch. |
| Missing deletion/export process | Privacy and support blocker | Design deletion and export workflows before production account requirement. |
| Identity mapping drift | Library, entitlement, and playback data corruption | Contract tests and backend-owned mappings. |
| Session refresh gaps | Broken sync and access state | Explicit expired, refreshing, unavailable, and rollback states. |
| Email overcollection | Privacy burden | Collect minimum identifiers required for account operation. |
| Support/admin overreach | Account integrity risk | Separate admin boundary and audit logging. |
| Local preview confusion | QA ambiguity | Clearly label local preview and live provider states. |

## Evidence For #041

- Clerk is preferred.
- Auth0 is fallback.
- Custom auth is last-resort fallback.
- `AuthService` and `AuthenticationProviderAdapter` boundaries are defined.
- BackendServiceLayer dependency, HighFive-owned user ID, and provider identity mapping are documented.
- Session lifecycle, sign-in, sign-out, refresh, account deletion, and account export flows are documented.
- Sign in with Apple requirement is documented.
- Local preview fallback, staging model, production model, credential requirements, backend requirements, App Store/privacy requirements, rollback strategy, risk register, what connects first, and what waits are documented.
- No live auth provider is connected.
- No SDKs, URLs, tokens, secrets, API keys, provider config, project settings, Info.plist, PrivacyInfo, entitlements, assets, or app code are added.
