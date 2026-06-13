# HighFive API Contracts And Adapter Plan

This document defines the future service protocol plan as pseudo-code. It does not add Swift implementation.

## 1. Service Adapter Strategy

- Local adapters remain the default for Debug and simulator demos.
- Remote adapters require provider choice, staging configuration, privacy review, and rollback proof.
- Screens talk to stores or feature view models, not raw provider APIs.
- Stores own loading, error, empty, and offline states.
- Provider adapters map remote payloads into HighFive app models.
- Production behavior must remain replaceable without rewriting UI screens.

## 2. Protocols To Create In Later Phases

### MovieCatalogService

```text
methods:
  fetchHomeRails() -> HomeCatalog
  fetchMovie(id) -> Movie
  searchMovies(query, filters) -> [Movie]
returns:
  catalog models and movie detail models
errors:
  unavailable, notFound, unauthorized, decodingFailed
caching/offline:
  cache catalog snapshots and movie detail metadata
privacy:
  search personalization requires privacy review
```

### AuthService

```text
methods:
  currentSession() -> Session?
  beginSignIn(provider) -> AuthResult
  finishSignIn(callbackPayload) -> AuthResult
  refreshSession() -> Session?
  signOut() -> Void
  requestAccountDeletion() -> DeletionRequest
  exportAccountData() -> AccountExportRequest
returns:
  account/session status
errors:
  cancelled, unauthorized, providerUnavailable, sessionExpired, accountDisabled, backendIdentityMissing
caching/offline:
  cached session status only; no sensitive credential storage in UI
privacy:
  account deletion and data export must be supported
provider boundary:
  Clerk is preferred; Auth0 or custom auth are fallbacks; implementation waits for #041
```

### UserProfileService

```text
methods:
  fetchProfile(userId) -> Profile
  updateProfile(profilePatch) -> Profile
returns:
  profile model
errors:
  unauthorized, validationFailed, conflict
caching/offline:
  cache display profile; defer writes until online if policy allows
privacy:
  profile visibility rules required
```

### LibraryService

```text
methods:
  fetchLibrary(userId) -> [LibraryItem]
  setSaved(movieId, saved) -> LibraryItem
  updateProgress(movieId, progress) -> LibraryItem
returns:
  account-scoped library items
errors:
  unauthorized, conflict, unavailable
caching/offline:
  optimistic local state with reconciliation
privacy:
  viewing history is sensitive
```

### PlaybackService

```text
methods:
  requestPlaybackSource(movieId) -> PlaybackSource
  refreshPlaybackSource(movieId) -> PlaybackSource
returns:
  playable source descriptor
errors:
  entitlementRequired, unavailable, expired
caching/offline:
  source descriptors may expire; do not persist long-term without policy
privacy:
  entitlement and viewing access are sensitive
```

### DownloadService

```text
methods:
  requestOfflineAvailability(movieId) -> OfflineAsset
  removeOfflineAsset(movieId) -> Void
  validateOfflineAsset(movieId) -> OfflineAssetState
returns:
  offline state and license status
errors:
  entitlementRequired, storageUnavailable, expired
caching/offline:
  license state controls playback; metadata cache allowed
privacy:
  offline viewing state is sensitive
```

### ConnectService

```text
methods:
  fetchUpdates(scope) -> [ConnectUpdate]
  saveDraft(updateDraft) -> ConnectUpdate
  submitUpdate(updateId) -> ConnectUpdate
returns:
  draft, preview, moderation, and published states
errors:
  moderationRequired, validationFailed, unauthorized
caching/offline:
  drafts local; submitted updates require backend
privacy:
  user-generated text requires moderation policy
```

### LaunchService

```text
methods:
  fetchCampaign(projectId) -> LaunchCampaign
  updateMilestone(milestoneId, completed) -> LaunchMilestone
  updateCampaign(campaignPatch) -> LaunchCampaign
returns:
  campaign and milestone state
errors:
  unauthorized, validationFailed, conflict
caching/offline:
  local checklist cache with reconciliation
privacy:
  release plans can be confidential
```

### ExportPackageService

```text
methods:
  fetchExportPackage(projectId) -> ExportPackage
  generateDeliverySummary(packageId) -> DeliverySummary
  updatePackage(packagePatch) -> ExportPackage
returns:
  package records and text summaries
errors:
  unauthorized, validationFailed, unavailable
caching/offline:
  cached summaries allowed; generated state should include version
privacy:
  delivery materials are sensitive
```

### PaymentEntitlementService

```text
methods:
  fetchEntitlements(userId) -> [SubscriptionEntitlement]
  refreshEntitlements() -> [SubscriptionEntitlement]
  currentAccessState(userId, movieId, accessKind) -> PaymentAccessState
  validateServerEntitlements(userId) -> ServerEntitlementValidationResult
returns:
  access state for playback and premium features
errors:
  unavailable, validationFailed, unauthorized, entitlementExpired, restoreRequired, providerNotConnected
caching/offline:
  cache entitlement with expiry
privacy:
  payment details stay with payment provider; app stores entitlement state only
provider boundary:
  RevenueCat + StoreKit is preferred; Stripe web is fallback only where Apple rules allow; implementation waits for #042 approval
```

### StoreProviderAdapter

```text
methods:
  currentProviderState(userId) -> StoreProviderState
  fetchAvailableProducts(userId) -> StoreProductReadiness
  refreshCustomerState(userId) -> StoreCustomerState
  restoreCustomerPurchases(userId) -> StoreRestoreResult
returns:
  provider readiness, validation-required state, restore-required state, and entitlement mapping input
errors:
  providerNotConnected, providerUnavailable, purchaseDenied, validationRequired, entitlementExpired
caching/offline:
  local preview only until provider is explicitly connected
privacy:
  app never stores raw payment details or provider secrets
provider boundary:
  isolates RevenueCat + StoreKit or approved Stripe web state from SwiftUI screens
```

### NotificationService

```text
methods:
  fetchPreferences(userId) -> [NotificationPreference]
  updatePreference(category, enabled) -> NotificationPreference
  registerDeviceIfAllowed() -> DeviceRegistrationState
returns:
  preference and device registration state
errors:
  permissionDenied, unavailable
caching/offline:
  cache user preference; OS permission state must be checked locally
privacy:
  notification opt-in must be explicit
```

### AnalyticsService

```text
methods:
  recordEvent(event) -> Void
  recordError(errorContext) -> Void
  setConsent(consentState) -> Void
returns:
  no user-facing return value
errors:
  dropped, disabled, unavailable
caching/offline:
  disabled until privacy policy and consent design are approved
privacy:
  minimize data, avoid sensitive viewing details unless approved
```

## 3. Feature-To-Service Map

| Feature | Services |
| --- | --- |
| Home | MovieCatalogService, LibraryService |
| Movie Detail | MovieCatalogService, PlaybackService, LibraryService, DownloadService |
| Library | LibraryService |
| Downloads | DownloadService, LibraryService |
| Connect | ConnectService |
| Launch | LaunchService |
| Export | ExportPackageService |
| Profile | AuthService, UserProfileService, PaymentEntitlementService |
| Demo/Developer QA | Local diagnostics and service health surfaces only |

## 4. Configuration Strategy

- Local mode: local adapters and mock data, default for simulator demos.
- Staging mode: real providers with non-production data and locked configuration.
- Production mode: real providers with approved security, privacy, and rollback plans.
- Provider keys and signing material must come from secure build configuration or managed environment.
- No keys, secrets, or credentials are committed.
- Environment selection must be explicit and auditable.

## 5. Testing Strategy

- Local mock tests verify stores and screens without network.
- Service contract tests verify adapter behavior against agreed models.
- Staging smoke tests verify auth, catalog, playback source, library sync, and safety fallbacks.
- Offline tests verify cached catalog, local library queue, and denied offline playback states.
- Failure-mode tests verify expired playback source, missing entitlement, provider outage, moderation pending, and privacy-disabled telemetry.
