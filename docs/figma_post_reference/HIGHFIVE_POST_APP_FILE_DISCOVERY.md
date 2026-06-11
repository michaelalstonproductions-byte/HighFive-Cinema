# HighFive Post — App File Discovery

## Purpose

This doc records whether HighFive Post app files were found before implementation begins. The goal is to avoid building HighFive Post UI inside the wrong project or from guessed source ownership.

## Baseline

- Repo path: `/Volumes/Scratch SSD/HighFive-Cinema-clean`
- Latest commit: `984a7db` — `Docs HighFive Post frame intake checklist`
- Working tree status at start: clean
- Current docs state:
  - Figma source file is accessible.
  - Starting node `3:286` is accessible and verified as `Video editor / NLE`.
  - `Video editor / NLE` is classified as `SECONDARY_STYLE_REFERENCE`.
  - Global Shell and Edit Workspace can use that node only as mood/layout reference.
  - Review Home, Media Pool, Audio Workspace, Color Room, AI Copilot, and Export / Diagnostics still need verified production frames.
  - Current build readiness says implementation should wait until direct production frames and a real Post app target are confirmed.

## Current Repo Search

| Candidate | Path | Evidence | Classification | Confidence | Notes |
| --- | --- | --- | --- | --- | --- |
| HighFive Cinema iOS project | `/Volumes/Scratch SSD/HighFive-Cinema-clean/HighFive.xcodeproj` | Primary Xcode project in this repo. App source is under `HighFive/` and matches the Cinema iOS app. | CINEMA_REFERENCE_ONLY | High | This is the active Cinema repo, not a dedicated HighFive Post app target. |
| Streaming shell/design system | `HighFive/App/HFStreamingRootView.swift`, `HighFive/DesignSystem/*`, `HighFive/Components/*` | SwiftUI streaming shell, design tokens, and reusable iOS components. | CINEMA_REFERENCE_ONLY | High | Useful style references only if a future approved isolated Post UI area is created here. |
| Creator preview surfaces | `HighFive/Views/Creator/*` | Creator package, asset manager, review, release, and workflow preview screens. | CINEMA_REFERENCE_ONLY | Medium | Loose conceptual overlap with review/media workflows, but not HighFive Post app files. |
| Release/diagnostics references | `HighFive/Views/Release/*`, `HighFive/Data/HFPosterAssetHealth.swift` | QA, release readiness, route matrix, and asset-health concepts. | CINEMA_REFERENCE_ONLY | Medium | Related diagnostic vocabulary, not Post export/diagnostics implementation. |
| Protected legacy media/playback | `HighFive/App/Playback/*`, `HighFive/App/UI/*`, `HighFive/App/Resources/*Audio*` | Playback, control bar, audio tap, and spatial media code found by timeline/audio/search terms. | PROTECTED_LEGACY_MEDIA | High | Not a Post UI target. Do not touch for Post UI work unless explicitly scoped. |
| Existing Post docs | `docs/figma_post_reference/*` | Figma reference, frame requests, readiness docs, and this audit. | NEEDS_CLARIFICATION | High | Documentation only; not app implementation source. |
| Profile-room workflow code | `HighFive/Views/Profile/ProfileView.swift` | Search terms hit local room workflows, timelines, export/readiness copy, and product-suite preview text. | CINEMA_REFERENCE_ONLY | High | HighFive Cinema product rooms, not HighFive Post app source. |

## Local Mac Search

| Candidate Directory / Project | Path | Evidence | Classification | Confidence | Notes |
| --- | --- | --- | --- | --- | --- |
| HighFive Post ASAR recovery | `/Users/michaelalston/Dev/highfive-post-asar-recovery` | Contains `package.json`, `app.js`, `index.html`, `styles.css`, `electron/main.js`, `electron/preload.js`, `core/*`, `assets/`, `renderer-dist/`, and `docs/figma_post_reference/`. `package.json` name is `resolve-app` and description is `Resolve-aware AI post-production cockpit for safe review, recommendations, proof, and operator control.` | POST_APP_CANDIDATE | High | Strongest candidate found. It appears to be an Electron/JavaScript recovered Post/Resolve app, but it should be confirmed before implementation because app naming also includes HighFive Cinema in places. |
| HighFive Post ASAR recovery backup | `/Users/michaelalston/Dev/highfive-post-asar-recovery-backups/phase_022_before_figma_ui_rebuild_20260611T001442Z` | Contains backup `package.json`, `app.js`, `main.js`, `preload.js`, and older `figma_post_reference` docs. Backup docs map Media/Edit/Audio/Color to recovered `app.js` pages. | POST_APP_CANDIDATE | Medium | Useful as backup/reference, but should not be the primary working directory unless the user selects it. |
| Resolve app native | `/Users/michaelalston/Dev/resolve-app-native` | Directory exists and contains HighFive Post reference docs/scripts such as `scripts/highfive_post_source_candidate_search.mjs` and `docs/figma_post_reference/*`. No project app entry files were found by the shallow project-file scan. | NEEDS_CLARIFICATION | Medium | Looks like support/reference tooling for Post discovery or native work, not clearly the main app. Needs user confirmation. |
| Current Cinema repo | `/Volumes/Scratch SSD/HighFive-Cinema-clean` | Current repo and Xcode project discovered in local volume search. | CINEMA_REFERENCE_ONLY | High | Active iOS Cinema project; not a dedicated Post app. |
| Older HighFive Cinema copies/checkpoints | `/Volumes/Scratch SSD/Almost done 137am april 19 /`, `/Volumes/Scratch SSD/April 25 1208/`, `/Volumes/Scratch SSD/April 25 927pm build 5 /`, `/Volumes/Scratch SSD/BAckup HIGHFIVE copy 3/`, `/Volumes/Scratch SSD/BAckup HIGHFIVE copy 6/`, `/Volumes/Scratch SSD/Checkpoint April 23 341pm/`, `/Volumes/Scratch SSD/Checkpoint april22 /`, `/Volumes/Scratch SSD/Codex /`, `/Volumes/Scratch SSD/May 24th 831pm checkpoint/`, `/Volumes/Scratch SSD/May 24th 917 /`, `/Volumes/Scratch SSD/New project may 29th/` | Each contains `HighFive.xcodeproj` and HighFive/Cinema backup structures. | CINEMA_REFERENCE_ONLY | High | These appear to be older Cinema iOS backups/checkpoints, not Post app targets. |
| HigherKey spatial/playback rebuilds | Paths containing `HigherKeySpatialPeek_PHASE_19_LIVE_PLAYBACK_ENGINE_GOLD_2026-03-25` | Xcode projects and playback/depth-oriented names found in several old backup trees. | PROTECTED_LEGACY_MEDIA | High | Playback/depth history, not Post UI. Do not use for Post app implementation. |
| Resolve Project Backups | `/Volumes/Scratch SSD/Movies/Resolve Project Backups` | Directory name found in local scan. | UNRELATED | Low | Resolve backup folder, not an app source project from this audit. |

## HighFive Post App File Status

Found possible candidate but needs confirmation.

The current repo does not contain dedicated HighFive Post app files. A strong external candidate exists at `/Users/michaelalston/Dev/highfive-post-asar-recovery`. It appears to be an Electron/JavaScript recovered app with Post/Resolve cockpit behavior and HighFive Post references. Because the package is named `resolve-app` and the Electron shell sets the app name to `HighFive Cinema`, the user should confirm whether this is the intended HighFive Post app target before implementation begins.

## Recommendation

If `/Users/michaelalston/Dev/highfive-post-asar-recovery` is the intended HighFive Post app:

- Switch Codex working directory to `/Users/michaelalston/Dev/highfive-post-asar-recovery` before implementation.
- Treat `app.js`, `index.html`, `styles.css`, `electron/main.js`, and `electron/preload.js` as the likely recovered app surfaces to audit first.
- Re-run a clean baseline and safety audit in that project before applying any Figma-driven UI work.

If it is not the intended Post app:

1. User provides the correct location of HighFive Post app files, or
2. user explicitly approves creating a new isolated HighFive Post UI area in the current Cinema repo.

## Do Not Build Yet Unless

- Direct Post app files are located and confirmed, or
- user explicitly approves a new isolated Post UI area, and
- direct Figma production frame links are provided for at least Global Shell and Review Home, and
- implementation phase scope is approved.

## Safety Notes

- No app code changed.
- No Swift files changed.
- No project files changed.
- No Figma assets copied.
- No tokens stored.
- No build run.
- No protected paths touched.
- Discovery searched the current repo plus likely local directories under `$HOME/Dev` and `/Volumes/Scratch SSD` with bounded depth.
