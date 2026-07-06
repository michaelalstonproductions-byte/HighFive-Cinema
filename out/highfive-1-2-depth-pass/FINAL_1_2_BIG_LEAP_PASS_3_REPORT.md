# HighFive Cinema 1.2 Big Leap Pass 3

## Verdict

Big Leap Pass 3 is implemented. Release safety passed. Direct Debug and Release Swift typechecks passed. Full `xcodebuild` remains blocked by local Xcode/CoreSimulator/swiftc permission tooling before Swift compilation.

## Files changed

- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFDepthPosterFrame.swift`
- `HighFive/Components/HFPosterCard.swift`
- `HighFive/Views/Home/HomeView.swift`
- `HighFive/Views/MovieDetail/MovieDetailView.swift`
- `HighFive/Packaging/PromoPackageModels.swift`
- `HighFive/Packaging/CaptionHookGenerator.swift`
- `HighFive/Packaging/MarkOfTheWestPromoKit.swift`
- `HighFive/Packaging/PackagingWorkspaceView.swift`
- `scripts/import_mark_of_the_west_lookbook_assets.sh`
- `out/highfive-1-2-depth-pass/FILES_TO_TRACK_FOR_1_2.md`
- `out/highfive-1-2-depth-pass/MARK_OF_THE_WEST_ASSET_IMPORT.md`

## Assets imported

No real The Mark of the West lookbook PDF or image source was found in the repo.

Asset search covered:

- `*mark*west*`
- `*lookbook*`
- `*keynote*`
- `*.pdf`
- `*queho*`

Result:

- No app assets were imported.
- The app keeps the procedural western cinematic fallback.
- The Home hero now automatically prefers `mark_west_hero_keyart` if that asset is added later.
- Added `scripts/import_mark_of_the_west_lookbook_assets.sh` as an isolated importer stub.
- Added `MARK_OF_THE_WEST_ASSET_IMPORT.md` with expected future asset names and import rules.

## Mark of the West asset mode

Current mode: procedural fallback.

Future preferred asset:

- `mark_west_hero_keyart`

Expected future generated assets:

- `mark_west_title_poster`
- `mark_west_character_queho`
- `mark_west_world_locations`
- `mark_west_pitch_at_glance`
- `mark_west_dark_quote`

## Depth Director components

Added / refined:

- `HFDepthScenePhase`
- `HFDepthSurfaceRole`
- `HFDepthRenderBudget`
- `HFDepthIntensityProfile`
- `HFCinematicDepthDirector`

Roles supported:

- `hero`
- `detailPoster`
- `focusedCard`
- `rowCard`
- `backgroundAtmosphere`
- `compactUtility`
- `staticDecorative`

The director coordinates motion budgets for image offset, background offset, glass offset, rotation, shadow, glow, geometry fallback, Reduce Motion, and Low Power Mode. It wraps the existing `HFUIDepthMotionController`; it does not create another CoreMotion loop.

## CoreMotion manager count

Current scan found 2 `CMMotionManager` instances:

1. `HFUIDepthMotionController` for UI-level depth.
2. Existing protected `HKV1_MotionService` for player/onboarding motion.

`HKV1_MotionService` was not rewritten.

## Home hero changes

- Home still uses the exact requested copy:
  - `PRE-PRODUCTION`
  - `The Mark of the West`
  - `Limited Series Coming Soon`
  - `Starring Derek Hinkey`
- Hero now participates in the cinematic depth director as role `hero`.
- Hero uses `mark_west_hero_keyart` if present, otherwise procedural western fallback.
- Procedural fallback remains layered with horizon glow, mountain silhouettes, dust/haze, vignette, and atmosphere.
- `Coming Soon` remains a non-tappable status pill.
- `My List` remains.
- Compact `Import` slate remains beside My List.
- No `Watch Now`, fake release date, or fake playable action was added.
- `Available Now` remains The Friendly and Paranormall only.

## Movie Detail changes

- Detail poster now uses the depth director role `detailPoster`.
- Added a premium floor/shadow plane under the framed poster.
- Poster frame continues to use physical motion, geometry fallback, glass reflection, edge glow, and deep shadow.
- Everything under the poster remains in place.
- StoreKit/watch/buy/trailer/episode logic was not changed.

## Poster card changes

- Row cards use low-intensity row depth.
- Pressed cards temporarily use `focusedCard` role.
- Press interaction keeps the existing subtle scale/shadow lift.
- No marquee, bulb, or NOW SHOWING component is mounted in active Home/detail/poster-card UI.

## Launch / intro changes

- No launch/intro source edits were required in Pass 3.
- Existing native LaunchScreen, `HFLaunchReadyGate`, launch atmosphere, and intro prewarm remain intact.
- No black-screen or launch-flow changes were introduced.

## Packaging / Social workspace progress

Added isolated internal scaffolding under `HighFive/Packaging/`:

- Promo package models.
- Export presets:
  - TikTok vertical 9:16
  - Instagram Reel/Story 9:16
  - Instagram square 1:1
  - LinkedIn landscape 16:9
  - poster export 2:3
  - press-kit slide 4:5 / 16:9
- Social layout presets.
- Caption hook generator.
- Mark of the West starter promo kit.
- Internal preview-only `PackagingWorkspaceView`.

No upload, network calls, contact imports, CRM, or consumer playback connection was added.

## CRM / privacy preservation

- No contact data imported.
- No public CRM UI added.
- No external service upload added.
- Packaging workspace is isolated and preview/draft oriented.

## Source hygiene

Still untracked but used:

- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFDepthPosterFrame.swift`

New pass 3 files are also untracked until the owner stages them.

Git add recommendations are written to:

- `out/highfive-1-2-depth-pass/FILES_TO_TRACK_FOR_1_2.md`

No `git add` was run.

## Systems preserved

- StoreKit
- Restore Purchases
- Entitlement checks
- Product IDs
- Purchase/watch routing
- The Friendly unlock/routing
- Paranormall unlock/routing
- Paranormall Episode 7 `e7.v2`
- Official catalog routing
- Imported/local video routing
- Streaming resolver
- Trailer-only preview rules
- Vertical Stage
- Layer 4
- Player Depth / Tilt / Peek
- `HKV1_MotionService`
- Legal acceptance flow
- Native LaunchScreen
- `HFLaunchReadyGate`
- CRM/contact privacy
- Release safety scripts

## Validation results

- Release safety: PASS
- Debug direct Swift typecheck: PASS
- Release direct Swift typecheck: PASS
- Debug `xcodebuild`: BLOCKED by local tooling
- Release `xcodebuild`: BLOCKED by local tooling

Known local `xcodebuild` blocker:

- `CoreSimulatorService connection became invalid`
- `Unable to discover swiftc command line tool info: Could not parse Swift versions from: error: permissionDenied`
- invalid local provisioning profile UUID warnings

## Risky string scan

Findings:

- No active `Button(action: {})` remains in the Home hero.
- Old marquee/bulb/NOW SHOWING strings remain only in unused legacy component files:
  - `HFPosterMarqueeFrame.swift`
  - `HFTheaterMarqueePosterFrame.swift`
- `poster_breaking_the_chain_coming_soon` remains in catalog/mock data for the separate Breaking the Chain title, not the active Mark of the West hero.
- `localhost` / `staging` findings are existing backend/readiness scaffolding, not introduced by this pass.

## Real-device QA still needed

- Home hero physical tilt feel.
- Movie Detail poster physical tilt feel.
- Scroll performance in poster rows.
- Reduce Motion behavior.
- Low Power Mode behavior.
- Mark of the West hero on small iPhones.
- The Friendly unlock.
- Paranormall Episode 7 `e7.v2`.
- Trailer-only previews.
- Official titles never open Import.
- Vertical Stage.
- Depth/Tilt/Peek.
- Layer 4.
- Release has no debug UI.
