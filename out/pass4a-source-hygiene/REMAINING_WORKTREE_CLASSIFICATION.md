# HighFive 1.2 Pass 4A Remaining Worktree Classification

Generated during Pass 4A after release safety and direct Debug/Release typecheck both passed.

## A. Essential app source to commit

### Launch / legal entry
- `HighFive/App/App/HKV1_SceneDelegate.swift`
- `HighFive/App/HFStreamingRootView.swift`
- `HighFive/App/Launch/HFLaunchReadyGate.swift`
- `HighFive/App/Launch/LaunchScreen.storyboard`
- `HighFive/App/Legal/HFLegalDocuments.swift`
- `HighFive/App/Legal/HFLegalGateView.swift`
- `HighFive/App/Legal/HFLegalTextSheet.swift`
- `HighFive/App/Debug/HFSimulatorQABootstrap.swift`

Reason: the app root now wraps `HFStreamingRootView` in `HFLaunchReadyGate`, uses a native launch screen, gates entry through local legal acceptance, and references `HFSimulatorQABootstrap` in Debug builds only.

### Official streaming / playback support
- `HighFive/Data/HFOfficialStreamResolver.swift`
- `HighFive/App/Resources/Streaming/HFOfficialStreams.json`
- `HighFive/App/Playback/HKV1_LivePlaybackEngine.swift`
- `HighFive/App/Playback/HKV1_TrainingClipLocator.swift`

Reason: current movie detail and playback paths reference the official stream resolver and production-safe stream manifest. Release safety verified the manifest contains HTTPS Cloudflare URLs and no preview-as-full or local `/Volumes` production dependency.

### Layer 4 / motion / depth / player runtime
- `HighFive/App/AI/`
- `HighFive/App/Depth/HKV1_DepthSidecar.swift`
- `HighFive/App/Layer4/`
- `HighFive/App/Motion/HKV1_MotionService.swift`
- `HighFive/App/Motion/HKV1_ProMotionService.swift`
- `HighFive/App/Motion/HKV1_ProPeekEngine.swift`
- `HighFive/App/Playback/HKV1_SpatialPeekViewController.swift`
- `HighFive/App/UI/Rendering/HKV1_PlayerLayerView.swift`

Reason: the current `HKV1_SpatialPeekViewController` directly references the AI/autopilot helper classes, `HKV1_DepthSidecar`, `HKV1_MotionService`, and related Layer 4/motion support. These files are protected runtime support and should be tracked together to avoid a clean-checkout build break.

### Profile / account / settings / help
- `HighFive/App/Support/HFSupportConfig.swift`
- `HighFive/Views/Profile/HFAccountView.swift`
- `HighFive/Views/Profile/HFAddProfileView.swift`
- `HighFive/Views/Profile/HFAppSettingsView.swift`
- `HighFive/Views/Profile/HFHelpSupportView.swift`
- `HighFive/Views/Profile/HFLocalProfileStore.swift`
- `HighFive/Views/Profile/HFManageProfileView.swift`
- `HighFive/Views/Profile/HFProfileDestination.swift`
- `HighFive/Views/Profile/ProfileView.swift`

Reason: `ProfileView` now navigates to account/settings/help routes and uses a local-only profile store. `HFSupportConfig` is referenced by the account/help/settings views.

### Library / search / downloads
- `HighFive/App/Library/`
- `HighFive/Views/DownloadsView.swift`
- `HighFive/Views/MyListView.swift`
- `HighFive/Views/Search/SearchView.swift`

Reason: these are current consumer tab surfaces and validated by direct typecheck.

## B. Essential scripts/tooling to commit

- `scripts/highfive_release_safety_check.sh`
- `scripts/highfive_ghost_code_audit.sh`
- `scripts/highfive_launch_smoke_check.sh`
- `scripts/highfive_xcodebuild_diagnose.sh`
- `scripts/copy_debug_full_streams.sh`

Reason: release safety, ghost-code audit, launch smoke, and build diagnosis are release/stabilization tooling. `copy_debug_full_streams.sh` is referenced by the Xcode project build phase; it is Debug-only for copying and explicitly removes accidental `*_ref.mp4` files in non-Debug configurations.

## C. Intentional report/doc to commit

- `out/pass4a-source-hygiene/REMAINING_WORKTREE_CLASSIFICATION.md`
- `out/pass4a-source-hygiene/FINAL_PASS_4A_SOURCE_HYGIENE_SIMULATOR_RESCUE.md`

Reason: Pass 4A handoff records the source/tooling diagnosis and remaining push readiness.

## D. Generated log/build artifacts to leave uncommitted

- `out/simulator/`
- `out/archive-submit/`
- `out/archive-submit-version-bump/`
- `out/commit-handoff/`
- `out/current-simulator/`
- historical `out/*proof*`, `out/*verification*`, `out/rs*`, and build logs/statuses
- simulator screenshots/videos
- DerivedData, `.xcresult`, `.app`, `.ipa`, `.dSYM`, and temporary build products

Reason: generated validation/build artifacts are useful locally but should not be committed unless explicitly selected as release handoff reports.

## E. Legacy/debug/reference risk requiring review

- `HighFive/App/Export/HKV1_CinematicExportPipeline.swift`
- `HighFive/Components/HFConsumerControlPanelSheet.swift`
- `HighFive/Components/HFPosterMarqueeFrame.swift`
- `HighFive/Components/HFTheaterMarqueePosterFrame.swift`

Reason: these compile locally but are not required by the current active consumer UI paths. The marquee components are intentionally not mounted in active UI after the depth-poster direction. Leave for owner review or a later ghost-code cleanup pass.

## F. Unclear / leave uncommitted

- Any remaining `out/` directories not explicitly listed in C.
- Any future untracked media, screenshots, videos, archives, or local build outputs.

Reason: not needed for a clean source checkout and not safe to bulk-commit.
