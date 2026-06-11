import Foundation

enum HFFinalDemoTourData {
    static let statusChips = ["Consumer First", "Five Product Rooms", "Creator Suite", "Public Momentum", "Professional Delivery", "Internal QA"]

    static let acts: [HFDemoAct] = [
        HFDemoAct(
            title: "Act 1 - Watch First",
            purpose: "Show that HighFive opens as a premium streaming app.",
            accessibilityLabel: "Act One Watch First, consumer streaming demo path",
            steps: watchSteps
        ),
        HFDemoAct(
            title: "Act 2 - HighFive Rooms",
            purpose: "Reveal the larger product ecosystem without changing the consumer tab shell.",
            accessibilityLabel: "Act Two HighFive Rooms, product ecosystem demo path",
            steps: roomSteps
        ),
        HFDemoAct(
            title: "Act 3 - Internal Validation",
            purpose: "Show that HighFive has an internal control room protecting the product.",
            accessibilityLabel: "Act Three Internal Validation, developer and QA control room demo path",
            steps: internalSteps
        )
    ]

    static let steps: [HFFinalDemoStep] = watchSteps + roomSteps + internalSteps

    static let watchSteps: [HFFinalDemoStep] = [
        HFFinalDemoStep(
            actName: "Act 1 - Watch First",
            title: "Home",
            subtitle: "Cinematic hero, poster rails, Watch Now, streaming-first impression.",
            pillar: "WATCH",
            routeLabel: "Bottom Tab -> Home",
            purpose: "Open with cinematic streaming.",
            expectedProof: "User immediately understands they are here to watch great content.",
            screenshotTarget: "highfive-demo-home.png",
            safetyNote: "No internal tools visible.",
            status: "Needs Screenshot",
            systemImage: "house.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 1 - Watch First",
            title: "Search / Discover",
            subtitle: "Find movies, originals, saved titles, and upcoming premieres.",
            pillar: "WATCH",
            routeLabel: "Bottom Tab -> Search",
            purpose: "Keep discovery content-first.",
            expectedProof: "Discovery feels like streaming, not an internal route list.",
            screenshotTarget: "highfive-demo-search-discover.png",
            safetyNote: "No route matrix or QA language.",
            status: "Needs Screenshot",
            systemImage: "magnifyingglass"
        ),
        HFFinalDemoStep(
            actName: "Act 1 - Watch First",
            title: "Movie Detail",
            subtitle: "Cinematic title page with hero, metadata, Watch Now, Save, and related titles.",
            pillar: "WATCH",
            routeLabel: "Home/Search -> Movie Detail",
            purpose: "Let a viewer evaluate a title like a streaming app.",
            expectedProof: "Hero, metadata, primary action, and related titles are readable.",
            screenshotTarget: "highfive-demo-movie-detail.png",
            safetyNote: "No AVPlayer or live playback integration.",
            status: "Needs Manual QA",
            systemImage: "film.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 1 - Watch First",
            title: "Library / My List",
            subtitle: "Saved titles, in-progress viewing, and downloaded titles.",
            pillar: "WATCH",
            routeLabel: "Bottom Tab -> Library",
            purpose: "Show the viewer can manage their viewing life.",
            expectedProof: "Saved and in-progress content feels consumer-facing.",
            screenshotTarget: "highfive-demo-library.png",
            safetyNote: "No account or file-management requirement.",
            status: "Needs Screenshot",
            systemImage: "bookmark.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 1 - Watch First",
            title: "Downloads",
            subtitle: "Offline-ready titles, storage card, and Find More To Download.",
            pillar: "WATCH",
            routeLabel: "Bottom Tab -> Downloads",
            purpose: "Prove Downloads is a streaming shelf.",
            expectedProof: "Downloads does not feel like a file manager.",
            screenshotTarget: "highfive-demo-downloads.png",
            safetyNote: "No FileManager or download-to-disk behavior.",
            status: "Needs Screenshot",
            systemImage: "arrow.down.circle.fill"
        )
    ]

    static let roomSteps: [HFFinalDemoStep] = [
        HFFinalDemoStep(
            actName: "Act 2 - HighFive Rooms",
            title: "Watch Room",
            subtitle: "The streaming layer summarized as a product room.",
            pillar: "WATCH",
            routeLabel: "Profile -> HighFive Rooms -> Watch",
            purpose: "Show Watch remains the primary public experience.",
            expectedProof: "Watch Room references Home, Search, Library, Downloads, and Movie Detail.",
            screenshotTarget: "highfive-demo-watch-room.png",
            safetyNote: "No AVPlayer or real playback added.",
            status: "Ready",
            systemImage: "play.rectangle.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 2 - HighFive Rooms",
            title: "Creator Studio",
            subtitle: "Projects, creator profile, pitch, media kit, and launch prep.",
            pillar: "CREATE",
            routeLabel: "Profile -> HighFive Rooms -> Create",
            purpose: "Show creators can prepare content.",
            expectedProof: "Studio structure exists without upload, backend, render, or export systems.",
            screenshotTarget: "highfive-demo-creator-studio.png",
            safetyNote: "Protected Creator engine path remains untouched.",
            status: "Ready",
            systemImage: "wand.and.stars"
        ),
        HFFinalDemoStep(
            actName: "Act 2 - HighFive Rooms",
            title: "Connect Room",
            subtitle: "Communities, reactions, following, creator updates, and watch community.",
            pillar: "CONNECT",
            routeLabel: "Profile -> HighFive Rooms -> Connect",
            purpose: "Preview audience connection.",
            expectedProof: "Connection appears without messaging, notifications, analytics, or backend.",
            screenshotTarget: "highfive-demo-connect-room.png",
            safetyNote: "No comments database, live chat, or social graph infrastructure.",
            status: "Ready",
            systemImage: "person.2.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 2 - HighFive Rooms",
            title: "Launch Room",
            subtitle: "Timeline, campaign, audience, materials, and release readiness.",
            pillar: "LAUNCH",
            routeLabel: "Profile -> HighFive Rooms -> Launch",
            purpose: "Preview release planning.",
            expectedProof: "Launch planning exists without payments, StoreKit, waitlists, analytics, or backend.",
            screenshotTarget: "highfive-demo-launch-room.png",
            safetyNote: "No campaign publishing or notification behavior.",
            status: "Ready",
            systemImage: "flag.checkered"
        ),
        HFFinalDemoStep(
            actName: "Act 2 - HighFive Rooms",
            title: "Export Room",
            subtitle: "Deliverables, media kit, festival package, platform checklist, and distribution readiness.",
            pillar: "EXPORT",
            routeLabel: "Profile -> HighFive Rooms -> Export",
            purpose: "Preview professional delivery readiness.",
            expectedProof: "Export readiness exists without export, render, file, share, or platform systems.",
            screenshotTarget: "highfive-demo-export-room.png",
            safetyNote: "Rendering, Layer4, Playback, Creator, and file systems remain protected.",
            status: "Ready",
            systemImage: "shippingbox.fill"
        )
    ]

    static let internalSteps: [HFFinalDemoStep] = [
        HFFinalDemoStep(
            actName: "Act 3 - Internal Validation",
            title: "Developer / QA Hub",
            subtitle: "Internal build room for release readiness, QA, route quality, and safety.",
            pillar: "INTERNAL",
            routeLabel: "Profile -> Internal -> Developer / QA Hub",
            purpose: "Show internal tools are separate from product rooms.",
            expectedProof: "Developer / QA is not the home for Watch, Create, Connect, Launch, or Export.",
            screenshotTarget: "highfive-demo-developer-qa.png",
            safetyNote: "Internal only.",
            status: "Internal Only",
            systemImage: "wrench.and.screwdriver.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 3 - Internal Validation",
            title: "Product Spine",
            subtitle: "Map WATCH -> CREATE -> CONNECT -> LAUNCH -> EXPORT.",
            pillar: "INTERNAL",
            routeLabel: "Developer / QA Hub -> Product Spine",
            purpose: "Prove product architecture is understandable and locked.",
            expectedProof: "Each pillar maps to the correct product room and sections.",
            screenshotTarget: "highfive-demo-product-spine.png",
            safetyNote: "Read-only static validation.",
            status: "Ready",
            systemImage: "point.3.connected.trianglepath.dotted"
        ),
        HFFinalDemoStep(
            actName: "Act 3 - Internal Validation",
            title: "Visual Parity Center",
            subtitle: "Show locked Figma source of truth.",
            pillar: "INTERNAL",
            routeLabel: "Developer / QA Hub -> Visual Parity",
            purpose: "Tie consumer UI to production frames.",
            expectedProof: "Figma file, key, canvas, and frame nodes are visible.",
            screenshotTarget: "highfive-demo-visual-parity.png",
            safetyNote: "No Figma mutation or asset URL hardcoding.",
            status: "Protected",
            systemImage: "rectangle.3.group.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 3 - Internal Validation",
            title: "Protected Systems Seal",
            subtitle: "Show protected paths and disconnected systems.",
            pillar: "INTERNAL",
            routeLabel: "Developer / QA Hub -> Protected Systems",
            purpose: "Prove sensitive systems are locked.",
            expectedProof: "Depth, Motion, Playback, Layer4, Rendering, Creator, UI, Store, assets, entitlements, and project files are protected.",
            screenshotTarget: "highfive-demo-protected-systems.png",
            safetyNote: "No unlock, edit, repair, or destructive actions.",
            status: "Protected",
            systemImage: "lock.shield.fill"
        ),
        HFFinalDemoStep(
            actName: "Act 3 - Internal Validation",
            title: "Screenshot Review",
            subtitle: "Show required screenshot targets.",
            pillar: "INTERNAL",
            routeLabel: "Developer / QA Hub -> Screenshot Review",
            purpose: "Give visual QA evidence requirements.",
            expectedProof: "Screenshot filenames, route focus, and needed status are visible.",
            screenshotTarget: "highfive-demo-demo-tour.png",
            safetyNote: "The app does not read screenshot files or run capture commands.",
            status: "Needs Screenshot",
            systemImage: "camera.viewfinder"
        )
    ]

    static let screenshotPlan: [HFDemoScreenshotTarget] = [
        HFDemoScreenshotTarget(filename: "highfive-demo-home.png", route: "Bottom Tab -> Home", reviewFocus: "Premium streaming first impression.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-search-discover.png", route: "Bottom Tab -> Search", reviewFocus: "Content discovery and filters.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-movie-detail.png", route: "Home/Search -> Movie Detail", reviewFocus: "Cinematic title page and actions.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-library.png", route: "Bottom Tab -> Library", reviewFocus: "Saved titles and viewing life.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-downloads.png", route: "Bottom Tab -> Downloads", reviewFocus: "Offline streaming shelf.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-profile.png", route: "Bottom Tab -> Profile", reviewFocus: "Consumer profile, HighFive Rooms, Internal separation.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-watch-room.png", route: "Profile -> HighFive Rooms -> Watch", reviewFocus: "Streaming room summary.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-creator-studio.png", route: "Profile -> HighFive Rooms -> Create", reviewFocus: "Studio structure without live systems.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-connect-room.png", route: "Profile -> HighFive Rooms -> Connect", reviewFocus: "Community preview without messaging/backend.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-launch-room.png", route: "Profile -> HighFive Rooms -> Launch", reviewFocus: "Launch readiness without payments/waitlists.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-export-room.png", route: "Profile -> HighFive Rooms -> Export", reviewFocus: "Distribution readiness without export/render/files.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-developer-qa.png", route: "Profile -> Internal -> Developer / QA", reviewFocus: "Internal control room.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-product-spine.png", route: "Developer / QA -> Product Spine", reviewFocus: "Five pillar mapping.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-visual-parity.png", route: "Developer / QA -> Visual Parity", reviewFocus: "Figma source of truth.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-protected-systems.png", route: "Developer / QA -> Protected Systems", reviewFocus: "Locked systems.", status: "Needed"),
        HFDemoScreenshotTarget(filename: "highfive-demo-demo-tour.png", route: "Developer / QA -> Consumer + Rooms Demo Tour", reviewFocus: "Three-act guided proof path.", status: "Needed")
    ]

    static let screenshotEvidencePlan: [HFDemoScreenshotTarget] = [
        HFDemoScreenshotTarget(filename: "consumer-evidence.png", route: "Home, Search, Movie Detail, Library, Downloads, Profile", reviewFocus: "Consumer Evidence", status: "Planned"),
        HFDemoScreenshotTarget(filename: "rooms-evidence.png", route: "Watch, Create, Connect, Launch, Export", reviewFocus: "Rooms Evidence", status: "Planned"),
        HFDemoScreenshotTarget(filename: "creator-suite-evidence.png", route: "Creator Studio", reviewFocus: "Creator Suite Evidence", status: "Planned"),
        HFDemoScreenshotTarget(filename: "launch-connect-evidence.png", route: "Connect Room and Launch Room", reviewFocus: "Launch + Connect Evidence", status: "Planned"),
        HFDemoScreenshotTarget(filename: "watch-export-evidence.png", route: "Watch Room and Export Room", reviewFocus: "Watch + Export Evidence", status: "Planned"),
        HFDemoScreenshotTarget(filename: "internal-qa-evidence.png", route: "Developer / QA", reviewFocus: "Internal QA Evidence", status: "Planned")
    ]

    static let ecosystemProofRows: [HFDemoProofRow] = [
        HFDemoProofRow(title: "Consumer shell built", detail: "Home, Search, Movie Detail, Library, Downloads, and Profile lead the app.", status: "Built", systemImage: "play.rectangle.fill"),
        HFDemoProofRow(title: "Rooms suite built", detail: "Watch, Create, Connect, Launch, and Export live through Profile.", status: "Built", systemImage: "rectangle.3.group.fill"),
        HFDemoProofRow(title: "Creator Studio deepened", detail: "Studio Slate, Project Package, Pitch Package, Media Kit, and Launch Prep are present.", status: "Built", systemImage: "wand.and.stars"),
        HFDemoProofRow(title: "Connect + Launch public momentum built", detail: "Audience energy, update planning, release calendar, and premiere packs are present.", status: "Built", systemImage: "person.2.fill"),
        HFDemoProofRow(title: "Watch + Export professional path built", detail: "Program board, viewing journey, delivery board, festival pack, and handoff planner are present.", status: "Built", systemImage: "shippingbox.fill"),
        HFDemoProofRow(title: "Evidence locks present", detail: "Prior verification passes captured source checks, screenshots, and review notes.", status: "Locked", systemImage: "checkmark.seal.fill"),
        HFDemoProofRow(title: "Live systems disconnected", detail: "Presentation mode stays local and static.", status: "Separated", systemImage: "bolt.slash.fill"),
        HFDemoProofRow(title: "Protected systems untouched", detail: "Sensitive media and app systems remain outside this presentation pass.", status: "Untouched", systemImage: "shield.lefthalf.filled")
    ]

    static let presentationRunOfShow: [HFDemoProofRow] = [
        HFDemoProofRow(title: "Start on Home", detail: "Lead with the premium streaming front door.", status: "1", systemImage: "house.fill"),
        HFDemoProofRow(title: "Open Movie Detail", detail: "Show title decision, public momentum, and related titles.", status: "2", systemImage: "film.fill"),
        HFDemoProofRow(title: "Open Profile", detail: "Move from viewer identity into the product suite.", status: "3", systemImage: "person.crop.circle.fill"),
        HFDemoProofRow(title: "Show Product Suite", detail: "Walk Watch, Create, Connect, Launch, and Export as one ecosystem.", status: "4", systemImage: "rectangle.3.group.fill"),
        HFDemoProofRow(title: "Open each Room", detail: "Show the local product story pillar by pillar.", status: "5", systemImage: "square.grid.3x3.fill"),
        HFDemoProofRow(title: "Finish in Developer / QA", detail: "Close with internal proof and safety review.", status: "6", systemImage: "lock.shield.fill")
    ]

    static let productStory: [HFDemoStoryItem] = [
        HFDemoStoryItem(label: "WATCH", value: "Premium streaming shell", systemImage: "play.rectangle.fill"),
        HFDemoStoryItem(label: "CREATE", value: "Creator Studio", systemImage: "wand.and.stars"),
        HFDemoStoryItem(label: "CONNECT", value: "Audience and community room", systemImage: "person.2.fill"),
        HFDemoStoryItem(label: "LAUNCH", value: "Premiere and campaign readiness", systemImage: "flag.checkered"),
        HFDemoStoryItem(label: "EXPORT", value: "Deliverables and distribution readiness", systemImage: "shippingbox.fill"),
        HFDemoStoryItem(label: "INTERNAL", value: "Developer / QA control room", systemImage: "lock.shield.fill")
    ]

    static let figmaFrames = [
        "HF_Home - Node 1:2",
        "HF_Movie_Detail - Node 1:78",
        "HF_Profile - Node 1:115",
        "HF_Downloads - Node 1:150",
        "HF_Discover - Node 1:191"
    ]

    static let protectedPaths = [
        "HighFive/App/Depth/*",
        "HighFive/App/Motion/*",
        "HighFive/App/Playback/*",
        "HighFive/App/Layer4/*",
        "HighFive/App/Rendering/*",
        "HighFive/App/Creator/*",
        "HighFive/App/UI/*",
        "HighFive/App/Store/*",
        "Assets.xcassets",
        "Poster mappings",
        "Backdrop mappings",
        "StoreKit",
        "Info.plist",
        "PrivacyInfo",
        "Entitlements",
        "Figma Blueprint"
    ]

    static let highlights: [HFFinalDemoHighlight] = [
        HFFinalDemoHighlight(title: "Streaming shell is first", subtitle: "Home, Search, Library, Downloads, and Profile remain the only tabs.", category: "Watch", status: "Ready", systemImage: "play.rectangle.fill"),
        HFFinalDemoHighlight(title: "HighFive Rooms are organized", subtitle: "Watch, Creator Studio, Connect, Launch, and Export sit under Profile.", category: "Rooms", status: "Ready", systemImage: "rectangle.3.group.fill"),
        HFFinalDemoHighlight(title: "Product Spine is locked", subtitle: "WATCH, CREATE, CONNECT, LAUNCH, and EXPORT map cleanly.", category: "Spine", status: "Ready", systemImage: "point.3.connected.trianglepath.dotted"),
        HFFinalDemoHighlight(title: "Internal QA is separate", subtitle: "Developer / QA contains validation, not consumer product navigation.", category: "QA", status: "Internal Only", systemImage: "lock.shield.fill")
    ]

    static let safetyLocks: [HFFinalDemoSafetyLock] = [
        HFFinalDemoSafetyLock(title: "No backend connected", subtitle: "All demo content is local/static.", status: "Locked", systemImage: "server.rack"),
        HFFinalDemoSafetyLock(title: "No auth/accounts connected", subtitle: "Profile and room paths are previews only.", status: "Locked", systemImage: "person.crop.circle.badge.xmark"),
        HFFinalDemoSafetyLock(title: "No payments/StoreKit connected", subtitle: "Launch and access copy remains preview-only.", status: "Locked", systemImage: "creditcard.trianglebadge.exclamationmark"),
        HFFinalDemoSafetyLock(title: "No uploads connected", subtitle: "Creator and export rooms do not upload files.", status: "Locked", systemImage: "icloud.slash.fill"),
        HFFinalDemoSafetyLock(title: "No messaging or notifications", subtitle: "Connect Room remains a static community preview.", status: "Locked", systemImage: "bell.slash.fill"),
        HFFinalDemoSafetyLock(title: "No Photos or file handling", subtitle: "The tour does not read images, screenshots, or documents.", status: "Locked", systemImage: "photo.on.rectangle.angled"),
        HFFinalDemoSafetyLock(title: "No share sheet", subtitle: "No ShareLink or activity controller is connected.", status: "Locked", systemImage: "square.and.arrow.up"),
        HFFinalDemoSafetyLock(title: "Protected media untouched", subtitle: "Playback, depth, motion, Layer4, rendering, and Creator systems stay isolated.", status: "Untouched", systemImage: "shield.lefthalf.filled")
    ]

    static let audiencePaths: [HFFinalDemoAudiencePath] = [
        HFFinalDemoAudiencePath(title: "Consumer First Demo", subtitle: "Start with Home, Search, Movie Detail, Library, Downloads, and Profile.", audience: "Viewer", recommendedStart: "Home", status: "Ready", systemImage: "play.rectangle.fill"),
        HFFinalDemoAudiencePath(title: "Rooms Ecosystem Demo", subtitle: "Walk Watch Room, Creator Studio, Connect Room, Launch Room, and Export Room.", audience: "Product", recommendedStart: "Profile -> HighFive Rooms", status: "Ready", systemImage: "rectangle.3.group.fill"),
        HFFinalDemoAudiencePath(title: "Internal Validation Demo", subtitle: "Show Product Spine, Visual Parity, Protected Systems, and Screenshot Review.", audience: "QA", recommendedStart: "Developer / QA Hub", status: "Internal Only", systemImage: "lock.shield.fill")
    ]

    static let viewerPath = ["Home", "Search / Discover", "Movie Detail", "Library / My List", "Downloads", "Profile"]
    static let creatorPath = ["HighFive Rooms", "Creator Studio", "Overview", "Projects", "Creator Profile", "Pitch", "Media Kit", "Launch Prep"]
    static let communityPath = ["HighFive Rooms", "Connect Room", "Overview", "Communities", "Reactions", "Following", "Creator Updates", "Watch Community"]
    static let launchPath = ["HighFive Rooms", "Launch Room", "Overview", "Timeline", "Campaign", "Audience", "Materials", "Release Readiness"]
    static let exportPath = ["HighFive Rooms", "Export Room", "Overview", "Deliverables", "Media Kit", "Festival Package", "Platform Checklist", "Distribution Readiness"]
    static let fullProductPath = ["Home", "Profile", "HighFive Rooms", "Watch Room", "Creator Studio", "Connect Room", "Launch Room", "Export Room", "Developer / QA Hub", "Product Spine", "Screenshot Review"]
}

struct HFDemoAct: Identifiable {
    let id = UUID()
    let title: String
    let purpose: String
    let accessibilityLabel: String
    let steps: [HFFinalDemoStep]
}

struct HFFinalDemoStep: Identifiable {
    let id = UUID()
    let actName: String
    let title: String
    let subtitle: String
    let pillar: String
    let routeLabel: String
    let purpose: String
    let expectedProof: String
    let screenshotTarget: String
    let safetyNote: String
    let status: String
    let systemImage: String
}

struct HFDemoScreenshotTarget: Identifiable {
    let id = UUID()
    let filename: String
    let route: String
    let reviewFocus: String
    let status: String
}

struct HFDemoStoryItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let systemImage: String
}

struct HFDemoProofRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
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
