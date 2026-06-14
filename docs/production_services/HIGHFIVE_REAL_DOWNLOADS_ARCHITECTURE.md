# HighFive Real Downloads Architecture

## #044.0A Real Downloads Architecture

This document defines the Real Downloads architecture before implementation. It is planning only. It does not add live media downloads, AVAssetDownloadURLSession implementation, URLSession, FileManager writes, file storage provider, background transfer, CloudKit implementation, Supabase SDK/config, backend URLs, tokens, secrets, API keys, provider config, DRM/FairPlay implementation, SDKs, project settings, Info.plist changes, PrivacyInfo changes, entitlements, asset changes, or app code changes.

## 1. Purpose

#044.0A locks the architecture for account-aware offline title downloads without connecting live downloads.

The architecture must support:

- Real Downloads architecture behind HighFive-owned service boundaries.
- `DownloadService` boundary for app-facing download state, queue state, progress, license state, and offline playback eligibility.
- `OfflineAssetProviderAdapter` boundary for provider-specific offline asset readiness.
- BackendServiceLayer dependency for account-scoped download records and policy flags.
- AuthService dependency for signed-in identity.
- HighFive-owned user ID dependency for every production download record.
- CloudLibraryProviderAdapter dependency for library metadata and cross-device download state references.
- LibraryService dependency for saved titles, My List, favorites, continue watching, and local download metadata.
- MovieCatalogService dependency for canonical title identity and media asset availability.
- PlaybackService dependency for playable source context and offline playback boundary.
- PaymentEntitlementService dependency for entitlement and refund-aware download eligibility.
- StreamingProviderAdapter dependency for source provider capability and availability.
- Local preview fallback until staging or production download behavior is explicitly approved.

## 2. Provider Decision

| Decision | Preferred path | Fallback | Current status |
| --- | --- | --- | --- |
| App boundary | `DownloadService` | Same boundary | Architecture only |
| Offline provider boundary | `OfflineAssetProviderAdapter` | Same adapter contract | Not implemented |
| Backend dependency | BackendServiceLayer | Local preview only until approved | No live media downloads |
| Identity dependency | AuthService and HighFive-owned user ID | Local preview fallback | No live account download records |
| Media source dependency | StreamingProviderAdapter | Provider not connected state | No provider SDK |
| License dependency | PaymentEntitlementService | Entitlement required state | No DRM/FairPlay implementation |

Real downloads should wait until streaming, authentication, entitlements, catalog identity, cloud library sync, backend policy, App Store review needs, and privacy requirements are stable enough to protect user data and content rights.

No provider is connected in #044.0A. No Supabase SDK/config, CloudKit implementation, Custom API client, backend URLs, URLSession, FileManager writes, AVAssetDownloadURLSession implementation, DRM/FairPlay implementation, file storage provider, tokens, secrets, API keys, provider config, SDKs, or app code changes are added.

## 3. Architecture Boundary

```text
SwiftUI screens
  -> DownloadService
  -> OfflineAssetProviderAdapter
  -> BackendServiceLayer later

DownloadService
  -> AuthService
  -> HighFive-owned user ID
  -> BackendServiceLayer
  -> CloudLibraryProviderAdapter
  -> LibraryService
  -> MovieCatalogService
  -> PlaybackService
  -> PaymentEntitlementService
  -> StreamingProviderAdapter
  -> OfflineAssetProviderAdapter
```

Rules:

- SwiftUI screens must not call AVAssetDownloadURLSession, URLSession, downloadTask, background transfer, FileManager writes, provider SDKs, backend URLs, or file storage providers directly.
- `DownloadService` owns app-facing download eligibility, queue, progress, pause / resume architecture, download retry, expiry policy, revocation policy, storage policy, and offline playback boundary.
- `OfflineAssetProviderAdapter` owns provider capability, media asset availability, offline license readiness, provider unavailable state, storage pressure state, and provider-specific error translation.
- BackendServiceLayer owns account-scoped download records, policy flags, audit state, server-side entitlement references, license metadata references, and rollback flags.
- AuthService owns session state and the HighFive-owned user ID required for production download records.
- CloudLibraryProviderAdapter and LibraryService own synced library metadata and local download state references, not offline media files.
- MovieCatalogService owns canonical movie identity and downloadable asset availability metadata.
- PlaybackService remains the playback owner; DownloadService may provide offline playback eligibility and local asset readiness, but it does not replace playback implementation.
- PaymentEntitlementService remains the paid-access authority for download eligibility, refund / entitlement loss policy, expiry policy, and revocation policy.
- StreamingProviderAdapter remains the source provider boundary for stream/offline asset availability, not a direct UI dependency.

## 4. DownloadService Contract

`DownloadService` is the app-facing boundary for offline downloads and user-safe download state.

```text
currentDownloadState(userId, movieId) -> DownloadState
downloadEligibility(userId, movieId) -> DownloadEligibilityResult
enqueueDownload(userId, movieId, quality) -> DownloadQueueResult
pauseDownload(userId, downloadId) -> DownloadMutationResult
resumeDownload(userId, downloadId) -> DownloadMutationResult
cancelDownload(userId, downloadId) -> DownloadMutationResult
deleteDownloadedTitle(userId, movieId) -> DownloadMutationResult
refreshDownloadLicense(userId, movieId) -> OfflineLicenseResult
offlinePlaybackEligibility(userId, movieId) -> OfflinePlaybackEligibility
downloadHealth() -> DownloadServiceHealth
```

Required behavior:

- Depend on AuthService for account state and HighFive-owned user ID.
- Depend on BackendServiceLayer for production download records and policy state.
- Depend on CloudLibraryProviderAdapter and LibraryService for library metadata and download state references.
- Depend on MovieCatalogService for canonical movie ID, runtime metadata, and media asset availability.
- Depend on PlaybackService for playable source context and offline playback boundary only.
- Depend on PaymentEntitlementService for entitlement validation, refund / entitlement loss policy, and license policy.
- Depend on StreamingProviderAdapter for provider capability and offline source availability.
- Depend on OfflineAssetProviderAdapter for provider-specific offline asset lifecycle.
- Preserve local preview fallback until staging download or production download behavior is approved.

## 5. OfflineAssetProviderAdapter Contract

`OfflineAssetProviderAdapter` maps provider-specific offline asset behavior into HighFive-safe states.

```text
currentProviderState(userId, movieId) -> OfflineAssetProviderState
prepareOfflineAsset(userId, movieId, policy) -> OfflineAssetPreparationResult
startOfflineTransfer(userId, downloadId) -> OfflineAssetTransferResult
pauseOfflineTransfer(userId, downloadId) -> OfflineAssetTransferResult
resumeOfflineTransfer(userId, downloadId) -> OfflineAssetTransferResult
deleteOfflineAsset(userId, movieId) -> OfflineAssetMutationResult
refreshOfflineLicense(userId, movieId) -> OfflineLicenseResult
providerHealth() -> OfflineAssetProviderHealth
```

Required `OfflineAssetProviderAdapter` states:

- `localPreview`
- `providerNotConnected`
- `providerSelected`
- `stagingReady`
- `eligibilityReady`
- `licenseRequired`
- `entitlementRequired`
- `queued`
- `downloading`
- `paused`
- `retryRequired`
- `downloaded`
- `expired`
- `revoked`
- `deleted`
- `storagePressure`
- `providerUnavailable`
- `offlinePlaybackDenied`

Contract rules:

- No live media downloads are added in #044.0A.
- No AVAssetDownloadURLSession implementation is added in #044.0A.
- No URLSession is added in #044.0A.
- No FileManager writes are added in #044.0A.
- No file storage provider is added in #044.0A.
- No backend URLs are added in #044.0A.
- No Supabase SDK/config is added in #044.0A.
- No CloudKit implementation is added in #044.0A.
- No DRM/FairPlay implementation is added in #044.0A.
- No SDKs/URLs/tokens/secrets/app code changes are added in #044.0A.

## 6. Offline Asset Record Model

Offline asset records are HighFive-owned backend records or local preview records that describe download state without storing media payloads in documentation or library sync records.

| Field | Purpose |
| --- | --- |
| `id` | Download record identifier. |
| `userId` | HighFive-owned user ID from AuthService and BackendServiceLayer. |
| `movieId` | Canonical title identity from MovieCatalogService. |
| `libraryRecordId` | Optional LibraryService / CloudLibraryProviderAdapter reference. |
| `providerAssetId` | Provider-owned offline asset reference, never a credential. |
| `eligibilityState` | Eligible, entitlement required, license required, unavailable, or denied. |
| `queueState` | Queued, downloading, paused, retry required, downloaded, deleted, expired, or revoked. |
| `progressState` | Download progress model with bytes/counts abstracted behind provider data. |
| `licenseState` | Offline license policy state, expiry state, stale license state, or revocation state. |
| `storageState` | Storage policy state, storage pressure state, or deletion state. |
| `environment` | Local preview, staging download, or production download model. |
| `updatedAt` | Last accepted state update. |
| `deletedAt` | Soft-delete marker for delete downloaded title behavior or account deletion impact. |

Records do not contain tokens, secrets, API keys, backend URLs, file storage provider credentials, media files, DRM keys, FairPlay certificates, or raw provider configuration.

## 7. Download Eligibility Model

The download eligibility model answers whether a title can be queued for offline download.

Eligibility inputs:

- AuthService account state and HighFive-owned user ID.
- PaymentEntitlementService access state, purchase state, subscription state, refund state, and entitlement loss state.
- MovieCatalogService catalog availability and downloadable asset metadata.
- StreamingProviderAdapter offline-capability metadata.
- OfflineAssetProviderAdapter provider readiness.
- LibraryService saved titles, My List, favorites, and download state references.
- BackendServiceLayer policy flags and account restrictions.
- Device storage policy and storage pressure state.

Eligibility outputs:

- `localPreview`
- `accountRequired`
- `entitlementRequired`
- `licenseRequired`
- `mediaUnavailable`
- `providerNotConnected`
- `storagePressure`
- `eligible`
- `denied`

## 8. Offline License Policy

Offline license policy belongs behind DownloadService and PaymentEntitlementService.

Policy rules:

- Offline license state must be tied to AuthService and the HighFive-owned user ID in production.
- PaymentEntitlementService is the authority for paid access, refund, entitlement loss, and revocation.
- BackendServiceLayer stores policy references and audit state, not DRM secrets.
- OfflineAssetProviderAdapter translates provider license readiness into HighFive states.
- Stale license behavior must deny offline playback when policy requires refresh.
- Expiry policy must be explicit before production download model activation.
- Local preview does not imply a production offline license.

## 9. Media Asset Availability Model

Media asset availability model:

- MovieCatalogService owns canonical title identity and asset availability metadata.
- StreamingProviderAdapter owns provider source availability and offline-capability metadata.
- OfflineAssetProviderAdapter owns offline asset preparation and provider-specific readiness.
- DownloadService merges catalog, entitlement, license, provider, and storage state into user-safe UI state.
- BackendServiceLayer may cache availability policy but must not expose raw provider credentials.
- Unavailable media must remain visible as provider unavailable, media unavailable, or offline playback denied.

## 10. Storage Policy

Storage policy is architecture-only in #044.0A.

Policy requirements:

- DownloadService owns storage policy decisions and user-facing delete downloaded title behavior.
- OfflineAssetProviderAdapter owns provider-specific storage state translation.
- FileManager writes are not added in this phase.
- File storage provider is not added in this phase.
- Storage allocation, quality selection, expiry cleanup, account deletion cleanup, and revocation cleanup must be explicit before live downloads.
- LibraryService and CloudLibraryProviderAdapter may store local download state references, never media files.

## 11. Device Storage Pressure Handling

Device storage pressure handling:

- DownloadService must expose `storagePressure` as a first-class state.
- New downloads should be denied or delayed when storage pressure would create a poor user experience.
- Existing downloads may be marked cleanup recommended, expired, revoked, or deleted based on policy.
- User-initiated delete downloaded title behavior must remain available even when provider state is degraded.
- Local preview can simulate storage pressure without writing media files.

## 12. Download Queue Model

Download queue model:

- Queue entries are account-scoped in production and keyed by HighFive-owned user ID.
- Queue entries require MovieCatalogService canonical movie ID and PaymentEntitlementService eligibility.
- Queue entries must survive transient provider unavailable states through retry policy.
- Queue entries must not grant playback until offline license policy and offline playback boundary approve.
- Queue state must support queued, downloading, paused, retryRequired, downloaded, expired, revoked, deleted, and offlinePlaybackDenied.

## 13. Download Progress Model

Download progress model:

- Download progress is provided through DownloadService and abstracted away from provider APIs.
- UI should receive stable progress states, not raw provider transfer objects.
- Progress may be estimated, unavailable, or stale depending on provider readiness.
- Progress updates must be safe to discard during rollback to local preview.
- Download progress model must not require URLSession, downloadTask, background transfer, or FileManager writes in #044.0A.

## 14. Pause / Resume / Retry Architecture

Pause / resume architecture:

- Pause and resume are DownloadService commands that map to OfflineAssetProviderAdapter only after provider integration is approved.
- Paused state must not imply entitlement remains valid forever.
- Resume must re-check entitlement, license, storage pressure, media asset availability, and provider availability.
- Download retry handles transient provider unavailable, stale license, storage pressure recovery, and network recovery.
- Retry limits and user-safe error messages belong behind DownloadService.
- No background transfer or downloadTask implementation is added in this phase.

## 15. Expiry Policy

Expiry policy:

- Expiry is controlled by PaymentEntitlementService policy, provider policy, backend policy, and offline license policy.
- Expired titles remain visible as expired until delete downloaded title behavior or refresh policy resolves them.
- Expired state must deny offline playback when required.
- BackendServiceLayer stores account-scoped expiry references for production download records.
- Local preview may simulate expiry without live provider behavior.

## 16. Revocation Policy

Revocation policy:

- Revocation occurs when provider policy, backend policy, account policy, or entitlement policy removes offline rights.
- PaymentEntitlementService owns paid-access revocation context.
- DownloadService owns user-safe revoked state and cleanup instructions.
- OfflineAssetProviderAdapter owns provider-specific revocation mapping.
- Revoked state must deny offline playback.

## 17. Refund / Entitlement Loss Policy

Refund / entitlement loss policy:

- Refund events and entitlement loss events come through PaymentEntitlementService and BackendServiceLayer.
- DownloadService must move affected assets to entitlementRequired, revoked, expired, or offlinePlaybackDenied based on policy.
- LibraryService may keep saved titles and viewing history, but it must not imply paid offline access.
- OfflineAssetProviderAdapter must not override PaymentEntitlementService decisions.

## 18. Account Deletion Impact

Account deletion impact:

- Account deletion must remove or anonymize account-scoped download records according to privacy policy.
- Offline assets must become deleted, revoked, or offlinePlaybackDenied according to provider and legal policy.
- BackendServiceLayer owns server-side deletion workflow.
- AuthService owns account deletion identity state.
- LibraryService and CloudLibraryProviderAdapter must remove local download state references when required.
- Account deletion must not leave recoverable provider credentials, media references, or stale entitlement state in app-owned records.

## 19. Offline Playback Boundary

Offline playback boundary:

- PlaybackService remains responsible for playback behavior.
- DownloadService may answer whether offline playback is allowed and whether an offline asset is ready.
- OfflineAssetProviderAdapter may provide provider readiness state after implementation is approved.
- PaymentEntitlementService remains the access authority.
- Offline playback must be denied for expired, revoked, stale license, entitlementRequired, licenseRequired, providerUnavailable, deleted, or offlinePlaybackDenied states.
- No real offline playback media files are added in #044.0A.

## 20. DRM / FairPlay Decision Framework

DRM / FairPlay decision framework:

- DRM and FairPlay are content-rights decisions, not UI decisions.
- PaymentEntitlementService, StreamingProviderAdapter, OfflineAssetProviderAdapter, BackendServiceLayer, App Store requirements, and legal policy must all be reviewed before production download model activation.
- No DRM/FairPlay implementation is added in #044.0A.
- No DRM secrets, FairPlay certificates, provider keys, or protected media credentials are stored in this document or repo changes.
- The decision framework must compare provider-native offline protection, platform requirements, entitlement refresh needs, support burden, and rollback capability.

## 21. Airplane-Mode Behavior

Airplane-mode behavior:

- DownloadService must support a clear airplane-mode behavior state.
- Already downloaded titles may be eligible only if offline license policy, expiry policy, entitlement state, and provider state allow playback without a refresh.
- Stale license behavior must deny playback when a refresh is required and unavailable.
- New downloads cannot start in airplane-mode unless a future provider explicitly supports queued local intent.
- Delete downloaded title behavior must remain available in airplane-mode when the app can update local state safely.

## 22. Stale License Behavior

Stale license behavior:

- A stale license means DownloadService cannot prove current offline rights.
- PaymentEntitlementService and BackendServiceLayer define when stale license state can be refreshed.
- OfflineAssetProviderAdapter maps provider stale state into HighFive-safe errors.
- Stale license behavior must never silently grant paid offline playback.
- Stale data from LibraryService or CloudLibraryProviderAdapter must not override fresher entitlement or license state.

## 23. Delete Downloaded Title Behavior

Delete downloaded title behavior:

- Delete downloaded title behavior is owned by DownloadService.
- Deletion must clear local download state references in LibraryService and CloudLibraryProviderAdapter when required.
- BackendServiceLayer must receive account-scoped deletion state in staging download and production download modes.
- OfflineAssetProviderAdapter owns provider-specific delete operation after implementation is approved.
- Deletion is distinct from unsave; deleting a download does not remove the title from My List unless product policy explicitly says so.

## 24. Local / Staging / Production Environment Model

Local preview:

- Local preview keeps current simulator-safe behavior.
- Local preview may display queued, downloaded, expired, revoked, storagePressure, and offlinePlaybackDenied states as mock or local state only.
- Local preview does not create a production offline license.

Staging download model:

- Staging download requires AuthService, HighFive-owned user ID, BackendServiceLayer, PaymentEntitlementService, MovieCatalogService, PlaybackService, StreamingProviderAdapter, CloudLibraryProviderAdapter, LibraryService, and OfflineAssetProviderAdapter readiness.
- Staging download must use non-production policy and test accounts only.
- Staging download cannot ship until privacy, App Store, rollback, and support evidence are reviewed.

Production download model:

- Production download requires production provider selection, backend requirements, credential requirements, App Store requirements, Privacy Requirements, rollback strategy, monitoring, support, and deletion evidence.
- Production download must not expose provider credentials, backend URLs, media storage details, tokens, secrets, API keys, or DRM/FairPlay private material to UI code.

## 25. Credential Requirements

Credential Requirements:

- Credentials are not collected in #044.0A.
- Tokens, secrets, API keys, provider config, backend URLs, file storage provider credentials, DRM secrets, and FairPlay private material must stay out of the repo.
- Future credential storage must use approved secure configuration and secret management outside app code.
- UI, SwiftUI screens, and local mock data must never own credentials.
- Credential rotation and provider disablement must be part of production readiness.

## 26. Backend Requirements

Backend Requirements:

- BackendServiceLayer must provide account-scoped download records keyed by HighFive-owned user ID.
- BackendServiceLayer must integrate with AuthService, PaymentEntitlementService, MovieCatalogService, LibraryService, CloudLibraryProviderAdapter, PlaybackService, StreamingProviderAdapter, and OfflineAssetProviderAdapter boundaries.
- BackendServiceLayer must support entitlement references, license policy references, expiry policy, revocation policy, account deletion impact, audit state, rollback flags, and environment selection.
- BackendServiceLayer must not expose backend URLs or provider credentials to UI.
- Custom API and Supabase hybrid remain future backend paths; no Custom API client and no Supabase SDK/config are added here.

## 27. App Store / Privacy Requirements

App Store requirements:

- Offline media download behavior may require review notes, content rights explanation, account deletion behavior, restore/access behavior, and subscription or purchase disclosure.
- Paid offline access must align with PaymentEntitlementService and any provider terms.
- If DRM / FairPlay is selected later, App Store review and platform compliance must be planned before implementation.

Privacy Requirements:

- Download records reveal viewing interest and must be treated as sensitive viewing history.
- Account deletion, export, retention, and deletion must be documented before production download model activation.
- Offline playback events and download progress events require privacy review before analytics.
- Local preview must remain available for demos without collecting production personal data.

## 28. Rollback Strategy

Rollback Strategy:

- DownloadService must support a return to local preview mode.
- OfflineAssetProviderAdapter must expose provider unavailable and provider not connected states.
- BackendServiceLayer must support disabling production download writes without breaking Home, Movie Detail, My List, Continue Watching, or existing local downloads UI.
- LibraryService and CloudLibraryProviderAdapter must tolerate stale or deleted local download state references.
- PaymentEntitlementService must deny new paid offline access if rollback is active.
- Rollback must not delete user library records unless an explicit deletion or account deletion workflow requires it.

## 29. What Connects First

What Connects First:

- DownloadService protocol and local preview adapter.
- Eligibility state mapping from AuthService, HighFive-owned user ID, MovieCatalogService, PaymentEntitlementService, and LibraryService.
- BackendServiceLayer download record shape in staging.
- OfflineAssetProviderAdapter provider state enum and provider unavailable behavior.
- Storage pressure simulation and delete downloaded title behavior.
- Staging download model with test accounts after provider selection.

## 30. What Waits

What Waits:

- Live media downloads.
- AVAssetDownloadURLSession implementation.
- URLSession, downloadTask, and background transfer.
- FileManager writes.
- File storage provider.
- Backend URLs.
- Supabase SDK/config and CloudKit implementation.
- Custom API client.
- DRM/FairPlay implementation.
- Real offline playback media files.
- Production download model.
- App code changes.

## 31. Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Entitlement mismatch | Paid users lose access or unpaid users gain access | PaymentEntitlementService remains the access authority and BackendServiceLayer stores audit state. |
| Stale license grants playback | Content rights violation | Stale license behavior denies offline playback when refresh is required. |
| Storage pressure harms device | User trust and App Store risk | Storage policy and storagePressure state are first-class before live downloads. |
| Provider lock-in | Expensive migration | OfflineAssetProviderAdapter isolates provider behavior. |
| Account deletion misses offline records | Privacy risk | Account deletion impact is included in BackendServiceLayer and DownloadService requirements. |
| Refund or entitlement loss not reflected | Revenue and rights risk | Refund / entitlement loss policy routes through PaymentEntitlementService. |
| DRM / FairPlay complexity | Delayed launch or broken playback | DRM / FairPlay decision framework is separated from app UI and requires review. |
| Rollback breaks library UI | User-facing regression | Local preview remains the default fallback and LibraryService stores metadata only. |

## 32. Evidence For #044

Evidence For #044:

- Real Downloads architecture is documented.
- DownloadService boundary is documented.
- OfflineAssetProviderAdapter boundary is documented.
- BackendServiceLayer dependency is documented.
- AuthService dependency is documented.
- HighFive-owned user ID dependency is documented.
- CloudLibraryProviderAdapter dependency is documented.
- LibraryService dependency is documented.
- MovieCatalogService dependency is documented.
- PlaybackService dependency is documented.
- PaymentEntitlementService dependency is documented.
- StreamingProviderAdapter dependency is documented.
- download eligibility model is documented.
- offline license policy is documented.
- media asset availability model is documented.
- storage policy and storage pressure handling are documented.
- download queue, download progress, download retry, pause, and resume are documented.
- expiry policy, revocation policy, refund, entitlement loss, and account deletion are documented.
- offline playback boundary is documented.
- DRM and FairPlay decision framework is documented.
- airplane-mode behavior, stale license behavior, and delete downloaded title behavior are documented.
- local preview, staging download, and production download models are documented.
- Credential Requirements, Backend Requirements, App Store requirements, Privacy Requirements, Rollback Strategy, What Connects First, What Waits, and Risk Register are documented.

## 33. Known Limitations

Known limitations:

- Architecture only.
- No live media downloads.
- No AVAssetDownloadURLSession implementation.
- No URLSession.
- No FileManager writes.
- No file storage provider.
- No Supabase SDK/config.
- No CloudKit implementation.
- No Custom API client.
- No backend URLs.
- No tokens/secrets/API keys.
- No provider config.
- No DRM/FairPlay implementation.
- No DRM.
- No FairPlay implementation.
- No SDKs.
- No app code.
- No real offline playback media files.
- No production download model.
- No real cross-device download sync.
