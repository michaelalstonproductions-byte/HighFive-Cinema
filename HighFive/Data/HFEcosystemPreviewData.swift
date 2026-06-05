import Foundation

enum HFEcosystemPreviewData {
    static let todaySummaryItems: [HFTodaySummaryItem] = [
        HFTodaySummaryItem(title: "Continue Watching", value: "The Friendly", caption: "Resume your local preview", systemImage: "play.circle.fill"),
        HFTodaySummaryItem(title: "Creator package", value: "72% ready", caption: "Team review active", systemImage: "checkmark.seal.fill"),
        HFTodaySummaryItem(title: "Connect activity", value: "5 updates", caption: "Rooms and creators", systemImage: "bell.badge.fill"),
        HFTodaySummaryItem(title: "Launch status", value: "Preview Planning", caption: "Mock readiness", systemImage: "rocket.fill")
    ]

    static let createHighlights: [HFEcosystemHighlight] = [
        HFEcosystemHighlight(title: "Creator Command Center", subtitle: "Track package, review, versions, and launch readiness.", category: "Create", status: "72%", systemImage: "rectangle.grid.2x2.fill"),
        HFEcosystemHighlight(title: "Package Builder", subtitle: "Continue assembling The Friendly creator package.", category: "Create", status: "In Progress", systemImage: "shippingbox.fill"),
        HFEcosystemHighlight(title: "Launch Center", subtitle: "Preview audience, marketplace, and release planning.", category: "Launch", status: "Preview", systemImage: "rocket.fill"),
        HFEcosystemHighlight(title: "Release Readiness", subtitle: "Review blockers, ready items, and launch path.", category: "Launch", status: "72%", systemImage: "gauge.with.dots.needle.bottom.50percent")
    ]

    static let connectHighlights: [HFEcosystemHighlight] = [
        HFEcosystemHighlight(title: "Community Discovery", subtitle: "Find creator communities and project circles.", category: "Connect", status: "Preview", systemImage: "person.3.fill"),
        HFEcosystemHighlight(title: "Social Rooms", subtitle: "Preview creator-led rooms for reviews and watch circles.", category: "Connect", status: "Live Mock", systemImage: "bubble.left.and.bubble.right.fill"),
        HFEcosystemHighlight(title: "Creator Circles", subtitle: "Explore mock collaborator networks and creative teams.", category: "Connect", status: "Preview", systemImage: "circle.hexagongrid.fill"),
        HFEcosystemHighlight(title: "Watch Party Preview", subtitle: "Preview shared viewing without playback sync.", category: "Connect", status: "Mock Only", systemImage: "play.tv.fill"),
        HFEcosystemHighlight(title: "Activity Feed", subtitle: "Review local project updates and community signals.", category: "Connect", status: "Local", systemImage: "text.bubble.fill")
    ]

    static let launchHighlights: [HFEcosystemHighlight] = [
        HFEcosystemHighlight(title: "Launch Center", subtitle: "Prepare package, audience, and marketplace previews.", category: "Launch", status: "Planning", systemImage: "rocket.fill"),
        HFEcosystemHighlight(title: "Access Preview", subtitle: "Mock premium package access without real purchases.", category: "Access", status: "Mock Only", systemImage: "lock.shield.fill"),
        HFEcosystemHighlight(title: "Release Presentation", subtitle: "Open the HighFive preview overview for demos.", category: "Release", status: "Ready", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFEcosystemHighlight(title: "Demo Checklist", subtitle: "Walk through the current local preview build.", category: "Release", status: "QA", systemImage: "checklist.checked")
    ]

    static let contentCategories: [HFDiscoveryCategory] = [
        HFDiscoveryCategory(title: "Movies", subtitle: "Browse cinematic originals and previews.", category: "Movies", systemImage: "film.fill"),
        HFDiscoveryCategory(title: "Originals", subtitle: "HighFive originals and featured stories.", category: "Movies", systemImage: "star.fill"),
        HFDiscoveryCategory(title: "Coming Soon", subtitle: "Upcoming local preview titles.", category: "Movies", systemImage: "calendar.badge.clock"),
        HFDiscoveryCategory(title: "Downloads", subtitle: "Offline-ready local mock downloads.", category: "Movies", systemImage: "arrow.down.circle.fill"),
        HFDiscoveryCategory(title: "My List", subtitle: "Saved titles and in-progress viewing.", category: "Movies", systemImage: "bookmark.fill")
    ]

    static let creatorCategories: [HFDiscoveryCategory] = [
        HFDiscoveryCategory(title: "Creator Studio Preview", subtitle: "Open the local creator studio shell.", category: "Creators", systemImage: "wand.and.stars"),
        HFDiscoveryCategory(title: "Creator Dashboard Preview", subtitle: "Review creator metrics and workflow status.", category: "Creators", systemImage: "chart.bar.fill"),
        HFDiscoveryCategory(title: "Creator Marketplace Preview", subtitle: "Preview marketplace-ready creator packages.", category: "Marketplace", systemImage: "storefront.fill"),
        HFDiscoveryCategory(title: "Creator Command Center", subtitle: "Track package, assets, review, and launch state.", category: "Creators", systemImage: "rectangle.grid.2x2.fill"),
        HFDiscoveryCategory(title: "Launch Center", subtitle: "Prepare release planning and audience previews.", category: "Launch", systemImage: "rocket.fill")
    ]

    static let communityCategories: [HFDiscoveryCategory] = [
        HFDiscoveryCategory(title: "Connect Hub", subtitle: "Open creator discovery and community previews.", category: "Communities", systemImage: "person.2.fill"),
        HFDiscoveryCategory(title: "Social Rooms", subtitle: "Preview rooms for watch circles and reviews.", category: "Communities", systemImage: "bubble.left.and.bubble.right.fill"),
        HFDiscoveryCategory(title: "Creator Circles", subtitle: "Find mock collaborator networks.", category: "Communities", systemImage: "circle.hexagongrid.fill"),
        HFDiscoveryCategory(title: "Watch Parties", subtitle: "Preview shared viewing rooms.", category: "Watch Parties", systemImage: "play.tv.fill"),
        HFDiscoveryCategory(title: "Project Communities", subtitle: "Follow project updates and launch signals.", category: "Communities", systemImage: "film.stack.fill")
    ]

    static let trendingItems: [HFTrendingEcosystemItem] = [
        HFTrendingEcosystemItem(title: "The Friendly — Creator Package", subtitle: "Team review and launch readiness are active.", category: "Creators", status: "72%", systemImage: "shippingbox.fill"),
        HFTrendingEcosystemItem(title: "Paranormall — Fan Room", subtitle: "Community discussion is trending in preview.", category: "Communities", status: "8.1K", systemImage: "sparkles"),
        HFTrendingEcosystemItem(title: "Black Turnip — Coming Soon", subtitle: "Upcoming title with rising local saves.", category: "Movies", status: "Soon", systemImage: "film.fill"),
        HFTrendingEcosystemItem(title: "Creator Launch Lab", subtitle: "Release planning and marketplace interest.", category: "Launch", status: "Preview", systemImage: "hammer.fill"),
        HFTrendingEcosystemItem(title: "Poster Artists Circle", subtitle: "Creator circle focused on campaign art.", category: "Communities", status: "Trending", systemImage: "paintpalette.fill")
    ]

    static let discoveryFilters = [
        "All",
        "Movies",
        "Creators",
        "Communities",
        "Launch",
        "Marketplace",
        "Watch Parties"
    ]
}

struct HFEcosystemHighlight: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let status: String
    let systemImage: String
}

struct HFDiscoveryCategory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let systemImage: String
}

struct HFTrendingEcosystemItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let status: String
    let systemImage: String
}

struct HFTodaySummaryItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
    let systemImage: String
}
