# HighFive Cinema 1.2 Pass 4A Source Hygiene + Simulator Rescue

## Verdict

BLOCKED ON GIT WRITE PERMISSIONS AND LOCAL XCODE/SIMULATOR TOOLING.

Source validation passed:
- Release safety: PASS
- Debug direct Swift typecheck: PASS
- Release direct Swift typecheck: PASS

Simulator/xcodebuild did not reach Swift source compilation. The extracted failure is local tooling:
- `CoreSimulatorService connection became invalid`
- `Unable to discover any Simulator runtimes`
- `simdiskimaged crashed or is not responding`
- `Could not parse Swift versions from: error: permissionDenied`
- `Unable to discover swiftc command line tool info`

## Current HEAD

Confirmed HEAD at the start of Pass 4A:

`26a0739 docs(qa): add HighFive 1.2 depth validation reports`

Recent 1.2 commits already on `main`:
- `3072e9c fix(storekit): align official access and entitlement state`
- `9716e49 feat(depth): add cinematic UI depth system`
- `b309972 feat(simulator): add HighFive simulator preview tooling`
- `dd71fde feat(packaging): add promo packaging workspace scaffolding`
- `9029dd0 chore(release): bump HighFive Cinema to 1.2 build 13`
- `26a0739 docs(qa): add HighFive 1.2 depth validation reports`

## Files Created In This Pass

- `scripts/highfive_xcodebuild_diagnose.sh`
- `out/pass4a-source-hygiene/status-before.txt`
- `out/pass4a-source-hygiene/working-tree-before.patch`
- `out/pass4a-source-hygiene/diff-stat-before.txt`
- `out/pass4a-source-hygiene/status-after-build-diagnose.txt`
- `out/pass4a-source-hygiene/REMAINING_WORKTREE_CLASSIFICATION.md`
- `out/pass4a-source-hygiene/release-safety.txt`
- `out/pass4a-source-hygiene/direct-typecheck.txt`
- `out/pass4a-source-hygiene/release-safety-post.txt`
- `out/pass4a-source-hygiene/direct-typecheck-post.txt`
- `out/pass4a-source-hygiene/run-simulator-post.txt`
- `out/pass4a-source-hygiene/FINAL_PASS_4A_SOURCE_HYGIENE_SIMULATOR_RESCUE.md`

## Commits Created In This Pass

None.

Commit creation was attempted but blocked by the managed sandbox:

`fatal: Unable to create '/Volumes/Scratch SSD/HighFive-Cinema-clean/.git/index.lock': Operation not permitted`

The current execution environment allows reading `.git` but not writing `.git/index.lock`, so no staging or committing can be completed inside this session.

## Recommended Commits To Run From Normal Terminal

Run these from a normal macOS Terminal with write access to `.git`. Do not use `git add -A`.

### Commit A

```bash
git add -- \
  HighFive/App/Launch/HFLaunchReadyGate.swift \
  HighFive/App/Launch/LaunchScreen.storyboard \
  HighFive/App/Legal \
  HighFive/App/App/HKV1_SceneDelegate.swift \
  HighFive/App/HFStreamingRootView.swift \
  HighFive/App/Debug/HFSimulatorQABootstrap.swift

git commit -m "feat(launch): track launch gate and legal entry flow"
```

### Commit B

```bash
git add -- \
  HighFive/Data/HFOfficialStreamResolver.swift \
  HighFive/App/Resources/Streaming \
  HighFive/App/Playback/HKV1_LivePlaybackEngine.swift \
  HighFive/App/Playback/HKV1_TrainingClipLocator.swift

git commit -m "feat(streaming): track official stream resolver and playback support"
```

### Commit C

```bash
git add -- \
  HighFive/App/AI \
  HighFive/App/Depth/HKV1_DepthSidecar.swift \
  HighFive/App/Layer4 \
  HighFive/App/Motion/HKV1_MotionService.swift \
  HighFive/App/Motion/HKV1_ProMotionService.swift \
  HighFive/App/Motion/HKV1_ProPeekEngine.swift \
  HighFive/App/Playback/HKV1_SpatialPeekViewController.swift \
  HighFive/App/UI/Rendering/HKV1_PlayerLayerView.swift

git commit -m "feat(player): track Layer 4 motion and depth runtime support"
```

### Commit D

```bash
git add -- \
  HighFive/App/Support/HFSupportConfig.swift \
  HighFive/Views/Profile/HFAccountView.swift \
  HighFive/Views/Profile/HFAddProfileView.swift \
  HighFive/Views/Profile/HFAppSettingsView.swift \
  HighFive/Views/Profile/HFHelpSupportView.swift \
  HighFive/Views/Profile/HFLocalProfileStore.swift \
  HighFive/Views/Profile/HFManageProfileView.swift \
  HighFive/Views/Profile/HFProfileDestination.swift \
  HighFive/Views/Profile/ProfileView.swift

git commit -m "feat(profile): add profile management surfaces"
```

### Commit E

```bash
git add -- \
  HighFive/App/Library \
  HighFive/Views/DownloadsView.swift \
  HighFive/Views/MyListView.swift \
  HighFive/Views/Search/SearchView.swift

git commit -m "feat(library): update library search and downloads surfaces"
```

### Commit F

```bash
git add -- \
  scripts/highfive_release_safety_check.sh \
  scripts/highfive_ghost_code_audit.sh \
  scripts/highfive_launch_smoke_check.sh \
  scripts/highfive_xcodebuild_diagnose.sh \
  scripts/copy_debug_full_streams.sh

git commit -m "chore(qa): track release safety and launch audit scripts"
```

### Commit G

```bash
git add -- \
  out/pass4a-source-hygiene/REMAINING_WORKTREE_CLASSIFICATION.md \
  out/pass4a-source-hygiene/FINAL_PASS_4A_SOURCE_HYGIENE_SIMULATOR_RESCUE.md

git commit -m "docs(qa): add Pass 4A source hygiene and simulator rescue report"
```

## Files Intentionally Left Uncommitted

Recommended review/optional:
- `HighFive/App/Export/HKV1_CinematicExportPipeline.swift`
- `HighFive/Components/HFConsumerControlPanelSheet.swift`
- `HighFive/Components/HFPosterMarqueeFrame.swift`
- `HighFive/Components/HFTheaterMarqueePosterFrame.swift`

Generated/local artifacts:
- `out/simulator/`
- `out/archive-submit/`
- `out/archive-submit-version-bump/`
- `out/commit-handoff/`
- historical `out/*proof*`, `out/*verification*`, `out/rs*`, and build logs/statuses
- simulator screenshots/videos
- DerivedData, `.xcresult`, `.app`, `.ipa`, `.dSYM`, and temporary build products

## Xcodebuild Error Extraction Result

Diagnostic script:

`scripts/highfive_xcodebuild_diagnose.sh`

Output:
- Full log: `out/simulator/xcodebuild-diagnose.log`
- Extracted errors: `out/simulator/xcodebuild-errors.txt`
- Result bundle path attempted: `out/simulator/highfive-diagnose.xcresult`

Result:

`xcodebuild status: 133`

Classification:

TOOLING-RELATED, NOT SOURCE-RELATED.

The build failed before useful Swift source diagnostics. The key blocker is local Xcode/CoreSimulator service failure plus `swiftc` discovery permission failure.

## Validation Results

Release safety:

PASS

Debug direct Swift typecheck:

PASS

Release direct Swift typecheck:

PASS

## Simulator Build / Install / Launch Result

BLOCKED.

`scripts/run_highfive_simulator.sh` failed before selecting a simulator:

- `CoreSimulatorService connection became invalid`
- `Unable to discover any Simulator runtimes`
- `simdiskimaged crashed or is not responding`
- `simctl list devices available -j` returned non-zero exit status 1

No simulator screenshot or video was created.

## Protected Systems Preserved

No source rewrites were made during Pass 4A beyond adding the diagnostic script and reports.

Validation still covers:
- StoreKit product IDs
- entitlement checks
- official stream manifest
- preview-only trailer rules
- absence of old forbidden product IDs
- absence of Release bundled `*_ref.mp4` references
- absence of `/Volumes` production stream dependency

## Safe To Push Main?

Not yet.

Reason:
- Essential app source remains uncommitted because this sandbox cannot write `.git/index.lock`.
- Push only after the recommended commits above are created from a normal Terminal and these commands pass:

```bash
scripts/highfive_release_safety_check.sh
scripts/highfive_direct_typecheck.sh
scripts/highfive_xcodebuild_diagnose.sh
```

If local Xcode/CoreSimulator remains broken, `scripts/highfive_xcodebuild_diagnose.sh` may still fail for tooling. In that case, the direct typecheck and release safety results are the source-level gate, and simulator QA should be completed from Xcode after CoreSimulator is repaired.

## Remaining Real-Device QA

- Home launch and legal entry flow.
- Native LaunchScreen and `HFLaunchReadyGate`.
- The Friendly unlock and full playback routing.
- Paranormall Episode 7 `e7.v2` unlock and routing.
- Trailer-only previews remain trailer-only.
- Official titles never open Import Movie.
- Vertical Stage.
- Depth / Tilt / Peek.
- Layer 4.
- Reduce Motion.
- Low Power Mode.
- Profile Account / App Settings / Help & Support.
- Add Profile and Manage Profile.
- Release build has no debug UI.
