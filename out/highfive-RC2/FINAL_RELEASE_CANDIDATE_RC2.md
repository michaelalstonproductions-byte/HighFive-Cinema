# HighFive Cinema RC2 - Real Device Validation Sprint

## Scope

RC2 focused on customer-visible validation only: Launch, onboarding gate, Home, Search, Movie Detail entry points, trailer preview entry points, Library, Downloads, Profile, Continue Watching, recommendation rails, Restore Purchases UI, and streaming access surfaces.

No protected runtime, StoreKit, playback, streaming, backend, rendering, Depth/Tilt/Peek, Vertical Stage, or Layer 4 systems were modified.

## Issues Found

- Home: Continue Watching used the generic catalog fallback when no progress titles existed. This presented unrelated titles under a Continue Watching label and could mislead QA/customer validation.
- Search: Recent Searches deduplicated with `Set` and sorted alphabetically, so the rail did not preserve recent-history order.
- Search: Search intent chips relied on combined child text instead of an explicit accessibility label, making VoiceOver output less predictable.
- Simulator validation: Debug simulator build could not complete because CoreSimulator services disconnected during storyboard and asset catalog compilation.

## Issues Fixed

- Home: Continue Watching now disables the generic fallback and shows a focused empty state when there are no in-progress titles.
- Home: Continue Watching hides the count badge when the rail is empty and exposes a clear combined accessibility label for the empty state.
- Search: Recent Searches now preserves first-seen order while removing duplicates.
- Search: Search intent chips now expose explicit combined accessibility labels.

## Remaining Risks

- Real-device/TestFlight QA remains required for launch, onboarding, trailer preview, StoreKit sheet presentation, Restore Purchases, entitlement state, streaming access, and exit playback flows.
- Simulator install/launch was not valid from this run because the failed build produced only a partial app bundle with no `Info.plist`.
- Existing asset catalog warnings remain for duplicate image/app icon set names across Store and UI asset catalogs. They were not changed in RC2 because this sprint was limited to low-risk customer-facing fixes.
- Pre-existing untracked 4.2 simulator workflow files remain outside the RC2 change set.

## Recommended Next Actions

- Run the same RC2 customer journey on a physical device or TestFlight build.
- Retry the Debug simulator build after CoreSimulatorService and simdiskimaged are stable.
- Verify Restore Purchases UI on a signed device build with a sandbox Apple ID.
- Verify trailer preview, streaming access, exit playback, and return Home on device.
- Schedule a separate asset-catalog cleanup if duplicate asset warnings become release-noisy.

## Validation

- `scripts/highfive_release_safety_check.sh`: PASS.
- `scripts/highfive_direct_typecheck.sh`: PASS for debug direct Swift typecheck and release direct Swift typecheck.
- `git diff --check`: PASS.
- Debug simulator build: BLOCKED by CoreSimulator environment.

Simulator build command attempted:

```bash
TMPDIR="/private/tmp" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/private/tmp/highfive-RC2-build" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Observed simulator failure:

- `CoreSimulatorService connection became invalid`
- `Unable to discover any Simulator runtimes`
- `No available simulator runtimes for platform iphonesimulator`
- Failures occurred during `CompileStoryboard` and `CompileAssetCatalogVariant`
- Partial bundle path existed, but `/private/tmp/highfive-RC2-build/Build/Products/Debug-iphonesimulator/HighFive Cinema.app/Info.plist` was missing, so install/launch was not attempted from that output.

## Updated Release Readiness Score

87 / 100

The app passes release safety and direct Swift validation after the RC2 visual/accessibility fixes. The score remains below final TestFlight readiness until a real-device run validates StoreKit presentation, restore flow, trailer preview, streaming access, playback exit, and full launch/navigation behavior.
