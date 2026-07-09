# HighFive Cinema TF1 - TestFlight Validation Pack

## Scope

TF1 is a final validation pack for the customer streaming journey: Launch, Onboarding, Home, Movie Detail, Trailer preview, Search, Library, Downloads, Profile, Purchase UI, Restore Purchases UI, Continue Watching, Recommendations, playback exit, and Return Home.

No feature work was added. No StoreKit, streaming, playback, Cloudflare, Vertical Stage, Layer 4, Depth/Tilt/Peek, backend, legal, CRM, Creator OS, Brain, Packaging, or Executive systems were modified.

## Real iPhone Checklist

| Area | Expected result | Status |
| --- | --- | --- |
| Launch | App cold launches to onboarding or Home without blank/dead-end UI. | Pending device QA |
| Onboarding | Intro controls are readable, safe-area aligned, and enter Home cleanly. | Pending device QA |
| Home | Hero, Continue Watching, recommendations, Featured Originals, Coming Soon, and Available Now scroll smoothly. | Pending device QA |
| Movie Detail | Poster, metadata, trailer, actions, episodes, cast, recommendations, and paywall states are readable. | Pending device QA |
| Trailer Preview | Trailer opens and closes back to Movie Detail. | Pending device QA |
| Search | Suggestions, recent searches, filters, empty states, and result navigation work. | Pending device QA |
| Library | Empty state, shelves, Continue Watching, Favorites, Purchased, Downloaded, and Watch Later are clear. | Pending device QA |
| Downloads | Empty state and local preview state are clear and do not overpromise real offline media. | Pending device QA |
| Profile | Account, profile management, support, legal, Restore Purchases, and internal tools remain reachable from Profile. | Pending device QA |
| Purchase UI | Locked title purchase controls show correct copy and in-progress accessibility state. | Pending device QA |
| Restore Purchases UI | Restore controls from Profile and paywall are visible, labeled, and report state. | Pending device QA |
| Playback exit | Player/trailer close returns to the prior customer surface without trapping navigation. | Pending device QA |
| Return Home | Home remains reachable from bottom tabs after detail, search, purchase, and playback flows. | Pending device QA |

## TestFlight Checklist

- Install TF1 on a clean physical iPhone.
- Install TF1 as an upgrade over the prior TestFlight build.
- Test with VoiceOver off, VoiceOver on, default text size, and at least one larger Dynamic Type size.
- Test on Wi-Fi and cellular.
- Use sandbox Apple IDs for purchase and Restore Purchases verification.
- Verify locked and unlocked states for The Friendly and Paranormall.
- Confirm debug-only unlock UI is absent in the TestFlight build.
- Confirm official titles do not expose Import as a playback path.
- Capture screenshots for Launch, Home, Movie Detail locked, Movie Detail unlocked, Search, Library, Downloads, Profile Account, purchase UI, and Restore Purchases.
- Record device model, iOS version, app version, build number, Apple ID type, and network type for each run.

## App Store Connect Checklist

- Bundle ID confirmed: `com.higherkey.HigherKeySpatialPeek-Rebuild`.
- Version and build number match the submitted TestFlight binary.
- App name, subtitle, category, age rating, copyright, support URL, and privacy policy URL are final.
- Privacy manifest and App Store privacy answers match shipped behavior.
- StoreKit products are correctly configured for TestFlight/App Review.
- In-app purchase screenshots, descriptions, and review notes are complete if required.
- App Review notes include sandbox purchase/restore guidance.
- Export compliance, content rights, and encryption answers are complete.
- Required device screenshots match the current UI.
- TestFlight external testing groups and tester instructions are ready.

## Known Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| StoreKit sheet behavior differs on physical device | Purchase validation could fail App Review/TestFlight QA. | Run sandbox purchase and restore on real iPhone before external TestFlight. |
| Simulator instability in local environment | Simulator build/install cannot be used as proof of readiness. | Use physical iPhone/TestFlight as source of truth. |
| Streaming provider boundaries | Cloudflare/playback paths require signed-device verification. | Validate trailer/full playback and exit flow on Wi-Fi and cellular. |
| Large Dynamic Type layout | Compact paywall/detail/Profile areas may wrap differently on device. | Include large text size pass in TF1 checklist. |
| Asset catalog duplicate warnings | Build logs may be noisy even if app runs. | Track separately; do not block TF1 unless archive fails. |

## Pass/Fail Table

| Gate | Required for TF1 | Current status |
| --- | --- | --- |
| Source release safety | Yes | PASS |
| Direct Swift typecheck | Yes | PASS |
| Whitespace diff check | Yes | PASS |
| Simulator build | Preferred, not authoritative | Not run for TF1; prior GM attempt blocked by CoreSimulator |
| Real iPhone install | Yes | Pending |
| Real iPhone launch | Yes | Pending |
| StoreKit purchase | Yes | Pending |
| Restore Purchases | Yes | Pending |
| Trailer/playback exit | Yes | Pending |
| App Store Connect metadata | Yes | Pending |

## Validation

- `scripts/highfive_release_safety_check.sh`: PASS.
- `scripts/highfive_direct_typecheck.sh`: PASS for debug direct Swift typecheck and release direct Swift typecheck.
- `git diff --check`: PASS.

## Release Recommendation

Proceed to internal TestFlight upload if the signed archive succeeds. Do not expand to external TestFlight or App Review until the real iPhone checklist passes, especially StoreKit purchase, Restore Purchases, trailer/playback exit, and App Store Connect metadata verification.
