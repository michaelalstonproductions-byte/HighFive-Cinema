# HighFive Cinema 4.1 Release Candidate Report

## Scope

HighFive Cinema 4.1 was stabilized for real-device and TestFlight QA without adding a new product layer.

Implemented scope:
- Added a Profile-only internal Release Candidate QA checklist.
- Kept consumer tabs locked to Home, Search, Library, Downloads, and Profile.
- Added manual QA coverage for onboarding, Home, Movie Detail, Search, Library, Downloads, Profile, purchases, Restore Purchases, The Friendly unlock, Paranormall Episode 7 e7.v2, trailer-only previews, official titles never opening Import, Vertical Stage, Depth/Tilt/Peek, Layer 4, and no debug UI in Release.

## Protected Systems

No protected runtime systems were intentionally modified.

Protected areas left untouched:
- StoreKit runtime implementation
- Streaming runtime implementation
- Playback
- Vertical Stage
- Layer 4
- Depth/Tilt/Peek
- Backend
- CRM
- Legal
- Rendering
- Publishing
- Intelligence engines

## Files Changed

- `HighFive/Views/Profile/HFProfileDestination.swift`
- `HighFive/Views/Profile/ProfileView.swift`
- `HighFive/Views/Profile/HFReleaseCandidateQAChecklistView.swift`
- `out/highfive-4-1-release-candidate/FINAL_RELEASE_CANDIDATE_4_1.md`

## Validation

- `scripts/highfive_release_safety_check.sh`: PASS
- `scripts/highfive_direct_typecheck.sh`: PASS
- `git diff --check`: PASS
- `xcodebuild` Debug simulator build: BLOCKED by local Xcode/CoreSimulator environment before app compilation.

Simulator build command attempted:

```bash
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-codex-check" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Retry used writable derived data at `/private/tmp/highfive-codex-check`, but Xcode still failed before app compilation while discovering simulator/toolchain metadata.

## Remaining Warnings

- CoreSimulatorService reported `connection became invalid` and `connection refused` during `xcodebuild`.
- Xcode reported `Unable to discover swiftc command line tool info: Could not parse Swift versions from: error: permissionDenied`.
- Several pre-existing deprecation warnings were observed during the first direct typecheck attempt in protected playback/resource/data files; those protected systems were not changed.
- Commit was attempted but blocked by local filesystem permissions: Git could not create `.git/index.lock`.
