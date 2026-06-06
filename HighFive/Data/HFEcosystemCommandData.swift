import Foundation

enum HFEcosystemCommandData {
    static let metrics: [HFEcosystemMetric] = [
        HFEcosystemMetric(title: "Watch", value: "5 titles", caption: "Local preview slate", systemImage: "play.rectangle.fill"),
        HFEcosystemMetric(title: "Create", value: "7 steps", caption: "Creator package path", systemImage: "shippingbox.fill"),
        HFEcosystemMetric(title: "Connect", value: "8 previews", caption: "Communities and rooms", systemImage: "person.2.fill"),
        HFEcosystemMetric(title: "Launch", value: "72%", caption: "Readiness preview", systemImage: "flag.checkered"),
        HFEcosystemMetric(title: "Access", value: "Mock only", caption: "No purchases connected", systemImage: "lock.shield.fill"),
        HFEcosystemMetric(title: "Personalized", value: "Local paths", caption: "Export roadmap included", systemImage: "sparkles")
    ]

    static let priorities: [HFEcosystemPriority] = [
        HFEcosystemPriority(title: "Continue The Friendly watch path", subtitle: "Open the featured title and keep the demo story moving.", destinationType: "movie:friendly", status: "Watch", systemImage: "play.fill"),
        HFEcosystemPriority(title: "Open For You", subtitle: "Review local paths across Watch, Create, Connect, Launch, and future Export.", destinationType: "personalizedHub", status: "For You", systemImage: "sparkles"),
        HFEcosystemPriority(title: "Continue Package Builder", subtitle: "Finish creator package details for the local preview.", destinationType: "packageBuilder", status: "Next", systemImage: "shippingbox.fill"),
        HFEcosystemPriority(title: "Preview Launch Center blockers", subtitle: "Check readiness cards without connecting launch services.", destinationType: "launchCenter", status: "Plan", systemImage: "flag.checkered"),
        HFEcosystemPriority(title: "Open recommended communities", subtitle: "See rooms, circles, and Connect signals as mock previews.", destinationType: "connectHub", status: "Local", systemImage: "person.2.fill"),
        HFEcosystemPriority(title: "Check Access Preview", subtitle: "Review future audience access as local-only copy.", destinationType: "accessPreview", status: "Mock", systemImage: "lock.shield.fill")
    ]

    static let watchItems: [HFEcosystemCommandItem] = [
        HFEcosystemCommandItem(title: "Home", subtitle: "Return to the streaming first screen.", category: "Watch", status: "Tab", systemImage: "house.fill", destinationType: "home"),
        HFEcosystemCommandItem(title: "Search / Discover", subtitle: "Browse movies, creators, communities, and launch previews.", category: "Watch", status: "Discover", systemImage: "magnifyingglass", destinationType: "discover"),
        HFEcosystemCommandItem(title: "Personalized Hub", subtitle: "Open local smart recommendations.", category: "Personalized", status: "For You", systemImage: "sparkles", destinationType: "personalizedHub"),
        HFEcosystemCommandItem(title: "My List", subtitle: "Open saved titles.", category: "Watch", status: "Saved", systemImage: "bookmark.fill", destinationType: "myList"),
        HFEcosystemCommandItem(title: "Downloads", subtitle: "Review offline-ready local titles.", category: "Watch", status: "Local", systemImage: "arrow.down.circle.fill", destinationType: "downloads"),
        HFEcosystemCommandItem(title: "The Friendly", subtitle: "Open the featured title detail.", category: "Watch", status: "Detail", systemImage: "film.fill", destinationType: "movie:friendly")
    ]

    static let createItems: [HFEcosystemCommandItem] = [
        HFEcosystemCommandItem(title: "Creator Hub", subtitle: "Enter Creator Mode.", category: "Create", status: "Preview", systemImage: "wand.and.stars", destinationType: "creatorHub"),
        HFEcosystemCommandItem(title: "Creator Command Center", subtitle: "Build workflow and readiness.", category: "Create", status: "72%", systemImage: "command", destinationType: "creatorCommand"),
        HFEcosystemCommandItem(title: "Creator Studio", subtitle: "Preview studio tools.", category: "Create", status: "Studio", systemImage: "film.stack.fill", destinationType: "creatorStudio"),
        HFEcosystemCommandItem(title: "Creator Dashboard", subtitle: "Review project signals.", category: "Create", status: "Mock", systemImage: "chart.bar.xaxis", destinationType: "creatorDashboard"),
        HFEcosystemCommandItem(title: "Creator Marketplace Preview", subtitle: "Preview marketplace readiness.", category: "Create", status: "Preview", systemImage: "storefront.fill", destinationType: "creatorMarketplace"),
        HFEcosystemCommandItem(title: "Package Builder", subtitle: "Continue The Friendly package.", category: "Create", status: "Active", systemImage: "shippingbox.fill", destinationType: "packageBuilder"),
        HFEcosystemCommandItem(title: "Asset Manager", subtitle: "Review artwork and package materials.", category: "Create", status: "Review", systemImage: "rectangle.stack.fill", destinationType: "assetManager"),
        HFEcosystemCommandItem(title: "Submission Workflow", subtitle: "Preview submission gates.", category: "Create", status: "Draft", systemImage: "paperplane.fill", destinationType: "submissionWorkflow"),
        HFEcosystemCommandItem(title: "Team Review", subtitle: "Open reviewer notes.", category: "Create", status: "Current", systemImage: "person.3.fill", destinationType: "teamReview"),
        HFEcosystemCommandItem(title: "Version History", subtitle: "Track package rounds.", category: "Create", status: "Tracking", systemImage: "clock.arrow.circlepath", destinationType: "versionHistory"),
        HFEcosystemCommandItem(title: "Team Permissions", subtitle: "Review local roles.", category: "Create", status: "Mock", systemImage: "person.3.sequence.fill", destinationType: "teamPermissions")
    ]

    static let connectItems: [HFEcosystemCommandItem] = [
        HFEcosystemCommandItem(title: "Connect Hub", subtitle: "Open creator and community preview.", category: "Connect", status: "Local", systemImage: "person.2.fill", destinationType: "connectHub"),
        HFEcosystemCommandItem(title: "Community Discovery", subtitle: "Find communities and project circles.", category: "Connect", status: "Preview", systemImage: "person.3.fill", destinationType: "communityDiscovery"),
        HFEcosystemCommandItem(title: "Social Rooms", subtitle: "Preview discussion rooms.", category: "Connect", status: "Rooms", systemImage: "bubble.left.and.bubble.right.fill", destinationType: "socialRooms"),
        HFEcosystemCommandItem(title: "Creator Circles", subtitle: "Explore collaborator circles.", category: "Connect", status: "Circles", systemImage: "circle.hexagongrid.fill", destinationType: "creatorCircles"),
        HFEcosystemCommandItem(title: "Watch Party Preview", subtitle: "Open shared viewing preview without live sync.", category: "Connect", status: "Mock", systemImage: "play.tv.fill", destinationType: "watchParty"),
        HFEcosystemCommandItem(title: "Project Community", subtitle: "Follow project room signals.", category: "Connect", status: "Project", systemImage: "film.stack.fill", destinationType: "projectCommunity"),
        HFEcosystemCommandItem(title: "Activity Feed", subtitle: "Review project updates.", category: "Connect", status: "Feed", systemImage: "text.bubble.fill", destinationType: "activityFeed"),
        HFEcosystemCommandItem(title: "Social Graph", subtitle: "Map local relationships.", category: "Connect", status: "Mock", systemImage: "point.3.connected.trianglepath.dotted", destinationType: "socialGraph"),
        HFEcosystemCommandItem(title: "Follow Suggestions", subtitle: "Preview local follow suggestions.", category: "Connect", status: "Mock", systemImage: "person.crop.circle.badge.plus", destinationType: "followSuggestions"),
        HFEcosystemCommandItem(title: "Connect Notifications", subtitle: "Preview local social updates.", category: "Connect", status: "Local", systemImage: "bell.badge.fill", destinationType: "connectNotifications")
    ]

    static let launchItems: [HFEcosystemCommandItem] = [
        HFEcosystemCommandItem(title: "Release Readiness", subtitle: "Review launch blockers.", category: "Launch", status: "72%", systemImage: "gauge.with.dots.needle.67percent", destinationType: "releaseReadiness"),
        HFEcosystemCommandItem(title: "Launch Center", subtitle: "Preview launch planning.", category: "Launch", status: "Plan", systemImage: "flag.checkered", destinationType: "launchCenter"),
        HFEcosystemCommandItem(title: "Access Preview", subtitle: "Review mock unlock paths.", category: "Access", status: "Mock", systemImage: "lock.shield.fill", destinationType: "accessPreview"),
        HFEcosystemCommandItem(title: "Release Presentation", subtitle: "Open the local product story.", category: "Release", status: "Ready", systemImage: "rectangle.on.rectangle.angled.fill", destinationType: "releasePresentation"),
        HFEcosystemCommandItem(title: "Demo Checklist", subtitle: "Walk Watch, Create, Connect, and Launch routes.", category: "Release", status: "QA", systemImage: "checklist.checked", destinationType: "demoChecklist"),
        HFEcosystemCommandItem(title: "Onboarding Preview", subtitle: "Preview first-run story.", category: "Release", status: "Preview", systemImage: "rectangle.stack.badge.play.fill", destinationType: "onboardingPreview")
    ]

    static let personalizedItems: [HFEcosystemCommandItem] = [
        HFEcosystemCommandItem(title: "Personalized Hub", subtitle: "Open all local smart paths.", category: "Personalized", status: "For You", systemImage: "sparkles", destinationType: "personalizedHub"),
        HFEcosystemCommandItem(title: "Smart Recommendations", subtitle: "Review static next actions.", category: "Personalized", status: "Local", systemImage: "wand.and.stars", destinationType: "personalizedHub"),
        HFEcosystemCommandItem(title: "Recommended Path", subtitle: "Follow the local watch-to-launch path.", category: "Personalized", status: "Path", systemImage: "map.fill", destinationType: "personalizedHub"),
        HFEcosystemCommandItem(title: "Because You Watched", subtitle: "Open viewer recommendations.", category: "Personalized", status: "Watch", systemImage: "play.circle.fill", destinationType: "personalizedHub"),
        HFEcosystemCommandItem(title: "Because You Create", subtitle: "Open creator recommendations.", category: "Personalized", status: "Create", systemImage: "shippingbox.fill", destinationType: "personalizedHub"),
        HFEcosystemCommandItem(title: "Because You Connect", subtitle: "Open community recommendations.", category: "Personalized", status: "Connect", systemImage: "person.2.fill", destinationType: "personalizedHub")
    ]

    static let demoItems: [HFEcosystemCommandItem] = [
        HFEcosystemCommandItem(title: "Release Presentation", subtitle: "Open the local partner presentation preview.", category: "Demo", status: "Preview", systemImage: "rectangle.on.rectangle.angled.fill", destinationType: "releasePresentation"),
        HFEcosystemCommandItem(title: "Demo Checklist", subtitle: "Review local QA routes without capture, export, or share systems.", category: "Demo", status: "Local", systemImage: "checklist.checked", destinationType: "demoChecklist"),
        HFEcosystemCommandItem(title: "Onboarding Preview", subtitle: "Preview first-run story copy with no account setup.", category: "Demo", status: "Preview", systemImage: "rectangle.stack.badge.play.fill", destinationType: "onboardingPreview")
    ]

    static let smartNextStepPath: [HFEcosystemPathStep] = [
        HFEcosystemPathStep(title: "Home", systemImage: "house.fill"),
        HFEcosystemPathStep(title: "For You", systemImage: "sparkles"),
        HFEcosystemPathStep(title: "Creator Command Center", systemImage: "command"),
        HFEcosystemPathStep(title: "Connect Hub", systemImage: "person.2.fill"),
        HFEcosystemPathStep(title: "Launch Center", systemImage: "flag.checkered"),
        HFEcosystemPathStep(title: "Access Preview", systemImage: "lock.shield.fill")
    ]
}

struct HFEcosystemCommandItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let status: String
    let systemImage: String
    let destinationType: String
}

struct HFEcosystemMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
    let systemImage: String
}

struct HFEcosystemPriority: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let destinationType: String
    let status: String
    let systemImage: String
}

struct HFEcosystemPathStep: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
}
