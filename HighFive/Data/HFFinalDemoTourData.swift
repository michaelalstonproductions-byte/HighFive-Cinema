import Foundation

enum HFFinalDemoTourData {
    static let steps: [HFFinalDemoStep] = [
        HFFinalDemoStep(title: "Start at Home", subtitle: "Open the viewer-first streaming shell.", pillar: "Watch", routeLabel: "Home tab", status: "Active", systemImage: "house.fill"),
        HFFinalDemoStep(title: "Watch The Friendly", subtitle: "Use the featured local title as the demo anchor.", pillar: "Watch", routeLabel: "Featured title", status: "Active", systemImage: "play.rectangle.fill"),
        HFFinalDemoStep(title: "Open Movie Detail", subtitle: "Review title copy, actions, and readable detail layout.", pillar: "Watch", routeLabel: "Movie Detail", status: "Active", systemImage: "film.fill"),
        HFFinalDemoStep(title: "Explore Unified Discovery", subtitle: "Show search, discovery, and product routes in one local surface.", pillar: "Watch", routeLabel: "Unified Discovery", status: "Active", systemImage: "magnifyingglass"),
        HFFinalDemoStep(title: "Open Personalized Hub", subtitle: "Preview static recommendations and local next paths.", pillar: "Watch", routeLabel: "For You", status: "Local", systemImage: "sparkles"),
        HFFinalDemoStep(title: "Enter Creator Mode", subtitle: "Move from viewing into creator package planning.", pillar: "Create", routeLabel: "Creator Mode", status: "Active", systemImage: "wand.and.stars"),
        HFFinalDemoStep(title: "Open Creator Command Center", subtitle: "Review workflow health, blockers, and next actions.", pillar: "Create", routeLabel: "Creator Command", status: "Active", systemImage: "command"),
        HFFinalDemoStep(title: "Continue Package Builder", subtitle: "Show the local package-building preview.", pillar: "Create", routeLabel: "Package Builder", status: "Active", systemImage: "shippingbox.fill"),
        HFFinalDemoStep(title: "Review Release Readiness", subtitle: "Check launch blockers and readiness signals.", pillar: "Create", routeLabel: "Release Readiness", status: "Local", systemImage: "gauge.with.dots.needle.67percent"),
        HFFinalDemoStep(title: "Open Connect Hub", subtitle: "Move into creator and community discovery.", pillar: "Connect", routeLabel: "Connect Hub", status: "Active", systemImage: "person.2.fill"),
        HFFinalDemoStep(title: "Explore Social Rooms", subtitle: "Review room previews without real comments or messaging.", pillar: "Connect", routeLabel: "Social Rooms", status: "Mock", systemImage: "bubble.left.and.bubble.right.fill"),
        HFFinalDemoStep(title: "Open Social Graph", subtitle: "Show local relationship mapping without real accounts.", pillar: "Connect", routeLabel: "Social Graph", status: "Mock", systemImage: "point.3.connected.trianglepath.dotted"),
        HFFinalDemoStep(title: "Open Launch Center", subtitle: "Review launch plan, audience interest, and local status.", pillar: "Launch", routeLabel: "Launch Center", status: "Local", systemImage: "flag.checkered"),
        HFFinalDemoStep(title: "Preview Access", subtitle: "Show mock access models with no payments or StoreKit.", pillar: "Launch", routeLabel: "Access Preview", status: "Mock", systemImage: "lock.shield.fill"),
        HFFinalDemoStep(title: "Open Social Export Hub", subtitle: "Explain the future export pillar as local preview only.", pillar: "Export", routeLabel: "Export Hub", status: "Future", systemImage: "square.and.arrow.up"),
        HFFinalDemoStep(title: "Compose Export Preview", subtitle: "Describe future composer flow without rendering or sharing.", pillar: "Export", routeLabel: "Composer", status: "Future", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFFinalDemoStep(title: "Review Export Queue", subtitle: "Explain future queued drafts as static planning.", pillar: "Export", routeLabel: "Queue", status: "Future", systemImage: "tray.full.fill"),
        HFFinalDemoStep(title: "Open Export Safety Center", subtitle: "Confirm capture, rendering, Photos, and sharing stay locked.", pillar: "Export", routeLabel: "Safety Center", status: "Future", systemImage: "shield.lefthalf.filled"),
        HFFinalDemoStep(title: "Open Product Spine Lockdown", subtitle: "Verify Watch, Create, Connect, Launch, and Export are clear.", pillar: "Release", routeLabel: "Spine Lockdown", status: "Active", systemImage: "map.fill"),
        HFFinalDemoStep(title: "Finish at Release Candidate Prep", subtitle: "Close with final QA readiness and safety rules.", pillar: "Release", routeLabel: "RC Prep", status: "Active", systemImage: "checkmark.seal.fill")
    ]

    static let highlights: [HFFinalDemoHighlight] = [
        HFFinalDemoHighlight(title: "Streaming shell is stable", subtitle: "Home, Search, Library, Downloads, and Profile remain the core tabs.", category: "Watch", status: "Ready", systemImage: "play.rectangle.fill"),
        HFFinalDemoHighlight(title: "Movie Detail safe-area fix is in place", subtitle: "Title actions remain visible without covering detail content.", category: "Watch", status: "Ready", systemImage: "rectangle.inset.filled"),
        HFFinalDemoHighlight(title: "Creator workflow is mapped", subtitle: "Creator Mode, Command Center, Package Builder, and Release Readiness are discoverable.", category: "Create", status: "Ready", systemImage: "shippingbox.fill"),
        HFFinalDemoHighlight(title: "Connect layer is discoverable", subtitle: "Hub, rooms, circles, graph, suggestions, and activity feed are local previews.", category: "Connect", status: "Local", systemImage: "person.2.fill"),
        HFFinalDemoHighlight(title: "Launch readiness is visible", subtitle: "Launch Center, Access Preview, release presentation, and checklist are reachable.", category: "Launch", status: "Local", systemImage: "flag.checkered"),
        HFFinalDemoHighlight(title: "Export is local/preview only", subtitle: "Export screens are represented as future walkthrough steps until implemented.", category: "Export", status: "Future", systemImage: "square.and.arrow.up"),
        HFFinalDemoHighlight(title: "Protected capture remains locked", subtitle: "No camera, screen, playback, depth, motion, or rendering capture is active.", category: "Safety", status: "Locked", systemImage: "lock.shield.fill"),
        HFFinalDemoHighlight(title: "Final QA route matrix exists", subtitle: "The local QA route list is available without automation.", category: "QA", status: "Ready", systemImage: "checklist.checked")
    ]

    static let safetyLocks: [HFFinalDemoSafetyLock] = [
        HFFinalDemoSafetyLock(title: "No backend connected", subtitle: "All demo content is local/static.", status: "Locked", systemImage: "server.rack"),
        HFFinalDemoSafetyLock(title: "No auth/accounts connected", subtitle: "Profile and social paths are previews only.", status: "Locked", systemImage: "person.crop.circle.badge.xmark"),
        HFFinalDemoSafetyLock(title: "No payments/StoreKit connected", subtitle: "Access and marketplace copy is mock only.", status: "Locked", systemImage: "creditcard.trianglebadge.exclamationmark"),
        HFFinalDemoSafetyLock(title: "No uploads connected", subtitle: "Creator asset and package paths do not upload files.", status: "Locked", systemImage: "icloud.slash.fill"),
        HFFinalDemoSafetyLock(title: "No camera capture", subtitle: "The tour does not request camera access.", status: "Locked", systemImage: "camera.fill"),
        HFFinalDemoSafetyLock(title: "No ReplayKit", subtitle: "Screen recording remains unconnected.", status: "Locked", systemImage: "record.circle"),
        HFFinalDemoSafetyLock(title: "No Photos permission", subtitle: "The app does not request Photos during the tour.", status: "Locked", systemImage: "photo.on.rectangle.angled"),
        HFFinalDemoSafetyLock(title: "No share sheet", subtitle: "No ShareLink or activity controller is connected.", status: "Locked", systemImage: "square.and.arrow.up"),
        HFFinalDemoSafetyLock(title: "No screenshot rendering", subtitle: "No image or screenshot pipeline is created.", status: "Locked", systemImage: "camera.viewfinder"),
        HFFinalDemoSafetyLock(title: "Protected media untouched", subtitle: "Playback, depth, motion, and rendering systems stay isolated.", status: "Untouched", systemImage: "shield.lefthalf.filled"),
        HFFinalDemoSafetyLock(title: "No Figma sync", subtitle: "Design source remains untouched.", status: "Untouched", systemImage: "square.grid.3x3.fill"),
        HFFinalDemoSafetyLock(title: "No poster mapping changes", subtitle: "Title IDs and poster/backdrop asset names remain unchanged.", status: "Untouched", systemImage: "photo.fill")
    ]

    static let audiencePaths: [HFFinalDemoAudiencePath] = [
        HFFinalDemoAudiencePath(title: "Viewer Demo", subtitle: "Start with streaming, The Friendly, Movie Detail, Search, My List, and Downloads.", audience: "Viewer", recommendedStart: "Home and Movie Detail", status: "Ready", systemImage: "play.rectangle.fill"),
        HFFinalDemoAudiencePath(title: "Creator Demo", subtitle: "Start with Creator Command Center, Package Builder, team review, and release readiness.", audience: "Creator", recommendedStart: "Creator Command Center", status: "Ready", systemImage: "shippingbox.fill"),
        HFFinalDemoAudiencePath(title: "Community Demo", subtitle: "Start with Connect Hub, Social Rooms, Creator Circles, Social Graph, and Activity Feed.", audience: "Community", recommendedStart: "Connect Hub", status: "Ready", systemImage: "person.2.fill"),
        HFFinalDemoAudiencePath(title: "Launch Demo", subtitle: "Start with Release Readiness, Launch Center, Access Preview, and release presentation.", audience: "Launch", recommendedStart: "Launch Center", status: "Ready", systemImage: "flag.checkered"),
        HFFinalDemoAudiencePath(title: "Export Demo", subtitle: "Start with future Social Export path and Export Safety Center planning.", audience: "Export", recommendedStart: "Export safety", status: "Future", systemImage: "square.and.arrow.up"),
        HFFinalDemoAudiencePath(title: "Full Product Demo", subtitle: "Start with Product Spine Lockdown and walk the complete Watch to Export path.", audience: "Full", recommendedStart: "Product Spine Lockdown", status: "Ready", systemImage: "map.fill")
    ]

    static let viewerPath = ["Home", "The Friendly", "Movie Detail", "Search", "Unified Discovery", "My List", "Downloads"]
    static let creatorPath = ["Profile", "Creator Mode", "Creator Command Center", "Package Builder", "Asset Manager", "Team Review", "Release Readiness"]
    static let communityPath = ["Connect Hub", "Community Discovery", "Social Rooms", "Creator Circles", "Social Graph", "Follow Suggestions", "Activity Feed"]
    static let launchPath = ["Release Readiness", "Launch Center", "Access Preview", "Release Presentation", "Demo Checklist", "Release Candidate Prep"]
    static let exportPath = ["Social Export Hub", "Composer", "Brand Kit", "Template Gallery", "Preview", "Queue", "Demo Flow", "Platform Guide", "Export Safety Center", "Protected Capture Roadmap"]
    static let fullProductPath = ["Product Spine Lockdown", "Final QA Route Matrix", "Release Candidate Prep", "Final Demo Tour"]
}

struct HFFinalDemoStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let routeLabel: String
    let status: String
    let systemImage: String
}

struct HFFinalDemoHighlight: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let status: String
    let systemImage: String
}

struct HFFinalDemoSafetyLock: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
}

struct HFFinalDemoAudiencePath: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let audience: String
    let recommendedStart: String
    let status: String
    let systemImage: String
}
