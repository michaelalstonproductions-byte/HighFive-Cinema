# HighFive Cinema — Codex Project Instructions

## Mission

HighFive Cinema is becoming a full entertainment and creator ecosystem.

The long-term product includes:

* Streaming
* Creator Studio
* Creator Dashboard
* Creator Marketplace
* Connect / social community
* Search and discovery
* Messaging
* Notifications
* Paywall
* File Manager
* Project Management
* Calendar
* AI / Agent Activity
* Media Viewer
* Editing Tools
* Analytics
* Asset Management
* Depth / motion / tilt / peek playback

Do not build everything at once.

Build in controlled phases. Protect working systems.

---

## Current Priority

The current priority is:

**Premium Streaming Foundation and UI polish**

Focus on the consumer streaming experience first.

Allowed current work:

* Home
* Discover
* Search
* Movie Detail
* My List / Library
* Downloads
* Profile
* Profile Switcher
* Bottom Tab Navigation
* Movie Cards
* Poster Cards
* Design Tokens
* Reusable Components
* Local Mock Data
* Streaming UI polish

Do not build Phase 2 or Phase 3 systems unless the task explicitly says to.

---

## Protected Systems

These systems are stable or sensitive.

Do not modify them unless the task specifically asks for depth, motion, playback, tilt, peek, or Layer 4 work.

Protected paths:

* `HighFive/App/Depth/*`
* `HighFive/App/Motion/*`
* `HighFive/App/Playback/*`
* `HighFive/App/Layer4/*`
* `HighFive/App/Rendering/*`

Protected concepts:

* Depth
* Tilt
* Peek
* Motion
* Spatial playback
* ProMotion
* Volumetric light field
* Layer 4
* Hinge / pivot stability
* Temporal depth fusion

Important:

Previous depth and Layer 4 experiments created hinge, pivot, snapping, and depth-break problems.

When working outside those systems, do not touch these paths.

When a task does require these systems, preserve existing tilt and peek behavior first. Never replace stable motion math without explaining why.

---

## Current SwiftUI Phase 1 Foundation

The Phase 1 streaming foundation may include or already includes:

* `HighFive/App/HFStreamingRootView.swift`
* `HighFive/DesignSystem/HFColors.swift`
* `HighFive/DesignSystem/HFTypography.swift`
* `HighFive/DesignSystem/HFSpacing.swift`
* `HighFive/Components/HFButton.swift`
* `HighFive/Components/HFMovieCard.swift`
* `HighFive/Components/HFPosterCard.swift`
* `HighFive/Components/HFSectionHeader.swift`
* `HighFive/Components/HFSearchBar.swift`
* `HighFive/Components/HFFilterChip.swift`
* `HighFive/Components/HFTabBar.swift`
* `HighFive/Components/HFGlassPanel.swift`
* `HighFive/Models/Movie.swift`
* `HighFive/Models/Creator.swift`
* `HighFive/Models/UserProfile.swift`
* `HighFive/Models/Category.swift`
* `HighFive/Models/SearchResult.swift`
* `HighFive/Data/HFMockData.swift`
* `HighFive/Views/Home/HomeView.swift`
* `HighFive/Views/Search/SearchView.swift`
* `HighFive/Views/Discover/DiscoverView.swift`
* `HighFive/Views/MovieDetail/MovieDetailView.swift`
* `HighFive/Views/MyListView.swift`
* `HighFive/Views/DownloadsView.swift`
* `HighFive/Views/Profile/ProfileView.swift`
* `HighFive/Views/Profile/ProfileSwitcherView.swift`

Preserve this modular architecture.

Do not collapse the app into one large file.

---

## Figma Source

The design source file is:

**HighFive Cinema Master Template**

Use these Figma pages first for streaming work:

1. `05_Design_System`
2. `01_Streaming_System`
3. `Home_Discovery_Gold`
4. `COMPONENT_08_MovieCard_Grid`
5. `KEEP_39_Search_Discovery_System`
6. `KEEP_18_Liquid_Glass_System` only for glass / blur styling inspiration

Do not use marketplace, warehouse, creator, AI, calendar, messaging, or operations pages unless the task explicitly asks for that phase.

---

## Canonical Figma Page Names

Core systems:

* `01_Streaming_System`
* `02_Connect_System`
* `03_Creator_Studio_System`
* `04_Creator_Dashboard_System`
* `05_Design_System`

Gold systems:

* `GOLD_01_Creator_Marketplace`
* `GOLD_02_Creator_Marketplace_Discovery`
* `GOLD_03_File_Manager`
* `Home_Discovery_Gold`

Component systems:

* `COMPONENT_08_MovieCard_Grid`
* `COMPONENT_09_Sidebar_System`

Keep systems:

* `KEEP_15_Paywall_System`
* `KEEP_16_Creator_Messaging_System`
* `KEEP_17_Social_Community_System`
* `KEEP_18_Liquid_Glass_System`
* `KEEP_19_Creator_Editing_System`
* `KEEP_20_Creator_Analytics_Dashboard`
* `KEEP_21_Agent_Activity_Feed`
* `KEEP_22_iOS15_Notification_System`
* `KEEP_23_Cheka_Team_Management_System`
* `KEEP_24_Digital_Warehouse_Command_Center`
* `KEEP_25_Advanced_Calendar_System`
* `KEEP_26_Creator_Progress_System`
* `KEEP_27_AI_Studio_Landing_System`
* `KEEP_28_Creator_Operations_Dashboard`
* `KEEP_29_Operations_Map_Dashboard`
* `KEEP_39_Search_Discovery_System`

---

## Design Direction

The app should feel like a premium cinematic streaming platform.

Use:

* Dark cinematic backgrounds
* Gold / orange accent color
* Rounded cards
* Large hero poster areas
* Horizontal content carousels
* Movie poster grids
* Clean search interface
* Filter chips
* Glass / blur panels
* Smooth scrolling
* Reusable SwiftUI components
* Consistent spacing and typography

Avoid:

* Random colors outside the design system
* One-off UI styles
* Crowded layouts
* Overbuilding future product areas
* Breaking existing HighFive style

---

## Engineering Rules

Use SwiftUI for the new streaming foundation unless the existing app shell requires UIKit bridge code.

Keep code modular.

Prefer:

* Small files
* Reusable components
* Local mock data
* Clear model names
* Clear folder structure
* Existing naming conventions

Avoid:

* One massive file
* New backend calls
* API keys
* Payment logic
* Real authentication
* Unrequested dependencies
* Unrequested architecture rewrites
* Touching protected depth/motion/playback systems

If files already exist, refactor carefully instead of duplicating.

If there is an existing app entry point, scene delegate, onboarding flow, or launch flow, update carefully and preserve existing working behavior.

---

## Project Structure

Use or preserve these folders when appropriate:

* `HighFive/App`
* `HighFive/Models`
* `HighFive/Views`
* `HighFive/Views/Home`
* `HighFive/Views/Discover`
* `HighFive/Views/Search`
* `HighFive/Views/MovieDetail`
* `HighFive/Views/Profile`
* `HighFive/Components`
* `HighFive/DesignSystem`
* `HighFive/Data`

Do not randomly move large systems unless the task is specifically a cleanup or reorganization task.

---

## Mock Data Rules

Use local mock data only unless explicitly instructed otherwise.

Do not add:

* Backend
* Network calls
* External APIs
* Login
* Payment
* Server sync
* Cloud storage

Mock data may include:

* Movies
* Creators
* Categories
* Profiles
* Search suggestions
* Continue-watching progress
* Download state
* My List state
* Related titles
* Cast / creator metadata

---

## Build / Check Command

Use the repo’s normal iOS build command.

A known working verification command is:

```bash
TMPDIR="/Volumes/Scratch SSD/tmp/" xcodebuild \
  -project HighFive.xcodeproj \
  -scheme HighFive \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "/Volumes/Scratch SSD/XcodeDerivedData/highfive-codex-check" \
  CODE_SIGNING_ALLOWED=NO \
  SDK_STAT_CACHE_ENABLE=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build
```

Run build checks after code changes.

If the build fails, fix compile errors and run the check again.

---

## Git / Repo Safety

Before making large edits, inspect the working tree.

Use:

```bash
git status --short
```

If there are many existing unstaged changes, report them before editing.

Do not overwrite unrelated user changes.

Do not commit large media files.

Ignore local video assets:

* `*.mov`
* `*.mp4`

Do not commit:

* DerivedData
* build folders
* temporary archives
* `.wandb-bin`
* large local videos
* private environment files
* secrets
* API keys

---

## Current Do-Not-Build List

Unless explicitly requested, do not build:

* Creator Marketplace
* Creator hiring
* Payments
* Paywall
* Calendar
* Warehouse command center
* AI Studio
* Agent activity
* File manager
* Project management
* Push notifications
* Messaging
* Social community
* Backend systems
* Real authentication

These are future phases.

---

## Recommended Next Phase

After the base streaming shell is stable, the recommended next phase is:

**Phase 1.5 — Premium Streaming Experience**

Possible tasks:

* Premium Home Hero
* Continue Watching
* Dynamic content rails
* Enhanced Discover
* Cinematic Movie Detail
* Related titles
* Trailer preview area
* Cast / creator rows
* Gallery rows
* My List polish
* Downloads polish
* Profile polish

While doing Phase 1.5, still do not modify protected depth, motion, playback, or Layer 4 systems.

---

## Definition of Done

A task is complete when:

* The app builds successfully.
* The requested screens or features exist.
* Existing working flows are preserved.
* Protected systems are untouched unless explicitly requested.
* No secrets are added.
* No large video files are committed.
* Final response includes:

  * Changed files
  * What was implemented
  * Build command used
  * Build result
  * Any remaining warnings

---

## Response Expectations

When finished, summarize clearly:

1. What changed
2. Which files changed
3. Whether the build passed
4. Any warnings
5. Any protected systems that were intentionally not touched

If a task requires touching Depth, Motion, Playback, or Layer 4, explain the risk and the exact files before making edits.
