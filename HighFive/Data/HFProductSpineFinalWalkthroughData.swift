import Foundation

struct HFFinalSpineWalkthroughStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let stepNumber: Int
    let status: String
    let systemImage: String
}

struct HFMockupReadinessLockItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let screenGroup: String
    let status: String
    let systemImage: String
}

struct HFFinalSpineSafetyItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let status: String
    let systemImage: String
}

struct HFFinalSpineCheckpoint: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let checkpointType: String
    let status: String
    let systemImage: String
}

enum HFProductSpineFinalWalkthroughData {
    static let walkthroughSteps: [HFFinalSpineWalkthroughStep] = [
        HFFinalSpineWalkthroughStep(title: "Start at Home", subtitle: "Begin with the viewer-facing streaming surface and product spine entry points.", pillar: "Watch", stepNumber: 1, status: "Local route", systemImage: "house.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Search / Discover", subtitle: "Confirm the viewer can move from Home into discovery without leaving local data.", pillar: "Watch", stepNumber: 2, status: "Local route", systemImage: "magnifyingglass"),
        HFFinalSpineWalkthroughStep(title: "Open Unified Discovery", subtitle: "Review unified discovery as a local browsing surface.", pillar: "Watch", stepNumber: 3, status: "Local route", systemImage: "sparkles.rectangle.stack.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Movie Detail if safe", subtitle: "Use existing title routes only; do not change IDs, posters, or backdrop mappings.", pillar: "Watch", stepNumber: 4, status: "Local route", systemImage: "film.fill"),
        HFFinalSpineWalkthroughStep(title: "Review My List", subtitle: "Confirm saved-title review remains local and does not persist new state.", pillar: "Watch", stepNumber: 5, status: "Local route", systemImage: "bookmark.fill"),
        HFFinalSpineWalkthroughStep(title: "Review Downloads", subtitle: "Confirm downloads remain a local preview and do not touch files.", pillar: "Watch", stepNumber: 6, status: "Local route", systemImage: "arrow.down.circle.fill"),

        HFFinalSpineWalkthroughStep(title: "Open Profile", subtitle: "Use Profile as the local hub for creator, connect, launch, and final lock routes.", pillar: "Create", stepNumber: 7, status: "Local route", systemImage: "person.crop.circle.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Creator Mode", subtitle: "Review the creator entry without auth, accounts, backend, or uploads.", pillar: "Create", stepNumber: 8, status: "Local route", systemImage: "wand.and.stars"),
        HFFinalSpineWalkthroughStep(title: "Open Creator Command Center", subtitle: "Confirm the creator workflow spine is reachable from local SwiftUI routes.", pillar: "Create", stepNumber: 9, status: "Local route", systemImage: "command"),
        HFFinalSpineWalkthroughStep(title: "Open Package Builder", subtitle: "Review package-building preview copy without file picker or upload behavior.", pillar: "Create", stepNumber: 10, status: "Local route", systemImage: "shippingbox.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Team Review", subtitle: "Confirm team review remains local mock copy, not real collaboration.", pillar: "Create", stepNumber: 11, status: "Local route", systemImage: "person.3.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Release Readiness", subtitle: "Review readiness signals without App Store automation or submission flow.", pillar: "Create", stepNumber: 12, status: "Static preview", systemImage: "checkmark.seal.fill"),

        HFFinalSpineWalkthroughStep(title: "Open Connect Hub", subtitle: "Confirm community preview starts locally and does not create accounts.", pillar: "Connect", stepNumber: 13, status: "Local route", systemImage: "person.2.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Social Rooms", subtitle: "Review social-room copy as local mock content only.", pillar: "Connect", stepNumber: 14, status: "Static preview", systemImage: "bubble.left.and.bubble.right.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Creator Circles", subtitle: "Confirm creator relationship previews do not enable real follows or messaging.", pillar: "Connect", stepNumber: 15, status: "Static preview", systemImage: "person.3.sequence.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Activity Feed", subtitle: "Review feed cards without network, push, analytics, or social APIs.", pillar: "Connect", stepNumber: 16, status: "Static preview", systemImage: "waveform.path.ecg"),
        HFFinalSpineWalkthroughStep(title: "Open Social Graph / Follow Suggestions if present", subtitle: "Keep graph and suggestion surfaces preview-only and locked to mock data.", pillar: "Connect", stepNumber: 17, status: "Static preview", systemImage: "point.3.connected.trianglepath.dotted"),

        HFFinalSpineWalkthroughStep(title: "Open Launch Center", subtitle: "Confirm launch planning is reachable as a local creator preview.", pillar: "Launch", stepNumber: 18, status: "Local route", systemImage: "flag.checkered"),
        HFFinalSpineWalkthroughStep(title: "Open Access Preview", subtitle: "Review access copy without accounts, permissions, payments, or entitlements.", pillar: "Launch", stepNumber: 19, status: "Local route", systemImage: "ticket.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Release Presentation", subtitle: "Review the local product story without App Store preparation.", pillar: "Launch", stepNumber: 20, status: "Local route", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Demo Checklist", subtitle: "Confirm checklist rows are static display only and do not run QA automation.", pillar: "Launch", stepNumber: 21, status: "Static preview", systemImage: "checklist.checked"),

        HFFinalSpineWalkthroughStep(title: "Open Product Spine Completion", subtitle: "Start final export/safety review from the local spine hub.", pillar: "Export / Safety", stepNumber: 22, status: "Local route", systemImage: "rectangle.connected.to.line.below"),
        HFFinalSpineWalkthroughStep(title: "Open Locked Systems Map", subtitle: "Confirm real export, capture, share, render, and upload systems remain locked.", pillar: "Export / Safety", stepNumber: 23, status: "Locked", systemImage: "lock.shield.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Visual Parity Backlog", subtitle: "Confirm mockup matching is planned later and not started here.", pillar: "Export / Safety", stepNumber: 24, status: "Later", systemImage: "rectangle.3.group.fill"),
        HFFinalSpineWalkthroughStep(title: "Open Pre-Mockup Readiness Review", subtitle: "Finish with the structure gate before any visual parity phase.", pillar: "Export / Safety", stepNumber: 25, status: "Gate", systemImage: "checkmark.circle.fill")
    ]

    static let mockupReadinessItems: [HFMockupReadinessLockItem] = [
        HFMockupReadinessLockItem(title: "Home structure stable", subtitle: "Home keeps streaming first and spine review lower on the page.", screenGroup: "Home + Tabs", status: "Stable", systemImage: "house.fill"),
        HFMockupReadinessLockItem(title: "Five tabs stable", subtitle: "Home, Search, Library, Downloads, and Profile remain unchanged.", screenGroup: "Home + Tabs", status: "Stable", systemImage: "rectangle.bottomthird.inset.filled"),
        HFMockupReadinessLockItem(title: "Search/Discover stable", subtitle: "Discovery routes remain viewer-facing and local.", screenGroup: "Home + Tabs", status: "Stable", systemImage: "magnifyingglass"),
        HFMockupReadinessLockItem(title: "Library/My List stable", subtitle: "Saved-title surfaces remain reachable without new persistence.", screenGroup: "Home + Tabs", status: "Stable", systemImage: "bookmark.fill"),
        HFMockupReadinessLockItem(title: "Downloads stable", subtitle: "Downloads stay a local preview and do not access files.", screenGroup: "Home + Tabs", status: "Stable", systemImage: "arrow.down.circle.fill"),
        HFMockupReadinessLockItem(title: "Profile hub stable", subtitle: "Profile exposes local product review routes without account systems.", screenGroup: "Home + Tabs", status: "Stable", systemImage: "person.crop.circle.fill"),

        HFMockupReadinessLockItem(title: "Movie Detail route stable", subtitle: "Existing title detail route remains reviewable.", screenGroup: "Watch", status: "Stable", systemImage: "film.fill"),
        HFMockupReadinessLockItem(title: "Poster/backdrop mappings untouched", subtitle: "Visual parity later must not change mappings without a scoped phase.", screenGroup: "Watch", status: "Locked", systemImage: "photo.fill"),
        HFMockupReadinessLockItem(title: "Watch actions preserved", subtitle: "Watch Now and saved actions remain local preview controls.", screenGroup: "Watch", status: "Preserved", systemImage: "play.fill"),

        HFMockupReadinessLockItem(title: "Creator Mode route stable", subtitle: "Creator entry remains a local SwiftUI route.", screenGroup: "Create", status: "Stable", systemImage: "wand.and.stars"),
        HFMockupReadinessLockItem(title: "Creator Command Center route stable", subtitle: "Creator workflow review remains reachable.", screenGroup: "Create", status: "Stable", systemImage: "command"),
        HFMockupReadinessLockItem(title: "Package Builder route stable", subtitle: "Package preview remains local and does not upload files.", screenGroup: "Create", status: "Stable", systemImage: "shippingbox.fill"),
        HFMockupReadinessLockItem(title: "Release Readiness route stable", subtitle: "Readiness stays local and does not run App Store automation.", screenGroup: "Create", status: "Static", systemImage: "checkmark.seal.fill"),

        HFMockupReadinessLockItem(title: "Connect Hub route stable", subtitle: "Connect starts from local preview content.", screenGroup: "Connect", status: "Stable", systemImage: "person.2.fill"),
        HFMockupReadinessLockItem(title: "Social Rooms route stable", subtitle: "Rooms remain static preview surfaces.", screenGroup: "Connect", status: "Static", systemImage: "bubble.left.and.bubble.right.fill"),
        HFMockupReadinessLockItem(title: "Creator Circles route stable", subtitle: "Circle previews do not create real follows or messages.", screenGroup: "Connect", status: "Static", systemImage: "person.3.fill"),
        HFMockupReadinessLockItem(title: "Activity Feed route stable", subtitle: "Feed content remains mock and local.", screenGroup: "Connect", status: "Static", systemImage: "waveform.path.ecg"),
        HFMockupReadinessLockItem(title: "Social Graph / Follow Suggestions preview-only", subtitle: "Graph and suggestion routes remain mock-only.", screenGroup: "Connect", status: "Preview-only", systemImage: "point.3.connected.trianglepath.dotted"),

        HFMockupReadinessLockItem(title: "Launch Center route stable", subtitle: "Launch planning remains local and reviewable.", screenGroup: "Launch", status: "Stable", systemImage: "flag.checkered"),
        HFMockupReadinessLockItem(title: "Access Preview route stable", subtitle: "Access previews do not create accounts, purchases, or entitlements.", screenGroup: "Launch", status: "Stable", systemImage: "ticket.fill"),
        HFMockupReadinessLockItem(title: "Release Presentation route stable", subtitle: "Presentation remains a local product story.", screenGroup: "Launch", status: "Stable", systemImage: "rectangle.on.rectangle.angled.fill"),
        HFMockupReadinessLockItem(title: "Demo Checklist route stable", subtitle: "Checklist remains static display only.", screenGroup: "Launch", status: "Static", systemImage: "checklist.checked"),

        HFMockupReadinessLockItem(title: "Export remains preview-only", subtitle: "No capture, render, share, upload, or export pipeline is connected.", screenGroup: "Export / Safety", status: "Locked", systemImage: "square.and.arrow.up.fill"),
        HFMockupReadinessLockItem(title: "Locked Systems Map exists", subtitle: "Real-system locks are documented before visual work.", screenGroup: "Export / Safety", status: "Ready", systemImage: "lock.shield.fill"),
        HFMockupReadinessLockItem(title: "Visual Parity Backlog exists", subtitle: "Mockup matching is named as a later phase.", screenGroup: "Export / Safety", status: "Ready", systemImage: "rectangle.3.group.fill"),
        HFMockupReadinessLockItem(title: "No real capture/share/render systems connected", subtitle: "Visual parity must stay styling/layout only.", screenGroup: "Export / Safety", status: "Locked", systemImage: "nosign")
    ]

    static let safetyItems: [HFFinalSpineSafetyItem] = [
        HFFinalSpineSafetyItem(title: "Backend locked", subtitle: "No backend calls, APIs, or server sync are connected.", category: "Real Services", status: "Locked", systemImage: "server.rack"),
        HFFinalSpineSafetyItem(title: "Auth/accounts locked", subtitle: "No login, real accounts, follows, comments, reactions, or messaging.", category: "Real Services", status: "Locked", systemImage: "person.crop.circle.badge.xmark"),
        HFFinalSpineSafetyItem(title: "Payments/StoreKit locked", subtitle: "No purchases, subscriptions, entitlements, or payment flows.", category: "Real Services", status: "Locked", systemImage: "creditcard.fill"),
        HFFinalSpineSafetyItem(title: "Uploads locked", subtitle: "No upload, file picker, FileManager, or real file access.", category: "Real Services", status: "Locked", systemImage: "icloud.slash.fill"),
        HFFinalSpineSafetyItem(title: "Push/analytics locked", subtitle: "No notifications, analytics, or recommendation engine.", category: "Real Services", status: "Locked", systemImage: "bell.slash.fill"),
        HFFinalSpineSafetyItem(title: "Recommendation engine locked", subtitle: "Recommendation language remains local/mock only.", category: "Real Services", status: "Locked", systemImage: "sparkles"),

        HFFinalSpineSafetyItem(title: "AVPlayer locked", subtitle: "No real playback implementation is connected.", category: "Media + Capture", status: "Locked", systemImage: "play.slash.fill"),
        HFFinalSpineSafetyItem(title: "Camera locked", subtitle: "No camera capture or AVCaptureSession usage.", category: "Media + Capture", status: "Locked", systemImage: "camera.fill"),
        HFFinalSpineSafetyItem(title: "ReplayKit locked", subtitle: "No ReplayKit or screen recording usage.", category: "Media + Capture", status: "Locked", systemImage: "record.circle"),
        HFFinalSpineSafetyItem(title: "Photos locked", subtitle: "No Photos permissions, pickers, or library access.", category: "Media + Capture", status: "Locked", systemImage: "photo.on.rectangle"),
        HFFinalSpineSafetyItem(title: "Share sheet locked", subtitle: "No ShareLink, UIActivityViewController, or social SDKs.", category: "Media + Capture", status: "Locked", systemImage: "square.and.arrow.up"),
        HFFinalSpineSafetyItem(title: "Screenshot/render pipeline locked", subtitle: "No screenshot generation, ImageRenderer, UIGraphicsImageRenderer, PDF, or slide export.", category: "Media + Capture", status: "Locked", systemImage: "viewfinder"),

        HFFinalSpineSafetyItem(title: "Figma sync locked", subtitle: "No Figma changes or sync are part of this phase.", category: "Design + Protected Paths", status: "Locked", systemImage: "rectangle.3.group.fill"),
        HFFinalSpineSafetyItem(title: "Asset catalog changes locked", subtitle: "Assets remain untouched before visual parity scope.", category: "Design + Protected Paths", status: "Locked", systemImage: "folder.fill.badge.minus"),
        HFFinalSpineSafetyItem(title: "Poster mappings locked", subtitle: "Poster and backdrop mappings remain unchanged.", category: "Design + Protected Paths", status: "Locked", systemImage: "photo.fill"),
        HFFinalSpineSafetyItem(title: "Protected media/depth/motion/rendering locked", subtitle: "Protected paths stay untouched unless separately scoped.", category: "Design + Protected Paths", status: "Locked", systemImage: "lock.shield.fill")
    ]

    static let checkpoints: [HFFinalSpineCheckpoint] = [
        HFFinalSpineCheckpoint(title: "Tree clean", subtitle: "Start visual work only from a clean working tree.", checkpointType: "Repo Requirements", status: "Required", systemImage: "checkmark.circle.fill"),
        HFFinalSpineCheckpoint(title: "Feature tag on HEAD", subtitle: "The completed feature commit must be tagged before QA.", checkpointType: "Repo Requirements", status: "Required", systemImage: "tag.fill"),
        HFFinalSpineCheckpoint(title: "QA tag on HEAD", subtitle: "The QA-passed tag must be on the reviewed commit.", checkpointType: "Repo Requirements", status: "Required", systemImage: "tag.circle.fill"),
        HFFinalSpineCheckpoint(title: "No unrelated dirty files", subtitle: "Only scoped visual files may change in the later visual pass.", checkpointType: "Repo Requirements", status: "Required", systemImage: "doc.badge.ellipsis"),
        HFFinalSpineCheckpoint(title: "No project churn", subtitle: "Project file membership/order churn must not be included.", checkpointType: "Repo Requirements", status: "Required", systemImage: "doc.text.magnifyingglass"),

        HFFinalSpineCheckpoint(title: "Final Spine Walkthrough reviewed", subtitle: "Review the full Watch, Create, Connect, Launch, Export sequence.", checkpointType: "Product Requirements", status: "Required", systemImage: "map.fill"),
        HFFinalSpineCheckpoint(title: "Mockup Readiness Lock reviewed", subtitle: "Confirm route structure is stable before styling work.", checkpointType: "Product Requirements", status: "Required", systemImage: "checkmark.seal.fill"),
        HFFinalSpineCheckpoint(title: "Spine Safety Seal reviewed", subtitle: "Confirm real systems remain locked.", checkpointType: "Product Requirements", status: "Required", systemImage: "lock.shield.fill"),
        HFFinalSpineCheckpoint(title: "Route Quality Center reviewed", subtitle: "Confirm live routes and locked placeholders are clear.", checkpointType: "Product Requirements", status: "Required", systemImage: "arrow.triangle.branch"),
        HFFinalSpineCheckpoint(title: "Pre-Mockup Readiness Review reviewed", subtitle: "Confirm the structure gate is complete.", checkpointType: "Product Requirements", status: "Required", systemImage: "checkmark.circle.fill"),

        HFFinalSpineCheckpoint(title: "Mockups/screenshots selected", subtitle: "Visual references must be named before styling begins.", checkpointType: "Visual Scope Requirements", status: "Before Visual Pass", systemImage: "rectangle.3.group.fill"),
        HFFinalSpineCheckpoint(title: "Target screen list defined", subtitle: "Visual parity should identify exact screens before editing.", checkpointType: "Visual Scope Requirements", status: "Before Visual Pass", systemImage: "list.bullet.rectangle"),
        HFFinalSpineCheckpoint(title: "Allowed visual files defined", subtitle: "The later visual pass should name safe SwiftUI/design-system files.", checkpointType: "Visual Scope Requirements", status: "Before Visual Pass", systemImage: "doc.text.fill"),
        HFFinalSpineCheckpoint(title: "Forbidden paths defined", subtitle: "Protected, asset, poster, plist, StoreKit, and entitlement paths stay excluded.", checkpointType: "Visual Scope Requirements", status: "Before Visual Pass", systemImage: "nosign"),
        HFFinalSpineCheckpoint(title: "No real systems included", subtitle: "The visual pass is styling/layout only and must not expand product scope.", checkpointType: "Visual Scope Requirements", status: "Required", systemImage: "lock.fill")
    ]

    static func walkthroughSteps(for pillar: String) -> [HFFinalSpineWalkthroughStep] {
        walkthroughSteps.filter { $0.pillar == pillar }
    }

    static func readinessItems(for group: String) -> [HFMockupReadinessLockItem] {
        mockupReadinessItems.filter { $0.screenGroup == group }
    }

    static func safetyItems(for category: String) -> [HFFinalSpineSafetyItem] {
        safetyItems.filter { $0.category == category }
    }

    static func checkpoints(for type: String) -> [HFFinalSpineCheckpoint] {
        checkpoints.filter { $0.checkpointType == type }
    }
}
