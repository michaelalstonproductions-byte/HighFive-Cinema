import Foundation

enum HFConnectPreviewData {
    static let featuredCreators: [HFConnectCreator] = [
        HFConnectCreator(
            name: "Maya Hart",
            role: "Director",
            bio: "Building atmospheric genre stories and practical-world previews.",
            followers: "18.4K",
            projects: ["The Friendly — Creator Package", "Behind the Vision — Short"],
            updates: ["Shared a new poster pass", "Marked trailer notes as ready for review"]
        ),
        HFConnectCreator(
            name: "Jon Bell",
            role: "Editor",
            bio: "Cutting creator trailers, preview reels, and release-ready packages.",
            followers: "9.7K",
            projects: ["Paranormall — Season 1 Preview", "Night Market Teaser"],
            updates: ["Flagged a tighter trailer opening", "Updated preview clip pacing"]
        ),
        HFConnectCreator(
            name: "Ari Chen",
            role: "Composer",
            bio: "Scoring cinematic releases with intimate, textural themes.",
            followers: "7.2K",
            projects: ["The Friendly — Creator Package", "Signal House"],
            updates: ["Added theme sketches", "Posted a sound palette note"]
        )
    ]

    static let projectUpdates: [HFConnectProjectUpdate] = [
        HFConnectProjectUpdate(title: "The Friendly — Creator Package", detail: "Poster artwork approved and team review remains active.", status: "Team Review", systemImage: "checkmark.seal.fill"),
        HFConnectProjectUpdate(title: "Paranormall — Season 1 Preview", detail: "New season preview package is trending in mock discovery.", status: "Preview", systemImage: "sparkles"),
        HFConnectProjectUpdate(title: "Behind the Vision — Short", detail: "Submission notes and creator commentary were refreshed.", status: "Updated", systemImage: "note.text")
    ]

    static let communitySignals: [HFConnectSignal] = [
        HFConnectSignal(title: "Creator saves", value: "1.2K", systemImage: "bookmark.fill"),
        HFConnectSignal(title: "Mock follows", value: "48", systemImage: "person.2.fill"),
        HFConnectSignal(title: "Project updates", value: "12", systemImage: "rectangle.stack.fill"),
        HFConnectSignal(title: "Trending packages", value: "3", systemImage: "flame.fill")
    ]

    static let trendingPackages = [
        "The Friendly — Creator Package",
        "Paranormall — Season 1 Preview",
        "Behind the Vision — Short",
        "Night Market Teaser"
    ]

    static let feedItems: [HFConnectActivityItem] = [
        HFConnectActivityItem(title: "Poster artwork approved", detail: "Creative Lead approved the latest Friendly package poster.", actor: "Maya Hart", reactions: "128", comments: "14", systemImage: "photo.fill"),
        HFConnectActivityItem(title: "Trailer note opened", detail: "Editor flagged the opening sequence for one tighter pass.", actor: "Jon Bell", reactions: "84", comments: "9", systemImage: "film.fill"),
        HFConnectActivityItem(title: "Marketplace preview generated", detail: "The Friendly package received a new mock marketplace signal.", actor: "HighFive Preview", reactions: "212", comments: "21", systemImage: "storefront.fill"),
        HFConnectActivityItem(title: "Creator profile refreshed", detail: "Ari Chen added new score notes for the launch package.", actor: "Ari Chen", reactions: "63", comments: "5", systemImage: "music.note")
    ]
}

struct HFConnectCreator: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let bio: String
    let followers: String
    let projects: [String]
    let updates: [String]
}

struct HFConnectProjectUpdate: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

struct HFConnectSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

struct HFConnectActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let actor: String
    let reactions: String
    let comments: String
    let systemImage: String
}
