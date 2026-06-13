# HighFive Cloud Library Sync Architecture

## #043.0A Cloud Library Sync Architecture

This document defines the Cloud Library Sync architecture before implementation. It is planning only. It does not add Supabase SDK/config, CloudKit implementation, backend URLs, URLSession, tokens, secrets, API keys, provider config, file storage, real cloud sync, real media downloads, project settings, Info.plist changes, PrivacyInfo changes, entitlements, asset changes, or app code.

## 1. Purpose

#043.0A locks the architecture for syncing a viewer's saved titles, watch progress, continue watching state, favorites / My List state, and account-scoped library metadata without connecting live cloud sync.

The architecture must support:

- Cloud Library Sync architecture behind HighFive-owned services.
- Supabase hybrid preferred backend path.
- Custom API fallback.
- `LibraryService` boundary for app-facing library behavior.
- `CloudLibraryProviderAdapter` boundary for provider-specific sync behavior.
- BackendServiceLayer dependency for account-scoped records.
- AuthService dependency for user identity.
- HighFive-owned user ID dependency for every library record.
- MovieCatalogService dependency for canonical title identity.
- PaymentEntitlementService boundary dependency for access-aware library context.
- DownloadService boundary for local download state, not media file sync.
- Local preview fallback until live sync is explicitly approved.

## 2. Provider Decision

| Decision | Preferred | Fallback | Current status |
| --- | --- | --- | --- |
| Cloud library backend path | Supabase hybrid | Custom API | Architecture only |
| App boundary | `LibraryService` | Same boundary | Not implemented |
| Provider adapter | `CloudLibraryProviderAdapter` | Same adapter contract | Not implemented |
| Identity dependency | AuthService and HighFive-owned user ID | Local preview fallback until approved | No live cloud library sync |
| Runtime default | `localPreview` | `providerNotConnected` | No provider config |

Supabase hybrid is preferred because it already fits the BackendServiceLayer direction for account-scoped records, row/resource-level access control, and rapid staging validation. A Custom API remains the fallback if portability, custom authorization, or operational control outweigh managed backend speed.

CloudKit is not selected for this architecture phase because the current provider plan centers library sync on the BackendServiceLayer so it can share account identity, entitlement records, catalog records, and backend audit policy. No CloudKit implementation is added.

## 3. Architecture Boundary

```text
SwiftUI screens
  -> LibraryService
  -> CloudLibraryProviderAdapter
  -> BackendServiceLayer later

LibraryService
  -> AuthService
  -> BackendServiceLayer
  -> MovieCatalogService
  -> PaymentEntitlementService
  -> DownloadService boundary
```

Rules:

- SwiftUI screens must not call Supabase, CloudKit, Custom API clients, backend URLs, URLSession, database clients, or file storage providers directly.
- `LibraryService` owns app-facing saved state, watch progress, continue watching state, favorites / My List state, local preview fallback, optimistic local update state, and user-safe sync errors.
- `CloudLibraryProviderAdapter` owns provider readiness, sync queue state, conflict state, retry state, stale state, delete pending state, and provider unavailable state.
- BackendServiceLayer owns account-scoped library records, validation, conflict metadata, audit state, and rollback flags.
- AuthService owns session state and the HighFive-owned user ID required for production sync.
- MovieCatalogService owns canonical movie identity and catalog availability used by library records.
- PaymentEntitlementService remains the paid-access authority. LibraryService may store and display account context but must not grant paid playback or downloads.
- DownloadService owns local download state and offline media policy; Cloud Library Sync does not sync media files.

## 4. LibraryService Contract

`LibraryService` is the app-facing boundary for saved titles, progress, continue watching, favorites / My List state, and library account state.

```text
currentLibraryState(userId) -> LibrarySyncState
fetchLibrary(userId) -> [CloudLibraryRecord]
setSaved(userId, movieId, saved) -> LibraryMutationResult
setFavorite(userId, movieId, favorite) -> LibraryMutationResult
updateWatchProgress(userId, movieId, progress) -> LibraryMutationResult
fetchContinueWatching(userId) -> [ContinueWatchingItem]
enqueueOfflineLibraryMutation(mutation) -> OfflineQueueState
resolveConflict(recordId, resolution) -> LibraryConflictResult
refreshLibrary(userId) -> LibraryRefreshResult
libraryHealth() -> LibraryServiceHealth
```

Required behavior:

- Depend on AuthService for signed-in account state and HighFive-owned user ID.
- Depend on BackendServiceLayer for account-scoped library records.
- Depend on MovieCatalogService for canonical movie IDs and metadata availability.
- Depend on PaymentEntitlementService for access-aware context only; it must not duplicate entitlement decisions.
- Respect DownloadService boundary by syncing only metadata and local download state references, not media files.
- Preserve local preview fallback for simulator demos and rollback.
- Support optimistic local update state, offline queue state, sync retry state, stale data state, delete pending state, and conflict resolution state.

## 5. CloudLibraryProviderAdapter Contract

`CloudLibraryProviderAdapter` is the provider-specific boundary. It maps Supabase hybrid or Custom API sync behavior into HighFive-safe states.

```text
currentProviderState(userId) -> CloudLibraryProviderState
fetchRecords(userId, cursor) -> CloudLibraryFetchResult
pushMutation(userId, mutation) -> CloudLibraryMutationResult
pullChanges(userId, sinceToken) -> CloudLibraryDeltaResult
markDeletePending(userId, recordId) -> CloudLibraryMutationResult
resolveConflict(userId, conflict) -> CloudLibraryConflictResult
providerHealth() -> CloudLibraryProviderHealth
```

Required `CloudLibraryProviderAdapter` states:

- `localPreview`
- `providerNotConnected`
- `providerSelected`
- `stagingReady`
- `syncReady`
- `syncQueued`
- `syncing`
- `synced`
- `stale`
- `conflictDetected`
- `retryRequired`
- `accountRequired`
- `providerUnavailable`
- `deletePending`
- `syncDenied`

Contract rules:

- No Supabase SDK/config is added in #043.0A.
- No CloudKit implementation is added in #043.0A.
- No Custom API client is added in #043.0A.
- No backend URLs are added in #043.0A.
- No file storage provider is added in #043.0A.
- No real cloud library sync is added in #043.0A.
- Provider state must default to local preview or provider not connected.

## 6. Cloud Library Record Model

Cloud library records are HighFive-owned backend records for user/title state.

| Field | Purpose |
| --- | --- |
| `id` | Library record identifier. |
| `userId` | HighFive-owned user ID from AuthService and BackendServiceLayer. |
| `movieId` | Canonical title identity from MovieCatalogService. |
| `saved` | Saved title state for My List. |
| `favorite` | Favorites state when product copy distinguishes favorites from saved titles. |
| `watchProgress` | Last known playback progress metadata. |
| `continueWatchingEligible` | Whether the title appears in Continue Watching. |
| `lastWatchedAt` | Timestamp used for ordering Continue Watching. |
| `localDownloadState` | App-local download metadata state, never a media file. |
| `syncState` | Synced, queued, stale, conflict detected, retry required, or delete pending. |
| `version` | Conflict detection token or monotonically increasing server version. |
| `updatedAt` | Last mutation timestamp. |
| `deletedAt` | Soft-delete marker for unsave or account deletion workflows. |

These records do not contain media files, provider credentials, backend URLs, or payment details.

## 7. Saved Titles Sync Model

Saved titles sync model:

- `setSaved(true)` creates or updates a Cloud Library Record.
- `setSaved(false)` marks the saved state false or delete pending depending on backend policy.
- Local preview mode persists current local behavior only.
- Production sync requires AuthService and HighFive-owned user ID.
- BackendServiceLayer is authoritative after sync succeeds.
- MovieCatalogService must confirm the movie ID maps to a known catalog record.
- PaymentEntitlementService is not required to save a title, but paid playback still requires entitlement validation later.

## 8. Watch Progress Sync Model

Watch progress sync model:

- Watch progress is account-scoped viewing history and must be treated as high privacy.
- Progress updates may be batched to reduce sync churn.
- Local progress updates can be optimistic and queued while offline.
- BackendServiceLayer stores the latest accepted progress version.
- Conflict resolution prefers the newest meaningful progress unless an explicit device conflict policy overrides it.
- Stale data must not overwrite newer server progress.

## 9. Continue Watching Sync Model

Continue watching sync model:

- Continue Watching is derived from watch progress, last watched timestamp, catalog availability, and access context.
- LibraryService owns the derived row consumed by Home and Library.
- MovieCatalogService supplies title metadata.
- PaymentEntitlementService supplies access context when paid gates exist, but it does not store viewing history.
- Titles can be removed from Continue Watching without unsaving the title if product policy allows.
- Stale or provider unavailable states should display cached continue watching items only with a clear sync state.

## 10. My List / Favorites Sync Model

My List / favorites sync model:

- My List is the primary saved titles experience.
- Favorites are optional product state and must remain compatible with saved title records.
- A title can be saved without being marked favorite.
- Unsave handling must remove or soft-delete My List state without deleting unrelated watch progress unless product policy explicitly requires it.
- Favorites / My List sync must be account-scoped and keyed by HighFive-owned user ID.

## 11. Download State Boundary

Download state boundary:

- Cloud Library Sync may store local download state metadata such as requested, available locally, expired locally, or removed locally.
- It must not sync media files.
- It must not add file storage.
- It must not add real media downloads.
- DownloadService remains the owner of offline media policy, storage, expiry, entitlement checks, and removal behavior.
- PaymentEntitlementService remains the access authority for paid offline eligibility.

## 12. Offline Queue Boundary

Offline queue boundary:

- LibraryService may queue metadata mutations such as save, unsave, favorite, progress update, and continue watching removal.
- Offline queue entries must be scoped to the HighFive-owned user ID when an account exists.
- Sensitive queue contents must be minimized because viewing history is private.
- Queue replay requires AuthService session validity and BackendServiceLayer availability.
- Queue replay must preserve ordering where ordering affects user intent.
- Offline queue does not include media files, provider credentials, URLs, or raw backend payloads.

## 13. Conflict Resolution Model

Conflict resolution model:

- BackendServiceLayer stores a version, updated timestamp, or equivalent conflict token.
- Local optimistic mutations carry the last known server version.
- If the server version changed, CloudLibraryProviderAdapter returns `conflictDetected`.
- LibraryService resolves simple conflicts with deterministic rules and escalates ambiguous cases to a safe state.
- Saved/unsaved conflicts prefer the most recent explicit user action.
- Watch progress conflicts prefer newest meaningful progress with safeguards against stale overwrite.
- Delete pending conflicts must not resurrect deleted records without a newer explicit save.

## 14. Optimistic Local Update Model

Optimistic local update model:

- User intent updates local UI immediately for save, unsave, favorite, and progress changes.
- The record enters `syncQueued` or `syncing`.
- Success marks the record `synced`.
- Failure moves the record to `retryRequired`, `stale`, `conflictDetected`, or `syncDenied`.
- Optimistic local update state must remain reversible and must not claim server persistence until BackendServiceLayer accepts the mutation.

## 15. Sync Retry / Stale Data Handling

Sync retry model:

- Retry only metadata mutations.
- Retry requires AuthService session state and provider availability.
- Retry should use backoff and avoid duplicate writes.
- Retry must preserve idempotency through mutation identifiers or version checks later.

Stale data handling:

- Stale data is displayed as cached library state with a sync state.
- Stale data must not overwrite newer server state.
- Stale watch progress must not drive production entitlement decisions.
- Provider unavailable state should keep the current screen usable through local preview or cached read-only data when policy allows.

## 16. Deletion / Unsave Handling

Deletion / unsave handling:

- Unsave is a library mutation, not account deletion.
- Unsave can soft-delete a saved title record or mark `saved` false.
- Unsave must not remove watch progress unless product policy explicitly says so.
- Delete pending state must survive app restart until sync completes or is rolled back.
- BackendServiceLayer must audit destructive mutations.
- Account deletion must remove or anonymize account-scoped library records according to privacy policy.

## 17. Privacy Model

Privacy model:

- Viewing history, saved titles, watch progress, continue watching, favorites, and download state metadata are high privacy.
- Library records are scoped to HighFive-owned user ID.
- Payment details must not be stored in library records.
- Provider credentials, backend URLs, tokens, secrets, API keys, and raw provider payloads must not be stored in UI state.
- Analytics must not receive viewing history until privacy review and event allowlist approval.
- Cached local library state must be minimized and removable on sign-out or account deletion according to policy.

## 18. Account Deletion Impact

Account deletion impact:

- AuthService owns account deletion request state.
- BackendServiceLayer owns deletion workflow and evidence.
- LibraryService must stop sync for deleted or deletion-pending accounts.
- Cloud library records must be deleted, anonymized, or retained only under an approved legal/support policy.
- Offline queue entries for the deleted account must be cleared or invalidated.
- DownloadService must handle local download removal according to offline media policy.
- PaymentEntitlementService must handle entitlement/account retention separately from library viewing history.

## 19. Local / Staging / Production Environment Model

| Environment | Cloud library behavior |
| --- | --- |
| Local | Local preview fallback only; no Supabase SDK/config; no Custom API client; no backend URLs; no real cloud sync. |
| Staging | Staging sync model after approval; test accounts; BackendServiceLayer records; conflict/retry/stale tests; rollback flag. |
| Production | Production sync model after approval; secure credentials; privacy review; monitoring; account deletion process; rollback plan. |

Local preview:

- Keeps current local saved/downloaded/progress behavior.
- Does not claim cross-device sync.
- Does not connect to Supabase, CloudKit, Custom API, file storage, or media download services.

Staging sync model:

- Requires AuthService identity, BackendServiceLayer records, test accounts, conflict tests, retry tests, and account deletion tests.

Production sync model:

- Requires secure configuration, privacy review, account deletion workflow, support owner, monitoring, rollback, and no direct SwiftUI dependency on provider SDKs.

## 20. Credential Requirements

Credentials are required later, not in #043.0A:

- Supabase project configuration if Supabase hybrid is implemented.
- Custom API credentials if fallback is selected.
- BackendServiceLayer credentials for server-side library records.
- Staging and production environment separation.
- Admin/support credentials for account deletion review with audit logging.
- No credentials are collected, configured, or committed in this phase.

## 21. Backend Requirements

Backend Requirements:

- HighFive-owned user ID records.
- Library record table keyed by user ID and movie ID.
- Saved titles sync fields.
- Watch progress sync fields.
- Continue Watching derivation or query model.
- Favorites / My List state.
- Conflict version or mutation token.
- Offline queue replay support.
- Delete pending and unsave handling.
- Account deletion cleanup or anonymization process.
- Privacy-aware audit trail.
- Rollback flag and provider health state.
- Contract tests for local preview, sync queued, synced, stale, conflict detected, retry required, account required, provider unavailable, and sync denied states.

## 22. App Store / Privacy Requirements

App Store / Privacy Requirements:

- Privacy labels must be reviewed before syncing viewing history, saved titles, watch progress, continue watching, favorites, or download state metadata.
- Account deletion must include library records and cached local state.
- Data export requirements must include library and viewing history if policy requires it.
- Real media downloads remain out of scope and require a later offline media/privacy review.
- No App Store capability, entitlement, PrivacyInfo, or Info.plist changes are added in this phase.

## 23. Rollback Strategy

Rollback Strategy:

- Local preview fallback remains available.
- Cloud sync can be disabled by environment flag later.
- LibraryService returns provider not connected, provider unavailable, retry required, stale, or local preview states instead of breaking Home, My List, Downloads, Movie Detail, or Profile.
- Queued mutations remain local until sync is safe or can be discarded with user-safe policy.
- BackendServiceLayer preserves audit state but stops accepting provider sync when rollback disables remote sync.
- SwiftUI screens stay decoupled from Supabase, CloudKit, Custom API, URLs, and provider SDK types.

## 24. What Connects First

What Connects First:

1. Cloud Library Sync architecture review.
2. BackendServiceLayer library record model.
3. AuthService stable HighFive-owned user ID.
4. LibraryService protocol and local preview adapter.
5. CloudLibraryProviderAdapter protocol with provider not connected states.
6. MovieCatalogService canonical movie identity checks.
7. Staging sync model with conflict, retry, stale, unsave, and account deletion tests after explicit approval.

## 25. What Waits

What Waits:

- Live Supabase SDK/config waits for explicit implementation scope.
- Custom API client waits unless fallback is selected.
- Backend URLs wait for secure configuration policy.
- Real cloud library sync waits for AuthService and BackendServiceLayer readiness.
- File storage provider waits because library sync is metadata-only.
- Real media downloads wait for real download architecture.
- Payment-aware access behavior waits for PaymentEntitlementService validation.
- Production sync waits for staging evidence, privacy review, support owner, and rollback proof.

## 26. Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Viewing history privacy leak | User trust and compliance risk | Treat library records as high privacy and minimize cached data. |
| Account mapping drift | Library state appears under the wrong account | Require HighFive-owned user ID and backend identity mapping. |
| Stale progress overwrite | Continue Watching becomes wrong | Version checks and stale data handling. |
| Save/unsave conflict | My List state flips unexpectedly | Deterministic conflict resolution and delete pending state. |
| Provider lock-in | Migration cost | Keep `LibraryService` and `CloudLibraryProviderAdapter` HighFive-owned. |
| Offline queue duplication | Duplicate or out-of-order mutations | Idempotent mutation design and ordered replay. |
| Sync outage | Library appears broken | Local preview fallback, stale read-only state, and retry required state. |
| Payment/library confusion | Saved title mistaken for paid access | PaymentEntitlementService remains access authority. |
| Download boundary drift | Metadata sync becomes file sync | DownloadService owns media policy; no file storage provider in #043.0A. |
| Credentials in repo | Security incident | Secure configuration only; no SDKs/URLs/tokens/secrets/app code changes. |

## 27. Evidence For #043

- Cloud Library Sync architecture documented.
- Supabase hybrid preferred backend path documented.
- Custom API fallback documented.
- `LibraryService` boundary defined.
- `CloudLibraryProviderAdapter` boundary defined.
- BackendServiceLayer dependency defined.
- AuthService dependency defined.
- HighFive-owned user ID dependency defined.
- MovieCatalogService dependency defined.
- PaymentEntitlementService boundary dependency defined.
- saved titles sync model defined.
- watch progress sync model defined.
- continue watching sync model defined.
- My List / favorites sync model defined.
- download state boundary defined.
- offline queue boundary defined.
- conflict resolution model defined.
- optimistic local update model defined.
- sync retry and stale data handling defined.
- deletion / unsave handling defined.
- privacy model for viewing history defined.
- account deletion impact defined.
- local preview, staging sync, and production sync models defined.
- Credential Requirements documented.
- Backend Requirements documented.
- App Store / Privacy Requirements documented.
- Rollback Strategy documented.
- Risk Register documented.
- What Connects First documented.
- What Waits documented.
- No live cloud library sync.
- No Supabase SDK/config.
- No backend URLs.
- No file storage provider.
- No media downloads.
- No SDKs/URLs/tokens/secrets/app code changes.
- No app code changes.

## 28. Known Limitations

- Architecture only.
- No live cloud library sync.
- No Supabase SDK/config.
- No Custom API client.
- No backend URLs.
- No tokens/secrets/API keys.
- No file storage provider.
- No real media downloads.
- No real cross-device sync.
- No app code changes.
