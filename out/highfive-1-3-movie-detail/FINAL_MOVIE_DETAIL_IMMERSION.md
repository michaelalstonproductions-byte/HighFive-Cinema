# HighFive Cinema 1.3 Step 4 — Movie Detail Immersion

## Verdict

Movie Detail visual immersion pass completed. Source validation passed. Simulator validation was not required for this commit gate.

## Files Changed

- `HighFive/Views/MovieDetail/MovieDetailView.swift`

## What Changed

- Upgraded the primary poster scene with the existing depth poster, atmosphere, glow, shadow plane, and Layer 4 Ultra visual effects.
- Replaced the inline autoplay trailer surface with a non-autoplay premium floating trailer preview button.
- Rebuilt the compact metadata stack around title, year/rating/runtime, genre pills, director, cast, companies, synopsis, and rating capsules.
- Added cinematic horizontal cast cards with glass edge, soft shadow, and subtle depth motion.
- Reworked Paranormall episode rows into floating glass cards while preserving existing episode action callbacks and StoreKit routing.
- Kept the More Like This rail using the existing premium poster card system.
- Added a subtle Movie Detail background atmosphere using the existing `DepthMotionProvider` and visual FX only.

## Accessibility

Added or preserved:

- `hf.v13.detail.hero`
- `hf.v13.detail.trailer`
- `hf.v13.detail.cast`
- `hf.v13.detail.episodes`
- `hf.v13.detail.recommendations`
- Existing `hf.titleDetail.*` identifiers remain available.

## Validation

- Release safety: PASS
- Debug direct Swift typecheck: PASS
- Release direct Swift typecheck: PASS

## Preserved

- StoreKit product IDs
- Restore Purchases
- entitlement verification
- purchase routing
- official/import routing
- streaming resolver
- Layer 4 math
- Vertical Stage playback
- Depth/Tilt/Peek runtime
- CRM privacy
- legal flow
- release safety scripts
- Paranormall Episode 7 `e7.v2`
- trailer-only preview rules

## QA Checklist

- Verify Movie Detail poster feels like a floating cinematic object.
- Verify trailer card does not autoplay and opens trailer only when tapped.
- Verify metadata order reads clearly on compact iPhone.
- Verify cast cards scroll horizontally and do not crowd the page.
- Verify Paranormall episode watch/purchase buttons keep existing behavior.
- Verify More Like This still opens title detail pages.
- Verify Reduce Motion keeps visual polish without distracting motion.
- Verify The Friendly purchase/watch routing.
- Verify Paranormall Episode 7 `e7.v2` routing.
- Verify official titles never open Import Movie.
- Verify Vertical Stage, Depth, Tilt, Peek, and Layer 4 still work on device.
