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

    static let communities: [HFConnectCommunity] = [
        HFConnectCommunity(name: "The Friendly Watch Circle", subtitle: "Creator package updates, cast notes, and launch planning.", members: "2.4K", category: "Film Circles", status: "Preview", systemImage: "person.3.fill"),
        HFConnectCommunity(name: "Paranormall Fan Room", subtitle: "Season theories, episode drops, and creator notes.", members: "8.1K", category: "Fan Theories", status: "Active Preview", systemImage: "sparkles"),
        HFConnectCommunity(name: "HighFive Creator Lab", subtitle: "Packaging, review, launch, and marketplace discussion.", members: "1.7K", category: "Creator Labs", status: "Preview", systemImage: "hammer.fill"),
        HFConnectCommunity(name: "Indie Film Builders", subtitle: "Directors, editors, composers, poster artists, and collaborators.", members: "5.3K", category: "Marketplace Interest", status: "Preview", systemImage: "film.stack.fill")
    ]

    static let discoveryCategories = [
        "Film Circles",
        "Creator Labs",
        "Watch Parties",
        "Marketplace Interest",
        "Review Rooms",
        "Fan Theories"
    ]

    static let recommendedCommunities = [
        "The Friendly Watch Circle",
        "Creator Launch Lab",
        "Poster Design Room",
        "Studio Review Preview"
    ]

    static let watchParties: [HFConnectWatchParty] = [
        HFConnectWatchParty(title: "The Friendly — Preview Night", host: "HighFive Cinema", time: "Tonight, 8:00 PM", guests: "124 waiting", status: "Preview Only", movieTitle: "The Friendly"),
        HFConnectWatchParty(title: "Paranormall Season 1 Theory Night", host: "Creator Lab", time: "Friday, 9:00 PM", guests: "212 interested", status: "Planned Preview", movieTitle: "Paranormall"),
        HFConnectWatchParty(title: "Black Turnip Creator Commentary", host: "Indie Film Builders", time: "Saturday, 7:30 PM", guests: "88 interested", status: "Preview", movieTitle: "Black Turnip"),
        HFConnectWatchParty(title: "Behind the Vision Live Notes", host: "Maya Hart", time: "Sunday, 6:00 PM", guests: "61 interested", status: "Preview", movieTitle: "Behind the Vision"),
        HFConnectWatchParty(title: "Marketplace Package Review Room", host: "HighFive Creator Lab", time: "Next week", guests: "48 watching", status: "Preview", movieTitle: "Creator Marketplace")
    ]

    static let projectCommunity = HFConnectProjectCommunity(
        projectTitle: "The Friendly",
        subtitle: "Creator Package",
        followers: "1.2K",
        updates: "18",
        status: "In Review",
        feed: [
            "Poster artwork approved",
            "Trailer cut flagged for review",
            "Launch readiness updated",
            "Team review moved to internal review",
            "Marketplace interest increased"
        ],
        signals: [
            HFConnectSignal(title: "Saves", value: "1.2K", systemImage: "bookmark.fill"),
            HFConnectSignal(title: "Reactions", value: "4.8K", systemImage: "hand.thumbsup.fill"),
            HFConnectSignal(title: "Comments preview", value: "318", systemImage: "text.bubble.fill"),
            HFConnectSignal(title: "Marketplace interest", value: "48", systemImage: "storefront.fill")
        ]
    )

    static let socialRooms: [HFConnectSocialRoom] = [
        HFConnectSocialRoom(name: "The Friendly Watch Room", type: "Watch Circle", subtitle: "Creator package updates, cast notes, and preview-night planning.", members: "2.4K", activeNow: "37", status: "Live Preview", category: "Watch Circles", reactions: "428", comments: "37"),
        HFConnectSocialRoom(name: "Creator Launch Lab", type: "Creator Circle", subtitle: "Launch readiness, access preview, and marketplace planning.", members: "1.7K", activeNow: "18", status: "Preview", category: "Creator Labs", reactions: "216", comments: "24"),
        HFConnectSocialRoom(name: "Poster Design Room", type: "Collaboration Room", subtitle: "Campaign art, visual polish, and creator package feedback.", members: "842", activeNow: "12", status: "Preview", category: "Collaboration", reactions: "184", comments: "19"),
        HFConnectSocialRoom(name: "Studio Review Lounge", type: "Review Room", subtitle: "Submission notes, readiness blockers, and internal review signals.", members: "318", activeNow: "8", status: "Internal Preview", category: "Review Rooms", reactions: "92", comments: "11")
    ]

    static let roomCategories = [
        "Watch Circles",
        "Creator Labs",
        "Review Rooms",
        "Fan Theories",
        "Marketplace Interest",
        "Collaboration"
    ]

    static let roomActivity = [
        "Trailer cut discussion opened.",
        "Poster artwork received new reactions.",
        "Studio Review Lounge added submission notes.",
        "Creator Launch Lab shared release checklist."
    ]

    static let creatorCircles: [HFConnectCreatorCircle] = [
        HFConnectCreatorCircle(name: "Directors Circle", focus: "visual storytelling, packaging, review", members: "4.8K", status: "Preview", suggestedRoles: ["Creative Lead", "Studio Reviewer"]),
        HFConnectCreatorCircle(name: "Editors Circle", focus: "trailers, preview clips, pacing", members: "3.2K", status: "Preview", suggestedRoles: ["Trailer Editor", "Preview Producer"]),
        HFConnectCreatorCircle(name: "Poster Artists Circle", focus: "campaign art and package visuals", members: "1.9K", status: "Trending Preview", suggestedRoles: ["Poster Designer", "Creative Lead"]),
        HFConnectCreatorCircle(name: "Composer Circle", focus: "score, sound, cinematic mood", members: "1.1K", status: "Preview", suggestedRoles: ["Composer", "Sound Designer"]),
        HFConnectCreatorCircle(name: "Studio Review Circle", focus: "readiness, rights, release planning", members: "620", status: "Internal Preview", suggestedRoles: ["Studio Reviewer", "Producer"])
    ]

    static let suggestedConnections: [HFConnectSuggestedConnection] = [
        HFConnectSuggestedConnection(name: "Creative Lead", role: "Reviewer", focus: "package polish and approval notes"),
        HFConnectSuggestedConnection(name: "Trailer Editor", role: "Contributor", focus: "preview clips and pacing"),
        HFConnectSuggestedConnection(name: "Poster Designer", role: "Collaborator", focus: "campaign art and key visuals"),
        HFConnectSuggestedConnection(name: "Studio Reviewer", role: "Reviewer", focus: "readiness, rights, and release planning")
    ]

    static let roomDiscussions: [HFConnectRoomDiscussion] = [
        HFConnectRoomDiscussion(title: "What should lead the trailer opening?", author: "HighFive Cinema", body: "The room is comparing a faster hook against a quieter character-first opening.", replies: "37", reactions: "248", status: "Featured"),
        HFConnectRoomDiscussion(title: "Poster artwork feels ready", author: "Creative Lead", body: "The current one-sheet gives the package a stronger premium signal.", replies: "18", reactions: "132", status: "Resolved Preview"),
        HFConnectRoomDiscussion(title: "Creator notes need one final pass", author: "Studio Review", body: "Submission notes read well, but the rights section should be easier to scan.", replies: "9", reactions: "64", status: "Open Preview")
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

struct HFConnectCommunity: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let members: String
    let category: String
    let status: String
    let systemImage: String
}

struct HFConnectWatchParty: Identifiable {
    let id = UUID()
    let title: String
    let host: String
    let time: String
    let guests: String
    let status: String
    let movieTitle: String
}

struct HFConnectProjectCommunity: Identifiable {
    let id = UUID()
    let projectTitle: String
    let subtitle: String
    let followers: String
    let updates: String
    let status: String
    let feed: [String]
    let signals: [HFConnectSignal]
}

struct HFConnectSocialRoom: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let subtitle: String
    let members: String
    let activeNow: String
    let status: String
    let category: String
    let reactions: String
    let comments: String
}

struct HFConnectCreatorCircle: Identifiable {
    let id = UUID()
    let name: String
    let focus: String
    let members: String
    let status: String
    let suggestedRoles: [String]
}

struct HFConnectSuggestedConnection: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let focus: String
}

struct HFConnectRoomDiscussion: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let body: String
    let replies: String
    let reactions: String
    let status: String
}
