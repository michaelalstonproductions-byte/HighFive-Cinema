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
        let savedLaunchStates = defaults.array(forKey: launchChecklistKey) as? [Bool]
        launchChecklistStates = savedLaunchStates?.count == launchChecklistItems.count ? savedLaunchStates ?? [] : Array(repeating: false, count: launchChecklistItems.count)
        generatedDeliverySummary = ""
        lastPlayerMovieID = defaults.string(forKey: lastPlayerMovieKey)
        selectedAudienceChannelID = "premiere-updates"
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
            playbackDescriptorBackendServiceStatus,
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
        let response = entitlementGatedPlaybackDescriptor(for: continueWatchingMovie)
        let backendState: HFBackendConnectionState = response.gateStatus == .cloudflareDescriptorReady ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "playback-descriptor",
            title: "Playback Descriptor",
            detail: "\(response.gateStatus.statusLabel). Backend-mediated playback only. No Cloudflare token in app.",
            state: backendState,
            statusLabel: response.cloudflareState.statusLabel,
            systemImage: "lock.rectangle.stack.fill",
            accessibilityIdentifier: "hf.backendStatus.playbackDescriptor"
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
        HFMockData.movies
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

    var newThisWeekCatalog: [Movie] {
        ["friendly", "paranormall-s1", "behind-vision", "artist-development", "big-loss"].compactMap(movie(id:))
    }

    var downloadableCatalog: [Movie] {
        allCatalogMovies.filter { isDownloaded($0) || $0.isDownloaded }
    }

    var premiumHomeCatalogRails: [Category] {
        [
            Category(id: "new-this-week", title: "New This Week", subtitle: "Fresh HighFive picks", movies: newThisWeekCatalog),
            Category(id: "continue-watching", title: "Continue Watching", subtitle: "Pick up where you left off", movies: allCatalogMovies.filter { $0.progress != nil }),
            Category(id: "recommended", title: "Recommended", subtitle: "Selected for your viewing profile", movies: ["black-turnip", "sunshine", "arrival-time", "maple-street", "night-file"].compactMap(movie(id:))),
            Category(id: "only-on-highfive", title: "Only On HighFive", subtitle: "Originals and local showcase titles", movies: originalsCatalog)
        ]
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

    func searchMovies(query: String, filter: String) -> [Movie] {
        let base: [Movie]
        switch filter {
        case "Movies":
            base = allCatalogMovies.filter { !$0.duration.localizedCaseInsensitiveContains("episode") }
        case "Series":
            base = allCatalogMovies.filter { $0.duration.localizedCaseInsensitiveContains("episode") || $0.genres.contains("Series") }
        case "Originals":
            base = originalsCatalog
        case "Downloaded":
            base = downloadedMovies
        default:
            base = allCatalogMovies
        }

        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else {
            return Array(base.prefix(8))
        }

        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchTerm) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchTerm) ||
            $0.genres.joined(separator: " ").localizedCaseInsensitiveContains(searchTerm)
        }
    }

    func catalogRails(filter: String = "All") -> [Category] {
        let rails = [
            Category(id: "trending", title: "Trending Now", subtitle: nil, movies: ["friendly", "paranormall-s1", "black-turnip", "big-loss", "artist-development", "bleu-velvet"].compactMap(movie(id:))),
            Category(id: "originals", title: "HighFive Originals", subtitle: "Premium original films and series", movies: originalsCatalog.filter { !$0.isComingSoon }),
            Category(id: "fresh-finds", title: "Fresh Finds", subtitle: "New from the HighFive slate", movies: Array(allCatalogMovies.suffix(10))),
            Category(id: "coming-soon", title: "Coming Soon", subtitle: "Scripted originals in development", movies: allCatalogMovies.filter { $0.isComingSoon }),
            Category(id: "my-movies", title: "My Movies", subtitle: "Saved and local titles", movies: allCatalogMovies.filter { isDownloaded($0) || $0.progress != nil })
        ]

        switch filter {
        case "Originals":
            return rails.filter { $0.id == "originals" }
        case "Drama", "Thriller", "Mystery", "Documentary":
            return [Category(id: filter.lowercased(), title: "\(filter) Picks", subtitle: nil, movies: allCatalogMovies.filter { $0.genres.contains(filter) })]
        case "Coming Soon":
            return rails.filter { $0.id == "coming-soon" }
        default:
            return rails
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
        return [
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
                id: "backend-mediated",
                title: "Playback Descriptor",
                detail: "Backend-mediated playback only",
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
