# HighFive Post — Figma To App Map

## Summary

The HigherKey Post Figma file was accessible through metadata and screenshot generation, but the verified source currently exposes only one broad `Video editor / NLE` reference canvas plus a `Home Video Editor` portfolio/storyboard page. `Video editor / NLE` can be used as a secondary style reference for the Global Shell and Edit Workspace, but no clearly named HighFive Post production frames were verified for Review Home, Media Pool, Audio Workspace, Color Room, AI Copilot, or Export / Diagnostics. The recovered repo appears to be the HighFive Cinema iOS app rather than a dedicated HighFive Post app, so target app files are mostly absent or only loosely analogous.

## Mapping Table

| Product Area | Figma Frame To Use | Figma Node ID | Do Not Use | Design Principle To Copy | What Not To Copy | Target App Files | Matching UI Exists | Implementation Readiness | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Global Shell | Video editor / NLE | 3:286 | Video Editor Storyboard Portfolio (Community) (Copy) | Premium dark editing shell, strong workspace hierarchy, restrained chrome | NEXTGEN branding, marketing cards, flattened laptop/image mockups | No HighFive Post shell file found; reusable style files include `HFColors.swift`, `HFSpacing.swift`, `HFTypography.swift`, `HFGlassPanel.swift` | Partial | Needs source frame | Use as style reference only until production shell frame is provided. |
| Review Home | No verified production frame found | N/A | Portfolio/storyboard cards | Review queue clarity, project/session cards, feedback hierarchy | Generic admin dashboard or case-study grid | No matching recovered app file found; loose references include `CreatorTeamReviewPreviewView.swift`, `DemoReviewChecklistView.swift` | Partial/low confidence | Needs source frame | Needs direct frame link or exported screenshot. |
| Media Pool | No verified production frame found | N/A | Portfolio/storyboard cards and raw image mockups | Media-first grid, bins, clip metadata, compact status | File manager behavior, import/upload assumptions | No matching recovered app file found; loose reference: `CreatorAssetManagerPreviewView.swift` | Partial/low confidence | Needs source frame | Needs media pool frame and clip-card component links. |
| Edit Workspace | Video editor / NLE | 3:286 | MONTAGE EDITS storyboard card | Viewer/timeline/inspector hierarchy and timeline-friendly spacing | Playback/edit engine behavior, marketing card copy | No matching HighFive Post file found; protected legacy media files exist under `HighFive/App/Playback/*` and `HighFive/App/UI/HKV1_ControlBar.swift` | No verified match | Needs source frame | Use only for broad NLE layout direction. |
| Audio Workspace | No verified production frame found | N/A | SOUND SYNC storyboard card | Waveform rows, mixer/levels, stem grouping | Live audio engine assumptions or service-card layout | No matching UI file found; non-UI audio resources exist under `HighFive/App/Resources/*Audio*` | No | Needs source frame | Needs audio room frame. |
| Color Room | No verified production frame found | N/A | COLOR GRADING storyboard card | Scopes/control hierarchy, calm dark correction room | Decorative color-service card, live LUT/render behavior | No matching UI file found | No | Needs source frame | Needs color room frame and color-control component details. |
| AI Copilot | No verified production frame found | N/A | Any generic AI/marketing frame if present elsewhere | Assistant panel, suggestions, transcript/analysis cards | Intrusive chatbot or automation promises | No matching recovered app file found | Unknown/no | Needs source frame | Needs direct AI Copilot frame. |
| Export / Diagnostics | No verified production frame found | N/A | CALL TO ACTION storyboard card | Readiness rows, warning hierarchy, calm status | Real render/export/file/share/platform behavior | No matching HighFive Post file found; loose references include `FinalQARouteMatrixView.swift`, `ReleaseCandidatePrepView.swift`, `ProductSpineLockdownView.swift` | Partial/low confidence | Needs source frame | Needs export/diagnostics frame and status-row components. |

## Target File Discovery

### Global Shell

- No matching recovered HighFive Post shell file found.
- Reusable style/system files found:
  - `HighFive/DesignSystem/HFColors.swift`
  - `HighFive/DesignSystem/HFSpacing.swift`
  - `HighFive/DesignSystem/HFTypography.swift`
  - `HighFive/Components/HFGlassPanel.swift`
  - `HighFive/Components/HFTabBar.swift`

### Review Home

- No matching recovered HighFive Post review-home file found.
- Loose, non-Post references found:
  - `HighFive/Views/Creator/CreatorTeamReviewPreviewView.swift`
  - `HighFive/Views/Demo/DemoReviewChecklistView.swift`
  - `HighFive/Views/Spine/SpineReviewPathsView.swift`

### Media Pool

- No matching recovered HighFive Post media-pool file found.
- Loose, non-Post references found:
  - `HighFive/Views/Creator/CreatorAssetManagerPreviewView.swift`
  - `HighFive/Components/HFPosterCard.swift`
  - `HighFive/Components/HFMovieCard.swift`

### Edit Workspace

- No matching recovered HighFive Post edit-workspace file found.
- Protected/legacy media files found but not target files for this pass:
  - `HighFive/App/Playback/HKV1_PlaybackController.swift`
  - `HighFive/App/Playback/HKV1_SpatialPeekViewController.swift`
  - `HighFive/App/UI/HKV1_ControlBar.swift`
  - `HighFive/Components/HFMockPlayerSheet.swift`

### Audio Workspace

- No matching recovered HighFive Post audio-workspace UI file found.
- Non-UI audio resources found:
  - `HighFive/App/Resources/HKV1_AudioSpeakerDetectionEngine.swift`
  - `HighFive/App/Resources/HKV1_PlayerAudioTap.swift`

### Color Room

- No matching recovered HighFive Post color-room UI file found.
- Static asset reference found but out of scope:
  - `HighFive/App/Store/Assets.xcassets/UI_Feature_ColorSystem.imageset`

### AI Copilot

- No matching recovered app file found.

### Export / Diagnostics

- No matching recovered HighFive Post export/diagnostics file found.
- Loose, non-Post references found:
  - `HighFive/Views/Release/FinalQARouteMatrixView.swift`
  - `HighFive/Views/Release/ReleaseCandidatePrepView.swift`
  - `HighFive/Views/Release/ProductSpineLockdownView.swift`
  - `HighFive/Data/HFPosterAssetHealth.swift`

## Recommended Build Order

1. Global Shell
2. Review Home
3. Media Pool
4. Edit Workspace
5. Audio Workspace
6. Color Room
7. AI Copilot
8. Export / Diagnostics

This order should hold unless direct Figma frame links reveal a more complete existing production flow.

## Risks

- Ambiguous Figma frames: `Video editor / NLE` may be a reference board rather than production UI.
- Unrelated references: the accessible `Home Video Editor` page includes portfolio/case-study cards and `NEXTGEN` branding.
- Missing production nodes: most target areas do not have verified frame links or node names.
- App files not recovered: the current repo appears to be HighFive Cinema iOS, not HighFive Post.
- Visual-only references mistaken for production UI: `IMAGE1` through `IMAGE4` may be flattened screenshots without Dev Mode hierarchy.
- Accidental implementation of live export/render/file behavior if future work treats reference copy as scoped functionality.
- Protected iOS media/playback/depth systems exist in this repo and must remain untouched unless explicitly scoped.

## Next Required Inputs

- Direct Figma frame links for missing areas.
- Screenshots/exports if MCP cannot access nested production frames.
- Dev Mode details for specific nodes, especially shell, timeline, inspector, media pool, audio, color, AI, and diagnostics.
- App file locations if a separate HighFive Post app exists outside this recovered iOS repo.
- Confirmation whether node `3:286` is intended as a production reference, a mood board, or an imported screenshot board.
