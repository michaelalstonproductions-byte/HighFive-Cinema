# HighFive Cinema 3.6 SwiftUI Modular Cleanup

Date: July 8, 2026

## Scope

Performed a low-risk modular cleanup pass on the largest SwiftUI surfaces without changing behavior, navigation, engines, playback, StoreKit, publishing, backend, or protected depth systems.

Targeted files:

- `HighFive/App/HFStreamingRootView.swift`
- `HighFive/Views/MovieDetail/MovieDetailView.swift`

`CreatorStudioView.swift` was audited but not edited in this pass. Its size makes it a strong future cleanup candidate, but safe decomposition requires a larger planned split than this low-risk phase should attempt.

## Cleanup Performed

### HFStreamingRootView

Extracted repeated local command/Brain presentation helpers into private subviews:

- `HFCommandMetricCardView`
- `HFCommandInsightCardView`
- `HFBrainSignalRowView`

Existing helper methods remain in place:

- `commandMetricCard(_:)`
- `insightCard(_:_:_:_:)`
- `brainSignalRow(title:detail:status:systemImage:accent:)`

This keeps all call sites stable while moving repeated rendering bodies out of the main `HFHighFiveOSView` implementation.

### MovieDetailView

Extracted the cinematic metadata metric tile into:

- `HFCinematicMetadataMetricTile`

The existing `movieDetailMetric(_:value:systemImage:accent:)` wrapper remains in place so call sites and visual output are unchanged.

## Behavior Boundary

No changes were made to:

- StoreKit
- Streaming
- Purchases
- Restore Purchases
- Entitlements
- Playback
- Vertical Stage runtime
- Layer 4
- Depth/Tilt/Peek
- Legal
- CRM
- Backend
- Upload
- Publishing
- Media export/rendering
- Existing intelligence engines

No navigation behavior changed. No product layer was added.

## Duplicate Helper Findings

Confirmed recurring helper patterns remain for future cleanup:

- Card, row, and metric helper functions are repeated across `HFStreamingRootView`, `MovieDetailView`, and `CreatorStudioView`.
- `CreatorStudioView.swift` remains the largest SwiftUI risk area and should be split by domain in a dedicated phase.
- `MovieDetailView.swift` still mixes title detail, player, paywall/access surfaces, and Vertical Stage presentation.

## Validation

Passed:

- `scripts/highfive_release_safety_check.sh`
- `scripts/highfive_direct_typecheck.sh`
- `git diff --check`
- Protected subsystem diff check returned no changes.

Simulator build attempted:

```bash
TMPDIR="/private/tmp" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/private/tmp/highfive-codex-check-36" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Result: failed due local simulator environment/tooling, not direct Swift typecheck failures.

Observed blockers:

- CoreSimulatorService connection invalid.
- No available simulator runtimes for `iphonesimulator`.
- Storyboard and asset catalog compilation failed through simulator tooling.

## Result

The cleanup reduced body complexity in two high-traffic SwiftUI surfaces by moving repeated visual helper implementations into private local subviews while preserving visual output, navigation, and runtime behavior.
