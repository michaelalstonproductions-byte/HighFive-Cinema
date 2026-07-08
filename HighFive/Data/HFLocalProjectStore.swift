import Foundation

enum HFLocalProjectStore {
    static let projects: [HFProject] = [
        markOfTheWest,
        paranormall,
        theFriendly
    ]

    static var packagingProject: HFProject {
        project(.markOfTheWest)
    }

    static var creatorOSProject: HFProject {
        project(.theFriendly)
    }

    static var studioIntelligenceProjects: [HFProject] {
        projects
    }

    static var studioIntelligenceSnapshot: HFProjectStudioIntelligenceSnapshot {
        let active = creatorOSProject
        return HFProjectStudioIntelligenceSnapshot(
            projectCount: projects.count,
            activeProjectTitle: active.creatorPackageTitle,
            readinessLabel: active.readinessPercentLabel,
            packageLabel: active.packagePercentLabel,
            reviewNotes: active.reviewNotes,
            marketplaceInterest: active.marketplaceInterest,
            detail: "Packaging Studio, Creator OS, Studio Intelligence, Operator Runtime, and HigherKey Brain read the same local project state."
        )
    }

    static var autonomousStudioIntelligenceSnapshot: HFStudioIntelligenceSnapshot {
        HFStudioIntelligenceEngine.snapshot(projects: projects)
    }

    static var workflowAutomationSnapshot: HFWorkflowAutomationSnapshot {
        HFWorkflowAutomationEngine.snapshot(projects: projects, intelligence: autonomousStudioIntelligenceSnapshot)
    }

    static var higherKeyBrainSnapshot: HFProjectBrainSnapshot {
        let active = creatorOSProject
        let intelligence = autonomousStudioIntelligenceSnapshot
        let workflowAutomation = workflowAutomationSnapshot
        return HFProjectBrainSnapshot(
            projectCount: projects.count,
            primaryProjectTitle: active.title,
            sourceLabel: "HFLocalProjectStore",
            summary: "\(projects.count) local projects share one project state source. HigherKey Brain has \(intelligence.totalSignalCount) studio signals and \(workflowAutomation.totalSignalCount) workflow automation signals.",
            toolSignals: [
                HFProjectToolSignal(id: "packaging", title: "Packaging Studio", value: packagingProject.shortTitle, detail: packagingProject.packageStatus, systemImage: "shippingbox.fill"),
                HFProjectToolSignal(id: "creator-os", title: "Creator OS", value: active.readinessPercentLabel, detail: active.workflowStage, systemImage: "command"),
                HFProjectToolSignal(id: "studio-intelligence", title: "Studio Intelligence", value: "\(intelligence.totalSignalCount)", detail: "Local event engine signals derived", systemImage: "lightbulb.max.fill"),
                HFProjectToolSignal(id: "workflow-automation", title: "Workflow Automation", value: "\(workflowAutomation.triggeredSuggestions.count)", detail: "Local triggered suggestions", systemImage: "arrow.triangle.branch"),
                HFProjectToolSignal(id: "operator-runtime", title: "Operator Runtime", value: "Signal", detail: "Graph remains intact with project-state input only", systemImage: "point.3.connected.trianglepath.dotted")
            ]
        )
    }

    static func project(_ id: HFProjectID) -> HFProject {
        guard let project = projects.first(where: { $0.id == id }) else {
            preconditionFailure("Missing local HighFive project: \(id.rawValue)")
        }
        return project
    }

    static func project(forMovieID movieID: String) -> HFProject? {
        projects.first { $0.movieID == movieID || $0.id.rawValue == movieID }
    }

    private static let markOfTheWest = HFProject(
        id: .markOfTheWest,
        movieID: nil,
        title: "The Mark of the West",
        shortTitle: "Mark of the West",
        creator: "HigherKey Inc.",
        format: .limitedSeries,
        genre: "Western",
        runtime: "Limited Series",
        synopsis: "A cinematic western package about myth, buried truth, and frontier consequence.",
        posterAssetName: "mark_west_hero_keyart",
        lifecycleState: .packaging,
        workflowStage: "Packaging Draft",
        packageStatus: "Preview / Draft",
        releaseState: "Local Packaging",
        readiness: HFProjectReadiness(overall: 0.58, package: 0.62, assets: 0.52, teamReview: 0.36, blockers: 3, status: "Packaging"),
        assetState: HFProjectAssetState(poster: "Draft", trailer: "Not Started", artwork: "Draft", metadata: "In Progress", thumbnail: "Key Art Draft"),
        reviewNotes: 4,
        marketplaceInterest: 12,
        audienceSaves: "Preview",
        teamMembers: 3,
        versionRounds: 1,
        tags: ["Western", "Limited Series", "Packaging"],
        packagingItems: [
            HFProjectPackagingItem(id: "mark-west-title-card", title: "The Mark of the West", subtitle: "Limited Series Coming Soon", layout: .titleCard, exportPresetIDs: ["tikTokVertical", "instagramReelStory", "linkedInLandscape", "pressKitSlide"], assetName: "mark_west_hero_keyart", isInternalOnly: false),
            HFProjectPackagingItem(id: "mark-west-quote", title: "The West is not the story they told.", subtitle: "It is the truth they buried.", layout: .quoteCard, exportPresetIDs: ["instagramSquare", "tikTokVertical", "posterExport"], assetName: "mark_west_dark_quote", isInternalOnly: false),
            HFProjectPackagingItem(id: "mark-west-queho", title: "Queho", subtitle: "Character card", layout: .characterCard, exportPresetIDs: ["tikTokVertical", "instagramReelStory", "posterExport"], assetName: "mark_west_character_queho", isInternalOnly: false),
            HFProjectPackagingItem(id: "mark-west-world", title: "World / Locations", subtitle: "Desert, mountain, and frontier atmosphere", layout: .worldLocations, exportPresetIDs: ["linkedInLandscape", "pressKitSlide"], assetName: "mark_west_world_locations", isInternalOnly: false),
            HFProjectPackagingItem(id: "mark-west-pitch", title: "Pitch at a Glance", subtitle: "Internal preview card", layout: .pitchAtGlance, exportPresetIDs: ["pressKitSlide", "linkedInLandscape"], assetName: "mark_west_pitch_at_glance", isInternalOnly: true),
            HFProjectPackagingItem(id: "mark-west-budget", title: "Budget / Investment", subtitle: "Internal packaging only", layout: .budgetInternal, exportPresetIDs: ["pressKitSlide"], assetName: nil, isInternalOnly: true)
        ],
        activitySignals: [
            HFProjectActivitySignal(id: "mark-west-package-seeded", title: "Promo kit seeded", detail: "Packaging Studio reads this project from the shared local store.", systemImage: "shippingbox.fill"),
            HFProjectActivitySignal(id: "mark-west-key-art", title: "Key art direction staged", detail: "Hero, quote, character, and pitch cards are draft-ready.", systemImage: "photo.fill")
        ],
        blockers: [
            HFProjectBlocker(id: "mark-west-trailer", title: "Trailer concept pending", status: "Blocking", systemImage: "film.fill"),
            HFProjectBlocker(id: "mark-west-cast", title: "Cast card copy needs review", status: "Pending", systemImage: "person.2.fill"),
            HFProjectBlocker(id: "mark-west-budget", title: "Internal budget card requires owner sign-off", status: "Internal", systemImage: "lock.fill")
        ],
        launchChecklist: [
            HFProjectChecklistItem(id: "mark-west-package", title: "Packaging board", status: "In Progress", systemImage: "shippingbox.fill"),
            HFProjectChecklistItem(id: "mark-west-assets", title: "Key art assets", status: "Draft", systemImage: "rectangle.stack.fill"),
            HFProjectChecklistItem(id: "mark-west-review", title: "Owner review", status: "Pending", systemImage: "person.crop.circle.badge.checkmark")
        ]
    )

    private static let paranormall = HFProject(
        id: .paranormall,
        movieID: "paranormall-s1",
        title: "Paranormall",
        shortTitle: "Paranormall",
        creator: "HighFive Cinema",
        format: .series,
        genre: "Horror",
        runtime: "7 episodes",
        synopsis: "A mall security guard discovers an Ouija board during a quiet shift and unlocks something inside the mall.",
        posterAssetName: "paranormall",
        lifecycleState: .streaming,
        workflowStage: "Series Preview",
        packageStatus: "Preview",
        releaseState: "Streaming Preview",
        readiness: HFProjectReadiness(overall: 0.81, package: 0.76, assets: 0.84, teamReview: 0.78, blockers: 1, status: "Preview Ready"),
        assetState: HFProjectAssetState(poster: "Ready", trailer: "Needs Review", artwork: "Ready", metadata: "Ready", thumbnail: "Poster Thumbnail Ready"),
        reviewNotes: 2,
        marketplaceInterest: 37,
        audienceSaves: "8.1K",
        teamMembers: 4,
        versionRounds: 2,
        tags: ["Horror", "Series", "Vertical"],
        packagingItems: [],
        activitySignals: [
            HFProjectActivitySignal(id: "paranormall-fan-room", title: "Fan room trending", detail: "Connect and discovery surfaces use the shared project title.", systemImage: "sparkles"),
            HFProjectActivitySignal(id: "paranormall-series-preview", title: "Season preview synced", detail: "Studio Intelligence can compare series readiness with packaging and creator work.", systemImage: "play.square.stack.fill")
        ],
        blockers: [
            HFProjectBlocker(id: "paranormall-trailer", title: "Trailer timing needs final review", status: "Pending", systemImage: "film.fill")
        ],
        launchChecklist: [
            HFProjectChecklistItem(id: "paranormall-episodes", title: "Episode metadata", status: "Ready", systemImage: "text.badge.checkmark"),
            HFProjectChecklistItem(id: "paranormall-room", title: "Fan room preview", status: "Active", systemImage: "person.3.fill")
        ]
    )

    private static let theFriendly = HFProject(
        id: .theFriendly,
        movieID: "friendly",
        title: "The Friendly",
        shortTitle: "Friendly",
        creator: "InTheLight Productions",
        format: .feature,
        genre: "Drama",
        runtime: "1h 48m",
        synopsis: "Military medic Curtis returns home with Friendly, the dog who saved him, and rebuilds his life while old violence follows.",
        posterAssetName: "the_friendly",
        lifecycleState: .creatorReview,
        workflowStage: "Team Review",
        packageStatus: "In Progress",
        releaseState: "Creator Package",
        readiness: HFProjectReadiness(overall: 0.72, package: 0.68, assets: 0.75, teamReview: 0.72, blockers: 2, status: "On track"),
        assetState: HFProjectAssetState(poster: "Ready", trailer: "Needs Review", artwork: "Ready", metadata: "Ready", thumbnail: "Poster Thumbnail Ready"),
        reviewNotes: 5,
        marketplaceInterest: 48,
        audienceSaves: "1.2K",
        teamMembers: 4,
        versionRounds: 3,
        tags: ["Drama", "War", "Creator Package"],
        packagingItems: [],
        activitySignals: [
            HFProjectActivitySignal(id: "friendly-poster", title: "Poster artwork approved", detail: "Creative Lead cleared the package artwork.", systemImage: "checkmark.seal.fill"),
            HFProjectActivitySignal(id: "friendly-trailer", title: "Trailer cut flagged for review", detail: "Opening sequence needs one more pass.", systemImage: "film.fill"),
            HFProjectActivitySignal(id: "friendly-metadata", title: "Metadata updated", detail: "Synopsis and cast details were refreshed.", systemImage: "text.badge.checkmark"),
            HFProjectActivitySignal(id: "friendly-permissions", title: "Team permissions reviewed", detail: "Reviewer roles are ready for preview.", systemImage: "checkmark.shield.fill"),
            HFProjectActivitySignal(id: "friendly-marketplace", title: "Marketplace preview generated", detail: "Listing signals are ready for the mock marketplace.", systemImage: "storefront.fill")
        ],
        blockers: [
            HFProjectBlocker(id: "friendly-trailer-opening", title: "Trailer opening needs review", status: "Blocking", systemImage: "film.fill"),
            HFProjectBlocker(id: "friendly-cast-credits", title: "Cast credits need confirmation", status: "Blocking", systemImage: "person.2.fill"),
            HFProjectBlocker(id: "friendly-submission-notes", title: "Submission notes incomplete", status: "Pending", systemImage: "note.text"),
            HFProjectBlocker(id: "friendly-team-signoff", title: "Team sign-off pending", status: "Pending", systemImage: "person.3.fill")
        ],
        launchChecklist: [
            HFProjectChecklistItem(id: "friendly-package", title: "Package complete", status: "In Progress", systemImage: "shippingbox.fill"),
            HFProjectChecklistItem(id: "friendly-assets", title: "Assets reviewed", status: "Needs Review", systemImage: "rectangle.stack.fill"),
            HFProjectChecklistItem(id: "friendly-team", title: "Team sign-off", status: "Pending", systemImage: "person.3.fill"),
            HFProjectChecklistItem(id: "friendly-marketplace-check", title: "Marketplace preview", status: "Preview Only", systemImage: "storefront.fill"),
            HFProjectChecklistItem(id: "friendly-access", title: "Access setup", status: "Mock Only", systemImage: "lock.shield.fill"),
            HFProjectChecklistItem(id: "friendly-release", title: "Release plan", status: "Not Started", systemImage: "flag.checkered")
        ]
    )
}
