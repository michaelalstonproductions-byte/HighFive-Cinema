# HighFive Real Downloads Policy Eligibility Staging

This phase adds policy and eligibility staging for future real downloads. It does not activate real media downloads.

## Service Boundary

The app boundary is `HFDownloadEligibilityService`.

Staged implementation types:

- `HFLocalDownloadEligibilityAdapter`
- `HFRemoteDownloadPolicyGateway`
- `HFDownloadPolicy`
- `HFDownloadQueueRecord`
- `HFOfflineLicenseState`
- `HFStoragePressureState`
- `HFDownloadExpirationPolicy`
- `HFDownloadProviderBoundary`
- `HFDownloadRuntimeStatus`
- `HFDownloadProviderStatus`
- `HFDownloadEligibilityResult`
- `HFDownloadPrerequisite`
- `HFDownloadQueueState`
- `HFDownloadStoragePolicy`
- `HFOfflineLicensePolicy`
- `HFDownloadActionReadiness`

## Runtime Config Names

Names only:

- `HIGHFIVE_DOWNLOADS_MODE`
- `HIGHFIVE_DOWNLOADS_PROVIDER`
- `HIGHFIVE_DOWNLOAD_POLICY_BASE_URL`
- `HIGHFIVE_OFFLINE_LICENSE_PROVIDER`
- `HIGHFIVE_DOWNLOAD_STORAGE_LIMIT_MB`

No real values, provider credentials, tokens, secrets, or environment files are committed.

## Local Adapter

The local adapter keeps the app in `Offline Preview` and `Local Offline Shelf` mode. Local offline preview state remains available through the existing local library/download state.

Visible staging copy includes:

- `Download Provider Not Connected Yet`
- `License Required`
- `Media Source Required`
- `Entitlement Required`
- `Storage Policy Required`
- `Real downloads disabled`
- `Backend-mediated downloads only`
- `Local offline preview only`
- `Offline license not active`
- `Expiration policy required`

## Remote Policy Gateway Stub

`HFRemoteDownloadPolicyGateway` is a policy boundary only. It does not call a network API in this phase.

Complete runtime config may report `Download policy configured`, but that remains staging-only. It does not mean real downloads, provider storage, offline viewing rights, or production delivery are active.

## Required Dependencies

Future production downloads require all of the following:

- Backend-mediated downloads only.
- Streaming provider playback descriptor approval.
- Entitlement/payment validation.
- Account/auth identity where policy is account-scoped.
- Library sync/offline record reconciliation.
- Offline license requirement.
- Storage pressure policy.
- Expiration policy.
- Revocation, refund, and expired entitlement policy.
- Airplane-mode behavior.
- Delete local offline state behavior.

## Explicit Non-Goals

This phase does not add:

- `AVAssetDownloadURLSession`.
- `AVAssetDownloadTask`.
- `AVAggregateAssetDownloadTask`.
- `URLSession`.
- FileManager media writes.
- Background transfer.
- Real media file storage.
- DRM/FairPlay implementation.
- `AVContentKeySession`.
- `AVAssetResourceLoader`.
- Cloudflare SDK.
- Mux SDK.
- Hardcoded media or backend URLs.
- Production download provider connection.

## What Waits For Production

Production still needs provider selection, server policy contracts, license handling, storage policy, expiry/revocation behavior, review of App Store requirements, privacy review, and QA across online, offline, account deletion, entitlement changes, refunds, and device storage pressure.
