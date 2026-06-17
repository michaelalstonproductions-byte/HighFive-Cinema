# HighFive StoreKit Paywall Movie ID Mapping

## Upgrade

#060.0A - StoreKit paywall movie-ID access mapping integration.

## Old Project Inspected

- Project path: `/Volumes/Scratch SSD/May 24th 917 `
- StoreKit config: `HighFive/App/Store/HighFive.storekit/Configuration.storekit`
- Purchase manager: `HigherKey_UI_Library_Paywall_LUT_Restore_Bundle/HKV1_PurchaseManager.swift`
- Paywall detail UI: `HigherKey_UI_Library_Paywall_LUT_Restore_Bundle/HKCMovieDetailViewController.swift`
- Library purchase routing: `HigherKey_UI_Library_Paywall_LUT_Restore_Bundle/HKC_LIBRARYViewController.swift`
- Playback source resolver: `HighFive/App/Library/HKCPlaybackSourceResolver.swift`
- Movie model source: `HighFive/App/Library/HKC_MovieModels.swift`

## What Was Reused

- Safe StoreKit product identifiers from the StoreKit configuration.
- Old movie IDs used by purchase entitlement routing.
- Product-to-title mapping for The Friendly and Paranormall Season 1.
- Episode product mapping pattern for Paranormall episodes 1 through 7.
- The access decision shape: Movie ID -> product reference -> entitlement validation -> playback descriptor readiness.

## What Was Not Copied

- Live StoreKit transaction handling.
- Product loading with StoreKit APIs.
- Purchase and restore calls.
- Old UIKit paywall screens.
- Hardcoded stream URLs.
- Cloudflare video UID values.
- Local network stream base URLs.
- Old playback engine or protected playback internals.
- Project file membership changes.

## Movie ID Mapping

| Current movie ID | Old project movie ID | StoreKit product ID | Access scope |
| --- | --- | --- | --- |
| `friendly` | `the_friendly` | `com.highfive.movie.thefriendly` | movie |
| `paranormall-s1` | `paranormall_s1` | `com.highfive.series.paranormall.season1` | season |
| `paranormall-s1` | `paranormall_s1_e1` | `com.highfive.episode.paranormall.e1` | episode |
| `paranormall-s1` | `paranormall_s1_e2` | `com.highfive.episode.paranormall.e2` | episode |
| `paranormall-s1` | `paranormall_s1_e3` | `com.highfive.episode.paranormall.e3` | episode |
| `paranormall-s1` | `paranormall_s1_e4` | `com.highfive.episode.paranormall.e4` | episode |
| `paranormall-s1` | `paranormall_s1_e5` | `com.highfive.episode.paranormall.e5` | episode |
| `paranormall-s1` | `paranormall_s1_e6` | `com.highfive.episode.paranormall.e6` | episode |
| `paranormall-s1` | `paranormall_s1_e7` | `com.highfive.episode.paranormall.e7` | episode |

Unmapped catalog titles use `<STOREKIT_PRODUCT_ID_REQUIRED>` until App Store product IDs are assigned.

## StoreKit Product Mapping Requirements

- StoreKit product mapping is staged in app code as catalog metadata only.
- Paywall readiness is visible but disabled.
- Product ID required is shown for unmapped catalog entries.
- Restore Purchases Not Active Yet remains true until production StoreKit restore behavior and entitlement validation are implemented.

Runtime config names:

- `HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE`
- `HIGHFIVE_REVENUECAT_PROJECT_ID`
- `HIGHFIVE_ENTITLEMENT_BASE_URL`

## Cloudflare Playback Descriptor Requirements

The old project contained hardcoded Cloudflare playback URLs and UID-like identifiers. Those were intentionally not copied.

Current rule:

- Cloudflare playback requires backend descriptor.
- Playback descriptor requires entitlement.
- Server Entitlement Validation Required before remote playback access.
- Local Preview Access remains available.

Runtime config names:

- `HIGHFIVE_STREAMING_PROVIDER`
- `HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL`

## Production Requirements Still Pending

- Sandbox StoreKit product configuration.
- Server entitlement validation.
- Restore purchase validation.
- Refund, revocation, and expiration handling.
- Backend playback descriptor endpoint.
- Cloudflare playback descriptor response.
- App Review paywall behavior.
- No secrets, URLs, Cloudflare tokens, service-role keys, or backend URLs are committed in this phase.
