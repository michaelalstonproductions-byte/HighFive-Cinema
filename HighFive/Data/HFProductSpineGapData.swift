import Foundation

struct HFSpineGapItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let status: String
    let systemImage: String
}

struct HFPillarHardeningItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let routeStatus: String
    let systemImage: String
}

struct HFSpineReviewPath: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let steps: [String]
    let status: String
    let systemImage: String
}

struct HFSpineFutureVisualItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let screenGroup: String
    let status: String
    let systemImage: String
}

enum HFProductSpineGapData {
    static let gaps: [HFSpineGapItem] = [
        HFSpineGapItem(title: "Movie Detail review path", subtitle: "Use The Friendly route from spine coverage to confirm title detail is reachable.", pillar: "Watch", status: "Local route present", systemImage: "film.fill"),
        HFSpineGapItem(title: "My List route clarity", subtitle: "Keep My List visible from Watch and the bottom tab shell.", pillar: "Watch", status: "Local route present", systemImage: "bookmark.fill"),
        HFSpineGapItem(title: "Downloads route clarity", subtitle: "Confirm Downloads stays reviewable as a local tab and route.", pillar: "Watch", status: "Local route present", systemImage: "arrow.down.circle.fill"),
        HFSpineGapItem(title: "Search-to-title route clarity", subtitle: "Search and Unified Discovery should clearly lead back to title review.", pillar: "Watch", status: "Local route present", systemImage: "magnifyingglass"),

        HFSpineGapItem(title: "Creator Mode entry clarity", subtitle: "Profile and spine routes should make Creator Mode easy to find.", pillar: "Create", status: "Local route present", systemImage: "wand.and.stars"),
        HFSpineGapItem(title: "Package Builder path clarity", subtitle: "Creator review should move from command center into package builder.", pillar: "Create", status: "Local route present", systemImage: "shippingbox.fill"),
        HFSpineGapItem(title: "Team Review path clarity", subtitle: "Team Review remains local and reachable from the Create pillar.", pillar: "Create", status: "Local route present", systemImage: "person.3.fill"),
        HFSpineGapItem(title: "Release Readiness path clarity", subtitle: "Release Readiness should close the Create review path before Launch.", pillar: "Create", status: "Local route present", systemImage: "gauge.with.dots.needle.bottom.50percent"),

        HFSpineGapItem(title: "Connect Hub route clarity", subtitle: "Connect Hub remains the main local entry for community previews.", pillar: "Connect", status: "Local route present", systemImage: "person.2.fill"),
        HFSpineGapItem(title: "Social Rooms path clarity", subtitle: "Social Rooms are local preview cards with no real messaging.", pillar: "Connect", status: "Local route present", systemImage: "bubble.left.and.bubble.right.fill"),
        HFSpineGapItem(title: "Creator Circles path clarity", subtitle: "Creator Circles explain collaborator relationships without real follows.", pillar: "Connect", status: "Local route present", systemImage: "circle.hexagongrid.fill"),
        HFSpineGapItem(title: "Activity Feed path clarity", subtitle: "Activity Feed stays local/static and supports Connect review.", pillar: "Connect", status: "Local route present", systemImage: "text.bubble.fill"),
        HFSpineGapItem(title: "Social Graph / Follow Suggestions path clarity", subtitle: "Graph and suggestions are reviewable when present and remain mock only.", pillar: "Connect", status: "Local route present", systemImage: "point.3.connected.trianglepath.dotted"),

        HFSpineGapItem(title: "Launch Center path clarity", subtitle: "Launch Center should be the first Launch review surface.", pillar: "Launch", status: "Local route present", systemImage: "rocket.fill"),
        HFSpineGapItem(title: "Access Preview path clarity", subtitle: "Access Preview remains mock-only and avoids purchases.", pillar: "Launch", status: "Local route present", systemImage: "lock.shield.fill"),
        HFSpineGapItem(title: "Release Presentation path clarity", subtitle: "Release Presentation keeps stakeholder review local.", pillar: "Launch", status: "Local route present", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFSpineGapItem(title: "Demo Checklist path clarity", subtitle: "Demo Checklist remains a static local review aid.", pillar: "Launch", status: "Local route present", systemImage: "checklist.checked"),

        HFSpineGapItem(title: "Export Safety path clarity", subtitle: "Export remains documented as preview-only because no export surface is present here.", pillar: "Export", status: "Static card only", systemImage: "lock.shield.fill"),
        HFSpineGapItem(title: "Protected Capture Roadmap path clarity", subtitle: "Protected capture remains future locked with no implementation.", pillar: "Export", status: "Future locked", systemImage: "video.slash.fill"),
        HFSpineGapItem(title: "Export composer/queue paths", subtitle: "Composer and queue are future placeholders unless separately scoped.", pillar: "Export", status: "Future locked", systemImage: "tray.full.fill"),
        HFSpineGapItem(title: "Clear preview-only status", subtitle: "Export copy must keep share, capture, render, and upload work locked.", pillar: "Export", status: "Needs visual parity later", systemImage: "square.and.arrow.up")
    ]

    static let hardeningItems: [HFPillarHardeningItem] = [
        HFPillarHardeningItem(title: "Home explains Watch", subtitle: "Home stays the cinematic entry into local watching.", pillar: "Watch", routeStatus: "Stable", systemImage: "house.fill"),
        HFPillarHardeningItem(title: "Search opens discovery", subtitle: "Search and Unified Discovery provide the browse path.", pillar: "Watch", routeStatus: "Stable", systemImage: "magnifyingglass"),
        HFPillarHardeningItem(title: "Movie Detail opens safely", subtitle: "Movie Detail remains local with no real playback implementation.", pillar: "Watch", routeStatus: "Stable", systemImage: "film.fill"),
        HFPillarHardeningItem(title: "My List and Downloads remain reachable", subtitle: "Saved and download review paths remain in the tab shell.", pillar: "Watch", routeStatus: "Stable", systemImage: "bookmark.fill"),

        HFPillarHardeningItem(title: "Profile exposes Creator Mode", subtitle: "Profile remains a compact product hub.", pillar: "Create", routeStatus: "Stable", systemImage: "person.crop.circle.fill"),
        HFPillarHardeningItem(title: "Creator Command Center is reachable", subtitle: "Create review starts from a clear command surface.", pillar: "Create", routeStatus: "Stable", systemImage: "command"),
        HFPillarHardeningItem(title: "Package Builder is reachable", subtitle: "Package Builder remains local/static preview.", pillar: "Create", routeStatus: "Stable", systemImage: "shippingbox.fill"),
        HFPillarHardeningItem(title: "Release Readiness is reachable", subtitle: "Release readiness closes the Create review path.", pillar: "Create", routeStatus: "Stable", systemImage: "checkmark.seal.fill"),

        HFPillarHardeningItem(title: "Connect Hub is reachable", subtitle: "Connect starts from a clear local hub.", pillar: "Connect", routeStatus: "Stable", systemImage: "person.2.fill"),
        HFPillarHardeningItem(title: "Social Rooms are reachable", subtitle: "Rooms remain preview-only without messaging.", pillar: "Connect", routeStatus: "Stable", systemImage: "bubble.left.and.bubble.right.fill"),
        HFPillarHardeningItem(title: "Creator Circles are reachable", subtitle: "Circles show collaborator relationships locally.", pillar: "Connect", routeStatus: "Stable", systemImage: "circle.hexagongrid.fill"),
        HFPillarHardeningItem(title: "Activity Feed is reachable", subtitle: "Activity remains local/static with no live service.", pillar: "Connect", routeStatus: "Stable", systemImage: "text.bubble.fill"),

        HFPillarHardeningItem(title: "Launch Center is reachable", subtitle: "Launch starts from the creator launch surface.", pillar: "Launch", routeStatus: "Stable", systemImage: "rocket.fill"),
        HFPillarHardeningItem(title: "Access Preview is reachable", subtitle: "Access stays mock-only and avoids purchases.", pillar: "Launch", routeStatus: "Stable", systemImage: "lock.shield.fill"),
        HFPillarHardeningItem(title: "Release Presentation is reachable", subtitle: "Presentation remains local stakeholder copy.", pillar: "Launch", routeStatus: "Stable", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFPillarHardeningItem(title: "Demo Checklist is reachable", subtitle: "Checklist gives a repeatable local review path.", pillar: "Launch", routeStatus: "Stable", systemImage: "checklist.checked"),

        HFPillarHardeningItem(title: "Export remains preview-only", subtitle: "Export is documented without real export, capture, render, or share.", pillar: "Export", routeStatus: "Locked", systemImage: "square.and.arrow.up"),
        HFPillarHardeningItem(title: "Locked Systems Map explains real-system locks", subtitle: "Real export work requires separate scope.", pillar: "Export", routeStatus: "Locked", systemImage: "lock.shield.fill"),
        HFPillarHardeningItem(title: "Visual Parity Backlog explains later design pass", subtitle: "Export styling waits until after spine QA.", pillar: "Export", routeStatus: "Later", systemImage: "rectangle.3.group.fill")
    ]

    static let reviewPaths: [HFSpineReviewPath] = [
        HFSpineReviewPath(title: "Viewer Review Path", subtitle: "Repeatable Watch review order.", steps: ["Home", "Search", "Unified Discovery", "Movie Detail", "My List", "Downloads"], status: "Local", systemImage: "play.rectangle.fill"),
        HFSpineReviewPath(title: "Creator Review Path", subtitle: "Repeatable Create review order.", steps: ["Profile", "Creator Mode", "Creator Command Center", "Package Builder", "Team Review", "Release Readiness"], status: "Local", systemImage: "shippingbox.fill"),
        HFSpineReviewPath(title: "Connect Review Path", subtitle: "Repeatable Connect review order.", steps: ["Profile", "Connect Hub", "Social Rooms", "Creator Circles", "Activity Feed", "Social Graph if present"], status: "Local", systemImage: "person.2.fill"),
        HFSpineReviewPath(title: "Launch Review Path", subtitle: "Repeatable Launch review order.", steps: ["Creator Command Center", "Launch Center", "Access Preview", "Release Presentation", "Demo Checklist"], status: "Local", systemImage: "flag.checkered"),
        HFSpineReviewPath(title: "Export Review Path", subtitle: "Repeatable Export safety review order.", steps: ["Product Spine Completion", "Locked Systems Map", "Export Safety route if present", "Visual Parity Backlog"], status: "Preview-only", systemImage: "square.and.arrow.up")
    ]

    static let futureVisualItems: [HFSpineFutureVisualItem] = [
        HFSpineFutureVisualItem(title: "Figma layout matching", subtitle: "Match mockups after spine hardening QA.", screenGroup: "Structure Before Style", status: "Later", systemImage: "rectangle.3.group.fill"),
        HFSpineFutureVisualItem(title: "Exact spacing", subtitle: "Tune spacing after route stability.", screenGroup: "Structure Before Style", status: "Later", systemImage: "ruler.fill"),
        HFSpineFutureVisualItem(title: "Typography scale", subtitle: "Lock typography after review paths are stable.", screenGroup: "Structure Before Style", status: "Later", systemImage: "textformat.size"),
        HFSpineFutureVisualItem(title: "Card shape and glass treatment", subtitle: "Polish cards in the visual parity phase.", screenGroup: "Structure Before Style", status: "Later", systemImage: "rectangle.roundedtop.fill"),
        HFSpineFutureVisualItem(title: "Poster/backdrop treatment", subtitle: "Do not change mappings during hardening.", screenGroup: "Structure Before Style", status: "Later", systemImage: "photo.fill"),
        HFSpineFutureVisualItem(title: "Motion and transitions", subtitle: "Motion polish waits until after spine lock.", screenGroup: "Structure Before Style", status: "Later", systemImage: "sparkles"),
        HFSpineFutureVisualItem(title: "Tab bar and safe-area polish", subtitle: "Shell polish belongs to visual parity.", screenGroup: "Structure Before Style", status: "Later", systemImage: "rectangle.bottomthird.inset.filled")
    ]

    static func gaps(for pillar: String) -> [HFSpineGapItem] {
        gaps.filter { $0.pillar == pillar }
    }

    static func hardeningItems(for pillar: String) -> [HFPillarHardeningItem] {
        hardeningItems.filter { $0.pillar == pillar }
    }
}
