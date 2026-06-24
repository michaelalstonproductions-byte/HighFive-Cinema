import Foundation
import Combine

struct HFLocalViewingProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var role: String
    var avatarSymbol: String
    var accentName: String
}

enum HFPlaybackSourceStatus: Equatable {
    case playableLocal
    case sourceNotConnected
}

struct HFPlaybackSource: Equatable {
    let movieID: String
    let title: String
    let status: HFPlaybackSourceStatus
    let localURL: URL?
    let providerName: String
    let readinessLabel: String
    let limitation: String
}

enum HFCloudSyncStatus {
    case localOnly
    case cloudReady
    case cloudNotConnected
}

enum HFOfflineAssetStatus {
    case eligible
    case queued
    case localStateOnly
    case sourceRequired
    case providerNotConnected
}

struct HFOfflineAssetRecord: Identifiable, Codable, Equatable {
    let id: String
    let movieID: String
    var title: String
    var status: String
    var detail: String
    var updatedAtLabel: String
}

struct HFDownloadQueueItem: Identifiable, Codable, Equatable {
    let id: String
    let movieID: String
    var title: String
    var status: String
    var reason: String
}

enum HFCommunicationProviderStatus {
    case localAdapterActive
    case remoteProviderNotConnected
}

enum HFCommunicationUpdateStatus: String, Codable, Equatable {
    case draft = "Draft"
    case preview = "Preview"
    case ready = "Ready"
    case notSent = "Not Sent"
}

struct HFAudienceChannel: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var purpose: String
    var status: String
    var systemImage: String
}

struct HFAudienceUpdateRecord: Identifiable, Codable, Equatable {
    let id: String
    var channelID: String
    var movieID: String
    var authorProfileID: String
    var body: String
    var status: String
    var safetyLabel: String
    var updatedAtLabel: String
}

struct HFCommunicationReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFLaunchCampaignProviderStatus {
    case localAdapterActive
    case remoteProviderNotConnected
}

enum HFLaunchMilestoneStatus: String, Codable, Equatable {
    case draft = "Draft"
    case ready = "Ready"
    case localReview = "Local Review"
    case notPublished = "Not Published"
}

struct HFLaunchCampaignRecord: Identifiable, Codable, Equatable {
    let id: String
    var movieID: String
    var title: String
    var audience: String
    var status: String
    var providerStatus: String
    var updatedAtLabel: String
}

struct HFLaunchMilestoneRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFLaunchChannelRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var purpose: String
    var status: String
    var systemImage: String
}

struct HFLaunchCampaignReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFCreatorReleaseState: String, CaseIterable, Codable, Equatable {
    case draft = "Draft"
    case review = "Review"
    case scheduled = "Scheduled"
    case published = "Published"
    case archived = "Archived"
}

enum HFCreatorPublishingAssetStatus: String, Codable, Equatable {
    case missing = "Missing"
    case placeholder = "Placeholder"
    case ready = "Ready"
    case needsReview = "Needs Review"
}

struct HFCreatorPublishingContent: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var posterAssetName: String?
    var trailerStatus: HFCreatorPublishingAssetStatus
    var creator: String
    var genre: String
    var tags: [String]
    var runtime: String
    var releaseState: HFCreatorReleaseState
    var posterStatus: HFCreatorPublishingAssetStatus
    var metadataStatus: HFCreatorPublishingAssetStatus
    var artworkStatus: HFCreatorPublishingAssetStatus
    var updatedAtLabel: String

    var readyForReview: Bool {
        [posterStatus, trailerStatus, metadataStatus, artworkStatus].allSatisfy { $0 == .ready || $0 == .needsReview }
            && releaseState != .archived
    }

    var discoveryEligible: Bool {
        releaseState == .published
    }

    var movie: Movie {
        Movie(
            id: id,
            title: title,
            subtitle: releaseState == .published ? "Creator published title" : "\(releaseState.rawValue) creator project",
            synopsis: description,
            year: "2026",
            rating: "TV-14",
            duration: runtime,
            genres: Array(Set([genre, "Creator"].filter { !$0.isEmpty } + tags)).sorted(),
            posterAssetName: posterAssetName,
            backdropAssetName: posterAssetName,
            creatorName: creator,
            isOriginal: true,
            isComingSoon: releaseState != .published,
            isDownloaded: false,
            progress: releaseState == .published ? nil : 0.12
        )
    }
}

struct HFCreatorProfile: Identifiable {
    let creator: Creator
    let bio: String
    let bannerTitle: String
    let avatarSymbol: String
    let filmography: [Movie]
    let publishedTitles: [Movie]
    let scheduledTitles: [Movie]
    let archivedTitles: [Movie]
    let collections: [Category]
    let featuredProject: Movie?
    let latestRelease: Movie?

    var id: String { creator.id }
}

enum HFCMSContentType: String, CaseIterable, Identifiable {
    case movie = "Movie"
    case series = "Series"
    case episode = "Episode"
    case trailer = "Trailer"
    case collection = "Collection"
    case creator = "Creator"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .movie: return "film.stack.fill"
        case .series: return "rectangle.stack.fill"
        case .episode: return "play.square.stack.fill"
        case .trailer: return "play.rectangle.fill"
        case .collection: return "rectangle.grid.2x2.fill"
        case .creator: return "person.crop.rectangle.stack.fill"
        }
    }
}

struct HFCMSContentRecord: Identifiable {
    let id: String
    var title: String
    var type: HFCMSContentType
    var description: String
    var creatorName: String
    var genre: String
    var tags: [String]
    var runtime: String
    var rating: String
    var artworkStatus: HFCreatorPublishingAssetStatus
    var trailerStatus: HFCreatorPublishingAssetStatus
    var releaseState: HFCreatorReleaseState
    var collectionIDs: [String]
    var seriesID: String?
    var relatedTitleIDs: [String]
}

struct HFCMSCollectionRecord: Identifiable {
    let id: String
    var title: String
    var description: String
    var movieIDs: [String]
}

struct HFCMSRelationshipRecord: Identifiable {
    let id: String
    var source: String
    var target: String
    var relationship: String
    var detail: String
}

struct HFCMSStatusCount: Identifiable {
    let state: HFCreatorReleaseState
    var count: Int

    var id: String { state.rawValue }
}

struct HFLibraryActivityRecord: Identifiable {
    let id: String
    var movie: Movie
    var status: String
    var detail: String
    var progress: Double?
}

struct HFLibraryCollection: Identifiable {
    let id: String
    var title: String
    var detail: String
    var movies: [Movie]
    var systemImage: String
}

struct HFLibraryNextEpisode: Identifiable {
    let id: String
    var series: Movie
    var title: String
    var detail: String
}

struct HFLibraryIntelligenceSignal: Identifiable {
    let id: String
    var title: String
    var detail: String
    var value: String
    var systemImage: String
}

struct HFAnalyticsMetric: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var systemImage: String
}

struct HFTitleAnalyticsRecord: Identifiable {
    let id: String
    var movie: Movie
    var totalViews: Int
    var averageWatchTime: String
    var completionRate: Int
    var libraryAdds: Int
    var favorites: Int
    var sharesPlaceholder: Int
}

struct HFDiscoveryAnalyticsRecord: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var systemImage: String
}

struct HFCreatorAnalyticsRecord: Identifiable {
    let id: String
    var creatorName: String
    var publishedTitles: Int
    var views: Int
    var watchTime: String
    var followers: Int
    var growthTrend: String
    var topContent: String
}

struct HFAnalyticsInsight: Identifiable {
    let id: String
    var title: String
    var detail: String
    var value: String
    var systemImage: String
}

struct HFCreatorPublishingQueueRecord: Identifiable {
    let id: String
    var project: HFCreatorPublishingContent
    var priority: String
    var stage: String
    var nextStep: String
    var owner: String
}

struct HFCreatorPublishingReadinessItem: Identifiable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFCreatorPublishingScheduleItem: Identifiable {
    let id: String
    var title: String
    var window: String
    var status: String
    var detail: String
}

struct HFCreatorPublishingAuditRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var result: String
    var systemImage: String
}

struct HFCreatorPublishingChecklistItem: Identifiable {
    let id: String
    var title: String
    var status: String
    var detail: String
}

enum HFExportDeliveryProviderStatus {
    case localAdapterActive
    case remoteProviderNotConnected
}

enum HFDeliveryPackageStatus: String, Codable, Equatable {
    case draft = "Draft"
    case localReview = "Local Review"
    case ready = "Ready"
    case notSubmitted = "Not Submitted"
}

struct HFDeliveryPackageRecord: Identifiable, Codable, Equatable {
    let id: String
    var movieID: String
    var title: String
    var ownerProfileID: String
    var summary: String
    var status: String
    var providerStatus: String
    var updatedAtLabel: String
}

struct HFDeliveryRequirementRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFDistributionHandoffRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFExportDeliveryReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFPaymentProviderStatus: String, Codable, Equatable {
    case localAdapterActive
    case remoteProviderNotConnected

    var statusLabel: String {
        switch self {
        case .localAdapterActive:
            return "Local Preview Access"
        case .remoteProviderNotConnected:
            return "Payment Provider Not Connected Yet"
        }
    }
}

enum HFEntitlementStatus: String, Codable, Equatable {
    case localPreview = "Local Preview Access"
    case included = "Included"
    case providerRequired = "Provider Required"
    case notValidated = "Not Validated"
}

struct HFAccessTierRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFEntitlementRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var scope: String
    var status: String
    var detail: String
    var systemImage: String
}

struct HFPaymentReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFBackendRuntimeConfigRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var status: String
}

final class HFStreamingStore: ObservableObject {
    @Published private(set) var savedMovieIDs: Set<String>
    @Published private(set) var downloadedMovieIDs: Set<String>
    @Published private(set) var recentSearches: [String]
    @Published var localConnectUpdateDraft: String
    @Published private(set) var localConnectUpdates: [String]
    @Published private(set) var launchChecklistStates: [Bool]
    @Published private(set) var generatedDeliverySummary: String
    @Published private(set) var localProfiles: [HFLocalViewingProfile]
    @Published private(set) var activeProfileID: String
    @Published private(set) var lastPlayerMovieID: String?
    @Published var selectedAudienceChannelID: String
    @Published private(set) var backendRuntimeStatus: HFBackendRuntimeStatus
    @Published private(set) var authRuntimeStatus: HFAuthRuntimeStatus
    @Published private(set) var entitlementRuntimeStatus: HFEntitlementRuntimeStatus
    @Published private(set) var backendEntitlementRequestState: HFBackendRequestState = .notConfigured
    @Published private(set) var backendPlaybackDescriptorRequestState: HFBackendRequestState = .localPreviewFallbackActive
    @Published private(set) var entitlementPlaybackResult: HFEntitlementPlaybackResult?
    @Published private(set) var activeStagingPlaybackDescriptor: HFPlaybackDescriptor?
    @Published private(set) var lastPlaybackDescriptorAuditContext: HFBackendRequestAuditContext?
    @Published private(set) var creatorPublishingContents: [HFCreatorPublishingContent]

    private let savedKey = "hf.savedMovieIDs"
    private let downloadsKey = "hf.downloadedMovieIDs"
    private let recentSearchesKey = "hf.recentSearches"
    private let connectUpdatesKey = "hf.localConnectUpdates"
    private let launchChecklistKey = "hf.launchChecklistStates"
    private let activeProfileKey = "hf.localProfile.activeID"
    private let profileDisplayNamePrefix = "hf.localProfile.displayName."
    private let lastPlayerMovieKey = "hf.player.lastMovieID"
    private let backendConfiguration: HFBackendConfiguration
    private let backendService: HFBackendService
    private let backendGateway: HFBackendGateway
    private let authConfiguration: HFAuthConfiguration
    private let authService: HFAuthService
    private let librarySyncConfiguration: HFLibrarySyncConfiguration
    private let downloadConfiguration: HFDownloadConfiguration
    private let entitlementConfiguration: HFEntitlementConfiguration
    private let entitlementService: HFEntitlementService
    private let streamingConfiguration: HFStreamingProviderConfiguration
    private let localPreviewPlaybackResolver: HFLocalPreviewPlaybackResolver
    private let remotePlaybackDescriptorGateway: HFRemotePlaybackDescriptorGateway
    private let entitlementPlaybackAdapter: HFBackendEntitlementPlaybackAdapter

    let launchChecklistItems = [
        "Campaign headline reviewed",
        "Premiere copy reviewed",
        "Audience prompt prepared",
        "Media kit checked",
        "Release calendar reviewed"
    ]

    init(
        defaultSavedIDs: Set<String> = ["friendly", "paranormall-s1"],
        backendConfiguration: HFBackendConfiguration = HFBackendConfiguration(),
        backendService: HFBackendService? = nil,
        backendGateway: HFBackendGateway? = nil,
        authConfiguration: HFAuthConfiguration = HFAuthConfiguration(),
        authService: HFAuthService? = nil,
        librarySyncConfiguration: HFLibrarySyncConfiguration = HFLibrarySyncConfiguration(),
        downloadConfiguration: HFDownloadConfiguration = HFDownloadConfiguration(),
        entitlementConfiguration: HFEntitlementConfiguration = HFEntitlementConfiguration(),
        entitlementService: HFEntitlementService? = nil,
        streamingConfiguration: HFStreamingProviderConfiguration = HFStreamingProviderConfiguration()
    ) {
        let resolvedBackendService = backendService ?? HFBackendServiceFactory.make(configuration: backendConfiguration)
        let resolvedAuthService = authService ?? HFAuthServiceFactory.make(configuration: authConfiguration)
        let resolvedEntitlementService = entitlementService ?? HFEntitlementServiceFactory.make(configuration: entitlementConfiguration)
        self.backendConfiguration = backendConfiguration
        self.backendService = resolvedBackendService
        self.backendGateway = backendGateway ?? HFBackendGatewayFactory.make(configuration: backendConfiguration)
        self.authConfiguration = authConfiguration
        self.authService = resolvedAuthService
        self.librarySyncConfiguration = librarySyncConfiguration
        self.downloadConfiguration = downloadConfiguration
        self.entitlementConfiguration = entitlementConfiguration
        self.entitlementService = resolvedEntitlementService
        self.streamingConfiguration = streamingConfiguration
        self.localPreviewPlaybackResolver = HFLocalPreviewPlaybackResolver(localPreviewIDs: Self.localPreviewStreamingIDs)
        self.remotePlaybackDescriptorGateway = HFRemotePlaybackDescriptorGateway(configuration: streamingConfiguration)
        self.entitlementPlaybackAdapter = HFBackendEntitlementPlaybackAdapter(
            endpointResolver: HFBackendEndpointResolver(
                backendConfiguration: backendConfiguration,
                entitlementConfiguration: entitlementConfiguration,
                streamingConfiguration: streamingConfiguration
            )
        )
        backendRuntimeStatus = resolvedBackendService.currentStatus()
        let defaults = UserDefaults.standard
        let profiles = Self.makeLocalProfiles(defaults: defaults)
        let storedActiveProfileID = defaults.string(forKey: activeProfileKey)
        let resolvedActiveProfileID = profiles.contains { $0.id == storedActiveProfileID } ? storedActiveProfileID ?? profiles[0].id : profiles[0].id
        let resolvedAuthProfile = profiles.first { $0.id == resolvedActiveProfileID } ?? profiles[0]
        localProfiles = profiles
        activeProfileID = resolvedActiveProfileID
        authRuntimeStatus = resolvedAuthService.currentStatus(localProfile: resolvedAuthProfile)
        entitlementRuntimeStatus = resolvedEntitlementService.runtimeStatus(userID: resolvedActiveProfileID, titleID: nil)
        savedMovieIDs = Self.loadProfileIDs(
            defaults: defaults,
            scopedKey: Self.scopedKey(savedKey, resolvedActiveProfileID),
            fallbackKey: savedKey,
            fallbackIDs: defaultSavedIDs
        )
        downloadedMovieIDs = Self.loadProfileIDs(
            defaults: defaults,
            scopedKey: Self.scopedKey(downloadsKey, resolvedActiveProfileID),
            fallbackKey: downloadsKey,
            fallbackIDs: Set(HFMockData.movies.filter(\.isDownloaded).map(\.id))
        )
        recentSearches = defaults.stringArray(forKey: recentSearchesKey) ?? HFMockData.searchSuggestions.prefix(3).map(\.title)
        localConnectUpdateDraft = "The Friendly watch-night prompt is ready for local review."
        localConnectUpdates = defaults.stringArray(forKey: connectUpdatesKey) ?? [
            "Draft: Invite viewers to choose who they would watch The Friendly with.",
            "Preview: Share a behind-the-scenes note before premiere week."
        ]
        creatorPublishingContents = Self.makeCreatorPublishingContents()
        let savedLaunchStates = defaults.array(forKey: launchChecklistKey) as? [Bool]
        launchChecklistStates = savedLaunchStates?.count == launchChecklistItems.count ? savedLaunchStates ?? [] : Array(repeating: false, count: launchChecklistItems.count)
        generatedDeliverySummary = ""
        lastPlayerMovieID = defaults.string(forKey: lastPlayerMovieKey)
        selectedAudienceChannelID = "premiere-updates"
        backendEntitlementRequestState = entitlementPlaybackAdapter.runtimeState
        backendPlaybackDescriptorRequestState = entitlementPlaybackAdapter.runtimeState == .notConfigured ? .localPreviewFallbackActive : entitlementPlaybackAdapter.runtimeState
        lastPlaybackDescriptorAuditContext = .localFallback(
            movieID: continueWatchingMovie.id,
            detail: "Staging backend not configured. Local Preview fallback active."
        )
    }

    var backendStatus: HFBackendServiceStatus {
        backendRuntimeStatus.status
    }

    var accountRuntimeStatus: HFAuthRuntimeStatus {
        authRuntimeStatus
    }

    var accountBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "account", fallback: backendService.accountStatus())
    }

    var libraryBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "library", fallback: backendService.libraryStatus())
    }

    var downloadsBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "downloads", fallback: backendService.downloadsStatus())
    }

    var paymentBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "payments", fallback: backendService.paymentStatus())
    }

    var creatorStudioBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "creator-studio", fallback: backendService.creatorStudioStatus())
    }

    var socialKitBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "social-kit", fallback: backendService.socialKitStatus())
    }

    var vodBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "vod-package", fallback: backendService.vodPackageStatus())
    }

    var backendServiceStatuses: [HFBackendServiceStatus] {
        backendRuntimeStatus.services.filter { $0.id != "payments" && $0.id != "downloads" } + [
            librarySyncBackendServiceStatus,
            downloadPolicyBackendServiceStatus,
            entitlementBackendServiceStatus,
            backendEntitlementValidationServiceStatus,
            playbackDescriptorBackendServiceStatus,
            backendEntitlementAdapterServiceStatus,
            backendPlaybackDescriptorAdapterServiceStatus,
            serverSideCloudflareSigningBackendServiceStatus,
            streamingBackendServiceStatus
        ]
    }

    var librarySyncRuntimeStatus: HFLibrarySyncRuntimeStatus {
        makeLibrarySyncService().runtimeStatus(userID: activeProfileID)
    }

    var librarySyncSnapshot: HFLibrarySyncSnapshot {
        makeLocalLibrarySyncAdapter().snapshot(userID: activeProfileID)
    }

    var librarySyncBackendServiceStatus: HFBackendServiceStatus {
        let status = librarySyncRuntimeStatus
        let backendState: HFBackendConnectionState = status.state == .configured ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "library-sync",
            title: "Library Sync",
            detail: status.detail,
            state: backendState,
            statusLabel: status.statusLabel,
            systemImage: "bookmark.rectangle.stack.fill",
            accessibilityIdentifier: "hf.library.syncStatus"
        )
    }

    var entitlementBackendServiceStatus: HFBackendServiceStatus {
        let accessState = entitlementRuntimeStatus.accessState
        let backendState: HFBackendConnectionState = accessState == .entitlementConfigured ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "payments",
            title: "Entitlements / Payments",
            detail: "\(entitlementRuntimeStatus.detail) StoreKit product mapping staged; Cloudflare playback requires backend descriptor and entitlement validation.",
            state: backendState,
            statusLabel: accessState.statusLabel,
            systemImage: "creditcard.and.123",
            accessibilityIdentifier: "hf.entitlement.status"
        )
    }

    var downloadPolicyRuntimeStatus: HFDownloadRuntimeStatus {
        makeDownloadEligibilityService(
            streamingStatus: streamingProviderStatus.status,
            entitlementStatus: entitlementRuntimeStatus.accessState
        )
        .runtimeStatus(localOfflineCount: downloadedMovies.count)
    }

    var downloadPolicyBackendServiceStatus: HFBackendServiceStatus {
        let status = downloadPolicyRuntimeStatus
        let backendState: HFBackendConnectionState = status.providerStatus == .policyConfigured ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "downloads",
            title: "Downloads",
            detail: status.detail,
            state: backendState,
            statusLabel: status.statusLabel,
            systemImage: "arrow.down.circle.fill",
            accessibilityIdentifier: "hf.backendStatus.downloads"
        )
    }

    var streamingProviderStatus: HFStreamingProviderStatus {
        let descriptor = playbackDescriptor(for: continueWatchingMovie)
        return streamingProviderStatus(for: descriptor)
    }

    var streamingBackendServiceStatus: HFBackendServiceStatus {
        let providerStatus = streamingProviderStatus
        let backendState: HFBackendConnectionState = providerStatus.status == .stagingDescriptorReady ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "streaming-provider",
            title: "Streaming Provider",
            detail: providerStatus.detail,
            state: backendState,
            statusLabel: providerStatus.status.statusLabel,
            systemImage: providerStatus.systemImage,
            accessibilityIdentifier: providerStatus.accessibilityIdentifier
        )
    }

    var playbackDescriptorBackendServiceStatus: HFBackendServiceStatus {
        let contract = backendPlaybackDescriptorContract(for: continueWatchingMovie)
        let backendState: HFBackendConnectionState = contract.statusLabel == "Playback descriptor contract ready" ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "playback-descriptor",
            title: "Playback Descriptor",
            detail: "\(contract.playbackDescriptorResponse.detail). Backend playback descriptor endpoint required. No Cloudflare token in app.",
            state: backendState,
            statusLabel: contract.statusLabel,
            systemImage: "lock.rectangle.stack.fill",
            accessibilityIdentifier: "hf.backendStatus.playbackDescriptor"
        )
    }

    var backendEntitlementValidationServiceStatus: HFBackendServiceStatus {
        let contract = backendPlaybackDescriptorContract(for: continueWatchingMovie)
        let backendState: HFBackendConnectionState = contract.entitlementValidationResponse.entitlementStatus == .approved ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "entitlement-validation",
            title: "Entitlement Validation",
            detail: "Backend entitlement validation required. \(contract.entitlementValidationResponse.detail).",
            state: backendState,
            statusLabel: contract.entitlementValidationResponse.entitlementStatus.statusLabel,
            systemImage: "checkmark.shield.fill",
            accessibilityIdentifier: "hf.backendStatus.entitlementValidation"
        )
    }

    var backendEntitlementAdapterServiceStatus: HFBackendServiceStatus {
        let backendState: HFBackendConnectionState = entitlementPlaybackAdapter.canContactStagingEndpoint ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "entitlement-adapter",
            title: "Entitlement Adapter",
            detail: "Validating entitlement uses runtime endpoint config only. No request payloads, response bodies, or playback references are logged.",
            state: backendState,
            statusLabel: backendEntitlementRequestState.statusLabel,
            systemImage: "shield.lefthalf.filled",
            accessibilityIdentifier: "hf.backendStatus.entitlementAdapter"
        )
    }

    var backendPlaybackDescriptorAdapterServiceStatus: HFBackendServiceStatus {
        let backendState: HFBackendConnectionState = activeStagingPlaybackDescriptor == nil ? .localMode : .backendConfigured
        return HFBackendServiceStatus(
            id: "playback-descriptor-adapter",
            title: "Playback Descriptor Adapter",
            detail: "Requesting playback descriptor follows entitlement approval and keeps the returned reference in memory only.",
            state: backendState,
            statusLabel: backendPlaybackDescriptorRequestState.statusLabel,
            systemImage: "rectangle.connected.to.line.below",
            accessibilityIdentifier: "hf.backendStatus.playbackDescriptorAdapter"
        )
    }

    var serverSideCloudflareSigningBackendServiceStatus: HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: "server-side-cloudflare-signing",
            title: "Server-side Cloudflare Signing",
            detail: "Server-side Cloudflare signing required. No Cloudflare token in app.",
            state: .localMode,
            statusLabel: "Server-side Cloudflare signing required",
            systemImage: "lock.shield.fill",
            accessibilityIdentifier: "hf.backendStatus.serverSideCloudflareSigning"
        )
    }

    var backendRuntimeConfigRows: [HFBackendRuntimeConfigRow] {
        [
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.modeKey,
                title: HFBackendConfiguration.modeKey,
                status: backendConfiguration.requestedMode == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.baseURLKey,
                title: HFBackendConfiguration.baseURLKey,
                status: backendConfiguration.backendBaseURL == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.projectURLKey,
                title: HFBackendConfiguration.projectURLKey,
                status: backendConfiguration.projectURL == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.anonKeyKey,
                title: HFBackendConfiguration.anonKeyKey,
                status: backendConfiguration.anonKey == nil ? "Not set" : "Present"
            )
        ]
    }

    var streamingRuntimeConfigRows: [HFBackendRuntimeConfigRow] {
        [
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.providerKey,
                title: HFStreamingProviderConfiguration.providerKey,
                status: streamingConfiguration.requestedProvider == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.modeKey,
                title: HFStreamingProviderConfiguration.modeKey,
                status: streamingConfiguration.requestedMode == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.descriptorBaseURLKey,
                title: HFStreamingProviderConfiguration.descriptorBaseURLKey,
                status: streamingConfiguration.descriptorBaseURL == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.cloudflareAccountIDKey,
                title: HFStreamingProviderConfiguration.cloudflareAccountIDKey,
                status: streamingConfiguration.cloudflareAccountID == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.muxEnvironmentKey,
                title: HFStreamingProviderConfiguration.muxEnvironmentKey,
                status: streamingConfiguration.muxEnvironmentKey == nil ? "Not set" : "Present"
            )
        ]
    }

    var backendHealthSummary: HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: "health",
            title: "Health Check",
            detail: healthDetail(for: backendRuntimeStatus.connectionState),
            state: backendRuntimeStatus.connectionState,
            statusLabel: healthLabel(for: backendRuntimeStatus.connectionState),
            systemImage: healthSystemImage(for: backendRuntimeStatus.connectionState),
            accessibilityIdentifier: healthAccessibilityIdentifier(for: backendRuntimeStatus.connectionState)
        )
    }

    var backendLocalFallbackNote: String {
        switch backendRuntimeStatus.connectionState {
        case .localMode, .localPreview, .backendNotConfigured:
            return "Local fallback active. Backend staging is not contacted without runtime config."
        case .missingCredentials, .credentialsMissing:
            return "Local fallback active until complete runtime config is provided."
        case .stagingUnavailable:
            return "Local fallback active because staging health is unavailable."
        default:
            return "Local fallback remains available for demos and rollback."
        }
    }

    func refreshBackendRuntimeStatus() async {
        guard backendConfiguration.hasAnyRuntimeConfig else {
            backendRuntimeStatus = backendService.currentStatus(for: .localMode)
            return
        }

        guard backendConfiguration.hasCompleteRuntimeConfig else {
            backendRuntimeStatus = backendService.currentStatus(for: .missingCredentials)
            return
        }

        backendRuntimeStatus = backendService.currentStatus(for: .backendConfigured)

        do {
            _ = try await backendGateway.health()
            backendRuntimeStatus = backendService.currentStatus(for: .stagingReachable)
        } catch {
            backendRuntimeStatus = backendService.currentStatus(for: .stagingUnavailable)
        }
    }

    func refreshAuthRuntimeStatus() {
        authRuntimeStatus = authService.currentStatus(localProfile: activeViewingProfile)
    }

    func refreshEntitlementRuntimeStatus(titleID: String? = nil) {
        entitlementRuntimeStatus = entitlementService.runtimeStatus(userID: activeProfileID, titleID: titleID)
    }

    private func backendServiceStatus(id: String, fallback: HFBackendServiceStatus) -> HFBackendServiceStatus {
        backendRuntimeStatus.services.first { $0.id == id } ?? fallback
    }

    private func makeLocalLibrarySyncAdapter() -> HFLocalLibrarySyncAdapter {
        HFLocalLibrarySyncAdapter(
            savedTitleIDs: savedMovieIDs,
            progressByTitleID: Dictionary(uniqueKeysWithValues: allCatalogMovies.compactMap { movie in
                guard let progress = movie.progress else { return nil }
                return (movie.id, progress)
            }),
            offlineTitleIDs: downloadedMovieIDs
        )
    }

    private func makeLibrarySyncService() -> HFLibrarySyncService {
        HFLibrarySyncServiceFactory.make(
            configuration: librarySyncConfiguration,
            backendConfiguration: backendConfiguration,
            authConfiguration: authConfiguration,
            localFallback: makeLocalLibrarySyncAdapter()
        )
    }

    private func makeDownloadEligibilityService(
        streamingStatus: HFPlaybackDescriptorStatus,
        entitlementStatus: HFProductAccessState
    ) -> HFDownloadEligibilityService {
        HFDownloadEligibilityServiceFactory.make(
            configuration: downloadConfiguration,
            streamingStatus: streamingStatus,
            entitlementStatus: entitlementStatus
        )
    }

    private func healthLabel(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Staging Reachable"
        case .stagingUnavailable:
            return "Staging Unavailable"
        case .backendConfigured, .readyForStaging:
            return "Backend Configured"
        case .missingCredentials, .credentialsMissing:
            return "Missing Credentials"
        case .localMode, .localPreview:
            return "Local Mode"
        default:
            return "Backend Not Connected Yet"
        }
    }

    private func healthDetail(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Health Check reached staging from runtime config. No production backend claim is made."
        case .stagingUnavailable:
            return "Health Check ran from runtime config and staging did not return a successful response."
        case .backendConfigured, .readyForStaging:
            return "Runtime config is complete. Health Check is ready to run."
        case .missingCredentials, .credentialsMissing:
            return "Health Check skipped because runtime config is incomplete."
        case .localMode, .localPreview:
            return "Health Check skipped because runtime config is missing."
        default:
            return "Health Check is not connected yet."
        }
    }

    private func healthSystemImage(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "checkmark.seal.fill"
        case .stagingUnavailable:
            return "exclamationmark.triangle.fill"
        default:
            return "server.rack"
        }
    }

    private func healthAccessibilityIdentifier(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "hf.backend.stagingReachable"
        case .stagingUnavailable:
            return "hf.backend.stagingUnavailable"
        case .missingCredentials, .credentialsMissing:
            return "hf.backend.credentialsMissing"
        case .backendConfigured, .readyForStaging:
            return "hf.backend.configured"
        case .localMode, .localPreview:
            return "hf.backend.localMode"
        default:
            return "hf.backend.notConnected"
        }
    }

    // hf.services.accountProfile
    // hf.services.localProfileStore
    // hf.services.activeViewingProfile
    var activeViewingProfile: HFLocalViewingProfile {
        localProfiles.first { $0.id == activeProfileID } ?? localProfiles[0]
    }

    var profileInitials: String {
        let parts = activeViewingProfile.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        let initials = String(parts).uppercased()
        return initials.isEmpty ? "HF" : initials
    }

    var accountMode: String {
        "Profile Active"
    }

    var cloudAccountStatus: String {
        "Cloud Account Not Connected Yet"
    }

    // hf.services.profilePrivacyState
    var profilePrivacyState: String {
        "Privacy Ready"
    }

    // MovieCatalogService
    // LocalCatalogAdapter
    // RemoteCatalogAdapterReady
    // hf.services.catalogProvider
    // hf.services.localCatalogAdapter
    // hf.services.remoteCatalogReady
    // hf.services.catalogReadiness
    // hf.services.catalogIdentity
    // hf.services.movieLookup
    var allCatalogMovies: [Movie] {
        var seen = Set<String>()
        return (HFMockData.movies + creatorPublishedMovies).filter { movie in
            seen.insert(movie.id).inserted
        }
    }

    var movieCatalogStatus: String {
        "Local Catalog Adapter Active"
    }

    var catalogProviderMode: String {
        "Remote Catalog Provider Not Connected Yet"
    }

    var originalsCatalog: [Movie] {
        allCatalogMovies.filter(\.isOriginal)
    }

    var creatorDraftProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .draft }
    }

    var creatorReviewProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .review }
    }

    var creatorScheduledProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .scheduled }
    }

    var creatorPublishedProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .published }
    }

    var creatorArchivedProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .archived }
    }

    var creatorReadyForReviewProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter(\.readyForReview)
    }

    var creatorPublishingQueueRecords: [HFCreatorPublishingQueueRecord] {
        let order: [HFCreatorReleaseState: Int] = [.review: 0, .draft: 1, .scheduled: 2, .published: 3, .archived: 4]
        return creatorPublishingContents
            .sorted { lhs, rhs in
                let left = order[lhs.releaseState] ?? 9
                let right = order[rhs.releaseState] ?? 9
                if left == right { return lhs.title < rhs.title }
                return left < right
            }
            .map { project in
                HFCreatorPublishingQueueRecord(
                    id: "queue-\(project.id)",
                    project: project,
                    priority: publishingPriority(for: project),
                    stage: project.releaseState.rawValue,
                    nextStep: publishingNextStep(for: project),
                    owner: project.creator
                )
            }
    }

    var creatorPublishingReadinessItems: [HFCreatorPublishingReadinessItem] {
        let activeProjects = creatorPublishingContents.filter { $0.releaseState != .archived }
        let readyProjects = activeProjects.filter(\.readyForReview).count
        let assetReady = activeProjects.filter { project in
            [project.posterStatus, project.trailerStatus, project.metadataStatus, project.artworkStatus].allSatisfy { $0 == .ready }
        }.count

        return [
            HFCreatorPublishingReadinessItem(id: "metadata", title: "Metadata readiness", detail: "\(activeProjects.filter { $0.metadataStatus == .ready }.count) of \(activeProjects.count) active records have metadata ready.", status: "\(activeProjects.filter { $0.metadataStatus == .ready }.count)/\(activeProjects.count)", systemImage: "text.justify.left"),
            HFCreatorPublishingReadinessItem(id: "poster", title: "Poster readiness", detail: "\(activeProjects.filter { $0.posterStatus == .ready }.count) poster records are ready or staged.", status: "\(activeProjects.filter { $0.posterStatus == .ready }.count)/\(activeProjects.count)", systemImage: "photo.fill.on.rectangle.fill"),
            HFCreatorPublishingReadinessItem(id: "trailer", title: "Trailer readiness", detail: "\(activeProjects.filter { $0.trailerStatus == .ready }.count) trailer records have local preview status.", status: "\(activeProjects.filter { $0.trailerStatus == .ready }.count)/\(activeProjects.count)", systemImage: "film.stack.fill"),
            HFCreatorPublishingReadinessItem(id: "assets", title: "Artwork readiness", detail: "\(assetReady) active packages have all asset statuses ready.", status: "\(assetReady)/\(activeProjects.count)", systemImage: "rectangle.stack.fill"),
            HFCreatorPublishingReadinessItem(id: "review", title: "Ready for review", detail: "\(readyProjects) packages can move into local review.", status: "\(readyProjects)", systemImage: "checkmark.seal.fill"),
            HFCreatorPublishingReadinessItem(id: "discovery", title: "Discovery connection", detail: "\(creatorPublishedProjects.count) published packages appear in local discovery.", status: "\(creatorPublishedProjects.count)", systemImage: "sparkle.magnifyingglass")
        ]
    }

    var creatorPublishingScheduleItems: [HFCreatorPublishingScheduleItem] {
        creatorPublishingContents.enumerated().map { index, project in
            HFCreatorPublishingScheduleItem(
                id: "schedule-\(project.id)",
                title: project.title,
                window: publishingWindow(for: project, index: index),
                status: project.releaseState == .published ? "Visible" : project.releaseState == .archived ? "Archived" : "Planned",
                detail: project.releaseState == .published ? "Already appears in local discovery." : "Local publishing calendar preview only."
            )
        }
    }

    var creatorPublishingAuditRecords: [HFCreatorPublishingAuditRecord] {
        [
            HFCreatorPublishingAuditRecord(id: "no-upload", title: "No upload action", detail: "Publishing remains a local lifecycle preview with no media transfer.", result: "Safe", systemImage: "lock.shield.fill"),
            HFCreatorPublishingAuditRecord(id: "no-provider", title: "No provider endpoint", detail: "No distributor, storefront, or publishing API is connected.", result: "Local", systemImage: "network.slash"),
            HFCreatorPublishingAuditRecord(id: "no-payment", title: "No payment path", detail: "No purchase, subscription, payout, or payment processor is active.", result: "Safe", systemImage: "creditcard.trianglebadge.exclamationmark"),
            HFCreatorPublishingAuditRecord(id: "discovery-gate", title: "Discovery gate", detail: "Only Published records enter local Home, Search, Discovery, Collections, and Creator Profile surfaces.", result: "\(creatorPublishedProjects.count) visible", systemImage: "checkmark.seal.fill"),
            HFCreatorPublishingAuditRecord(id: "review-gate", title: "Review gate", detail: "\(creatorReadyForReviewProjects.count) projects satisfy local readiness checks.", result: "\(creatorReadyForReviewProjects.count) ready", systemImage: "doc.text.magnifyingglass")
        ]
    }

    var creatorPublishingChecklistItems: [HFCreatorPublishingChecklistItem] {
        [
            HFCreatorPublishingChecklistItem(id: "metadata", title: "Metadata", status: readinessStatus(for: creatorPrimaryReadinessProject.metadataStatus), detail: "Title, description, creator, genre, tags, runtime, and release state."),
            HFCreatorPublishingChecklistItem(id: "poster", title: "Poster", status: readinessStatus(for: creatorPrimaryReadinessProject.posterStatus), detail: "Poster asset or safe placeholder assigned locally."),
            HFCreatorPublishingChecklistItem(id: "trailer", title: "Trailer", status: readinessStatus(for: creatorPrimaryReadinessProject.trailerStatus), detail: "Trailer preview state remains local-only."),
            HFCreatorPublishingChecklistItem(id: "artwork", title: "Artwork", status: readinessStatus(for: creatorPrimaryReadinessProject.artworkStatus), detail: "Artwork package status for local review."),
            HFCreatorPublishingChecklistItem(id: "analytics", title: "Analytics", status: analyticsTitleRecords.contains { $0.id == creatorPrimaryReadinessProject.id } ? "Linked" : "Preview", detail: "P6 analytics can inform publishing decisions."),
            HFCreatorPublishingChecklistItem(id: "audit", title: "Audit", status: "Safe", detail: "No upload, provider, network, payment, or external publish behavior.")
        ]
    }

    var creatorPrimaryReadinessProject: HFCreatorPublishingContent {
        creatorReviewProjects.first
            ?? creatorDraftProjects.first
            ?? creatorScheduledProjects.first
            ?? creatorPublishedProjects.first
            ?? creatorPublishingContents[0]
    }

    private func publishingPriority(for project: HFCreatorPublishingContent) -> String {
        switch project.releaseState {
        case .review:
            return project.readyForReview ? "High" : "Review"
        case .draft:
            return "Build"
        case .scheduled:
            return "Planned"
        case .published:
            return "Monitor"
        case .archived:
            return "Archive"
        }
    }

    private func publishingNextStep(for project: HFCreatorPublishingContent) -> String {
        if project.metadataStatus != .ready { return "Complete metadata" }
        if project.posterStatus != .ready { return "Finalize poster" }
        if project.trailerStatus != .ready { return "Stage trailer preview" }
        if project.artworkStatus != .ready { return "Review artwork" }
        switch project.releaseState {
        case .draft:
            return "Move to local review"
        case .review:
            return "Review readiness"
        case .scheduled:
            return "Confirm planned window"
        case .published:
            return "Measure performance"
        case .archived:
            return "Retain audit"
        }
    }

    private func publishingWindow(for project: HFCreatorPublishingContent, index: Int) -> String {
        switch project.releaseState {
        case .draft:
            return "Draft window"
        case .review:
            return "Review this week"
        case .scheduled:
            return "Planned T+\(index + 2)"
        case .published:
            return "Now visible"
        case .archived:
            return "Retained"
        }
    }

    private func readinessStatus(for status: HFCreatorPublishingAssetStatus) -> String {
        switch status {
        case .ready:
            return "Ready"
        case .needsReview:
            return "Review"
        case .placeholder:
            return "Placeholder"
        case .missing:
            return "Missing"
        }
    }

    var creatorPublishedMovies: [Movie] {
        creatorPublishedProjects.map(\.movie)
    }

    var cmsContentRecords: [HFCMSContentRecord] {
        let titleRecords = allCatalogMovies.map { cmsRecord(for: $0) }
        let episodeRecords = cmsEpisodeRecords
        let trailerRecords = creatorPublishingContents.map { project in
            HFCMSContentRecord(
                id: "\(project.id)-trailer",
                title: "\(project.title) Trailer",
                type: .trailer,
                description: "Trailer management record for \(project.title).",
                creatorName: project.creator,
                genre: project.genre,
                tags: project.tags + ["Trailer"],
                runtime: "Preview",
                rating: "Unrated",
                artworkStatus: project.artworkStatus,
                trailerStatus: project.trailerStatus,
                releaseState: project.releaseState,
                collectionIDs: cmsCollectionIDs(for: project.movie),
                seriesID: nil,
                relatedTitleIDs: []
            )
        }
        let collectionRecords = cmsCollections.map { collection in
            HFCMSContentRecord(
                id: "cms-content-\(collection.id)",
                title: collection.title,
                type: .collection,
                description: collection.description,
                creatorName: "HighFive CMS",
                genre: "Collection",
                tags: ["Collection"],
                runtime: "\(collection.movieIDs.count) titles",
                rating: "Local",
                artworkStatus: .ready,
                trailerStatus: .placeholder,
                releaseState: .published,
                collectionIDs: [collection.id],
                seriesID: nil,
                relatedTitleIDs: collection.movieIDs
            )
        }
        let creatorRecords = creatorProfiles.map { profile in
            HFCMSContentRecord(
                id: "cms-creator-\(profile.id)",
                title: profile.creator.name,
                type: .creator,
                description: profile.bio,
                creatorName: profile.creator.name,
                genre: profile.creator.role,
                tags: ["Creator", "Profile"],
                runtime: "\(profile.filmography.count) titles",
                rating: "Local",
                artworkStatus: .ready,
                trailerStatus: .placeholder,
                releaseState: .published,
                collectionIDs: profile.collections.map(\.id),
                seriesID: nil,
                relatedTitleIDs: profile.filmography.map(\.id)
            )
        }
        return titleRecords + episodeRecords + trailerRecords + collectionRecords + creatorRecords
    }

    var cmsCollections: [HFCMSCollectionRecord] {
        let managedCollections = collectionSystem.map { category in
            HFCMSCollectionRecord(
                id: category.id,
                title: category.title,
                description: category.subtitle ?? "Managed local collection",
                movieIDs: category.movies.map(\.id)
            )
        }
        return managedCollections + creatorProfiles.flatMap { profile in
            profile.collections.map { category in
                HFCMSCollectionRecord(
                    id: category.id,
                    title: category.title,
                    description: category.subtitle ?? "Creator collection",
                    movieIDs: category.movies.map(\.id)
                )
            }
        }
    }

    var cmsStatusCounts: [HFCMSStatusCount] {
        HFCreatorReleaseState.allCases.map { state in
            HFCMSStatusCount(
                state: state,
                count: cmsContentRecords.filter { $0.releaseState == state && [.movie, .series, .episode, .trailer].contains($0.type) }.count
            )
        }
    }

    var cmsRelationships: [HFCMSRelationshipRecord] {
        let movieCreator = allCatalogMovies.map { movie in
            HFCMSRelationshipRecord(
                id: "creator-\(movie.id)",
                source: movie.title,
                target: movie.creatorName,
                relationship: "Movie -> Creator",
                detail: "Creator ownership and profile routing"
            )
        }
        let movieCollections = allCatalogMovies.flatMap { movie in
            cmsCollections
                .filter { $0.movieIDs.contains(movie.id) }
                .map { collection in
                    HFCMSRelationshipRecord(
                        id: "collection-\(movie.id)-\(collection.id)",
                        source: movie.title,
                        target: collection.title,
                        relationship: "Movie -> Collection",
                        detail: "Discovery and browse grouping"
                    )
                }
        }
        let seriesEpisodes = cmsEpisodeRecords.map { episode in
            HFCMSRelationshipRecord(
                id: "episode-\(episode.id)",
                source: episode.title,
                target: episode.seriesID ?? "Series",
                relationship: "Episode -> Series",
                detail: "Series structure for scalable catalog browsing"
            )
        }
        let related = allCatalogMovies.flatMap { movie in
            relatedMovies(for: movie).prefix(2).map { related in
                HFCMSRelationshipRecord(
                    id: "related-\(movie.id)-\(related.id)",
                    source: movie.title,
                    target: related.title,
                    relationship: "Movie -> Related Titles",
                    detail: "Recommendation and detail-page connection"
                )
            }
        }
        var seen = Set<String>()
        return (movieCreator + movieCollections + seriesEpisodes + related).filter { seen.insert($0.id).inserted }
    }

    var creatorProfiles: [HFCreatorProfile] {
        let publishingCreators = creatorPublishingContents.map(\.creator)
        let catalogCreators = allCatalogMovies.map(\.creatorName)
        var seen = Set<String>()
        let creators = (HFMockData.creators + (publishingCreators + catalogCreators).compactMap { name -> Creator? in
            guard seen.insert(name).inserted, !HFMockData.creators.contains(where: { $0.name == name }) else { return nil }
            return Creator(
                id: name.lowercased().replacingOccurrences(of: " ", with: "-"),
                name: name,
                role: "Creator",
                avatarAssetName: nil,
                featuredMovieIDs: allCatalogMovies.filter { $0.creatorName == name }.map(\.id)
            )
        })
        return creators.map { creatorProfile(for: $0) }
    }

    var newThisWeekCatalog: [Movie] {
        ["friendly", "paranormall-s1", "behind-vision", "artist-development", "big-loss"].compactMap(movie(id:)) + creatorPublishedMovies
    }

    var downloadableCatalog: [Movie] {
        allCatalogMovies.filter { isDownloaded($0) || $0.isDownloaded }
    }

    var premiumHomeCatalogRails: [Category] {
        var rails = [
            Category(id: "new-this-week", title: "New This Week", subtitle: "Fresh HighFive picks", movies: newThisWeekCatalog),
            Category(id: "continue-watching", title: "Continue Watching", subtitle: "Pick up where you left off", movies: allCatalogMovies.filter { $0.progress != nil }),
            Category(id: "recommended", title: "Recommended", subtitle: "Selected for your viewing profile", movies: ["black-turnip", "sunshine", "arrival-time", "maple-street", "night-file"].compactMap(movie(id:))),
            Category(id: "only-on-highfive", title: "Only On HighFive", subtitle: "Originals and local showcase titles", movies: originalsCatalog)
        ]
        if !creatorPublishedMovies.isEmpty {
            rails.insert(
                Category(
                    id: "creator-library-published",
                    title: "Creator Published",
                    subtitle: "Titles promoted from Creator Library",
                    movies: creatorPublishedMovies
                ),
                at: 1
            )
        }
        return rails
    }

    var catalogReadinessRows: [String] {
        [
            "Local catalog - Active",
            "Shared movie identity - Active",
            "Home/Search/Movie Detail - Connected",
            "Library/Downloads - Connected",
            "Remote provider - Not Connected Yet",
            "Contracts - Ready from architecture plan"
        ]
    }

    // Playback Source Resolver
    // Local Playback Source
    // RemoteStreamingProviderReady
    // hf.services.playerService
    // hf.services.playbackSourceResolver
    // hf.services.localPlaybackSource
    // hf.services.remoteStreamingProviderReady
    // hf.services.playerReadiness
    // hf.services.continueWatchingState
    var playerProviderStatus: String {
        "Remote Streaming Provider Not Connected Yet"
    }

    var playerServiceMode: String {
        "Player Service Local Resolver"
    }

    var playerReadinessRows: [String] {
        let localStatus = playbackSource(for: continueWatchingMovie).status == .playableLocal ? "Active" : "Missing"
        return [
            "Catalog title - Active",
            "Player route - Active",
            "Player Entitlement Boundary - Local",
            "Local entitlement adapter - Active",
            "Playback source resolver - Active",
            "Local source - \(localStatus)",
            "Remote streaming provider - Not Connected Yet",
            "Remote payment provider - Not Connected Yet",
            "Store provider - Not Connected Yet",
            "Server entitlement validation - Not Connected Yet",
            "Rights checks - Not Connected Yet"
        ]
    }

    func playbackSource(for movie: Movie) -> HFPlaybackSource {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        if Self.localPreviewStreamingIDs.contains(catalogMovie.id) {
            return HFPlaybackSource(
                movieID: catalogMovie.id,
                title: catalogMovie.title,
                status: .playableLocal,
                localURL: nil,
                providerName: "HighFive Local Preview",
                readinessLabel: "Local preview streaming ready",
                limitation: "Local preview only. No streaming provider connected."
            )
        }

        return HFPlaybackSource(
            movieID: catalogMovie.id,
            title: catalogMovie.title,
            status: .sourceNotConnected,
            localURL: nil,
            providerName: "Remote Streaming Provider",
            readinessLabel: "Streaming source not connected yet",
            limitation: "Player route ready. Streaming source not connected yet."
        )
    }

    func playbackDescriptor(for movie: Movie) -> HFPlaybackDescriptor {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        if let activeStagingPlaybackDescriptor,
           activeStagingPlaybackDescriptor.movieID == catalogMovie.id {
            return HFPlaybackDescriptor(
                id: activeStagingPlaybackDescriptor.id,
                movieID: activeStagingPlaybackDescriptor.movieID,
                title: catalogMovie.title,
                status: activeStagingPlaybackDescriptor.status,
                provider: activeStagingPlaybackDescriptor.provider,
                providerAssetMapping: activeStagingPlaybackDescriptor.providerAssetMapping,
                detail: activeStagingPlaybackDescriptor.detail,
                boundary: activeStagingPlaybackDescriptor.boundary
            )
        }

        guard streamingConfiguration.hasAnyRuntimeConfig else {
            return localPreviewPlaybackResolver.descriptor(for: catalogMovie.id, title: catalogMovie.title)
        }

        return remotePlaybackDescriptorGateway.descriptor(
            for: HFPlaybackDescriptorRequest(movieID: catalogMovie.id, profileID: activeProfileID),
            title: catalogMovie.title
        )
    }

    func playbackDescriptorAccessRequest(for movie: Movie) -> HFPlaybackDescriptorAccessRequest {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let context = playbackEntitlementContext(for: catalogMovie)
        return HFPlaybackDescriptorAccessRequest(
            movieID: catalogMovie.id,
            profileID: activeProfileID,
            productIdentifier: context.productReference.productIdentifier,
            provider: streamingConfiguration.preferredProvider,
            entitlementRequirement: context.entitlementRequirement,
            backendRequirement: .required
        )
    }

    func entitlementGatedPlaybackDescriptor(for movie: Movie) -> HFPlaybackDescriptorAccessResponse {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let descriptor = playbackDescriptor(for: catalogMovie)
        let context = playbackEntitlementContext(for: catalogMovie)
        let service = HFEntitlementGatedPlaybackDescriptorService(
            streamingConfiguration: streamingConfiguration,
            entitlementConfiguration: entitlementConfiguration
        )
        return service.accessResponse(
            request: playbackDescriptorAccessRequest(for: catalogMovie),
            descriptor: descriptor,
            context: context,
            entitlementRuntimeStatus: entitlementRuntimeStatus
        )
    }

    func cloudflarePlaybackDescriptorState(for movie: Movie) -> HFCloudflarePlaybackDescriptorState {
        entitlementGatedPlaybackDescriptor(for: movie).cloudflareState
    }

    func playbackDescriptorGateStatus(for movie: Movie) -> HFPlaybackDescriptorGateStatus {
        entitlementGatedPlaybackDescriptor(for: movie).gateStatus
    }

    func backendEntitlementValidationRequest(for movie: Movie) -> HFBackendEntitlementValidationRequest {
        backendPlaybackDescriptorContract(for: movie).entitlementValidationRequest
    }

    func backendPlaybackDescriptorRequest(for movie: Movie) -> HFBackendPlaybackDescriptorRequest {
        backendPlaybackDescriptorContract(for: movie).playbackDescriptorRequest
    }

    func backendPlaybackDescriptorContract(for movie: Movie) -> HFBackendPlaybackDescriptorContract {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let context = playbackEntitlementContext(for: catalogMovie)
        let descriptor = playbackDescriptor(for: catalogMovie)
        let hasCompleteContractConfig = backendConfiguration.hasCompleteRuntimeConfig &&
            entitlementConfiguration.hasCompleteRuntimeConfig &&
            streamingConfiguration.hasCompleteRuntimeConfig
        return HFBackendPlaybackDescriptorContract.staged(
            movieID: catalogMovie.id,
            userID: activeProfileID,
            anonymousSessionID: "local-session-\(activeProfileID)",
            context: context,
            descriptorAccessRequest: playbackDescriptorAccessRequest(for: catalogMovie),
            descriptorStatus: descriptor.status,
            entitlementState: serverEntitlementValidationState(for: catalogMovie),
            hasCompleteRuntimeConfig: hasCompleteContractConfig
        )
    }

    func serverEntitlementValidationState(for movie: Movie) -> HFServerEntitlementValidationState {
        guard backendConfiguration.hasCompleteRuntimeConfig,
              entitlementConfiguration.hasCompleteRuntimeConfig else {
            return .pending
        }

        return entitlementRuntimeStatus.accessState == .accessReady || entitlementRuntimeStatus.accessState == .entitlementConfigured ? .approved : .pending
    }

    func playbackDescriptorContractStatus(for movie: Movie) -> String {
        backendPlaybackDescriptorContract(for: movie).statusLabel
    }

    var canRunStagingEntitlementPlaybackCheck: Bool {
        entitlementPlaybackAdapter.canContactStagingEndpoint
    }

    func refreshEntitlementAndPlaybackDescriptor(for movie: Movie) async {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        guard canRunStagingEntitlementPlaybackCheck else {
            let result = HFEntitlementPlaybackResult.localFallback(
                movieID: catalogMovie.id,
                detail: "Staging backend not configured. Local Preview fallback active."
            )
            entitlementPlaybackResult = result
            backendEntitlementRequestState = .notConfigured
            backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
            activeStagingPlaybackDescriptor = nil
            lastPlaybackDescriptorAuditContext = result.auditContext
            return
        }

        backendEntitlementRequestState = .validatingEntitlement
        backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
        activeStagingPlaybackDescriptor = nil

        let entitlementRequest = backendEntitlementValidationRequest(for: catalogMovie)
        let descriptorRequest = backendPlaybackDescriptorRequest(for: catalogMovie)
        let result = await entitlementPlaybackAdapter.validateAndRequestPlaybackDescriptor(
            entitlementRequest: entitlementRequest,
            descriptorRequest: descriptorRequest
        )

        entitlementPlaybackResult = result
        backendEntitlementRequestState = result.entitlementState
        backendPlaybackDescriptorRequestState = result.descriptorState
        lastPlaybackDescriptorAuditContext = result.auditContext

        if let descriptor = result.playbackDescriptor {
            activeStagingPlaybackDescriptor = HFPlaybackDescriptor(
                id: descriptor.id,
                movieID: descriptor.movieID,
                title: catalogMovie.title,
                status: descriptor.status,
                provider: descriptor.provider,
                providerAssetMapping: descriptor.providerAssetMapping,
                detail: descriptor.detail,
                boundary: descriptor.boundary
            )
        } else {
            activeStagingPlaybackDescriptor = nil
        }
    }

    func validateBackendEntitlement(for movie: Movie) async {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        guard canRunStagingEntitlementPlaybackCheck else {
            backendEntitlementRequestState = .notConfigured
            activeStagingPlaybackDescriptor = nil
            return
        }

        backendEntitlementRequestState = .validatingEntitlement
        do {
            let response = try await entitlementPlaybackAdapter.validateEntitlement(
                request: backendEntitlementValidationRequest(for: catalogMovie)
            )
            backendEntitlementRequestState = response.entitlementStatus == .approved ? .entitlementApproved : .entitlementDenied
            lastPlaybackDescriptorAuditContext = HFBackendRequestAuditContext(
                movieID: catalogMovie.id,
                endpointLabel: HFBackendPlaybackDescriptorEndpoint.entitlementValidation.statusLabel,
                state: backendEntitlementRequestState,
                detail: response.detail,
                localFallback: "Local Preview fallback active"
            )
        } catch {
            backendEntitlementRequestState = .localPreviewFallbackActive
            activeStagingPlaybackDescriptor = nil
        }
    }

    func requestBackendPlaybackDescriptor(for movie: Movie) async {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        guard canRunStagingEntitlementPlaybackCheck else {
            backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
            activeStagingPlaybackDescriptor = nil
            return
        }

        backendPlaybackDescriptorRequestState = .requestingPlaybackDescriptor
        do {
            let response = try await entitlementPlaybackAdapter.requestPlaybackDescriptor(
                request: backendPlaybackDescriptorRequest(for: catalogMovie)
            )
            switch response.error {
            case .descriptorExpired:
                backendPlaybackDescriptorRequestState = .playbackDescriptorExpired
                activeStagingPlaybackDescriptor = nil
            case .descriptorRefreshRequired:
                backendPlaybackDescriptorRequestState = .descriptorRefreshRequired
                activeStagingPlaybackDescriptor = nil
            case .entitlementDenied:
                backendPlaybackDescriptorRequestState = .entitlementDenied
                activeStagingPlaybackDescriptor = nil
            case .unavailable:
                backendPlaybackDescriptorRequestState = .playbackDescriptorUnavailable
                activeStagingPlaybackDescriptor = nil
            case .none:
                backendPlaybackDescriptorRequestState = response.playbackDescriptorStatus == .stagingDescriptorReady ? .stagingPlaybackDescriptorReady : .playbackDescriptorUnavailable
            }
            lastPlaybackDescriptorAuditContext = HFBackendRequestAuditContext(
                movieID: catalogMovie.id,
                endpointLabel: HFBackendPlaybackDescriptorEndpoint.playbackDescriptor.statusLabel,
                state: backendPlaybackDescriptorRequestState,
                detail: response.detail,
                localFallback: "Local Preview fallback active"
            )
        } catch {
            backendPlaybackDescriptorRequestState = .playbackDescriptorUnavailable
            activeStagingPlaybackDescriptor = nil
        }
    }

    func clearTransientPlaybackDescriptor() {
        activeStagingPlaybackDescriptor = nil
        entitlementPlaybackResult = nil
        backendEntitlementRequestState = entitlementPlaybackAdapter.runtimeState
        backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
        lastPlaybackDescriptorAuditContext = .localFallback(
            movieID: continueWatchingMovie.id,
            detail: "Transient staging descriptor cleared. Local Preview fallback active."
        )
    }

    func streamingProviderStatus(for movie: Movie) -> HFStreamingProviderStatus {
        streamingProviderStatus(for: playbackDescriptor(for: movie))
    }

    private func streamingProviderStatus(for descriptor: HFPlaybackDescriptor) -> HFStreamingProviderStatus {
        switch descriptor.status {
        case .localPreviewReady:
            return .localPreviewReady
        case .providerDescriptorMissing:
            return HFStreamingProviderStatus(
                status: .providerDescriptorMissing,
                provider: descriptor.provider,
                title: "Streaming Provider",
                detail: "Provider Descriptor Missing. Local preview remains available while backend-mediated playback is configured.",
                systemImage: "network.slash",
                accessibilityIdentifier: "hf.streaming.providerDescriptorMissing"
            )
        case .stagingDescriptorReady:
            return HFStreamingProviderStatus(
                status: .stagingDescriptorReady,
                provider: descriptor.provider,
                title: "Streaming Provider",
                detail: "Staging Descriptor Ready. Backend-mediated playback only; no production streaming claim is made.",
                systemImage: "checkmark.seal.fill",
                accessibilityIdentifier: "hf.streaming.stagingDescriptorReady"
            )
        case .streamingProviderNotConnected:
            return HFStreamingProviderStatus(
                status: .streamingProviderNotConnected,
                provider: descriptor.provider,
                title: "Streaming Provider",
                detail: "Streaming Provider Not Connected Yet. No streaming provider connected.",
                systemImage: "play.slash.fill",
                accessibilityIdentifier: "hf.streaming.notConnected"
            )
        }
    }

    func markStartedWatching(_ movie: Movie) {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        lastPlayerMovieID = catalogMovie.id
        UserDefaults.standard.set(catalogMovie.id, forKey: lastPlayerMovieKey)
    }

    // Cloud Library Service
    // Offline Asset Service
    // Download Queue
    // Download Eligibility
    // Remote Download Provider
    // Local Offline State
    // hf.services.cloudLibrary
    // hf.services.librarySync
    // hf.services.offlineAssetService
    // hf.services.downloadQueue
    // hf.services.downloadEligibility
    // hf.services.offlineProviderReady
    // hf.services.downloadReadiness
    // hf.services.cloudLibraryReadiness
    var cloudLibraryStatus: HFCloudSyncStatus {
        .cloudReady
    }

    var librarySyncMode: String {
        "Cloud Library Service local ready. Cloud sync Not Connected Yet."
    }

    var offlineAssetServiceMode: String {
        "Offline Asset Service local ready"
    }

    var offlineProviderStatus: String {
        "Remote Download Provider Not Connected Yet"
    }

    var libraryReadinessRows: [String] {
        [
            "Saved list - Local",
            "Active profile - \(activeViewingProfile.displayName)",
            "Catalog identity - Active",
            "Cloud sync - Not Connected Yet",
            "Account service - Local profile",
            "Conflict resolution - Future"
        ]
    }

    var cloudLibraryProofRows: [String] {
        [
            "Cloud Library Service - Local Ready",
            "Saved List Sync - Not Connected Yet",
            "Active profile boundary - Ready",
            "Catalog identity - Active"
        ]
    }

    var downloadReadinessRows: [String] {
        let sourceStatus = playbackSource(for: continueWatchingMovie).status == .playableLocal ? "Active" : "Source required"
        return [
            "Local offline state - Active",
            "Catalog identity - Active",
            "Player source - \(sourceStatus)",
            "Remote download provider - Not Connected Yet",
            "Background downloads - Not Connected Yet",
            "Media storage - Not Created Yet"
        ]
    }

    var downloadArchitectureProofRows: [String] {
        [
            "Offline Asset Service - Local Ready",
            "Download Queue - Local State",
            "Download Eligibility - Source aware",
            "Remote Download Provider - Not Connected Yet"
        ]
    }

    var offlineAssetRecords: [HFOfflineAssetRecord] {
        downloadedMovies.map { movie in
            let eligibility = offlineEligibility(for: movie)
            return HFOfflineAssetRecord(
                id: "offline-\(movie.id)",
                movieID: movie.id,
                title: movie.title,
                status: "Local Offline State",
                detail: eligibility.reason,
                updatedAtLabel: "Local state"
            )
        }
    }

    var downloadQueueItems: [HFDownloadQueueItem] {
        downloadedMovies.map { movie in
            let eligibility = offlineEligibility(for: movie)
            return HFDownloadQueueItem(
                id: "queue-\(movie.id)",
                movieID: movie.id,
                title: movie.title,
                status: eligibility.statusLabel,
                reason: eligibility.reason
            )
        }
    }

    func offlineEligibility(for movie: Movie) -> (status: HFOfflineAssetStatus, statusLabel: String, reason: String) {
        let source = playbackSource(for: movie)
        if source.status == .playableLocal {
            return (.eligible, "Eligible", "Local playback source is active.")
        }
        if isDownloaded(movie) {
            return (.localStateOnly, "Local Offline State", "Media source required before real download.")
        }
        return (.sourceRequired, "Source Required", "Media source required before real download.")
    }

    func downloadEligibility(for movie: Movie) -> HFDownloadEligibilityResult {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        return makeDownloadEligibilityService(
            streamingStatus: playbackDescriptor(for: catalogMovie).status,
            entitlementStatus: entitlementRuntimeStatus.accessState
        )
        .eligibility(
            titleID: catalogMovie.id,
            title: catalogMovie.title,
            isInLocalOfflineShelf: isDownloaded(catalogMovie)
        )
    }

    func queueOfflineAsset(for movie: Movie) {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        downloadedMovieIDs.insert(catalogMovie.id)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
    }

    func removeOfflineAsset(for movie: Movie) {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        downloadedMovieIDs.remove(catalogMovie.id)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
    }

    func offlineAssetRecord(for movie: Movie) -> HFOfflineAssetRecord {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let eligibility = offlineEligibility(for: catalogMovie)
        return HFOfflineAssetRecord(
            id: "offline-\(catalogMovie.id)",
            movieID: catalogMovie.id,
            title: catalogMovie.title,
            status: isDownloaded(catalogMovie) ? "Local Offline State" : eligibility.statusLabel,
            detail: eligibility.reason,
            updatedAtLabel: "Local state"
        )
    }

    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = localProfiles.firstIndex(where: { $0.id == activeProfileID }) else { return }
        localProfiles[index].displayName = trimmed
        UserDefaults.standard.set(trimmed, forKey: profileDisplayNamePrefix + activeProfileID)
        refreshAuthRuntimeStatus()
    }

    func selectProfile(_ profile: HFLocalViewingProfile) {
        guard localProfiles.contains(where: { $0.id == profile.id }) else { return }
        persist(savedMovieIDs, key: scopedSavedKey)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
        activeProfileID = profile.id
        UserDefaults.standard.set(activeProfileID, forKey: activeProfileKey)
        savedMovieIDs = Self.loadProfileIDs(
            defaults: .standard,
            scopedKey: scopedSavedKey,
            fallbackKey: savedKey,
            fallbackIDs: Set(["friendly", "paranormall-s1"])
        )
        downloadedMovieIDs = Self.loadProfileIDs(
            defaults: .standard,
            scopedKey: scopedDownloadsKey,
            fallbackKey: downloadsKey,
            fallbackIDs: Set(HFMockData.movies.filter(\.isDownloaded).map(\.id))
        )
        refreshAuthRuntimeStatus()
    }

    // hf.services.unifiedStore
    // hf.services.movieCatalog
    var featuredMovie: Movie {
        movie(id: "friendly") ?? allCatalogMovies[0]
    }

    var continueWatchingMovie: Movie {
        if let lastPlayerMovieID, let movie = movie(id: lastPlayerMovieID) {
            return movie
        }
        return allCatalogMovies.first { $0.progress != nil } ?? featuredMovie
    }

    var savedMovies: [Movie] {
        allCatalogMovies.filter { isSaved($0) }
    }

    // hf.services.downloadState
    var downloadedMovies: [Movie] {
        allCatalogMovies.filter { isDownloaded($0) }
    }

    var libraryContinueWatchingMovies: [Movie] {
        var ordered = allCatalogMovies.filter { movie in
            guard let progress = movie.progress else { return false }
            return progress > 0 && progress < 0.95
        }
        if let lastPlayerMovieID, let last = movie(id: lastPlayerMovieID), ordered.contains(where: { $0.id == last.id }) {
            ordered.removeAll { $0.id == last.id }
            ordered.insert(last, at: 0)
        }
        return ordered
    }

    var libraryCompletedMovies: [Movie] {
        allCatalogMovies.filter { ($0.progress ?? 0) >= 0.95 }
    }

    var libraryWatchLaterMovies: [Movie] {
        savedMovies.filter { $0.progress == nil }
    }

    var libraryFavoriteMovies: [Movie] {
        savedMovies.filter { movie in
            movie.isOriginal || movie.genres.contains("Drama") || movie.genres.contains("Crime")
        }
    }

    var libraryLastViewedMovie: Movie {
        continueWatchingMovie
    }

    var libraryNextEpisode: HFLibraryNextEpisode? {
        guard let series = allCatalogMovies.first(where: { $0.duration.localizedCaseInsensitiveContains("episode") || $0.genres.contains("Series") }) else {
            return nil
        }
        let watchedIndex = max(1, Int(((series.progress ?? 0.14) * 7).rounded(.up)))
        let nextIndex = min(7, watchedIndex + 1)
        return HFLibraryNextEpisode(
            id: "\(series.id)-next-\(nextIndex)",
            series: series,
            title: "Episode \(nextIndex)",
            detail: "Next episode in \(series.title)"
        )
    }

    var libraryViewingHistory: [HFLibraryActivityRecord] {
        var records: [HFLibraryActivityRecord] = []
        records.append(
            HFLibraryActivityRecord(
                id: "history-last-\(libraryLastViewedMovie.id)",
                movie: libraryLastViewedMovie,
                status: "Last Viewed",
                detail: "Most recent local playback route",
                progress: libraryLastViewedMovie.progress
            )
        )
        records += libraryContinueWatchingMovies.map { movie in
            HFLibraryActivityRecord(
                id: "history-progress-\(movie.id)",
                movie: movie,
                status: "In Progress",
                detail: "\(Int((movie.progress ?? 0) * 100))% watched locally",
                progress: movie.progress
            )
        }
        records += libraryCompletedMovies.map { movie in
            HFLibraryActivityRecord(
                id: "history-complete-\(movie.id)",
                movie: movie,
                status: "Completed",
                detail: "Completed in local viewing history",
                progress: movie.progress
            )
        }
        var seen = Set<String>()
        return records.filter { seen.insert($0.id).inserted }
    }

    var libraryUserCollections: [HFLibraryCollection] {
        [
            HFLibraryCollection(id: "favorites", title: "Favorites", detail: "Pinned from saved original titles", movies: libraryFavoriteMovies, systemImage: "star.fill"),
            HFLibraryCollection(id: "watch-later", title: "Watch Later", detail: "Saved titles without progress", movies: libraryWatchLaterMovies, systemImage: "bookmark.fill"),
            HFLibraryCollection(id: "documentaries", title: "Documentaries", detail: "Documentary titles in your local library", movies: allCatalogMovies.filter { $0.genres.contains("Documentary") }, systemImage: "doc.richtext.fill"),
            HFLibraryCollection(id: "crime", title: "Crime", detail: "Crime stories saved or recommended", movies: allCatalogMovies.filter { $0.genres.contains("Crime") }, systemImage: "eye.fill"),
            HFLibraryCollection(id: "creator-collections", title: "Creator Collections", detail: "Creator-led titles connected to profiles", movies: creatorProfiles.flatMap(\.filmography).reduce(into: [Movie]()) { result, movie in
                if !result.contains(where: { $0.id == movie.id }) { result.append(movie) }
            }, systemImage: "person.crop.rectangle.stack.fill"),
            HFLibraryCollection(id: "premieres", title: "Premieres", detail: "Premiere and scheduled local titles", movies: allCatalogMovies.filter { $0.isComingSoon || $0.genres.contains("Premiere") }, systemImage: "theatermasks.fill"),
            HFLibraryCollection(id: "available-offline", title: "Available Offline", detail: "Local offline preview shelf", movies: downloadedMovies, systemImage: "arrow.down.circle.fill")
        ].filter { !$0.movies.isEmpty }
    }

    var libraryIntelligenceSignals: [HFLibraryIntelligenceSignal] {
        [
            HFLibraryIntelligenceSignal(id: "continue", title: "Continue Watching", detail: "Feeds local recommendations and home rails", value: "\(libraryContinueWatchingMovies.count)", systemImage: "play.circle.fill"),
            HFLibraryIntelligenceSignal(id: "recommendations", title: "Recommendations", detail: "Based on \(libraryLastViewedMovie.title)", value: "\(relatedMovies(for: libraryLastViewedMovie).count)", systemImage: "sparkle.magnifyingglass"),
            HFLibraryIntelligenceSignal(id: "collections", title: "Collections", detail: "Favorites, documentaries, crime, premieres, creator collections", value: "\(libraryUserCollections.count)", systemImage: "rectangle.stack.fill"),
            HFLibraryIntelligenceSignal(id: "offline", title: "Downloads Integration", detail: "Local offline preview state only", value: "\(downloadedMovies.count)", systemImage: "arrow.down.circle.fill")
        ]
    }

    var analyticsTitleRecords: [HFTitleAnalyticsRecord] {
        allCatalogMovies
            .map(analyticsRecord)
            .sorted { lhs, rhs in
                if lhs.totalViews == rhs.totalViews {
                    return lhs.completionRate > rhs.completionRate
                }
                return lhs.totalViews > rhs.totalViews
            }
    }

    var analyticsViewerMetrics: [HFAnalyticsMetric] {
        let titleRecords = analyticsTitleRecords
        let totalViews = titleRecords.reduce(0) { $0 + $1.totalViews }
        let totalWatchMinutes = titleRecords.reduce(0) { partial, record in
            partial + analyticsMinutes(from: record.averageWatchTime) * max(1, record.totalViews / 18)
        }
        let averageCompletion = titleRecords.isEmpty ? 0 : titleRecords.reduce(0) { $0 + $1.completionRate } / titleRecords.count
        let progressCount = allCatalogMovies.filter { $0.progress != nil }.count
        let resumeRate = progressCount == 0 ? 0 : Int((Double(libraryContinueWatchingMovies.count) / Double(progressCount)) * 100)
        let dropOffCount = libraryContinueWatchingMovies.filter { movie in
            let progress = movie.progress ?? 0
            return progress >= 0.25 && progress <= 0.72
        }.count

        return [
            HFAnalyticsMetric(id: "views", title: "Views", value: "\(totalViews)", detail: "Local catalog view estimate", systemImage: "play.tv.fill"),
            HFAnalyticsMetric(id: "unique-viewers", title: "Unique Viewers", value: "\(localProfiles.count)", detail: "Local profile count", systemImage: "person.2.fill"),
            HFAnalyticsMetric(id: "watch-time", title: "Watch Time", value: "\(max(1, totalWatchMinutes / 60))h", detail: "Computed from local progress", systemImage: "clock.fill"),
            HFAnalyticsMetric(id: "completion-rate", title: "Completion Rate", value: "\(averageCompletion)%", detail: "Average local title completion", systemImage: "checkmark.circle.fill"),
            HFAnalyticsMetric(id: "resume-rate", title: "Resume Rate", value: "\(resumeRate)%", detail: "In-progress titles with resume state", systemImage: "arrow.clockwise.circle.fill"),
            HFAnalyticsMetric(id: "drop-off-points", title: "Drop-off Points", value: "\(dropOffCount)", detail: "Mid-session local drop-off markers", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
        ]
    }

    var analyticsDiscoveryRecords: [HFDiscoveryAnalyticsRecord] {
        [
            HFDiscoveryAnalyticsRecord(id: "searches", title: "Searches", value: "\(recentSearches.count)", detail: "Recent local search terms", systemImage: "magnifyingglass"),
            HFDiscoveryAnalyticsRecord(id: "search-clicks", title: "Search Clicks", value: "\(searchMovies(query: recentSearches.first ?? featuredMovie.title, filter: "All").count)", detail: "Matching local result taps proxy", systemImage: "cursorarrow.click.2"),
            HFDiscoveryAnalyticsRecord(id: "collection-opens", title: "Collection Opens", value: "\(discoveryCollections.count + libraryUserCollections.count)", detail: "Discovery and Library collection surfaces", systemImage: "rectangle.stack.fill"),
            HFDiscoveryAnalyticsRecord(id: "recommendation-clicks", title: "Recommendation Clicks", value: "\(relatedMovies(for: libraryLastViewedMovie).count)", detail: "Because-you-watched local signal", systemImage: "sparkles"),
            HFDiscoveryAnalyticsRecord(id: "trending-signals", title: "Trending Signals", value: "\(discoveryCollections.first { $0.id == "trending" }?.movies.count ?? 0)", detail: "Trending rail titles", systemImage: "chart.line.uptrend.xyaxis")
        ]
    }

    var analyticsCreatorRecords: [HFCreatorAnalyticsRecord] {
        creatorProfiles.map { profile in
            let titleIDs = Set(profile.filmography.map(\.id))
            let records = analyticsTitleRecords.filter { titleIDs.contains($0.movie.id) }
            let views = records.reduce(0) { $0 + $1.totalViews }
            let watchMinutes = records.reduce(0) { $0 + analyticsMinutes(from: $1.averageWatchTime) * max(1, $1.totalViews / 20) }
            let topContent = records.first?.movie.title ?? profile.featuredProject?.title ?? "Local slate"
            let followers = 120 + analyticsSeed(profile.id) % 880
            let growth = "+\(8 + analyticsSeed(profile.creator.name) % 34)%"
            return HFCreatorAnalyticsRecord(
                id: profile.id,
                creatorName: profile.creator.name,
                publishedTitles: profile.publishedTitles.count,
                views: views,
                watchTime: "\(max(1, watchMinutes / 60))h",
                followers: followers,
                growthTrend: growth,
                topContent: topContent
            )
        }
        .sorted { $0.views > $1.views }
    }

    var analyticsInsights: [HFAnalyticsInsight] {
        let records = analyticsTitleRecords
        let mostWatched = records.first
        let fastestGrowing = records.sorted { lhs, rhs in
            analyticsSeed(lhs.movie.id + "growth") > analyticsSeed(rhs.movie.id + "growth")
        }.first
        let mostSaved = records.sorted { $0.libraryAdds > $1.libraryAdds }.first
        let highestCompletion = records.sorted { $0.completionRate > $1.completionRate }.first

        return [
            HFAnalyticsInsight(id: "most-watched", title: "Most Watched This Week", detail: mostWatched?.movie.title ?? "Local catalog", value: "\(mostWatched?.totalViews ?? 0)", systemImage: "play.fill"),
            HFAnalyticsInsight(id: "fastest-growing", title: "Fastest Growing Title", detail: fastestGrowing?.movie.title ?? "Local catalog", value: "+\(8 + analyticsSeed(fastestGrowing?.movie.id ?? "local") % 38)%", systemImage: "chart.line.uptrend.xyaxis"),
            HFAnalyticsInsight(id: "most-saved", title: "Most Saved Title", detail: mostSaved?.movie.title ?? "Local catalog", value: "\(mostSaved?.libraryAdds ?? 0)", systemImage: "bookmark.fill"),
            HFAnalyticsInsight(id: "highest-completion", title: "Highest Completion Rate", detail: highestCompletion?.movie.title ?? "Local catalog", value: "\(highestCompletion?.completionRate ?? 0)%", systemImage: "checkmark.seal.fill")
        ]
    }

    private func analyticsRecord(for movie: Movie) -> HFTitleAnalyticsRecord {
        let seed = analyticsSeed(movie.id)
        let isCreatorPublished = creatorPublishedMovies.contains { $0.id == movie.id }
        let localProgress = movie.progress ?? (movie.isComingSoon ? 0 : Double(42 + seed % 45) / 100.0)
        let completion = movie.isComingSoon ? 0 : min(98, max(12, Int(localProgress * 100)))
        let runtimeMinutes = analyticsRuntimeMinutes(for: movie)
        let averageMinutes = movie.isComingSoon ? 0 : max(4, Int(Double(runtimeMinutes) * Double(completion) / 100.0))
        let recentSearchBoost = recentSearches.contains { query in
            movie.title.localizedCaseInsensitiveContains(query) || query.localizedCaseInsensitiveContains(movie.title)
        } ? 30 : 0
        let viewBase = 42 + seed % 520
        let viewBoost = (isSaved(movie) ? 54 : 0) + (isDownloaded(movie) ? 22 : 0) + (isCreatorPublished ? 86 : 0) + recentSearchBoost
        let libraryAdds = isSaved(movie) ? 18 + seed % 46 : seed % 12
        let favorites = libraryFavoriteMovies.contains { $0.id == movie.id } ? 10 + seed % 26 : seed % 6

        return HFTitleAnalyticsRecord(
            id: movie.id,
            movie: movie,
            totalViews: viewBase + viewBoost,
            averageWatchTime: "\(averageMinutes)m",
            completionRate: completion,
            libraryAdds: libraryAdds,
            favorites: favorites,
            sharesPlaceholder: seed % 18
        )
    }

    private func analyticsRuntimeMinutes(for movie: Movie) -> Int {
        let number = movie.duration.split(separator: " ").compactMap { Int($0) }.first
        return max(12, number ?? (movie.duration.localizedCaseInsensitiveContains("episode") ? 44 : 96))
    }

    private func analyticsMinutes(from label: String) -> Int {
        Int(label.filter(\.isNumber)) ?? 0
    }

    private func analyticsSeed(_ key: String) -> Int {
        key.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    }

    // hf.services.libraryState
    func movie(id: String) -> Movie? {
        allCatalogMovies.first { $0.id == id }
    }

    func movie(for id: String) -> Movie? {
        movie(id: id)
    }

    func relatedMovies(for movie: Movie) -> [Movie] {
        let genreMatches = allCatalogMovies.filter { candidate in
            candidate.id != movie.id &&
            !Set(candidate.genres).isDisjoint(with: Set(movie.genres))
        }
        let creatorMatches = allCatalogMovies.filter { $0.id != movie.id && $0.creatorName == movie.creatorName }
        let fallback = premiumHomeCatalogRails.first { $0.id == "recommended" }?.movies ?? []
        var seen = Set<String>()
        return (genreMatches + creatorMatches + fallback).filter { seen.insert($0.id).inserted }.prefix(8).map { $0 }
    }

    func creatorProfile(for creator: Creator) -> HFCreatorProfile {
        let publishingRecords = creatorPublishingContents.filter { $0.creator == creator.name }
        let published = publishingRecords.filter { $0.releaseState == .published }.map(\.movie)
        let scheduled = publishingRecords.filter { $0.releaseState == .scheduled }.map(\.movie)
        let archived = publishingRecords.filter { $0.releaseState == .archived }.map(\.movie)
        let catalogTitles = allCatalogMovies.filter { movie in
            movie.creatorName == creator.name || creator.featuredMovieIDs.contains(movie.id)
        }
        let filmography = uniqueMovies(catalogTitles + published + scheduled + archived)
        let featured = creator.featuredMovieIDs.compactMap(movie(id:)).first ?? filmography.first
        let latest = published.first ?? filmography.first
        return HFCreatorProfile(
            creator: creator,
            bio: creatorBio(for: creator),
            bannerTitle: "\(creator.name) Spotlight",
            avatarSymbol: creatorAvatarSymbol(for: creator),
            filmography: filmography,
            publishedTitles: uniqueMovies(published + catalogTitles.filter { !$0.isComingSoon }),
            scheduledTitles: uniqueMovies(scheduled + catalogTitles.filter(\.isComingSoon)),
            archivedTitles: archived,
            collections: creatorCollections(for: creator, filmography: filmography, records: publishingRecords),
            featuredProject: featured,
            latestRelease: latest
        )
    }

    func searchCreatorProfiles(query: String) -> [HFCreatorProfile] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            return Array(creatorProfiles.prefix(6))
        }
        return creatorProfiles
            .map { profile in (profile, creatorSearchScore(for: profile, term: term)) }
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.creator.name < rhs.0.creator.name
                }
                return lhs.1 > rhs.1
            }
            .map(\.0)
    }

    var discoveryCollections: [Category] {
        compactCategories([
            Category(id: "featured", title: "Featured", subtitle: "High-signal local picks for the first watch decision", movies: [featuredMovie]),
            Category(id: "trending", title: "Trending", subtitle: "Local momentum from the HighFive catalog", movies: moviesByIDs(["friendly", "paranormall-s1", "black-turnip", "big-loss", "artist-development", "bleu-velvet"])),
            Category(id: "new-releases", title: "New Releases", subtitle: "Fresh and recently staged local catalog titles", movies: newThisWeekCatalog),
            Category(id: "highfive-originals", title: "HighFive Originals", subtitle: "Original films, series, creator cuts, and local premieres", movies: originalsCatalog.filter { !$0.isComingSoon }),
            Category(id: "creator-published", title: "Creator Published", subtitle: "Titles promoted from the Creator Publishing Pipeline", movies: creatorPublishedMovies),
            Category(id: "award-winners", title: "Award Winners", subtitle: "Prestige-style local programming for editorial rails", movies: moviesByIDs(["friendly", "artist-development", "behind-vision", "black-turnip", "sunshine"])),
            Category(id: "premieres", title: "Premieres", subtitle: "Premiere-ready and coming-soon worlds", movies: allCatalogMovies.filter { $0.isComingSoon || $0.genres.contains("Premiere") })
        ])
    }

    func recommendationCollections(anchor movie: Movie? = nil) -> [Category] {
        let selected = movie ?? continueWatchingMovie
        return compactCategories([
            Category(id: "because-you-watched", title: "Because You Watched \(selected.title)", subtitle: "Genre, tone, and creator-adjacent local picks", movies: relatedMovies(for: selected)),
            Category(id: "similar-titles", title: "Similar Titles", subtitle: selected.genres.prefix(2).joined(separator: " + "), movies: similarTitles(to: selected)),
            Category(id: "same-creator", title: "From \(selected.creatorName)", subtitle: "More local titles from the same creator", movies: fromSameCreator(as: selected)),
            Category(id: "continue-watching", title: "Continue Watching", subtitle: "Resume local progress", movies: allCatalogMovies.filter { $0.progress != nil })
        ])
    }

    var collectionSystem: [Category] {
        compactCategories([
            collectionCategory(id: "horror", title: "Horror", genre: "Horror"),
            collectionCategory(id: "documentary", title: "Documentary", genre: "Documentary"),
            collectionCategory(id: "western", title: "Western", genre: "Western"),
            collectionCategory(id: "crime", title: "Crime", genre: "Crime"),
            collectionCategory(id: "drama", title: "Drama", genre: "Drama"),
            Category(id: "premiere-collection", title: "Premieres", subtitle: "Scheduled and coming-soon local titles", movies: allCatalogMovies.filter { movie in
                movie.isComingSoon || searchableTags(for: movie).contains { $0.localizedCaseInsensitiveContains("Premiere") }
            }),
            Category(id: "creator-collections", title: "Creator Collections", subtitle: "Creator-led discovery paths", movies: creatorCollectionMovies)
        ])
    }

    func searchMovies(query: String, filter: String) -> [Movie] {
        let base: [Movie]
        switch filter {
        case "Movies":
            base = allCatalogMovies.filter { !$0.duration.localizedCaseInsensitiveContains("episode") }
        case "Series":
            base = allCatalogMovies.filter { $0.duration.localizedCaseInsensitiveContains("episode") || $0.genres.contains("Series") }
        case "Originals":
            base = originalsCatalog
        case "Creator Published":
            base = creatorPublishedMovies
        case "Downloaded":
            base = downloadedMovies
        default:
            base = allCatalogMovies
        }

        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else {
            return Array(base.prefix(8))
        }

        return base
            .map { movie in (movie, searchScore(for: movie, term: searchTerm)) }
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.title < rhs.0.title
                }
                return lhs.1 > rhs.1
            }
            .map(\.0)
    }

    func catalogRails(filter: String = "All") -> [Category] {
        let rails = discoveryCollections + recommendationCollections() + collectionSystem

        switch filter {
        case "Originals":
            return rails.filter { $0.id == "highfive-originals" }
        case "Creator Published":
            return rails.filter { $0.id == "creator-published" }
        case "Premieres":
            return rails.filter { $0.id == "premieres" || $0.id == "premiere-collection" }
        case "Award Winners":
            return rails.filter { $0.id == "award-winners" }
        case "Drama", "Thriller", "Mystery", "Documentary", "Horror", "Western", "Crime":
            return [collectionCategory(id: filter.lowercased(), title: "\(filter) Picks", genre: filter)]
        case "Coming Soon":
            return [Category(id: "coming-soon", title: "Coming Soon", subtitle: "Scripted originals in development", movies: allCatalogMovies.filter { $0.isComingSoon })]
        default:
            return rails
        }
    }

    private var creatorCollectionMovies: [Movie] {
        var seen = Set<String>()
        let creatorLed = allCatalogMovies.filter { movie in
            movie.isOriginal || !fromSameCreator(as: movie).isEmpty || !searchableTags(for: movie).isEmpty
        }
        return creatorLed.filter { seen.insert($0.id).inserted }
    }

    private var cmsEpisodeRecords: [HFCMSContentRecord] {
        guard let series = movie(id: "paranormall-s1") else { return [] }
        return (1...7).map { episode in
            HFCMSContentRecord(
                id: "paranormall-s1-e\(episode)",
                title: "Paranormall Episode \(episode)",
                type: .episode,
                description: "Episode \(episode) metadata placeholder attached to Paranormall Season 1.",
                creatorName: series.creatorName,
                genre: "Horror",
                tags: ["Episode", "Series", "Mystery"],
                runtime: "Episode",
                rating: series.rating,
                artworkStatus: .ready,
                trailerStatus: .placeholder,
                releaseState: .published,
                collectionIDs: cmsCollectionIDs(for: series),
                seriesID: series.id,
                relatedTitleIDs: relatedMovies(for: series).map(\.id)
            )
        }
    }

    private func cmsRecord(for movie: Movie) -> HFCMSContentRecord {
        let project = creatorPublishingContents.first { $0.id == movie.id }
        return HFCMSContentRecord(
            id: "cms-title-\(movie.id)",
            title: movie.title,
            type: movie.duration.localizedCaseInsensitiveContains("episode") || movie.genres.contains("Series") ? .series : .movie,
            description: movie.synopsis,
            creatorName: movie.creatorName,
            genre: movie.genres.first ?? "Cinema",
            tags: searchableTags(for: movie) + movie.genres,
            runtime: movie.duration,
            rating: movie.rating,
            artworkStatus: project?.artworkStatus ?? (movie.posterAssetName == nil ? .placeholder : .ready),
            trailerStatus: project?.trailerStatus ?? (movie.isComingSoon ? .placeholder : .ready),
            releaseState: project?.releaseState ?? (movie.isComingSoon ? .scheduled : .published),
            collectionIDs: cmsCollectionIDs(for: movie),
            seriesID: movie.duration.localizedCaseInsensitiveContains("episode") || movie.genres.contains("Series") ? movie.id : nil,
            relatedTitleIDs: relatedMovies(for: movie).map(\.id)
        )
    }

    private func cmsCollectionIDs(for movie: Movie) -> [String] {
        (discoveryCollections + collectionSystem)
            .filter { category in category.movies.contains { $0.id == movie.id } }
            .map(\.id)
    }

    private func uniqueMovies(_ movies: [Movie]) -> [Movie] {
        var seen = Set<String>()
        return movies.filter { seen.insert($0.id).inserted }
    }

    private func creatorBio(for creator: Creator) -> String {
        switch creator.name {
        case "HigherKey Inc.":
            return "A HighFive studio identity for crime, drama, music, and creator-led releases built around strong local catalog momentum."
        case "HighFive Cinema":
            return "The flagship originals label behind paranormal worlds, creator cuts, and premium streaming stories inside the HighFive catalog."
        case "In The Light Productions":
            return "A production partner focused on mystery, thriller, and premiere-ready stories with a cinematic independent voice."
        default:
            return "A HighFive creator profile generated from local publishing and catalog records."
        }
    }

    private func creatorAvatarSymbol(for creator: Creator) -> String {
        switch creator.role {
        case "Studio": return "building.columns.fill"
        case "Originals": return "sparkles.tv.fill"
        case "Production Partner": return "camera.aperture"
        default: return "person.crop.rectangle.stack.fill"
        }
    }

    private func creatorCollections(for creator: Creator, filmography: [Movie], records: [HFCreatorPublishingContent]) -> [Category] {
        let commentary = filmography.filter { movie in
            movie.title.localizedCaseInsensitiveContains("Commentary")
                || searchableTags(for: movie).contains { $0.localizedCaseInsensitiveContains("Commentary") }
        }
        return compactCategories([
            Category(id: "\(creator.id)-documentaries", title: "Documentaries", subtitle: "Documentary work from \(creator.name)", movies: filmography.filter { $0.genres.contains("Documentary") }),
            Category(id: "\(creator.id)-crime", title: "Crime Stories", subtitle: "Crime and thriller titles from the creator catalog", movies: filmography.filter { movie in
                movie.genres.contains("Crime") || movie.genres.contains("Thriller")
            }),
            Category(id: "\(creator.id)-commentary", title: "Creator Commentary", subtitle: "Commentary and creator-led releases", movies: commentary),
            Category(id: "\(creator.id)-premieres", title: "Premieres", subtitle: "Scheduled and premiere-ready projects", movies: filmography.filter { movie in
                movie.isComingSoon
                    || movie.genres.contains("Premiere")
                    || records.contains { $0.id == movie.id && $0.releaseState == .scheduled }
            })
        ])
    }

    private func creatorSearchScore(for profile: HFCreatorProfile, term: String) -> Int {
        let fields: [(String, Int)] = [
            (profile.creator.name, 140),
            (profile.creator.role, 70),
            (profile.bio, 48),
            (profile.filmography.map(\.title).joined(separator: " "), 92),
            (profile.filmography.flatMap(\.genres).joined(separator: " "), 58),
            (profile.collections.map(\.title).joined(separator: " "), 52)
        ]
        return fields.reduce(0) { partial, field in
            if field.0.localizedCaseInsensitiveCompare(term) == .orderedSame {
                return partial + field.1 + 35
            }
            if field.0.localizedCaseInsensitiveContains(term) {
                return partial + field.1
            }
            return partial
        }
    }

    private func moviesByIDs(_ ids: [String]) -> [Movie] {
        ids.compactMap(movie(id:))
    }

    private func compactCategories(_ categories: [Category]) -> [Category] {
        categories.filter { !$0.movies.isEmpty }
    }

    private func collectionCategory(id: String, title: String, genre: String) -> Category {
        Category(
            id: id,
            title: title,
            subtitle: "\(genre) collection from the local catalog",
            movies: allCatalogMovies.filter { movie in
                movie.genres.contains { $0.localizedCaseInsensitiveCompare(genre) == .orderedSame }
            }
        )
    }

    private func similarTitles(to movie: Movie) -> [Movie] {
        let anchorGenres = Set(movie.genres)
        return allCatalogMovies
            .filter { candidate in
                candidate.id != movie.id && !anchorGenres.isDisjoint(with: Set(candidate.genres))
            }
            .prefix(10)
            .map { $0 }
    }

    private func fromSameCreator(as movie: Movie) -> [Movie] {
        allCatalogMovies
            .filter { $0.id != movie.id && $0.creatorName == movie.creatorName }
            .prefix(10)
            .map { $0 }
    }

    private func searchableTags(for movie: Movie) -> [String] {
        creatorPublishingContents.first { $0.id == movie.id }?.tags ?? []
    }

    private func collectionNames(for movie: Movie) -> [String] {
        (discoveryCollections + collectionSystem)
            .filter { category in category.movies.contains { $0.id == movie.id } }
            .flatMap { [$0.title, $0.subtitle ?? ""] }
    }

    private func searchScore(for movie: Movie, term: String) -> Int {
        let normalized = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return 0 }

        let fields: [(String, Int)] = [
            (movie.title, 120),
            (movie.subtitle, 55),
            (movie.creatorName, 70),
            (movie.genres.joined(separator: " "), 60),
            (searchableTags(for: movie).joined(separator: " "), 65),
            (collectionNames(for: movie).joined(separator: " "), 50),
            (movie.synopsis, 28),
            (movie.duration, 12),
            (movie.year, 8)
        ]

        return fields.reduce(0) { partial, field in
            let value = field.0
            let weight = field.1
            if value.localizedCaseInsensitiveCompare(normalized) == .orderedSame {
                return partial + weight + 40
            }
            if value.localizedCaseInsensitiveContains(normalized) {
                return partial + weight
            }
            return partial
        }
    }

    func isSaved(_ movie: Movie) -> Bool {
        savedMovieIDs.contains(movie.id)
    }

    func toggleSaved(_ movie: Movie) {
        if savedMovieIDs.contains(movie.id) {
            savedMovieIDs.remove(movie.id)
        } else {
            savedMovieIDs.insert(movie.id)
        }
        persist(savedMovieIDs, key: scopedSavedKey)
    }

    func isDownloaded(_ movie: Movie) -> Bool {
        downloadedMovieIDs.contains(movie.id)
    }

    func toggleDownload(_ movie: Movie) {
        if downloadedMovieIDs.contains(movie.id) {
            removeOfflineAsset(for: movie)
        } else {
            queueOfflineAsset(for: movie)
        }
    }

    func removeAllDownloads() {
        downloadedMovieIDs.removeAll()
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(6))
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    // Communication Service
    // Local Communication Adapter
    // Remote Communication Provider
    // Local-to-Remote Adapter
    // Moderation Readiness
    // Local Audience Updates
    // hf.services.communication
    // hf.services.localCommunicationAdapter
    // hf.services.remoteCommunicationProviderReady
    // hf.services.communicationReadiness
    // hf.services.communicationModeration
    // hf.services.localToRemoteCommunicationAdapter
    // hf.services.audienceChannels
    var communicationServiceMode: String {
        "Local Communication Adapter Active"
    }

    var communicationProviderStatus: HFCommunicationProviderStatus {
        .remoteProviderNotConnected
    }

    var audienceChannels: [HFAudienceChannel] {
        [
            HFAudienceChannel(id: "premiere-updates", title: "Premiere Updates", purpose: "Prepare release-window notes around the featured catalog title.", status: "Local", systemImage: "sparkles.tv.fill"),
            HFAudienceChannel(id: "creator-notes", title: "Creator Notes", purpose: "Shape creator context before future delivery.", status: "Local", systemImage: "note.text"),
            HFAudienceChannel(id: "audience-prompts", title: "Audience Prompts", purpose: "Draft watch-night prompts without live replies.", status: "Preview", systemImage: "questionmark.bubble.fill"),
            HFAudienceChannel(id: "release-reminders", title: "Release Reminders", purpose: "Prepare reminder copy while remote alerts stay disconnected.", status: "Draft", systemImage: "calendar.badge.clock")
        ]
    }

    var localAudienceUpdates: [HFAudienceUpdateRecord] {
        localConnectUpdates.enumerated().map { offset, update in
            let channel = audienceChannels[offset % audienceChannels.count]
            return HFAudienceUpdateRecord(
                id: "local-update-\(offset)",
                channelID: channel.id,
                movieID: featuredMovie.id,
                authorProfileID: activeViewingProfile.id,
                body: update,
                status: offset == 0 ? HFCommunicationUpdateStatus.preview.rawValue : HFCommunicationUpdateStatus.notSent.rawValue,
                safetyLabel: "Local review",
                updatedAtLabel: "Local draft"
            )
        }
    }

    var communicationReadinessRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "local-adapter", title: "Local Communication Adapter", detail: "Audience updates remain local.", status: "Active", systemImage: "point.3.connected.trianglepath.dotted"),
            HFCommunicationReadinessRow(id: "channels", title: "Audience Channels", detail: "Premiere Updates, Creator Notes, Audience Prompts, and Release Reminders.", status: "Local", systemImage: "rectangle.stack.fill"),
            HFCommunicationReadinessRow(id: "drafts", title: "Update Drafts", detail: "Draft, Preview, Ready, and Not Sent states are local.", status: "Local", systemImage: "text.bubble.fill"),
            HFCommunicationReadinessRow(id: "moderation", title: "Moderation Readiness", detail: "Local review and safety checks are prepared.", status: "Local Review", systemImage: "checkmark.shield.fill"),
            HFCommunicationReadinessRow(id: "remote-provider", title: "Remote Communication Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFCommunicationReadinessRow(id: "remote-alerts", title: "Push Notifications", detail: "Not Connected Yet", status: "Future", systemImage: "bell.slash.fill")
        ]
    }

    var communicationModerationRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "local-review", title: "Local review", detail: "Active for local audience updates.", status: "Active", systemImage: "checkmark.circle.fill"),
            HFCommunicationReadinessRow(id: "safety-check", title: "Safety check", detail: "Prepared as a local readiness step.", status: "Local", systemImage: "shield.lefthalf.filled"),
            HFCommunicationReadinessRow(id: "remote-moderation", title: "Remote moderation provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFCommunicationReadinessRow(id: "reporting", title: "Reporting tools", detail: "Not Connected Yet", status: "Future", systemImage: "exclamationmark.bubble.fill"),
            HFCommunicationReadinessRow(id: "abuse-prevention", title: "Abuse prevention", detail: "Future service", status: "Future", systemImage: "lock.shield.fill")
        ]
    }

    var localToRemoteAdapterRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "schema", title: "Channel", detail: selectedAudienceChannelTitle, status: "Local", systemImage: "rectangle.stack.fill"),
            HFCommunicationReadinessRow(id: "catalog", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFCommunicationReadinessRow(id: "profile", title: "Author profile", detail: activeViewingProfile.displayName, status: "Local", systemImage: activeViewingProfile.avatarSymbol),
            HFCommunicationReadinessRow(id: "remote", title: "Remote Communication Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var communicationProofRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "local-adapter-proof", title: "Local Communication Adapter", detail: "Active", status: "Active", systemImage: "point.3.connected.trianglepath.dotted"),
            HFCommunicationReadinessRow(id: "audience-updates-proof", title: "Audience Updates", detail: "Local", status: "Local", systemImage: "text.bubble.fill"),
            HFCommunicationReadinessRow(id: "channels-proof", title: "Channels", detail: "Local", status: "Local", systemImage: "rectangle.stack.fill"),
            HFCommunicationReadinessRow(id: "remote-provider-proof", title: "Remote Communication Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFCommunicationReadinessRow(id: "remote-alerts-proof", title: "Push Notifications", detail: "Not Connected Yet", status: "Future", systemImage: "bell.slash.fill"),
            HFCommunicationReadinessRow(id: "moderation-proof", title: "Moderation Provider", detail: "Not Connected Yet", status: "Future", systemImage: "checkmark.shield.fill")
        ]
    }

    var selectedAudienceChannelTitle: String {
        audienceChannels.first { $0.id == selectedAudienceChannelID }?.title ?? audienceChannels[0].title
    }

    func addAudienceUpdate(body: String, channelID: String? = nil) {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let resolvedChannelID = channelID ?? selectedAudienceChannelID
        selectedAudienceChannelID = resolvedChannelID
        let channelTitle = audienceChannels.first { $0.id == resolvedChannelID }?.title ?? selectedAudienceChannelTitle
        localConnectUpdates.insert("Not Sent • \(channelTitle) • \(featuredMovie.title) • \(activeViewingProfile.displayName): \(trimmed)", at: 0)
        localConnectUpdateDraft = ""
        UserDefaults.standard.set(localConnectUpdates, forKey: connectUpdatesKey)
    }

    func removeAudienceUpdate(id: String) {
        guard let indexText = id.split(separator: "-").last, let index = Int(indexText), localConnectUpdates.indices.contains(index) else { return }
        localConnectUpdates.remove(at: index)
        UserDefaults.standard.set(localConnectUpdates, forKey: connectUpdatesKey)
    }

    func updateStatus(for record: HFAudienceUpdateRecord) -> String {
        record.status
    }

    // hf.services.connectUpdates
    func addLocalConnectUpdate(_ text: String) {
        addAudienceUpdate(body: text, channelID: selectedAudienceChannelID)
    }

    // Launch Campaign Service
    // Local Launch Campaign Adapter
    // Remote Campaign Provider
    // Release Calendar
    // Launch Milestones
    // Local-to-Remote Launch Adapter
    // Campaign Readiness
    // Not Published
    // hf.services.launchCampaign
    // hf.services.localLaunchCampaignAdapter
    // hf.services.remoteCampaignProviderReady
    // hf.services.launchCampaignReadiness
    // hf.services.releaseCalendar
    // hf.services.launchMilestones
    // hf.services.localToRemoteLaunchAdapter
    // hf.services.launchCommunicationBridge
    // hf.services.launchExportHandoff
    var launchCampaignServiceMode: String {
        "Local Launch Campaign Adapter Active"
    }

    var launchCampaignProviderStatus: HFLaunchCampaignProviderStatus {
        .remoteProviderNotConnected
    }

    var localLaunchCampaignAdapterStatus: String {
        "Local Launch Campaign Adapter Active"
    }

    var launchCampaignRecord: HFLaunchCampaignRecord {
        HFLaunchCampaignRecord(
            id: "launch-campaign-\(featuredMovie.id)",
            movieID: featuredMovie.id,
            title: "\(featuredMovie.title) Release Plan",
            audience: "Featured title audience",
            status: launchChecklistProgress == launchChecklistItems.count ? HFLaunchMilestoneStatus.ready.rawValue : HFLaunchMilestoneStatus.localReview.rawValue,
            providerStatus: "Remote Campaign Provider Not Connected Yet",
            updatedAtLabel: "Local campaign plan"
        )
    }

    var releaseCalendarRows: [HFLaunchMilestoneRecord] {
        [
            HFLaunchMilestoneRecord(id: "calendar-package-lock", title: "Package review", detail: "Local release package is in review.", status: "Local Review", systemImage: "checklist.checked"),
            HFLaunchMilestoneRecord(id: "calendar-premiere-copy", title: "Premiere copy", detail: "Copy is prepared locally for the featured title.", status: launchChecklistStates.indices.contains(1) && launchChecklistStates[1] ? "Ready" : "Draft", systemImage: "text.quote"),
            HFLaunchMilestoneRecord(id: "calendar-audience-prompt", title: "Audience prompt", detail: "Communication bridge can use local audience updates.", status: launchChecklistStates.indices.contains(2) && launchChecklistStates[2] ? "Ready" : "Local Review", systemImage: "text.bubble.fill"),
            HFLaunchMilestoneRecord(id: "calendar-handoff", title: "Export handoff", detail: "Delivery summary can support campaign package context.", status: generatedDeliverySummary.isEmpty ? "Local Review" : "Ready", systemImage: "shippingbox.fill")
        ]
    }

    var launchMilestoneRecords: [HFLaunchMilestoneRecord] {
        launchChecklistItems.enumerated().map { index, item in
            HFLaunchMilestoneRecord(
                id: "launch-milestone-\(index)",
                title: item,
                detail: "Structured local milestone for \(featuredMovie.title).",
                status: launchChecklistStates.indices.contains(index) && launchChecklistStates[index] ? HFLaunchMilestoneStatus.ready.rawValue : HFLaunchMilestoneStatus.notPublished.rawValue,
                systemImage: launchChecklistStates.indices.contains(index) && launchChecklistStates[index] ? "checkmark.seal.fill" : "circle.dotted"
            )
        }
    }

    var launchCampaignReadinessRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "local-review", title: "Local review", detail: "Active for launch checklist and milestones.", status: "Active", systemImage: "checkmark.circle.fill"),
            HFLaunchCampaignReadinessRow(id: "communication-adapter", title: "Communication adapter", detail: "Audience update bridge is local.", status: "Active", systemImage: "text.bubble.fill"),
            HFLaunchCampaignReadinessRow(id: "export-handoff", title: "Export handoff", detail: "Delivery summary can support launch package context.", status: "Local", systemImage: "shippingbox.fill"),
            HFLaunchCampaignReadinessRow(id: "remote-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFLaunchCampaignReadinessRow(id: "publishing-tools", title: "Publishing tools", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane"),
            HFLaunchCampaignReadinessRow(id: "audience-access", title: "Audience access tools", detail: "Not Connected Yet", status: "Future", systemImage: "person.badge.key.fill"),
            HFLaunchCampaignReadinessRow(id: "campaign-measurement", title: "Campaign measurement", detail: "Not Connected Yet", status: "Future", systemImage: "chart.bar.xaxis")
        ]
    }

    var localToRemoteLaunchAdapterRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "campaign-record", title: "Campaign record", detail: launchCampaignRecord.title, status: launchCampaignRecord.status, systemImage: "flag.checkered"),
            HFLaunchCampaignReadinessRow(id: "catalog-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFLaunchCampaignReadinessRow(id: "active-profile", title: "Local profile", detail: activeViewingProfile.displayName, status: "Local", systemImage: activeViewingProfile.avatarSymbol),
            HFLaunchCampaignReadinessRow(id: "remote-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var launchCampaignProofRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "local-adapter", title: "Local Launch Campaign Adapter", detail: "Active", status: "Active", systemImage: "flag.checkered"),
            HFLaunchCampaignReadinessRow(id: "release-calendar", title: "Release Calendar", detail: "Local", status: "Local", systemImage: "calendar"),
            HFLaunchCampaignReadinessRow(id: "campaign-milestones", title: "Campaign Milestones", detail: "Local", status: "Local", systemImage: "checklist.checked"),
            HFLaunchCampaignReadinessRow(id: "communication-bridge", title: "Communication Bridge", detail: "Local", status: "Local", systemImage: "text.bubble.fill"),
            HFLaunchCampaignReadinessRow(id: "export-handoff", title: "Export Handoff", detail: "Local", status: "Local", systemImage: "shippingbox.fill"),
            HFLaunchCampaignReadinessRow(id: "remote-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFLaunchCampaignReadinessRow(id: "audience-access", title: "Publishing / Audience Access", detail: "Not Connected Yet", status: "Future", systemImage: "person.badge.key.fill")
        ]
    }

    var launchCommunicationBridgeRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "audience-updates", title: "Local Audience Updates", detail: "\(localAudienceUpdates.count) local records", status: "Local", systemImage: "text.bubble.fill"),
            HFLaunchCampaignReadinessRow(id: "channel", title: "Audience channel", detail: selectedAudienceChannelTitle, status: "Local", systemImage: "rectangle.stack.fill"),
            HFLaunchCampaignReadinessRow(id: "campaign-package", title: "Campaign package", detail: "Local communication bridge ready", status: "Local", systemImage: "arrow.triangle.2.circlepath")
        ]
    }

    var launchExportHandoffRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "delivery-summary", title: "Delivery summary", detail: generatedDeliverySummary.isEmpty ? "Ready to generate" : "Generated locally", status: generatedDeliverySummary.isEmpty ? "Local Review" : "Ready", systemImage: "doc.text.fill"),
            HFLaunchCampaignReadinessRow(id: "featured-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "rectangle.stack.fill"),
            HFLaunchCampaignReadinessRow(id: "campaign-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var campaignPackageSummary: String {
        "\(featuredMovie.title) campaign package is local: \(launchChecklistProgress)/\(launchChecklistItems.count) milestones reviewed, communication bridge local, export handoff local, Remote Campaign Provider Not Connected Yet."
    }

    func markLaunchMilestoneReady(id: String) {
        guard let indexText = id.split(separator: "-").last, let index = Int(indexText), launchChecklistStates.indices.contains(index) else { return }
        toggleLaunchChecklistItem(index, isComplete: true)
    }

    func resetLaunchMilestone(id: String) {
        guard let indexText = id.split(separator: "-").last, let index = Int(indexText), launchChecklistStates.indices.contains(index) else { return }
        toggleLaunchChecklistItem(index, isComplete: false)
    }

    // Export Delivery Service
    // Local Export Delivery Adapter
    // Remote Delivery Provider
    // Delivery Package
    // Delivery Requirements
    // Distribution Handoff
    // Local-to-Remote Export Adapter
    // Export Readiness
    // Not Submitted
    // hf.services.exportDelivery
    // hf.services.localExportDeliveryAdapter
    // hf.services.remoteDeliveryProviderReady
    // hf.services.exportDeliveryReadiness
    // hf.services.deliveryPackage
    // hf.services.deliveryRequirements
    // hf.services.distributionHandoff
    // hf.services.localToRemoteExportAdapter
    // hf.services.exportLaunchHandoff
    // hf.services.exportCommunicationPackage
    var exportDeliveryServiceMode: String {
        "Local Export Delivery Adapter Active"
    }

    var exportDeliveryProviderStatus: HFExportDeliveryProviderStatus {
        .remoteProviderNotConnected
    }

    var localExportDeliveryAdapterStatus: String {
        "Local Export Delivery Adapter Active"
    }

    var deliveryPackageRecord: HFDeliveryPackageRecord {
        HFDeliveryPackageRecord(
            id: "delivery-package-\(featuredMovie.id)",
            movieID: featuredMovie.id,
            title: "\(featuredMovie.title) Delivery Package",
            ownerProfileID: activeViewingProfile.id,
            summary: generatedDeliverySummary.isEmpty ? "Local delivery summary ready to generate." : generatedDeliverySummary,
            status: generatedDeliverySummary.isEmpty ? HFDeliveryPackageStatus.localReview.rawValue : HFDeliveryPackageStatus.ready.rawValue,
            providerStatus: "Remote Delivery Provider Not Connected Yet",
            updatedAtLabel: generatedDeliverySummary.isEmpty ? "Local review" : "Generated locally"
        )
    }

    var deliveryRequirementRows: [HFDeliveryRequirementRecord] {
        [
            HFDeliveryRequirementRecord(id: "poster-artwork", title: "Poster / artwork checklist", detail: "Local readiness notes only.", status: "Local", systemImage: "photo.stack.fill"),
            HFDeliveryRequirementRecord(id: "festival-synopsis", title: "Festival synopsis", detail: "Local summary copy can support review.", status: "Local", systemImage: "rosette"),
            HFDeliveryRequirementRecord(id: "platform-notes", title: "Platform notes", detail: "Provider-ready notes without live submission.", status: "Local", systemImage: "checklist.checked"),
            HFDeliveryRequirementRecord(id: "accessibility-copy", title: "Accessibility copy", detail: "Local text readiness for future packages.", status: "Local", systemImage: "textformat.alt"),
            HFDeliveryRequirementRecord(id: "final-media-asset", title: "Final media asset", detail: "Source required before delivery media exists.", status: "Not Connected Yet", systemImage: "play.slash.fill")
        ]
    }

    var distributionHandoffRows: [HFDistributionHandoffRecord] {
        [
            HFDistributionHandoffRecord(id: "launch-handoff", title: "Launch campaign handoff", detail: "Local campaign package can inform delivery notes.", status: "Local", systemImage: "flag.checkered"),
            HFDistributionHandoffRecord(id: "communication-package", title: "Communication package", detail: "Local audience updates can inform package context.", status: "Local", systemImage: "text.bubble.fill"),
            HFDistributionHandoffRecord(id: "catalog-identity", title: "Catalog identity", detail: featuredMovie.title, status: "Active", systemImage: "rectangle.stack.fill"),
            HFDistributionHandoffRecord(id: "cloud-library", title: "Cloud library boundary", detail: "Saved title state remains local.", status: "Local", systemImage: "bookmark.fill"),
            HFDistributionHandoffRecord(id: "remote-distribution", title: "Remote distribution provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var exportDeliveryReadinessRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "local-review", title: "Local review", detail: "Active for delivery package text.", status: "Active", systemImage: "checkmark.circle.fill"),
            HFExportDeliveryReadinessRow(id: "catalog-identity", title: "Catalog identity", detail: featuredMovie.title, status: "Active", systemImage: "rectangle.stack.fill"),
            HFExportDeliveryReadinessRow(id: "launch-handoff", title: "Launch campaign handoff", detail: "Local campaign adapter connected.", status: "Local", systemImage: "flag.checkered"),
            HFExportDeliveryReadinessRow(id: "communication-package", title: "Communication package", detail: "Local audience updates connected.", status: "Local", systemImage: "text.bubble.fill"),
            HFExportDeliveryReadinessRow(id: "cloud-library", title: "Cloud library boundary", detail: "Local library state can identify selected titles.", status: "Local", systemImage: "bookmark.fill"),
            HFExportDeliveryReadinessRow(id: "remote-provider", title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFExportDeliveryReadinessRow(id: "platform-submission", title: "Platform Submission", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane"),
            HFExportDeliveryReadinessRow(id: "media-render-file-export", title: "Media Render / File Export", detail: "Not Connected Yet", status: "Future", systemImage: "shippingbox.fill")
        ]
    }

    var localToRemoteExportAdapterRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "package-record", title: "Delivery Package", detail: deliveryPackageRecord.title, status: deliveryPackageRecord.status, systemImage: "shippingbox.fill"),
            HFExportDeliveryReadinessRow(id: "catalog-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFExportDeliveryReadinessRow(id: "active-profile", title: "Local profile", detail: activeViewingProfile.displayName, status: "Local", systemImage: activeViewingProfile.avatarSymbol),
            HFExportDeliveryReadinessRow(id: "remote-provider", title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var exportDeliveryProofRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "local-adapter", title: "Local Export Delivery Adapter", detail: "Active", status: "Active", systemImage: "shippingbox.fill"),
            HFExportDeliveryReadinessRow(id: "delivery-package", title: "Delivery Package", detail: "Local", status: "Local", systemImage: "doc.text.fill"),
            HFExportDeliveryReadinessRow(id: "distribution-handoff", title: "Distribution Handoff", detail: "Local", status: "Local", systemImage: "arrow.triangle.2.circlepath"),
            HFExportDeliveryReadinessRow(id: "launch-handoff", title: "Launch Campaign Handoff", detail: "Local", status: "Local", systemImage: "flag.checkered"),
            HFExportDeliveryReadinessRow(id: "remote-provider", title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFExportDeliveryReadinessRow(id: "platform-submission", title: "Platform Submission", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane"),
            HFExportDeliveryReadinessRow(id: "media-render-file-export", title: "Media Render / File Export", detail: "Not Connected Yet", status: "Future", systemImage: "video.slash.fill")
        ]
    }

    var exportLaunchHandoffRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "campaign-package", title: "Launch campaign plan", detail: launchCampaignRecord.title, status: launchCampaignRecord.status, systemImage: "flag.checkered"),
            HFExportDeliveryReadinessRow(id: "release-calendar", title: "Release Calendar", detail: "\(releaseCalendarRows.count) local rows", status: "Local", systemImage: "calendar"),
            HFExportDeliveryReadinessRow(id: "delivery-package", title: "Delivery Package", detail: deliveryPackageRecord.status, status: "Local", systemImage: "shippingbox.fill")
        ]
    }

    var exportCommunicationPackageRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "audience-updates", title: "Local Audience Updates", detail: "\(localAudienceUpdates.count) local records", status: "Local", systemImage: "text.bubble.fill"),
            HFExportDeliveryReadinessRow(id: "channel", title: "Audience channel", detail: selectedAudienceChannelTitle, status: "Local", systemImage: "rectangle.stack.fill"),
            HFExportDeliveryReadinessRow(id: "delivery-notes", title: "Delivery notes", detail: "Audience context can inform local package notes.", status: "Local", systemImage: "note.text")
        ]
    }

    var exportCatalogContextRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "catalog-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFExportDeliveryReadinessRow(id: "player-source", title: "Player source boundary", detail: playbackSource(for: featuredMovie).readinessLabel, status: "Source", systemImage: "play.rectangle.fill"),
            HFExportDeliveryReadinessRow(id: "library-boundary", title: "Cloud Library boundary", detail: isSaved(featuredMovie) ? "Saved locally" : "Ready for local saved state", status: "Local", systemImage: "bookmark.fill"),
            HFExportDeliveryReadinessRow(id: "offline-boundary", title: "Offline state boundary", detail: "Offline state does not create delivery media files.", status: "Local", systemImage: "arrow.down.circle.fill")
        ]
    }

    func updateDeliveryPackageStatus(_ status: HFDeliveryPackageStatus) -> String {
        status.rawValue
    }

    // Payment + Entitlement Service
    // Local Entitlement Adapter
    // Remote Payment Provider
    // Store Provider
    // Access Tiers
    // Entitlement Readiness
    // Local Preview Only
    // No Purchase Active
    // hf.services.paymentEntitlement
    // hf.services.localEntitlementAdapter
    // hf.services.remotePaymentProviderReady
    // hf.services.storeProviderReady
    // hf.services.entitlementReadiness
    // hf.services.accessTiers
    // hf.services.localToRemotePaymentAdapter
    // hf.services.playerEntitlementBoundary
    // hf.services.libraryEntitlementBoundary
    // hf.services.downloadEntitlementBoundary
    // hf.services.exportEntitlementBoundary
    // hf.services.launchEntitlementBoundary
    var paymentEntitlementServiceMode: String {
        entitlementRuntimeStatus.statusLabel
    }

    var localEntitlementAdapterStatus: String {
        "Local Preview Access"
    }

    var paymentProviderStatus: HFPaymentProviderStatus {
        entitlementRuntimeStatus.accessState == .localPreviewAccess ? .localAdapterActive : .remoteProviderNotConnected
    }

    var storeProviderStatus: String {
        entitlementRuntimeStatus.restoreState.statusLabel
    }

    var activeProfileAccessTier: String {
        "\(activeViewingProfile.displayName) - Local Preview Access"
    }

    var accessTierRows: [HFAccessTierRecord] {
        [
            HFAccessTierRecord(id: "viewer-preview", title: "Viewer Preview", detail: "Streaming shell access is represented locally.", status: "Local Preview Access", systemImage: "person.crop.circle.fill"),
            HFAccessTierRecord(id: "highfive-originals", title: "HighFive Originals", detail: "Original title scope is organized locally.", status: "Local Preview Access", systemImage: "sparkles.tv.fill"),
            HFAccessTierRecord(id: "creator-package", title: "Creator Package", detail: "Export and launch package scope remains local.", status: "Local Preview Access", systemImage: "shippingbox.fill")
        ]
    }

    var entitlementRecords: [HFEntitlementRecord] {
        [
            HFEntitlementRecord(id: "featured-title", title: featuredMovie.title, scope: "Movie access scope", status: HFEntitlementStatus.localPreview.rawValue, detail: "No server validation. Watch Now remains available.", systemImage: "play.rectangle.fill"),
            HFEntitlementRecord(id: "library-shelf", title: "Library shelf", scope: "Saved title access", status: HFEntitlementStatus.localPreview.rawValue, detail: "Saved state uses local readiness only.", systemImage: "bookmark.fill"),
            HFEntitlementRecord(id: "offline-state", title: "Offline shelf", scope: "Downloads access", status: HFEntitlementStatus.notValidated.rawValue, detail: "Offline state is local and not provider validated.", systemImage: "arrow.down.circle.fill")
        ]
    }

    var paymentReadinessRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "local-adapter", title: "Local Entitlement Adapter", detail: "Active", status: "Local Preview Access", systemImage: "checkmark.shield.fill"),
            HFPaymentReadinessRow(id: "access-tiers", title: "Access Tiers", detail: "\(accessTierRows.count) local preview rows", status: "Local Preview Access", systemImage: "rectangle.3.group.fill"),
            HFPaymentReadinessRow(id: "profile-access", title: "Profile Access", detail: activeProfileAccessTier, status: entitlementRuntimeStatus.statusLabel, systemImage: activeViewingProfile.avatarSymbol),
            HFPaymentReadinessRow(id: "storekit-paywall-source", title: "StoreKit / Paywall Source", detail: storeKitPaywallSourceSummary, status: "Mapped", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "player-boundary", title: "Player Entitlement Boundary", detail: "Local", status: "Local", systemImage: "play.rectangle.fill"),
            HFPaymentReadinessRow(id: "library-downloads", title: "Library / Downloads Access Boundary", detail: "Local", status: "Local", systemImage: "bookmark.fill"),
            HFPaymentReadinessRow(id: "export-launch", title: "Export / Launch Package Access", detail: "Local", status: "Local", systemImage: "shippingbox.fill"),
            HFPaymentReadinessRow(id: "remote-payment", title: "Payment Provider", detail: entitlementRuntimeStatus.paymentProviderLabel, status: "Provider-ready", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store Provider", detail: entitlementRuntimeStatus.restoreState.statusLabel, status: "Provider-ready", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server Entitlement Validation", detail: entitlementRuntimeStatus.boundary.detail, status: "Required", systemImage: "lock.slash.fill")
        ]
    }

    var playbackDescriptorReadinessRows: [HFPaymentReadinessRow] {
        let response = entitlementGatedPlaybackDescriptor(for: continueWatchingMovie)
        let contract = backendPlaybackDescriptorContract(for: continueWatchingMovie)
        return [
            HFPaymentReadinessRow(
                id: "backend-entitlement-validation",
                title: "Backend entitlement validation required",
                detail: "POST \(HFBackendPlaybackDescriptorEndpoint.entitlementValidationPath) for \(contract.entitlementValidationRequest.movieID)",
                status: contract.entitlementValidationResponse.entitlementStatus.statusLabel,
                systemImage: "checkmark.shield.fill"
            ),
            HFPaymentReadinessRow(
                id: "backend-playback-contract",
                title: "Backend playback descriptor endpoint required",
                detail: contract.playbackDescriptorRequest.endpoint.detail,
                status: contract.statusLabel,
                systemImage: "server.rack"
            ),
            HFPaymentReadinessRow(
                id: "server-validation-pending",
                title: "Server entitlement validation pending",
                detail: "Contract is staged without a live backend URL.",
                status: contract.policy.backendURLPolicy,
                systemImage: "clock.badge.checkmark.fill"
            ),
            HFPaymentReadinessRow(
                id: "entitlement-gate",
                title: "Entitlement gate required",
                detail: "Playback descriptor requires entitlement before provider playback can be approved.",
                status: response.gateStatus.statusLabel,
                systemImage: "lock.shield.fill"
            ),
            HFPaymentReadinessRow(
                id: "backend-descriptor",
                title: "Backend descriptor required",
                detail: response.request.backendRequirement.detail,
                status: response.request.backendRequirement.status.statusLabel,
                systemImage: "server.rack"
            ),
            HFPaymentReadinessRow(
                id: "cloudflare-descriptor",
                title: "Cloudflare descriptor not connected",
                detail: "Cloudflare playback requires backend descriptor. No Cloudflare token in app.",
                status: response.cloudflareState.statusLabel,
                systemImage: "network.slash"
            ),
            HFPaymentReadinessRow(
                id: "staging-playback-adapter",
                title: "Staging backend not configured",
                detail: "Staging adapter builds endpoint URLs from runtime config only and keeps Local Preview fallback active when config is missing.",
                status: backendPlaybackDescriptorRequestState.statusLabel,
                systemImage: "rectangle.connected.to.line.below"
            ),
            HFPaymentReadinessRow(
                id: "server-side-cloudflare-signing",
                title: "Server-side Cloudflare signing required",
                detail: "No Cloudflare token in app. Descriptor references are memory-only and not shown.",
                status: "No Cloudflare token in app",
                systemImage: "lock.shield.fill"
            ),
            HFPaymentReadinessRow(
                id: "backend-mediated",
                title: "Playback Descriptor",
                detail: "Cloudflare signed token generated server-side",
                status: "No Cloudflare token in app",
                systemImage: "play.rectangle.on.rectangle.fill"
            )
        ]
    }

    var storeKitPaywallSourceSummary: String {
        "\(HFStoreKitPaywallCatalog.mappings.count) product IDs imported as staging metadata"
    }

    var storeKitPaywallMappings: [HFStoreKitProductMapping] {
        HFStoreKitPaywallCatalog.mappings
    }

    var storeKitAccessRules: [HFMovieAccessRule] {
        HFStoreKitAccessMapping.rules
    }

    func storeKitPaywallMapping(for movie: Movie) -> HFStoreKitProductMapping? {
        HFStoreKitPaywallCatalog.mapping(forCurrentMovieID: movie.id)
    }

    func storeKitEpisodeMappings(for movie: Movie) -> [HFStoreKitProductMapping] {
        HFStoreKitPaywallCatalog.episodeMappings(forCurrentMovieID: movie.id)
    }

    func storeKitAccessRule(for movie: Movie) -> HFMovieAccessRule {
        HFStoreKitAccessMapping.rule(forCurrentMovieID: movie.id)
    }

    func playbackEntitlementContext(for movie: Movie) -> HFPlaybackDescriptorEntitlementContext {
        HFStoreKitAccessMapping.context(forCurrentMovieID: movie.id)
    }

    var localToRemotePaymentAdapterRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "local-profile", title: "Local profile", detail: activeViewingProfile.displayName, status: "Active", systemImage: activeViewingProfile.avatarSymbol),
            HFPaymentReadinessRow(id: "access-tier-record", title: "Access tier record", detail: activeProfileAccessTier, status: "Local Preview Access", systemImage: "rectangle.3.group.fill"),
            HFPaymentReadinessRow(id: "movie-access-scope", title: "Movie access scope", detail: featuredMovie.title, status: "Local", systemImage: "film.stack.fill"),
            HFPaymentReadinessRow(id: "player-boundary", title: "Player boundary", detail: "Local entitlement readiness only", status: "Local", systemImage: "play.rectangle.fill"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store Provider", detail: "Not Connected Yet", status: "Future", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "remote-payment-provider", title: "Remote Payment Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server entitlement validation", detail: "Not Connected Yet", status: "Future", systemImage: "lock.slash.fill")
        ]
    }

    var playerEntitlementBoundaryRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "catalog-identity", title: "Catalog identity", detail: featuredMovie.title, status: "Active", systemImage: "rectangle.stack.fill"),
            HFPaymentReadinessRow(id: "player-route", title: "Player route", detail: "Active", status: "Active", systemImage: "play.rectangle.fill"),
            HFPaymentReadinessRow(id: "local-entitlement-adapter", title: "Local entitlement adapter", detail: "Active", status: "Active", systemImage: "checkmark.shield.fill"),
            HFPaymentReadinessRow(id: "remote-payment-provider", title: "Remote payment provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store provider", detail: "Not Connected Yet", status: "Future", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server entitlement validation", detail: "Not Connected Yet", status: "Future", systemImage: "lock.slash.fill")
        ]
    }

    var libraryEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "saved-titles", title: "Saved titles", detail: "\(savedMovies.count) local records", status: "Local", systemImage: "bookmark.fill"),
            HFPaymentReadinessRow(id: "access-boundary", title: "Access Boundary", detail: "Saved titles use local entitlement readiness only.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var downloadEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "offline-state", title: "Offline state", detail: "\(downloadedMovies.count) local records", status: "Local", systemImage: "arrow.down.circle.fill"),
            HFPaymentReadinessRow(id: "offline-access", title: "Offline Access Boundary", detail: "Real entitlement validation is not connected yet.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var exportEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "delivery-package", title: "Delivery package", detail: deliveryPackageRecord.title, status: "Local", systemImage: "shippingbox.fill"),
            HFPaymentReadinessRow(id: "access-boundary", title: "Delivery Access Boundary", detail: "Payment and entitlement providers are not connected yet.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var launchEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "campaign-package", title: "Campaign package", detail: launchCampaignRecord.title, status: "Local", systemImage: "flag.checkered"),
            HFPaymentReadinessRow(id: "access-boundary", title: "Campaign Access Boundary", detail: "Payment and entitlement providers are not connected yet.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var paymentProofRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "local-adapter", title: "Local Entitlement Adapter", detail: "Active", status: "Active", systemImage: "checkmark.shield.fill"),
            HFPaymentReadinessRow(id: "access-tiers", title: "Access Tiers", detail: "Local Preview Access", status: "Local Preview Access", systemImage: "rectangle.3.group.fill"),
            HFPaymentReadinessRow(id: "remote-payment-provider", title: "Remote Payment Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store Provider", detail: "Not Connected Yet", status: "Future", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server Entitlement Validation", detail: "Not Connected Yet", status: "Future", systemImage: "lock.slash.fill")
        ]
    }

    func entitlementStatus(for movie: Movie) -> HFEntitlementStatus {
        entitlementRuntimeStatus.accessState == .entitlementConfigured ? .notValidated : (movie.isComingSoon ? .providerRequired : .localPreview)
    }

    func entitlementCopy(for movie: Movie) -> String {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        return "\(catalogMovie.title) uses \(entitlementRuntimeStatus.statusLabel). \(entitlementRuntimeStatus.boundary.detail)"
    }

    // hf.services.launchChecklist
    var launchChecklistProgress: Int {
        launchChecklistStates.filter { $0 }.count
    }

    func toggleLaunchChecklistItem(_ index: Int, isComplete: Bool) {
        guard launchChecklistStates.indices.contains(index) else { return }
        launchChecklistStates[index] = isComplete
        UserDefaults.standard.set(launchChecklistStates, forKey: launchChecklistKey)
    }

    // hf.services.exportSummary
    func generateDeliverySummary(for movie: Movie? = nil) {
        let selectedMovie = movie ?? featuredMovie
        generatedDeliverySummary = """
        HighFive Cinema Delivery Summary
        Title: \(selectedMovie.title)
        Watch surface: Movie Detail, Watch Now path, related titles, and My List route.
        Launch handoff: Campaign headline, premiere copy, audience prompt, media kit, and release calendar reviewed locally.
        Communication package: \(localAudienceUpdates.count) local audience updates, \(selectedAudienceChannelTitle) channel context, Remote Delivery Provider Not Connected Yet.
        Export package: Delivery Package, Delivery Requirements, Distribution Handoff, and Local-to-Remote Export Adapter are ready for text review.
        Status: \(HFDeliveryPackageStatus.notSubmitted.rawValue), local summary only.
        """
    }

    var currentFunctionalProofRows: [String] {
        [
            "\(savedMovies.count) saved titles",
            "\(downloadedMovies.count) offline-ready titles",
            "Active local profile: \(activeViewingProfile.displayName)",
            "\(localConnectUpdates.count) local updates",
            "\(launchChecklistProgress)/\(launchChecklistItems.count) launch items reviewed",
            generatedDeliverySummary.isEmpty ? "Delivery summary ready to generate" : "Delivery summary generated"
        ]
    }

    private var scopedSavedKey: String {
        Self.scopedKey(savedKey, activeProfileID)
    }

    private var scopedDownloadsKey: String {
        Self.scopedKey(downloadsKey, activeProfileID)
    }

    private func persist(_ ids: Set<String>, key: String) {
        UserDefaults.standard.set(Array(ids).sorted(), forKey: key)
    }

    private static func scopedKey(_ base: String, _ profileID: String) -> String {
        "\(base).\(profileID)"
    }

    private static let localPreviewStreamingIDs: Set<String> = [
        "friendly",
        "paranormall-s1"
    ]

    private static func loadProfileIDs(defaults: UserDefaults, scopedKey: String, fallbackKey: String, fallbackIDs: Set<String>) -> Set<String> {
        if let scoped = defaults.stringArray(forKey: scopedKey) {
            return Set(scoped)
        }
        if let fallback = defaults.stringArray(forKey: fallbackKey) {
            return Set(fallback)
        }
        return fallbackIDs
    }

    private static func makeCreatorPublishingContents() -> [HFCreatorPublishingContent] {
        [
            HFCreatorPublishingContent(
                id: "creator-pipeline-night-file",
                title: "The Night File: Creator Cut",
                description: "A compact thriller package moving from local edit notes into metadata, poster, and trailer review.",
                posterAssetName: nil,
                trailerStatus: .placeholder,
                creator: "HighFive Cinema",
                genre: "Thriller",
                tags: ["Creator", "Pipeline", "Mystery"],
                runtime: "44m",
                releaseState: .draft,
                posterStatus: .placeholder,
                metadataStatus: .ready,
                artworkStatus: .needsReview,
                updatedAtLabel: "Draft saved locally"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-behind-vision",
                title: "Behind the Vision: Studio Notes",
                description: "A creator documentary package with metadata, poster, and trailer materials ready for local review.",
                posterAssetName: "poster_artist_development_coming_soon",
                trailerStatus: .ready,
                creator: "HighFive Cinema",
                genre: "Documentary",
                tags: ["Creator Spotlight", "Original"],
                runtime: "22m",
                releaseState: .review,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .ready,
                updatedAtLabel: "Ready for review"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-maple-street",
                title: "Maple Street: Premiere Preview",
                description: "A scheduled creator release preview for the local catalog, campaign, and collection surfaces.",
                posterAssetName: "poster_maple_street_coming_soon",
                trailerStatus: .ready,
                creator: "In The Light Productions",
                genre: "Mystery",
                tags: ["Premiere", "Collection"],
                runtime: "Limited Series",
                releaseState: .scheduled,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .ready,
                updatedAtLabel: "Scheduled preview"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-friendly-commentary",
                title: "The Friendly: Creator Commentary",
                description: "A published local creator title that now appears in Home, Search, Discovery rails, collections, and creator surfaces.",
                posterAssetName: "the_friendly",
                trailerStatus: .ready,
                creator: "HigherKey Inc.",
                genre: "Drama",
                tags: ["Commentary", "Creator", "Published"],
                runtime: "31m",
                releaseState: .published,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .ready,
                updatedAtLabel: "Published to local discovery"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-archive",
                title: "Artist Development: Early Assembly",
                description: "Archived creator package retained for local library history and excluded from discovery.",
                posterAssetName: "poster_artist_development_coming_soon",
                trailerStatus: .needsReview,
                creator: "HigherKey Studios",
                genre: "Documentary",
                tags: ["Archive", "Music"],
                runtime: "18m",
                releaseState: .archived,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .needsReview,
                updatedAtLabel: "Archived locally"
            )
        ]
    }

    private static func makeLocalProfiles(defaults: UserDefaults) -> [HFLocalViewingProfile] {
        [
            HFLocalViewingProfile(
                id: "profile-michael",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-michael") ?? "Michael",
                role: "Viewer",
                avatarSymbol: "person.crop.circle.fill",
                accentName: "Gold"
            ),
            HFLocalViewingProfile(
                id: "profile-family",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-family") ?? "Family",
                role: "Family",
                avatarSymbol: "person.2.circle.fill",
                accentName: "Orange"
            ),
            HFLocalViewingProfile(
                id: "profile-creator",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-creator") ?? "Creator",
                role: "Creator",
                avatarSymbol: "video.circle.fill",
                accentName: "Cyan"
            )
        ]
    }
}
