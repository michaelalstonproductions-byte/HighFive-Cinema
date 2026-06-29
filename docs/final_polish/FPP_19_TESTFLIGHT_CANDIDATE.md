# FPP-19 TestFlight Candidate

## Baseline

- Baseline commit: `4d537ab`
- Baseline tag: `phase-fpp-18-bug-hunt`
- Phase: `FPP-19 - TestFlight Candidate`
- Date: `2026-06-28`

## Result

FPP-19 passes as a simulator-validated TestFlight candidate handoff.

This phase did not add product systems, tabs, or architecture. It performed candidate validation across Debug and Release simulator builds, refreshed the screenshot regression matrix, and fixed one candidate-blocking QA route issue where fresh simulator installs could show onboarding instead of the requested launch route during screenshot automation.

## Implementation

- Updated the root SwiftUI launch gate so route QA launches that should skip onboarding also persist the completed onboarding state on appear.
- Preserved first-run onboarding for normal app launches.
- Preserved the locked five-tab shell: Home, Search, Library, Downloads, Profile.
- Added candidate documentation for build, screenshot, scan, and signing status.

## Builds

Debug simulator build:

```bash
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-fpp-19-testflight-candidate" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Result: Passed.

Release simulator build:

```bash
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-fpp-19-testflight-candidate-release" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Result: Passed.

## Tests

- Xcode scheme inspection shows only the `HighFive` target and `HighFive` scheme are present.
- No dedicated unit-test target is available in the project for this phase.
- Candidate validation used Debug build, Release build, deterministic simulator launch routes, screenshot regression, visual inspection, and safety scans.

## Screenshots

Screenshot directory:

`/private/tmp/highfive-fpp-19-testflight-candidate/screenshots/`

Captured:

- `home.png`
- `search.png`
- `library.png`
- `downloads.png`
- `profile.png`
- `movie_detail.png`
- `player.png`
- `membership.png`
- `creator_studio.png`
- `enterprise_polish.png`

Contact sheet:

`/private/tmp/highfive-fpp-19-testflight-candidate/fpp19_contact_sheet.png`

Visual result: `96/100`

Notes:

- All route screenshots render real app surfaces after onboarding completion is seeded for screenshot automation.
- Five bottom tabs remain visible where expected.
- No blank route screenshots were accepted.
- No major clipping, route-tab regression, or protected-system visual regression was observed in the matrix.

## Scans

Passed:

- `git diff --check`
- Protected path scan
- `project.pbxproj` untouched scan
- Unsafe diff scan for Calendar/EventKit/WebSocket/payment/secret/file-write/repeat animation/tab additions
- Manual screenshot review

Protected paths intentionally not touched:

- `HighFive/App/Depth`
- `HighFive/App/Motion`
- `HighFive/App/Playback`
- `HighFive/App/Layer4`
- `HighFive/App/Rendering`

## Warnings

Remaining build warnings are known deprecation/tooling warnings:

- `HKV1_PlayerAudioTap.swift`: `tracks(withMediaType:)` deprecation.
- `HFStreamingStore.swift`: AVFoundation media inspection deprecations around `duration`, tracks, natural size, preferred transform, frame rate, and format descriptions.
- `HFTabBar.swift`: `UIScreen.main` deprecation on iOS 26.
- AppIntents metadata extraction warning because no AppIntents framework dependency exists.

No build error remains.

## TestFlight Readiness

Simulator candidate: Passed.

Real TestFlight upload status: Not exported in this environment.

Manual setup still required for a real TestFlight upload:

- Apple Developer signing identity.
- Provisioning profile.
- App Store Connect application configuration.
- Production bundle/capability verification.
- Archive/export or CI upload step.

## Recommendation

Proceed to `FPP-20 - Launch Candidate`.
