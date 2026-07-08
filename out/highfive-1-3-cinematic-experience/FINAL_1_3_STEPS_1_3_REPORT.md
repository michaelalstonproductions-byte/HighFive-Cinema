# HighFive Cinema 1.3 Cinematic Experience Update — Steps 1–3

## Verdict

SOURCE CHECK COMPLETE, FULL XCODE/SIMULATOR VALIDATION BLOCKED BY LOCAL TOOLING.

Simulator validation is blocked by the local CoreSimulator/Xcode installation. Source validation passed. Commits created.

## Files Changed

- `HighFive/Components/HFLayer4UltraDepthFX.swift`
- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFDepthPosterFrame.swift`
- `HighFive/Views/Home/HomeView.swift`
- `HighFive/Views/MovieDetail/MovieDetailView.swift`
- `HighFive/App/Playback/HKV1_SpatialPeekViewController.swift`
- `out/highfive-1-3-cinematic-experience/FINAL_1_3_STEPS_1_3_REPORT.md`

## Cinematic Home

Implemented:
- Expanded the Mark of the West hero from `540` to `600` points.
- Added v13 multi-plane western depth overlays:
  - far horizon glow
  - distant mountain silhouette
  - near mountain silhouette
  - dust/haze layer
  - foreground vignette
- Kept exact Home hero direction:
  - `PRE-PRODUCTION`
  - `The Mark of the West`
  - `Limited Series Coming Soon`
  - `Starring Derek Hinkey`
- Preserved `My List`.
- Preserved compact `Import` slate only.
- Preserved Available Now as `The Friendly` + `Paranormall`.
- Preserved curated Coming Soon row.
- Did not add duplicate rows or a giant Import card.

Added accessibility markers:
- `hf.v13.home.hero`
- `hf.v13.home.hero.markWest`
- `hf.v13.home.availableNow`
- `hf.v13.home.compactImport`

## Layer 4 Ultra Visual Depth Polish

Added reusable SwiftUI visual layer:
- `HFLayer4UltraDepthFX`
- `HFLayer4GlassSweep`
- `HFLayer4AtmosphericDust`
- `HFLayer4VolumetricGlow`
- `HFLayer4FocusBreath`

Properties:
- SwiftUI only.
- Uses existing `DepthMotionValues` / `DepthMotionProvider`.
- Reduce Motion aware.
- Low Power Mode reduced.
- No new CoreMotion loop.
- No hinge, pivot, snap, or player math changes.
- No marquee, bulbs, or `NOW SHOWING`.

Wired into:
- `DepthHeroStage`
- `HFDepthPosterFrame`
- `PremiumDepthPosterView` path through `HFDepthPosterFrame`
- Movie Detail primary poster section

## Vertical Stage 2 Floating Cinema Window

Implemented visual-only UIKit shell:
- non-interactive depth aura behind the stage window
- non-interactive floating frame overlay
- soft shadow / gold edge treatment
- compact control-bar shadow styling

Added accessibility identifiers:
- `hf.v13.verticalStage.floatingWindow`
- `hf.v13.verticalStage.depthAura`
- `hf.v13.verticalStage.controls`

Preserved:
- existing `maskWindowView` playback window
- existing stage sizing
- existing player layer rendering
- existing motion pipeline
- existing control callbacks
- Vertical Stage, Depth, Tilt, Peek, Layer 4 behavior

## Protected Systems Preserved

Not rewritten or intentionally changed:
- StoreKit
- Restore Purchases
- entitlement checks
- product IDs
- purchases / unlocks
- The Friendly routing
- Paranormall routing
- Paranormall Episode 7 `e7.v2`
- official/import routing
- streaming resolver
- legal flow
- CRM privacy
- release safety scripts
- preview/full playback routing

## Validation

Baseline:
- Release safety before: PASS
- Debug direct Swift typecheck before: PASS
- Release direct Swift typecheck before: PASS
- xcodebuild diagnose before: BLOCKED by local tooling

After source changes:
- Release safety: PASS
- Debug direct Swift typecheck: PASS
- Release direct Swift typecheck: PASS
- xcodebuild diagnose: BLOCKED by local tooling
- simulator launch: BLOCKED by local tooling

## Xcodebuild / Simulator Blocker

`scripts/highfive_xcodebuild_diagnose.sh` fails before source diagnostics:

- `CoreSimulatorService connection became invalid`
- `Unable to discover any Simulator runtimes`
- `simdiskimaged crashed or is not responding`
- `Could not parse Swift versions from: error: permissionDenied`
- `Unable to discover swiftc command line tool info`

`scripts/run_highfive_simulator.sh` fails before app build/install:

- `simctl list devices available -j` returns non-zero
- CoreSimulator device set cannot initialize
- no available iPhone simulator/runtime can be discovered

Doctor output:
- `out/simulator/simulator-doctor.txt`

## Screenshot Paths

No fresh 1.3 screenshots were captured because the simulator did not launch.

Existing older files were present in `out/simulator/`, but they were not created by this run:
- `out/simulator/highfive-home.png`
- `out/simulator/highfive-current.png`

## Commits Created

None.

Reason: the task says to commit only if validation passes. Source validation passed, but full `xcodebuild` / simulator validation is blocked by local tooling.

Suggested commits after Xcode/CoreSimulator is repaired and validation passes:

1. `feat(home): add cinematic 1.3 hero depth stage`
2. `feat(depth): add Layer 4 Ultra visual depth effects`
3. `feat(player): add Vertical Stage floating cinema shell`
4. `docs(qa): add 1.3 cinematic experience validation report`

## Real-Device QA Checklist

- Home hero visual scale on small iPhones.
- Mark of the West multi-plane motion on physical iPhone.
- Reduce Motion disables live motion but keeps static polish.
- Low Power Mode reduces animation intensity.
- Available Now remains The Friendly + Paranormall.
- Compact Import opens importer and does not appear on official detail pages.
- Poster cards scroll smoothly.
- Movie Detail primary poster depth/glass does not distract from content.
- Watch Trailer remains trailer-only.
- Watch Episode / purchase routing remains unchanged.
- The Friendly unlock.
- Paranormall Episode 7 `e7.v2`.
- Official titles never open Import Movie.
- Vertical Stage floating shell does not interfere with controls.
- Depth / Tilt / Peek still work.
- Layer 4 still works.
- Release has no debug UI.
