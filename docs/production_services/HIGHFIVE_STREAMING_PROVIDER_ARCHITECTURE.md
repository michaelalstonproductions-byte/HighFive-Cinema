# HighFive Streaming Provider Architecture

## #039.0A Streaming Provider Integration Architecture

This document defines the streaming provider integration architecture before implementation. It is planning only. It does not add SDKs, provider configuration, URLs, secrets, tokens, keys, project settings, Info.plist changes, PrivacyInfo changes, entitlements, backend calls, asset changes, or app code.

## Provider Recommendation

| Decision | Preferred | Fallback |
| --- | --- | --- |
| Managed streaming provider | Cloudflare Stream | Mux |
| Playback entry point | HighFive `PlaybackService` | Local preview adapter until approved |
| Source mediation | Backend service layer | Signed-source helper only after backend approval |
| Offline media policy | Deferred until real downloads phase | Local offline state remains preview-only |
| Analytics dependency | Not required for first playback integration | Provider analytics later after privacy review |

Cloudflare Stream remains the preferred first provider because it fits a narrow managed-streaming boundary and keeps playback integration focused. Mux remains the fallback if the product needs stronger encoding operations, asset workflow, or provider analytics before launch.

## Architecture Boundary

```text
SwiftUI screens
  -> Movie detail / player route
  -> PlaybackService
  -> StreamingProviderAdapter
  -> Cloudflare Stream or Mux later
  -> BackendServiceLayer for source mediation

PlaybackService
  -> MovieCatalogService for title identity
  -> PaymentEntitlementService for access state
  -> DownloadService for offline policy when approved
  -> AnalyticsService only after privacy approval
```

Rules:

- SwiftUI screens must not call Cloudflare Stream, Mux, raw provider clients, provider URLs, or backend clients directly.
- `PlaybackService` owns source request state, source expiry, provider availability, local fallback, and player-safe errors.
- `StreamingProviderAdapter` maps provider records into HighFive playback descriptors.
- Backend mediation owns any future signed source, entitlement validation, provider asset mapping, and provider health checks.
- Local preview playback remains available for simulator demos and rollback.

## PlaybackService Contract Shape

```text
currentPlaybackState(movieId) -> PlaybackState
requestPlaybackSource(movieId, profileId) -> PlaybackSourceResult
refreshPlaybackSource(movieId, profileId) -> PlaybackSourceResult
validatePlaybackSource(sourceId) -> PlaybackSourceValidation
reportPlaybackFailure(movieId, failure) -> PlaybackFailureRecord
providerHealth() -> StreamingProviderHealth
```

Required state:

- `localPreview`
- `requestingSource`
- `ready`
- `sourceExpired`
- `entitlementRequired`
- `providerUnavailable`
- `catalogMappingMissing`
- `offlinePolicyRequired`

Required failure handling:

- Provider unavailable.
- Catalog title is missing a provider asset mapping.
- Source descriptor expired.
- Entitlement state requires validation.
- Network unavailable.
- Playback format unsupported.
- Backend mediation unavailable.
- Offline playback requested before real download policy exists.

## Streaming Data Model

| Model | Owner | Purpose |
| --- | --- | --- |
| `PlaybackSource` | PlaybackService | App-safe descriptor for a playable stream, expiry state, and source type. |
| `StreamingProviderAsset` | StreamingProviderAdapter / backend layer | Maps a HighFive movie ID to provider asset identity. |
| `PlaybackSession` | PlaybackService | Tracks local playback request, selected profile, title, state, and errors. |
| `PlaybackPolicy` | PlaybackService / backend layer | Defines access, expiry, provider availability, and offline eligibility. |
| `ProviderHealth` | StreamingProviderAdapter | Reports remote provider availability without exposing credentials or URLs. |
| `PlaybackFailureRecord` | PlaybackService | Captures user-safe failure reason for support and QA review. |

Sensitive values:

- Provider asset identifiers.
- Signed playback source descriptors if approved later.
- Playback session identifiers.
- Entitlement validation state.
- Profile/account-scoped viewing state.
- Provider health and failure diagnostics.

The app must not store raw provider credentials, admin keys, service tokens, signing keys, refresh secrets, private URLs, or unmediated provider responses.

## Provider Adapter Responsibilities

| Responsibility | Adapter boundary |
| --- | --- |
| Provider asset lookup | Resolve HighFive movie ID to provider asset identity through backend mediation. |
| Playback source creation | Return app-safe `PlaybackSource` with expiry and source type, never raw admin credentials. |
| Source refresh | Refresh only through `PlaybackService`; screens do not refresh provider sources. |
| Provider errors | Map provider failures into HighFive states such as provider unavailable or catalog mapping missing. |
| Provider health | Provide coarse availability status for QA and rollback decisions. |
| Local rollback | Return local preview state when remote provider is disabled or unavailable. |

## Environment Requirements

| Environment | Streaming behavior |
| --- | --- |
| Local | Local preview adapter only; no provider credentials; no remote source required. |
| Staging | Provider project, test assets, backend mediation, rollback flag, source expiry smoke tests. |
| Production | Production provider project, secure credentials, provider health owner, monitoring, rollback plan. |

## Credential Requirements

Credentials are required later, not in #039.0A:

- Provider account access.
- Provider asset administration credentials if uploads or encoding are managed by HighFive.
- Playback signing or token policy if source protection is approved.
- Backend service credentials for source mediation.
- Provider webhook secret only if provider events are approved later.
- Staging and production credential separation.

Current status: not collected, not configured, not committed.

## Backend Requirements

- HighFive movie ID to provider asset mapping table.
- Playback source mediation endpoint behind authenticated backend service layer.
- Entitlement-aware playback source policy.
- Provider health check and operational status.
- Source expiry and refresh policy.
- Playback failure event table if support diagnostics are approved.
- Staging test assets and rollback flag.
- Migration path if Cloudflare Stream changes to Mux.

## App Store And Privacy Requirements

- No App Store capability change is required for streaming playback architecture alone.
- Privacy labels must be reviewed before collecting remote playback diagnostics or provider analytics.
- Paid access gates wait for payment entitlement integration.
- Real downloads and offline media wait for download licensing, storage, expiry, and privacy review.
- App Review notes may be needed later if playback access, account, or paid content rules change.

## What Connects First

1. Streaming provider architecture docs and contract review.
2. Backend service layer source mediation design.
3. Provider staging project decision: Cloudflare Stream primary, Mux fallback.
4. PlaybackService implementation behind local fallback.
5. Catalog provider asset mapping.
6. Entitlement-aware source policy after account and payments stabilize.

## What Waits

- Live provider SDK or client integration waits for explicit implementation scope.
- Remote playback source requests wait for backend service layer approval.
- Signed playback sources wait for credential storage policy.
- Real downloads wait for download service policy.
- Provider analytics wait for privacy approval and analytics event allowlist.
- DRM or advanced protection waits for a separate security review.

## Integration Sequence

| Step | Outcome | Gate |
| --- | --- | --- |
| 1 | Keep local preview playback as default | Current simulator behavior remains unchanged. |
| 2 | Add `PlaybackService` protocol and local adapter | No provider calls or credentials. |
| 3 | Add provider adapter skeleton | Provider disabled by default and configuration-free. |
| 4 | Add backend source mediation contract | Backend service layer must exist first. |
| 5 | Add staging provider mapping | Test assets only; rollback flag required. |
| 6 | Add production provider configuration | Privacy, security, monitoring, and support owner approved. |

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Raw provider source leakage | Unauthorized playback | Backend mediation, short-lived descriptors, no raw provider calls in UI. |
| Provider lock-in | Migration cost | HighFive-owned `PlaybackService` and `StreamingProviderAdapter`. |
| Catalog mapping drift | Broken playback | Contract tests between catalog IDs and provider asset mappings. |
| Entitlement mismatch | Incorrect access | Defer paid gates until account, backend, and entitlement services are active. |
| Offline policy gap | Review and support risk | Keep real downloads out of #039; require separate download policy. |
| Provider outage | Playback failure | Local fallback state, provider health status, support messaging, rollback flag. |
| Analytics overcollection | Privacy risk | Provider analytics disabled until privacy/event approval. |
| Credentials in repo | Security incident | Secure config only; no credentials in docs or source. |
| UI tied to provider SDK | Rewrite cost | Screens use stores and `PlaybackService`, never raw provider clients. |

## Evidence For #039

- Streaming provider architecture is documented.
- Cloudflare Stream is preferred; Mux is fallback.
- `PlaybackService` and `StreamingProviderAdapter` boundaries are defined.
- Local preview playback remains default until implementation approval.
- No app code is added.
- No provider SDKs, URLs, tokens, secrets, project settings, Info.plist, PrivacyInfo, entitlements, assets, or backend calls are added.
- Future implementation remains gated by backend mediation, secure configuration, privacy review, rollback proof, and simulator verification.
