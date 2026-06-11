# HighFive Post — UI Needs From Figma

## Product Intent

HighFive Post should feel like a premium post-production workspace for review, editing, media organization, audio, color, AI assistance, export preparation, and diagnostics.

It should not feel like:
- generic admin dashboard
- cloud backend console
- raw file manager
- generic SaaS panel
- unrelated marketing site

## Area Requirements

### Global Shell

- Use this Figma frame: `Video editor / NLE` (`3:286`) as a secondary style reference only.
- Do not use this frame: `Video Editor Storyboard Portfolio (Community) (Copy)` (`3:5`) as production UI.
- Design principle to copy: dark premium workspace, professional editing-app density, strong primary canvas, restrained chrome.
- What not to copy: unrelated branding, flattened screenshots, marketing portfolio cards, or mockup-only laptop/image framing.
- Target app files if recoverable: no recovered HighFive Post shell file found. Reusable iOS style files found: `HighFive/DesignSystem/HFColors.swift`, `HighFive/DesignSystem/HFSpacing.swift`, `HighFive/DesignSystem/HFTypography.swift`, `HighFive/Components/HFGlassPanel.swift`.
- Current recovered app matching UI: partial, because the repo has a premium dark iOS streaming shell but no verified HighFive Post desktop shell.
- UI needs: direct production shell frame, sidebar/topbar hierarchy, workspace switcher, active project context, status area, inspector placement, safe preview states.

### Review Home

- Use this Figma frame: no verified production frame found.
- Do not use this frame: portfolio/storyboard cards from page `Home Video Editor`.
- Design principle to copy: if later verified, use media-first cards, calm review queue hierarchy, clear notes/status surfaces.
- What not to copy: generic project dashboard, dense tables, marketing case-study grids.
- Target app files if recoverable: no matching HighFive Post review home file found. Related but not equivalent iOS files include `HighFive/Views/Creator/CreatorTeamReviewPreviewView.swift`, `HighFive/Views/Demo/DemoReviewChecklistView.swift`, and `HighFive/Views/Spine/SpineReviewPathsView.swift`.
- Current recovered app matching UI: partial/low confidence; related review concepts exist, but not HighFive Post.
- UI needs: direct review-home frame, project/session list, recent reviews, feedback queue, notes summary, reviewer status, safe local-only empty states.

### Media Pool

- Use this Figma frame: no verified production frame found.
- Do not use this frame: generic portfolio cards or image mockups without Dev Mode structure.
- Design principle to copy: media-first grid/list, clip thumbnails, metadata rows, bins, filters, compact status chips.
- What not to copy: raw file manager behavior, import/upload CTAs, file-browser assumptions, backend storage language.
- Target app files if recoverable: no matching HighFive Post media pool file found. Related but not equivalent iOS files include `HighFive/Views/Creator/CreatorAssetManagerPreviewView.swift`, `HighFive/Components/HFPosterCard.swift`, and `HighFive/Components/HFMovieCard.swift`.
- Current recovered app matching UI: partial/low confidence; asset-preview ideas exist, not a Post media pool.
- UI needs: direct media-pool frame, bin list, clip cards, source browser, preview metadata, local/static placeholders, protected intake boundary.

### Edit Workspace

- Use this Figma frame: `Video editor / NLE` (`3:286`) as a secondary style reference.
- Do not use this frame: `MONTAGE EDITS` storyboard card (`3:50`) as production UI.
- Design principle to copy: NLE hierarchy with viewer, timeline, clip context, inspector, toolbar, and readable spacing.
- What not to copy: live playback controls, editing engine assumptions, raw tool integrations, marketing portfolio content.
- Target app files if recoverable: no matching HighFive Post edit workspace file found. Protected/legacy media files exist under `HighFive/App/Playback/*` and `HighFive/App/UI/HKV1_ControlBar.swift`, but they are not target app files for this docs pass.
- Current recovered app matching UI: no verified match.
- UI needs: direct edit workspace frame, timeline row structure, viewer area, local clip strip, inspector panel, safe disabled/live-system boundaries.

### Audio Workspace

- Use this Figma frame: no verified production frame found.
- Do not use this frame: `SOUND SYNC` storyboard card (`3:132`) as an audio workspace.
- Design principle to copy: waveform-friendly layout, clear meters/levels, track rows, dialogue/music/stems grouping.
- What not to copy: live audio engine assumptions, recording controls, generic portfolio service cards.
- Target app files if recoverable: no matching HighFive Post audio workspace file found. Audio-related app files exist at `HighFive/App/Resources/HKV1_AudioSpeakerDetectionEngine.swift` and `HighFive/App/Resources/HKV1_PlayerAudioTap.swift`, but they are not UI targets and were not modified.
- Current recovered app matching UI: no.
- UI needs: direct audio workspace frame, waveform rows, mixer treatment, level meters, stem grouping, static/local diagnostics.

### Color Room

- Use this Figma frame: no verified production frame found.
- Do not use this frame: `COLOR GRADING` storyboard card (`3:158`) as a color room.
- Design principle to copy: professional color controls, scopes area, correction stack, before/after context, calm dark UI.
- What not to copy: decorative color-service cards, live LUT/render/export behavior, overly dense control tables.
- Target app files if recoverable: no matching HighFive Post color room file found. A static asset reference exists under `HighFive/App/Store/Assets.xcassets/UI_Feature_ColorSystem.imageset`, but assets are out of scope and were not touched.
- Current recovered app matching UI: no.
- UI needs: direct color room frame, scopes/correction controls, exposure/contrast/saturation hierarchy, static protected-state copy.

### AI Copilot

- Use this Figma frame: no verified production frame found.
- Do not use this frame: no accessible AI-specific production frame was found.
- Design principle to copy: assistant panel should support analysis and suggestions without overtaking the creative workspace.
- What not to copy: intrusive chatbot, generic AI landing page, automation promises without scoped local behavior.
- Target app files if recoverable: no matching HighFive Post AI Copilot file found.
- Current recovered app matching UI: unknown/no.
- UI needs: direct AI Copilot frame, prompt/suggestion panel, transcript summary area, analysis cards, safe local preview states.

### Export / Diagnostics

- Use this Figma frame: no verified production frame found.
- Do not use this frame: `CALL TO ACTION` storyboard card (`3:240`) or any marketing CTA card.
- Design principle to copy: calm diagnostics states, readiness rows, warning hierarchy, delivery preparation without live execution.
- What not to copy: real render/export/file behavior, platform submission, share sheets, backend delivery language.
- Target app files if recoverable: no matching HighFive Post export/diagnostics file found. Related but not equivalent iOS files include `HighFive/Views/Release/FinalQARouteMatrixView.swift`, `HighFive/Views/Release/ReleaseCandidatePrepView.swift`, `HighFive/Views/Release/ProductSpineLockdownView.swift`, and `HighFive/Data/HFPosterAssetHealth.swift`.
- Current recovered app matching UI: partial/low confidence; diagnostics/release-readiness concepts exist, not HighFive Post.
- UI needs: direct export/diagnostics frame, queue/status rows, readiness cards, warnings, report summary, protected delivery boundary.

## Cross-App Design Principles To Copy

- Dark premium workspace shell.
- Clear sidebar/topbar hierarchy.
- Media-first cards and panels.
- Strong inspector panels.
- Timeline-friendly spacing.
- Readable status chips.
- Calm diagnostics states.
- AI panel as assistant, not intrusive chatbot.
- Local/static preview boundaries when live systems are not scoped.

## What Not To Copy

- Unrelated brand names.
- Marketing splash sections.
- Fake upload/export CTAs.
- Dashboards that look operational instead of creative.
- Over-dense tables.
- Real render/export/file behavior.
- Backend, token, or cloud assumptions.
- Flattened screenshot references as if they were Dev Mode production frames.

## Implementation Constraints

- Docs only in this pass.
- No app code changes.
- No Figma assets copied.
- No tokens stored.
- No live systems assumed.
- No build required or run.
- Do not touch `Assets.xcassets`, `project.pbxproj`, app settings, signing, StoreKit, or protected systems.
