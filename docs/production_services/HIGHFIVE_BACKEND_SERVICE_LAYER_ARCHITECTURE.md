# HighFive Backend Service Layer Architecture

## #040.0A Backend Service Layer Architecture

This document defines the backend service layer architecture before implementation. It is planning only. It does not add Supabase SDKs, custom API clients, backend URLs, tokens, secrets, API keys, project settings, Info.plist changes, PrivacyInfo changes, entitlements, asset changes, or app code.

## Provider Recommendation

| Decision | Preferred | Fallback |
| --- | --- | --- |
| Backend model | Supabase hybrid | Custom API |
| Data ownership | HighFive-owned service layer and records | Custom backend service layer |
| Client access pattern | App talks to HighFive services only | App talks to local adapters until backend is approved |
| Server mediation | BackendServiceLayer owns provider mediation | Custom API owns mediation if Supabase is rejected |
| Admin operations | Separate admin/support boundary | Manual support process until tooling is approved |

Supabase hybrid is preferred because it can provide managed database, auth-adjacent records, row-level policy options, and operational speed while still allowing HighFive-owned service boundaries. A custom API remains the fallback if portability, security review, or operational control outweigh managed-service speed.

## Architecture Boundary

```text
SwiftUI screens
  -> HighFive stores / view models
  -> HighFive service protocols
  -> BackendServiceLayer
  -> Supabase hybrid or Custom API later

BackendServiceLayer
  -> Account identity records
  -> Provider identity mapping
  -> Catalog records
  -> Library sync records
  -> Entitlement records
  -> Playback source mediation records
  -> Download policy records
  -> Communication records
  -> Launch campaign records
  -> Delivery package records
  -> Notification preference records
  -> Analytics event allowlist boundary
  -> Admin/support boundary
```

Rules:

- SwiftUI screens must not call Supabase, a custom API client, provider URLs, or database clients directly.
- Local adapters remain the default until backend implementation is explicitly approved.
- `BackendServiceLayer` owns record contracts, identity mapping, provider mediation, rollback state, and service health.
- Feature services own domain behavior and call the backend layer through HighFive-owned protocols.
- Admin/support tools stay outside consumer UI and require separate access control.

## BackendServiceLayer Contract Shape

```text
currentBackendState() -> BackendState
fetchRecord(collection, id, scope) -> BackendRecordResult
upsertRecord(collection, record, scope) -> BackendRecordResult
deleteRecord(collection, id, scope) -> BackendMutationResult
syncChanges(collection, since, scope) -> BackendSyncResult
resolveProviderIdentity(provider, subject) -> ProviderIdentityResult
requestPlaybackSource(movieId, accountId) -> PlaybackSourceMediationResult
recordEventIfAllowed(eventName, payload) -> AnalyticsBoundaryResult
providerHealth() -> BackendProviderHealth
```

Required state:

- `localPreview`
- `stagingDisabled`
- `connecting`
- `ready`
- `providerUnavailable`
- `migrationRequired`
- `unauthorized`
- `schemaMismatch`
- `rollbackActive`

Required failure handling:

- Provider unavailable.
- Backend credentials missing from secure configuration.
- Account identity record missing.
- Provider identity mapping missing.
- Entitlement record unavailable.
- Catalog record mapping missing.
- Sync conflict.
- Schema migration mismatch.
- Privacy or analytics allowlist rejection.
- Admin/support action denied.

## Production Data Model Map

| Record | Owner | Purpose |
| --- | --- | --- |
| `AccountIdentityRecord` | AuthService / BackendServiceLayer | HighFive-owned account ID, account status, deletion/export state. |
| `ProviderIdentityMapping` | BackendServiceLayer | Maps external provider subject to HighFive account ID. |
| `CatalogRecord` | MovieCatalogService / BackendServiceLayer | Canonical title identity, metadata, provider asset references. |
| `LibrarySyncRecord` | LibraryService / BackendServiceLayer | Saved title state, watch progress, account-scoped library entries. |
| `EntitlementRecord` | PaymentEntitlementService / BackendServiceLayer | Access tier, entitlement state, expiry, validation status. |
| `PlaybackSourceMediationRecord` | PlaybackService / BackendServiceLayer | Source request state, source expiry, provider mapping, failure state. |
| `DownloadPolicyRecord` | DownloadService / BackendServiceLayer | Offline eligibility, license policy, expiry, removal requirements. |
| `CommunicationRecord` | ConnectService / BackendServiceLayer | Audience update drafts, review status, provider delivery state. |
| `LaunchCampaignRecord` | LaunchService / BackendServiceLayer | Release calendar, milestones, campaign readiness, communication bridge. |
| `DeliveryPackageRecord` | ExportPackageService / BackendServiceLayer | Delivery summary, requirements, distribution handoff, package status. |
| `NotificationPreferenceRecord` | NotificationService / BackendServiceLayer | Category-level opt-in state and device registration readiness. |
| `AnalyticsEventAllowlistRecord` | AnalyticsService / BackendServiceLayer | Approved event names, payload fields, consent rules, disabled state. |
| `AdminSupportRecord` | Admin/support boundary | Support actions, audit state, migration ownership, account remediation. |

Sensitive values:

- Account identifiers and provider subject mappings.
- Entitlement and playback access state.
- Library and viewing progress.
- Download/offline license state.
- Communication, launch, and delivery package content.
- Notification preferences and device registration state if approved later.
- Analytics payload allowlist decisions.
- Admin/support audit records.

The app must not store service-role credentials, database admin keys, private URLs, webhook secrets, raw provider tokens, or backend secrets.

## Service Dependencies

| Service | Backend dependency |
| --- | --- |
| `AuthService` | Account identity records and provider identity mapping. |
| `UserProfileService` | Account-scoped profile records and local profile fallback. |
| `MovieCatalogService` | Catalog records and provider asset mapping. |
| `LibraryService` | Library sync records and conflict resolution. |
| `PaymentEntitlementService` | Entitlement records and validation state. |
| `PlaybackService` | Playback source mediation records and provider health. |
| `DownloadService` | Download policy records and offline license state. |
| `ConnectService` | Communication records, moderation state, provider delivery readiness. |
| `LaunchService` | Launch campaign records, milestones, release calendar. |
| `ExportPackageService` | Delivery package records and distribution handoff. |
| `NotificationService` | Notification preference records and device registration readiness. |
| `AnalyticsService` | Event allowlist boundary and consent state. |

## Environment Model

| Environment | Backend behavior |
| --- | --- |
| Local | Local adapters only; no backend credentials; no remote records required. |
| Staging | Supabase/custom test project, schema migrations, seeded test accounts, rollback flag, smoke tests. |
| Production | Production project, secure credentials, monitoring owner, migration owner, support owner, rollback plan. |

## Credential Requirements

Credentials are required later, not in #040.0A:

- Supabase project configuration if selected.
- Custom API endpoint configuration if fallback is selected.
- Database migration credentials.
- Service-role credentials for server-only operations.
- Provider webhook secrets if events are approved later.
- Storage credentials only if backend storage is approved later.
- Admin/support access credentials with audit logging.
- Separate staging and production credentials.

Current status: not collected, not configured, not committed.

## Server Requirements

- Schema migration system and owner.
- HighFive-owned account identity table.
- Provider identity mapping table.
- Catalog table and provider asset mapping.
- Library sync table with conflict policy.
- Entitlement table with validation and expiry policy.
- Playback source mediation table and short-lived source policy.
- Download policy table and offline eligibility state.
- Communication table with moderation/readiness state.
- Launch campaign table with milestones and release calendar state.
- Delivery package table with requirement and handoff state.
- Notification preference table before device registration is enabled.
- Analytics event allowlist table before analytics SDK/config is approved.
- Admin/support audit table and permission boundary.
- Backup, restore, migration rollback, and incident-response process.

## App Store And Privacy Requirements

- Privacy labels must be reviewed before syncing account, library, playback, entitlement, notification, or analytics data.
- Account deletion and data export paths must exist before remote accounts are required.
- Paid access and entitlement validation wait for payment provider integration.
- Real downloads wait for license, expiry, storage, and removal policy.
- Push notifications wait for entitlement, permission copy, and notification preference records.
- Analytics waits for consent design and event allowlist approval.
- App Review notes may be required for account, paid access, downloads, and external provider behavior.

## Rollback Strategy

- Local adapters remain available for every service until production is stable.
- Backend provider can be disabled by environment flag.
- Feature services must surface local fallback, provider unavailable, and sync deferred states.
- Schema migrations require forward and rollback plans.
- Provider migration from Supabase hybrid to custom API requires record export, ID preservation, and audit review.
- Consumer UI must not depend on backend-specific SDK types.

## What Connects First

1. Backend service layer architecture and data model review.
2. Supabase hybrid versus custom API final provider decision.
3. Staging schema and migration ownership.
4. Account identity records and provider identity mapping.
5. Catalog records and provider asset mapping.
6. Playback source mediation contract for streaming provider security.
7. Library sync and entitlement records after account identity stabilizes.

## What Waits

- Live Supabase SDK/config waits for explicit implementation scope.
- Custom API client waits unless fallback is selected.
- Backend URLs, credentials, tokens, and secrets wait for secure configuration policy.
- Production streaming security waits for backend source mediation and provider credential storage.
- Real cloud library sync waits for account identity and conflict policy.
- Real payments wait for entitlement validation and App Store review.
- Real downloads wait for playback source, entitlement, storage, and license policy.
- Notifications wait for preferences, push entitlement, and consent copy.
- Analytics waits for privacy review and event allowlist.
- Admin/support tooling waits for access-control and audit policy.

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Backend provider lock-in | Migration cost | Keep HighFive-owned service protocols and record IDs. |
| Credentials in repo | Security incident | Secure config only; no credentials in docs or source. |
| Screens tied to backend SDK | Rewrite cost | Screens use stores and services, never raw backend clients. |
| Identity mapping drift | Library, entitlement, and playback corruption | HighFive-owned account IDs and mapping tests. |
| Schema migration failure | Production outage or data loss | Migration owner, backups, rollback plan, staging tests. |
| Entitlement mismatch | Incorrect access grants or denials | Server-side validation and audit before paid gates. |
| Playback source leakage | Unauthorized playback | Backend mediation and short-lived source policy. |
| Privacy overcollection | App Store or user trust risk | Event allowlist, privacy review, minimum data collection. |
| Admin/support overreach | Account or content integrity risk | Separate admin boundary, audit logs, least privilege. |
| Offline/download policy gap | Broken playback or review risk | Keep real downloads gated behind license and storage policy. |

## Evidence For #040

- Supabase hybrid is preferred; Custom API is fallback.
- `BackendServiceLayer` boundary is defined.
- Required production records are documented across account, provider mapping, catalog, library, entitlement, playback source mediation, downloads, communication, launch, delivery, notification, analytics, and admin/support.
- Environment, credential, server, App Store/privacy, rollback, risk, connect-first, and wait states are documented.
- No live backend provider is connected.
- No URLs, tokens, secrets, API keys, SDKs, project settings, Info.plist, PrivacyInfo, entitlements, assets, or app code are added.
