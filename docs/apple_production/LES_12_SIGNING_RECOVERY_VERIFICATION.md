# LES-12 Signing Recovery Verification

Date: 2026-06-29

Baseline:
- Start tag: `phase-les-07-accessibility-audit`
- Start commit: `f415b5e`
- Working tree before phase: clean

Actions:
- Checked Xcode project signing settings for scheme `HighFive`.
- Moved stale unreadable provisioning profile out of Xcode's profile folder:
  - From: `/Users/michaelalston/Library/Developer/Xcode/UserData/Provisioning Profiles/d0d14310-2774-4c8b-86bc-dccf70eb92e1.mobileprovision`
  - To: `/private/tmp/highfive_stale_provisioning_d0d14310-2774-4c8b-86bc-dccf70eb92e1.mobileprovision`
- Ran signed Release archive with `-allowProvisioningUpdates`.
- Exported App Store Connect IPA with `HighFive/Config/ExportOptions.AppStore.example.plist`.

Archive command:

```bash
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Release \
  -destination generic/platform=iOS \
  -archivePath /private/tmp/highfive-les-12-signing-recovery/HighFive.xcarchive \
  -derivedDataPath /private/tmp/highfive-les-12-signing-recovery/DerivedData \
  -allowProvisioningUpdates \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  archive
```

Archive result:

```text
** ARCHIVE SUCCEEDED **
```

Export command:

```bash
xcodebuild -exportArchive \
  -archivePath /private/tmp/highfive-les-12-signing-recovery/HighFive.xcarchive \
  -exportPath /private/tmp/highfive-les-12-signing-recovery/export \
  -exportOptionsPlist HighFive/Config/ExportOptions.AppStore.example.plist \
  -allowProvisioningUpdates
```

Export result:

```text
Exported HighFive to: /tmp/highfive-les-12-signing-recovery/export
** EXPORT SUCCEEDED **
```

Export proof:
- IPA: `/private/tmp/highfive-les-12-signing-recovery/export/HighFive.ipa`
- IPA size: 42 MB
- Distribution summary: `/private/tmp/highfive-les-12-signing-recovery/export/DistributionSummary.plist`
- Packaging log: `/private/tmp/highfive-les-12-signing-recovery/export/Packaging.log`

Distribution summary:
- Version: `1.0`
- Build number: `1`
- Team ID: `4N9QF424Z8`
- Bundle identifier: `com.higherkey.HighFiveCinemaClean.HighFive`
- Certificate: `Cloud Managed Apple Distribution`
- Provisioning profile: `iOS Team Store Provisioning Profile: com.higherkey.HighFiveCinemaClean.HighFive`
- Provisioning profile UUID: `5c743c4e-00d1-4476-ae72-1d550f2047da`
- `aps-environment`: `production`
- `com.apple.developer.applesignin`: `Default`
- `get-task-allow`: `0`
- `beta-reports-active`: `1`

Result:

LES-12 is complete. Signed archive and App Store Connect IPA export both succeeded.

Warnings remaining:
- `HKV1_PlayerAudioTap.swift` uses deprecated `tracks(withMediaType:)`.
- `HFTabBar.swift` uses deprecated `UIScreen.main` on iOS 26.
- `HFStreamingStore.swift` uses several deprecated AVAsset/AVAssetTrack synchronous properties.
- AppIntents metadata extraction was skipped because no AppIntents dependency was found.

Protected systems:

No protected Depth, Motion, Playback, Rendering, or Layer 4 source paths were modified.
