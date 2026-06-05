import Foundation

enum HFPersonalizationPreviewData {
    static let smartSignals: [HFPersonalSignal] = [
        HFPersonalSignal(title: "Watching", value: "2 in progress", caption: "The Friendly and Behind the Vision", systemImage: "play.circle.fill"),
        HFPersonalSignal(title: "Creator package", value: "72% ready", caption: "Package Builder is active", systemImage: "shippingbox.fill"),
        HFPersonalSignal(title: "Connect activity", value: "5 new updates", caption: "Rooms, circles, and project notes", systemImage: "bell.badge.fill"),
        HFPersonalSignal(title: "Launch readiness", value: "72%", caption: "Two blockers remain in preview", systemImage: "flag.checkered")
    ]

    static let recommendedNext: [HFPersonalizedRecommendation] = [
        HFPersonalizedRecommendation(title: "Continue Watching", subtitle: "Resume The Friendly from your local progress.", category: "Viewer", reason: "You started this title", destinationType: "watch", systemImage: "play.fill", accentLabel: "Resume"),
        HFPersonalizedRecommendation(title: "Continue Package Builder", subtitle: "Finish credits, notes, and package details.", category: "Creator", reason: "Your package is in progress", destinationType: "packageBuilder", systemImage: "shippingbox.fill", accentLabel: "Next"),
        HFPersonalizedRecommendation(title: "Open Release Readiness", subtitle: "Review blockers and launch path signals.", category: "Launch", reason: "Readiness is 72%", destinationType: "releaseReadiness", systemImage: "gauge.with.dots.needle.67percent", accentLabel: "72%"),
        HFPersonalizedRecommendation(title: "Explore Connect", subtitle: "Open creator updates and community previews.", category: "Connect", reason: "5 local updates are waiting", destinationType: "connectHub", systemImage: "person.2.fill", accentLabel: "Local")
    ]

    static let viewerRecommendations: [HFPersonalizedRecommendation] = [
        HFPersonalizedRecommendation(title: "Continue The Friendly", subtitle: "Pick up your featured premiere.", category: "Viewer", reason: "In progress", destinationType: "movie:friendly", systemImage: "play.circle.fill", accentLabel: "42%"),
        HFPersonalizedRecommendation(title: "Discover Paranormall Fan Room", subtitle: "Open the community path around Paranormall.", category: "Connect", reason: "You watched a HighFive original", destinationType: "watchParty", systemImage: "sparkles", accentLabel: "Fan Room"),
        HFPersonalizedRecommendation(title: "Save Black Turnip", subtitle: "A local coming-soon title with rising interest.", category: "Viewer", reason: "Matches your slate", destinationType: "movie:black-turnip", systemImage: "bookmark.fill", accentLabel: "Soon"),
        HFPersonalizedRecommendation(title: "Explore Watch Party Preview", subtitle: "Preview shared viewing without live sync.", category: "Connect", reason: "Related to your watchlist", destinationType: "watchParty", systemImage: "play.tv.fill", accentLabel: "Mock")
    ]

    static let creatorRecommendations: [HFPersonalizedRecommendation] = [
        HFPersonalizedRecommendation(title: "Package Builder", subtitle: "Continue assembling The Friendly package.", category: "Creator", reason: "Credits need review", destinationType: "packageBuilder", systemImage: "shippingbox.fill", accentLabel: "Active"),
        HFPersonalizedRecommendation(title: "Asset Manager", subtitle: "Review artwork, trailer, and supporting assets.", category: "Creator", reason: "Assets need review", destinationType: "assetManager", systemImage: "rectangle.stack.fill", accentLabel: "Review"),
        HFPersonalizedRecommendation(title: "Team Review", subtitle: "Open internal reviewer notes and sign-off state.", category: "Creator", reason: "Current stage", destinationType: "teamReview", systemImage: "person.3.fill", accentLabel: "Current"),
        HFPersonalizedRecommendation(title: "Version History", subtitle: "Track local package rounds and changes.", category: "Creator", reason: "3 rounds logged", destinationType: "versionHistory", systemImage: "clock.arrow.circlepath", accentLabel: "Tracking")
    ]

    static let launchRecommendations: [HFPersonalizedRecommendation] = [
        HFPersonalizedRecommendation(title: "Open Release Readiness", subtitle: "Check blockers, ready items, and launch path.", category: "Launch", reason: "72% ready", destinationType: "releaseReadiness", systemImage: "gauge.with.dots.needle.67percent", accentLabel: "72%"),
        HFPersonalizedRecommendation(title: "Review Launch Center", subtitle: "Preview package, audience, and release planning.", category: "Launch", reason: "Planning is active", destinationType: "launchCenter", systemImage: "flag.checkered", accentLabel: "Plan"),
        HFPersonalizedRecommendation(title: "Preview Access Model", subtitle: "Review mock unlock paths with local data only.", category: "Access", reason: "Access setup is mock-only", destinationType: "accessPreview", systemImage: "lock.shield.fill", accentLabel: "Mock"),
        HFPersonalizedRecommendation(title: "View Demo Checklist", subtitle: "Walk the current preview build route list.", category: "Release", reason: "QA path is ready", destinationType: "demoChecklist", systemImage: "checklist.checked", accentLabel: "QA")
    ]

    static let connectRecommendations: [HFPersonalizedRecommendation] = [
        HFPersonalizedRecommendation(title: "Follow Creative Lead", subtitle: "Preview a creator connection from The Friendly.", category: "Connect", reason: "Works on your active package", destinationType: "creatorProfile", systemImage: "person.crop.circle.badge.plus", accentLabel: "Mock"),
        HFPersonalizedRecommendation(title: "Join The Friendly Watch Room", subtitle: "Open a local room around trailer notes.", category: "Connect", reason: "Matches your active title", destinationType: "socialRooms", systemImage: "bubble.left.and.bubble.right.fill", accentLabel: "Room"),
        HFPersonalizedRecommendation(title: "Explore Creator Circles", subtitle: "Find directors, editors, and poster artists.", category: "Connect", reason: "Relevant collaborators", destinationType: "creatorCircles", systemImage: "circle.hexagongrid.fill", accentLabel: "Circles"),
        HFPersonalizedRecommendation(title: "Open Activity Feed", subtitle: "Review creator notes and project updates.", category: "Connect", reason: "5 updates available", destinationType: "activityFeed", systemImage: "text.bubble.fill", accentLabel: "Feed")
    ]

    static let recommendedPath = HFRecommendedPath(
        title: "Launch The Friendly Package",
        subtitle: "A local preview path from package work to audience access.",
        steps: [
            "Finish Package Builder",
            "Review Assets",
            "Prepare Submission",
            "Open Team Review",
            "Check Launch Center",
            "Preview Access"
        ],
        status: "72%",
        systemImage: "map.fill"
    )

    static let homeRecommendations: [HFPersonalizedRecommendation] = [
        HFPersonalizedRecommendation(title: "Personalized Hub", subtitle: "Open smart local paths across HighFive.", category: "For You", reason: "Built from local preview state", destinationType: "personalizedHub", systemImage: "sparkles", accentLabel: "For You"),
        HFPersonalizedRecommendation(title: "Continue Package Builder", subtitle: "Resume The Friendly creator package.", category: "Creator", reason: "In progress", destinationType: "packageBuilder", systemImage: "shippingbox.fill", accentLabel: "Next"),
        HFPersonalizedRecommendation(title: "Explore Connect", subtitle: "Open community and creator signals.", category: "Connect", reason: "5 local updates", destinationType: "connectHub", systemImage: "person.2.fill", accentLabel: "Local"),
        HFPersonalizedRecommendation(title: "Open Launch Center", subtitle: "Preview release and audience planning.", category: "Launch", reason: "Preview Planning", destinationType: "launchCenter", systemImage: "flag.checkered", accentLabel: "Plan")
    ]

    static let recommendedCommunities = [
        "The Friendly Watch Room",
        "Creator Launch Lab",
        "Poster Artists Circle",
        "Paranormall Fan Room"
    ]
}

struct HFPersonalizedRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let reason: String
    let destinationType: String
    let systemImage: String
    let accentLabel: String
}

struct HFPersonalSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
    let systemImage: String
}

struct HFRecommendedPath: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let steps: [String]
    let status: String
    let systemImage: String
}
