# HighFive Cinema 6.0 - Gold Master Preparation

## Scope

Gold Master preparation focused on production-quality refinement of the customer streaming app only: Launch, Onboarding, Home, Movie Detail, Trailer, Search, Library, Downloads, Profile, Continue Watching, Recommendations, Purchase UI, and Restore Purchases.

No protected architecture or runtime systems were modified: StoreKit, streaming, Cloudflare playback, playback runtime, Vertical Stage runtime, Layer 4, Depth/Tilt/Peek, backend, publishing, CRM, legal, Creator OS, Packaging Studio, HigherKey Brain, Mission Planner, Workflow Automation, Execution Tracking, and Executive Command were left untouched.

## Issues Fixed

- Movie Detail paywall purchase and restore buttons now expose clearer accessibility values for ready, purchase in-progress, and restore in-progress states.
- Movie Detail paywall purchase and restore buttons now visually dim during disabled/in-progress states without changing purchase, restore, StoreKit, or entitlement behavior.

## Remaining Known Issues

- Real-device/TestFlight validation is still required for StoreKit sheet presentation, sandbox purchase interruption handling, Restore Purchases result copy, trailer preview, streaming access, playback exit, and return-home behavior.
- Simulator build is currently blocked by local CoreSimulator instability, not by Swift compilation. The build attempt failed after `CoreSimulatorService connection became invalid` and storyboard compilation reported `iOS 26.2 Platform Not Installed`.
- Existing duplicate asset catalog warnings observed in prior simulator attempts remain outside this GM change because they were not part of the customer-facing app-flow fix set.
- Pre-existing untracked 4.2 simulator workflow files remain outside the GM change set.

## Must-Fix Before App Store

- Run a signed Release/TestFlight build on physical iPhone hardware.
- Verify StoreKit purchase and restore flows with sandbox Apple IDs.
- Confirm debug-only unlock UI is absent in Release/TestFlight.
- Verify legal/privacy/support links from Profile on device.
- Verify official titles never expose Import as a playback path.
- Confirm trailer preview and full playback close cleanly back to Movie Detail and Home.
- Confirm app metadata, screenshots, privacy nutrition labels, age rating, and in-app purchase metadata are aligned in App Store Connect.

## Nice-To-Have After Launch

- Add automated UI screenshots for the full GM customer journey.
- Clean duplicate asset catalog names if they continue to produce release-noisy warnings.
- Add a dedicated signed-device smoke checklist script that records bundle id, build number, install result, launch result, and screenshot paths.
- Expand accessibility audit coverage for larger Dynamic Type and VoiceOver rotor order across Movie Detail and Profile.

## Device Testing Checklist

- Clean install on a physical iPhone.
- Upgrade install over the previous TestFlight build.
- First launch and onboarding completion.
- Home hero, Continue Watching empty/populated states, recommendations, Featured Originals, Available Now, and Coming Soon.
- Movie Detail for The Friendly and Paranormall, including trailer preview and locked/unlocked states.
- Purchase UI for locked movie, season, and episode access.
- Restore Purchases from Profile > Account and paywall.
- Search suggestions, recent searches, empty results, and result navigation.
- Library empty state, shelves, Continue Watching, Favorites, Purchased, Downloaded, and Watch Later.
- Downloads empty state and local preview state.
- Profile account, help/support, legal/support links, profile management, and internal QA tools remaining under Profile only.
- Playback exit and return Home.
- VoiceOver and larger Dynamic Type pass on Home, Movie Detail, Search, Library, Downloads, and Profile.

## App Store Submission Checklist

- Confirm bundle identifier: `com.higherkey.HigherKeySpatialPeek-Rebuild`.
- Confirm signing team, provisioning profile, and Release configuration.
- Confirm build number and marketing version for 6.0.
- Confirm StoreKit products are approved or correctly staged for TestFlight.
- Confirm Restore Purchases copy and support path.
- Confirm privacy manifest and App Store privacy answers.
- Confirm support URL, privacy policy URL, copyright, category, rating, and review notes.
- Attach review account/sandbox instructions if Apple needs purchase validation.
- Submit with device screenshots that match current UI.

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
  -derivedDataPath "/private/tmp/highfive-GM-build" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Observed simulator failure:

- `CoreSimulatorService connection became invalid`
- `Unable to discover any Simulator runtimes`
- `simdiskimaged crashed or is not responding`
- `HighFive/App/Launch/LaunchScreen.storyboard: error: iOS 26.2 Platform Not Installed`
- Failure occurred during `CompileStoryboard`

## Final Release Readiness Score

90 / 100

The app is GM-candidate ready from a source-validation and customer-facing polish standpoint. The remaining 10 points require signed physical-device/TestFlight verification of StoreKit, restore, trailer, streaming, playback exit, legal/support links, and final App Store metadata.
