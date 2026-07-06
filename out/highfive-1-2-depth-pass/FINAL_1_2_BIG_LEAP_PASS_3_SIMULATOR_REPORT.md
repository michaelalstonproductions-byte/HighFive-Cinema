# HighFive Cinema 1.2 Big Leap Pass 3 + Simulator Preview Report

## Verdict

SOURCE CHECK COMPLETE. Simulator preview support was implemented, release safety passed, and direct Debug/Release Swift typechecks passed. Full simulator build/install/launch is blocked by local CoreSimulator tooling before app build begins.

Latest validation rerun: July 6, 2026 at 12:14 PM MDT.

## Files Changed

- `HighFive/Components/HFDepthUIComponents.swift`
- `scripts/highfive_simulator_doctor.sh`
- `scripts/run_highfive_simulator.sh`
- `scripts/capture_highfive_simulator.sh`
- `scripts/highfive_direct_typecheck.sh`
- `out/highfive-1-2-depth-pass/FILES_TO_TRACK_FOR_1_2.md`
- `out/highfive-1-2-depth-pass/MARK_OF_THE_WEST_ASSET_IMPORT_PASS_3.md`
- `out/highfive-1-2-depth-pass/FINAL_1_2_BIG_LEAP_PASS_3_SIMULATOR_REPORT.md`

## Simulator Scripts Created / Modified

- `scripts/highfive_simulator_doctor.sh`: non-destructive Xcode/CoreSimulator diagnostic script writing `out/simulator/simulator-doctor.txt`.
- `scripts/run_highfive_simulator.sh`: picks an iPhone simulator, builds Debug, installs, launches with `--hf-simulator-preview --hf-simulate-ui-depth --hf-open-home`, and captures `out/simulator/highfive-home.png` when tooling works.
- `scripts/capture_highfive_simulator.sh`: captures `out/simulator/highfive-current.png` and optionally records `out/simulator/highfive-depth-preview.mov`.
- `scripts/highfive_direct_typecheck.sh`: reusable direct Debug/Release Swift typecheck fallback using known pass-3 file lists and `/private/tmp` module cache.

All scripts are executable and passed `bash -n`.

## Simulator Build / Install / Launch Result

BLOCKED by local CoreSimulator tooling before build/install/launch. Reconfirmed on the latest run at July 6, 2026 12:14 PM MDT.

Exact blocker from `out/simulator/run-highfive-simulator.log` and `out/simulator/simulator-doctor.txt`:

- `CoreSimulatorService connection became invalid`
- `Error opening log file (/Users/michaelalston/Library/Logs/CoreSimulator/CoreSimulator.com.apple.CoreSimulator.simctl.log): Operation not permitted`
- `Unable to discover any Simulator runtimes`
- `simdiskimaged crashed or is not responding`
- `Unable to locate device set`
- `NSPOSIXErrorDomain Code=61 "Connection refused"`

Screenshot/video were not created because `simctl list devices available -j` failed before a simulator could be selected.

## Simulator Preview Mode

Implemented `--hf-simulate-ui-depth` in `HFUIDepthMotionController`.

Behavior:

- Active only under `#if DEBUG && targetEnvironment(simulator)`.
- Also accepts `--hf-simulator-preview`.
- Uses the existing UI depth motion controller.
- Does not create another production CoreMotion loop.
- Does not touch `HKV1_MotionService`, Vertical Stage, Layer 4, or player Depth/Tilt/Peek.
- Emits a slow cinematic synthetic vector:
  - x roughly `-0.35...0.35`
  - y roughly `-0.22...0.22`
  - cycle roughly `11.5s` / `13s`
- Low Power Mode reduces intensity.
- Reduce Motion disables motion because `DepthMotionProvider` calls `start(reduceMotion:)` and returns `.still` when Reduce Motion is enabled.

Visual confirmation is still pending because the simulator is blocked locally.

## Mark of the West Assets

No real Mark of the West lookbook PDF or optimized image package was found.

Search output:

- `out/highfive-1-2-depth-pass/mark-west-asset-search-simulator.txt`

Current app behavior:

- Home hero uses `mark_west_hero_keyart` if available.
- If unavailable, Home uses the procedural cinematic western fallback.

Asset notes:

- `out/highfive-1-2-depth-pass/MARK_OF_THE_WEST_ASSET_IMPORT_PASS_3.md`
- Importer stub remains: `scripts/import_mark_of_the_west_lookbook_assets.sh`

## Depth Director Components

Already present from Pass 3 and preserved:

- `HFCinematicDepthDirector`
- `HFDepthScenePhase`
- `HFDepthSurfaceRole`
- `HFDepthIntensityProfile`
- `HFDepthRenderBudget`
- `DepthMotionProvider`
- `HFUIDepthMotionController`
- `PremiumDepthPosterView`
- `DepthHeroStage`
- `DepthAtmosphereLayer`

This pass added DEBUG simulator synthetic depth motion inside `HFUIDepthMotionController`.

## CoreMotion Manager Count

`out/highfive-1-2-depth-pass/coremotion-manager-count-simulator.txt` found 2 `CMMotionManager` instances:

- `HighFive/App/Motion/HKV1_MotionService.swift` for protected player motion.
- `HighFive/Components/HFDepthUIComponents.swift` for UI-level depth motion.

No new production CoreMotion manager was added.

## Home Hero Changes

No consumer layout rewrite was needed in this pass. Existing Pass 3 behavior remains:

- Hero promotes The Mark of the West.
- Exact copy is preserved:
  - `PRE-PRODUCTION`
  - `The Mark of the West`
  - `Limited Series Coming Soon`
  - `Starring Derek Hinkey`
- Uses real `mark_west_hero_keyart` if present, else procedural western fallback.
- Available Now remains The Friendly and Paranormall.
- Import remains compact and secondary.

## Movie Detail Changes

No StoreKit/watch/buy/trailer/episode logic changed.

Existing Pass 3 behavior remains:

- Detail poster uses premium depth poster treatment.
- Title/info/actions remain below poster.
- Trailer/episode controls remain unchanged.

## Poster Cards

No card routing changes.

Existing Pass 3 behavior remains:

- Poster cards use premium depth treatment.
- Row cards stay low intensity.
- Press/focus state deepens tactile feel.
- Badges remain outside artwork.

## Launch / Intro

Native LaunchScreen and `HFLaunchReadyGate` were not changed in this pass.

Simulator synthetic UI depth is isolated to UI depth surfaces and does not affect the launch gate, protected player motion, Vertical Stage, Layer 4, or onboarding playback logic.

## Packaging / Social Workspace

Existing isolated scaffolding remains:

- `HighFive/Packaging/PromoPackageModels.swift`
- `HighFive/Packaging/CaptionHookGenerator.swift`
- `HighFive/Packaging/MarkOfTheWestPromoKit.swift`
- `HighFive/Packaging/PackagingWorkspaceView.swift`

No network calls, uploads, contact data, public CRM UI, StoreKit changes, or consumer playback changes were added.

## CRM / Privacy Preservation

PASS. No CRM/contact data import, external upload, backend call, or public CRM UI was added.

## Source Hygiene

These app source files are still untracked but used:

- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFDepthPosterFrame.swift`

Updated recommendations:

- `out/highfive-1-2-depth-pass/FILES_TO_TRACK_FOR_1_2.md`

No files were staged or committed.

## Systems Preserved

No intentional changes were made to:

- StoreKit product IDs
- Restore Purchases
- Entitlement checks
- Purchase/watch routing
- The Friendly unlock/routing
- Paranormall unlock/routing
- Paranormall Episode 7 `e7.v2`
- Official/import routing separation
- Streaming resolver
- Trailer-only preview rules
- Vertical Stage
- Layer 4
- Player Depth/Tilt/Peek
- `HKV1_MotionService`
- Legal acceptance flow
- Native LaunchScreen
- `HFLaunchReadyGate`
- CRM/contact privacy
- Release safety scripts

## Validation Results

- Release safety: PASS
  - `out/highfive-1-2-depth-pass/release-safety-check-simulator.txt`
- Debug direct Swift typecheck: PASS
  - `out/simulator/debug-typecheck.status`
  - `out/simulator/debug-typecheck.log`
- Release direct Swift typecheck: PASS
  - `out/simulator/release-typecheck.status`
  - `out/simulator/release-typecheck.log`
- Simulator build/install/launch: BLOCKED by CoreSimulatorService local tooling.
  - `out/simulator/run-highfive-simulator.log`
  - `out/simulator/simulator-doctor.txt`

## Risky String Scan

Scan output:

- `out/highfive-1-2-depth-pass/risky-string-scan-simulator.txt`

Notes:

- `staging`/`localhost` hits are existing backend/staging scripts and scaffolding, not this pass's consumer UI.
- `full movie` appears in release safety script language.
- Legacy marquee/bulb strings may remain in unused legacy component files but are not mounted by Home/Movie Detail/PosterCard active UI.

Protected-system scan output:

- `out/highfive-1-2-depth-pass/protected-string-scan-simulator.txt`

## Real-Device QA Still Needed

- Home hero physical tilt feel.
- Movie Detail poster physical tilt feel.
- Simulator visual depth preview comparison after CoreSimulator is fixed.
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
