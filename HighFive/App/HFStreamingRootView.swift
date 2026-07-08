import SwiftUI

enum HFStreamingTab: Hashable {
    case home
    case search
    case library
    case downloads
    case profile
}

private enum HFHighFiveOSMode: String, CaseIterable, Identifiable {
    case universeMap
    case relationshipGraph
    case networkCreator
    case networkAudience
    case cinemaGalaxy
    case commandCenter
    case analytics
    case executiveDashboard
    case controlWall
    case intelligence
    case dashboard
    case activity
    case spotlight
    case missionControl
    case health

    var id: String { rawValue }

    var title: String {
        switch self {
        case .universeMap: return "Universe Map"
        case .relationshipGraph: return "Graph"
        case .networkCreator: return "Creators"
        case .networkAudience: return "Audience"
        case .cinemaGalaxy: return "Galaxy"
        case .commandCenter: return "Command Center"
        case .analytics: return "Analytics"
        case .executiveDashboard: return "Executive Command"
        case .controlWall: return "Control Wall"
        case .intelligence: return "HigherKey Brain"
        case .dashboard: return "Dashboard"
        case .activity: return "Activity"
        case .spotlight: return "Spotlight"
        case .missionControl: return "Mission Control"
        case .health: return "Health"
        }
    }

    var systemImage: String {
        switch self {
        case .universeMap: return "globe.americas.fill"
        case .relationshipGraph: return "point.3.connected.trianglepath.dotted"
        case .networkCreator: return "person.2.wave.2.fill"
        case .networkAudience: return "theatermasks.fill"
        case .cinemaGalaxy: return "sparkles"
        case .commandCenter: return "rectangle.3.group.fill"
        case .analytics: return "chart.xyaxis.line"
        case .executiveDashboard: return "gauge.with.dots.needle.50percent"
        case .controlWall: return "rectangle.grid.3x2.fill"
        case .intelligence: return "brain.head.profile"
        case .dashboard: return "rectangle.grid.2x2.fill"
        case .activity: return "waveform.path.ecg"
        case .spotlight: return "sparkle.magnifyingglass"
        case .missionControl: return "square.grid.3x3.fill"
        case .health: return "checkmark.seal.fill"
        }
    }
}

struct HFStreamingRootView: View {
    @State private var selectedTab: HFStreamingTab = Self.initialTab
    @State private var selectedProfile = HFMockData.userProfiles[0]
    @State private var searchMode: HFSearchHubMode = Self.initialSearchMode
    @State private var hasCompletedLaunchIntro = Self.shouldSkipLaunchIntro
    @State private var showsProtectedDepthPreview = false
    @AppStorage("hf.hasCompletedCinematicOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hf.hasSeenControlPanelWalkthrough") private var hasSeenControlPanelWalkthrough = false
    @AppStorage(HFLegalDocuments.acceptedTermsVersionKey) private var acceptedTermsVersion = ""
    @AppStorage(HFLegalDocuments.acceptedPrivacyVersionKey) private var acceptedPrivacyVersion = ""
    @AppStorage(HFLegalDocuments.acceptedTermsDateKey) private var acceptedTermsDate = ""
    @AppStorage(HFLegalDocuments.hasAcceptedTermsKey) private var hasAcceptedTerms = false
    @StateObject private var streamingStore = HFStreamingStore()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let tabItems: [HFTabItem<HFStreamingTab>] = [
        HFTabItem(value: .home, title: "Home", systemImage: "house.fill"),
        HFTabItem(value: .search, title: "Search", systemImage: "magnifyingglass"),
        HFTabItem(value: .library, title: "Library", systemImage: "bookmark.fill"),
        HFTabItem(value: .downloads, title: "Downloads", systemImage: "arrow.down.circle.fill"),
        HFTabItem(value: .profile, title: "Profile", systemImage: "person.crop.circle.fill")
    ]

    private static var initialTab: HFStreamingTab {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-search") || arguments.contains("--hf-fpp-search-polish") || arguments.contains("--hf-start-search-results") || arguments.contains("--hf-start-search-empty") || arguments.contains("--hf-premium-streaming-discovery") || arguments.contains("--hf-start-discovery-service") || arguments.contains("--hf-discovery-search-service") || arguments.contains("--hf-discovery-recommendations") || arguments.contains("--hf-discovery-related") || arguments.contains("--hf-discovery-creator") || arguments.contains("--hf-discovery-empty") { return .search }
        if arguments.contains("--hf-start-library") || arguments.contains("--hf-fpp-library-polish") || arguments.contains("--hf-start-library-continue") || arguments.contains("--hf-start-library-history") || arguments.contains("--hf-start-library-favorites") || arguments.contains("--hf-start-library-watch-later") || arguments.contains("--hf-start-library-offline") || arguments.contains("--hf-start-library-empty") || arguments.contains("--hf-premium-streaming-library") || arguments.contains("--hf-start-viewer-library-runtime") || arguments.contains("--hf-library-progress-sync") || arguments.contains("--hf-library-recommendations-sync") { return .library }
        if arguments.contains("--hf-start-downloads") || arguments.contains("--hf-start-downloads-offline") || arguments.contains("--hf-start-downloads-empty") || arguments.contains("--hf-premium-streaming-downloads") || arguments.contains("--hf-download-offline-sync") || arguments.contains("--hf-download-storage") { return .downloads }
        if arguments.contains("--hf-start-connect") { return .profile }
        if Self.shouldStartInProfile { return .profile }
        return .home
    }

    private static var initialSearchMode: HFSearchHubMode {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-premium-streaming-discovery") || arguments.contains("--hf-start-discovery-service") || arguments.contains("--hf-discovery-recommendations") ? .discover : .search
    }

    private static var shouldSkipLaunchIntro: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-skip-onboarding") || Self.shouldStartAfterOnboarding
    }

    private static var shouldForceLaunchIntro: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-onboarding")
            || arguments.contains("--hf-start-intro-video")
            || arguments.contains("--hf-onboarding-intro")
            || arguments.contains("--hf-start-training-controls")
            || arguments.contains("--hf-start-timeline-practice")
    }

    private static var shouldResetLaunchIntro: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-reset-onboarding")
    }

    private static var shouldStartAfterOnboarding: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-home")
            || arguments.contains("--hf-fpp-accessibility")
            || arguments.contains("--hf-fpp-performance")
            || arguments.contains("--hf-fpp-home-polish")
            || Self.shouldStartInHighFiveOS
            || arguments.contains("--hf-premium-streaming-home")
            || arguments.contains("--hf-premium-streaming-discovery")
            || arguments.contains("--hf-premium-streaming-library")
            || arguments.contains("--hf-premium-streaming-downloads")
            || arguments.contains("--hf-premium-streaming-detail")
            || arguments.contains("--hf-premium-streaming-collections")
            || arguments.contains("--hf-start-creator-profile")
            || arguments.contains("--hf-start-search")
            || arguments.contains("--hf-fpp-search-polish")
            || arguments.contains("--hf-start-search-results")
            || arguments.contains("--hf-start-search-empty")
            || arguments.contains("--hf-start-discovery-service")
            || arguments.contains("--hf-discovery-search-service")
            || arguments.contains("--hf-discovery-recommendations")
            || arguments.contains("--hf-discovery-related")
            || arguments.contains("--hf-discovery-creator")
            || arguments.contains("--hf-discovery-empty")
            || arguments.contains("--hf-start-library")
            || arguments.contains("--hf-fpp-library-polish")
            || arguments.contains("--hf-start-library-continue")
            || arguments.contains("--hf-start-library-history")
            || arguments.contains("--hf-start-library-favorites")
            || arguments.contains("--hf-start-library-watch-later")
            || arguments.contains("--hf-start-library-offline")
            || arguments.contains("--hf-start-library-empty")
            || arguments.contains("--hf-start-viewer-library-runtime")
            || arguments.contains("--hf-library-progress-sync")
            || arguments.contains("--hf-library-recommendations-sync")
            || arguments.contains("--hf-start-downloads")
            || arguments.contains("--hf-start-downloads-offline")
            || arguments.contains("--hf-start-downloads-empty")
            || arguments.contains("--hf-download-offline-sync")
            || arguments.contains("--hf-download-storage")
            || arguments.contains("--hf-start-movie-detail")
            || arguments.contains("--hf-start-player")
            || arguments.contains("--hf-fpp-player-polish")
            || arguments.contains("--hf-start-player-controls")
            || arguments.contains("--hf-start-player-metadata")
            || arguments.contains("--hf-start-player-watch-together")
            || arguments.contains("--hf-start-player-creator-commentary")
            || arguments.contains("--hf-start-streaming-playback-runtime")
            || arguments.contains("--hf-playback-hls")
            || arguments.contains("--hf-playback-session")
            || arguments.contains("--hf-playback-tracks")
            || arguments.contains("--hf-playback-next-episode")
            || arguments.contains("--hf-playback-error")
            || arguments.contains("--hf-start-protected-depth-preview")
            || arguments.contains("--hf-start-creator-studio")
            || arguments.contains("--hf-fpp-creator-polish")
            || arguments.contains("--hf-fpp-enterprise-polish")
            || arguments.contains("--hf-start-creator-publishing")
            || arguments.contains("--hf-start-publishing")
            || arguments.contains("--hf-publishing-queue")
            || arguments.contains("--hf-publishing-readiness")
            || arguments.contains("--hf-publishing-audit")
            || arguments.contains("--hf-publishing-calendar")
            || Self.shouldStartInCreatorCollaboration
            || Self.shouldStartInSeriesEpisodes
            || Self.shouldStartInRevenueSystem
            || Self.shouldStartInNotificationsActivity
            || Self.shouldStartInPlatformAdministration
            || Self.shouldStartInMarketplaceDistribution
            || Self.shouldStartInRightsLicensingOperations
            || Self.shouldStartInIntegrationReadiness
            || Self.shouldStartInProductionBridge
            || Self.shouldStartInProductionBackend
            || Self.shouldStartInCloudCatalogSync
            || Self.shouldStartInRealIdentity
            || Self.shouldStartInContentBackend
            || Self.shouldStartInDraftWorkspace
            || Self.shouldStartInCreatorProjectRuntime
            || Self.shouldStartInCreatorMediaImportRuntime
            || Self.shouldStartInCreatorLocalPackageRuntime
            || Self.shouldStartInCreatorDraftSync
            || Self.shouldStartInCreatorUploadObjectStorage
            || Self.shouldStartInPublishingReview
            || Self.shouldStartInAnalyticsEventPipeline
            || Self.shouldStartInProductionNotifications
            || Self.shouldStartInMonetizationEntitlements
            || arguments.contains("--hf-start-analytics")
            || arguments.contains("--hf-analytics-viewers")
            || arguments.contains("--hf-analytics-content")
            || arguments.contains("--hf-analytics-discovery")
            || arguments.contains("--hf-analytics-creators")
            || arguments.contains("--hf-analytics-intelligence")
            || arguments.contains("--hf-start-content-management")
            || arguments.contains("--hf-cms-content-types")
            || arguments.contains("--hf-cms-collections")
            || arguments.contains("--hf-cms-relationships")
            || arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
            || arguments.contains("--hf-start-instagram-connect")
            || arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
            || Self.shouldStartInVODPackage
            || Self.shouldStartInLaunchPro
            || arguments.contains("--hf-start-membership")
            || arguments.contains("--hf-start-membership-identity")
            || arguments.contains("--hf-start-membership-premieres")
            || arguments.contains("--hf-start-membership-creator-rooms")
            || arguments.contains("--hf-start-membership-protected-playback")
            || arguments.contains("--hf-start-membership-depth-peek")
            || arguments.contains("--hf-start-connect")
            || arguments.contains("--hf-start-premiere-lobby")
            || arguments.contains("--hf-start-backend-status")
            || Self.shouldStartInProfile
    }

    private static var shouldStartInProfile: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-profile")
            || arguments.contains("--hf-start-profile-rooms")
            || arguments.contains("--hf-start-watch-room")
            || arguments.contains("--hf-start-create-room")
            || arguments.contains("--hf-start-connect")
            || arguments.contains("--hf-start-connect-room")
            || arguments.contains("--hf-start-premiere-lobby")
            || arguments.contains("--hf-start-launch-room")
            || arguments.contains("--hf-start-export-room")
            || arguments.contains("--hf-start-creator-studio")
            || arguments.contains("--hf-start-creator-publishing")
            || arguments.contains("--hf-start-publishing")
            || arguments.contains("--hf-publishing-queue")
            || arguments.contains("--hf-publishing-readiness")
            || arguments.contains("--hf-publishing-audit")
            || arguments.contains("--hf-publishing-calendar")
            || Self.shouldStartInCreatorCollaboration
            || Self.shouldStartInSeriesEpisodes
            || Self.shouldStartInRevenueSystem
            || Self.shouldStartInNotificationsActivity
            || Self.shouldStartInPlatformAdministration
            || Self.shouldStartInMarketplaceDistribution
            || Self.shouldStartInRightsLicensingOperations
            || Self.shouldStartInIntegrationReadiness
            || Self.shouldStartInProductionBridge
            || Self.shouldStartInProductionBackend
            || Self.shouldStartInCloudCatalogSync
            || Self.shouldStartInRealIdentity
            || Self.shouldStartInContentBackend
            || Self.shouldStartInDraftWorkspace
            || Self.shouldStartInCreatorProjectRuntime
            || Self.shouldStartInCreatorMediaImportRuntime
            || Self.shouldStartInCreatorLocalPackageRuntime
            || Self.shouldStartInCreatorDraftSync
            || Self.shouldStartInCreatorUploadObjectStorage
            || Self.shouldStartInPublishingReview
            || Self.shouldStartInAnalyticsEventPipeline
            || Self.shouldStartInProductionNotifications
            || Self.shouldStartInMonetizationEntitlements
            || arguments.contains("--hf-start-analytics")
            || arguments.contains("--hf-analytics-viewers")
            || arguments.contains("--hf-analytics-content")
            || arguments.contains("--hf-analytics-discovery")
            || arguments.contains("--hf-analytics-creators")
            || arguments.contains("--hf-analytics-intelligence")
            || arguments.contains("--hf-start-content-management")
            || arguments.contains("--hf-cms-content-types")
            || arguments.contains("--hf-cms-collections")
            || arguments.contains("--hf-cms-relationships")
            || arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
            || arguments.contains("--hf-start-instagram-connect")
            || arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
            || Self.shouldStartInVODPackage
            || Self.shouldStartInLaunchPro
            || Self.shouldStartInMembership
            || arguments.contains("--hf-start-backend-status")
            || arguments.contains("--hf-start-developer-qa")
            || arguments.contains("--hf-start-demo-tour")
    }

    private static var shouldStartInHighFiveOS: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-cinema-network")
            || arguments.contains("--hf-cinema-network-universe")
            || arguments.contains("--hf-cinema-network-graph")
            || arguments.contains("--hf-cinema-network-creators")
            || arguments.contains("--hf-cinema-network-audience")
            || arguments.contains("--hf-cinema-galaxy")
            || arguments.contains("--hf-spatial-command-center")
            || arguments.contains("--hf-command-center-deck")
            || arguments.contains("--hf-command-center-analytics")
            || arguments.contains("--hf-command-center-executive")
            || arguments.contains("--hf-command-center-control-wall")
            || arguments.contains("--hf-command-center-intelligence")
            || arguments.contains("--hf-os-dashboard")
            || arguments.contains("--hf-os-activity")
            || arguments.contains("--hf-os-spotlight")
            || arguments.contains("--hf-os-mission-control")
            || arguments.contains("--hf-os-health")
    }

    private static var highFiveOSInitialMode: HFHighFiveOSMode {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-cinema-network-graph") { return .relationshipGraph }
        if arguments.contains("--hf-cinema-network-creators") { return .networkCreator }
        if arguments.contains("--hf-cinema-network-audience") { return .networkAudience }
        if arguments.contains("--hf-cinema-galaxy") { return .cinemaGalaxy }
        if arguments.contains("--hf-cinema-network") || arguments.contains("--hf-cinema-network-universe") { return .universeMap }
        if arguments.contains("--hf-command-center-analytics") { return .analytics }
        if arguments.contains("--hf-command-center-executive") { return .executiveDashboard }
        if arguments.contains("--hf-command-center-control-wall") { return .controlWall }
        if arguments.contains("--hf-command-center-intelligence") { return .intelligence }
        if arguments.contains("--hf-spatial-command-center") || arguments.contains("--hf-command-center-deck") { return .commandCenter }
        if arguments.contains("--hf-os-activity") { return .activity }
        if arguments.contains("--hf-os-spotlight") { return .spotlight }
        if arguments.contains("--hf-os-mission-control") { return .missionControl }
        if arguments.contains("--hf-os-health") { return .health }
        return .dashboard
    }

    private static var shouldStartInMovieDetail: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-movie-detail")
            || arguments.contains("--hf-premium-streaming-detail")
    }

    private static var shouldStartInCreatorProfile: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-creator-profile")
    }

    private static var shouldStartInProtectedDepthPreview: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-protected-depth-preview")
    }

    private static var shouldStartInPlayer: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-player")
            || arguments.contains("--hf-fpp-player-polish")
            || arguments.contains("--hf-start-player-controls")
            || arguments.contains("--hf-start-player-metadata")
            || arguments.contains("--hf-start-player-watch-together")
            || arguments.contains("--hf-start-player-creator-commentary")
            || arguments.contains("--hf-start-streaming-playback-runtime")
            || arguments.contains("--hf-playback-hls")
            || arguments.contains("--hf-playback-session")
            || arguments.contains("--hf-playback-tracks")
            || arguments.contains("--hf-playback-next-episode")
            || arguments.contains("--hf-playback-error")
    }

    private static var playerInitialSurface: HFPlayerSurfaceFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-fpp-player-polish") { return .polish }
        if arguments.contains("--hf-start-streaming-playback-runtime") || arguments.contains("--hf-playback-hls") || arguments.contains("--hf-playback-session") || arguments.contains("--hf-playback-tracks") || arguments.contains("--hf-playback-next-episode") || arguments.contains("--hf-playback-error") { return .metadata }
        if arguments.contains("--hf-start-player-controls") { return .controls }
        if arguments.contains("--hf-start-player-metadata") { return .metadata }
        if arguments.contains("--hf-start-player-watch-together") { return .watchTogether }
        if arguments.contains("--hf-start-player-creator-commentary") { return .creatorCommentary }
        return .cinema
    }

    private static var shouldStartInCreatorStudio: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-creator-studio")
            || arguments.contains("--hf-fpp-creator-polish")
            || arguments.contains("--hf-fpp-enterprise-polish")
            || arguments.contains("--hf-start-creator-publishing")
            || arguments.contains("--hf-start-publishing")
            || arguments.contains("--hf-publishing-queue")
            || arguments.contains("--hf-publishing-readiness")
            || arguments.contains("--hf-publishing-audit")
            || arguments.contains("--hf-publishing-calendar")
            || Self.shouldStartInCreatorCollaboration
            || Self.shouldStartInSeriesEpisodes
            || Self.shouldStartInRevenueSystem
            || Self.shouldStartInNotificationsActivity
            || Self.shouldStartInPlatformAdministration
            || Self.shouldStartInMarketplaceDistribution
            || Self.shouldStartInRightsLicensingOperations
            || Self.shouldStartInIntegrationReadiness
            || Self.shouldStartInProductionBridge
            || Self.shouldStartInProductionBackend
            || Self.shouldStartInCloudCatalogSync
            || Self.shouldStartInRealIdentity
            || Self.shouldStartInContentBackend
            || Self.shouldStartInDraftWorkspace
            || Self.shouldStartInCreatorProjectRuntime
            || Self.shouldStartInCreatorMediaImportRuntime
            || Self.shouldStartInCreatorLocalPackageRuntime
            || Self.shouldStartInCreatorDraftSync
            || Self.shouldStartInCreatorUploadObjectStorage
            || Self.shouldStartInPublishingReview
            || Self.shouldStartInAnalyticsEventPipeline
            || Self.shouldStartInProductionNotifications
            || arguments.contains("--hf-start-analytics")
            || arguments.contains("--hf-analytics-viewers")
            || arguments.contains("--hf-analytics-content")
            || arguments.contains("--hf-analytics-discovery")
            || arguments.contains("--hf-analytics-creators")
            || arguments.contains("--hf-analytics-intelligence")
            || arguments.contains("--hf-start-content-management")
            || arguments.contains("--hf-cms-content-types")
            || arguments.contains("--hf-cms-collections")
            || arguments.contains("--hf-cms-relationships")
            || arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
            || arguments.contains("--hf-start-instagram-connect")
            || arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
            || Self.shouldStartInLaunchPro
    }

    private static var shouldStartInConnect: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-connect")
            || arguments.contains("--hf-start-connect-room")
            || arguments.contains("--hf-start-connect-watch-room")
            || arguments.contains("--hf-start-premiere-lobby")
            || arguments.contains("--hf-connect-pro-lobby")
            || arguments.contains("--hf-connect-pro-audience")
            || arguments.contains("--hf-connect-pro-commentary")
            || arguments.contains("--hf-connect-pro-roster")
            || arguments.contains("--hf-connect-pro-seat-map")
            || arguments.contains("--hf-connect-pro-afterparty")
    }

    private static var shouldStartInBackendStatus: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-backend-status")
    }

    private static var shouldStartInProductionBackend: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-production-backend")
            || arguments.contains("--hf-production-backend-health")
            || arguments.contains("--hf-production-backend-catalog")
            || arguments.contains("--hf-production-backend-fallback")
    }

    private static var shouldStartInCloudCatalogSync: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-cloud-catalog-sync")
            || arguments.contains("--hf-cloud-catalog-cache")
            || arguments.contains("--hf-cloud-catalog-delta")
            || arguments.contains("--hf-cloud-catalog-diagnostics")
    }

    private static var shouldStartInRealIdentity: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-real-identity")
            || arguments.contains("--hf-identity-signin")
            || arguments.contains("--hf-identity-session")
            || arguments.contains("--hf-identity-roles")
            || arguments.contains("--hf-identity-delete")
    }

    private static var connectInitialMode: HFConnectSpatialMode {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-connect-room") { return .watchRoom }
        if arguments.contains("--hf-start-connect-watch-room") { return .watchRoom }
        if arguments.contains("--hf-start-premiere-lobby") { return .premiereLobby }
        if arguments.contains("--hf-connect-pro-lobby") { return .premiereLobby }
        return .hub
    }

    private static var creatorStudioInitialFocus: HFCreatorStudioFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if Self.shouldStartInSocialMediaKit { return .socialMediaKit }
        if arguments.contains("--hf-start-instagram-connect") { return .instagramConnect }
        if Self.shouldStartInVODPackage { return .vodPackage }
        return .dashboard
    }

    private static var shouldStartInCreatorCollaboration: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-collaboration")
            || arguments.contains("--hf-collaboration-team")
            || arguments.contains("--hf-collaboration-tasks")
            || arguments.contains("--hf-collaboration-notes")
            || arguments.contains("--hf-collaboration-activity")
            || arguments.contains("--hf-collaboration-timeline")
    }

    private static var shouldStartInSeriesEpisodes: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-series")
            || arguments.contains("--hf-series-detail")
            || arguments.contains("--hf-series-episodes")
            || arguments.contains("--hf-series-next-episode")
            || arguments.contains("--hf-series-analytics")
    }

    private static var shouldStartInRevenueSystem: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-revenue")
            || arguments.contains("--hf-revenue-dashboard")
            || arguments.contains("--hf-revenue-titles")
            || arguments.contains("--hf-revenue-analytics")
            || arguments.contains("--hf-revenue-payouts")
    }

    private static var shouldStartInNotificationsActivity: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-notifications")
            || arguments.contains("--hf-notifications-center")
            || arguments.contains("--hf-activity-center")
            || arguments.contains("--hf-notifications-publishing")
            || arguments.contains("--hf-notifications-discovery")
            || arguments.contains("--hf-notifications-series")
            || arguments.contains("--hf-notifications-collaboration")
            || arguments.contains("--hf-notifications-revenue")
    }

    private static var shouldStartInPlatformAdministration: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-admin")
            || arguments.contains("--hf-fpp-enterprise-polish")
            || arguments.contains("--hf-admin-review")
            || arguments.contains("--hf-admin-creators")
            || arguments.contains("--hf-admin-health")
            || arguments.contains("--hf-admin-moderation")
            || arguments.contains("--hf-admin-operations")
            || arguments.contains("--hf-admin-audit")
            || arguments.contains("--hf-start-platform-operations")
            || arguments.contains("--hf-operations-rights")
            || arguments.contains("--hf-operations-moderation")
            || arguments.contains("--hf-operations-audit")
            || arguments.contains("--hf-operations-health")
    }

    private static var shouldStartInMarketplaceDistribution: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-marketplace")
            || arguments.contains("--hf-marketplace-catalog")
            || arguments.contains("--hf-marketplace-targets")
            || arguments.contains("--hf-marketplace-rights")
            || arguments.contains("--hf-marketplace-packages")
            || arguments.contains("--hf-marketplace-licensing")
            || arguments.contains("--hf-marketplace-readiness")
    }

    private static var shouldStartInRightsLicensingOperations: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-rights")
            || arguments.contains("--hf-rights-ledger")
            || arguments.contains("--hf-rights-windows")
            || arguments.contains("--hf-rights-territories")
            || arguments.contains("--hf-rights-clearance")
            || arguments.contains("--hf-licensing-packages")
            || arguments.contains("--hf-licensing-readiness")
            || arguments.contains("--hf-deal-preparation")
    }

    private static var shouldStartInIntegrationReadiness: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-integration")
            || arguments.contains("--hf-integration-services")
            || arguments.contains("--hf-integration-data-sources")
            || arguments.contains("--hf-integration-sync")
            || arguments.contains("--hf-integration-api")
            || arguments.contains("--hf-integration-environments")
            || arguments.contains("--hf-integration-audit")
    }

    private static var shouldStartInProductionBridge: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-production-bridge")
            || arguments.contains("--hf-production-connections")
            || arguments.contains("--hf-production-flags")
            || arguments.contains("--hf-production-service-mapping")
            || arguments.contains("--hf-production-environments")
            || arguments.contains("--hf-production-readiness")
            || arguments.contains("--hf-production-dependencies")
    }

    private static var shouldStartInContentBackend: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-content-backend")
            || arguments.contains("--hf-content-repositories")
            || arguments.contains("--hf-content-fetch")
            || arguments.contains("--hf-content-persistence")
            || arguments.contains("--hf-content-relationships")
    }

    private static var shouldStartInDraftWorkspace: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-draft-workspace")
            || arguments.contains("--hf-draft-editor")
            || arguments.contains("--hf-draft-validation")
            || arguments.contains("--hf-draft-compare")
            || arguments.contains("--hf-draft-history")
    }

    private static var shouldStartInCreatorProjectRuntime: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-project-runtime")
            || arguments.contains("--hf-project-manifest")
            || arguments.contains("--hf-project-assets")
            || arguments.contains("--hf-project-validation")
            || arguments.contains("--hf-project-release-package")
            || arguments.contains("--hf-project-timeline")
    }

    private static var shouldStartInCreatorMediaImportRuntime: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-media-import")
            || arguments.contains("--hf-media-import-queue")
            || arguments.contains("--hf-media-import-validation")
            || arguments.contains("--hf-media-registration")
            || arguments.contains("--hf-media-manifest-updates")
            || arguments.contains("--hf-media-project-linking")
            || arguments.contains("--hf-media-import-preflight")
            || arguments.contains("--hf-media-inspection-preflight")
            || arguments.contains("--hf-media-inspection-report")
            || arguments.contains("--hf-media-quarantine")
    }

    private static var shouldStartInCreatorLocalPackageRuntime: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-local-package")
            || arguments.contains("--hf-package-create")
            || arguments.contains("--hf-package-history")
            || arguments.contains("--hf-package-validation")
            || arguments.contains("--hf-package-export")
    }

    private static var shouldStartInCreatorDraftSync: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-creator-draft-sync")
            || arguments.contains("--hf-draft-sync-queue")
            || arguments.contains("--hf-draft-sync-conflict")
            || arguments.contains("--hf-draft-sync-revisions")
    }

    private static var shouldStartInCreatorUploadObjectStorage: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-creator-upload")
            || arguments.contains("--hf-upload-selection")
            || arguments.contains("--hf-upload-validation")
            || arguments.contains("--hf-upload-manifest")
            || arguments.contains("--hf-upload-queue")
            || arguments.contains("--hf-upload-preflight")
            || arguments.contains("--hf-start-creator-upload-object-storage")
            || arguments.contains("--hf-upload-object-session")
            || arguments.contains("--hf-upload-object-assets")
            || arguments.contains("--hf-upload-object-duplicates")
            || arguments.contains("--hf-upload-object-cancel")
            || arguments.contains("--hf-upload-object-matrix")
            || arguments.contains("--hf-upload-object-retry")
            || arguments.contains("--hf-start-media-processing")
            || arguments.contains("--hf-processing-jobs")
            || arguments.contains("--hf-processing-hls")
            || arguments.contains("--hf-processing-status")
            || arguments.contains("--hf-processing-logs")
            || arguments.contains("--hf-processing-failure")
    }

    private static var shouldStartInPublishingReview: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-publishing-review")
            || arguments.contains("--hf-review-queue")
            || arguments.contains("--hf-review-publish")
            || arguments.contains("--hf-review-audit")
    }

    private static var shouldStartInAnalyticsEventPipeline: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-analytics-events")
            || arguments.contains("--hf-analytics-events-ingest")
            || arguments.contains("--hf-analytics-events-dashboard")
            || arguments.contains("--hf-analytics-events-privacy")
    }

    private static var shouldStartInProductionNotifications: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-production-notifications")
            || arguments.contains("--hf-notification-registration")
            || arguments.contains("--hf-notification-inbox")
            || arguments.contains("--hf-notification-delivery-audit")
            || arguments.contains("--hf-notification-deeplink")
    }

    private static var shouldStartInMonetizationEntitlements: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-monetization")
            || arguments.contains("--hf-monetization-products")
            || arguments.contains("--hf-monetization-purchase")
            || arguments.contains("--hf-monetization-restore")
            || arguments.contains("--hf-monetization-entitlements")
    }

    private static var shouldStartInSocialMediaKit: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
    }

    private static var socialCampaignInitialFocus: HFSocialCampaignFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-social-media-kit-reel") { return .reel }
        if arguments.contains("--hf-start-social-media-kit-caption") { return .caption }
        if arguments.contains("--hf-start-social-media-kit-story") { return .story }
        if arguments.contains("--hf-start-social-media-kit-platforms") { return .platforms }
        return .poster
    }

    private static var shouldStartInVODPackage: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
            || Self.shouldStartInLaunchPro
    }

    private static var shouldStartInLaunchPro: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-launch-pro-dashboard")
            || arguments.contains("--hf-launch-pro-pipeline")
            || arguments.contains("--hf-launch-pro-platforms")
            || arguments.contains("--hf-launch-pro-campaign")
            || arguments.contains("--hf-launch-pro-assets")
            || arguments.contains("--hf-launch-pro-final-gate")
    }

    private static var vodReleaseInitialFocus: HFVODReleaseFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-vod-package-poster") { return .poster }
        if arguments.contains("--hf-start-vod-package-synopsis") { return .synopsis }
        if arguments.contains("--hf-start-vod-package-access") { return .access }
        if arguments.contains("--hf-start-vod-package-release") { return .release }
        return .trailer
    }

    private static var shouldStartInMembership: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-membership")
            || arguments.contains("--hf-start-membership-identity")
            || arguments.contains("--hf-start-membership-premieres")
            || arguments.contains("--hf-start-membership-creator-rooms")
            || arguments.contains("--hf-start-membership-protected-playback")
            || arguments.contains("--hf-start-membership-depth-peek")
            || arguments.contains("--hf-start-membership-stats")
            || arguments.contains("--hf-start-membership-collection-vault")
            || arguments.contains("--hf-start-membership-achievements")
    }

    private static var membershipInitialFacet: HFMembershipPassFacet {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-membership-premieres") { return .premieres }
        if arguments.contains("--hf-start-membership-creator-rooms") { return .creatorRooms }
        if arguments.contains("--hf-start-membership-protected-playback") { return .protectedPlayback }
        if arguments.contains("--hf-start-membership-depth-peek") { return .depthPeek }
        return .identity
    }

    private static var membershipInitialShowcase: HFMembershipShowcaseFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-membership-stats") { return .stats }
        if arguments.contains("--hf-start-membership-collection-vault") { return .collectionVault }
        if arguments.contains("--hf-start-membership-achievements") { return .achievements }
        return .pass
    }

    private static var qaMovieDetailMovie: Movie {
        let arguments = CommandLine.arguments
        if arguments.contains("--hf-start-player-paranormall") {
            return HFMockData.movie("paranormall-s1") ?? HFMockData.movies[0]
        }
        if arguments.contains("--hf-start-player-friendly") {
            return HFMockData.movie("friendly") ?? HFMockData.movies[0]
        }
        return HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        Group {
            if shouldShowStreamingShell {
                if hasAcceptedCurrentLegal {
                    if Self.shouldStartInHighFiveOS {
                        qaHighFiveOSView
                    } else if Self.shouldStartInProtectedDepthPreview {
                        HighFiveProtectedSpatialPeekBridge()
                    } else if Self.shouldStartInPlayer {
                        qaPlayerView
                    } else if Self.shouldStartInBackendStatus {
                        qaBackendStatusView
                    } else if Self.shouldStartInCreatorStudio {
                        qaCreatorStudioView
                    } else if Self.shouldStartInConnect {
                        qaConnectView
                    } else if Self.shouldStartInCreatorProfile {
                        qaCreatorProfileView
                    } else if Self.shouldStartInMovieDetail {
                        qaMovieDetailView
                    } else {
                        streamingShell
                    }
                } else {
                    HFTermsAgreementView {
                        acceptLegalAndEnter()
                    }
                }
            } else {
                HighFiveIntroFlowView(
                    initialStep: HighFiveIntroStep.initialFromLaunchArguments,
                    onFinish: {
                    completeLaunchIntro()
                    }
                )
            }
        }
        .tint(HFColors.gold)
        .preferredColorScheme(.dark)
        .background(HFColors.background.ignoresSafeArea())
        .environmentObject(streamingStore)
        .hfDynamicTypeGuard()
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .onAppear {
            if Self.shouldResetLaunchIntro {
                hasCompletedOnboarding = false
                hasCompletedLaunchIntro = Self.shouldSkipLaunchIntro && !Self.shouldForceLaunchIntro
            } else if Self.shouldSkipLaunchIntro && !Self.shouldForceLaunchIntro {
                hasCompletedLaunchIntro = true
                hasCompletedOnboarding = true
            }
        }
        .task {
            guard Self.shouldStartInBackendStatus || ProcessInfo.processInfo.arguments.contains("--hf-refresh-backend-runtime") else {
                return
            }
            try? await Task.sleep(nanoseconds: 750_000_000)
            await streamingStore.refreshBackendRuntimeStatus()
        }
    }

    private var shouldShowStreamingShell: Bool {
        hasCompletedLaunchIntro && !Self.shouldForceLaunchIntro
    }

    private var hasAcceptedCurrentLegal: Bool {
        hasAcceptedTerms &&
            acceptedTermsVersion == HFLegalDocuments.currentTermsVersion &&
            acceptedPrivacyVersion == HFLegalDocuments.currentPrivacyVersion
    }

    private func completeLaunchIntro() {
        withAnimation(.easeInOut(duration: 0.35)) {
            hasCompletedLaunchIntro = true
            hasCompletedOnboarding = true
        }
        if !hasSeenControlPanelWalkthrough {
            hasSeenControlPanelWalkthrough = true
        }
    }

    private func acceptLegalAndEnter() {
        HFLegalDocuments.recordCurrentAcceptance()
        hasAcceptedTerms = true
        acceptedTermsVersion = HFLegalDocuments.currentTermsVersion
        acceptedPrivacyVersion = HFLegalDocuments.currentPrivacyVersion
        acceptedTermsDate = UserDefaults.standard.string(forKey: HFLegalDocuments.acceptedTermsDateKey) ?? acceptedTermsDate
    }

    private func selectTab(_ tab: HFStreamingTab) {
        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.tabSelectionAnimation) {
            selectedTab = tab
        }
    }

    private var qaHighFiveOSView: some View {
        HFHighFiveOSView(initialMode: Self.highFiveOSInitialMode, selectedProfile: selectedProfile)
            .environmentObject(streamingStore)
    }

    private var qaMovieDetailView: some View {
        NavigationStack {
            MovieDetailView(movie: Self.qaMovieDetailMovie)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialNavigationSpine()
    }

    private var qaCreatorProfileView: some View {
        NavigationStack {
            CreatorProfileView(creator: HFMockData.creator(for: Self.qaMovieDetailMovie))
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(movie: movie)
                }
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialNavigationSpine()
    }

    private var qaPlayerView: some View {
        NavigationStack {
            HFPlayerServiceSheet(movie: Self.qaMovieDetailMovie, initialSurface: Self.playerInitialSurface)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialNavigationSpine()
    }

    private var qaCreatorStudioView: some View {
        NavigationStack {
            CreatorStudioView(
                initialFocus: Self.creatorStudioInitialFocus,
                initialSocialFocus: Self.socialCampaignInitialFocus,
                initialVODFocus: Self.vodReleaseInitialFocus
            )
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialNavigationSpine()
    }

    private var qaConnectView: some View {
        NavigationStack {
            ConnectHubView(initialMode: Self.connectInitialMode)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialNavigationSpine()
    }

    private var qaBackendStatusView: some View {
        NavigationStack {
            HFBackendStatusView()
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialNavigationSpine()
    }

    private var streamingShell: some View {
        NavigationStack {
            ZStack {
                HFColors.screenBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(
                                selectedProfile: selectedProfile,
                                onSearch: {
                                    searchMode = .search
                                    selectTab(.search)
                                },
                                onDiscover: {
                                    searchMode = .discover
                                    selectTab(.search)
                                },
                                onProfile: {
                                    selectTab(.profile)
                                },
                                onMyList: {
                                    selectTab(.library)
                                },
                                onDownloads: {
                                    selectTab(.downloads)
                                }
                            )
                        case .search:
                            SearchView(mode: $searchMode)
                        case .library:
                            MyListView(onBrowseDiscover: {
                                searchMode = .discover
                                selectTab(.search)
                            })
                        case .downloads:
                            DownloadsView(onFindMore: {
                                searchMode = .discover
                                selectTab(.search)
                            })
                        case .profile:
                            ProfileView(
                                selectedProfile: $selectedProfile,
                                initialMembershipFacet: Self.membershipInitialFacet,
                                initialMembershipShowcase: Self.membershipInitialShowcase,
                                startInMembership: Self.shouldStartInMembership,
                                onOpenMyList: {
                                    selectTab(.library)
                                }
                            )
                        }
                    }
                    .id(selectedTab)
                    .transition(HFSpatialRouteTransition.tabTransition(reduceMotion: reduceMotion))
                    .hfSpatialNavigationSpine()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    HFTabBar(items: tabItems, selection: $selectedTab)
                        .accessibilityIdentifier("hf.tabs.locked")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
            .navigationDestination(for: Creator.self) { creator in
                CreatorProfileView(creator: creator)
            }
        }
    }
}

private struct HFHighFiveOSView: View {
    let initialMode: HFHighFiveOSMode
    let selectedProfile: UserProfile

    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedMode: HFHighFiveOSMode
    @State private var selectedRoom: HFOSRoom = .watchRoom
    @State private var isAwake = false

    init(initialMode: HFHighFiveOSMode, selectedProfile: UserProfile) {
        self.initialMode = initialMode
        self.selectedProfile = selectedProfile
        _selectedMode = State(initialValue: initialMode)
    }

    private var featuredMovie: Movie {
        streamingStore.featuredMovie
    }

    private var savedCount: Int {
        streamingStore.savedMovies.count
    }

    private var commandMetrics: [HFCommandMetric] {
        [
            HFCommandMetric(title: "Viewer Activity", value: featuredMovie.title, detail: "Continue path staged", accent: HFColors.gold, systemImage: "play.rectangle.fill"),
            HFCommandMetric(title: "Creator Activity", value: "Studio Pro", detail: "Draft surfaces aligned", accent: HFColors.violet, systemImage: "wand.and.stars"),
            HFCommandMetric(title: "Release Activity", value: "Final Review", detail: "Launch remains visual", accent: HFColors.gold, systemImage: "sparkles.tv.fill"),
            HFCommandMetric(title: "Room Status", value: "Local", detail: "Connect preview ready", accent: HFColors.cyanGlow, systemImage: "person.3.sequence.fill"),
            HFCommandMetric(title: "Platform Health", value: "Ready", detail: "Local only", accent: HFColors.cyanGlow, systemImage: "checkmark.seal.fill"),
            HFCommandMetric(title: "Growth", value: "\(savedCount) saved", detail: "Local signals only", accent: HFColors.gold, systemImage: "chart.line.uptrend.xyaxis")
        ]
    }

    private var universeNodes: [HFCinemaNetworkNode] {
        [
            HFCinemaNetworkNode(title: "Movies", detail: featuredMovie.title, accent: HFColors.gold, systemImage: "film.stack.fill"),
            HFCinemaNetworkNode(title: "Creators", detail: "Studio Pro", accent: HFColors.violet, systemImage: "person.crop.rectangle.stack.fill"),
            HFCinemaNetworkNode(title: "Rooms", detail: "Watch Room", accent: HFColors.cyanGlow, systemImage: "person.3.sequence.fill"),
            HFCinemaNetworkNode(title: "Collections", detail: "\(savedCount) saved", accent: HFColors.gold, systemImage: "square.stack.3d.up.fill"),
            HFCinemaNetworkNode(title: "Campaigns", detail: "Social kit", accent: HFColors.violet, systemImage: "megaphone.fill"),
            HFCinemaNetworkNode(title: "Launches", detail: "Final review", accent: HFColors.gold, systemImage: "sparkles.tv.fill")
        ]
    }

    private var creatorNetworkNodes: [HFCinemaNetworkNode] {
        [
            HFCinemaNetworkNode(title: "Projects", detail: "Release workspace", accent: HFColors.gold, systemImage: "folder.fill"),
            HFCinemaNetworkNode(title: "Collaborators", detail: "Preview roster", accent: HFColors.cyanGlow, systemImage: "person.2.fill"),
            HFCinemaNetworkNode(title: "Commentary", detail: "Creator surface", accent: HFColors.violet, systemImage: "quote.bubble.fill"),
            HFCinemaNetworkNode(title: "Releases", detail: "Launch package", accent: HFColors.gold, systemImage: "paperplane.fill")
        ]
    }

    private var audienceNetworkNodes: [HFCinemaNetworkNode] {
        [
            HFCinemaNetworkNode(title: "Viewing Paths", detail: "Continue journey", accent: HFColors.gold, systemImage: "point.topleft.down.curvedto.point.bottomright.up"),
            HFCinemaNetworkNode(title: "Collections", detail: "Saved worlds", accent: HFColors.gold, systemImage: "square.stack.3d.up.fill"),
            HFCinemaNetworkNode(title: "Premieres", detail: "Lobby preview", accent: HFColors.cyanGlow, systemImage: "theatermasks.fill"),
            HFCinemaNetworkNode(title: "Watch Rooms", detail: "Local room map", accent: HFColors.cyanGlow, systemImage: "person.3.fill")
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                osHeader
                osDock
                modeSwitcher
                activeModeSurface
                osFooter
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.xxl)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .hfSpatialSceneEntrance(isActive: isAwake, reduceMotion: reduceMotion)
        .onAppear {
            guard !isAwake else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isAwake = true
            }
        }
        .accessibilityIdentifier("hf.os.commandLayer")
    }

    private var osHeader: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .center, spacing: HFSpacing.md) {
                Image(systemName: "sparkles.tv.fill")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 64, height: 64)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("HIGHFIVE OS")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("Cinema Network for Watch, Create, Connect, Launch, Pass, Analytics, and local universe signals.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: HFSpacing.xs) {
                HFSpatialRouteBadge(title: "Local Preview", accent: HFColors.cyanGlow)
                HFSpatialRouteBadge(title: selectedProfile.name, accent: HFColors.gold)
                HFSpatialRouteBadge(title: selectedMode.title, accent: HFColors.violet)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HighFive OS, \(selectedMode.title), local command layer")
    }

    private var osDock: some View {
        HFOpticalGlassSurface(cornerRadius: 34, strokeColor: HFColors.gold.opacity(0.38)) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(HFOSRoom.allCases) { room in
                    Button {
                        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
                            selectedRoom = room
                        }
                    } label: {
                        VStack(spacing: HFSpacing.xs) {
                            Image(systemName: room.systemImage)
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(selectedRoom == room ? .black : room.accent)
                                .frame(width: 46, height: 46)
                                .background(selectedRoom == room ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(room.accent.opacity(0.16)))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            Text(room.shortTitle)
                                .font(HFTypography.micro)
                                .foregroundStyle(selectedRoom == room ? HFColors.gold : HFColors.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.68)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(room.title) room")
                    .accessibilityValue(selectedRoom == room ? "Selected" : "Available")
                }
            }
            .padding(HFSpacing.sm)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.os.dock")
    }

    private var modeSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(HFHighFiveOSMode.allCases) { mode in
                    Button {
                        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.standardAnimation) {
                            selectedMode = mode
                        }
                    } label: {
                        Label(mode.title, systemImage: mode.systemImage)
                            .font(HFTypography.caption)
                            .foregroundStyle(selectedMode == mode ? .black : HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, HFSpacing.sm)
                            .frame(height: 42)
                            .background(selectedMode == mode ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                            .overlay(Capsule().stroke((selectedMode == mode ? HFColors.gold : HFColors.cyanGlow).opacity(0.28), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(selectedMode == mode ? "Selected" : "Available")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.os.quickActions")
    }

    @ViewBuilder
    private var activeModeSurface: some View {
        switch selectedMode {
        case .universeMap:
            universeMapSurface
        case .relationshipGraph:
            relationshipGraphSurface
        case .networkCreator:
            creatorNetworkSurface
        case .networkAudience:
            audienceNetworkSurface
        case .cinemaGalaxy:
            cinemaGalaxySurface
        case .commandCenter:
            commandCenterSurface
        case .analytics:
            analyticsSurface
        case .executiveDashboard:
            executiveDashboardSurface
        case .controlWall:
            controlWallSurface
        case .intelligence:
            intelligenceSurface
        case .dashboard:
            dashboardSurface
        case .activity:
            activitySurface
        case .spotlight:
            spotlightSurface
        case .missionControl:
            missionControlSurface
        case .health:
            healthSurface
        }
    }

    private var universeMapSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: 38, strokeColor: HFColors.gold.opacity(0.54)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(HFColors.gold.opacity(0.18))
                                .frame(width: 78, height: 78)
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 34, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Universe Map")
                                .font(.system(size: 36, weight: .black))
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.70)
                            Text("A cinematic map of movies, creators, rooms, collections, campaigns, and launches.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    cinemaOrbit(nodes: universeNodes)

                    HFSpatialActionCluster {
                        HFEnergyAction(title: "Open Relationship Graph", systemImage: "point.3.connected.trianglepath.dotted", style: .gold) {
                            selectedMode = .relationshipGraph
                        }
                        HStack(spacing: HFSpacing.sm) {
                            HFEnergyAction(title: "Creator Network", systemImage: "person.2.wave.2.fill", style: .glass) {
                                selectedMode = .networkCreator
                            }
                            HFEnergyAction(title: "Cinema Galaxy", systemImage: "sparkles", style: .glass) {
                                selectedMode = .cinemaGalaxy
                            }
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            relationshipSummaryRail
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.cinema.network.universeMap")
    }

    private var relationshipGraphSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.50)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Relationship Graph", detail: "Local visual connections across movies, creators, rooms, collections, campaigns, and launches.")
                    relationshipPath("Movies", "Creators", "Title worlds feed creator projects", HFColors.gold, HFColors.violet)
                    relationshipPath("Creators", "Rooms", "Commentary becomes room presence", HFColors.violet, HFColors.cyanGlow)
                    relationshipPath("Rooms", "Campaigns", "Audience energy informs campaign previews", HFColors.cyanGlow, HFColors.violet)
                    relationshipPath("Campaigns", "Launches", "Creative assets flow into release review", HFColors.violet, HFColors.gold)
                    relationshipPath("Launches", "Collections", "Release worlds return to the library vault", HFColors.gold, HFColors.gold)
                }
                .padding(HFSpacing.lg)
            }
            cinemaNetworkGrid(universeNodes)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.cinema.network.relationshipGraph")
    }

    private var creatorNetworkSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.52)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Creator Network", detail: "Projects, collaborators, commentary, and releases shown as a local creator constellation.")
                    cinemaOrbit(nodes: creatorNetworkNodes)
                }
                .padding(HFSpacing.lg)
            }
            creatorConstellationBoard
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.cinema.network.creatorNetwork")
    }

    private var audienceNetworkSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.52)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Audience Network", detail: "Viewing paths, collections, premieres, and watch rooms as a cinematic audience map.")
                    cinemaOrbit(nodes: audienceNetworkNodes)
                }
                .padding(HFSpacing.lg)
            }
            cinemaNetworkGrid(audienceNetworkNodes)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.cinema.network.audienceNetwork")
    }

    private var cinemaGalaxySurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: 38, strokeColor: HFColors.gold.opacity(0.50)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Cinema Galaxy", detail: "A sci-fi command view of HighFive's local cinematic universe.")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        galaxyCluster("Watch", "Films", HFColors.gold)
                        galaxyCluster("Create", "Projects", HFColors.violet)
                        galaxyCluster("Connect", "Rooms", HFColors.cyanGlow)
                        galaxyCluster("Launch", "Releases", HFColors.gold)
                        galaxyCluster("Pass", "Members", HFColors.gold)
                        galaxyCluster("Analytics", "Signals", HFColors.cyanGlow)
                    }
                }
                .padding(HFSpacing.lg)
            }
            relationshipSummaryRail
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.cinema.network.cinemaGalaxy")
    }

    private var relationshipSummaryRail: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                osSectionHeader(title: "Network Signals", detail: "Read-only local links between story worlds, creator work, rooms, and releases.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Movies", value: featuredMovie.title, detail: "Current story world", accent: HFColors.gold, systemImage: "film.fill"))
                    commandMetricCard(HFCommandMetric(title: "Creators", value: "Studio Pro", detail: "Project constellation", accent: HFColors.violet, systemImage: "person.crop.rectangle.stack.fill"))
                    commandMetricCard(HFCommandMetric(title: "Rooms", value: "Watch Room", detail: "Audience map", accent: HFColors.cyanGlow, systemImage: "person.3.fill"))
                    commandMetricCard(HFCommandMetric(title: "Launches", value: "Review", detail: "Release path", accent: HFColors.gold, systemImage: "paperplane.fill"))
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.cinema.network.signals")
    }

    private var commandCenterSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            globalCommandDeck
            livePreviewPanels
            roomStatusGrid
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.command.center.globalDeck")
    }

    private var globalCommandDeck: some View {
        HFOpticalGlassSurface(cornerRadius: 36, strokeColor: HFColors.gold.opacity(0.52)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.3.group.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 66, height: 66)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Global Command Deck")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        Text("Executive cockpit for Watch, Create, Connect, Launch, Pass, and Analytics.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandPillar("Watch", "Streaming", "play.tv.fill", HFColors.gold)
                    commandPillar("Create", "Studio", "wand.and.stars", HFColors.violet)
                    commandPillar("Connect", "Rooms", "person.3.sequence.fill", HFColors.cyanGlow)
                    commandPillar("Launch", "Release", "sparkles.tv.fill", HFColors.gold)
                    commandPillar("Pass", "Member", "person.text.rectangle.fill", HFColors.gold)
                    commandPillar("Analytics", "Signals", "chart.xyaxis.line", HFColors.cyanGlow)
                }

                HFSpatialActionCluster {
                    HFEnergyAction(title: "Open Executive Dashboard", systemImage: "gauge.with.dots.needle.50percent", style: .gold) {
                        selectedMode = .executiveDashboard
                    }
                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: "Control Wall", systemImage: "rectangle.grid.3x2.fill", style: .glass) {
                            selectedMode = .controlWall
                        }
                        HFEnergyAction(title: "HigherKey Brain", systemImage: "brain.head.profile", style: .glass) {
                            selectedMode = .intelligence
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
    }

    private var analyticsSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.48)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Analytics Command Center", detail: "Growth, creator activity, viewer activity, and release activity shown as local visual signals.")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        ForEach(commandMetrics) { metric in
                            commandMetricCard(metric)
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            activitySignalsPanel
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.command.center.analytics")
    }

    private var executiveDashboardSurface: some View {
        let snapshot = HFLocalProjectStore.executiveCommandCenterSnapshot
        let summary = snapshot.executiveSummary
        let systemMap = HFLocalProjectStore.higherKeyOSCohesionSnapshot

        return VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: 36, strokeColor: HFColors.gold.opacity(0.50)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Executive Command", detail: "Read-only operating view for Brain, Mission, Orchestration, Workflow, Studio, Creator, and Packaging signals.")
                    insightCard("Executive Operating Snapshot", snapshot.summary, "gauge.with.dots.needle.50percent", HFColors.gold)

                    HFSpatialActionCluster {
                        HFEnergyAction(title: "Open HigherKey Brain", systemImage: "brain.head.profile", style: .gold) {
                            selectedMode = .intelligence
                        }
                        HStack(spacing: HFSpacing.sm) {
                            HFEnergyAction(title: "Open Packaging Studio", systemImage: "shippingbox.fill", style: .glass) {
                                selectedRoom = .createRoom
                                selectedMode = .missionControl
                            }
                            HFEnergyAction(title: "Open Creator OS", systemImage: "command", style: .glass) {
                                selectedRoom = .createRoom
                                selectedMode = .missionControl
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        ForEach(snapshot.healthMetrics) { metric in
                            commandMetricCard(HFCommandMetric(title: metric.title, value: "\(metric.score)%", detail: metric.detail, accent: brainAccent(for: metric.severity), systemImage: metric.systemImage))
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }

            systemMapSection(systemMap, title: "System Map", detail: "Read-only route map for moving between Executive Command, HigherKey Brain, Studio Intelligence, Mission Planner, Execution Tracking, Workflow Automation, Creator OS, and Packaging Studio.")

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Executive Summary", detail: "Local project, mission, risk, release, and review counts.")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        commandMetricCard(HFCommandMetric(title: "Projects", value: "\(summary.projectCount)", detail: "Local project state", accent: HFColors.cyanGlow, systemImage: "square.stack.3d.up.fill"))
                        commandMetricCard(HFCommandMetric(title: "Milestones", value: "\(summary.completedMilestones)", detail: "Completed locally", accent: HFColors.gold, systemImage: "flag.checkered"))
                        commandMetricCard(HFCommandMetric(title: "Blocked Projects", value: "\(summary.blockedProjects)", detail: summary.blockedProjects > 0 ? "Needs local review" : "No blocked projects", accent: summary.blockedProjects > 0 ? HFColors.redAccent : HFColors.cyanGlow, systemImage: "exclamationmark.triangle.fill"))
                        commandMetricCard(HFCommandMetric(title: "Critical Risks", value: "\(summary.criticalRisks)", detail: summary.criticalRisks > 0 ? "Needs executive review" : "No critical risks", accent: summary.criticalRisks > 0 ? HFColors.redAccent : HFColors.cyanGlow, systemImage: "lock.trianglebadge.exclamationmark.fill"))
                        commandMetricCard(HFCommandMetric(title: "Review", value: "\(summary.projectsReadyForReview)", detail: "Ready for review", accent: HFColors.violet, systemImage: "checklist.checked"))
                        commandMetricCard(HFCommandMetric(title: "Release", value: "\(summary.projectsReadyForRelease)", detail: "Ready for release", accent: HFColors.gold, systemImage: "sparkles.tv.fill"))
                    }
                }
                .padding(HFSpacing.lg)
            }

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    osSectionHeader(title: "Executive Briefing", detail: "Deterministic local summary with no AI, network, persistence, upload, or publish path.")
                    brainSignalRow(title: "Today's Priorities", detail: snapshot.briefing.todaysPriorities, status: "Priority", systemImage: "target", accent: HFColors.gold)
                    brainSignalRow(title: "Highest Risk", detail: snapshot.briefing.highestRisk, status: "Risk", systemImage: "exclamationmark.triangle.fill", accent: HFColors.redAccent)
                    brainSignalRow(title: "Highest Opportunity", detail: snapshot.briefing.highestOpportunity, status: "Opportunity", systemImage: "sparkles", accent: HFColors.cyanGlow)
                    brainSignalRow(title: "Recommended Focus", detail: snapshot.briefing.recommendedFocus, status: "Focus", systemImage: "scope", accent: HFColors.violet)
                }
                .padding(HFSpacing.lg)
            }

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.redAccent.opacity(0.30)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    osSectionHeader(title: "Risk Matrix", detail: "Critical, high, medium, and low risks grouped by project from local engines.")
                    ForEach(HFExecutiveRiskLevel.allCases, id: \.rawValue) { level in
                        let risks = snapshot.riskMatrix.filter { $0.level == level }
                        VStack(alignment: .leading, spacing: HFSpacing.sm) {
                            Text("\(level.rawValue) (\(risks.count))")
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(executiveRiskAccent(for: level))
                            if risks.isEmpty {
                                emptySignalRow(title: "No \(level.rawValue.lowercased()) risks", detail: "No local \(level.rawValue.lowercased()) risk records are visible in this executive snapshot.")
                            } else {
                                ForEach(risks.prefix(4)) { risk in
                                    brainSignalRow(title: "\(risk.projectTitle): \(risk.title)", detail: "\(risk.detail) Source: \(risk.source).", status: risk.level.rawValue, systemImage: risk.systemImage, accent: executiveRiskAccent(for: risk.level))
                                }
                            }
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Resource Allocation", detail: "Placeholder allocation only. No staffing, CRM, backend, or persistence is connected.")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        ForEach(snapshot.resourceAllocation) { resource in
                            commandMetricCard(HFCommandMetric(title: resource.area.rawValue, value: resource.allocationLabel, detail: "\(resource.loadScore)% load. \(resource.detail)", accent: resourceAccent(for: resource.loadScore), systemImage: resource.systemImage))
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    osSectionHeader(title: "Executive Timeline", detail: "Development, Packaging, QA, Release, and Marketing timeline from Mission Planner and Execution Tracking.")
                    ForEach(snapshot.timeline) { item in
                        brainSignalRow(title: "\(item.stage.rawValue) \(item.progressPercent)%", detail: "\(item.detail) \(item.blockedCount) blockers.", status: item.blockedCount > 0 ? "Blocked" : "Local", systemImage: item.systemImage, accent: brainAccent(for: item.severity))
                    }
                }
                .padding(HFSpacing.lg)
            }

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "Executive Navigation", detail: "Local navigation only. Use these to open Brain views or studio workspaces without publishing, uploading, persisting, or calling a backend.")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        ForEach(snapshot.commandActions) { action in
                            executiveCommandButton(action)
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.command.center.executiveDashboard")
    }

    private var controlWallSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            cinematicControlWall
            livePreviewPanels
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.command.center.controlWall")
    }

    private var intelligenceSurface: some View {
        let brainSnapshot = HFLocalProjectStore.higherKeyBrainSnapshot
        let studioIntelligence = HFLocalProjectStore.autonomousStudioIntelligenceSnapshot
        let workflowAutomation = HFLocalProjectStore.workflowAutomationSnapshot
        let orchestration = HFLocalProjectStore.orchestrationSnapshot
        let missionPlanner = HFLocalProjectStore.missionPlannerSnapshot
        let executionTracking = HFLocalProjectStore.executionTrackingSnapshot
        let cohesion = HFLocalProjectStore.higherKeyOSCohesionSnapshot

        return VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.48)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    osSectionHeader(title: "HigherKey Brain", detail: "Local command hub for Studio Intelligence, Workflow Automation, Orchestration, Mission Planner, and Execution Tracking.")
                    insightCard("Brain Operating Snapshot", brainSnapshot.summary, "brain.head.profile", HFColors.violet)
                    insightCard("Project State", "\(brainSnapshot.sourceLabel) feeds \(brainSnapshot.projectCount) local projects into studio tools.", "square.stack.3d.up.fill", HFColors.cyanGlow)
                    insightCard("Autonomous Studio Signals", studioIntelligence.summary, "waveform.path.ecg", HFColors.gold)
                    insightCard("Workflow Automation", workflowAutomation.summary, "arrow.triangle.branch", HFColors.cyanGlow)
                    insightCard("Orchestration Engine", orchestration.summary, "point.3.connected.trianglepath.dotted", HFColors.violet)
                    insightCard("Mission Planner", missionPlanner.summary, "checklist.checked", HFColors.gold)
                    insightCard("Execution Tracking", executionTracking.summary, "chart.line.uptrend.xyaxis", HFColors.cyanGlow)

                    HFSpatialActionCluster {
                        HFEnergyAction(title: "Back to Executive", systemImage: "gauge.with.dots.needle.50percent", style: .gold) {
                            selectedMode = .executiveDashboard
                        }
                        HStack(spacing: HFSpacing.sm) {
                            HFEnergyAction(title: "Open Packaging Studio", systemImage: "shippingbox.fill", style: .glass) {
                                selectedRoom = .createRoom
                                selectedMode = .missionControl
                            }
                            HFEnergyAction(title: "Open Creator OS", systemImage: "command", style: .glass) {
                                selectedRoom = .createRoom
                                selectedMode = .missionControl
                            }
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            systemMapSection(cohesion, title: "System Map", detail: "Read-only navigation map for the HigherKey OS surfaces that share the local project state.")
            brainDashboardSection(studioIntelligence)
            orchestrationSection(orchestration)
            missionPlannerSection(missionPlanner)
            executionTrackingSection(executionTracking)
            workflowAutomationSection(workflowAutomation)
            activitySignalsPanel
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.command.center.intelligenceLayer")
    }

    private func brainDashboardSection(_ snapshot: HFStudioIntelligenceSnapshot) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "HigherKey Brain Dashboard", detail: "Safe local-only studio intelligence. Actions prepare review notes and do not publish, upload, or call a backend.")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Events", value: "\(snapshot.events.count)", detail: "Project activity", accent: HFColors.violet, systemImage: "waveform.path.ecg"))
                    commandMetricCard(HFCommandMetric(title: "Dependencies", value: "\(snapshot.dependencySignals.count)", detail: "Local blockers", accent: HFColors.gold, systemImage: "point.3.connected.trianglepath.dotted"))
                    commandMetricCard(HFCommandMetric(title: "Readiness", value: "\(snapshot.readinessChanges.count)", detail: "State changes", accent: HFColors.cyanGlow, systemImage: "gauge.with.dots.needle.67percent"))
                    commandMetricCard(HFCommandMetric(title: "Suggestions", value: "\(snapshot.automationSuggestions.count)", detail: "Local next actions", accent: HFColors.gold, systemImage: "sparkles"))
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Project Events")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.events.isEmpty {
                        emptySignalRow(title: "No project events", detail: "Studio Intelligence has no local project events to surface right now.")
                    } else {
                        ForEach(snapshot.events.prefix(3)) { event in
                            brainSignalRow(title: event.title, detail: "\(event.projectTitle) - \(event.detail)", status: event.kind.rawValue, systemImage: event.systemImage, accent: brainAccent(for: event.severity))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Dependencies")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.dependencySignals.isEmpty {
                        emptySignalRow(title: "No dependency blockers", detail: "No local dependency signals need executive or Brain review.")
                    } else {
                        ForEach(snapshot.dependencySignals.prefix(3)) { signal in
                            brainSignalRow(title: signal.dependencyTitle, detail: "\(signal.upstreamWorkspace) to \(signal.downstreamWorkspace) - \(signal.detail)", status: signal.status, systemImage: signal.systemImage, accent: brainAccent(for: signal.severity))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Readiness Changes")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.readinessChanges.isEmpty {
                        emptySignalRow(title: "No readiness movement", detail: "Project readiness is stable in the current local snapshot.")
                    } else {
                        ForEach(snapshot.readinessChanges.prefix(3)) { change in
                            brainSignalRow(title: "\(change.projectTitle) \(change.readinessLabel)", detail: change.detail, status: change.deltaLabel, systemImage: change.systemImage, accent: brainAccent(for: change.severity))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Automation Suggestions")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.automationSuggestions.isEmpty {
                        emptySignalRow(title: "No automation suggestions", detail: "Workflow Automation has no local suggestions ready for Brain review.")
                    } else {
                        ForEach(snapshot.automationSuggestions.prefix(3)) { suggestion in
                            brainSignalRow(title: suggestion.title, detail: "\(suggestion.projectTitle) - \(suggestion.detail)", status: suggestion.actionLabel, systemImage: suggestion.systemImage, accent: brainAccent(for: suggestion.severity))
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.higherKeyBrainDashboard")
    }

    private func systemMapSection(_ snapshot: HFOSCohesionSnapshot, title: String, detail: String) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: title, detail: detail)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(snapshot.checks) { check in
                        commandMetricCard(HFCommandMetric(title: check.title, value: check.status.rawValue, detail: check.detail, accent: cohesionAccent(for: check.status), systemImage: check.systemImage))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Operating Routes")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.navigationRoutes) { route in
                        brainSignalRow(title: route.title, detail: "\(route.source) to \(route.target). \(route.detail)", status: "Local", systemImage: route.systemImage, accent: HFColors.cyanGlow)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Local Boundaries")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(Array(snapshot.localBoundaryNotes.enumerated()), id: \.offset) { index, note in
                        brainSignalRow(title: "Boundary \(index + 1)", detail: note, status: "Read Only", systemImage: "lock.shield.fill", accent: HFColors.gold)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.systemCohesion")
    }

    private func orchestrationSection(_ snapshot: HFOrchestrationSnapshot) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Orchestration Engine", detail: "Local-only sequencing across project state, Studio Intelligence, Workflow Automation, HigherKey Brain, Packaging Studio, Creator OS, QA, Release, and Marketing.")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Queue", value: "\(snapshot.queue.count)", detail: "Handoff items", accent: HFColors.violet, systemImage: "list.bullet.rectangle.fill"))
                    commandMetricCard(HFCommandMetric(title: "Next Handoff", value: snapshot.nextHandoff?.targetWorkspace.rawValue ?? "Clear", detail: snapshot.nextHandoff?.projectTitle ?? "No handoff waiting for review", accent: HFColors.gold, systemImage: "arrow.turn.down.right"))
                    commandMetricCard(HFCommandMetric(title: "Blocked Handoffs", value: "\(snapshot.blockedHandoffs.count)", detail: snapshot.blockedHandoffs.isEmpty ? "No blocked workspace handoffs" : "Review held workspace handoffs", accent: snapshot.blockedHandoffs.isEmpty ? HFColors.cyanGlow : HFColors.redAccent, systemImage: "lock.trianglebadge.exclamationmark.fill"))
                    commandMetricCard(HFCommandMetric(title: "Pipeline", value: "\(snapshot.projectStates.count)", detail: "Project states", accent: HFColors.cyanGlow, systemImage: "square.stack.3d.up.fill"))
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Orchestration Queue")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.queue.isEmpty {
                        emptySignalRow(title: "Queue is clear", detail: "No local handoff items are waiting in the orchestration queue.")
                    } else {
                        ForEach(snapshot.queue.prefix(5)) { item in
                            brainSignalRow(title: "\(item.position). \(item.title)", detail: "\(item.projectTitle) -> \(item.targetWorkspace.rawValue). \(item.suggestedAction)", status: item.status.rawValue, systemImage: item.systemImage, accent: brainAccent(for: item.severity))
                        }
                    }
                }

                if let nextHandoff = snapshot.nextHandoff {
                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("Next Workspace Handoff")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        brainSignalRow(title: nextHandoff.title, detail: "\(nextHandoff.sourceWorkspace.rawValue) -> \(nextHandoff.targetWorkspace.rawValue). \(nextHandoff.detail)", status: nextHandoff.status.rawValue, systemImage: nextHandoff.systemImage, accent: brainAccent(for: nextHandoff.severity))
                    }
                } else {
                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("Next Workspace Handoff")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        emptySignalRow(title: "No handoff waiting", detail: "No local workspace handoff is currently waiting for Brain or Executive review.")
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Blocked Handoffs")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.blockedHandoffs.isEmpty {
                        emptySignalRow(title: "No blocked handoffs", detail: "Every visible workspace handoff is clear or already sequenced.")
                    } else {
                        ForEach(snapshot.blockedHandoffs.prefix(4)) { handoff in
                            brainSignalRow(title: handoff.title, detail: "\(handoff.projectTitle) - \(handoff.blockerSummary). \(handoff.detail)", status: handoff.status.rawValue, systemImage: handoff.systemImage, accent: brainAccent(for: handoff.severity))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Suggested Sequence")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.projectStates.prefix(3)) { state in
                        brainSignalRow(title: state.projectTitle, detail: state.suggestedSequence, status: state.readinessLabel, systemImage: state.systemImage, accent: brainAccent(for: state.severity))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Project Pipeline State")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.projectStates.prefix(3)) { state in
                        brainSignalRow(title: state.pipelineState, detail: "\(state.currentWorkspace.rawValue) -> \(state.nextWorkspace.rawValue). \(state.blockedHandoffCount) blocked handoffs.", status: state.status.rawValue, systemImage: state.systemImage, accent: brainAccent(for: state.severity))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Local Navigation Actions")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        ForEach(snapshot.localActions) { action in
                            orchestrationActionButton(action, nextWorkspace: snapshot.nextHandoff?.targetWorkspace)
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.orchestrationEngine")
    }

    private func missionPlannerSection(_ snapshot: HFMissionPlannerSnapshot) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Mission Planner", detail: "Local mission plans convert orchestration output into milestones, task groups, blocker timelines, and execution steps.")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Missions", value: "\(snapshot.activeMissions.count)", detail: "Active plans", accent: HFColors.gold, systemImage: "checklist.checked"))
                    commandMetricCard(HFCommandMetric(title: "Milestones", value: "\(snapshot.milestones.count)", detail: "Workspace gates", accent: HFColors.violet, systemImage: "flag.checkered"))
                    commandMetricCard(HFCommandMetric(title: "Tasks", value: "\(snapshot.priorityTasks.count)", detail: "Priority actions", accent: HFColors.cyanGlow, systemImage: "list.bullet.clipboard.fill"))
                    commandMetricCard(HFCommandMetric(title: "Blockers", value: "\(snapshot.blockerTimeline.count)", detail: snapshot.blockerTimeline.isEmpty ? "No mission blockers visible" : "Review mission blocker timeline", accent: snapshot.blockerTimeline.isEmpty ? HFColors.cyanGlow : HFColors.redAccent, systemImage: "exclamationmark.triangle.fill"))
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Active Missions")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.activeMissions.prefix(3)) { mission in
                        brainSignalRow(title: mission.title, detail: "\(mission.objective) \(mission.blockerCount) blockers visible.", status: mission.priority.rawValue, systemImage: mission.systemImage, accent: missionAccent(for: mission.priority))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Milestones")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.milestones.prefix(5)) { milestone in
                        brainSignalRow(title: "\(milestone.sequenceIndex). \(milestone.title)", detail: "\(milestone.projectTitle) -> \(milestone.workspace.rawValue). \(milestone.detail)", status: milestone.status.rawValue, systemImage: milestone.systemImage, accent: brainAccent(for: milestone.severity))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Priority Tasks")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.priorityTasks.prefix(5)) { task in
                        brainSignalRow(title: task.title, detail: "\(task.projectTitle) -> \(task.workspace.rawValue). \(task.detail)", status: task.priority.rawValue, systemImage: task.systemImage, accent: missionAccent(for: task.priority))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Blocker Timeline")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.blockerTimeline.isEmpty {
                        emptySignalRow(title: "No mission blockers", detail: "Mission Planner does not show a local blocker timeline in this snapshot.")
                    } else {
                        ForEach(snapshot.blockerTimeline.prefix(5)) { event in
                            brainSignalRow(title: "\(event.sequenceIndex). \(event.title)", detail: "\(event.sourceWorkspace.rawValue) -> \(event.targetWorkspace.rawValue). \(event.detail)", status: event.status.rawValue, systemImage: event.systemImage, accent: brainAccent(for: event.severity))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Execution Plan")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.executionPlan.prefix(6)) { step in
                        brainSignalRow(title: "\(step.sequenceIndex). \(step.title)", detail: "\(step.projectTitle) -> \(step.workspace.rawValue). \(step.detail)", status: step.status.rawValue, systemImage: step.systemImage, accent: brainAccent(for: step.severity))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.missionPlanner")
    }

    private func executionTrackingSection(_ snapshot: HFExecutionTrackingSnapshot) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Execution Tracking", detail: "Local execution status turns mission plans into task state, progress history, ownership placeholders, timeline progress, and completion forecasts.")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Execution", value: "\(snapshot.activeExecutionStatuses.count)", detail: "Active statuses", accent: HFColors.cyanGlow, systemImage: "chart.line.uptrend.xyaxis"))
                    commandMetricCard(HFCommandMetric(title: "Completion", value: "\(snapshot.averageCompletionPercent)%", detail: "Average progress", accent: HFColors.gold, systemImage: "gauge.with.dots.needle.67percent"))
                    commandMetricCard(HFCommandMetric(title: "Tasks", value: "\(snapshot.taskCompletionStates.count)", detail: "Tracked states", accent: HFColors.violet, systemImage: "checklist.checked"))
                    commandMetricCard(HFCommandMetric(title: "Execution Holds", value: "\(snapshot.blockedTaskCount)", detail: snapshot.blockedTaskCount > 0 ? "Review blocked execution tasks" : "No blocked execution tasks", accent: snapshot.blockedTaskCount > 0 ? HFColors.redAccent : HFColors.cyanGlow, systemImage: "exclamationmark.triangle.fill"))
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Active Execution Status")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.activeExecutionStatuses.isEmpty {
                        emptySignalRow(title: "No active execution status", detail: "No mission execution records are active in this local snapshot.")
                    } else {
                        ForEach(snapshot.activeExecutionStatuses.prefix(3)) { status in
                            brainSignalRow(title: status.title, detail: "\(status.completionPercent)% complete. \(status.activeTaskCount) active tasks, \(status.blockedTaskCount) blocked. Owner: \(status.ownerPlaceholder).", status: status.status.rawValue, systemImage: status.systemImage, accent: executionAccent(for: status.status))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Task Completion")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.taskCompletionStates.isEmpty {
                        emptySignalRow(title: "No tracked tasks", detail: "Execution Tracking has no local task states to display.")
                    } else {
                        ForEach(snapshot.taskCompletionStates.prefix(5)) { task in
                            brainSignalRow(title: task.title, detail: "\(task.projectTitle) -> \(task.workspace.rawValue). \(task.completionPercent)% complete. Owner: \(task.ownerPlaceholder).", status: task.state.rawValue, systemImage: task.systemImage, accent: executionAccent(for: task.state))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Progress History")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.progressHistory.prefix(5)) { event in
                        brainSignalRow(title: "\(event.sequenceIndex). \(event.title)", detail: "\(event.projectTitle) - \(event.detail)", status: event.progressLabel, systemImage: event.systemImage, accent: executionAccent(for: event.state))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Owner Placeholders")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.ownerPlaceholders.prefix(5)) { owner in
                        brainSignalRow(title: owner.ownerName, detail: "\(owner.role) for \(owner.projectTitle): \(owner.responsibility)", status: owner.state.rawValue, systemImage: owner.systemImage, accent: executionAccent(for: owner.state))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Timeline Progress")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.timelineProgress.prefix(6)) { progress in
                        brainSignalRow(title: "\(progress.sequenceIndex). \(progress.title)", detail: "\(progress.projectTitle) -> \(progress.workspace.rawValue). \(progress.progressPercent)% timeline progress, \(progress.blockedCount) blockers.", status: progress.state.rawValue, systemImage: progress.systemImage, accent: executionAccent(for: progress.state))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Completion Forecast")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.completionForecasts.prefix(3)) { forecast in
                        brainSignalRow(title: forecast.forecastLabel, detail: "\(forecast.projectTitle): \(forecast.projectedCompletionPercent)% projected. \(forecast.blockerRisk). Next: \(forecast.nextBestAction).", status: forecast.confidence.rawValue, systemImage: forecast.systemImage, accent: forecastAccent(for: forecast.confidence))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.executionTracking")
    }

    private func workflowAutomationSection(_ snapshot: HFWorkflowAutomationSnapshot) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Workflow Automation", detail: "Rules and readiness movement are local recommendations only. No state is persisted and no publish or upload path is enabled.")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Rules", value: "\(snapshot.rules.count)", detail: "Enabled local rules", accent: HFColors.cyanGlow, systemImage: "switch.2"))
                    commandMetricCard(HFCommandMetric(title: "Triggered", value: "\(snapshot.triggeredSuggestions.count)", detail: "Suggested actions", accent: HFColors.gold, systemImage: "sparkles"))
                    commandMetricCard(HFCommandMetric(title: "Dependency Holds", value: "\(snapshot.blockedDependencies.count)", detail: snapshot.blockedDependencies.isEmpty ? "No blocked dependencies" : "Review local dependency holds", accent: snapshot.blockedDependencies.isEmpty ? HFColors.cyanGlow : HFColors.redAccent, systemImage: "lock.trianglebadge.exclamationmark.fill"))
                    commandMetricCard(HFCommandMetric(title: "Movement", value: "\(snapshot.readinessMovementRecommendations.count)", detail: "Readiness guidance", accent: HFColors.violet, systemImage: "arrow.up.forward.circle.fill"))
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Automation Rules")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.rules.prefix(4)) { rule in
                        brainSignalRow(title: rule.title, detail: "\(rule.trigger) - \(rule.localAction)", status: rule.kind.rawValue, systemImage: rule.systemImage, accent: brainAccent(for: rule.severity))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Triggered Suggestions")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.triggeredSuggestions.prefix(4)) { suggestion in
                        brainSignalRow(title: suggestion.title, detail: "\(suggestion.projectTitle) - \(suggestion.detail)", status: suggestion.actionLabel, systemImage: suggestion.systemImage, accent: brainAccent(for: suggestion.severity))
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Blocked Dependencies")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    if snapshot.blockedDependencies.isEmpty {
                        emptySignalRow(title: "No dependency holds", detail: "Workflow Automation has no blocked local dependencies to inspect.")
                    } else {
                        ForEach(snapshot.blockedDependencies.prefix(4)) { dependency in
                            brainSignalRow(title: dependency.dependencyTitle, detail: "\(dependency.projectTitle) - \(dependency.detail)", status: dependency.status, systemImage: dependency.systemImage, accent: brainAccent(for: dependency.severity))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Readiness Movement")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    ForEach(snapshot.readinessMovementRecommendations.prefix(4)) { movement in
                        brainSignalRow(title: movement.recommendedState, detail: "\(movement.projectTitle) \(movement.readinessLabel) - \(movement.dependencySummary). \(movement.detail)", status: movement.isMovementAllowed ? "Advance" : "Hold", systemImage: movement.systemImage, accent: brainAccent(for: movement.severity))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.workflowAutomation")
    }

    private var cinematicControlWall: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.46)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Cinematic Control Wall", detail: "A premium wall of local platform views and visual room controls.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    previewPanel("Watch Preview", featuredMovie.title, "play.rectangle.fill", HFColors.gold)
                    previewPanel("Create Preview", "Creator Studio Pro", "wand.and.stars", HFColors.violet)
                    previewPanel("Connect Preview", "Watch Room", "person.3.sequence.fill", HFColors.cyanGlow)
                    previewPanel("Launch Preview", "Final Gate", "sparkles.tv.fill", HFColors.gold)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.controlWallPanels")
    }

    private var livePreviewPanels: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                osSectionHeader(title: "Live Preview Panels", detail: "Visual-only windows for Watch, Create, Connect, Launch, and Pass.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    previewPanel("Watch", "Local Preview", "play.tv.fill", HFColors.gold)
                    previewPanel("Create", "Draft Studio", "wand.and.stars", HFColors.violet)
                    previewPanel("Connect", "Room Preview", "person.3.sequence.fill", HFColors.cyanGlow)
                    previewPanel("Launch", "Review Gate", "sparkles.tv.fill", HFColors.gold)
                    previewPanel("Pass", selectedProfile.name, "person.text.rectangle.fill", HFColors.gold)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.livePreviewPanels")
    }

    private var roomStatusGrid: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                osSectionHeader(title: "Room Status Center", detail: "Room, launch, and creator status presented as local read-only state.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    commandMetricCard(HFCommandMetric(title: "Room Status", value: "Local", detail: "Audience preview ready", accent: HFColors.cyanGlow, systemImage: "person.3.sequence.fill"))
                    commandMetricCard(HFCommandMetric(title: "Launch Status", value: "Review", detail: "Final gate visual only", accent: HFColors.gold, systemImage: "sparkles.tv.fill"))
                    commandMetricCard(HFCommandMetric(title: "Creator Status", value: "Draft", detail: "Pro surfaces staged", accent: HFColors.violet, systemImage: "wand.and.stars"))
                    commandMetricCard(HFCommandMetric(title: "Pass Status", value: "Active", detail: selectedProfile.name, accent: HFColors.gold, systemImage: "person.text.rectangle.fill"))
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.roomStatus")
    }

    private var activitySignalsPanel: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                osSectionHeader(title: "Activity Signals", detail: "Viewer, creator, release, and membership signals grouped from local preview state.")
                activityRow(room: .watchRoom, title: "Viewer Activity", detail: "\(featuredMovie.title) remains staged for local preview", status: "Watch")
                activityRow(room: .createRoom, title: "Creator Activity", detail: "Creator Studio Pro and commentary gateways stay visual", status: "Create")
                activityRow(room: .launchRoom, title: "Release Activity", detail: "Launch center preview and review surfaces remain local", status: "Launch")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.command.center.activitySignals")
    }

    private var dashboardSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            primaryCommandPanel(
                title: "\(selectedRoom.title) Command Layer",
                detail: selectedRoom.detail,
                systemImage: selectedRoom.systemImage,
                accent: selectedRoom.accent,
                identifier: "hf.os.commandPalette"
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                roomStatusCard(.watchRoom, value: featuredMovie.title, status: "Ready")
                roomStatusCard(.createRoom, value: "Studio Pro", status: "Draft")
                roomStatusCard(.roomConnect, value: "Room Preview", status: "Local")
                roomStatusCard(.launchRoom, value: "Final Gate", status: "Review")
                roomStatusCard(.passRoom, value: selectedProfile.name, status: "Active")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.os.roomStatusCenter")
    }

    private var activitySurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Activity Center", detail: "Recent local room motion across the HighFive product.")
                activityFeed
                recentTimeline
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.os.activityCenter")
    }

    private var activityFeed: some View {
        VStack(spacing: HFSpacing.sm) {
            activityRow(room: .watchRoom, title: "Continue Watching", detail: featuredMovie.title, status: "Local")
            activityRow(room: .createRoom, title: "Creator Work", detail: "Release notes and social kit preview", status: "Draft")
            activityRow(room: .roomConnect, title: "Room Activity", detail: "Watch room command center reviewed", status: "Preview")
            activityRow(room: .launchRoom, title: "Launch Activity", detail: "Mock targets and final gate aligned", status: "Review")
            activityRow(room: .passRoom, title: "Pass Activity", detail: "Local account mode remains active", status: "Private")
        }
        .accessibilityIdentifier("hf.os.activityFeed")
    }

    private var spotlightSurface: some View {
        HFOpticalGlassSurface(cornerRadius: 34, strokeColor: HFColors.gold.opacity(0.50)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "OS Spotlight", detail: "Visual command palette for titles, rooms, recents, and local actions.")

                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                    Text("Search titles, open rooms, review recent local activity")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                }
                .padding(HFSpacing.md)
                .background(Color.black.opacity(0.34))
                .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(HFColors.gold.opacity(0.24), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    quickAction("Open Watch", systemImage: "play.tv.fill", room: .watchRoom)
                    quickAction("Open Create", systemImage: "wand.and.stars", room: .createRoom)
                    quickAction("Open Connect", systemImage: "person.3.sequence.fill", room: .roomConnect)
                    quickAction("Open Launch", systemImage: "sparkles.tv.fill", room: .launchRoom)
                    quickAction("Open Pass", systemImage: "person.text.rectangle.fill", room: .passRoom)
                    quickAction("Recent Room", systemImage: "clock.fill", room: selectedRoom)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.os.spotlight")
        .accessibilityIdentifier("hf.os.commandPalette")
    }

    private var missionControlSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.44)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    osSectionHeader(title: "OS Mission Control", detail: "A unified overview of every HighFive room.")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        missionCard(.watchRoom, metric: "Now")
                        missionCard(.createRoom, metric: "Pro")
                        missionCard(.roomConnect, metric: "Room")
                        missionCard(.launchRoom, metric: "Gate")
                        missionCard(.passRoom, metric: "Gold")
                    }
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.os.missionControl")
    }

    private var healthSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.44)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                osSectionHeader(title: "Room Health Board", detail: "Read-only local status for the HighFive OS surfaces.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    healthCard(title: "Watch", value: "Ready", accent: HFColors.gold)
                    healthCard(title: "Create", value: "Draft", accent: HFColors.violet)
                    healthCard(title: "Connect", value: "Local", accent: HFColors.cyanGlow)
                    healthCard(title: "Launch", value: "Review", accent: HFColors.gold)
                    healthCard(title: "Pass", value: "Active", accent: HFColors.gold)
                    healthCard(title: "Signals", value: "\(savedCount) saved", accent: HFColors.cyanGlow)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.os.healthBoard")
    }

    private var recentTimeline: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            osSectionHeader(title: "Recent Activity Timeline", detail: "Local preview events grouped by room.")
            timelineStep("Watch", "Featured title staged in the hero theater", HFColors.gold)
            timelineStep("Create", "Creator Studio Pro remains draft-focused", HFColors.violet)
            timelineStep("Connect", "Audience room preview is ready", HFColors.cyanGlow)
            timelineStep("Launch", "Distribution center final gate is visual only", HFColors.gold)
        }
        .accessibilityIdentifier("hf.os.recentTimeline")
    }

    private var osFooter: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Text("Unified Room Footer")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text("HighFive OS is a visual command layer. The locked streaming tabs remain Home, Search, Library, Downloads, and Profile.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func primaryCommandPanel(title: String, detail: String, systemImage: String, accent: Color, identifier: String) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.46)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(accent == HFColors.gold ? .black : accent)
                        .frame(width: 62, height: 62)
                        .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.title)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        Text(detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFSpatialActionCluster {
                    HFEnergyAction(title: "Review \(selectedRoom.shortTitle)", systemImage: selectedRoom.systemImage, style: .gold) {
                        selectedMode = .missionControl
                    }
                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: "Activity", systemImage: "waveform.path.ecg", style: .glass) {
                            selectedMode = .activity
                        }
                        HFEnergyAction(title: "Spotlight", systemImage: "sparkle.magnifyingglass", style: .glass) {
                            selectedMode = .spotlight
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier(identifier)
    }

    private func commandPillar(_ title: String, _ value: String, _ systemImage: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(accent == HFColors.gold ? .black : accent)
                .frame(width: 42, height: 42)
                .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(value)
                .font(HFTypography.micro)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func commandMetricCard(_ metric: HFCommandMetric) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top) {
                Image(systemName: metric.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(metric.accent == HFColors.gold ? .black : metric.accent)
                    .frame(width: 42, height: 42)
                    .background(metric.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(metric.accent.opacity(0.18)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Spacer()
                Text(metric.title)
                    .font(HFTypography.micro)
                    .foregroundStyle(metric.accent)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
            }
            Text(metric.value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.64)
            Text(metric.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.black.opacity(0.28))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(metric.accent.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func executiveTile(_ title: String, _ value: String, _ detail: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(value)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.black.opacity(0.30))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func previewPanel(_ title: String, _ value: String, _ systemImage: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 40, height: 40)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Spacer()
                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)
            }
            Spacer(minLength: HFSpacing.xs)
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(value)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(
            LinearGradient(
                colors: [accent.opacity(0.18), Color.black.opacity(0.42)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func insightCard(_ title: String, _ detail: String, _ systemImage: String, _ accent: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(accent == HFColors.gold ? .black : accent)
                .frame(width: 42, height: 42)
                .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(HFSpacing.md)
        .background(Color.black.opacity(0.28))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func brainSignalRow(title: String, detail: String, status: String, systemImage: String, accent: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(accent == HFColors.gold ? .black : accent)
                .frame(width: 34, height: 34)
                .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                HStack(alignment: .top, spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: HFSpacing.xs)
                    Text(status)
                        .font(HFTypography.micro)
                        .foregroundStyle(accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }

                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.26))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.22), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func emptySignalRow(title: String, detail: String) -> some View {
        brainSignalRow(title: title, detail: detail, status: "Clear", systemImage: "checkmark.seal.fill", accent: HFColors.cyanGlow)
    }

    private func orchestrationActionButton(_ action: HFOrchestrationLocalAction, nextWorkspace: HFOrchestrationWorkspace?) -> some View {
        let accent = action.isPlaceholder ? HFColors.gold : brainAccent(for: action.targetWorkspace == .qa ? .blocked : .info)

        return osNavigationActionButton(
            id: "orchestration.\(action.id)",
            title: action.title,
            caption: orchestrationActionCaption(action),
            detail: action.detail,
            systemImage: action.systemImage,
            accent: accent,
            minHeight: 158
        ) {
            if action.id == "open-target-workspace" {
                openOrchestrationWorkspace(nextWorkspace ?? action.targetWorkspace)
            } else {
                selectedMode = .intelligence
            }
        }
    }

    private func executiveCommandButton(_ action: HFExecutiveCommandAction) -> some View {
        let accent = action.targetWorkspace.map(executiveWorkspaceAccent) ?? HFColors.gold

        return osNavigationActionButton(
            id: "executive.\(action.id)",
            title: action.title,
            caption: executiveActionCaption(action),
            detail: action.detail,
            systemImage: action.systemImage,
            accent: accent,
            minHeight: 150
        ) {
            openExecutiveCommandAction(action)
        }
    }

    private func osNavigationActionButton(
        id: String,
        title: String,
        caption: String,
        detail: String,
        systemImage: String,
        accent: Color,
        minHeight: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 38, height: 38)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(caption)
                    .font(HFTypography.micro)
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .padding(HFSpacing.sm)
            .background(Color.black.opacity(0.28))
            .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.24), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("hf.command.center.\(id)")
    }

    private func executiveActionCaption(_ action: HFExecutiveCommandAction) -> String {
        switch action.id {
        case "open-brain":
            return "HigherKey Brain"
        case "open-mission-planner":
            return "Brain -> Mission Planner"
        case "open-workflow-automation":
            return "Brain -> Workflow Automation"
        case "open-packaging-studio", "open-creator-os":
            return "Open Studio Workspace"
        case "open-studio-intelligence":
            return "Brain -> Studio Intelligence"
        case "open-execution-tracking":
            return "Brain -> Execution Tracking"
        default:
            return action.targetWorkspace?.rawValue ?? "Local"
        }
    }

    private func orchestrationActionCaption(_ action: HFOrchestrationLocalAction) -> String {
        if action.isPlaceholder { return "Review Placeholder" }
        switch action.targetWorkspace {
        case .packagingStudio, .creatorOS:
            return "Open Studio Workspace"
        case .higherKeyBrain:
            return "Back to Brain"
        default:
            return action.targetWorkspace.rawValue
        }
    }

    private func openExecutiveCommandAction(_ action: HFExecutiveCommandAction) {
        switch action.id {
        case "open-packaging-studio", "open-creator-os":
            selectedRoom = .createRoom
            selectedMode = .missionControl
        default:
            selectedMode = .intelligence
        }
    }

    private func openOrchestrationWorkspace(_ workspace: HFOrchestrationWorkspace) {
        switch workspace {
        case .unifiedProjectState, .studioIntelligence, .workflowAutomation, .higherKeyBrain:
            selectedMode = .intelligence
        case .packagingStudio, .creatorOS:
            selectedRoom = .createRoom
            selectedMode = .missionControl
        case .qa, .release, .marketing:
            selectedRoom = .launchRoom
            selectedMode = .missionControl
        }
    }

    private func executiveWorkspaceAccent(for workspace: HFOrchestrationWorkspace) -> Color {
        switch workspace {
        case .unifiedProjectState, .studioIntelligence, .workflowAutomation, .higherKeyBrain:
            return HFColors.cyanGlow
        case .packagingStudio, .release, .marketing:
            return HFColors.gold
        case .creatorOS:
            return HFColors.violet
        case .qa:
            return HFColors.redAccent
        }
    }

    private func executiveRiskAccent(for level: HFExecutiveRiskLevel) -> Color {
        switch level {
        case .critical:
            return HFColors.redAccent
        case .high:
            return HFColors.gold
        case .medium:
            return HFColors.violet
        case .low:
            return HFColors.cyanGlow
        }
    }

    private func resourceAccent(for loadScore: Int) -> Color {
        if loadScore >= 75 { return HFColors.redAccent }
        if loadScore >= 50 { return HFColors.gold }
        return HFColors.cyanGlow
    }

    private func cohesionAccent(for status: HFOSCohesionStatus) -> Color {
        switch status {
        case .aligned:
            return HFColors.cyanGlow
        case .localOnly:
            return HFColors.gold
        case .review:
            return HFColors.redAccent
        }
    }

    private func missionAccent(for priority: HFMissionPriority) -> Color {
        switch priority {
        case .critical:
            return HFColors.redAccent
        case .high:
            return HFColors.gold
        case .medium:
            return HFColors.violet
        case .normal:
            return HFColors.cyanGlow
        }
    }

    private func executionAccent(for state: HFExecutionTaskState) -> Color {
        switch state {
        case .notStarted:
            return HFColors.violet
        case .inProgress:
            return HFColors.cyanGlow
        case .blocked:
            return HFColors.redAccent
        case .reviewNeeded:
            return HFColors.gold
        case .complete:
            return HFColors.cyanGlow
        }
    }

    private func forecastAccent(for confidence: HFExecutionForecastConfidence) -> Color {
        switch confidence {
        case .high:
            return HFColors.cyanGlow
        case .medium:
            return HFColors.gold
        case .low:
            return HFColors.redAccent
        }
    }

    private func brainAccent(for severity: HFStudioSignalSeverity) -> Color {
        switch severity {
        case .info:
            return HFColors.cyanGlow
        case .watch:
            return HFColors.violet
        case .attention:
            return HFColors.gold
        case .blocked:
            return HFColors.redAccent
        case .ready:
            return HFColors.cyanGlow
        }
    }

    private func cinemaOrbit(nodes: [HFCinemaNetworkNode]) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.black.opacity(0.28))
                .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(HFColors.cyanGlow.opacity(0.18), lineWidth: 1))

            Circle()
                .stroke(HFColors.gold.opacity(0.20), lineWidth: 1)
                .frame(width: 190, height: 190)
            Circle()
                .stroke(HFColors.cyanGlow.opacity(0.16), lineWidth: 1)
                .frame(width: 130, height: 130)

            VStack(spacing: HFSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text("HighFive")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Cinema Network")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .padding(HFSpacing.sm)
            .background(Color.black.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

            VStack {
                HStack {
                    networkNodeChip(nodes[safe: 0])
                    Spacer()
                    networkNodeChip(nodes[safe: 1])
                }
                Spacer()
                HStack {
                    networkNodeChip(nodes[safe: 2])
                    Spacer()
                    networkNodeChip(nodes[safe: 3])
                }
                Spacer()
                HStack {
                    networkNodeChip(nodes[safe: 4])
                    Spacer()
                    networkNodeChip(nodes[safe: 5])
                }
            }
            .padding(HFSpacing.md)
        }
        .frame(minHeight: 340)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cinema Network orbit map")
    }

    private func networkNodeChip(_ node: HFCinemaNetworkNode?) -> some View {
        Group {
            if let node {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: node.systemImage)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(node.accent == HFColors.gold ? .black : node.accent)
                        .frame(width: 34, height: 34)
                        .background(node.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(node.accent.opacity(0.20)))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(node.title)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Text(node.detail)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(width: 102, height: 86, alignment: .topLeading)
                .padding(HFSpacing.xs)
                .background(Color.black.opacity(0.38))
                .overlay(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous).stroke(node.accent.opacity(0.28), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            }
        }
    }

    private func relationshipPath(_ start: String, _ end: String, _ detail: String, _ startAccent: Color, _ endAccent: Color) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Text(start)
                .font(HFTypography.micro)
                .foregroundStyle(startAccent)
                .frame(width: 78, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
            Rectangle()
                .fill(LinearGradient(colors: [startAccent, endAccent], startPoint: .leading, endPoint: .trailing))
                .frame(height: 2)
                .overlay(alignment: .trailing) {
                    Circle()
                        .fill(endAccent)
                        .frame(width: 8, height: 8)
                }
            Text(end)
                .font(HFTypography.micro)
                .foregroundStyle(endAccent)
                .frame(width: 82, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .overlay(alignment: .bottomLeading) {
            Text(detail)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .padding(.leading, 86)
                .offset(y: 14)
        }
        .padding(.bottom, HFSpacing.sm)
    }

    private func cinemaNetworkGrid(_ nodes: [HFCinemaNetworkNode]) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                osSectionHeader(title: "Connected Objects", detail: "Visual-only local objects in the HighFive cinema universe.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(nodes) { node in
                        networkObjectCard(node)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
    }

    private func networkObjectCard(_ node: HFCinemaNetworkNode) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Image(systemName: node.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(node.accent == HFColors.gold ? .black : node.accent)
                .frame(width: 42, height: 42)
                .background(node.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(node.accent.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            Text(node.title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(node.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(node.accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private var creatorConstellationBoard: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                osSectionHeader(title: "Creator Constellation", detail: "Projects, collaborators, commentary, and releases remain local preview objects.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(creatorNetworkNodes) { node in
                        networkObjectCard(node)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
    }

    private func galaxyCluster(_ title: String, _ detail: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 70, height: 70)
                Circle()
                    .stroke(accent.opacity(0.40), lineWidth: 1)
                    .frame(width: 92, height: 92)
                Circle()
                    .fill(accent)
                    .frame(width: 12, height: 12)
                    .offset(x: 34, y: -28)
            }
            .frame(maxWidth: .infinity)
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.black.opacity(0.30))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func roomStatusCard(_ room: HFOSRoom, value: String, status: String) -> some View {
        Button {
            selectedRoom = room
            selectedMode = .missionControl
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: room.systemImage)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(room.accent == HFColors.gold ? .black : room.accent)
                    .frame(width: 46, height: 46)
                    .background(room.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(room.accent.opacity(0.18)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Text(room.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(value)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(status)
                    .font(HFTypography.micro)
                    .foregroundStyle(room.accent)
            }
            .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
            .padding(HFSpacing.md)
            .background(Color.white.opacity(0.055))
            .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(room.accent.opacity(0.28), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func activityRow(room: HFOSRoom, title: String, detail: String, status: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: room.systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(room.accent == HFColors.gold ? .black : room.accent)
                .frame(width: 38, height: 38)
                .background(room.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(room.accent.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            Spacer(minLength: HFSpacing.xs)
            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(room.accent)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 26)
                .background(room.accent.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.26))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func quickAction(_ title: String, systemImage: String, room: HFOSRoom) -> some View {
        Button {
            selectedRoom = room
            selectedMode = .dashboard
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(room.accent == HFColors.gold ? .black : room.accent)
                    .frame(width: 44, height: 44)
                    .background(room.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(room.accent.opacity(0.18)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text("Visual command")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
            .padding(HFSpacing.sm)
            .background(Color.white.opacity(0.055))
            .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(room.accent.opacity(0.24), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func missionCard(_ room: HFOSRoom, metric: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Image(systemName: room.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(room.accent)
                Spacer()
                Text(metric)
                    .font(HFTypography.micro)
                    .foregroundStyle(room.accent)
            }
            Text(room.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
            Text(room.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.black.opacity(0.28))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(room.accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func healthCard(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.30))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous).stroke(accent.opacity(0.24), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func timelineStep(_ title: String, _ detail: String, _ accent: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Circle()
                .fill(accent)
                .frame(width: 10, height: 10)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }
        }
    }

    private func osSectionHeader(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(title)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.textPrimary)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFCommandMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let detail: String
    let accent: Color
    let systemImage: String
}

private struct HFCinemaNetworkNode: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let accent: Color
    let systemImage: String
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private enum HFOSRoom: String, CaseIterable, Identifiable {
    case watchRoom
    case createRoom
    case roomConnect
    case launchRoom
    case passRoom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .watchRoom: return "Watch"
        case .createRoom: return "Create"
        case .roomConnect: return "Connect"
        case .launchRoom: return "Launch"
        case .passRoom: return "Pass"
        }
    }

    var shortTitle: String {
        title.uppercased()
    }

    var detail: String {
        switch self {
        case .watchRoom: return "Streaming home, detail world, player, and local preview paths."
        case .createRoom: return "Creator Studio Pro, social asset kit, and commentary room gateway."
        case .roomConnect: return "Watch room, premiere lobby, audience presence, and room energy."
        case .launchRoom: return "Distribution center, mock targets, visual pipeline, and final review."
        case .passRoom: return "HighFive Pass, local account mode, and private access readiness."
        }
    }

    var systemImage: String {
        switch self {
        case .watchRoom: return "play.tv.fill"
        case .createRoom: return "wand.and.stars"
        case .roomConnect: return "person.3.sequence.fill"
        case .launchRoom: return "sparkles.tv.fill"
        case .passRoom: return "person.text.rectangle.fill"
        }
    }

    var accent: Color {
        switch self {
        case .watchRoom: return HFColors.gold
        case .createRoom: return HFColors.violet
        case .roomConnect: return HFColors.cyanGlow
        case .launchRoom: return HFColors.gold
        case .passRoom: return HFColors.gold
        }
    }
}

private enum HFLaunchIntroStep: Int, CaseIterable {
    case intro
    case motion
    case controls
    case homeReveal

    var page: Int { rawValue }

    static var initialFromLaunchArguments: HFLaunchIntroStep {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-onboarding-intro") { return .intro }
        if arguments.contains("--hf-onboarding-tilt-peek") { return .motion }
        if arguments.contains("--hf-onboarding-instructions") { return .controls }
        if arguments.contains("--hf-onboarding-controls") { return .controls }
        if arguments.contains("--hf-onboarding-home-reveal") { return .homeReveal }
        return .intro
    }
}

private struct HFLaunchIntroSequenceView: View {
    let onFinish: () -> Void

    @State private var step: HFLaunchIntroStep

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        _step = State(initialValue: HFLaunchIntroStep.initialFromLaunchArguments)
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            switch step {
            case .intro:
                HFLaunchIntroVideoScreen(
                    onContinue: { advance(to: .motion) },
                    onSkip: onFinish
                )
                .transition(.opacity)
                .accessibilityIdentifier("hf.onboarding.brandIntro")
                .accessibilityLabel("HighFive Cinema brand intro")
            case .motion:
                HFLaunchMotionInstructionScreen(
                    onContinue: { advance(to: .controls) },
                    onSkip: onFinish
                )
                .transition(.opacity)
                .accessibilityIdentifier("hf.onboarding.motionTraining")
                .accessibilityLabel("Motion training, tilt to move and peek to explore")
            case .controls:
                HFLaunchControlsTrainingScreen(
                    onContinue: { advance(to: .homeReveal) },
                    onSkip: onFinish
                )
                .transition(.opacity)
                .accessibilityIdentifier("hf.onboarding.controlsTraining")
                .accessibilityLabel("Controls training, play scrub depth focus import and export")
            case .homeReveal:
                HFLaunchHomeRevealScreen(onFinish: onFinish)
                    .transition(.opacity)
                    .accessibilityIdentifier("hf.onboarding.homeReveal")
                    .accessibilityLabel("Home reveal, enter HighFive Cinema")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HFLaunchPageDots(currentPage: step.page, totalPages: HFLaunchIntroStep.allCases.count)
                .padding(.bottom, 148)
        }
    }

    private func advance(to nextStep: HFLaunchIntroStep) {
        withAnimation(.easeInOut(duration: 0.28)) {
            step = nextStep
        }
    }
}

private struct HFLaunchIntroVideoScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var isAnimating = false

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Continue",
            secondaryTitle: "Skip Intro",
            primaryIdentifier: "hf.onboarding.continueButton",
            secondaryIdentifier: "hf.onboarding.skipButton",
            onPrimary: onContinue,
            onSecondary: onSkip
        ) {
            VStack(spacing: 22) {
                ZStack {
                    Image("UI_Feature_SpatialViewing")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(isAnimating ? 1.08 : 1.0)
                        .frame(width: 278, height: 372)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .black.opacity(0.12),
                                    .black.opacity(0.72)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(HFColors.gold.opacity(0.36), lineWidth: 1)
                        )
                        .shadow(color: HFColors.gold.opacity(0.20), radius: 28, x: 0, y: 16)

                    VStack(spacing: 14) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 58, weight: .semibold))
                            .foregroundStyle(.white, HFColors.gold)
                            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)

                        Text("HighFive Cinema")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .kerning(1.4)
                    }
                    .offset(y: 112)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("HighFive Cinema intro video")

                VStack(spacing: 12) {
                    Text("HighFive Cinema")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.82)

                    Text("A cinematic walk into the streaming home.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.76))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 28)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

private struct HFLaunchMotionInstructionScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var isTilting = false

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Next",
            secondaryTitle: "Skip",
            primaryIdentifier: "hf.onboarding.continueButton",
            secondaryIdentifier: "hf.onboarding.skipButton",
            onPrimary: onContinue,
            onSecondary: onSkip
        ) {
            VStack(spacing: 30) {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.white)
                        .frame(width: 156, height: 308)
                        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 16)
                        .overlay {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27, style: .continuous)
                                    .fill(Color(red: 0.05, green: 0.06, blue: 0.09))
                                    .padding(8)

                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                HFColors.gold.opacity(0.38),
                                                Color(red: 0.12, green: 0.15, blue: 0.22),
                                                .white.opacity(0.10)
                                            ],
                                            startPoint: isTilting ? .topLeading : .topTrailing,
                                            endPoint: isTilting ? .bottomTrailing : .bottomLeading
                                        )
                                    )
                                    .padding(14)
                                    .offset(x: isTilting ? 16 : -16)

                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.white.opacity(0.16))
                                    .frame(width: 84, height: 88)
                                    .offset(x: isTilting ? -10 : 10, y: 78)

                                Capsule()
                                    .fill(Color.black.opacity(0.22))
                                    .frame(width: 44, height: 5)
                                    .offset(y: -134)
                            }
                        }
                        .rotationEffect(.degrees(isTilting ? -7 : 7), anchor: .bottom)
                        .rotation3DEffect(.degrees(isTilting ? -14 : 14), axis: (x: 0, y: 1, z: 0), perspective: 0.65)
                        .offset(x: isTilting ? -5 : 5)
                        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: isTilting)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Tilting and peeking phone animation")

                VStack(spacing: 10) {
                    Text("Tilt to move")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("hf.onboarding.tiltToMove")

                    Text("Shift your view")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(HFColors.gold.opacity(0.92))
                        .multilineTextAlignment(.center)

                    Text("Peek to explore")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("hf.onboarding.peekToExplore")

                    Text("Reveal more of the scene with guided motion training.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Small movements work best.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(HFColors.gold.opacity(0.88))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear { isTilting = true }
    }
}

private struct HFLaunchControlsTrainingScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Next",
            secondaryTitle: "Skip",
            primaryIdentifier: "hf.onboarding.continueButton",
            secondaryIdentifier: "hf.onboarding.skipButton",
            onPrimary: onContinue,
            onSecondary: onSkip
        ) {
            VStack(spacing: HFSpacing.lg) {
                VStack(spacing: HFSpacing.sm) {
                    Text("Master the Controls")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Everything you need to play, explore, and save your videos.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    HFLaunchControlTile(title: "Play / Pause", detail: "Start or pause the scene.", systemImage: "playpause.fill")
                    HFLaunchControlTile(title: "Scrub", detail: "Move through a moment.", systemImage: "slider.horizontal.3")
                    HFLaunchControlTile(title: "Depth", detail: "Explore layered viewing.", systemImage: "square.stack.3d.down.forward.fill")
                        .accessibilityIdentifier("hf.onboarding.depthControl")
                    HFLaunchControlTile(title: "Focus", detail: "Keep the story clear.", systemImage: "scope")
                        .accessibilityIdentifier("hf.onboarding.focusControl")
                    HFLaunchControlTile(title: "Import", detail: "Training label only.", systemImage: "tray.and.arrow.down.fill")
                    HFLaunchControlTile(title: "Export", detail: "Training label only.", systemImage: "tray.and.arrow.up.fill")
                }
                .accessibilityIdentifier("hf.onboarding.importExportTraining")
            }
            .padding(.horizontal, 28)
        }
    }
}

private struct HFLaunchHomeRevealScreen: View {
    let onFinish: () -> Void

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Enter Home",
            secondaryTitle: nil,
            primaryIdentifier: "hf.onboarding.enterHomeButton",
            secondaryIdentifier: nil,
            onPrimary: onFinish,
            onSecondary: nil
        ) {
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(HFColors.gold.opacity(0.18))
                        .frame(width: 210, height: 210)
                        .blur(radius: 18)

                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 74, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 132, height: 132)
                        .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: HFColors.gold.opacity(0.30), radius: 28, x: 0, y: 18)
                }

                VStack(spacing: 12) {
                    Text("HighFive Cinema")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Home is ready.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(HFColors.gold)
                        .multilineTextAlignment(.center)

                    Text("Start with premium streaming, then open the product suite when you are ready.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 30)
            }
        }
        .accessibilityIdentifier("hf.functional.onboarding.entersHome")
    }
}

private struct HFLaunchControlTile: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 34, height: 34)
                .background(HFColors.gold.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 112, alignment: .topLeading)
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(detail)")
    }
}

private struct HFLaunchInstructionFormatScreen: View {
    let onFinish: () -> Void

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Enter Home",
            secondaryTitle: nil,
            primaryIdentifier: "hf.onboarding.enterHomeButton",
            secondaryIdentifier: nil,
            onPrimary: onFinish,
            onSecondary: nil
        ) {
            VStack(spacing: 14) {
                Text("Before you enter")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .textCase(.uppercase)
                    .kerning(1.2)

                Text("How to watch in HighFive")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.82)

                Text("Use small, comfortable phone movements. You can always watch normally from the Home screen.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.74))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)

                HFLaunchInstructionRow(identifier: "hf.onboarding.row.tilt", number: "1", title: "Tilt", detail: "Gently angle the phone to move through a scene.")
                HFLaunchInstructionRow(identifier: "hf.onboarding.row.peek", number: "2", title: "Peek", detail: "Lean left or right to reveal more of the frame.")
                HFLaunchInstructionRow(identifier: "hf.onboarding.row.watch", number: "3", title: "Watch", detail: "Enter the Home screen when you are ready to browse.")
            }
            .padding(.horizontal, 28)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("HighFive instructions, tilt to move, peek to explore, then enter the home screen")
        }
    }
}

private struct HFLaunchInstructionRow: View {
    let identifier: String
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 32, height: 32)
                .background(HFColors.gold, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text(detail)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.70))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("\(title) instruction, \(detail)")
    }
}

private struct HFLaunchScreenFrame<Content: View>: View {
    let primaryTitle: String
    let secondaryTitle: String?
    let primaryIdentifier: String
    let secondaryIdentifier: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.06, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer(minLength: 22)
                content
                Spacer(minLength: 168)
            }

            VStack(spacing: 14) {
                Spacer()

                Button(action: onPrimary) {
                    Text(primaryTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .accessibilityIdentifier(primaryIdentifier)
                .accessibilityLabel(primaryTitle == "Next" ? "Continue onboarding" : primaryTitle)

                if let secondaryTitle, let onSecondary {
                    Button(action: onSecondary) {
                        Text(secondaryTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.82))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .accessibilityIdentifier(secondaryIdentifier ?? "hf.onboarding.skipButton")
                    .accessibilityLabel(secondaryTitle)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
        }
    }
}

private struct HFLaunchPageDots: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? .white : .white.opacity(0.30))
                    .frame(width: index == currentPage ? 22 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.20), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding page \(currentPage + 1) of \(totalPages)")
    }
}
