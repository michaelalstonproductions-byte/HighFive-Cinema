# HighFive Streaming Provider Staging Bridge

## Scope

#056.0A adds a release-safe streaming provider staging bridge through backend-mediated playback descriptors. It does not launch production streaming, direct provider playback, media downloads, app-side provider clients, provider tokens, or provider SDKs.

## Provider Direction

- Cloudflare Stream preferred
- Mux fallback

Provider selection remains a staging boundary until backend descriptor contracts, provider credentials, rights checks, entitlement validation, rollback policy, and App Store review requirements are approved.

## Runtime Config Names

Runtime streaming config is read from environment names only:

- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_STREAMING_MODE`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`
- `HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID`
- `HIGHFIVE_MUX_ENVIRONMENT_KEY`

No real values, provider URLs, media URLs, tokens, secrets, API keys, account credentials, or provider credentials are committed.

## Playback Descriptor Boundary

Playback is backend-mediated playback only. The app requests descriptor readiness from the app service boundary and never talks directly to raw streaming provider clients.

The app-side descriptor model can represent:

- `Local Preview Ready`
- `Provider Descriptor Missing`
- `Staging Descriptor Ready`
- `Streaming Provider Not Connected Yet`

Complete runtime config alone does not claim remote playback is live. `Staging Descriptor Ready` requires an approved backend descriptor response.

## Evidence Identifiers

- `hf.streaming.status`
- `hf.streaming.localPreviewReady`
- `hf.streaming.providerDescriptorMissing`
- `hf.streaming.stagingDescriptorReady`
- `hf.streaming.notConnected`
- `hf.streaming.cloudflarePreferred`
- `hf.streaming.muxFallback`
- `hf.playback.descriptorBoundary`
- `hf.player.localPreview`
- `hf.player.providerStatus`
- `hf.movieDetail.playbackStatus`
- `hf.route.watchNow`

## Local Preview Fallback

Local preview remains the default fallback. Friendly and Paranormall can continue through local preview readiness when no provider descriptor is available.

If streaming runtime config is missing, the app remains `Local Preview Ready`.

If streaming runtime config is partial, the app reports `Provider Descriptor Missing`.

## What Waits For Production

- Production streaming provider launch
- Raw Cloudflare or Mux SDKs
- App-side provider tokens
- Hardcoded backend URLs
- Hardcoded media URLs
- Remote playback activation without approved backend descriptors
- Media downloads
- Payment/entitlement validation
- Rights checks
- Provider credential storage
- Live VOD publishing
- App Store production configuration
