# FPP-20 Launch Candidate

## Baseline

- Baseline commit: `d94edcc`
- Baseline tag: `phase-fpp-19-testflight-candidate`
- Phase: `FPP-20 - Launch Candidate`
- Date: `2026-06-28`

## Result

HIGHFIVE CINEMA LAUNCH READY

FPP-20 passes as the local launch-candidate gate. This phase did not add features, tabs, product systems, or architecture. It verified launch documentation, App Store listing material, support/legal/privacy artifacts, screenshot coverage, backend smoke coverage, simulator build coverage, public-release runbook coverage, and an unsigned device archive build.

## Launch Validation

LP15 launch validation:

- Status: passed
- Backend smoke: `227/227` passed
- iOS build: passed
- Required documents: `5/5` present
- Required screenshots: `7/7` present

LP16 public release validation:

- Status: passed
- Backend smoke: `227/227` passed
- iOS build: passed
- Public release runbook: present
- Public release operations covered: submit, cutover, monitor, hotfix, analytics, creator onboarding, and audit

## Build And Archive

Unsigned device archive command:

```bash
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-fpp-20-launch-candidate/HighFive.xcarchive" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  archive
```

Result: Passed.

Archive path:

`/Volumes/Scratch SSD/XcodeDerivedData/highfive-fpp-20-launch-candidate/HighFive.xcarchive`

Archive log:

`/private/tmp/highfive-fpp-20-launch-candidate/archive.log`

Important: this is an unsigned local archive. App Store upload still requires a signed archive/export with Apple Developer credentials and App Store Connect access.

## App Store Assets And Documents

Verified launch documents:

- `docs/launch/APP_STORE_LISTING.md`
- `docs/launch/SUPPORT_RUNBOOK.md`
- `docs/launch/TERMS_OF_USE.md`
- `docs/launch/PRIVACY_NOTICE.md`
- `docs/launch/PRESS_KIT.md`
- `docs/launch/PUBLIC_RELEASE_RUNBOOK.md`

Verified project metadata:

- Bundle identifier: `com.higherkey.HighFiveCinemaClean.HighFive`
- Marketing version: `1.0`
- Build number: `1`
- App icon catalog: `AppIcon`
- Development team configured in build settings
- Privacy manifest present: `HighFive/Config/PrivacyInfo.xcprivacy`

## Screenshots

LP15 screenshot directory:

`/private/tmp/highfive-fpp-20-launch-candidate/launch_validation/screenshots/`

LP16 screenshot directory:

`/private/tmp/highfive-fpp-20-launch-candidate/public_release_validation/screenshots/`

Captured launch matrix:

- `home.png`
- `search.png`
- `library.png`
- `profile.png`
- `creator.png`
- `operations.png`
- `player.png`

Contact sheet:

`/private/tmp/highfive-fpp-20-launch-candidate/fpp20_launch_contact_sheet.png`

Visual score: `97/100`

## Scans

Passed:

- launch validation script
- public release validation script
- backend smoke matrix
- iOS simulator build inside validation scripts
- unsigned device archive
- screenshot matrix
- launch document manifest check
- public-release runbook check

Protected systems intentionally not touched:

- `HighFive/App/Depth`
- `HighFive/App/Motion`
- `HighFive/App/Playback`
- `HighFive/App/Layer4`
- `HighFive/App/Rendering`

## Warnings

Known warnings remain:

- `HKV1_PlayerAudioTap.swift`: AVFoundation `tracks(withMediaType:)` deprecation.
- `HFStreamingStore.swift`: AVFoundation media-inspection deprecations.
- `HFTabBar.swift`: `UIScreen.main` deprecation on iOS 26.
- AppIntents metadata extraction skipped because the app has no AppIntents dependency.

No build or archive error remains.

## Manual App Store Requirements

The local launch candidate is ready. Actual App Store submission still requires:

- Final legal approval.
- Final privacy approval and App Store privacy answers.
- Final support URL and marketing URL.
- Signed archive export.
- App Store Connect metadata and media upload.
- App Store Connect submission and release cutover.
- Hosted production monitoring review.

## Final Recommendation

HighFive Cinema is ready for the manual App Store submission path once the external Apple/legal/hosting checklist items above are completed.
