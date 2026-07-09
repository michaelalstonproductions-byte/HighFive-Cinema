# HighFive Cinema Regression Fix Report

Date: July 9, 2026

## Scope

This sprint restored customer-facing TestFlight behavior only.

No new systems were added. No redesign was performed. StoreKit, purchase logic, streaming engine, Cloudflare, playback engine, Vertical Stage runtime, Layer 4, Depth/Tilt/Peek, backend, CRM, legal, Creator OS, Packaging, Brain, and Executive systems were not modified.

## Issues Addressed

- Poster taps could fail or feel blocked after the recent ship-track interaction changes.
- Home horizontal rails could freeze or stall after recent view-aligned scroll targeting was added across nested poster rails.
- The Mark of the West hero used generic consumer snapshot copy, which could surface Paranormall-flavored text under the Mark hero.
- Trailer preview sheet playback needed a more explicit autoplay start path.
- Trailer, paywall, and poster responsiveness needed to stay on the current safe handlers without changing StoreKit or playback engines.

## Fixes

Files changed:

- `HighFive/Components/HFPosterCard.swift`
- `HighFive/Views/Home/HomeView.swift`
- `HighFive/Views/MovieDetail/MovieDetailView.swift`

Changes:

- Restored the poster card hit surface to the prior stable behavior by removing the recent card-level `contentShape` and hover lift additions.
- Preserved the lighter poster press animation tokens from the ship-track pass.
- Removed recent `.scrollTargetLayout()` and `.scrollTargetBehavior(.viewAligned)` modifiers from Home and Movie Detail horizontal rails to avoid scroll stalls/freezes.
- Pinned the Mark of the West hero eyebrow/detail copy to `HFLocalProjectStore.project(.markOfTheWest)` instead of generic consumer snapshot hero copy.
- Kept Home rail data mapping for The Friendly and Paranormall through existing catalog IDs:
  - `friendly`
  - `paranormall-s1`
- Made trailer sheet autoplay startup explicit:
  - initializes the trailer `AVPlayer` muted
  - seeks to `.zero` on appear
  - calls `play()` on appear
  - loops on `AVPlayerItemDidPlayToEndTime`
- Preserved the existing `onWatchTrailer` handler and `activeTrailerPreview` sheet path.
- Preserved the existing HighFive Pass paywall presentation and did not touch purchase or restore logic.
- Confirmed the IMDb-style title/credit/info areas still exist:
  - `compactTitleInfoBlock`
  - `synopsisBlock`
  - `creditsBlock`
  - `cinematicMetadataPanel`

## Protected Systems

No changes were made in protected or excluded systems:

- StoreKit / purchases / restore purchases
- Streaming engine
- Cloudflare playback
- Playback engine
- Vertical Stage runtime
- Layer 4
- Depth / Tilt / Peek
- Backend
- CRM
- Legal
- Creator OS
- Packaging
- Brain
- Executive systems

## Validation

- `scripts/highfive_release_safety_check.sh`: PASS
- `scripts/highfive_direct_typecheck.sh`: PASS
  - debug direct Swift typecheck: PASS
  - release direct Swift typecheck: PASS
- `git diff --check`: PASS

## Simulator Run

Simulator requested and attempted.

Steps attempted:

- Booted iPhone 17 Pro simulator `8F38D793-C7B8-4512-AB2D-834677A057AD`: PASS
- Attempted Debug simulator build/install path: BLOCKED

Simulator blocker:

- `xcodebuild` and `ibtool` lost `CoreSimulatorService` connectivity.
- Retry with `/private/tmp` derived data reached build execution but failed compiling `HighFive/App/Launch/LaunchScreen.storyboard` with:
  - `iOS 26.2 Platform Not Installed`
- Because the simulator build did not complete, install and app launch could not be completed in this environment.

## Commit Status

Requested commits:

- `fix(app): restore trailer poster navigation and home data integrity`
- `docs(qa): add regression fix report`

Commit attempt was blocked by the local sandbox because `.git/index.lock` could not be created:

- `fatal: Unable to create '.git/index.lock': Operation not permitted`

The intended source and report changes remain in the working tree.

## Remaining Risks

- Real-device/TestFlight validation is still required for trailer autoplay, poster tap latency, paywall sheet entry, and Home scroll behavior.
- Xcode 26 warnings and SDK deprecations remain intentionally untouched.
- Simulator validation is blocked by local Xcode/CoreSimulator runtime availability, not by the regression source changes.

## Recommendation

Proceed to real-device TestFlight validation with this regression-fix diff.
