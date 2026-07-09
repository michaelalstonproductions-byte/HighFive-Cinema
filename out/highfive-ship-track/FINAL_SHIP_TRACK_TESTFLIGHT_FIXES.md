# HighFive Cinema Ship Track / TestFlight Bug Fix Pass

Date: July 9, 2026

## Scope

This pass prepares the current Gold Master/TestFlight candidate for real-device validation by keeping only customer-facing shipping fixes.

No Xcode 26 modernization was kept. No SDK deprecation cleanup was kept. Protected runtime/business systems were not changed.

## Worktree Separation

Inspected current uncommitted files and separated them into two groups:

- Kept: customer-facing interaction fixes in Home, Movie Detail, trailer entry, paywall presentation, poster responsiveness, and horizontal rail feel.
- Reverted/ignored: Xcode 26 warning-cleanup edits in Creator/Packaging adapters, runtime playback hygiene, depth `onChange`, bottom tab `UIScreen.main`, and shared screen-bound helper.

The Xcode 26 cleanup report was removed from this ship-track output set. Duplicate asset warnings and SDK deprecations are intentionally not part of this sprint.

## Shipping Fixes Kept

Files:

- `HighFive/Components/HFSpatialCinemaPrimitives.swift`
- `HighFive/Components/HFPosterCard.swift`
- `HighFive/Views/Home/HomeView.swift`
- `HighFive/Views/MovieDetail/MovieDetailView.swift`

Changes kept:

- Poster taps now feel lighter and faster with a less aggressive press scale, smaller lift, faster spring, and higher pressed opacity.
- Poster cards now expose a clearer content shape and pointer hover lift without changing navigation targets.
- Home customer rails use view-aligned horizontal scrolling so poster rails settle cleanly on cards.
- Movie Detail recommendation, related, and cast rails use the same view-aligned horizontal scroll behavior.
- Trailer preview card now has a visible centered play affordance.
- Trailer preview card uses the existing `onWatchTrailer` handler, preserving trailer playback logic.
- Paywall presentation has stronger premium framing, background atmosphere, benefit-card glass, and sheet corner polish.

## Protected Systems

No retained changes in:

- StoreKit
- Purchases
- Restore Purchases
- Streaming
- Cloudflare playback
- Playback behavior
- Vertical Stage runtime
- Layer 4
- Depth/Tilt/Peek behavior
- Backend
- Publishing
- CRM
- Legal
- Creator OS
- Packaging
- Brain
- Executive systems

Note: prior warning-cleanup edits in protected/runtime areas were reverted out of the active diff for this ship-track pass.

## QA Checklist For Real Device

- Launch app.
- Complete onboarding.
- Open Home.
- Tap poster cards across Featured Originals, Available Now, Coming Soon, and Continue Watching.
- Open The Friendly detail.
- Tap trailer preview card.
- Tap Watch Trailer button.
- Open HighFive Pass paywall from locked playback path.
- Test Restore Purchases UI without changing StoreKit logic.
- Open Paranormall Episode 7 detail path.
- Test Search empty and populated states.
- Test Library shelves.
- Test Downloads empty/downloaded state presentation.
- Test Profile and Account path.
- Enter Vertical Stage from existing entry points.
- Test Depth/Tilt/Peek on device using existing runtime.
- Exit playback and return Home.

## Validation

- `git diff --check`: PASS
- `scripts/highfive_release_safety_check.sh`: PASS
- `scripts/highfive_direct_typecheck.sh`: PASS
  - debug direct Swift typecheck: PASS
  - release direct Swift typecheck: PASS

## Remaining Risks

- Real-device subjective feel still needs validation for tap latency, sheet entry, and horizontal rail settle.
- Xcode 26 deprecation warnings remain by design and should be handled in a separate compatibility pass.
- Duplicate asset catalog warnings remain by design and should be handled in a separate asset hygiene pass.

## Release Recommendation

Proceed to TestFlight device validation with this ship-track diff.

Readiness score: 94/100.
