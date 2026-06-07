import Foundation

struct HFRouteQualityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let routeState: String
    let issueType: String
    let systemImage: String
}

struct HFDeadEndCleanupItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let cleanupState: String
    let systemImage: String
}

struct HFSpineNavigationMapItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let source: String
    let destination: String
    let pillar: String
    let status: String
    let systemImage: String
}

struct HFPreMockupReadinessItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let screenGroup: String
    let status: String
    let systemImage: String
}

enum HFProductSpineRouteQualityData {
    static let routeQualityItems: [HFRouteQualityItem] = [
        HFRouteQualityItem(title: "Home to Search / Discover is clear", subtitle: "Viewer routes are labeled as local streaming discovery paths.", pillar: "Watch", routeState: "Local route", issueType: "Label clarity", systemImage: "magnifyingglass"),
        HFRouteQualityItem(title: "Home to Movie Detail is clear", subtitle: "Title cards open local movie detail without changing title or poster mappings.", pillar: "Watch", routeState: "Local route", issueType: "Route clarity", systemImage: "film.fill"),
        HFRouteQualityItem(title: "Home to My List is clear", subtitle: "Saved-title language stays viewer-facing and local.", pillar: "Watch", routeState: "Local route", issueType: "Route clarity", systemImage: "bookmark.fill"),
        HFRouteQualityItem(title: "Home to Downloads is clear", subtitle: "Downloads remain a local preview surface with no file access.", pillar: "Watch", routeState: "Local route", issueType: "Safety copy", systemImage: "arrow.down.circle.fill"),
        HFRouteQualityItem(title: "Watch labels stay viewer-facing", subtitle: "Watch route labels distinguish streaming from creator, launch, and export routes.", pillar: "Watch", routeState: "Local route", issueType: "Pillar clarity", systemImage: "play.rectangle.fill"),

        HFRouteQualityItem(title: "Profile to Creator Mode is clear", subtitle: "Creator entry remains a local preview route from Profile.", pillar: "Create", routeState: "Local route", issueType: "Entry clarity", systemImage: "wand.and.stars"),
        HFRouteQualityItem(title: "Product Spine links to creator workflow clearly", subtitle: "Spine cards name the creator workflow without implying a real studio backend.", pillar: "Create", routeState: "Local route", issueType: "Route clarity", systemImage: "command"),
        HFRouteQualityItem(title: "Package Builder labels are consistent", subtitle: "Package Builder is presented as a local preview route.", pillar: "Create", routeState: "Local route", issueType: "Label consistency", systemImage: "shippingbox.fill"),
        HFRouteQualityItem(title: "Release Readiness labels are consistent", subtitle: "Readiness cards stay static and do not imply App Store automation.", pillar: "Create", routeState: "Static preview", issueType: "Safety copy", systemImage: "checkmark.seal.fill"),

        HFRouteQualityItem(title: "Connect Hub labels are clear", subtitle: "Connect stays a community preview route with no real accounts or social graph.", pillar: "Connect", routeState: "Local route", issueType: "Label clarity", systemImage: "person.2.fill"),
        HFRouteQualityItem(title: "Social Rooms labels are clear", subtitle: "Rooms are presented as local mock community surfaces.", pillar: "Connect", routeState: "Static preview", issueType: "Preview clarity", systemImage: "bubble.left.and.bubble.right.fill"),
        HFRouteQualityItem(title: "Creator Circles labels are clear", subtitle: "Creator relationship previews do not imply real follows or messaging.", pillar: "Connect", routeState: "Static preview", issueType: "Safety copy", systemImage: "person.3.fill"),
        HFRouteQualityItem(title: "Activity Feed labels are clear", subtitle: "Activity remains local mock content with no network or push systems.", pillar: "Connect", routeState: "Static preview", issueType: "Preview clarity", systemImage: "waveform.path.ecg"),
        HFRouteQualityItem(title: "Social graph and follow suggestions stay preview-only", subtitle: "Graph and suggestion cards remain locked to local mock data.", pillar: "Connect", routeState: "Static preview", issueType: "Real-system lock", systemImage: "point.3.connected.trianglepath.dotted"),

        HFRouteQualityItem(title: "Launch Center route is clear", subtitle: "Launch planning is reachable as a local creator preview.", pillar: "Launch", routeState: "Local route", issueType: "Route clarity", systemImage: "flag.checkered"),
        HFRouteQualityItem(title: "Access Preview route is clear", subtitle: "Access previews remain mock-only and do not create permissions or accounts.", pillar: "Launch", routeState: "Local route", issueType: "Safety copy", systemImage: "ticket.fill"),
        HFRouteQualityItem(title: "Release Presentation route is clear", subtitle: "The release story is a local presentation surface, not App Store prep.", pillar: "Launch", routeState: "Local route", issueType: "Route clarity", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFRouteQualityItem(title: "Demo Checklist route is clear", subtitle: "Checklist rows are static display only and do not run QA automation.", pillar: "Launch", routeState: "Static preview", issueType: "Automation lock", systemImage: "checklist.checked"),

        HFRouteQualityItem(title: "Export is preview-only", subtitle: "Export route copy states that capture, rendering, sharing, and uploads are locked.", pillar: "Export", routeState: "Locked future", issueType: "Safety gate", systemImage: "square.and.arrow.up.fill"),
        HFRouteQualityItem(title: "Locked Systems Map explains export locks", subtitle: "The lock map names export and share systems that need separate phases.", pillar: "Export", routeState: "Static preview", issueType: "Safety map", systemImage: "lock.shield.fill"),
        HFRouteQualityItem(title: "Visual Parity Backlog does not imply export works", subtitle: "Backlog copy keeps export matching separate from real export implementation.", pillar: "Export", routeState: "Needs visual parity later", issueType: "Backlog clarity", systemImage: "rectangle.3.group.fill"),
        HFRouteQualityItem(title: "Missing export screens appear locked", subtitle: "Optional export cards are static placeholders instead of broken links.", pillar: "Export", routeState: "Locked future", issueType: "Dead-end cleanup", systemImage: "exclamationmark.lock.fill")
    ]

    static let deadEndCleanupItems: [HFDeadEndCleanupItem] = [
        HFDeadEndCleanupItem(title: "Tappable cards open existing screens", subtitle: "NavigationLink cards should land on a real local SwiftUI destination.", pillar: "Route", cleanupState: "Required", systemImage: "arrow.right.circle.fill"),
        HFDeadEndCleanupItem(title: "Missing screens are marked locked", subtitle: "Future or optional routes must read as locked/static placeholders.", pillar: "Route", cleanupState: "Required", systemImage: "lock.fill"),
        HFDeadEndCleanupItem(title: "Static cards do not look broken", subtitle: "Non-routing cards need clear locked, static, or preview-only status labels.", pillar: "Route", cleanupState: "Required", systemImage: "rectangle.dashed"),
        HFDeadEndCleanupItem(title: "Optional export routes are preview-only", subtitle: "Export cards do not imply capture, rendering, share, upload, or file access.", pillar: "Route", cleanupState: "Locked", systemImage: "square.and.arrow.up.fill"),
        HFDeadEndCleanupItem(title: "Visual parity backlog remains planning-only", subtitle: "Backlog rows describe later matching work without starting it here.", pillar: "Route", cleanupState: "Planning", systemImage: "rectangle.3.group.fill"),

        HFDeadEndCleanupItem(title: "Local preview language is clear", subtitle: "Copy distinguishes local mock routes from future real systems.", pillar: "Copy", cleanupState: "Required", systemImage: "text.alignleft"),
        HFDeadEndCleanupItem(title: "Real systems are marked locked", subtitle: "Backend, auth, payments, media, capture, export, and share systems stay disconnected.", pillar: "Copy", cleanupState: "Locked", systemImage: "lock.shield.fill"),
        HFDeadEndCleanupItem(title: "Export/capture/share are not active", subtitle: "Export copy stays safety-gated and preview-only.", pillar: "Copy", cleanupState: "Locked", systemImage: "nosign"),
        HFDeadEndCleanupItem(title: "Figma/mockup parity is later", subtitle: "Visual matching starts only after route quality is QA-passed.", pillar: "Copy", cleanupState: "Later", systemImage: "rectangle.3.group.fill"),
        HFDeadEndCleanupItem(title: "No App Store readiness is implied", subtitle: "Release language remains local and does not imply submission prep.", pillar: "Copy", cleanupState: "Locked", systemImage: "app.badge.checkmark"),

        HFDeadEndCleanupItem(title: "Watch routes are viewer-facing", subtitle: "Watch cards stay focused on streaming, discovery, title detail, list, and downloads.", pillar: "Pillar", cleanupState: "Clear", systemImage: "play.rectangle.fill"),
        HFDeadEndCleanupItem(title: "Create routes are creator-facing", subtitle: "Create cards stay focused on creator workflow previews.", pillar: "Pillar", cleanupState: "Clear", systemImage: "wand.and.stars"),
        HFDeadEndCleanupItem(title: "Connect routes are community-facing", subtitle: "Connect cards stay focused on local community and creator relationship previews.", pillar: "Pillar", cleanupState: "Clear", systemImage: "person.2.fill"),
        HFDeadEndCleanupItem(title: "Launch routes are readiness-facing", subtitle: "Launch cards stay focused on planning, access previews, release presentation, and demo checks.", pillar: "Pillar", cleanupState: "Clear", systemImage: "flag.checkered"),
        HFDeadEndCleanupItem(title: "Export routes are safety-gated", subtitle: "Export cards stay locked or preview-only until separately scoped.", pillar: "Pillar", cleanupState: "Locked", systemImage: "lock.fill")
    ]

    static let navigationMapItems: [HFSpineNavigationMapItem] = [
        HFSpineNavigationMapItem(title: "Home to Product Spine Completion", subtitle: "Lower Home card opens the product spine overview.", source: "Home", destination: "Product Spine Completion", pillar: "Entry", status: "Entry Point", systemImage: "house.fill"),
        HFSpineNavigationMapItem(title: "Home to Product Spine Gap Review", subtitle: "Home exposes route gap review without crowding the hero.", source: "Home", destination: "Product Spine Gap Review", pillar: "Entry", status: "Entry Point", systemImage: "exclamationmark.triangle.fill"),
        HFSpineNavigationMapItem(title: "Profile to Product Spine Completion", subtitle: "Profile exposes the full local product structure.", source: "Profile", destination: "Product Spine Completion", pillar: "Entry", status: "Entry Point", systemImage: "person.crop.circle.fill"),
        HFSpineNavigationMapItem(title: "Profile to Pre-Visual Lock", subtitle: "Profile gives reviewers a compact structure-before-style gate.", source: "Profile", destination: "Pre-Visual Lock", pillar: "Entry", status: "Entry Point", systemImage: "checkmark.seal.fill"),
        HFSpineNavigationMapItem(title: "Ecosystem Command Center to Product Spine Completion", subtitle: "Command Center keeps spine routes with Watch, Create, Connect, Launch, and Export.", source: "Ecosystem Command Center", destination: "Product Spine Completion", pillar: "Entry", status: "Entry Point", systemImage: "command"),

        HFSpineNavigationMapItem(title: "Completion to Route Coverage", subtitle: "Coverage remains the route inventory for the five pillars.", source: "Product Spine Completion", destination: "Route Coverage", pillar: "Spine", status: "Spine Review", systemImage: "arrow.triangle.branch"),
        HFSpineNavigationMapItem(title: "Completion to Gap Review", subtitle: "Gap Review names weak spots before visual parity.", source: "Product Spine Completion", destination: "Gap Review", pillar: "Spine", status: "Spine Review", systemImage: "exclamationmark.triangle.fill"),
        HFSpineNavigationMapItem(title: "Completion to Pillar Hardening", subtitle: "Pillar Hardening checks Watch, Create, Connect, Launch, and Export readiness.", source: "Product Spine Completion", destination: "Pillar Hardening", pillar: "Spine", status: "Spine Review", systemImage: "shield.lefthalf.filled"),
        HFSpineNavigationMapItem(title: "Completion to Spine Review Paths", subtitle: "Review Paths provide repeatable QA order.", source: "Product Spine Completion", destination: "Spine Review Paths", pillar: "Spine", status: "Spine Review", systemImage: "map.fill"),
        HFSpineNavigationMapItem(title: "Completion to Pre-Visual Lock", subtitle: "Pre-Visual Lock confirms structure before style.", source: "Product Spine Completion", destination: "Pre-Visual Lock", pillar: "Spine", status: "Spine Review", systemImage: "checkmark.seal.fill"),

        HFSpineNavigationMapItem(title: "Visual Parity Backlog to Pre-Visual Lock", subtitle: "Backlog points reviewers back to the structure gate.", source: "Visual Parity Backlog", destination: "Pre-Visual Lock", pillar: "Visual Prep", status: "Visual Prep", systemImage: "rectangle.3.group.fill"),
        HFSpineNavigationMapItem(title: "Walkthrough to Pillar Hardening", subtitle: "Walkthrough ends with hardening review before visual work.", source: "Product Spine Walkthrough", destination: "Pillar Hardening", pillar: "Visual Prep", status: "Visual Prep", systemImage: "shield.lefthalf.filled"),
        HFSpineNavigationMapItem(title: "Walkthrough to Spine Review Paths", subtitle: "Walkthrough links to repeatable route review order.", source: "Product Spine Walkthrough", destination: "Spine Review Paths", pillar: "Visual Prep", status: "Visual Prep", systemImage: "map.fill")
    ]

    static let readinessItems: [HFPreMockupReadinessItem] = [
        HFPreMockupReadinessItem(title: "Home structure stable", subtitle: "Home keeps product spine entry points below the streaming story.", screenGroup: "Structure Readiness", status: "Stable", systemImage: "house.fill"),
        HFPreMockupReadinessItem(title: "Profile structure stable", subtitle: "Profile exposes spine review without crowding account-style actions.", screenGroup: "Structure Readiness", status: "Stable", systemImage: "person.crop.circle.fill"),
        HFPreMockupReadinessItem(title: "Ecosystem Command Center structure stable", subtitle: "Command Center groups product spine routes without removing existing pillar routes.", screenGroup: "Structure Readiness", status: "Stable", systemImage: "command"),
        HFPreMockupReadinessItem(title: "Spine screens stable", subtitle: "Completion, coverage, hardening, route quality, and pre-mockup checks are reviewable.", screenGroup: "Structure Readiness", status: "Stable", systemImage: "rectangle.connected.to.line.below"),

        HFPreMockupReadinessItem(title: "Watch path reviewable", subtitle: "Viewer story, search, detail, list, and downloads remain clear.", screenGroup: "Pillar Readiness", status: "Reviewable", systemImage: "play.rectangle.fill"),
        HFPreMockupReadinessItem(title: "Create path reviewable", subtitle: "Creator workflow preview remains reachable and local.", screenGroup: "Pillar Readiness", status: "Reviewable", systemImage: "wand.and.stars"),
        HFPreMockupReadinessItem(title: "Connect path reviewable", subtitle: "Community and creator relationship previews remain local/mock.", screenGroup: "Pillar Readiness", status: "Reviewable", systemImage: "person.2.fill"),
        HFPreMockupReadinessItem(title: "Launch path reviewable", subtitle: "Launch planning, access preview, release presentation, and demo checks remain discoverable.", screenGroup: "Pillar Readiness", status: "Reviewable", systemImage: "flag.checkered"),
        HFPreMockupReadinessItem(title: "Export preview status clear", subtitle: "Export, capture, render, share, and upload remain locked or preview-only.", screenGroup: "Pillar Readiness", status: "Locked", systemImage: "lock.fill"),

        HFPreMockupReadinessItem(title: "Locked systems documented", subtitle: "Real systems require separate scoped phases.", screenGroup: "Safety Readiness", status: "Documented", systemImage: "lock.shield.fill"),
        HFPreMockupReadinessItem(title: "Export/capture/share remain locked", subtitle: "No export pipeline, share sheet, screenshot, or rendering system is connected.", screenGroup: "Safety Readiness", status: "Locked", systemImage: "nosign"),
        HFPreMockupReadinessItem(title: "No Figma sync", subtitle: "Mockup parity planning does not modify Figma.", screenGroup: "Safety Readiness", status: "Locked", systemImage: "rectangle.3.group.fill"),
        HFPreMockupReadinessItem(title: "No asset/poster changes", subtitle: "Asset catalogs, poster mappings, and backdrop mappings remain untouched.", screenGroup: "Safety Readiness", status: "Locked", systemImage: "photo.fill"),
        HFPreMockupReadinessItem(title: "No permission changes", subtitle: "Info.plist, PrivacyInfo, and entitlements stay unchanged.", screenGroup: "Safety Readiness", status: "Locked", systemImage: "hand.raised.fill"),
        HFPreMockupReadinessItem(title: "No real services", subtitle: "Backend, auth, payments, uploads, analytics, playback, and social systems stay disconnected.", screenGroup: "Safety Readiness", status: "Locked", systemImage: "network.slash"),

        HFPreMockupReadinessItem(title: "Exact layout", subtitle: "Later visual parity will match final screen composition.", screenGroup: "Mockup Later", status: "Later", systemImage: "rectangle.inset.filled"),
        HFPreMockupReadinessItem(title: "Exact spacing", subtitle: "Later visual parity will lock gaps, margins, and rail density.", screenGroup: "Mockup Later", status: "Later", systemImage: "ruler.fill"),
        HFPreMockupReadinessItem(title: "Typography scale", subtitle: "Later visual parity will tune type size, weight, and hierarchy.", screenGroup: "Mockup Later", status: "Later", systemImage: "textformat.size"),
        HFPreMockupReadinessItem(title: "Card shapes", subtitle: "Later visual parity will refine corner radius and card treatment.", screenGroup: "Mockup Later", status: "Later", systemImage: "rectangle.roundedtop.fill"),
        HFPreMockupReadinessItem(title: "Glass treatment", subtitle: "Later visual parity will align glass surfaces and contrast.", screenGroup: "Mockup Later", status: "Later", systemImage: "sparkles"),
        HFPreMockupReadinessItem(title: "Poster/backdrop presentation", subtitle: "Later visual parity will align media treatment without mapping changes.", screenGroup: "Mockup Later", status: "Later", systemImage: "photo.on.rectangle.angled"),
        HFPreMockupReadinessItem(title: "Motion and transitions", subtitle: "Later visual parity will tune motion without touching protected playback/depth systems.", screenGroup: "Mockup Later", status: "Later", systemImage: "sparkle.magnifyingglass"),
        HFPreMockupReadinessItem(title: "Bottom tab visual polish", subtitle: "Later visual parity will refine the existing five-tab shell.", screenGroup: "Mockup Later", status: "Later", systemImage: "rectangle.bottomthird.inset.filled")
    ]

    static func routeQualityItems(for pillar: String) -> [HFRouteQualityItem] {
        routeQualityItems.filter { $0.pillar == pillar }
    }

    static func cleanupItems(for pillar: String) -> [HFDeadEndCleanupItem] {
        deadEndCleanupItems.filter { $0.pillar == pillar }
    }

    static func navigationItems(status: String) -> [HFSpineNavigationMapItem] {
        navigationMapItems.filter { $0.status == status }
    }

    static func readinessItems(for group: String) -> [HFPreMockupReadinessItem] {
        readinessItems.filter { $0.screenGroup == group }
    }
}
