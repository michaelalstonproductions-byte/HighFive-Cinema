# HighFive Post — Selected Figma Frames

## Source

- Figma file: HigherKey Post
- File key: emGsL3b6Z6191CJof84Zv3
- Starting node: 3:286
- Link: https://www.figma.com/design/emGsL3b6Z6191CJof84Zv3/HigherKey-Post?node-id=3-286&m=dev&t=AYmBE6LTvKxQGkPO-1
- Date reviewed: 2026-06-10

## Access Summary

- File accessible: yes
- Node 3:286 accessible: yes
- Metadata accessible: yes
- Screenshot accessible: yes
- Design context accessible: limited
- Notes: Figma MCP listed one top-level page, `Home Video Editor`, and returned metadata for node `3:286`, named `Video editor / NLE`. Screenshot generation succeeded for `3:286`, but design context reported that no layer was selected. No short-lived Figma asset URLs were copied into this documentation.

The accessible Figma source did not expose clearly named production frames for every HighFive Post target area. The starting node appears to be a broad NLE reference canvas containing image/mockup frames (`IMAGE1`, `IMAGE2`, `IMAGE3`, `IMAGE4`) rather than individually named product screens. The top-level page also contains a branded video-editor portfolio/storyboard, which is useful only as a weak style reference and should not be treated as HighFive Post production UI.

## Selected Frames Table

| Area | Use This Figma Frame | Node ID | Dimensions | Classification | Screenshot Access | Design Context Access | Why Selected | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Global Shell | Video editor / NLE | 3:286 | Screenshot bounds reported as 3920 x 1918; metadata canvas reports 0 x 0 | SECONDARY_STYLE_REFERENCE | Yes | Limited | Best verified reference for an editing-app workspace shell. Use only for premium dark NLE layout direction, not as final production UI. | Medium |
| Review Home | No verified production frame found | N/A | N/A | NEEDS_CLARIFICATION | No | No | No accessible frame is clearly a HighFive Post review home, project queue, notes, or feedback screen. | Low |
| Media Pool | No verified production frame found | N/A | N/A | NEEDS_CLARIFICATION | No | No | No accessible frame is clearly a media pool, bins, clips, footage browser, or asset library. | Low |
| Edit Workspace | Video editor / NLE | 3:286 | Screenshot bounds reported as 3920 x 1918; metadata canvas reports 0 x 0 | SECONDARY_STYLE_REFERENCE | Yes | Limited | The node name directly references an NLE and may inform timeline/editor hierarchy, viewer placement, and professional workspace density. It is not enough to identify exact production panels. | Medium |
| Audio Workspace | No verified production frame found | N/A | N/A | NEEDS_CLARIFICATION | No | No | The page contains a portfolio card named `SOUND SYNC`, but that is not a production audio workspace. | Low |
| Color Room | No verified production frame found | N/A | N/A | NEEDS_CLARIFICATION | No | No | The page contains a portfolio card named `COLOR GRADING`, but that is not a production color-room workspace. | Low |
| AI Copilot | No verified production frame found | N/A | N/A | NEEDS_CLARIFICATION | No | No | No accessible frame or component clearly maps to AI assistant, prompt, transcript, suggestions, automation, or analysis. | Low |
| Export / Diagnostics | No verified production frame found | N/A | N/A | NEEDS_CLARIFICATION | No | No | No accessible frame clearly maps to export preparation, render queue, diagnostics, health, warnings, or status reports. | Low |

## Frames To Discard

| Frame Name | Node ID | Reason To Discard | Risk If Used |
| --- | --- | --- | --- |
| Video Editor Storyboard Portfolio (Community) (Copy) | 3:5 | Branded portfolio/storyboard page, not HighFive Post production UI. Includes `NEXTGEN` branding and case-study style cards. | Would push HighFive Post toward a marketing portfolio instead of a professional post-production app. |
| CINEMATIC INTRO storyboard card | 3:20 | Portfolio card for a service/case-study item, not a production workspace. | Could cause the app to look like a project showcase grid rather than a working review/editing surface. |
| MONTAGE EDITS storyboard card | 3:50 | Portfolio card with tags and goals/tools, not a timeline or edit workspace. | Could be mistaken for an edit workflow card and overfit the UI to marketing content. |
| SOUND SYNC storyboard card | 3:132 | Audio-related portfolio card, not an audio mixer, waveform editor, or levels workspace. | Would produce an audio area without real workspace hierarchy. |
| COLOR GRADING storyboard card | 3:158 | Color-related portfolio card, not a color correction room with scopes or controls. | Would produce a color room that lacks professional controls and structure. |
| VFX COMPOSITE storyboard card | 3:184 | VFX portfolio card, not a HighFive Post product screen. | Could introduce unrelated visual-effects service positioning. |
| CALL TO ACTION storyboard card | 3:240 | Marketing/portfolio CTA card, not a product export or delivery flow. | Would make the app feel like a marketing site or sales funnel. |

## Open Questions

- Provide direct Figma frame links for the intended HighFive Post Global Shell, Review Home, Media Pool, Edit Workspace, Audio Workspace, Color Room, AI Copilot, and Export / Diagnostics screens.
- If the intended frames are embedded as flattened screenshots inside `IMAGE1` through `IMAGE4`, provide exported screenshots or Dev Mode details for each source screen.
- Confirm whether `Video editor / NLE` is a real HighFive Post production reference or only a mood/reference board.
- Provide component-level links for sidebar, top bar, toolbar, timeline cell, clip card, inspector panel, media tile, AI panel, color control, audio row, export status card, and diagnostics row if those exist elsewhere in the Figma file.
