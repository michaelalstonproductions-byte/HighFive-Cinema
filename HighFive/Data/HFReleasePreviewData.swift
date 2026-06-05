import Foundation

enum HFReleasePreviewData {
    static let productSnapshot: [HFReleaseStatusItem] = [
        HFReleaseStatusItem(title: "Streaming foundation", status: "Ready", systemImage: "play.rectangle.fill"),
        HFReleaseStatusItem(title: "Creator workflow", status: "Preview", systemImage: "command"),
        HFReleaseStatusItem(title: "Launch center", status: "Preview", systemImage: "flag.checkered"),
        HFReleaseStatusItem(title: "Access model", status: "Mock only", systemImage: "lock.shield.fill"),
        HFReleaseStatusItem(title: "Protected depth systems", status: "Untouched", systemImage: "checkmark.shield.fill")
    ]

    static let featureHighlights: [HFReleaseFeatureHighlight] = [
        HFReleaseFeatureHighlight(title: "Premium Streaming", detail: "Home, Search, Discover, My List, Downloads, Profiles.", systemImage: "film.stack.fill"),
        HFReleaseFeatureHighlight(title: "Creator Command Center", detail: "Track package, assets, review, versions, and permissions.", systemImage: "command"),
        HFReleaseFeatureHighlight(title: "Launch Readiness", detail: "Preview audience, marketplace, and release planning.", systemImage: "gauge.with.dots.needle.67percent"),
        HFReleaseFeatureHighlight(title: "Access Preview", detail: "Mock audience access model without real payments.", systemImage: "lock.shield.fill"),
        HFReleaseFeatureHighlight(title: "Cinematic Design System", detail: "Dark glass UI, gold accents, poster-first experiences.", systemImage: "sparkles")
    ]

    static let demoChecklist: [HFReleaseChecklistItem] = [
        HFReleaseChecklistItem(title: "Open Home", group: "Presentation"),
        HFReleaseChecklistItem(title: "Search and Discover", group: "Presentation"),
        HFReleaseChecklistItem(title: "Open Movie Detail", group: "Presentation"),
        HFReleaseChecklistItem(title: "Add to My List", group: "Presentation"),
        HFReleaseChecklistItem(title: "Open Creator Mode", group: "Presentation"),
        HFReleaseChecklistItem(title: "Open Command Center", group: "Presentation"),
        HFReleaseChecklistItem(title: "Open Launch Center", group: "Presentation"),
        HFReleaseChecklistItem(title: "Open Access Preview", group: "Presentation")
    ]

    static let releaseNotes: [HFReleaseNote] = [
        HFReleaseNote(phase: "Phase 1", detail: "Streaming foundation"),
        HFReleaseNote(phase: "Phase 2", detail: "Runtime polish and asset hygiene"),
        HFReleaseNote(phase: "Phase 3", detail: "Creator entry and preview shells"),
        HFReleaseNote(phase: "Phase 4", detail: "Creator workflow chain"),
        HFReleaseNote(phase: "Phase 5", detail: "Mega product polish and launch/access previews")
    ]

    static let releaseComingNext = [
        "Real account system",
        "Real payment/access system",
        "Real creator uploads",
        "Real marketplace transactions",
        "Real analytics",
        "Protected depth/playback expansion"
    ]

    static let onboardingSteps: [HFPreviewStep] = [
        HFPreviewStep(title: "Welcome", detail: "Stream cinematic originals and previews.", systemImage: "sparkles"),
        HFPreviewStep(title: "Discover", detail: "Find films, creator packages, and coming-soon titles.", systemImage: "magnifyingglass"),
        HFPreviewStep(title: "Creator Mode", detail: "Package, review, and prepare your slate.", systemImage: "wand.and.stars"),
        HFPreviewStep(title: "Launch Center", detail: "Preview release readiness and audience access.", systemImage: "flag.checkered"),
        HFPreviewStep(title: "Safe Preview Mode", detail: "This build uses local mock data only.", systemImage: "checkmark.shield.fill")
    ]

    static let streamingDemoItems = [
        "Home loads",
        "Search / Discover works",
        "Movie Detail opens",
        "My List updates locally",
        "Downloads update locally",
        "Profile and Notifications open"
    ]

    static let creatorDemoItems = [
        "Creator Mode opens",
        "Command Center opens",
        "Studio opens",
        "Dashboard opens",
        "Marketplace opens",
        "Package Builder opens",
        "Asset Manager opens",
        "Submission Workflow opens",
        "Team Review opens",
        "Version History opens",
        "Team Permissions opens",
        "Launch Center opens",
        "Access Preview opens"
    ]

    static let safetyDemoItems = [
        "No backend",
        "No auth",
        "No payments",
        "No real uploads",
        "Protected systems untouched"
    ]
}

struct HFReleaseStatusItem: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

struct HFReleaseFeatureHighlight: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct HFReleaseChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let group: String
}

struct HFReleaseNote: Identifiable {
    let id = UUID()
    let phase: String
    let detail: String
}

struct HFPreviewStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}
