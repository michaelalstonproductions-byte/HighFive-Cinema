# HighFive Cinema 1.2 Immersive Depth Pass

## Files changed

- `HighFive.xcodeproj/project.pbxproj`
- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFPosterCard.swift`
- `HighFive/Views/Home/HomeView.swift`
- `HighFive/Views/MovieDetail/MovieDetailView.swift`
- `HighFive/App/Launch/HFLaunchBridgeView.swift`
- `HighFive/Views/Onboarding/HighFiveIntroFlowView.swift`

## Depth components created / modified

- Added `DepthMotionValues`
- Added `DepthMotionProvider`
- Added `DepthParallaxModifier`
- Added `DepthAtmosphereLayer`
- Added `PremiumDepthPosterView`
- Added `DepthHeroStage`
- Added `CompactImportSlateButton`
- Reused the existing `HFDepthPosterFrame` as the core framed-poster renderer.

The new depth behavior is UI-level and geometry-based. It does not start another CoreMotion loop and respects Reduce Motion through `DepthMotionProvider` / `DepthParallaxModifier`.

## Home changes

- Home hero now promotes:
  - `PRE-PRODUCTION`
  - `The Mark of the West`
  - `Limited Series Coming Soon`
  - `Starring Derek Hinkey`
  - `A HighFive Cinema Original`
- Hero now uses `DepthHeroStage` with cinematic atmosphere and subtle geometry parallax.
- Paranormall remains down in `Available Now`.
- `Available Now` remains limited to:
  - The Friendly
  - Paranormall
- `Coming Soon` remains a single curated rail.
- Import is a compact slate button beside `My List`.
- Lower giant Import card is not mounted in the current Home body.

## Movie Detail changes

- Compact title detail poster is now a centered premium framed depth poster again, instead of a full-width cropped hero.
- Poster uses `PremiumDepthPosterView`.
- Added subtle atmosphere behind the poster.
- Poster image uses full `scaledToFit` 2:3 presentation.
- Title/info card, preview, genres, actions, synopsis, credits, episodes, and purchase/watch logic remain below the poster.

## Launch / Intro changes

- Launch bridge now uses `DepthAtmosphereLayer` for a more cinematic branded loading moment.
- Intro depth prewarm cover now shares the same depth atmosphere language.
- Existing native LaunchScreen and `HFLaunchReadyGate` flow are preserved.
- Existing intro depth prewarm logic remains in place.

## Version

- `MARKETING_VERSION` is now `1.2`.
- `CURRENT_PROJECT_VERSION` is now `13`.

## Systems intentionally preserved

- StoreKit product IDs
- Pricing logic
- Entitlement verification
- Paywall behavior
- Official stream manifest / resolver behavior
- Preview vs full playback routing
- Official/import routing boundaries
- Vertical Stage
- Layer 4 runtime rules
- Depth / Tilt / Peek player behavior
- Bottom tabs
- CRM privacy
- Release safety scripts

## QA completed

- Release safety check: PASS
- Active UI scan: old marquee/bulb components are not mounted in active Home/Movie Detail UI. Old component files still exist and were not deleted.
- Debug xcodebuild: BLOCKED by local Xcode/CoreSimulator/tooling permissions.
- Release xcodebuild: BLOCKED by local Xcode/CoreSimulator/tooling permissions.
- Debug direct Swift typecheck: PASS
- Release direct Swift typecheck: PASS

Known local xcodebuild blockers:
- `CoreSimulatorService connection became invalid`
- `Unable to discover swiftc command line tool info: Could not parse Swift versions from: error: permissionDenied`
- `/Volumes/Scratch SSD/XcodeDerivedData/...` log arena permission failure

Warnings remaining are existing AVFoundation/deprecation warnings in playback/store inspection code.

## Real-device QA still needed

- Confirm Home hero motion feels subtle on physical device.
- Confirm Reduce Motion disables depth movement.
- Confirm The Mark of the West hero layout on small iPhones.
- Confirm detail poster frame looks premium and title/info remains below it.
- Confirm Home/Search poster card scrolling remains smooth.
- Confirm intro starts without a late depth pop.
- Confirm Watch Trailer / Watch Episode / Unlock flows still behave normally.

