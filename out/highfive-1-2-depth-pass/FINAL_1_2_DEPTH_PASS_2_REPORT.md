# HighFive Cinema 1.2 Immersive Depth Pass 2

## Verdict

SOURCE CHECK COMPLETE. The second depth pass is implemented. Full `xcodebuild` is still blocked by local Xcode/CoreSimulator permission/tooling, but direct Debug and Release Swift typechecks pass.

## Files changed in this pass

- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFDepthPosterFrame.swift`
- `HighFive/Components/HFPosterCard.swift`
- `HighFive/Views/Home/HomeView.swift`

## Tracked / untracked depth files

- `HighFive/Components/HFDepthPosterFrame.swift`: untracked, used by the app.
- `HighFive/Components/HFDepthUIComponents.swift`: untracked, used by the app.

Both were left in place.

## UI motion source

- Added `HFUIDepthMotionController`, a shared UI-level motion controller.
- It uses a single `CMMotionManager` for Home/detail/poster UI depth.
- It starts from `DepthMotionProvider` only while depth UI surfaces are visible.
- It stops when there are no visible subscribers.
- It respects Reduce Motion.
- It reduces update rate/intensity when Low Power Mode is enabled.
- It clamps and smooths output.
- It warms in from a neutral vector to avoid a late snap.
- It falls back to geometry-based depth when device motion is unavailable.

## CoreMotion manager count

Current source scan found 2 `CMMotionManager` instances:

1. `HFUIDepthMotionController` for lightweight UI depth.
2. Existing protected `HKV1_MotionService` for player/onboarding motion.

No player, Vertical Stage, Layer 4, Tilt, or Peek motion service was rewritten.

## Home hero changes

- Replaced unrelated hero asset usage with a procedural Mark of the West cinematic western backdrop.
- Removed the active no-op `Button(action: {})` from the hero.
- `Coming Soon` is now a non-tappable premium status pill.
- Hero copy remains:
  - `PRE-PRODUCTION`
  - `The Mark of the West`
  - `Limited Series Coming Soon`
  - `Starring Derek Hinkey`
- `My List` remains.
- Compact `Import` slate remains beside My List.
- `Available Now` remains curated to The Friendly and Paranormall.

## Movie Detail depth changes

- The existing premium framed poster now reads from the shared UI depth provider.
- Poster frame shadow, 3D rotation, atmosphere, and glass reflection respond subtly to physical iPhone motion.
- Geometry fallback remains active for simulator/unavailable motion.
- Title/info/actions/preview remain below the poster.
- StoreKit/watch/buy/trailer/episode logic was not changed.

## Poster card changes

- Catalog poster cards keep the premium depth poster wrapper.
- Added subtle press/lift interaction.
- Press state deepens gold shadow and slightly compresses the card.
- No marquee, bulbs, or NOW SHOWING treatment is mounted in active Home/detail/poster-card UI.

## Launch / intro changes

- No additional launch/intro source edits were needed in this pass.
- Existing launch atmosphere and intro prewarm behavior from pass 1 remain in place.
- Native LaunchScreen and `HFLaunchReadyGate` were not changed.

## Systems intentionally preserved

- StoreKit product IDs
- Restore Purchases
- Entitlement checks
- Official catalog routing
- Imported/local video routing
- Streaming resolver
- The Friendly purchase/watch routing
- Paranormall purchase/watch routing
- Paranormall Episode 7 `e7.v2`
- Vertical Stage
- Layer 4
- Player Depth / Tilt / Peek
- Legal agreement flow
- Native LaunchScreen
- `HFLaunchReadyGate`
- CRM/contact privacy

## Validation

- Release safety check: PASS
- Debug `xcodebuild`: BLOCKED by local Xcode/CoreSimulator tooling
- Release `xcodebuild`: BLOCKED by local Xcode/CoreSimulator tooling
- Debug direct Swift typecheck: PASS
- Release direct Swift typecheck: PASS

Known local build blockers:

- `CoreSimulatorService connection became invalid`
- `Unable to discover swiftc command line tool info: Could not parse Swift versions from: error: permissionDenied`
- invalid/missing local provisioning profile UUID warnings

These occurred before normal Swift compilation. Direct typecheck passed after using a writable module cache and repo-relative source file list.

## QA completed

- Verified active Home/detail/poster-card files do not mount marquee/bulb UI.
- Verified release safety script passes.
- Verified direct Debug and Release Swift typechecks pass.
- Verified the Mark of the West hero no longer uses `poster_breaking_the_chain_coming_soon` in the active hero path.
- Verified the hero no longer has an active no-op `Coming Soon` button.

## Real-device QA still needed

- Home hero tilt feel on physical iPhone.
- Reduce Motion behavior.
- Low Power Mode behavior.
- The Mark of the West hero on small iPhones.
- The Friendly unlock.
- Paranormall Episode 7 `e7.v2`.
- Trailer-only previews.
- Official titles never open Import.
- Vertical Stage.
- Depth/Tilt/Peek.
- Layer 4.
- Release has no debug UI.
