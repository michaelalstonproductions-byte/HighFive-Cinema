import Foundation

struct HFProductSpineCompletionPillar: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let goal: String
    let status: String
    let systemImage: String
}

struct HFProductSpineRouteItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let status: String
    let routeType: String
    let systemImage: String
}

struct HFProductSpineCoverageSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
    let status: String
    let systemImage: String
}

struct HFProductSpineLockItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let lockCategory: String
    let status: String
    let systemImage: String
}

struct HFVisualParityBacklogItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let screenGroup: String
    let priority: String
    let status: String
    let systemImage: String
}

enum HFProductSpineCompletionData {
    static let pillars: [HFProductSpineCompletionPillar] = [
        HFProductSpineCompletionPillar(
            title: "Watch",
            subtitle: "Find and review cinematic titles locally.",
            goal: "Viewer can find and watch cinematic titles locally.",
            status: "Local routes",
            systemImage: "play.rectangle.fill"
        ),
        HFProductSpineCompletionPillar(
            title: "Create",
            subtitle: "Preview creator workflow from studio to release readiness.",
            goal: "Creator can preview workflow from studio to package to release readiness.",
            status: "Local routes",
            systemImage: "shippingbox.fill"
        ),
        HFProductSpineCompletionPillar(
            title: "Connect",
            subtitle: "Discover community and creator relationship previews.",
            goal: "Community and creator relationship previews are discoverable.",
            status: "Local routes",
            systemImage: "person.2.fill"
        ),
        HFProductSpineCompletionPillar(
            title: "Launch",
            subtitle: "Reach launch planning, access preview, and release prep.",
            goal: "Launch planning and access preview are reachable.",
            status: "Local routes",
            systemImage: "flag.checkered"
        ),
        HFProductSpineCompletionPillar(
            title: "Export",
            subtitle: "Keep export, share, and capture preview-only and safety-gated.",
            goal: "Export, share, and capture remains preview-only and safety-gated.",
            status: "Locked preview",
            systemImage: "square.and.arrow.up"
        )
    ]

    static let coverageSignals: [HFProductSpineCoverageSignal] = [
        HFProductSpineCoverageSignal(title: "Watch coverage", value: "Present", caption: "Home, Search, Discovery, Movie Detail, My List, Downloads.", status: "Local", systemImage: "play.rectangle.fill"),
        HFProductSpineCoverageSignal(title: "Create coverage", value: "Present", caption: "Creator Mode, package, team review, readiness.", status: "Local", systemImage: "shippingbox.fill"),
        HFProductSpineCoverageSignal(title: "Connect coverage", value: "Present", caption: "Hub, rooms, circles, activity, graph, suggestions.", status: "Local", systemImage: "person.2.fill"),
        HFProductSpineCoverageSignal(title: "Launch coverage", value: "Present", caption: "Launch Center, access, presentation, checklist, RC prep.", status: "Local", systemImage: "flag.checkered"),
        HFProductSpineCoverageSignal(title: "Export coverage", value: "Documented", caption: "Preview-only routes are locked or marked as future placeholders.", status: "Locked", systemImage: "lock.shield.fill"),
        HFProductSpineCoverageSignal(title: "Real systems", value: "Locked", caption: "Backend, payment, upload, capture, share, playback, and protected systems stay disconnected.", status: "Locked", systemImage: "shield.lefthalf.filled"),
        HFProductSpineCoverageSignal(title: "Visual parity", value: "Later", caption: "Mockup matching starts after the spine is complete and QA-ready.", status: "Backlog", systemImage: "rectangle.3.group.fill"),
        HFProductSpineCoverageSignal(title: "Repo truth", value: "Required", caption: "Build, commit, tag, QA, and QA tag remain outside the app.", status: "Manual", systemImage: "checkmark.seal.fill")
    ]

    static let routeItems: [HFProductSpineRouteItem] = [
        HFProductSpineRouteItem(title: "Home", subtitle: "Primary streaming tab and product entry.", pillar: "Watch", status: "Tab", routeType: "static", systemImage: "house.fill"),
        HFProductSpineRouteItem(title: "Search", subtitle: "Bottom tab search path remains present.", pillar: "Watch", status: "Tab", routeType: "static", systemImage: "magnifyingglass"),
        HFProductSpineRouteItem(title: "Unified Discovery", subtitle: "Local discovery route for browsing the catalog.", pillar: "Watch", status: "Opens", routeType: "unifiedDiscovery", systemImage: "sparkles"),
        HFProductSpineRouteItem(title: "Movie Detail", subtitle: "Review title detail via The Friendly.", pillar: "Watch", status: "Opens", routeType: "movie:friendly", systemImage: "film.fill"),
        HFProductSpineRouteItem(title: "My List", subtitle: "Saved local title list remains reachable.", pillar: "Watch", status: "Opens", routeType: "myList", systemImage: "bookmark.fill"),
        HFProductSpineRouteItem(title: "Downloads", subtitle: "Local downloads tab and route remain reachable.", pillar: "Watch", status: "Opens", routeType: "downloads", systemImage: "arrow.down.circle.fill"),

        HFProductSpineRouteItem(title: "Creator Mode", subtitle: "Creator entry point for the local workflow.", pillar: "Create", status: "Opens", routeType: "creatorMode", systemImage: "wand.and.stars"),
        HFProductSpineRouteItem(title: "Creator Command Center", subtitle: "Map package, review, readiness, and release signals.", pillar: "Create", status: "Opens", routeType: "creatorCommand", systemImage: "command"),
        HFProductSpineRouteItem(title: "Package Builder", subtitle: "Preview assembling creator package details.", pillar: "Create", status: "Opens", routeType: "packageBuilder", systemImage: "shippingbox.fill"),
        HFProductSpineRouteItem(title: "Asset Manager", subtitle: "Static creator asset planning preview.", pillar: "Create", status: "Opens", routeType: "assetManager", systemImage: "tray.full.fill"),
        HFProductSpineRouteItem(title: "Team Review", subtitle: "Review collaborators and approval state locally.", pillar: "Create", status: "Opens", routeType: "teamReview", systemImage: "person.3.fill"),
        HFProductSpineRouteItem(title: "Release Readiness", subtitle: "Check local readiness signals before launch.", pillar: "Create", status: "Opens", routeType: "releaseReadiness", systemImage: "gauge.with.dots.needle.bottom.50percent"),

        HFProductSpineRouteItem(title: "Connect Hub", subtitle: "Local community and relationship entry point.", pillar: "Connect", status: "Opens", routeType: "connectHub", systemImage: "person.2.fill"),
        HFProductSpineRouteItem(title: "Social Rooms", subtitle: "Preview rooms without real messaging.", pillar: "Connect", status: "Opens", routeType: "socialRooms", systemImage: "bubble.left.and.bubble.right.fill"),
        HFProductSpineRouteItem(title: "Creator Circles", subtitle: "Preview creator and collaborator circles.", pillar: "Connect", status: "Opens", routeType: "creatorCircles", systemImage: "circle.hexagongrid.fill"),
        HFProductSpineRouteItem(title: "Activity Feed", subtitle: "Local activity signals for projects and communities.", pillar: "Connect", status: "Opens", routeType: "activityFeed", systemImage: "text.bubble.fill"),
        HFProductSpineRouteItem(title: "Social Graph", subtitle: "Static relationship graph preview.", pillar: "Connect", status: "Opens", routeType: "socialGraph", systemImage: "point.3.connected.trianglepath.dotted"),
        HFProductSpineRouteItem(title: "Follow Suggestions", subtitle: "Local creator suggestion preview.", pillar: "Connect", status: "Opens", routeType: "followSuggestions", systemImage: "person.badge.plus.fill"),
        HFProductSpineRouteItem(title: "Connect Notifications", subtitle: "Local notification preview for Connect.", pillar: "Connect", status: "Opens", routeType: "connectNotifications", systemImage: "bell.badge.fill"),

        HFProductSpineRouteItem(title: "Launch Center", subtitle: "Plan launch, audience, and release previews.", pillar: "Launch", status: "Opens", routeType: "launchCenter", systemImage: "rocket.fill"),
        HFProductSpineRouteItem(title: "Access Preview", subtitle: "Mock access path without purchases.", pillar: "Launch", status: "Opens", routeType: "accessPreview", systemImage: "lock.shield.fill"),
        HFProductSpineRouteItem(title: "Release Presentation", subtitle: "Local product story for stakeholders.", pillar: "Launch", status: "Opens", routeType: "releasePresentation", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFProductSpineRouteItem(title: "Demo Checklist", subtitle: "Static route checklist for local review.", pillar: "Launch", status: "Opens", routeType: "demoChecklist", systemImage: "checklist.checked"),
        HFProductSpineRouteItem(title: "Release Candidate Prep", subtitle: "Local prep surface for final QA readiness.", pillar: "Launch", status: "Opens", routeType: "releaseCandidatePrep", systemImage: "checkmark.seal.fill"),

        HFProductSpineRouteItem(title: "Social Export Hub", subtitle: "Future local placeholder; no real export exists here.", pillar: "Export", status: "Future", routeType: "locked", systemImage: "square.and.arrow.up"),
        HFProductSpineRouteItem(title: "Export Composer", subtitle: "Future preview-only composer placeholder.", pillar: "Export", status: "Future", routeType: "locked", systemImage: "rectangle.and.pencil.and.ellipsis"),
        HFProductSpineRouteItem(title: "Export Queue", subtitle: "Future static queue placeholder; no files are generated.", pillar: "Export", status: "Future", routeType: "locked", systemImage: "tray.full.fill"),
        HFProductSpineRouteItem(title: "Export Safety Center", subtitle: "Future safety placeholder; export remains locked.", pillar: "Export", status: "Future", routeType: "locked", systemImage: "lock.shield.fill"),
        HFProductSpineRouteItem(title: "Protected Capture Roadmap", subtitle: "Future protected scope only; no capture implementation.", pillar: "Export", status: "Future", routeType: "locked", systemImage: "video.slash.fill"),
        HFProductSpineRouteItem(title: "Demo Flow", subtitle: "Future export demo flow placeholder.", pillar: "Export", status: "Future", routeType: "locked", systemImage: "map.fill")
    ]

    static let locks: [HFProductSpineLockItem] = [
        HFProductSpineLockItem(title: "Backend/auth/accounts", subtitle: "No backend, login, real accounts, follows, comments, messages, or recommendations.", lockCategory: "Account + Backend", status: "Locked", systemImage: "server.rack"),
        HFProductSpineLockItem(title: "Payments/StoreKit", subtitle: "No purchases, subscriptions, entitlements, or payment flows.", lockCategory: "Commerce", status: "Locked", systemImage: "creditcard.fill"),
        HFProductSpineLockItem(title: "Uploads/file picker", subtitle: "No uploads, FileManager integration, or real file access.", lockCategory: "Export / Share", status: "Locked", systemImage: "folder.badge.plus"),
        HFProductSpineLockItem(title: "AVPlayer/playback", subtitle: "No real playback, playback sync, or watch-party networking.", lockCategory: "Media / Capture", status: "Locked", systemImage: "play.slash.fill"),
        HFProductSpineLockItem(title: "Camera/ReplayKit/Photos", subtitle: "No camera capture, ReplayKit, screen recording, or Photos permission.", lockCategory: "Media / Capture", status: "Locked", systemImage: "camera.fill"),
        HFProductSpineLockItem(title: "Share sheets/social APIs", subtitle: "No ShareLink, UIActivityViewController, share sheet, or social SDK integration.", lockCategory: "Export / Share", status: "Locked", systemImage: "square.and.arrow.up"),
        HFProductSpineLockItem(title: "Export/render/screenshot pipeline", subtitle: "No screenshot generation, image rendering, PDFs, slides, reports, uploads, or analytics.", lockCategory: "Export / Share", status: "Locked", systemImage: "photo.on.rectangle.angled"),
        HFProductSpineLockItem(title: "Protected depth/playback/motion/rendering", subtitle: "Protected media, depth, playback, motion, and rendering paths remain untouched.", lockCategory: "Media / Capture", status: "Protected", systemImage: "shield.lefthalf.filled"),
        HFProductSpineLockItem(title: "Figma sync", subtitle: "No Figma sync or mockup parity work in this phase.", lockCategory: "Design / Asset", status: "Locked", systemImage: "rectangle.3.group.fill"),
        HFProductSpineLockItem(title: "Asset/poster mapping changes", subtitle: "No asset catalog, poster mapping, backdrop mapping, or visual asset changes.", lockCategory: "Design / Asset", status: "Locked", systemImage: "photo.stack.fill"),
        HFProductSpineLockItem(title: "App Store submission automation", subtitle: "No submission preparation or App Store automation.", lockCategory: "Commerce", status: "Locked", systemImage: "paperplane.fill")
    ]

    static let visualParityBacklog: [HFVisualParityBacklogItem] = [
        HFVisualParityBacklogItem(title: "Match mockup hero layout", subtitle: "Align Home hero composition after spine lock.", screenGroup: "Home + Core Tabs", priority: "High", status: "After Spine Lock", systemImage: "rectangle.topthird.inset.filled"),
        HFVisualParityBacklogItem(title: "Match card spacing and rail density", subtitle: "Tune Home rails once product structure is stable.", screenGroup: "Home + Core Tabs", priority: "High", status: "After Spine Lock", systemImage: "rectangle.grid.2x2.fill"),
        HFVisualParityBacklogItem(title: "Match typography hierarchy", subtitle: "Finalize type scale after route coverage is QA-ready.", screenGroup: "Home + Core Tabs", priority: "High", status: "After Spine Lock", systemImage: "textformat.size"),
        HFVisualParityBacklogItem(title: "Match Movie Detail layout", subtitle: "Align detail hierarchy and action placement later.", screenGroup: "Watch + Movie Detail", priority: "High", status: "After Spine Lock", systemImage: "film.fill"),
        HFVisualParityBacklogItem(title: "Match poster/backdrop treatment", subtitle: "Preserve mappings; tune visual treatment in a separate phase.", screenGroup: "Watch + Movie Detail", priority: "High", status: "After Spine Lock", systemImage: "photo.fill"),
        HFVisualParityBacklogItem(title: "Match safe-area action bar", subtitle: "Review action bar spacing after route QA.", screenGroup: "Watch + Movie Detail", priority: "High", status: "After Spine Lock", systemImage: "rectangle.bottomthird.inset.filled"),
        HFVisualParityBacklogItem(title: "Match Creator workflow cards", subtitle: "Polish creator screen hierarchy later.", screenGroup: "Creator", priority: "Medium", status: "After Spine Lock", systemImage: "shippingbox.fill"),
        HFVisualParityBacklogItem(title: "Match package builder layout", subtitle: "Align builder sections in visual parity phase.", screenGroup: "Creator", priority: "Medium", status: "After Spine Lock", systemImage: "rectangle.grid.1x2.fill"),
        HFVisualParityBacklogItem(title: "Match review/readiness hierarchy", subtitle: "Tune team review and readiness screens later.", screenGroup: "Creator", priority: "Medium", status: "After Spine Lock", systemImage: "checklist.checked"),
        HFVisualParityBacklogItem(title: "Match social/community surfaces", subtitle: "Align Connect hub and community cards later.", screenGroup: "Connect", priority: "Medium", status: "After Spine Lock", systemImage: "person.2.fill"),
        HFVisualParityBacklogItem(title: "Match room cards", subtitle: "Polish room previews after route lock.", screenGroup: "Connect", priority: "Medium", status: "After Spine Lock", systemImage: "bubble.left.and.bubble.right.fill"),
        HFVisualParityBacklogItem(title: "Match creator profile cards", subtitle: "Tune creator relationship cards later.", screenGroup: "Connect", priority: "Medium", status: "After Spine Lock", systemImage: "person.crop.square.fill"),
        HFVisualParityBacklogItem(title: "Match release readiness presentation", subtitle: "Finalize readiness hierarchy after spine QA.", screenGroup: "Launch", priority: "Medium", status: "After Spine Lock", systemImage: "flag.checkered"),
        HFVisualParityBacklogItem(title: "Match launch/access preview cards", subtitle: "Tune launch and access cards in visual pass.", screenGroup: "Launch", priority: "Medium", status: "After Spine Lock", systemImage: "lock.shield.fill"),
        HFVisualParityBacklogItem(title: "Match export composer/queue/safety screens", subtitle: "Only after export remains clearly preview-only.", screenGroup: "Export", priority: "Medium", status: "After Spine Lock", systemImage: "square.and.arrow.up"),
        HFVisualParityBacklogItem(title: "Match preview-only language treatment", subtitle: "Make locked export state visually clear later.", screenGroup: "Export", priority: "Medium", status: "After Spine Lock", systemImage: "text.badge.checkmark"),
        HFVisualParityBacklogItem(title: "Match tab bar, glass surfaces, color, spacing, and motion", subtitle: "Global brand pass happens after product structure is stable.", screenGroup: "Global Design System", priority: "High", status: "After Spine Lock", systemImage: "sparkles")
    ]

    static func routes(for pillar: String) -> [HFProductSpineRouteItem] {
        routeItems.filter { $0.pillar == pillar }
    }

    static func locks(for category: String) -> [HFProductSpineLockItem] {
        locks.filter { $0.lockCategory == category }
    }

    static func backlog(for group: String) -> [HFVisualParityBacklogItem] {
        visualParityBacklog.filter { $0.screenGroup == group }
    }
}
